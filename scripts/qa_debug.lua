if not GLOBAL.NOMU_QA then GLOBAL.NOMU_QA = {} end
local PREFAB_MOD_CACHE, BUILD_CACHE = {}, {}

local function GetModNameForPrefab(prefab)
    if not prefab then return false end
    if PREFAB_MOD_CACHE[prefab] ~= nil then return PREFAB_MOD_CACHE[prefab] end

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
    if BUILD_CACHE[inst.prefab] then
        return BUILD_CACHE[inst.prefab].bank, BUILD_CACHE[inst.prefab].build
    end

    local str = inst.entity:GetDebugString()
    if not str then return nil, nil end

    local bank, build = str:match("bank: (.+) build: (.+) anim: ")
    if bank and build then
        BUILD_CACHE[inst.prefab] = { bank = bank, build = build }
        return bank, build
    end

    return nil, nil
end

local function GetEntityDebugString(entity, extra_prefix)
    if not (GLOBAL.NOMU_QA.DATA and GLOBAL.NOMU_QA.DATA.DEBUG_MODE) then return nil end
    if not entity then return "[实体不存在]" end

    local debug_str = entity.entity and type(entity.entity.GetDebugString) == "function" and entity.entity:GetDebugString() or ""
    
    local tags = debug_str:match("Tags:%s*([^\n\r]*)") or "无"
    tags = tags:gsub("%s*Prefab:.*$", ""):gsub("%s*AnimState:.*$", ""):gsub("^%s*(.-)%s*$", "%1")
    if tags == "" then tags = "无" end

    local bank = debug_str:match("bank:%s*(%S+)") or "无"
    local build = debug_str:match("build:%s*(%S+)") or "无"
    local anim = debug_str:match("anim:%s*(%S+)") or "无"
    local anim_str = (bank == "无" and build == "无" and anim == "无") and "无" or string.format("Bank: %s, Build: %s, Anim: %s", bank, build, anim)

    local guid = entity.GUID or "无"
    local px, py, pz = 0, 0, 0
    if entity.Transform then px, py, pz = entity.Transform:GetWorldPosition() end
    local rep_list = {}
    if entity.replica then
        for k, v in pairs(entity.replica) do
            if type(k) == "string" and k ~= "_ent" and k ~= "_components" and type(v) == "table" then table.insert(rep_list, k) end
        end
    end
    table.sort(rep_list)

    local raw_display = type(entity.GetDisplayName) == "function" and entity:GetDisplayName() or "无"
    local actual_prefab = tostring(entity.prefabnameoverride or entity.nameoverride or entity.prefab)
    local upper_prefab = string.upper(actual_prefab)
    
    -- 跨文件环境获取词库
    local LOCAL_STRINGS = GLOBAL.STRINGS.NOMU_QA or {}
    
    local raw_basic = (GLOBAL.STRINGS.NAMES[upper_prefab] and tostring(GLOBAL.STRINGS.NAMES[upper_prefab])) or actual_prefab
    local raw_qa = LOCAL_STRINGS[upper_prefab] or "无"
    local raw_override = entity.nameoverride or "无"
    
    return string.format("[代码: %s] %s[Display: %s] [Basic: %s] [QA: %s] [Override: %s]\n[Tags: %s]\n[AnimState: %s]\n[GUID: %s] [坐标: (%.2f, %.2f, %.2f)]\n[Replica: %s]",
        tostring(entity.prefab),
        extra_prefix and (extra_prefix .. " ") or "",
        string.gsub(tostring(raw_display), "\n", " "),
        string.gsub(tostring(raw_basic), "\n", " "),
        string.gsub(tostring(raw_qa), "\n", " "),
        tostring(raw_override), tags, anim_str,
        tostring(guid), px, py, pz,
        #rep_list > 0 and table.concat(rep_list, ", ") or "无"
    )
end

local function GetUIDebugString(widget, status_table, controls_table)
    if not (GLOBAL.NOMU_QA.DATA and GLOBAL.NOMU_QA.DATA.DEBUG_MODE) then return nil end
    if not (widget and widget.widget) then return "[UI组件无效]" end
    
    local original_w = widget.widget
    local curr = original_w
    local ui_code = curr.name or "Unknown"
    local found = false
    
    while curr do
        if status_table then
            for k, v in pairs(status_table) do
                if v == curr and type(k) == "string" then
                    ui_code = k; found = true; break
                end
            end
        end
        if not found and controls_table then
            for k, v in pairs(controls_table) do
                if v == curr and type(k) == "string" then
                    ui_code = k; found = true; break
                end
            end
        end
        if found then break end
        curr = curr.parent
    end

    local raw_name = original_w.name or "Unknown"
    local parent_name = (original_w.parent and original_w.parent.name) or "无"
    
    local text_str = "无"
    if type(original_w.GetString) == "function" then
        text_str = original_w:GetString()
    elseif original_w.text and type(original_w.text) == "table" and type(original_w.text.GetString) == "function" then
        text_str = original_w.text:GetString()
    end
    if type(text_str) == "string" then text_str = text_str:gsub("\n", " ") end
    if text_str == "" then text_str = "无" end
    
    local hover_str = "无"
    if type(original_w.GetHoverText) == "function" then
        hover_str = original_w:GetHoverText() or "无"
    end
    
    local sx, sy = 0, 0
    if type(original_w.GetWorldPosition) == "function" then
        local pos = original_w:GetWorldPosition()
        if pos then sx, sy = pos.x, pos.y end
    end

    return string.format("[UI代码: %s] [组件: %s] [父级: %s]\n[文本: %s] [悬浮: %s]\n[屏幕坐标: (%.1f, %.1f)]", 
        tostring(ui_code), tostring(raw_name), tostring(parent_name), tostring(text_str), tostring(hover_str), sx, sy)
end

local function GetContainerSlotDebugString(item, container_inst, slot_name, ui_code)
    if not (GLOBAL.NOMU_QA.DATA and GLOBAL.NOMU_QA.DATA.DEBUG_MODE) then return nil end

    local debug_txt = ""
    if item then
        local prefix = slot_name and string.format("[槽位: %s]", tostring(slot_name)) or ""
        debug_txt = GetEntityDebugString(item, prefix) or ""
    end
    if container_inst then
        local prefix = "[归属容器]"
        if ui_code then prefix = prefix .. string.format(" [UI代码: %s]", tostring(ui_code)) end
        if not item and slot_name then prefix = prefix .. string.format(" [空槽位: %s]", tostring(slot_name)) end

        local cont_debug = GetEntityDebugString(container_inst, prefix)
        if cont_debug then
            debug_txt = (debug_txt ~= "" and (debug_txt .. "\n" .. cont_debug) or cont_debug)
        end
    end
    
    return debug_txt ~= "" and debug_txt or nil
end

GLOBAL.NOMU_QA.GetModNameForPrefab = GetModNameForPrefab
GLOBAL.NOMU_QA.GetEntityDebugString = GetEntityDebugString
GLOBAL.NOMU_QA.GetUIDebugString = GetUIDebugString
GLOBAL.NOMU_QA.GetContainerSlotDebugString = GetContainerSlotDebugString

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
            str = str:gsub("[ \t\r\n]+$", "")

            local HIDDEN_TAG = "󰀉" 
            local LOCAL_STRINGS = GLOBAL.STRINGS.NOMU_QA or {}

            if show_mod then
                local cached_mod = GetModNameForPrefab(target.prefab)
                if cached_mod then
                    str = str .. "\n" .. HIDDEN_TAG .. (LOCAL_STRINGS.SHOW_MOD_PREFIX or "Mod: ") .. cached_mod
                end
            end

            if asset_mode and asset_mode > 0 then
                str = str .. "\n" .. HIDDEN_TAG .. (LOCAL_STRINGS.HOVER_PREFAB_PREFIX or "Prefab: "):gsub("\n", "") .. target.prefab
                if asset_mode == 2 then
                    local bank, build = GetBuildCached(target)
                    if bank and build then
                        str = str .. "\n" .. HIDDEN_TAG .. (LOCAL_STRINGS.HOVER_BANK_PREFIX or "Bank: anim/"):gsub("\n", "") .. bank .. (LOCAL_STRINGS.HOVER_ZIP_SUFFIX or ".zip")
                        str = str .. "\n" .. HIDDEN_TAG .. (LOCAL_STRINGS.HOVER_BUILD_PREFIX or "Build: anim/"):gsub("\n", "") .. build .. (LOCAL_STRINGS.HOVER_ZIP_SUFFIX or ".zip")
                    end
                end
            end
        end

        if oldSetString then
            return oldSetString(text, str, ...)
        end
    end
end)