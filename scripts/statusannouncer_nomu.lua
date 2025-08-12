local WHISPER = false
local WHISPER_ONLY = false
local EXPLICIT = true
local OVERRIDEB = true
local OVERRIDESELECT = true
local SHOWDURABILITY = true
local SHOWPROTOTYPER = true
local SHOWEMOJI = true

local setters = {
    WHISPER = function(v)
        WHISPER = v
    end,
    WHISPER_ONLY = function(v)
        WHISPER_ONLY = v
    end,
    EXPLICIT = function(v)
        EXPLICIT = v
    end,
    OVERRIDEB = function(v)
        OVERRIDEB = v
    end,
    OVERRIDESELECT = function(v)
        OVERRIDESELECT = v
    end,
    SHOWDURABILITY = function(v)
        SHOWDURABILITY = v
    end,
    SHOWPROTOTYPER = function(v)
        SHOWPROTOTYPER = v
    end,
    SHOWEMOJI = function(v)
        SHOWEMOJI = v
    end,
}

local needs_strings = {
    NEEDSCIENCEMACHINE = "RESEARCHLAB",
    NEEDALCHEMYENGINE = "RESEARCHLAB2",
    NEEDSHADOWMANIPULATOR = "RESEARCHLAB3",
    NEEDPRESTIHATITATOR = "RESEARCHLAB4",
    NEEDSANCIENT_FOUR = "ANCIENT_ALTAR",
    NEEDSFISHING = "钓具容器",
    NEEDCARNIVAL_HOSTSHOP_PLAZA = "鸦年华树苗",
    NEEDSSEAFARING_STATION = "智囊团",
    NEEDSSPIDERFRIENDSHIP = "特殊蜘蛛",
}

local hint_text = {
    ["NEEDSSCIENCEMACHINE"] = "NEEDSCIENCEMACHINE",
    ["NEEDSALCHEMYMACHINE"] = "NEEDALCHEMYENGINE",
    ["NEEDSSHADOWMANIPULATOR"] = "NEEDSHADOWMANIPULATOR",
    ["NEEDSPRESTIHATITATOR"] = "NEEDPRESTIHATITATOR",
    ["NEEDSANCIENTALTAR_HIGH"] = "NEEDSANCIENT_FOUR",
    ["NEEDSSPIDERCRAFT"] = "NEEDSSPIDERFRIENDSHIP",
}

local StatusAnnouncerNoMu = Class(function(self)
    self.cooldown = false
    self.cooldowns = {}
    self.stats = {}
    self.button_to_stat = {}
    self.char_messages = STRINGS._STATUS_ANNOUNCEMENTS_NOMU.UNKNOWN
end,
        nil,
        {
        })

local function CountItemWithName(container, name, prefab)
    local num_found = 0
    local items = container:GetItems()
    for _, v in pairs(items) do
        if v and v.prefab == prefab and v:GetDisplayName() == name then
            if v.replica.stackable ~= nil then
                num_found = num_found + v.replica.stackable:StackSize()
            else
                num_found = num_found + 1
            end
        end
    end

    if container.GetActiveItem then
        local active_item = container:GetActiveItem()
        if active_item and active_item.prefab == prefab and active_item:GetDisplayName() == name then
            if active_item.replica.stackable ~= nil then
                num_found = num_found + active_item.replica.stackable:StackSize()
            else
                num_found = num_found + 1
            end
        end
    end

    if container.GetOverflowContainer then
        local overflow = container:GetOverflowContainer()
        if overflow ~= nil then
            local overflow_found = CountItemWithName(overflow, name, prefab)
            num_found = num_found + overflow_found
        end
    end

    return num_found
end

function StatusAnnouncerNoMu:Announce(message)
    local whisper = TheInput:IsKeyDown(KEY_CTRL) or TheInput:IsControlPressed(CONTROL_MENU_MISC_3)
    TheNet:Say(STRINGS.LMB .. " " .. message, WHISPER_ONLY or WHISPER ~= whisper)
    return true
end

local function get_container_name(container)
    if not container then
        return
    end
    local container_name = container:GetBasicDisplayName()
    local container_prefab = container and container.prefab
    local underscore_index = container_prefab and container_prefab:find("_container")
    --container name was empty or blank, and matches the bundle container prefab naming system
    if type(container_name) == "string" and container_name:find("^%s*$") and underscore_index then
        container_name = STRINGS.NAMES[container_prefab:sub(1, underscore_index - 1):upper()]
    end
    return container_name and container_name:lower()
end

function StatusAnnouncerNoMu:AnnounceItem(slot)
    local item = slot.tile.item
    local container = slot.container
    local percent = nil
    local percent_type = nil
    if slot.tile.percent then
        percent = slot.tile.percent:GetString()
        percent_type = "DURABILITY"
    elseif slot.tile.hasspoilage then
        percent = math.floor(item.replica.inventoryitem.classified.perish:value() * (1 / .62)) .. "%"
        percent_type = "FRESHNESS"
    end
    local S = STRINGS._STATUS_ANNOUNCEMENTS_NOMU._NOMU --To save some table lookups
    if container == nil or (container and container.type == "pack") then
        --\equipslots/        \backpacks/
        container = ThePlayer.replica.inventory
    end
    local num_equipped = 0
    local num_equipped_name = 0
    if not container.type then
        --this is an inventory
        --add in items in equipslots, which don't normally get counted by Has
        for _, slot in pairs(EQUIPSLOTS) do
            local equipped_item = container:GetEquippedItem(slot)
            if equipped_item and equipped_item.prefab == item.prefab then
                num_equipped = num_equipped + (equipped_item.replica.stackable and equipped_item.replica.stackable:StackSize() or 1)
                if equipped_item.name == item.name then
                    num_equipped_name = num_equipped_name + (equipped_item.replica.stackable and equipped_item.replica.stackable:StackSize() or 1)
                end
            end
        end
    end
    local container_name = get_container_name(container.type and container.inst)
    -- Try to trace the path from construction container to the constructionsite that spawned it
    if not container_name then
        if not container_name then
            local player = container.inst.entity:GetParent()
            local constructionbuilder = player and player.components and player.components.constructionbuilder
            if constructionbuilder and constructionbuilder.constructionsite then
                container_name = get_container_name(constructionbuilder.constructionsite)
            end
        end
    end
    local name = item.prefab and STRINGS.NAMES[item.prefab:upper()] or '<未命名>'
    local has, num_found = container:Has(item.prefab, 1)
    local num_found_name = CountItemWithName(container, item:GetDisplayName(), item.prefab)
    num_found_name = num_found_name + num_equipped_name
    num_found = num_found + num_equipped
    local i_have = ""
    local in_this = ""
    if container_name then
        -- this is a chest
        i_have = S.ANNOUNCE_ITEM.WE_HAVE
        in_this = S.ANNOUNCE_ITEM.IN_THIS
    else
        -- this is a backpack or inventory
        i_have = S.ANNOUNCE_ITEM.I_HAVE
        container_name = ""
    end
    local this_many = "" .. num_found
    local plural = num_found > 1
    local with = ""
    local durability = ""
    if SHOWDURABILITY and percent then
        with = plural
                and S.ANNOUNCE_ITEM.AND_THIS_ONE_HAS
                or S.ANNOUNCE_ITEM.WITH
        durability = percent and S.ANNOUNCE_ITEM[percent_type]
    else
        percent = ""
    end
    local a = S.getArticle(name)
    local s = S.S
    if (not plural) or string.find(name, s .. "$") ~= nil then
        s = ""
    end
    if this_many == nil or this_many == "1" then
        this_many = a
    end
    local nomu_state = ''
    if item.prefab == 'heatrock' then
        --'heatrock_fantasy', 'heat_rock', 'heatrock_fire'
        -- hash('heatrock_fantasy3.tex')
        local temp_range = {
            [4264163310] = 1, [3706253814] = 1, [2098310090] = 1,
            [1108760303] = 2, [550850807] = 2, [3237874379] = 2,
            [2248324592] = 3, [1690415096] = 3, [82471372] = 3,
            [3387888881] = 4, [2829979385] = 4, [1222035661] = 4,
            [232485874] = 5, [3969543674] = 5, [2361599950] = 5
        }
        local temp_name = {
            '，而且是冰冷的', '，而且是有点冷的', '，而且是常温的', '，而且是有点热的', '，而且是炙热的'
        }
        if item.replica and item.replica.inventoryitem and item.replica.inventoryitem.GetImage then
            local range = temp_range[item.replica.inventoryitem:GetImage()]
            if range and temp_name[range] then
                nomu_state = temp_name[range]
            end
        end
    end
    local item_name = string.gsub(item:GetBasicDisplayName(), '\n', ' ')
    if item_name ~= name then
        name = name .. string.format('（有%d个名为%s）', num_found_name, item_name)
    end
    local announce_str = subfmt(S.ANNOUNCE_ITEM.FORMAT_STRING,
            {
                I_HAVE = i_have,
                THIS_MANY = this_many,
                ITEM = name,
                S = s,
                IN_THIS = in_this,
                CONTAINER = container_name,
                WITH = with,
                PERCENT = percent,
                DURABILITY = durability,
                NOMU_STATE = nomu_state
            })
    return self:Announce(announce_str)
end

function StatusAnnouncerNoMu:AnnounceRecipe(slot, recipepopup, ingnum)
    local S = STRINGS._STATUS_ANNOUNCEMENTS_NOMU._NOMU --To save some table lookups
    local builder = slot.owner.replica.builder
    local buffered = builder:IsBuildBuffered(slot.recipe.name)
    local knows = builder:KnowsRecipe(slot.recipe.name) or CanPrototypeRecipe(slot.recipe.level, builder:GetTechTrees())
    local can_build = builder:CanBuild(slot.recipe.name)
    local strings_name = STRINGS.NAMES[slot.recipe.product:upper()] or STRINGS.NAMES[slot.recipe.name:upper()]
    local name = strings_name and smoisturemetertrings_name:lower() or "<missing_string>"
    local a = S.getArticle(name)
    local ingredient = nil
    recipepopup = recipepopup or slot.recipepopup
    local ing = recipepopup.ing or { recipepopup.ingredient }
    if ingnum == nil then
        --mouse controls, we have to find the focused ingredient
        for i, ing in ipairs(ing) do
            if ing.focus then
                ingredient = ing
            end
        end
    else
        --controller controls, we pick it by number (determined by which button was pressed)
        ingredient = ing[ingnum]
    end
    if ingnum and ingredient == nil then
        return
    end --controller button for ingredient that doesn't exist
    local prototyper = ""
    if recipepopup.teaser.shown then
        --we patch RecipePopup in the modmain to insert _original_string when the teaser string gets set
        local teaser_string = recipepopup.teaser._original_string
        local CRAFTING = STRINGS.UI.CRAFTING
        for needs_string, prototyper_prefab in pairs(needs_strings) do
            if teaser_string == CRAFTING[needs_string] then
                prototyper = STRINGS.NAMES[prototyper_prefab]:lower()
            end
        end
    end
    local a_proto = ""
    local proto = ""
    if ingredient == nil then
        --announce the recipe (need more x, can make x, have x ready)
        local start_q = ""
        local to_do = ""
        local s = ""
        local pre_built = ""
        local end_q = ""
        local i_need = ""
        local for_it = ""
        if buffered then
            to_do = S.ANNOUNCE_RECIPE.I_HAVE
            pre_built = S.ANNOUNCE_RECIPE.PRE_BUILT
        elseif can_build and knows then
            to_do = S.ANNOUNCE_RECIPE.ILL_MAKE
        elseif knows then
            to_do = S.ANNOUNCE_RECIPE.WE_NEED
            a = ""
            s = string.find(name, S.S .. "$") == nil and S.S or ""
        else
            to_do = S.ANNOUNCE_RECIPE.CAN_SOMEONE
            if prototyper ~= "" and SHOWPROTOTYPER then
                i_need = S.ANNOUNCE_RECIPE.I_NEED
                a_proto = S.getArticle(prototyper) .. " "
                proto = prototyper
                for_it = S.ANNOUNCE_RECIPE.FOR_IT
            end
            start_q = S.ANNOUNCE_RECIPE.START_Q
            end_q = S.ANNOUNCE_RECIPE.END_Q
        end
        local announce_str = subfmt(S.ANNOUNCE_RECIPE.FORMAT_STRING,
                {
                    START_Q = start_q,
                    TO_DO = to_do,
                    THIS_MANY = a,
                    ITEM = name,
                    S = s,
                    PRE_BUILT = pre_built,
                    END_Q = end_q,
                    I_NEED = i_need,
                    A_PROTO = a_proto,
                    PROTOTYPER = proto,
                    FOR_IT = for_it,
                })
        return self:Announce(announce_str)
    else
        --announce the ingredient (need more, have enough to make x of recipe)
        local num = 0
        local ingname = nil
        local ingtooltip = nil
        if ingredient.ing then
            -- RecipePopup
            ingname = ingredient.ing.texture:sub(1, -5)
            ingtooltip = ingredient.tooltip
        else
            -- Quagmire_RecipePopup
            ingname = recipepopup.recipe.ingredients[1].type
            ingtooltip = STRINGS.NAMES[string.upper(ingname)]
        end
        local ing_s = S.S
        local amount_needed = 1
        for k, v in pairs(slot.recipe.ingredients) do
            if ingname == v.type then
                amount_needed = v.amount
            end
        end
        local has, num_found = slot.owner.replica.inventory:Has(ingname, RoundBiasedUp(amount_needed * slot.owner.replica.builder:IngredientMod()))
        for k, v in pairs(slot.recipe.character_ingredients) do
            if ingname == v.type then
                amount_needed = v.amount
                has, num_found = slot.owner.replica.builder:HasCharacterIngredient(v)
                ing_s = "" --health and sanity are already plural
            end
        end
        num = amount_needed - num_found
        local can_make = math.floor(num_found / amount_needed) * slot.recipe.numtogive
        local ingredient_str = (ingtooltip or "<missing_string>"):lower()
        if num == 1 or ingredient_str:find(ing_s .. "$") ~= nil then
            ing_s = ""
        end
        local announce_str = "";
        if num > 0 then
            local and_str = ""
            if prototyper ~= "" and SHOWPROTOTYPER then
                and_str = S.ANNOUNCE_INGREDIENTS.AND
                a_proto = S.getArticle(prototyper) .. " "
                proto = prototyper
            end
            announce_str = subfmt(S.ANNOUNCE_INGREDIENTS.FORMAT_NEED,
                    {
                        NUM_ING = num,
                        INGREDIENT = ingredient_str,
                        S = ing_s,
                        AND = and_str,
                        A_PROTO = a_proto,
                        PROTOTYPER = proto,
                        A_REC = S.getArticle(name),
                        RECIPE = name,
                    })
        else
            local but_need = ""
            if prototyper ~= "" and SHOWPROTOTYPER then
                but_need = S.ANNOUNCE_INGREDIENTS.BUT_NEED
                a_proto = S.getArticle(prototyper) .. " "
                proto = prototyper
            end
            local a_rec = ""
            local rec_s = ""
            if can_make > 1 then
                a_rec = can_make .. ""
                rec_s = S.S
                if string.find(name, rec_s .. "$") ~= nil then
                    --already plural
                    rec_s = ""
                end
            else
                a_rec = S.getArticle(name)
            end
            announce_str = subfmt(S.ANNOUNCE_INGREDIENTS.FORMAT_HAVE,
                    {
                        INGREDIENT = ingredient_str,
                        ING_S = ing_s,
                        A_REC = a_rec,
                        RECIPE = name,
                        REC_S = rec_s,
                        BUT_NEED = but_need,
                        A_PROTO = a_proto,
                        PROTOTYPER = proto,
                    })
        end
        return self:Announce(announce_str)
    end
end

local function GetPrototype(knows, recipe, owner)
    local prototyper
    if not knows then
        local details = ThePlayer.HUD.controls.craftingmenu.craftingmenu.details_root
        local prototyper_tree = details:_GetHintTextForRecipe(owner, recipe)
        local str = STRINGS.UI.CRAFTING[hint_text[prototyper_tree] or prototyper_tree]
        local CRAFTING = STRINGS.UI.CRAFTING
        for needs_string, prototyper_prefab in pairs(needs_strings) do
            if str == CRAFTING[needs_string] then
                prototyper = STRINGS.NAMES[prototyper_prefab] or prototyper_prefab
            end
        end
        prototyper = prototyper or '未知科技'
    end
    return prototyper or ''
end

function StatusAnnouncerNoMu:AnnounceRecipePinSlot(slot, recipepopup, ingnum)
    local recipe = slot.craftingmenu:GetRecipeState(slot.recipe_name)
    if not recipe or not recipe.recipe then
        return
    end
    recipe = recipe.recipe
    local S = STRINGS._STATUS_ANNOUNCEMENTS_NOMU._NOMU --To save some table lookups
    local builder = slot.owner.replica.builder
    local buffered = builder:IsBuildBuffered(recipe.name)
    local knows = builder:KnowsRecipe(recipe.name) or CanPrototypeRecipe(recipe.level, builder:GetTechTrees())
    local can_build = builder:CanBuild(recipe.name)
    local strings_name = STRINGS.NAMES[recipe.product:upper()] or STRINGS.NAMES[recipe.name:upper()]
    local name = strings_name and strings_name:lower() or "<missing_string>"
    local a = S.getArticle(name)
    local ingredient = nil
    recipepopup = recipepopup or slot.recipe_popup
    local ing = recipepopup.ing
    if ing == nil then
        ing = {}
        local ingredients
        if not recipepopup or not recipepopup.ingredients or not recipepopup.ingredients.children then
            return
        end
        for _, v in pairs(recipepopup.ingredients.children) do
            ingredients = v
            break
        end
        if ingredients ~= nil then
            for _, v in pairs(ingredients.children) do
                table.insert(ing, v)
            end
        end
    end
    if ingnum == nil then
        --mouse controls, we have to find the focused ingredient
        for i, ing in ipairs(ing) do
            if ing.focus then
                ingredient = ing
            end
        end
    else
        --controller controls, we pick it by number (determined by which button was pressed)
        ingredient = ing[ingnum]
    end
    if ingnum and ingredient == nil then
        return
    end --controller button for ingredient that doesn't exist
    local prototyper = GetPrototype(knows, recipe, slot.owner)

    local a_proto = ""
    local proto = ""
    if ingredient == nil then
        --announce the recipe (need more x, can make x, have x ready)
        local start_q = ""
        local to_do = ""
        local s = ""
        local pre_built = ""
        local end_q = ""
        local i_need = ""
        local for_it = ""
        if buffered then
            to_do = S.ANNOUNCE_RECIPE.I_HAVE
            pre_built = S.ANNOUNCE_RECIPE.PRE_BUILT
        elseif can_build and knows then
            to_do = S.ANNOUNCE_RECIPE.ILL_MAKE
        elseif knows then
            to_do = S.ANNOUNCE_RECIPE.WE_NEED
            a = ""
            s = string.find(name, S.S .. "$") == nil and S.S or ""
        else
            to_do = S.ANNOUNCE_RECIPE.CAN_SOMEONE
            if prototyper ~= "" and SHOWPROTOTYPER then
                i_need = S.ANNOUNCE_RECIPE.I_NEED
                a_proto = S.getArticle(prototyper) .. " "
                proto = prototyper
                for_it = S.ANNOUNCE_RECIPE.FOR_IT
            end
            start_q = S.ANNOUNCE_RECIPE.START_Q
            end_q = S.ANNOUNCE_RECIPE.END_Q
        end
        local announce_str = subfmt(S.ANNOUNCE_RECIPE.FORMAT_STRING,
                {
                    START_Q = start_q,
                    TO_DO = to_do,
                    THIS_MANY = a,
                    ITEM = name,
                    S = s,
                    PRE_BUILT = pre_built,
                    END_Q = end_q,
                    I_NEED = i_need,
                    A_PROTO = a_proto,
                    PROTOTYPER = proto,
                    FOR_IT = for_it,
                })
        return self:Announce(announce_str)
    else
        --announce the ingredient (need more, have enough to make x of recipe)
        local num = 0
        local ingname = nil
        local ingtooltip = nil
        if ingredient.ing then
            -- RecipePopup
            ingname = ingredient.ing.texture:sub(1, -5)
            ingtooltip = ingredient.tooltip
        else
            -- Quagmire_RecipePopup
            ingname = recipepopup.recipe.ingredients[1].type
            ingtooltip = STRINGS.NAMES[string.upper(ingname)]
        end
        local ing_s = S.S
        local amount_needed = 1
        for k, v in pairs(recipe.ingredients) do
            if ingname == v.type then
                amount_needed = v.amount
            end
        end
        local has, num_found = slot.owner.replica.inventory:Has(ingname, RoundBiasedUp(amount_needed * slot.owner.replica.builder:IngredientMod()))
        for k, v in pairs(recipe.character_ingredients) do
            if ingname == v.type then
                amount_needed = v.amount
                has, num_found = slot.owner.replica.builder:HasCharacterIngredient(v)
                ing_s = "" --health and sanity are already plural
            end
        end
        num = amount_needed - num_found
        local can_make = math.floor(num_found / amount_needed) * recipe.numtogive
        local ingredient_str = (ingtooltip or "<missing_string>"):lower()
        if num == 1 or ingredient_str:find(ing_s .. "$") ~= nil then
            ing_s = ""
        end
        local announce_str = "";
        if num > 0 then
            local and_str = ""
            if prototyper ~= "" and SHOWPROTOTYPER then
                and_str = S.ANNOUNCE_INGREDIENTS.AND
                a_proto = S.getArticle(prototyper) .. " "
                proto = prototyper
            end
            announce_str = subfmt(S.ANNOUNCE_INGREDIENTS.FORMAT_NEED,
                    {
                        NUM_ING = num,
                        INGREDIENT = ingredient_str,
                        S = ing_s,
                        AND = and_str,
                        A_PROTO = a_proto,
                        PROTOTYPER = proto,
                        A_REC = S.getArticle(name),
                        RECIPE = name,
                    })
        else
            local but_need = ""
            if prototyper ~= "" and SHOWPROTOTYPER then
                but_need = S.ANNOUNCE_INGREDIENTS.BUT_NEED
                a_proto = S.getArticle(prototyper) .. " "
                proto = prototyper
            end
            local a_rec = ""
            local rec_s = ""
            if can_make > 1 then
                a_rec = can_make .. ""
                rec_s = S.S
                if string.find(name, rec_s .. "$") ~= nil then
                    --already plural
                    rec_s = ""
                end
            else
                a_rec = S.getArticle(name)
            end
            announce_str = subfmt(S.ANNOUNCE_INGREDIENTS.FORMAT_HAVE,
                    {
                        INGREDIENT = ingredient_str,
                        ING_S = ing_s,
                        A_REC = a_rec,
                        RECIPE = name,
                        REC_S = rec_s,
                        BUT_NEED = but_need,
                        A_PROTO = a_proto,
                        PROTOTYPER = proto,
                    })
        end
        return self:Announce(announce_str)
    end
end

function StatusAnnouncerNoMu:AnnounceRecipeCMIngredients(ingredients)
    local recipe = ingredients.recipe
    if not recipe then
        return
    end
    local S = STRINGS._STATUS_ANNOUNCEMENTS_NOMU._NOMU --To save some table lookups
    local builder = ingredients.owner.replica.builder
    local buffered = builder:IsBuildBuffered(recipe.name)
    local knows = builder:KnowsRecipe(recipe.name) or CanPrototypeRecipe(recipe.level, builder:GetTechTrees())
    local can_build = builder:CanBuild(recipe.name)
    local strings_name = STRINGS.NAMES[recipe.product:upper()] or STRINGS.NAMES[recipe.name:upper()]
    local name = strings_name and strings_name:lower() or "<missing_string>"
    local a = S.getArticle(name)
    local ingredient = nil

    local ing = {}
    local ingredients_root
    for _, v in pairs(ingredients.children) do
        ingredients_root = v
        break
    end
    if ingredients_root ~= nil then
        for _, v in pairs(ingredients_root.children) do
            table.insert(ing, v)
        end
    end

    for i, ing in ipairs(ing) do
        if ing.focus then
            ingredient = ing
        end
    end

    local prototyper = GetPrototype(knows, recipe, ingredients.owner)
    local a_proto = ""
    local proto = ""
    if ingredient == nil then
        --announce the recipe (need more x, can make x, have x ready)
        local start_q = ""
        local to_do = ""
        local s = ""
        local pre_built = ""
        local end_q = ""
        local i_need = ""
        local for_it = ""
        if buffered then
            to_do = S.ANNOUNCE_RECIPE.I_HAVE
            pre_built = S.ANNOUNCE_RECIPE.PRE_BUILT
        elseif can_build and knows then
            to_do = S.ANNOUNCE_RECIPE.ILL_MAKE
        elseif knows then
            to_do = S.ANNOUNCE_RECIPE.WE_NEED
            a = ""
            s = string.find(name, S.S .. "$") == nil and S.S or ""
        else
            to_do = S.ANNOUNCE_RECIPE.CAN_SOMEONE
            if prototyper ~= "" and SHOWPROTOTYPER then
                i_need = S.ANNOUNCE_RECIPE.I_NEED
                a_proto = S.getArticle(prototyper) .. " "
                proto = prototyper
                for_it = S.ANNOUNCE_RECIPE.FOR_IT
            end
            start_q = S.ANNOUNCE_RECIPE.START_Q
            end_q = S.ANNOUNCE_RECIPE.END_Q
        end
        local announce_str = subfmt(S.ANNOUNCE_RECIPE.FORMAT_STRING,
                {
                    START_Q = start_q,
                    TO_DO = to_do,
                    THIS_MANY = a,
                    ITEM = name,
                    S = s,
                    PRE_BUILT = pre_built,
                    END_Q = end_q,
                    I_NEED = i_need,
                    A_PROTO = a_proto,
                    PROTOTYPER = proto,
                    FOR_IT = for_it,
                })
        return self:Announce(announce_str)
    else
        --announce the ingredient (need more, have enough to make x of recipe)
        local num = 0
        local ingname = nil
        local ingtooltip = nil
        if ingredient.ing then
            -- RecipePopup
            ingname = ingredient.ing.texture:sub(1, -5)
            ingtooltip = ingredient.tooltip
        end
        local ing_s = S.S
        local amount_needed = 1
        for k, v in pairs(recipe.ingredients) do
            if ingname == v.type then
                amount_needed = v.amount
            end
        end
        local has, num_found = ingredients.owner.replica.inventory:Has(ingname, RoundBiasedUp(amount_needed * ingredients.owner.replica.builder:IngredientMod()))
        for k, v in pairs(recipe.character_ingredients) do
            if ingname == v.type then
                amount_needed = v.amount
                has, num_found = ingredients.owner.replica.builder:HasCharacterIngredient(v)
                ing_s = "" --health and sanity are already plural
            end
        end
        num = amount_needed - num_found
        local can_make = math.floor(num_found / amount_needed) * recipe.numtogive
        local ingredient_str = (ingtooltip or "<missing_string>"):lower()
        if num == 1 or ingredient_str:find(ing_s .. "$") ~= nil then
            ing_s = ""
        end
        local announce_str = "";
        if num > 0 then
            local and_str = ""
            if prototyper ~= "" and SHOWPROTOTYPER then
                and_str = S.ANNOUNCE_INGREDIENTS.AND
                a_proto = S.getArticle(prototyper) .. " "
                proto = prototyper
            end
            announce_str = subfmt(S.ANNOUNCE_INGREDIENTS.FORMAT_NEED,
                    {
                        NUM_ING = num,
                        INGREDIENT = ingredient_str,
                        S = ing_s,
                        AND = and_str,
                        A_PROTO = a_proto,
                        PROTOTYPER = proto,
                        A_REC = S.getArticle(name),
                        RECIPE = name,
                    })
        else
            local but_need = ""
            if prototyper ~= "" and SHOWPROTOTYPER then
                but_need = S.ANNOUNCE_INGREDIENTS.BUT_NEED
                a_proto = S.getArticle(prototyper) .. " "
                proto = prototyper
            end
            local a_rec = ""
            local rec_s = ""
            if can_make > 1 then
                a_rec = can_make .. ""
                rec_s = S.S
                if string.find(name, rec_s .. "$") ~= nil then
                    --already plural
                    rec_s = ""
                end
            else
                a_rec = S.getArticle(name)
            end
            announce_str = subfmt(S.ANNOUNCE_INGREDIENTS.FORMAT_HAVE,
                    {
                        INGREDIENT = ingredient_str,
                        ING_S = ing_s,
                        A_REC = a_rec,
                        RECIPE = name,
                        REC_S = rec_s,
                        BUT_NEED = but_need,
                        A_PROTO = a_proto,
                        PROTOTYPER = proto,
                    })
        end
        return self:Announce(announce_str)
    end
end

function StatusAnnouncerNoMu:AnnounceRecipeGrid(grid, owner)
    local focused_item_index = grid.focused_widget_index + grid.displayed_start_index
    local recipe
    if grid.focus and #grid.items > 0 and grid.items[focused_item_index] then
        recipe = grid.items[focused_item_index].recipe
    end
    if not recipe then
        return
    end
    local S = STRINGS._STATUS_ANNOUNCEMENTS_NOMU._NOMU --To save some table lookups
    local builder = owner.replica.builder
    local buffered = builder:IsBuildBuffered(recipe.name)
    local knows = builder:KnowsRecipe(recipe.name) or CanPrototypeRecipe(recipe.level, builder:GetTechTrees())
    local can_build = builder:CanBuild(recipe.name)
    local strings_name = STRINGS.NAMES[recipe.product:upper()] or STRINGS.NAMES[recipe.name:upper()]
    local name = strings_name and strings_name:lower() or "<missing_string>"
    local a = S.getArticle(name)

    local prototyper = GetPrototype(knows, recipe, owner)
    local a_proto = ""
    local proto = ""

    --announce the recipe (need more x, can make x, have x ready)
    local start_q = ""
    local to_do = ""
    local s = ""
    local pre_built = ""
    local end_q = ""
    local i_need = ""
    local for_it = ""
    if buffered then
        to_do = S.ANNOUNCE_RECIPE.I_HAVE
        pre_built = S.ANNOUNCE_RECIPE.PRE_BUILT
    elseif can_build and knows then
        to_do = S.ANNOUNCE_RECIPE.ILL_MAKE
    elseif knows then
        to_do = S.ANNOUNCE_RECIPE.WE_NEED
        a = ""
        s = string.find(name, S.S .. "$") == nil and S.S or ""
    else
        to_do = S.ANNOUNCE_RECIPE.CAN_SOMEONE
        if prototyper ~= "" and SHOWPROTOTYPER then
            i_need = S.ANNOUNCE_RECIPE.I_NEED
            a_proto = S.getArticle(prototyper) .. " "
            proto = prototyper
            for_it = S.ANNOUNCE_RECIPE.FOR_IT
        end
        start_q = S.ANNOUNCE_RECIPE.START_Q
        end_q = S.ANNOUNCE_RECIPE.END_Q
    end
    local announce_str = subfmt(S.ANNOUNCE_RECIPE.FORMAT_STRING,
            {
                START_Q = start_q,
                TO_DO = to_do,
                THIS_MANY = a,
                ITEM = name,
                S = s,
                PRE_BUILT = pre_built,
                END_Q = end_q,
                I_NEED = i_need,
                A_PROTO = a_proto,
                PROTOTYPER = proto,
                FOR_IT = for_it,
            })
    return self:Announce(announce_str)

end

function StatusAnnouncerNoMu:AnnounceSkin(recipepopup)
    if not recipepopup.focus then
        return
    end
    local skin_name = recipepopup.skins_spinner and recipepopup.skins_spinner.GetItem()
    if skin_name == nil then
        skin_name = recipepopup.GetItem and recipepopup:GetItem()
    end
    if skin_name == nil then
        return
    end
    local item_name = STRINGS.NAMES[string.upper(recipepopup.recipe.product)] or recipepopup.recipe.name
    if skin_name ~= item_name then
        --don't announce default skins
        return self:Announce(subfmt(STRINGS._STATUS_ANNOUNCEMENTS_NOMU._NOMU.ANNOUNCE_SKIN.FORMAT_STRING,
                { SKIN = GetSkinName(skin_name), ITEM = item_name }))
    end
end

function StatusAnnouncerNoMu:AnnounceTemperature(pronoun)
    local S = STRINGS._STATUS_ANNOUNCEMENTS_NOMU._NOMU.ANNOUNCE_TEMPERATURE --To save some table lookups
    local temp = ThePlayer:GetTemperature()
    local pronoun = pronoun and S.PRONOUN[pronoun] or S.PRONOUN.DEFAULT
    local message = S.TEMPERATURE.GOOD
    local TUNING = TUNING
    if temp >= TUNING.OVERHEAT_TEMP then
        message = S.TEMPERATURE.BURNING
    elseif temp >= TUNING.OVERHEAT_TEMP - 5 then
        message = S.TEMPERATURE.HOT
    elseif temp >= TUNING.OVERHEAT_TEMP - 15 then
        message = S.TEMPERATURE.WARM
    elseif temp <= 0 then
        message = S.TEMPERATURE.FREEZING
    elseif temp <= 5 then
        message = S.TEMPERATURE.COLD
    elseif temp <= 15 then
        message = S.TEMPERATURE.COOL
    end
    message = subfmt(S.FORMAT_STRING,
            {
                PRONOUN = pronoun,
                TEMPERATURE = message,
            })
    if EXPLICIT then
        return self:Announce(string.format("(%d\176) %s", temp, message))
    else
        return self:Announce(message)
    end
end

-- 降雨预测
local function PredictRainStart()
    -- 资料来源：https://www.bilibili.com/video/BV1DE411E7Qi

    -- 一场雨什么时候下由上限决定、什么时候停由下限决定
    -- 冬天第二天上涨速率速率是50
    -- 水分 = 水分速率下限 + (水分速率上限 - 水分速率下限) * {1 - Sin[Π * (当前季节剩余天数, 包括当天) / 当前季节总天数]}

    -- 水分速率上下限
    local MOISTURE_RATES = {
        MIN = {
            autumn = .25,
            winter = .25,
            spring = 3,
            summer = .1
        },
        MAX = {
            autumn = 1.0,
            winter = 1.0,
            spring = 3.75,
            summer = .5
        }
    }
    local world = TheWorld.net.components.weather ~= nil and "Surface" or "Caves"
    local remainingsecondsinday = TUNING.TOTAL_DAY_TIME - (TheWorld.state.time * TUNING.TOTAL_DAY_TIME)
    local totalseconds = 0
    local rain = false

    local season = TheWorld.state.season
    local seasonprogress = TheWorld.state.seasonprogress
    local elapseddaysinseason = TheWorld.state.elapseddaysinseason
    local remainingdaysinseason = TheWorld.state.remainingdaysinseason
    local totaldaysinseason = remainingdaysinseason / (1 - seasonprogress)
    local _totaldaysinseason = elapseddaysinseason + remainingdaysinseason

    local moisture = TheWorld.state.moisture
    local moistureceil = TheWorld.state.moistureceil

    while elapseddaysinseason < _totaldaysinseason do
        local moisturerate

        if world == "Surface" and season == "winter" and elapseddaysinseason == 2 then
            moisturerate = 50
        else
            local p = 1 - math.sin(PI * seasonprogress)
            moisturerate = MOISTURE_RATES.MIN[season] + p * (MOISTURE_RATES.MAX[season] - MOISTURE_RATES.MIN[season])
        end

        local _moisture = moisture + (moisturerate * remainingsecondsinday)

        if _moisture >= moistureceil then
            totalseconds = totalseconds + ((moistureceil - moisture) / moisturerate)
            rain = true
            break
        else
            moisture = _moisture
            totalseconds = totalseconds + remainingsecondsinday
            remainingsecondsinday = TUNING.TOTAL_DAY_TIME
            elapseddaysinseason = elapseddaysinseason + 1
            remainingdaysinseason = remainingdaysinseason - 1
            seasonprogress = 1 - (remainingdaysinseason / totaldaysinseason)
        end
    end
    if world == "Surface" then
        world = "地表"
    elseif world == "Caves" then
        world = "洞穴"
    end
    return world, totalseconds, rain
end
-- 停雨预测
local function PredictRainStop()
    local PRECIP_RATE_SCALE = 10
    local MIN_PRECIP_RATE = .1

    local world = TheWorld.net.components.weather ~= nil and "Surface" or "Caves"
    local dbgstr = (TheWorld.net.components.weather ~= nil and TheWorld.net.components.weather:GetDebugString()) or
            TheWorld.net.components.caveweather:GetDebugString()
    local _, _, moisture, moisturefloor, moistureceil, moisturerate, preciprate, peakprecipitationrate = string.find(
            dbgstr, ".*moisture:(%d+.%d+)%((%d+.%d+)/(%d+.%d+)%) %+ (%d+.%d+), preciprate:%((%d+.%d+) of (%d+.%d+)%).*")

    moisture = tonumber(moisture)
    moistureceil = tonumber(moistureceil)
    moisturefloor = tonumber(moisturefloor)
    preciprate = tonumber(preciprate)
    peakprecipitationrate = tonumber(peakprecipitationrate)

    local totalseconds = 0

    while moisture > moisturefloor do
        if preciprate > 0 then
            local p = math.max(0, math.min(1, (moisture - moisturefloor) / (moistureceil - moisturefloor)))
            local rate = MIN_PRECIP_RATE + (1 - MIN_PRECIP_RATE) * math.sin(p * PI)

            preciprate = math.min(rate, peakprecipitationrate)
            moisture = math.max(moisture - preciprate * FRAMES * PRECIP_RATE_SCALE, 0)

            totalseconds = totalseconds + FRAMES
        else
            break
        end
    end

    if world == "Surface" then
        world = "地上"
    elseif world == "Caves" then
        world = "洞穴"
    end

    return world, totalseconds
end
--宣告世界温度
function StatusAnnouncerNoMu:AnnounceWorldtemp(pronoun)
    local S = STRINGS._STATUS_ANNOUNCEMENTS_NOMU._NOMU.ANNOUNCE_WORLDTEMP or nil -- 以保存一些表查找
    if S then
        local temp = TheWorld.state.temperature
        local message = ""
        local tshow = "降雨"
        local tseason = TheWorld.state.season
        if tseason == "spring" then
            tseason = "春天"
            --tshow = "绵绵春雨"
        elseif tseason == "summer" then
            tseason = "夏天"
            --tshow = "狂风暴雨"
        elseif tseason == "autumn" then
            tseason = "秋天"
            --tshow = "蒙蒙细雨"
        elseif tseason == "winter" then
            tseason = "冬天"
            --tshow = "纷纷白雪"
            tshow = "降雪"
        end

        local _world = '地上'
        if TheWorld.state.pop ~= 1 then
            local world, totalseconds, rain = PredictRainStart()
            _world = world

            if rain then
                local d = TheWorld.state.cycles + 1 + TheWorld.state.time + (totalseconds / TUNING.TOTAL_DAY_TIME)
                local m = math.floor(totalseconds / 60)
                local s = totalseconds % 60
                message = string.format("%s：第%.2f天（%d分%d秒）", tshow, d, m, s)
            else
                message = string.format("%s不再%s", tseason, tshow)
            end
        else
            local world, totalseconds = PredictRainStop()
            _world = world

            local d = TheWorld.state.cycles + 1 + TheWorld.state.time + (totalseconds / TUNING.TOTAL_DAY_TIME)
            local m = math.floor(totalseconds / 60)
            local s = totalseconds % 60

            message = string.format("放晴：第%.2f天（%d分%d秒）", d, m, s)
        end

        return self:Announce(string.format("%s气温:%d°，%s", _world, temp, message))
    end
end
--宣告世界温度

--宣告月圆 --失败了 请求支援--Shang
-- function StatusAnnouncerNoMu:AnnounceMoonanim()
-- 	local message = "距离月圆还有未知天。"
-- 	return self:Announce(message)
-- end

function StatusAnnouncerNoMu:AnnounceSeason()
    return self:Announce(subfmt(
            STRINGS._STATUS_ANNOUNCEMENTS_NOMU._NOMU.ANNOUNCE_SEASON,
            {
                DAYS_LEFT = TheWorld.state.remainingdaysinseason,
                SEASON = STRINGS.UI.SERVERLISTINGSCREEN.SEASONS[TheWorld.state.season:upper()],
            }
    ))
end

--NOTE: Your mod is responsible for adding and deciding when to show/hide the controller button hint
-- look at the modmain for examples-- most stats just show/hide with controller inventory,
-- but moisture requires some special handling
function StatusAnnouncerNoMu:RegisterStat(name, widget, controller_btn,
                                      thresholds, category_names, value_fn, switch_fn)
    self.button_to_stat[controller_btn] = name
    self.stats[name] = {
        --The widget that should be focused when announcing this stat
        widget = widget,
        --The button on the controller that announces this stat
        controller_btn = controller_btn,
        --the numerical thresholds at which messages change (must be sorted in increasing order!)
        thresholds = thresholds,
        --the names of the buckets between the thresholds, for looking up strings
        category_names = category_names,
        --value_fn(ThePlayer) returns the current and maximum of the stat
        value_fn = value_fn,
        --switch_fn(ThePlayer) returns the mode (e.g. HUMAN for Woodie vs WEREBEAVER for Werebeaver)
        --if this is nil, it assumes there's just one table (look at Woodie's table in announcestrings vs the others)
        switch_fn = switch_fn,
    }
end

--The other arguments are here so that mods can use them to override this function
-- and avoid some of these stats if their character doesn't have them
function StatusAnnouncerNoMu:RegisterCommonStats(HUD, prefab, hunger, sanity, health, moisture, wereness)
    local stat_categorynames = { "EMPTY", "LOW", "MID", "HIGH", "FULL" }
    local default_thresholds = { .15, .35, .55, .75 }

    local status = HUD.controls.status
    local has_weremode = type(status.wereness) == "table"
    local switch_fn = has_weremode
            and function(ThePlayer)
        return ThePlayer.weremode:value() ~= 0 and "WEREBEAVER" or "HUMAN"
    end
            or nil

    if hunger ~= false and type(status.stomach) == "table" then
        self:RegisterStat(
                "Hunger",
                status.stomach,
                CONTROL_INVENTORY_USEONSCENE, -- D-Pad Left
                default_thresholds,
                stat_categorynames,
                function(ThePlayer)
                    return ThePlayer.player_classified.currenthunger:value(),
                    ThePlayer.player_classified.maxhunger:value()
                end,
                switch_fn
        )
    end
    if sanity ~= false and type(status.brain) == "table" then
        self:RegisterStat(
                "Sanity",
                status.brain,
                CONTROL_INVENTORY_EXAMINE, -- D-Pad Up
                default_thresholds,
                stat_categorynames,
                function(ThePlayer)
                    return ThePlayer.player_classified.currentsanity:value(),
                    ThePlayer.player_classified.maxsanity:value()
                end,
                switch_fn
        )
    end
    if health ~= false and type(status.heart) == "table" then
        self:RegisterStat(
                "Health",
                status.heart,
                CONTROL_INVENTORY_USEONSELF, -- D-Pad Right
                { .25, .5, .75, 1 },
                stat_categorynames,
                function(ThePlayer)
                    return ThePlayer.player_classified.currenthealth:value(),
                    ThePlayer.player_classified.maxhealth:value()
                end,
                switch_fn
        )
    end
    if wereness ~= false and has_weremode then
        self:RegisterStat(
                "Log Meter",
                status.wereness,
                CONTROL_ROTATE_LEFT, -- Left Bumper
                { .25, .5, .7, .9 },
                stat_categorynames,
                function(ThePlayer)
                    return ThePlayer.player_classified.currentwereness:value(),
                    100 -- looks like the only way is to hardcode this; not networked
                end,
                switch_fn
        )
    end
    if moisture ~= false and type(status.moisturemeter) == "table" then
        self:RegisterStat(
                "Wetness",
                status.moisturemeter,
                CONTROL_ROTATE_RIGHT, -- Right Bumper
                default_thresholds,
                stat_categorynames,
                function(ThePlayer)
                    return ThePlayer.player_classified.moisture:value(),
                    ThePlayer.player_classified.maxmoisture:value()
                end,
                switch_fn
        )
    end
end

local function has_seasons(HUD, ignore_focus)
    return HUD.controls.seasonclock and (ignore_focus or HUD.controls.seasonclock.focus)
            or HUD.controls.status.season and (ignore_focus or HUD.controls.status.season.focus)
end

local function FormatTime(seconds)
    local minutes = math.modf(seconds / 60)
    seconds = math.modf(math.fmod(seconds, 60))
    local message = ''
    if minutes > 0 then
        message = message .. tostring(minutes) .. '分'
    end
    message = message .. tostring(seconds) .. '秒'
    return message
end

function StatusAnnouncerNoMu:AnnounceMoonAnim(moonment)
    -- {今晚或明晚}{月相}{，}距离{反月相}还有{XX}天。
    -- {我们刚刚度过}{月相}{，}距离{月相}还有{XX}天。
    -- 距离{月相}还有{XX}天。
    local worldment = TheWorld.state.cycles + 1 or 0
    if worldment == 0 then
        return
    end
    local MS = STRINGS._STATUS_ANNOUNCEMENTS_NOMU._NOMU.ANNOUNCE_MOON
    local recent, phase1, phase2, a_str = "", "", "", ""
    local moonleft = moonment - worldment

    if moonleft >= 10 then
        phase1 = MS.FULLMOON
        phase2 = MS.NEWMOON
    else
        phase1 = MS.NEWMOON
        phase2 = MS.FULLMOON
    end
    local interval = MS.INTERVAL
    local judge = moonleft % 10
    if judge <= 1 then
        if judge == 0 then
            recent = MS.TODAY
        else
            recent = MS.TOMORROW
        end
        judge = judge + 10
        phase1, phase2 = phase2, phase1
        if worldment < 20 then
            if phase1 == MS.FULLMOON then
                return self:Announce(subfmt(MS.FORMAT_FULLMOON, {
                    RECENT = recent,
                    PHASE1 = phase1,
                    INTERVAL = interval,
                }))
            else
                return self:Announce(subfmt(MS.FORMAT_NEWMOON, {
                    RECENT = recent,
                    PHASE1 = phase1,
                    INTERVAL = interval,
                }))
            end
        end
    elseif judge >= 8 then
        recent = MS.AFTER
    else
        recent = ""
        phase1 = ""
        interval = ""
    end
    return self:Announce(subfmt(MS.FORMAT_STRING, {
        RECENT = recent,
        PHASE1 = phase1,
        INTERVAL = interval,
        PHASE2 = phase2,
        MOONLEFT = judge,
    }))
end

function StatusAnnouncerNoMu:OnHUDMouseButton(HUD)
    for stat_name, data in pairs(self.stats) do
        if data.widget.focus then
            return self:Announce(self:ChooseStatMessage(stat_name))
        end
    end
    if HUD.controls.status.temperature and HUD.controls.status.temperature.focus then
        return self:AnnounceTemperature(HUD.controls.status._weremode and "BEAST" or nil)
    end
    if has_seasons(HUD, false) then
        return self:AnnounceSeason()
    end
    if HUD.controls.clock and HUD.controls.clock._moonanim and HUD.controls.clock._moonanim.focus and HUD.controls.clock._moonanim.moontext then
        if string.find(tostring(HUD.controls.clock._moonanim.moontext), '?') ~= nil then
            ThePlayer.components.talker:Say('上线时间太短，无法判明月相！')
            return
        end
        local moonment = string.match(tostring(HUD.controls.clock._moonanim.moontext), "(%d+)") or 0
        if moonment ~= 0 then
            return self:AnnounceMoonAnim(moonment)
        end
    end
    if HUD.controls.clock and HUD.controls.clock.focus then
        local clock = TheWorld.net.components.clock
        if clock and clock._remainingtimeinphase and clock._phase and clock.CalcRemainTimeOfDay then
            local message = clock.PHASE_NAMES[clock._phase:value()] .. '还有' .. FormatTime(clock._remainingtimeinphase:value()) .. '，今天还有' .. FormatTime(clock.CalcRemainTimeOfDay()) .. '。'
            return self:Announce(message)
        end
    end
    --添加宣告世界温度_鼠标 shang
    if HUD.controls.status.worldtemp and HUD.controls.status.worldtemp.focus then
        return self:AnnounceWorldtemp(HUD.controls.status._weremode and "BEAST" or nil)
    end
    if HUD.controls.status.boatmeter and HUD.controls.status.boatmeter.focus then
        local sayings = {
            "啊~~~水！",
            "越是残血我越浪！",
            "就这，不慌！",
            "来啊，玩碰碰船啊！",
            "我要当海贼王！",
        }
        local max = HUD.controls.status.boatmeter.boat.components.healthsyncer.max_health
        local step = max / 5 + 1
        local current = HUD.controls.status.boatmeter.boat.components.healthsyncer:GetPercent() * max
        local idx = math.floor(current / step) + 1
        local message = '(船: ' .. tostring(math.floor(current)) .. '/' .. tostring(max) .. ') ' .. sayings[idx]
        return self:Announce(message)
    end
    if HUD.controls.status.pethealthbadge and HUD.controls.status.pethealthbadge.focus then
        local badge = HUD.controls.status.pethealthbadge
        if not badge.nomu_max or not badge.nomu_percent then
            return
        end
        local sayings = {
            "阿比盖尔！别离开我！",
            "小心啊！阿比盖尔！",
            "你还好吗？阿比盖尔！",
            "你受伤了，阿比盖尔！",
            "阿比盖尔可以保护我！",
        }
        local max = badge.nomu_max
        local current = badge.nomu_percent * max
        local step = max / 5 + 1
        local idx = math.floor(current / step) + 1
        local message = '(:ghost:: ' .. tostring(math.floor(current)) .. '/' .. tostring(max) .. ') ' .. sayings[idx]
        return self:Announce(message)
    end
    if HUD.controls.status.mightybadge and HUD.controls.status.mightybadge.focus then
        local badge = HUD.controls.status.mightybadge
        if not badge.nomu_percent then
            return
        end
        badge.nomu_max = badge.nomu_max or 100
        local sayings = {
            "我只是一个弱鸡…",
            "我需要锻炼！",
            "我是最强壮的！",
        }
        local max = badge.nomu_max
        local current = badge.nomu_percent * max
        local idx = 1
        if current >= TUNING.MIGHTY_THRESHOLD then
            idx = 3
        elseif current >= TUNING.WIMPY_THRESHOLD then
            idx = 2
        end
        local message = '(:flex:: ' .. tostring(math.floor(current)) .. '/' .. tostring(max) .. ') ' .. sayings[idx]
        return self:Announce(message)
    end
    if HUD.controls.status.inspirationbadge and HUD.controls.status.inspirationbadge.focus then
        local badge = HUD.controls.status.inspirationbadge
        if not badge.nomu_percent then
            return
        end
        badge.nomu_max = badge.nomu_max or 100
        local sayings = {
            "我开不了嗓",
            "我可以唱1首歌！",
            "我可以唱2首歌！",
            "我可以唱3首歌！",
        }
        local max = badge.nomu_max
        local current = badge.nomu_percent * max
        local idx = 1
        if badge.nomu_percent >= TUNING.BATTLESONG_THRESHOLDS[3] then
            idx = 4
        elseif badge.nomu_percent >= TUNING.BATTLESONG_THRESHOLDS[2] then
            idx = 3
        elseif badge.nomu_percent >= TUNING.BATTLESONG_THRESHOLDS[1] then
            idx = 2
        end
        local message = '(:horn:: ' .. tostring(math.floor(current)) .. '/' .. tostring(max) .. ') ' .. sayings[idx]
        return self:Announce(message)
    end
end

function StatusAnnouncerNoMu:OnHUDControl(HUD, control)
    if HUD:IsControllerCraftingOpen() then
        local cc = HUD.controls.crafttabs.controllercrafting
        if cc ~= nil then
            local slot = cc.oldslot or cc.craftslots.slots[cc.selected_slot]
            local recipepopup = cc.recipepopup or slot.recipepopup
            if control == CONTROL_MENU_MISC_2 then
                --Y
                return self:AnnounceRecipe(slot, recipepopup)
            elseif control == CONTROL_INVENTORY_USEONSCENE then
                --d-pad left
                return self:AnnounceRecipe(slot, recipepopup, 1)
            elseif control == CONTROL_INVENTORY_EXAMINE then
                --d-pad up
                return self:AnnounceRecipe(slot, recipepopup, 2)
            elseif control == CONTROL_INVENTORY_USEONSELF then
                --d-pad right
                return self:AnnounceRecipe(slot, recipepopup, 3)
            elseif control == CONTROL_INVENTORY_DROP and recipepopup.skins_spinner then
                --d-pad down
                return self:AnnounceSkin(recipepopup)
            end
        end
    elseif HUD:IsControllerInventoryOpen()
            or (HUD.controls.status._weremode and HUD._statuscontrollerbuttonhintsshown) then
        local stat = self.button_to_stat[control]
        if stat and self.stats[stat].widget.shown then
            return self:Announce(self:ChooseStatMessage(stat))
        end
        if OVERRIDEB and HUD.controls.status.temperature and control == CONTROL_CANCEL then
            return self:AnnounceTemperature(HUD.controls.status._weremode and "BEAST" or nil)
        end
        if OVERRIDESELECT and control == CONTROL_MAP and has_seasons(HUD, true) then
            return self:AnnounceSeason()
        end
        --添加宣告世界温度_控制器_LB shang
        if OVERRIDEB and HUD.controls.status.worldtemp and control == CONTROL_ROTATE_LEFT then
            return self:AnnounceWorldtemp(HUD.controls.status._beavermode and "BEAST" or nil)
        end
        --结束
    end
end

local function get_category(thresholds, percent)
    local i = 1
    while thresholds[i] ~= nil and percent >= thresholds[i] do
        i = i + 1
    end
    return i
end

function StatusAnnouncerNoMu:ChooseStatMessage(stat)
    local cur, max = self.stats[stat].value_fn(ThePlayer)
    local percent = cur / max
    local messages = self.stats[stat].switch_fn
            and self.char_messages[self.stats[stat].switch_fn(ThePlayer)]
            or self.char_messages
    local category = get_category(self.stats[stat].thresholds, percent)
    local category_name = self.stats[stat].category_names[category]
    local message = messages[stat:upper()][category_name]
    if EXPLICIT then
        return string.format("(%s: %d/%d) %s", self.stat_names[stat] or stat, cur, max, message)
    else
        return message
    end
end

function StatusAnnouncerNoMu:ClearCooldowns()
    self.cooldown = false
    self.cooldowns = {}
end

function StatusAnnouncerNoMu:ClearStats()
    self.stats = {}
    self.button_to_stat = {}
end

function StatusAnnouncerNoMu:SetCharacter(prefab)
    self:ClearCooldowns()
    self:ClearStats()
    self.char_messages = STRINGS._STATUS_ANNOUNCEMENTS_NOMU[prefab:upper()] or STRINGS._STATUS_ANNOUNCEMENTS_NOMU.UNKNOWN
    self.stat_names = {}
    for stat, name in pairs(STRINGS._STATUS_ANNOUNCEMENTS_NOMU._NOMU.STAT_NAMES) do
        self.stat_names[stat] = name
    end
    if SHOWEMOJI then
        for stat, emoji in pairs(STRINGS._STATUS_ANNOUNCEMENTS_NOMU._NOMU.STAT_EMOJI) do
            if TheInventory:CheckOwnership("emoji_" .. emoji) then
                self.stat_names[stat] = ":" .. emoji
            end
        end
    end
end

function StatusAnnouncerNoMu:SetLocalParameter(parameter, value)
    if setters[parameter] then
        setters[parameter](value)
    end
end

return StatusAnnouncerNoMu
