local _G = GLOBAL

_G.NOMU_QA.VERSION = 1

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
_G.NOMU_QA.DeepCopy = DeepCopy -- 尽早暴露供其他模块使用

-- 转义正则特殊字符
local function escape_pattern(text)
    return text:gsub("([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
end
_G.NOMU_QA.escape_pattern = escape_pattern

-- 提取字符串中的所有占位符并排序，用于比对
local function GetPlaceholders(str)
    local placeholders = {}
    if type(str) == "string" then
        for p in str:gmatch("{(.-)}") do placeholders[p] = true end
    end
    local sorted = {}
    for p in pairs(placeholders) do table.insert(sorted, p) end
    table.sort(sorted)
    return table.concat(sorted, ",")
end

local function IsPlaceholderMatch(str1, str2)
    return GetPlaceholders(str1) == GetPlaceholders(str2)
end

local DEFAULT_SCHEME = DeepCopy(_G.STRINGS.DEFAULT_NOMU_QA)
local MAX_HISTORY_POSITION = 20

-- 初始化 NOMU_QA 核心配置数据
_G.NOMU_QA.DATA = {
    CUSTOM_PREFIX = "",
    ALT_MODE = 1,    
    SHIFT_MODE = 1,
    DEFAULT_WHISPER = false,
    CHARACTER_SPECIFIC = true,
    FREQ_AUTO_CLOSE = true,
    SHOW_ME = 1,
    ANNOUNCE_RANGE = 40,
    FUZZY_ANNOUNCE = false,
    DISABLE_MEME_PREVIEW = false,
    SHOW_DISTANCE = 0,
    SHOW_MOD_NAME = false,
    SHOW_ASSET_INFO = 0,
    BLOCK_ACTION = true,
    ANNOUNCE_ALL_MISSING_INGREDIENTS = true,
    DEBUG_MODE = false,
    ENABLE_FORBIDDEN = true,
    ENABLE_REPLACE = true,
    MEME_FAVS = {},
    FREQ_LIST = { _G.STRINGS.NOMU_QA.FREQ_EXAMPLE },
    ENABLE_CUSTOM_PREFAB_NAME = true,
    ENABLE_SPECIAL_STATE = true,
    ENABLE_SHOWME_FILTER = true,
    CUSTOM_PREFAB_NAMES = {},
    SHOWME_FILTERS = {},
    FORBIDDEN_WORDS = {},
    REPLACEMENTS = {},
    FORBIDDEN_WORDS_ESCAPED = {}, 
    REPLACEMENTS_ESCAPED = {},
    SCHEMES = {
        {
            name = _G.STRINGS.NOMU_QA.TITLE_TEXT_DEFAULT_SCHEME,
            data = DeepCopy(_G.STRINGS.DEFAULT_NOMU_QA),
            version = _G.NOMU_QA.VERSION
        }
    },
    CURRENT_SCHEME = {
        name = _G.STRINGS.NOMU_QA.TITLE_TEXT_DEFAULT_SCHEME,
        data = DeepCopy(_G.STRINGS.DEFAULT_NOMU_QA),
        version = _G.NOMU_QA.VERSION
    }
}
_G.NOMU_QA.SCHEME = DEFAULT_SCHEME

-- 数据同步系统
local function SyncSchemeData(user_data, backup_data, source_data, is_legacy)
    if not source_data or type(source_data) ~= "table" then return end
    for k, v in pairs(source_data) do
        if type(v) == "table" then
            if type(user_data[k]) ~= "table" then user_data[k] = {} end
            if not is_legacy and type(backup_data[k]) ~= "table" then backup_data[k] = {} end
            SyncSchemeData(user_data[k], backup_data[k], v, is_legacy)
        else
            if is_legacy then
                if user_data[k] == nil or not IsPlaceholderMatch(user_data[k], v) then user_data[k] = v end
            else
                if backup_data[k] ~= v then
                    local is_user_customized = (user_data[k] ~= backup_data[k])
                    if is_user_customized then
                        if not IsPlaceholderMatch(user_data[k], v) then user_data[k] = v end
                    else
                        user_data[k] = v
                    end
                    backup_data[k] = v 
                else
                    if user_data[k] == nil or not IsPlaceholderMatch(user_data[k], v) then user_data[k] = v end
                end
            end
        end
    end

    local keys_to_remove = {}
    for k, _ in pairs(user_data) do
        if source_data[k] == nil then
            if type(source_data) == "table" and source_data.DEFAULT == nil then
                table.insert(keys_to_remove, k)
            end
        end
    end
    for _, k in ipairs(keys_to_remove) do
        user_data[k] = nil
        if not is_legacy and type(backup_data) == "table" then backup_data[k] = nil end
    end
end

local function MergeTables(dst, src)
    for k, v in pairs(src) do
        if type(v) == "table" and type(dst[k]) == "table" then
            MergeTables(dst[k], v)
        else
            dst[k] = type(v) == "table" and DeepCopy(v) or v
        end
    end
end

local function GetMergedBuiltin(target_source)
    local merged = DeepCopy(_G.STRINGS.DEFAULT_NOMU_QA)
    if target_source and target_source ~= _G.STRINGS.DEFAULT_NOMU_QA then
        MergeTables(merged, target_source)
    end
    return merged
end

_G.NOMU_QA.UpdateScheme = function(scheme_node)
    if not scheme_node or not scheme_node.data then return end

    if scheme_node.skip_sync then return end
    
    local BUILTIN_LOOKUP = {
        [_G.STRINGS.NOMU_QA.TITLE_TEXT_DEFAULT_SCHEME] = _G.STRINGS.DEFAULT_NOMU_QA,
        [_G.STRINGS.NOMU_QA.TITLE_TEXT_CAT_SCHEME] = GetMergedBuiltin(_G.STRINGS.CAT_NOMU_QA),
        [_G.STRINGS.NOMU_QA.TITLE_TEXT_TSUNDERE_SCHEME] = GetMergedBuiltin(_G.STRINGS.TSUNDERE_NOMU_QA),
        [_G.STRINGS.NOMU_QA.TITLE_TEXT_CUTE_SCHEME] = GetMergedBuiltin(_G.STRINGS.CUTE_NOMU_QA),
    }
    local is_legacy = false
    if not scheme_node.source_template and not scheme_node.backup_data then
        is_legacy = true
        if BUILTIN_LOOKUP[scheme_node.name] then
            scheme_node.source_template = scheme_node.name
            scheme_node.backup_data = DeepCopy(BUILTIN_LOOKUP[scheme_node.name])
        else
            scheme_node.source_template = _G.STRINGS.NOMU_QA.TITLE_TEXT_DEFAULT_SCHEME
            scheme_node.backup_data = DeepCopy(_G.STRINGS.DEFAULT_NOMU_QA)
        end
    end
    local source_name = scheme_node.source_template or scheme_node.name
    local source_data = BUILTIN_LOOKUP[source_name] or _G.STRINGS.DEFAULT_NOMU_QA
    SyncSchemeData(scheme_node.data, scheme_node.backup_data, source_data, is_legacy)
end

_G.NOMU_QA.ApplyScheme = function(scheme)
    if not scheme then return end
    if not scheme.data then
        print("[NoMu QA] 检测到方案数据丢失，已自动修复坏档！")
        scheme.data = DeepCopy(_G.STRINGS.DEFAULT_NOMU_QA)
    end
    _G.NOMU_QA.UpdateScheme(scheme)
    _G.NOMU_QA.SCHEME = scheme.data
end

-- 存档文件定义
local DATA_FILE = 'mod_config_data/nomu_quick_announce_v3'

_G.NOMU_QA.UpdateEscapedCaches = function()
    local data = _G.NOMU_QA.DATA
    data.FORBIDDEN_WORDS_ESCAPED = {}
    if data.FORBIDDEN_WORDS then
        for _, word in ipairs(data.FORBIDDEN_WORDS) do
            if word and word ~= "" then table.insert(data.FORBIDDEN_WORDS_ESCAPED, escape_pattern(word)) end
        end
    end
    data.REPLACEMENTS_ESCAPED = {}
    if data.REPLACEMENTS then
        for _, rule in ipairs(data.REPLACEMENTS) do
            if rule.target and rule.target ~= "" then
                table.insert(data.REPLACEMENTS_ESCAPED, { target = escape_pattern(rule.target), result = rule.result or "" })
            end
        end
    end
end

local function EnsureDataType(template_val, saved_val)
    if template_val == nil then return saved_val end 
    local t_type = type(template_val)
    local s_type = type(saved_val)
    if t_type == s_type then return saved_val end
    if t_type == "number" and s_type == "boolean" then return saved_val and 1 or 0 end
    if t_type == "boolean" and s_type == "number" then return saved_val > 0 end
    return template_val
end

_G.NOMU_QA.LoadData = function()
    _G.TheSim:GetPersistentString(DATA_FILE, function(load_success, str)
        if load_success and #str > 0 then
            local run_success, data = _G.RunInSandboxSafe(str)
            if run_success and type(data) == "table" then
                for k, template_value in pairs(_G.NOMU_QA.DATA) do
                    if data[k] ~= nil then _G.NOMU_QA.DATA[k] = EnsureDataType(template_value, data[k]) end
                end
            end
        end

        local BUILTIN_SCHEMES = {
            { name = _G.STRINGS.NOMU_QA.TITLE_TEXT_DEFAULT_SCHEME, source = _G.STRINGS.DEFAULT_NOMU_QA },
            { name = _G.STRINGS.NOMU_QA.TITLE_TEXT_CAT_SCHEME, source = GetMergedBuiltin(_G.STRINGS.CAT_NOMU_QA) },
            { name = _G.STRINGS.NOMU_QA.TITLE_TEXT_TSUNDERE_SCHEME, source = GetMergedBuiltin(_G.STRINGS.TSUNDERE_NOMU_QA) },
            { name = _G.STRINGS.NOMU_QA.TITLE_TEXT_CUTE_SCHEME, source = GetMergedBuiltin(_G.STRINGS.CUTE_NOMU_QA) }
        }

        local schemes = _G.NOMU_QA.DATA.SCHEMES
        if schemes then
            for i, template in ipairs(BUILTIN_SCHEMES) do
                if not schemes[i] or schemes[i].name ~= template.name then
                    local new_scheme = { 
                        name = template.name, 
                        data = DeepCopy(template.source), 
                        version = _G.NOMU_QA.VERSION,
                        source_template = template.name,
                        backup_data = DeepCopy(template.source)
                    }
                    if not schemes[i] then schemes[i] = new_scheme else table.insert(schemes, i, new_scheme) end
                else
                    schemes[i].data = DeepCopy(template.source)
                    schemes[i].name = template.name
                    schemes[i].source_template = template.name
                    schemes[i].backup_data = DeepCopy(template.source)
                end
            end
            for i, scheme in ipairs(schemes) do if i > 4 then _G.NOMU_QA.UpdateScheme(scheme) end end
        end

        local current = _G.NOMU_QA.DATA.CURRENT_SCHEME
        if current then
            for _, template in ipairs(BUILTIN_SCHEMES) do
                if current.name == template.name then 
                    current.data = DeepCopy(template.source)
                    current.source_template = template.name
                    current.backup_data = DeepCopy(template.source)
                    break 
                end
            end
            _G.NOMU_QA.ApplyScheme(current)
        end
        _G.NOMU_QA.UpdateEscapedCaches()
    end)
end

_G.NOMU_QA.SaveData = function()
    _G.NOMU_QA.UpdateEscapedCaches()
    _G.SavePersistentString(DATA_FILE, _G.DataDumper(_G.NOMU_QA.DATA, nil, true), false, nil)
end