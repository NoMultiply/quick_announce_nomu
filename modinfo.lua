name = "快捷宣告(NoMu)"
author = "NoMu，冰冰羊，THEDOG"
description = [[
- 修改自“快捷宣告 - Shang 完美汉化”（https://steamcommunity.com/sharedfiles/filedetails/?id=610528767）
- 兼容新版本的制作栏
- 只保留简体中文
- 对于同Prefab但显示名称不同的物品，宣告数量时分别计算
- 增加制作配方时需要“科学仪器”、“钓具容器”、“智囊团”等的提示
- 增加对暖石温度状态、月相、时钟、降水宣告的支持
- “shift + alt + 鼠标左键点击世界物品”宣告附近的物品
- “shift + alt + 鼠标中键”对自己宣告Ping、对别人打招呼、显示物品信息
- 添加了自定义宣告同步功能
]]

version = "2026-05-14-A"

folder_name = folder_name or "quick_announce_nomu"
if not folder_name:find("workshop-") then
    name = name .. " -dev"
end

api_version = 10

dst_compatible = true
priority = -2
all_clients_require_mod = false
client_only_mod = true
server_filter_tags = {}

icon_atlas = "modicon.xml"
icon = "modicon.tex"

local function AddOpt(desc, data, hover)
	return { description = desc, data = data, hover = hover }
end

local theKeys = {
	AddOpt("关闭", false),
	AddOpt("B", 98),
	AddOpt("C", 99),
	AddOpt("G", 103),
	AddOpt("H", 104),
	AddOpt("I", 105, "该项是饥荒检查自身皮肤的默认按键, 不怕冲突可以选"),
	AddOpt("J", 106),
	AddOpt("K", 107),
	AddOpt("L", 108),
	AddOpt("N", 110),
	AddOpt("O", 111),
	AddOpt("P", 112),
	AddOpt("R", 114),
	AddOpt("T", 116),
	AddOpt("V", 118),
	AddOpt("X", 120),
	AddOpt("Z", 122),
	AddOpt("减号-", 45, "该项是OB视角的默认键位, 使用此快捷键请关闭OB视角"),
	AddOpt("加号+", 61, "该项是OB视角的默认键位, 使用此快捷键请关闭OB视角"),
	AddOpt("鼠标 侧键A", 1005, "不同鼠标可能不生效"),
	AddOpt("鼠标 侧键B", 1006, "不同鼠标可能不生效"),
	AddOpt("关闭", false, " ↑↑↑ 上面不是有关闭按钮嘛 ↑↑↑ ,干嘛要在这里关"),
	AddOpt("<", 44, "小于号或者逗号"),
	AddOpt(">", 46, "大于号或者小数点"),
	AddOpt(":", 59, "冒号或者分号"),
	AddOpt("'", 39, "单引号或者双引号"),
	AddOpt("[", 91, "左括号"),
	AddOpt("]", 93, "右括号"),
	AddOpt("\\", 92, "右斜杠"),
	AddOpt("F1", 282),
	AddOpt("F2", 283),
	AddOpt("F3", 284),
	AddOpt("F4", 285),
	AddOpt("F5", 286),
	AddOpt("F6", 287),
	AddOpt("F7", 288),
	AddOpt("F8", 289),
	AddOpt("F9", 290),
	AddOpt("F10", 291),
	AddOpt("F11", 292),
	AddOpt("方向键(↑)", 273),
	AddOpt("方向键(↓)", 274),
	AddOpt("方向键(←)", 276),
	AddOpt("方向键(→)", 275),
	AddOpt("关闭", false, " ↑↑↑ 上面不是有关闭按钮嘛 ↑↑↑ ,干嘛要在这里关"),
	AddOpt("PageUp", 280, "PageUp"),
	AddOpt("PageDown", 281, "PageDown"),
	AddOpt("Home", 278, "Home"),
	AddOpt("Insert", 277, "Insert"),
	AddOpt("Delete", 127, "Delete"),
	AddOpt("End", 279, "End"),
	AddOpt("Pause", 19, "Pause"),
	AddOpt("Scroll Lock", 145, "Scroll Lock"),
	AddOpt("CAPSLOCK大写锁定", 301, "CAPSLOCK大写锁定"),
	AddOpt("左ALT", 308, "游戏默认的检查键, 请确保不冲突再使用此按键"),
	AddOpt("右ALT", 307, "游戏默认的检查键, 请确保不冲突再使用此按键"),
	AddOpt("左CTRL", 306, "左CTRL"),
	AddOpt("右CTRL", 305, "右CTRL"),
	AddOpt("左Shift", 304, "左Shift"),
	AddOpt("右Shift", 303, "右Shift"),
	AddOpt("小键盘0", 256, "小键盘0"),
	AddOpt("小键盘1", 257, "小键盘1"),
	AddOpt("小键盘2", 258, "小键盘2"),
	AddOpt("小键盘3", 259, "小键盘3"),
	AddOpt("小键盘4", 260, "小键盘4"),
	AddOpt("小键盘5", 261, "小键盘5"),
	AddOpt("小键盘6", 262, "小键盘6"),
	AddOpt("小键盘7", 263, "小键盘7"),
	AddOpt("小键盘8", 264, "小键盘8"),
	AddOpt("小键盘9", 265, "小键盘9"),
	AddOpt("小键盘 .", 266, "小键盘 ."),
	AddOpt("小键盘 /", 267, "小键盘 /"),
	AddOpt("小键盘 *", 268, "小键盘 *"),
	AddOpt("小键盘 -", 269, "小键盘 -"),
	AddOpt("小键盘 +", 270, "小键盘 +"),
	AddOpt("关闭", false, " ↑↑↑ 上面不是有关闭按钮嘛 ↑↑↑ ,干嘛要在这里关"),
}
local theBoardKeys = { AddOpt("功能面板", "biubiu", "将该功能在群鸟面板显示/需开启群鸟绘卷") }
for i = 2, #theKeys + 1 do
	theBoardKeys[i] = theKeys[i - 1]
end


configuration_options = {
    {
        name = "announcekey_toggle",
        label = "快捷键（Shortcut）",
        options = theBoardKeys,
		default = 106,
	}
}
