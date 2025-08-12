name = "Status Announcements (NoMu)"
author = "NoMu"
description = [[
- 修改自“快捷宣告 - Shang 完美汉化”（https://steamcommunity.com/sharedfiles/filedetails/?id=610528767）
- 兼容新版本的制作栏
- 只保留简体中文
- 对于同Prefab但显示名称不同的物品，宣告数量时分别计算
- 增加制作配方时需要“钓具容器”、“智囊团”等的提示
- 增加对暖石温度状态、月相、时钟、降水宣告的支持
- “shift + alt + 鼠标左键点击世界物品”宣告附近的物品
- “shift + alt + 鼠标右键”宣告坐标
- “shift + alt + 鼠标中键”宣告Ping
- 删除了自定义宣告语言的功能

FINISHED
旺达钟表CD
网络状况
打招呼
管理员
幸存天数
服务器信息
常用语
自定义
WX78电路和芯片宣告
没有皮肤时的宣告
皮肤数量宣告
人物头像
可疑的大理石
大理石雕像
人物角色
审视自我
装备了
技能树
保留原版宣告接口
地下时钟宣告
智能锅联动
食谱
兼容信息提示：礼物包装、暖石温度、食物剩余保鲜时间
]]
version = "0.8123.30"

folder_name = folder_name or "quick_announce_nomu"
if not folder_name:find("workshop-") then
    name = name .. " -dev"
end

api_version = 10

dst_compatible = true
priority = -10000001
all_clients_require_mod = false
client_only_mod = true
server_filter_tags = {}

icon_atlas = "modicon.xml"
icon = "modicon.tex"

local key_list = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12", "TAB", "CAPSLOCK", "LSHIFT", "RSHIFT", "LCTRL", "RCTRL", "LALT", "RALT", "ALT", "CTRL", "SHIFT", "SPACE", "ENTER", "ESCAPE", "MINUS", "EQUALS", "BACKSPACE", "PERIOD", "SLASH", "LEFTBRACKET", "BACKSLASH", "RIGHTBRACKET", "TILDE", "PRINT", "SCROLLOCK", "PAUSE", "INSERT", "HOME", "DELETE", "END", "PAGEUP", "PAGEDOWN", "UP", "DOWN", "LEFT", "RIGHT", "KP_DIVIDE", "KP_MULTIPLY", "KP_PLUS", "KP_MINUS", "KP_ENTER", "KP_PERIOD", "KP_EQUALS" }
local key_options = {}

for i = 1, #key_list do
    key_options[i] = { description = key_list[i], data = "KEY_" .. key_list[i] }
end

key_options[#key_list + 1] = {
    description = '-', data = 'KEY_MINUS'
}

configuration_options = {
    {
        name = "key_toggle",
        label = "快捷键（Shortcut）",
        options = key_options,
        default = "KEY_J",
    },
}
