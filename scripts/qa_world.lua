-- scripts/qa_world.lua
-- 负责世界实体动画/状态解析、玩家状态交互、中键调试输出及周围环境实体宣告

local QA = GLOBAL.NOMU_QA
local LOCAL_STRINGS = GLOBAL.STRINGS.NOMU_QA or {}

--------------------------------------------------------------------------------
-- 1. 动画与实体状态检索
--------------------------------------------------------------------------------
local function CheckAnims(animState, anim_list)
    if not animState then return false end
    for _, anim in ipairs(anim_list) do
        if animState:IsCurrentAnimation(anim) then
            return true
        end
    end
    return false
end

local BASIC_PICKABLES = {
    grass = true, sapling = true, berrybush = true, berrybush2 = true,
    berrybush_juicy = true, reeds = true, bullkelp_plant = true,
    marsh_bush = true, lichen = true, cave_banana_tree = true,
    monkeytail = true, bananabush = true, sapling_moon = true,
    cactus = true, oasis_cactus = true, rock_avocado_bush = true,
    wormlight_plant = true, oceanvine = true, orchidbush = true,
    lilybush = true, nightrosebush = true, rosebush = true,
    coffeebush = true, rock_limpet = true
}

local ANIM_STATE_CONFIG = {
    crop = {
        { state = "SEED",  anims = {"crop_seed"} },
        { state = "GROW",  anims = {"crop_sprout", "crop_small", "crop_med"} },
        { state = "FULL",  anims = {"crop_full"} },
        { state = "OVER",  anims = {"crop_oversized"} },
        { state = "ROT",   anims = {"crop_rot", "crop_rot_oversized"} }
    },
    saltstack = {
        { state = "SALT_FULL",  anims = {"full", "med_to_full"} },
        { state = "SALT_MED",   anims = {"med", "low_to_med"} },
        { state = "SALT_LOW",   anims = {"low", "empty_to_low"} },
        { state = "SALT_EMPTY", anims = {"empty"} }
    },
    marbleshrub = {
        { state = "MARBLE_TALL",   anims = {"idle_tall", "hit_tall", "grow_normal_to_tall"} },
        { state = "MARBLE_NORMAL", anims = {"idle_normal", "hit_normal", "grow_short_to_normal"} },
        { state = "MARBLE_SHORT",  anims = {"idle_short", "hit_short", "grow_tall_to_short", "grow_seed_to_short"} }
    },
    beebox = {
        { state = "BEEBOX_FULL",  anims = {"honey3", "hit_honey3"} },
        { state = "BEEBOX_SOME",  anims = {"honey2", "hit_honey2", "honey1", "hit_honey1"} },
        { state = "BEEBOX_EMPTY", anims = {"bees_loop", "hit_idle", "idle", "place"} }
    },
    mushroom_farm = {
        { state = "MUSHROOMFARM_ROTTEN",  anims = {"expired"} },
        { state = "MUSHROOMFARM_STAGE4",  anims = {"mushroom_4_idle", "hit_mushroom_4", "mushroom_4"} },
        { state = "MUSHROOMFARM_STAGE3",  anims = {"mushroom_3_idle", "hit_mushroom_3", "mushroom_3"} },
        { state = "MUSHROOMFARM_STAGE2",  anims = {"mushroom_2_idle", "hit_mushroom_2", "mushroom_2"} },
        { state = "MUSHROOMFARM_STAGE1",  anims = {"mushroom_1_idle", "hit_mushroom_1", "mushroom_1"} },
        { state = "MUSHROOMFARM_EMPTY",   anims = {"idle", "hit_idle", "place"} }
    },
    lureplant = {
        { state = "PICKABLE_EMPTY", anims = {"idle_empty", "idle_hidden", "hibernate", "picked", "emerge", "hidebait", "grow_bait"} }
    },
    tree = {
        { state = "SAPLING", anims = {"idle_sapling"} },
        { state = "SHORT",   anims = {"idle_short", "sway1_loop_short", "sway2_loop_short", "sway_loop_short"} },
        { state = "NORMAL",  anims = {"idle_normal", "sway1_loop_normal", "sway2_loop_normal", "sway_loop_normal"} },
        { state = "TALL",    anims = {"idle_tall", "sway1_loop_tall", "sway2_loop_tall", "idle_old", "sway1_loop_old", "sway2_loop_old"} }
    },
    spiderden = {
        { state = 1, anims = {"cocoon_small", "cocoon_small_hit", "frozen_small", "frozen_loop_pst_small", "cocoon_small_bedazzled"} },
        { state = 2, anims = {"cocoon_medium", "cocoon_medium_hit", "frozen_medium", "frozen_loop_pst_medium", "cocoon_medium_bedazzled", "grow_small_to_medium"} },
        { state = 3, anims = {"cocoon_large", "cocoon_large_hit", "frozen_large", "frozen_loop_pst_large", "cocoon_large_bedazzled", "grow_medium_to_large", "cocoon_sleep_loop"} }
    }
}

local function GetStateFromAnimConfig(config_key, animState, default_state)
    if not animState or not ANIM_STATE_CONFIG[config_key] then
        return default_state
    end
    for _, config in ipairs(ANIM_STATE_CONFIG[config_key]) do
        if CheckAnims(animState, config.anims) then
            return config.state
        end
    end
    return default_state
end

local function GetSpiderDenStat(ent)
    if not ent then return nil end
    if ent:HasTag("shadowchesspiece") then
        return ent:HasTag("smallepic") and "L2" or (ent:HasTag("epic") and "L3" or "L1")
    end

    if not ent:HasTag("spiderden") then return nil end
    local level = (ent:HasTag("tent") and 3)
        or (ent.prefab == "spiderden_2" and 2)
        or (ent.prefab == "spiderden_3" and 3)
        or GetStateFromAnimConfig("spiderden", ent.AnimState, nil)
    if not level then return nil end
    return "L" .. tostring(level) .. (ent:HasTag("bedazzled") and "_BEDAZZLED" or "")
end

local function GetTreeStat(ent)
    if not ent then return nil end
    if ent:HasTag("stump") then return "STUMP" end

    if ent:HasTag("rock_tree") then
        if ent:HasTag("boulder") then return "BOULDER" end
        if ent.AnimState and CheckAnims(ent.AnimState, {"idle_normal", "sway1_loop_normal"}) then
            return "TALL"
        end
    end

    if ent.prefab and string.find(ent.prefab, "ancienttree") then
        if string.find(ent.prefab, "sapling") then
            if ent:HasTag("seedstage") or (ent.AnimState and ent.AnimState:IsCurrentAnimation("idle_planted")) then
                return "SEED"
            end
            if ent.AnimState and ent.AnimState:IsCurrentAnimation("sprout_idle") then
                return "SAPLING"
            end
        end
        if ent:HasTag("ancienttree") then
            return ent:HasTag("pickable") and "ANCIENT_READY" or "ANCIENT_EMPTY"
        end
    end

    if ent.prefab == "marblebean_sapling" then return "SEED" end
    if ent.prefab and string.find(ent.prefab, "sapling") and not string.find(ent.prefab, "dug_") then
        return "SAPLING"
    end

    if ent:HasTag("mushtree") then
        local sx = ent.Transform:GetScale()
        if sx < 0.95 then return "SHORT" end
        if sx > 1.05 then return "TALL" end
        return "NORMAL"
    end

    return GetStateFromAnimConfig("tree", ent.AnimState)
end

function QA.GetHeatrockStat(ent)
    if not ent or ent.prefab ~= "heatrock" or not ent.AnimState then return nil end
    local states = { "COLD", "COOL", "NORMAL", "WARM", "HOT" }
    for i = 1, 5 do
        if ent.AnimState:IsCurrentAnimation(tostring(i)) then
            return states[i]
        end
    end
    return nil
end

local function GetGenericCropStat(entity)
    if entity:HasTag("farm_plant") then
        return GetStateFromAnimConfig("crop", entity.AnimState)
    elseif entity.prefab == "waterplant" then
        return entity:HasTag("harvestable") and "WITH_BARNACLES" or "NO_BARNACLES"
    elseif entity.prefab == "saltstack" then
        return GetStateFromAnimConfig("saltstack", entity.AnimState)
    elseif entity.prefab == "marbleshrub" then
        return GetStateFromAnimConfig("marbleshrub", entity.AnimState)
    elseif entity:HasTag("beebox") then
        return GetStateFromAnimConfig("beebox", entity.AnimState)
    elseif entity.prefab == "mushroom_farm" then
        return GetStateFromAnimConfig("mushroom_farm", entity.AnimState)
    elseif entity.prefab == "tallbirdnest" then
        return entity:HasTag("pickable") and "NEST_HAS_EGG" or "NEST_EMPTY"
    elseif entity.prefab == "lureplant" then
        return GetStateFromAnimConfig("lureplant", entity.AnimState, "PICKABLE_READY")
    elseif BASIC_PICKABLES[entity.prefab] then
        return entity:HasTag("pickable") and "PICKABLE_READY" or "PICKABLE_EMPTY"
    end
    return nil
end

local SPECIAL_STATE_DISPATCHER = {
    trophyscale_fish = function(ent)
        if ent.AnimState and CheckAnims(ent.AnimState, {"nofish_idle", "nofish_hit", "spawn"}) then
            return "TROPHYSCALE_EMPTY"
        end
        return "TROPHYSCALE_HAS"
    end,

    trophyscale_oversizedveggies = function(ent)
        if ent.AnimState and CheckAnims(ent.AnimState, {"noveg_idle", "noveg_hit", "spawn"}) then
            return "TROPHYSCALE_EMPTY"
        end
        return "TROPHYSCALE_HAS"
    end,

    fruitdragon = function(ent)
        local ripe = (ent.AnimState and ent.AnimState:GetBuild() == "fruit_dragon_ripe_build")
            or string.find(ent:GetDisplayName() or "", "Ripe")
        return ripe and "FRUITDRAGON_RIPE" or nil
    end,

    beefalo = function(ent)
        return not ent:HasTag("has_beard") and "BEEFALO_SHAVED" or nil
    end,

    archive_switch = function(ent)
        if ent.AnimState and CheckAnims(ent.AnimState, {"idle_full", "activate"}) then
            return "ARCHIVE_SWITCH_FULL"
        end
        return "ARCHIVE_SWITCH_EMPTY"
    end,

    heatrock = function(ent, is_target)
        if not is_target then return nil end
        local heat_stat = QA.GetHeatrockStat(ent)
        return heat_stat and ("HEATROCK_" .. heat_stat) or nil
    end,

    birdcage = function(ent, is_target)
        if not is_target then return nil end
        if ent.AnimState then
            if ent.AnimState:IsCurrentAnimation("idle_empty") then
                return "BIRDCAGE_EMPTY"
            elseif CheckAnims(ent.AnimState, {"idle_sick", "idle_sick2", "idle_sick3", "fall_sick"}) then
                return "BIRDCAGE_SICK"
            elseif CheckAnims(ent.AnimState, {"death", "idle_death", "idle_skeleton"}) then
                return "BIRDCAGE_DEAD"
            end
        end
        return "BIRDCAGE_FULL"
    end
}

local function GetEntitySpecialState(entity, is_target)
    if not entity then return nil end

    if entity:HasTag("fire") then return "FIRE" end
    if entity:HasTag("burnt") then return "BURNT" end
    if entity:HasTag("smolder") then return "SMOLDER" end
    if entity:HasTag("withered") then return "WITHERED" end
    if entity:HasTag("barren") then return "BARREN" end
    if entity.prefab == "lightninggoat" and entity:HasTag("charged") then return "GOAT_CHARGED" end

    local stat = GetGenericCropStat(entity) or GetTreeStat(entity) or GetSpiderDenStat(entity)
    if stat then return stat end

    if SPECIAL_STATE_DISPATCHER[entity.prefab] then
        return SPECIAL_STATE_DISPATCHER[entity.prefab](entity, is_target)
    end
    return nil
end

--------------------------------------------------------------------------------
-- 2. 玩家状态探测与世界点击交互
--------------------------------------------------------------------------------
local function IsPlayerFishing(player)
    local inventory = player.replica.inventory
    local equip = inventory and inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS)
    if not equip then return false end

    if equip.replica.fishingrod and equip.replica.fishingrod:GetTarget() ~= nil then
        return true
    end
    if equip.replica.oceanfishingrod then
        if type(equip.replica.oceanfishingrod.GetBobber) == "function" and equip.replica.oceanfishingrod:GetBobber() ~= nil then
            return true
        end
        if type(equip.replica.oceanfishingrod.GetTarget) == "function" and equip.replica.oceanfishingrod:GetTarget() ~= nil then
            return true
        end
    end
    return false
end

local function IsPlayerFrozenOrThawing(entity)
    if not entity or not entity:IsValid() then return false end
    if entity.sg ~= nil and entity.sg:HasStateTag("frozen") then return true end
    return CheckAnims(entity.AnimState, {"frozen", "frozen_loop_pst", "frozen_hit", "frozen_pst", "frozen_loop"})
end

local function IsPlayerSleeping(entity)
    return entity ~= nil and entity:IsValid() and CheckAnims(entity.AnimState, {"sleep_loop"})
end

local function HandlePlayerClick(entity)
    local is_fishing = IsPlayerFishing(entity)
    local is_frozen = IsPlayerFrozenOrThawing(entity)
    local is_sleeping = IsPlayerSleeping(entity)
    local is_me_ghost = GLOBAL.ThePlayer:HasTag("playerghost")
    local is_ent_ghost = entity:HasTag("playerghost")
    local qa_formats = QA.SCHEME.PLAYER.FORMATS
    local debug_str = QA.GetEntityDebugString(entity)
    local name = entity:GetDisplayName()

    local function SayPlayer(fmt_key, extra_fmts)
        if not qa_formats[fmt_key] then return false end
        local fmts = extra_fmts or {}
        fmts.NAME = name
        return QA.Announce(GLOBAL.subfmt(qa_formats[fmt_key], fmts), nil, debug_str, QA.GetStatementLoc("PLAYER", fmt_key))
    end

    if entity == GLOBAL.ThePlayer then
        if is_me_ghost then return SayPlayer("I_AM_GHOST") end
        if is_frozen then return SayPlayer("ME_FROZEN") end
        if is_sleeping then return SayPlayer("ME_SLEEPING") end
        if is_fishing then return SayPlayer("ME_FISHING") end

        local rider = entity.replica.rider
        if rider and rider:IsRiding() then
            local mount_name = QA.GetEntityName(rider:GetMount(), false)
            if qa_formats.ME_RIDING then
                return SayPlayer("ME_RIDING", { MOUNT = mount_name })
            end
        end

        local inventory = entity.replica.inventory
        local equip_body = inventory and inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.BODY)
        if equip_body and equip_body:HasTag("heavy") and qa_formats.ME_CARRYING then
            return SayPlayer("ME_CARRYING", { ITEM = QA.GetEntityName(equip_body, false) })
        end

        return SayPlayer("I_AM_HERE")
    end

    local my_inventory = GLOBAL.ThePlayer.replica.inventory
    local active_item = my_inventory and my_inventory:GetActiveItem()
    if active_item then
        return SayPlayer("GIVE_ITEM", {
            NUM = active_item.replica.stackable and active_item.replica.stackable:StackSize() or 1,
            ITEM_NAME = string.gsub(active_item:GetDisplayName(), "\n", " ")
        })
    end

    if is_me_ghost or is_ent_ghost then
        local fmt_key = (is_me_ghost and is_ent_ghost) and "BOTH_GHOST" or (is_me_ghost and "ME_GHOST" or "THEY_GHOST")
        return SayPlayer(fmt_key)
    end

    if is_frozen and qa_formats.THEY_FROZEN then return SayPlayer("THEY_FROZEN") end
    if is_sleeping and qa_formats.THEY_SLEEPING then return SayPlayer("THEY_SLEEPING") end
    if is_fishing and qa_formats.THEY_FISHING then return SayPlayer("THEY_FISHING") end

    return SayPlayer("GREET")
end

function QA.HandleEnvMiddleClick(entity)
    if not GLOBAL.TheInput:IsKeyDown(GLOBAL.KEY_LCTRL) and entity:HasTag("player") then
        if entity == GLOBAL.ThePlayer then
            return QA.Announce(GLOBAL.subfmt(QA.SCHEME.PLAYER.FORMATS.PING, {
                PING = GLOBAL.TheNet:GetPing()
            }), nil, nil, QA.GetStatementLoc("PLAYER", "PING"))
        else
            return QA.Announce(GLOBAL.subfmt(QA.SCHEME.PLAYER.FORMATS.GREET, {
                NAME = entity:GetDisplayName()
            }), nil, nil, QA.GetStatementLoc("PLAYER", "GREET"))
        end
    end

    local qa_env = QA.SCHEME.ENV
    local safe_prefab = entity.prefab or "UNKNOWN"
    local mod_name = QA.GetModNameForPrefab(safe_prefab)
    local mod_str = mod_name and GLOBAL.subfmt(QA.GetMapping(qa_env, "WORDS", "MOD_INFO"), { MOD_NAME = mod_name }) or ""

    local entity_info = GLOBAL.subfmt(qa_env.FORMATS.CODE, {
        PREFAB = safe_prefab,
        NAME = entity:GetDisplayName(),
        MOD_INFO = mod_str,
        ASSET_INFO = ""
    })

    print(entity_info)
    GLOBAL.ThePlayer.components.talker:Say(entity_info, 5)
    return true
end

--------------------------------------------------------------------------------
-- 3. 世界实体总宣告入口
--------------------------------------------------------------------------------
function QA.AnnounceEntity(entity, is_single)
    if not entity or not entity:IsValid() then return false end

    if not GLOBAL.TheInput:IsKeyDown(GLOBAL.KEY_LCTRL) and entity:HasTag("player") then
        return HandlePlayerClick(entity)
    end

    local ThePlayer = GLOBAL.ThePlayer
    local qa_env = QA.SCHEME.ENV
    local px, py, pz = entity:GetPosition():Get()
    local is_on_water = GLOBAL.TheWorld.Map
        and GLOBAL.TheWorld.Map:IsOceanAtPoint(px, py, pz)
        and (entity.GetCurrentPlatform == nil or entity:GetCurrentPlatform() == nil)

    local radius = type(QA.DATA.ANNOUNCE_RANGE) == "number" and QA.DATA.ANNOUNCE_RANGE or 40
    local entities = GLOBAL.TheSim:FindEntities(px, py, pz, radius)

    local target_state = GetEntitySpecialState(entity, true)
    local display_name, prefab_name, is_player_named = QA.GetEntityName(entity, false)
    local target_name = (entity.GetDisplayName and type(entity.GetDisplayName) == "function") and (entity:GetDisplayName() or "") or ""

    local count_prefab, count_name, stat_count = 0, 0, 0
    local is_shadow_centipede_piece = entity:HasTag("shadowthrall_centipede")
    local is_worm_boss_piece = entity:HasTag("worm_boss_piece")
    local centipede_has_piece = false
    local centipede_head_count = 0
    local alias_map = QA.ITEM_PREFAB_ALIAS

    for _, v in ipairs(entities) do
        local is_same_entity = false
        if is_shadow_centipede_piece and v:HasTag("shadowthrall_centipede") then
            is_same_entity = true
            centipede_has_piece = true
            if v.prefab == "shadowthrall_centipede_head" then
                centipede_head_count = centipede_head_count + 1
            end
        elseif is_worm_boss_piece and v:HasTag("worm_boss_piece") then
            is_same_entity = true
        elseif v == entity or (entity.prefab ~= nil and
                ((alias_map[entity.prefab] and alias_map[entity.prefab] == alias_map[v.prefab])
                or v.prefab == entity.prefab)) then
            is_same_entity = true
        end

        if v.entity:IsVisible() and is_same_entity then
            local v_name = (v.GetDisplayName and type(v.GetDisplayName) == "function") and v:GetDisplayName() or ""
            local s = v.replica and v.replica.stackable and v.replica.stackable:StackSize() or 1
            count_prefab = count_prefab + s
            if v_name == target_name then count_name = count_name + s end
            if target_state and GetEntitySpecialState(v, false) == target_state then
                stat_count = stat_count + s
            end
        end
    end

    if is_worm_boss_piece then
        local boss_count = 0
        for _, v in pairs(GLOBAL.Ents) do
            if v.prefab == "worm_boss" and v:GetDistanceSqToInst(entity) <= 10000 then
                boss_count = boss_count + 1
            end
        end
        count_prefab = math.max(1, boss_count)
        count_name = count_prefab
    elseif is_shadow_centipede_piece then
        local boss_count = math.ceil(centipede_head_count / 2)
        if boss_count == 0 and centipede_has_piece then boss_count = 1 end
        count_prefab = boss_count
        count_name = boss_count
    end

    local debug_str = QA.GetEntityDebugString(entity)
    local start_line = #(string.split(entity:GetBasicDisplayName(), "\n")) + 1
    local show_me = QA.GetShowMeString(entity, qa_env, start_line, nil, nil, 2)

    local dist_str = ""
    local show_dist = QA.DATA.SHOW_DISTANCE
    if show_dist > 0 then
        local raw_dist = math.sqrt(ThePlayer:GetDistanceSqToInst(entity)) / 4
        if raw_dist >= 1 then
            local dist_val = (show_dist == 2) and string.format("%.1f", raw_dist) or math.floor(raw_dist)
            local word_key = is_on_water and "DISTANCE_FAR_WATER" or "DISTANCE_FAR"
            dist_str = GLOBAL.subfmt(QA.GetMapping(qa_env, "WORDS", word_key) or QA.GetMapping(qa_env, "WORDS", "DISTANCE_FAR"), { DIST = dist_val })
        else
            local word_key = is_on_water and "DISTANCE_CLOSE_WATER" or "DISTANCE_CLOSE"
            dist_str = QA.GetMapping(qa_env, "WORDS", word_key) or QA.GetMapping(qa_env, "WORDS", "DISTANCE_CLOSE")
        end
    end

    if entity.prefab == "gelblob_storage" then
        local held_item = entity.takeitem and entity.takeitem:value()
        if held_item ~= nil and held_item:IsValid() then
            local item_display_name = QA.GetEntityName(held_item, false)
            local stack_size = held_item.replica and held_item.replica.stackable and held_item.replica.stackable:StackSize() or 1
            return QA.Announce(GLOBAL.subfmt(qa_env.FORMATS.STORAGE_HAS, {
                TOTAL = count_prefab, NAME = prefab_name, NUM = stack_size,
                ITEM = item_display_name, SHOW_ME = show_me, DISTANCE = dist_str
            }), entity:HasTag("player"), debug_str, QA.GetStatementLoc("ENV", "STORAGE_HAS"))
        else
            local empty_count = 0
            for _, v in ipairs(entities) do
                if v.prefab == "gelblob_storage" and v.entity:IsVisible() then
                    local v_item = v.takeitem and v.takeitem:value()
                    if v_item == nil or not v_item:IsValid() then
                        empty_count = empty_count + 1
                    end
                end
            end

            local fmt_name = "STORAGE_EMPTY"
            if count_prefab == 1 then
                fmt_name = qa_env.FORMATS.STORAGE_EMPTY_THIS_SINGLE and "STORAGE_EMPTY_THIS_SINGLE" or "STORAGE_EMPTY_THIS"
            elseif empty_count == count_prefab then
                fmt_name = qa_env.FORMATS.STORAGE_EMPTY_EQUAL and "STORAGE_EMPTY_EQUAL" or "STORAGE_EMPTY"
            elseif empty_count == 1 then
                fmt_name = qa_env.FORMATS.STORAGE_EMPTY_THIS and "STORAGE_EMPTY_THIS" or "STORAGE_EMPTY"
            end

            return QA.Announce(GLOBAL.subfmt(qa_env.FORMATS[fmt_name], {
                TOTAL = count_prefab, NAME = prefab_name, NUM = empty_count,
                SHOW_ME = show_me, DISTANCE = dist_str
            }), entity:HasTag("player"), debug_str, QA.GetStatementLoc("ENV", fmt_name))
        end
    end

    if entity.prefab == "icefishing_hole" then
        return QA.Announce(GLOBAL.subfmt(qa_env.FORMATS.SINGLE, {
            NAME = LOCAL_STRINGS.ICEFISHING_HOLE, SHOW_ME = show_me, DISTANCE = dist_str
        }), entity:HasTag("player"), debug_str, QA.GetStatementLoc("ENV", "SINGLE"))
    end

    if entity.prefab == "townportal" then
        local is_on = entity.AnimState and entity.AnimState:IsCurrentAnimation("idle_on_loop")
        local fmt_key = is_on and "PORTAL_ON" or "PORTAL_OFF"
        return QA.Announce(GLOBAL.subfmt(QA.SCHEME.PLAYER.FORMATS[fmt_key], { NAME = display_name }), entity:HasTag("player"), debug_str, QA.GetStatementLoc("PLAYER", fmt_key))
    end

    -- 鱼群宣告
    if entity:HasTag("oceanfishable") and entity:HasTag("oceanfishinghookable")
        and not string.find(entity.prefab or "", "flotsam") then

        local adj = GLOBAL.STRINGS.UI.CUSTOMIZATIONSCREEN.OCEAN_SHOAL or LOCAL_STRINGS.OCEAN_SHOAL
        local shoal_name = adj
        local fish_name = GLOBAL.STRINGS.NAMES.FISH or "Fish"

        if entity.name and type(entity.name) == "string"
            and entity.name ~= "" and entity.name ~= adj then
            fish_name = QA.GetLocalizedName(entity.name, entity.name)
            shoal_name = GLOBAL.STRINGS.UI.OBJECTOWNERSHIP
                and GLOBAL.subfmt(GLOBAL.STRINGS.UI.OBJECTOWNERSHIP, { owner = fish_name, object = adj })
                or shoal_name
        end

        local f_c = 0
        for _, v in ipairs(entities) do
            if (v:HasTag("oceanfish") or v:HasTag("oceanfishable"))
                and v.prefab == entity.prefab then
                f_c = f_c + 1
            end
        end

        return QA.Announce(GLOBAL.subfmt(qa_env.FORMATS.FISH_SHOAL, {
            NAME = shoal_name, NUM = f_c, FISH = fish_name,
            SHOW_ME = show_me, DISTANCE = dist_str
        }), entity:HasTag("player"), debug_str, QA.GetStatementLoc("ENV", "FISH_SHOAL"))
    end

    if is_single then
        return QA.Announce(GLOBAL.subfmt(qa_env.FORMATS.SINGLE, {
            NAME = display_name, SHOW_ME = show_me, DISTANCE = dist_str
        }), entity:HasTag("player"), debug_str, QA.GetStatementLoc("ENV", "SINGLE"))
    end

    if QA.DATA.ENABLE_SPECIAL_STATE and target_state then
        local is_specific_only = (entity.prefab == "heatrock" or entity.prefab == "birdcage")
        if is_specific_only or count_prefab == 1 then
            local fmt_name = count_prefab > 1 and "STATE_THIS" or "STATE_THIS_SINGLE"
            return QA.Announce(GLOBAL.subfmt(qa_env.FORMATS[fmt_name], {
                TOTAL = count_prefab, NAME = prefab_name,
                ADJ = QA.GetMapping(qa_env, "ADJ", target_state) or target_state,
                SHOW_ME = show_me, DISTANCE = dist_str
            }), entity:HasTag("player"), debug_str, QA.GetStatementLoc("ENV", fmt_name))
        else
            local fmt_name = (stat_count == count_prefab) and "STATE_EQUAL" or "STATE_DESCRIBE"
            return QA.Announce(GLOBAL.subfmt(qa_env.FORMATS[fmt_name], {
                TOTAL = count_prefab, NUM = stat_count, NAME = prefab_name,
                ADJ = QA.GetMapping(qa_env, "ADJ", target_state) or target_state,
                SHOW_ME = show_me, DISTANCE = dist_str
            }), entity:HasTag("player"), debug_str, QA.GetStatementLoc("ENV", fmt_name))
        end
    end

    local actual_prefab = tostring(entity.prefabnameoverride or entity.nameoverride or entity.prefab)
    if prefab_name ~= actual_prefab and display_name ~= prefab_name and (is_player_named or count_prefab > count_name) then
        local fmt_name = (count_prefab == 1 and "NAMED_THIS_SINGLE") or (count_name == 1 and "NAMED_THIS") or "NAMED"
        if qa_env.FORMATS[fmt_name] then
            return QA.Announce(GLOBAL.subfmt(qa_env.FORMATS[fmt_name], {
                NUM_PREFAB = count_prefab, PREFAB_NAME = prefab_name, NUM = count_name,
                NAME = display_name, SHOW_ME = show_me, DISTANCE = dist_str
            }), entity:HasTag("player"), debug_str, QA.GetStatementLoc("ENV", fmt_name))
        end
    end

    local final_count = (display_name == prefab_name) and count_prefab or count_name
    local fmt_name = final_count <= 1 and "SINGLE" or "DEFAULT"
    return QA.Announce(GLOBAL.subfmt(qa_env.FORMATS[fmt_name], {
        NUM = final_count, NAME = display_name, SHOW_ME = show_me, DISTANCE = dist_str
    }), entity:HasTag("player"), debug_str, QA.GetStatementLoc("ENV", fmt_name))
end