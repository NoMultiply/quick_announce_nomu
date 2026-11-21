-- scripts/qa_inventory.lua
-- 负责配方材料、容器、制作栏、物品栏等界面宣告

local QA = GLOBAL.NOMU_QA
local LOCAL_STRINGS = GLOBAL.STRINGS.NOMU_QA or {}
local DEBUG_STR = LOCAL_STRINGS.DEBUG or {}
local MEASURE_WORD = LOCAL_STRINGS.MEASURE_WORD

-- 配方材料反查与缺失计算
local function GetFocusedIngredientType(recipe, focused_index)
    if not recipe or not focused_index then return nil end

    local all_reqs = {}
    if recipe.tech_ingredients then
        for _, v in ipairs(recipe.tech_ingredients) do
            if v.type:sub(-9) == "_material" then
                table.insert(all_reqs, v.type)
            end
        end
    end
    if recipe.ingredients then
        for _, v in ipairs(recipe.ingredients) do
            table.insert(all_reqs, v.type)
        end
    end
    if recipe.character_ingredients then
        for _, v in ipairs(recipe.character_ingredients) do
            table.insert(all_reqs, v.type)
        end
    end

    return all_reqs[focused_index]
end

local function GetPrototype(knows, recipe, owner)
    local prototyper, raw_tech
    if not knows then
        local details = GLOBAL.ThePlayer.HUD.controls.craftingmenu.craftingmenu.details_root
        raw_tech = details:_GetHintTextForRecipe(owner, recipe)

        local qa_recipe = QA.SCHEME.RECIPE
        local proto_map = qa_recipe and qa_recipe.MAPPINGS and qa_recipe.MAPPINGS.DEFAULT and qa_recipe.MAPPINGS.DEFAULT.PROTOTYPER
        if proto_map then
            prototyper = proto_map[raw_tech] or proto_map["UNKNOWN_PROTOTYPE"]
        end
    end
    return prototyper or "", raw_tech or ""
end

local function GetAllMissingIngredients(recipe, builder, inventory)
    if not recipe then return nil end
    local missing = {}

    if recipe.ingredients then
        for _, v in pairs(recipe.ingredients) do
            local is_catalyst = (v.amount == 0)
            local actual_needed = is_catalyst and 1 or GLOBAL.RoundBiasedUp(v.amount * builder:IngredientMod())
            local _, num_found = inventory:Has(v.type, actual_needed, true)
            if num_found < actual_needed then
                local diff = actual_needed - num_found
                local item_name = QA.GetLocalizedName(v.type, v.type)
                table.insert(missing, is_catalyst and item_name or (diff .. MEASURE_WORD .. item_name))
            end
        end
    end

    if recipe.character_ingredients then
        for _, v in pairs(recipe.character_ingredients) do
            local is_catalyst = (v.amount == 0)
            local actual_needed = is_catalyst and 1 or v.amount
            local _, num_found = builder:HasCharacterIngredient(v)
            if num_found < actual_needed then
                local diff = actual_needed - num_found
                local item_name = QA.GetLocalizedName(v.type, v.type)
                table.insert(missing, is_catalyst and item_name or (diff .. MEASURE_WORD .. item_name))
            end
        end
    end

    return #missing > 0 and table.concat(missing, ", ") or nil
end

local function FindRecipeIngredient(recipe, target_type, builder, inventory)
    if target_type:sub(-9) == "_material" then
        local is_unlocked = builder:KnowsRecipe(recipe.name) or GLOBAL.CanPrototypeRecipe(recipe.level, builder:GetTechTrees())
        return 1, is_unlocked and 1 or 0, true
    end

    if recipe.character_ingredients then
        for _, v in pairs(recipe.character_ingredients) do
            if target_type == v.type then
                local is_catalyst = (v.amount == 0)
                local actual_needed = is_catalyst and 1 or v.amount
                local _, num_found = builder:HasCharacterIngredient(v)
                return actual_needed, num_found, is_catalyst
            end
        end
    end

    for _, v in pairs(recipe.ingredients or {}) do
        if target_type == v.type then
            local is_catalyst = (v.amount == 0)
            local actual_needed = is_catalyst and 1 or GLOBAL.RoundBiasedUp(v.amount * builder:IngredientMod())
            local _, num_found = inventory:Has(target_type, actual_needed, true)
            return actual_needed, num_found, is_catalyst
        end
    end

    local _, num_found = inventory:Has(target_type, 1, true)
    return 1, num_found, false
end

function QA.AnnounceMergedRecipe(recipe, builder, inventory, owner, specific_ingredient_type, force_all_materials)
    if not recipe then return end

    local buffered = builder:IsBuildBuffered(recipe.name)
    local knows = builder:KnowsRecipe(recipe.name) or GLOBAL.CanPrototypeRecipe(recipe.level, builder:GetTechTrees())
    local can_build = builder:CanBuild(recipe.name)

    local strings_name = (recipe.nameoverride and QA.GetLocalizedName(recipe.nameoverride))
        or (recipe.name and QA.GetLocalizedName(recipe.name))
        or (recipe.product and QA.GetLocalizedName(recipe.product))

    local name = strings_name and strings_name:lower() or LOCAL_STRINGS.UNKNOWN_NAME
    name = QA.ApplyCustomName(recipe.nameoverride or recipe.name or recipe.product, name)

    local prototype, raw_tech = GetPrototype(knows, recipe, owner)
    local debug_str = string.format(DEBUG_STR.RECIPE_CODE, tostring(recipe.name))
    if raw_tech and raw_tech ~= "" then
        debug_str = debug_str .. string.format(DEBUG_STR.TECH_CODE, string.lower(tostring(raw_tech)))
    end

    local qa_recipe = QA.SCHEME.RECIPE
    local qa_const = QA.SCHEME.CONSTRUCTION_AND_TRADE

    if buffered then
        return QA.Announce(GLOBAL.subfmt(qa_recipe.FORMATS.BUFFERED, {
            ITEM = name, PROTOTYPE = prototype
        }), nil, debug_str, QA.GetStatementLoc("RECIPE", "BUFFERED"))
    end

    local and_proto = prototype ~= "" and GLOBAL.subfmt(QA.GetMapping(qa_const, "WORDS", "AND_PROTOTYPE"), { PROTOTYPE = prototype }) or ""
    local but_proto = prototype ~= "" and GLOBAL.subfmt(QA.GetMapping(qa_const, "WORDS", "BUT_PROTOTYPE"), { PROTOTYPE = prototype }) or ""

    if specific_ingredient_type and not force_all_materials then
        local actual_needed, num_found, is_catalyst = FindRecipeIngredient(recipe, specific_ingredient_type, builder, inventory)
        local num_missing = actual_needed - num_found
        local ingredient_name = QA.GetLocalizedName(specific_ingredient_type, specific_ingredient_type)

        if specific_ingredient_type:sub(-9) == "_material"
            and qa_recipe.MAPPINGS and qa_recipe.MAPPINGS.DEFAULT and qa_recipe.MAPPINGS.DEFAULT.PROTOTYPER then
            ingredient_name = qa_recipe.MAPPINGS.DEFAULT.PROTOTYPER[specific_ingredient_type:upper()] or ingredient_name
        end

        local fmts = {
            RECIPE = name,
            AND_PROTOTYPE = and_proto,
            BUT_PROTOTYPE = but_proto,
        }

        if num_missing <= 0 then
            fmts.INGREDIENT = ingredient_name
            if is_catalyst then
                return QA.Announce(GLOBAL.subfmt(qa_const.FORMATS.CRAFT_HAVE_CATALYST, fmts), nil, debug_str, QA.GetStatementLoc("CONSTRUCTION_AND_TRADE", "CRAFT_HAVE_CATALYST"))
            else
                fmts.TOTAL_NUM = num_found
                fmts.REQ_NUM = actual_needed
                fmts.CRAFT_COUNT = actual_needed > 0 and math.floor(num_found / actual_needed) or 1
                return QA.Announce(GLOBAL.subfmt(qa_const.FORMATS.CRAFT_HAVE, fmts), nil, debug_str, QA.GetStatementLoc("CONSTRUCTION_AND_TRADE", "CRAFT_HAVE"))
            end
        elseif not QA.DATA.ANNOUNCE_ALL_MISSING_INGREDIENTS then
            local amount_fmt = QA.GetMapping(qa_const, "WORDS", "AMOUNT_FMT")
            fmts.INGREDIENT = is_catalyst and ingredient_name or GLOBAL.subfmt(amount_fmt, { NUM = num_missing, ITEM = ingredient_name })
            return QA.Announce(GLOBAL.subfmt(qa_const.FORMATS.CRAFT_NEED, fmts), nil, debug_str, QA.GetStatementLoc("CONSTRUCTION_AND_TRADE", "CRAFT_NEED"))
        end
    end

    if not force_all_materials and can_build and knows then
        return QA.Announce(GLOBAL.subfmt(qa_recipe.FORMATS.WILL_MAKE, {
            ITEM = name, PROTOTYPE = prototype
        }), nil, debug_str, QA.GetStatementLoc("RECIPE", "WILL_MAKE"))
    end

    if not force_all_materials and not QA.DATA.ANNOUNCE_ALL_MISSING_INGREDIENTS and not specific_ingredient_type then
        local fmt_key = knows and "WE_NEED" or "CAN_SOMEONE"
        return QA.Announce(GLOBAL.subfmt(qa_recipe.FORMATS[fmt_key], {
            ITEM = name, PROTOTYPE = prototype
        }), nil, debug_str, QA.GetStatementLoc("RECIPE", fmt_key))
    end

    local missing_str = GetAllMissingIngredients(recipe, builder, inventory)
    if missing_str then
        return QA.Announce(GLOBAL.subfmt(qa_const.FORMATS.CRAFT_NEED, {
            INGREDIENT = missing_str, RECIPE = name, AND_PROTOTYPE = and_proto
        }), nil, debug_str, QA.GetStatementLoc("CONSTRUCTION_AND_TRADE", "CRAFT_NEED"))
    else
        return QA.Announce(GLOBAL.subfmt(qa_const.FORMATS.CRAFT_HAVE_ALL, {
            RECIPE = name, BUT_PROTOTYPE = but_proto
        }), nil, debug_str, QA.GetStatementLoc("CONSTRUCTION_AND_TRADE", "CRAFT_HAVE_ALL"))
    end
end

-- 容器统计/施工点宣告
local RECHARGEABLE_PREFABS = {
    wurt_swampitem_shadow = GLOBAL.TUNING.WURT_TERRAFORMING_RECHARGE_TIME,
    wurt_swampitem_lunar  = GLOBAL.TUNING.WURT_TERRAFORMING_RECHARGE_TIME,
    shadow_beef_bell      = GLOBAL.TUNING.SHADOW_BEEF_BELL_REVIVE_COOLDOWN,
    pocketwatch_heal      = GLOBAL.TUNING.POCKETWATCH_HEAL_COOLDOWN,
    pocketwatch_revive    = GLOBAL.TUNING.POCKETWATCH_REVIVE_COOLDOWN,
    pocketwatch_warp      = GLOBAL.TUNING.POCKETWATCH_WARP_COOLDOWN,
    pocketwatch_recall    = GLOBAL.TUNING.POCKETWATCH_RECALL_COOLDOWN,
    pocketwatch_portal    = GLOBAL.TUNING.POCKETWATCH_RECALL_COOLDOWN
}

local function check_item(v, name, target_prefab, use_alias)
    if v and (name == nil or v:GetDisplayName() == name) then
        local alias_map = QA.ITEM_PREFAB_ALIAS
        if (use_alias and alias_map[v.prefab] == target_prefab) or (not use_alias and v.prefab == target_prefab) then
            return v.replica.stackable and v.replica.stackable:StackSize() or 1
        end
    end
    return 0
end

local function CountItems(container, name, target_prefab, use_alias)
    if not container then return 0 end
    local num_found = 0

    if container.GetItems then
        for _, v in pairs(container:GetItems() or {}) do
            num_found = num_found + check_item(v, name, target_prefab, use_alias)
        end
    end
    if container.GetBoatEquips then
        for _, v in pairs(container:GetBoatEquips() or {}) do
            num_found = num_found + check_item(v, name, target_prefab, use_alias)
        end
    end
    if container.GetActiveItem then
        num_found = num_found + check_item(container:GetActiveItem(), name, target_prefab, use_alias)
    end
    if container.GetOverflowContainer and container:GetOverflowContainer() then
        num_found = num_found + CountItems(container:GetOverflowContainer(), name, target_prefab, use_alias)
    end

    return num_found
end

local function get_container_name(container)
    if not container then return end
    local name = container:GetBasicDisplayName()
    local prefab = container.prefab

    if type(name) == "string" and name:find("^[ \t\r\n]*$") and prefab and prefab:find("_container") then
        name = GLOBAL.STRINGS.NAMES[prefab:sub(1, prefab:find("_container") - 1):upper()]
    end
    return (prefab and LOCAL_STRINGS[prefab:upper()]) or (name and name:lower())
end

local EQUIP_SLOT_MAP = {
    HEAD = "SLOT_HEAD", HANDS = "SLOT_HANDS", BODY = "SLOT_BODY",
    BACK = "SLOT_BACK", NECK = "SLOT_NECK", BELLY = "SLOT_BELLY", MEDAL = "SLOT_MEDAL"
}

local function GetEquipSlotName(qa_scheme, equipslot)
    if not equipslot then return nil end
    local key = string.upper(tostring(equipslot))
    for k, v in pairs(GLOBAL.EQUIPSLOTS) do
        if equipslot == v then
            key = k
            break
        end
    end
    return (EQUIP_SLOT_MAP[key] and QA.GetMapping(qa_scheme, "WORDS", EQUIP_SLOT_MAP[key])) or tostring(equipslot)
end

local function GetItemCountWrapper(container, item, match_name)
    if not container then return 0 end
    if container.Has and not container.GetBoatEquips and not container:Has(item.prefab, 1) then
        return 0
    end
    local target_name = match_name and item:GetDisplayName() or nil
    local alias = QA.ITEM_PREFAB_ALIAS[item.prefab]
    return CountItems(container, target_name, alias or item.prefab, alias ~= nil)
end

function QA.AnnounceConstructionSite(site, container_widget, slot_index)
    local site_rep = site and site.replica and site.replica.constructionsite
    if not site_rep then return false end

    local plans = site_rep:GetIngredients()
        or GLOBAL.CONSTRUCTION_PLANS[site.prefab]
        or (site.nameoverride and GLOBAL.CONSTRUCTION_PLANS[site.nameoverride])
    if not plans then return false end

    local container_rep = container_widget and container_widget.inst and container_widget.inst.replica.container
    local site_name = QA.GetEntityName(site, false)
    local is_trade = site:HasTag("offerconstructionsite")
        or (container_widget and container_widget.inst and container_widget.inst:HasTag("offerconstructionsite"))

    local qa_const = QA.SCHEME.CONSTRUCTION_AND_TRADE
    local prefix = is_trade and "TRADE_" or "CONS_"
    local debug_str = string.format(
        DEBUG_STR.SITE_CODE,
        tostring(site.prefab),
        tostring(container_widget and container_widget.inst and container_widget.inst.prefab or DEBUG_STR.NONE)
    )

    local function GetSlotCurrent(idx)
        local in_slot = container_rep and container_rep:GetItemInSlot(idx)
        local slot_cnt = in_slot and (in_slot.replica.stackable and in_slot.replica.stackable:StackSize() or 1) or 0
        return (site_rep:GetSlotCount(idx) or 0) + slot_cnt
    end

    if slot_index and plans[slot_index] then
        local plan = plans[slot_index]
        local missing = plan.amount - GetSlotCurrent(slot_index)
        local ing_name = QA.GetLocalizedName(plan.type, plan.type)
        local amount_fmt = QA.GetMapping(qa_const, "WORDS", "AMOUNT_FMT") or "{NUM} {ITEM}"

        if missing <= 0 then
            local fmt_name = prefix .. (qa_const.FORMATS[prefix .. "HAVE_ITEM"] and "HAVE_ITEM" or "HAVE")
            return QA.Announce(GLOBAL.subfmt(qa_const.FORMATS[fmt_name], {
                RECIPE = site_name,
                INGREDIENT = GLOBAL.subfmt(amount_fmt, { NUM = plan.amount, ITEM = ing_name })
            }), nil, debug_str, QA.GetStatementLoc("CONSTRUCTION_AND_TRADE", fmt_name))
        elseif not QA.DATA.ANNOUNCE_ALL_MISSING_INGREDIENTS then
            local fmt_name = prefix .. "NEED"
            return QA.Announce(GLOBAL.subfmt(qa_const.FORMATS[fmt_name], {
                INGREDIENT = GLOBAL.subfmt(amount_fmt, { NUM = missing, ITEM = ing_name }),
                RECIPE = site_name
            }), nil, debug_str, QA.GetStatementLoc("CONSTRUCTION_AND_TRADE", fmt_name))
        end
    end

    local missing, total_req = {}, {}
    for i, plan in ipairs(plans) do
        local current = GetSlotCurrent(i)
        local name = QA.GetLocalizedName(plan.type, plan.type)
        table.insert(total_req, plan.amount .. MEASURE_WORD .. name)
        if plan.amount - current > 0 then
            table.insert(missing, (plan.amount - current) .. MEASURE_WORD .. name)
        end
    end

    if #missing > 0 then
        local fmt_name = prefix .. "NEED"
        return QA.Announce(GLOBAL.subfmt(qa_const.FORMATS[fmt_name], {
            INGREDIENT = table.concat(missing, ", "), RECIPE = site_name
        }), nil, debug_str, QA.GetStatementLoc("CONSTRUCTION_AND_TRADE", fmt_name))
    else
        local fmt_name = prefix .. "HAVE"
        return QA.Announce(GLOBAL.subfmt(qa_const.FORMATS[fmt_name], {
            RECIPE = site_name, INGREDIENT = table.concat(total_req, ", ")
        }), nil, debug_str, QA.GetStatementLoc("CONSTRUCTION_AND_TRADE", fmt_name))
    end
end

function QA.AnnounceItem(slot, classname)
    if not slot then return false end
    if not (slot.tile and slot.tile.item) then
        return QA.AnnounceSlot(slot, classname)
    end

    local qa_item = QA.SCHEME.ITEM
    local item = slot.tile.item
    local ThePlayer = GLOBAL.ThePlayer

    local is_player_inv = (slot.container == nil or slot.container.type == "pack" or slot.container.inst == ThePlayer)
    local container = is_player_inv and ThePlayer.replica.inventory or slot.container
    local is_external = (container ~= ThePlayer.replica.inventory and container.inst ~= ThePlayer)

    local percent, percent_type
    if slot.tile.percent then
        percent = slot.tile.percent:GetString()
        percent_type = "DURABILITY"
    elseif slot.tile.hasspoilage and item.replica.inventoryitem and item.replica.inventoryitem.classified then
        percent = math.floor(item.replica.inventoryitem.classified.perish:value() * (1 / .62)) .. "%"
        percent_type = "FRESHNESS"
    end

    local num_equipped_prefab, num_equipped_name = 0, 0
    if not is_external and ThePlayer.replica.inventory then
        for _, _slot in pairs(GLOBAL.EQUIPSLOTS) do
            local eq = ThePlayer.replica.inventory:GetEquippedItem(_slot)
            if eq and eq.prefab == item.prefab then
                local s = eq.replica.stackable and eq.replica.stackable:StackSize() or 1
                num_equipped_prefab = num_equipped_prefab + s
                if eq:GetDisplayName() == item:GetDisplayName() then
                    num_equipped_name = num_equipped_name + s
                end
            end
        end
    end

    local container_inst = is_external and (container.inst or (container.entity and container)) or nil
    local container_name = nil
    if container_inst then
        container_name = get_container_name(container_inst)
        if not container_name then
            local parent_ent = container_inst.entity and container_inst.entity:GetParent()
            local cb = parent_ent and parent_ent.components and parent_ent.components.constructionbuilder
            if cb and cb.constructionsite then
                container_name = get_container_name(cb.constructionsite)
            end
        end
    end

    local display_name, prefab_name, is_player_named = QA.GetEntityName(item, false)
    local inv_count_prefab = GetItemCountWrapper(container, item, false)
    local inv_count_name = GetItemCountWrapper(container, item, true)

    local num_found_prefab = inv_count_prefab + num_equipped_prefab
    local num_found_name = inv_count_name + num_equipped_name

    local fmts = {
        PRONOUN = QA.GetMapping(qa_item, "PRONOUN", "I"),
        NUM = num_found_prefab,
        EQUIP_NUM = num_equipped_prefab,
        ITEM = "",
        IN_CONTAINER = "",
        WITH_PERCENT = "",
        POST_STATE = "",
        SHOW_ME = "",
        ITEM_NUM = num_equipped_prefab ~= num_found_prefab
            and GLOBAL.subfmt(QA.GetMapping(qa_item, "WORDS", "ITEM_NUM"), { NUM = num_found_prefab })
            or ""
    }

    if is_player_named or (num_found_prefab > num_found_name and display_name ~= prefab_name) then
        fmts.ITEM = prefab_name
        fmts.ITEM_NAME = GLOBAL.subfmt(QA.GetMapping(qa_item, "WORDS", "ITEM_NAME"), {
            NUM = num_found_name, NAME = display_name
        })
    else
        fmts.ITEM_NAME = ""
        fmts.ITEM = display_name
    end

    if container_name then
        fmts.PRONOUN = QA.GetMapping(qa_item, "PRONOUN", "WE")
        fmts.IN_CONTAINER = GLOBAL.subfmt(QA.GetMapping(qa_item, "WORDS", "IN_CONTAINER"), { NAME = container_name })
    end

    if classname == "equipslot" then
        fmts.SLOT_CODE = tostring(slot.equipslot)
        fmts.EQUIPSLOT = tostring(slot.equipslot)
    end

    if percent then
        fmts.WITH_PERCENT = GLOBAL.subfmt(QA.GetMapping(qa_item, "WORDS", "WITH_PERCENT"), {
            THIS_ONE = num_found_prefab > 1 and QA.GetMapping(qa_item, "WORDS", "THIS_ONE") or "",
            PERCENT = percent,
            TYPE = QA.GetMapping(qa_item, "PERCENT_TYPE", percent_type)
        })
    end

    if QA.DATA.ENABLE_SPECIAL_STATE and item.prefab == "heatrock" then
        local heat_stat = QA.GetHeatrockStat(item)
        if heat_stat then
            fmts.POST_STATE = QA.GetMapping(qa_item, "HEAT_ROCK", heat_stat)
        end
    end

    local recharge_netvar = item.replica.inventoryitem
        and item.replica.inventoryitem.classified
        and item.replica.inventoryitem.classified.recharge
    local recharge_val = recharge_netvar and recharge_netvar:value()
    local is_rechargeable = item:HasTag("rechargeable") or (recharge_val and recharge_val < 180)

    if is_rechargeable and recharge_val then
        if RECHARGEABLE_PREFABS[item.prefab] then
            local seconds = (180 - recharge_val) / 180 * RECHARGEABLE_PREFABS[item.prefab]
            if seconds <= 0 then
                fmts.POST_STATE = QA.GetMapping(qa_item, "RECHARGE", "FULL")
            else
                local mins = math.modf(seconds / 60)
                local secs = math.modf(math.fmod(seconds, 60))
                fmts.POST_STATE = GLOBAL.subfmt(QA.GetMapping(qa_item, "RECHARGE", "CHARGING"), {
                    TIME = (mins > 0 and (mins .. QA.GetMapping(qa_item, "TIME", "MINUTES")) or "")
                        .. secs .. QA.GetMapping(qa_item, "TIME", "SECONDS")
                })
            end
        elseif recharge_val == 180 then
            fmts.POST_STATE = QA.GetMapping(qa_item, "RECHARGE", "FULL")
        else
            fmts.POST_STATE = GLOBAL.subfmt(QA.GetMapping(qa_item, "RECHARGE", "PERCENT"), {
                PERCENT = math.floor((180 - recharge_val) / 180 * 100)
            })
        end
    end

    local start_line = #(string.split(item:GetBasicDisplayName(), "\n")) + 1
    local show_me_str = QA.GetShowMeString(item, qa_item, start_line, nil, nil, 2)
    if show_me_str ~= "" then
        fmts.SHOW_ME = show_me_str
    end

    local result_str
    local fmt_loc_key = "INV_SLOT"
    if classname == "invslot" then
        result_str = GLOBAL.subfmt(qa_item.FORMATS.INV_SLOT, fmts)
    else
        local is_heavy = item:HasTag("heavy")
        local slot_pos_name = GetEquipSlotName(qa_item, slot.equipslot)
        if slot_pos_name then
            fmts.SLOT_POS = slot_pos_name
            fmts.v = slot_pos_name
            fmt_loc_key = (is_heavy and qa_item.FORMATS.EQUIP_SLOT_HEAVY_POS) and "EQUIP_SLOT_HEAVY_POS" or "EQUIP_SLOT_POS"
        else
            fmt_loc_key = (is_heavy and qa_item.FORMATS.EQUIP_SLOT_HEAVY) and "EQUIP_SLOT_HEAVY" or "EQUIP_SLOT"
        end
        result_str = GLOBAL.subfmt(qa_item.FORMATS[fmt_loc_key], fmts)
    end

    local slot_name = classname == "equipslot" and tostring(slot.equipslot) or ("inv_" .. tostring(slot.num))
    local debug_txt = QA.GetContainerSlotDebugString(item, container and container.inst, slot_name, classname)
    return QA.Announce(result_str, nil, debug_txt, QA.GetStatementLoc("ITEM", fmt_loc_key))
end

local CONSTRUCTION_CONTAINERS = {
    construction_container = true,
    construction_container_1x1 = true,
    enable_shadow_rift_construction_container = true,
}

function QA.AnnounceSlot(w, classname)
    if not w then return false end
    classname = classname or (w.equipslot and "equipslot" or "invslot")
    local container = w.container or (GLOBAL.ThePlayer and GLOBAL.ThePlayer.replica.inventory)

    if container and container.inst and (CONSTRUCTION_CONTAINERS[container.inst.prefab] or container.inst:HasTag("offerconstructionsite")) then
        local site = GLOBAL.ThePlayer and GLOBAL.ThePlayer.components.constructionbuilderuidata
            and GLOBAL.ThePlayer.components.constructionbuilderuidata:GetTarget()
        if not site and container.inst.Transform then
            local px, py, pz = container.inst.Transform:GetWorldPosition()
            if px and py and pz then
                local ents = GLOBAL.TheSim:FindEntities(px, py, pz, 4, { "constructionsite" })
                site = ents and ents[1]
            end
        end
        if site and QA.AnnounceConstructionSite(site, container, w.num) then
            return true
        end

    elseif w.tile and w.tile.item then
        return QA.AnnounceItem(w, classname)

    elseif classname == "equipslot" then
        local qa_item = QA.SCHEME.ITEM
        local slot_code = tostring(w.equipslot or "unknown")
        local slot_pos_name = GetEquipSlotName(qa_item, w.equipslot) or slot_code
        local debug_str = QA.GetContainerSlotDebugString(nil, container and container.inst, slot_code, "equipslot", string.format(DEBUG_STR.EQUIP_SLOT_CODE, slot_code))

        return QA.Announce(GLOBAL.subfmt(qa_item.FORMATS.EQUIP_SLOT_EMPTY, {
            PRONOUN = QA.GetMapping(qa_item, "PRONOUN", "I"),
            SLOT_POS = slot_pos_name,
            v = slot_pos_name,
            SLOT_CODE = slot_code,
            EQUIPSLOT = slot_code,
            CODE = slot_code,
        }), nil, debug_str, QA.GetStatementLoc("ITEM", "EQUIP_SLOT_EMPTY"))

    elseif container and container.GetNumSlots and container.GetItems then
        local free_slots, total_slots = QA.GetContainerSlotStats(container)

        local inst = container.inst or (container.entity and container)
        local is_player = (inst == GLOBAL.ThePlayer)
        local is_pack = (container.type == "pack") or (inst and (inst:HasTag("INLIMBO") or inst:HasTag("inlimbo")))
        local cont_type = is_player and "PLAYER" or (is_pack and "INV" or "CONTAINER")

        local ui_code = classname == "invslot" and "inv" or tostring(classname)
        local slot_name = w.num and ("slot_" .. tostring(w.num)) or (w.equipslot and tostring(w.equipslot)) or "empty_slot"
        local debug_str = QA.GetContainerSlotDebugString(nil, inst, slot_name, ui_code, string.format(DEBUG_STR.CONTAINER_CAP, free_slots, total_slots))

        local space_formats = QA.SCHEME.SPACE.FORMATS
        local target_fmt = space_formats[cont_type] or space_formats.CONTAINER or space_formats.PLAYER
        local container_name = get_container_name(inst) or (inst and inst.prefab) or LOCAL_STRINGS.DEFAULT_CONTAINER_NAME

        return QA.Announce(GLOBAL.subfmt(target_fmt, {
            COUNT = free_slots,
            TOTAL = total_slots,
            CONTAINER_NAME = container_name,
            CONTAINER_CODE = inst and inst.prefab or "unknown"
        }), nil, debug_str, QA.GetStatementLoc("SPACE", cont_type))
    end

    return false
end

-- 制作栏与皮肤宣告
function QA.AnnounceSkin(recipepopup)
    if not recipepopup.focus then return end

    local skin_name = (recipepopup.skins_spinner and recipepopup.skins_spinner.GetItem())
        or (recipepopup.GetItem and recipepopup:GetItem())
    local recipe = recipepopup.recipe

    local upper_override = recipe.nameoverride and string.upper(recipe.nameoverride) or nil
    local upper_name = recipe.name and string.upper(recipe.name) or nil
    local upper_product = recipe.product and string.upper(recipe.product) or nil

    local item_name = (upper_override and GLOBAL.STRINGS.NAMES[upper_override])
        or (upper_name and GLOBAL.STRINGS.NAMES[upper_name])
        or (upper_product and GLOBAL.STRINGS.NAMES[upper_product])
        or recipe.name

    local prefab = recipe.product or recipe.name
    if skin_name == nil then
        if #recipepopup.skins_options == 1 then
            local fmt_key = (not GLOBAL.PREFAB_SKINS[prefab] or #GLOBAL.PREFAB_SKINS[prefab] == 0) and "NO_SKIN" or "HAS_NO_SKIN"
            return QA.Announce(GLOBAL.subfmt(QA.SCHEME.SKIN.FORMATS[fmt_key], { ITEM = item_name }), nil, nil, QA.GetStatementLoc("SKIN", fmt_key))
        end
        return
    end

    if skin_name ~= item_name then
        local num = #recipepopup.skins_options - 1
        return QA.Announce(GLOBAL.subfmt(QA.SCHEME.SKIN.FORMATS.DEFAULT, {
            SKIN = GLOBAL.GetSkinName(skin_name),
            ITEM = item_name,
            NUM = num,
            TOTAL = GLOBAL.PREFAB_SKINS[prefab] and #GLOBAL.PREFAB_SKINS[prefab] or num
        }), nil, nil, QA.GetStatementLoc("SKIN", "DEFAULT"))
    end
end

function QA.AnnounceRecipePinSlot(slot, recipepopup, ingnum)
    local recipe_state = slot.craftingmenu:GetRecipeState(slot.recipe_name)
    if not recipe_state or not recipe_state.recipe then return end

    local specific_ingredient_type = nil
    local recipe = recipe_state.recipe
    recipepopup = recipepopup or slot.recipe_popup

    if recipepopup then
        local ing = recipepopup.ing or {}
        if #ing == 0 and recipepopup.ingredients and recipepopup.ingredients.ingredient_widgets then
            ing = recipepopup.ingredients.ingredient_widgets
        elseif #ing == 0 and recipepopup.ingredients and recipepopup.ingredients.children then
            local root = next(recipepopup.ingredients.children) and recipepopup.ingredients.children[next(recipepopup.ingredients.children)]
            if root then
                for _, v in pairs(root.children) do
                    table.insert(ing, v)
                end
            end
        end

        local focused_index = ingnum
        if not focused_index then
            for i, _ing in ipairs(ing) do
                if _ing.focus then
                    focused_index = i
                    break
                end
            end
        end
        specific_ingredient_type = GetFocusedIngredientType(recipe, focused_index)
    end

    return QA.AnnounceMergedRecipe(recipe, slot.owner.replica.builder, slot.owner.replica.inventory, slot.owner, specific_ingredient_type)
end

function QA.AnnounceRecipeGrid(grid, owner)
    local idx = grid.focused_widget_index + grid.displayed_start_index
    if grid.focus and #grid.items > 0 and grid.items[idx] then
        return QA.AnnounceMergedRecipe(grid.items[idx].recipe, owner.replica.builder, owner.replica.inventory, owner, nil)
    end
end

function QA.AnnounceRecipeCMIngredients(ingredients)
    local recipe = ingredients.recipe
    if not recipe then return end

    local focused_index = nil
    if ingredients.ingredient_widgets then
        for i, widget in ipairs(ingredients.ingredient_widgets) do
            if widget.focus then
                focused_index = i
                break
            end
        end
    else
        local root = ingredients.children and next(ingredients.children) and ingredients.children[next(ingredients.children)]
        if root and root.children then
            local i = 1
            for _, _ing in pairs(root.children) do
                if _ing.focus then
                    focused_index = i
                    break
                end
                i = i + 1
            end
        end
    end

    return QA.AnnounceMergedRecipe(
        recipe,
        ingredients.owner.replica.builder,
        ingredients.owner.replica.inventory,
        ingredients.owner,
        GetFocusedIngredientType(recipe, focused_index)
    )
end