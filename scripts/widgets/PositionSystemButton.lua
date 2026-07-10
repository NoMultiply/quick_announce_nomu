local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local TextButton = require "widgets/textbutton"
local PositionIndicator = require("widgets/PositionIndicator")
local delta = 25

local PositionSystemButton = Class(Widget, function(self)
    Widget._ctor(self, "PositionSystemButton")
    self:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self:SetVAnchor(ANCHOR_TOP)
    self:SetHAnchor(ANCHOR_MIDDLE)
    self.root = self:AddChild(Widget("ROOT"))
    self.pageIcon = self.root:AddChild(ImageButton("images/PositionSystemIcon.xml", "PositionSystemIcon.tex", nil, nil, nil, nil, { 1, 1 }, { 0, 0 }))
    self.pageIcon:SetScale(0.15, 0.15, 0.15)
    
    if PositionSystem.DATA.PositionSystemButtonPos then
        self.root:SetPosition(unpack(PositionSystem.DATA.PositionSystemButtonPos))
    else
        self.root:SetPosition(0, -50, 0)
    end
    
    self.pageIcon:SetTooltip(STRINGS.NOMU_QA.POS_SYS.BUTTON_TOOLTIPS_ENTRY)
    self.pageIcon:SetOnClick(function()
        if NOMU_QA and NOMU_QA.PositionSystemScreen then
            TheFrontEnd:PushScreen(NOMU_QA.PositionSystemScreen(nil))
        end
    end)

    local tips_text_button = self.root:AddChild(TextButton())
    tips_text_button:SetFont(CHATFONT)
    tips_text_button:SetTextSize(20)
    tips_text_button:SetText(STRINGS.NOMU_QA.POS_SYS.TITLE_TEXT)
    tips_text_button:SetPosition(0, -25, 0)
    tips_text_button:SetTextFocusColour({ 0.9, 0.8, 0.6, 1 })
    tips_text_button:SetTextColour({ 1, 1, 1, 1 })
    self.tips_text_button = tips_text_button
    self.tips_text_button:Hide()

    self:MoveToBack()
    self:StartUpdating()
end)

local function IsAltDown()
    return TheInput:IsKeyDown(KEY_LALT) or TheInput:IsKeyDown(KEY_RALT) or TheInput:IsKeyDown(KEY_ALT)
end

function PositionSystemButton:OnControl(control, down)
    if IsAltDown() then
        self:Passive_OnControl(control, down)
    else
        if self.tips_text_button.shown then
            if down and control == CONTROL_ACCEPT then
                self:ChasePosition()
            elseif down and control == CONTROL_SECONDARY then
                self.tips_text_button:Hide()
            end
            return true
        end
        return PositionSystemButton._base.OnControl(self, control, down)
    end
    return true
end

function PositionSystemButton:Passive_OnControl(control, down)
    if control == CONTROL_ACCEPT then
        if down then self:StartDrag() else self:EndDrag() end
    end
end

function PositionSystemButton:SetDragPosition(x, y, z)
    local pos = type(x) == "number" and Vector3(x, y, z) or x
    local diff = (pos - self.dragPosDiff_mouse)
    local scale = self:GetScale()
    local scale2 = ThePlayer.HUD.controls.status:GetScale()
    diff.x = diff.x * scale2.x / scale.x
    diff.y = diff.y * scale2.y / scale.y
    local w, h = TheSim:GetScreenSize()
    w = w * scale2.x / scale.x / 2
    h = h * scale2.y / scale.y
    local new_pos = diff + self.dragPosDiff_widget
    if new_pos.y > -delta then new_pos.y = -delta elseif new_pos.y < -h + delta then new_pos.y = -h + delta end
    if new_pos.x < -w + delta then new_pos.x = -w + delta elseif new_pos.x > w - delta then new_pos.x = w - delta end
    self.root:SetPosition(new_pos)
end

function PositionSystemButton:StartDrag()
    if not self.follow_handler then
        local mouse_pos = TheInput:GetScreenPosition()
        self.dragPosDiff_widget = self.root:GetPosition()
        self.dragPosDiff_mouse = mouse_pos
        self.follow_handler = TheInput:AddMoveHandler(function(x, y)
            self:SetDragPosition(x, y, 0)
            if not IsAltDown() then self:EndDrag() end
        end)
        self:SetDragPosition(mouse_pos)
    end
end

function PositionSystemButton:EndDrag()
    if self.follow_handler then self.follow_handler:Remove() end
    local x, y, z = self.root:GetPosition():Get()
    PositionSystem.DATA.PositionSystemButtonPos = { x, y, z }
    PositionSystem.SaveData()
    self.follow_handler = nil
    self.dragPosDiff = nil
    self:MoveToBack()
end

function PositionSystemButton:OnUpdate()
    local w, h = TheSim:GetScreenSize()
    local scale = self:GetScale()
    local scale2 = ThePlayer.HUD.controls.status:GetScale()
    w = w * scale2.x / scale.x / 2
    h = h * scale2.y / scale.y
    local x, y, _ = self.root:GetPosition():Get()
    local ox, oy = x, y
    if y > -delta then y = -delta elseif y < -h + delta then y = -h + delta end
    if x < -w + delta then x = -w + delta elseif x > w - delta then x = w - delta end
    if ox ~= x or oy ~= y then self.root:SetPosition(x, y, 0) end
end

function PositionSystemButton:DetectPosition(name, x, y, z, world)
    if name and x and y and z then
        self.ps_name, self.ps_x, self.ps_y, self.ps_z, self.ps_world = name, x, y, z, world
        self.tips_text_button:SetText(string.format(STRINGS.NOMU_QA.POS_SYS.DETECT_TIPS_FORMAT, world or "未知", name, x, y, z))
        self.tips_text_button:Show()
        local _, h = self.tips_text_button.text:GetRegionSize()
        self.tips_text_button:SetPosition(0, -25 - h / 2, 0)
    else
        self.tips_text_button:Hide()
    end
end

function PositionSystemButton:ChasePosition(name, x, y, z, world)
    name, x, y, z, world = name or self.ps_name, x or self.ps_x, y or self.ps_y, z or self.ps_z, world or self.ps_world
    if not (name and x and y and z) then return end
    local indicator = ThePlayer.HUD.under_root:AddChild(PositionIndicator(name, x, y, z))
    table.insert(PositionSystem.POSITION.chasing, { name = name, x = x, y = y, z = z, world = world, type = 'chasing', indicator = indicator })
    self.tips_text_button:Hide()
end

return PositionSystemButton