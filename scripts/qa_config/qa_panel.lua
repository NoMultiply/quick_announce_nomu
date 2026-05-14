local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"
local ImageButton = require "widgets/imagebutton"
local Image = require "widgets/image"
local TextButton = require "widgets/textbutton"
local Text = require "widgets/text"

-- 获取主文件暴露的局部函数和常量
local DeepCopy = GLOBAL.NOMU_QA.DeepCopy
local Announce = GLOBAL.NOMU_QA.Announce
local VERSION = GLOBAL.NOMU_QA.VERSION

local NoMuScreen = Class(Screen, function(self, name, nomu_parent, width, height, title)
    Screen._ctor(self, name)
    self.nomu_parent = nomu_parent
    if nomu_parent then nomu_parent:Hide() end
    
    self.root = self:AddChild(TEMPLATES.RectangleWindow(width, height, title))
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetPosition(0, 0)

    -- 标准化按钮添加方法
    self.AddButton = function(x, y, w, h, text, fn)
        local button = self.root:AddChild(ImageButton("images/global_redux.xml", "button_carny_long_normal.tex", "button_carny_long_hover.tex", "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
        button:SetFont(CHATFONT)
        button:SetPosition(x, y, 0)
        button.text:SetColour(0, 0, 0, 1)
        button:SetOnClick(function() 
            fn(button)
            if type(text) == 'function' then 
                button:SetText(text(button)) 
            end 
        end)
        button:SetTextSize(26)
        button:SetText(type(text) == 'function' and text(button) or text)
        button:ForceImageSize(w, h)
        return button
    end

    -- 切换按钮添加方法
    self.AddToggle = function(x, y, w, h, key, text_on, text_off, on_toggle)
        return self.AddButton(x, y, w, h, function() return GLOBAL.NOMU_QA.DATA[key] and text_on or text_off end, function()
            if on_toggle then 
                on_toggle() 
            else 
                GLOBAL.NOMU_QA.DATA[key] = not GLOBAL.NOMU_QA.DATA[key] 
            end
            GLOBAL.NOMU_QA.SaveData()
        end)
    end
end)

function NoMuScreen:Close()
    if self.EM_all_widgets then
        for _, v in ipairs(self.EM_all_widgets) do
            if v and v.Kill then v:Kill() end
        end
    end
    if self.EM_input then
        self.EM_input:Remove()
        self.EM_input = nil
    end

    if self.nomu_parent then self.nomu_parent:Show() end
    TheFrontEnd:PopScreen(self)
end

function NoMuScreen:OnControl(control, down)
    -- 拦截取消按键，优先关闭表情面板
    if self.EM_bg and self.EM_bg.shown and (control == CONTROL_CANCEL or control == CONTROL_PAUSE) then
        if self.EM_menu and self.EM_menu.focus then
            return true
        end
        if not down then
            self.EM_bg:Hide()
            if self.config_input and self.config_input.textbox then
                self.config_input.textbox:SetEditing(true)
            end
        end
        return true
    end

    if NoMuScreen._base.OnControl(self, control, down) then return true end
    if not down and (control == CONTROL_PAUSE or control == CONTROL_CANCEL) then 
        self:Close() 
    end
    return true
end

-- 自定义滚动列表组件
local NoMuList = Class(Widget, function(self, list_item_fn, x, y, item_width, item_height, cols, rows)
    Widget._ctor(self, "NoMuList")
    self.x, self.y = x or 0, y or 0
    self.item_width, self.item_height = item_width or 200, item_height or 80
    self.cols, self.rows = cols or 1, rows or 10
    self.list_item_fn = list_item_fn
end)

function NoMuList:Refresh(list_data, override)
    override = override or {}
    if self.scroll_lists then self.scroll_lists:Kill() end
    
    self.scroll_lists = self:AddChild(TEMPLATES.ScrollingGrid(list_data, {
        context = {}, 
        widget_width = override.item_width or self.item_width, 
        widget_height = override.item_height or self.item_height,
        num_visible_rows = override.rows or self.rows, 
        num_columns = override.cols or self.cols,
        item_ctor_fn = function(_, index)
            local w = Widget("widget-" .. index)
            w:SetOnGainFocus(function() 
                if self.scroll_lists then self.scroll_lists:OnWidgetFocus(w) end 
            end)
            w.nomu_list_item = w:AddChild(self.list_item_fn(self))
            w.focus_forward = w.nomu_list_item
            return w
        end,
        apply_fn = function(_, w, data)
            w.data = data
            w.nomu_list_item:Hide()
            if not data then 
                w.focus_forward = nil
                return 
            end
            w.focus_forward = w.nomu_list_item
            w.nomu_list_item:Show()
            w.nomu_list_item:SetInfo(data)
        end,
        scrollbar_offset = 10, 
        scrollbar_height_offset = -60, 
        peek_percent = 0, 
        allow_bottom_empty_row = true
    }))
    self.scroll_lists:SetPosition(override.x or self.x, override.y or self.y)
end


-- 表情和常用语菜单核心逻辑 (前置声明以供 GetInputString 使用)
local xbox_emojis = {
    "\238\128\143", "\238\128\140", "\238\128\141", "\238\128\142",
    "\238\128\132", "\238\128\133", "\238\128\134", "\238\128\137",
    "\238\128\135", "\238\128\138", "\238\128\128", "\238\128\129",
    "\238\128\130", "\238\128\131", "\238\128\146", "\238\128\147",
    "\238\128\145", "\238\128\144", "\238\128\150", "\238\128\151",
    "\238\128\149", "\238\128\148", "\238\128\136", "\238\128\136",
    "\238\128\139", "\238\128\139", "\238\128\152", "\238\128\153",
    "\238\132\128", "\238\132\129",
}

local function CreateEmojiAndPhraseMenu(self, mode)
    self.EM_all_widgets = {}
    self.EM_emojis = {}

    local function build_bg()
        self.EM_bg = (mode == "chat" and self.screen_root or (mode == "input_string" and self.root or self)):AddChild(TEMPLATES.RectangleWindow(320, 360, "", nil, nil, ""))
        
        if mode == "chat" then
            self.EM_bg:SetPosition(-320, 320, 0)
            self.EM_bg:MoveToFront()
        elseif mode == "input_string" then
            self.EM_bg:SetPosition(400, 0, 0) 
            self.EM_bg:MoveToFront()
        else
            self.EM_bg:SetPosition(0, -150, 0)
        end
        self.EM_bg:SetBackgroundTint(80/255, 61/255, 39/255, 0.9)
        table.insert(self.EM_all_widgets, self.EM_bg)

        self.EM_menu_root = self.EM_bg:AddChild(Widget("menu_root"))
        self.EM_menu_root:SetPosition(0, 0, 0)

        local function AddTabBtn(x, y, text, fn)
            local btn = self.EM_menu_root:AddChild(ImageButton("images/global_redux.xml", "button_carny_long_normal.tex", "button_carny_long_hover.tex", "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
            btn:SetFont(GLOBAL.CHATFONT)
            btn:SetPosition(x, y, 0)
            btn.text:SetColour(0, 0, 0, 1)
            btn:SetTextSize(26)
            btn:ForceImageSize(120, 40)
            btn:SetOnClick(fn)
            btn:SetText(text)
            return btn
        end

        self.EM_btn_1 = AddTabBtn(-70, 140, "emoji", function()
            self.EM_page_1:Show()
            self.EM_page_2:Hide()
        end)
        self.EM_btn_2 = AddTabBtn(70, 140, "常用语", function()
            self.EM_page_1:Hide()
            self.EM_page_2:Show()
        end)

        local function InsertText(str)
            if mode == "chat" and self.chat_edit then
                local old = self.chat_edit:GetString()
                self.chat_edit:SetString(old .. str)
                self.chat_edit:SetEditing(true)
            elseif mode == "input_string" and self.config_input and self.config_input.textbox then
                local old = self.config_input.textbox:GetString()
                self.config_input.textbox:SetString(old .. str)
                self.config_input.textbox:SetEditing(true)
            elseif mode == "writeable" then
                local old = self:GetText()
                if old then
                    self:OverrideText(old .. str)
                    self:OnBecomeActive()
                end
            end
        end

        self.EM_page_1 = self.EM_bg:AddChild(Widget("page_1"))
        if #self.EM_emojis == 0 then
            for _, v in pairs(GLOBAL.EMOJI_ITEMS or {}) do
                local emoji = v.data and v.data.utf8_str
                if emoji then
                    local textbtn = self.EM_page_1:AddChild(TextButton())
                    textbtn:SetTextSize(30)
                    textbtn:SetText(emoji)
                    textbtn:SetOnGainFocus(function() textbtn:SetScale(1.2) end)
                    textbtn:SetOnLoseFocus(function() textbtn:SetScale(1) end)
                    textbtn:SetOnClick(function() InsertText(emoji) end)
                    table.insert(self.EM_emojis, textbtn)
                end
            end
            for _, v in ipairs(xbox_emojis) do
                local textbtn = self.EM_page_1:AddChild(TextButton())
                textbtn:SetTextSize(30)
                textbtn:SetText(v)
                textbtn:SetOnGainFocus(function() textbtn:SetScale(1.2) end)
                textbtn:SetOnLoseFocus(function() textbtn:SetScale(1) end)
                textbtn:SetOnClick(function() InsertText(v) end)
                table.insert(self.EM_emojis, textbtn)
            end

            local space_x, space_y, row_buttons, y_offset = 35, 35, 10, 105
            for k, v in ipairs(self.EM_emojis) do
                local row = math.floor((k - 1) / row_buttons)
                local col = (k - 1) % row_buttons
                local buttons_in_row = math.min(row_buttons, #self.EM_emojis - row * row_buttons)
                local offset_x = (col - (buttons_in_row - 1) / 2) * space_x
                local offset_y = y_offset - row * space_y
                v:SetPosition(offset_x, offset_y)
            end
        end

        self.EM_page_2 = self.EM_bg:AddChild(Widget("page_2"))
        self.EM_page_2:Hide()

        local function RefreshPhraseList()
            local fl = {}
            for idx, freq in ipairs(GLOBAL.NOMU_QA.DATA.FREQ_LIST or {}) do 
                table.insert(fl, { idx = idx, freq = freq }) 
            end
            if self.EM_str_list then
                self.EM_str_list:Refresh(fl)
            end
        end

        self.EM_str_list = self.EM_page_2:AddChild(NoMuList(function()
            local item = Widget('freq-list-item')
            item.backing = item:AddChild(TEMPLATES.ListItemBackground(280, 40, function() end))
            item.backing.move_on_click = true
            item.text = item:AddChild(Text(GLOBAL.BODYTEXTFONT, 20, nil, GLOBAL.UICOLOURS.WHITE))
            
            item.delete = item:AddChild(TextButton())
            item.delete:SetFont(GLOBAL.CHATFONT)
            item.delete:SetTextSize(20)
            item.delete:SetText(GLOBAL.STRINGS.NOMU_QA.BUTTON_TEXT_DELETE)
            item.delete:SetPosition(120, 0, 0)
            item.delete:SetTextFocusColour({1,1,1,1})
            item.delete:SetTextColour({1,0,0,1})
            item.delete:Hide()
            
            function item:OnGainFocus() self.delete:Show() end
            function item:OnLoseFocus() self.delete:Hide() end
            
            item.SetInfo = function(_, data)
                local txt = data.freq
                if #txt > 45 then txt = string.sub(txt, 1, 45) .. "..." end
                item.text:SetString(txt)
                item.backing:SetOnClick(function() InsertText(data.freq) end)
                item.delete:SetOnClick(function() 
                    table.remove(GLOBAL.NOMU_QA.DATA.FREQ_LIST, data.idx)
                    GLOBAL.NOMU_QA.SaveData()
                    RefreshPhraseList()
                    if GLOBAL.ThePlayer and GLOBAL.ThePlayer.HUD and GLOBAL.ThePlayer.HUD.controls and GLOBAL.ThePlayer.HUD.controls.nomu_qa_panel then
                        GLOBAL.ThePlayer.HUD.controls.nomu_qa_panel:Refresh()
                    end
                end)
            end
            item.focus_forward = item.backing
            return item
        end, 0, 20, 280, 40, 1, 5))

        self.EM_input_root = self.EM_page_2:AddChild(Widget("input_root"))
        self.EM_input_root:SetPosition(0, -120)
        
        self.EM_input_box = self.EM_input_root:AddChild(TEMPLATES.StandardSingleLineTextEntry("", 220, 40, GLOBAL.CHATFONT, 26, "添加常用语"))
        self.EM_input_box:SetPosition(-45, 0)
        
        self.EM_input_btn = self.EM_input_root:AddChild(ImageButton("images/global_redux.xml", "button_carny_long_normal.tex", "button_carny_long_hover.tex", "button_carny_long_hover.tex"))
        self.EM_input_btn:SetFont(GLOBAL.CHATFONT)
        self.EM_input_btn.text:SetColour(0, 0, 0, 1)
        self.EM_input_btn:SetText("添加")
        self.EM_input_btn:SetTextSize(24)
        self.EM_input_btn:SetPosition(105, 0)
        self.EM_input_btn:ForceImageSize(70, 40)
        self.EM_input_btn:SetOnClick(function()
            local text = self.EM_input_box.textbox:GetString()
            if text and text ~= "" then
                table.insert(GLOBAL.NOMU_QA.DATA.FREQ_LIST, text)
                GLOBAL.NOMU_QA.SaveData()
                self.EM_input_box.textbox:SetString("")
                RefreshPhraseList()
                if GLOBAL.ThePlayer and GLOBAL.ThePlayer.HUD and GLOBAL.ThePlayer.HUD.controls and GLOBAL.ThePlayer.HUD.controls.nomu_qa_panel then
                    GLOBAL.ThePlayer.HUD.controls.nomu_qa_panel:Refresh()
                end
            end
        end)
        
        RefreshPhraseList()
    end

    local menu = (mode == "chat" and self.root or (mode == "input_string" and self.root or self)):AddChild(ImageButton("images/hud.xml", "self_inspect_mod.tex", "self_inspect_mod.tex", "self_inspect_mod.tex", nil, nil, {1,1}, {0,0}))
    menu.image:SetScale(0.6, 0.6, 1)
    
    if mode == "chat" then
        local pos = self.chat_type and self.chat_type:GetPosition()
        local x = pos and pos.x - 20 or -520
        menu:SetPosition(x, 0, 0)
    elseif mode == "input_string" then
        menu:SetPosition(0, -40, 0) -- 放在应用和取消的中间
    else
        menu:SetPosition(0, 60, 0)
        if self.SM_menu then menu:Hide() else menu:Show() end
    end
    
    menu.name = "emoji_menu"
    menu:SetOnGainFocus(function() menu.image:SetScale(0.7, 0.7, 1) end)
    menu:SetOnLoseFocus(function() menu.image:SetScale(0.6, 0.6, 1) end)
    menu:SetOnClick(function()
        if mode == "chat" then self.chat_edit:SetEditing(true) end
        if mode == "input_string" then self.config_input.textbox:SetEditing(true) end
        
        if self.EM_bg then
            if self.EM_bg.shown then self.EM_bg:Hide() else self.EM_bg:Show() end
        else
            build_bg()
        end
    end)

    self.EM_menu = menu
    table.insert(self.EM_all_widgets, menu)

    if not self.EM_input then
        self.EM_input = GLOBAL.TheInput:AddMouseButtonHandler(function(button, down)
            if not down then return false end
            
            if button == GLOBAL.MOUSEBUTTON_LEFT then
                if self.EM_bg and self.EM_bg.shown then
                    if self.EM_menu and self.EM_menu.focus then return false end

                    if not self.EM_bg.focus then
                        self.EM_bg:Hide()
                        if mode == "chat" and self.chat_edit then 
                            self.chat_edit:SetEditing(true) 
                        elseif mode == "input_string" and self.config_input then
                            self.config_input.textbox:SetEditing(true)
                        end
                        return true 
                    end
                end
            elseif button == GLOBAL.MOUSEBUTTON_RIGHT then
                if (mode == "chat" or mode == "input_string") and self.EM_menu and self.EM_menu.focus then
                    if self.EM_bg and self.EM_bg.shown then
                        self.EM_bg:Hide()
                        if mode == "chat" and self.chat_edit then self.chat_edit:SetEditing(true) end
                        if mode == "input_string" and self.config_input then self.config_input.textbox:SetEditing(true) end
                    else
                        if not self.EM_bg then build_bg() else self.EM_bg:Show() end
                    end
                    return true 
                end

                if self.EM_bg and self.EM_bg.shown then
                    if not self.EM_bg.focus then
                        self.EM_bg:Hide()
                        if mode == "chat" and self.chat_edit then 
                            self.chat_edit:SetEditing(true) 
                        elseif mode == "input_string" and self.config_input then
                            self.config_input.textbox:SetEditing(true)
                        end
                        return true 
                    end
                end
            end
        end)
    end
end

-- 字符串输入面板
local GetInputString = Class(NoMuScreen, function(self, nomu_parent, title, value, callback, limit, width)
    -- 稍微加宽默认宽度以容纳三个按钮布局
    NoMuScreen._ctor(self, "GetInputString", nomu_parent, width or 280, 130)
    
    self.config_label = self.root:AddChild(Text(BODYTEXTFONT, 32))
    self.config_label:SetString(title)
    self.config_label:SetHAlign(ANCHOR_MIDDLE)
    self.config_label:SetRegionSize(200, 40)
    self.config_label:SetPosition(0, 40)
    
    self.config_input = self.root:AddChild(TEMPLATES.StandardSingleLineTextEntry("", width or 200, 40))
    self.config_input.textbox:SetTextLengthLimit(limit or 50)
    self.config_input.textbox:SetString(tostring(value))
    self.config_input:SetPosition(0, 0, 0)
    
    -- 拉开应用和关闭按钮的间距，留出中间放表情按钮 (-80 和 80)
    self.AddButton(-80, -40, 100, 40, STRINGS.NOMU_QA.BUTTON_TEXT_APPLY, function() 
        callback(self.config_input.textbox:GetLineEditString())
        self:Close() 
    end)
    self.AddButton(80, -40, 100, 40, STRINGS.NOMU_QA.BUTTON_TEXT_CLOSE, function() 
        self:Close() 
    end)

    -- 调用并注入表情和常用语菜单功能
    CreateEmojiAndPhraseMenu(self, "input_string")
end)

-- 确认对话框
local ConfirmDialog = Class(NoMuScreen, function(self, nomu_parent, title, callback)
    NoMuScreen._ctor(self, "ConfirmDialog", nomu_parent, 250, 90)
    
    self.config_label = self.root:AddChild(Text(BODYTEXTFONT, 32))
    self.config_label:SetString(title)
    self.config_label:SetHAlign(ANCHOR_MIDDLE)
    self.config_label:SetRegionSize(250, 40)
    self.config_label:SetPosition(0, 20)
    
    self.AddButton(-50, -20, 100, 40, STRINGS.NOMU_QA.BUTTON_TEXT_YES, function() 
        callback()
        self:Close() 
    end)
    self.AddButton(50, -20, 100, 40, STRINGS.NOMU_QA.BUTTON_TEXT_NO, function() 
        self:Close() 
    end)
end)

-- 角色选择器面板
local CharacterPicker = Class(NoMuScreen, function(self, nomu_parent, callback)
    local iw, ih = 120, 40
    local width, height = iw + 10, 80 + ih * 4
    NoMuScreen._ctor(self, "CharacterPicker", nomu_parent, width, height + 10)
    
    self.character_list = self.root:AddChild(NoMuList(function()
        local item = Widget('character-list-item')
        item.backing = item:AddChild(TEMPLATES.ListItemBackground(iw, ih, function() end))
        item.backing.move_on_click = true
        item.text = item:AddChild(Text(BODYTEXTFONT, 26, nil, UICOLOURS.WHITE))
        
        item.SetInfo = function(_, character)
            item.text:SetString(character == 'DEFAULT' and STRINGS.NOMU_QA.TITLE_TEXT_MAPPING_DEFAULT or STRINGS.NAMES[character:upper()] or character:upper())
            item.backing:SetOnClick(function() 
                callback(character)
                self:Close() 
            end)
        end
        item.focus_forward = item.backing
        return item
    end, 0, 0, iw, ih, math.floor(width / iw), math.floor((height - 80) / ih)))
    
    self.AddButton(0, -height / 2 + 20, 120, 40, STRINGS.NOMU_QA.BUTTON_TEXT_CLOSE, function() self:Close() end)
    
    local character_list = { 'DEFAULT' }
    for _, character in ipairs(DST_CHARACTERLIST) do table.insert(character_list, character) end
    self.character_list:Refresh(character_list)
end)

-- 词库管理面板 (屏蔽词/整行屏蔽/文本替换/自定义名称) 
local QAWordManagementPanel = Class(NoMuScreen, function(self, nomu_parent)
    local width, height = 860, 480
    local x1, x2 = -215, 215
    local y_top, y_bot = 230, 5
    local dy = 35
    
    NoMuScreen._ctor(self, "QAWordManagementPanel", nomu_parent, width, height + 10)

    self.h_line = self.root:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
    self.h_line:SetScale(1.0, 1)
    self.h_line:SetPosition(0, 25)     

    self.title_forbidden = self.root:AddChild(Text(BODYTEXTFONT, 28))
    self.title_forbidden:SetString(STRINGS.NOMU_QA.TITLE_FORBIDDEN_LIST)
    self.title_forbidden:SetPosition(x1, y_top)
    
    self.AddToggle(x1 - 65, y_top - dy, 120, dy, "ENABLE_FORBIDDEN", STRINGS.NOMU_QA.BUTTON_TEXT_FORBIDDEN_ON, STRINGS.NOMU_QA.BUTTON_TEXT_FORBIDDEN_OFF)
    self.AddButton(x1 + 65, y_top - dy, 120, dy, STRINGS.NOMU_QA.BUTTON_NEW_FORBIDDEN, function()
        TheFrontEnd:PushScreen(GetInputString(self, STRINGS.NOMU_QA.TITLE_FORBIDDEN_LIST, '', function(value)
            if value and value ~= "" then 
                table.insert(GLOBAL.NOMU_QA.DATA.FORBIDDEN_WORDS, value)
                GLOBAL.NOMU_QA.SaveData()
                self:RefreshForbiddenList() 
            end
        end, 100, 300))
    end)
    self.forbidden_list = self.root:AddChild(NoMuList(function()
        local item = Widget('forbidden-list-item')
        item.backing = item:AddChild(TEMPLATES.ListItemBackground(240, 40, function() end))
        item.text = item:AddChild(Text(BODYTEXTFONT, 20, nil, UICOLOURS.WHITE))
        item.delete = item:AddChild(TextButton())
        item.delete:SetFont(CHATFONT)
        item.delete:SetTextSize(20)
        item.delete:SetText(STRINGS.NOMU_QA.BUTTON_TEXT_DELETE)
        item.delete:SetPosition(80, 0, 0)
        item.delete:SetTextColour({1,0,0,1})
        item.delete:Hide()
        function item:OnGainFocus() item.delete:Show() end
        function item:OnLoseFocus() item.delete:Hide() end
        item.SetInfo = function(_, data)
            item.text:SetString(data.word)
            item.delete:SetOnClick(function() 
                table.remove(GLOBAL.NOMU_QA.DATA.FORBIDDEN_WORDS, data.idx)
                GLOBAL.NOMU_QA.SaveData()
                self:RefreshForbiddenList() 
            end)
        end
        item.focus_forward = item.backing
        return item
    end, x1, y_top - 2*dy - 50, 240, 40, 1, 3))

    self.title_showme = self.root:AddChild(Text(BODYTEXTFONT, 28))
    self.title_showme:SetString(STRINGS.NOMU_QA.TITLE_SHOWME_FILTER)
    self.title_showme:SetPosition(x2, y_top)

    self.AddToggle(x2 - 65, y_top - dy, 120, dy, "ENABLE_SHOWME_FILTER", STRINGS.NOMU_QA.BUTTON_TEXT_SHOWME_ON, STRINGS.NOMU_QA.BUTTON_TEXT_SHOWME_OFF)
    self.AddButton(x2 + 65, y_top - dy, 120, dy, STRINGS.NOMU_QA.BUTTON_NEW_SHOWME_FILTER, function()
        TheFrontEnd:PushScreen(GetInputString(self, STRINGS.NOMU_QA.TITLE_SHOWME_FILTER, '', function(value)
            if value and value ~= "" then 
                if not GLOBAL.NOMU_QA.DATA.SHOWME_FILTERS then GLOBAL.NOMU_QA.DATA.SHOWME_FILTERS = {} end
                table.insert(GLOBAL.NOMU_QA.DATA.SHOWME_FILTERS, value)
                GLOBAL.NOMU_QA.SaveData()
                self:RefreshShowMeList() 
            end
        end, 100, 300))
    end)
    self.showme_list = self.root:AddChild(NoMuList(function()
        local item = Widget('showme-list-item')
        item.backing = item:AddChild(TEMPLATES.ListItemBackground(240, 40, function() end))
        item.text = item:AddChild(Text(BODYTEXTFONT, 20, nil, UICOLOURS.WHITE))
        item.delete = item:AddChild(TextButton())
        item.delete:SetFont(CHATFONT)
        item.delete:SetTextSize(20)
        item.delete:SetText(STRINGS.NOMU_QA.BUTTON_TEXT_DELETE)
        item.delete:SetPosition(80, 0, 0)
        item.delete:SetTextColour({1,0,0,1})
        item.delete:Hide()
        function item:OnGainFocus() item.delete:Show() end
        function item:OnLoseFocus() item.delete:Hide() end
        item.SetInfo = function(_, data)
            item.text:SetString(data.word)
            item.delete:SetOnClick(function() 
                table.remove(GLOBAL.NOMU_QA.DATA.SHOWME_FILTERS, data.idx)
                GLOBAL.NOMU_QA.SaveData()
                self:RefreshShowMeList() 
            end)
        end
        item.focus_forward = item.backing
        return item
    end, x2, y_top - 2*dy - 50, 240, 40, 1, 3)) 

    self.title_replace = self.root:AddChild(Text(BODYTEXTFONT, 28))
    self.title_replace:SetString(STRINGS.NOMU_QA.TITLE_REPLACE_LIST)
    self.title_replace:SetPosition(x1, y_bot)
    
    self.AddToggle(x1 - 65, y_bot - dy, 120, dy, "ENABLE_REPLACE", STRINGS.NOMU_QA.BUTTON_TEXT_REPLACE_ON, STRINGS.NOMU_QA.BUTTON_TEXT_REPLACE_OFF)
    self.AddButton(x1 + 65, y_bot - dy, 120, dy, STRINGS.NOMU_QA.BUTTON_NEW_REPLACE, function()
        TheFrontEnd:PushScreen(GetInputString(self, STRINGS.NOMU_QA.INPUT_REPLACE_TARGET, '', function(target_val)
            if target_val and target_val ~= "" then
                TheFrontEnd:PushScreen(GetInputString(self, STRINGS.NOMU_QA.INPUT_REPLACE_RESULT, '', function(result_val)
                    table.insert(GLOBAL.NOMU_QA.DATA.REPLACEMENTS, { target = target_val, result = result_val or "" })
                    GLOBAL.NOMU_QA.SaveData()
                    self:RefreshReplaceList()
                end, 100, 300))
            end
        end, 100, 300))
    end)
    self.replace_list = self.root:AddChild(NoMuList(function()
        local item = Widget('replace-list-item')
        item.backing = item:AddChild(TEMPLATES.ListItemBackground(280, 40, function() end))
        item.text = item:AddChild(Text(BODYTEXTFONT, 20, nil, UICOLOURS.WHITE))
        item.delete = item:AddChild(TextButton())
        item.delete:SetFont(CHATFONT)
        item.delete:SetTextSize(20)
        item.delete:SetText(STRINGS.NOMU_QA.BUTTON_TEXT_DELETE)
        item.delete:SetPosition(110, 0, 0)
        item.delete:SetTextColour({1,0,0,1})
        item.delete:Hide()
        function item:OnGainFocus() item.delete:Show() end
        function item:OnLoseFocus() item.delete:Hide() end
        item.SetInfo = function(_, data)
            item.text:SetString(data.rule.target .. " -> " .. (data.rule.result ~= "" and data.rule.result or "(空)"))
            item.delete:SetOnClick(function() 
                table.remove(GLOBAL.NOMU_QA.DATA.REPLACEMENTS, data.idx)
                GLOBAL.NOMU_QA.SaveData()
                self:RefreshReplaceList() 
            end)
        end
        item.focus_forward = item.backing
        return item
    end, x1, y_bot - 2*dy - 50, 280, 40, 1, 3)) 

    self.title_custom = self.root:AddChild(Text(BODYTEXTFONT, 28))
    self.title_custom:SetString(STRINGS.NOMU_QA.TITLE_CUSTOM_PREFAB_LIST)
    self.title_custom:SetPosition(x2, y_bot)

    self.AddToggle(x2 - 65, y_bot - dy, 120, dy, "ENABLE_CUSTOM_PREFAB_NAME", STRINGS.NOMU_QA.BUTTON_TEXT_CUSTOM_PREFAB_ON, STRINGS.NOMU_QA.BUTTON_TEXT_CUSTOM_PREFAB_OFF)
    self.AddButton(x2 + 65, y_bot - dy, 120, dy, STRINGS.NOMU_QA.BUTTON_NEW_CUSTOM_PREFAB, function()
        TheFrontEnd:PushScreen(GetInputString(self, STRINGS.NOMU_QA.INPUT_PREFAB_TARGET, '', function(prefab_val)
            if prefab_val and prefab_val ~= "" then
                TheFrontEnd:PushScreen(GetInputString(self, STRINGS.NOMU_QA.INPUT_PREFAB_RESULT, '', function(name_val)
                    if not GLOBAL.NOMU_QA.DATA.CUSTOM_PREFAB_NAMES then GLOBAL.NOMU_QA.DATA.CUSTOM_PREFAB_NAMES = {} end
                    table.insert(GLOBAL.NOMU_QA.DATA.CUSTOM_PREFAB_NAMES, { prefab = prefab_val, name = name_val or "" })
                    GLOBAL.NOMU_QA.SaveData()
                    self:RefreshCustomPrefabList()
                end, 100, 300))
            end
        end, 100, 300))
    end)
    self.custom_prefab_list = self.root:AddChild(NoMuList(function()
        local item = Widget('custom-prefab-list-item')
        item.backing = item:AddChild(TEMPLATES.ListItemBackground(280, 40, function() end))
        item.text = item:AddChild(Text(BODYTEXTFONT, 20, nil, UICOLOURS.WHITE))
        item.delete = item:AddChild(TextButton())
        item.delete:SetFont(CHATFONT)
        item.delete:SetTextSize(20)
        item.delete:SetText(STRINGS.NOMU_QA.BUTTON_TEXT_DELETE)
        item.delete:SetPosition(110, 0, 0)
        item.delete:SetTextColour({1,0,0,1})
        item.delete:Hide()
        function item:OnGainFocus() item.delete:Show() end
        function item:OnLoseFocus() item.delete:Hide() end
        item.SetInfo = function(_, data)
            item.text:SetString(data.rule.prefab .. " -> " .. (data.rule.name ~= "" and data.rule.name or "(空)"))
            item.delete:SetOnClick(function() 
                table.remove(GLOBAL.NOMU_QA.DATA.CUSTOM_PREFAB_NAMES, data.idx)
                GLOBAL.NOMU_QA.SaveData()
                self:RefreshCustomPrefabList() 
            end)
        end
        item.focus_forward = item.backing
        return item
    end, x2, y_bot - 2*dy - 50, 280, 40, 1, 3)) 

    -- 底部关闭按钮
    self.AddButton(0, -215, 200, 40, STRINGS.NOMU_QA.BUTTON_TEXT_CLOSE, function() self:Close() end)
    
    self:RefreshForbiddenList()
    self:RefreshShowMeList()
    self:RefreshReplaceList()
    self:RefreshCustomPrefabList()
end)

function QAWordManagementPanel:RefreshForbiddenList()
    local list = {}
    if GLOBAL.NOMU_QA.DATA.FORBIDDEN_WORDS then 
        for i, v in ipairs(GLOBAL.NOMU_QA.DATA.FORBIDDEN_WORDS) do table.insert(list, { idx = i, word = v }) end 
    end
    self.forbidden_list:Refresh(list)
end

function QAWordManagementPanel:RefreshShowMeList()
    local list = {}
    if GLOBAL.NOMU_QA.DATA.SHOWME_FILTERS then 
        for i, v in ipairs(GLOBAL.NOMU_QA.DATA.SHOWME_FILTERS) do table.insert(list, { idx = i, word = v }) end 
    end
    self.showme_list:Refresh(list)
end

function QAWordManagementPanel:RefreshReplaceList()
    local list = {}
    if GLOBAL.NOMU_QA.DATA.REPLACEMENTS then 
        for i, v in ipairs(GLOBAL.NOMU_QA.DATA.REPLACEMENTS) do table.insert(list, { idx = i, rule = v }) end 
    end
    self.replace_list:Refresh(list)
end

function QAWordManagementPanel:RefreshCustomPrefabList()
    local list = {}
    if GLOBAL.NOMU_QA.DATA.CUSTOM_PREFAB_NAMES then 
        for i, v in ipairs(GLOBAL.NOMU_QA.DATA.CUSTOM_PREFAB_NAMES) do table.insert(list, { idx = i, rule = v }) end 
    end
    self.custom_prefab_list:Refresh(list)
end

local QAConfigPanel = Class(NoMuScreen, function(self, nomu_parent)
    local width, height = 200, 620 
    NoMuScreen._ctor(self, "QAConfigPanel", nomu_parent, width, height + 10)

    local sy, row = height / 2 - 20, 0
    local function get_y() 
        local y = sy - row * 40
        row = row + 1
        return y 
    end
    local s = STRINGS.NOMU_QA

    self.AddToggle(0, get_y(), 200, 40, "BLOCK_ACTION", s.BUTTON_TEXT_BLOCK_ACTION_ON, s.BUTTON_TEXT_BLOCK_ACTION_OFF)
    self.AddToggle(0, get_y(), 200, 40, "ANNOUNCE_ALL_MISSING_INGREDIENTS", s.BUTTON_TEXT_ANNOUNCE_ALL_MISSING_ON, s.BUTTON_TEXT_ANNOUNCE_ALL_MISSING_OFF)
    self.AddToggle(0, get_y(), 200, 40, "DEFAULT_WHISPER", s.BUTTON_TEXT_DEFAULT_WHISPER_ON, s.BUTTON_TEXT_DEFAULT_WHISPER_OFF)
    self.AddToggle(0, get_y(), 200, 40, "CHARACTER_SPECIFIC", s.BUTTON_TEXT_CHARACTER_SPECIFIC_ON, s.BUTTON_TEXT_CHARACTER_SPECIFIC_OFF)
    self.AddToggle(0, get_y(), 200, 40, "FREQ_AUTO_CLOSE", s.BUTTON_TEXT_FREQ_AUTO_CLOSE_ON, s.BUTTON_TEXT_FREQ_AUTO_CLOSE_OFF)
    self.AddButton(0, get_y(), 200, 40, function() return GLOBAL.NOMU_QA.DATA.SHOW_ME == 1 and s.BUTTON_TEXT_SHOW_ME_ON or (GLOBAL.NOMU_QA.DATA.SHOW_ME == 2 and s.BUTTON_TEXT_SHOW_ME_GIFT or s.BUTTON_TEXT_SHOW_ME_OFF) end, function() GLOBAL.NOMU_QA.DATA.SHOW_ME = (GLOBAL.NOMU_QA.DATA.SHOW_ME + 1) % 3; GLOBAL.NOMU_QA.SaveData() end)
    self.AddButton(0, get_y(), 200, 40, function() 
        return GLOBAL.NOMU_QA.DATA.ANNOUNCE_RANGE == 60 and s.BUTTON_TEXT_ANNOUNCE_RANGE_LARGE or s.BUTTON_TEXT_ANNOUNCE_RANGE_DEFAULT 
    end, function() 
        GLOBAL.NOMU_QA.DATA.ANNOUNCE_RANGE = GLOBAL.NOMU_QA.DATA.ANNOUNCE_RANGE == 40 and 60 or 40 
        GLOBAL.NOMU_QA.SaveData() 
    end)
    self.AddToggle(0, get_y(), 200, 40, "FUZZY_ANNOUNCE", s.BUTTON_TEXT_FUZZY_ON, s.BUTTON_TEXT_FUZZY_OFF)
    self.AddToggle(0, get_y(), 200, 40, "SHOW_PREFIX", s.BUTTON_TEXT_PREFIX_ON, s.BUTTON_TEXT_PREFIX_OFF)
    self.AddButton(0, get_y(), 200, 40, function() 
        local v = GLOBAL.NOMU_QA.DATA.SHOW_DISTANCE
        if type(v) == "boolean" then v = v and 1 or 0 end
        return v == 1 and s.BUTTON_TEXT_DISTANCE_ON or (v == 2 and s.BUTTON_TEXT_DISTANCE_PRECISE or s.BUTTON_TEXT_DISTANCE_OFF)
    end, function() 
        local v = GLOBAL.NOMU_QA.DATA.SHOW_DISTANCE
        if type(v) == "boolean" then v = v and 1 or 0 end
        GLOBAL.NOMU_QA.DATA.SHOW_DISTANCE = (v + 1) % 3
        GLOBAL.NOMU_QA.SaveData() 
    end)
    self.AddToggle(0, get_y(), 200, 40, "SHOW_MOD_NAME", s.BUTTON_TEXT_SHOW_MOD_NAME_ON, s.BUTTON_TEXT_SHOW_MOD_NAME_OFF)

    self.AddToggle(0, get_y(), 200, 40, "ENABLE_SPECIAL_STATE", s.BUTTON_TEXT_SPECIAL_STATE_ON, s.BUTTON_TEXT_SPECIAL_STATE_OFF)
    
    self.AddButton(0, get_y(), 200, 40, function() return GLOBAL.NOMU_QA.DATA.SHOW_ASSET_INFO == 1 and s.BUTTON_TEXT_SHOW_ASSET_CODE or (GLOBAL.NOMU_QA.DATA.SHOW_ASSET_INFO == 2 and s.BUTTON_TEXT_SHOW_ASSET_ALL or s.BUTTON_TEXT_SHOW_ASSET_OFF) end, function() GLOBAL.NOMU_QA.DATA.SHOW_ASSET_INFO = (GLOBAL.NOMU_QA.DATA.SHOW_ASSET_INFO + 1) % 3; GLOBAL.NOMU_QA.SaveData() end)
    self.AddToggle(0, get_y(), 200, 40, "DEBUG_MODE", s.BUTTON_TEXT_DEBUG_ON, s.BUTTON_TEXT_DEBUG_OFF)
    self.AddButton(0, get_y(), 200, 40, s.BUTTON_TEXT_CLOSE, function() self:Close() end)
end)

local function ValidateScheme(scheme) return scheme.name ~= nil and scheme.data ~= nil and scheme.version ~= nil end

local SchemeTemplatePicker = Class(NoMuScreen, function(self, nomu_parent, callback)
    local iw, ih = 200, 40
    local width, height = iw + 40, 80 + ih * 5
    NoMuScreen._ctor(self, "SchemeTemplatePicker", nomu_parent, width, height + 10)
    
    self.title = self.root:AddChild(Text(BODYTEXTFONT, 28))
    self.title:SetString(STRINGS.NOMU_QA.TITLE_TEXT_CHOOSE_TEMPLATE or "选择模板方案")
    self.title:SetPosition(0, height / 2 - 25)
    
    self.scheme_list = self.root:AddChild(NoMuList(function()
        local item = Widget('scheme-list-item')
        item.backing = item:AddChild(TEMPLATES.ListItemBackground(iw, ih, function() end))
        item.backing.move_on_click = true
        item.text = item:AddChild(Text(BODYTEXTFONT, 20, nil, UICOLOURS.WHITE))
        
        item.SetInfo = function(_, scheme) 
            item.text:SetString(scheme.name)
            item.backing:SetOnClick(function() 
                callback(scheme)
                self:Close() 
            end) 
        end
        item.focus_forward = item.backing
        return item
    end, 0, -10, iw, ih, 1, 5))
    
    self.AddButton(0, -height / 2 + 25, 120, 40, STRINGS.NOMU_QA.BUTTON_TEXT_CLOSE, function() self:Close() end)
    self.scheme_list:Refresh(GLOBAL.NOMU_QA.DATA.SCHEMES)
end)

local QACustomizePanel = Class(NoMuScreen, function(self, nomu_parent)
    local width, height = 860, 480
    local sy, sx, dy = height / 2 - 20, -width / 2, 40
    self.sx, self.sy, self.dy = sx, sy, dy
    NoMuScreen._ctor(self, "QACustomizePanel", nomu_parent, width, height + 10)

    self.scheme_idx = 1
    self.title_text_schemes = self.root:AddChild(Text(BODYTEXTFONT, 32))
    self.title_text_schemes:SetString(STRINGS.NOMU_QA.TITLE_TEXT_SCHEMES)
    self.title_text_schemes:SetHAlign(ANCHOR_MIDDLE)
    self.title_text_schemes:SetRegionSize(200, dy)
    self.title_text_schemes:SetPosition(sx + 100, sy)
    
    self.default_scheme_hint = self.root:AddChild(Text(BODYTEXTFONT, 18))
    self.default_scheme_hint:SetString(STRINGS.NOMU_QA.DEFAULT_SCHEME_RESET_HINT)
    self.default_scheme_hint:SetHAlign(ANCHOR_MIDDLE)
    self.default_scheme_hint:SetRegionSize(240, 50)
    self.default_scheme_hint:SetPosition(sx + 100, sy - 35)
    self.default_scheme_hint:SetColour(0.9, 0.6, 0.6, 1) 

    self.AddButton(sx + 100, sy - 75, 200, dy, STRINGS.NOMU_QA.BUTTON_TEXT_NEW_SCHEME, function() 
        TheFrontEnd:PushScreen(GetInputString(self, STRINGS.NOMU_QA.BUTTON_TEXT_NEW_SCHEME, '', function(value)
            if not value or value == "" then return end
            local iscr = TheFrontEnd:GetActiveScreen()
            if iscr and iscr.name == "GetInputString" then iscr.nomu_parent = nil end
            TheFrontEnd:PushScreen(SchemeTemplatePicker(self, function(ts) 
                table.insert(GLOBAL.NOMU_QA.DATA.SCHEMES, { 
                    name = value, 
                    data = DeepCopy(ts.data), 
                    version = VERSION,
                    source_template = ts.source_template or ts.name,
                    backup_data = DeepCopy(ts.data)
                })
                GLOBAL.NOMU_QA.SaveData()
                self:RefreshSchemeList()
                self:RefreshScheme(#GLOBAL.NOMU_QA.DATA.SCHEMES) 
            end))
        end))
    end)

    self.scheme_list = self.root:AddChild(NoMuList(function()
        local item = Widget('scheme-list-item')
        item.backing = item:AddChild(TEMPLATES.ListItemBackground(200, 40, function() end))
        item.backing.move_on_click = true
        item.text = item:AddChild(Text(BODYTEXTFONT, 20, nil, UICOLOURS.WHITE))
        
        item.delete = item:AddChild(TextButton())
        item.delete:SetFont(CHATFONT)
        item.delete:SetTextSize(20)
        item.delete:SetText(STRINGS.NOMU_QA.BUTTON_TEXT_DELETE)
        item.delete:SetPosition(70, 0, 0)
        item.delete:SetTextFocusColour({1,1,1,1})
        item.delete:SetTextColour({1,0,0,1})
        item.delete:Hide()
        
        item.rename = item:AddChild(TextButton())
        item.rename:SetFont(CHATFONT)
        item.rename:SetTextSize(20)
        item.rename:SetText(STRINGS.NOMU_QA.BUTTON_TEXT_RENAME)
        item.rename:SetPosition(-70, 0, 0)
        item.rename:SetTextFocusColour({1,1,1,1})
        item.rename:SetTextColour({0,1,0,1})
        item.rename:Hide()

        function item:OnGainFocus() 
            self.delete:Show()
            if not item.no_rename then item.rename:Show() end 
        end
        function item:OnLoseFocus() 
            self.delete:Hide()
            if not item.no_rename then item.rename:Hide() end 
        end

        item.SetInfo = function(_, data)
            item.text:SetString(data.name)
            item.backing:SetOnClick(function() self:RefreshScheme(data.idx) end)

            if data.idx <= 4 then
                item.rename:Hide()
                item.no_rename = true
                item.delete:SetText(STRINGS.NOMU_QA.BUTTON_TEXT_RESET)
                item.delete:SetOnClick(function() 
                    TheFrontEnd:PushScreen(ConfirmDialog(nil, STRINGS.NOMU_QA.TITLE_TEXT_SURE_TO_RESET_DEFAULT, function() 
                        local default_schemes = { GLOBAL.STRINGS.DEFAULT_NOMU_QA, GLOBAL.STRINGS.CAT_NOMU_QA, GLOBAL.STRINGS.TSUNDERE_NOMU_QA, GLOBAL.STRINGS.CUTE_NOMU_QA }
                        GLOBAL.NOMU_QA.DATA.SCHEMES[data.idx].data = DeepCopy(default_schemes[data.idx])
                        GLOBAL.NOMU_QA.SaveData()
                        self:RefreshScheme(data.idx) 
                    end)) 
                end)
            else
                item.delete:SetOnClick(function()
                    TheFrontEnd:PushScreen(ConfirmDialog(nil, STRINGS.NOMU_QA.TITLE_TEXT_SURE_TO_DELETE, function() 
                        table.remove(GLOBAL.NOMU_QA.DATA.SCHEMES, data.idx)
                        GLOBAL.NOMU_QA.SaveData()
                        self:RefreshSchemeList()
                        if data.idx == self.scheme_idx then 
                            self:RefreshScheme(1) 
                        elseif data.idx < self.scheme_idx then 
                            self:RefreshScheme(self.scheme_idx - 1) 
                        end 
                    end)) 
                end)
                item.rename:SetOnClick(function() 
                    TheFrontEnd:PushScreen(GetInputString(nil, STRINGS.NOMU_QA.BUTTON_TEXT_RENAME, data.name, function(val) 
                        GLOBAL.NOMU_QA.DATA.SCHEMES[data.idx].name = val
                        GLOBAL.NOMU_QA.SaveData()
                        self:RefreshSchemeList()
                        self:RefreshScheme(data.idx) 
                    end)) 
                end)
            end
        end
        item.focus_forward = item.backing
        return item
    end, sx + 100, -55, 200, 40, 1, 9))

    self.AddButton(sx + 100, -sy, 200, 40, STRINGS.NOMU_QA.BUTTON_TEXT_IMPORT_SCHEME, function()
        TheFrontEnd:PushScreen(GetInputString(nil, STRINGS.NOMU_QA.TITLE_TEXT_SCHEME_FILENAME, '', function(filename)
            if string.sub(filename, -5) ~= '.json' then 
                return TheFrontEnd:PushScreen(ConfirmDialog(nil, STRINGS.NOMU_QA.JSON_NEEDED, function() end)) 
            end
            local file = io.open('unsafedata/' .. filename)
            if file then
                local scheme = json.decode(file:read('*a'))
                file:close()
                if ValidateScheme(scheme) then 
                    table.insert(GLOBAL.NOMU_QA.DATA.SCHEMES, scheme)
                    GLOBAL.NOMU_QA.SaveData()
                    self:RefreshSchemeList()
                    self:RefreshScheme(#GLOBAL.NOMU_QA.DATA.SCHEMES)
                    return ThePlayer.components.talker:Say(STRINGS.NOMU_QA.MESSAGE_IMPORT_SUCCEED) 
                end
            end
            ThePlayer.components.talker:Say(STRINGS.NOMU_QA.MESSAGE_IMPORT_FAILED)
        end))
    end)

    self.vertical_line = self.root:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
    self.vertical_line:SetRotation(90)
    self.vertical_line:SetScale(1, 0.57)

    sx = sx + 260
    self.title_text_editing = self.root:AddChild(Text(BODYTEXTFONT, 32))
    self.title_text_editing:SetHAlign(ANCHOR_MIDDLE)
    self.title_text_editing:SetRegionSize(600, dy)
    self.title_text_editing:SetPosition(sx + 300, sy)
    
    self.AddButton(sx + 300, -sy, 200, 40, STRINGS.NOMU_QA.BUTTON_TEXT_APPLY_SCHEME, function()
        TheFrontEnd:PushScreen(ConfirmDialog(nil, subfmt(STRINGS.NOMU_QA.TITLE_TEXT_SURE_TO_APPLY_SCHEME, { NAME = self.scheme.name }), function() 
            GLOBAL.NOMU_QA.DATA.CURRENT_SCHEME = GLOBAL.NOMU_QA.DATA.SCHEMES[self.scheme_idx]
            GLOBAL.NOMU_QA.SaveData()
            GLOBAL.NOMU_QA.ApplyScheme(GLOBAL.NOMU_QA.DATA.CURRENT_SCHEME) 
        end))
    end)

    local function save_and_apply() 
        GLOBAL.NOMU_QA.DATA.SCHEMES[self.scheme_idx] = DeepCopy(self.scheme)
        GLOBAL.NOMU_QA.DATA.CURRENT_SCHEME = GLOBAL.NOMU_QA.DATA.SCHEMES[self.scheme_idx]
        GLOBAL.NOMU_QA.SaveData()
        GLOBAL.NOMU_QA.ApplyScheme(GLOBAL.NOMU_QA.DATA.CURRENT_SCHEME) 
    end

    self.AddButton(sx + 100, -sy, 200, 40, STRINGS.NOMU_QA.BUTTON_TEXT_EXPORT_SCHEME, function()
        TheFrontEnd:PushScreen(GetInputString(nil, STRINGS.NOMU_QA.TITLE_TEXT_SCHEME_FILENAME, '', function(filename)
            if string.sub(filename, -5) ~= '.json' then 
                return TheFrontEnd:PushScreen(ConfirmDialog(nil, STRINGS.NOMU_QA.JSON_NEEDED, function() end)) 
            end
            local file = io.open('unsafedata/' .. filename, 'w')
            if file then 
                file:write(json.encode(GLOBAL.NOMU_QA.DATA.SCHEMES[self.scheme_idx]))
                file:close()
                ThePlayer.components.talker:Say(STRINGS.NOMU_QA.MESSAGE_EXPORT_SUCCEED)
            else 
                ThePlayer.components.talker:Say(STRINGS.NOMU_QA.MESSAGE_EXPORT_FAILED) 
            end
        end))
    end)
    self.AddButton(sx + 500, -sy, 200, 40, STRINGS.NOMU_QA.BUTTON_TEXT_CLOSE, function() self:Close() end)

    self.title_text_func = self.root:AddChild(Text(BODYTEXTFONT, 32))
    self.title_text_func:SetHAlign(ANCHOR_MIDDLE)
    self.title_text_func:SetRegionSize(120, dy)
    self.title_text_func:SetPosition(sx + 60, sy - dy)
    self.title_text_func:SetString(STRINGS.NOMU_QA.TITLE_TEXT_FUNC)

    self.func_list = self.root:AddChild(NoMuList(function()
        local item = Widget('func-list-item')
        item.backing = item:AddChild(TEMPLATES.ListItemBackground(120, 40, function() end))
        item.backing.move_on_click = true
        item.text = item:AddChild(Text(BODYTEXTFONT, 20, nil, UICOLOURS.WHITE))
        
        item.SetInfo = function(_, func) 
            item.text:SetString(STRINGS.NOMU_QA.FUNC[func])
            item.backing:SetOnClick(function() self:RefreshFunc(func) end) 
        end
        item.focus_forward = item.backing
        return item
    end, sx + 60, -20, 120, 40, 1, 9))

    sx = sx + 160
    self.title_text_format = self.root:AddChild(Text(BODYTEXTFONT, 32))
    self.title_text_format:SetHAlign(ANCHOR_MIDDLE)
    self.title_text_format:SetRegionSize(420, dy)
    self.title_text_format:SetPosition(sx + 210, sy - dy)
    
    self.format_list = self.root:AddChild(NoMuList(function()
        local item = Widget('format-list-item')
        item.backing = item:AddChild(TEMPLATES.ListItemBackground(420, 40, function() end))
        item.backing.move_on_click = true
        item.text = item:AddChild(Text(BODYTEXTFONT, 20, nil, UICOLOURS.WHITE))
        
        item.SetInfo = function(_, format)
            item.text:SetString(format.name .. ': ' .. format.value)
            item.backing:SetOnClick(function() 
                TheFrontEnd:PushScreen(GetInputString(nil, STRINGS.NOMU_QA.FUNC[self.scheme_func] .. '-' .. format.name, format.value, function(value) 
                    self.scheme.data[self.scheme_func].FORMATS[format.name] = value
                    save_and_apply()
                    self:RefreshFunc() 
                end, 256, 420)) 
            end)
        end
        item.focus_forward = item.backing
        return item
    end, sx + 210, sy - 3.5 * dy, 420, 40, 1, 3))

    self.btn_mapping = self.AddButton(sx + 210, sy - 5 * dy, 200, 40, STRINGS.NOMU_QA.BUTTON_TEXT_MAPPING, function()
        TheFrontEnd:PushScreen(CharacterPicker(nil, function(mapping) 
            mapping = mapping:upper()
            if not self.scheme.data[self.scheme_func].MAPPINGS[mapping] then 
                self.scheme.data[self.scheme_func].MAPPINGS[mapping] = DeepCopy(self.scheme.data[self.scheme_func].MAPPINGS.DEFAULT) 
            end
            self:RefreshFunc(nil, mapping) 
        end))
    end)
    if not GLOBAL.NOMU_QA.DATA.CHARACTER_SPECIFIC then 
        self.btn_mapping:Disable() 
    end

    self.mapping_list = self.root:AddChild(NoMuList(function()
        local item = Widget('mapping-list-item')
        item.backing = item:AddChild(TEMPLATES.ListItemBackground(420, 40, function() end))
        item.backing.move_on_click = true
        item.text = item:AddChild(Text(BODYTEXTFONT, 20, nil, UICOLOURS.WHITE))
        
        item.SetInfo = function(_, mapping)
            item.text:SetString(mapping.category .. '-' .. mapping.name .. ': ' .. mapping.value)
            item.backing:SetOnClick(function() 
                TheFrontEnd:PushScreen(GetInputString(nil, mapping.category .. '-' .. mapping.name, mapping.value, function(val) 
                    self.scheme.data[self.scheme_func].MAPPINGS[self.scheme_mapping][mapping.category][mapping.name] = val
                    save_and_apply()
                    self:RefreshFunc() 
                end, 256, 420)) 
            end)
        end
        item.focus_forward = item.backing
        return item
    end, sx + 210, sy - 8 * dy, 420, 40, 1, 5))

    self:RefreshSchemeList()
    self:RefreshScheme(1)
end)

function QACustomizePanel:RefreshSchemeList()
    self.vertical_line:SetPosition(self.sx + (#GLOBAL.NOMU_QA.DATA.SCHEMES <= 9 and 220 or 230), 0)
    local sl = {}
    for idx, scheme in ipairs(GLOBAL.NOMU_QA.DATA.SCHEMES) do 
        table.insert(sl, { idx = idx, name = scheme.name }) 
    end
    self.scheme_list:Refresh(sl)
end

function QACustomizePanel:RefreshScheme(idx)
    self.scheme_idx = idx or self.scheme_idx
    self.scheme = DeepCopy(GLOBAL.NOMU_QA.DATA.SCHEMES[self.scheme_idx])
    self.title_text_editing:SetString(STRINGS.NOMU_QA.TITLE_TEXT_EDITING .. self.scheme.name)
    local fl = {}
    
    -- 防止坏档
    if not self.scheme.data then
        self.scheme.data = {}
    end

    for func in pairs(self.scheme.data) do 
        table.insert(fl, func) 
    end
    self.func_list:Refresh(fl)
    self:RefreshFunc(fl[1], 'DEFAULT')
end

function QACustomizePanel:RefreshFunc(func, mapping)
    self.scheme_func = func or self.scheme_func
    self.title_text_format:SetString(subfmt(STRINGS.NOMU_QA.TITLE_TEXT_FORMAT, { NAME = STRINGS.NOMU_QA.FUNC[self.scheme_func] }))
    local fl, ml = {}, {}
    for name, format in pairs(self.scheme.data[self.scheme_func].FORMATS) do 
        table.insert(fl, { name = name, value = format }) 
    end

    if self.scheme.data[self.scheme_func].MAPPINGS.DEFAULT then
        self.scheme_mapping = mapping or self.scheme_mapping
        if not self.scheme.data[self.scheme_func].MAPPINGS[self.scheme_mapping] then 
            self.scheme_mapping = 'DEFAULT' 
        end
        self.mapping_list:Show()
        self.btn_mapping:Show()
        self.btn_mapping:SetText(subfmt(STRINGS.NOMU_QA.BUTTON_TEXT_MAPPING, { NAME = (self.scheme_mapping == 'DEFAULT' and STRINGS.NOMU_QA.TITLE_TEXT_MAPPING_DEFAULT or STRINGS.NAMES[self.scheme_mapping] or self.scheme_mapping) }))
        
        for cat, items in pairs(self.scheme.data[self.scheme_func].MAPPINGS[self.scheme_mapping]) do 
            for name, value in pairs(items) do 
                table.insert(ml, { category = cat, name = name, value = value }) 
            end 
        end
    else 
        self.mapping_list:Hide()
        self.btn_mapping:Hide() 
    end

    local n_format = math.min(8 - math.min(#ml, 4), #fl)
    self.format_list:Refresh(fl, { rows = n_format, y = self.sy - self.dy * (1.5 + 0.5 * n_format) })
    self.btn_mapping:SetPosition(self.sx + 630, self.sy - (2 + n_format) * self.dy)
    self.mapping_list:Refresh(ml, { rows = 8 - n_format, y = self.sy - (2.5 + 0.5 * (8 - n_format) + n_format) * self.dy })
end

-- 快捷宣告主面板
local QAPanel = Class(Widget, function(self)
    local width, height = 860, 480
    local sy, dy = height / 2 - 20, 40
    Widget._ctor(self, "QAPanel")
    
    self.root = self:AddChild(TEMPLATES.RectangleWindow(width, height + 10))
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetPosition(0, 0)

    local function AddBtn(x, y, w, h, text, fn)
        local btn = self.root:AddChild(ImageButton("images/global_redux.xml", "button_carny_long_normal.tex", "button_carny_long_hover.tex", "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
        btn:SetFont(CHATFONT)
        btn:SetPosition(x, y, 0)
        btn.text:SetColour(0, 0, 0, 1)
        btn:SetTextSize(26)
        btn:ForceImageSize(w, h)
        btn:SetOnClick(function() 
            fn(btn)
            if type(text) == 'function' then btn:SetText(text(btn)) end 
        end)
        btn:SetText(type(text) == 'function' and text(btn) or text)
        return btn
    end

    local function AddToggleBtn(x, y, w, h, key, ton, toff)
        return AddBtn(x, y, w, h, function() return GLOBAL.NOMU_QA.DATA[key] and ton or toff end, function() 
            GLOBAL.NOMU_QA.DATA[key] = not GLOBAL.NOMU_QA.DATA[key]
            GLOBAL.NOMU_QA.SaveData() 
        end)
    end

    self.title_text = self.root:AddChild(Text(BODYTEXTFONT, 32))
    self.title_text:SetString(STRINGS.NOMU_QA.TITLE_TEXT_QA)
    self.title_text:SetHAlign(ANCHOR_MIDDLE)
    self.title_text:SetRegionSize(width, dy)
    self.title_text:SetPosition(0, sy)
    
    self.vertical_line = self.root:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
    self.vertical_line:SetRotation(90)
    self.vertical_line:SetScale(1, 0.45)
    self.vertical_line:SetPosition(0, 15) 

    AddBtn(-320, sy - dy, 200, dy, STRINGS.NOMU_QA.BUTTON_TEXT_NEW_FREQ, function() 
        TheFrontEnd:PushScreen(GetInputString(self, STRINGS.NOMU_QA.BUTTON_TEXT_NEW_FREQ, '', function(val) 
            table.insert(GLOBAL.NOMU_QA.DATA.FREQ_LIST, val)
            GLOBAL.NOMU_QA.SaveData()
            self:Refresh() 
        end, 256, 420)) 
    end)
    AddBtn(-120, sy - dy, 200, dy, STRINGS.NOMU_QA.BUTTON_TEXT_CUSTOMIZE, function() 
        TheFrontEnd:PushScreen(QACustomizePanel(self)) 
    end)

    self.freq_list = self.root:AddChild(NoMuList(function()
        local item = Widget('freq-list-item')
        item.backing = item:AddChild(TEMPLATES.ListItemBackground(200, 40, function() end))
        item.backing.move_on_click = true
        item.text = item:AddChild(Text(BODYTEXTFONT, 20, nil, UICOLOURS.WHITE))
        
        item.delete = item:AddChild(TextButton())
        item.delete:SetFont(CHATFONT)
        item.delete:SetTextSize(20)
        item.delete:SetText(STRINGS.NOMU_QA.BUTTON_TEXT_DELETE)
        item.delete:SetPosition(80, 0, 0)
        item.delete:SetTextFocusColour({1,1,1,1})
        item.delete:SetTextColour({1,0,0,1})
        item.delete:Hide()
        
        function item:OnGainFocus() self.delete:Show() end
        function item:OnLoseFocus() self.delete:Hide() end
        
        item.SetInfo = function(_, data)
            item.text:SetString(data.freq)
            item.backing:SetOnClick(function() 
                Announce(data.freq)
                if GLOBAL.NOMU_QA.DATA.FREQ_AUTO_CLOSE then self:Hide() end 
            end)
            item.delete:SetOnClick(function() 
                TheFrontEnd:PushScreen(ConfirmDialog(nil, STRINGS.NOMU_QA.TITLE_TEXT_SURE_TO_DELETE, function() 
                    table.remove(GLOBAL.NOMU_QA.DATA.FREQ_LIST, data.idx)
                    GLOBAL.NOMU_QA.SaveData()
                    self:Refresh() 
                end)) 
            end)
        end
        item.focus_forward = item.backing
        return item
    end, -220, 0, 200, 40, 2, 7)) 

    AddBtn(-220, -170, 400, dy, STRINGS.NOMU_QA.BUTTON_TEXT_WORD_MANAGE, function() 
        TheFrontEnd:PushScreen(QAWordManagementPanel(self)) 
    end)

    local s = STRINGS.NOMU_QA
    AddToggleBtn(120, sy - dy, 200, dy, "BLOCK_ACTION", s.BUTTON_TEXT_BLOCK_ACTION_ON, s.BUTTON_TEXT_BLOCK_ACTION_OFF)
    AddToggleBtn(320, sy - dy, 200, dy, "ANNOUNCE_ALL_MISSING_INGREDIENTS", s.BUTTON_TEXT_ANNOUNCE_ALL_MISSING_ON, s.BUTTON_TEXT_ANNOUNCE_ALL_MISSING_OFF)
    AddToggleBtn(120, sy - 2*dy, 200, dy, "DEFAULT_WHISPER", s.BUTTON_TEXT_DEFAULT_WHISPER_ON, s.BUTTON_TEXT_DEFAULT_WHISPER_OFF)
    AddToggleBtn(320, sy - 2*dy, 200, dy, "CHARACTER_SPECIFIC", s.BUTTON_TEXT_CHARACTER_SPECIFIC_ON, s.BUTTON_TEXT_CHARACTER_SPECIFIC_OFF)
    AddToggleBtn(120, sy - 3*dy, 200, dy, "FREQ_AUTO_CLOSE", s.BUTTON_TEXT_FREQ_AUTO_CLOSE_ON, s.BUTTON_TEXT_FREQ_AUTO_CLOSE_OFF)
    
    AddBtn(320, sy - 3*dy, 200, dy, function() 
        return GLOBAL.NOMU_QA.DATA.SHOW_ME == 1 and s.BUTTON_TEXT_SHOW_ME_ON or (GLOBAL.NOMU_QA.DATA.SHOW_ME == 2 and s.BUTTON_TEXT_SHOW_ME_GIFT or s.BUTTON_TEXT_SHOW_ME_OFF) 
    end, function() 
        GLOBAL.NOMU_QA.DATA.SHOW_ME = (GLOBAL.NOMU_QA.DATA.SHOW_ME + 1) % 3
        GLOBAL.NOMU_QA.SaveData() 
    end)
    
    AddBtn(120, sy - 4*dy, 200, dy, function() 
        return GLOBAL.NOMU_QA.DATA.ANNOUNCE_RANGE == 60 and s.BUTTON_TEXT_ANNOUNCE_RANGE_LARGE or s.BUTTON_TEXT_ANNOUNCE_RANGE_DEFAULT 
    end, function() 
        GLOBAL.NOMU_QA.DATA.ANNOUNCE_RANGE = GLOBAL.NOMU_QA.DATA.ANNOUNCE_RANGE == 40 and 60 or 40 
        GLOBAL.NOMU_QA.SaveData() 
    end)
    AddToggleBtn(320, sy - 4*dy, 200, dy, "FUZZY_ANNOUNCE", s.BUTTON_TEXT_FUZZY_ON, s.BUTTON_TEXT_FUZZY_OFF)
    AddBtn(120, sy - 5*dy, 200, dy, function() 
        local v = GLOBAL.NOMU_QA.DATA.SHOW_DISTANCE
        if type(v) == "boolean" then v = v and 1 or 0 end
        return v == 1 and s.BUTTON_TEXT_DISTANCE_ON or (v == 2 and s.BUTTON_TEXT_DISTANCE_PRECISE or s.BUTTON_TEXT_DISTANCE_OFF) 
    end, function() 
        local v = GLOBAL.NOMU_QA.DATA.SHOW_DISTANCE
        if type(v) == "boolean" then v = v and 1 or 0 end
        GLOBAL.NOMU_QA.DATA.SHOW_DISTANCE = (v + 1) % 3
        GLOBAL.NOMU_QA.SaveData() 
    end)
    AddToggleBtn(320, sy - 5*dy, 200, dy, "SHOW_PREFIX", s.BUTTON_TEXT_PREFIX_ON, s.BUTTON_TEXT_PREFIX_OFF)
    AddToggleBtn(120, sy - 6*dy, 200, dy, "SHOW_MOD_NAME", s.BUTTON_TEXT_SHOW_MOD_NAME_ON, s.BUTTON_TEXT_SHOW_MOD_NAME_OFF)
    AddToggleBtn(320, sy - 6*dy, 200, dy, "ENABLE_SPECIAL_STATE", s.BUTTON_TEXT_SPECIAL_STATE_ON, s.BUTTON_TEXT_SPECIAL_STATE_OFF)
    AddBtn(120, sy - 7*dy, 200, dy, function() 
        return GLOBAL.NOMU_QA.DATA.SHOW_ASSET_INFO == 1 and s.BUTTON_TEXT_SHOW_ASSET_CODE or (GLOBAL.NOMU_QA.DATA.SHOW_ASSET_INFO == 2 and s.BUTTON_TEXT_SHOW_ASSET_ALL or s.BUTTON_TEXT_SHOW_ASSET_OFF) 
    end, function() 
        GLOBAL.NOMU_QA.DATA.SHOW_ASSET_INFO = (GLOBAL.NOMU_QA.DATA.SHOW_ASSET_INFO + 1) % 3
        GLOBAL.NOMU_QA.SaveData() 
    end)
    AddToggleBtn(320, sy - 7*dy, 200, dy, "DEBUG_MODE", s.BUTTON_TEXT_DEBUG_ON, s.BUTTON_TEXT_DEBUG_OFF)
    AddBtn(0, -sy, 200, dy, s.BUTTON_TEXT_CLOSE, function() self:Hide() end)
    self:Refresh()
end)

function QAPanel:Refresh()
    local fl = {}
    for idx, freq in ipairs(GLOBAL.NOMU_QA.DATA.FREQ_LIST) do 
        table.insert(fl, { idx = idx, freq = freq }) 
    end
    self.freq_list:Refresh(fl)
end

function QAPanel:OnGainFocus() 
    self.camera_controllable_reset = TheCamera:IsControllable()
    TheCamera:SetControllable(false) 
end

function QAPanel:OnLoseFocus() 
    TheCamera:SetControllable(self.camera_controllable_reset) 
end

function QAPanel:OnControl(control, down)
    if QAPanel._base.OnControl(self, control, down) then return true end
    if not down and (control == CONTROL_PAUSE or control == CONTROL_CANCEL) then 
        self:Hide() 
    end
    return true
end

-- 导出给主文件使用
GLOBAL.NOMU_QA.QAPanel = QAPanel


-- 添加至写字板屏幕
AddClassPostConstruct("widgets/writeablewidget", function(self)
    local inst = self.writeable
    local owner = self.owner
    if inst == nil or owner == nil then return end

    CreateEmojiAndPhraseMenu(self, "writeable")

    local old_Close = self.Close
    function self:Close(...)
        if old_Close then old_Close(self, ...) end
        for _, v in ipairs(self.EM_all_widgets or {}) do
            v:Kill()
        end
        if self.EM_input then
            self.EM_input:Remove()
            self.EM_input = nil
        end
    end
end)

-- 添加至聊天输入屏幕
AddClassPostConstruct("screens/chatinputscreen", function(self)
    local old_OnBecomeActive = self.OnBecomeActive
    function self:OnBecomeActive(...)
        if old_OnBecomeActive then old_OnBecomeActive(self, ...) end
        CreateEmojiAndPhraseMenu(self, "chat")
    end

    local old_Close = self.Close
    function self:Close(...)
        if old_Close then old_Close(self, ...) end
        for _, v in ipairs(self.EM_all_widgets or {}) do
            v:Kill()
        end
        if self.EM_input then
            self.EM_input:Remove()
            self.EM_input = nil
        end
    end

    if self.chat_edit then
        local old_OnStopForceEdit = self.chat_edit.OnStopForceEdit
        self.chat_edit.OnStopForceEdit = function(...)
            if self.EM_bg and self.EM_bg.shown then return end
            if self.EM_menu and self.EM_menu.focus then return end
            if old_OnStopForceEdit then return old_OnStopForceEdit(...) end
        end
    end

    local old_OnControl = self.OnControl
    function self:OnControl(control, down)
        if self.EM_bg and self.EM_bg.shown and control == GLOBAL.CONTROL_CANCEL then
            if self.EM_menu and self.EM_menu.focus then
                return true
            end
            
            if not down then
                self.EM_bg:Hide()
                if self.chat_edit then self.chat_edit:SetEditing(true) end
            end
            return true 
        end
        
        if old_OnControl then 
            return old_OnControl(self, control, down) 
        end
        return false
    end
end)