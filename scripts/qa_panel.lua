local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"
local ImageButton = require "widgets/imagebutton"
local Image = require "widgets/image"
local TextButton = require "widgets/textbutton"
local Text = require "widgets/text"
local PlayerBadge = require "widgets/playerbadge"

local QA = GLOBAL.NOMU_QA
local LOCAL_STRINGS = GLOBAL.STRINGS.NOMU_QA or {}
local DeepCopy = QA.DeepCopy
local Announce = QA.Announce
local VERSION = QA.VERSION
local PlayMoveSound = QA.PlayMoveSound
local IsChildOf = QA.IsChildOf
local EnsureTable = QA.EnsureTable

-- 通用 UI 辅助构建函数
local function MakeCarnyButton(parent, x, y, w, h, text, text_size, fn)
    local button = parent:AddChild(ImageButton(
        "images/global_redux.xml",
        "button_carny_long_normal.tex",
        "button_carny_long_hover.tex",
        "button_carny_long_disabled.tex",
        "button_carny_long_down.tex"
    ))
    button:SetFont(CHATFONT)
    button:SetPosition(x, y, 0)
    button:SetTextSize(text_size or 26)
    button:ForceImageSize(w, h)
    button:SetTextColour(0, 0, 0, 1)
    button:SetTextFocusColour(0.9, 0.45, 0.1, 1)
    button:SetFocusScale(1.05, 1.05, 1.05)
    button:SetOnClick(function()
        fn(button)
        if type(text) == "function" then button:SetText(text(button)) end
    end)
    button:SetText(type(text) == "function" and text(button) or text)
    return button
end

local function MakeToggleButton(parent, x, y, w, h, key, text_on, text_off, on_toggle)
    return MakeCarnyButton(parent, x, y, w, h, function()
        return QA.DATA[key] and text_on or text_off
    end, 26, function()
        if on_toggle then
            on_toggle()
        else
            QA.DATA[key] = not QA.DATA[key]
        end
        QA.SaveData()
    end)
end

local function MakeListItem(name, w, h)
    local item = Widget(name)
    item.backing = item:AddChild(TEMPLATES.ListItemBackground(w, h, function() end))
    item.backing.move_on_click = true
    item.backing:SetFocusScale(1.04, 1.04, 1.04)
    item.text = item:AddChild(Text(GLOBAL.BODYTEXTFONT, 20, nil, GLOBAL.UICOLOURS.WHITE))
    item.focus_forward = item.backing

    item.backing:SetOnGainFocus(function() item.text:SetColour(1, 1, 0.3, 1) end)
    item.backing:SetOnLoseFocus(function() item.text:SetColour(1, 1, 1, 1) end)
    return item
end

local function MakeHoverBtn(parent, text, size, x, color, hover_color)
    local btn = parent:AddChild(TextButton())
    btn:SetFont(GLOBAL.CHATFONT)
    btn:SetTextSize(size)
    btn:SetText(text)
    btn:SetPosition(x, 0, 0)
    btn:SetTextColour(color or { 1, 1, 1, 1 })
    btn:SetTextFocusColour(hover_color or { 1, 1, 1, 1 })
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

-- 弹窗基类与滚动列表组件
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
        return MakeCarnyButton(self.root, x, y, w, h, text, 26, fn)
    end

    self.AddToggle = function(x, y, w, h, key, text_on, text_off, on_toggle)
        return MakeToggleButton(self.root, x, y, w, h, key, text_on, text_off, on_toggle)
    end
end)

function NoMuScreen:Close()
    if self.EM_all_widgets then
        for _, v in ipairs(self.EM_all_widgets) do
            if v and v.Kill then v:Kill() end
        end
    end
    if self.EM_input then self.EM_input:Remove(); self.EM_input = nil end
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
            if not data then w.focus_forward = nil; return end
            w.focus_forward = w.nomu_list_item
            w.nomu_list_item:Show()
            w.nomu_list_item:SetInfo(data)
        end,
        scrollbar_offset = 10, scrollbar_height_offset = -60, peek_percent = 0, allow_bottom_empty_row = true
    }))
    self.scroll_lists:SetPosition(override.x or self.x, override.y or self.y)
end

local CONTROLLER_EMOJIS = {
    "\238\128\143", "\238\128\140", "\238\128\141", "\238\128\142", "\238\128\132", "\238\128\133", "\238\128\134", "\238\128\137",
    "\238\128\135", "\238\128\138", "\238\128\128", "\238\128\129", "\238\128\130", "\238\128\131", "\238\128\146", "\238\128\147",
    "\238\128\145", "\238\128\144", "\238\128\150", "\238\128\151", "\238\128\149", "\238\128\148", "\238\128\136", "\238\128\136",
    "\238\128\139", "\238\128\139", "\238\128\152", "\238\128\153", "\238\132\128", "\238\132\129", "\238\136\130", "\238\136\131",
    "\238\136\129", "\238\136\128", "\238\129\136", "\238\129\139", "\238\129\135", "\238\129\138", "\238\129\132", "\238\129\133",
}

local function SendMemeChatMessage(meme_name, whisper)
    if GLOBAL.TheNet then GLOBAL.TheNet:Say("[Meme:" .. meme_name .. "]", whisper) end
end

local function BuildEmojiTab(self, page, insert_fn)
    if #self.EM_emojis > 0 then return end
    local function AddEmojiBtn(char)
        local textbtn = page:AddChild(TextButton())
        textbtn:SetTextSize(30)
        textbtn:SetText(char)
        textbtn:SetOnGainFocus(function() textbtn:SetScale(1.2) end)
        textbtn:SetOnLoseFocus(function() textbtn:SetScale(1) end)
        textbtn:SetOnClick(function() insert_fn(char) end)
        table.insert(self.EM_emojis, textbtn)
    end

    for _, v in pairs(GLOBAL.EMOJI_ITEMS or {}) do
        if v.data and v.data.utf8_str then AddEmojiBtn(v.data.utf8_str) end
    end
    for _, v in ipairs(CONTROLLER_EMOJIS) do AddEmojiBtn(v) end

    local space_x, space_y, row_buttons, y_offset = 35, 35, 10, 125
    for k, v in ipairs(self.EM_emojis) do
        local row = math.floor((k - 1) / row_buttons)
        local row_count = math.min(row_buttons, #self.EM_emojis - row * row_buttons)
        v:SetPosition(((k - 1) % row_buttons - (row_count - 1) / 2) * space_x, y_offset - row * space_y)
    end
end

local function BuildPhraseTab(self, page, insert_fn, S)
    local function RefreshPhraseList()
        local fl = {}
        for idx, freq in ipairs(QA.DATA.FREQ_LIST or {}) do table.insert(fl, { idx = idx, freq = freq }) end
        if self.EM_str_list then self.EM_str_list:Refresh(fl) end
    end

    self.EM_str_list = page:AddChild(NoMuList(function()
        local item = MakeListItem("freq-list-item", 320, 40)
        item.delete = MakeHoverBtn(item, LOCAL_STRINGS.BUTTON_TEXT_DELETE, 20, 140, { 1, 0, 0, 1 })
        BindHoverActions(item, { item.delete })

        item.SetInfo = function(_, data)
            item.text:SetString(#data.freq > 45 and string.sub(data.freq, 1, 45) .. "..." or data.freq)
            item.backing:SetOnClick(function() insert_fn(data.freq) end)
            item.delete:SetOnClick(function()
                table.remove(QA.DATA.FREQ_LIST, data.idx)
                QA.SaveData()
                RefreshPhraseList()
                if GLOBAL.ThePlayer and GLOBAL.ThePlayer.HUD and GLOBAL.ThePlayer.HUD.controls.nomu_qa_panel then
                    GLOBAL.ThePlayer.HUD.controls.nomu_qa_panel:Refresh()
                end
            end)
        end
        return item
    end, 0, 20, 320, 40, 1, 5))

    self.EM_input_root = page:AddChild(Widget("input_root"))
    self.EM_input_root:SetPosition(0, -120)
    self.EM_input_box = self.EM_input_root:AddChild(TEMPLATES.StandardSingleLineTextEntry("", 240, 40, GLOBAL.CHATFONT, 26, S.INPUT_ADD_PHRASE))
    self.EM_input_box:SetPosition(-35, 0)

    self.EM_input_btn = MakeCarnyButton(self.EM_input_root, 115, 0, 70, 40, S.BTN_ADD, 24, function()
        local text = self.EM_input_box.textbox:GetString()
        if text and text ~= "" then
            table.insert(QA.DATA.FREQ_LIST, text)
            QA.SaveData()
            self.EM_input_box.textbox:SetString("")
            RefreshPhraseList()
            if GLOBAL.ThePlayer and GLOBAL.ThePlayer.HUD and GLOBAL.ThePlayer.HUD.controls.nomu_qa_panel then
                GLOBAL.ThePlayer.HUD.controls.nomu_qa_panel:Refresh()
            end
        end
    end)
    RefreshPhraseList()
end

local function BuildMemeTab(self, page, mode)
    local current_tab = QA.LAST_MEME_TAB or 0
    local current_cat_page = QA.LAST_MEME_CAT_PAGE or 1
    local cats_per_page = 5
    local fav_set = {}

    local function CloseAfterSend()
        if self.EM_bg then self.EM_bg:Hide() end
        if QA.DATA.FREQ_AUTO_CLOSE and mode == "chat" then
            if type(self.Close) == "function" then self:Close() else GLOBAL.TheFrontEnd:PopScreen(self) end
        else
            self.RestoreInputFocus()
        end
    end

    self.EM_meme_grid = page:AddChild(NoMuList(function()
        local item = Widget("meme-grid-item")
        item.btn = item:AddChild(ImageButton())
        item.btn:SetNormalScale(0.45, 0.45, 0.45)
        item.btn:SetFocusScale(0.5, 0.5, 0.5)

        item.fav_marker = item:AddChild(Text(GLOBAL.UIFONT, 25, "★"))
        item.fav_marker:SetColour(1, 0.8, 0.1, 1)
        item.fav_marker:SetPosition(22, 22)
        item.fav_marker:SetClickable(false)
        item.fav_marker:Hide()

        local old_OnMouseButton = item.btn.OnMouseButton
        item.btn.OnMouseButton = function(self_btn, button, down, x, y)
            if button == GLOBAL.MOUSEBUTTON_MIDDLE and not down and item.data then
                local name = item.data.name
                local favs = QA.DATA.MEME_FAVS or {}
                local found_idx = nil
                for i, v in ipairs(favs) do if v == name then found_idx = i; break end end
                if found_idx then
                    table.remove(favs, found_idx)
                    fav_set[name] = nil
                    item.fav_marker:Hide()
                else
                    table.insert(favs, 1, name)
                    fav_set[name] = true
                    item.fav_marker:Show()
                end
                QA.DATA.MEME_FAVS = favs
                QA.SaveData()
                if current_tab == 0 and item.refresh_fn then item.refresh_fn() end
                return true
            end
            if button == GLOBAL.MOUSEBUTTON_RIGHT and not down and item.data then
                SendMemeChatMessage(item.data.name, true)
                CloseAfterSend()
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

            if fav_set[data.name] then item.fav_marker:Show() else item.fav_marker:Hide() end

            item.btn:SetOnClick(function()
                SendMemeChatMessage(data.name, false)
                CloseAfterSend()
            end)
        end
        item.focus_forward = item.btn
        return item
    end, 0, -15, 65, 65, 5, 4))

    local function RefreshMemes()
        fav_set = {}
        for _, name in ipairs(QA.DATA.MEME_FAVS or {}) do fav_set[name] = true end

        local list_key = "List_" .. current_tab
        local grid_data = {}
        if current_tab == 0 then
            for _, name in ipairs(QA.DATA.MEME_FAVS or {}) do
                local prefix = name:match("^(.*)_%d+")
                local atlas = (prefix and QA.Prefix_Atlas_Map and QA.Prefix_Atlas_Map[prefix]) or "images/meme/" .. name .. ".xml"
                table.insert(grid_data, { name = name, atlas = atlas, prefix = prefix })
            end
        else
            for _, name in ipairs(QA.MEME_LIST[list_key] or {}) do
                table.insert(grid_data, { name = name, atlas = QA.MEME_LIST_DATA[list_key].atlas, prefix = QA.MEME_LIST_DATA[list_key].prefix })
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
        while QA.MEME_LIST_DATA["List_" .. total_meme_lists] do total_meme_lists = total_meme_lists + 1 end
        local total_cat_pages = math.max(1, math.ceil(total_meme_lists / cats_per_page))

        if total_cat_pages > 1 then
            local function AddPageBtn(text, x, step)
                local btn = page:AddChild(ImageButton("images/global_redux.xml", "button_carny_square_normal.tex", "button_carny_square_hover.tex", "button_carny_square_disabled.tex", "button_carny_square_down.tex"))
                btn:SetPosition(x, 126)
                btn:ForceImageSize(28, 28)
                btn:SetFont(GLOBAL.CHATFONT)
                btn.text:SetColour(0, 0, 0, 1)
                btn:SetTextSize(18)
                btn:SetText(text)
                btn:SetOnClick(function()
                    current_cat_page = current_cat_page + step
                    if current_cat_page < 1 then current_cat_page = total_cat_pages elseif current_cat_page > total_cat_pages then current_cat_page = 1 end
                    QA.LAST_MEME_CAT_PAGE = current_cat_page
                    RefreshCategoryButtons()
                end)
                table.insert(self.EM_meme_cat_btns, btn)
            end
            AddPageBtn("<", -170, -1)
            AddPageBtn(">", 170, 1)
        end

        local start_idx = (current_cat_page - 1) * cats_per_page
        local end_idx = math.min(start_idx + cats_per_page - 1, total_meme_lists - 1)
        local start_x = -(end_idx - start_idx + 1) * 62 / 2 + 28

        for i = start_idx, end_idx do
            local title = QA.MEME_LIST_DATA["List_" .. i] and QA.MEME_LIST_DATA["List_" .. i].title or tostring(i)
            local sub_btn = MakeCarnyButton(page, start_x + (i - start_idx) * 62, 126, 56, 28, title, 15, function()
                current_tab = i
                QA.LAST_MEME_TAB = i
                RefreshMemes()
                RefreshCategoryButtons()
            end)
            sub_btn:SetFocusScale(1, 1, 1)
            local col = (i == 0) and { 0.2, 0.8, 0.2, 1 } or { 0, 0, 0, 1 }
            sub_btn:SetTextColour(col)
            sub_btn:SetTextFocusColour(col)
            sub_btn.text:SetColour(unpack(col))
            if sub_btn.SetTextSelectedColour then sub_btn:SetTextSelectedColour(col) end
            if current_tab == i then sub_btn.image:SetTint(0.8, 0.8, 0.8, 1) end
            table.insert(self.EM_meme_cat_btns, sub_btn)
        end
    end

    RefreshCategoryButtons()
    RefreshMemes()
end

local function BuildPlayerTab(self, page, mode, insert_fn, S)
    local pw, ph = 300, 46
    self.EM_player_list = page:AddChild(NoMuList(function()
        local item = MakeListItem("player-list-item", pw, ph)
        item.focus_forward = nil

        item.characterBadge = item:AddChild(PlayerBadge("", GLOBAL.DEFAULT_PLAYER_COLOUR, false, 0))
        item.characterBadge:SetScale(0.55)
        item.characterBadge:SetPosition(-pw / 2 + 25, 0, 0)

        item.text:SetHAlign(GLOBAL.ANCHOR_LEFT)
        item.text:SetRegionSize(pw - 130, 20)
        item.text:SetPosition(-5, 9, 0)
        item.text:SetSize(18)

        item.kuid_btn = item:AddChild(TextButton())
        item.kuid_btn:SetFont(GLOBAL.CHATFONT)
        item.kuid_btn:SetTextSize(13)
        item.kuid_btn:SetTextColour({ 0.75, 0.75, 0.75, 1 })
        item.kuid_btn:SetTextFocusColour(GLOBAL.UICOLOURS.GOLD)
        if item.kuid_btn.text then
            item.kuid_btn.text:SetHAlign(GLOBAL.ANCHOR_LEFT)
            item.kuid_btn.text:SetRegionSize(pw - 130, 16)
        end
        item.kuid_btn:SetPosition(-5, -11, 0)
        if S and S.TOOLTIP_KUID then item.kuid_btn:SetHoverText(S.TOOLTIP_KUID) end

        item.SetInfo = function(_, client)
            item.client = client
            item.text:SetString(client.name)
            item.text:SetColour(unpack(client.colour or GLOBAL.DEFAULT_PLAYER_COLOUR))
            item.characterBadge:Set(client.prefab or "", client.colour or GLOBAL.DEFAULT_PLAYER_COLOUR, client.performance ~= nil, client.userflags or 0, client.base_skin)
            local display_kuid = client.userid or ""
            item.kuid_btn:SetText(display_kuid)

            item.kuid_btn:SetOnClick(function()
                local qa_player = QA.SCHEME and QA.SCHEME.PLAYER
                local fmt = (qa_player and qa_player.FORMATS and qa_player.FORMATS.KUID)
                    or (GLOBAL.STRINGS.DEFAULT_NOMU_QA and GLOBAL.STRINGS.DEFAULT_NOMU_QA.PLAYER.FORMATS.KUID)
                Announce(GLOBAL.subfmt(fmt, { NAME = client.name, KUID = display_kuid }))
                if QA.DATA.FREQ_AUTO_CLOSE and mode == "chat" then
                    if type(self.Close) == "function" then self:Close() else GLOBAL.TheFrontEnd:PopScreen(self) end
                else
                    self.RestoreInputFocus()
                end
            end)

            item.backing:SetOnClick(function()
                insert_fn("@" .. client.name .. " ")
                self.SwitchToTab(2)
                self.RestoreInputFocus()
            end)
        end
        return item
    end, 0, 10, pw, ph, 1, 6))
end

local function CreateEmojiAndPhraseMenu(self, mode)
    self.EM_all_widgets = {}
    self.EM_emojis = {}
    local S = LOCAL_STRINGS.EMOJI_MENU

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
        local bg_parent = (mode == "chat" and self.screen_root)
            or ((mode == "input_string" or mode == "rename_position") and self.root) or self
        self.EM_bg = bg_parent:AddChild(Widget("EM_bg"))

        local width, height = 360, 380
        local atlas = resolvefilepath(CRAFTING_ATLAS)
        local function AddTex(tex, w, h, x, y, clickable)
            local img = self.EM_bg:AddChild(Image(atlas, tex))
            img:ScaleToSize(w, h)
            img:SetPosition(x, y)
            if clickable == false then img:SetClickable(false) end
            return img
        end

        AddTex("backing.tex", width + 10, height + 18, 0, 0):SetTint(1, 1, 1, 0.5)
        AddTex("side.tex", -26, -(height - 20), -width / 2 - 8, 1)
        AddTex("side.tex", 26, height - 20, width / 2 + 8, 1, false)
        AddTex("top.tex", width + 34, 38, 0, height / 2 + 10)
        AddTex("bottom.tex", width + 34, 38, 0, -height / 2 - 8, false)

        if mode == "chat" then self.EM_bg:SetPosition(-320, 320, 0); self.EM_bg:MoveToFront()
        elseif mode == "input_string" then self.EM_bg:SetPosition(400, 0, 0); self.EM_bg:MoveToFront()
        elseif mode == "lobby_chat" then self.EM_bg:SetPosition(390, 310, 0); self.EM_bg:MoveToFront()
        else self.EM_bg:SetPosition(400, 20, 0) end

        table.insert(self.EM_all_widgets, self.EM_bg)

        self.EM_menu_root = self.EM_bg:AddChild(Widget("menu_root"))
        for i = 1, 4 do self["EM_page_" .. i] = self.EM_bg:AddChild(Widget("page_" .. i)) end

        local function SwitchToTab(tab_idx)
            if not QA.ENABLE_MEME_SYSTEM and tab_idx == 3 then tab_idx = 1 end
            QA.LAST_EMOJI_TAB = tab_idx
            for i = 1, 4 do
                if i == tab_idx then self["EM_page_" .. i]:Show() else self["EM_page_" .. i]:Hide() end
            end
            if tab_idx == 4 and self.EM_player_list then
                self.EM_player_list:Refresh(GLOBAL.TheNet:GetClientTable() or {})
            end
        end
        self.SwitchToTab = SwitchToTab

        if QA.ENABLE_MEME_SYSTEM then
            self.EM_btn_1 = MakeCarnyButton(self.EM_menu_root, -110, 160, 100, 36, S.TAB_EMOJI, 22, function() SwitchToTab(1) end)
            self.EM_btn_2 = MakeCarnyButton(self.EM_menu_root, 0, 160, 100, 36, S.TAB_PHRASE, 22, function() SwitchToTab(2) end)
            self.EM_btn_3 = MakeCarnyButton(self.EM_menu_root, 110, 160, 100, 36, S.TAB_MEME, 22, function() SwitchToTab(3) end)
        else
            self.EM_btn_1 = MakeCarnyButton(self.EM_menu_root, -60, 160, 100, 36, S.TAB_EMOJI, 22, function() SwitchToTab(1) end)
            self.EM_btn_2 = MakeCarnyButton(self.EM_menu_root, 60, 160, 100, 36, S.TAB_PHRASE, 22, function() SwitchToTab(2) end)
        end

        self.EM_btn_2:SetOnClick(function()
            SwitchToTab(QA.LAST_EMOJI_TAB == 2 and 4 or 2)
        end)

        BuildEmojiTab(self, self.EM_page_1, InsertText)
        BuildPhraseTab(self, self.EM_page_2, InsertText, S)
        if QA.ENABLE_MEME_SYSTEM then BuildMemeTab(self, self.EM_page_3, mode) end
        BuildPlayerTab(self, self.EM_page_4, mode, InsertText, S)

        SwitchToTab(QA.LAST_EMOJI_TAB or 1)
    end

    local menu_parent = (mode == "chat" or mode == "input_string" or mode == "rename_position") and self.root or self
    local menu = menu_parent:AddChild(ImageButton("images/hud.xml", "self_inspect_mod.tex", "self_inspect_mod.tex", "self_inspect_mod.tex", nil, nil, { 1, 1 }, { 0, 0 }))
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
            if self.EM_bg.shown then self.EM_bg:Hide() else self.EM_bg:Show(); if self.SwitchToTab then self.SwitchToTab(QA.LAST_EMOJI_TAB or 1) end end
        else
            build_bg()
        end
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
                    else self.EM_bg:Show(); if self.SwitchToTab then self.SwitchToTab(QA.LAST_EMOJI_TAB or 1) end end
                    return true
                end
                if is_bg_shown and not self.EM_bg.focus then
                    self.EM_bg:Hide(); self.RestoreInputFocus(); return true
                end
            end
        end)
    end
end

-- 子弹窗组件
local GetInputString = Class(NoMuScreen, function(self, nomu_parent, title, value, callback, limit, width)
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

    self.AddButton(-80, -40, 100, 40, LOCAL_STRINGS.BUTTON_TEXT_APPLY, function() callback(self.config_input.textbox:GetLineEditString()); self:Close() end)
    self.AddButton(80, -40, 100, 40, LOCAL_STRINGS.BUTTON_TEXT_CLOSE, function() self:Close() end)
    CreateEmojiAndPhraseMenu(self, "input_string")
end)

local ConfirmDialog = Class(NoMuScreen, function(self, nomu_parent, title, callback)
    NoMuScreen._ctor(self, "ConfirmDialog", nomu_parent, 250, 90)
    self.root:AddChild(Text(BODYTEXTFONT, 32, title)):SetPosition(0, 20)
    self.AddButton(-50, -20, 100, 40, LOCAL_STRINGS.BUTTON_TEXT_YES, function() callback(); self:Close() end)
    self.AddButton(50, -20, 100, 40, LOCAL_STRINGS.BUTTON_TEXT_NO, function() self:Close() end)
end)

local ActionMenuDialog = Class(NoMuScreen, function(self, nomu_parent, title, on_copy, on_reset)
    NoMuScreen._ctor(self, "ActionMenuDialog", nomu_parent, 360, 130)
    local title_txt = self.root:AddChild(Text(BODYTEXTFONT, 26, title or LOCAL_STRINGS.TITLE_ACTION_MENU))
    title_txt:SetPosition(0, 30)
    title_txt:SetRegionSize(320, 30)

    self.AddButton(-110, -25, 95, 38, LOCAL_STRINGS.BUTTON_TEXT_COPY_TO, function() self:Close(); if on_copy then on_copy() end end)
    self.AddButton(0, -25, 95, 38, LOCAL_STRINGS.BUTTON_TEXT_RESET, function() self:Close(); if on_reset then on_reset() end end)
    self.AddButton(110, -25, 95, 38, LOCAL_STRINGS.BUTTON_TEXT_CLOSE, function() self:Close() end)
end)

local CharacterPicker = Class(NoMuScreen, function(self, nomu_parent, callback)
    local iw, ih = 120, 40
    local width, height = iw + 10, 80 + ih * 4
    NoMuScreen._ctor(self, "CharacterPicker", nomu_parent, width, height + 10)

    self.character_list = self.root:AddChild(NoMuList(function()
        local item = MakeListItem("character-list-item", iw, ih)
        item.SetInfo = function(_, character)
            item.text:SetString(character == "DEFAULT" and LOCAL_STRINGS.TITLE_TEXT_MAPPING_DEFAULT or STRINGS.NAMES[character:upper()] or character:upper())
            item.backing:SetOnClick(function() callback(character); self:Close() end)
        end
        return item
    end, 0, 0, iw, ih, math.floor(width / iw), math.floor((height - 80) / ih)))

    self.AddButton(0, -height / 2 + 20, 120, 40, LOCAL_STRINGS.BUTTON_TEXT_CLOSE, function() self:Close() end)

    local character_list = { "DEFAULT" }
    for _, character in ipairs(DST_CHARACTERLIST) do table.insert(character_list, character) end
    self.character_list:Refresh(character_list)
end)

local QAWordManagementPanel = Class(NoMuScreen, function(self, nomu_parent)
    local dy = 35
    NoMuScreen._ctor(self, "QAWordManagementPanel", nomu_parent, 860, 490)

    self.h_line = self.root:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
    self.h_line:SetScale(1.0, 1)
    self.h_line:SetPosition(0, 25)

    local function BuildSection(title_str, toggle_key, btn_text, input1, input2, data_key, x, y, w, fmt_fn)
        self.root:AddChild(Text(BODYTEXTFONT, 28, title_str)):SetPosition(x, y)
        self.AddToggle(x - 65, y - dy, 120, dy, toggle_key, LOCAL_STRINGS.EMOJI_MENU.ON, LOCAL_STRINGS.EMOJI_MENU.OFF)
        self.AddButton(x + 65, y - dy, 120, dy, btn_text, function()
            TheFrontEnd:PushScreen(GetInputString(self, input1, "", function(v1)
                if not v1 or v1 == "" then return end
                if input2 then
                    TheFrontEnd:PushScreen(GetInputString(self, input2, "", function(v2)
                        table.insert(EnsureTable(QA.DATA, data_key), { target = v1, result = v2 or "", prefab = v1, name = v2 or "" })
                        QA.SaveData(); self["Refresh" .. data_key](self)
                    end, 100, 300))
                else
                    table.insert(EnsureTable(QA.DATA, data_key), v1)
                    QA.SaveData(); self["Refresh" .. data_key](self)
                end
            end, 100, 300))
        end)

        local list_ui = self.root:AddChild(NoMuList(function()
            local item = MakeListItem(data_key .. "-item", w, 40)
            item.delete = MakeHoverBtn(item, LOCAL_STRINGS.BUTTON_TEXT_DELETE, 20, w / 2 - 40, { 1, 0, 0, 1 })
            BindHoverActions(item, { item.delete })

            item.SetInfo = function(_, data)
                item.text:SetString(fmt_fn(data.val))
                item.delete:SetOnClick(function()
                    table.remove(QA.DATA[data_key], data.idx)
                    QA.SaveData(); self["Refresh" .. data_key](self)
                end)
            end
            return item
        end, x, y - 2 * dy - 50, w, 40, 1, 3))

        self["Refresh" .. data_key] = function()
            local l = {}
            for i, v in ipairs(QA.DATA[data_key] or {}) do table.insert(l, { idx = i, val = v }) end
            list_ui:Refresh(l)
        end
        self["Refresh" .. data_key](self)
    end

    local empty_hint = LOCAL_STRINGS.EMPTY_VALUE_HINT
    BuildSection(LOCAL_STRINGS.TITLE_FORBIDDEN_LIST, "ENABLE_FORBIDDEN", LOCAL_STRINGS.BUTTON_NEW_FORBIDDEN, LOCAL_STRINGS.TITLE_FORBIDDEN_LIST, nil, "FORBIDDEN_WORDS", -215, 230, 240, function(v) return v end)
    BuildSection(LOCAL_STRINGS.TITLE_SHOWME_FILTER, "ENABLE_SHOWME_FILTER", LOCAL_STRINGS.BUTTON_NEW_SHOWME_FILTER, LOCAL_STRINGS.TITLE_SHOWME_FILTER, nil, "SHOWME_FILTERS", 215, 230, 240, function(v) return v end)
    BuildSection(LOCAL_STRINGS.TITLE_REPLACE_LIST, "ENABLE_REPLACE", LOCAL_STRINGS.BUTTON_NEW_REPLACE, LOCAL_STRINGS.INPUT_REPLACE_TARGET, LOCAL_STRINGS.INPUT_REPLACE_RESULT, "REPLACEMENTS", -215, 5, 280, function(v) return v.target .. " -> " .. (v.result ~= "" and v.result or empty_hint) end)
    BuildSection(LOCAL_STRINGS.TITLE_CUSTOM_PREFAB_LIST, "ENABLE_CUSTOM_PREFAB_NAME", LOCAL_STRINGS.BUTTON_NEW_CUSTOM_PREFAB, LOCAL_STRINGS.INPUT_PREFAB_TARGET, LOCAL_STRINGS.INPUT_PREFAB_RESULT, "CUSTOM_PREFAB_NAMES", 215, 5, 280, function(v) return v.prefab .. " -> " .. (v.name ~= "" and v.name or empty_hint) end)

    self.AddButton(0, -215, 200, 40, LOCAL_STRINGS.BUTTON_TEXT_CLOSE, function() self:Close() end)
end)

local function ValidateScheme(scheme)
    return scheme.name ~= nil and scheme.data ~= nil and scheme.version ~= nil
end

local SchemeTemplatePicker = Class(NoMuScreen, function(self, nomu_parent, callback)
    local iw, ih = 200, 40
    local width, height = iw + 40, 80 + ih * 5
    NoMuScreen._ctor(self, "SchemeTemplatePicker", nomu_parent, width, height + 10)
    self.root:AddChild(Text(BODYTEXTFONT, 28, LOCAL_STRINGS.TITLE_TEXT_CHOOSE_TEMPLATE)):SetPosition(0, height / 2 - 25)

    self.scheme_list = self.root:AddChild(NoMuList(function()
        local item = MakeListItem("scheme-list-item", iw, ih)
        item.SetInfo = function(_, scheme)
            item.text:SetString(scheme.name)
            item.backing:SetOnClick(function() callback(scheme); self:Close() end)
        end
        return item
    end, 0, -10, iw, ih, 1, 5))

    self.AddButton(0, -height / 2 + 25, 120, 40, LOCAL_STRINGS.BUTTON_TEXT_CLOSE, function() self:Close() end)
    self.scheme_list:Refresh(QA.DATA.SCHEMES)
end)

local QACustomizePanel = Class(NoMuScreen, function(self, nomu_parent)
    local width, height = 860, 480
    local sy, sx, dy = height / 2 - 20, -width / 2, 40
    self.sx, self.sy, self.dy = sx, sy, dy
    NoMuScreen._ctor(self, "QACustomizePanel", nomu_parent, width, height + 10)

    self.scheme_idx = 1
    self.root:AddChild(Text(BODYTEXTFONT, 32, LOCAL_STRINGS.TITLE_TEXT_SCHEMES)):SetPosition(sx + 100, sy)

    local d_hint = self.root:AddChild(Text(BODYTEXTFONT, 18, LOCAL_STRINGS.DEFAULT_SCHEME_RESET_HINT))
    d_hint:SetPosition(sx + 100, sy - 35)
    d_hint:SetColour(0.9, 0.6, 0.6, 1)

    self.AddButton(sx + 100, sy - 75, 200, dy, LOCAL_STRINGS.BUTTON_TEXT_NEW_SCHEME, function()
        TheFrontEnd:PushScreen(GetInputString(nil, LOCAL_STRINGS.BUTTON_TEXT_NEW_SCHEME, "", function(value)
            if not value or value == "" then return end
            TheFrontEnd:PushScreen(SchemeTemplatePicker(nil, function(ts)
                table.insert(QA.DATA.SCHEMES, { name = value, data = DeepCopy(ts.data), version = VERSION, source_template = ts.source_template or ts.name })
                QA.SaveData(); self:RefreshSchemeList(); self:RefreshScheme(#QA.DATA.SCHEMES)
            end))
        end))
    end)

    self.scheme_list = self.root:AddChild(NoMuList(function()
        local item = MakeListItem("scheme-list-item", 200, 40)
        item.rename = MakeHoverBtn(item, LOCAL_STRINGS.BUTTON_TEXT_RENAME, 20, -70, { 0, 1, 0, 1 })
        item.delete = MakeHoverBtn(item, LOCAL_STRINGS.BUTTON_TEXT_DELETE, 20, 70, { 1, 0, 0, 1 })

        function item:OnGainFocus() item.delete:Show(); if not item.no_rename then item.rename:Show() end end
        function item:OnLoseFocus() item.delete:Hide(); if not item.no_rename then item.rename:Hide() end end

        item.SetInfo = function(_, data)
            item.text:SetString(data.name)
            item.backing:SetOnClick(function() self:RefreshScheme(data.idx) end)
            if data.idx <= 4 then
                item.rename:Hide(); item.no_rename = true; item.delete:SetText(LOCAL_STRINGS.BUTTON_TEXT_RESET)
                item.delete:SetOnClick(function()
                    TheFrontEnd:PushScreen(ConfirmDialog(nil, LOCAL_STRINGS.TITLE_TEXT_SURE_TO_RESET_DEFAULT, function()
                        local builtins = QA.GetBuiltinSchemes and QA.GetBuiltinSchemes() or {}
                        if builtins[data.idx] then
                            QA.DATA.SCHEMES[data.idx].data = DeepCopy(builtins[data.idx].source)
                            QA.SaveData(); self:RefreshScheme(data.idx)
                        end
                    end))
                end)
            else
                item.no_rename = false
                item.delete:SetText(LOCAL_STRINGS.BUTTON_TEXT_DELETE)
                item.delete:SetOnClick(function()
                    TheFrontEnd:PushScreen(ConfirmDialog(nil, LOCAL_STRINGS.TITLE_TEXT_SURE_TO_DELETE, function()
                        table.remove(QA.DATA.SCHEMES, data.idx); QA.SaveData()
                        self:RefreshSchemeList(); self:RefreshScheme(math.min(self.scheme_idx, #QA.DATA.SCHEMES))
                    end))
                end)
                item.rename:SetOnClick(function()
                    TheFrontEnd:PushScreen(GetInputString(nil, LOCAL_STRINGS.BUTTON_TEXT_RENAME, data.name, function(val)
                        QA.DATA.SCHEMES[data.idx].name = val; QA.SaveData()
                        self:RefreshSchemeList(); self:RefreshScheme(data.idx)
                    end))
                end)
            end
        end
        return item
    end, sx + 100, -55, 200, 40, 1, 9))

    self.AddButton(sx + 100, -sy, 200, 40, LOCAL_STRINGS.BUTTON_TEXT_IMPORT_SCHEME, function()
        TheFrontEnd:PushScreen(GetInputString(nil, LOCAL_STRINGS.TITLE_TEXT_SCHEME_FILENAME, "", function(filename)
            if string.sub(filename, -5) ~= ".json" then return TheFrontEnd:PushScreen(ConfirmDialog(nil, LOCAL_STRINGS.JSON_NEEDED, function() end)) end
            local file = io.open("unsafedata/" .. filename)
            if file then
                local scheme = json.decode(file:read("*a")); file:close()
                if ValidateScheme(scheme) then
                    table.insert(QA.DATA.SCHEMES, scheme); QA.SaveData()
                    self:RefreshSchemeList(); self:RefreshScheme(#QA.DATA.SCHEMES)
                    return ThePlayer.components.talker:Say(LOCAL_STRINGS.MESSAGE_IMPORT_SUCCEED)
                end
            end
            ThePlayer.components.talker:Say(LOCAL_STRINGS.MESSAGE_IMPORT_FAILED)
        end))
    end)

    self.vertical_line = self.root:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
    self.vertical_line:SetRotation(90)
    self.vertical_line:SetScale(1, 0.57)

    sx = sx + 260
    self.title_text_editing = self.root:AddChild(Text(BODYTEXTFONT, 32))
    self.title_text_editing:SetPosition(sx + 300, sy)

    local function save_and_apply()
        QA.DATA.SCHEMES[self.scheme_idx] = DeepCopy(self.scheme)
        QA.DATA.CURRENT_SCHEME = QA.DATA.SCHEMES[self.scheme_idx]
        QA.SaveData(); QA.ApplyScheme(QA.DATA.CURRENT_SCHEME)
    end

    self.AddButton(sx + 300, -sy, 200, 40, LOCAL_STRINGS.BUTTON_TEXT_APPLY_SCHEME, function()
        TheFrontEnd:PushScreen(ConfirmDialog(nil, subfmt(LOCAL_STRINGS.TITLE_TEXT_SURE_TO_APPLY_SCHEME, { NAME = self.scheme.name }), function()
            QA.DATA.CURRENT_SCHEME = QA.DATA.SCHEMES[self.scheme_idx]
            QA.SaveData(); QA.ApplyScheme(QA.DATA.CURRENT_SCHEME)
        end))
    end)
    self.AddButton(sx + 100, -sy, 200, 40, LOCAL_STRINGS.BUTTON_TEXT_EXPORT_SCHEME, function()
        TheFrontEnd:PushScreen(GetInputString(nil, LOCAL_STRINGS.TITLE_TEXT_SCHEME_FILENAME, "", function(filename)
            if string.sub(filename, -5) ~= ".json" then return TheFrontEnd:PushScreen(ConfirmDialog(nil, LOCAL_STRINGS.JSON_NEEDED, function() end)) end
            local file = io.open("unsafedata/" .. filename, "w")
            if file then file:write(json.encode(QA.DATA.SCHEMES[self.scheme_idx])); file:close(); ThePlayer.components.talker:Say(LOCAL_STRINGS.MESSAGE_EXPORT_SUCCEED)
            else ThePlayer.components.talker:Say(LOCAL_STRINGS.MESSAGE_EXPORT_FAILED) end
        end))
    end)
    self.AddButton(sx + 500, -sy, 200, 40, LOCAL_STRINGS.BUTTON_TEXT_CLOSE, function() self:Close() end)

    self.root:AddChild(Text(BODYTEXTFONT, 32, LOCAL_STRINGS.TITLE_TEXT_FUNC)):SetPosition(sx + 60, sy - dy)

    self.func_list = self.root:AddChild(NoMuList(function()
        local item = MakeListItem("func-list-item", 120, 40)
        item.SetInfo = function(_, func)
            item.text:SetString(LOCAL_STRINGS.FUNC[func] or func)
            item.backing:SetOnClick(function() self:RefreshFunc(func) end)
        end
        return item
    end, sx + 60, -20, 120, 40, 1, 9))

    sx = sx + 160
    self.title_text_format = self.root:AddChild(Text(BODYTEXTFONT, 32))
    self.title_text_format:SetPosition(sx + 210, sy - dy)

    self.scheme_settings_root = self.root:AddChild(Widget("scheme_settings_root"))
    self.scheme_settings_root:SetPosition(sx + 210, 0)
    self.scheme_settings_root:Hide()

    local function get_scheme_affix_text(field, label_key, fallback)
        local val = self.scheme and self.scheme[field]
        local label = LOCAL_STRINGS[label_key] or ""
        return label .. tostring((val and val ~= "") and val or fallback)
    end

    self.btn_scheme_prefix = MakeCarnyButton(self.scheme_settings_root, -105, 40, 200, 42,
        function() return get_scheme_affix_text("custom_prefix", "BUTTON_TEXT_SCHEME_PREFIX", GLOBAL.STRINGS.LMB) end, 22,
        function()
            TheFrontEnd:PushScreen(GetInputString(nil, LOCAL_STRINGS.TITLE_SCHEME_PREFIX, self.scheme and self.scheme.custom_prefix or "", function(val)
                self.scheme.custom_prefix = (val and val ~= "") and val or nil
                save_and_apply()
                if self.btn_scheme_prefix then self.btn_scheme_prefix:SetText(get_scheme_affix_text("custom_prefix", "BUTTON_TEXT_SCHEME_PREFIX", GLOBAL.STRINGS.LMB)) end
            end, 30, 320))
        end
    )

    self.btn_scheme_suffix = MakeCarnyButton(self.scheme_settings_root, 105, 40, 200, 42,
        function() return get_scheme_affix_text("custom_suffix", "BUTTON_TEXT_SCHEME_SUFFIX", LOCAL_STRINGS.DEFAULT_VALUE_HINT) end, 22,
        function()
            TheFrontEnd:PushScreen(GetInputString(nil, LOCAL_STRINGS.TITLE_SCHEME_SUFFIX, self.scheme and self.scheme.custom_suffix or "", function(val)
                self.scheme.custom_suffix = (val and val ~= "") and val or nil
                save_and_apply()
                if self.btn_scheme_suffix then self.btn_scheme_suffix:SetText(get_scheme_affix_text("custom_suffix", "BUTTON_TEXT_SCHEME_SUFFIX", LOCAL_STRINGS.DEFAULT_VALUE_HINT)) end
            end, 30, 320))
        end
    )

    local hint_txt = self.scheme_settings_root:AddChild(Text(BODYTEXTFONT, 20, LOCAL_STRINGS.HINT_SCHEME_SETTINGS))
    hint_txt:SetPosition(0, -20)
    hint_txt:SetRegionSize(420, 50)
    hint_txt:SetColour(0.7, 0.7, 0.7, 1)
    hint_txt:EnableWordWrap(true)

    local function CreateSettingListItem(name, val_str_fn, action_title, save_cb_path, get_default_val_fn)
        local item = MakeListItem(name, 420, 40)
        item.text:SetRegionSize(360, 40); item.text:SetHAlign(ANCHOR_LEFT); item.text:SetPosition(-15, 0, 0)
        item.more_btn = MakeHoverBtn(item, "...", 26, 185, { 0.3, 0.7, 1, 1 }, { 1, 1, 1, 1 })
        BindHoverActions(item, { item.more_btn })

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
                        QA.SaveData()
                        if GLOBAL.ThePlayer and GLOBAL.ThePlayer.components.talker then
                            GLOBAL.ThePlayer.components.talker:Say(GLOBAL.subfmt(LOCAL_STRINGS.MESSAGE_COPY_FORMAT_SUCCEED, { NAME = target_scheme.name }))
                        end
                    end))
                end, function()
                    local builtins = QA.GetBuiltinSchemes and QA.GetBuiltinSchemes() or {}
                    local source_name = self.scheme.source_template or self.scheme.name
                    local source_data = GLOBAL.STRINGS.DEFAULT_NOMU_QA
                    for _, b in ipairs(builtins) do
                        if b.name == source_name then source_data = b.source; break end
                    end
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
        return CreateSettingListItem("format-list-item",
            function(d) return d.name .. ": " .. d.value end,
            function(d) return LOCAL_STRINGS.FUNC[self.scheme_func] .. "-" .. d.name end,
            function(d, val, target_scheme)
                EnsureTable(target_scheme or self.scheme, "data", self.scheme_func, "FORMATS")[d.name] = val
            end,
            function(d, source_data) return source_data[self.scheme_func] and source_data[self.scheme_func].FORMATS and source_data[self.scheme_func].FORMATS[d.name] end
        )
    end, sx + 210, sy - 3.5 * dy, 420, 40, 1, 3))

    self.btn_mapping = self.AddButton(sx + 210, sy - 5 * dy, 200, 40, LOCAL_STRINGS.BUTTON_TEXT_MAPPING, function()
        TheFrontEnd:PushScreen(CharacterPicker(nil, function(mapping)
            mapping = mapping:upper()
            local mappings = EnsureTable(self.scheme, "data", self.scheme_func, "MAPPINGS")
            if not mappings[mapping] then mappings[mapping] = DeepCopy(mappings.DEFAULT) end
            self:RefreshFunc(nil, mapping)
        end))
    end)
    if not QA.DATA.CHARACTER_SPECIFIC then self.btn_mapping:Disable() end

    self.mapping_list = self.root:AddChild(NoMuList(function()
        return CreateSettingListItem("mapping-list-item",
            function(d) return d.category .. "-" .. d.name .. ": " .. d.value end,
            function(d) return d.category .. "-" .. d.name end,
            function(d, val, target_scheme)
                EnsureTable(target_scheme or self.scheme, "data", self.scheme_func, "MAPPINGS", self.scheme_mapping, d.category)[d.name] = val
            end,
            function(d, source_data)
                local src_m = source_data[self.scheme_func] and source_data[self.scheme_func].MAPPINGS
                local cur_m = self.scheme.data[self.scheme_func] and self.scheme.data[self.scheme_func].MAPPINGS
                if self.scheme_mapping ~= "DEFAULT" then
                    local val = src_m and src_m[self.scheme_mapping] and src_m[self.scheme_mapping][d.category] and src_m[self.scheme_mapping][d.category][d.name]
                    if val then return val end
                    val = cur_m and cur_m.DEFAULT and cur_m.DEFAULT[d.category] and cur_m.DEFAULT[d.category][d.name]
                    if val then return val end
                end
                return src_m and src_m.DEFAULT and src_m.DEFAULT[d.category] and src_m.DEFAULT[d.category][d.name]
            end
        )
    end, sx + 210, sy - 8 * dy, 420, 40, 1, 5))

    self:RefreshSchemeList(); self:RefreshScheme(1)
end)

function QACustomizePanel:RefreshSchemeList()
    self.vertical_line:SetPosition(self.sx + (#QA.DATA.SCHEMES <= 9 and 220 or 230), 0)
    local sl = {}
    for idx, scheme in ipairs(QA.DATA.SCHEMES) do table.insert(sl, { idx = idx, name = scheme.name }) end
    self.scheme_list:Refresh(sl)
end

function QACustomizePanel:RefreshScheme(idx)
    self.scheme_idx = idx or self.scheme_idx
    self.scheme = DeepCopy(QA.DATA.SCHEMES[self.scheme_idx])
    self.title_text_editing:SetString(LOCAL_STRINGS.TITLE_TEXT_EDITING .. self.scheme.name)

    local fl = { "SETTINGS" }
    local added_funcs = { SETTINGS = true }
    if not self.scheme.data then self.scheme.data = {} end

    for _, func_info in ipairs(LOCAL_STRINGS.FUNC) do
        if func_info.id ~= "SETTINGS" and self.scheme.data[func_info.id] then
            table.insert(fl, func_info.id)
            added_funcs[func_info.id] = true
        end
    end
    for func_id in pairs(self.scheme.data) do
        if not added_funcs[func_id] then table.insert(fl, func_id) end
    end
    self.func_list:Refresh(fl); self:RefreshFunc(fl[1], "DEFAULT")
end

function QACustomizePanel:RefreshFunc(func, mapping)
    self.scheme_func = func or self.scheme_func

    if self.scheme_func == "SETTINGS" then
        self.title_text_format:SetString(LOCAL_STRINGS.TITLE_TEXT_SCHEME_SETTINGS)
        self.format_list:Hide(); self.btn_mapping:Hide(); self.mapping_list:Hide()
        if self.scheme_settings_root then
            self.scheme_settings_root:Show()
            local fallback = LOCAL_STRINGS.DEFAULT_VALUE_HINT
            if self.btn_scheme_prefix then
                local p = self.scheme and self.scheme.custom_prefix
                self.btn_scheme_prefix:SetText((LOCAL_STRINGS.BUTTON_TEXT_SCHEME_PREFIX or "") .. tostring((p and p ~= "") and p or fallback))
            end
            if self.btn_scheme_suffix then
                local sfx = self.scheme and self.scheme.custom_suffix
                self.btn_scheme_suffix:SetText((LOCAL_STRINGS.BUTTON_TEXT_SCHEME_SUFFIX or "") .. tostring((sfx and sfx ~= "") and sfx or fallback))
            end
        end
        return
    end

    if self.scheme_settings_root then self.scheme_settings_root:Hide() end
    self.format_list:Show()
    self.title_text_format:SetString(GLOBAL.subfmt(LOCAL_STRINGS.TITLE_TEXT_FORMAT, { NAME = LOCAL_STRINGS.FUNC[self.scheme_func] or self.scheme_func }))

    local fl, ml = {}, {}
    local func_data = self.scheme.data[self.scheme_func]
    if func_data and func_data.FORMATS then
        for name, format in pairs(func_data.FORMATS) do table.insert(fl, { name = name, value = format }) end
    end
    if func_data and func_data.MAPPINGS and func_data.MAPPINGS.DEFAULT then
        self.scheme_mapping = mapping or self.scheme_mapping
        if not func_data.MAPPINGS[self.scheme_mapping] then self.scheme_mapping = "DEFAULT" end
        self.mapping_list:Show(); self.btn_mapping:Show()
        self.btn_mapping:SetText(GLOBAL.subfmt(LOCAL_STRINGS.BUTTON_TEXT_MAPPING, {
            NAME = (self.scheme_mapping == "DEFAULT" and LOCAL_STRINGS.TITLE_TEXT_MAPPING_DEFAULT or STRINGS.NAMES[self.scheme_mapping] or self.scheme_mapping)
        }))
        for cat, items in pairs(func_data.MAPPINGS[self.scheme_mapping]) do
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

-- 快捷宣告主面板
local QAPanel = Class(Widget, function(self)
    local width, height = 860, 480
    local sy, dy = height / 2 - 20, 40
    self.sy, self.dy = sy, dy
    Widget._ctor(self, "QAPanel")

    self.root = self:AddChild(TEMPLATES.RectangleWindow(width, height + 10))
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetVAnchor(ANCHOR_MIDDLE)

    local function AddBtn(x, y, w, h, text, fn)
        return MakeCarnyButton(self.root, x, y, w, h, text, 26, fn)
    end

    local function AddToggleBtn(x, y, w, h, key, ton, toff)
        return MakeToggleButton(self.root, x, y, w, h, key, ton, toff)
    end

    self.root:AddChild(Text(BODYTEXTFONT, 32, LOCAL_STRINGS.TITLE_TEXT_QA)):SetPosition(0, sy)
    self.vertical_line = self.root:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
    self.vertical_line:SetRotation(90)
    self.vertical_line:SetScale(1, 0.45)
    self.vertical_line:SetPosition(0, 15)

    self.btn_new_freq = AddBtn(-320, sy - dy, 200, dy, LOCAL_STRINGS.BUTTON_TEXT_NEW_FREQ, function()
        TheFrontEnd:PushScreen(GetInputString(self, LOCAL_STRINGS.BUTTON_TEXT_NEW_FREQ, "", function(val)
            table.insert(QA.DATA.FREQ_LIST, val)
            QA.SaveData(); self:Refresh()
        end, 256, 420))
    end)

    self.btn_customize = AddBtn(-120, sy - dy, 200, dy, LOCAL_STRINGS.BUTTON_TEXT_CUSTOMIZE, function()
        TheFrontEnd:PushScreen(QACustomizePanel(self))
    end)

    self.freq_list = self.root:AddChild(NoMuList(function()
        local item = MakeListItem("freq-list-item", 200, 40)
        item.delete = MakeHoverBtn(item, LOCAL_STRINGS.BUTTON_TEXT_DELETE, 20, 80, { 1, 0, 0, 1 })
        BindHoverActions(item, { item.delete })

        item.SetInfo = function(_, data)
            item.text:SetString(data.freq)
            item.backing:SetOnClick(function()
                Announce(data.freq)
                if QA.DATA.FREQ_AUTO_CLOSE then self:Hide() end
            end)
            item.delete:SetOnClick(function()
                TheFrontEnd:PushScreen(ConfirmDialog(nil, LOCAL_STRINGS.TITLE_TEXT_SURE_TO_DELETE, function()
                    table.remove(QA.DATA.FREQ_LIST, data.idx)
                    QA.SaveData(); self:Refresh()
                end))
            end)
        end
        return item
    end, -220, 0, 200, 40, 2, 7))

    self.btn_word_manage = AddBtn(-330, -170, 195, dy, LOCAL_STRINGS.BUTTON_TEXT_WORD_MANAGE, function()
        TheFrontEnd:PushScreen(QAWordManagementPanel(self))
    end)

    local s = LOCAL_STRINGS
    local right_grid = {
        { type = "state",  key = "ALT_MODE", states = { 1, 2, 3 }, texts = { [1] = s.BUTTON_TEXT_ALT_MODE_1, [2] = s.BUTTON_TEXT_ALT_MODE_2, [3] = s.BUTTON_TEXT_ALT_MODE_3 } },
        { type = "state",  key = "SHIFT_MODE", states = { 1, 2, 3 }, texts = { [1] = s.BUTTON_TEXT_SHIFT_MODE_1, [2] = s.BUTTON_TEXT_SHIFT_MODE_2, [3] = s.BUTTON_TEXT_SHIFT_MODE_3 } },
        { type = "toggle", key = "BLOCK_ACTION", on = s.BUTTON_TEXT_BLOCK_ACTION_ON, off = s.BUTTON_TEXT_BLOCK_ACTION_OFF },
        { type = "toggle", key = "ANNOUNCE_ALL_MISSING_INGREDIENTS", on = s.BUTTON_TEXT_ANNOUNCE_ALL_MISSING_ON, off = s.BUTTON_TEXT_ANNOUNCE_ALL_MISSING_OFF },
        { type = "toggle", key = "DEFAULT_WHISPER", on = s.BUTTON_TEXT_DEFAULT_WHISPER_ON, off = s.BUTTON_TEXT_DEFAULT_WHISPER_OFF },
        { type = "toggle", key = "CHARACTER_SPECIFIC", on = s.BUTTON_TEXT_CHARACTER_SPECIFIC_ON, off = s.BUTTON_TEXT_CHARACTER_SPECIFIC_OFF },
        { type = "toggle", key = "FREQ_AUTO_CLOSE", on = s.BUTTON_TEXT_FREQ_AUTO_CLOSE_ON, off = s.BUTTON_TEXT_FREQ_AUTO_CLOSE_OFF },
        { type = "state",  key = "SHOW_ME", states = { 0, 1, 2 }, texts = { [0] = s.BUTTON_TEXT_SHOW_ME_OFF, [1] = s.BUTTON_TEXT_SHOW_ME_ON, [2] = s.BUTTON_TEXT_SHOW_ME_GIFT } },
        { type = "state",  key = "ANNOUNCE_RANGE", states = { 40, 60 }, texts = { [40] = s.BUTTON_TEXT_ANNOUNCE_RANGE_DEFAULT, [60] = s.BUTTON_TEXT_ANNOUNCE_RANGE_LARGE } },
        { type = "toggle", key = "FUZZY_ANNOUNCE", on = s.BUTTON_TEXT_FUZZY_ON, off = s.BUTTON_TEXT_FUZZY_OFF },
        { type = "state",  key = "SHOW_DISTANCE", states = { 0, 1, 2 }, texts = { [0] = s.BUTTON_TEXT_DISTANCE_OFF, [1] = s.BUTTON_TEXT_DISTANCE_ON, [2] = s.BUTTON_TEXT_DISTANCE_PRECISE } },
        { type = "toggle", key = "DISABLE_MEME_PREVIEW", on = s.BUTTON_TEXT_MEME_PREVIEW_ON, off = s.BUTTON_TEXT_MEME_PREVIEW_OFF },
        { type = "toggle", key = "SHOW_MOD_NAME", on = s.BUTTON_TEXT_SHOW_MOD_NAME_ON, off = s.BUTTON_TEXT_SHOW_MOD_NAME_OFF },
        { type = "toggle", key = "ENABLE_SPECIAL_STATE", on = s.BUTTON_TEXT_SPECIAL_STATE_ON, off = s.BUTTON_TEXT_SPECIAL_STATE_OFF },
        { type = "state",  key = "SHOW_ASSET_INFO", states = { 0, 1, 2 }, texts = { [0] = s.BUTTON_TEXT_SHOW_ASSET_OFF, [1] = s.BUTTON_TEXT_SHOW_ASSET_CODE, [2] = s.BUTTON_TEXT_SHOW_ASSET_ALL } },
        { type = "toggle", key = "DEBUG_MODE", on = s.BUTTON_TEXT_DEBUG_ON, off = s.BUTTON_TEXT_DEBUG_OFF },
    }

    self.grid_buttons = {}
    for r = 1, 8 do self.grid_buttons[r] = {} end

    local r_row, r_col = 1, 1
    for _, v in ipairs(right_grid) do
        local btn_x = (r_col == 1) and 120 or 320
        local btn_y = sy - r_row * dy
        local btn_w = v.w or 200
        local btn

        if v.type == "toggle" then
            btn = AddToggleBtn(btn_x, btn_y, btn_w, dy, v.key, v.on, v.off)
        elseif v.type == "state" then
            btn = AddBtn(btn_x, btn_y, btn_w, dy, function()
                local val = QA.DATA[v.key]
                if type(val) == "boolean" then val = val and 1 or 0 end
                return v.texts[val] or v.texts[v.states[1]]
            end, function()
                local cur = QA.DATA[v.key]
                if type(cur) == "boolean" then cur = cur and 1 or 0 end
                local next_val = v.states[1]
                for i, st in ipairs(v.states) do
                    if st == cur then next_val = v.states[(i % #v.states) + 1]; break end
                end
                QA.DATA[v.key] = next_val
                QA.SaveData()
            end)
        end

        if btn then self.grid_buttons[r_row][r_col] = btn end
        if r_col == 2 then r_row = r_row + 1; r_col = 1 else r_col = 2 end
    end

    self.btn_close = AddBtn(0, -sy, 200, dy, s.BUTTON_TEXT_CLOSE, function() self:Hide() end)
    self:Refresh()
end)

function QAPanel:Toggle()
    if self.shown then
        self:Hide()
    else
        self:Show()
    end
end

function QAPanel:GetActiveFreqButtons()
    local btns = {}
    local grid = self.freq_list and self.freq_list.scroll_lists
    if grid and grid.widgets_to_update then
        for _, w in ipairs(grid.widgets_to_update) do
            if w.data and w.nomu_list_item and w.nomu_list_item.backing and w.nomu_list_item.shown then
                table.insert(btns, w.nomu_list_item.backing)
            end
        end
    end
    return btns
end

function QAPanel:BuildAdjacencyMap()
    local map = {}
    local function Link(from, dir, to)
        if not from or not to then return end
        if not map[from] then map[from] = {} end
        map[from][dir] = to
    end

    local btn_new, btn_cust = self.btn_new_freq, self.btn_customize
    local btn_word, btn_close = self.btn_word_manage, self.btn_close
    local grid = self.grid_buttons
    local freq_btns = self:GetActiveFreqButtons()
    local has_freq = #freq_btns > 0
    local f1 = has_freq and freq_btns[1] or btn_word
    local f2 = (has_freq and freq_btns[2]) or f1

    Link(btn_new, GLOBAL.MOVE_RIGHT, btn_cust); Link(btn_new, GLOBAL.MOVE_DOWN, f1)
    Link(btn_new, GLOBAL.MOVE_UP, btn_close); Link(btn_new, GLOBAL.MOVE_LEFT, grid[1][2])

    Link(btn_cust, GLOBAL.MOVE_LEFT, btn_new); Link(btn_cust, GLOBAL.MOVE_RIGHT, grid[1][1])
    Link(btn_cust, GLOBAL.MOVE_DOWN, f2); Link(btn_cust, GLOBAL.MOVE_UP, btn_close)

    if has_freq then
        for i, b in ipairs(freq_btns) do
            Link(b, GLOBAL.MOVE_UP, i > 2 and freq_btns[i - 2] or ((i == 1) and btn_new or btn_cust))
            Link(b, GLOBAL.MOVE_DOWN, i + 2 <= #freq_btns and freq_btns[i + 2] or btn_word)
            local row_idx = math.min(8, math.ceil(i / 2) + 1)
            if i % 2 == 1 then
                Link(b, GLOBAL.MOVE_RIGHT, i + 1 <= #freq_btns and freq_btns[i + 1] or grid[row_idx][1])
                Link(b, GLOBAL.MOVE_LEFT, grid[row_idx][2])
            else
                Link(b, GLOBAL.MOVE_LEFT, freq_btns[i - 1])
                Link(b, GLOBAL.MOVE_RIGHT, grid[row_idx][1])
            end
        end
    end

    local last_f = has_freq and freq_btns[#freq_btns] or btn_new
    Link(btn_word, GLOBAL.MOVE_UP, last_f); Link(btn_word, GLOBAL.MOVE_DOWN, btn_close)
    Link(btn_word, GLOBAL.MOVE_RIGHT, grid[7][1]); Link(btn_word, GLOBAL.MOVE_LEFT, grid[7][2])

    Link(btn_close, GLOBAL.MOVE_UP, grid[8][1]); Link(btn_close, GLOBAL.MOVE_DOWN, btn_new)
    Link(btn_close, GLOBAL.MOVE_LEFT, btn_word); Link(btn_close, GLOBAL.MOVE_RIGHT, grid[8][2])

    for r = 1, 8 do
        local b1, b2 = grid[r][1], grid[r][2]
        Link(b1, GLOBAL.MOVE_RIGHT, b2); Link(b2, GLOBAL.MOVE_LEFT, b1)

        if has_freq and r >= 2 and r <= 7 then
            Link(b1, GLOBAL.MOVE_LEFT, freq_btns[math.min(#freq_btns, (r - 2) * 2 + 2)] or freq_btns[1])
        elseif r <= 2 then
            Link(b1, GLOBAL.MOVE_LEFT, btn_cust)
        else
            Link(b1, GLOBAL.MOVE_LEFT, btn_word)
        end

        if r <= 2 then
            Link(b2, GLOBAL.MOVE_RIGHT, btn_new)
        elseif r >= 7 then
            Link(b2, GLOBAL.MOVE_RIGHT, btn_word)
        else
            Link(b2, GLOBAL.MOVE_RIGHT, has_freq and freq_btns[1] or btn_new)
        end

        Link(b1, GLOBAL.MOVE_UP, r == 1 and btn_cust or grid[r - 1][1])
        Link(b1, GLOBAL.MOVE_DOWN, r == 8 and btn_close or grid[r + 1][1])
        Link(b2, GLOBAL.MOVE_UP, r == 1 and btn_close or grid[r - 1][2])
        Link(b2, GLOBAL.MOVE_DOWN, r == 8 and btn_close or grid[r + 1][2])
    end

    self._nav_map = map
    self.default_focus = (grid[1] and grid[1][1]) or btn_new
end

function QAPanel:Refresh()
    local fl = {}
    for idx, freq in ipairs(QA.DATA.FREQ_LIST or {}) do table.insert(fl, { idx = idx, freq = freq }) end
    self.freq_list:Refresh(fl)
    self:BuildAdjacencyMap()
end

function QAPanel:AcquireControllerLock()
    if not self._controller_locked then
        self._controller_locked = true
        if GLOBAL.ThePlayer and GLOBAL.ThePlayer.components.playercontroller then
            GLOBAL.ThePlayer.components.playercontroller:Enable(false)
        end
        if GLOBAL.TheCamera then GLOBAL.TheCamera:SetControllable(false) end
        local hud = GLOBAL.ThePlayer and GLOBAL.ThePlayer.HUD
        if hud and hud.SetModFocus then hud:SetModFocus("NOMU_QA", "QAPanel", true) end
        self:StartUpdating()
    end
end

function QAPanel:ReleaseControllerLock()
    if self.current_focus then self.current_focus:ClearFocus(); self.current_focus = nil end
    if self.focus then self:ClearFocus() end
    self._last_move_tick = nil
    self._last_click_tick = nil

    if self._controller_locked then
        self._controller_locked = false
        local hud = GLOBAL.ThePlayer and GLOBAL.ThePlayer.HUD
        if hud and hud.SetModFocus then hud:SetModFocus("NOMU_QA", "QAPanel", false) end
        if GLOBAL.ThePlayer and GLOBAL.ThePlayer.components.playercontroller then
            GLOBAL.ThePlayer.components.playercontroller:Enable(true)
        end
        if GLOBAL.TheCamera then GLOBAL.TheCamera:SetControllable(true) end
    end
    self:StopUpdating()
end

function QAPanel:OnUpdate()
    if self.shown and self._controller_locked and not GLOBAL.TheInput:ControllerAttached() then
        self:ReleaseControllerLock()
    end
end

function QAPanel:Show(...)
    Widget.Show(self, ...)
    self:Refresh()

    if GLOBAL.TheInput:ControllerAttached() then
        self:AcquireControllerLock()
        self.current_focus = self.default_focus
        if self.current_focus then self.current_focus:SetFocus() end

        for _, delay in ipairs({ 0.05, 0.15 }) do
            self.inst:DoTaskInTime(delay, function()
                if self.shown and GLOBAL.TheInput:ControllerAttached() and self.current_focus then
                    self.current_focus:SetFocus()
                end
            end)
        end
    else
        self:ReleaseControllerLock()
    end
end

function QAPanel:Hide(...)
    self:ReleaseControllerLock()
    Widget.Hide(self, ...)
end

function QAPanel:OnGainFocus()
    if not self._controller_locked then
        self.camera_controllable_reset = TheCamera:IsControllable()
        TheCamera:SetControllable(false)
    end
end

function QAPanel:OnLoseFocus()
    if not self._controller_locked then
        TheCamera:SetControllable(self.camera_controllable_reset ~= nil and self.camera_controllable_reset or true)
    end
end

local DIR_CONTROL_MAP = {
    [GLOBAL.CONTROL_FOCUS_UP] = GLOBAL.MOVE_UP,
    [GLOBAL.CONTROL_MOVE_UP] = GLOBAL.MOVE_UP,
    [GLOBAL.CONTROL_FOCUS_DOWN] = GLOBAL.MOVE_DOWN,
    [GLOBAL.CONTROL_MOVE_DOWN] = GLOBAL.MOVE_DOWN,
    [GLOBAL.CONTROL_FOCUS_LEFT] = GLOBAL.MOVE_LEFT,
    [GLOBAL.CONTROL_MOVE_LEFT] = GLOBAL.MOVE_LEFT,
    [GLOBAL.CONTROL_FOCUS_RIGHT] = GLOBAL.MOVE_RIGHT,
    [GLOBAL.CONTROL_MOVE_RIGHT] = GLOBAL.MOVE_RIGHT,
}

function QAPanel:OnControl(control, down)
    if not GLOBAL.TheInput:ControllerAttached() then
        if self._controller_locked then self:ReleaseControllerLock() end
        return QAPanel._base.OnControl(self, control, down)
    end

    if not self._controller_locked then self:AcquireControllerLock() end

    if not down and (control == GLOBAL.CONTROL_CANCEL or control == GLOBAL.CONTROL_PAUSE) then
        self:Hide()
        return true
    end

    if control == GLOBAL.CONTROL_ACCEPT or control == GLOBAL.CONTROL_PRIMARY
        or control == GLOBAL.CONTROL_ACTION or control == GLOBAL.CONTROL_CONTROLLER_ACTION then
        if down then return true end
        local tick = GLOBAL.TheSim:GetTick()
        if (tick - (self._last_click_tick or 0)) < 6 then return true end
        self._last_click_tick = tick

        local cur = self.current_focus
        if not cur or not IsChildOf(cur, self) then cur = self.default_focus end
        if cur and cur.IsEnabled and cur:IsEnabled() then
            if cur.OnClick then cur:OnClick() elseif cur.onclick then cur.onclick(cur) end
            PlayMoveSound()
        end
        return true
    end

    local dir = DIR_CONTROL_MAP[control]
    if dir ~= nil then
        if not down then return true end
        local tick = GLOBAL.TheSim:GetTick()
        if (tick - (self._last_move_tick or 0)) < 6 then return true end
        self._last_move_tick = tick

        local cur = self.current_focus
        if not cur or not IsChildOf(cur, self) then
            cur = self.default_focus
            if cur then self.current_focus = cur; cur:SetFocus(); PlayMoveSound() end
            return true
        end

        local next_target = self._nav_map and self._nav_map[cur] and self._nav_map[cur][dir]
        if next_target and next_target.IsEnabled and next_target:IsEnabled() then
            if cur ~= next_target then cur:ClearFocus() end
            self.current_focus = next_target
            next_target:SetFocus()
            PlayMoveSound()
        end
        return true
    end

    return true
end

QA.QAPanel = QAPanel

-- 聊天窗口表情菜单注入
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

HookEmojiMenu("widgets/writeablewidget", "writeable", function() return nil end)
HookEmojiMenu("screens/chatinputscreen", "chat", function(self) return self.chat_edit end)
HookEmojiMenu("widgets/redux/chatsidebar", "lobby_chat", function(self) return self.chatbox and self.chatbox.textbox end)