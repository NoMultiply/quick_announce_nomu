-- ============================================================================
-- [1] 模组初始化与基础环境设定
-- ============================================================================
GLOBAL.setmetatable(env, {
    __index = function(_, k)
        return GLOBAL.rawget(GLOBAL, k)
    end
})

if GLOBAL.rawget(GLOBAL, "NOMU_QA") then return end

-- 声明模组所需的资源文件（图标、贴图等）
Assets = {}

-- 是否启用表情包功能
local ENABLE_MEME_SYSTEM = GetModConfigData("enable_meme_system")
if ModManager and ModManager:GetMod("workshop-3678295700") ~= nil then
    ENABLE_MEME_SYSTEM = false
end
GLOBAL.NOMU_QA = {}
GLOBAL.NOMU_QA.ENABLE_MEME_SYSTEM = ENABLE_MEME_SYSTEM
GLOBAL.NOMU_QA.MOON_DATA = {
    last_phase = nil,
    phase_start_cycle = 0,
    is_confident = false, -- 是否已观测到阶段起点
}

-- 导入外部 Lua 辅助模块的安全加载函数
local function Import(modulename)
    local f = GLOBAL.kleiloadlua(modulename)
    if f and type(f) == "function" then
        setfenv(f, GLOBAL)
        return f()
    end
end

-- 加载 Upvalue 修改助手
Upvaluehelper = Import(MODROOT .. "bbgoat_upvaluehelper.lua")

-- 检查当前是否处于游戏主界面 (HUD) 且玩家未在打字/输入状态
local function IsDefaultScreen()
    local active_screen = GLOBAL.TheFrontEnd:GetActiveScreen()

    -- 如果正在编辑文本，返回 false
    if active_screen and active_screen.IsEditing and active_screen:IsEditing() then
        return false
    end

    local screen = active_screen and active_screen.name or ""

    -- 必须满足：在 HUD 界面、有玩家实体、未打开聊天框、无可写屏幕
    return screen:find("HUD") ~= nil
        and GLOBAL.ThePlayer ~= nil
        and not GLOBAL.ThePlayer.HUD:IsChatInputScreenOpen()
        and not GLOBAL.ThePlayer.HUD.writeablescreen
end

-- ============================================================================
-- [2] 导入配置文件与核心数据模块
-- ============================================================================

-- 导入各类词库与配置文件
modimport('scripts/qa_config/qa_default.lua')
modimport('scripts/qa_config/qa_cat.lua')
modimport('scripts/qa_config/qa_tsundere.lua')
modimport('scripts/qa_config/qa_cute.lua')
modimport('scripts/qa_config/qa_utils.lua')
modimport('scripts/qa_data.lua')
modimport('scripts/qa_debug.lua')
-- 提取常用工具函数到本地变量，提高访问效率
local DeepCopy = GLOBAL.NOMU_QA.DeepCopy
local escape_pattern = GLOBAL.NOMU_QA.escape_pattern

-- 本地化字符串表映射
local LOCAL_STRINGS = GLOBAL.STRINGS.NOMU_QA or {}

-- 检测 Show Me 模组是否已启用
local SHOW_ME_ON = MOD_RPC.ShowMeSHint ~= nil or ModManager:GetMod("workshop-2189004162") ~= nil

-- 检测是否启用了群鸟绘卷
local QUNNIAO_ON = ModManager:GetMod("workshop-3161117403") ~= nil

-- ============================================================================
-- [3] 按键管理与核心辅助工具
-- ============================================================================
----------------------------------------
-- 3.2 Insight 信息清洗
----------------------------------------

local function CleanInsightString(clean_info)
    if not clean_info or clean_info == "" then return "" end

    clean_info = clean_info:gsub("<prefab=([^>]+)>", function(prefab)
    local upper_prefab = string.upper(prefab)
    return LOCAL_STRINGS[upper_prefab] 
        or (GLOBAL.STRINGS.NAMES[upper_prefab] and tostring(GLOBAL.STRINGS.NAMES[upper_prefab]))
        or prefab
    end)

    clean_info = clean_info:gsub("<string=([^>]+)>", function(str_path)
        local current = GLOBAL.STRINGS
        for field in str_path:gmatch("[^%.]+") do
            if type(current) == "table" then
                current = current[field]
            else
                current = nil
                break
            end
        end
        return type(current) == "string" and current or str_path
    end)

    clean_info = clean_info:gsub("<temperature=([^>]+)>", "%1")
    clean_info = clean_info:gsub("</?%a+[^>]*>", "")

    return clean_info
end

----------------------------------------
-- 3.3 动画状态批量检查
----------------------------------------

-- 检查 AnimState 是否正在播放指定列表中的任意动画
local function CheckAnims(animState, anim_list)
    if not animState then return false end
    for _, anim in ipairs(anim_list) do
        if animState:IsCurrentAnimation(anim) then
            return true
        end
    end
    return false
end
-------------------------------------
-- 3.4 实体名称获取与自定义名称
----------------------------------------
-- 应用自定义预制物名称
local function ApplyCustomName(prefab, fallback_name)
    if not GLOBAL.NOMU_QA.DATA.ENABLE_CUSTOM_PREFAB_NAME
        or not GLOBAL.NOMU_QA.DATA.CUSTOM_PREFAB_NAMES
        or not prefab then
        return fallback_name, false
    end

    local prefab_str = string.lower(tostring(prefab))
    for _, v in ipairs(GLOBAL.NOMU_QA.DATA.CUSTOM_PREFAB_NAMES) do
        if v.prefab and string.lower(v.prefab) == prefab_str and v.name ~= "" then
            return v.name, true
        end
    end
    return fallback_name, false
end

-- 统一获取实体名称
local function GetEntityName(entity, force_basic)
    if not entity then
        return GLOBAL.STRINGS.NOMU_QA.UNKNOWN_NAME, GLOBAL.STRINGS.NOMU_QA.UNKNOWN_NAME, false
    end

    local actual_prefab = tostring(entity.prefabnameoverride or entity.nameoverride or entity.prefab)

    local upper_prefab = string.upper(actual_prefab)
    
    local base_prefab_name = LOCAL_STRINGS[upper_prefab] 
        or (GLOBAL.STRINGS.NAMES[upper_prefab] and tostring(GLOBAL.STRINGS.NAMES[upper_prefab])) 
        or actual_prefab

    local raw_name = ""
    if not force_basic and entity.GetDisplayName and type(entity.GetDisplayName) == "function" then
        raw_name = entity:GetDisplayName() or ""
    elseif entity.GetBasicDisplayName and type(entity.GetBasicDisplayName) == "function" then
        raw_name = entity:GetBasicDisplayName() or entity.name or ""
    else
        raw_name = entity.name or ""
    end
    
    local original_display_name = string.match(raw_name, "[^\n]+") or raw_name
    local is_missing = (original_display_name == "" or string.find(string.upper(original_display_name), "MISSING") or string.find(string.upper(base_prefab_name), "MISSING"))
    if is_missing then original_display_name = base_prefab_name end

    local display_name = original_display_name
    local final_prefab_name = base_prefab_name
    local is_player_named = false

    if entity.prefab and string.find(entity.prefab, "sinkhole") then
        local sinkhole_name = GLOBAL.STRINGS.NOMU_QA[string.upper(entity.prefab)] or GLOBAL.STRINGS.NOMU_QA.SINKHOLE
        return sinkhole_name, sinkhole_name, false
    end

    local custom_name = entity.replica and (
        (entity.replica.named and entity.replica.named._name and entity.replica.named._name:value()) or 
        (entity.replica.writeable and entity.replica.writeable._text and entity.replica.writeable._text:value())
    )
    if custom_name and custom_name ~= "" then
        is_player_named = true
        if string.find(raw_name, custom_name, 1, true) then
            display_name = string.gsub(raw_name, "\n", " ")
        else
            local adj = entity.GetAdjective and entity:GetAdjective() or ""
            display_name = string.gsub(adj ~= "" and (adj .. custom_name) or custom_name, "\n", " ")
        end
    end

    local custom_qa_name, has_custom = ApplyCustomName(actual_prefab, base_prefab_name)
    local qa_hardcoded_name = GLOBAL.STRINGS.NOMU_QA[string.upper(actual_prefab)]
    local broad_category_name = GLOBAL.STRINGS.NOMU_QA.BROAD_CATEGORIES and GLOBAL.STRINGS.NOMU_QA.BROAD_CATEGORIES[string.upper(actual_prefab)]

    if has_custom then
        final_prefab_name = custom_qa_name
        display_name = is_player_named and display_name or custom_qa_name
    elseif qa_hardcoded_name then
        local l_ori, l_qa = string.lower(original_display_name), string.lower(qa_hardcoded_name)
        if is_missing or string.find(l_ori, l_qa, 1, true) or qa_hardcoded_name == original_display_name then
            final_prefab_name = qa_hardcoded_name
            display_name = is_player_named and display_name or (is_missing and qa_hardcoded_name or original_display_name)
        else
            final_prefab_name = original_display_name
            if not is_player_named then display_name = qa_hardcoded_name; is_player_named = true end
        end
    else
        final_prefab_name = base_prefab_name
        display_name = is_player_named and display_name or original_display_name
    end

    if broad_category_name then final_prefab_name = broad_category_name end
    return display_name, final_prefab_name, is_player_named
end

----------------------------------------
-- 3.5 核心消息宣告函数
----------------------------------------

-- 获取语句在模板方案中的位置描述
local function GetStatementLoc(func_key, sub_key)
    local func_name = (LOCAL_STRINGS.FUNC and LOCAL_STRINGS.FUNC[func_key])
        or (GLOBAL.STRINGS.NOMU_QA and GLOBAL.STRINGS.NOMU_QA.FUNC and GLOBAL.STRINGS.NOMU_QA.FUNC[func_key])
        or func_key
    if sub_key and sub_key ~= "" then
        return string.format("%s-%s", tostring(func_name), tostring(sub_key))
    end
    return tostring(func_name)
end

-- 发送宣告消息到聊天频道
local function Announce(message, no_whisper, debug_info, statement_loc)
    -- 执行文本替换规则
    if GLOBAL.NOMU_QA.DATA.ENABLE_REPLACE and GLOBAL.NOMU_QA.DATA.REPLACEMENTS_ESCAPED then
        for _, rule in ipairs(GLOBAL.NOMU_QA.DATA.REPLACEMENTS_ESCAPED) do
            message = message:gsub(rule.target, rule.result)
        end
    end

    -- 修复温度符号编码
    message = message:gsub("(%d)\176", "%1°")

    -- 过滤违禁词
    if GLOBAL.NOMU_QA.DATA.ENABLE_FORBIDDEN and GLOBAL.NOMU_QA.DATA.FORBIDDEN_WORDS_ESCAPED then
        for _, escaped_word in ipairs(GLOBAL.NOMU_QA.DATA.FORBIDDEN_WORDS_ESCAPED) do
            message = message:gsub(escaped_word, "")
        end
    end

    -- 判断是否为私聊（Ctrl 键切换）
    local whisper = GLOBAL.NOMU_QA.DATA.DEFAULT_WHISPER ~= GLOBAL.TheInput:IsKeyDown(GLOBAL.KEY_LCTRL)
    if no_whisper then
        whisper = false
    end

    local sent = false

    if message ~= "" then
        local prefix = GLOBAL.NOMU_QA.DATA.CUSTOM_PREFIX
        if prefix == nil or prefix == "" then
            prefix = GLOBAL.STRINGS.LMB
        end
        GLOBAL.TheNet:Say(prefix .. ' ' .. message, whisper)
        sent = true
    end

    if GLOBAL.NOMU_QA.DATA.DEBUG_MODE then
        local loc_tag = ""
        if statement_loc and statement_loc ~= "" then
            loc_tag = statement_loc:find("%[语句:") and statement_loc or string.format("[语句:%s]", statement_loc)
        end

        local final_debug_str = ""
        if loc_tag ~= "" then
            final_debug_str = loc_tag .. " "
        end
        if debug_info and debug_info ~= "" then
            final_debug_str = final_debug_str .. debug_info
        end

        if CURRENT_HUD_DEBUG_STR and CURRENT_HUD_DEBUG_STR ~= "" then
            local first_line, rest = string.match(final_debug_str, "^([^\n]*)(\n.*)$")
            if first_line then
                final_debug_str = first_line .. " " .. CURRENT_HUD_DEBUG_STR .. rest
            else
                final_debug_str = final_debug_str .. " " .. CURRENT_HUD_DEBUG_STR
            end
            CURRENT_HUD_DEBUG_STR = nil
        end

        if final_debug_str ~= "" then
            print("==================================================")
            print("[NOMU_QA 调试信息] " .. final_debug_str)
        end
    end

    return sent
end

----------------------------------------
-- 3.6 方案映射与徽章宣告辅助
----------------------------------------

-- 根据当前角色和类别获取映射文本（支持角色专属配置）
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
local function AnnounceBadge(qa, current, max, category, qa_key, custom_fmt_key)
    local fmts = {
        CURRENT = math.floor(current + 0.5),
        MAX = max,
        MESSAGE = GetMapping(qa, 'MESSAGE', category)
    }

    -- 优先使用拥有的表情符号，否则回退到文本符号
    local emoji_key = GetMapping(qa, 'SYMBOL', 'EMOJI')
    if emoji_key and TheInventory:CheckOwnership('emoji_' .. emoji_key) then
        fmts.SYMBOL = ':' .. emoji_key .. ':'
    else
        fmts.SYMBOL = GetMapping(qa, 'SYMBOL', 'TEXT')
    end

    local fmt_key = custom_fmt_key or 'DEFAULT'
    local stmt_loc = qa_key and GetStatementLoc(qa_key, fmt_key) or nil
    return Announce(subfmt(qa.FORMATS[fmt_key] or qa.FORMATS.DEFAULT, fmts), nil, nil, stmt_loc)
end

-- 根据阈值数组获取百分比对应的层级索引
local function get_category(thresholds, percent)
    local i = 1
    while thresholds[i] ~= nil and percent >= thresholds[i] do
        i = i + 1
    end
    return i
end

----------------------------------------
-- 3.7 Show Me 模组兼容处理
----------------------------------------
local SHOW_ME_CACHE = nil

local function IsBannedShowMeLine(str, target_name)
    if str == target_name then return true end
    if str:find("󰀉") then return true end

    if not SHOW_ME_CACHE then
        SHOW_ME_CACHE = {
            lmb_pattern = GLOBAL.STRINGS.LMB and ("^%s*" .. escape_pattern(GLOBAL.STRINGS.LMB)),
            rmb_pattern = GLOBAL.STRINGS.RMB and ("^%s*" .. escape_pattern(GLOBAL.STRINGS.RMB))
        }
    end
    
    local p = SHOW_ME_CACHE
    if (p.lmb_pattern and str:find(p.lmb_pattern)) or (p.rmb_pattern and str:find(p.rmb_pattern)) then
        return true
    end

    local filters = GLOBAL.NOMU_QA.DATA.ENABLE_SHOWME_FILTER and GLOBAL.NOMU_QA.DATA.SHOWME_FILTERS
    if filters then
        for _, bad_word in ipairs(filters) do
            if bad_word ~= "" and str:find(bad_word) then return true end
        end
    end
    return false
end

local function ParseBundleLine(str)
    local clean_str = str and str:gsub("^%s*%d+%s*[:%.、%-]%s*", ""):match("^(.-)%s*$")
    if not clean_str or clean_str:match("^%d+[%d%.]*$") then return nil end

    local name, count = clean_str:match("^(.-)%s*%(%s*(%d+)%s*%)%s*$")
    if not name then name, count = clean_str:match("^(.-)%s*[xX*×]%s*(%d+)%s*$") end

    return name and name ~= "" and (tonumber(count) > 1 and name .. " x" .. count or name) or clean_str
end

local function GetShowMeString(target, qa, start_line, end_line, p3, p4)
    if not target then return "" end

    local SB = GLOBAL.rawget(GLOBAL, "SB")
    local is_gift = target:HasTag('unwrappable') or target:HasTag('bundle') or target:HasTag('gift') 
        or target.prefab == 'gift' or target.prefab == 'bundle' 
        or (target.replica and target.replica.unwrappable ~= nil) 
        or (SB and SB.supported_items and SB.supported_items[target.prefab] ~= nil)
        
    local has_health = target:HasTag('_health') or target:HasTag('health') or (target.replica and target.replica.health ~= nil)
    local showbundle_data = target.showbundle_itemdata
    local has_showbundle = type(showbundle_data) == "table" and next(showbundle_data) ~= nil

    local show_me_mode = GLOBAL.NOMU_QA.DATA.SHOW_ME
    if (not SHOW_ME_ON and not has_showbundle) or not (show_me_mode == 1 or (show_me_mode == 2 and (is_gift or has_health or has_showbundle))) then
        return ""
    end

    local items = {}
    if SHOW_ME_ON then
        items = GLOBAL.QA_UTILS.ParseHoverText(start_line, end_line, p3, p4) or {}
        local insight_data = GLOBAL.ThePlayer and GLOBAL.ThePlayer.replica.insight and GLOBAL.ThePlayer.replica.insight.entity_data and GLOBAL.ThePlayer.replica.insight.entity_data[target]
        if insight_data and insight_data.information and insight_data.information ~= "" then
            for line in CleanInsightString(insight_data.information):gmatch("[^\r\n]+") do table.insert(items, line) end
        end
        local hover = GLOBAL.ThePlayer and GLOBAL.ThePlayer.HUD and GLOBAL.ThePlayer.HUD.controls and GLOBAL.ThePlayer.HUD.controls.hover
        if is_gift and #items == 0 and hover then
            local hover_str = (hover.insightText and hover.insightText.raw_text and CleanInsightString(hover.insightText.raw_text)) or (hover.text and hover.text.GetString and hover.text:GetString()) or ""
            for line in hover_str:gmatch("[^\r\n]+") do table.insert(items, line) end
        end
    end

    local filtered, found_health_line = {}, false
    local target_display_name = (target.GetBasicDisplayName and target:GetBasicDisplayName()) or target.name or ""

    for _, str in ipairs(items) do
        if str:match("[^ \t\r\n]") and not IsBannedShowMeLine(str, target_display_name) then
            if show_me_mode == 2 and has_health and not is_gift then
                if not found_health_line and str:find("%d+[%d%,%.]*%s*/%s*%d+[%d%,%.]*") then
                    found_health_line = true
                    table.insert(filtered, "󰀍 " .. str)
                end
            else
                local line = str
                if line then table.insert(filtered, line) end
            end
        end
    end

    if is_gift and #filtered == 0 and has_showbundle then
        for _, info in pairs(showbundle_data) do
            if type(info) == "table" and info.prefab then
                local stack = tonumber(info.stack or info.count or info.num) or 1
                local item_name = ApplyCustomName(info.prefab, LOCAL_STRINGS[string.upper(info.prefab)] or GLOBAL.STRINGS.NAMES[string.upper(info.prefab)] or tostring(info.prefab))
                local parsed_line = stack > 1 and (item_name .. "x" .. stack) or item_name
                table.insert(filtered, parsed_line)
            end
        end
    end

    -- 农场植物保留前两行
    if target:HasTag("farm_plant") then while #filtered > 2 do table.remove(filtered) end end

    if #filtered > 0 then
        local joined_str = ""
        for _, line in ipairs(filtered) do
            local add = (joined_str == "" and "" or ", ") .. line
            if #joined_str + #add > 125 then 
                return subfmt(GetMapping(qa, 'WORDS', 'SHOW_ME'), { SHOW_ME = joined_str .. "..." }) 
            end
            joined_str = joined_str .. add
        end
        return subfmt(GetMapping(qa, 'WORDS', 'SHOW_ME'), { SHOW_ME = joined_str })
    end
    
    return ""
end

-- ============================================================================
-- [4] 实体状态检测工具
-- ============================================================================

-- 常见可采摘植物预制物集合
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

-- 统一动画状态配置表：将动画名映射到逻辑状态
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
    },
    hotspring = {
        { state = "BOMBED", anims = {"glow_loop", "glow_pre", "bath_bomb"} },
        { state = "EMPTY",  anims = {"empty"} }
    }
}

-- 通用动画状态检索函数
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

-- 各类型实体状态的快捷获取函数
local function GetCropStat(animState)
    return GetStateFromAnimConfig("crop", animState)
end

local function GetSaltStackStat(animState)
    return GetStateFromAnimConfig("saltstack", animState)
end

local function GetMarbleShrubStat(animState)
    return GetStateFromAnimConfig("marbleshrub", animState)
end

local function GetBeeboxStat(animState)
    return GetStateFromAnimConfig("beebox", animState)
end

local function GetMushroomFarmStat(animState)
    return GetStateFromAnimConfig("mushroom_farm", animState)
end

local function GetLureplantStat(animState)
    return GetStateFromAnimConfig("lureplant", animState, "PICKABLE_READY")
end

local function GetHotspringStat(ent)
    if not ent or ent.prefab ~= "hotspring" then return nil end
    if ent:HasTag("moonglass") then return "GLASSED" end
    return GetStateFromAnimConfig("hotspring", ent.AnimState)
end

local function GetSpiderDenStat(ent)
    if not ent then return nil end
    -- 暗影棋子
    if ent:HasTag("shadowchesspiece") then
        if ent:HasTag("smallepic") then
            return "L2"
        elseif ent:HasTag("epic") then
            return "L3"
        else
            return "L1"
        end
    end

    if not ent:HasTag("spiderden") then return nil end
    local level = nil
    if ent:HasTag("tent") then
        level = 3
    elseif ent.prefab == "spiderden_2" then
        level = 2
    elseif ent.prefab == "spiderden_3" then
        level = 3
    else
        level = GetStateFromAnimConfig("spiderden", ent.AnimState, nil)
    end
    if not level then return nil end
    return "L" .. tostring(level) .. (ent:HasTag("bedazzled") and "_BEDAZZLED" or "")
end

-- 树木状态综合判断（含多种特殊树种）
local function GetTreeStat(ent)
    if not ent then return nil end

    if ent:HasTag("stump") then return "STUMP" end

    -- 石化树
    if ent:HasTag("rock_tree") then
        if ent:HasTag("boulder") then return "BOULDER" end
        if ent.AnimState and CheckAnims(ent.AnimState, {"idle_normal", "sway1_loop_normal"}) then
            return "TALL"
        end
    end

    -- 大理石灌木
    if ent.prefab == "marbleshrub" then
        return GetStateFromAnimConfig("marbleshrub", ent.AnimState)
    end

    -- 大理石树
    if ent.prefab and string.find(ent.prefab, "marbletree") then
        return "MARBLE_TREE"
    end

    -- 远古树
    if ent.prefab and string.find(ent.prefab, "ancienttree") then
        if string.find(ent.prefab, "sapling") then
            if ent:HasTag("seedstage")
                or (ent.AnimState and ent.AnimState:IsCurrentAnimation("idle_planted")) then
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

    -- 大理石豆苗
    if ent.prefab == "marblebean_sapling" then return "SEED" end

    -- 普通树苗
    if ent.prefab and string.find(ent.prefab, "sapling")
        and not string.find(ent.prefab, "dug_") then
        return "SAPLING"
    end

    -- 蘑菇树（按缩放判断大小）
    if ent:HasTag("mushtree") then
        local sx = ent.Transform:GetScale()
        if sx < 0.95 then return "SHORT" end
        if sx > 1.05 then return "TALL" end
        return "NORMAL"
    end

    return GetStateFromAnimConfig("tree", ent.AnimState)
end

-- 暖石温度状态
local function GetHeatrockStat(ent)
    if not ent or ent.prefab ~= "heatrock" or not ent.AnimState then return nil end
    local states = { 'COLD', 'COOL', 'NORMAL', 'WARM', 'HOT' }
    for i = 1, 5 do
        if ent.AnimState:IsCurrentAnimation(tostring(i)) then
            return states[i]
        end
    end
    return nil
end

-- 通用作物/采集物状态分发
local function GetGenericCropStat(entity)
    if entity:HasTag("farm_plant") then
        return GetCropStat(entity.AnimState)
    elseif entity.prefab == "waterplant" then
        return entity:HasTag("harvestable") and "WITH_BARNACLES" or "NO_BARNACLES"
    elseif entity.prefab == "saltstack" then
        return GetSaltStackStat(entity.AnimState)
    elseif entity.prefab == "marbleshrub" then
        return GetMarbleShrubStat(entity.AnimState)
    elseif entity:HasTag("beebox") then
        return GetBeeboxStat(entity.AnimState)
    elseif entity.prefab == "mushroom_farm" then
        return GetMushroomFarmStat(entity.AnimState)
    elseif entity.prefab == "tallbirdnest" then
        return entity:HasTag("pickable") and "NEST_HAS_EGG" or "NEST_EMPTY"
    elseif entity.prefab == "lureplant" then
        return GetLureplantStat(entity.AnimState)
    elseif BASIC_PICKABLES[entity.prefab] then
        return entity:HasTag("pickable") and "PICKABLE_READY" or "PICKABLE_EMPTY"
    end
    return nil
end

-- ============================================================================
-- [5] 核心宣告逻辑与 HUD 事件处理
-- ============================================================================

-- 默认阈值与徽章等级定义
local QA_DEFAULT_THRESHOLDS = { .15, .35, .55, .75 }
local QA_BADGE_LEVELS = { 'EMPTY', 'LOW', 'MID', 'HIGH', 'FULL' }

----------------------------------------
-- 5.1 外部模组 UI 处理（Insight & 勋章 Buff）
----------------------------------------

local function HandleExternalMods(HUD, status, widget)
    if not (widget and widget.widget) then return false end
    local w = widget.widget

    ---- Insight 面板宣告 ----
    local is_insight_menu = false
    local temp_w = w
    while temp_w do
        if HUD.controls and temp_w == HUD.controls.insight_menu then
            is_insight_menu = true
            break
        end
        temp_w = temp_w.parent
    end

    if is_insight_menu then
                local text_str = nil
                local comp_name = nil
                local item_detail = nil
                local curr = w

                -- 向上遍历查找文本内容和组件名
                while curr and curr ~= HUD.controls.insight_menu do
                    if curr.componentName then 
                        comp_name = curr.componentName 
                        item_detail = curr -- 保存找到的 Insight 项 UI 控件对象
                    end
                    if curr.data and curr.data.componentName then comp_name = curr.data.componentName end

                    if curr.raw_text and type(curr.raw_text) == "string" then
                        text_str = curr:GetString()
                        break
                    elseif curr.text and curr.text.GetString then
                        text_str = curr.text:GetString()
                        break
                    end
                    curr = curr.parent
                end

                if not text_str and w.GetString then
                    text_str = w:GetString()
                end

                if text_str and text_str ~= "" then
                    if item_detail and GLOBAL.Insight and GLOBAL.ThePlayer and GLOBAL.ThePlayer.replica.insight then
                        local cmp = (item_detail.componentData and item_detail.componentData.source_descriptor) or item_detail.componentName
                        if cmp then
                            local insight_rep = GLOBAL.ThePlayer.replica.insight
                            local special_data = insight_rep.world_data and insight_rep.world_data.special_data and insight_rep.world_data.special_data[item_detail.componentName]
                            
                            local describer = special_data and (
                                (special_data.prefably and GLOBAL.Insight.prefab_descriptors and GLOBAL.Insight.prefab_descriptors[cmp] and GLOBAL.Insight.prefab_descriptors[cmp].StatusAnnouncementsDescribe) or
                                (GLOBAL.Insight.descriptors and GLOBAL.Insight.descriptors[cmp] and GLOBAL.Insight.descriptors[cmp].StatusAnnouncementsDescribe)
                            )
                            
                            if describer then
                                return false
                            end
                        end
                    end

                    -- 提取图标/预制物代码
                    local raw_code = text_str:match("<icon=([^>]+)>") or text_str:match("<prefab=([^>]+)>")
            if not raw_code and comp_name then
                raw_code = string.gsub(comp_name, "spawner$", "")
                raw_code = string.gsub(raw_code, "manager$", "")
            end

            -- 查找本地化前缀
            local INSIGHT_CODE_MAP = LOCAL_STRINGS.INSIGHT_CODE_MAP or {}
            local prefix_name = ""
            if raw_code and INSIGHT_CODE_MAP[string.lower(raw_code)] then
                prefix_name = INSIGHT_CODE_MAP[string.lower(raw_code)] .. "："
            end

            local clean_info = CleanInsightString(text_str)

            -- 添加前缀（避免重复）
            if prefix_name ~= "" and not string.find(clean_info, INSIGHT_CODE_MAP[string.lower(raw_code)]) then
                clean_info = clean_info:gsub("^[ \t]+", "")
                clean_info = prefix_name .. clean_info
            end

            local debug_txt = raw_code and ("[代号: " .. raw_code .. "]") or nil
            return Announce(clean_info, nil, debug_txt, GetStatementLoc("MEDAL_BUFF", "INSIGHT"))
        end
    end

    ---- 勋章 Buff 宣告 ----
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
                return Announce(subfmt(qa.FORMATS.FOREVER, { BUFF_NAME = buff_name }), nil, nil, GetStatementLoc("MEDAL_BUFF", "FOREVER"))
            else
                return Announce(subfmt(qa.FORMATS.DEFAULT, {
                    BUFF_NAME = buff_name,
                    TIME = left_time
                }), nil, nil, GetStatementLoc("MEDAL_BUFF", "DEFAULT"))
            end
        end
    end

    return false
end

----------------------------------------
-- 5.2 皮弗娄牛状态栏处理
----------------------------------------

local function HandleBeefaloStats(HUD, status, widget)
    local b_hud = HUD.controls and HUD.controls.BeefaloStatusBar
    if not (b_hud and b_hud:IsVisible() and not b_hud.isHidden) then
        return false
    end

    local w = widget and widget.widget
    local target_badge = nil

    -- 向上查找匹配的徽章控件
    while w do
        if w == b_hud.healthBadge
            or w == b_hud.domesticationBadge
            or w == b_hud.obedienceBadge
            or w == b_hud.timerBadge
            or w == b_hud.hungerBadge then
            target_badge = w
            break
        end
        w = w.parent
    end

    if not target_badge then return false end

    local qa = GLOBAL.NOMU_QA.SCHEME.BEEFALO
    if not qa then return false end

    -- 生命值
    if target_badge == b_hud.healthBadge then
        local pct = target_badge.percent or 0
        local state = pct < 0.25 and 'HEALTH_LOW'
            or (pct > 0.8 and 'HEALTH_HIGH' or 'HEALTH_NORMAL')
        return Announce(subfmt(qa.FORMATS.HEALTH, {
            MESSAGE = subfmt(GetMapping(qa, 'MESSAGE', state), {
                PCT = math.floor(pct * 100 + 0.5)
            })
        }), nil, nil, GetStatementLoc("BEEFALO", "HEALTH"))

    -- 饥饿值
    elseif target_badge == b_hud.hungerBadge and b_hud.isHungerVisible then
        local val = tonumber(target_badge.num and target_badge.num:GetString() or "0") or 0
        local state = val < 50 and 'HUNGER_STARVING'
            or (val < 150 and 'HUNGER_HUNGRY'
            or (val > 300 and 'HUNGER_FULL' or 'HUNGER_NORMAL'))
        return Announce(subfmt(qa.FORMATS.HUNGER, {
            MESSAGE = subfmt(GetMapping(qa, 'MESSAGE', state), { VAL = val })
        }), nil, nil, GetStatementLoc("BEEFALO", "HUNGER"))

    -- 服从度
    elseif target_badge == b_hud.obedienceBadge then
        local pct = (target_badge.percent or 0) * 100
        local state = pct < 40 and 'OBEDIENCE_LOW'
            or (pct > 80 and 'OBEDIENCE_HIGH' or 'OBEDIENCE_NORMAL')
        return Announce(subfmt(qa.FORMATS.OBEDIENCE, {
            MESSAGE = subfmt(GetMapping(qa, 'MESSAGE', state), {
                PCT = math.floor(pct + 0.5)
            })
        }), nil, nil, GetStatementLoc("BEEFALO", "OBEDIENCE"))

    -- 驯化度
    elseif target_badge == b_hud.domesticationBadge then
        local pct = (target_badge.percent or 0) * 100
        local state = pct >= 100 and 'DOMESTICATION_FULL'
            or (pct > 90 and 'DOMESTICATION_HIGH'
            or (pct < 10 and 'DOMESTICATION_LOW' or 'DOMESTICATION_NORMAL'))
        local tendency_str = ""
        if b_hud.tendency then
            local t_name = GetMapping(qa, 'TENDENCY_NAME', b_hud.tendency) or b_hud.tendency
            tendency_str = " (趋势: " .. t_name .. ")"
        end
        return Announce(subfmt(qa.FORMATS.DOMESTICATION, {
            MESSAGE = subfmt(GetMapping(qa, 'MESSAGE', state), {
                PCT = string.format("%.1f", pct)
            }),
            TENDENCY = tendency_str
        }), nil, nil, GetStatementLoc("BEEFALO", "DOMESTICATION"))

    -- 骑乘计时器
    elseif target_badge == b_hud.timerBadge then
        local timeStr = target_badge.num and target_badge.num:GetString() or "0:00"
        local timeLeft = 999
        if b_hud.bucktime and b_hud.bucktime_start then
            timeLeft = math.floor(b_hud.bucktime_start + b_hud.bucktime - GLOBAL.GetTime())
        end
        local state = timeLeft < 30 and 'TIMER_LOW' or 'TIMER_RIDING'
        return Announce(subfmt(qa.FORMATS.TIMER, {
            MESSAGE = subfmt(GetMapping(qa, 'MESSAGE', state), { TIME = timeStr })
        }), nil, nil, GetStatementLoc("BEEFALO", "TIMER"))
    end

    return false
end

----------------------------------------
-- 5.3 玩家状态徽章处理
----------------------------------------

-- 玩家通用属性徽章配置定义
local BADGE_CONFIG_DEFS = {
    {
        btn_path = "pethungerbadge",
        comp_path = "pet_hunger_classified",
        qa = "WOBY_HUNGER",
        cur_fn = function(c) return c:GetPercent() * (c:Max() or 50) end,
        max_fn = function(c) return c:Max() or 50 end
    },
    {
        btn_path = "waterstomach",
        comp_path = "thirst",
        qa = "THIRST",
        cur_fn = function(c) return c:GetPercent() * (c:Max() or 100) end,
        max_fn = function(c) return c:Max() or 100 end
    },
    {
        btn_path = "stomach",
        comp_path = "player_classified",
        qa = "STOMACH",
        cur_fn = function(c) return c.currenthunger:value() end,
        max_fn = function(c) return c.maxhunger:value() end
    },
    {
        btn_path = "brain",
        comp_path = "player_classified",
        qa = "SANITY",
        cur_fn = function(c) return c.currentsanity:value() end,
        max_fn = function(c) return c.maxsanity:value() end
    },
    {
        btn_path = "heart",
        comp_path = "player_classified",
        qa = "HEALTH",
        thresholds = { .25, .5, .75, 1 },
        cur_fn = function(c) return c.currenthealth:value() end,
        max_fn = function(c) return c.maxhealth:value() end
    },
    {
        btn_path = "moisturemeter",
        comp_path = "player_classified",
        qa = "WETNESS",
        cur_fn = function(c) return c.moisture:value() end,
        max_fn = function(c) return c.maxmoisture:value() end
    },
    {
        btn_path = "wereness",
        comp_path = "player_classified",
        qa = "LOG_METER",
        thresholds = { .25, .5, .7, .9 },
        cur_fn = function(c) return c.currentwereness:value() end,
        max_fn = function(c) return 100 end
    },
    {
        btn_path = "fungusinfectionmeter",
        comp_path = "fungusinfection",
        qa = "FUNGUS_INFECTION",
        thresholds = { .25, .5, .75, 1 },
        cur_fn = function(c)
            local player = GLOBAL.ThePlayer
            if player.components.fungusinfection then
                return player.components.fungusinfection:GetFungusInfection()
            elseif player.player_classified and player.player_classified.fungusinfection then
                return player.player_classified.fungusinfection:value()
            end
            return 0
        end,
        max_fn = function(c) return 100 end
    }
}

local function HandlePlayerStats(HUD, status, widget)
    ---- 绽放值（Bloomness）----
    if status.bloombadge and status.bloombadge.focus
        and ThePlayer and ThePlayer.components._bloomness then

        local current = status.bloombadge.val or 0
        local max = status.bloombadge.max or 100
        local level = ThePlayer.components._bloomness:GetLevel()
        local stage = level

        -- 非开花状态下阶段偏移
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

        return Announce(subfmt(qa.FORMATS.DEFAULT, fmts), nil, nil, GetStatementLoc("BLOOMNESS", "DEFAULT"))
    end

    ---- 淘气值 ----
    if (status.naughtiness and status.naughtiness.focus)
        or (status.naughtybadge and status.naughtybadge.focus) then

        local current, max = 0, 50
        if status.naughtiness and status.naughtiness.num then
            local cur_str, max_str = string.match(
                status.naughtiness.num:GetString() or "",
                "(%d+)[ \t\r\n]*/[ \t\r\n]*(%d+)"
            )
            if cur_str and max_str then
                current, max = tonumber(cur_str), tonumber(max_str)
            end
        end

        if max > 0 then
            return AnnounceBadge(
                GLOBAL.NOMU_QA.SCHEME.NAUGHTINESS,
                current, max,
                QA_BADGE_LEVELS[get_category(QA_DEFAULT_THRESHOLDS, current / max)],
                "NAUGHTINESS"
            )
        end
    end

    ---- 幸运值 ----
    if (status.luck and status.luck.focus)
        or (status.luckbadge and status.luckbadge.focus) then

        return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.NAUGHTINESS.FORMATS.LUCK, {
            CURRENT = status.luck.num and status.luck.num:GetString() or "0.00"
        }), nil, nil, GetStatementLoc("NAUGHTINESS", "LUCK"))
    end

    ---- 遍历通用徽章配置进行宣告 ----
    for _, cfg in ipairs(BADGE_CONFIG_DEFS) do
        local btn = status[cfg.btn_path]
        local comp = nil
        if cfg.comp_path == "thirst" then
            comp = ThePlayer.replica.thirst
        elseif cfg.comp_path == "fungusinfection" then
            comp = ThePlayer.replica.fungusinfection
        else
            comp = ThePlayer[cfg.comp_path]
        end

        if btn and btn.focus and comp then
            local current = cfg.cur_fn(comp)
            local max = cfg.max_fn(comp)
            local category = QA_BADGE_LEVELS[
                get_category(cfg.thresholds or QA_DEFAULT_THRESHOLDS, current / max)
            ]

            -- WX-78 护盾特殊处理
            if cfg.qa == "HEALTH"
                and ThePlayer.prefab == "wx78"
                and ThePlayer.wx78_classified then

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

                    local fmt_key = qa.FORMATS.WITH_SHIELD and "WITH_SHIELD" or "DEFAULT"
                    return Announce(subfmt(
                        qa.FORMATS[fmt_key], fmts
                    ), nil, nil, GetStatementLoc(cfg.qa, fmt_key))
                end
            end

            return AnnounceBadge(GLOBAL.NOMU_QA.SCHEME[cfg.qa], current, max, category, cfg.qa)
        end
    end

    return false
end

----------------------------------------
-- 5.4 环境与时间信息处理
----------------------------------------

local function HandleEnvironmentAndTime(HUD, status, widget)
    ---- 人物体温 ----
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

        return Announce(subfmt(qa.FORMATS.DEFAULT, fmts), nil, nil, GetStatementLoc("TEMPERATURE", "DEFAULT"))
    end

    ---- 世界温度 & 季节 ----
    local is_worldtemp_focus = status.worldtemp and status.worldtemp.focus
    local is_season_focus = (HUD.controls.seasonclock and HUD.controls.seasonclock.focus)
        or (status.season and status.season.focus)

    if is_worldtemp_focus or is_season_focus then
        local raw_season = TheWorld.state.season:upper()
        local SEASON = GetMapping(GLOBAL.NOMU_QA.SCHEME.SEASON, 'SEASON_NAMES', raw_season)
            or GLOBAL.STRINGS.UI.SERVERLISTINGSCREEN.SEASONS[raw_season]
            or raw_season

        -- 世界温度 + 降雨预测
        if is_worldtemp_focus then
            local qa = GLOBAL.NOMU_QA.SCHEME.WORLD_TEMPERATURE_AND_RAIN
            local display_temp = math.floor(TheWorld.state.temperature + 0.5) .. "°"
            if status.worldtemp and status.worldtemp.num and status.worldtemp.num:GetString() then
                display_temp = status.worldtemp.num:GetString()
            end

            local px, py, pz = ThePlayer.Transform:GetWorldPosition()
            local is_winterland = TheWorld.components.winterlands_manager
                and TheWorld.components.winterlands_manager:IsWinterlandsAtPoint(px, py, pz)

            local world_name = is_winterland and GetMapping(qa, 'WORLD', 'WINTERLAND') or GetMapping(qa, 'WORLD', GLOBAL.QA_UTILS.GetWorldType())
            local is_bwb_cave = TheWorld:HasTag("cave") and (raw_season == "TRANQUIL" or raw_season == "FROST" or raw_season == "VERDANT" or raw_season == "UMBRAL")

            if is_bwb_cave then
                local rain_status = ""
                if TheWorld.state.pop ~= 1 then
                    local _, total_seconds, rain = GLOBAL.QA_UTILS.PredictRainStart()
                    if rain then
                        local d, m, s = GLOBAL.QA_UTILS.FormatSeconds(total_seconds)
                        rain_status = subfmt(GetMapping(qa, 'BWB_WORDS', 'RAIN_APPROACH'), { DAYS = d, MINUTES = m, SECONDS = s })
                    else
                        rain_status = GetMapping(qa, 'BWB_WORDS', 'RAIN_NONE')
                    end
                else
                    local _, total_seconds = GLOBAL.QA_UTILS.PredictRainStop()
                    local d, m, s = GLOBAL.QA_UTILS.FormatSeconds(total_seconds)
                    rain_status = subfmt(GetMapping(qa, 'BWB_WORDS', 'RAIN_STOP'), { DAYS = d, MINUTES = m, SECONDS = s })
                end

                local fog_status = ""
                local is_fungusfog_active, fungusfog_cd = GLOBAL.QA_UTILS.PredictFungusFog()

                if is_fungusfog_active then
                    fog_status = GetMapping(qa, 'BWB_WORDS', 'FOG_ACTIVE')
                elseif raw_season == "VERDANT" and fungusfog_cd > 0 then
                    local d, m, s = GLOBAL.QA_UTILS.FormatSeconds(fungusfog_cd)
                    fog_status = subfmt(GetMapping(qa, 'BWB_WORDS', 'FOG_APPROACH'), { DAYS = d, MINUTES = m, SECONDS = s })
                else
                    fog_status = GetMapping(qa, 'BWB_WORDS', 'FOG_NONE')
                end

                return Announce(subfmt(qa.FORMATS.BWB_CAVE_WEATHER, {
                    WORLD = world_name,
                    TEMPERATURE = display_temp,
                    FOG_STATUS = fog_status,
                    RAIN_STATUS = rain_status
                }), nil, nil, GetStatementLoc("WORLD_TEMPERATURE_AND_RAIN", "BWB_CAVE_WEATHER"))
            else
                local fmts = {
                    TEMPERATURE = display_temp,
                    SEASON = SEASON,
                    WEATHER = GetMapping(qa, 'WEATHER', raw_season) or "异常天气",
                    WORLD = world_name
                }
                local qa_fmt = qa.FORMATS.NO_RAIN
                local fmt_key = "NO_RAIN"

                if TheWorld.state.pop ~= 1 then
                    local world, total_seconds, rain = GLOBAL.QA_UTILS.PredictRainStart()
                    fmts.WORLD = is_winterland and GetMapping(qa, 'WORLD', 'WINTERLAND') or GetMapping(qa, 'WORLD', world)
                    if rain then
                        fmts.DAYS, fmts.MINUTES, fmts.SECONDS = GLOBAL.QA_UTILS.FormatSeconds(total_seconds)
                        qa_fmt = qa.FORMATS.START_RAIN
                        fmt_key = "START_RAIN"
                    end
                else
                    local world, total_seconds = GLOBAL.QA_UTILS.PredictRainStop()
                    fmts.WORLD = is_winterland and GetMapping(qa, 'WORLD', 'WINTERLAND') or GetMapping(qa, 'WORLD', world)
                    fmts.DAYS, fmts.MINUTES, fmts.SECONDS = GLOBAL.QA_UTILS.FormatSeconds(total_seconds)
                    qa_fmt = qa.FORMATS.STOP_RAIN
                    fmt_key = "STOP_RAIN"
                end

                return Announce(subfmt(qa_fmt, fmts), nil, nil, GetStatementLoc("WORLD_TEMPERATURE_AND_RAIN", fmt_key))
            end
        end

        -- 季节剩余天数
        if is_season_focus then
            local DAYS_LEFT = TheWorld.state.remainingdaysinseason
            if DAYS_LEFT == 10000 then DAYS_LEFT = "∞" end
            return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.SEASON.FORMATS.DEFAULT, {
                SEASON = SEASON,
                DAYS_LEFT = DAYS_LEFT
            }), nil, nil, GetStatementLoc("SEASON", "DEFAULT"))
        end
    end

    ---- 月相宣告 ----
    if HUD.controls.clock
        and HUD.controls.clock._moonanim
        and HUD.controls.clock._moonanim.focus then

        local qa = GLOBAL.NOMU_QA.SCHEME.MOON_PHASE
        local cur_moonphase = TheWorld.state.moonphase
        local is_waxing = TheWorld.state.iswaxingmoon
        local cycles = TheWorld.state.cycles

        if not cur_moonphase then return false end

        --  优先处理今晚就是月圆或月黑
        if cur_moonphase == "full" or cur_moonphase == "new" then
            local phase_key = (cur_moonphase == "full") and "FULL" or "NEW"
            local fmts = {
                RECENT = GetMapping(qa, 'RECENT', 'TODAY'),
                PHASE1 = GetMapping(qa, 'MOON', phase_key),
            }
            return Announce(subfmt(qa.FORMATS.MOON, fmts), nil, nil, GetStatementLoc("MOON_PHASE", "MOON"))
        end

        local moon_data = GLOBAL.NOMU_QA and GLOBAL.NOMU_QA.MOON_DATA
        if not (moon_data and moon_data.is_confident and moon_data.last_phase == cur_moonphase) then
            if ThePlayer and ThePlayer.components.talker then
                local failed_msg = (qa.FORMATS and qa.FORMATS.FAILED)
                    or (GLOBAL.STRINGS.DEFAULT_NOMU_QA.MOON_PHASE.FORMATS.FAILED)
                ThePlayer.components.talker:Say(failed_msg)
            end
            return true
        end

        local phase_durations = { quarter = 3, half = 3, threequarter = 3 }
        local total_len = phase_durations[cur_moonphase] or 3
        local elapsed = math.max(0, cycles - (moon_data.phase_start_cycle or 0))
        local remaining_in_cur_phase = math.max(1, total_len - elapsed)

        local days_to_full = 0
        local days_to_new = 0

        if is_waxing then
            if cur_moonphase == "threequarter" then
                days_to_full = remaining_in_cur_phase
            elseif cur_moonphase == "half" then
                days_to_full = remaining_in_cur_phase + 3
            elseif cur_moonphase == "quarter" then
                days_to_full = remaining_in_cur_phase + 6
            end
            days_to_new = days_to_full + 10
        else
            if cur_moonphase == "threequarter" then
                days_to_new = remaining_in_cur_phase + 6
            elseif cur_moonphase == "half" then
                days_to_new = remaining_in_cur_phase + 3
            elseif cur_moonphase == "quarter" then
                days_to_new = remaining_in_cur_phase
            end
            days_to_full = days_to_new + 10
        end

        local target_phase_is_full = (days_to_full <= days_to_new)
        local target_days = target_phase_is_full and days_to_full or days_to_new
        local target_key = target_phase_is_full and "FULL" or "NEW"     -- 下一个目标月相
        local past_key = target_phase_is_full and "NEW" or "FULL"       -- 刚度过的上一个月相

        local fmts = {
            INTERVAL = GetMapping(qa, 'INTERVAL', 'COMMA'),
            PHASE2 = GetMapping(qa, 'MOON', target_key),
            LEFT = target_days,
        }

        if target_days == 1 then
            fmts.RECENT = GetMapping(qa, 'RECENT', 'TOMORROW')
            fmts.PHASE1 = GetMapping(qa, 'MOON', target_key)
            return Announce(subfmt(qa.FORMATS.MOON, fmts), nil, nil, GetStatementLoc("MOON_PHASE", "MOON"))

        elseif target_days >= 8 then
            fmts.RECENT = GetMapping(qa, 'RECENT', 'AFTER')
            fmts.PHASE1 = GetMapping(qa, 'MOON', past_key)
            return Announce(subfmt(qa.FORMATS.DEFAULT, fmts), nil, nil, GetStatementLoc("MOON_PHASE", "DEFAULT"))

        else
            fmts.RECENT = ''
            fmts.PHASE1 = ''
            fmts.INTERVAL = GetMapping(qa, 'INTERVAL', 'NONE')
            return Announce(subfmt(qa.FORMATS.DEFAULT, fmts), nil, nil, GetStatementLoc("MOON_PHASE", "DEFAULT"))
        end
    end

    ---- 时钟宣告 ----
    if HUD.controls.clock and HUD.controls.clock.focus then
        local clock = TheWorld.net.components.clock
        if clock and clock._remainingtimeinphase and clock._phase and clock.CalcRemainTimeOfDay then
            local qa = GLOBAL.NOMU_QA.SCHEME.CLOCK
            local phases = { 'DAY', 'DUSK', 'NIGHT' }

            -- 时间格式化辅助函数
            local function _fmt_time(secs)
                local m = math.modf(secs / 60)
                local s = math.modf(math.fmod(secs, 60))
                return (m > 0 and (m .. GetMapping(qa, 'TIME', 'MINUTES')) or '')
                    .. s .. GetMapping(qa, 'TIME', 'SECONDS')
            end

            local fmt = qa.FORMATS.DEFAULT
            local fmt_key = "DEFAULT"
            local fmts = {
                PHASE = GetMapping(qa, 'PHASE', phases[clock._phase:value()]),
                PHASE_REMAIN = _fmt_time(clock._remainingtimeinphase:value()),
                DAY_REMAIN = _fmt_time(clock.CalcRemainTimeOfDay())
            }

            -- 噩梦循环特殊处理
            if TheWorld.GetNightmareData then
                local data = TheWorld:GetNightmareData()
                if data.remain == 0 and data.total ~= 0 then
                    fmt = qa.FORMATS.NIGHTMARE_LOCK
                    fmt_key = "NIGHTMARE_LOCK"
                else
                    fmt = qa.FORMATS.NIGHTMARE
                    fmt_key = "NIGHTMARE"
                end
                fmts.NIGHTMARE = GetMapping(qa, 'NIGHTMARE', data.phase:upper())
                fmts.REMAIN = _fmt_time(data.remain)
                fmts.TOTAL = _fmt_time(data.total)
            end

            return Announce(subfmt(fmt, fmts), nil, nil, GetStatementLoc("CLOCK", fmt_key))
        end
    end

    return false
end

----------------------------------------
-- 5.5 特殊机制处理（船、阿比盖尔、力量、灵感、电路）
----------------------------------------

local function HandleSpecificMechanics(HUD, status, widget)
    ---- 船只耐久 ----
    if status.boatmeter and status.boatmeter.focus then
        local qa = GLOBAL.NOMU_QA.SCHEME.BOAT
        local max = status.boatmeter.boat.components.healthsyncer.max_health
        local current = status.boatmeter.boat.components.healthsyncer:GetPercent() * max
        local idx = math.floor(current / (max / 5 + 1)) + 1

        return Announce(subfmt(qa.FORMATS.DEFAULT, {
            CURRENT = math.floor(current + 0.5),
            MAX = max,
            MESSAGE = GetMapping(qa, 'MESSAGE', QA_BADGE_LEVELS[idx])
        }), nil, nil, GetStatementLoc("BOAT", "DEFAULT"))
    end

    ---- 阿比盖尔生命 ----
    if status.pethealthbadge and status.pethealthbadge.focus and status.pethealthbadge.nomu_max then
        local max = status.pethealthbadge.nomu_max
        local current = status.pethealthbadge.nomu_percent * max
        return AnnounceBadge(
            GLOBAL.NOMU_QA.SCHEME.ABIGAIL,
            current, max,
            QA_BADGE_LEVELS[math.floor(current / (max / 5 + 1)) + 1],
            "ABIGAIL"
        )
    end

    ---- 力量值（沃尔夫冈）----
    if status.mightybadge and status.mightybadge.focus and status.mightybadge.nomu_percent then
        local max = status.mightybadge.nomu_max or 100
        local current = status.mightybadge.nomu_percent * max
        local idx = current >= TUNING.MIGHTY_THRESHOLD and 3
            or (current >= TUNING.WIMPY_THRESHOLD and 2 or 1)
        local mighty_states = { 'WIMPY', 'NORMAL', 'MIGHTY' }
        return AnnounceBadge(GLOBAL.NOMU_QA.SCHEME.MIGHTINESS, current, max, mighty_states[idx], "MIGHTINESS")
    end

    ---- 灵感值（薇格弗德）----
    if status.inspirationbadge and status.inspirationbadge.focus and status.inspirationbadge.nomu_percent then
        local max = status.inspirationbadge.nomu_max or 100
        local pct = status.inspirationbadge.nomu_percent
        local idx = pct >= TUNING.BATTLESONG_THRESHOLDS[3] and 4
            or (pct >= TUNING.BATTLESONG_THRESHOLDS[2] and 3
            or (pct >= TUNING.BATTLESONG_THRESHOLDS[1] and 2 or 1))
        return AnnounceBadge(GLOBAL.NOMU_QA.SCHEME.INSPIRATION, pct * max, max, QA_BADGE_LEVELS[idx], "INSPIRATION")
    end

    ---- WX-78 电路模块 ----
    if HUD.controls.secondary_status
        and HUD.controls.secondary_status.upgrademodulesdisplay
        and HUD.controls.secondary_status.upgrademodulesdisplay.focus then

        local qa = GLOBAL.NOMU_QA.SCHEME.ENERGY
        local module_display = HUD.controls.secondary_status.upgrademodulesdisplay
        local current = module_display.energy_level or 0
        local energy_levels = { 'ZERO', 'ONE', 'TWO', 'THREE', 'FOUR', 'FIVE', 'SIX' }

        -- 计算已用插槽数
        local used_slots = 0
        if module_display.chip_slotsinuse then
            for _, v in pairs(module_display.chip_slotsinuse) do
                used_slots = used_slots + (tonumber(v) or 0)
            end
        else
            used_slots = module_display.slots_in_use or 0
        end

        -- 计算模块显示区域的边界，判断鼠标是否在电路区域
        local min_x, max_x = math.huge, -math.huge
        local function find_bounds(w)
            if not w or not w.GetWorldPosition then return end
            local px = w:GetWorldPosition().x
            if px < min_x then min_x = px end
            if px > max_x then max_x = px end
            if w.children then
                for _, child in pairs(w.children) do find_bounds(child) end
            end
        end
        find_bounds(module_display)

        local mx = GLOBAL.TheInput:GetScreenPosition().x
        local is_circuit_area = false
        if min_x < max_x then
            if mx < min_x + (max_x - min_x) * 0.90 then is_circuit_area = true end
        else
            if mx < module_display:GetWorldPosition().x - 20 then is_circuit_area = true end
        end

        -- 在电路区域内：列出所有已安装模块
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
                                if def then counts[def.name] = (counts[def.name] or 0) + 1 end
                            end
                        end
                    end
                end
            end

            local modules_str_list = {}
            for modname, count in pairs(counts) do
                local loc_name = GLOBAL.STRINGS.NAMES['WX78MODULE_' .. string.upper(modname)] or modname
                table.insert(modules_str_list, subfmt(
                    qa.FORMATS.CHIP or "{NUM}个{ITEM}",
                    { ITEM = loc_name, NUM = count }
                ))
            end

            if #modules_str_list > 0 then
                return Announce(subfmt(qa.FORMATS.ALL_MODULES, {
                    MODULES = table.concat(modules_str_list, "，")
                }), nil, nil, GetStatementLoc("ENERGY", "ALL_MODULES"))
            else
                return Announce(qa.FORMATS.NO_MODULES, nil, nil, GetStatementLoc("ENERGY", "NO_MODULES"))
            end

        -- 不在电路区域：宣告电量等级
        else
            return Announce(subfmt(qa.FORMATS.DEFAULT, {
                CURRENT = math.floor(current + 0.5),
                MAX = module_display.max_energy or TUNING.WX78_MAXELECTRICCHARGE or 6,
                USED = used_slots,
                MESSAGE = GetMapping(qa, 'MESSAGE',
                    energy_levels[math.min(math.max(math.floor(current) + 1, 1), 7)]
                )
            }), nil, nil, GetStatementLoc("ENERGY", "DEFAULT"))
        end
    end

    return false
end

----------------------------------------
-- 5.6 烹饪锅料理处理
----------------------------------------

local function HandleCooking(HUD, status, widget)
    if HUD.controls and HUD.controls.foodcrafting and HUD.controls.foodcrafting.focus
        and HUD.controls.foodcrafting.focusItem and HUD.controls.foodcrafting.focusItem.focus then

        local qa = GLOBAL.NOMU_QA.SCHEME.COOK
        local recipe = HUD.controls.foodcrafting.focusItem.recipe
        local popup = HUD.controls.foodcrafting.focusItem.recipepopup
        local name = LOCAL_STRINGS[string.upper(recipe.name)]
            or GLOBAL.STRINGS.NAMES[string.upper(recipe.name)]
            or recipe.name

        -- 弹窗内具体数值宣告
        if popup and popup.focus then
            local fmts = { TYPE = GetMapping(qa, 'TYPE', 'POS'), NAME = name }
            local fmt, value, fmt_key

            if popup.health and popup.health.focus then
                value = recipe.health; fmt = qa.FORMATS.HEALTH; fmt_key = "HEALTH"
            end
            if popup.sanity and popup.sanity.focus then
                value = recipe.sanity; fmt = qa.FORMATS.SANITY; fmt_key = "SANITY"
            end
            if popup.hunger and popup.hunger.focus then
                value = recipe.hunger; fmt = qa.FORMATS.HUNGER; fmt_key = "HUNGER"
            end

            if value then
                if type(value) == 'number' and value < 0 then
                    fmts.TYPE = GetMapping(qa, 'TYPE', 'NEG')
                    value = -value
                end
                fmts.VALUE = not recipe.unlocked and '?'
                    or (type(value) == 'number' and value ~= 0
                        and string.format("%g", (math.floor(value * 10 + 0.5) / 10))
                        or '-')
                return Announce(subfmt(fmt, fmts), nil, nil, GetStatementLoc("COOK", fmt_key))
            end

            -- 料理名称焦点：宣告完整三维数值
            if popup.name and popup.name.focus and popup.hunger and popup.sanity and popup.health then
                return Announce(subfmt(qa.FORMATS.FOOD, {
                    NAME = name,
                    HUNGER = popup.hunger:GetString(),
                    SANITY = popup.sanity:GetString(),
                    HEALTH = popup.health:GetString()
                }), nil, nil, GetStatementLoc("COOK", "FOOD"))
            end

            -- 食材焦点
            if popup.ingredients then
                for _, ingredient in ipairs(popup.ingredients) do
                    if ingredient.focus then
                        local ing_fmt = ingredient.is_min and 'MIN_INGREDIENT'
                            or (ingredient.quantity > 0 and 'MAX_INGREDIENT' or 'ZERO_INGREDIENT')
                        return Announce(subfmt(qa.FORMATS[ing_fmt], {
                            NAME = name,
                            INGREDIENT = ingredient.localized_name,
                            NUM = ingredient.quantity
                        }), nil, nil, GetStatementLoc("COOK", ing_fmt))
                    end
                end
            end

        -- 未打开弹窗：宣告可否制作
        else
            local can_cook = (recipe.readytocook or recipe.reqsmatch) and recipe.unlocked
            return Announce(subfmt(
                can_cook and qa.FORMATS.CAN or qa.FORMATS.NEED,
                { NAME = name }
            ), nil, nil, GetStatementLoc("COOK", can_cook and "CAN" or "NEED"))
        end
    end

    return false
end

----------------------------------------
-- 5.7 HUD 鼠标点击事件分发
----------------------------------------

-- HUD 点击处理器优先级列表
local HUD_CLICK_HANDLERS = {
    HandleExternalMods,
    HandlePlayerStats,
    HandleBeefaloStats,
    HandleEnvironmentAndTime,
    HandleSpecificMechanics,
    HandleCooking
}

-- HUD 鼠标点击总入口
local function OnHUDMouseButton(HUD)
    local status = HUD.controls and HUD.controls.status
    local widget = GLOBAL.TheInput:GetHUDEntityUnderMouse()

    if GLOBAL.NOMU_QA.DATA.DEBUG_MODE and widget and widget.widget then
        CURRENT_HUD_DEBUG_STR = GLOBAL.NOMU_QA.GetUIDebugString(widget, status, HUD.controls)
        
        -- 利用零延迟任务判定 UI 点击是否被拦截
        if GLOBAL.ThePlayer then
            GLOBAL.ThePlayer:DoTaskInTime(0, function()
                if CURRENT_HUD_DEBUG_STR then
                    print("[NOMU_QA 未适配UI] " .. CURRENT_HUD_DEBUG_STR)
                    CURRENT_HUD_DEBUG_STR = nil
                end
            end)
        end
    else
        CURRENT_HUD_DEBUG_STR = nil
    end

    -- 执行实际的宣告点击分发
    for _, handler in ipairs(HUD_CLICK_HANDLERS) do
        if handler(HUD, status, widget) then
            CURRENT_HUD_DEBUG_STR = nil
            return true
        end
    end

    return false
end
-- ============================================================================
-- [6] 物品配方、容器与制作栏相关方法
-- ============================================================================

----------------------------------------
-- 6.1 配方材料反查与缺失计算
----------------------------------------

-- 根据焦点索引反查配方中对应的材料类型
local function GetFocusedIngredientType(recipe, focused_index)
    if not recipe or not focused_index then return nil end

    local all_reqs = {}

    -- 科技材料
    if recipe.tech_ingredients then
        for _, v in ipairs(recipe.tech_ingredients) do
            if v.type:sub(-9) == "_material" then
                table.insert(all_reqs, v.type)
            end
        end
    end

    -- 普通材料
    if recipe.ingredients then
        for _, v in ipairs(recipe.ingredients) do
            table.insert(all_reqs, v.type)
        end
    end

    -- 角色专属材料
    if recipe.character_ingredients then
        for _, v in ipairs(recipe.character_ingredients) do
            table.insert(all_reqs, v.type)
        end
    end

    return all_reqs[focused_index]
end

-- 获取配方所需原型机/科技名称
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

-- 获取配方所有缺失材料的描述字符串
local function GetAllMissingIngredients(recipe, builder, inventory)
    if not recipe then return nil end

    local missing = {}

    -- 检查普通材料
    if recipe.ingredients then
        for _, v in pairs(recipe.ingredients) do
            local is_catalyst = (v.amount == 0)
            local actual_needed = is_catalyst and 1
                or RoundBiasedUp(v.amount * builder:IngredientMod())

            local _, num_found = inventory:Has(v.type, actual_needed, true)
            if num_found < actual_needed then
                local diff = actual_needed - num_found
                local item_name = LOCAL_STRINGS[string.upper(v.type)]
                    or GLOBAL.STRINGS.NAMES[string.upper(v.type)]
                    or v.type
                if is_catalyst then
                    table.insert(missing, item_name)
                else
                    table.insert(missing, diff .. "个" .. item_name)
                end
            end
        end
    end

    -- 检查角色专属材料
    if recipe.character_ingredients then
        for _, v in pairs(recipe.character_ingredients) do
            local is_catalyst = (v.amount == 0)
            local actual_needed = is_catalyst and 1 or v.amount

            local _, num_found = builder:HasCharacterIngredient(v)
            if num_found < actual_needed then
                local diff = actual_needed - num_found
                local item_name = LOCAL_STRINGS[string.upper(v.type)]
                    or GLOBAL.STRINGS.NAMES[string.upper(v.type)]
                    or v.type
                if is_catalyst then
                    table.insert(missing, item_name)
                else
                    table.insert(missing, diff .. "个" .. item_name)
                end
            end
        end
    end

    return #missing > 0 and table.concat(missing, ", ") or nil
end

----------------------------------------
-- 6.2 配方宣告核心函数
----------------------------------------

-- 统一的配方宣告入口
local function AnnounceMergedRecipe(recipe, builder, inventory, owner, specific_ingredient_type)
    if not recipe then return end

    local buffered = builder:IsBuildBuffered(recipe.name)
    local knows = builder:KnowsRecipe(recipe.name)
        or CanPrototypeRecipe(recipe.level, builder:GetTechTrees())
    local can_build = builder:CanBuild(recipe.name)

    -- 获取本地化名称
    local upper_override = recipe.nameoverride and string.upper(recipe.nameoverride) or nil
    local upper_name = recipe.name and string.upper(recipe.name) or nil
    local upper_product = recipe.product and string.upper(recipe.product) or nil

    local strings_name = (upper_override and (LOCAL_STRINGS[upper_override] or GLOBAL.STRINGS.NAMES[upper_override]))
        or (upper_name and (LOCAL_STRINGS[upper_name] or GLOBAL.STRINGS.NAMES[upper_name]))
        or (upper_product and (LOCAL_STRINGS[upper_product] or GLOBAL.STRINGS.NAMES[upper_product]))

    local name = strings_name and strings_name:lower() or LOCAL_STRINGS.UNKNOWN_NAME
    name = ApplyCustomName(recipe.nameoverride or recipe.name or recipe.product, name)

    local prototype, raw_tech = GetPrototype(knows, recipe, owner)

    -- 构建调试信息
    local debug_str = string.format("[配方代码: %s]", tostring(recipe.name))
    if raw_tech and raw_tech ~= "" then
        debug_str = debug_str .. string.format(" [科技代码: %s]", string.lower(tostring(raw_tech)))
    end

    local qa_recipe = GLOBAL.NOMU_QA.SCHEME.RECIPE
    local qa_const = GLOBAL.NOMU_QA.SCHEME.CONSTRUCTION_AND_TRADE

    -- 已缓存制作
    if buffered then
        return Announce(subfmt(qa_recipe.FORMATS.BUFFERED, {
            ITEM = name, PROTOTYPE = prototype
        }), nil, debug_str, GetStatementLoc("RECIPE", "BUFFERED"))
    end

    -- 点击了特定材料：只宣告该材料的拥有/缺失情况
    if specific_ingredient_type then
        local amount_needed, num_found = 1, 0
        local is_catalyst = false

        -- 在普通材料中查找
        for _, v in pairs(recipe.ingredients) do
            if specific_ingredient_type == v.type then
                amount_needed = v.amount
                if v.amount == 0 then is_catalyst = true end
            end
        end

        local actual_needed = is_catalyst and 1
            or RoundBiasedUp(amount_needed * builder:IngredientMod())
        _, num_found = inventory:Has(specific_ingredient_type, actual_needed, true)

        -- 在角色材料中查找
        if recipe.character_ingredients then
            for _, v in pairs(recipe.character_ingredients) do
                if specific_ingredient_type == v.type then
                    amount_needed = v.amount
                    is_catalyst = (v.amount == 0)
                    actual_needed = is_catalyst and 1 or v.amount
                    _, num_found = builder:HasCharacterIngredient(v)
                end
            end
        end

        -- 科技材料特殊处理
        if specific_ingredient_type:sub(-9) == "_material" then
            is_catalyst = true
            actual_needed = 1
            local is_unlocked = builder:KnowsRecipe(recipe.name)
                or CanPrototypeRecipe(recipe.level, builder:GetTechTrees())
            num_found = is_unlocked and 1 or 0
        end

        local num_missing = actual_needed - num_found
        local ingredient_name = LOCAL_STRINGS[specific_ingredient_type:upper()]
            or GLOBAL.STRINGS.NAMES[specific_ingredient_type:upper()]
            or specific_ingredient_type

        -- 科技材料名称映射
        if specific_ingredient_type:sub(-9) == "_material"
            and qa_recipe.MAPPINGS
            and qa_recipe.MAPPINGS.DEFAULT
            and qa_recipe.MAPPINGS.DEFAULT.PROTOTYPER then
            ingredient_name = qa_recipe.MAPPINGS.DEFAULT.PROTOTYPER[
                specific_ingredient_type:upper()
            ] or ingredient_name
        end

        local fmts = {
            RECIPE = name,
            AND_PROTOTYPE = prototype ~= ""
                and subfmt(GetMapping(qa_const, 'WORDS', 'AND_PROTOTYPE'), { PROTOTYPE = prototype })
                or "",
            BUT_PROTOTYPE = prototype ~= ""
                and subfmt(GetMapping(qa_const, 'WORDS', 'BUT_PROTOTYPE'), { PROTOTYPE = prototype })
                or ""
        }

        local amount_fmt = GetMapping(qa_const, 'WORDS', 'AMOUNT_FMT')

        if num_missing <= 0 then
            -- 材料充足
            fmts.INGREDIENT = ingredient_name
            
            if is_catalyst then
                return Announce(subfmt(qa_const.FORMATS.CRAFT_HAVE_CATALYST, fmts), nil, debug_str, GetStatementLoc("CONSTRUCTION_AND_TRADE", "CRAFT_HAVE_CATALYST"))
            else
                local craft_count = actual_needed > 0 and math.floor(num_found / actual_needed) or 1
                fmts.TOTAL_NUM = num_found
                fmts.REQ_NUM = actual_needed
                fmts.CRAFT_COUNT = craft_count
                
                return Announce(subfmt(qa_const.FORMATS.CRAFT_HAVE, fmts), nil, debug_str, GetStatementLoc("CONSTRUCTION_AND_TRADE", "CRAFT_HAVE"))
            end
        else
            -- 材料不足
            if not GLOBAL.NOMU_QA.DATA.ANNOUNCE_ALL_MISSING_INGREDIENTS then
                if is_catalyst then
                    fmts.INGREDIENT = ingredient_name
                else
                    fmts.INGREDIENT = subfmt(amount_fmt, { NUM = num_missing, ITEM = ingredient_name })
                end
                return Announce(subfmt(qa_const.FORMATS.CRAFT_NEED, fmts), nil, debug_str, GetStatementLoc("CONSTRUCTION_AND_TRADE", "CRAFT_NEED"))
            end
        end
    end

    -- 可以直接制作
    if can_build and knows then
        return Announce(subfmt(qa_recipe.FORMATS.WILL_MAKE, {
            ITEM = name, PROTOTYPE = prototype
        }), nil, debug_str, GetStatementLoc("RECIPE", "WILL_MAKE"))
    end

    -- 简单宣告（不列出所有缺失材料）
    if not GLOBAL.NOMU_QA.DATA.ANNOUNCE_ALL_MISSING_INGREDIENTS and not specific_ingredient_type then
        local fmt_key = knows and "WE_NEED" or "CAN_SOMEONE"
        return Announce(subfmt(
            qa_recipe.FORMATS[fmt_key],
            { ITEM = name, PROTOTYPE = prototype }
        ), nil, debug_str, GetStatementLoc("RECIPE", fmt_key))
    end

    -- 完整缺失材料宣告
    local missing_str = GetAllMissingIngredients(recipe, builder, inventory)
    local and_proto = prototype ~= ""
        and subfmt(GetMapping(qa_const, 'WORDS', 'AND_PROTOTYPE'), { PROTOTYPE = prototype })
        or ""
    local but_proto = prototype ~= ""
        and subfmt(GetMapping(qa_const, 'WORDS', 'BUT_PROTOTYPE'), { PROTOTYPE = prototype })
        or ""

    if missing_str then
        return Announce(subfmt(qa_const.FORMATS.CRAFT_NEED, {
            INGREDIENT = missing_str,
            RECIPE = name,
            AND_PROTOTYPE = and_proto
        }), nil, debug_str, GetStatementLoc("CONSTRUCTION_AND_TRADE", "CRAFT_NEED"))
    else
        return Announce(subfmt(qa_const.FORMATS.CRAFT_HAVE_ALL, {
            RECIPE = name,
            BUT_PROTOTYPE = but_proto
        }), nil, debug_str, GetStatementLoc("CONSTRUCTION_AND_TRADE", "CRAFT_HAVE_ALL"))
    end
end

----------------------------------------
-- 6.3 物品数量统计与容器遍历
----------------------------------------

-- 预制物别名映射
local ITEM_PREFAB_ALIAS = {
    driftwood_small1 = "driftwood_small1",
    driftwood_tall   = "driftwood_small1",
    driftwood_small2 = "driftwood_small1",
    boatfragment03   = "boatfragment03",
    boatfragment04   = "boatfragment03",
    boatfragment05   = "boatfragment03",
    deer_antler1     = "deer_antler",
    deer_antler2     = "deer_antler",
    deer_antler3     = "deer_antler"
}

-- 可充能物品的冷却时间表
local RECHARGEABLE_PREFABS = {
    wurt_swampitem_shadow = TUNING.WURT_TERRAFORMING_RECHARGE_TIME,
    wurt_swampitem_lunar  = TUNING.WURT_TERRAFORMING_RECHARGE_TIME,
    shadow_beef_bell      = TUNING.SHADOW_BEEF_BELL_REVIVE_COOLDOWN,
    pocketwatch_heal      = TUNING.POCKETWATCH_HEAL_COOLDOWN,
    pocketwatch_revive    = TUNING.POCKETWATCH_REVIVE_COOLDOWN,
    pocketwatch_warp      = TUNING.POCKETWATCH_WARP_COOLDOWN,
    pocketwatch_recall    = TUNING.POCKETWATCH_RECALL_COOLDOWN,
    pocketwatch_portal    = TUNING.POCKETWATCH_RECALL_COOLDOWN
}

-- 单个物品匹配检查
local function check_item(v, name, target_prefab, use_alias)
    if v then
        if name == nil or v:GetDisplayName() == name then
            if (use_alias and ITEM_PREFAB_ALIAS[v.prefab] == target_prefab)
                or (not use_alias and v.prefab == target_prefab) then
                return v.replica.stackable and v.replica.stackable:StackSize() or 1
            end
        end
    end
    return 0
end

-- 递归统计容器内指定物品数量
local function CountItems(container, name, target_prefab, use_alias)
    local num_found = 0
    if not container then return 0 end

    -- 普通物品栏
    if container.GetItems then
        local items = container:GetItems() or {}
        for _, v in pairs(items) do
            num_found = num_found + check_item(v, name, target_prefab, use_alias)
        end
    end

    -- 船只装备栏
    if container.GetBoatEquips then
        local boat_equips = container:GetBoatEquips() or {}
        for _, v in pairs(boat_equips) do
            num_found = num_found + check_item(v, name, target_prefab, use_alias)
        end
    end

    -- 手持物品
    if container.GetActiveItem then
        num_found = num_found + check_item(container:GetActiveItem(), name, target_prefab, use_alias)
    end

    -- 溢出容器（如背包扩展）
    if container.GetOverflowContainer and container:GetOverflowContainer() then
        num_found = num_found + CountItems(
            container:GetOverflowContainer(), name, target_prefab, use_alias
        )
    end

    return num_found
end

-- 获取容器的本地化名称
local function get_container_name(container)
    if not container then return end

    local name = container:GetBasicDisplayName()
    local prefab = container.prefab

    -- 处理空名称的容器预制物
    if type(name) == "string" and name:find("^[ \t\r\n]*$")
        and prefab and prefab:find("_container") then
        name = GLOBAL.STRINGS.NAMES[
            prefab:sub(1, prefab:find("_container") - 1):upper()
        ]
    end

    return prefab and LOCAL_STRINGS[prefab:upper()]
        or (name and name:lower())
end

-- 获取装备槽位的本地化名称
local function GetEquipSlotName(qa, equipslot)
    if not equipslot then return nil end

    local key = string.upper(tostring(equipslot))
    local mapping = {
        HEAD  = "SLOT_HEAD",
        HANDS = "SLOT_HANDS",
        BODY  = "SLOT_BODY",
        BACK  = "SLOT_BACK",
        NECK  = "SLOT_NECK",
        BELLY = "SLOT_BELLY",
        MEDAL = "SLOT_MEDAL"
    }

    for k, v in pairs(GLOBAL.EQUIPSLOTS) do
        if equipslot == v then
            key = k
            break
        end
    end

    return mapping[key] and GetMapping(qa, 'WORDS', mapping[key]) or nil
end

-- 物品栏数量统计包装函数
local function GetItemCountWrapper(container, item, match_name)
    if not container:Has(item.prefab, 1) then return 0 end

    local target_name = match_name and item:GetDisplayName() or nil
    local use_alias = ITEM_PREFAB_ALIAS[item.prefab] ~= nil
    local target_prefab = use_alias and ITEM_PREFAB_ALIAS[item.prefab] or item.prefab

    return CountItems(container, target_name, target_prefab, use_alias)
end

----------------------------------------
-- 6.4 物品槽位宣告
----------------------------------------

-- 宣告物品栏/装备栏中的物品信息
local function AnnounceItem(slot, classname)
    local qa = GLOBAL.NOMU_QA.SCHEME.ITEM
    local item = slot.tile.item
    local container = (slot.container == nil or slot.container.type == "pack")
        and ThePlayer.replica.inventory
        or slot.container

    -- 获取耐久度/新鲜度百分比
    local percent, percent_type
    if slot.tile.percent then
        percent = slot.tile.percent:GetString()
        percent_type = "DURABILITY"
    elseif slot.tile.hasspoilage
        and item.replica.inventoryitem
        and item.replica.inventoryitem.classified then
        percent = math.floor(
            item.replica.inventoryitem.classified.perish:value() * (1 / .62)
        ) .. "%"
        percent_type = "FRESHNESS"
    end

    -- 统计已装备的同名物品数量
    local num_equipped_prefab, num_equipped_name = 0, 0
    if not container.type then
        for _, _slot in pairs(EQUIPSLOTS) do
            local eq = container:GetEquippedItem(_slot)
            if eq and eq.prefab == item.prefab then
                local s = eq.replica.stackable and eq.replica.stackable:StackSize() or 1
                num_equipped_prefab = num_equipped_prefab + s
                if eq:GetDisplayName() == item:GetDisplayName() then
                    num_equipped_name = num_equipped_name + s
                end
            end
        end
    end

    -- 获取容器名称
    local container_name = get_container_name(container.type and container.inst)
    if not container_name then
        local cb = container.inst.entity:GetParent()
            and container.inst.entity:GetParent().components.constructionbuilder
        if cb and cb.constructionsite then
            container_name = get_container_name(cb.constructionsite)
        end
    end

    -- 获取实体名称信息
    local display_name, prefab_name, is_player_named = GetEntityName(item, false)

    -- 统计容器内数量
    local inv_count_prefab = GetItemCountWrapper(container, item, false)
    local inv_count_name = GetItemCountWrapper(container, item, true)
    local num_found_prefab = inv_count_prefab + num_equipped_prefab
    local num_found_name = inv_count_name + num_equipped_name

    -- 构建格式化参数表
    local fmts = {
        PRONOUN = GetMapping(qa, 'PRONOUN', 'I'),
        NUM = num_found_prefab,
        EQUIP_NUM = num_equipped_prefab,
        ITEM = '',
        IN_CONTAINER = '',
        WITH_PERCENT = '',
        POST_STATE = '',
        SHOW_ME = '',
        ITEM_NUM = num_equipped_prefab ~= num_found_prefab
            and subfmt(GetMapping(qa, 'WORDS', 'ITEM_NUM'), { NUM = num_found_prefab })
            or ''
    }

    -- 根据是否有自定义名决定显示方式
    if is_player_named or (num_found_prefab > num_found_name and display_name ~= prefab_name) then
        fmts.ITEM = prefab_name
        fmts.ITEM_NAME = subfmt(GetMapping(qa, 'WORDS', 'ITEM_NAME'), {
            NUM = num_found_name, NAME = display_name
        })
    else
        fmts.ITEM_NAME = ''
        fmts.ITEM = display_name
    end

    -- 容器信息
    if container_name then
        fmts.PRONOUN = GetMapping(qa, 'PRONOUN', 'WE')
        fmts.IN_CONTAINER = subfmt(GetMapping(qa, 'WORDS', 'IN_CONTAINER'), {
            NAME = container_name
        })
    end

    -- 百分比信息
    if percent then
        fmts.WITH_PERCENT = subfmt(GetMapping(qa, 'WORDS', 'WITH_PERCENT'), {
            THIS_ONE = num_found_prefab > 1 and GetMapping(qa, 'WORDS', 'THIS_ONE') or '',
            PERCENT = percent,
            TYPE = GetMapping(qa, 'PERCENT_TYPE', percent_type)
        })
    end

    -- 特殊状态（暖石温度等）
    if GLOBAL.NOMU_QA.DATA.ENABLE_SPECIAL_STATE then
        if item.prefab == 'heatrock' then
            local heat_stat = GetHeatrockStat(item)
            if heat_stat then
                fmts.POST_STATE = GetMapping(qa, 'HEAT_ROCK', heat_stat)
            end
        end
    end

    -- 充能状态
    local recharge_netvar = item.replica.inventoryitem
        and item.replica.inventoryitem.classified
        and item.replica.inventoryitem.classified.recharge
    local recharge_val = recharge_netvar and recharge_netvar:value()
    local is_rechargeable = item:HasTag("rechargeable")
        or (recharge_val and recharge_val < 180)

    if is_rechargeable and recharge_val then
        if RECHARGEABLE_PREFABS[item.prefab] then
            local seconds = (180 - recharge_val) / 180 * RECHARGEABLE_PREFABS[item.prefab]
            if seconds <= 0 then
                fmts.POST_STATE = GetMapping(qa, 'RECHARGE', 'FULL')
            else
                fmts.POST_STATE = subfmt(GetMapping(qa, 'RECHARGE', 'CHARGING'), {
                    TIME = (math.modf(seconds / 60) > 0
                        and math.modf(seconds / 60) .. GetMapping(qa, 'TIME', 'MINUTES')
                        or '')
                    .. math.modf(math.fmod(seconds, 60)) .. GetMapping(qa, 'TIME', 'SECONDS')
                })
            end
        else
            if recharge_val == 180 then
                fmts.POST_STATE = GetMapping(qa, 'RECHARGE', 'FULL')
            else
                local left_percent = math.floor((180 - recharge_val) / 180 * 100)
                fmts.POST_STATE = subfmt(GetMapping(qa, 'RECHARGE', 'PERCENT'), {
                    PERCENT = left_percent
                })
            end
        end
    end

    -- Show Me 信息附加
    local start_line = #(string.split(item:GetBasicDisplayName(), '\n')) + 1
    local show_me_str = GetShowMeString(item, qa, start_line, nil, nil, 2)
    if show_me_str ~= "" then
        fmts.SHOW_ME = show_me_str
    end

    -- 根据槽位类型选择格式模板
    local result_str
    local fmt_loc_key = "INV_SLOT"
    if classname == 'invslot' then
        result_str = subfmt(qa.FORMATS.INV_SLOT, fmts)
    else
        local is_heavy = item:HasTag("heavy")
        local slot_pos_name = GetEquipSlotName(qa, slot.equipslot)

        if slot_pos_name then
            fmts.SLOT_POS = slot_pos_name
            fmts.v = slot_pos_name
            if is_heavy and qa.FORMATS.EQUIP_SLOT_HEAVY_POS then
                result_str = subfmt(qa.FORMATS.EQUIP_SLOT_HEAVY_POS, fmts)
                fmt_loc_key = "EQUIP_SLOT_HEAVY_POS"
            else
                result_str = subfmt(qa.FORMATS.EQUIP_SLOT_POS, fmts)
                fmt_loc_key = "EQUIP_SLOT_POS"
            end
        else
            if is_heavy and qa.FORMATS.EQUIP_SLOT_HEAVY then
                result_str = subfmt(qa.FORMATS.EQUIP_SLOT_HEAVY, fmts)
                fmt_loc_key = "EQUIP_SLOT_HEAVY"
            else
                result_str = subfmt(qa.FORMATS.EQUIP_SLOT, fmts)
                fmt_loc_key = "EQUIP_SLOT"
            end
        end
    end

    -- 调试信息
    local slot_name = classname == 'equipslot' and tostring(slot.equipslot) or ("inv_" .. tostring(slot.num))
    local debug_txt = GLOBAL.NOMU_QA.GetContainerSlotDebugString(item, container and container.inst, slot_name, classname)

    return Announce(result_str, nil, debug_txt, GetStatementLoc("ITEM", fmt_loc_key))
end

----------------------------------------
-- 6.5 建筑工地与交易站宣告
----------------------------------------

local function AnnounceConstructionSite(site, container_widget, slot_index)
    local site_rep = site.replica.constructionsite
    if not site_rep then return false end

    local plans = site_rep:GetIngredients()
        or GLOBAL.CONSTRUCTION_PLANS[site.prefab]
        or (site.nameoverride and GLOBAL.CONSTRUCTION_PLANS[site.nameoverride])
    if not plans then return false end

    local container_rep = container_widget
        and container_widget.inst
        and container_widget.inst.replica.container

    local site_name = GetEntityName(site, false)
    local is_trade = site:HasTag("offerconstructionsite")
        or (container_widget and container_widget.inst
            and container_widget.inst:HasTag("offerconstructionsite"))

    local qa_const = GLOBAL.NOMU_QA.SCHEME.CONSTRUCTION_AND_TRADE
    local prefix = is_trade and "TRADE_" or "CONS_"

    local debug_str = string.format(
        "[施工点代码: %s] [容器代码: %s]",
        tostring(site.prefab),
        tostring(container_widget and container_widget.inst and container_widget.inst.prefab or "无")
    )

    -- 单槽位宣告
    if slot_index and plans[slot_index] then
        local plan = plans[slot_index]
        local current = (site_rep:GetSlotCount(slot_index) or 0)
            + (container_rep and container_rep:GetItemInSlot(slot_index)
                and (container_rep:GetItemInSlot(slot_index).replica.stackable
                    and container_rep:GetItemInSlot(slot_index).replica.stackable:StackSize() or 1)
                or 0)

        local missing = plan.amount - current
        local ing_name = LOCAL_STRINGS[plan.type:upper()]
            or GLOBAL.STRINGS.NAMES[plan.type:upper()]
            or plan.type
        local amount_fmt = GetMapping(qa_const, 'WORDS', 'AMOUNT_FMT') or "{NUM} {ITEM}"

        if missing <= 0 then
            local fmt_name = prefix .. (qa_const.FORMATS[prefix .. "HAVE_ITEM"] and "HAVE_ITEM" or "HAVE")
            return Announce(subfmt(qa_const.FORMATS[fmt_name], {
                RECIPE = site_name,
                INGREDIENT = subfmt(amount_fmt, { NUM = plan.amount, ITEM = ing_name })
            }), nil, debug_str, GetStatementLoc("CONSTRUCTION_AND_TRADE", fmt_name))
        else
            if not GLOBAL.NOMU_QA.DATA.ANNOUNCE_ALL_MISSING_INGREDIENTS then
                local fmt_name = prefix .. "NEED"
                return Announce(subfmt(qa_const.FORMATS[fmt_name], {
                    INGREDIENT = subfmt(amount_fmt, { NUM = missing, ITEM = ing_name }),
                    RECIPE = site_name
                }), nil, debug_str, GetStatementLoc("CONSTRUCTION_AND_TRADE", fmt_name))
            end
        end
    end

    -- 全量材料宣告
    local missing, total_req = {}, {}
    for i, plan in ipairs(plans) do
        local current = (site_rep:GetSlotCount(i) or 0)
            + (container_rep and container_rep:GetItemInSlot(i)
                and (container_rep:GetItemInSlot(i).replica.stackable
                    and container_rep:GetItemInSlot(i).replica.stackable:StackSize() or 1)
                or 0)

        local name = LOCAL_STRINGS[plan.type:upper()]
            or GLOBAL.STRINGS.NAMES[plan.type:upper()]
            or plan.type

        table.insert(total_req, plan.amount .. "个" .. name)
        if plan.amount - current > 0 then
            table.insert(missing, (plan.amount - current) .. "个" .. name)
        end
    end

    if #missing > 0 then
        local fmt_name = prefix .. "NEED"
        return Announce(subfmt(qa_const.FORMATS[fmt_name], {
            INGREDIENT = table.concat(missing, ", "),
            RECIPE = site_name
        }), nil, debug_str, GetStatementLoc("CONSTRUCTION_AND_TRADE", fmt_name))
    else
        local fmt_name = prefix .. "HAVE"
        return Announce(subfmt(qa_const.FORMATS[fmt_name], {
            RECIPE = site_name,
            INGREDIENT = table.concat(total_req, ", ")
        }), nil, debug_str, GetStatementLoc("CONSTRUCTION_AND_TRADE", fmt_name))
    end
end

----------------------------------------
-- 6.6 皮肤与制作栏其他宣告
----------------------------------------

-- 皮肤选择器宣告
local function AnnounceSkin(recipepopup)
    if not recipepopup.focus then return end

    local skin_name = recipepopup.skins_spinner and recipepopup.skins_spinner.GetItem()
        or (recipepopup.GetItem and recipepopup:GetItem())
    local recipe = recipepopup.recipe

    local upper_override = recipe.nameoverride and string.upper(recipe.nameoverride) or nil
    local upper_name = recipe.name and string.upper(recipe.name) or nil
    local upper_product = recipe.product and string.upper(recipe.product) or nil

    local item_name = (upper_override and GLOBAL.STRINGS.NAMES[upper_override])
        or (upper_name and GLOBAL.STRINGS.NAMES[upper_name])
        or (upper_product and GLOBAL.STRINGS.NAMES[upper_product])
        or recipe.name

    if skin_name == nil then
        if #recipepopup.skins_options == 1 then
            local prefab = recipepopup.recipe.product or recipepopup.recipe.name
            local fmt_key = (not PREFAB_SKINS[prefab] or #PREFAB_SKINS[prefab] == 0) and "NO_SKIN" or "HAS_NO_SKIN"
            return Announce(subfmt(
                GLOBAL.NOMU_QA.SCHEME.SKIN.FORMATS[fmt_key],
                { ITEM = item_name }
            ), nil, nil, GetStatementLoc("SKIN", fmt_key))
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
        }), nil, nil, GetStatementLoc("SKIN", "DEFAULT"))
    end
end

-- 制作栏固定槽位宣告
local function AnnounceRecipePinSlot(slot, recipepopup, ingnum)
    local recipe_state = slot.craftingmenu:GetRecipeState(slot.recipe_name)
    if not recipe_state or not recipe_state.recipe then return end

    local specific_ingredient_type = nil
    local recipe = recipe_state.recipe
    recipepopup = recipepopup or slot.recipe_popup

    if recipepopup then
        local ing = recipepopup.ing or {}

        -- 兼容 Redux 制作栏和旧版 UI
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

    return AnnounceMergedRecipe(
        recipe,
        slot.owner.replica.builder,
        slot.owner.replica.inventory,
        slot.owner,
        specific_ingredient_type
    )
end

-- 制作栏网格宣告
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

-- 制作栏材料面板宣告
local function AnnounceRecipeCMIngredients(ingredients)
    local recipe = ingredients.recipe
    if not recipe then return end

    local specific_ingredient_type = nil
    local focused_index = nil

    -- 优先获取 Redux 制作栏准确的 widget 列表序号
    if ingredients.ingredient_widgets then
        for i, widget in ipairs(ingredients.ingredient_widgets) do
            if widget.focus then
                focused_index = i
                break
            end
        end
    else
        -- 兜底逻辑
        local root = ingredients.children
            and next(ingredients.children)
            and ingredients.children[next(ingredients.children)]
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

    specific_ingredient_type = GetFocusedIngredientType(recipe, focused_index)

    return AnnounceMergedRecipe(
        recipe,
        ingredients.owner.replica.builder,
        ingredients.owner.replica.inventory,
        ingredients.owner,
        specific_ingredient_type
    )
end

-- ============================================================================
-- [7] 环境实体探测与世界交互逻辑
-- ============================================================================
----------------------------------------
-- 7.2 实体特殊状态分发器
----------------------------------------

local SPECIAL_STATE_DISPATCHER = {
    hotspring = function(ent, _)
        local stat = GetHotspringStat(ent)
        return stat and ("HOTSPRING_" .. stat) or nil
    end,

    trophyscale_fish = function(ent, _)
        if ent.AnimState and (ent.AnimState:IsCurrentAnimation("nofish_idle") or ent.AnimState:IsCurrentAnimation("nofish_hit") or ent.AnimState:IsCurrentAnimation("spawn")) then
            return "TROPHYSCALE_EMPTY"
        end
        return "TROPHYSCALE_HAS"
    end,

    trophyscale_oversizedveggies = function(ent, _)
        if ent.AnimState and (ent.AnimState:IsCurrentAnimation("noveg_idle") or ent.AnimState:IsCurrentAnimation("noveg_hit") or ent.AnimState:IsCurrentAnimation("spawn")) then
            return "TROPHYSCALE_EMPTY"
        end
        return "TROPHYSCALE_HAS"
    end,

    fruitdragon = function(ent, _)
        local ripe = (ent.AnimState and ent.AnimState:GetBuild() == "fruit_dragon_ripe_build")
            or string.find(ent:GetDisplayName() or "", "Ripe")
        return ripe and "FRUITDRAGON_RIPE" or nil
    end,

    beefalo = function(ent, _)
        return not ent:HasTag("has_beard") and "BEEFALO_SHAVED" or nil
    end,

    archive_switch = function(ent, _)
        return (ent.AnimState and (
            ent.AnimState:IsCurrentAnimation("idle_full")
            or ent.AnimState:IsCurrentAnimation("activate")
        )) and "ARCHIVE_SWITCH_FULL" or "ARCHIVE_SWITCH_EMPTY"
    end,

    heatrock = function(ent, is_target)
        if not is_target then return nil end
        local heat_stat = GetHeatrockStat(ent)
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
    end,

    oasislake = function(ent, is_target)
        if not is_target then return nil end
        return ent:HasTag("NOCLICK") and "OASISLAKE_EMPTY" or "OASISLAKE_FULL"
    end,

    toadstool_cap = function(ent, is_target)
        if not is_target then return nil end
        if ent._state and ent._state:value() > 0 then
            return ent._dark and ent._dark:value() and "TOADSTOOL_DARK" or "TOADSTOOL_NORMAL"
        end
        return "TOADSTOOL_EMPTY"
    end
}

-- 统一获取实体的特殊状态标签
local function GetEntitySpecialState(entity, is_target)
    if not entity then return nil end

    -- 通用标签状态
    if entity:HasTag("fire") then return "FIRE" end
    if entity:HasTag("burnt") then return "BURNT" end
    if entity:HasTag("smolder") then return "SMOLDER" end
    if entity:HasTag("withered") then return "WITHERED" end
    if entity:HasTag("barren") then return "BARREN" end
    if entity.prefab == "lightninggoat" and entity:HasTag("charged") then return "GOAT_CHARGED" end

    -- 作物/树木/蜘蛛巢状态
    local stat = GetGenericCropStat(entity) or GetTreeStat(entity) or GetSpiderDenStat(entity)
    if stat then return stat end

    -- 分发器特殊状态
    if SPECIAL_STATE_DISPATCHER[entity.prefab] then
        return SPECIAL_STATE_DISPATCHER[entity.prefab](entity, is_target)
    end

    return nil
end

----------------------------------------
-- 7.3 玩家专属点击处理
----------------------------------------

-- 检测玩家是否正在钓鱼
local function IsPlayerFishing(player)
    local inventory = player.replica.inventory
    if not inventory then return false end

    local equip = inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS)
    if not equip then return false end

    if equip.replica.fishingrod and equip.replica.fishingrod:GetTarget() ~= nil then
        return true
    end

    if equip.replica.oceanfishingrod then
        if type(equip.replica.oceanfishingrod.GetBobber) == "function"
            and equip.replica.oceanfishingrod:GetBobber() ~= nil then
            return true
        end
        if type(equip.replica.oceanfishingrod.GetTarget) == "function"
            and equip.replica.oceanfishingrod:GetTarget() ~= nil then
            return true
        end
    end

    return false
end

-- 检测实体是否处于冰冻/解冻状态
local function IsPlayerFrozenOrThawing(entity)
    if not entity or not entity:IsValid() then return false end

    if entity.sg ~= nil and entity.sg:HasStateTag("frozen") then
        return true
    end

    if entity.AnimState ~= nil then
        return entity.AnimState:IsCurrentAnimation("frozen")
            or entity.AnimState:IsCurrentAnimation("frozen_loop_pst")
            or entity.AnimState:IsCurrentAnimation("frozen_hit")
            or entity.AnimState:IsCurrentAnimation("frozen_pst")
            or entity.AnimState:IsCurrentAnimation("frozen_loop")
    end

    return false
end

-- 处理玩家实体的点击宣告
local function HandlePlayerClick(entity)
    local is_fishing = IsPlayerFishing(entity)
    local is_frozen = IsPlayerFrozenOrThawing(entity)
    local is_me_ghost = GLOBAL.ThePlayer:HasTag("playerghost")
    local is_ent_ghost = entity:HasTag("playerghost")
    local qa_formats = GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS
    
    -- 获取玩家实体的调试信息
    local debug_str = GLOBAL.NOMU_QA.GetEntityDebugString(entity)

    -- 点击自己
    if entity == GLOBAL.ThePlayer then
        if is_me_ghost and qa_formats.I_AM_GHOST then
            return Announce(subfmt(qa_formats.I_AM_GHOST, { NAME = entity:GetDisplayName() }), nil, debug_str, GetStatementLoc("PLAYER", "I_AM_GHOST"))
        end
        if is_frozen and qa_formats.ME_FROZEN then
            return Announce(subfmt(qa_formats.ME_FROZEN, { NAME = entity:GetDisplayName() }), nil, debug_str, GetStatementLoc("PLAYER", "ME_FROZEN"))
        end
        if is_fishing and qa_formats.ME_FISHING then
            return Announce(subfmt(qa_formats.ME_FISHING, { NAME = entity:GetDisplayName() }), nil, debug_str, GetStatementLoc("PLAYER", "ME_FISHING"))
        end

        -- 骑乘状态
        local rider = entity.replica.rider
        if rider and rider:IsRiding() then
            local mount = rider:GetMount()
            local mount_name = GetEntityName(mount, false)
            if qa_formats.ME_RIDING then
                return Announce(subfmt(qa_formats.ME_RIDING, {
                    NAME = entity:GetDisplayName(), MOUNT = mount_name
                }), nil, debug_str, GetStatementLoc("PLAYER", "ME_RIDING"))
            end
        end

        -- 搬运重物
        local inventory = entity.replica.inventory
        if inventory then
            local equip_body = inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.BODY)
            if equip_body and equip_body:HasTag("heavy") then
                local heavy_name = GetEntityName(equip_body, false)
                if qa_formats.ME_CARRYING then
                    return Announce(subfmt(qa_formats.ME_CARRYING, {
                        NAME = entity:GetDisplayName(), ITEM = heavy_name
                    }), nil, debug_str, GetStatementLoc("PLAYER", "ME_CARRYING"))
                end
            end
        end

        return Announce(subfmt(qa_formats.I_AM_HERE, { NAME = entity:GetDisplayName() }), nil, debug_str, GetStatementLoc("PLAYER", "I_AM_HERE"))
    end

    -- 手持物品给予他人
    local my_inventory = GLOBAL.ThePlayer.replica.inventory
    local active_item = my_inventory and my_inventory:GetActiveItem()
    if active_item then
        return Announce(subfmt(qa_formats.GIVE_ITEM, {
            NAME = entity:GetDisplayName(),
            NUM = active_item.replica.stackable and active_item.replica.stackable:StackSize() or 1,
            ITEM_NAME = string.gsub(active_item:GetDisplayName(), '\n', ' ')
        }), nil, debug_str, GetStatementLoc("PLAYER", "GIVE_ITEM"))
    end

    -- 幽灵状态交互
    if is_me_ghost or is_ent_ghost then
        local player_fmt_key = (is_me_ghost and is_ent_ghost) and "BOTH_GHOST"
            or (is_me_ghost and "ME_GHOST" or "THEY_GHOST")
        return Announce(subfmt(qa_formats[player_fmt_key], { NAME = entity:GetDisplayName() }), nil, debug_str, GetStatementLoc("PLAYER", player_fmt_key))
    end

    -- 对方状态
    if is_frozen and qa_formats.THEY_FROZEN then
        return Announce(subfmt(qa_formats.THEY_FROZEN, { NAME = entity:GetDisplayName() }), nil, debug_str, GetStatementLoc("PLAYER", "THEY_FROZEN"))
    end
    if is_fishing and qa_formats.THEY_FISHING then
        return Announce(subfmt(qa_formats.THEY_FISHING, { NAME = entity:GetDisplayName() }), nil, debug_str, GetStatementLoc("PLAYER", "THEY_FISHING"))
    end

    return Announce(subfmt(qa_formats.GREET, { NAME = entity:GetDisplayName() }), nil, debug_str, GetStatementLoc("PLAYER", "GREET"))
end

----------------------------------------
-- 7.4 中键调试信息输出
----------------------------------------

local function HandleEnvMiddleClick(entity)
    if not GLOBAL.TheInput:IsKeyDown(GLOBAL.KEY_LCTRL) and entity:HasTag('player') then
        if entity == GLOBAL.ThePlayer then
            return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.PING, {
                PING = GLOBAL.TheNet:GetAveragePing()
            }), nil, nil, GetStatementLoc("PLAYER", "PING"))
        else
            return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.GREET, {
                NAME = entity:GetDisplayName()
            }), nil, nil, GetStatementLoc("PLAYER", "GREET"))
        end
    end

    local qa = GLOBAL.NOMU_QA.SCHEME.ENV
    local mod_str = ""
    local safe_prefab = entity.prefab or "UNKNOWN"
    local mod_name = GLOBAL.NOMU_QA.GetModNameForPrefab(safe_prefab)
    if mod_name then
        mod_str = subfmt(GetMapping(qa, 'WORDS', 'MOD_INFO'), { MOD_NAME = mod_name })
    end

    local entity_info = subfmt(qa.FORMATS.CODE, {
        PREFAB = safe_prefab,
        NAME = entity:GetDisplayName(),
        MOD_INFO = mod_str,
        ASSET_INFO = ""
    })

    print(entity_info)
    GLOBAL.ThePlayer.components.talker:Say(entity_info, 5)
    return true
end

----------------------------------------
-- 7.5 世界实体鼠标点击主监听器
----------------------------------------

GLOBAL.TheInput:AddMouseButtonHandler(function(button, down)
    -- 仅在 HUD 界面 + Alt + Shift + 按下时触发
    if not (IsDefaultScreen() and GLOBAL.QA_UTILS.IsAltPressed() and GLOBAL.QA_UTILS.IsShiftPressed() and down) then
        return
    end

    local ThePlayer = GLOBAL.ThePlayer
    local TheInput = GLOBAL.TheInput

    -- 获取鼠标下的实体
    local entity = ConsoleWorldEntityUnderMouse()
    if entity and (entity:HasTag("NOCLICK") or entity:HasTag("FX") or entity:HasTag("DECOR")) then
        entity = nil
    end

    -- 模糊搜索：当精确点击未命中时，搜索附近的特殊实体
    if not entity then
        local pos = TheInput:GetWorldPosition()
        local ents = GLOBAL.TheSim:FindEntities(
            pos.x, pos.y, pos.z,
            GLOBAL.NOMU_QA.DATA.FUZZY_ANNOUNCE and 4 or 2,
            nil,
            { "INLIMBO", "player" }
        )
        local fuzzy_entity = nil

        for _, v in ipairs(ents) do
            -- 优先匹配特殊可交互实体
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

            -- 模糊匹配备选
            if GLOBAL.NOMU_QA.DATA.FUZZY_ANNOUNCE
                and not fuzzy_entity
                and v.prefab and v.name
                and not v:HasTag("NOCLICK")
                and not v:HasTag("FX")
                and not v:HasTag("DECOR") then
                fuzzy_entity = v
            end
        end

        entity = entity or fuzzy_entity
    end

    local qa = GLOBAL.NOMU_QA.SCHEME.ENV

    ---- 中键：调试信息 ----
    if button == GLOBAL.MOUSEBUTTON_MIDDLE then
        if entity then HandleEnvMiddleClick(entity) end
        return
    end

    ---- 左键：实体宣告 ----
    if button ~= GLOBAL.MOUSEBUTTON_LEFT then return end
    if not entity then return end

    -- 玩家实体特殊处理
    if not TheInput:IsKeyDown(GLOBAL.KEY_LCTRL) and entity:HasTag('player') then
        return HandlePlayerClick(entity)
    end

    -- 世界实体宣告核心逻辑
    local px, py, pz = entity:GetPosition():Get()
    local is_on_water = GLOBAL.TheWorld.Map
        and GLOBAL.TheWorld.Map:IsOceanAtPoint(px, py, pz)
        and (entity.GetCurrentPlatform == nil or entity:GetCurrentPlatform() == nil)

    local radius = type(GLOBAL.NOMU_QA.DATA.ANNOUNCE_RANGE) == "number"
        and GLOBAL.NOMU_QA.DATA.ANNOUNCE_RANGE or 40
    local entities = GLOBAL.TheSim:FindEntities(px, py, pz, radius)

    -- 获取目标实体状态
    local target_state = GetEntitySpecialState(entity, true)
    local display_name, prefab_name, is_player_named = GetEntityName(entity, false)

    local target_name = ""
    if entity.GetDisplayName and type(entity.GetDisplayName) == "function" then
        target_name = entity:GetDisplayName() or ""
    end

    -- 统计范围内同类实体数量
    local count_prefab, count_name, stat_count = 0, 0, 0
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
        elseif (ITEM_PREFAB_ALIAS and ITEM_PREFAB_ALIAS[entity.prefab]
                and ITEM_PREFAB_ALIAS[entity.prefab] == ITEM_PREFAB_ALIAS[v.prefab])
            or v.prefab == entity.prefab then
            is_same_entity = true
        end

        if v.entity:IsVisible() and is_same_entity then
            local v_name = ""
            if v.GetDisplayName and type(v.GetDisplayName) == "function" then
                v_name = v:GetDisplayName() or ""
            end

            local s = v.replica and v.replica.stackable and v.replica.stackable:StackSize() or 1
            count_prefab = count_prefab + s
            if v_name == target_name then count_name = count_name + s end

            if target_state and GetEntitySpecialState(v, false) == target_state then
                stat_count = stat_count + s
            end
        end
    end

    -- Boss 碎片特殊计数
    if is_worm_boss_piece then
        local boss_count = 0
        for _, v in pairs(GLOBAL.Ents) do
            if v.prefab == "worm_boss" and v:GetDistanceSqToInst(entity) <= 10000 then
                boss_count = boss_count + 1
            end
        end
        count_prefab = math.max(1, boss_count)
        count_name = math.max(1, boss_count)
    elseif is_shadow_centipede_piece then
        local boss_count = math.ceil(centipede_head_count / 2)
        if boss_count == 0 and centipede_has_piece then boss_count = 1 end
        count_prefab = boss_count
        count_name = boss_count
    end

    -- 调试信息
    local debug_str = GLOBAL.NOMU_QA.GetEntityDebugString(entity)

    -- Show Me 信息
    local start_line = #(string.split(entity:GetBasicDisplayName(), '\n')) + 1
    local show_me = GetShowMeString(entity, qa, start_line, nil, nil, 2)

    -- 距离计算
    local dist_str = ""
    local show_dist = GLOBAL.NOMU_QA.DATA.SHOW_DISTANCE
    if show_dist > 0 then
        local raw_dist = math.sqrt(ThePlayer:GetDistanceSqToInst(entity)) / 4
        if raw_dist >= 1 then
            local dist_val = (show_dist == 2)
                and string.format("%.1f", raw_dist)
                or math.floor(raw_dist)
            local word_key = is_on_water and 'DISTANCE_FAR_WATER' or 'DISTANCE_FAR'
            dist_str = subfmt(
                GetMapping(qa, 'WORDS', word_key) or GetMapping(qa, 'WORDS', 'DISTANCE_FAR'),
                { DIST = dist_val }
            )
        else
            local word_key = is_on_water and 'DISTANCE_CLOSE_WATER' or 'DISTANCE_CLOSE'
            dist_str = GetMapping(qa, 'WORDS', word_key)
                or GetMapping(qa, 'WORDS', 'DISTANCE_CLOSE')
        end
    end

    ---- 特殊预制物打断处理 ----
    if entity.prefab == "gelblob_storage" then
        local held_item = entity.takeitem and entity.takeitem:value()
        
        if held_item ~= nil and held_item:IsValid() then
            -- 获取内部物品的名称和数量
            local item_display_name = GetEntityName(held_item, false)
            local stack_size = held_item.replica and held_item.replica.stackable and held_item.replica.stackable:StackSize() or 1
            
            return Announce(subfmt(qa.FORMATS.STORAGE_HAS, {
                TOTAL = count_prefab,
                NAME = prefab_name,
                NUM = stack_size,
                ITEM = item_display_name,
                SHOW_ME = show_me,
                DISTANCE = dist_str
            }), entity:HasTag('player'), debug_str, GetStatementLoc("ENV", "STORAGE_HAS"))
        else
            -- 统计空的数量
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
                fmt_name = qa.FORMATS.STORAGE_EMPTY_THIS_SINGLE and "STORAGE_EMPTY_THIS_SINGLE" or "STORAGE_EMPTY_THIS"
            elseif empty_count == count_prefab then
                fmt_name = qa.FORMATS.STORAGE_EMPTY_EQUAL and "STORAGE_EMPTY_EQUAL" or "STORAGE_EMPTY"
            elseif empty_count == 1 then
                fmt_name = qa.FORMATS.STORAGE_EMPTY_THIS and "STORAGE_EMPTY_THIS" or "STORAGE_EMPTY"
            end

            return Announce(subfmt(qa.FORMATS[fmt_name], {
                TOTAL = count_prefab,
                NAME = prefab_name,
                NUM = empty_count,
                SHOW_ME = show_me,
                DISTANCE = dist_str
            }), entity:HasTag('player'), debug_str, GetStatementLoc("ENV", fmt_name))
        end
    end

    if entity.prefab == "icefishing_hole" then
        return Announce(subfmt(qa.FORMATS.SINGLE, {
            NAME = GLOBAL.STRINGS.NOMU_QA.ICEFISHING_HOLE,
            SHOW_ME = show_me, DISTANCE = dist_str
        }), entity:HasTag('player'), debug_str, GetStatementLoc("ENV", "SINGLE"))
    end

    if entity.prefab == "townportal" then
        local is_on = entity.AnimState and entity.AnimState:IsCurrentAnimation("idle_on_loop")
        local fmt_key = is_on and "PORTAL_ON" or "PORTAL_OFF"
        return Announce(subfmt(
            GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS[fmt_key],
            { NAME = display_name }
        ), entity:HasTag('player'), debug_str, GetStatementLoc("PLAYER", fmt_key))
    end

    -- 鱼群宣告
    if entity:HasTag("oceanfishable") and entity:HasTag("oceanfishinghookable")
        and not string.find(entity.prefab or "", "flotsam") then

        local adj = GLOBAL.STRINGS.UI.CUSTOMIZATIONSCREEN.OCEAN_SHOAL or LOCAL_STRINGS.OCEAN_SHOAL
        local shoal_name = adj
        local fish_name = GLOBAL.STRINGS.NAMES.FISH or "Fish"

        if entity.name and type(entity.name) == "string"
            and entity.name ~= "" and entity.name ~= adj then
            fish_name = LOCAL_STRINGS[string.upper(entity.name)]
                or GLOBAL.STRINGS.NAMES[string.upper(entity.name)]
                or entity.name
            shoal_name = GLOBAL.STRINGS.UI.OBJECTOWNERSHIP
                and subfmt(GLOBAL.STRINGS.UI.OBJECTOWNERSHIP, {owner = fish_name, object = adj})
                or shoal_name
        end

        local f_c = 0
        for _, v in ipairs(entities) do
            if (v:HasTag("oceanfish") or v:HasTag("oceanfishable"))
                and v.prefab == entity.prefab then
                f_c = f_c + 1
            end
        end

        return Announce(subfmt(qa.FORMATS.FISH_SHOAL, {
            NAME = shoal_name, NUM = f_c, FISH = fish_name,
            SHOW_ME = show_me, DISTANCE = dist_str
        }), entity:HasTag('player'), debug_str, GetStatementLoc("ENV", "FISH_SHOAL"))
    end

    ---- 带特殊状态的宣告 ----
    local use_special = GLOBAL.NOMU_QA.DATA.ENABLE_SPECIAL_STATE
    if use_special and target_state then
        local is_specific_only = (entity.prefab == "heatrock"
            or entity.prefab == "birdcage"
            or entity.prefab == "oasislake"
            or entity.prefab == "toadstool_cap")
        local force_display_name = prefab_name

        if is_specific_only or count_prefab == 1 then
            local fmt_name = count_prefab > 1 and "STATE_THIS" or "STATE_THIS_SINGLE"
            local fmt = qa.FORMATS[fmt_name]
            return Announce(subfmt(fmt, {
                TOTAL = count_prefab, NAME = force_display_name,
                ADJ = GetMapping(qa, 'ADJ', target_state) or target_state,
                SHOW_ME = show_me, DISTANCE = dist_str
            }), entity:HasTag('player'), debug_str, GetStatementLoc("ENV", fmt_name))
        else
            local is_equal = (stat_count == count_prefab)
            local fmt_name = is_equal and "STATE_EQUAL" or "STATE_DESCRIBE"
            return Announce(subfmt(
                qa.FORMATS[fmt_name],
                {
                    TOTAL = count_prefab, NUM = stat_count, NAME = force_display_name,
                    ADJ = GetMapping(qa, 'ADJ', target_state) or target_state,
                    SHOW_ME = show_me, DISTANCE = dist_str
                }
            ), entity:HasTag('player'), debug_str, GetStatementLoc("ENV", fmt_name))
        end
    end

    ---- 常规宣告（Fallback）----
    local actual_prefab = tostring(entity.prefabnameoverride or entity.nameoverride or entity.prefab)
    if prefab_name ~= actual_prefab and display_name ~= prefab_name and (is_player_named or count_prefab > count_name) then
        local fmt_name = "NAMED"
        if count_prefab == 1 then
            fmt_name = qa.FORMATS.NAMED_THIS_SINGLE and "NAMED_THIS_SINGLE" or "NAMED_THIS"
        elseif count_name == 1 then
            fmt_name = qa.FORMATS.NAMED_THIS and "NAMED_THIS" or "NAMED"
        end

        if qa.FORMATS[fmt_name] then
            return Announce(subfmt(qa.FORMATS[fmt_name], {
                NUM_PREFAB = count_prefab,
                PREFAB_NAME = prefab_name,
                NUM = count_name,
                NAME = display_name,
                SHOW_ME = show_me,
                DISTANCE = dist_str
            }), entity:HasTag('player'), debug_str, GetStatementLoc("ENV", fmt_name))
        end
    end

    local final_count = (display_name == prefab_name) and count_prefab or count_name

    if final_count <= 1 then
        return Announce(subfmt(qa.FORMATS.SINGLE, {
            NAME = display_name, SHOW_ME = show_me, DISTANCE = dist_str
        }), entity:HasTag('player'), debug_str, GetStatementLoc("ENV", "SINGLE"))
    end

    return Announce(subfmt(qa.FORMATS.DEFAULT, {
        NUM = final_count, NAME = display_name,
        SHOW_ME = show_me, DISTANCE = dist_str
    }), entity:HasTag('player'), debug_str, GetStatementLoc("ENV", "DEFAULT"))
end)

-- ============================================================================
-- [8] 界面 UI 组件注册
-- ============================================================================

-- 暴露 Announce 函数供外部模块调用
GLOBAL.NOMU_QA.Announce = Announce

-- 导入表情包模块
modimport('scripts/qa_meme.lua')

-- 导入设置面板 UI
modimport('scripts/qa_panel.lua')

-- ============================================================================
-- [9] 游戏内系统钩子与事件注入
-- ============================================================================

----------------------------------------
-- 9.1 UI Hook 高阶函数
----------------------------------------

-- 注入 Alt+确认 快捷键到指定 Widget
local function InjectAltAccept(widget, logic_fn)
    if not widget then return end
    local old_OnControl = widget.OnControl

    widget.OnControl = function(w, control, down, ...)
        if down and control == GLOBAL.CONTROL_ACCEPT and GLOBAL.QA_UTILS.IsAltPressed() then
            if logic_fn(w, ...) then return true end
        end
        if old_OnControl then return old_OnControl(w, control, down, ...) end
        return false
    end
end

-- 注入 Alt+Shift+确认 快捷键到指定 Widget
local function InjectAltShiftAccept(widget, logic_fn)
    if not widget then return end
    local old_OnControl = widget.OnControl

    widget.OnControl = function(w, control, down, ...)
        if down and control == GLOBAL.CONTROL_ACCEPT and GLOBAL.QA_UTILS.IsAltPressed() and GLOBAL.QA_UTILS.IsShiftPressed() then
            if logic_fn(w, ...) then return true end
        end
        if old_OnControl then return old_OnControl(w, control, down, ...) end
        return false
    end
end

-- 统一为滚动列表中的子 Widget 注入 Hook
local function HookScrollListWidgets(scroll_list, get_targets_fn, logic_fn, width, height)
    if not scroll_list or not scroll_list.widgets_to_update then return end

    for _, widget in ipairs(scroll_list.widgets_to_update) do
        local targets = get_targets_fn(widget)
        for _, w in ipairs(targets) do
            if w and not w._qa_hooked then
                w._qa_hooked = true
                w.focus_forward = nil

                if width and height and type(w.SetRegionSize) == "function" then
                    w:SetRegionSize(width, height)
                end

                if type(w.SetHoverText) == "function" then
                    w:SetHoverText(LOCAL_STRINGS.HOVER_TEXT_ANNOUNCE)
                end

                InjectAltAccept(w, function(...)
                    return logic_fn(widget, ...)
                end)
            end
        end
    end
end

-- 为整个类注入 Alt+确认 Hook
local function HookClassAltAccept(class_path, logic_fn)
    AddClassPostConstruct(class_path, function(self)
        InjectAltAccept(self, logic_fn)
    end)
end

----------------------------------------
-- 9.2 模拟器初始化后钩子
----------------------------------------

AddSimPostInit(function()
    -- 加载持久化数据
    GLOBAL.NOMU_QA.LoadData()

    -- 动态拦截屏幕弹窗（勋章答题等）
    if GLOBAL.TheFrontEnd and GLOBAL.TheFrontEnd.PushScreen then
        local old_PushScreen = GLOBAL.TheFrontEnd.PushScreen

        GLOBAL.TheFrontEnd.PushScreen = function(self, screen, ...)
            if screen and screen.name == "MedalExamScreens" and not screen._nomu_qa_hooked then
                screen._nomu_qa_hooked = true

                -- 设置悬浮提示
                if screen.content and not screen.content.hovertext then
                    screen.content:SetHoverText(LOCAL_STRINGS.HOVER_TEXT_ANNOUNCE)
                end
                if screen.title and not screen.title.hovertext then
                    screen.title:SetHoverText(LOCAL_STRINGS.HOVER_TEXT_ANNOUNCE)
                end

                -- 注入宣告快捷键
                InjectAltAccept(screen, function(w)
                    if (w.content and w.content.focus)
                        or (w.title and w.title.focus)
                        or (w.destspanel and w.destspanel.focus) then

                        local question = w.content and w.content:GetString() or LOCAL_STRINGS.UNKNOWN_NAME
                        question = question:gsub("\n", ""):gsub("\t", "")

                        local opt_str_list = {}
                        local prefix = {"A.", "B.", "C.", "D."}

                        if w.menu and w.menu.items then
                            for i, v in ipairs(w.menu.items) do
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
                            OPTIONS = table.concat(opt_str_list, " ")
                        }), nil, nil, GetStatementLoc("MEDAL_BUFF", "EXAM"))
                    end
                end)
            end

            return old_PushScreen(self, screen, ...)
        end
    end
end)

----------------------------------------
-- 9.3 HUD 鼠标点击拦截
----------------------------------------

AddClassPostConstruct('screens/playerhud', function(self)
    local cur_moonphase = GLOBAL.TheWorld and GLOBAL.TheWorld.state and GLOBAL.TheWorld.state.moonphase

    if GLOBAL.NOMU_QA and GLOBAL.NOMU_QA.MOON_DATA then
        if cur_moonphase == "full" or cur_moonphase == "new" then
            GLOBAL.NOMU_QA.MOON_DATA.last_phase = cur_moonphase
            GLOBAL.NOMU_QA.MOON_DATA.phase_start_cycle = GLOBAL.TheWorld.state.cycles
            GLOBAL.NOMU_QA.MOON_DATA.is_confident = true
        else
            -- 初始记录当前月相
            GLOBAL.NOMU_QA.MOON_DATA.last_phase = cur_moonphase
            GLOBAL.NOMU_QA.MOON_DATA.phase_start_cycle = 0
            GLOBAL.NOMU_QA.MOON_DATA.is_confident = false
        end
    end

    -- 监听月相变更
    self.inst:ListenForEvent("moonphasechanged2", function(src, data)
        if GLOBAL.NOMU_QA and GLOBAL.NOMU_QA.MOON_DATA and data and data.moonphase then
            local moon_data = GLOBAL.NOMU_QA.MOON_DATA
            if data.moonphase ~= moon_data.last_phase then
                moon_data.last_phase = data.moonphase
                moon_data.phase_start_cycle = GLOBAL.TheWorld and GLOBAL.TheWorld.state and GLOBAL.TheWorld.state.cycles or 0
                moon_data.is_confident = true
            end
        end
    end, GLOBAL.TheWorld)
end)

AddClassPostConstruct('screens/playerhud', function(PlayerHud)
    local oldOnMouseButton = PlayerHud.OnMouseButton

    function PlayerHud:OnMouseButton(button, down, ...)
        if button == MOUSEBUTTON_LEFT and down and GLOBAL.QA_UTILS.IsAltPressed() then
            if OnHUDMouseButton(self) then return true end
        end
        return oldOnMouseButton(self, button, down, ...)
    end

    -- 状态宣告器兼容接口
    PlayerHud._StatusAnnouncer = {
        stat_names = { IA_BOAT = '船' },
        char_messages = {},
        Announce = function(_, message) return Announce(message) end,
        AnnounceItem = function(_, slot) return AnnounceItem(slot, 'invslot') end
    }
    setmetatable(PlayerHud._StatusAnnouncer.char_messages, {
        __index = function(_, k) return STRINGS._STATUS_ANNOUNCEMENTS.UNKNOWN[k] end
    })

    -- 烹饪锅悬浮提示注入
    local oldOnUpdate = PlayerHud.OnUpdate
    function PlayerHud:OnUpdate(...)
        if self.controls and self.controls.foodcrafting and self.controls.foodcrafting.allfoods then
            for _, food_item in ipairs(self.controls.foodcrafting.allfoods) do
                if food_item.recipepopup then
                    for _, k in ipairs({"hunger", "health", "sanity", "name"}) do
                        if food_item.recipepopup[k] and not food_item.recipepopup[k].hovertext then
                            if k ~= "name" then food_item.recipepopup[k]:SetString('-') end
                            food_item.recipepopup[k]:SetHoverText(LOCAL_STRINGS.HOVER_TEXT_ANNOUNCE)
                        end
                    end
                end
            end
        end
        return oldOnUpdate(self, ...)
    end
end)

----------------------------------------
-- 9.4 制作栏系列 Hook
----------------------------------------

local CRAFTING_HOOKS = {
    { class = 'widgets/redux/craftingmenu_pinslot',       fn = AnnounceRecipePinSlot },
    { class = 'widgets/redux/craftingmenu_widget',        fn = function(self) return AnnounceRecipeGrid(self.recipe_grid, self.owner) end },
    { class = 'widgets/redux/craftingmenu_ingredients',   fn = AnnounceRecipeCMIngredients },
    { class = 'widgets/redux/craftingmenu_skinselector',  fn = AnnounceSkin }
}

for _, hook in ipairs(CRAFTING_HOOKS) do
    AddClassPostConstruct(hook.class, function(self)
        local target = self.recipe_grid or self
        InjectAltAccept(target, function()
            if hook.fn(self) then return true end
        end)
    end)
end

-- 制作栏分类标签页 Hook
AddClassPostConstruct("widgets/redux/craftingmenu_widget", function(self)
    if self.filter_buttons then
        for name, w in pairs(self.filter_buttons) do
            if w and w.button and w.filter_def then
                InjectAltAccept(w.button, function()
                    local filter_def = w.filter_def
                    local raw_name = string.upper(filter_def.name)
                    local loc_name = GLOBAL.STRINGS.UI.CRAFTING_FILTERS[raw_name] or filter_def.name
                    loc_name = LOCAL_STRINGS[raw_name] or loc_name

                    local debug_str = string.format("[分类代码: %s]", tostring(raw_name))

                    Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.RECIPE.FORMATS.FILTER_TAB, {
                        TAB = loc_name
                    }), nil, debug_str, GetStatementLoc("RECIPE", "FILTER_TAB"))
                    return true
                end)
            end
        end
    end
end)

----------------------------------------
-- 9.5 物品栏/装备栏槽位 Hook
----------------------------------------

for _, classname in pairs({ 'invslot', 'equipslot' }) do
    AddClassPostConstruct('widgets/' .. classname, function(self)
        InjectAltShiftAccept(self, function(w)
            local container = w.container

            -- 建筑工地容器特殊处理
            if container and container.inst and (
                container.inst.prefab == "construction_container"
                or container.inst.prefab == "construction_container_1x1"
                or container.inst:HasTag("offerconstructionsite")
                or container.inst.prefab == "enable_shadow_rift_construction_container"
            ) then
                local site = GLOBAL.ThePlayer
                    and GLOBAL.ThePlayer.components.constructionbuilderuidata
                    and GLOBAL.ThePlayer.components.constructionbuilderuidata:GetTarget()
                    or GLOBAL.TheSim:FindEntities(
                        container.inst.Transform:GetWorldPosition(), 4, { "constructionsite" }
                    )[1]

                if site and AnnounceConstructionSite(site, container, w.num) then
                    return true
                end

            -- 普通物品宣告
            elseif w.tile and w.tile.item then
                return AnnounceItem(w, classname)

            -- 空装备槽位宣告
            elseif classname == 'equipslot' then
                local slot_pos_name = GetEquipSlotName(GLOBAL.NOMU_QA.SCHEME.ITEM, w.equipslot)
                if slot_pos_name then
                    local debug_str = GLOBAL.NOMU_QA.GetContainerSlotDebugString(nil, container and container.inst, w.equipslot, "equipslot")
                    return Announce(subfmt(
                        GLOBAL.NOMU_QA.SCHEME.ITEM.FORMATS.EQUIP_SLOT_EMPTY,
                        {
                            PRONOUN = GetMapping(GLOBAL.NOMU_QA.SCHEME.ITEM, 'PRONOUN', 'I'),
                            SLOT_POS = slot_pos_name,
                            v = slot_pos_name
                        }
                    ), nil, debug_str, GetStatementLoc("ITEM", "EQUIP_SLOT_EMPTY"))
                end

            -- 容器剩余空间宣告
            elseif container and container.GetNumSlots and container.GetItems then
                local used_slots = 0
                for _ in pairs(container:GetItems()) do used_slots = used_slots + 1 end

                local inst = container.inst
                local cont_type = inst == GLOBAL.ThePlayer and "PLAYER"
                    or (inst and inst:HasTag("inlimbo") and "INV" or "CONTAINER")
                local ui_code = classname == "invslot" and "inv" or tostring(classname)
                local debug_str = GLOBAL.NOMU_QA.GetContainerSlotDebugString(nil, inst, nil, ui_code)

                return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.SPACE.FORMATS[cont_type], {
                    COUNT = container:GetNumSlots() - used_slots,
                    CONTAINER_NAME = get_container_name(inst)
                }), nil, debug_str, GetStatementLoc("SPACE", cont_type))
            end
        end)
    end)
end

----------------------------------------
-- 9.6 礼物吐司 Hook
----------------------------------------

AddClassPostConstruct('widgets/giftitemtoast', function(self)
    local oldOnMouseButton = self.OnMouseButton

    function self:OnMouseButton(button, down, ...)
        local ret = oldOnMouseButton(self, button, down, ...)
        if button == MOUSEBUTTON_LEFT and down and GLOBAL.QA_UTILS.IsAltPressed() then
            local fmt_name = self.enabled and "CAN_OPEN" or "NEED_SCIENCE"
            Announce(GLOBAL.NOMU_QA.SCHEME.GIFT.FORMATS[fmt_name], nil, nil, GetStatementLoc("GIFT", fmt_name))
        end
        return ret
    end
end)

----------------------------------------
-- 9.7 玩家状态屏幕 Hook
----------------------------------------

HookClassAltAccept('screens/playerstatusscreen', function(self)
    -- 服务器名称
    if self.servertitle and self.servertitle.focus then
        return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.SERVER.FORMATS.NAME, {
            NAME = self.servertitle:GetString()
        }), nil, nil, GetStatementLoc("SERVER", "NAME"))
    end

    -- 服务器天数
    if self.serverstate and self.serverstate.focus then
        return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.SERVER.FORMATS.AGE, {
            AGE = self.serverage
        }), nil, nil, GetStatementLoc("SERVER", "AGE"))
    end

    -- 玩家人数
    if self.players_number and self.players_number.focus then
        return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.SERVER.FORMATS.NUM_PLAYER, {
            NUM = self.players_number:GetString()
        }), nil, nil, GetStatementLoc("SERVER", "NUM_PLAYER"))
    end

    -- 遍历玩家列表
    for _, w in ipairs(self.player_widgets) do
        if w.focus and w.displayName then
            -- 玩家名称
            if w.name and w.name.focus then
                return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.GREET, {
                    NAME = w.displayName
                }), nil, nil, GetStatementLoc("PLAYER", "GREET"))
            end

            -- 管理员徽章
            if w.adminBadge and w.adminBadge.shown and w.adminBadge.focus then
                return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.ADMIN, {
                    NAME = w.displayName
                }), nil, nil, GetStatementLoc("PLAYER", "ADMIN"))
            end

            -- 网络性能
            if w.perf and w.perf.shown and w.perf.focus then
                local ClientObjs = GLOBAL.TheNet:GetClientTable() or {}
                local client = nil
                for _, c in ipairs(ClientObjs) do
                    if c.userid == w.userid then client = c; break end
                end

                local status_key = 'UNKNOWN'
                if client then
                    local score = client.performance ~= nil and client.performance or client.netscore
                    if score ~= nil then
                        if score <= 0 then status_key = 'GOOD'
                        elseif score == 1 then status_key = 'OK'
                        else status_key = 'BAD' end
                    end
                end

                local qa = GLOBAL.NOMU_QA.SCHEME.PLAYER
                local status_str = (qa.MAPPINGS and qa.MAPPINGS.DEFAULT
                    and qa.MAPPINGS.DEFAULT.PERF_STATUS
                    and qa.MAPPINGS.DEFAULT.PERF_STATUS[status_key])
                    or (GLOBAL.STRINGS.DEFAULT_NOMU_QA.PLAYER.MAPPINGS.DEFAULT.PERF_STATUS[status_key])

                return Announce(subfmt(qa.FORMATS.PERF, {
                    NAME = w.displayName,
                    STATUS = status_str,
                    PING = (w.userid == GLOBAL.ThePlayer.userid
                        and subfmt(qa.FORMATS.PING, { PING = GLOBAL.TheNet:GetAveragePing() })
                        )
                        or (GLOBAL.rawget(GLOBAL, "SayAboutYourPing_PlayerPings") and w.userid and GLOBAL.SayAboutYourPing_PlayerPings[w.userid]
                        and subfmt(qa.FORMATS.PING, { PING = GLOBAL.SayAboutYourPing_PlayerPings[w.userid] })
                        )
                        or ''
                }), nil, nil, GetStatementLoc("PLAYER", "PERF"))
            end

            -- 角色头像/选择状态
            if w.profileFlair and w.profileFlair.shown and w.profileFlair.focus and w.characterBadge then
                local prefab = w.characterBadge.prefabname
                local is_connecting = type(w.characterBadge.IsLoading) == "function" and w.characterBadge:IsLoading()
                
                if is_connecting then
                    -- 只要在加载，就是连接中
                    return Announce(subfmt(
                        GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.CONNECTING, 
                        { NAME = w.displayName }
                    ), nil, nil, GetStatementLoc("PLAYER", "CONNECTING"))
                elseif not prefab or prefab == "" then
                    -- 加载完成，但没有角色代码，说明在选人界面
                    return Announce(subfmt(
                        GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.CHOOSING, 
                        { NAME = w.displayName }
                    ), nil, nil, GetStatementLoc("PLAYER", "CHOOSING"))
                else
                    -- 正常游玩状态
                    return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.NAME, {
                        NAME = w.displayName,
                        CHARACTER = GLOBAL.STRINGS.NAMES[prefab:upper()] or prefab
                    }), nil, nil, GetStatementLoc("PLAYER", "NAME"))
                end
            end

            -- 游玩天数
            if w.age and w.age.shown and w.age.focus and #w.age:GetString() > 0 then
                return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.AGE, {
                    NAME = w.displayName,
                    AGE = w.age:GetString()
                }), nil, nil, GetStatementLoc("PLAYER", "AGE"))
            end
        end
    end
end)

-- 玩家状态屏幕悬浮提示注入
AddClassPostConstruct('screens/playerstatusscreen', function(self)
    local oldOnUpdate = self.OnUpdate

    function self:OnUpdate(...)
        for _, v in ipairs({self.servertitle, self.serverstate, self.players_number}) do
            if v and not v.hovertext then
                v:SetHoverText(LOCAL_STRINGS.HOVER_TEXT_ANNOUNCE)
            end
        end
        for _, widget in ipairs(self.player_widgets) do
            if widget.age and not widget.age.hovertext then
                widget.age:SetHoverText(LOCAL_STRINGS.HOVER_TEXT_ANNOUNCE)
            end
        end
        return oldOnUpdate(self, ...)
    end
end)

----------------------------------------
-- 9.8 Redux 玩家列表 Hook
----------------------------------------

AddClassPostConstruct("widgets/redux/playerlist", function(self)
    local old_BuildPlayerList = self.BuildPlayerList

    function self:BuildPlayerList(players, nextWidgets)
        if old_BuildPlayerList then old_BuildPlayerList(self, players, nextWidgets) end

        -- 玩家人数按钮 Hook
        if self.players_number and not self.players_number._qa_hooked then
            self.players_number._qa_hooked = true
            self.players_number:SetClickable(true)
            self.players_number:SetHoverText(LOCAL_STRINGS.HOVER_TEXT_ANNOUNCE)

            InjectAltAccept(self.players_number, function()
                local ClientObjs = GLOBAL.TheNet:GetClientTable() or {}
                local actual_players = 0
                for _, v in ipairs(ClientObjs) do
                    if v.performance == nil then actual_players = actual_players + 1 end
                end
                if GLOBAL.TheNet:GetServerIsClientHosted() then
                    actual_players = #ClientObjs
                end

                local max_players = GLOBAL.TheNet:GetServerMaxPlayers() or "?"
                Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.SERVER.FORMATS.NUM_PLAYER, {
                    NUM = tostring(actual_players) .. "/" .. tostring(max_players)
                }), nil, nil, GetStatementLoc("SERVER", "NUM_PLAYER"))
                return true
            end)
        end

        -- 玩家列表子项 Hook
        if self.scroll_list and self.scroll_list.widgets_to_update then
            for _, w in ipairs(self.scroll_list.widgets_to_update) do
                if not w._qa_hooked then
                    w._qa_hooked = true

                    local function HookChild(child, action_type, widget_row)
                        if not child then return end
                        child:SetClickable(true)
                        child:SetHoverText(LOCAL_STRINGS.HOVER_TEXT_ANNOUNCE)

                        InjectAltAccept(child, function(ui)
                            local qa = GLOBAL.NOMU_QA.SCHEME.PLAYER
                            local client = GLOBAL.TheNet:GetClientTableForUser(widget_row.userid)
                            local target_name = client and client.name or LOCAL_STRINGS.UNKNOWN_NAME

                            if action_type == "netscore" then
                                local status_key = 'UNKNOWN'
                                if client then
                                    local score = client.performance ~= nil and client.performance or client.netscore
                                    if score ~= nil then
                                        if score <= 0 then status_key = 'GOOD'
                                        elseif score == 1 then status_key = 'OK'
                                        else status_key = 'BAD' end
                                    end
                                end
                                local status_str = qa.MAPPINGS and qa.MAPPINGS.DEFAULT
                                    and qa.MAPPINGS.DEFAULT.PERF_STATUS
                                    and qa.MAPPINGS.DEFAULT.PERF_STATUS[status_key] or '未知'
                                Announce(subfmt(qa.FORMATS.PERF, {
                                    NAME = target_name, STATUS = status_str,
                                    PING = (widget_row.userid == GLOBAL.TheNet:GetUserID()
                                        and subfmt(qa.FORMATS.PING, { PING = GLOBAL.TheNet:GetAveragePing() })
                                        or '')
                                }), nil, nil, GetStatementLoc("PLAYER", "PERF"))

                            elseif action_type == "characterBadge" then
                                local badge = widget_row.characterBadge
                                local prefab = badge and badge.prefabname or ""
                                local is_loading = badge and type(badge.IsLoading) == "function" and badge:IsLoading()
                                if is_loading then
                                    Announce(subfmt(qa.FORMATS.CONNECTING, { NAME = target_name }), nil, nil, GetStatementLoc("PLAYER", "CONNECTING"))
                                elseif prefab == "" then
                                    Announce(subfmt(qa.FORMATS.CHOOSING, { NAME = target_name }), nil, nil, GetStatementLoc("PLAYER", "CHOOSING"))
                                else
                                    Announce(subfmt(qa.FORMATS.NAME, {
                                        NAME = target_name,
                                        CHARACTER = GLOBAL.STRINGS.NAMES[prefab:upper()] or prefab
                                    }), nil, nil, GetStatementLoc("PLAYER", "NAME"))
                                end

                            elseif action_type == "adminBadge" then
                                Announce(subfmt(qa.FORMATS.ADMIN, { NAME = target_name }), nil, nil, GetStatementLoc("PLAYER", "ADMIN"))

                            elseif action_type == "name" then
                                Announce(subfmt(qa.FORMATS.GREET, { NAME = target_name }), nil, nil, GetStatementLoc("PLAYER", "GREET"))
                            end

                            return true
                        end)
                    end

                    HookChild(w.netscore, "netscore", w)
                    HookChild(w.characterBadge, "characterBadge", w)
                    HookChild(w.adminBadge, "adminBadge", w)
                    HookChild(w.name, "name", w)
                end
            end
        end
    end
end)

----------------------------------------
-- 9.9 玩家头像弹窗 Hook
----------------------------------------

HookClassAltAccept('widgets/playeravatarpopup', function(self)
    if not self.player_name then return false end

    -- 游玩天数
    if self.age and self.age.focus and self.currentcharacter then
        return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.AGE_SHORT, {
            NAME = self.player_name, AGE = self.age:GetString()
        }), nil, nil, GetStatementLoc("PLAYER", "AGE_SHORT"))
    end

    -- 角色名称
    if self.character_name and self.character_name.focus and self.currentcharacter then
        return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.NAME, {
            NAME = self.player_name,
            CHARACTER = STRINGS.NAMES[self.currentcharacter:upper()] or self.currentcharacter
        }), nil, nil, GetStatementLoc("PLAYER", "NAME"))
    end

    -- 勋章/背景/装备等各部位
    if self.puppet and self.puppet.rank and self.puppet.rank.focus
        and self.puppet.rank.flair and self.puppet.rank.flair.hovertext then
        return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.BADGE, {
            NAME = self.player_name,
            BADGE = self.puppet.rank.flair.hovertext:GetString()
        }), nil, nil, GetStatementLoc("PLAYER", "BADGE"))
    end

    if self.puppet and self.puppet.frame and self.puppet.frame.focus
        and self.puppet.frame.bg and self.puppet.frame.bg.hovertext then
        return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.BACKGROUND, {
            NAME = self.player_name,
            BACKGROUND = self.puppet.frame.bg.hovertext:GetString()
        }), nil, nil, GetStatementLoc("PLAYER", "BACKGROUND"))
    end

    local items = { 'body', 'hand', 'legs', 'feet', 'base', 'head_equip', 'hand_equip', 'body_equip' }
    for _, item in ipairs(items) do
        if self[item .. '_image'] and self[item .. '_image'].focus then
            local upper_item = item:upper()
            return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS[upper_item], {
                NAME = self.player_name,
                [upper_item] = self[item .. '_image']._text:GetString()
            }), nil, nil, GetStatementLoc("PLAYER", upper_item))
        end
    end
end)

-- 玩家头像弹窗悬浮提示注入
AddClassPostConstruct('widgets/playeravatarpopup', function(self)
    local items = { 'body', 'hand', 'legs', 'feet', 'base', 'head_equip', 'hand_equip', 'body_equip' }

    if self.age and not self.age.hovertext then
        self.age:SetHoverText(LOCAL_STRINGS.HOVER_TEXT_ANNOUNCE)
    end

    for _, item in ipairs(items) do
        if self[item .. '_image'] and self[item .. '_image']._text
            and not self[item .. '_image']._text.hovertext then
            self[item .. '_image']._text:SetHoverText(LOCAL_STRINGS.HOVER_TEXT_ANNOUNCE)
        end
    end
end)

----------------------------------------
-- 9.10 技能树 Hook
----------------------------------------

HookClassAltAccept('widgets/redux/skilltreebuilder', function(self)
    local name = (type(self.fromfrontend) == "table" and self.fromfrontend.data
        and self.fromfrontend.data.name and self.fromfrontend.data.name ~= "")
        and self.fromfrontend.data.name
        or (self.player_name and self.player_name ~= "" and self.player_name
            or (GLOBAL.TheFrontEnd:GetActiveScreen()
                and GLOBAL.TheFrontEnd:GetActiveScreen().player_name or "该玩家"))

    -- XP 总量宣告
    if self.root
        and ((self.root.xpicon and self.root.xpicon.focus)
            or (self.root.xptotal and self.root.xptotal.focus)
            or (self.root.xp_tospend and self.root.xp_tospend.focus))
        and self.root.xptotal and self.root.xptotal:GetString() then

        return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.SKILL_TREE.FORMATS.XP, {
            NAME = name, XP = self.root.xptotal:GetString()
        }), nil, nil, GetStatementLoc("SKILL_TREE", "XP"))
    end

    -- 技能节点宣告
    for k, v in pairs(self.skillgraphics) do
        if v.button and v.button.focus and v.status
            and self.skilltreedef and self.skilltreedef[k] and self.skilltreedef[k].title then

            local fmt_name = v.status.activated and "ACTIVATED"
                or (v.status.activatable and "CAN_ACTIVATE" or "NOT_ACTIVATED")

            return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.SKILL_TREE.FORMATS[fmt_name], {
                NAME = name, SKILL = self.skilltreedef[k].title
            }), nil, nil, GetStatementLoc("SKILL_TREE", fmt_name))
        end
    end
end)

-- 技能树描述面板 Hook
AddClassPostConstruct('widgets/redux/skilltreebuilder', function(self)
    if self.infopanel and self.infopanel.desc and not self.infopanel.desc.hovertext then
        self.infopanel.desc:SetHoverText(LOCAL_STRINGS.HOVER_TEXT_ANNOUNCE)

        InjectAltAccept(self.infopanel.desc, function(desc_self)
            local name = (type(self.fromfrontend) == "table" and self.fromfrontend.data
                and self.fromfrontend.data.name and self.fromfrontend.data.name ~= "")
                and self.fromfrontend.data.name
                or (self.player_name and self.player_name ~= "" and self.player_name
                    or (GLOBAL.TheFrontEnd:GetActiveScreen()
                        and GLOBAL.TheFrontEnd:GetActiveScreen().player_name or "该玩家"))

            local desc_str = desc_self:GetString()
            local title_str = self.infopanel.title and self.infopanel.title:GetString() or "未知技能"

            if desc_str and desc_str ~= "" then
                desc_str = desc_str:gsub("\n", ""):gsub("\t", "")
                Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.SKILL_TREE.FORMATS.DESC, {
                    NAME = name, SKILL = title_str, DESC = desc_str
                }), nil, nil, GetStatementLoc("SKILL_TREE", "DESC"))
                return true
            end
        end)
    end
end)

----------------------------------------
-- 9.11 世界设置 / Mod 配置 / 启用列表 Hook
----------------------------------------

-- 世界设置列表
AddClassPostConstruct("widgets/redux/worldsettings/settingslist", function(self)
    local old_MakeScrollList = self.MakeScrollList

    function self:MakeScrollList(...)
        local res = old_MakeScrollList(self, ...)
        if GLOBAL.TheWorld == nil then return res end

        HookScrollListWidgets(self.scroll_list,
            function(widget)
                local targets = {}
                if widget.opt_spinner and widget.opt_spinner.image then
                    table.insert(targets, widget.opt_spinner.image)
                end
                if widget.opt_textentry and widget.opt_textentry.image then
                    table.insert(targets, widget.opt_textentry.image)
                end
                return targets
            end,
            function(widget)
                local data = widget.data
                if data and data.option then
                    local val_str = "未知"
                    local real_value = (GLOBAL.TheWorld and GLOBAL.TheWorld.topology
                        and GLOBAL.TheWorld.topology.overrides
                        and GLOBAL.TheWorld.topology.overrides[data.option.name])
                        or data.saved_value or data.initial_value or data.value

                    if widget.opt_spinner and widget.opt_spinner.spinner then
                        local spinner = widget.opt_spinner.spinner
                        if real_value ~= nil and spinner.options then
                            for _, opt in ipairs(spinner.options) do
                                if opt.data == real_value then val_str = opt.text; break end
                            end
                        end
                        if val_str == "未知" and type(spinner.GetSelectedText) == "function" then
                            val_str = spinner:GetSelectedText()
                        end
                    elseif widget.opt_textentry and widget.opt_textentry.textbox then
                        val_str = real_value ~= nil and tostring(real_value)
                            or widget.opt_textentry.textbox:GetString()
                    end

                    local name_str = GLOBAL.STRINGS.UI.CUSTOMIZATIONSCREEN[string.upper(data.option.name)]
                        or data.option.name

                    Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.SERVER.FORMATS.WORLD_SETTING, {
                        SETTING = name_str, VALUE = val_str
                    }), nil, nil, GetStatementLoc("SERVER", "WORLD_SETTING"))
                    return true
                end
            end,
            50, 50
        )

        return res
    end
end)

-- Mod 配置屏幕
AddClassPostConstruct("screens/redux/modconfigurationscreen", function(self)
    if GLOBAL.TheWorld == nil then return end

    HookScrollListWidgets(self.options_scroll_list,
        function(widget)
            return (widget.opt and widget.opt.label) and {widget.opt.label} or {}
        end,
        function(widget)
            local data = widget.opt.data
            if data and data.option then
                local val_str = "未知"
                local real_value = nil

                -- 从服务器列表中获取实际配置值
                local server_listing = GLOBAL.TheNet:GetServerListing()
                if server_listing and type(server_listing.mods_config_data) == "string" then
                    local mod_config_data = server_listing._processed_mods_config_data
                    if mod_config_data == nil and GLOBAL.RunInSandboxSafe then
                        local success, parsed = GLOBAL.RunInSandboxSafe(server_listing.mods_config_data)
                        if success and type(parsed) == "table" then
                            server_listing._processed_mods_config_data = parsed
                            mod_config_data = parsed
                        end
                    end
                    if type(mod_config_data) == "table" and mod_config_data[self.modname] ~= nil then
                        real_value = mod_config_data[self.modname][data.option.name]
                    end
                end

                if real_value ~= nil then
                    if data.spin_options then
                        for _, opt in ipairs(data.spin_options) do
                            if opt.data == real_value then val_str = tostring(opt.text); break end
                        end
                    end
                    if val_str == "未知" then val_str = tostring(real_value) end
                else
                    if widget.opt.spinner and type(widget.opt.spinner.GetSelectedText) == "function" then
                        val_str = widget.opt.spinner:GetSelectedText()
                    else
                        local val = data.selected_value
                        if widget.opt.spinner and type(widget.opt.spinner.GetSelected) == "function" then
                            val = widget.opt.spinner:GetSelected()
                        end
                        if data.spin_options then
                            for _, opt in ipairs(data.spin_options) do
                                if opt.data == val then val_str = tostring(opt.text); break end
                            end
                        end
                        if val_str == "未知" then val_str = tostring(val) end
                    end
                end

                local modinfo = GLOBAL.KnownModIndex:GetModInfo(self.modname)
                local mod_name = modinfo and modinfo.name or self.modname
                local setting_name = data.option.label or data.option.name

                Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.SERVER.FORMATS.MOD_SETTING, {
                    MOD = mod_name, SETTING = setting_name, VALUE = val_str
                }), nil, nil, GetStatementLoc("SERVER", "MOD_SETTING"))
                return true
            end
        end,
        300, 40
    )
end)

-- Mod 启用列表
AddClassPostConstruct("screens/redux/textlistpopup", function(self)
    if GLOBAL.TheWorld == nil then return end

    HookScrollListWidgets(self.scroll_list,
        function(widget) return {widget} end,
        function(widget)
            local mod_name = ""
            if type(widget.GetText) == "function" then
                mod_name = widget:GetText()
            elseif widget.text and type(widget.text.GetString) == "function" then
                mod_name = widget.text:GetString()
            end

            if mod_name and mod_name ~= "" then
                local announce_msg = subfmt(GLOBAL.NOMU_QA.SCHEME.SERVER.FORMATS.MOD_ENABLED, {
                    MOD = mod_name
                })
                Announce(announce_msg, nil, nil, GetStatementLoc("SERVER", "MOD_ENABLED"))
                return true
            end
        end
    )
end)

----------------------------------------
-- 9.12 烹饪书 Hook
----------------------------------------

HookClassAltAccept('widgets/redux/cookbookpage_crockpot', function(self)
    if self.nomu_qa_data and self.details_root and self.details_root.focus then
        local data = self.nomu_qa_data
        return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.COOK.FORMATS.FOOD, {
            NAME = data.name,
            HUNGER = data.recipe_def.hunger ~= nil and math.floor(10 * data.recipe_def.hunger) / 10 or '-',
            SANITY = data.recipe_def.sanity ~= nil and math.floor(10 * data.recipe_def.sanity) / 10 or '-',
            HEALTH = data.recipe_def.health ~= nil and math.floor(10 * data.recipe_def.health) / 10 or '-'
        }), nil, nil, GetStatementLoc("COOK", "FOOD"))
    end
end)

AddClassPostConstruct('widgets/redux/cookbookpage_crockpot', function(self)
    local oldPopulateRecipeDetailPanel = self.PopulateRecipeDetailPanel

    function self:PopulateRecipeDetailPanel(data, ...)
        self.nomu_qa_data = data
        return oldPopulateRecipeDetailPanel(self, data, ...)
    end

    self.nomu_qa_data = self.all_recipes[
        (TheCookbook.selected ~= nil and TheCookbook.selected[self.category] or 1)
    ]
end)

----------------------------------------
-- 9.13 设置面板开关与 ModUtil 集成
----------------------------------------

local controls

AddClassPostConstruct("widgets/controls", function(self)
    controls = self
    if controls and controls.top_root then
        controls.nomu_qa_panel = controls.top_root:AddChild(GLOBAL.NOMU_QA.QAPanel())
        controls.nomu_qa_panel:Hide()
    end
end)

-- 键盘快捷键切换面板
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

if QUNNIAO_ON then
    local state, m_util = GLOBAL.pcall(GLOBAL.require, "util/modutil")
    if state and type(m_util) == "table" and m_util.AddBindIcon then
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

        m_util:AddBindIcon(
            "快捷宣告",
            "playbill_the_veil",
            STRINGS.LMB .. "打开设置" .. STRINGS.RMB .. "切换风格",
            false,
            ToggleQAPanel,
            SwitchAnnounceScheme
        )
    end
end

----------------------------------------
-- 9.15 操作阻断（防止误触）
----------------------------------------

AddComponentPostInit("playercontroller", function(self)
    local old_OnControl = self.OnControl

    function self:OnControl(control, down, ...)
        -- 在宣告快捷键按下时阻断主/副操作
        if GLOBAL.NOMU_QA.DATA.BLOCK_ACTION
            and (control == GLOBAL.CONTROL_PRIMARY or control == GLOBAL.CONTROL_SECONDARY) then
            if IsDefaultScreen() and GLOBAL.QA_UTILS.IsAltPressed() and GLOBAL.QA_UTILS.IsShiftPressed() then
                return true
            end
        end

        if old_OnControl then
            return old_OnControl(self, control, down, ...)
        end
    end
end)
