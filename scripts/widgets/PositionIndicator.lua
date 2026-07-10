local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Text = require "widgets/text"

local ARROW_OFFSET = 65
local TOP_EDGE_BUFFER = 20
local BOTTOM_EDGE_BUFFER = 40
local LEFT_EDGE_BUFFER = 67
local RIGHT_EDGE_BUFFER = 80

local MIN_SCALE = .8
local MIN_ALPHA = .8
local MIN_INDICATOR_RANGE = 20
local MAX_INDICATOR_RANGE = 60

local function CancelIndicator(inst)
    inst.startindicatortask:Cancel()
    inst.startindicatortask = nil
    inst.OnRemoveEntity = nil
end

local function StartIndicator(_, self)
    self.inst.startindicatortask = nil
    self.inst.OnRemoveEntity = nil
    self:StartUpdating()
    self:OnUpdate()
    self:Show()
    self:MoveToFront()
end

local function MakeMarker(name, pos)
    local PLACER_SCALE = 1.13
    local inst = CreateEntity()
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")

    inst.Transform:SetScale(PLACER_SCALE, PLACER_SCALE, PLACER_SCALE)

    inst.AnimState:SetBank("firefighter_placement")
    inst.AnimState:SetBuild("firefighter_placement")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)
    inst.AnimState:SetAddColour(0, 1, 0, 0)
    inst.Transform:SetPosition(pos:Get())

    local label = inst.entity:AddLabel()

    label:SetFontSize(18)
    label:SetFont(_G.BODYTEXTFONT)
    label:SetWorldOffset(0, 2.3, 0)

    label:SetText(name)
    label:SetColour(255 / 255, 255 / 255, 255 / 255)
    label:Enable(true)
    inst.label = label
    return inst
end

local PositionIndicator = Class(Widget, function(self, name, x, y, z)
    Widget._ctor(self, "PositionIndicator")
    self.isFE = false
    self:SetClickable(true)

    self.root = self:AddChild(Widget("root"))
    self.icon = self.root:AddChild(Widget("target"))
    self.head = self.icon:AddChild(Image("images/PositionSystemIcon.xml", "PositionSystemIcon.tex"))
    self.head:SetScale(.25)

    self.arrow = self.root:AddChild(Image("images/ui.xml", "scroll_arrow.tex"))
    self.arrow:SetScale(.5)

    self.name = name
    self.target = Vector3(x, y, z)
    self.marker = MakeMarker(name, self.target)
    self.colour = { 240 / 255, 70 / 255, 70 / 255 }
    self.name_label = self.icon:AddChild(Text(UIFONT, 45, string.format(STRINGS.NOMU_QA.POS_SYS.BUTTON_TOOLTIPS_INDICATOR, self.name)))
    self.name_label:SetPosition(0, 80, 0)
    self.name_label:Hide()

    self:Hide()
    self.inst.startindicatortask = self.inst:DoTaskInTime(0, StartIndicator, self)
    self.inst.OnRemoveEntity = CancelIndicator
end)

function PositionIndicator:OnControl(control, down)
    if down and control == CONTROL_ACCEPT then
        PositionSystem.AnnouncePosition(self.name, self.target.x, self.target.y, self.target.z)
        return true
    elseif down and control == CONTROL_SECONDARY then
        for i, position in ipairs(PositionSystem.POSITION.chasing) do
            if position.indicator == self then
                table.remove(PositionSystem.POSITION.chasing, i)
                break
            end
        end
        self.marker:Remove()
        self:Kill()
        return true
    end
    return PositionIndicator._base.OnControl(self, control, down)
end

function PositionIndicator:OnGainFocus()
    PositionIndicator._base.OnGainFocus(self)
    self.name_label:Show()
end

function PositionIndicator:OnLoseFocus()
    PositionIndicator._base.OnLoseFocus(self)
    self.name_label:Hide()
end

function PositionIndicator:GetPositionIndicatorAlpha(dist)
    if dist > TUNING.MAX_INDICATOR_RANGE * 2 then dist = TUNING.MAX_INDICATOR_RANGE * 2 end
    local alpha = Remap(dist, TUNING.MAX_INDICATOR_RANGE, TUNING.MAX_INDICATOR_RANGE * 2, 1, MIN_ALPHA)
    if dist <= TUNING.MAX_INDICATOR_RANGE then alpha = 1 end
    return alpha
end

function PositionIndicator:OnUpdate()
    local dist = ThePlayer:GetPosition():Dist(self.target)
    if dist < 8 then
        self.colour = { 0 / 255, 220 / 255, 60 / 255 }
    else
        self.colour = { 240 / 255, 70 / 255, 70 / 255 }
    end
    local alpha = self:GetPositionIndicatorAlpha(dist)
    self.marker.AnimState:SetAddColour(self.colour[1], self.colour[2], self.colour[3], alpha)
    self.marker.label:SetColour(self.colour[1], self.colour[2], self.colour[3])
    self.head:SetTint(1, 1, 1, alpha)
    self.arrow:SetTint(self.colour[1], self.colour[2], self.colour[3], alpha)
    self.name_label:SetColour(self.colour[1], self.colour[2], self.colour[3], alpha)

    if dist < MIN_INDICATOR_RANGE then
        dist = MIN_INDICATOR_RANGE
    elseif dist > MAX_INDICATOR_RANGE then
        dist = MAX_INDICATOR_RANGE
    end
    local scale = Remap(dist, MIN_INDICATOR_RANGE, MAX_INDICATOR_RANGE, 1, MIN_SCALE)
    self:SetScale(scale)
    self:UpdatePosition(self.target.x, self.target.z)
end

local function GetXCoord(angle, width)
    if angle >= 90 and angle <= 180 then return 0
    elseif angle <= 0 and angle >= -90 then return width
    else
        if angle < 0 then angle = -angle - 90 end
        local pctX = 1 - (angle / 90)
        return pctX * width
    end
end

local function GetYCoord(angle, height)
    if angle <= -90 and angle >= -180 then return height
    elseif angle >= 0 and angle <= 90 then return 0
    else
        if angle < 0 then angle = -angle end
        if angle > 90 then angle = angle - 90 end
        local pctY = (angle / 90)
        return pctY * height
    end
end

function PositionIndicator:UpdatePosition(targX, targZ)
    local angleToTarget = ThePlayer:GetAngleToPoint(targX, 0, targZ)
    local downVector = TheCamera:GetDownVec()
    local downAngle = -math.atan2(downVector.z, downVector.x) / DEGREES
    local indicatorAngle = (angleToTarget - downAngle) + 45
    while indicatorAngle > 180 do indicatorAngle = indicatorAngle - 360 end
    while indicatorAngle < -180 do indicatorAngle = indicatorAngle + 360 end

    local scale = self:GetScale()
    local w, h = 0, 0
    local w0, h0 = 16, 16
    local w1, h1 = self.arrow:GetSize()
    if w0 and w1 then w = (w0 + w1) end
    if h0 and h1 then h = (h0 + h1) end

    local screenWidth, screenHeight = TheSim:GetScreenSize()
    local x = GetXCoord(indicatorAngle, screenWidth)
    local y = GetYCoord(indicatorAngle, screenHeight)

    if x <= LEFT_EDGE_BUFFER + (.5 * w * scale.x) then
        x = LEFT_EDGE_BUFFER + (.5 * w * scale.x)
    elseif x >= screenWidth - RIGHT_EDGE_BUFFER - (.5 * w * scale.x) then
        x = screenWidth - RIGHT_EDGE_BUFFER - (.5 * w * scale.x)
    end

    if y <= BOTTOM_EDGE_BUFFER + (.5 * h * scale.y) then
        y = BOTTOM_EDGE_BUFFER + (.5 * h * scale.y)
    elseif y >= screenHeight - TOP_EDGE_BUFFER - (.5 * h * scale.y) then
        y = screenHeight - TOP_EDGE_BUFFER - (.5 * h * scale.y)
    end

    self:SetPosition(x, y, 0)
    self.x = x
    self.y = y
    self.angle = indicatorAngle
    self:PositionArrow()
    self:PositionLabel()
end

function PositionIndicator:PositionArrow()
    if not self.x and self.y and self.angle then return end
    local angle = self.angle + 45
    self.arrow:SetRotation(angle)
    local x = math.cos(angle * DEGREES) * ARROW_OFFSET
    local y = -(math.sin(angle * DEGREES) * ARROW_OFFSET)
    self.arrow:SetPosition(x, y, 0)
end

function PositionIndicator:PositionLabel()
    if not self.x and self.y and self.angle then return end
    local angle = self.angle + 45 - 180
    local x = math.cos(angle * DEGREES) * ARROW_OFFSET * 1.75
    local y = -(math.sin(angle * DEGREES) * ARROW_OFFSET * 1.25)
    self.name_label:SetPosition(x, y, 0)
end

return PositionIndicator