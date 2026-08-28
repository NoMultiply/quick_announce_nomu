if not GLOBAL.NOMU_QA.ENABLE_MEME_SYSTEM then
    return
end


local oldNetworking_Say = GLOBAL.Networking_Say
GLOBAL.Networking_Say = function(guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)
    if type(message) == "string" and string.match(message, "%[Meme:.-%]") then
        message = message .. "\n "
    end
    return oldNetworking_Say(guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)
end

local LIST = {
    List_0 = {}, -- 收藏分类
    List_1 = {}, List_2 = {}, List_3 = {}, List_4 = {}, List_5 = {},
    List_6 = {}, List_7 = {}, List_8 = {}, List_9 = {}, List_10 = {}
}
for i = 1, 180 do table.insert(LIST.List_1, "zayu_"..i) end
for i = 1, 80  do table.insert(LIST.List_2, "feibi_"..i) end
for i = 1, 101 do table.insert(LIST.List_3, "hewu_"..i) end
for i = 1, 67  do table.insert(LIST.List_4, "chaijun_"..i) end
for i = 1, 70  do table.insert(LIST.List_5, "gif_catmeme_"..i) end
for i = 1, 80  do table.insert(LIST.List_6, "taff_"..i) end
for i = 1, 20  do table.insert(LIST.List_7, "yuexin_"..i) end
for i = 1, 129 do table.insert(LIST.List_8, "xiyy_"..i) end
for i = 1, 30  do table.insert(LIST.List_9, "mtcat_"..i) end
for i = 1, 25  do table.insert(LIST.List_10, "jiaran_"..i) end

local LIST_DATA = {
    List_0 = { title = "收藏", atlas = nil, prefix = nil },
    List_1 = { title = "杂图", atlas = "images/meme/zayu.xml", prefix = "zayu" },
    List_2 = { title = "菲比", atlas = "images/meme/feibi.xml", prefix = "feibi" },
    List_3 = { title = "塞西莉亚", atlas = "images/meme/hewu.xml", prefix = "hewu" },
    List_4 = { title = "柴郡", atlas = "images/meme/chaijun.xml", prefix = "chaijun" },
    List_5 = { title = "动图", atlas = "images/meme/gif_catmeme.xml", prefix = "gif_catmeme" },
    List_6 = { title = "塔菲", atlas = "images/meme/taff.xml", prefix = "taff" },
    List_7 = { title = "月薪猫", atlas = "images/meme/yuexin.xml", prefix = "yuexin" },
    List_8 = { title = "喜羊羊", atlas = "images/meme/xiyy.xml", prefix = "xiyy" },
    List_9 = { title = "蜜桃猫", atlas = "images/meme/mtcat.xml", prefix = "mtcat" },
    List_10 = { title = "嘉然", atlas = "images/meme/jiaran.xml", prefix = "jiaran" },
}

GLOBAL.NOMU_QA.MEME_LIST = LIST
GLOBAL.NOMU_QA.MEME_LIST_DATA = LIST_DATA

local VALID_MEME_NAMES = {}
for list_key, names in pairs(LIST) do
    for _, name in ipairs(names) do
        VALID_MEME_NAMES[name] = true
    end
end
GLOBAL.NOMU_QA.VALID_MEME_NAMES = VALID_MEME_NAMES

-- 动态加载图集资源
table.insert(Assets, Asset("ATLAS", "images/meme/meme_icon.xml"))
table.insert(Assets, Asset("IMAGE", "images/meme/meme_icon.tex"))
for i = 1, 10 do
    local data = LIST_DATA["List_"..i]
    if data and data.atlas then
        table.insert(Assets, Asset("ATLAS", data.atlas))
        table.insert(Assets, Asset("IMAGE", data.atlas:gsub("%.xml$", ".tex")))
    end
end
for i = 1, #LIST.List_5 do
    table.insert(Assets, Asset("ANIM", "anim/gif_catmeme_"..i..".zip"))
end

local Prefix_Atlas_Map = {}
for _, v in pairs(LIST_DATA) do
    if v.prefix then
        Prefix_Atlas_Map[v.prefix] = v.atlas
    end
end
GLOBAL.NOMU_QA.Prefix_Atlas_Map = Prefix_Atlas_Map

GLOBAL.NOMU_QA.HD_MEMES = {}
local hd_xml_path = GLOBAL.resolvefilepath("images/meme/meme_hd.xml")
if hd_xml_path then
    local file = GLOBAL.io.open(hd_xml_path, "r")
    if file then
        local xml_data = file:read("*a")
        file:close()
        for meme_name in string.gmatch(xml_data, 'name="(.-)%.tex"') do
            GLOBAL.NOMU_QA.HD_MEMES[meme_name] = true
        end
    end
end

-- 统一注册高清图集
table.insert(Assets, Asset("ATLAS", "images/meme/meme_hd.xml"))
table.insert(Assets, Asset("IMAGE", "images/meme/meme_hd.tex"))

-- 悬浮预览功能
GLOBAL.NOMU_QA.AttachHoverZoom = function(parent_root, meme_widget, meme_name, atlas, is_anim)
    if not VALID_MEME_NAMES[meme_name] then return nil end

    local Image = GLOBAL.require("widgets/image")
    local UIAnim = GLOBAL.require("widgets/uianim")
    local Widget = GLOBAL.require("widgets/widget")

    local dummy_tracker = parent_root:AddChild(Widget("dummy_tracker"))
    local mx, my = meme_widget:GetPosition():Get()
    dummy_tracker:SetPosition(mx + 100, my + 38)

    local function HideHover()
        if meme_widget.hover_preview and meme_widget.hover_preview.inst:IsValid() then
            meme_widget.hover_preview:Kill()
            meme_widget.hover_preview = nil
        end
    end

    local function ShowHover()
        if GLOBAL.NOMU_QA.DATA.DISABLE_MEME_PREVIEW then return end
        if meme_widget.hover_preview and meme_widget.hover_preview.inst:IsValid() then return end

        local top_parent = GLOBAL.TheFrontEnd.overlayroot
        local hp
        local ui_scale = GLOBAL.TheFrontEnd:GetHUDScale()

        if is_anim then
            hp = top_parent:AddChild(UIAnim())
            hp:GetAnimState():SetBank(meme_name)
            hp:GetAnimState():SetBuild(meme_name)
            hp:GetAnimState():PlayAnimation("idle", true)
            hp:GetAnimState():SetTime(GLOBAL.GetTime())
            hp:SetScale(1.80 * ui_scale, 1.80 * ui_scale, 1.80 * ui_scale)
        else
            if GLOBAL.NOMU_QA.HD_MEMES and GLOBAL.NOMU_QA.HD_MEMES[meme_name] then
                hp = top_parent:AddChild(Image("images/meme/meme_hd.xml", meme_name..".tex", meme_name..".tex"))
                hp:SetScale(0.80 * ui_scale, 0.80 * ui_scale, 0.80 * ui_scale)
            else
                hp = top_parent:AddChild(Image(atlas, meme_name..".tex", meme_name..".tex"))
                hp:SetScale(1.80 * ui_scale, 1.80 * ui_scale, 1.80 * ui_scale)
            end
        end
        
        hp:MoveToFront()
        if dummy_tracker.inst:IsValid() then
            local w_pos = dummy_tracker:GetWorldPosition()
            if not is_anim and GLOBAL.NOMU_QA.HD_MEMES and GLOBAL.NOMU_QA.HD_MEMES[meme_name] then
                hp:SetPosition(w_pos.x + 45, w_pos.y + 38, w_pos.z)
            else
                hp:SetPosition(w_pos:Get())
            end
        end
        meme_widget.hover_preview = hp
    end

    meme_widget.inst:ListenForEvent("onremove", HideHover)
    dummy_tracker.inst:ListenForEvent("onremove", HideHover)
    meme_widget:SetOnGainFocus(function() meme_widget.ui_focus = true; ShowHover() end)
    meme_widget:SetOnLoseFocus(function() meme_widget.ui_focus = false; if not meme_widget.manual_hover then HideHover() end end)

    dummy_tracker.inst:DoPeriodicTask(0, function()
        if not meme_widget.inst:IsValid() or not dummy_tracker.inst:IsValid() then
            HideHover(); return
        end
        if meme_widget.hover_preview and meme_widget.hover_preview.inst:IsValid() then
            local w_pos = dummy_tracker:GetWorldPosition()
            if not is_anim and GLOBAL.NOMU_QA.HD_MEMES and GLOBAL.NOMU_QA.HD_MEMES[meme_name] then
                meme_widget.hover_preview:SetPosition(w_pos.x + 45, w_pos.y + 38, w_pos.z)
            else
                meme_widget.hover_preview:SetPosition(w_pos:Get())
            end
        end
        local is_chat_open = GLOBAL.ThePlayer and GLOBAL.ThePlayer.HUD and GLOBAL.ThePlayer.HUD:IsChatInputScreenOpen()
        if is_chat_open or not parent_root.shown then
            meme_widget.manual_hover = false
            if not meme_widget.ui_focus then HideHover() end
            return
        end

        local mouse_pos = GLOBAL.TheInput:GetScreenPosition()
        local widget_pos = meme_widget:GetWorldPosition()
        local threshold = 35 * GLOBAL.TheFrontEnd:GetHUDScale()
        local dx, dy = mouse_pos.x - widget_pos.x, mouse_pos.y - widget_pos.y
        if dx*dx + dy*dy <= threshold*threshold then
            if not meme_widget.manual_hover then meme_widget.manual_hover = true; ShowHover() end
        else
            if meme_widget.manual_hover then
                meme_widget.manual_hover = false
                if not meme_widget.ui_focus then HideHover() end
            end
        end
    end)
    return dummy_tracker
end

local function InjectMemeHover(self, is_lobby)
    local Image = GLOBAL.require("widgets/image")
    local UIAnim = GLOBAL.require("widgets/uianim")

    self.meme_alpha = self.meme_alpha or 1

    local old_SetChatData = self.SetChatData
    if old_SetChatData then
        self.SetChatData = function(w, ...)
            old_SetChatData(w, ...)
            w:UpdateMemeDisplay()
        end
    elseif is_lobby and self.message then
        local old_SetString = self.message.SetString
        self.message.SetString = function(msg_self, str, ...)
            if old_SetString then old_SetString(msg_self, str, ...) end
            self:UpdateMemeDisplay()
        end
        local old_SetTruncatedString = self.message.SetTruncatedString
        if old_SetTruncatedString then
            self.message.SetTruncatedString = function(msg_self, str, ...)
                old_SetTruncatedString(msg_self, str, ...)
                self:UpdateMemeDisplay()
            end
        end
    end

    if not is_lobby then
        local old_UpdateAlpha = self.UpdateAlpha
        self.UpdateAlpha = function(w, alpha, ...)
            if old_UpdateAlpha then old_UpdateAlpha(w, alpha, ...) end
            if w.meme then
                if w.meme.isanim then w.meme:GetAnimState():SetMultColour(1, 1, 1, alpha)
                else w.meme:SetFadeAlpha(alpha) end
                w.meme_alpha = alpha
            end
        end
    end

    self.UpdateMemeDisplay = function(w)
        local is_skin_announcement = not is_lobby and w.type == (GLOBAL.ChatTypes and GLOBAL.ChatTypes.SkinAnnouncement or 4)
        local str = (not is_skin_announcement and w.message) and w.message:GetString() or nil
        local meme_name = str and string.match(str, "%[Meme:(.-)%]")

        if meme_name and not VALID_MEME_NAMES[meme_name] then meme_name = nil end

        if w.current_meme_name == meme_name then
            if w.message then
                if meme_name then w.message:Hide()
                elseif not is_skin_announcement then w.message:Show() end
            end
            return
        end
        w.current_meme_name = meme_name

        if w.meme then w.meme:Kill(); w.meme = nil end
        if w.meme_dummy_tracker then w.meme_dummy_tracker:Kill(); w.meme_dummy_tracker = nil end

        if meme_name then
            if w.message then w.message:Hide() end
            
            if meme_name:sub(1, 4) == "gif_" then
                w.meme = w.root:AddChild(UIAnim())
                w.meme:GetAnimState():SetBank(meme_name)
                w.meme:GetAnimState():SetBuild(meme_name)
                w.meme:GetAnimState():PlayAnimation("idle", true)
                w.meme:GetAnimState():SetTime(GLOBAL.GetTime())
                if not is_lobby then w.meme:GetAnimState():SetMultColour(1, 1, 1, w.meme_alpha) end
                w.meme.isanim = true
                w.meme.atlas = nil
            else
                local prefix = meme_name:match("^(.*)_%d+")
                local atlas = Prefix_Atlas_Map[prefix] or "images/meme/"..meme_name..".xml"
                w.meme = w.root:AddChild(Image(atlas, meme_name..".tex", meme_name..".tex"))
                if not is_lobby then w.meme:SetFadeAlpha(w.meme_alpha) end
                w.meme.isanim = false
                w.meme.atlas = atlas
            end
            
            -- 自适应排版
            if is_lobby then
                local mx, my = w.message:GetPosition():Get()
                local mw = w.message:GetRegionSize()
                if w.meme.isanim then
                    w.meme:SetPosition(mx - mw/2 + 100, my - 12)
                else
                    w.meme:SetPosition((mx - mw/2 + 72) + (w.meme:GetSize() * 0.35) / 2, my - 12)
                end
                w.meme:SetScale(0.35)
                if w.extra_line_count then w.extra_line_count = w.extra_line_count + 1 end
            else
                if w.meme.isanim then
                    w.meme:SetPosition(-268, -8)
                else
                    w.meme:SetPosition(-294 + (w.meme:GetSize() * 0.4) / 2, -8)
                end
                w.meme:SetScale(0.4)
            end

            if w.meme.isanim and type(w.meme.SetRegionSize) == "function" then w.meme:SetRegionSize(100, 100) end
            w.meme:SetClickable(true)
            w.meme_dummy_tracker = GLOBAL.NOMU_QA.AttachHoverZoom(w.root, w.meme, meme_name, w.meme.atlas, w.meme.isanim)
        else
            if w.message and not is_skin_announcement then w.message:Show() end
        end
    end

    if is_lobby and not old_SetChatData then self:UpdateMemeDisplay() end
end

AddClassPostConstruct("widgets/redux/chatline", function(self) InjectMemeHover(self, false) end)
AddClassPostConstruct("widgets/redux/lobbychatline", function(self) InjectMemeHover(self, true) end)