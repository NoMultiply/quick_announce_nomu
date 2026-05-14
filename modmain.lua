-- [1] 初始化
GLOBAL.setmetatable(env, { __index = function(_, k) return GLOBAL.rawget(GLOBAL, k) end })

-- 导入其他 Lua 文件的辅助函数
local function Import(modulename)
    local f = GLOBAL.kleiloadlua(modulename)
    if f and type(f) == "function" then
        setfenv(f, GLOBAL)
        return f()
    end
end

Upvaluehelper = Import(MODROOT .. "bbgoat_upvaluehelper.lua")

-- 深拷贝函数，用于安全地复制 Table
local function DeepCopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy

    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[DeepCopy(orig_key, copies)] = DeepCopy(orig_value, copies)
            end
            setmetatable(copy, DeepCopy(getmetatable(orig), copies))
        end
    else
        copy = orig
    end

    return copy
end

--提取字符串中的所有占位符并排序，用于比对
local function GetPlaceholders(str)
    local placeholders = {}
    if type(str) == "string" then
        for p in str:gmatch("{(.-)}") do
            placeholders[p] = true
        end
    end
    local sorted = {}
    for p in pairs(placeholders) do table.insert(sorted, p) end
    table.sort(sorted)
    return table.concat(sorted, ",")
end

local function IsPlaceholderMatch(str1, str2)
    return GetPlaceholders(str1) == GetPlaceholders(str2)
end

-- 检查当前是否在游戏主界面 (HUD) 且没有在打字
local function IsDefaultScreen()
    local active_screen = GLOBAL.TheFrontEnd:GetActiveScreen()
    local screen = active_screen and active_screen.name or ""
    local focus = GLOBAL.TheFrontEnd:GetFocusWidget()
    local is_typing = focus ~= nil and focus.inst ~= nil and focus.inst.TextEditWidget ~= nil

    if is_typing then
        return false
    end

    return screen:find("HUD") ~= nil
        and GLOBAL.ThePlayer ~= nil
        and not GLOBAL.ThePlayer.HUD:IsChatInputScreenOpen()
        and not GLOBAL.ThePlayer.HUD.writeablescreen
end

-- 导入各个配置与词库文件
modimport('scripts/qa_config/qa_default.lua')
modimport('scripts/qa_config/qa_cat.lua')
modimport('scripts/qa_config/qa_tsundere.lua')
modimport('scripts/qa_config/qa_cute.lua')
modimport('scripts/qa_config/qa_utils.lua')

-- [2] 全局数据
local DEFAULT_SCHEME = DeepCopy(GLOBAL.STRINGS.DEFAULT_NOMU_QA)
local VERSION = 1

-- 检查是否启用了 Show Me
local SHOW_ME_ON = ModManager:GetMod("workshop-666155465") ~= nil or ModManager:GetMod("workshop-2287303119") ~= nil

GLOBAL.NOMU_QA = {
    DATA = {
        DEFAULT_WHISPER = false,
        CHARACTER_SPECIFIC = true,
        FREQ_AUTO_CLOSE = true,
        SHOW_ME = 1,
        ANNOUNCE_RANGE = 40,
        FUZZY_ANNOUNCE = false,
        SHOW_PREFIX = true,
        SHOW_DISTANCE = 0,
        SHOW_MOD_NAME = false,
        SHOW_ASSET_INFO = 0,
        BLOCK_ACTION = true,
        ANNOUNCE_ALL_MISSING_INGREDIENTS = true,
        DEBUG_MODE = false,
        ENABLE_FORBIDDEN = true,
        ENABLE_REPLACE = true,
        FREQ_LIST = { STRINGS.NOMU_QA.FREQ_EXAMPLE },
        ENABLE_CUSTOM_PREFAB_NAME = true,
        ENABLE_SPECIAL_STATE = true,
        ENABLE_SHOWME_FILTER = true,
        CUSTOM_PREFAB_NAMES = {},
        SHOWME_FILTERS = {},
        FORBIDDEN_WORDS = {},
        REPLACEMENTS = {},
        SCHEMES = {
            {
                name = STRINGS.NOMU_QA.TITLE_TEXT_DEFAULT_SCHEME,
                data = DeepCopy(GLOBAL.STRINGS.DEFAULT_NOMU_QA),
                version = VERSION
            }
        },
        CURRENT_SCHEME = {
            name = STRINGS.NOMU_QA.TITLE_TEXT_DEFAULT_SCHEME,
            data = DeepCopy(GLOBAL.STRINGS.DEFAULT_NOMU_QA),
            version = VERSION
        }
    },
    SCHEME = DEFAULT_SCHEME
}


-- 三方同步
local function SyncSchemeData(user_data, backup_data, source_data, is_legacy)
    if not source_data or type(source_data) ~= "table" then return end
    
    for k, v in pairs(source_data) do
        if type(v) == "table" then
            if type(user_data[k]) ~= "table" then user_data[k] = {} end
            if not is_legacy and type(backup_data[k]) ~= "table" then backup_data[k] = {} end
            SyncSchemeData(user_data[k], backup_data[k], v, is_legacy)
        else
            if is_legacy then
                -- 老方案处理逻辑：
                -- 如果用户原本没有这个字段，直接补全
                -- 如果用户有这个字段，但占位符与源码不一致，强制覆盖（防止崩溃）
                -- 其他情况（占位符一致），保留用户文案
                -- 老方案或多或少还是有问题，并不能完美同步
                if user_data[k] == nil or not IsPlaceholderMatch(user_data[k], v) then
                    user_data[k] = v
                end
            else
                if backup_data[k] ~= v then
                    user_data[k] = v
                    backup_data[k] = v
                end
            end
        end
    end
end

-- 更新方案，每次启动游戏执行同步校验
GLOBAL.NOMU_QA.UpdateScheme = function(scheme_node)
    if not scheme_node or not scheme_node.data then return end

    local BUILTIN_LOOKUP = {
        [GLOBAL.STRINGS.NOMU_QA.TITLE_TEXT_DEFAULT_SCHEME] = GLOBAL.STRINGS.DEFAULT_NOMU_QA,
        [GLOBAL.STRINGS.NOMU_QA.TITLE_TEXT_CAT_SCHEME] = GLOBAL.STRINGS.CAT_NOMU_QA,
        [GLOBAL.STRINGS.NOMU_QA.TITLE_TEXT_TSUNDERE_SCHEME] = GLOBAL.STRINGS.TSUNDERE_NOMU_QA,
        [GLOBAL.STRINGS.NOMU_QA.TITLE_TEXT_CUTE_SCHEME] = GLOBAL.STRINGS.CUTE_NOMU_QA,
    }

    local is_legacy = false
    if not scheme_node.source_template and not scheme_node.backup_data then
        is_legacy = true
        -- 以默认方案作为比对基准
        scheme_node.source_template = GLOBAL.STRINGS.NOMU_QA.TITLE_TEXT_DEFAULT_SCHEME
        scheme_node.backup_data = DeepCopy(GLOBAL.STRINGS.DEFAULT_NOMU_QA)
    end

    local source_name = scheme_node.source_template or scheme_node.name
    local source_data = BUILTIN_LOOKUP[source_name] or GLOBAL.STRINGS.DEFAULT_NOMU_QA

    SyncSchemeData(scheme_node.data, scheme_node.backup_data, source_data, is_legacy)
end

-- 应用宣告方案
GLOBAL.NOMU_QA.ApplyScheme = function(scheme)
    if not scheme then return end

    if not scheme.data then
        print("[NoMu QA] 检测到方案数据丢失，已自动修复坏档！")
        scheme.data = DeepCopy(GLOBAL.STRINGS.DEFAULT_NOMU_QA)
    end

    GLOBAL.NOMU_QA.UpdateScheme(scheme)
    GLOBAL.NOMU_QA.SCHEME = scheme.data
end


-- 本地存储文件路径
local DATA_FILE = 'mod_config_data/nomu_quick_announce_v3'

-- 通用的数据类型纠正函数
local function EnsureDataType(template_val, saved_val)
    local t_type = type(template_val)
    local s_type = type(saved_val)

    if t_type == s_type then return saved_val end

    if t_type == "number" and s_type == "boolean" then
        return saved_val and 1 or 0
    end

    if t_type == "boolean" and s_type == "number" then
        return saved_val > 0
    end

    return template_val
end

-- 加载本地数据并执行同步
GLOBAL.NOMU_QA.LoadData = function()
    TheSim:GetPersistentString(DATA_FILE, function(load_success, str)
        if load_success and #str > 0 then
            local run_success, data = RunInSandboxSafe(str)
            if run_success and type(data) == "table" then
                for k, template_value in pairs(GLOBAL.NOMU_QA.DATA) do
                    if data[k] ~= nil then
                        GLOBAL.NOMU_QA.DATA[k] = EnsureDataType(template_value, data[k])
                    end
                end
            end
        end

        local BUILTIN_SCHEMES = {
            { name = STRINGS.NOMU_QA.TITLE_TEXT_DEFAULT_SCHEME, source = GLOBAL.STRINGS.DEFAULT_NOMU_QA },
            { name = STRINGS.NOMU_QA.TITLE_TEXT_CAT_SCHEME, source = GLOBAL.STRINGS.CAT_NOMU_QA },
            { name = STRINGS.NOMU_QA.TITLE_TEXT_TSUNDERE_SCHEME, source = GLOBAL.STRINGS.TSUNDERE_NOMU_QA },
            { name = STRINGS.NOMU_QA.TITLE_TEXT_CUTE_SCHEME, source = GLOBAL.STRINGS.CUTE_NOMU_QA }
        }

        local schemes = GLOBAL.NOMU_QA.DATA.SCHEMES
        if schemes then
            --  强制刷新前4个内置方案
            for i, template in ipairs(BUILTIN_SCHEMES) do
                if not schemes[i] or schemes[i].name ~= template.name then
                    local new_scheme = { name = template.name, data = DeepCopy(template.source), version = VERSION }
                    if not schemes[i] then
                        schemes[i] = new_scheme
                    else
                        table.insert(schemes, i, new_scheme)
                    end
                else
                    schemes[i].data = DeepCopy(template.source)
                    schemes[i].name = template.name
                end
            end

            for i, scheme in ipairs(schemes) do
                if i > 4 then 
                    GLOBAL.NOMU_QA.UpdateScheme(scheme)
                end
            end
        end

        local current = GLOBAL.NOMU_QA.DATA.CURRENT_SCHEME
        if current then
            for _, template in ipairs(BUILTIN_SCHEMES) do
                if current.name == template.name then
                    current.data = DeepCopy(template.source)
                    break
                end
            end
            GLOBAL.NOMU_QA.ApplyScheme(current)
        end
    end)
end

-- 保存本地数据
GLOBAL.NOMU_QA.SaveData = function()
    SavePersistentString(DATA_FILE, DataDumper(GLOBAL.NOMU_QA.DATA, nil, true), false, nil)
end


-- [3] 核心辅助工具 

-- 转义正则特殊字符
local function escape_pattern(text)
    return text:gsub("([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
end

-- 批量检查动画状态
local function CheckAnims(animState, anim_list)
    if not animState then return false end
    for _, anim in ipairs(anim_list) do
        if animState:IsCurrentAnimation(anim) then return true end
    end
    return false
end

-- 通用字符串前缀清理工具
local function CleanPrefixName(raw_display, base_name, current_name)
    local final_name = current_name
    if GLOBAL.NOMU_QA.DATA.SHOW_PREFIX then
        local display_no_n = string.gsub(raw_display, '\n', '')
        local display_spaced = string.gsub(raw_display, '\n', ' ')
        if base_name and base_name ~= "" then
            if display_no_n ~= base_name and string.find(display_no_n, base_name, 1, true) then
                final_name = string.gsub(display_no_n, escape_pattern(base_name), final_name)
            elseif display_spaced ~= base_name and string.find(display_spaced, base_name, 1, true) then
                final_name = string.gsub(display_spaced, escape_pattern(base_name), final_name)
            end
        else
            if final_name and display_no_n ~= final_name and string.find(display_no_n, final_name, 1, true) then
                final_name = display_no_n
            elseif final_name and display_spaced ~= final_name and string.find(display_spaced, final_name, 1, true) then
                final_name = display_spaced
            end
        end
    end
    return final_name
end

--  获取自定义预制物名称 
local function ApplyCustomName(prefab, original_name)
    if not GLOBAL.NOMU_QA.DATA.ENABLE_CUSTOM_PREFAB_NAME
        or not GLOBAL.NOMU_QA.DATA.CUSTOM_PREFAB_NAMES
        or not prefab then
        return original_name
    end

    local prefab_str = string.lower(tostring(prefab))
    for _, v in ipairs(GLOBAL.NOMU_QA.DATA.CUSTOM_PREFAB_NAMES) do
        if v.prefab and string.lower(v.prefab) == prefab_str and v.name ~= "" then
            return v.name
        end
    end
    return original_name
end

-- 核心发送宣告消息的函数
local function Announce(message, no_whisper, debug_info)
    -- 文本替换处理
    if GLOBAL.NOMU_QA.DATA.ENABLE_REPLACE and GLOBAL.NOMU_QA.DATA.REPLACEMENTS then
        for _, rule in ipairs(GLOBAL.NOMU_QA.DATA.REPLACEMENTS) do
            if rule.target and rule.target ~= "" then
                message = message:gsub(escape_pattern(rule.target), rule.result or "")
            end
        end
    end

    -- 处理温度符号
    message = message:gsub("(%d)\176", "%1°")

    -- 违禁词处理
    if GLOBAL.NOMU_QA.DATA.ENABLE_FORBIDDEN and GLOBAL.NOMU_QA.DATA.FORBIDDEN_WORDS then
        for _, word in ipairs(GLOBAL.NOMU_QA.DATA.FORBIDDEN_WORDS) do
            if word and word ~= "" then
                message = message:gsub(escape_pattern(word), "")
            end
        end
    end

    -- 去除多余的空格
    message = message:gsub("%s+", " "):gsub("^%s", ""):gsub("%s$", "")

    -- 拼接调试信息
    if GLOBAL.NOMU_QA.DATA.DEBUG_MODE and debug_info then
        message = message .. " " .. debug_info
    end

    -- 确定是否为私聊宣告
    local whisper = GLOBAL.NOMU_QA.DATA.DEFAULT_WHISPER ~= TheInput:IsKeyDown(KEY_LCTRL)
    if no_whisper then
        whisper = false
    end

    if message ~= "" then
        TheNet:Say(STRINGS.LMB .. ' ' .. message, whisper)
        return true
    end
    return false
end

-- 获取方案对应的映射文本
local function GetMapping(qa, category, key)
    local prefab = ThePlayer.prefab:upper()
    if GLOBAL.NOMU_QA.DATA.CHARACTER_SPECIFIC
        and qa.MAPPINGS[prefab]
        and qa.MAPPINGS[prefab][category]
        and qa.MAPPINGS[prefab][category][key] then

        return qa.MAPPINGS[prefab][category][key]
    end
    return qa.MAPPINGS.DEFAULT[category][key]
end

-- 发送带有表情符号和百分比的徽章类宣告
local function AnnounceBadge(qa, current, max, category)
    local fmts = {
        CURRENT = math.floor(current + 0.5),
        MAX = max,
        MESSAGE = GetMapping(qa, 'MESSAGE', category)
    }

    local emoji_key = GetMapping(qa, 'SYMBOL', 'EMOJI')
    if emoji_key and TheInventory:CheckOwnership('emoji_' .. emoji_key) then
        fmts.SYMBOL = ':' .. emoji_key .. ':'
    else
        fmts.SYMBOL = GetMapping(qa, 'SYMBOL', 'TEXT')
    end

    return Announce(subfmt(qa.FORMATS.DEFAULT, fmts))
end

-- 根据阈值获取百分比对应的层级
local function get_category(thresholds, percent)
    local i = 1
    while thresholds[i] ~= nil and percent >= thresholds[i] do
        i = i + 1
    end
    return i
end

-- 处理 Show Me 信息的公共方法
local function GetShowMeString(target, qa, start_line, end_line, p3, p4)
    if not SHOW_ME_ON then
        return ""
    end

    if not (GLOBAL.NOMU_QA.DATA.SHOW_ME == 1 or
           (GLOBAL.NOMU_QA.DATA.SHOW_ME == 2 and target:HasTag('unwrappable'))) then
        return ""
    end

    local items = GLOBAL.QA_UTILS.ParseHoverText(start_line, end_line, p3, p4)
    local filtered = {}
    local bad_prefab = (GLOBAL.STRINGS.NOMU_QA.HOVER_PREFAB_PREFIX or "Prefab:"):gsub("\n", "")
    local bad_bank = (GLOBAL.STRINGS.NOMU_QA.HOVER_BANK_PREFIX or "Bank:"):gsub("\n", "")
    local bad_build = (GLOBAL.STRINGS.NOMU_QA.HOVER_BUILD_PREFIX or "Build:"):gsub("\n", "")
    local bad_mod = (GLOBAL.STRINGS.NOMU_QA.SHOW_MOD_PREFIX or "Mod:"):gsub("\n", "")

    for _, str in ipairs(items) do
        if str and str:match("%S") then
            local is_banned = str:find(bad_prefab, 1, true)
                           or str:find(bad_bank, 1, true)
                           or str:find(bad_build, 1, true)
                           or str:find(bad_mod, 1, true)

            if not is_banned and GLOBAL.NOMU_QA.DATA.ENABLE_SHOWME_FILTER and GLOBAL.NOMU_QA.DATA.SHOWME_FILTERS then
                for _, bad_word in ipairs(GLOBAL.NOMU_QA.DATA.SHOWME_FILTERS) do
                    if bad_word and bad_word ~= "" and str:find(bad_word) then
                        is_banned = true
                        break
                    end
                end
            end

            if not is_banned then
                table.insert(filtered, str)
            end
        end
    end

    if target:HasTag("farm_plant") then
        local s = {}
        for i = 1, math.min(#filtered, 2) do
            table.insert(s, filtered[i])
        end
        filtered = s
    end

    if #filtered > 0 then
        local joined_str = table.concat(filtered, GLOBAL.STRINGS.NOMU_QA.COMMA or ", ")

        if #joined_str > 270 then
            joined_str = filtered[#filtered]
        end

        return subfmt(GetMapping(qa, 'WORDS', 'SHOW_ME'), { SHOW_ME = joined_str })
    end

    return ""
end


-- [4] 实体状态检测工具 
-- 常见可采摘植物列表
local BASIC_PICKABLES = {
    grass = true, sapling = true, berrybush = true, berrybush2 = true, berrybush_juicy = true,
    reeds = true, bullkelp_plant = true, marsh_bush = true, lichen = true, cave_banana_tree = true,
    monkeytail = true, bananabush = true, sapling_moon = true, cactus = true, oasis_cactus = true,
    rock_avocado_bush = true, wormlight_plant = true, oceanvine = true
}

-- 需要特殊判定
local SPECIAL_CROPS = {
    waterplant = true,
    saltstack = true,
    marbleshrub = true,
    mushroom_farm = true,
    tallbirdnest = true,
    lureplant = true
}

local function GetCropStat(animState)
    if not animState then return nil end
    if CheckAnims(animState, {"crop_seed"}) then return "SEED" end
    if CheckAnims(animState, {"crop_sprout", "crop_small", "crop_med"}) then return "GROW" end
    if CheckAnims(animState, {"crop_full"}) then return "FULL" end
    if CheckAnims(animState, {"crop_oversized"}) then return "OVER" end
    if CheckAnims(animState, {"crop_rot", "crop_rot_oversized"}) then return "ROT" end
    return nil
end

local function GetSaltStackStat(animState)
    if not animState then return nil end
    if CheckAnims(animState, {"full", "med_to_full"}) then return "SALT_FULL" end
    if CheckAnims(animState, {"med", "low_to_med"}) then return "SALT_MED" end
    if CheckAnims(animState, {"low", "empty_to_low"}) then return "SALT_LOW" end
    if CheckAnims(animState, {"empty"}) then return "SALT_EMPTY" end
    return nil
end

local function GetMarbleShrubStat(animState)
    if not animState then return nil end
    if CheckAnims(animState, {"idle_tall", "hit_tall", "grow_normal_to_tall"}) then return "MARBLE_TALL" end
    if CheckAnims(animState, {"idle_normal", "hit_normal", "grow_short_to_normal"}) then return "MARBLE_NORMAL" end
    if CheckAnims(animState, {"idle_short", "hit_short", "grow_tall_to_short", "grow_seed_to_short"}) then return "MARBLE_SHORT" end
    return nil
end

local function GetBeeboxStat(animState)
    if not animState then return nil end
    if CheckAnims(animState, {"honey3", "hit_honey3"}) then return "BEEBOX_FULL" end
    if CheckAnims(animState, {"honey2", "hit_honey2", "honey1", "hit_honey1"}) then return "BEEBOX_SOME" end
    if CheckAnims(animState, {"bees_loop", "hit_idle", "idle", "place"}) then return "BEEBOX_EMPTY" end
    return nil
end

local function GetMushroomFarmStat(animState)
    if not animState then return nil end
    if CheckAnims(animState, {"expired"}) then return "MUSHROOMFARM_ROTTEN" end
    if CheckAnims(animState, {"mushroom_4_idle", "hit_mushroom_4", "mushroom_4"}) then return "MUSHROOMFARM_STAGE4" end
    if CheckAnims(animState, {"mushroom_3_idle", "hit_mushroom_3", "mushroom_3"}) then return "MUSHROOMFARM_STAGE3" end
    if CheckAnims(animState, {"mushroom_2_idle", "hit_mushroom_2", "mushroom_2"}) then return "MUSHROOMFARM_STAGE2" end
    if CheckAnims(animState, {"mushroom_1_idle", "hit_mushroom_1", "mushroom_1"}) then return "MUSHROOMFARM_STAGE1" end
    if CheckAnims(animState, {"idle", "hit_idle", "place"}) then return "MUSHROOMFARM_EMPTY" end
    return nil
end

local function GetLureplantStat(animState)
    if not animState then return "PICKABLE_EMPTY" end
    if CheckAnims(animState, {"idle_empty", "idle_hidden", "hibernate", "picked", "emerge", "hidebait", "grow_bait"}) then
        return "PICKABLE_EMPTY"
    end
    return "PICKABLE_READY"
end

local function GetTreeStat(ent)
    if not ent then return nil end
    if ent:HasTag("stump") then return "STUMP" end

    if ent:HasTag("rock_tree") then
        if ent:HasTag("boulder") then return "BOULDER" end
        if ent.AnimState and CheckAnims(ent.AnimState, {"idle_normal", "sway1_loop_normal"}) then return "TALL" end
    end

    if ent.prefab == "marbleshrub" then return GetMarbleShrubStat(ent.AnimState) end
    if ent.prefab and string.find(ent.prefab, "marbletree") then return "MARBLE_TREE" end

    if ent.prefab and string.find(ent.prefab, "ancienttree") then
        if string.find(ent.prefab, "sapling") then
            if ent:HasTag("seedstage") or (ent.AnimState and ent.AnimState:IsCurrentAnimation("idle_planted")) then return "SEED" end
            if ent.AnimState and ent.AnimState:IsCurrentAnimation("sprout_idle") then return "SAPLING" end
        end
        if ent:HasTag("ancienttree") then
            if ent:HasTag("pickable") then return "ANCIENT_READY" else return "ANCIENT_EMPTY" end
        end
    end

    if ent.prefab == "marblebean_sapling" then return "SEED" end
    if ent.prefab and string.find(ent.prefab, "sapling") and not string.find(ent.prefab, "dug_") then return "SAPLING" end

    if ent:HasTag("mushtree") then
        local sx = ent.Transform:GetScale()
        if sx < 0.95 then return "SHORT" end
        if sx > 1.05 then return "TALL" end
        return "NORMAL"
    end

    local anim = ent.AnimState
    if not anim then return nil end
    if anim:IsCurrentAnimation("idle_sapling") then return "SAPLING" end
    if CheckAnims(anim, {"idle_short", "sway1_loop_short", "sway2_loop_short", "sway_loop_short"}) then return "SHORT" end
    if CheckAnims(anim, {"idle_normal", "sway1_loop_normal", "sway2_loop_normal", "sway_loop_normal"}) then return "NORMAL" end
    if CheckAnims(anim, {"idle_tall", "sway1_loop_tall", "sway2_loop_tall", "idle_old", "sway1_loop_old", "sway2_loop_old"}) then return "TALL" end

    return nil
end

local function GetSpiderDenStat(ent)
    if not ent then return nil end

    if ent:HasTag("shadowchesspiece") then
        if not ent:HasTag("epic") then return "L1"
        elseif ent:HasTag("smallepic") then return "L2"
        else return "L3" end
    end

    -- 蜘蛛巢等级判定
    if not ent:HasTag("spiderden") then return nil end
    local level = 1

    if ent:HasTag("tent") then
        level = 3
    else
        if ent.prefab == "spiderden_2" then level = 2
        elseif ent.prefab == "spiderden_3" then level = 3 end

        if ent.AnimState then
            if CheckAnims(ent.AnimState, {"cocoon_medium", "cocoon_medium_hit", "frozen_medium", "frozen_loop_pst_medium", "cocoon_medium_bedazzled", "grow_small_to_medium"}) then
                level = 2
            elseif CheckAnims(ent.AnimState, {"cocoon_large", "cocoon_large_hit", "frozen_large", "frozen_loop_pst_large", "cocoon_large_bedazzled", "grow_medium_to_large", "cocoon_sleep_loop"}) then
                level = 3
            end
        end
    end

    local bedazzled = ent:HasTag("bedazzled")
    return "L" .. tostring(level) .. (bedazzled and "_BEDAZZLED" or "")
end

local function GetHotspringStat(ent)
    if not ent or ent.prefab ~= "hotspring" then return nil end
    if ent:HasTag("moonglass") then return "GLASSED" end
    if ent.AnimState then
        if CheckAnims(ent.AnimState, {"glow_loop", "glow_pre", "bath_bomb"}) then return "BOMBED" end
        if ent.AnimState:IsCurrentAnimation("empty") then return "EMPTY" end
    end
    return nil
end


-- [5] 核心宣告逻辑与事件处理
local function OnHUDMouseButton(HUD)
    local status = HUD.controls.status
    local widget = TheInput:GetHUDEntityUnderMouse()
    local default_thresholds = { .15, .35, .55, .75 }
    local levels = { 'EMPTY', 'LOW', 'MID', 'HIGH', 'FULL' }

    -- 勋章 Buff 宣告
    if widget and widget.widget then
        local w = widget.widget
        local parent = w
        local buff_card = nil
        local is_medal_buff = false

        while parent do
            if parent.buff_time and parent.buff_name then
                buff_card = parent
            end
            if parent.name == "medalBuffPanel"
                or parent.name == "medal_buff_panel"
                or (HUD.owner and HUD.owner.medalBuffPanel == parent) then
                is_medal_buff = true
                break
            end
            parent = parent.parent
        end

        if is_medal_buff and buff_card then
            local buff_name = buff_card.buff_name:GetString() or "未知BUFF"
            local left_time = buff_card.buff_time:GetString() or ""
            local qa = GLOBAL.NOMU_QA.SCHEME.MEDAL_BUFF
            if qa then
                if left_time == "" or left_time == "--:--" then
                    return Announce(subfmt(qa.FORMATS.FOREVER, { BUFF_NAME = buff_name }))
                else
                    return Announce(subfmt(qa.FORMATS.DEFAULT, { BUFF_NAME = buff_name, TIME = left_time }))
                end
            end
        end
    end

    -- 绽放值宣告
    if status.bloombadge and status.bloombadge.focus and ThePlayer and ThePlayer.components._bloomness then
        local current = status.bloombadge.val or 0
        local max = status.bloombadge.max or 100
        local level = ThePlayer.components._bloomness:GetLevel()
        local stage = level

        if (stage == 1 or stage == 2) and not ThePlayer.components._bloomness.is_blooming then
            stage = stage + 3
        end

        local qa = GLOBAL.NOMU_QA.SCHEME.BLOOMNESS
        local fmts = {
            CURRENT = math.floor(current + 0.5),
            MAX = max,
            LEVEL = tostring(level),
            MESSAGE = GetMapping(qa, 'MESSAGE', "STAGE_" .. tostring(stage))
        }

        local emoji_key = GetMapping(qa, 'SYMBOL', 'EMOJI')
        if emoji_key and TheInventory:CheckOwnership('emoji_' .. emoji_key) then
            fmts.SYMBOL = ':' .. emoji_key .. ':'
        else
            fmts.SYMBOL = GetMapping(qa, 'SYMBOL', 'TEXT')
        end

        return Announce(subfmt(qa.FORMATS.DEFAULT, fmts))
    end

    -- 淘气值宣告
    if (status.naughtiness and status.naughtiness.focus) or (status.naughtybadge and status.naughtybadge.focus) then
        local current, max = 0, 50
        if status.naughtiness and status.naughtiness.num then
            local cur_str, max_str = string.match(status.naughtiness.num:GetString() or "", "(%d+)%s*/%s*(%d+)")
            if cur_str and max_str then
                current, max = tonumber(cur_str), tonumber(max_str)
            end
        end
        if max > 0 then
            return AnnounceBadge(
                GLOBAL.NOMU_QA.SCHEME.NAUGHTINESS,
                current,
                max,
                levels[get_category(default_thresholds, current / max)]
            )
        end
    end

    -- 幸运值宣告
    if (status.luck and status.luck.focus) or (status.luckbadge and status.luckbadge.focus) then
        return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.NAUGHTINESS.FORMATS.LUCK, {
            CURRENT = status.luck.num and status.luck.num:GetString() or "0.00"
        }))
    end

    -- Beefalo HUD 宣告 
    if HUD.controls and HUD.controls.BeefaloStatusBar and HUD.controls.BeefaloStatusBar:IsVisible() and not HUD.controls.BeefaloStatusBar.isHidden then
        local b_hud = HUD.controls.BeefaloStatusBar
        local w = widget and widget.widget
        local target_badge = nil

        while w do
            if w == b_hud.healthBadge or w == b_hud.domesticationBadge or w == b_hud.obedienceBadge or w == b_hud.timerBadge or w == b_hud.hungerBadge then
                target_badge = w
                break
            end
            w = w.parent
        end

        if target_badge then
            local qa = GLOBAL.NOMU_QA.SCHEME.BEEFALO
            if not qa then return false end

            local BEEFALO_CONFIG = {
                {
                    badge = b_hud.healthBadge,
                    fmt = qa.FORMATS.HEALTH,
                    fn = function(tb)
                        local pct = tb.percent or 0
                        local state = pct < 0.25 and 'HEALTH_LOW' or (pct > 0.8 and 'HEALTH_HIGH' or 'HEALTH_NORMAL')
                        return { MESSAGE = subfmt(GetMapping(qa, 'MESSAGE', state), { PCT = math.floor(pct * 100 + 0.5) }) }
                    end
                },
                {
                    badge = b_hud.hungerBadge,
                    condition = b_hud.isHungerVisible,
                    fmt = qa.FORMATS.HUNGER,
                    fn = function(tb)
                        local val = tonumber(tb.num and tb.num:GetString() or "0") or 0
                        local state = val < 50 and 'HUNGER_STARVING' or (val < 150 and 'HUNGER_HUNGRY' or (val > 300 and 'HUNGER_FULL' or 'HUNGER_NORMAL'))
                        return { MESSAGE = subfmt(GetMapping(qa, 'MESSAGE', state), { VAL = val }) }
                    end
                },
                {
                    badge = b_hud.obedienceBadge,
                    fmt = qa.FORMATS.OBEDIENCE,
                    fn = function(tb)
                        local pct = (tb.percent or 0) * 100
                        local state = pct < 40 and 'OBEDIENCE_LOW' or (pct > 80 and 'OBEDIENCE_HIGH' or 'OBEDIENCE_NORMAL')
                        return { MESSAGE = subfmt(GetMapping(qa, 'MESSAGE', state), { PCT = math.floor(pct + 0.5) }) }
                    end
                },
                {
                    badge = b_hud.domesticationBadge,
                    fmt = qa.FORMATS.DOMESTICATION,
                    fn = function(tb)
                        local pct = (tb.percent or 0) * 100
                        local state = pct >= 100 and 'DOMESTICATION_FULL' or (pct > 90 and 'DOMESTICATION_HIGH' or (pct < 10 and 'DOMESTICATION_LOW' or 'DOMESTICATION_NORMAL'))
                        local tendency_str = ""
                        if b_hud.tendency then
                            local t_name = GetMapping(qa, 'TENDENCY_NAME', b_hud.tendency) or b_hud.tendency
                            tendency_str = " (趋势: " .. t_name .. ")"
                        end
                        return {
                            MESSAGE = subfmt(GetMapping(qa, 'MESSAGE', state), { PCT = string.format("%.1f", pct) }),
                            TENDENCY = tendency_str
                        }
                    end
                },
                {
                    badge = b_hud.timerBadge,
                    fmt = qa.FORMATS.TIMER,
                    fn = function(tb)
                        local timeStr = tb.num and tb.num:GetString() or "0:00"
                        local timeLeft = 999
                        if b_hud.bucktime and b_hud.bucktime_start then
                            timeLeft = math.floor(b_hud.bucktime_start + b_hud.bucktime - GLOBAL.GetTime())
                        end
                        local state = timeLeft < 30 and 'TIMER_LOW' or 'TIMER_RIDING'
                        return { MESSAGE = subfmt(GetMapping(qa, 'MESSAGE', state), { TIME = timeStr }) }
                    end
                }
            }

            for _, cfg in ipairs(BEEFALO_CONFIG) do
                if target_badge == cfg.badge and (cfg.condition == nil or cfg.condition == true) then
                    return Announce(subfmt(cfg.fmt, cfg.fn(target_badge)))
                end
            end
        end
    end

    -- 通用属性徽章配置
    local BADGE_CONFIG = {
        {
            btn = status.pethungerbadge,
            comp = ThePlayer.pet_hunger_classified,
            qa = "WOBY_HUNGER",
            cur_fn = function(c) return c:GetPercent() * (c:Max() or 50) end,
            max_fn = function(c) return c:Max() or 50 end
        },
        {
            btn = status.waterstomach,
            comp = ThePlayer.replica.thirst,
            qa = "THIRST",
            cur_fn = function(c) return c:GetPercent() * (c:Max() or 100) end,
            max_fn = function(c) return c:Max() or 100 end
        },
        {
            btn = status.stomach,
            comp = ThePlayer.player_classified,
            qa = "STOMACH",
            cur_fn = function(c) return c.currenthunger:value() end,
            max_fn = function(c) return c.maxhunger:value() end
        },
        {
            btn = status.brain,
            comp = ThePlayer.player_classified,
            qa = "SANITY",
            cur_fn = function(c) return c.currentsanity:value() end,
            max_fn = function(c) return c.maxsanity:value() end
        },
        {
            btn = status.heart,
            comp = ThePlayer.player_classified,
            qa = "HEALTH",
            thresholds = { .25, .5, .75, 1 },
            cur_fn = function(c) return c.currenthealth:value() end,
            max_fn = function(c) return c.maxhealth:value() end
        },
        {
            btn = status.moisturemeter,
            comp = ThePlayer.player_classified,
            qa = "WETNESS",
            cur_fn = function(c) return c.moisture:value() end,
            max_fn = function(c) return c.maxmoisture:value() end
        },
        {
            btn = status.wereness,
            comp = ThePlayer.player_classified,
            qa = "LOG_METER",
            thresholds = { .25, .5, .7, .9 },
            cur_fn = function(c) return c.currentwereness:value() end,
            max_fn = function(c) return 100 end
        }
    }

    -- 遍历通用徽章进行宣告
    for _, cfg in ipairs(BADGE_CONFIG) do
        if cfg.btn and cfg.btn.focus and cfg.comp then
            local current, max = cfg.cur_fn(cfg.comp), cfg.max_fn(cfg.comp)
            local category = levels[get_category(cfg.thresholds or default_thresholds, current / max)]
            
            -- WX-78 护盾判定
            if cfg.qa == "HEALTH" and ThePlayer.prefab == "wx78" and ThePlayer.wx78_classified then
                local shield_cur = ThePlayer.wx78_classified.currentshield:value()
                local shield_max = ThePlayer.wx78_classified.maxshield:value()

                if shield_max > 1 then
                    local qa = GLOBAL.NOMU_QA.SCHEME[cfg.qa]
                    local fmts = {
                        CURRENT = math.floor(current + 0.5),
                        MAX = max,
                        SHIELD_CUR = shield_cur,
                        SHIELD_MAX = shield_max,
                        MESSAGE = GetMapping(qa, 'MESSAGE', category)
                    }

                    local emoji_key = GetMapping(qa, 'SYMBOL', 'EMOJI')
                    if emoji_key and TheInventory:CheckOwnership('emoji_' .. emoji_key) then
                        fmts.SYMBOL = ':' .. emoji_key .. ':'
                    else
                        fmts.SYMBOL = GetMapping(qa, 'SYMBOL', 'TEXT')
                    end

                    return Announce(subfmt(qa.FORMATS.WITH_SHIELD or qa.FORMATS.DEFAULT, fmts))
                end
            end

            return AnnounceBadge(
                GLOBAL.NOMU_QA.SCHEME[cfg.qa],
                current,
                max,
                category
            )
        end
    end

    -- 温度宣告
    if status.temperature and status.temperature.focus then
        local qa = GLOBAL.NOMU_QA.SCHEME.TEMPERATURE
        local temp = ThePlayer:GetTemperature()
        local fmts = {
            TEMPERATURE = string.format('%d', temp),
            MESSAGE = GetMapping(qa, 'MESSAGE', 'GOOD')
        }

        if temp >= TUNING.OVERHEAT_TEMP then
            fmts.MESSAGE = GetMapping(qa, 'MESSAGE', 'BURNING')
        elseif temp >= TUNING.OVERHEAT_TEMP - 5 then
            fmts.MESSAGE = GetMapping(qa, 'MESSAGE', 'HOT')
        elseif temp >= TUNING.OVERHEAT_TEMP - 15 then
            fmts.MESSAGE = GetMapping(qa, 'MESSAGE', 'WARM')
        elseif temp <= 0 then
            fmts.MESSAGE = GetMapping(qa, 'MESSAGE', 'FREEZING')
        elseif temp <= 5 then
            fmts.MESSAGE = GetMapping(qa, 'MESSAGE', 'COLD')
        elseif temp <= 15 then
            fmts.MESSAGE = GetMapping(qa, 'MESSAGE', 'COOL')
        end

        return Announce(subfmt(qa.FORMATS.DEFAULT, fmts))
    end

    -- 预判断焦点是否在温度计或季节表盘上
    local is_worldtemp_focus = status.worldtemp and status.worldtemp.focus
    local is_season_focus = (HUD.controls.seasonclock and HUD.controls.seasonclock.focus) or (status.season and status.season.focus)

    if is_worldtemp_focus or is_season_focus then

       local raw_season = TheWorld.state.season:upper()
       local SEASON = GetMapping(GLOBAL.NOMU_QA.SCHEME.SEASON, 'SEASON_NAMES', raw_season) 
                       or GLOBAL.STRINGS.UI.SERVERLISTINGSCREEN.SEASONS[raw_season] 
                       or raw_season

           -- 世界温度 & 降雨宣告
        if is_worldtemp_focus then
            local qa = GLOBAL.NOMU_QA.SCHEME.WORLD_TEMPERATURE_AND_RAIN
            
            -- 直接读取Combined Status上的文本
            local display_temp = math.floor(TheWorld.state.temperature + 0.5) .. "°"
            if status.worldtemp and status.worldtemp.num and status.worldtemp.num:GetString() then
                display_temp = status.worldtemp.num:GetString()
            end

            local px, py, pz = ThePlayer.Transform:GetWorldPosition()
            local is_winterland = TheWorld.components.winterlands_manager and TheWorld.components.winterlands_manager:IsWinterlandsAtPoint(px, py, pz)

            local fmts = {
                TEMPERATURE = display_temp,
                SEASON = SEASON,
                WEATHER = GetMapping(qa, 'WEATHER', raw_season)
            }
            local qa_fmt = qa.FORMATS.NO_RAIN

            if TheWorld.state.pop ~= 1 then
                local world, total_seconds, rain = GLOBAL.QA_UTILS.PredictRainStart()

                fmts.WORLD = is_winterland and GetMapping(qa, 'WORLD', 'WINTERLAND') or GetMapping(qa, 'WORLD', world)
                
                if rain then
                    fmts.DAYS, fmts.MINUTES, fmts.SECONDS = GLOBAL.QA_UTILS.FormatSeconds(total_seconds)
                    qa_fmt = qa.FORMATS.START_RAIN
                end
            else
                local world, total_seconds = GLOBAL.QA_UTILS.PredictRainStop()

                fmts.WORLD = is_winterland and GetMapping(qa, 'WORLD', 'WINTERLAND') or GetMapping(qa, 'WORLD', world)
                
                fmts.DAYS, fmts.MINUTES, fmts.SECONDS = GLOBAL.QA_UTILS.FormatSeconds(total_seconds)
                qa_fmt = qa.FORMATS.STOP_RAIN
            end

            return Announce(subfmt(qa_fmt, fmts))
        end
        -- 季节宣告
        if is_season_focus then
            local DAYS_LEFT = TheWorld.state.remainingdaysinseason
            if DAYS_LEFT == 10000 then DAYS_LEFT = "∞" end

            return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.SEASON.FORMATS.DEFAULT, {
                SEASON = SEASON,
                DAYS_LEFT = DAYS_LEFT
            }))
        end
    end

    -- 月相宣告
    if HUD.controls.clock
        and HUD.controls.clock._moonanim
        and HUD.controls.clock._moonanim.focus
        and HUD.controls.clock._moonanim.moontext then

        local qa = GLOBAL.NOMU_QA.SCHEME.MOON_PHASE
        local text_val = tostring(HUD.controls.clock._moonanim.moontext)

        if string.find(text_val, '?') ~= nil then
            return ThePlayer.components.talker:Say(qa.FORMATS.FAILED)
        end

        local moonment = string.match(text_val, '(%d+)') or 0
        local worldment = TheWorld.state.cycles + 1 or 0
        if moonment == 0 or worldment == 0 then return end

        local fmts = { INTERVAL = GetMapping(qa, 'INTERVAL', 'COMMA') }
        local moonleft = moonment - worldment

        if moonleft >= 10 then
            fmts.PHASE1 = GetMapping(qa, 'MOON', 'FULL')
            fmts.PHASE2 = GetMapping(qa, 'MOON', 'NEW')
        else
            fmts.PHASE1 = GetMapping(qa, 'MOON', 'NEW')
            fmts.PHASE2 = GetMapping(qa, 'MOON', 'FULL')
        end

        local judge = moonleft % 10
        if judge <= 1 then
            fmts.RECENT = judge == 0 and GetMapping(qa, 'RECENT', 'TODAY') or GetMapping(qa, 'RECENT', 'TOMORROW')
            judge, fmts.PHASE1, fmts.PHASE2 = judge + 10, fmts.PHASE2, fmts.PHASE1
            if worldment < 20 then
                return Announce(subfmt(qa.FORMATS.MOON, fmts))
            end
        elseif judge >= 8 then
            fmts.RECENT = GetMapping(qa, 'RECENT', 'AFTER')
        else
            fmts.RECENT, fmts.PHASE1, fmts.INTERVAL = '', '', GetMapping(qa, 'INTERVAL', 'NONE')
        end

        fmts.LEFT = judge
        return Announce(subfmt(qa.FORMATS.DEFAULT, fmts))
    end

    -- 时钟宣告
    if HUD.controls.clock and HUD.controls.clock.focus then
        local clock = TheWorld.net.components.clock
        if clock and clock._remainingtimeinphase and clock._phase and clock.CalcRemainTimeOfDay then
            local qa = GLOBAL.NOMU_QA.SCHEME.CLOCK
            local phases = { 'DAY', 'DUSK', 'NIGHT' }

            local function _fmt_time(secs)
                local m, s = math.modf(secs / 60), math.modf(math.fmod(secs, 60))
                return (m > 0 and (m .. GetMapping(qa, 'TIME', 'MINUTES')) or '')
                    .. s .. GetMapping(qa, 'TIME', 'SECONDS')
            end

            local fmt = qa.FORMATS.DEFAULT
            local fmts = {
                PHASE = GetMapping(qa, 'PHASE', phases[clock._phase:value()]),
                PHASE_REMAIN = _fmt_time(clock._remainingtimeinphase:value()),
                DAY_REMAIN = _fmt_time(clock.CalcRemainTimeOfDay())
            }

            if TheWorld.GetNightmareData then
                local data = TheWorld:GetNightmareData()
                fmt = (data.remain == 0 and data.total ~= 0) and qa.FORMATS.NIGHTMARE_LOCK or qa.FORMATS.NIGHTMARE
                fmts.NIGHTMARE = GetMapping(qa, 'NIGHTMARE', data.phase:upper())
                fmts.REMAIN = _fmt_time(data.remain)
                fmts.TOTAL = _fmt_time(data.total)
            end

            return Announce(subfmt(fmt, fmts))
        end
    end

    -- 船耐久宣告
    if status.boatmeter and status.boatmeter.focus then
        local qa = GLOBAL.NOMU_QA.SCHEME.BOAT
        local health = { 'EMPTY', 'LOW', 'MID', 'HIGH', 'FULL' }
        local max = status.boatmeter.boat.components.healthsyncer.max_health
        local current = status.boatmeter.boat.components.healthsyncer:GetPercent() * max
        local idx = math.floor(current / (max / 5 + 1)) + 1

        return Announce(subfmt(qa.FORMATS.DEFAULT, {
            CURRENT = math.floor(current + 0.5),
            MAX = max,
            MESSAGE = GetMapping(qa, 'MESSAGE', health[idx])
        }))
    end

    -- 阿比盖尔宣告
    if status.pethealthbadge and status.pethealthbadge.focus and status.pethealthbadge.nomu_max then
        local max = status.pethealthbadge.nomu_max
        local current = status.pethealthbadge.nomu_percent * max
        return AnnounceBadge(GLOBAL.NOMU_QA.SCHEME.ABIGAIL, current, max, levels[math.floor(current / (max / 5 + 1)) + 1])
    end

    -- 力量值宣告
    if status.mightybadge and status.mightybadge.focus and status.mightybadge.nomu_percent then
        local max = status.mightybadge.nomu_max or 100
        local current = status.mightybadge.nomu_percent * max
        local idx = current >= TUNING.MIGHTY_THRESHOLD and 3 or (current >= TUNING.WIMPY_THRESHOLD and 2 or 1)
        local mighty_states = { 'WIMPY', 'NORMAL', 'MIGHTY' }
        return AnnounceBadge(GLOBAL.NOMU_QA.SCHEME.MIGHTINESS, current, max, mighty_states[idx])
    end

    -- 灵感值宣告
    if status.inspirationbadge and status.inspirationbadge.focus and status.inspirationbadge.nomu_percent then
        local max = status.inspirationbadge.nomu_max or 100
        local pct = status.inspirationbadge.nomu_percent
        local idx = pct >= TUNING.BATTLESONG_THRESHOLDS[3] and 4
                 or (pct >= TUNING.BATTLESONG_THRESHOLDS[2] and 3
                 or (pct >= TUNING.BATTLESONG_THRESHOLDS[1] and 2 or 1))
        return AnnounceBadge(GLOBAL.NOMU_QA.SCHEME.INSPIRATION, pct * max, max, levels[idx])
    end

    -- 电路宣告 (WX-78)
    if HUD.controls.secondary_status
        and HUD.controls.secondary_status.upgrademodulesdisplay
        and HUD.controls.secondary_status.upgrademodulesdisplay.focus then

        local qa = GLOBAL.NOMU_QA.SCHEME.ENERGY
        local module_display = HUD.controls.secondary_status.upgrademodulesdisplay
        local current = module_display.energy_level or 0
        local energy_levels = { 'ZERO', 'ONE', 'TWO', 'THREE', 'FOUR', 'FIVE', 'SIX' }

        -- 计算占用电量
        local used_slots = 0
        if module_display.chip_slotsinuse then
            for _, v in pairs(module_display.chip_slotsinuse) do
                used_slots = used_slots + (tonumber(v) or 0)
            end
        else
            used_slots = module_display.slots_in_use or 0
        end

        local min_x = math.huge
        local max_x = -math.huge

        local function find_bounds(w)
            if not w or not w.GetWorldPosition then return end
            local px = w:GetWorldPosition().x
            if px < min_x then min_x = px end
            if px > max_x then max_x = px end
            if w.children then
                for _, child in pairs(w.children) do
                    find_bounds(child)
                end
            end
        end
        find_bounds(module_display)

        local mx = GLOBAL.TheInput:GetScreenPosition().x
        local is_circuit_area = false

        if min_x < max_x then
            local threshold = min_x + (max_x - min_x) * 0.70
            if mx < threshold then
                is_circuit_area = true
            end
        else
            if mx < module_display:GetWorldPosition().x - 20 then
                is_circuit_area = true
            end
        end

        if is_circuit_area then
            local counts = {}
            local player = GLOBAL.ThePlayer

            if player and player.wx78_classified and player.wx78_classified.upgrademodulebars then
                local GetWX78ModuleByNetID = GLOBAL.require("wx78_moduledefs").GetModuleDefinitionFromNetID
                for bartype, bars in pairs(player.wx78_classified.upgrademodulebars) do
                    for _, module_netvar in ipairs(bars) do
                        if module_netvar and type(module_netvar.value) == "function" then
                            local netid = 0
                            pcall(function() netid = module_netvar:value() end)
                            if netid > 0 then
                                local def = GetWX78ModuleByNetID(netid)
                                if def then
                                    counts[def.name] = (counts[def.name] or 0) + 1
                                end
                            end
                        end
                    end
                end
            end

            local modules_str_list = {}
            for modname, count in pairs(counts) do
                local loc_name = GLOBAL.STRINGS.NAMES['WX78MODULE_' .. string.upper(modname)] or modname
                local chip_fmt = qa.FORMATS.CHIP or "{NUM}个{ITEM}"
                table.insert(modules_str_list, subfmt(chip_fmt, { ITEM = loc_name, NUM = count }))
            end

            if #modules_str_list > 0 then
                local modules_str = table.concat(modules_str_list, "，")
                return Announce(subfmt(qa.FORMATS.ALL_MODULES, { MODULES = modules_str }))
            else
                return Announce(qa.FORMATS.NO_MODULES)
            end

        else
            return Announce(subfmt(qa.FORMATS.DEFAULT, {
                CURRENT = math.floor(current + 0.5),
                MAX = module_display.max_energy or TUNING.WX78_MAXELECTRICCHARGE or 6,
                USED = used_slots,
                MESSAGE = GetMapping(qa, 'MESSAGE', energy_levels[math.min(math.max(math.floor(current) + 1, 1), 7)])
            }))
        end
    end

    -- 烹饪/料理宣告
    if HUD.controls
        and HUD.controls.foodcrafting
        and HUD.controls.foodcrafting.focus
        and HUD.controls.foodcrafting.focusItem
        and HUD.controls.foodcrafting.focusItem.focus then

        local qa = GLOBAL.NOMU_QA.SCHEME.COOK
        local recipe = HUD.controls.foodcrafting.focusItem.recipe
        local popup = HUD.controls.foodcrafting.focusItem.recipepopup
        local name = STRINGS.NAMES[string.upper(recipe.name)] or recipe.name

        if popup and popup.focus then
            local fmts = { TYPE = GetMapping(qa, 'TYPE', 'POS'), NAME = name }
            local fmt, value

            if popup.health and popup.health.focus then
                value = recipe.health; fmt = qa.FORMATS.HEALTH
            end
            if popup.sanity and popup.sanity.focus then
                value = recipe.sanity; fmt = qa.FORMATS.SANITY
            end
            if popup.hunger and popup.hunger.focus then
                value = recipe.hunger; fmt = qa.FORMATS.HUNGER
            end

            if value then
                if type(value) == 'number' and value < 0 then
                    fmts.TYPE = GetMapping(qa, 'TYPE', 'NEG')
                    value = -value
                end
                fmts.VALUE = not recipe.unlocked and '?' or type(value) == 'number' and value ~= 0 and string.format("%g", (math.floor(value * 10 + 0.5) / 10)) or '-'
                return Announce(subfmt(fmt, fmts))
            end

            if popup.name and popup.name.focus and popup.hunger and popup.sanity and popup.health then
                return Announce(subfmt(qa.FORMATS.FOOD, {
                    NAME = name,
                    HUNGER = popup.hunger:GetString(),
                    SANITY = popup.sanity:GetString(),
                    HEALTH = popup.health:GetString()
                }))
            end

            if popup.ingredients then
                for _, ingredient in ipairs(popup.ingredients) do
                    if ingredient.focus then
                        local ing_fmt = ingredient.is_min and 'MIN_INGREDIENT' or (ingredient.quantity > 0 and 'MAX_INGREDIENT' or 'ZERO_INGREDIENT')
                        return Announce(subfmt(qa.FORMATS[ing_fmt], {
                            NAME = name,
                            INGREDIENT = ingredient.localized_name,
                            NUM = ingredient.quantity
                        }))
                    end
                end
            end
        else
            return Announce(subfmt((recipe.readytocook or recipe.reqsmatch) and recipe.unlocked and qa.FORMATS.CAN or qa.FORMATS.NEED, { NAME = name }))
        end
    end
end

-- [6] 物品配方与容器相关方法
local function GetPrototype(knows, recipe, owner)
    local prototyper, raw_tech
    if not knows then
        local details = ThePlayer.HUD.controls.craftingmenu.craftingmenu.details_root
        raw_tech = details:_GetHintTextForRecipe(owner, recipe)

        local qa_recipe = GLOBAL.NOMU_QA.SCHEME.RECIPE
        if qa_recipe
            and qa_recipe.MAPPINGS
            and qa_recipe.MAPPINGS.DEFAULT
            and qa_recipe.MAPPINGS.DEFAULT.PROTOTYPER then

            prototyper = qa_recipe.MAPPINGS.DEFAULT.PROTOTYPER[raw_tech]
        end

        prototyper = prototyper or (qa_recipe
            and qa_recipe.MAPPINGS
            and qa_recipe.MAPPINGS.DEFAULT
            and qa_recipe.MAPPINGS.DEFAULT.PROTOTYPER
            and qa_recipe.MAPPINGS.DEFAULT.PROTOTYPER["UNKNOWN_PROTOTYPE"])
    end
    return prototyper or '', raw_tech or ''
end

local function GetAllMissingIngredients(recipe, builder, inventory)
    if not recipe then return nil end
    local missing = {}

    if recipe.ingredients then
        for _, v in pairs(recipe.ingredients) do
            local actual_needed = RoundBiasedUp(v.amount * builder:IngredientMod())
            local _, num_found = inventory:Has(v.type, actual_needed)
            if num_found < actual_needed then
                local diff = actual_needed - num_found
                local item_name = STRINGS.NOMU_QA[string.upper(v.type)] or STRINGS.NAMES[string.upper(v.type)] or v.type
                table.insert(missing, diff .. "个" .. item_name)
            end
        end
    end

    if recipe.character_ingredients then
        for _, v in pairs(recipe.character_ingredients) do
            local _, num_found = builder:HasCharacterIngredient(v)
            if num_found < v.amount then
                local diff = v.amount - num_found
                local item_name = STRINGS.NOMU_QA[string.upper(v.type)] or STRINGS.NAMES[string.upper(v.type)] or v.type
                table.insert(missing, diff .. "个" .. item_name)
            end
        end
    end

    return #missing > 0 and table.concat(missing, ", ") or nil
end

local function AnnounceMergedRecipe(recipe, builder, inventory, owner, specific_ingredient_type)
    if not recipe then return end

    local buffered = builder:IsBuildBuffered(recipe.name)
    local knows = builder:KnowsRecipe(recipe.name) or CanPrototypeRecipe(recipe.level, builder:GetTechTrees())
    local can_build = builder:CanBuild(recipe.name)

    local strings_name = STRINGS.NOMU_QA[recipe.product:upper()]
                      or STRINGS.NAMES[recipe.product:upper()]
                      or STRINGS.NOMU_QA[recipe.name:upper()]
                      or STRINGS.NAMES[recipe.name:upper()]

    local name = strings_name and strings_name:lower() or STRINGS.NOMU_QA.UNKNOWN_NAME
    name = ApplyCustomName(recipe.product or recipe.name, name)

    local prototype, raw_tech = GetPrototype(knows, recipe, owner)

    local debug_str = string.format("[配方代码: %s]", tostring(recipe.name))
    if raw_tech and raw_tech ~= "" then
        debug_str = debug_str .. string.format(" [科技代码: %s]", string.lower(tostring(raw_tech)))
    end

    local qa_recipe = GLOBAL.NOMU_QA.SCHEME.RECIPE
    local qa_ing = GLOBAL.NOMU_QA.SCHEME.INGREDIENT

    if buffered then
        return Announce(subfmt(qa_recipe.FORMATS.BUFFERED, {ITEM = name, PROTOTYPE = prototype}), nil, debug_str)
    elseif can_build and knows then
        return Announce(subfmt(qa_recipe.FORMATS.WILL_MAKE, {ITEM = name, PROTOTYPE = prototype}), nil, debug_str)
    end

    if not GLOBAL.NOMU_QA.DATA.ANNOUNCE_ALL_MISSING_INGREDIENTS and specific_ingredient_type then
        local amount_needed, num_found = 1, 0

        for _, v in pairs(recipe.ingredients) do
            if specific_ingredient_type == v.type then
                amount_needed = v.amount
            end
        end

        _, num_found = inventory:Has(specific_ingredient_type, RoundBiasedUp(amount_needed * builder:IngredientMod()))

        if recipe.character_ingredients then
            for _, v in pairs(recipe.character_ingredients) do
                if specific_ingredient_type == v.type then
                    amount_needed = v.amount
                    _, num_found = builder:HasCharacterIngredient(v)
                end
            end
        end

        local num = amount_needed - num_found
        local ingredient_name = STRINGS.NOMU_QA[specific_ingredient_type:upper()]
                             or STRINGS.NAMES[specific_ingredient_type:upper()]
                             or specific_ingredient_type

        local fmts = {
            AND_PROTOTYPE = '',
            BUT_PROTOTYPE = '',
            RECIPE = name
        }

        if num > 0 then
            fmts.NUM = num
            fmts.INGREDIENT = subfmt(GetMapping(qa_ing, 'WORDS', 'ITEM_AMOUNT_FORMAT'), { NUM = num, ITEM = ingredient_name })
            if prototype ~= "" then
                fmts.AND_PROTOTYPE = subfmt(GetMapping(qa_ing, 'WORDS', 'AND_PROTOTYPE'), { PROTOTYPE = prototype })
            end
            return Announce(subfmt(qa_ing.FORMATS.NEED or qa_ing.FORMATS.NEED_MULTIPLE, fmts), nil, debug_str)
        else
            fmts.NUM = math.floor(num_found / amount_needed) * (recipe.numtogive or 1)
            fmts.INGREDIENT = ingredient_name
            if prototype ~= "" then
                fmts.BUT_PROTOTYPE = subfmt(GetMapping(qa_ing, 'WORDS', 'BUT_PROTOTYPE'), { PROTOTYPE = prototype })
            end
            return Announce(subfmt(qa_ing.FORMATS.HAVE or qa_ing.FORMATS.HAVE_ALL, fmts), nil, debug_str)
        end
    end

    if not GLOBAL.NOMU_QA.DATA.ANNOUNCE_ALL_MISSING_INGREDIENTS and not specific_ingredient_type then
        return Announce(subfmt(qa_recipe.FORMATS[knows and "WE_NEED" or "CAN_SOMEONE"], {ITEM = name, PROTOTYPE = prototype}), nil, debug_str)
    end

    local missing_str = GetAllMissingIngredients(recipe, builder, inventory)
    if missing_str then
        local and_proto = prototype ~= "" and subfmt(GetMapping(qa_ing, 'WORDS', 'AND_PROTOTYPE'), { PROTOTYPE = prototype }) or ""
        local fmt_str = (qa_ing.FORMATS.NEED_MULTIPLE or qa_ing.FORMATS.NEED):gsub("{NUM}" .. GLOBAL.STRINGS.NOMU_QA.MEASURE_WORD .. "%s*", ""):gsub("{NUM}%s*", "")

        return Announce(subfmt(fmt_str, {
            INGREDIENT = missing_str,
            RECIPE = name,
            AND_PROTOTYPE = and_proto,
            NUM = ""
        }), nil, debug_str)
    else
        local but_proto = prototype ~= "" and subfmt(GetMapping(qa_ing, 'WORDS', 'BUT_PROTOTYPE'), { PROTOTYPE = prototype }) or ""
        local all_materials = GetMapping(qa_ing, 'WORDS', 'ALL_MATERIALS')
        local fmt_str = (qa_ing.FORMATS.HAVE_ALL or qa_ing.FORMATS.HAVE):gsub("{NUM}" .. GLOBAL.STRINGS.NOMU_QA.MEASURE_WORD .. "%s*{INGREDIENT}", all_materials):gsub("{NUM}%s*{INGREDIENT}", all_materials)

        return Announce(subfmt(fmt_str, {
            RECIPE = name,
            BUT_PROTOTYPE = but_proto,
            INGREDIENT = all_materials,
            ALL_MATERIALS = all_materials,
            NUM = ""
        }), nil, debug_str)
    end
end

local ITEM_PREFAB_ALIAS = {
    deer_antler1 = "deer_antler",
    deer_antler2 = "deer_antler",
    deer_antler3 = "deer_antler"
}
local RECHARGEABLE_PREFABS = {
    pocketwatch_heal = TUNING.POCKETWATCH_HEAL_COOLDOWN,
    pocketwatch_revive = TUNING.POCKETWATCH_REVIVE_COOLDOWN,
    pocketwatch_warp = TUNING.POCKETWATCH_WARP_COOLDOWN,
    pocketwatch_recall = TUNING.POCKETWATCH_RECALL_COOLDOWN,
    pocketwatch_portal = TUNING.POCKETWATCH_RECALL_COOLDOWN
}

local function CountItems(container, name, target_prefab, use_alias)
    local num_found = 0
    if not container then return 0 end

    local function check_item(v)
        if v and v:GetDisplayName() == name then
            if (use_alias and ITEM_PREFAB_ALIAS[v.prefab] == target_prefab) or (not use_alias and v.prefab == target_prefab) then
                return v.replica.stackable and v.replica.stackable:StackSize() or 1
            end
        end
        return 0
    end

    for _, v in pairs(container:GetItems()) do
        num_found = num_found + check_item(v)
    end

    if container.GetBoatEquips then
        for _, v in pairs(container:GetBoatEquips()) do
            num_found = num_found + check_item(v)
        end
    end

    if container.GetActiveItem then
        num_found = num_found + check_item(container:GetActiveItem())
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

    if type(name) == "string" and name:find("^%s*$") and prefab and prefab:find("_container") then
        name = STRINGS.NAMES[prefab:sub(1, prefab:find("_container") - 1):upper()]
    end

    return prefab and STRINGS.NOMU_QA[prefab:upper()] or (name and name:lower())
end

local function GetEquipSlotName(qa, equipslot)
    if not equipslot then return nil end
    local key = string.upper(tostring(equipslot))
    local mapping = {
        HEAD="SLOT_HEAD",
        HANDS="SLOT_HANDS",
        BODY="SLOT_BODY",
        BACK="SLOT_BACK",
        NECK="SLOT_NECK",
        BELLY="SLOT_BELLY",
        MEDAL="SLOT_MEDAL"
    }

    for k, v in pairs(GLOBAL.EQUIPSLOTS) do
        if equipslot == v then
            key = k
            break
        end
    end

    return mapping[key] and GetMapping(qa, 'WORDS', mapping[key]) or nil
end

local function AnnounceItem(slot, classname)
    local item = slot.tile.item
    local container = (slot.container == nil or slot.container.type == "pack") and ThePlayer.replica.inventory or slot.container
    local percent, percent_type

    if slot.tile.percent then
        percent = slot.tile.percent:GetString()
        percent_type = "DURABILITY"
    elseif slot.tile.hasspoilage and item.replica.inventoryitem and item.replica.inventoryitem.classified then
        percent = math.floor(item.replica.inventoryitem.classified.perish:value() * (1 / .62)) .. "%"
        percent_type = "FRESHNESS"
    end

    local num_equipped, num_equipped_name = 0, 0
    if not container.type then
        for _, _slot in pairs(EQUIPSLOTS) do
            local eq = container:GetEquippedItem(_slot)
            if eq and eq.prefab == item.prefab then
                local s = eq.replica.stackable and eq.replica.stackable:StackSize() or 1
                num_equipped = num_equipped + s
                if eq.name == item.name then
                    num_equipped_name = num_equipped_name + s
                end
            end
        end
    end

    local container_name = get_container_name(container.type and container.inst)
    if not container_name then
        local cb = container.inst.entity:GetParent() and container.inst.entity:GetParent().components.constructionbuilder
        if cb and cb.constructionsite then
            container_name = get_container_name(cb.constructionsite)
        end
    end

    local name = item.prefab and (STRINGS.NOMU_QA[item.prefab:upper()] or STRINGS.NAMES[item.prefab:upper()]) or STRINGS.NOMU_QA.UNKNOWN_NAME
    name = ApplyCustomName(item.prefab, name)

    local num_found = container:Has(item.prefab, 1) and (
        ITEM_PREFAB_ALIAS[item.prefab] and CountItems(container, item:GetDisplayName(), ITEM_PREFAB_ALIAS[item.prefab], true)
        or CountItems(container, item:GetDisplayName(), item.prefab, false)
    ) or 0

    local num_found_name = (
        ITEM_PREFAB_ALIAS[item.prefab] and CountItems(container, item:GetDisplayName(), ITEM_PREFAB_ALIAS[item.prefab], true)
        or CountItems(container, item:GetDisplayName(), item.prefab, false)
    ) + num_equipped_name

    num_found = num_found + num_equipped
    local item_name = string.gsub(item:GetBasicDisplayName(), '\n', '')

    -- 应用通用的字符串前缀清理优化
    if name ~= STRINGS.NOMU_QA.UNKNOWN_NAME then
        name = CleanPrefixName(item:GetDisplayName(), item.prefab and STRINGS.NAMES[item.prefab:upper()], name)
    end

    if name == STRINGS.NOMU_QA.UNKNOWN_NAME and num_found == num_found_name then
        name = item:GetDisplayName():gsub('\n', '')
    end

    local qa = GLOBAL.NOMU_QA.SCHEME.ITEM

    local is_target_prefab = item.prefab and (
        item.prefab:find("certificate")
        or item.prefab:find("blueprint")
        or item.prefab:find("sketch")
        or item.prefab == "cookingrecipecard"
    )
    if is_target_prefab then
        name = item_name
    end

    local fmts = {
        PRONOUN = GetMapping(qa, 'PRONOUN', 'I'),
        NUM = num_found,
        EQUIP_NUM = num_equipped,
        ITEM = name,
        IN_CONTAINER = '',
        WITH_PERCENT = '',
        POST_STATE = '',
        SHOW_ME = '',
        ITEM_NUM = num_equipped ~= num_found and subfmt(GetMapping(qa, 'WORDS', 'ITEM_NUM'), { NUM = num_found }) or ''
    }

    local is_qa_item = item.prefab and STRINGS.NOMU_QA[item.prefab:upper()] ~= nil
    local default_name = item.prefab and (STRINGS.NOMU_QA[item.prefab:upper()] or STRINGS.NAMES[item.prefab:upper()]) or ""
    local is_custom_named = false

    if not is_qa_item then
        is_custom_named = item_name ~= ""
                         and item_name ~= "MISSING NAME"
                         and item_name ~= default_name
                         and item_name ~= name
                         and not is_target_prefab
    end

    if is_custom_named then
        fmts.ITEM_NAME = subfmt(GetMapping(qa, 'WORDS', 'ITEM_NAME'), { NUM = num_found_name, NAME = item_name })
    else
        fmts.ITEM_NAME = ''
    end

    if container_name then
        fmts.PRONOUN = GetMapping(qa, 'PRONOUN', 'WE')
        fmts.IN_CONTAINER = subfmt(GetMapping(qa, 'WORDS', 'IN_CONTAINER'), { NAME = container_name })
    end

    if percent then
        fmts.WITH_PERCENT = subfmt(GetMapping(qa, 'WORDS', 'WITH_PERCENT'), {
            THIS_ONE = num_found > 1 and GetMapping(qa, 'WORDS', 'THIS_ONE') or '',
            PERCENT = percent,
            TYPE = GetMapping(qa, 'PERCENT_TYPE', percent_type)
        })
    end

    if item.prefab == 'heatrock' and item.replica and item.replica.inventoryitem and item.replica.inventoryitem.GetImage then
        local range = {
            [4264163310]=1, [3706253814]=1, [2098310090]=1,
            [1108760303]=2, [550850807]=2, [3237874379]=2,
            [2248324592]=3, [1690415096]=3, [82471372]=3,
            [3387888881]=4, [2829979385]=4, [1222035661]=4,
            [232485874]=5, [3969543674]=5, [2361599950]=5
        }
        local img = item.replica.inventoryitem:GetImage()
        if range[img] then
            local heat_states = { 'COLD', 'COOL', 'NORMAL', 'WARM', 'HOT' }
            fmts.POST_STATE = GetMapping(qa, 'HEAT_ROCK', heat_states[range[img]])
        end
    end

    if RECHARGEABLE_PREFABS[item.prefab] and item.replica.inventoryitem.classified then
        local seconds = (180 - item.replica.inventoryitem.classified.recharge:value()) / 180 * RECHARGEABLE_PREFABS[item.prefab]
        if seconds == 0 then
            fmts.POST_STATE = GetMapping(qa, 'RECHARGE', 'FULL')
        else
            fmts.POST_STATE = subfmt(GetMapping(qa, 'RECHARGE', 'CHARGING'), {
                TIME = (math.modf(seconds / 60) > 0 and math.modf(seconds / 60) .. GetMapping(qa, 'TIME', 'MINUTES') or '')
                    .. math.modf(math.fmod(seconds, 60)) .. GetMapping(qa, 'TIME', 'SECONDS')
            })
        end
    end

    local start_line = #(string.split(item:GetDisplayName(), '\n')) + (classname == 'invslot' and 3 or 2)
    local show_me_str = GetShowMeString(item, qa, start_line, -1)
    if show_me_str ~= "" then
        fmts.SHOW_ME = show_me_str
    end

    local result_str
    if classname == 'invslot' then
        result_str = subfmt(qa.FORMATS.INV_SLOT, fmts)
    else
        local slot_pos_name = GetEquipSlotName(qa, slot.equipslot)
        if slot_pos_name then
            fmts.SLOT_POS = slot_pos_name
            fmts.v = slot_pos_name
            result_str = subfmt(qa.FORMATS.EQUIP_SLOT_POS, fmts)
        else
            result_str = subfmt(qa.FORMATS.EQUIP_SLOT, fmts)
        end
    end

    local debug_txt = GLOBAL.NOMU_QA.DATA.DEBUG_MODE and string.format(
        "[物品代码: %s, 容器代码: %s, 槽位代码: %s]",
        tostring(item.prefab),
        container and (container.inst and container.inst.prefab or container.type or "inventory") or "无",
        classname == 'equipslot' and tostring(slot.equipslot) or "inv_" .. tostring(slot.num)
    ) or ""

    return Announce(result_str, nil, debug_txt)
end

local function AnnounceConstructionSite(site, container_widget, slot_index)
    local site_rep = site.replica.constructionsite
    if not site_rep then return false end

    local plans = site_rep:GetIngredients()
               or GLOBAL.CONSTRUCTION_PLANS[site.prefab]
               or (site.nameoverride and GLOBAL.CONSTRUCTION_PLANS[site.nameoverride])
    if not plans then return false end

    local container_rep = container_widget and container_widget.inst and container_widget.inst.replica.container
    local site_name = (site:GetDisplayName()
                    or GLOBAL.STRINGS.NOMU_QA[site.prefab:upper()]
                    or GLOBAL.STRINGS.NAMES[site.prefab:upper()]
                    or site.prefab):gsub('\n', ' ')

    site_name = ApplyCustomName(site.prefab, site_name)

    local qa_const = (site:HasTag("offerconstructionsite")
                   or (container_widget and container_widget.inst and container_widget.inst:HasTag("offerconstructionsite")))
                   and GLOBAL.NOMU_QA.SCHEME.TRADE
                   or GLOBAL.NOMU_QA.SCHEME.CONSTRUCTION

    local debug_str = GLOBAL.NOMU_QA.DATA.DEBUG_MODE and string.format(
        "[施工点代码: %s, 容器代码: %s]",
        tostring(site.prefab),
        tostring(container_widget and container_widget.inst and container_widget.inst.prefab or "无")
    ) or nil

    if not GLOBAL.NOMU_QA.DATA.ANNOUNCE_ALL_MISSING_INGREDIENTS and slot_index and plans[slot_index] then
        local plan = plans[slot_index]
        local current = (site_rep:GetSlotCount(slot_index) or 0)
                      + (container_rep and container_rep:GetItemInSlot(slot_index)
                      and (container_rep:GetItemInSlot(slot_index).replica.stackable
                      and container_rep:GetItemInSlot(slot_index).replica.stackable:StackSize() or 1) or 0)
        local missing = plan.amount - current
        local ing_name = GLOBAL.STRINGS.NOMU_QA[plan.type:upper()] or GLOBAL.STRINGS.NAMES[plan.type:upper()] or plan.type
        local amount_fmt = GetMapping(qa_const, 'WORDS', 'AMOUNT_FMT') or "{NUM} {ITEM}"

        if missing > 0 then
            return Announce(subfmt(qa_const.FORMATS.NEED, {
                INGREDIENT = subfmt(amount_fmt, { NUM = missing, ITEM = ing_name }),
                RECIPE = site_name
            }), nil, debug_str)
        else
            local fmt_have = qa_const.FORMATS.HAVE_ITEM or qa_const.FORMATS.HAVE
            return Announce(subfmt(fmt_have, {
                RECIPE = site_name,
                INGREDIENT = subfmt(amount_fmt, { NUM = plan.amount, ITEM = ing_name })
            }), nil, debug_str)
        end
    end

    local missing, total_req = {}, {}
    for i, plan in ipairs(plans) do
        local current = (site_rep:GetSlotCount(i) or 0)
                      + (container_rep and container_rep:GetItemInSlot(i)
                      and (container_rep:GetItemInSlot(i).replica.stackable
                      and container_rep:GetItemInSlot(i).replica.stackable:StackSize() or 1) or 0)
        local name = GLOBAL.STRINGS.NOMU_QA[plan.type:upper()] or GLOBAL.STRINGS.NAMES[plan.type:upper()] or plan.type

        table.insert(total_req, plan.amount .. "个" .. name)
        if plan.amount - current > 0 then
            table.insert(missing, (plan.amount - current) .. "个" .. name)
        end
    end

    if #missing > 0 then
        return Announce(subfmt(qa_const.FORMATS.NEED, {
            INGREDIENT = table.concat(missing, ", "),
            RECIPE = site_name
        }), nil, debug_str)
    else
        return Announce(subfmt(qa_const.FORMATS.HAVE, {
            RECIPE = site_name,
            INGREDIENT = table.concat(total_req, ", ")
        }), nil, debug_str)
    end
end

local function AnnounceSkin(recipepopup)
    if not recipepopup.focus then return end

    local skin_name = recipepopup.skins_spinner and recipepopup.skins_spinner.GetItem()
                   or (recipepopup.GetItem and recipepopup:GetItem())
    local item_name = STRINGS.NAMES[string.upper(recipepopup.recipe.product)] or recipepopup.recipe.name

    if skin_name == nil then
        if #recipepopup.skins_options == 1 then
            local prefab = recipepopup.recipe.product or recipepopup.recipe.name
            return Announce(subfmt(
                GLOBAL.NOMU_QA.SCHEME.SKIN.FORMATS[(not PREFAB_SKINS[prefab] or #PREFAB_SKINS[prefab] == 0) and "NO_SKIN" or "HAS_NO_SKIN"],
                { ITEM = item_name }
            ))
        end
        return
    end

    if skin_name ~= item_name then
        local prefab = recipepopup.recipe.product or recipepopup.recipe.name
        local num = #recipepopup.skins_options - 1
        return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.SKIN.FORMATS.DEFAULT, {
            SKIN = GetSkinName(skin_name),
            ITEM = item_name,
            NUM = num,
            TOTAL = PREFAB_SKINS[prefab] and #PREFAB_SKINS[prefab] or num
        }))
    end
end

local function AnnounceRecipePinSlot(slot, recipepopup, ingnum)
    local recipe_state = slot.craftingmenu:GetRecipeState(slot.recipe_name)
    if not recipe_state or not recipe_state.recipe then return end

    local specific_ingredient_type = nil

    recipepopup = recipepopup or slot.recipe_popup
    if recipepopup then
        local ing = recipepopup.ing or {}
        if #ing == 0 and recipepopup.ingredients and recipepopup.ingredients.children then
            local root = next(recipepopup.ingredients.children) and recipepopup.ingredients.children[next(recipepopup.ingredients.children)]
            if root then
                for _, v in pairs(root.children) do
                    table.insert(ing, v)
                end
            end
        end

        local ingredient = ingnum and ing[ingnum] or nil
        if not ingredient then
            for _, _ing in ipairs(ing) do
                if _ing.focus then ingredient = _ing end
            end
        end

        if ingredient and ingredient.ing and ingredient.ing.texture then
            specific_ingredient_type = ingredient.ing.texture:sub(1, -5)
        elseif ingredient and not ingredient.ing and recipepopup.recipe and recipepopup.recipe.ingredients and recipepopup.recipe.ingredients[1] then
            specific_ingredient_type = recipepopup.recipe.ingredients[1].type
        end
    end

    return AnnounceMergedRecipe(
        recipe_state.recipe,
        slot.owner.replica.builder,
        slot.owner.replica.inventory,
        slot.owner,
        specific_ingredient_type
    )
end

local function AnnounceRecipeGrid(grid, owner)
    local idx = grid.focused_widget_index + grid.displayed_start_index
    if grid.focus and #grid.items > 0 and grid.items[idx] then
        return AnnounceMergedRecipe(
            grid.items[idx].recipe,
            owner.replica.builder,
            owner.replica.inventory,
            owner,
            nil
        )
    end
end

local function AnnounceRecipeCMIngredients(ingredients)
    local recipe = ingredients.recipe
    if not recipe then return end

    local specific_ingredient_type = nil
    local root = ingredients.children and next(ingredients.children) and ingredients.children[next(ingredients.children)]

    if root and root.children then
        for _, _ing in pairs(root.children) do
            if _ing.focus and _ing.ing and _ing.ing.texture then
                specific_ingredient_type = _ing.ing.texture:sub(1, -5)
            end
        end
    end

    return AnnounceMergedRecipe(
        recipe,
        ingredients.owner.replica.builder,
        ingredients.owner.replica.inventory,
        ingredients.owner,
        specific_ingredient_type
    )
end

-- [7] 环境实体探测逻辑
local PREFAB_MOD_CACHE, BUILD_CACHE = {}, {}

local function GetModNameForPrefab(prefab)
    if PREFAB_MOD_CACHE[prefab] ~= nil then
        return PREFAB_MOD_CACHE[prefab]
    end

    for _, modname in ipairs(GLOBAL.KnownModIndex:GetModNames()) do
        local pre = GLOBAL.Prefabs["MOD_" .. modname]
        if pre ~= nil and table.contains(pre.deps, prefab) then
            PREFAB_MOD_CACHE[prefab] = GLOBAL.KnownModIndex:GetModFancyName(modname)
            return PREFAB_MOD_CACHE[prefab]
        end
    end

    PREFAB_MOD_CACHE[prefab] = false
    return false
end

local function GetBuildCached(inst)
    if not inst or not inst.entity or not inst.prefab then return nil, nil end
    if BUILD_CACHE[inst.prefab] then return BUILD_CACHE[inst.prefab].bank, BUILD_CACHE[inst.prefab].build end

    local str = inst.entity:GetDebugString()
    if not str then return nil, nil end

    local bank, build = str:match("bank: (.+) build: (.+) anim: ")
    if bank and build then
        BUILD_CACHE[inst.prefab] = { bank = bank, build = build }
        return bank, build
    end
    return nil, nil
end

local function GetCleanEntityName(entity, base_prefab_name)
    return CleanPrefixName(entity:GetDisplayName(), entity.prefab and STRINGS.NAMES[entity.prefab:upper()], base_prefab_name)
end

TheInput:AddMouseButtonHandler(function(button, down)
    if not (IsDefaultScreen() and TheInput:IsControlPressed(CONTROL_FORCE_INSPECT) and TheInput:IsKeyDown(KEY_LSHIFT) and down) then
        return
    end

    local entity = ConsoleWorldEntityUnderMouse()
    local qa = GLOBAL.NOMU_QA.SCHEME.ENV
    --鼠标中键
    if button == MOUSEBUTTON_MIDDLE then
        if entity then
            if not TheInput:IsKeyDown(KEY_LCTRL) and entity:HasTag('player') then
                if entity == ThePlayer then
                    return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.PING, { PING = TheNet:GetAveragePing() }))
                else
                    return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.GREET, { NAME = entity:GetDisplayName() }))
                end
            end

            local mod_str = ""
            local mod_name = GetModNameForPrefab(entity.prefab)
            if mod_name then
                mod_str = subfmt(GetMapping(qa, 'WORDS', 'MOD_INFO'), { MOD_NAME = mod_name })
            end

            local entity_info = subfmt(qa.FORMATS.CODE, { 
                PREFAB = entity.prefab, 
                NAME = entity:GetDisplayName(),
                MOD_INFO = mod_str,
                ASSET_INFO = "" 
            })
            
            print(entity_info)
            ThePlayer.components.talker:Say(entity_info, 5)
        end
        return
    end

    -- 鼠标左键
    if button ~= MOUSEBUTTON_LEFT then return end

    if not entity then
        local pos = TheInput:GetWorldPosition()
        local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, GLOBAL.NOMU_QA.DATA.FUZZY_ANNOUNCE and 4 or 2, nil, { "INLIMBO", "player" })
        local fuzzy_entity = nil

        for _, v in ipairs(ents) do
            if v.prefab == "oasislake"
                or v.prefab == "icefishing_hole"
                or v.prefab == "oceanwhirlbigportal"
                or v.prefab == "willow_ember"
                or (v.prefab and string.find(v.prefab, "sinkhole"))
                or v:HasTag("underwater_salvageable")
                or (v:HasTag("oceanfishable") and v:HasTag("oceanfishinghookable")) then
                entity = v
                break
            end

            if GLOBAL.NOMU_QA.DATA.FUZZY_ANNOUNCE
                and not fuzzy_entity
                and v.prefab
                and v.name
                and not v:HasTag("NOCLICK")
                and not v:HasTag("FX")
                and not v:HasTag("DECOR") then
                fuzzy_entity = v
            end
        end
        if not entity and fuzzy_entity then
            entity = fuzzy_entity
        end
    end

    if not entity then return end
    if not TheInput:IsKeyDown(KEY_LCTRL) and entity:HasTag('player') then
    -- 判断玩家是否正在钓鱼
        local is_fishing = false
        local inventory = entity.replica.inventory
        if inventory then
            local equip = inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS)
            if equip then
                if equip.replica.fishingrod and equip.replica.fishingrod:GetTarget() ~= nil then
                    is_fishing = true
                elseif equip.replica.oceanfishingrod then
                    if type(equip.replica.oceanfishingrod.GetBobber) == "function" and equip.replica.oceanfishingrod:GetBobber() ~= nil then
                        is_fishing = true
                    elseif type(equip.replica.oceanfishingrod.GetTarget) == "function" and equip.replica.oceanfishingrod:GetTarget() ~= nil then
                        is_fishing = true
                    end
                end
            end
        end
        -- 宣告自己
        if entity == ThePlayer then
            if is_fishing and GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.ME_FISHING then
                return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.ME_FISHING, { NAME = entity:GetDisplayName() }))
            end
            return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.I_AM_HERE, { NAME = entity:GetDisplayName() }))
        end
        -- 宣告给物品
        local my_inventory = ThePlayer.replica.inventory
        local active_item = my_inventory and my_inventory:GetActiveItem()
        if active_item then
            return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.GIVE_ITEM, {
                NAME = entity:GetDisplayName(),
                NUM = active_item.replica.stackable and active_item.replica.stackable:StackSize() or 1,
                ITEM_NAME = string.gsub(active_item:GetDisplayName(), '\n', ' ')
            }))
        end
        -- 宣告鬼魂状态
        local is_me = ThePlayer:HasTag("playerghost")
        local is_ent = entity:HasTag("playerghost")
        if is_me or is_ent then
            local player_fmt = GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.DEFAULT
            if is_me and is_ent then
                player_fmt = GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.BOTH_GHOST
            elseif is_me then
                player_fmt = GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.ME_GHOST
            elseif is_ent then
                player_fmt = GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.THEY_GHOST
            end
            return Announce(subfmt(player_fmt, { NAME = entity:GetDisplayName() }))
        end
        --宣告他人正在钓鱼
        if is_fishing and GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.THEY_FISHING then
            return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.THEY_FISHING, { NAME = entity:GetDisplayName() }))
        end
        -- 普通的打招呼
        return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.GREET, { NAME = entity:GetDisplayName() }))
    end

    local px, py, pz = entity:GetPosition():Get()

    local is_on_water = TheWorld.Map and TheWorld.Map:IsOceanAtPoint(px, py, pz) and (entity.GetCurrentPlatform == nil or entity:GetCurrentPlatform() == nil)

    local radius = type(GLOBAL.NOMU_QA.DATA.ANNOUNCE_RANGE) == "number" and GLOBAL.NOMU_QA.DATA.ANNOUNCE_RANGE or 40
    local entities = TheSim:FindEntities(px, py, pz, radius)

    local count_name, count_prefab, count_burnt, count_fire, count_withered = 0, 0, 0, 0, 0
    local count_barren, count_smolder, count_charged_goat, count_normal_goat = 0, 0, 0, 0

    local dist_sq = ThePlayer:GetDistanceSqToInst(entity)
    local dist_str = ""

    local show_dist = GLOBAL.NOMU_QA.DATA.SHOW_DISTANCE

    if show_dist > 0 then
        local raw_dist = math.sqrt(dist_sq) / 4
        if raw_dist >= 1 then
            local dist_val = (show_dist == 2) and string.format("%.1f", raw_dist) or math.floor(raw_dist)

            local word_key = is_on_water and 'DISTANCE_FAR_WATER' or 'DISTANCE_FAR'
            local template = GetMapping(qa, 'WORDS', word_key) or GetMapping(qa, 'WORDS', 'DISTANCE_FAR')

            dist_str = subfmt(template, { DIST = dist_val })
        else
            local word_key = is_on_water and 'DISTANCE_CLOSE_WATER' or 'DISTANCE_CLOSE'
            dist_str = GetMapping(qa, 'WORDS', word_key) or GetMapping(qa, 'WORDS', 'DISTANCE_CLOSE')
        end
    end

    local target_burnt = entity:HasTag("burnt")
    local target_fire = entity:HasTag("fire")
    local target_withered = entity:HasTag("withered")
    local target_barren = entity:HasTag("barren")
    local target_smolder = entity:HasTag("smolder")
    local is_lightninggoat = entity.prefab == "lightninggoat"
    local target_is_charged_goat = is_lightninggoat and entity:HasTag("charged")

    local target_is_crop = entity:HasTag("farm_plant")
                        or entity:HasTag("beebox")
                        or SPECIAL_CROPS[entity.prefab]
                        or BASIC_PICKABLES[entity.prefab]

    local target_crop_stat = nil
    if target_is_crop then
        if entity:HasTag("farm_plant") then target_crop_stat = GetCropStat(entity.AnimState)
        elseif entity.prefab == "waterplant" then target_crop_stat = entity:HasTag("harvestable") and "WITH_BARNACLES" or "NO_BARNACLES"
        elseif entity.prefab == "saltstack" then target_crop_stat = GetSaltStackStat(entity.AnimState)
        elseif entity.prefab == "marbleshrub" then target_crop_stat = GetMarbleShrubStat(entity.AnimState)
        elseif entity:HasTag("beebox") then target_crop_stat = GetBeeboxStat(entity.AnimState)
        elseif entity.prefab == "mushroom_farm" then target_crop_stat = GetMushroomFarmStat(entity.AnimState)
        elseif entity.prefab == "tallbirdnest" then target_crop_stat = entity:HasTag("pickable") and "NEST_HAS_EGG" or "NEST_EMPTY"
        elseif entity.prefab == "lureplant" then target_crop_stat = GetLureplantStat(entity.AnimState)
        elseif BASIC_PICKABLES[entity.prefab] then target_crop_stat = entity:HasTag("pickable") and "PICKABLE_READY" or "PICKABLE_EMPTY"
        end
    end

    local target_is_tree = entity:HasTag("tree")
                        or entity:HasTag("rock_tree")
                        or (entity.prefab and (string.find(entity.prefab, "sapling")
                            or entity.prefab == "marbleshrub"
                            or string.find(entity.prefab, "marbletree"))
                            and not entity:HasTag("player"))
    local target_tree_stat = target_is_tree and GetTreeStat(entity) or nil

    local target_is_spiderden = (entity:HasTag("spiderden")
                              and entity.prefab ~= "moonspiderden"
                              and entity.prefab ~= "spiderhole")
                              or entity:HasTag("shadowchesspiece")
    local target_spiderden_stat = target_is_spiderden and GetSpiderDenStat(entity) or nil

    local target_is_hotspring = entity.prefab == "hotspring"
    local target_hotspring_stat = target_is_hotspring and GetHotspringStat(entity) or nil

    local is_fruitdragon = entity.prefab == "fruitdragon"
    local target_is_ripe_fruitdragon = is_fruitdragon and (
        (entity.AnimState and entity.AnimState:GetBuild() == "fruit_dragon_ripe_build")
        or string.find(entity:GetDisplayName() or "", "Ripe")
    )

    local is_archive_switch = entity.prefab == "archive_switch"
    local target_is_full_archive_switch = is_archive_switch and entity.AnimState and (
        entity.AnimState:IsCurrentAnimation("idle_full")
        or entity.AnimState:IsCurrentAnimation("activate")
    )

    local count_crop_stat = 0
    local count_tree_stat = 0
    local count_spiderden_stat = 0
    local count_hotspring_stat = 0
    local count_ripe_fruitdragon = 0
    local count_unripe_fruitdragon = 0
    local count_archive_switch_full = 0
    local count_archive_switch_empty = 0

    local target_name = ""
    pcall(function() target_name = entity:GetDisplayName() end)

    local is_shadow_centipede_piece = entity:HasTag("shadowthrall_centipede")
    local is_worm_boss_piece = entity:HasTag("worm_boss_piece")
    local centipede_has_piece = false
    local centipede_head_count = 0

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
        elseif ((ITEM_PREFAB_ALIAS[entity.prefab] and ITEM_PREFAB_ALIAS[entity.prefab] == ITEM_PREFAB_ALIAS[v.prefab])
             or v.prefab == entity.prefab) then
            is_same_entity = true
        end

        if v.entity:IsVisible() and is_same_entity then
            local v_name = ""
            pcall(function() v_name = v:GetDisplayName() end)

            local s = v.replica and v.replica.stackable and v.replica.stackable:StackSize() or 1
            count_prefab = count_prefab + s

            if v_name == target_name then count_name = count_name + s end
            if target_burnt and v:HasTag("burnt") then count_burnt = count_burnt + 1 end
            if target_fire and v:HasTag("fire") then count_fire = count_fire + 1 end
            if target_withered and v:HasTag("withered") then count_withered = count_withered + 1 end
            if target_barren and v:HasTag("barren") then count_barren = count_barren + 1 end
            if target_smolder and v:HasTag("smolder") then count_smolder = count_smolder + 1 end

            if is_lightninggoat and v.prefab == "lightninggoat" then
                if v:HasTag("charged") then
                    count_charged_goat = count_charged_goat + 1
                else
                    count_normal_goat = count_normal_goat + 1
                end
            end

            if target_is_crop and target_crop_stat then
                local v_crop_stat = nil
                if v:HasTag("farm_plant") then v_crop_stat = GetCropStat(v.AnimState)
                elseif v.prefab == "waterplant" then v_crop_stat = v:HasTag("harvestable") and "WITH_BARNACLES" or "NO_BARNACLES"
                elseif v.prefab == "saltstack" then v_crop_stat = GetSaltStackStat(v.AnimState)
                elseif v.prefab == "marbleshrub" then v_crop_stat = GetMarbleShrubStat(v.AnimState)
                elseif v:HasTag("beebox") then v_crop_stat = GetBeeboxStat(v.AnimState)
                elseif v.prefab == "mushroom_farm" then v_crop_stat = GetMushroomFarmStat(v.AnimState)
                elseif v.prefab == "tallbirdnest" then v_crop_stat = v:HasTag("pickable") and "NEST_HAS_EGG" or "NEST_EMPTY"
                elseif v.prefab == "lureplant" then v_crop_stat = GetLureplantStat(v.AnimState)
                elseif BASIC_PICKABLES[v.prefab] then v_crop_stat = v:HasTag("pickable") and "PICKABLE_READY" or "PICKABLE_EMPTY"
                end

                if target_crop_stat == v_crop_stat then
                    count_crop_stat = count_crop_stat + 1
                end
            end

            if target_is_tree and target_tree_stat and target_tree_stat == GetTreeStat(v) then
                count_tree_stat = count_tree_stat + 1
            end

            if target_is_spiderden and target_spiderden_stat and target_spiderden_stat == GetSpiderDenStat(v) then
                count_spiderden_stat = count_spiderden_stat + 1
            end

            if target_is_hotspring and target_hotspring_stat and v.prefab == "hotspring" then
                if target_hotspring_stat == GetHotspringStat(v) then
                    count_hotspring_stat = count_hotspring_stat + 1
                end
            end

            if is_fruitdragon and v.prefab == "fruitdragon" then
                if (v.AnimState and v.AnimState:GetBuild() == "fruit_dragon_ripe_build")
                    or string.find(v:GetDisplayName() or "", "Ripe") then
                    count_ripe_fruitdragon = count_ripe_fruitdragon + 1
                else
                    count_unripe_fruitdragon = count_unripe_fruitdragon + 1
                end
            end

            if is_archive_switch and v.prefab == "archive_switch" then
                if v.AnimState and (v.AnimState:IsCurrentAnimation("idle_full") or v.AnimState:IsCurrentAnimation("activate")) then
                    count_archive_switch_full = count_archive_switch_full + 1
                else
                    count_archive_switch_empty = count_archive_switch_empty + 1
                end
            end
        end
    end

    if is_worm_boss_piece then
        local boss_count = 0
        for _, v in pairs(GLOBAL.Ents) do
            if v.prefab == "worm_boss" then
                if v:GetDistanceSqToInst(entity) <= 10000 then
                    boss_count = boss_count + 1
                end
            end
        end
        if boss_count == 0 then boss_count = 1 end
        count_prefab = boss_count
        count_name = boss_count
    elseif is_shadow_centipede_piece then
        local boss_count = math.ceil(centipede_head_count / 2)
        if boss_count == 0 and centipede_has_piece then boss_count = 1 end
        count_prefab = boss_count
        count_name = boss_count
    end

    local prefab_name = entity.prefab and (STRINGS.NOMU_QA[entity.prefab:upper()] or STRINGS.NAMES[entity.prefab:upper()])
    prefab_name = ApplyCustomName(entity.prefab, prefab_name)

    local display_name = ""
    pcall(function()
        display_name = string.gsub(GLOBAL.NOMU_QA.DATA.SHOW_PREFIX and entity:GetDisplayName() or entity:GetBasicDisplayName(), '\n', ' ')
    end)

    if display_name == "" then
        display_name = prefab_name or "MISSING NAME"
    end

    if entity.prefab and string.find(entity.prefab, "sinkhole") then
        prefab_name = GLOBAL.STRINGS.NOMU_QA[entity.prefab:upper()]
                   or (display_name ~= entity.prefab and not string.find(display_name, "MISSING") and display_name or GLOBAL.STRINGS.NOMU_QA.SINKHOLE)
    end

    local debug_str = string.format("[实体代码: %s]", tostring(entity.prefab))

    local start_line = #(string.split(entity:GetDisplayName(), '\n')) + 1
    local show_me = GetShowMeString(entity, qa, start_line, nil, nil, 2)

    local final_name = GetCleanEntityName(entity, prefab_name)
    local is_blueprint_type = false
    if entity.prefab and (
        string.find(entity.prefab, "certificate")
        or string.find(entity.prefab, "blueprint")
        or string.find(entity.prefab, "sketch")
        or entity.prefab == "cookingrecipecard"
    ) and display_name ~= prefab_name then
        final_name = display_name
        is_blueprint_type = true
    end

    -- 针对不同特殊实体的不同宣告
    if entity.prefab == "icefishing_hole" then
        return Announce(subfmt(qa.FORMATS.FISH_HOLE or qa.FORMATS.SINGLE, {
            NAME = GLOBAL.STRINGS.NOMU_QA.ICEFISHING_HOLE,
            SHOW_ME = show_me,
            DISTANCE = dist_str
        }), entity:HasTag('player'), debug_str)
    end

    if entity.prefab == "townportal" then
        return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PORTAL.FORMATS[entity.AnimState and entity.AnimState:IsCurrentAnimation("idle_on_loop") and "ON" or "OFF"], {
            NAME = display_name
        }), entity:HasTag('player'), debug_str)
    end

    if entity:HasTag("oceanfishable") and entity:HasTag("oceanfishinghookable") and not string.find(entity.prefab or "", "flotsam") then
        local adj = GLOBAL.STRINGS.UI.CUSTOMIZATIONSCREEN.OCEAN_SHOAL or GLOBAL.STRINGS.NOMU_QA.OCEAN_SHOAL
        local shoal_name, fish_name = adj, "鱼"

        if entity.name and type(entity.name) == "string" and entity.name ~= "" and entity.name ~= adj then
            fish_name = GLOBAL.STRINGS.NOMU_QA[string.upper(entity.name)] or GLOBAL.STRINGS.NAMES[string.upper(entity.name)] or entity.name
            shoal_name = GLOBAL.STRINGS.UI.OBJECTOWNERSHIP and subfmt(GLOBAL.STRINGS.UI.OBJECTOWNERSHIP, {owner = fish_name, object = adj}) or shoal_name
        end

        local f_c = 0
        for _, v in ipairs(entities) do
            if (v:HasTag("oceanfish") or v:HasTag("oceanfishable")) and v.prefab == entity.prefab then
                f_c = f_c + 1
            end
        end
        return Announce(subfmt(qa.FORMATS.FISH_SHOAL, {
            NAME = shoal_name,
            NUM = f_c,
            FISH = fish_name,
            SHOW_ME = show_me,
            DISTANCE = dist_str
        }), entity:HasTag('player'), debug_str)
    end

    local use_special = GLOBAL.NOMU_QA.DATA.ENABLE_SPECIAL_STATE

    -- 鸟笼特殊宣告判定
    if use_special and entity.prefab == "birdcage" then
        local anim = entity.AnimState
        local state_fmt = qa.FORMATS.BIRDCAGE_FULL

        if anim then
            if anim:IsCurrentAnimation("idle_empty") then
                state_fmt = qa.FORMATS.BIRDCAGE_EMPTY
            elseif CheckAnims(anim, {"idle_sick", "idle_sick2", "idle_sick3", "fall_sick"}) then
                state_fmt = qa.FORMATS.BIRDCAGE_SICK
            elseif CheckAnims(anim, {"death", "idle_death", "idle_skeleton"}) then
                state_fmt = qa.FORMATS.BIRDCAGE_DEAD
            end
        end

        return Announce(subfmt(state_fmt or qa.FORMATS.SINGLE, {
            TOTAL = count_prefab,
            NAME = final_name or display_name,
            SHOW_ME = show_me,
            DISTANCE = dist_str
        }), entity:HasTag('player'), debug_str)
    end

    -- 绿洲湖泊特殊宣告
    if use_special and entity.prefab == "oasislake" then
        local state_fmt = entity:HasTag("NOCLICK") and qa.FORMATS.OASISLAKE_EMPTY or qa.FORMATS.OASISLAKE_FULL
        return Announce(subfmt(state_fmt, {
            NAME = final_name or display_name,
            SHOW_ME = show_me,
            DISTANCE = dist_str
        }), entity:HasTag('player'), debug_str)
    end

    -- 蟾蜍洞特殊宣告
    if use_special and entity.prefab == "toadstool_cap" then
        local state_fmt = qa.FORMATS.TOADSTOOL_EMPTY
        if entity._state and entity._state:value() > 0 then
            if entity._dark and entity._dark:value() then
                state_fmt = qa.FORMATS.TOADSTOOL_DARK
            else
                state_fmt = qa.FORMATS.TOADSTOOL_NORMAL
            end
        end

        return Announce(subfmt(state_fmt or qa.FORMATS.SINGLE, {
            NAME = final_name or display_name,
            SHOW_ME = show_me,
            DISTANCE = dist_str
        }), entity:HasTag('player'), debug_str)
    end

    if use_special and entity:HasTag("fire") and not entity:HasTag("campfire") and not entity:HasTag("tree") then
        local is_equal = (count_fire == count_prefab)
        return Announce(subfmt(is_equal and qa.FORMATS.FIRE_EQUAL or qa.FORMATS.FIRE_DESCRIBE, {
            TOTAL = count_prefab,
            NUM = count_fire,
            NAME = (entity.prefab == "houndfire" and prefab_name) or display_name or GLOBAL.STRINGS.NOMU_QA.HOUNDFIRE,
            SHOW_ME = show_me,
            DISTANCE = dist_str
        }), entity:HasTag('player'), debug_str)
    end

    if use_special and count_burnt > 0 then
        local is_equal = (count_burnt == count_prefab)
        return Announce(subfmt(is_equal and qa.FORMATS.BURNT_EQUAL or qa.FORMATS.BURNT_DESCRIBE, {
            TOTAL = count_prefab,
            NUM = count_burnt,
            NAME = final_name or display_name,
            SHOW_ME = show_me,
            DISTANCE = dist_str
        }), entity:HasTag('player'), debug_str)
    end

    if use_special and target_smolder then
        local is_equal = (count_smolder == count_prefab)
        return Announce(subfmt(is_equal and qa.FORMATS.SMOLDER_EQUAL or qa.FORMATS.SMOLDER_DESCRIBE, {
            TOTAL = count_prefab,
            NUM = count_smolder,
            NAME = final_name or display_name,
            SHOW_ME = show_me,
            DISTANCE = dist_str
        }), entity:HasTag('player'), debug_str)
    end

    if use_special and is_lightninggoat and target_is_charged_goat then
        local is_equal = (count_charged_goat == count_prefab)
        local fmt = is_equal and qa.FORMATS.GOAT_CHARGED_EQUAL or qa.FORMATS.GOAT_CHARGED_DESCRIBE
        return Announce(subfmt(fmt, {
            TOTAL = count_prefab,
            NUM = count_charged_goat,
            NAME = final_name or display_name,
            SHOW_ME = show_me,
            DISTANCE = dist_str
        }), entity:HasTag('player'), debug_str)
    end

    if use_special and entity:HasTag("withered") then
        local is_equal = (count_withered == count_prefab)
        return Announce(subfmt(is_equal and qa.FORMATS.WITHERED_EQUAL or qa.FORMATS.WITHERED_DESCRIBE, {
            TOTAL = count_prefab,
            NUM = count_withered,
            NAME = prefab_name,
            SHOW_ME = show_me,
            DISTANCE = dist_str
        }), entity:HasTag('player'), debug_str)
    end

    if use_special and target_barren then
        local is_equal = (count_barren == count_prefab)
        return Announce(subfmt(is_equal and qa.FORMATS.BARREN_EQUAL or qa.FORMATS.BARREN_DESCRIBE, {
            TOTAL = count_prefab,
            NUM = count_barren,
            NAME = prefab_name,
            SHOW_ME = show_me,
            DISTANCE = dist_str
        }), entity:HasTag('player'), debug_str)
    end

    if use_special and target_is_crop and target_crop_stat then
        return Announce(subfmt(count_crop_stat == count_prefab and GLOBAL.NOMU_QA.SCHEME.CROP.FORMATS.EQUAL or GLOBAL.NOMU_QA.SCHEME.CROP.FORMATS.DESCRIBE, {
            COUNT = count_prefab,
            NUM = count_crop_stat,
            NAME = final_name or display_name,
            ADJ = GetMapping(GLOBAL.NOMU_QA.SCHEME.CROP, 'ADJ', target_crop_stat),
            SHOW_ME = dist_str .. show_me
        }), entity:HasTag('player'), debug_str)
    end

    if use_special and target_is_tree and target_tree_stat then
        return Announce(subfmt(count_tree_stat == count_prefab and GLOBAL.NOMU_QA.SCHEME.TREE.FORMATS.EQUAL or GLOBAL.NOMU_QA.SCHEME.TREE.FORMATS.DESCRIBE, {
            COUNT = count_prefab,
            NUM = count_tree_stat,
            NAME = final_name or display_name,
            ADJ = GetMapping(GLOBAL.NOMU_QA.SCHEME.TREE, 'ADJ', target_tree_stat),
            SHOW_ME = dist_str .. show_me
        }), entity:HasTag('player'), debug_str)
    end

    if use_special and target_is_spiderden and target_spiderden_stat then
        return Announce(subfmt(count_spiderden_stat == count_prefab and GLOBAL.NOMU_QA.SCHEME.SPIDERDEN.FORMATS.EQUAL or GLOBAL.NOMU_QA.SCHEME.SPIDERDEN.FORMATS.DESCRIBE, {
            COUNT = count_prefab,
            NUM = count_spiderden_stat,
            NAME = final_name or display_name,
            ADJ = GetMapping(GLOBAL.NOMU_QA.SCHEME.SPIDERDEN, 'ADJ', target_spiderden_stat),
            SHOW_ME = dist_str .. show_me
        }), entity:HasTag('player'), debug_str)
    end

    if use_special and target_is_hotspring and target_hotspring_stat then
        local is_equal = (count_hotspring_stat == count_prefab)
        local fmt_key = "HOTSPRING_" .. target_hotspring_stat .. (is_equal and "_EQUAL" or "_DESCRIBE")
        return Announce(subfmt(qa.FORMATS[fmt_key], {
            TOTAL = count_prefab,
            NUM = count_hotspring_stat,
            NAME = final_name or display_name,
            SHOW_ME = show_me,
            DISTANCE = dist_str
        }), entity:HasTag('player'), debug_str)
    end

    if use_special and is_fruitdragon and target_is_ripe_fruitdragon then
        local is_equal = (count_ripe_fruitdragon == count_prefab)
        local fmt_key = "FRUITDRAGON_RIPE" .. (is_equal and "_EQUAL" or "_DESCRIBE")

        return Announce(subfmt(qa.FORMATS[fmt_key], {
            TOTAL = count_prefab,
            NUM = count_ripe_fruitdragon,
            NAME = final_name or display_name,
            SHOW_ME = show_me,
            DISTANCE = dist_str
        }), entity:HasTag('player'), debug_str)
    end

    if use_special and is_archive_switch then
        local is_equal = (target_is_full_archive_switch and count_archive_switch_full == count_prefab)
                      or (not target_is_full_archive_switch and count_archive_switch_empty == count_prefab)
        local fmt_key = (target_is_full_archive_switch and "ARCHIVE_SWITCH_FULL" or "ARCHIVE_SWITCH_EMPTY") .. (is_equal and "_EQUAL" or "_DESCRIBE")
        local num = target_is_full_archive_switch and count_archive_switch_full or count_archive_switch_empty

        return Announce(subfmt(qa.FORMATS[fmt_key], {
            TOTAL = count_prefab,
            NUM = num,
            NAME = final_name or display_name,
            SHOW_ME = show_me,
            DISTANCE = dist_str
        }), entity:HasTag('player'), debug_str)
    end

    local final_count = is_blueprint_type and count_name or (final_name and count_prefab or count_name)

    local basic_name = ""
    pcall(function() basic_name = entity:GetBasicDisplayName() end)
    local default_name = entity.prefab and GLOBAL.STRINGS.NAMES[entity.prefab:upper()] or ""

    local is_qa_item = entity.prefab and STRINGS.NOMU_QA[entity.prefab:upper()] ~= nil

    local is_custom_named = false
    if not is_qa_item then
        is_custom_named = basic_name ~= ""
                         and prefab_name ~= nil
                         and basic_name ~= default_name
                         and basic_name ~= prefab_name
                         and not is_blueprint_type
    end

    if is_custom_named and qa.FORMATS.NAMED then
        return Announce(subfmt(qa.FORMATS.NAMED, {
            NUM_PREFAB = count_prefab,
            PREFAB_NAME = prefab_name or GLOBAL.STRINGS.NOMU_QA.UNKNOWN_NAME,
            NUM = count_name,
            NAME = display_name,
            SHOW_ME = show_me,
            DISTANCE = dist_str
        }), entity:HasTag('player'), debug_str)
    end

    if final_count <= 1 then
        return Announce(subfmt(qa.FORMATS.SINGLE, {
            NAME = final_name or display_name,
            SHOW_ME = show_me,
            DISTANCE = dist_str
        }), entity:HasTag('player'), debug_str)
    end

    return Announce(subfmt(qa.FORMATS.DEFAULT, {
        NUM = final_count,
        NAME = final_name or display_name,
        SHOW_ME = show_me,
        DISTANCE = dist_str
    }), entity:HasTag('player'), debug_str)
end)


-- [8] 界面 UI 组件与窗口定义
GLOBAL.NOMU_QA.DeepCopy = DeepCopy
GLOBAL.NOMU_QA.Announce = Announce
GLOBAL.NOMU_QA.VERSION = VERSION
modimport('scripts/qa_config/qa_panel.lua')


-- [9] 游戏内系统钩子与事件注入 
AddSimPostInit(function()

    GLOBAL.NOMU_QA.LoadData()

    -- 动态拦截屏幕弹窗
    if GLOBAL.TheFrontEnd and GLOBAL.TheFrontEnd.PushScreen then
        local old_PushScreen = GLOBAL.TheFrontEnd.PushScreen
        GLOBAL.TheFrontEnd.PushScreen = function(self, screen, ...)
            if screen and screen.name == "MedalExamScreens" and not screen._nomu_qa_hooked then
                screen._nomu_qa_hooked = true
                -- 勋章答题
                if screen.content and not screen.content.hovertext then
                    screen.content:SetHoverText(GLOBAL.STRINGS.NOMU_QA.HOVER_TEXT_ANNOUNCE)
                end
                if screen.title and not screen.title.hovertext then
                    screen.title:SetHoverText(GLOBAL.STRINGS.NOMU_QA.HOVER_TEXT_ANNOUNCE)
                end
                local oldOnControl = screen.OnControl
                function screen:OnControl(control, down, ...)
                    if down and control == GLOBAL.CONTROL_ACCEPT and GLOBAL.TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then
                        if (self.content and self.content.focus) or (self.title and self.title.focus) or (self.destspanel and self.destspanel.focus) then
                            
                            local question = self.content and self.content:GetString() or GLOBAL.STRINGS.NOMU_QA.UNKNOWN_NAME
                            question = question:gsub("\n", ""):gsub("\t", "")
                            
                            local opt_str_list = {}
                            local prefix = {"A.", "B.", "C.", "D."}
                            
                            if self.menu and self.menu.items then
                                for i, v in ipairs(self.menu.items) do
                                    local txt = v:GetText() or ""
                                    if txt ~= "" then
                                        if not txt:match("^[A-D][%.、]") and prefix[i] then
                                            txt = prefix[i] .. " " .. txt
                                        end
                                        table.insert(opt_str_list, txt)
                                    end
                                end
                            end
                            
                            return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.MEDAL_BUFF.FORMATS.EXAM, {
                                QUESTION = question,
                                OPTIONS = table.concat(opt_str_list, "  ")
                            }))
                        end
                    end
                    if oldOnControl then
                        return oldOnControl(self, control, down, ...)
                    end
                    return false
                end
            end
            return old_PushScreen(self, screen, ...)
        end
    end
end)

-- 拦截 HUD 鼠标点击事件
AddClassPostConstruct('screens/playerhud', function(PlayerHud)
    local oldOnMouseButton = PlayerHud.OnMouseButton
    function PlayerHud:OnMouseButton(button, down, ...)
        if button == MOUSEBUTTON_LEFT and down and TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then
            if OnHUDMouseButton(self) then
                return true
            end
        end
        return oldOnMouseButton(self, button, down, ...)
    end

    PlayerHud._StatusAnnouncer = {
        stat_names = { IA_BOAT = '船' },
        char_messages = { },
        Announce = function(_, message) return Announce(message) end,
        AnnounceItem = function(_, slot) return AnnounceItem(slot, 'invslot') end
    }

    setmetatable(PlayerHud._StatusAnnouncer.char_messages, {
        __index = function(_, k) return STRINGS._STATUS_ANNOUNCEMENTS.UNKNOWN[k] end
    })

    local oldOnUpdate = PlayerHud.OnUpdate
    function PlayerHud:OnUpdate(...)
        if self.controls and self.controls.foodcrafting and self.controls.foodcrafting.allfoods then
            for _, food_item in ipairs(self.controls.foodcrafting.allfoods) do
                if food_item.recipepopup then
                    for _, k in ipairs({"hunger", "health", "sanity", "name"}) do
                        if food_item.recipepopup[k] and not food_item.recipepopup[k].hovertext then
                            if k ~= "name" then
                                food_item.recipepopup[k]:SetString('-')
                            end
                            food_item.recipepopup[k]:SetHoverText(STRINGS.NOMU_QA.HOVER_TEXT_ANNOUNCE)
                        end
                    end
                end
            end
        end
        return oldOnUpdate(self, ...)
    end
end)


-- 拦截各种制作栏和槽位的按键
AddClassPostConstruct('widgets/redux/craftingmenu_pinslot', function(PinSlot)
    local oldOnControl = PinSlot.OnControl
    function PinSlot:OnControl(control, down, ...)
        if down and control == GLOBAL.CONTROL_ACCEPT and TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then
            return AnnounceRecipePinSlot(self)
        end
        return oldOnControl(self, control, down, ...)
    end
end)

AddClassPostConstruct('widgets/redux/craftingmenu_widget', function(CMWidget)
    local grid = CMWidget.recipe_grid
    local oldOnControl = grid.OnControl
    function grid:OnControl(control, down, ...)
        if down and control == GLOBAL.CONTROL_ACCEPT and TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then
            return AnnounceRecipeGrid(self, CMWidget.owner)
        end
        return oldOnControl(self, control, down, ...)
    end
end)

AddClassPostConstruct('widgets/redux/craftingmenu_ingredients', function(CMIngredients)
    local oldOnControl = CMIngredients.OnControl
    function CMIngredients:OnControl(control, down, ...)
        if down and control == GLOBAL.CONTROL_ACCEPT and TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then
            return AnnounceRecipeCMIngredients(self)
        end
        return oldOnControl(self, control, down, ...)
    end
end)

AddClassPostConstruct('widgets/redux/craftingmenu_skinselector', function(CMSkinSelector)
    local oldOnControl = CMSkinSelector.OnControl
    function CMSkinSelector:OnControl(control, down, ...)
        if down and control == GLOBAL.CONTROL_ACCEPT and TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then
            return AnnounceSkin(self)
        end
        return oldOnControl(self, control, down, ...)
    end
end)

for _, classname in pairs({ 'invslot', 'equipslot' }) do
    AddClassPostConstruct('widgets/' .. classname, function(SlotClass)
        local oldOnControl = SlotClass.OnControl
        function SlotClass:OnControl(control, down, ...)
            if down and control == GLOBAL.CONTROL_ACCEPT
                and TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT)
                and TheInput:IsKeyDown(GLOBAL.KEY_LSHIFT) then

                local container = self.container
                if container and container.inst and (
                    container.inst.prefab == "construction_container"
                    or container.inst.prefab == "construction_container_1x1"
                    or container.inst:HasTag("offerconstructionsite")
                    or container.inst.prefab == "enable_shadow_rift_construction_container"
                ) then
                    local site = GLOBAL.ThePlayer
                              and GLOBAL.ThePlayer.components.constructionbuilderuidata
                              and GLOBAL.ThePlayer.components.constructionbuilderuidata:GetTarget()
                              or GLOBAL.TheSim:FindEntities(container.inst.Transform:GetWorldPosition(), 4, { "constructionsite" })[1]

                    if site and AnnounceConstructionSite(site, container, self.num) then
                        return true
                    end
                elseif self.tile and self.tile.item then
                    return AnnounceItem(self, classname)
                elseif classname == 'equipslot' then
                    local slot_pos_name = GetEquipSlotName(GLOBAL.NOMU_QA.SCHEME.ITEM, self.equipslot)
                    if slot_pos_name then
                        return Announce(
                            subfmt(GLOBAL.NOMU_QA.SCHEME.ITEM.FORMATS.EQUIP_SLOT_EMPTY, {
                                PRONOUN = GetMapping(GLOBAL.NOMU_QA.SCHEME.ITEM, 'PRONOUN', 'I'),
                                SLOT_POS = slot_pos_name,
                                v = slot_pos_name
                            }),
                            nil,
                            GLOBAL.NOMU_QA.DATA.DEBUG_MODE and string.format("[槽位代码: %s]", tostring(self.equipslot)) or nil
                        )
                    end
                elseif container and container.GetNumSlots and container.GetItems then
                    local used_slots = 0
                    for _ in pairs(container:GetItems()) do
                        used_slots = used_slots + 1
                    end
                    local inst = container.inst
                    local cont_type = inst == GLOBAL.ThePlayer and "PLAYER" or (inst and inst:HasTag("inlimbo") and "INV" or "CONTAINER")

                    return Announce(
                        subfmt(GLOBAL.NOMU_QA.SCHEME.SPACE.FORMATS[cont_type], {
                            COUNT = container:GetNumSlots() - used_slots,
                            CONTAINER_NAME = get_container_name(inst)
                        }),
                        nil,
                        GLOBAL.NOMU_QA.DATA.DEBUG_MODE and string.format("[容器代码: %s]", tostring(inst and (inst == GLOBAL.ThePlayer and "inventory" or inst.prefab) or container.type or "inventory")) or nil
                    )
                end
            end
            return oldOnControl(self, control, down, ...)
        end
    end)
end

AddClassPostConstruct('widgets/giftitemtoast', function(self)
    local oldOnMouseButton = self.OnMouseButton
    function self:OnMouseButton(button, down, ...)
        local ret = oldOnMouseButton(self, button, down, ...)
        if button == MOUSEBUTTON_LEFT and down and TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then
            Announce(self.enabled and GLOBAL.NOMU_QA.SCHEME.GIFT.FORMATS.CAN_OPEN or GLOBAL.NOMU_QA.SCHEME.GIFT.FORMATS.NEED_SCIENCE)
        end
        return ret
    end
end)

AddClassPostConstruct('screens/playerstatusscreen', function(PlayerStatusScreen)
    local oldOnUpdate = PlayerStatusScreen.OnUpdate
    function PlayerStatusScreen:OnUpdate(...)
        for _, v in ipairs({self.servertitle, self.serverstate, self.players_number}) do
            if v and not v.hovertext then
                v:SetHoverText(STRINGS.NOMU_QA.HOVER_TEXT_ANNOUNCE)
            end
        end
        for _, widget in ipairs(PlayerStatusScreen.player_widgets) do
            if widget.age and not widget.age.hovertext then
                widget.age:SetHoverText(STRINGS.NOMU_QA.HOVER_TEXT_ANNOUNCE)
            end
        end
        return oldOnUpdate(self, ...)
    end

    local oldOnControl = PlayerStatusScreen.OnControl
    function PlayerStatusScreen:OnControl(control, down, ...)
        if down and control == GLOBAL.CONTROL_ACCEPT and TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then
            if self.servertitle and self.servertitle.focus then
                return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.SERVER.FORMATS.NAME, { NAME = PlayerStatusScreen.servertitle:GetString() }))
            end
            if self.serverstate and self.serverstate.focus then
                return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.SERVER.FORMATS.AGE, { AGE = PlayerStatusScreen.serverage }))
            end
            if self.players_number and self.players_number.focus then
                return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.SERVER.FORMATS.NUM_PLAYER, { NUM = PlayerStatusScreen.players_number:GetString() }))
            end
            for _, w in ipairs(PlayerStatusScreen.player_widgets) do
                if w.focus and w.displayName then
                    if w.name and w.name.focus then
                        return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.GREET, { NAME = w.displayName }))
                    end
                    if w.adminBadge and w.adminBadge.shown and w.adminBadge.focus then
                        return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.ADMIN, { NAME = w.displayName }))
                    end
                    if w.perf and w.perf.shown and w.perf.focus and w.perf.hovertext then 
                        return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.PERF, { 
                            NAME = w.displayName, 
                            PERF = w.perf.hovertext:GetString(), 
                            PING = (w.userid == ThePlayer.userid and subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.PING, { PING = TheNet:GetAveragePing() }) or '') 
                        })) 
                    end
                    if w.profileFlair and w.profileFlair.shown and w.profileFlair.focus and w.characterBadge and w.characterBadge.prefabname then
                        return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.NAME, {
                            NAME = w.displayName,
                            CHARACTER = STRINGS.NAMES[w.characterBadge.prefabname:upper()] or w.characterBadge.prefabname
                        }))
                    end
                    if w.age and w.age.shown and w.age.focus and #w.age:GetString() > 0 then
                        return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.AGE, {
                            NAME = w.displayName,
                            AGE = w.age:GetString()
                        }))
                    end
                end
            end
        end
        return oldOnControl(self, control, down, ...)
    end
end)

AddClassPostConstruct('widgets/playeravatarpopup', function(PlayerAvatarPopup)
    local items = { 'body', 'hand', 'legs', 'feet', 'base', 'head_equip', 'hand_equip', 'body_equip' }

    if PlayerAvatarPopup.age and not PlayerAvatarPopup.age.hovertext then
        PlayerAvatarPopup.age:SetHoverText(STRINGS.NOMU_QA.HOVER_TEXT_ANNOUNCE)
    end

    for _, item in ipairs(items) do
        if PlayerAvatarPopup[item .. '_image'] and PlayerAvatarPopup[item .. '_image']._text and not PlayerAvatarPopup[item .. '_image']._text.hovertext then
            PlayerAvatarPopup[item .. '_image']._text:SetHoverText(STRINGS.NOMU_QA.HOVER_TEXT_ANNOUNCE)
        end
    end

    local oldOnControl = PlayerAvatarPopup.OnControl
    function PlayerAvatarPopup:OnControl(control, down, ...)
        if down and control == GLOBAL.CONTROL_ACCEPT and TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) and self.player_name then
            if self.age and self.age.focus and self.currentcharacter then
                return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.AGE_SHORT, {
                    NAME = self.player_name,
                    AGE = self.age:GetString()
                }))
            end
            if self.character_name and self.character_name.focus and self.currentcharacter then
                return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.NAME, {
                    NAME = self.player_name,
                    CHARACTER = STRINGS.NAMES[self.currentcharacter:upper()] or self.currentcharacter
                }))
            end
            if self.puppet and self.puppet.rank and self.puppet.rank.focus and self.puppet.rank.flair and self.puppet.rank.flair.hovertext then
                return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.BADGE, {
                    NAME = self.player_name,
                    BADGE = self.puppet.rank.flair.hovertext:GetString()
                }))
            end
            if self.puppet and self.puppet.frame and self.puppet.frame.focus and self.puppet.frame.bg and self.puppet.frame.bg.hovertext then
                return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.BACKGROUND, {
                    NAME = self.player_name,
                    BACKGROUND = self.puppet.frame.bg.hovertext:GetString()
                }))
            end
            for _, item in ipairs(items) do
                if self[item .. '_image'] and self[item .. '_image'].focus then
                    return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS[item:upper()], {
                        NAME = self.player_name,
                        [string.upper(item)] = self[item .. '_image']._text:GetString()
                    }))
                end
            end
        end
        return oldOnControl(self, control, down, ...)
    end
end)

AddClassPostConstruct('widgets/redux/skilltreebuilder', function(SkillTreeBuilder)
    local oldOnControl = SkillTreeBuilder.OnControl
    function SkillTreeBuilder:OnControl(control, down, ...)
        if down and control == GLOBAL.CONTROL_ACCEPT and TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then
            local name = (type(self.fromfrontend) == "table" and self.fromfrontend.data and self.fromfrontend.data.name and self.fromfrontend.data.name ~= "")
                      and self.fromfrontend.data.name
                      or (self.player_name and self.player_name ~= "" and self.player_name
                      or (GLOBAL.TheFrontEnd:GetActiveScreen() and GLOBAL.TheFrontEnd:GetActiveScreen().player_name or "该玩家"))

            if self.root
                and ((self.root.xpicon and self.root.xpicon.focus) or (self.root.xptotal and self.root.xptotal.focus) or (self.root.xp_tospend and self.root.xp_tospend.focus))
                and self.root.xptotal
                and self.root.xptotal:GetString() then
                return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.SKILL_TREE.FORMATS.XP, {
                    NAME = name,
                    XP = self.root.xptotal:GetString()
                }))
            end

            for k, v in pairs(self.skillgraphics) do
                if v.button and v.button.focus and v.status and self.skilltreedef and self.skilltreedef[k] and self.skilltreedef[k].title then
                    local scheme_fmt = v.status.activated and GLOBAL.NOMU_QA.SCHEME.SKILL_TREE.FORMATS.ACTIVATED
                                    or (v.status.activatable and GLOBAL.NOMU_QA.SCHEME.SKILL_TREE.FORMATS.CAN_ACTIVATE
                                    or GLOBAL.NOMU_QA.SCHEME.SKILL_TREE.FORMATS.NOT_ACTIVATED)
                    return Announce(subfmt(scheme_fmt, {
                        NAME = name,
                        SKILL = self.skilltreedef[k].title
                    }))
                end
            end
        end
        return oldOnControl(self, control, down, ...)
    end
end)

AddClassPostConstruct('widgets/redux/cookbookpage_crockpot', function(CookbookPageCrockPot)
    local oldPopulateRecipeDetailPanel = CookbookPageCrockPot.PopulateRecipeDetailPanel
    function CookbookPageCrockPot:PopulateRecipeDetailPanel(data, ...)
        self.nomu_qa_data = data
        return oldPopulateRecipeDetailPanel(self, data, ...)
    end

    CookbookPageCrockPot.nomu_qa_data = CookbookPageCrockPot.all_recipes[(TheCookbook.selected ~= nil and TheCookbook.selected[CookbookPageCrockPot.category] or 1)]

    local oldOnControl = CookbookPageCrockPot.OnControl
    function CookbookPageCrockPot:OnControl(control, down, ...)
        if down and control == GLOBAL.CONTROL_ACCEPT and TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) and self.nomu_qa_data and self.details_root and self.details_root.focus then
            local data = self.nomu_qa_data
            return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.COOK.FORMATS.FOOD, {
                NAME = data.name,
                HUNGER = data.recipe_def.hunger ~= nil and math.floor(10 * data.recipe_def.hunger) / 10 or '-',
                SANITY = data.recipe_def.sanity ~= nil and math.floor(10 * data.recipe_def.sanity) / 10 or '-',
                HEALTH = data.recipe_def.health ~= nil and math.floor(10 * data.recipe_def.health) / 10 or '-'
            }))
        end
        return oldOnControl(self, control, down, ...)
    end
end)

local controls
AddClassPostConstruct("widgets/controls", function(self)
    controls = self
    if controls and controls.top_root then
        controls.nomu_qa_panel = controls.top_root:AddChild(GLOBAL.NOMU_QA.QAPanel())
        controls.nomu_qa_panel:Hide()
    end
end)

local key_toggle = GetModConfigData("announcekey_toggle")
TheInput:AddKeyUpHandler(key_toggle, function()
    if IsDefaultScreen() and controls and controls.nomu_qa_panel then
        if controls.nomu_qa_panel.shown then
            controls.nomu_qa_panel:Hide()
        else
            controls.nomu_qa_panel:Show()
        end
    end
end)

local state, m_util = GLOBAL.pcall(GLOBAL.require, "util/modutil")
if state and m_util then
    local function ToggleQAPanel()
        local icons = m_util:GetIcons()
        if icons and icons["快捷宣告"] then
            icons["快捷宣告"].close = true
        end
        if IsDefaultScreen() and controls and controls.nomu_qa_panel then
            if controls.nomu_qa_panel.shown then
                controls.nomu_qa_panel:Hide()
            else
                controls.nomu_qa_panel:Show()
            end
        end
    end

    local function SwitchAnnounceScheme()
        local icons = m_util:GetIcons()
        if icons and icons["快捷宣告"] then
            icons["快捷宣告"].close = false
        end

        local qadata = GLOBAL.NOMU_QA.DATA
        if not qadata or not qadata.SCHEMES or #qadata.SCHEMES == 0 then
            return
        end

        local current_name = qadata.CURRENT_SCHEME and qadata.CURRENT_SCHEME.name
        local next_idx = 1
        for i, scheme in ipairs(qadata.SCHEMES) do
            if scheme.name == current_name then
                next_idx = (i % #qadata.SCHEMES) + 1
                break
            end
        end

        local new_scheme = qadata.SCHEMES[next_idx]
        qadata.CURRENT_SCHEME = new_scheme
        GLOBAL.NOMU_QA.ApplyScheme(new_scheme)
        GLOBAL.NOMU_QA.SaveData()

        if GLOBAL.ThePlayer and GLOBAL.ThePlayer.components.talker then
            GLOBAL.ThePlayer.components.talker:Say("宣告风格已切换为: " .. tostring(new_scheme.name))
        end
    end

    m_util:AddBindIcon("快捷宣告", "playbill_the_veil", STRINGS.LMB .. "打开设置" .. STRINGS.RMB .. "切换风格", false, ToggleQAPanel, SwitchAnnounceScheme)
end

AddClassPostConstruct("widgets/hoverer", function(hoverer)
    local oldSetString = hoverer.text.SetString
    hoverer.text.SetString = function(text, str, ...)
        local show_mod = GLOBAL.NOMU_QA.DATA.SHOW_MOD_NAME
        local asset_mode = GLOBAL.NOMU_QA.DATA.SHOW_ASSET_INFO

        if not show_mod and (not asset_mode or asset_mode == 0) then
            return oldSetString and oldSetString(text, str, ...)
        end

        local target = GLOBAL.TheInput:GetHUDEntityUnderMouse()
        target = (target and target.widget and target.widget.parent ~= nil and target.widget.parent.item)
              or GLOBAL.TheInput:GetWorldEntityUnderMouse()
              or nil

        if target and target.prefab then
            str = str:gsub("%s+$", "")

            if show_mod then
                local cached_mod = GetModNameForPrefab(target.prefab)
                if cached_mod then
                    str = str .. "\n" .. (STRINGS.NOMU_QA.SHOW_MOD_PREFIX or "Mod: ") .. cached_mod
                end
            end

            if asset_mode and asset_mode > 0 then
                str = str .. (STRINGS.NOMU_QA.HOVER_PREFAB_PREFIX or "\nPrefab: ") .. target.prefab
                if asset_mode == 2 then
                    local bank, build = GetBuildCached(target)
                    if bank and build then
                        str = str .. (STRINGS.NOMU_QA.HOVER_BANK_PREFIX or "\nBank: anim/") .. bank .. (STRINGS.NOMU_QA.HOVER_ZIP_SUFFIX or ".zip")
                        str = str .. (STRINGS.NOMU_QA.HOVER_BUILD_PREFIX or "\nBuild: anim/") .. build .. (STRINGS.NOMU_QA.HOVER_ZIP_SUFFIX or ".zip")
                    end
                end
            end
        end

        if oldSetString then
            return oldSetString(text, str, ...)
        end
    end
end)

AddComponentPostInit("playercontroller", function(self)
    local old_OnControl = self.OnControl
    function self:OnControl(control, down, ...)
        if GLOBAL.NOMU_QA.DATA.BLOCK_ACTION and (control == GLOBAL.CONTROL_PRIMARY or control == GLOBAL.CONTROL_SECONDARY) then
            if IsDefaultScreen() and TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) and TheInput:IsKeyDown(GLOBAL.KEY_LSHIFT) then
                return true
            end
        end
        if old_OnControl then
            return old_OnControl(self, control, down, ...)
        end
    end
end)