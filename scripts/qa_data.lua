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

local DEFAULT_SCHEME = DeepCopy(_G.STRINGS.DEFAULT_NOMU_QA)

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

_G.NOMU_QA.ApplyScheme = function(scheme)
    if not scheme then return end
    if not scheme.data then
        print("[NoMu QA] 检测到方案数据丢失，已自动修复坏档！")
        scheme.data = DeepCopy(_G.STRINGS.DEFAULT_NOMU_QA)
    end
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
                        source_template = template.name
                    }
                    if not schemes[i] then schemes[i] = new_scheme else table.insert(schemes, i, new_scheme) end
                else
                    schemes[i].data = DeepCopy(template.source)
                    schemes[i].name = template.name
                    schemes[i].source_template = template.name
                end
            end
        end

        local current = _G.NOMU_QA.DATA.CURRENT_SCHEME
        if current then
            for _, template in ipairs(BUILTIN_SCHEMES) do
                if current.name == template.name then 
                    current.data = DeepCopy(template.source)
                    current.source_template = template.name
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