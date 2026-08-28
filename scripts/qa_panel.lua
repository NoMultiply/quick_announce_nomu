local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"
local ImageButton = require "widgets/imagebutton"
local Image = require "widgets/image"
local TextButton = require "widgets/textbutton"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local PlayerBadge = require "widgets/playerbadge"

-- 获取主文件暴露的局部函数和常量
local DeepCopy = GLOBAL.NOMU_QA.DeepCopy
local Announce = GLOBAL.NOMU_QA.Announce
local VERSION = GLOBAL.NOMU_QA.VERSION

-- ==========================================
-- 通用 UI 辅助构建函数
-- ==========================================
local function MakeListItem(name, w, h)
    local item = Widget(name)
    item.backing = item:AddChild(TEMPLATES.ListItemBackground(w, h, function() end))
    item.backing.move_on_click = true
    item.text = item:AddChild(Text(GLOBAL.BODYTEXTFONT, 20, nil, GLOBAL.UICOLOURS.WHITE))
    item.focus_forward = item.backing
    return item
end

local function MakeHoverBtn(parent, text, size, x, color, hover_color)
    local btn = parent:AddChild(TextButton())
    btn:SetFont(GLOBAL.CHATFONT)
    btn:SetTextSize(size)
    btn:SetText(text)
    btn:SetPosition(x, 0, 0)
    btn:SetTextColour(color or {1, 1, 1, 1})
    btn:SetTextFocusColour(hover_color or {1, 1, 1, 1})
    btn:Hide()
    return btn
end

local function BindHoverActions(item, btns)
    function item:OnGainFocus()
        for _, b in ipairs(btns) do if b then b:Show() end end
    end
    function item:OnLoseFocus()
        for _, b in ipairs(btns) do if b then b:Hide() end end
    end
end
-- ==========================================

local NoMuScreen = Class(Screen, function(self, name, nomu_parent, width, height, title)
    Screen._ctor(self, name)
    self.nomu_parent = nomu_parent
    if nomu_parent then nomu_parent:Hide() end
    
    self.root = self:AddChild(TEMPLATES.RectangleWindow(width, height, title))
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetPosition(0, 0)

    self.AddButton = function(x, y, w, h, text, fn)
        local button = self.root:AddChild(ImageButton("images/global_redux.xml", "button_carny_long_normal.tex", "button_carny_long_hover.tex", "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
        button:SetFont(CHATFONT)
        button:SetPosition(x, y, 0)
        button.text:SetColour(0, 0, 0, 1)
        button:SetOnClick(function() 
            fn(button)
            if type(text) == 'function' then button:SetText(text(button)) end 
        end)
        button:SetTextSize(26)
        button:SetText(type(text) == 'function' and text(button) or text)
        button:ForceImageSize(w, h)
        return button
    end

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
    if self.EM_bg and self.EM_bg.shown and (control == CONTROL_CANCEL or control == CONTROL_PAUSE) then
        if self.EM_menu and self.EM_menu.focus then return true end
        if not down then
            self.EM_bg:Hide()
            if self.RestoreInputFocus then self:RestoreInputFocus() end
        end
        return true
    end

    if NoMuScreen._base.OnControl(self, control, down) then return true end
    if not down and (control == CONTROL_PAUSE or control == CONTROL_CANCEL) then self:Close() end
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
            w:SetOnGainFocus(function() if self.scroll_lists then self.scroll_lists:OnWidgetFocus(w) end end)
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
        scrollbar_offset = 10, scrollbar_height_offset = -60, peek_percent = 0, allow_bottom_empty_row = true
    }))
    self.scroll_lists:SetPosition(override.x or self.x, override.y or self.y)
end

local controller_emojis = {
    "\238\128\143", "\238\128\140", "\238\128\141", "\238\128\142", "\238\128\132", "\238\128\133", "\238\128\134", "\238\128\137",
    "\238\128\135", "\238\128\138", "\238\128\128", "\238\128\129", "\238\128\130", "\238\128\131", "\238\128\146", "\238\128\147",
    "\238\128\145", "\238\128\144", "\238\128\150", "\238\128\151", "\238\128\149", "\238\128\148", "\238\128\136", "\238\128\136",
    "\238\128\139", "\238\128\139", "\238\128\152", "\238\128\153", "\238\132\128", "\238\132\129", "\238\136\130", "\238\136\131",
    "\238\136\129", "\238\136\128", "\238\129\136", "\238\129\139", "\238\129\135", "\238\129\138", "\238\129\132", "\238\129\133",
}

local function SendMemeChatMessage(meme_name, whisper)
    if GLOBAL.TheNet then GLOBAL.TheNet:Say("[Meme:" .. meme_name .. "]", whisper) end
end

local function CreateEmojiAndPhraseMenu(self, mode)
    self.EM_all_widgets = {}
    self.EM_emojis = {}
    local S = STRINGS.NOMU_QA.EMOJI_MENU

    local target_textbox = (mode == "chat" and self.chat_edit) 
                        or (mode == "input_string" and self.config_input and self.config_input.textbox) 
                        or (mode == "rename_position" and self.rename and self.rename.textbox) 
                        or (mode == "lobby_chat" and self.chatbox and self.chatbox.textbox)

    self.RestoreInputFocus = function()
        if target_textbox then target_textbox:SetEditing(true) end
    end

    local function InsertText(str)
        if target_textbox then
            target_textbox:SetString(target_textbox:GetString() .. str)
            self.RestoreInputFocus()
        elseif mode == "writeable" then
            local old = self:GetText()
            if old then
                self:OverrideText(old .. str)
                self:OnBecomeActive()
            end
        end
    end

    local function build_bg()
        local bg_parent = (mode == "chat" and self.screen_root) or ((mode == "input_string" or mode == "rename_position") and self.root) or self
        self.EM_bg = bg_parent:AddChild(Widget("EM_bg"))
        
        local width, height = 360, 380
        local atlas = resolvefilepath(CRAFTING_ATLAS)

        local function AddTex(tex, w, h, x, y, clickable)
            local img = self.EM_bg:AddChild(Image(atlas, tex))
            img:ScaleToSize(w, h); img:SetPosition(x, y)
            if clickable == false then img:SetClickable(false) end
            return img
        end

        local fill = AddTex("backing.tex", width + 10, height + 18, 0, 0)
        fill:SetTint(1, 1, 1, 0.5) 
        AddTex("side.tex", -26, -(height - 20), -width/2 - 8, 1)
        AddTex("side.tex", 26, height - 20, width/2 + 8, 1, false)
        AddTex("top.tex", width + 34, 38, 0, height/2 + 10)
        AddTex("bottom.tex", width + 34, 38, 0, -height/2 - 8, false)
        
        if mode == "chat" then self.EM_bg:SetPosition(-320, 320, 0); self.EM_bg:MoveToFront()
        elseif mode == "input_string" then self.EM_bg:SetPosition(400, 0, 0); self.EM_bg:MoveToFront()
        elseif mode == "lobby_chat" then self.EM_bg:SetPosition(390, 310, 0); self.EM_bg:MoveToFront()
        else self.EM_bg:SetPosition(400, 20, 0) end

        table.insert(self.EM_all_widgets, self.EM_bg)

        self.EM_menu_root = self.EM_bg:AddChild(Widget("menu_root"))
        self.EM_page_1 = self.EM_bg:AddChild(Widget("page_1"))
        self.EM_page_2 = self.EM_bg:AddChild(Widget("page_2"))
        self.EM_page_3 = self.EM_bg:AddChild(Widget("page_3"))
        self.EM_page_4 = self.EM_bg:AddChild(Widget("page_4"))

        local function SwitchToTab(tab_idx)
            if not GLOBAL.NOMU_QA.ENABLE_MEME_SYSTEM and tab_idx == 3 then tab_idx = 1 end
            GLOBAL.NOMU_QA.LAST_EMOJI_TAB = tab_idx

            for i = 1, 4 do
                if i == tab_idx then self["EM_page_"..i]:Show() else self["EM_page_"..i]:Hide() end
            end
            if tab_idx == 4 and self.EM_player_list then
                self.EM_player_list:Refresh(GLOBAL.TheNet:GetClientTable() or {})
            end
        end
        self.SwitchToTab = SwitchToTab

        local function AddTabBtn(x, y, text, tab_idx)
            local btn = self.EM_menu_root:AddChild(ImageButton("images/global_redux.xml", "button_carny_long_normal.tex", "button_carny_long_hover.tex", "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
            btn:SetFont(GLOBAL.CHATFONT); btn:SetPosition(x, y, 0); btn.text:SetColour(0, 0, 0, 1)
            btn:SetTextSize(22); btn:ForceImageSize(100, 36); btn:SetText(text)
            btn:SetOnClick(function() SwitchToTab(tab_idx) end)
            return btn
        end

        if GLOBAL.NOMU_QA.ENABLE_MEME_SYSTEM then
            self.EM_btn_1 = AddTabBtn(-110, 160, S.TAB_EMOJI, 1)
            self.EM_btn_2 = AddTabBtn(0, 160, S.TAB_PHRASE, 2)
            self.EM_btn_3 = AddTabBtn(110, 160, S.TAB_MEME, 3)
        else
            self.EM_btn_1 = AddTabBtn(-60, 160, S.TAB_EMOJI, 1)
            self.EM_btn_2 = AddTabBtn(60, 160, S.TAB_PHRASE, 2)
        end

        self.EM_btn_2:SetOnClick(function()
            SwitchToTab(GLOBAL.NOMU_QA.LAST_EMOJI_TAB == 2 and 4 or 2)
        end)

        -- ===== Tab 1: Emoji =====
        if #self.EM_emojis == 0 then
            local function AddEmojiBtn(char)
                local textbtn = self.EM_page_1:AddChild(TextButton())
                textbtn:SetTextSize(30); textbtn:SetText(char)
                textbtn:SetOnGainFocus(function() textbtn:SetScale(1.2) end)
                textbtn:SetOnLoseFocus(function() textbtn:SetScale(1) end)
                textbtn:SetOnClick(function() InsertText(char) end)
                table.insert(self.EM_emojis, textbtn)
            end
            
            for _, v in pairs(GLOBAL.EMOJI_ITEMS or {}) do 
                if v.data and v.data.utf8_str then AddEmojiBtn(v.data.utf8_str) end 
            end
            for _, v in ipairs(controller_emojis) do AddEmojiBtn(v) end

            local space_x, space_y, row_buttons, y_offset = 35, 35, 10, 125
            for k, v in ipairs(self.EM_emojis) do
                local row = math.floor((k - 1) / row_buttons)
                v:SetPosition(((k - 1) % row_buttons - (math.min(row_buttons, #self.EM_emojis - row * row_buttons) - 1) / 2) * space_x, y_offset - row * space_y)
            end
        end

        -- ===== Tab 2: 常用语 =====
        local function RefreshPhraseList()
            local fl = {}
            for idx, freq in ipairs(GLOBAL.NOMU_QA.DATA.FREQ_LIST or {}) do table.insert(fl, { idx = idx, freq = freq }) end
            if self.EM_str_list then self.EM_str_list:Refresh(fl) end
        end

        self.EM_str_list = self.EM_page_2:AddChild(NoMuList(function()
            local item = MakeListItem('freq-list-item', 320, 40)
            item.delete = MakeHoverBtn(item, GLOBAL.STRINGS.NOMU_QA.BUTTON_TEXT_DELETE, 20, 140, {1,0,0,1})
            BindHoverActions(item, {item.delete})
            
            item.SetInfo = function(_, data)
                item.text:SetString(#data.freq > 45 and string.sub(data.freq, 1, 45) .. "..." or data.freq)
                item.backing:SetOnClick(function() InsertText(data.freq) end)
                item.delete:SetOnClick(function() 
                    table.remove(GLOBAL.NOMU_QA.DATA.FREQ_LIST, data.idx)
                    GLOBAL.NOMU_QA.SaveData(); RefreshPhraseList()
                    if GLOBAL.ThePlayer and GLOBAL.ThePlayer.HUD and GLOBAL.ThePlayer.HUD.controls.nomu_qa_panel then
                        GLOBAL.ThePlayer.HUD.controls.nomu_qa_panel:Refresh()
                    end
                end)
            end
            return item
        end, 0, 20, 320, 40, 1, 5))

        self.EM_input_root = self.EM_page_2:AddChild(Widget("input_root"))
        self.EM_input_root:SetPosition(0, -120)
        self.EM_input_box = self.EM_input_root:AddChild(TEMPLATES.StandardSingleLineTextEntry("", 240, 40, GLOBAL.CHATFONT, 26, S.INPUT_ADD_PHRASE))
        self.EM_input_box:SetPosition(-35, 0)
        
        self.EM_input_btn = self.EM_input_root:AddChild(ImageButton("images/global_redux.xml", "button_carny_long_normal.tex", "button_carny_long_hover.tex", "button_carny_long_hover.tex"))
        self.EM_input_btn:SetFont(GLOBAL.CHATFONT); self.EM_input_btn.text:SetColour(0, 0, 0, 1)
        self.EM_input_btn:SetText(S.BTN_ADD); self.EM_input_btn:SetTextSize(24)
        self.EM_input_btn:SetPosition(115, 0); self.EM_input_btn:ForceImageSize(70, 40)
        self.EM_input_btn:SetOnClick(function()
            local text = self.EM_input_box.textbox:GetString()
            if text and text ~= "" then
                table.insert(GLOBAL.NOMU_QA.DATA.FREQ_LIST, text)
                GLOBAL.NOMU_QA.SaveData(); self.EM_input_box.textbox:SetString(""); RefreshPhraseList()
                if GLOBAL.ThePlayer and GLOBAL.ThePlayer.HUD and GLOBAL.ThePlayer.HUD.controls.nomu_qa_panel then
                    GLOBAL.ThePlayer.HUD.controls.nomu_qa_panel:Refresh()
                end
            end
        end)
        RefreshPhraseList()

        -- ===== Tab 3: Meme 表情包 =====
        if GLOBAL.NOMU_QA.ENABLE_MEME_SYSTEM then
            local current_tab = GLOBAL.NOMU_QA.LAST_MEME_TAB or 0 
            local current_cat_page = GLOBAL.NOMU_QA.LAST_MEME_CAT_PAGE or 1
            local cats_per_page = 5

            self.EM_meme_grid = self.EM_page_3:AddChild(NoMuList(function()
                local item = Widget('meme-grid-item')
                item.btn = item:AddChild(ImageButton())
                item.btn:SetNormalScale(0.45, 0.45, 0.45); item.btn:SetFocusScale(0.5, 0.5, 0.5)

                item.fav_marker = item:AddChild(Text(GLOBAL.UIFONT, 25, "★"))
                item.fav_marker:SetColour(1, 0.8, 0.1, 1); item.fav_marker:SetPosition(22, 22); item.fav_marker:SetClickable(false); item.fav_marker:Hide()
                
                local old_OnMouseButton = item.btn.OnMouseButton
                item.btn.OnMouseButton = function(self_btn, button, down, x, y)
                    if button == GLOBAL.MOUSEBUTTON_MIDDLE and not down and item.data then
                        local name = item.data.name
                        local favs = GLOBAL.NOMU_QA.DATA.MEME_FAVS or {}
                        local found_idx = nil
                        for i, v in ipairs(favs) do if v == name then found_idx = i; break end end
                        if found_idx then table.remove(favs, found_idx); item.fav_marker:Hide()
                        else table.insert(favs, 1, name); item.fav_marker:Show() end
                        GLOBAL.NOMU_QA.DATA.MEME_FAVS = favs; GLOBAL.NOMU_QA.SaveData()
                        if current_tab == 0 and item.refresh_fn then item.refresh_fn() end
                        return true
                    end
                    
                    if button == GLOBAL.MOUSEBUTTON_RIGHT and not down and item.data then
                        SendMemeChatMessage(item.data.name, true)
                        if self.EM_bg then self.EM_bg:Hide() end
                        if GLOBAL.NOMU_QA.DATA.FREQ_AUTO_CLOSE and mode == "chat" then
                            if type(self.Close) == "function" then self:Close() else GLOBAL.TheFrontEnd:PopScreen(self) end
                        else self.RestoreInputFocus() end
                        return true
                    end
                    
                    if old_OnMouseButton then return old_OnMouseButton(self_btn, button, down, x, y) end
                    return false
                end
                
                item.SetInfo = function(_, data)
                    item.data = data
                    item.btn:SetTextures(data.atlas or ("images/meme/" .. data.name .. ".xml"), data.name .. ".tex", data.name .. ".tex", nil, data.name .. ".tex")

                    local img_w, img_h = item.btn:GetSize()
                    local final_scale, max_size = 0.45, 58
                    if img_w and img_h then
                        if img_w * final_scale > max_size then final_scale = max_size / img_w end
                        if img_h * final_scale > max_size then final_scale = max_size / img_h end
                        item.btn:SetPosition(0, 0)
                        item.btn:SetNormalScale(final_scale, final_scale, final_scale)
                        item.btn:SetFocusScale(final_scale * 1.15, final_scale * 1.15, final_scale * 1.15)
                        if item.btn.image then item.btn.image:SetScale(final_scale, final_scale, final_scale) end
                    end

                    local is_fav = false
                    for _, v in ipairs(GLOBAL.NOMU_QA.DATA.MEME_FAVS or {}) do if v == data.name then is_fav = true; break end end
                    if is_fav then item.fav_marker:Show() else item.fav_marker:Hide() end

                    item.btn:SetOnClick(function()
                        SendMemeChatMessage(data.name, false)
                        if self.EM_bg then self.EM_bg:Hide() end
                        if GLOBAL.NOMU_QA.DATA.FREQ_AUTO_CLOSE and mode == "chat" then
                            if type(self.Close) == "function" then self:Close() else GLOBAL.TheFrontEnd:PopScreen(self) end
                        else self.RestoreInputFocus() end
                    end)
                end
                item.focus_forward = item.btn; return item
            end, 0, -15, 65, 65, 5, 4))

            local function RefreshMemes()
                local list_key = "List_" .. current_tab
                local grid_data = {}
                
                if current_tab == 0 then
                    for _, name in ipairs(GLOBAL.NOMU_QA.DATA.MEME_FAVS or {}) do
                        local prefix = name:match("^(.*)_%d+")
                        local atlas = (prefix and GLOBAL.NOMU_QA.Prefix_Atlas_Map and GLOBAL.NOMU_QA.Prefix_Atlas_Map[prefix]) or "images/meme/"..name..".xml"
                        table.insert(grid_data, { name = name, atlas = atlas, prefix = prefix })
                    end
                else
                    for _, name in ipairs(GLOBAL.NOMU_QA.MEME_LIST[list_key] or {}) do
                        table.insert(grid_data, { name = name, atlas = GLOBAL.NOMU_QA.MEME_LIST_DATA[list_key].atlas, prefix = GLOBAL.NOMU_QA.MEME_LIST_DATA[list_key].prefix })
                    end
                end
                self.EM_meme_grid:Refresh(grid_data)
                
                if self.EM_meme_grid.scroll_lists and self.EM_meme_grid.scroll_lists.widgets_to_update then
                    for _, w in ipairs(self.EM_meme_grid.scroll_lists.widgets_to_update) do
                        if w.nomu_list_item then w.nomu_list_item.refresh_fn = RefreshMemes end
                    end
                end
            end

            self.EM_meme_cat_btns = {}
            local function RefreshCategoryButtons()
                for _, btn in ipairs(self.EM_meme_cat_btns) do btn:Kill() end
                self.EM_meme_cat_btns = {}

                local total_meme_lists = 0
                while GLOBAL.NOMU_QA.MEME_LIST_DATA["List_" .. total_meme_lists] do total_meme_lists = total_meme_lists + 1 end
                local total_cat_pages = math.max(1, math.ceil(total_meme_lists / cats_per_page))

                if total_cat_pages > 1 then
                    local function AddPageBtn(text, x, step)
                        local btn = self.EM_page_3:AddChild(ImageButton("images/global_redux.xml", "button_carny_square_normal.tex", "button_carny_square_hover.tex", "button_carny_square_disabled.tex", "button_carny_square_down.tex"))
                        btn:SetPosition(x, 126); btn:ForceImageSize(28, 28) 
                        btn:SetFont(GLOBAL.CHATFONT); btn.text:SetColour(0, 0, 0, 1); btn:SetTextSize(18); btn:SetText(text)
                        btn:SetOnClick(function()
                            current_cat_page = current_cat_page + step
                            if current_cat_page < 1 then current_cat_page = total_cat_pages elseif current_cat_page > total_cat_pages then current_cat_page = 1 end
                            GLOBAL.NOMU_QA.LAST_MEME_CAT_PAGE = current_cat_page; RefreshCategoryButtons()
                        end)
                        table.insert(self.EM_meme_cat_btns, btn)
                    end
                    AddPageBtn("<", -170, -1); AddPageBtn(">", 170, 1)
                end

                local start_idx = (current_cat_page - 1) * cats_per_page
                local end_idx = math.min(start_idx + cats_per_page - 1, total_meme_lists - 1)
                local start_x = -(end_idx - start_idx + 1) * 62 / 2 + 28

                for i = start_idx, end_idx do
                    local title = GLOBAL.NOMU_QA.MEME_LIST_DATA["List_"..i] and GLOBAL.NOMU_QA.MEME_LIST_DATA["List_"..i].title or tostring(i)

                    local sub_btn = self.EM_page_3:AddChild(ImageButton("images/global_redux.xml", "button_carny_long_normal.tex", "button_carny_long_hover.tex", "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
                    
                    sub_btn:SetPosition(start_x + (i - start_idx) * 62, 126); sub_btn:ForceImageSize(56, 28)
                    sub_btn:SetFont(GLOBAL.CHATFONT); sub_btn:SetTextSize(15); sub_btn:SetText(title)

                    local col = (i == 0) and {0.2, 0.8, 0.2, 1} or {0, 0, 0, 1}
                    sub_btn:SetTextColour(col); sub_btn:SetTextFocusColour(col); sub_btn.text:SetColour(unpack(col))
                    if sub_btn.SetTextSelectedColour then sub_btn:SetTextSelectedColour(col) end
                    if current_tab == i then sub_btn.image:SetTint(0.8, 0.8, 0.8, 1) end

                    sub_btn:SetOnClick(function() 
                        current_tab = i; GLOBAL.NOMU_QA.LAST_MEME_TAB = i
                        RefreshMemes(); RefreshCategoryButtons()
                    end)
                    table.insert(self.EM_meme_cat_btns, sub_btn)
                end
            end
            RefreshCategoryButtons(); RefreshMemes()
        end

        -- ===== Tab 4: 玩家选择列表 =====
        local pw, ph = 300, 44
        self.EM_player_list = self.EM_page_4:AddChild(NoMuList(function()
            local item = MakeListItem('player-list-item', pw, ph)
            item.characterBadge = item:AddChild(PlayerBadge("", GLOBAL.DEFAULT_PLAYER_COLOUR, false, 0))
            item.characterBadge:SetScale(0.55); item.characterBadge:SetPosition(-pw / 2 + 25, 0, 0)

            item.text:SetHAlign(GLOBAL.ANCHOR_LEFT); item.text:SetRegionSize(pw - 60, ph); item.text:SetPosition(30, 0, 0)

            item.SetInfo = function(_, client)
                item.text:SetString(client.name); item.text:SetColour(unpack(client.colour or GLOBAL.DEFAULT_PLAYER_COLOUR))
                item.characterBadge:Set(client.prefab or "", client.colour or GLOBAL.DEFAULT_PLAYER_COLOUR, client.performance ~= nil, client.userflags or 0, client.base_skin)
                item.backing:SetOnClick(function()
                    InsertText("@" .. client.name .. " "); SwitchToTab(2); self.RestoreInputFocus()
                end)
            end
            return item
        end, 0, 10, pw, ph, 1, 6))

        RefreshPhraseList()
        SwitchToTab(GLOBAL.NOMU_QA.LAST_EMOJI_TAB or 1)
    end

    local menu = (mode == "chat" and self.root or ((mode == "input_string" or mode == "rename_position") and self.root or self)):AddChild(ImageButton("images/hud.xml", "self_inspect_mod.tex", "self_inspect_mod.tex", "self_inspect_mod.tex", nil, nil, {1,1}, {0,0}))
    menu.image:SetScale(0.6, 0.6, 1)
    
    if mode == "chat" then menu:SetPosition((self.chat_type and self.chat_type:GetPosition().x - 20) or -520, 0, 0)
    elseif mode == "input_string" then menu:SetPosition(0, -40, 0) 
    elseif mode == "rename_position" then menu:SetPosition(300, -185, 0) 
    elseif mode == "lobby_chat" then menu:SetPosition(340, 75, 0)
    else menu:SetPosition(0, 60, 0); if self.SM_menu then menu:Hide() else menu:Show() end end
    
    menu.name = "emoji_menu"
    menu:SetOnGainFocus(function() menu.image:SetScale(0.7, 0.7, 1) end)
    menu:SetOnLoseFocus(function() menu.image:SetScale(0.6, 0.6, 1) end)
    menu:SetOnClick(function()
        self.RestoreInputFocus()
        if self.EM_bg then 
            if self.EM_bg.shown then self.EM_bg:Hide() else self.EM_bg:Show(); if self.SwitchToTab then self.SwitchToTab(GLOBAL.NOMU_QA.LAST_EMOJI_TAB or 1) end end 
        else build_bg() end
    end)

    self.EM_menu = menu
    table.insert(self.EM_all_widgets, menu)

    if not self.EM_input then
        self.EM_input = GLOBAL.TheInput:AddMouseButtonHandler(function(button, down)
            if not down then return false end
            local is_bg_shown = self.EM_bg and self.EM_bg.shown
            local is_menu_focus = self.EM_menu and self.EM_menu.focus

            if button == GLOBAL.MOUSEBUTTON_LEFT then
                if is_bg_shown and not is_menu_focus and not self.EM_bg.focus then
                    self.EM_bg:Hide(); self.RestoreInputFocus(); return true 
                end
            elseif button == GLOBAL.MOUSEBUTTON_RIGHT then
                if (mode == "chat" or mode == "input_string" or mode == "rename_position" or mode == "lobby_chat") and is_menu_focus then
                    if is_bg_shown then self.EM_bg:Hide(); self.RestoreInputFocus() 
                    elseif not self.EM_bg then build_bg() 
                    else self.EM_bg:Show(); if self.SwitchToTab then self.SwitchToTab(GLOBAL.NOMU_QA.LAST_EMOJI_TAB or 1) end end
                    return true 
                end
                if is_bg_shown and not self.EM_bg.focus then
                    self.EM_bg:Hide(); self.RestoreInputFocus(); return true 
                end
            end
        end)
    end
end

local function GetMergedBuiltin(target_source)
    local merged = DeepCopy(GLOBAL.STRINGS.DEFAULT_NOMU_QA)
    if target_source and target_source ~= GLOBAL.STRINGS.DEFAULT_NOMU_QA then
        local function MergeTables(dst, src)
            for k, v in pairs(src) do
                if type(v) == "table" and type(dst[k]) == "table" then MergeTables(dst[k], v) else dst[k] = type(v) == "table" and DeepCopy(v) or v end
            end
        end
        MergeTables(merged, target_source)
    end
    return merged
end

-- 字符串输入面板
local GetInputString = Class(NoMuScreen, function(self, nomu_parent, title, value, callback, limit, width)
    NoMuScreen._ctor(self, "GetInputString", nomu_parent, width or 280, 130)
    
    self.config_label = self.root:AddChild(Text(BODYTEXTFONT, 32))
    self.config_label:SetString(title); self.config_label:SetHAlign(ANCHOR_MIDDLE); self.config_label:SetRegionSize(200, 40); self.config_label:SetPosition(0, 40)
    
    self.config_input = self.root:AddChild(TEMPLATES.StandardSingleLineTextEntry("", width or 200, 40))
    self.config_input.textbox:SetTextLengthLimit(limit or 50); self.config_input.textbox:SetString(tostring(value)); self.config_input:SetPosition(0, 0, 0)
    
    self.AddButton(-80, -40, 100, 40, STRINGS.NOMU_QA.BUTTON_TEXT_APPLY, function() callback(self.config_input.textbox:GetLineEditString()); self:Close() end)
    self.AddButton(80, -40, 100, 40, STRINGS.NOMU_QA.BUTTON_TEXT_CLOSE, function() self:Close() end)
    CreateEmojiAndPhraseMenu(self, "input_string")
end)

-- 确认对话框
local ConfirmDialog = Class(NoMuScreen, function(self, nomu_parent, title, callback)
    NoMuScreen._ctor(self, "ConfirmDialog", nomu_parent, 250, 90)
    self.root:AddChild(Text(BODYTEXTFONT, 32, title)):SetPosition(0, 20)
    self.AddButton(-50, -20, 100, 40, STRINGS.NOMU_QA.BUTTON_TEXT_YES, function() callback(); self:Close() end)
    self.AddButton(50, -20, 100, 40, STRINGS.NOMU_QA.BUTTON_TEXT_NO, function() self:Close() end)
end)

-- 操作选择弹窗
local ActionMenuDialog = Class(NoMuScreen, function(self, nomu_parent, title, on_copy, on_reset)
    NoMuScreen._ctor(self, "ActionMenuDialog", nomu_parent, 360, 130)
    local title_txt = self.root:AddChild(Text(BODYTEXTFONT, 26, title or STRINGS.NOMU_QA.TITLE_ACTION_MENU))
    title_txt:SetPosition(0, 30); title_txt:SetRegionSize(320, 30)
    
    self.AddButton(-110, -25, 95, 38, STRINGS.NOMU_QA.BUTTON_TEXT_COPY_TO, function() self:Close(); if on_copy then on_copy() end end)
    self.AddButton(0, -25, 95, 38, STRINGS.NOMU_QA.BUTTON_TEXT_RESET, function() self:Close(); if on_reset then on_reset() end end)
    self.AddButton(110, -25, 95, 38, STRINGS.NOMU_QA.BUTTON_TEXT_CLOSE, function() self:Close() end)
end)

-- 角色选择器面板
local CharacterPicker = Class(NoMuScreen, function(self, nomu_parent, callback)
    local iw, ih = 120, 40
    local width, height = iw + 10, 80 + ih * 4
    NoMuScreen._ctor(self, "CharacterPicker", nomu_parent, width, height + 10)
    
    self.character_list = self.root:AddChild(NoMuList(function()
        local item = MakeListItem('character-list-item', iw, ih)
        item.SetInfo = function(_, character)
            item.text:SetString(character == 'DEFAULT' and STRINGS.NOMU_QA.TITLE_TEXT_MAPPING_DEFAULT or STRINGS.NAMES[character:upper()] or character:upper())
            item.backing:SetOnClick(function() callback(character); self:Close() end)
        end
        return item
    end, 0, 0, iw, ih, math.floor(width / iw), math.floor((height - 80) / ih)))
    
    self.AddButton(0, -height / 2 + 20, 120, 40, STRINGS.NOMU_QA.BUTTON_TEXT_CLOSE, function() self:Close() end)
    
    local character_list = { 'DEFAULT' }
    for _, character in ipairs(DST_CHARACTERLIST) do table.insert(character_list, character) end
    self.character_list:Refresh(character_list)
end)

-- 词库管理面板
local QAWordManagementPanel = Class(NoMuScreen, function(self, nomu_parent)
    local dy = 35
    NoMuScreen._ctor(self, "QAWordManagementPanel", nomu_parent, 860, 490)

    self.h_line = self.root:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
    self.h_line:SetScale(1.0, 1); self.h_line:SetPosition(0, 25)

    local function BuildSection(title_str, toggle_key, btn_text, input1, input2, data_key, x, y, w, fmt_fn)
        self.root:AddChild(Text(BODYTEXTFONT, 28, title_str)):SetPosition(x, y)
        self.AddToggle(x - 65, y - dy, 120, dy, toggle_key, STRINGS.NOMU_QA.EMOJI_MENU.ON, STRINGS.NOMU_QA.EMOJI_MENU.OFF)
        self.AddButton(x + 65, y - dy, 120, dy, btn_text, function()
            TheFrontEnd:PushScreen(GetInputString(self, input1, '', function(v1)
                if not v1 or v1 == "" then return end
                if input2 then
                    TheFrontEnd:PushScreen(GetInputString(self, input2, '', function(v2)
                        if not GLOBAL.NOMU_QA.DATA[data_key] then GLOBAL.NOMU_QA.DATA[data_key] = {} end
                        table.insert(GLOBAL.NOMU_QA.DATA[data_key], {target=v1, result=v2 or "", prefab=v1, name=v2 or ""})
                        GLOBAL.NOMU_QA.SaveData(); self["Refresh"..data_key](self)
                    end, 100, 300))
                else
                    if not GLOBAL.NOMU_QA.DATA[data_key] then GLOBAL.NOMU_QA.DATA[data_key] = {} end
                    table.insert(GLOBAL.NOMU_QA.DATA[data_key], v1)
                    GLOBAL.NOMU_QA.SaveData(); self["Refresh"..data_key](self)
                end
            end, 100, 300))
        end)
        
        local list_ui = self.root:AddChild(NoMuList(function()
            local item = MakeListItem(data_key..'-item', w, 40)
            item.delete = MakeHoverBtn(item, STRINGS.NOMU_QA.BUTTON_TEXT_DELETE, 20, w/2 - 40, {1,0,0,1})
            BindHoverActions(item, {item.delete})
            
            item.SetInfo = function(_, data)
                item.text:SetString(fmt_fn(data.val))
                item.delete:SetOnClick(function()
                    table.remove(GLOBAL.NOMU_QA.DATA[data_key], data.idx)
                    GLOBAL.NOMU_QA.SaveData(); self["Refresh"..data_key](self)
                end)
            end
            return item
        end, x, y - 2*dy - 50, w, 40, 1, 3))
        
        self["Refresh"..data_key] = function(this)
            local l = {}
            for i, v in ipairs(GLOBAL.NOMU_QA.DATA[data_key] or {}) do table.insert(l, {idx=i, val=v}) end
            list_ui:Refresh(l)
        end
        self["Refresh"..data_key](self)
    end

    BuildSection(STRINGS.NOMU_QA.TITLE_FORBIDDEN_LIST, "ENABLE_FORBIDDEN", STRINGS.NOMU_QA.BUTTON_NEW_FORBIDDEN, STRINGS.NOMU_QA.TITLE_FORBIDDEN_LIST, nil, "FORBIDDEN_WORDS", -215, 230, 240, function(v) return v end)
    BuildSection(STRINGS.NOMU_QA.TITLE_SHOWME_FILTER, "ENABLE_SHOWME_FILTER", STRINGS.NOMU_QA.BUTTON_NEW_SHOWME_FILTER, STRINGS.NOMU_QA.TITLE_SHOWME_FILTER, nil, "SHOWME_FILTERS", 215, 230, 240, function(v) return v end)
    BuildSection(STRINGS.NOMU_QA.TITLE_REPLACE_LIST, "ENABLE_REPLACE", STRINGS.NOMU_QA.BUTTON_NEW_REPLACE, STRINGS.NOMU_QA.INPUT_REPLACE_TARGET, STRINGS.NOMU_QA.INPUT_REPLACE_RESULT, "REPLACEMENTS", -215, 5, 280, function(v) return v.target.." -> "..(v.result~="" and v.result or "(空)") end)
    BuildSection(STRINGS.NOMU_QA.TITLE_CUSTOM_PREFAB_LIST, "ENABLE_CUSTOM_PREFAB_NAME", STRINGS.NOMU_QA.BUTTON_NEW_CUSTOM_PREFAB, STRINGS.NOMU_QA.INPUT_PREFAB_TARGET, STRINGS.NOMU_QA.INPUT_PREFAB_RESULT, "CUSTOM_PREFAB_NAMES", 215, 5, 280, function(v) return v.prefab.." -> "..(v.name~="" and v.name or "(空)") end)
    
    self.AddButton(0, -215, 200, 40, STRINGS.NOMU_QA.BUTTON_TEXT_CLOSE, function() self:Close() end)
end)

local function ValidateScheme(scheme) return scheme.name ~= nil and scheme.data ~= nil and scheme.version ~= nil end

local SchemeTemplatePicker = Class(NoMuScreen, function(self, nomu_parent, callback)
    local iw, ih = 200, 40
    local width, height = iw + 40, 80 + ih * 5
    NoMuScreen._ctor(self, "SchemeTemplatePicker", nomu_parent, width, height + 10)
    self.root:AddChild(Text(BODYTEXTFONT, 28, STRINGS.NOMU_QA.TITLE_TEXT_CHOOSE_TEMPLATE)):SetPosition(0, height / 2 - 25)
    
    self.scheme_list = self.root:AddChild(NoMuList(function()
        local item = MakeListItem('scheme-list-item', iw, ih)
        item.SetInfo = function(_, scheme) 
            item.text:SetString(scheme.name)
            item.backing:SetOnClick(function() callback(scheme); self:Close() end) 
        end
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
    self.root:AddChild(Text(BODYTEXTFONT, 32, STRINGS.NOMU_QA.TITLE_TEXT_SCHEMES)):SetPosition(sx + 100, sy)
    
    local d_hint = self.root:AddChild(Text(BODYTEXTFONT, 18, STRINGS.NOMU_QA.DEFAULT_SCHEME_RESET_HINT))
    d_hint:SetPosition(sx + 100, sy - 35); d_hint:SetColour(0.9, 0.6, 0.6, 1)

    self.AddButton(sx + 100, sy - 75, 200, dy, STRINGS.NOMU_QA.BUTTON_TEXT_NEW_SCHEME, function() 
        TheFrontEnd:PushScreen(GetInputString(nil, STRINGS.NOMU_QA.BUTTON_TEXT_NEW_SCHEME, '', function(value)
            if not value or value == "" then return end
            TheFrontEnd:PushScreen(SchemeTemplatePicker(nil, function(ts) 
                -- 彻底移除了 backup_data=DeepCopy(ts.data)
                table.insert(GLOBAL.NOMU_QA.DATA.SCHEMES, { name=value, data=DeepCopy(ts.data), version=VERSION, source_template=ts.source_template or ts.name })
                GLOBAL.NOMU_QA.SaveData(); self:RefreshSchemeList(); self:RefreshScheme(#GLOBAL.NOMU_QA.DATA.SCHEMES) 
            end))
        end))
    end)

    self.scheme_list = self.root:AddChild(NoMuList(function()
        local item = MakeListItem('scheme-list-item', 200, 40)
        item.rename = MakeHoverBtn(item, STRINGS.NOMU_QA.BUTTON_TEXT_RENAME, 20, -70, {0,1,0,1})
        item.delete = MakeHoverBtn(item, STRINGS.NOMU_QA.BUTTON_TEXT_DELETE, 20, 70, {1,0,0,1})
        
        function item:OnGainFocus() item.delete:Show(); if not item.no_rename then item.rename:Show() end end
        function item:OnLoseFocus() item.delete:Hide(); if not item.no_rename then item.rename:Hide() end end

        item.SetInfo = function(_, data)
            item.text:SetString(data.name)
            item.backing:SetOnClick(function() self:RefreshScheme(data.idx) end)
            if data.idx <= 4 then
                item.rename:Hide(); item.no_rename = true; item.delete:SetText(STRINGS.NOMU_QA.BUTTON_TEXT_RESET)
                item.delete:SetOnClick(function() 
                    TheFrontEnd:PushScreen(ConfirmDialog(nil, STRINGS.NOMU_QA.TITLE_TEXT_SURE_TO_RESET_DEFAULT, function() 
                        local defs = { 
                            GLOBAL.STRINGS.DEFAULT_NOMU_QA, 
                            GetMergedBuiltin(GLOBAL.STRINGS.CAT_NOMU_QA), 
                            GetMergedBuiltin(GLOBAL.STRINGS.TSUNDERE_NOMU_QA), 
                            GetMergedBuiltin(GLOBAL.STRINGS.CUTE_NOMU_QA) 
                        }
                        GLOBAL.NOMU_QA.DATA.SCHEMES[data.idx].data = DeepCopy(defs[data.idx])
                        -- 移除 backup_data
                        GLOBAL.NOMU_QA.SaveData(); self:RefreshScheme(data.idx) 
                    end)) 
                end)
            else
                item.delete:SetText(STRINGS.NOMU_QA.BUTTON_TEXT_DELETE)
                item.delete:SetOnClick(function()
                    TheFrontEnd:PushScreen(ConfirmDialog(nil, STRINGS.NOMU_QA.TITLE_TEXT_SURE_TO_DELETE, function() 
                        table.remove(GLOBAL.NOMU_QA.DATA.SCHEMES, data.idx); GLOBAL.NOMU_QA.SaveData()
                        self:RefreshSchemeList(); self:RefreshScheme(math.min(self.scheme_idx, #GLOBAL.NOMU_QA.DATA.SCHEMES)) 
                    end)) 
                end)
                item.rename:SetOnClick(function() 
                    TheFrontEnd:PushScreen(GetInputString(nil, STRINGS.NOMU_QA.BUTTON_TEXT_RENAME, data.name, function(val) 
                        GLOBAL.NOMU_QA.DATA.SCHEMES[data.idx].name = val; GLOBAL.NOMU_QA.SaveData()
                        self:RefreshSchemeList(); self:RefreshScheme(data.idx) 
                    end)) 
                end)
            end
        end
        return item
    end, sx + 100, -55, 200, 40, 1, 9))

    self.AddButton(sx + 100, -sy, 200, 40, STRINGS.NOMU_QA.BUTTON_TEXT_IMPORT_SCHEME, function()
        TheFrontEnd:PushScreen(GetInputString(nil, STRINGS.NOMU_QA.TITLE_TEXT_SCHEME_FILENAME, '', function(filename)
            if string.sub(filename, -5) ~= '.json' then return TheFrontEnd:PushScreen(ConfirmDialog(nil, STRINGS.NOMU_QA.JSON_NEEDED, function() end)) end
            local file = io.open('unsafedata/' .. filename)
            if file then
                local scheme = json.decode(file:read('*a')); file:close()
                if ValidateScheme(scheme) then 
                    table.insert(GLOBAL.NOMU_QA.DATA.SCHEMES, scheme); GLOBAL.NOMU_QA.SaveData()
                    self:RefreshSchemeList(); self:RefreshScheme(#GLOBAL.NOMU_QA.DATA.SCHEMES)
                    return ThePlayer.components.talker:Say(STRINGS.NOMU_QA.MESSAGE_IMPORT_SUCCEED) 
                end
            end
            ThePlayer.components.talker:Say(STRINGS.NOMU_QA.MESSAGE_IMPORT_FAILED)
        end))
    end)

    self.vertical_line = self.root:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
    self.vertical_line:SetRotation(90); self.vertical_line:SetScale(1, 0.57)

    sx = sx + 260
    self.title_text_editing = self.root:AddChild(Text(BODYTEXTFONT, 32)); self.title_text_editing:SetPosition(sx + 300, sy)
    
    local function save_and_apply() 
        GLOBAL.NOMU_QA.DATA.SCHEMES[self.scheme_idx] = DeepCopy(self.scheme)
        GLOBAL.NOMU_QA.DATA.CURRENT_SCHEME = GLOBAL.NOMU_QA.DATA.SCHEMES[self.scheme_idx]
        GLOBAL.NOMU_QA.SaveData(); GLOBAL.NOMU_QA.ApplyScheme(GLOBAL.NOMU_QA.DATA.CURRENT_SCHEME) 
    end

    self.AddButton(sx + 300, -sy, 200, 40, STRINGS.NOMU_QA.BUTTON_TEXT_APPLY_SCHEME, function()
        TheFrontEnd:PushScreen(ConfirmDialog(nil, subfmt(STRINGS.NOMU_QA.TITLE_TEXT_SURE_TO_APPLY_SCHEME, { NAME = self.scheme.name }), function() 
            GLOBAL.NOMU_QA.DATA.CURRENT_SCHEME = GLOBAL.NOMU_QA.DATA.SCHEMES[self.scheme_idx]
            GLOBAL.NOMU_QA.SaveData(); GLOBAL.NOMU_QA.ApplyScheme(GLOBAL.NOMU_QA.DATA.CURRENT_SCHEME) 
        end))
    end)
    self.AddButton(sx + 100, -sy, 200, 40, STRINGS.NOMU_QA.BUTTON_TEXT_EXPORT_SCHEME, function()
        TheFrontEnd:PushScreen(GetInputString(nil, STRINGS.NOMU_QA.TITLE_TEXT_SCHEME_FILENAME, '', function(filename)
            if string.sub(filename, -5) ~= '.json' then return TheFrontEnd:PushScreen(ConfirmDialog(nil, STRINGS.NOMU_QA.JSON_NEEDED, function() end)) end
            local file = io.open('unsafedata/' .. filename, 'w')
            if file then file:write(json.encode(GLOBAL.NOMU_QA.DATA.SCHEMES[self.scheme_idx])); file:close(); ThePlayer.components.talker:Say(STRINGS.NOMU_QA.MESSAGE_EXPORT_SUCCEED)
            else ThePlayer.components.talker:Say(STRINGS.NOMU_QA.MESSAGE_EXPORT_FAILED) end
        end))
    end)
    self.AddButton(sx + 500, -sy, 200, 40, STRINGS.NOMU_QA.BUTTON_TEXT_CLOSE, function() self:Close() end)

    self.root:AddChild(Text(BODYTEXTFONT, 32, STRINGS.NOMU_QA.TITLE_TEXT_FUNC)):SetPosition(sx + 60, sy - dy)

    self.func_list = self.root:AddChild(NoMuList(function()
        local item = MakeListItem('func-list-item', 120, 40)
        item.SetInfo = function(_, func) 
            item.text:SetString(STRINGS.NOMU_QA.FUNC[func])
            item.backing:SetOnClick(function() self:RefreshFunc(func) end) 
        end
        return item
    end, sx + 60, -20, 120, 40, 1, 9))

    sx = sx + 160
    self.title_text_format = self.root:AddChild(Text(BODYTEXTFONT, 32))
    self.title_text_format:SetPosition(sx + 210, sy - dy)
    
    -- 抽取格式列表和映射列表项共用 UI
    local function CreateSettingListItem(name, val_str_fn, action_title, save_cb_path, get_default_val_fn)
        local item = MakeListItem(name, 420, 40)
        item.text:SetRegionSize(360, 40); item.text:SetHAlign(ANCHOR_LEFT); item.text:SetPosition(-15, 0, 0)
        item.more_btn = MakeHoverBtn(item, "...", 26, 185, {0.3, 0.7, 1, 1}, {1, 1, 1, 1})
        BindHoverActions(item, {item.more_btn})

        item.SetInfo = function(_, data)
            item.text:SetString(val_str_fn(data))
            item.backing:SetOnClick(function() 
                TheFrontEnd:PushScreen(GetInputString(nil, action_title(data), data.value, function(value) 
                    save_cb_path(data, value)
                    save_and_apply(); self:RefreshFunc() 
                end, 256, 420)) 
            end)
            item.more_btn:SetOnClick(function()
                TheFrontEnd:PushScreen(ActionMenuDialog(nil, action_title(data), function()
                    TheFrontEnd:PushScreen(SchemeTemplatePicker(nil, function(target_scheme)
                        save_cb_path(data, data.value, target_scheme)
                        GLOBAL.NOMU_QA.SaveData()
                        if GLOBAL.ThePlayer and GLOBAL.ThePlayer.components.talker then
                            GLOBAL.ThePlayer.components.talker:Say(GLOBAL.subfmt(STRINGS.NOMU_QA.MESSAGE_COPY_FORMAT_SUCCEED, { NAME = target_scheme.name }))
                        end
                    end))
                end, function()
                    local BUILTIN_LOOKUP = {
                        [GLOBAL.STRINGS.NOMU_QA.TITLE_TEXT_DEFAULT_SCHEME] = GLOBAL.STRINGS.DEFAULT_NOMU_QA,
                        [GLOBAL.STRINGS.NOMU_QA.TITLE_TEXT_CAT_SCHEME] = GetMergedBuiltin(GLOBAL.STRINGS.CAT_NOMU_QA),
                        [GLOBAL.STRINGS.NOMU_QA.TITLE_TEXT_TSUNDERE_SCHEME] = GetMergedBuiltin(GLOBAL.STRINGS.TSUNDERE_NOMU_QA),
                        [GLOBAL.STRINGS.NOMU_QA.TITLE_TEXT_CUTE_SCHEME] = GetMergedBuiltin(GLOBAL.STRINGS.CUTE_NOMU_QA),
                    }
                    local source_name = self.scheme.source_template or self.scheme.name
                    local source_data = BUILTIN_LOOKUP[source_name] or GLOBAL.STRINGS.DEFAULT_NOMU_QA
                    local default_val = get_default_val_fn(data, source_data)
                    if default_val then
                        save_cb_path(data, default_val)
                        save_and_apply(); self:RefreshFunc()
                    end
                end))
            end)
        end
        return item
    end

    self.format_list = self.root:AddChild(NoMuList(function()
        return CreateSettingListItem('format-list-item', 
            function(d) return d.name .. ': ' .. d.value end,
            function(d) return STRINGS.NOMU_QA.FUNC[self.scheme_func] .. '-' .. d.name end,
            function(d, val, target_scheme)
                local t = target_scheme or self.scheme
                if not t.data[self.scheme_func] then t.data[self.scheme_func] = { FORMATS = {}, MAPPINGS = {} } end
                if not t.data[self.scheme_func].FORMATS then t.data[self.scheme_func].FORMATS = {} end
                t.data[self.scheme_func].FORMATS[d.name] = val
            end,
            function(d, source_data) return source_data[self.scheme_func] and source_data[self.scheme_func].FORMATS and source_data[self.scheme_func].FORMATS[d.name] end
        )
    end, sx + 210, sy - 3.5 * dy, 420, 40, 1, 3))

    self.btn_mapping = self.AddButton(sx + 210, sy - 5 * dy, 200, 40, STRINGS.NOMU_QA.BUTTON_TEXT_MAPPING, function()
        TheFrontEnd:PushScreen(CharacterPicker(nil, function(mapping) 
            mapping = mapping:upper()
            if not self.scheme.data[self.scheme_func].MAPPINGS[mapping] then self.scheme.data[self.scheme_func].MAPPINGS[mapping] = DeepCopy(self.scheme.data[self.scheme_func].MAPPINGS.DEFAULT) end
            self:RefreshFunc(nil, mapping) 
        end))
    end)
    if not GLOBAL.NOMU_QA.DATA.CHARACTER_SPECIFIC then self.btn_mapping:Disable() end

    self.mapping_list = self.root:AddChild(NoMuList(function()
        return CreateSettingListItem('mapping-list-item', 
            function(d) return d.category .. '-' .. d.name .. ': ' .. d.value end,
            function(d) return d.category .. '-' .. d.name end,
            function(d, val, target_scheme)
                local t = target_scheme or self.scheme
                if not t.data[self.scheme_func] then t.data[self.scheme_func] = { FORMATS = {}, MAPPINGS = {} } end
                if not t.data[self.scheme_func].MAPPINGS then t.data[self.scheme_func].MAPPINGS = {} end
                if not t.data[self.scheme_func].MAPPINGS[self.scheme_mapping] then t.data[self.scheme_func].MAPPINGS[self.scheme_mapping] = {} end
                if not t.data[self.scheme_func].MAPPINGS[self.scheme_mapping][d.category] then t.data[self.scheme_func].MAPPINGS[self.scheme_mapping][d.category] = {} end
                t.data[self.scheme_func].MAPPINGS[self.scheme_mapping][d.category][d.name] = val
            end,
            function(d, source_data)
                local val = nil
                if source_data[self.scheme_func] and source_data[self.scheme_func].MAPPINGS then
                    if self.scheme_mapping ~= 'DEFAULT' and source_data[self.scheme_func].MAPPINGS[self.scheme_mapping] and source_data[self.scheme_func].MAPPINGS[self.scheme_mapping][d.category] then
                        val = source_data[self.scheme_func].MAPPINGS[self.scheme_mapping][d.category][d.name]
                    end
                end
                if not val and self.scheme_mapping ~= 'DEFAULT' then
                    if self.scheme.data[self.scheme_func] and self.scheme.data[self.scheme_func].MAPPINGS and self.scheme.data[self.scheme_func].MAPPINGS.DEFAULT and self.scheme.data[self.scheme_func].MAPPINGS.DEFAULT[d.category] then
                        val = self.scheme.data[self.scheme_func].MAPPINGS.DEFAULT[d.category][d.name]
                    end
                end
                if not val and source_data[self.scheme_func] and source_data[self.scheme_func].MAPPINGS and source_data[self.scheme_func].MAPPINGS.DEFAULT and source_data[self.scheme_func].MAPPINGS.DEFAULT[d.category] then
                    val = source_data[self.scheme_func].MAPPINGS.DEFAULT[d.category][d.name]
                end

                return val
            end
        )
    end, sx + 210, sy - 8 * dy, 420, 40, 1, 5))

    self:RefreshSchemeList(); self:RefreshScheme(1)
end)

function QACustomizePanel:RefreshSchemeList()
    self.vertical_line:SetPosition(self.sx + (#GLOBAL.NOMU_QA.DATA.SCHEMES <= 9 and 220 or 230), 0)
    local sl = {}
    for idx, scheme in ipairs(GLOBAL.NOMU_QA.DATA.SCHEMES) do table.insert(sl, { idx = idx, name = scheme.name }) end
    self.scheme_list:Refresh(sl)
end

function QACustomizePanel:RefreshScheme(idx)
    self.scheme_idx = idx or self.scheme_idx
    self.scheme = DeepCopy(GLOBAL.NOMU_QA.DATA.SCHEMES[self.scheme_idx])
    self.title_text_editing:SetString(STRINGS.NOMU_QA.TITLE_TEXT_EDITING .. self.scheme.name)

    local fl = {}
    if not self.scheme.data then self.scheme.data = {} end

    local added_funcs = {}
    for _, func_info in ipairs(GLOBAL.STRINGS.NOMU_QA.FUNC) do
        if self.scheme.data[func_info.id] then
            table.insert(fl, func_info.id)
            added_funcs[func_info.id] = true
        end
    end

    for func_id in pairs(self.scheme.data) do
        if not added_funcs[func_id] then table.insert(fl, func_id) end
    end
    self.func_list:Refresh(fl); self:RefreshFunc(fl[1], 'DEFAULT')
end

function QACustomizePanel:RefreshFunc(func, mapping)
    self.scheme_func = func or self.scheme_func
    self.title_text_format:SetString(GLOBAL.subfmt(STRINGS.NOMU_QA.TITLE_TEXT_FORMAT, { NAME = STRINGS.NOMU_QA.FUNC[self.scheme_func] }))
    local fl, ml = {}, {}
    for name, format in pairs(self.scheme.data[self.scheme_func].FORMATS) do table.insert(fl, { name = name, value = format }) end
    if self.scheme.data[self.scheme_func].MAPPINGS.DEFAULT then
        self.scheme_mapping = mapping or self.scheme_mapping
        if not self.scheme.data[self.scheme_func].MAPPINGS[self.scheme_mapping] then self.scheme_mapping = 'DEFAULT' end
        self.mapping_list:Show(); self.btn_mapping:Show()
        self.btn_mapping:SetText(GLOBAL.subfmt(STRINGS.NOMU_QA.BUTTON_TEXT_MAPPING, { NAME = (self.scheme_mapping == 'DEFAULT' and STRINGS.NOMU_QA.TITLE_TEXT_MAPPING_DEFAULT or STRINGS.NAMES[self.scheme_mapping] or self.scheme_mapping) }))
        for cat, items in pairs(self.scheme.data[self.scheme_func].MAPPINGS[self.scheme_mapping]) do 
            for name, value in pairs(items) do table.insert(ml, { category = cat, name = name, value = value }) end 
        end
    else 
        self.mapping_list:Hide(); self.btn_mapping:Hide() 
    end
    local n_format = math.min(8 - math.min(#ml, 4), #fl)
    self.format_list:Refresh(fl, { rows = n_format, y = self.sy - self.dy * (1.5 + 0.5 * n_format) })
    self.btn_mapping:SetPosition(self.sx + 630, self.sy - (2 + n_format) * self.dy)
    self.mapping_list:Refresh(ml, { rows = 8 - n_format, y = self.sy - (2.5 + 0.5 * (8 - n_format) + n_format) * self.dy })
end

-- 快捷宣告面板
local QAPanel = Class(Widget, function(self)
    local width, height = 860, 480
    local sy, dy = height / 2 - 20, 40
    Widget._ctor(self, "QAPanel")
    
    self.root = self:AddChild(TEMPLATES.RectangleWindow(width, height + 10))
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL); self.root:SetHAnchor(ANCHOR_MIDDLE); self.root:SetVAnchor(ANCHOR_MIDDLE)

    local function AddBtn(x, y, w, h, text, fn)
        local btn = self.root:AddChild(ImageButton("images/global_redux.xml", "button_carny_long_normal.tex", "button_carny_long_hover.tex", "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
        btn:SetFont(CHATFONT); btn:SetPosition(x, y, 0); btn.text:SetColour(0, 0, 0, 1)
        btn:SetTextSize(26); btn:ForceImageSize(w, h)
        btn:SetOnClick(function() fn(btn); if type(text) == 'function' then btn:SetText(text(btn)) end end)
        btn:SetText(type(text) == 'function' and text(btn) or text); return btn
    end

    local function AddToggleBtn(x, y, w, h, key, ton, toff)
        return AddBtn(x, y, w, h, function() return GLOBAL.NOMU_QA.DATA[key] and ton or toff end, function() 
            GLOBAL.NOMU_QA.DATA[key] = not GLOBAL.NOMU_QA.DATA[key]; GLOBAL.NOMU_QA.SaveData() 
        end)
    end

    self.root:AddChild(Text(BODYTEXTFONT, 32, STRINGS.NOMU_QA.TITLE_TEXT_QA)):SetPosition(0, sy)
    self.vertical_line = self.root:AddChild(Image("images/global_redux.xml", "item_divider.tex")); self.vertical_line:SetRotation(90); self.vertical_line:SetScale(1, 0.45); self.vertical_line:SetPosition(0, 15) 

    AddBtn(-320, sy - dy, 200, dy, STRINGS.NOMU_QA.BUTTON_TEXT_NEW_FREQ, function() 
        TheFrontEnd:PushScreen(GetInputString(self, STRINGS.NOMU_QA.BUTTON_TEXT_NEW_FREQ, '', function(val) 
            table.insert(GLOBAL.NOMU_QA.DATA.FREQ_LIST, val); GLOBAL.NOMU_QA.SaveData(); self:Refresh() 
        end, 256, 420)) 
    end)
    AddBtn(-120, sy - dy, 200, dy, STRINGS.NOMU_QA.BUTTON_TEXT_CUSTOMIZE, function() TheFrontEnd:PushScreen(QACustomizePanel(self)) end)

    self.freq_list = self.root:AddChild(NoMuList(function()
        local item = MakeListItem('freq-list-item', 200, 40)
        item.delete = MakeHoverBtn(item, STRINGS.NOMU_QA.BUTTON_TEXT_DELETE, 20, 80, {1,0,0,1})
        BindHoverActions(item, {item.delete})

        item.SetInfo = function(_, data)
            item.text:SetString(data.freq)
            item.backing:SetOnClick(function() Announce(data.freq); if GLOBAL.NOMU_QA.DATA.FREQ_AUTO_CLOSE then self:Hide() end end)
            item.delete:SetOnClick(function() 
                TheFrontEnd:PushScreen(ConfirmDialog(nil, STRINGS.NOMU_QA.TITLE_TEXT_SURE_TO_DELETE, function() 
                    table.remove(GLOBAL.NOMU_QA.DATA.FREQ_LIST, data.idx); GLOBAL.NOMU_QA.SaveData(); self:Refresh() 
                end)) 
            end)
        end
        return item
    end, -220, 0, 200, 40, 2, 7)) 

    AddBtn(-330, -170, 195, dy, STRINGS.NOMU_QA.BUTTON_TEXT_WORD_MANAGE, function() TheFrontEnd:PushScreen(QAWordManagementPanel(self)) end)

    local s = STRINGS.NOMU_QA
    local right_grid = {
        { type="state", key="ALT_MODE", states={1,2,3}, texts={[1]=s.BUTTON_TEXT_ALT_MODE_1, [2]=s.BUTTON_TEXT_ALT_MODE_2, [3]=s.BUTTON_TEXT_ALT_MODE_3} },
        { type="state", key="SHIFT_MODE", states={1,2,3}, texts={[1]=s.BUTTON_TEXT_SHIFT_MODE_1, [2]=s.BUTTON_TEXT_SHIFT_MODE_2, [3]=s.BUTTON_TEXT_SHIFT_MODE_3} },
        { type="prefix", w=400, span=2 },
        { type="toggle", key="BLOCK_ACTION", on=s.BUTTON_TEXT_BLOCK_ACTION_ON, off=s.BUTTON_TEXT_BLOCK_ACTION_OFF },
        { type="toggle", key="ANNOUNCE_ALL_MISSING_INGREDIENTS", on=s.BUTTON_TEXT_ANNOUNCE_ALL_MISSING_ON, off=s.BUTTON_TEXT_ANNOUNCE_ALL_MISSING_OFF },
        { type="toggle", key="DEFAULT_WHISPER", on=s.BUTTON_TEXT_DEFAULT_WHISPER_ON, off=s.BUTTON_TEXT_DEFAULT_WHISPER_OFF },
        { type="toggle", key="CHARACTER_SPECIFIC", on=s.BUTTON_TEXT_CHARACTER_SPECIFIC_ON, off=s.BUTTON_TEXT_CHARACTER_SPECIFIC_OFF },
        { type="toggle", key="FREQ_AUTO_CLOSE", on=s.BUTTON_TEXT_FREQ_AUTO_CLOSE_ON, off=s.BUTTON_TEXT_FREQ_AUTO_CLOSE_OFF },
        { type="state", key="SHOW_ME", states={0,1,2}, texts={[0]=s.BUTTON_TEXT_SHOW_ME_OFF, [1]=s.BUTTON_TEXT_SHOW_ME_ON, [2]=s.BUTTON_TEXT_SHOW_ME_GIFT} },
        { type="state", key="ANNOUNCE_RANGE", states={40,60}, texts={[40]=s.BUTTON_TEXT_ANNOUNCE_RANGE_DEFAULT, [60]=s.BUTTON_TEXT_ANNOUNCE_RANGE_LARGE} },
        { type="toggle", key="FUZZY_ANNOUNCE", on=s.BUTTON_TEXT_FUZZY_ON, off=s.BUTTON_TEXT_FUZZY_OFF },
        { type="state", key="SHOW_DISTANCE", states={0,1,2}, texts={[0]=s.BUTTON_TEXT_DISTANCE_OFF, [1]=s.BUTTON_TEXT_DISTANCE_ON, [2]=s.BUTTON_TEXT_DISTANCE_PRECISE} },
        { type="toggle", key="DISABLE_MEME_PREVIEW", on=s.BUTTON_TEXT_MEME_PREVIEW_ON, off=s.BUTTON_TEXT_MEME_PREVIEW_OFF },
        { type="toggle", key="SHOW_MOD_NAME", on=s.BUTTON_TEXT_SHOW_MOD_NAME_ON, off=s.BUTTON_TEXT_SHOW_MOD_NAME_OFF },
        { type="toggle", key="ENABLE_SPECIAL_STATE", on=s.BUTTON_TEXT_SPECIAL_STATE_ON, off=s.BUTTON_TEXT_SPECIAL_STATE_OFF },
        { type="state", key="SHOW_ASSET_INFO", states={0,1,2}, texts={[0]=s.BUTTON_TEXT_SHOW_ASSET_OFF, [1]=s.BUTTON_TEXT_SHOW_ASSET_CODE, [2]=s.BUTTON_TEXT_SHOW_ASSET_ALL} },
        { type="toggle", key="DEBUG_MODE", on=s.BUTTON_TEXT_DEBUG_ON, off=s.BUTTON_TEXT_DEBUG_OFF },
    }

    local r_row, r_col = 1, 1
    for _, v in ipairs(right_grid) do
        local btn_x = (r_col == 1) and 120 or 320
        local btn_y = sy - r_row * dy
        local btn_w = v.w or 200

        if v.type == "prefix" then
            local prefix_btn
            prefix_btn = AddBtn(220, btn_y, btn_w, dy, function()
                local p = GLOBAL.NOMU_QA.DATA.CUSTOM_PREFIX
                return s.BUTTON_TEXT_CUSTOM_PREFIX .. tostring((p == nil or p == "") and GLOBAL.STRINGS.LMB or p)
            end, function()
                local default_val = GLOBAL.NOMU_QA.DATA.CUSTOM_PREFIX
                TheFrontEnd:PushScreen(GetInputString(self, s.TITLE_CUSTOM_PREFIX, (default_val == nil or default_val == "") and GLOBAL.STRINGS.LMB or default_val, function(val)
                    GLOBAL.NOMU_QA.DATA.CUSTOM_PREFIX = val; GLOBAL.NOMU_QA.SaveData()
                    if prefix_btn then prefix_btn:SetText(s.BUTTON_TEXT_CUSTOM_PREFIX .. tostring(val == "" and GLOBAL.STRINGS.LMB or val)) end
                end, 30, 300))
            end)
            r_row = r_row + 1; r_col = 1
        elseif v.type == "toggle" then
            AddToggleBtn(btn_x, btn_y, btn_w, dy, v.key, v.on, v.off)
            if r_col == 2 then r_row = r_row + 1; r_col = 1 else r_col = 2 end
        elseif v.type == "state" then
            AddBtn(btn_x, btn_y, btn_w, dy, function()
                local val = GLOBAL.NOMU_QA.DATA[v.key]
                if type(val) == "boolean" then val = val and 1 or 0 end
                return v.texts[val] or v.texts[v.states[1]]
            end, function()
                local cur = GLOBAL.NOMU_QA.DATA[v.key]
                if type(cur) == "boolean" then cur = cur and 1 or 0 end
                local next_val = v.states[1]
                for i, st in ipairs(v.states) do if st == cur then next_val = v.states[(i % #v.states) + 1] break end end
                GLOBAL.NOMU_QA.DATA[v.key] = next_val
                GLOBAL.NOMU_QA.SaveData()
            end)
            if r_col == 2 then r_row = r_row + 1; r_col = 1 else r_col = 2 end
        end
    end
    
    AddBtn(0, -sy, 200, dy, s.BUTTON_TEXT_CLOSE, function() self:Hide() end)
    self:Refresh()
end)

function QAPanel:Refresh()
    local fl = {}
    for idx, freq in ipairs(GLOBAL.NOMU_QA.DATA.FREQ_LIST) do table.insert(fl, { idx = idx, freq = freq }) end
    self.freq_list:Refresh(fl)
end
function QAPanel:OnGainFocus() self.camera_controllable_reset = TheCamera:IsControllable(); TheCamera:SetControllable(false) end
function QAPanel:OnLoseFocus() TheCamera:SetControllable(self.camera_controllable_reset) end
function QAPanel:OnControl(control, down)
    if QAPanel._base.OnControl(self, control, down) then return true end
    if not down and (control == CONTROL_PAUSE or control == CONTROL_CANCEL) then self:Hide() end
    return true
end

GLOBAL.NOMU_QA.QAPanel = QAPanel

-- 通用 Hook 工具用于向所有支持聊天的组件注入表情菜单
local function HookEmojiMenu(class_path, mode, get_textbox_fn)
    AddClassPostConstruct(class_path, function(self)
        if mode == "chat" or mode == "writeable" then
            local old_OnBecomeActive = self.OnBecomeActive
            function self:OnBecomeActive(...)
                if old_OnBecomeActive then old_OnBecomeActive(self, ...) end
                CreateEmojiAndPhraseMenu(self, mode)
            end
        elseif mode == "lobby_chat" then
            CreateEmojiAndPhraseMenu(self, mode)
        end
        
        local function CleanEmojiMenu()
            for _, v in ipairs(self.EM_all_widgets or {}) do if v and v.Kill then v:Kill() end end
            if self.EM_input then self.EM_input:Remove(); self.EM_input = nil end
        end
        
        if self.Kill then
            local old_Kill = self.Kill
            function self:Kill(...) CleanEmojiMenu(); if old_Kill then return old_Kill(self, ...) end end
        end
        if self.Close then
            local old_Close = self.Close
            function self:Close(...) CleanEmojiMenu(); if old_Close then old_Close(self, ...) end end
        end
        
        local textbox = get_textbox_fn(self)
        if textbox then
            local old_OnStopForceEdit = textbox.OnStopForceEdit
            textbox.OnStopForceEdit = function(...)
                if self.EM_bg and self.EM_bg.shown then return end
                if self.EM_menu and self.EM_menu.focus then return end
                if old_OnStopForceEdit then return old_OnStopForceEdit(...) end
            end
        end
        
        local old_OnControl = self.OnControl
        function self:OnControl(control, down)
            if self.EM_bg and self.EM_bg.shown and control == GLOBAL.CONTROL_CANCEL then
                if self.EM_menu and self.EM_menu.focus then return true end
                if not down then self.EM_bg:Hide(); if textbox then textbox:SetEditing(true) end end
                return true
            end
            if old_OnControl then return old_OnControl(self, control, down) end
            return false
        end
    end)
end

HookEmojiMenu("widgets/writeablewidget", "writeable", function(self) return nil end)
HookEmojiMenu("screens/chatinputscreen", "chat", function(self) return self.chat_edit end)
HookEmojiMenu("widgets/redux/chatsidebar", "lobby_chat", function(self) return self.chatbox and self.chatbox.textbox end)