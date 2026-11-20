-- scripts/qa_controller.lua
-- 负责手柄适配

if GLOBAL.TheNet:IsDedicated() then return end

local Text = GLOBAL.require("widgets/text")
local Widget = GLOBAL.require("widgets/widget")
local Image = GLOBAL.require("widgets/image")

local QA = GLOBAL.NOMU_QA
local PlayMoveSound = QA.PlayMoveSound
local IsChildOf = QA.IsChildOf

local function SetModHUDFocus(focusid, hasfocus)
    local hud = GLOBAL.ThePlayer and GLOBAL.ThePlayer.HUD
    if hud and hud.SetModFocus then
        hud:SetModFocus("NOMU_QA", focusid, hasfocus)
    end
end

local function StopPlayerActions(inst, pc)
    if not inst then return end
    inst:ClearBufferedAction()
    if pc and pc.locomotor then
        pc.locomotor:Stop()
        pc.locomotor:Clear()
    end
    if inst.components.combat then
        inst.components.combat:SetTarget(nil)
    end
end

local function GetL3Control()
    return GLOBAL.CONTROL_MENU_MISC_3 or GLOBAL.CONTROL_AXISALIGNEDPLACEMENT_CYCLEGRID
end

local function IsL3Control(control)
    if (GLOBAL.CONTROL_MENU_MISC_3 and control == GLOBAL.CONTROL_MENU_MISC_3)
        or (GLOBAL.CONTROL_AXISALIGNEDPLACEMENT_CYCLEGRID and control == GLOBAL.CONTROL_AXISALIGNEDPLACEMENT_CYCLEGRID) then
        return true
    end
    if GLOBAL.TheInput and GLOBAL.CONTROL_AXISALIGNEDPLACEMENT_CYCLEGRID and GLOBAL.TheInput.ControlsHaveSameMapping then
        local cid = GLOBAL.TheInput:GetControllerID()
        return GLOBAL.TheInput:ControlsHaveSameMapping(cid, control, GLOBAL.CONTROL_AXISALIGNEDPLACEMENT_CYCLEGRID)
    end
    return false
end

local function SafeAnnounceSlot(slot)
    if not slot then return false end
    local classname = slot.equipslot and "equipslot" or "invslot"
    local announce_fn = QA.AnnounceSlot or QA.AnnounceItem
    return announce_fn and announce_fn(slot, classname) or false
end

local function OpenQAPanel(controls)
    if not controls or not controls.nomu_qa_panel then return end
    StopPlayerActions(GLOBAL.ThePlayer, GLOBAL.ThePlayer and GLOBAL.ThePlayer.components.playercontroller)
    controls.nomu_qa_panel:Show()
    PlayMoveSound()
end

local function IsAnyContainerOpen(inst)
    local hud = inst and inst.HUD
    if not hud then return false end
    if (hud.IsControllerInventoryOpen and hud:IsControllerInventoryOpen())
        or (hud.controls and hud.controls.inv and hud.controls.inv.open)
        or (hud.HasOpenContainerWidget and hud:HasOpenContainerWidget()) then
        return true
    end
    if hud.controls and hud.controls.containers then
        for _, c in pairs(hud.controls.containers) do
            if c and c.shown and c:IsVisible() then return true end
        end
    end
    return false
end

local function GetCurrentInteractingSlot(hud)
    if not hud or not hud.controls then return nil end

    local focus = GLOBAL.TheFrontEnd and GLOBAL.TheFrontEnd:GetFocusWidget()
    local cur, depth = focus, 0
    while cur and depth < 6 do
        depth = depth + 1
        if cur.tile or cur.equipslot or cur.container then return cur end
        cur = cur.parent
    end

    if hud.controls.inv and hud.controls.inv.active_slot then
        return hud.controls.inv.active_slot
    end

    if hud.controls.containers then
        for _, cwidget in pairs(hud.controls.containers) do
            if cwidget and cwidget.shown and cwidget:IsVisible() and cwidget.inv then
                for _, s in ipairs(cwidget.inv) do
                    if s and (s.focus or (focus and IsChildOf(focus, s))) then return s end
                end
            end
        end
    end
    return nil
end

local CONTROLLER_WHEEL_SLOTS = 8
local CONTROLLER_WHEEL_RADIUS = 245
local CONTROLLER_WHEEL_LABEL_WIDTH = 180
local CONTROLLER_WHEEL_LABEL_HEIGHT = 75
local CONTROLLER_WHEEL_TEXT_SIZE = 30
local CONTROLLER_WHEEL_CENTER_Y_OFFSET = 60

-- 智能状态收集器
local function CollectPlayerStatusEntries(inst)
    local hud = inst and inst.HUD
    local controls = hud and hud.controls
    local status = controls and controls.status
    if not (hud and controls and status) then return {} end

    local STRINGS_QA = GLOBAL.STRINGS.NOMU_QA or {}
    local F = STRINGS_QA.FUNC or {}
    local CTRL = STRINGS_QA.CONTROLLER or {}
    local entries = {}

    local function Add(name, fn)
        if name and name ~= "" and fn then
            table.insert(entries, { name = name, is_status = true, execute_fn = fn })
        end
    end

    local function AddBadge(widget, label, handler, force_visible)
        if widget and (force_visible or widget.shown) and handler then
            Add(label, function()
                widget.focus = true
                local r = handler(hud, status, { widget = widget })
                widget.focus = false
                return r
            end)
        end
    end

    local season_w = controls.seasonclock or status.season
    local naught_w = status.naughtiness or status.naughtybadge
    local modules_w = controls.secondary_status and controls.secondary_status.upgrademodulesdisplay

    local badge_defs = {
        { status.heart,                                F.HEALTH,                     QA.HandlePlayerStats },
        { status.brain,                                F.SANITY,                     QA.HandlePlayerStats },
        { status.stomach,                              F.STOMACH,                    QA.HandlePlayerStats },
        { status.moisturemeter,                        F.WETNESS,                    QA.HandlePlayerStats },
        { status.temperature,                          F.TEMPERATURE,                QA.HandleEnvironmentAndTime },
        { controls.clock,                              F.CLOCK,                      QA.HandleEnvironmentAndTime },
        { season_w,                                    F.SEASON,                     QA.HandleEnvironmentAndTime },
        { status.worldtemp,                            F.WORLD_TEMPERATURE_AND_RAIN, QA.HandleEnvironmentAndTime },
        { controls.clock and controls.clock._moonanim, F.MOON_PHASE,                 QA.HandleEnvironmentAndTime },
        { status.pethungerbadge,                       F.WOBY_HUNGER,                QA.HandlePlayerStats },
        { status.mightybadge,                          F.MIGHTINESS,                 QA.HandleSpecificMechanics },
        { status.inspirationbadge,                     F.INSPIRATION,                QA.HandleSpecificMechanics },
        { status.wereness,                             F.LOG_METER,                  QA.HandlePlayerStats },
        { status.pethealthbadge,                       F.ABIGAIL,                    QA.HandleSpecificMechanics },
        { modules_w,                                   F.ENERGY,                     QA.HandleSpecificMechanics },
        { status.bloombadge,                           F.BLOOMNESS,                  QA.HandlePlayerStats },
        { naught_w,                                    F.NAUGHTINESS,                QA.HandlePlayerStats },
        { status.fungusinfectionmeter,                 F.FUNGUS_INFECTION,           QA.HandlePlayerStats },
        { status.waterstomach,                         F.THIRST,                     QA.HandlePlayerStats },
    }
    for _, def in ipairs(badge_defs) do AddBadge(def[1], def[2], def[3]) end

    local platform = inst.GetCurrentPlatform and inst:GetCurrentPlatform()
    if (platform and platform.components.healthsyncer) or (status.boatmeter and status.boatmeter.boat) then
        AddBadge(status.boatmeter, F.BOAT, QA.HandleSpecificMechanics, true)
    end

    if controls.containers then
        for target_container, cwidget in pairs(controls.containers) do
            if target_container and target_container:IsValid() and cwidget:IsVisible() then
                local crep = target_container.replica and target_container.replica.container
                if crep and crep:GetNumSlots() > 0 then
                    Add(CTRL.OPEN_CONTAINER_SPACE, function()
                        local total_slots = crep:GetNumSlots()
                        local used_slots = 0
                        for _ in pairs(crep:GetItems() or {}) do used_slots = used_slots + 1 end
                        local c_name = (target_container.GetDisplayName and target_container:GetDisplayName())
                            or STRINGS_QA.DEFAULT_CONTAINER_NAME
                        local target_fmt = QA.SCHEME.SPACE.FORMATS.CONTAINER
                        return QA.Announce(GLOBAL.subfmt(target_fmt, {
                            COUNT = total_slots - used_slots,
                            TOTAL = total_slots,
                            CONTAINER_NAME = c_name,
                            CONTAINER_CODE = target_container.prefab or "container"
                        }))
                    end)
                    break
                end
            end
        end
    end

    local b_hud = controls.BeefaloStatusBar
    local is_riding = inst.replica.rider and inst.replica.rider:IsRiding()
    if b_hud and (is_riding or (b_hud:IsVisible() and not b_hud.isHidden)) and QA.HandleBeefaloStats then
        local beef_badges = {
            { b_hud.healthBadge,        CTRL.BEEFALO_HEALTH },
            { b_hud.hungerBadge,        CTRL.BEEFALO_HUNGER },
            { b_hud.obedienceBadge,     CTRL.BEEFALO_OBEDIENCE },
            { b_hud.domesticationBadge, CTRL.BEEFALO_DOMESTICATION },
        }
        for _, item in ipairs(beef_badges) do
            if item[1] then
                Add(item[2], function() return QA.HandleBeefaloStats(hud, status, { widget = item[1] }) end)
            end
        end
        if b_hud.timerBadge and (is_riding or (b_hud.bucktime and b_hud.bucktime > 0) or b_hud.timerBadge:IsVisible()) then
            Add(CTRL.BEEFALO_TIMER, function()
                return QA.HandleBeefaloStats(hud, status, { widget = b_hud.timerBadge })
            end)
        end
    elseif is_riding then
        local mount = inst.replica.rider:GetMount()
        if mount and mount:IsValid() and mount:HasTag("beefalo") then
            Add(CTRL.BEEFALO_HEALTH, function()
                local qa_beef = QA.SCHEME.BEEFALO
                if not qa_beef then return false end
                local pct = mount.replica.health and mount.replica.health:GetPercent() or 1
                local state = pct < 0.25 and "HEALTH_LOW" or (pct > 0.8 and "HEALTH_HIGH" or "HEALTH_NORMAL")
                local msg = GLOBAL.subfmt(qa_beef.MAPPINGS.DEFAULT.MESSAGE[state], { PCT = math.floor(pct * 100 + 0.5) })
                return QA.Announce(GLOBAL.subfmt(qa_beef.FORMATS.HEALTH, { MESSAGE = msg }))
            end)
        end
    end

    local medal_panel = (hud.owner and hud.owner.medalBuffPanel) or controls.medalBuffPanel
    if medal_panel and medal_panel.shown and QA.HandleExternalMods then
        Add(F.MEDAL_BUFF, function() return QA.HandleExternalMods(hud, status, { widget = medal_panel }) end)
    end

    return entries
end

AddClassPostConstruct("screens/playerhud", function(self)
    local function ShouldBlockSelfInspect()
        local pc = GLOBAL.ThePlayer and GLOBAL.ThePlayer.components.playercontroller
        return (self.IsControllerInventoryOpen and self:IsControllerInventoryOpen())
            or (self.controls and self.controls.inv and self.controls.inv.open)
            or (self.IsCraftingOpen and self:IsCraftingOpen())
            or (pc and pc._qa_wheel_mode)
            or (self.controls and self.controls.nomu_qa_panel and self.controls.nomu_qa_panel.shown)
    end

    local old_InspectSelf = self.InspectSelf
    function self:InspectSelf(...)
        if ShouldBlockSelfInspect() then return false end
        if old_InspectSelf then return old_InspectSelf(self, ...) end
    end

    local old_TogglePlayerInfoPopup = self.TogglePlayerInfoPopup
    function self:TogglePlayerInfoPopup(...)
        if ShouldBlockSelfInspect() then return false end
        if old_TogglePlayerInfoPopup then return old_TogglePlayerInfoPopup(self, ...) end
    end

    local old_OnControl = self.OnControl
    function self:OnControl(control, down, ...)
        if GLOBAL.TheInput:ControllerAttached() and self.controls and self.controls.nomu_qa_panel and self.controls.nomu_qa_panel.shown then
            return self.controls.nomu_qa_panel:OnControl(control, down)
        end

        local pc = GLOBAL.ThePlayer and GLOBAL.ThePlayer.components.playercontroller
        if pc and pc._qa_wheel_mode and pc._qa_handle_wheel_control and pc:_qa_handle_wheel_control(control, down) then
            return true
        end

        local is_y_key = (control == GLOBAL.CONTROL_USE_ITEM_ON_ITEM
            or control == GLOBAL.CONTROL_INVENTORY_EXAMINE
            or control == GLOBAL.CONTROL_INSPECT)

        if GLOBAL.TheInput:ControllerAttached() and is_y_key and IsAnyContainerOpen(self.owner) then
            local active_item = self.owner.replica.inventory and self.owner.replica.inventory:GetActiveItem()
            if active_item == nil then
                local slot = GetCurrentInteractingSlot(self)
                if slot then
                    if down then
                        self._qa_slot_y_held = false
                        if self._qa_slot_y_task then self._qa_slot_y_task:Cancel(); self._qa_slot_y_task = nil end
                        self._qa_slot_y_task = self.inst:DoTaskInTime(0.35, function()
                            self._qa_slot_y_held = true
                            self._qa_slot_y_task = nil
                            if pc and pc._qa_open_status_wheel then
                                pc:_qa_open_status_wheel()
                                PlayMoveSound()
                            end
                        end)
                    else
                        if self._qa_slot_y_task ~= nil then
                            self._qa_slot_y_task:Cancel()
                            self._qa_slot_y_task = nil
                            if not self._qa_slot_y_held and SafeAnnounceSlot(slot) then
                                PlayMoveSound()
                                if pc and pc._qa_swallow_controls_fn then
                                    pc:_qa_swallow_controls_fn(
                                        GLOBAL.CONTROL_USE_ITEM_ON_ITEM,
                                        GLOBAL.CONTROL_INVENTORY_EXAMINE,
                                        GLOBAL.CONTROL_INSPECT,
                                        GLOBAL.CONTROL_INSPECT_SELF
                                    )
                                end
                                StopPlayerActions(self.owner, pc)
                            end
                        end
                        self._qa_slot_y_held = false
                    end
                    return true
                end
            end
        end

        return old_OnControl and old_OnControl(self, control, down, ...)
    end
end)

AddClassPostConstruct("widgets/inventorybar", function(self)
    local old_UpdateCursorText = self.UpdateCursorText
    function self:UpdateCursorText(...)
        if old_UpdateCursorText then old_UpdateCursorText(self, ...) end
        if not (GLOBAL.TheInput:ControllerAttached() and self.open) then return end

        if self:GetCursorItem() == nil then
            if self.actionstringtitle then self.actionstringtitle:SetString("") end
            return
        end

        if self.actionstring and self.actionstring.shown then
            local STRINGS_CTRL = GLOBAL.STRINGS.NOMU_QA and GLOBAL.STRINGS.NOMU_QA.CONTROLLER or {}
            local y_btn_name = GLOBAL.TheInput:GetLocalizedControl(GLOBAL.TheInput:GetControllerID(), GLOBAL.CONTROL_USE_ITEM_ON_ITEM)
            local hint = GLOBAL.subfmt(STRINGS_CTRL.HINT_INV_ANNOUNCE, { BTN = y_btn_name })
            local current_body = self.actionstringbody:GetString() or ""
            if current_body ~= "" and not string.find(current_body, hint, 1, true) then
                self.actionstringbody:SetString(hint .. "\n" .. current_body)
            end
        end
    end
end)

AddClassPostConstruct("widgets/redux/craftingmenu_hud", function(self)
    local function AnnounceCrafting(recipe, force_ingredients)
        if not recipe or not QA.AnnounceMergedRecipe then return end
        QA.AnnounceMergedRecipe(recipe, self.owner.replica.builder, self.owner.replica.inventory, self.owner, nil, force_ingredients)
        PlayMoveSound()
        local pc = self.owner and self.owner.components.playercontroller
        if pc and pc._qa_swallow_controls_fn then pc:_qa_swallow_controls_fn(GetL3Control()) end
        StopPlayerActions(self.owner, pc)
    end

    local old_OnControl = self.OnControl
    function self:OnControl(control, down, ...)
        if GLOBAL.TheInput:ControllerAttached() and self:IsCraftingOpen() and IsL3Control(control) then
            local recipe = nil
            if self.pinbar and self.pinbar.focus then
                local pinslot = self.pinbar:GetFocusSlot()
                recipe = pinslot and pinslot.recipe_name and GLOBAL.AllRecipes[pinslot.recipe_name]
            elseif self.craftingmenu and self.craftingmenu.details_root and self.craftingmenu.details_root.data then
                recipe = self.craftingmenu.details_root.data.recipe
            end
            if not recipe and self.GetCurrentRecipeState then
                local state = self:GetCurrentRecipeState()
                recipe = state and state.recipe
            end
            if not recipe and self.GetCurrentRecipeName then
                local rname = self:GetCurrentRecipeName()
                recipe = rname and GLOBAL.AllRecipes[rname]
            end

            if recipe then
                if down then
                    if GLOBAL.TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then
                        AnnounceCrafting(recipe, true)
                        return true
                    end
                    self._qa_l3_held = false
                    if self._qa_l3_task then self._qa_l3_task:Cancel(); self._qa_l3_task = nil end
                    self._qa_l3_task = self.inst:DoTaskInTime(0.35, function()
                        self._qa_l3_held = true
                        self._qa_l3_task = nil
                        AnnounceCrafting(recipe, true)
                    end)
                else
                    if self._qa_l3_task ~= nil then
                        self._qa_l3_task:Cancel()
                        self._qa_l3_task = nil
                        if not self._qa_l3_held then AnnounceCrafting(recipe, false) end
                    end
                    self._qa_l3_held = false
                end
                return true
            end
        end
        return old_OnControl and old_OnControl(self, control, down, ...)
    end

    local old_RefreshCraftingHelpText = self.RefreshCraftingHelpText
    function self:RefreshCraftingHelpText(...)
        if old_RefreshCraftingHelpText then old_RefreshCraftingHelpText(self, ...) end
        if self.is_open and GLOBAL.TheInput:ControllerAttached() and self.nav_hint then
            local STRINGS_CTRL = GLOBAL.STRINGS.NOMU_QA and GLOBAL.STRINGS.NOMU_QA.CONTROLLER or {}
            local l3_btn = GLOBAL.TheInput:GetLocalizedControl(GLOBAL.TheInput:GetControllerID(), GetL3Control())
            local hint_add = GLOBAL.subfmt(STRINGS_CTRL.HINT_CRAFT_COMBINED, { BTN = l3_btn })
            local current_hint = self.nav_hint:GetString() or ""
            if not string.find(current_hint, hint_add, 1, true) then
                self.nav_hint:SetString(current_hint .. "   " .. hint_add)
            end
        end
    end
end)

local function IsEntityInScreen(ent)
    if not ent or not ent:IsValid() or not ent.Transform then return false end
    local wx, wy, wz
    if ent.AnimState then wx, wy, wz = ent.AnimState:GetSymbolPosition("", 0, 0, 0) end
    if wx == nil then wx, wy, wz = ent.Transform:GetWorldPosition() end
    local sx, sy = GLOBAL.TheSim:GetScreenPos(wx, wy, wz)
    local sw, sh = GLOBAL.TheSim:GetScreenSize()
    return sx and sy and sx >= 0 and sx <= sw and sy >= 0 and sy <= sh
end

AddComponentPostInit("playercontroller", function(self, inst)
    if inst ~= GLOBAL.ThePlayer then return end

    local function CancelHoldTask()
        if self._qa_hold_task then self._qa_hold_task:Cancel(); self._qa_hold_task = nil end
        self._qa_initial_focus_ent = nil
    end

    self._qa_swallow_controls_fn = function(pc, ...)
        CancelHoldTask()
        pc._qa_swallowed = pc._qa_swallowed or {}
        for i = 1, select("#", ...) do
            local ctrl = select(i, ...)
            if ctrl ~= nil then pc._qa_swallowed[ctrl] = true end
        end
        if pc._qa_swallow_task then pc._qa_swallow_task:Cancel() end
        pc._qa_swallow_task = inst:DoTaskInTime(0.35, function()
            pc._qa_swallowed = nil
            pc._qa_swallow_task = nil
        end)
    end

    local old_DoCameraControl = self.DoCameraControl
    function self:DoCameraControl(...)
        if self._qa_wheel_mode or self._qa_hold_task ~= nil then return end
        local hud = inst.HUD
        if GLOBAL.TheInput:ControllerAttached() and hud and hud.controls and hud.controls.nomu_qa_panel and hud.controls.nomu_qa_panel.shown then
            return
        end
        if old_DoCameraControl then return old_DoCameraControl(self, ...) end
    end

    local function ClearHighlight()
        if self._qa_highlight and self._qa_highlight:IsValid() and self._qa_highlight.AnimState then
            self._qa_highlight.AnimState:SetHighlightColour()
        end
        self._qa_highlight = nil
        self._qa_wheel_target = nil
        if self._qa_wheel_root then self._qa_wheel_root:Hide() end
    end

    local function ExitWheelMode()
        CancelHoldTask()
        ClearHighlight()
        SetModHUDFocus("ControllerWheel", false)
        if GLOBAL.TheCamera then GLOBAL.TheCamera:SetControllable(true) end
        self._qa_wheel_mode = false
        self._qa_wheel_type = nil
        self._qa_hold_elapsed = nil
        self._qa_wheel_targets = nil
        self._qa_wheel_index = nil
        self._qa_wheel_page = nil
    end

    local function EnsureWheelUI()
        if self._qa_wheel_root or not inst.HUD or not inst.HUD.controls then return end
        local root = inst.HUD.controls:AddChild(Widget("nomu_qa_wheel"))
        root:SetPosition(0, 0)
        root.title = root:AddChild(Text(GLOBAL.HEADERFONT, 32, ""))
        root.selected_info = root:AddChild(Text(GLOBAL.BODYTEXTFONT, 34, ""))
        root.selected_info:SetColour(1, 0.9, 0.2, 1)
        root.selected_info:SetRegionSize(520, 50)
        root.selected_info:EnableWordWrap(false)
        root.slots = {}

        for i = 1, CONTROLLER_WHEEL_SLOTS do
            local slot = root:AddChild(Widget("qa_wheel_slot_" .. i))
            slot.bg = slot:AddChild(Image("images/global.xml", "square.tex"))
            slot.bg:SetSize(CONTROLLER_WHEEL_LABEL_WIDTH, CONTROLLER_WHEEL_LABEL_HEIGHT)
            slot.bg:SetTint(0, 0, 0, 0.65)

            slot.text = slot:AddChild(Text(GLOBAL.BODYTEXTFONT, CONTROLLER_WHEEL_TEXT_SIZE, ""))
            slot.text:SetRegionSize(CONTROLLER_WHEEL_LABEL_WIDTH - 12, CONTROLLER_WHEEL_LABEL_HEIGHT - 6)
            slot.text:EnableWordWrap(true)
            slot:Hide()
            root.slots[i] = slot
        end

        root.footer = root:AddChild(Text(GLOBAL.BODYTEXTFONT, 28, ""))
        root.footer:SetRegionSize(760, 60)
        root.footer:EnableWordWrap(false)
        self._qa_wheel_root = root
        root:Hide()
    end

    local function UpdateWheelDisplay()
        EnsureWheelUI()
        local root = self._qa_wheel_root
        local entries = self._qa_wheel_targets or {}
        local selected = self._qa_wheel_index or 1
        local is_status = (self._qa_wheel_type == "STATUS")
        local STRINGS_CTRL = GLOBAL.STRINGS.NOMU_QA and GLOBAL.STRINGS.NOMU_QA.CONTROLLER or {}
        if not root or #entries == 0 then return end

        local sw, sh = GLOBAL.TheSim:GetScreenSize()
        local cx, cy = sw * 0.5, sh * 0.5 + CONTROLLER_WHEEL_CENTER_Y_OFFSET
        local page_count = math.max(1, math.ceil(#entries / CONTROLLER_WHEEL_SLOTS))
        local page = math.max(1, math.min(page_count, self._qa_wheel_page or 1))
        self._qa_wheel_page = page

        local first = (page - 1) * CONTROLLER_WHEEL_SLOTS + 1
        local count = math.min(CONTROLLER_WHEEL_SLOTS, #entries - first + 1)

        root.title:SetString(GLOBAL.subfmt(STRINGS_CTRL.WHEEL_TITLE_FMT, {
            TITLE = is_status and (STRINGS_CTRL.WHEEL_TITLE_STATUS or "") or (STRINGS_CTRL.WHEEL_TITLE_ENTITY or ""),
            INDEX = selected,
            TOTAL = #entries,
            PAGE = page,
            MAX_PAGE = page_count
        }))
        root.title:SetPosition(cx, cy + 34)

        local cur_entry = entries[selected]
        if cur_entry and root.selected_info then
            local full_sel_name = cur_entry.name .. ((not is_status and cur_entry.count and cur_entry.count > 1) and (" x" .. cur_entry.count) or "")
            root.selected_info:SetString(full_sel_name)
            root.selected_info:SetPosition(cx, cy - 8)
        end

        for slot_idx, slot in ipairs(root.slots) do
            local entry_idx = first + slot_idx - 1
            local entry = entries[entry_idx]
            if entry then
                local angle = math.pi * 0.5 - (slot_idx - 1) * math.pi * 2 / count
                slot:SetPosition(cx + math.cos(angle) * CONTROLLER_WHEEL_RADIUS, cy + math.sin(angle) * CONTROLLER_WHEEL_RADIUS)

                local item_name = entry.name .. ((not is_status and entry.count and entry.count > 1) and (" x" .. entry.count) or "")
                local ulen = item_name.utf8len and item_name:utf8len() or #item_name
                slot.text:SetSize(ulen > 8 and 25 or CONTROLLER_WHEEL_TEXT_SIZE)
                slot.text:SetString(item_name)

                if entry_idx == selected then
                    slot.bg:SetTint(0.85, 0.45, 0.1, 0.9)
                    slot.text:SetColour(1, 1, 0.3, 1)
                else
                    slot.bg:SetTint(0, 0, 0, 0.65)
                    slot.text:SetColour(1, 1, 1, 1)
                end
                slot:Show()
            else
                slot:Hide()
            end
        end

        local cid = GLOBAL.TheInput:GetControllerID()
        local footer_template = is_status and (STRINGS_CTRL.FOOTER_STATUS or "") or (STRINGS_CTRL.FOOTER_ENTITY or "")
        root.footer:SetString(GLOBAL.subfmt(footer_template, {
            A_BTN = GLOBAL.TheInput:GetLocalizedControl(cid, GLOBAL.CONTROL_ACCEPT),
            LB_BTN = GLOBAL.TheInput:GetLocalizedControl(cid, GLOBAL.CONTROL_ROTATE_LEFT),
            RB_BTN = GLOBAL.TheInput:GetLocalizedControl(cid, GLOBAL.CONTROL_ROTATE_RIGHT),
            CANCEL_BTN = GLOBAL.TheInput:GetLocalizedControl(cid, GLOBAL.CONTROL_CANCEL)
        }))
        root.footer:SetPosition(cx, cy - CONTROLLER_WHEEL_RADIUS - 55)
        root:Show()
    end

    local function SetSelectedTarget(entry)
        ClearHighlight()
        if not entry then return false end
        self._qa_wheel_target = entry.target
        if entry.target and entry.target:IsValid() then
            local h = entry.target.highlightforward or entry.target
            if h.AnimState then
                h.AnimState:SetHighlightColour(0.3, 0.3, 0.1, 0)
                self._qa_highlight = h
            end
        end
        UpdateWheelDisplay()
        return true
    end

    local function CollectNearbyEntities(focus_ent)
        local px, py, pz = inst.Transform:GetWorldPosition()
        local ents = GLOBAL.TheSim:FindEntities(px, py, pz, 30, nil, { "FX", "DECOR", "INLIMBO", "NOCLICK" })
        local list, seen = {}, {}

        if focus_ent and focus_ent:IsValid() and focus_ent ~= inst and focus_ent.prefab and focus_ent.AnimState and IsEntityInScreen(focus_ent) then
            local found = false
            for _, ent in ipairs(ents) do if ent == focus_ent then found = true; break end end
            if not found then table.insert(ents, 1, focus_ent) end
        end

        for _, ent in ipairs(ents) do
            if ent ~= inst and ent:IsValid() and ent.prefab and ent.AnimState and IsEntityInScreen(ent) then
                local raw_name = (ent.GetDisplayName and type(ent.GetDisplayName) == "function") and ent:GetDisplayName() or ent.prefab
                local key = ent.prefab .. "_" .. raw_name
                local s = ent.replica and ent.replica.stackable and ent.replica.stackable:StackSize() or 1

                if seen[key] then
                    seen[key].count = seen[key].count + s
                    if ent == focus_ent then seen[key].target = focus_ent end
                else
                    local item = { target = ent, name = raw_name, count = s, dist_sq = inst:GetDistanceSqToInst(ent) }
                    seen[key] = item
                    table.insert(list, item)
                end
            end
        end

        table.sort(list, function(a, b) return a.dist_sq < b.dist_sq end)

        if focus_ent and focus_ent:IsValid() then
            local focus_idx = nil
            for idx, item in ipairs(list) do
                if item.target == focus_ent then focus_idx = idx; break end
            end
            if not focus_idx then
                local raw_name = (focus_ent.GetDisplayName and type(focus_ent.GetDisplayName) == "function") and focus_ent:GetDisplayName() or focus_ent.prefab
                local focus_key = focus_ent.prefab .. "_" .. raw_name
                for idx, item in ipairs(list) do
                    if item.target and (item.target.prefab .. "_" .. item.name) == focus_key then
                        item.target = focus_ent; focus_idx = idx; break
                    end
                end
            end
            if focus_idx and focus_idx > 1 then
                table.insert(list, 1, table.remove(list, focus_idx))
            end
        end

        return list
    end

    local function OpenWheelInternal(wheel_type, focus_ent)
        local targets = (wheel_type == "STATUS") and CollectPlayerStatusEntries(inst) or CollectNearbyEntities(focus_ent)
        if #targets == 0 then return end

        CancelHoldTask()
        StopPlayerActions(inst, self)

        self._qa_wheel_mode = true
        self._qa_wheel_type = wheel_type
        self._qa_wheel_targets = targets
        self._qa_wheel_index = 1
        self._qa_wheel_page = 1

        SetModHUDFocus("ControllerWheel", true)
        if GLOBAL.TheCamera then GLOBAL.TheCamera:SetControllable(false) end
        SetSelectedTarget(targets[1])
        PlayMoveSound()
    end

    self._qa_open_status_wheel = function() OpenWheelInternal("STATUS") end

    self._qa_handle_wheel_control = function(_, control, down)
        if not self._qa_wheel_mode then return false end
        StopPlayerActions(inst, self)

        if control == GLOBAL.CONTROL_MOVE_UP or control == GLOBAL.CONTROL_MOVE_DOWN or control == GLOBAL.CONTROL_MOVE_LEFT or control == GLOBAL.CONTROL_MOVE_RIGHT then
            if down then
                local x = (GLOBAL.TheInput:IsControlPressed(GLOBAL.CONTROL_MOVE_RIGHT) and 1 or 0) - (GLOBAL.TheInput:IsControlPressed(GLOBAL.CONTROL_MOVE_LEFT) and 1 or 0)
                local y = (GLOBAL.TheInput:IsControlPressed(GLOBAL.CONTROL_MOVE_UP) and 1 or 0) - (GLOBAL.TheInput:IsControlPressed(GLOBAL.CONTROL_MOVE_DOWN) and 1 or 0)
                if x ~= 0 or y ~= 0 then
                    local targets = self._qa_wheel_targets or {}
                    local page = self._qa_wheel_page or 1
                    local first = (page - 1) * CONTROLLER_WHEEL_SLOTS + 1
                    local count = math.min(CONTROLLER_WHEEL_SLOTS, #targets - first + 1)
                    local best_idx, best_dot = 1, -math.huge

                    for slot_i = 1, count do
                        local s_angle = math.pi * 0.5 - (slot_i - 1) * math.pi * 2 / count
                        local dot = math.cos(s_angle) * x + math.sin(s_angle) * y
                        if dot > best_dot then best_dot = dot; best_idx = first + slot_i - 1 end
                    end
                    self._qa_wheel_index = best_idx
                    SetSelectedTarget(targets[best_idx])
                end
            end
            return true

        elseif (control == GLOBAL.CONTROL_ROTATE_LEFT or control == GLOBAL.CONTROL_ROTATE_RIGHT) and down then
            local p_max = math.ceil(#self._qa_wheel_targets / CONTROLLER_WHEEL_SLOTS)
            local step = (control == GLOBAL.CONTROL_ROTATE_LEFT) and -2 or 0
            self._qa_wheel_page = ((self._qa_wheel_page + step + p_max) % p_max) + 1
            self._qa_wheel_index = (self._qa_wheel_page - 1) * CONTROLLER_WHEEL_SLOTS + 1
            SetSelectedTarget(self._qa_wheel_targets[self._qa_wheel_index])
            return true

        elseif (control == GLOBAL.CONTROL_ACCEPT or control == GLOBAL.CONTROL_INVENTORY_USEONSELF) and down then
            local entry = self._qa_wheel_targets and self._qa_wheel_targets[self._qa_wheel_index]
            if entry then
                if self._qa_wheel_type == "STATUS" and entry.execute_fn then
                    entry.execute_fn()
                elseif self._qa_wheel_target and QA.AnnounceEntity then
                    QA.AnnounceEntity(self._qa_wheel_target, false)
                end
                PlayMoveSound()
            end
            self:_qa_swallow_controls_fn(
                GLOBAL.CONTROL_ACCEPT, GLOBAL.CONTROL_ACTION,
                GLOBAL.CONTROL_CONTROLLER_ACTION, GLOBAL.CONTROL_INVENTORY_USEONSELF, GLOBAL.CONTROL_PRIMARY
            )
            StopPlayerActions(inst, self)
            ExitWheelMode()
            return true

        elseif control == GLOBAL.CONTROL_CANCEL or control == GLOBAL.CONTROL_CONTROLLER_ALTACTION then
            if down then
                self:_qa_swallow_controls_fn(GLOBAL.CONTROL_CANCEL, GLOBAL.CONTROL_CONTROLLER_ALTACTION)
                StopPlayerActions(inst, self)
                ExitWheelMode()
            end
            return true
        end

        return true
    end

    local old_OnControl = self.OnControl
    self.OnControl = function(ctrl_self, control, down, ...)
        local hud = inst.HUD
        if GLOBAL.TheInput:ControllerAttached() and hud and hud.controls and hud.controls.nomu_qa_panel and hud.controls.nomu_qa_panel.shown then
            return true
        end

        if self._qa_swallowed and self._qa_swallowed[control] then
            if not down then
                self._qa_swallowed[control] = nil
                if next(self._qa_swallowed) == nil then
                    self._qa_swallowed = nil
                    if self._qa_swallow_task then self._qa_swallow_task:Cancel(); self._qa_swallow_task = nil end
                end
            end
            return true
        end

        if GLOBAL.TheInput:ControllerAttached() then
            if self._qa_wheel_mode then
                return self:_qa_handle_wheel_control(control, down)
            end

            if control == GLOBAL.CONTROL_INSPECT then
                local is_craft_open = inst.HUD and inst.HUD.IsCraftingOpen and inst.HUD:IsCraftingOpen()
                if not IsAnyContainerOpen(inst) and not is_craft_open then
                    if down then
                        CancelHoldTask()
                        self._qa_hold_elapsed = false
                        self._qa_initial_focus_ent = self:GetControllerTarget() or self.controller_target or self:GetControllerAttackTarget() or self.controller_attack_target

                        self._qa_hold_task = inst:DoTaskInTime(0.45, function()
                            self._qa_hold_task = nil
                            self._qa_hold_elapsed = true
                            local cur_target = self:GetControllerTarget() or self.controller_target or self:GetControllerAttackTarget() or self.controller_attack_target
                            OpenWheelInternal("ENTITIES", cur_target or self._qa_initial_focus_ent)
                        end)
                        return true
                    else
                        local was_holding = (self._qa_hold_task ~= nil)
                        CancelHoldTask()
                        if was_holding then
                            self._qa_hold_elapsed = nil
                            old_OnControl(ctrl_self, control, true, ...)
                            old_OnControl(ctrl_self, control, false, ...)
                            return true
                        end
                        if self._qa_hold_elapsed then
                            self._qa_hold_elapsed = nil
                            return true
                        end
                    end
                end
            end
        end

        return old_OnControl(ctrl_self, control, down, ...)
    end

    inst:ListenForEvent("onremove", ExitWheelMode)
end)

AddClassPostConstruct("widgets/controls", function(self)
    if self.commandwheel then
        local old_SetItems = self.commandwheel.SetItems
        self.commandwheel.SetItems = function(w, items, radius, focus_radius, ...)
            if items and type(items) == "table" then
                local already_added = false
                for _, item in ipairs(items) do
                    if item.is_nomu_qa then already_added = true; break end
                end
                if not already_added then
                    local STRINGS_CTRL = GLOBAL.STRINGS.NOMU_QA and GLOBAL.STRINGS.NOMU_QA.CONTROLLER or {}
                    table.insert(items, {
                        is_nomu_qa = true,
                        label = STRINGS_CTRL.BTN_QA_PANEL,
                        atlas = "images/command_wheel.xml",
                        normal = "command_talk.tex",
                        execute = function()
                            if self.owner and self.owner.HUD then self.owner.HUD:CloseCommandWheel() end
                            self.inst:DoTaskInTime(0.15, function() OpenQAPanel(self) end)
                        end,
                    })
                end
            end
            return old_SetItems(w, items, radius, focus_radius, ...)
        end
        self:BuildCommandWheel()
    end

    if self.nomu_qa_panel then
        local old_Hide = self.nomu_qa_panel.Hide
        self.nomu_qa_panel.Hide = function(p, ...)
            if p.focus then p:ClearFocus() end
            SetModHUDFocus("QAPanel", false)
            if GLOBAL.TheCamera then GLOBAL.TheCamera:SetControllable(true) end
            if old_Hide then return old_Hide(p, ...) end
        end
    end
end)