GLOBAL.setmetatable(env, {
    __index = function(_, k)
        return GLOBAL.rawget(GLOBAL, k)
    end
})

if GLOBAL.rawget(GLOBAL, "NOMU_QA") then return end

Assets = {}

local ENABLE_MEME_SYSTEM = GetModConfigData("enable_meme_system")
if ModManager and ModManager:GetMod("workshop-3678295700") ~= nil then
    ENABLE_MEME_SYSTEM = false
end

GLOBAL.NOMU_QA = {
    ENABLE_MEME_SYSTEM = ENABLE_MEME_SYSTEM,
    MOON_DATA = {
        last_phase = nil,
        phase_start_cycle = 0,
        is_confident = false,
    },
}

local function Import(modulename)
    local f = GLOBAL.kleiloadlua(modulename)
    if f and type(f) == "function" then
        setfenv(f, GLOBAL)
        return f()
    end
end

Upvaluehelper = Import(MODROOT .. "bbgoat_upvaluehelper.lua")

modimport("scripts/qa_config/qa_default.lua")
modimport("scripts/qa_config/qa_cat.lua")
modimport("scripts/qa_config/qa_tsundere.lua")
modimport("scripts/qa_config/qa_cute.lua")
modimport("scripts/qa_config/qa_utils.lua")
modimport("scripts/qa_data.lua")
modimport("scripts/qa_debug.lua")

-- ============================================================================
local QA = GLOBAL.NOMU_QA
local LOCAL_STRINGS = GLOBAL.STRINGS.NOMU_QA or {}
local DEBUG_STR = LOCAL_STRINGS.DEBUG or {}
local escape_pattern = QA.escape_pattern

QA.SHOW_ME_ON = GLOBAL.MOD_RPC.ShowMeSHint ~= nil or GLOBAL.ModManager:GetMod("workshop-2189004162") ~= nil
QA.CURRENT_HUD_DEBUG_STR = nil

QA.ITEM_PREFAB_ALIAS = {
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

function QA.PlayMoveSound()
    local snd = GLOBAL.TheFrontEnd and GLOBAL.TheFrontEnd:GetSound()
    if snd and snd.PlaySound then
        snd:PlaySound("dontstarve/HUD/click_move")
    end
end

function QA.IsChildOf(child, parent_widget)
    while child ~= nil do
        if child == parent_widget then
            return true
        end
        child = child.parent
    end
    return false
end

function QA.EnsureTable(root, ...)
    local cur = root
    for i = 1, select("#", ...) do
        local k = select(i, ...)
        if type(cur[k]) ~= "table" then
            cur[k] = {}
        end
        cur = cur[k]
    end
    return cur
end

function QA.GetLocalizedName(prefab, fallback)
    if not prefab then return fallback end
    local upper = string.upper(tostring(prefab))
    return LOCAL_STRINGS[upper]
        or (GLOBAL.STRINGS.NAMES[upper] and tostring(GLOBAL.STRINGS.NAMES[upper]))
        or fallback
end

function QA.GetContainerSlotStats(container_rep)
    if not (container_rep and container_rep.GetNumSlots and container_rep.GetItems) then
        return 0, 0, 0
    end
    local used_slots = 0
    for _ in pairs(container_rep:GetItems() or {}) do
        used_slots = used_slots + 1
    end
    local total_slots = container_rep:GetNumSlots()
    return math.max(0, total_slots - used_slots), total_slots, used_slots
end

function QA.IsDefaultScreen()
    local active_screen = GLOBAL.TheFrontEnd:GetActiveScreen()
    if active_screen and active_screen.IsEditing and active_screen:IsEditing() then
        return false
    end
    local screen = active_screen and active_screen.name or ""
    return screen:find("HUD") ~= nil
        and GLOBAL.ThePlayer ~= nil
        and not GLOBAL.ThePlayer.HUD:IsChatInputScreenOpen()
        and not GLOBAL.ThePlayer.HUD.writeablescreen
end

function QA.CleanInsightString(clean_info)
    if not clean_info or clean_info == "" then return "" end

    clean_info = clean_info:gsub("<prefab=([^>]+)>", function(prefab)
        return QA.GetLocalizedName(prefab, prefab)
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

function QA.ApplyCustomName(prefab, fallback_name)
    if not QA.DATA.ENABLE_CUSTOM_PREFAB_NAME
        or not QA.DATA.CUSTOM_PREFAB_NAMES
        or not prefab then
        return fallback_name, false
    end

    local prefab_str = string.lower(tostring(prefab))
    for _, v in ipairs(QA.DATA.CUSTOM_PREFAB_NAMES) do
        if v.prefab and string.lower(v.prefab) == prefab_str and v.name ~= "" then
            return v.name, true
        end
    end
    return fallback_name, false
end

function QA.GetEntityName(entity, force_basic)
    if not entity then
        return LOCAL_STRINGS.UNKNOWN_NAME, LOCAL_STRINGS.UNKNOWN_NAME, false
    end

    local actual_prefab = tostring(entity.prefabnameoverride or entity.nameoverride or entity.prefab)
    local base_prefab_name = QA.GetLocalizedName(actual_prefab, actual_prefab)

    local raw_name = ""
    if not force_basic and entity.GetDisplayName and type(entity.GetDisplayName) == "function" then
        raw_name = entity:GetDisplayName() or ""
    elseif entity.GetBasicDisplayName and type(entity.GetBasicDisplayName) == "function" then
        raw_name = entity:GetBasicDisplayName() or entity.name or ""
    else
        raw_name = entity.name or ""
    end

    local original_display_name = string.match(raw_name, "[^\n]+") or raw_name
    local is_missing = (original_display_name == ""
        or string.find(string.upper(original_display_name), "MISSING")
        or string.find(string.upper(base_prefab_name), "MISSING"))
    if is_missing then original_display_name = base_prefab_name end

    local display_name = original_display_name
    local final_prefab_name = base_prefab_name
    local is_player_named = false

    if entity.prefab and string.find(entity.prefab, "sinkhole") then
        local sinkhole_name = LOCAL_STRINGS[string.upper(entity.prefab)] or LOCAL_STRINGS.SINKHOLE
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

    local custom_qa_name, has_custom = QA.ApplyCustomName(actual_prefab, base_prefab_name)
    local qa_hardcoded_name = LOCAL_STRINGS[string.upper(actual_prefab)]
    local broad_category_name = LOCAL_STRINGS.BROAD_CATEGORIES and LOCAL_STRINGS.BROAD_CATEGORIES[string.upper(actual_prefab)]

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
            if not is_player_named then
                display_name = qa_hardcoded_name
                is_player_named = true
            end
        end
    else
        final_prefab_name = base_prefab_name
        display_name = is_player_named and display_name or original_display_name
    end

    if broad_category_name then
        final_prefab_name = broad_category_name
    end
    return display_name, final_prefab_name, is_player_named
end

function QA.GetStatementLoc(func_key, sub_key)
    local func_name = (LOCAL_STRINGS.FUNC and LOCAL_STRINGS.FUNC[func_key]) or func_key
    if sub_key and sub_key ~= "" then
        return string.format("%s-%s", tostring(func_name), tostring(sub_key))
    end
    return tostring(func_name)
end

function QA.Announce(message, no_whisper, debug_info, statement_loc)
    if QA.DATA.ENABLE_REPLACE and QA.DATA.REPLACEMENTS_ESCAPED then
        for _, rule in ipairs(QA.DATA.REPLACEMENTS_ESCAPED) do
            message = message:gsub(rule.target, rule.result)
        end
    end

    message = message:gsub("(%d)\176", "%1°")

    if QA.DATA.ENABLE_FORBIDDEN and QA.DATA.FORBIDDEN_WORDS_ESCAPED then
        for _, escaped_word in ipairs(QA.DATA.FORBIDDEN_WORDS_ESCAPED) do
            message = message:gsub(escaped_word, "")
        end
    end

    local whisper = QA.DATA.DEFAULT_WHISPER ~= GLOBAL.TheInput:IsKeyDown(GLOBAL.KEY_LCTRL)
    if no_whisper then
        whisper = false
    end

    local sent = false
    if message ~= "" then
        local active_scheme = QA.ACTIVE_SCHEME or QA.DATA.CURRENT_SCHEME
        local scheme_p = active_scheme and (active_scheme.custom_prefix or (active_scheme.data and active_scheme.data.CUSTOM_PREFIX))
        local prefix = (scheme_p ~= nil and scheme_p ~= "") and scheme_p or GLOBAL.STRINGS.LMB

        local scheme_s = active_scheme and (active_scheme.custom_suffix or (active_scheme.data and active_scheme.data.CUSTOM_SUFFIX))
        local suffix = (scheme_s ~= nil and scheme_s ~= "") and scheme_s or ""

        GLOBAL.TheNet:Say(prefix .. " " .. message .. suffix, whisper)
        sent = true
    end

    if QA.DATA.DEBUG_MODE then
        local loc_tag = ""
        if statement_loc and statement_loc ~= "" then
            local stmt_fmt = DEBUG_STR.STMT_LOC
            local stmt_prefix = stmt_fmt:match("^(.-)%%s")
            loc_tag = statement_loc:find(stmt_prefix, 1, true) and statement_loc or string.format(stmt_fmt, statement_loc)
        end

        local final_debug_str = (loc_tag ~= "" and (loc_tag .. " ") or "") .. (debug_info or "")

        if QA.CURRENT_HUD_DEBUG_STR and QA.CURRENT_HUD_DEBUG_STR ~= "" then
            local first_line, rest = string.match(final_debug_str, "^([^\n]*)(\n.*)$")
            if first_line then
                final_debug_str = first_line .. " " .. QA.CURRENT_HUD_DEBUG_STR .. rest
            else
                final_debug_str = final_debug_str .. " " .. QA.CURRENT_HUD_DEBUG_STR
            end
            QA.CURRENT_HUD_DEBUG_STR = nil
        end

        if final_debug_str ~= "" then
            print("==================================================")
            print(DEBUG_STR.INFO_PREFIX .. final_debug_str)
        end
    end

    return sent
end

function QA.GetMapping(qa_scheme, category, key)
    local prefab = GLOBAL.ThePlayer and GLOBAL.ThePlayer.prefab and GLOBAL.ThePlayer.prefab:upper() or "DEFAULT"
    if QA.DATA.CHARACTER_SPECIFIC
        and qa_scheme.MAPPINGS[prefab]
        and qa_scheme.MAPPINGS[prefab][category]
        and qa_scheme.MAPPINGS[prefab][category][key] then
        return qa_scheme.MAPPINGS[prefab][category][key]
    end
    return qa_scheme.MAPPINGS.DEFAULT[category][key]
end

function QA.GetSymbolString(qa_scheme)
    local emoji_key = QA.GetMapping(qa_scheme, "SYMBOL", "EMOJI")
    if emoji_key and emoji_key ~= "" and GLOBAL.TheInventory:CheckOwnership("emoji_" .. emoji_key) then
        return ":" .. emoji_key .. ":"
    end
    return QA.GetMapping(qa_scheme, "SYMBOL", "TEXT") or ""
end

function QA.AnnounceBadge(qa_scheme, current, max, category, qa_key, custom_fmt_key)
    local fmts = {
        CURRENT = math.floor(current + 0.5),
        MAX = max,
        MESSAGE = QA.GetMapping(qa_scheme, "MESSAGE", category) or "",
        SYMBOL = QA.GetSymbolString(qa_scheme),
    }

    local fmt_key = custom_fmt_key or "DEFAULT"
    local stmt_loc = qa_key and QA.GetStatementLoc(qa_key, fmt_key) or nil
    return QA.Announce(GLOBAL.subfmt(qa_scheme.FORMATS[fmt_key] or qa_scheme.FORMATS.DEFAULT, fmts), nil, nil, stmt_loc)
end

function QA.GetCategory(thresholds, percent)
    local i = 1
    while thresholds[i] ~= nil and percent >= thresholds[i] do
        i = i + 1
    end
    return i
end

local SHOW_ME_CACHE = nil

local function IsBannedShowMeLine(str, target_name)
    if str == target_name or str:find("󰀉") then
        return true
    end

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

    local filters = QA.DATA.ENABLE_SHOWME_FILTER and QA.DATA.SHOWME_FILTERS
    if filters then
        for _, bad_word in ipairs(filters) do
            if bad_word ~= "" and str:find(bad_word) then
                return true
            end
        end
    end
    return false
end

function QA.GetShowMeString(target, qa_scheme, start_line, end_line, p3, p4)
    if not target then return "" end

    local SB = GLOBAL.rawget(GLOBAL, "SB")
    local is_gift = target:HasTag("unwrappable") or target:HasTag("bundle") or target:HasTag("gift")
        or target.prefab == "gift" or target.prefab == "bundle"
        or (target.replica and target.replica.unwrappable ~= nil)
        or (SB and SB.supported_items and SB.supported_items[target.prefab] ~= nil)

    local has_health = target:HasTag("_health") or target:HasTag("health") or (target.replica and target.replica.health ~= nil)
    local showbundle_data = target.showbundle_itemdata
    local has_showbundle = type(showbundle_data) == "table" and next(showbundle_data) ~= nil

    local show_me_mode = QA.DATA.SHOW_ME
    if (not QA.SHOW_ME_ON and not has_showbundle) or not (show_me_mode == 1 or (show_me_mode == 2 and (is_gift or has_health or has_showbundle))) then
        return ""
    end

    local items = {}
    if QA.SHOW_ME_ON then
        items = GLOBAL.QA_UTILS.ParseHoverText(start_line, end_line, p3, p4) or {}
        local insight_data = GLOBAL.ThePlayer and GLOBAL.ThePlayer.replica.insight and GLOBAL.ThePlayer.replica.insight.entity_data and GLOBAL.ThePlayer.replica.insight.entity_data[target]
        if insight_data and insight_data.information and insight_data.information ~= "" then
            for line in QA.CleanInsightString(insight_data.information):gmatch("[^\r\n]+") do
                table.insert(items, line)
            end
        end
        local hover = GLOBAL.ThePlayer and GLOBAL.ThePlayer.HUD and GLOBAL.ThePlayer.HUD.controls and GLOBAL.ThePlayer.HUD.controls.hover
        if is_gift and #items == 0 and hover then
            local hover_str = (hover.insightText and hover.insightText.raw_text and QA.CleanInsightString(hover.insightText.raw_text))
                or (hover.text and hover.text.GetString and hover.text:GetString()) or ""
            for line in hover_str:gmatch("[^\r\n]+") do
                table.insert(items, line)
            end
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
                table.insert(filtered, str)
            end
        end
    end

    if is_gift and #filtered == 0 and has_showbundle then
        for _, info in pairs(showbundle_data) do
            if type(info) == "table" and info.prefab then
                local stack = tonumber(info.stack or info.count or info.num) or 1
                local item_name = QA.ApplyCustomName(info.prefab, QA.GetLocalizedName(info.prefab, tostring(info.prefab)))
                table.insert(filtered, stack > 1 and (item_name .. "x" .. stack) or item_name)
            end
        end
    end

    if target:HasTag("farm_plant") then
        while #filtered > 2 do
            table.remove(filtered)
        end
    end

    if #filtered > 0 then
        local joined_str = ""
        for _, line in ipairs(filtered) do
            local add = (joined_str == "" and "" or ", ") .. line
            if #joined_str + #add > 125 then
                return GLOBAL.subfmt(QA.GetMapping(qa_scheme, "WORDS", "SHOW_ME"), { SHOW_ME = joined_str .. "..." })
            end
            joined_str = joined_str .. add
        end
        return GLOBAL.subfmt(QA.GetMapping(qa_scheme, "WORDS", "SHOW_ME"), { SHOW_ME = joined_str })
    end

    return ""
end

modimport("scripts/qa_world.lua")
modimport("scripts/qa_inventory.lua")
modimport("scripts/qa_hud_hooks.lua")
modimport("scripts/qa_meme.lua")
modimport("scripts/qa_panel.lua")
modimport("scripts/qa_controller.lua")

-- ============================================================================
local controls

AddClassPostConstruct("widgets/controls", function(self)
    controls = self
    if controls and controls.top_root then
        controls.nomu_qa_panel = controls.top_root:AddChild(GLOBAL.NOMU_QA.QAPanel())
        controls.nomu_qa_panel:Hide()
    end
end)

local function ToggleQAPanel()
    if GLOBAL.NOMU_QA.IsDefaultScreen() and controls and controls.nomu_qa_panel then
        controls.nomu_qa_panel:Toggle()
    end
end

local key_toggle = GetModConfigData("announcekey_toggle")
TheInput:AddKeyUpHandler(key_toggle, ToggleQAPanel)

-- 群鸟绘卷快捷图标集成
local QUNNIAO_ON = ModManager:GetMod("workshop-3161117403") ~= nil
if QUNNIAO_ON then
    local state, m_util = GLOBAL.pcall(GLOBAL.require, "util/modutil")
    if state and type(m_util) == "table" and m_util.AddBindIcon then
        local S = GLOBAL.STRINGS.NOMU_QA
        local icon_name = S.QUNNIAO_ICON_NAME

        local function OnIconLeftClick()
            local icons = m_util:GetIcons()
            if icons and icons[icon_name] then icons[icon_name].close = true end
            ToggleQAPanel()
        end

        local function OnIconRightClick()
            local icons = m_util:GetIcons()
            if icons and icons[icon_name] then icons[icon_name].close = false end

            local qadata = GLOBAL.NOMU_QA.DATA
            if not qadata or not qadata.SCHEMES or #qadata.SCHEMES == 0 then return end

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
                GLOBAL.ThePlayer.components.talker:Say(GLOBAL.subfmt(S.SCHEME_SWITCHED_MSG, { NAME = tostring(new_scheme.name) }))
            end
        end

        m_util:AddBindIcon(
            icon_name,
            "playbill_the_veil",
            S.QUNNIAO_ICON_TIP,
            false,
            OnIconLeftClick,
            OnIconRightClick
        )
    end
end

-- 世界实体目标查找
local function FindWorldTargetEntity()
    local TheInput = GLOBAL.TheInput
    local entity = GLOBAL.ConsoleWorldEntityUnderMouse and GLOBAL.ConsoleWorldEntityUnderMouse()
        or TheInput:GetWorldEntityUnderMouse()

    if entity and (entity:HasTag("NOCLICK") or entity:HasTag("FX") or entity:HasTag("DECOR")) then
        entity = nil
    end

    if not entity then
        local pos = TheInput:GetWorldPosition()
        if not pos then return nil end

        local ents = GLOBAL.TheSim:FindEntities(
            pos.x, pos.y, pos.z,
            QA.DATA.FUZZY_ANNOUNCE and 4 or 2,
            nil,
            { "INLIMBO", "player" }
        )
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

            -- 模糊匹配备选
            if QA.DATA.FUZZY_ANNOUNCE
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

    return entity
end

-- 世界实体鼠标点击宣告监听
TheInput:AddMouseButtonHandler(function(button, down)
    if not (down and QA.IsDefaultScreen() and GLOBAL.QA_UTILS.IsAltPressed() and GLOBAL.QA_UTILS.IsShiftPressed()) then
        return
    end
    if controls and controls.nomu_qa_panel and controls.nomu_qa_panel.shown then return end
    if GLOBAL.TheInput:GetHUDEntityUnderMouse() ~= nil then return end

    local entity = FindWorldTargetEntity()
    if not entity or not entity:IsValid() then return end

    if button == GLOBAL.MOUSEBUTTON_MIDDLE then
        QA.HandleEnvMiddleClick(entity)
        return true
    end

    if button == GLOBAL.MOUSEBUTTON_LEFT then
        QA.AnnounceEntity(entity, false)
        return true
    end
end)

-- 操作阻断
AddComponentPostInit("playercontroller", function(self)
    local old_OnControl = self.OnControl
    function self:OnControl(control, down, ...)
        if GLOBAL.NOMU_QA.DATA.BLOCK_ACTION
            and (control == GLOBAL.CONTROL_PRIMARY or control == GLOBAL.CONTROL_SECONDARY) then
            if GLOBAL.NOMU_QA.IsDefaultScreen() and GLOBAL.QA_UTILS.IsAltPressed() and GLOBAL.QA_UTILS.IsShiftPressed() then
                return true
            end
        end
        if old_OnControl then
            return old_OnControl(self, control, down, ...)
        end
    end
end)