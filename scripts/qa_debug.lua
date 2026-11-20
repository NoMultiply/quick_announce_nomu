if not GLOBAL.NOMU_QA then GLOBAL.NOMU_QA = {} end
local PREFAB_MOD_CACHE, BUILD_CACHE = {}, {}

local function GetDebugStrings()
    local S = GLOBAL.STRINGS.NOMU_QA or {}
    return S, S.DEBUG or {}
end

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
    local LOCAL_STRINGS, D = GetDebugStrings()
    local NONE = D.NONE or "无"
    if not entity then return D.ENTITY_NOT_EXIST end

    local debug_str = entity.entity and type(entity.entity.GetDebugString) == "function" and entity.entity:GetDebugString() or ""
    
    local tags = debug_str:match("Tags:%s*([^\n\r]*)") or NONE
    tags = tags:gsub("%s*Prefab:.*$", ""):gsub("%s*AnimState:.*$", ""):gsub("^%s*(.-)%s*$", "%1")
    if tags == "" then tags = NONE end

    local bank = debug_str:match("bank:%s*(%S+)") or NONE
    local build = debug_str:match("build:%s*(%S+)") or NONE
    local anim = debug_str:match("anim:%s*(%S+)") or NONE
    local anim_str = (bank == NONE and build == NONE and anim == NONE) and NONE or string.format("Bank: %s, Build: %s, Anim: %s", bank, build, anim)

    local guid = entity.GUID or NONE
    local px, py, pz = 0, 0, 0
    if entity.Transform then px, py, pz = entity.Transform:GetWorldPosition() end
    local rep_list = {}
    if entity.replica then
        for k, v in pairs(entity.replica) do
            if type(k) == "string" and k ~= "_ent" and k ~= "_components" and type(v) == "table" then table.insert(rep_list, k) end
        end
    end
    table.sort(rep_list)

    local raw_display = type(entity.GetDisplayName) == "function" and entity:GetDisplayName() or NONE
    local actual_prefab = tostring(entity.prefabnameoverride or entity.nameoverride or entity.prefab)
    local upper_prefab = string.upper(actual_prefab)

    local raw_basic = (GLOBAL.STRINGS.NAMES[upper_prefab] and tostring(GLOBAL.STRINGS.NAMES[upper_prefab])) or actual_prefab
    local raw_qa = LOCAL_STRINGS[upper_prefab] or NONE
    local raw_override = entity.nameoverride or NONE
    
    local fmt = D.ENTITY_FMT
    return string.format(fmt,
        tostring(entity.prefab),
        extra_prefix and (extra_prefix .. " ") or "",
        string.gsub(tostring(raw_display), "\n", " "),
        string.gsub(tostring(raw_basic), "\n", " "),
        string.gsub(tostring(raw_qa), "\n", " "),
        tostring(raw_override), tags, anim_str,
        tostring(guid), px, py, pz,
        #rep_list > 0 and table.concat(rep_list, ", ") or NONE
    )
end

local function GetUIDebugString(widget, status_table, controls_table)
    if not (GLOBAL.NOMU_QA.DATA and GLOBAL.NOMU_QA.DATA.DEBUG_MODE) then return nil end
    local _, D = GetDebugStrings()
    local NONE = D.NONE
    if not (widget and widget.widget) then return D.UI_INVALID end
    
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
    local parent_name = (original_w.parent and original_w.parent.name) or NONE
    
    local text_str = NONE
    if type(original_w.GetString) == "function" then
        text_str = original_w:GetString()
    elseif original_w.text and type(original_w.text) == "table" and type(original_w.text.GetString) == "function" then
        text_str = original_w.text:GetString()
    end
    if type(text_str) == "string" then text_str = text_str:gsub("\n", " ") end
    if text_str == "" then text_str = NONE end
    
    local hover_str = NONE
    if type(original_w.GetHoverText) == "function" then
        hover_str = original_w:GetHoverText() or NONE
    end
    
    local sx, sy = 0, 0
    if type(original_w.GetWorldPosition) == "function" then
        local pos = original_w:GetWorldPosition()
        if pos then sx, sy = pos.x, pos.y end
    end

    local fmt = D.UI_FMT
    return string.format(fmt, 
        tostring(ui_code), tostring(raw_name), tostring(parent_name), tostring(text_str), tostring(hover_str), sx, sy)
end

local function GetContainerSlotDebugString(item, container_inst, slot_name, ui_code, extra_info)
    if not (GLOBAL.NOMU_QA.DATA and GLOBAL.NOMU_QA.DATA.DEBUG_MODE) then return nil end
    local _, D = GetDebugStrings()

    local debug_txt = ""
    if item then
        local prefix = slot_name and string.format(D.SLOT_PREFIX, tostring(slot_name)) or ""
        debug_txt = GetEntityDebugString(item, prefix) or ""
    end
    if container_inst then
        local prefix = D.OWNER_CONTAINER
        if ui_code then prefix = prefix .. string.format(D.UI_CODE_TAG, tostring(ui_code)) end
        if slot_name then prefix = prefix .. string.format(D.SLOT_TAG, tostring(slot_name)) end
        if extra_info then prefix = prefix .. " " .. tostring(extra_info) end

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

        local hud_ent = GLOBAL.TheInput:GetHUDEntityUnderMouse()
        local target = nil
        local ing_prefab = nil

        if hud_ent and hud_ent.widget then
            local w = hud_ent.widget

            if w.parent ~= nil and w.parent.item then
                target = w.parent.item
            else
                local curr = w
                while curr do
                    if curr.ing then
                        ing_prefab = curr.ing.texture or curr.ing.type or curr.ing.prefab
                    elseif curr.ingtype then
                        ing_prefab = curr.ingtype
                    elseif curr.ingredient then
                        ing_prefab = type(curr.ingredient) == "table" and (curr.ingredient.type or curr.ingredient.prefab) or curr.ingredient
                    end

                    if type(ing_prefab) == "string" then
                        ing_prefab = ing_prefab:gsub("%.tex$", "")
                        break
                    end
                    curr = curr.parent
                end
            end
        else
            target = GLOBAL.TheInput:GetWorldEntityUnderMouse()
        end

        local query_prefab = (target and target.prefab) or ing_prefab

        if query_prefab then
            str = str:gsub("[ \t\r\n]+$", "")

            local HIDDEN_TAG = "󰀉" 
            local LOCAL_STRINGS = GLOBAL.STRINGS.NOMU_QA or {}

            if show_mod then
                local cached_mod = GetModNameForPrefab(query_prefab)
                if cached_mod then
                    str = str .. "\n" .. HIDDEN_TAG .. (LOCAL_STRINGS.SHOW_MOD_PREFIX ) .. cached_mod
                end
            end

            if asset_mode and asset_mode > 0 then
                str = str .. "\n" .. HIDDEN_TAG .. (LOCAL_STRINGS.HOVER_PREFAB_PREFIX ):gsub("\n", "") .. query_prefab
                if asset_mode == 2 and target then
                    local bank, build = GetBuildCached(target)
                    if bank and build then
                        str = str .. "\n" .. HIDDEN_TAG .. (LOCAL_STRINGS.HOVER_BANK_PREFIX) .. bank .. (LOCAL_STRINGS.HOVER_ZIP_SUFFIX or ".zip")
                        str = str .. "\n" .. HIDDEN_TAG .. (LOCAL_STRINGS.HOVER_BUILD_PREFIX) .. build .. (LOCAL_STRINGS.HOVER_ZIP_SUFFIX or ".zip")
                    end
                end
            end
        end

        if oldSetString then
            return oldSetString(text, str, ...)
        end
    end
end)