GLOBAL.setmetatable(env, { __index = function(_, k)
    return GLOBAL.rawget(GLOBAL, k)
end })

local function Import(modulename)
	local f = GLOBAL.kleiloadlua(modulename)
	if f and type(f) == "function" then
        setfenv(f, env.env)
        return f()
	end
end

Upvaluehelper = Import(MODROOT .. "scripts/bbgoat_upvaluehelper.lua") -- 使用Import而不是require，防止引用到其它模组的同名文件

local function IsDefaultScreen()
    local active_screen = GLOBAL.TheFrontEnd:GetActiveScreen()
    local screen = active_screen and active_screen.name or ""
    return screen:find("HUD") ~= nil and GLOBAL.ThePlayer ~= nil and not GLOBAL.ThePlayer.HUD:IsChatInputScreenOpen() and not GLOBAL.ThePlayer.HUD.writeablescreen and not
    (ThePlayer.HUD.controls and ThePlayer.HUD.controls.craftingmenu and ThePlayer.HUD.controls.craftingmenu.craftingmenu and ThePlayer.HUD.controls.craftingmenu.craftingmenu.search_box and ThePlayer.HUD.controls.craftingmenu.craftingmenu.search_box.textbox and ThePlayer.HUD.controls.craftingmenu.craftingmenu.search_box.textbox.editing)
end

modimport('scripts/qa_default.lua')
modimport('scripts/qa_utils.lua')

local DEFAULT_SCHEME = json.decode(json.encode(GLOBAL.STRINGS.DEFAULT_NOMU_QA))
local VERSION = 1
local SHOW_ME_ON = ModManager:GetMod("workshop-666155465") ~= nil or ModManager:GetMod("workshop-2287303119") ~= nil

-- 数据 --
GLOBAL.NOMU_QA = {
    DATA = {
        DEFAULT_WHISPER = false,
        CHARACTER_SPECIFIC = true,
        FREQ_AUTO_CLOSE = true,
        SHOW_ME = 1,
        FREQ_LIST = {
            STRINGS.NOMU_QA.FREQ_EXAMPLE
        },
        SCHEMES = {
            { name = STRINGS.NOMU_QA.TITLE_TEXT_DEFAULT_SCHEME, data = json.decode(json.encode(GLOBAL.STRINGS.DEFAULT_NOMU_QA)), version = VERSION }
        },
        CURRENT_SCHEME = { name = STRINGS.NOMU_QA.TITLE_TEXT_DEFAULT_SCHEME, data = DEFAULT_SCHEME, version = VERSION }
    },
    SCHEME = DEFAULT_SCHEME
}

-- GLOBAL.NOMU_QA.UpdateScheme = function(scheme)
--     for func, func_value in pairs(GLOBAL.STRINGS.DEFAULT_NOMU_QA) do
--         if not scheme[func] then
--             scheme[func] = json.decode(json.encode(func_value))
--         else
--             for format, format_value in pairs(func_value.FORMATS) do
--                 if not scheme[func].FORMATS[format] then
--                     scheme[func].FORMATS[format] = format_value
--                 end
--             end
--             if func_value.MAPPINGS.DEFAULT then
--                 for mapping, mapping_value in pairs(func_value.MAPPINGS.DEFAULT) do
--                     for _, character_value in scheme[func].MAPPINGS do
--                         if not character_value[mapping] then
--                             character_value[mapping] = json.decode(json.encode(mapping_value))
--                         else
--                             for item, item_value in pairs(mapping_value) do
--                                 if not character_value[mapping][item] then
--                                     character_value[mapping][item] = item_value
--                                 end
--                             end
--                         end
--                     end
--                 end
--                 if not scheme[func].MAPPINGS.DEFAULT then
--                     scheme[func].MAPPINGS.DEFAULT = json.decode(json.encode(func_value.MAPPINGS.DEFAUL))
--                 end
--             end
--         end
--     end
-- end

GLOBAL.NOMU_QA.ApplyScheme = function(scheme)
    --GLOBAL.NOMU_QA.UpdateScheme(scheme)
    GLOBAL.NOMU_QA.SCHEME = scheme.data
end

local DATA_FILE = 'mod_config_data/nomu_quick_announce'

GLOBAL.NOMU_QA.LoadData = function()
    TheSim:GetPersistentString(DATA_FILE, function(load_success, str)
        if load_success and #str > 0 then
            local run_success, data = RunInSandboxSafe(str)
            if run_success then
                for k, v in pairs(data) do
                    if v ~= nil then
                        GLOBAL.NOMU_QA.DATA[k] = v
                    end
                end
            end
        end
    end)
    GLOBAL.NOMU_QA.ApplyScheme(GLOBAL.NOMU_QA.DATA.CURRENT_SCHEME)
end

GLOBAL.NOMU_QA.SaveData = function()
    SavePersistentString(DATA_FILE, DataDumper(GLOBAL.NOMU_QA.DATA, nil, true), false, nil)
end

AddSimPostInit(function()
    GLOBAL.NOMU_QA.LoadData()
end)

-- 宣告消息
local function Announce(message, no_whisper)
    message = message:gsub("(%d)\176([CF）])", "%1°%2") -- 修复无法宣告暖石温度的问题 show me用的 ° 是 \176 这个玩意无法被Say出来
    local whisper = GLOBAL.NOMU_QA.DATA.DEFAULT_WHISPER ~= TheInput:IsKeyDown(KEY_LCTRL)
    if no_whisper then
        whisper = false
    end
    TheNet:Say(STRINGS.LMB .. ' ' .. message, whisper)
    return true
end

local function GetMapping(qa, category, key)
    local prefab = ThePlayer.prefab:upper()
    return GLOBAL.NOMU_QA.DATA.CHARACTER_SPECIFIC and qa.MAPPINGS[prefab] and qa.MAPPINGS[prefab][category] and qa.MAPPINGS[prefab][category][key] or qa.MAPPINGS.DEFAULT[category][key]
end

local function AnnounceBadge(qa, current, max, category)
    local fmts = {
        CURRENT = math.floor(current + 0.5),
        MAX = max,
        MESSAGE = GetMapping(qa, 'MESSAGE', category)
    }
    if GetMapping(qa, 'SYMBOL', 'EMOJI') and TheInventory:CheckOwnership('emoji_' .. GetMapping(qa, 'SYMBOL', 'EMOJI')) then
        fmts.SYMBOL = ':' .. GetMapping(qa, 'SYMBOL', 'EMOJI') .. ':'
    else
        fmts.SYMBOL = GetMapping(qa, 'SYMBOL', 'TEXT')
    end
    return Announce(subfmt(qa.FORMATS.DEFAULT, fmts))
end

-- 处理“shift + alt + 鼠标左键”
local function OnHUDMouseButton(HUD)
    local status = HUD.controls.status
    local default_thresholds = { .15, .35, .55, .75 }
    local levels = { 'EMPTY', 'LOW', 'MID', 'HIGH', 'FULL' }
    local function get_category(thresholds, percent)
        local i = 1
        while thresholds[i] ~= nil and percent >= thresholds[i] do
            i = i + 1
        end
        return i
    end

    -- 饱食度
    if status.stomach and status.stomach.focus then
        local qa = GLOBAL.NOMU_QA.SCHEME.STOMACH
        local current = ThePlayer.player_classified.currenthunger:value()
        local max = ThePlayer.player_classified.maxhunger:value()
        local category = levels[get_category(default_thresholds, current / max)]
        return AnnounceBadge(qa, current, max, category)
    end

    -- 精神值
    if status.brain and status.brain.focus then
        local qa = GLOBAL.NOMU_QA.SCHEME.SANITY
        local current = ThePlayer.player_classified.currentsanity:value()
        local max = ThePlayer.player_classified.maxsanity:value()
        local category = levels[get_category(default_thresholds, current / max)]
        return AnnounceBadge(qa, current, max, category)
    end

    -- 生命值
    if status.heart and status.heart.focus then
        local qa = GLOBAL.NOMU_QA.SCHEME.HEALTH
        local current = ThePlayer.player_classified.currenthealth:value()
        local max = ThePlayer.player_classified.maxhealth:value()
        local category = levels[get_category({ .25, .5, .75, 1 }, current / max)]
        return AnnounceBadge(qa, current, max, category)
    end

    -- 潮湿度
    if status.moisturemeter and status.moisturemeter.focus then
        local qa = GLOBAL.NOMU_QA.SCHEME.WETNESS
        local current = ThePlayer.player_classified.moisture:value()
        local max = ThePlayer.player_classified.maxmoisture:value()
        local category = levels[get_category(default_thresholds, current / max)]
        return AnnounceBadge(qa, current, max, category)
    end

    -- 木头值
    if status.wereness and status.wereness.focus then
        local qa = GLOBAL.NOMU_QA.SCHEME.LOG_METER
        local max = 100
        local current = ThePlayer.player_classified.currentwereness:value()
        local category = levels[get_category({ .25, .5, .7, .9 }, current / max)]
        return AnnounceBadge(qa, current, max, category)
    end

    -- 人物温度
    if status.temperature and status.temperature.focus then
        local qa = GLOBAL.NOMU_QA.SCHEME.TEMPERATURE
        local temp = ThePlayer:GetTemperature()
        local fmts = {
            TEMPERATURE = string.format('%d', temp),
            MESSAGE = GetMapping(qa, 'MESSAGE', 'GOOD')
        }
        if temp >= TUNING.OVERHEAT_TEMP then
            fmts.MESSAGE = GetMapping(qa, 'MESSAGE', 'BURNING')
        elseif temp >= TUNING.OVERHEAT_TEMP - 5 then
            fmts.MESSAGE = GetMapping(qa, 'MESSAGE', 'HOT')
        elseif temp >= TUNING.OVERHEAT_TEMP - 15 then
            fmts.MESSAGE = GetMapping(qa, 'MESSAGE', 'WARM')
        elseif temp <= 0 then
            fmts.MESSAGE = GetMapping(qa, 'MESSAGE', 'FREEZING')
        elseif temp <= 5 then
            fmts.MESSAGE = GetMapping(qa, 'MESSAGE', 'COLD')
        elseif temp <= 15 then
            fmts.MESSAGE = GetMapping(qa, 'MESSAGE', 'COOL')
        end
        return Announce(subfmt(qa.FORMATS.DEFAULT, fmts))
    end

    -- 世界温度和降雨
    if status.worldtemp and status.worldtemp.focus then
        local SEASON = GLOBAL.STRINGS.UI.SERVERLISTINGSCREEN.SEASONS[TheWorld.state.season:upper()]
        if SEASON == '春' or SEASON == '夏' or SEASON == '秋' or SEASON == '冬' then
            SEASON = SEASON .. '季'
        end

        local qa = GLOBAL.NOMU_QA.SCHEME.WORLD_TEMPERATURE_AND_RAIN
        local fmts = {
            TEMPERATURE = math.floor(TheWorld.state.temperature + 0.5),
            SEASON = SEASON,
            WEATHER = GetMapping(qa, 'WEATHER', TheWorld.state.season:upper())
        }
        local qa_fmt = qa.FORMATS.NO_RAIN
        if TheWorld.state.pop ~= 1 then
            local world, total_seconds, rain = GLOBAL.QA_UTILS.PredictRainStart()
            fmts.WORLD = GetMapping(qa, 'WORLD', world)
            if rain then
                fmts.DAYS, fmts.MINUTES, fmts.SECONDS = GLOBAL.QA_UTILS.FormatSeconds(total_seconds)
                qa_fmt = qa.FORMATS.START_RAIN
            end
        else
            local world, total_seconds = GLOBAL.QA_UTILS.PredictRainStop()
            fmts.WORLD = GetMapping(qa, 'WORLD', world)
            fmts.DAYS, fmts.MINUTES, fmts.SECONDS = GLOBAL.QA_UTILS.FormatSeconds(total_seconds)
            qa_fmt = qa.FORMATS.STOP_RAIN
        end
        return Announce(subfmt(qa_fmt, fmts))
    end

    -- 季节
    if HUD.controls.seasonclock and HUD.controls.seasonclock.focus or status.season and status.season.focus then
        local SEASON = GLOBAL.STRINGS.UI.SERVERLISTINGSCREEN.SEASONS[TheWorld.state.season:upper()]
        if SEASON == '春' or SEASON == '夏' or SEASON == '秋' or SEASON == '冬' then
            SEASON = SEASON .. '季'
        end

        local DAYS_LEFT = TheWorld.state.remainingdaysinseason
        if DAYS_LEFT == 10000 then DAYS_LEFT = "∞" end

        return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.SEASON.FORMATS.DEFAULT, {
            SEASON = SEASON,
            DAYS_LEFT = DAYS_LEFT,
        }))
    end

    -- 月相
    if HUD.controls.clock and HUD.controls.clock._moonanim and HUD.controls.clock._moonanim.focus and HUD.controls.clock._moonanim.moontext then
        local qa = GLOBAL.NOMU_QA.SCHEME.MOON_PHASE
        if string.find(tostring(HUD.controls.clock._moonanim.moontext), '?') ~= nil then
            ThePlayer.components.talker:Say(qa.FORMATS.FAILED)
            return
        end
        local moonment = string.match(tostring(HUD.controls.clock._moonanim.moontext), '(%d+)') or 0
        if moonment == 0 then
            return
        end
        local worldment = TheWorld.state.cycles + 1 or 0
        if worldment == 0 then
            return
        end
        local fmts = {
            INTERVAL = GetMapping(qa, 'INTERVAL', 'COMMA')
        }
        local moonleft = moonment - worldment

        if moonleft >= 10 then
            fmts.PHASE1 = GetMapping(qa, 'MOON', 'FULL')
            fmts.PHASE2 = GetMapping(qa, 'MOON', 'NEW')
        else
            fmts.PHASE1 = GetMapping(qa, 'MOON', 'NEW')
            fmts.PHASE2 = GetMapping(qa, 'MOON', 'FULL')
        end

        local judge = moonleft % 10
        if judge <= 1 then
            if judge == 0 then
                fmts.RECENT = GetMapping(qa, 'RECENT', 'TODAY')
            else
                fmts.RECENT = GetMapping(qa, 'RECENT', 'TOMORROW')
            end
            judge = judge + 10
            fmts.PHASE1, fmts.PHASE2 = fmts.PHASE2, fmts.PHASE1
            if worldment < 20 then
                return Announce(subfmt(qa.FORMATS.MOON, fmts))
            end
        elseif judge >= 8 then
            fmts.RECENT = GetMapping(qa, 'RECENT', 'AFTER')
        else
            fmts.RECENT = ''
            fmts.PHASE1 = ''
            fmts.INTERVAL = GetMapping(qa, 'INTERVAL', 'NONE')
        end
        fmts.LEFT = judge
        return Announce(subfmt(qa.FORMATS.DEFAULT, fmts))
    end

    -- 时钟
    if HUD.controls.clock and HUD.controls.clock.focus then
        local clock = TheWorld.net.components.clock
        if clock and clock._remainingtimeinphase and clock._phase and clock.CalcRemainTimeOfDay then
            local qa = GLOBAL.NOMU_QA.SCHEME.CLOCK
            local phases = { 'DAY', 'DUSK', 'NIGHT' }
            local function _format_time(seconds)
                local minutes = math.modf(seconds / 60)
                seconds = math.modf(math.fmod(seconds, 60))
                local message = ''
                if minutes > 0 then
                    message = message .. tostring(minutes) .. GetMapping(qa, 'TIME', 'MINUTES')
                end
                message = message .. tostring(seconds) .. GetMapping(qa, 'TIME', 'SECONDS')
                return message
            end

            local fmt = qa.FORMATS.DEFAULT
            local fmts = {
                PHASE = GetMapping(qa, 'PHASE', phases[clock._phase:value()]),
                PHASE_REMAIN = _format_time(clock._remainingtimeinphase:value()),
                DAY_REMAIN = _format_time(clock.CalcRemainTimeOfDay())
            }

            if TheWorld.GetNightmareData then
                local data = TheWorld:GetNightmareData()
                fmt = data.remain == 0 and data.total ~= 0 and qa.FORMATS.NIGHTMARE_LOCK or qa.FORMATS.NIGHTMARE
                fmts.NIGHTMARE = GetMapping(qa, 'NIGHTMARE', data.phase:upper())
                fmts.REMAIN = _format_time(data.remain)
                fmts.TOTAL = _format_time(data.total)
            end

            return Announce(subfmt(fmt, fmts))
        end
    end

    -- 船生命值
    if status.boatmeter and status.boatmeter.focus then
        local qa = GLOBAL.NOMU_QA.SCHEME.BOAT
        local health = { 'EMPTY', 'LOW', 'MID', 'HIGH', 'FULL' }
        local max = status.boatmeter.boat.components.healthsyncer.max_health
        local step = max / 5 + 1
        local current = status.boatmeter.boat.components.healthsyncer:GetPercent() * max
        local idx = math.floor(current / step) + 1
        return Announce(subfmt(qa.FORMATS.DEFAULT, {
            CURRENT = math.floor(current + 0.5),
            MAX = max,
            MESSAGE = GetMapping(qa, 'MESSAGE', health[idx])
        }))
    end

    -- 温蒂：阿比盖尔
    if status.pethealthbadge and status.pethealthbadge.focus then
        local badge = status.pethealthbadge
        if not badge.nomu_max or not badge.nomu_percent then
            return
        end
        local qa = GLOBAL.NOMU_QA.SCHEME.ABIGAIL
        local max = badge.nomu_max
        local current = badge.nomu_percent * max
        local step = max / 5 + 1
        local idx = math.floor(current / step) + 1

        return AnnounceBadge(qa, current, max, levels[idx])
    end

    -- 沃尔夫冈：力量值
    if status.mightybadge and status.mightybadge.focus then
        local badge = status.mightybadge
        if not badge.nomu_percent then
            return
        end
        local qa = GLOBAL.NOMU_QA.SCHEME.MIGHTINESS
        badge.nomu_max = badge.nomu_max or 100
        local mightiness_levels = { 'WIMPY', 'NORMAL', 'MIGHTY' }
        local max = badge.nomu_max
        local current = badge.nomu_percent * max
        local idx = 1
        if current >= TUNING.MIGHTY_THRESHOLD then
            idx = 3
        elseif current >= TUNING.WIMPY_THRESHOLD then
            idx = 2
        end

        return AnnounceBadge(qa, current, max, mightiness_levels[idx])
    end

    -- 薇格弗德：灵感值
    if status.inspirationbadge and status.inspirationbadge.focus then
        local badge = status.inspirationbadge
        if not badge.nomu_percent then
            return
        end
        local qa = GLOBAL.NOMU_QA.SCHEME.INSPIRATION
        badge.nomu_max = badge.nomu_max or 100
        local max = badge.nomu_max
        local current = badge.nomu_percent * max
        local idx = 1
        if badge.nomu_percent >= TUNING.BATTLESONG_THRESHOLDS[3] then
            idx = 4
        elseif badge.nomu_percent >= TUNING.BATTLESONG_THRESHOLDS[2] then
            idx = 3
        elseif badge.nomu_percent >= TUNING.BATTLESONG_THRESHOLDS[1] then
            idx = 2
        end

        return AnnounceBadge(qa, current, max, levels[idx])
    end

    -- WX78: 能量值
    if HUD.controls.secondary_status and HUD.controls.secondary_status.upgrademodulesdisplay and HUD.controls.secondary_status.upgrademodulesdisplay.focus then
        local qa = GLOBAL.NOMU_QA.SCHEME.ENERGY
        local widget = HUD.controls.secondary_status.upgrademodulesdisplay
        local current = widget.energy_level
        local energy_levels = { 'ZERO', 'ONE', 'TWO', 'THREE', 'FOUR', 'FIVE', 'SIX' }
        local fmts = {
            CURRENT = math.floor(current + 0.5),
            MAX = TUNING.WX78_MAXELECTRICCHARGE,
            USED = widget.slots_in_use,
            MESSAGE = GetMapping(qa, 'MESSAGE', energy_levels[current + 1])
        }
        return Announce(subfmt(qa.FORMATS.DEFAULT, fmts))
    end

    --烹饪锅
    if HUD.controls and HUD.controls.foodcrafting and HUD.controls.foodcrafting.focus then
        local qa = GLOBAL.NOMU_QA.SCHEME.COOK
        if HUD.controls.foodcrafting.focusItem and HUD.controls.foodcrafting.focusItem.focus then
            local recipe = HUD.controls.foodcrafting.focusItem.recipe
            local popup = HUD.controls.foodcrafting.focusItem.recipepopup
            local name = STRINGS.NAMES[string.upper(recipe.name)] or recipe.name
            if popup and popup.focus then
                local fmts = {
                    TYPE = GetMapping(qa, 'TYPE', 'POS'),
                    NAME = name
                }
                local fmt
                local value
                if popup.health and popup.health.focus then
                    value = recipe.health
                    fmt = qa.FORMATS.HEALTH
                end
                if popup.sanity and popup.sanity.focus then
                    value = recipe.sanity
                    fmt = qa.FORMATS.SANITY
                end
                if popup.hunger and popup.hunger.focus then
                    value = recipe.hunger
                    fmt = qa.FORMATS.HUNGER
                end
                if value then
                    if type(value) == 'number' and value < 0 then
                        fmts.TYPE = GetMapping(qa, 'TYPE', 'NEG')
                        value = -value
                    end
                    fmts.VALUE = not recipe.unlocked and '?' or type(value) == 'number' and value ~= 0 and string.format("%g", (math.floor(value * 10 + 0.5) / 10)) or '-'
                    return Announce(subfmt(fmt, fmts))
                end
                if popup.name and popup.name.focus and popup.hunger and popup.sanity and popup.health then
                    return Announce(subfmt(qa.FORMATS.FOOD, {
                        NAME = name, HUNGER = popup.hunger:GetString(), SANITY = popup.sanity:GetString(), HEALTH = popup.health:GetString()
                    }))
                end
                if popup.ingredients then
                    for _, ingredient in ipairs(popup.ingredients) do
                        if ingredient.focus then
                            return Announce(subfmt(qa.FORMATS[ingredient.is_min and 'MIN_INGREDIENT' or ingredient.quantity > 0 and 'MAX_INGREDIENT' or 'ZERO_INGREDIENT'], {
                                NAME = name, INGREDIENT = ingredient.localized_name, NUM = ingredient.quantity
                            }))
                        end
                    end
                end
            else
                if (recipe.readytocook or recipe.reqsmatch) and recipe.unlocked then
                    return Announce(subfmt(qa.FORMATS.CAN, { NAME = name }))
                else
                    return Announce(subfmt(qa.FORMATS.NEED, { NAME = name }))
                end
            end
        end
    end
end

-- WX78：芯片
local GetModuleDefinitionFromNetID = require("wx78_moduledefs").GetModuleDefinitionFromNetID
AddClassPostConstruct('widgets/upgrademodulesdisplay', function(UpgradeModulesDisplay)
    local oldOnModuleAdded = UpgradeModulesDisplay.OnModuleAdded
    function UpgradeModulesDisplay:OnModuleAdded(moduledefinition_index, ...)
        oldOnModuleAdded(self, moduledefinition_index, ...)
        local module_def = GetModuleDefinitionFromNetID(moduledefinition_index)
        if module_def == nil then
            return
        end
        local modname = module_def.name
        local new_chip = self.chip_objectpool[self.chip_poolindex - 1]
        new_chip.modname = modname
    end

    for _, chip in ipairs(UpgradeModulesDisplay.chip_objectpool) do
        local oldOnControl = chip.OnControl
        function chip:OnControl(control, down, ...)
            if down and control == GLOBAL.CONTROL_ACCEPT and TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then
                local name = self.modname
                local num = 0
                for _idx, _chip in ipairs(UpgradeModulesDisplay.chip_objectpool) do
                    if _idx < UpgradeModulesDisplay.chip_poolindex and _chip.modname == name then
                        num = num + 1
                    end
                end
                return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.ENERGY.FORMATS.CHIP, { ITEM = STRINGS.NAMES['WX78MODULE_' .. name:upper()], NUM = num }))
            elseif not TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then
                return oldOnControl(self, control, down, ...)
            end
        end
    end
end)

local needs_strings = {
    NEEDSCIENCEMACHINE = "RESEARCHLAB",
    NEEDALCHEMYENGINE = "RESEARCHLAB2",
    NEEDSHADOWMANIPULATOR = "RESEARCHLAB3",
    NEEDPRESTIHATITATOR = "RESEARCHLAB4",
    NEEDSANCIENT_FOUR = "ANCIENT_ALTAR",
    NEEDSFISHING = STRINGS.NOMU_QA.FISHING,
    NEEDCARNIVAL_HOSTSHOP_PLAZA = STRINGS.NOMU_QA.CARNIVAL_HOST_SHOP_PLAZA,
    NEEDSSEAFARING_STATION = STRINGS.NOMU_QA.SEAFARING_STATION,
    NEEDSSPIDERFRIENDSHIP = STRINGS.NOMU_QA.SPIDER_FRIENDSHIP,
}

local hint_text = {
    ["NEEDSSCIENCEMACHINE"] = "NEEDSCIENCEMACHINE",
    ["NEEDSALCHEMYMACHINE"] = "NEEDALCHEMYENGINE",
    ["NEEDSSHADOWMANIPULATOR"] = "NEEDSHADOWMANIPULATOR",
    ["NEEDSPRESTIHATITATOR"] = "NEEDPRESTIHATITATOR",
    ["NEEDSANCIENTALTAR_HIGH"] = "NEEDSANCIENT_FOUR",
    ["NEEDSSPIDERCRAFT"] = "NEEDSSPIDERFRIENDSHIP",
}

local function GetPrototype(knows, recipe, owner)
    local prototyper
    if not knows then
        local details = ThePlayer.HUD.controls.craftingmenu.craftingmenu.details_root
        local prototyper_tree = details:_GetHintTextForRecipe(owner, recipe)
        local str = STRINGS.UI.CRAFTING[hint_text[prototyper_tree] or prototyper_tree]
        local CRAFTING = STRINGS.UI.CRAFTING
        for needs_string, prototyper_prefab in pairs(needs_strings) do
            if str == CRAFTING[needs_string] then
                prototyper = STRINGS.NAMES[prototyper_prefab] or prototyper_prefab
            end
        end
        prototyper = prototyper or STRINGS.NOMU_QA.UNKNOWN_PROTOTYPE
    end
    return prototyper or ''
end

local function AnnounceSkin(recipepopup)
    if not recipepopup.focus then
        return
    end
    local skin_name = recipepopup.skins_spinner and recipepopup.skins_spinner.GetItem()
    if skin_name == nil then
        skin_name = recipepopup.GetItem and recipepopup:GetItem()
    end
    local qa = GLOBAL.NOMU_QA.SCHEME.SKIN
    local item_name = STRINGS.NAMES[string.upper(recipepopup.recipe.product)] or recipepopup.recipe.name
    if skin_name == nil then
        local n_options = #recipepopup.skins_options
        if n_options == 1 then
            local prefab = recipepopup.recipe.product or recipepopup.recipe.name
            if not PREFAB_SKINS[prefab] or #PREFAB_SKINS[prefab] == 0 then
                return Announce(subfmt(qa.FORMATS.NO_SKIN, { ITEM = item_name }))
            else
                return Announce(subfmt(qa.FORMATS.HAS_NO_SKIN, { ITEM = item_name }))
            end
        end
        return
    end
    if skin_name ~= item_name then
        local prefab = recipepopup.recipe.product or recipepopup.recipe.name
        local num = #recipepopup.skins_options - 1
        local total = PREFAB_SKINS[prefab] and #PREFAB_SKINS[prefab] or num
        return Announce(subfmt(qa.FORMATS.DEFAULT, { SKIN = GetSkinName(skin_name), ITEM = item_name, NUM = num, TOTAL = total }))
    end
end

local function AnnounceRecipePinSlot(slot, recipepopup, ingnum)
    local recipe = slot.craftingmenu:GetRecipeState(slot.recipe_name)
    if not recipe or not recipe.recipe then
        return
    end
    recipe = recipe.recipe
    local builder = slot.owner.replica.builder
    local buffered = builder:IsBuildBuffered(recipe.name)
    local knows = builder:KnowsRecipe(recipe.name) or CanPrototypeRecipe(recipe.level, builder:GetTechTrees())
    local can_build = builder:CanBuild(recipe.name)
    local strings_name = STRINGS.NAMES[recipe.product:upper()] or STRINGS.NAMES[recipe.name:upper()]
    local name = strings_name and strings_name:lower() or STRINGS.NOMU_QA.UNKNOWN_NAME

    local ingredient
    recipepopup = recipepopup or slot.recipe_popup
    local ing = recipepopup.ing
    if ing == nil then
        ing = {}
        local ingredients
        if not recipepopup or not recipepopup.ingredients or not recipepopup.ingredients.children then
            return
        end
        for _, v in pairs(recipepopup.ingredients.children) do
            ingredients = v
            break
        end
        if ingredients ~= nil then
            for _, v in pairs(ingredients.children) do
                table.insert(ing, v)
            end
        end
    end
    if ingnum == nil then
        for _, _ing in ipairs(ing) do
            if _ing.focus then
                ingredient = _ing
            end
        end
    else
        ingredient = ing[ingnum]
    end
    if ingnum and ingredient == nil then
        return
    end

    local prototype = GetPrototype(knows, recipe, slot.owner)

    if ingredient == nil then
        local fmts = {
            ITEM = name,
            PROTOTYPE = prototype
        }
        local qa = GLOBAL.NOMU_QA.SCHEME.RECIPE
        if buffered then
            return Announce(subfmt(qa.FORMATS.BUFFERED, fmts))
        elseif can_build and knows then
            return Announce(subfmt(qa.FORMATS.WILL_MAKE, fmts))
        elseif knows then
            return Announce(subfmt(qa.FORMATS.WE_NEED, fmts))
        else
            return Announce(subfmt(qa.FORMATS.CAN_SOMEONE, fmts))
        end
    else
        local num = 0
        local ingname
        local ingtooltip
        if ingredient.ing then
            ingname = ingredient.ing.texture:sub(1, -5)
            ingtooltip = ingredient.tooltip
        else
            ingname = recipepopup.recipe.ingredients[1].type
            ingtooltip = STRINGS.NAMES[string.upper(ingname)]
        end
        local amount_needed = 1
        for _, v in pairs(recipe.ingredients) do
            if ingname == v.type then
                amount_needed = v.amount
            end
        end
        local has, num_found = slot.owner.replica.inventory:Has(ingname, RoundBiasedUp(amount_needed * slot.owner.replica.builder:IngredientMod()))
        for _, v in pairs(recipe.character_ingredients) do
            if ingname == v.type then
                amount_needed = v.amount
                has, num_found = slot.owner.replica.builder:HasCharacterIngredient(v)
            end
        end
        num = amount_needed - num_found
        local can_make = math.floor(num_found / amount_needed) * recipe.numtogive
        if amount_needed == 0 then
            num = num_found > 0 and 0 or 1
            can_make = ''
        end
        local ingredient_str = (ingtooltip or STRINGS.NOMU_QA.UNKNOWN_NAME):lower()
        local p = string.find(ingredient_str, '\n')
        if p then
            ingredient_str = string.sub(ingredient_str, 0, p - 1)
        end

        local qa = GLOBAL.NOMU_QA.SCHEME.INGREDIENT
        local fmts = {
            AND_PROTOTYPE = '',
            BUT_PROTOTYPE = '',
            INGREDIENT = ingredient_str,
            RECIPE = name,
        }

        if num > 0 then
            fmts.NUM = num
            if prototype ~= "" then
                fmts.AND_PROTOTYPE = subfmt(GetMapping(qa, 'WORDS', 'AND_PROTOTYPE'), { PROTOTYPE = prototype })
            end
            return Announce(subfmt(qa.FORMATS.NEED, fmts))
        else
            fmts.NUM = can_make
            if prototype ~= "" then
                fmts.BUT_PROTOTYPE = subfmt(GetMapping(qa, 'WORDS', 'BUT_PROTOTYPE'), { PROTOTYPE = prototype })
            end
            return Announce(subfmt(qa.FORMATS.HAVE, fmts))
        end
    end
end

local function AnnounceRecipeGrid(grid, owner)
    local focused_item_index = grid.focused_widget_index + grid.displayed_start_index
    local recipe
    if grid.focus and #grid.items > 0 and grid.items[focused_item_index] then
        recipe = grid.items[focused_item_index].recipe
    end
    if not recipe then
        return
    end
    local builder = owner.replica.builder
    local buffered = builder:IsBuildBuffered(recipe.name)
    local knows = builder:KnowsRecipe(recipe.name) or CanPrototypeRecipe(recipe.level, builder:GetTechTrees())
    local can_build = builder:CanBuild(recipe.name)
    local strings_name = STRINGS.NAMES[recipe.product:upper()] or STRINGS.NAMES[recipe.name:upper()]
    local name = strings_name and strings_name:lower() or STRINGS.NOMU_QA.UNKNOWN_NAME

    local prototype = GetPrototype(knows, recipe, owner)
    local fmts = {
        ITEM = name,
        PROTOTYPE = prototype
    }
    local qa = GLOBAL.NOMU_QA.SCHEME.RECIPE
    if buffered then
        return Announce(subfmt(qa.FORMATS.BUFFERED, fmts))
    elseif can_build and knows then
        return Announce(subfmt(qa.FORMATS.WILL_MAKE, fmts))
    elseif knows then
        return Announce(subfmt(qa.FORMATS.WE_NEED, fmts))
    else
        return Announce(subfmt(qa.FORMATS.CAN_SOMEONE, fmts))
    end
end

local function AnnounceRecipeCMIngredients(ingredients)
    local recipe = ingredients.recipe
    if not recipe then
        return
    end
    local builder = ingredients.owner.replica.builder
    local knows = builder:KnowsRecipe(recipe.name) or CanPrototypeRecipe(recipe.level, builder:GetTechTrees())
    local strings_name = STRINGS.NAMES[recipe.product:upper()] or STRINGS.NAMES[recipe.name:upper()]
    local name = strings_name and strings_name:lower() or STRINGS.NOMU_QA.UNKNOWN_NAME

    local ingredient

    local ing = {}
    local ingredients_root
    for _, v in pairs(ingredients.children) do
        ingredients_root = v
        break
    end
    if ingredients_root ~= nil then
        for _, v in pairs(ingredients_root.children) do
            table.insert(ing, v)
        end
    end

    for _, _ing in ipairs(ing) do
        if _ing.focus then
            ingredient = _ing
        end
    end

    if ingredient == nil then
        return
    end
    local prototype = GetPrototype(knows, recipe, ingredients.owner)
    local num = 0
    local ingname
    local ingtooltip
    if ingredient.ing then
        ingname = ingredient.ing.texture:sub(1, -5)
        ingtooltip = ingredient.tooltip
    end

    local amount_needed = 1
    for _, v in pairs(recipe.ingredients) do
        if ingname == v.type then
            amount_needed = v.amount
        end
    end
    local has, num_found = ingredients.owner.replica.inventory:Has(ingname, RoundBiasedUp(amount_needed * ingredients.owner.replica.builder:IngredientMod()))
    for _, v in pairs(recipe.character_ingredients) do
        if ingname == v.type then
            amount_needed = v.amount
            has, num_found = ingredients.owner.replica.builder:HasCharacterIngredient(v)
        end
    end
    num = amount_needed - num_found
    local can_make = math.floor(num_found / amount_needed) * recipe.numtogive
    if amount_needed == 0 then
        num = num_found > 0 and 0 or 1
        can_make = ''
    end
    local ingredient_str = (ingtooltip or STRINGS.NOMU_QA.UNKNOWN_NAME):lower()
    local p = string.find(ingredient_str, '\n')
    if p then
        ingredient_str = string.sub(ingredient_str, 0, p - 1)
    end
    local qa = GLOBAL.NOMU_QA.SCHEME.INGREDIENT
    local fmts = {
        AND_PROTOTYPE = '',
        BUT_PROTOTYPE = '',
        INGREDIENT = ingredient_str,
        RECIPE = name,
    }

    if num > 0 then
        fmts.NUM = num
        if prototype ~= "" then
            fmts.AND_PROTOTYPE = subfmt(GetMapping(qa, 'WORDS', 'AND_PROTOTYPE'), { PROTOTYPE = prototype })
        end
        return Announce(subfmt(qa.FORMATS.NEED, fmts))
    else
        fmts.NUM = can_make
        if prototype ~= "" then
            fmts.BUT_PROTOTYPE = subfmt(GetMapping(qa, 'WORDS', 'BUT_PROTOTYPE'), { PROTOTYPE = prototype })
        end
        return Announce(subfmt(qa.FORMATS.HAVE, fmts))
    end
end

local function CountItemWithName(container, name, prefab)
    local num_found = 0
    local items = container:GetItems()
    for _, v in pairs(items) do
        if v and v.prefab == prefab and v:GetDisplayName() == name then
            if v.replica.stackable ~= nil then
                num_found = num_found + v.replica.stackable:StackSize()
            else
                num_found = num_found + 1
            end
        end
    end

    if container.GetActiveItem then
        local active_item = container:GetActiveItem()
        if active_item and active_item.prefab == prefab and active_item:GetDisplayName() == name then
            if active_item.replica.stackable ~= nil then
                num_found = num_found + active_item.replica.stackable:StackSize()
            else
                num_found = num_found + 1
            end
        end
    end

    if container.GetOverflowContainer then
        local overflow = container:GetOverflowContainer()
        if overflow ~= nil then
            local overflow_found = CountItemWithName(overflow, name, prefab)
            num_found = num_found + overflow_found
        end
    end

    return num_found
end

local function get_container_name(container)
    if not container then
        return
    end
    local container_name = container:GetBasicDisplayName()
    local container_prefab = container and container.prefab
    local underscore_index = container_prefab and container_prefab:find("_container")
    if type(container_name) == "string" and container_name:find("^%s*$") and underscore_index then
        container_name = STRINGS.NAMES[container_prefab:sub(1, underscore_index - 1):upper()]
    end
    --print('!!!', container_prefab)
    return STRINGS.NOMU_QA[container_prefab:upper()] or container_name and container_name:lower()
end

local RECHARGEABLE_PREFABS = {
    pocketwatch_heal = TUNING.POCKETWATCH_HEAL_COOLDOWN,
    pocketwatch_revive = TUNING.POCKETWATCH_REVIVE_COOLDOWN,
    pocketwatch_warp = TUNING.POCKETWATCH_WARP_COOLDOWN,
    pocketwatch_recall = TUNING.POCKETWATCH_RECALL_COOLDOWN,
    pocketwatch_portal = TUNING.POCKETWATCH_RECALL_COOLDOWN,
}

local SUSPICIOUS_MARBLE = {
    sculpture_bishophead = STRINGS.NOMU_QA.SCULPTURE_BISHOPHEAD,
    sculpture_knighthead = STRINGS.NOMU_QA.SCULPTURE_KNIGHTHEAD,
    sculpture_rooknose = STRINGS.NOMU_QA.SCULPTURE_ROOKNOSE,
    sculpture_bishopbody = STRINGS.NOMU_QA.SCULPTURE_BISHOPBODY,
    sculpture_knightbody = STRINGS.NOMU_QA.SCULPTURE_KNIGHTBODY,
    sculpture_rookbody = STRINGS.NOMU_QA.SCULPTURE_ROOKBODY
}

local ITEM_PREFAB_ALIAS = {
    -- 鹿角
    deer_antler1 = "deer_antler",
    deer_antler2 = "deer_antler",
    deer_antler3 = "deer_antler",
    -- 还有啥呢？好难猜呀
}

local function CountItem_ALIAS(container, name, prefab)
    local num_found = 0
    local items = container:GetItems()
    for _, v in pairs(items) do
        if v and ITEM_PREFAB_ALIAS[v.prefab] == prefab and v:GetDisplayName() == name then
            if v.replica.stackable ~= nil then
                num_found = num_found + v.replica.stackable:StackSize()
            else
                num_found = num_found + 1
            end
        end
    end

    if container.GetActiveItem then
        local active_item = container:GetActiveItem()
        if active_item and ITEM_PREFAB_ALIAS[active_item.prefab] == prefab and active_item:GetDisplayName() == name then
            if active_item.replica.stackable ~= nil then
                num_found = num_found + active_item.replica.stackable:StackSize()
            else
                num_found = num_found + 1
            end
        end
    end

    if container.GetOverflowContainer then
        local overflow = container:GetOverflowContainer()
        if overflow ~= nil then
            local overflow_found = CountItem_ALIAS(overflow, name, prefab)
            num_found = num_found + overflow_found
        end
    end

    return num_found
end

local function AnnounceItem(slot, classname)
    local item = slot.tile.item
    local container = slot.container
    local percent
    local percent_type
    if slot.tile.percent then
        percent = slot.tile.percent:GetString()
        percent_type = "DURABILITY"
    elseif slot.tile.hasspoilage then
        percent = math.floor(item.replica.inventoryitem.classified.perish:value() * (1 / .62)) .. "%"
        percent_type = "FRESHNESS"
    end
    if container == nil or (container and container.type == "pack") then
        container = ThePlayer.replica.inventory
    end
    local num_equipped = 0
    local num_equipped_name = 0
    if not container.type then
        for _, _slot in pairs(EQUIPSLOTS) do
            local equipped_item = container:GetEquippedItem(_slot)
            if equipped_item and equipped_item.prefab == item.prefab then
                num_equipped = num_equipped + (equipped_item.replica.stackable and equipped_item.replica.stackable:StackSize() or 1)
                if equipped_item.name == item.name then
                    num_equipped_name = num_equipped_name + (equipped_item.replica.stackable and equipped_item.replica.stackable:StackSize() or 1)
                end
            end
        end
    end
    local container_name = get_container_name(container.type and container.inst)
    if not container_name then
        local player = container.inst.entity:GetParent()
        local constructionbuilder = player and player.components and player.components.constructionbuilder
        if constructionbuilder and constructionbuilder.constructionsite then
            container_name = get_container_name(constructionbuilder.constructionsite)
        end
    end

    local name = item.prefab and STRINGS.NAMES[item.prefab:upper()] or STRINGS.NOMU_QA.UNKNOWN_NAME
    local _, num_found = container:Has(item.prefab, 1)
    local num_found_name = CountItemWithName(container, item:GetDisplayName(), item.prefab)
    num_found_name = num_found_name + num_equipped_name
    num_found = num_found + num_equipped
    local item_name = string.gsub(item:GetBasicDisplayName(), '\n', ' ')
    if name == STRINGS.NOMU_QA.UNKNOWN_NAME and num_found == num_found_name then
        name = item_name
    end

    local qa = GLOBAL.NOMU_QA.SCHEME.ITEM
    local fmts = {
        PRONOUN = GetMapping(qa, 'PRONOUN', 'I'),
        NUM = num_found,
        EQUIP_NUM = num_equipped,
        ITEM = name,
        ITEM_NAME = item_name ~= name and subfmt(GetMapping(qa, 'WORDS', 'ITEM_NAME'), { NUM = num_found_name, NAME = item_name }) or '',
        IN_CONTAINER = '',
        WITH_PERCENT = '',
        POST_STATE = '',
        SHOW_ME = '',
        ITEM_NUM = num_equipped ~= num_found and subfmt(GetMapping(qa, 'WORDS', 'ITEM_NUM'), { NUM = num_found }) or '',
    }

    if container_name then
        fmts.PRONOUN = GetMapping(qa, 'PRONOUN', 'WE')
        fmts.IN_CONTAINER = subfmt(GetMapping(qa, 'WORDS', 'IN_CONTAINER'), {
            NAME = container_name
        })
    end

    if percent then
        local this_one = num_found > 1 and GetMapping(qa, 'WORDS', 'THIS_ONE') or ''
        fmts.WITH_PERCENT = subfmt(GetMapping(qa, 'WORDS', 'WITH_PERCENT'), {
            THIS_ONE = this_one,
            PERCENT = percent,
            TYPE = GetMapping(qa, 'PERCENT_TYPE', percent_type)
        })
    end

    if item.prefab == 'heatrock' then
        --'heatrock_fantasy', 'heat_rock', 'heatrock_fire'
        -- hash('heatrock_fantasy3.tex')
        local temp_range = {
            [4264163310] = 1, [3706253814] = 1, [2098310090] = 1,
            [1108760303] = 2, [550850807] = 2, [3237874379] = 2,
            [2248324592] = 3, [1690415096] = 3, [82471372] = 3,
            [3387888881] = 4, [2829979385] = 4, [1222035661] = 4,
            [232485874] = 5, [3969543674] = 5, [2361599950] = 5
        }
        local temp_category = { 'COLD', 'COOL', 'NORMAL', 'WARM', 'HOT' }
        if item.replica and item.replica.inventoryitem and item.replica.inventoryitem.GetImage then
            local range = temp_range[item.replica.inventoryitem:GetImage()]
            if range and temp_category[range] then
                fmts.POST_STATE = GetMapping(qa, 'HEAT_ROCK', temp_category[range])
            end
        end
    end

    if SUSPICIOUS_MARBLE[item.prefab] then
        fmts.POST_STATE = subfmt(GetMapping(qa, 'WORDS', 'SUSPICIOUS_MARBLE'), { NAME = SUSPICIOUS_MARBLE[item.prefab] })
    end

    if RECHARGEABLE_PREFABS[item.prefab] and item.replica.inventoryitem.classified then
        local seconds = (180 - item.replica.inventoryitem.classified.recharge:value()) / 180 * RECHARGEABLE_PREFABS[item.prefab]
        local minutes = math.modf(seconds / 60)
        if seconds == 0 then
            fmts.POST_STATE = GetMapping(qa, 'RECHARGE', 'FULL')
        else
            seconds = math.modf(math.fmod(seconds, 60))
            local message = ''
            if minutes > 0 then
                message = message .. tostring(minutes) .. GetMapping(qa, 'TIME', 'MINUTES')
            end
            message = message .. tostring(seconds) .. GetMapping(qa, 'TIME', 'SECONDS')
            fmts.POST_STATE = subfmt(GetMapping(qa, 'RECHARGE', 'CHARGING'), { TIME = message })
        end
    end

    if SHOW_ME_ON and (GLOBAL.NOMU_QA.DATA.SHOW_ME == 1 or GLOBAL.NOMU_QA.DATA.SHOW_ME == 2 and item:HasTag('unwrappable')) then
        local n_line_name = #(string.split(item:GetDisplayName(), '\n'))
        local items = GLOBAL.QA_UTILS.ParseHoverText(n_line_name + (classname == 'invslot' and 3 or 2), -1)
        if #items > 0 then
            fmts.SHOW_ME = subfmt(GetMapping(qa, 'WORDS', 'SHOW_ME'), { SHOW_ME = table.concat(items, STRINGS.NOMU_QA.COMMA) })
        end
    end

    -- 将部分物品视为同一个prefab，解决宣告数量不准确的问题
    if ITEM_PREFAB_ALIAS[item.prefab] then
        fmts.NUM = CountItem_ALIAS(container, item:GetDisplayName(), ITEM_PREFAB_ALIAS[item.prefab])
    end

    return Announce(subfmt(classname == 'invslot' and qa.FORMATS.INV_SLOT or qa.FORMATS.EQUIP_SLOT, fmts))
end

AddClassPostConstruct('screens/playerhud', function(PlayerHud)
    local oldOnMouseButton = PlayerHud.OnMouseButton
    function PlayerHud:OnMouseButton(button, down, ...)
        if button == MOUSEBUTTON_LEFT and down and TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then
            if OnHUDMouseButton(self) then
                return true
            end
        end
        return oldOnMouseButton(self, button, down, ...)
    end

    PlayerHud._StatusAnnouncer = {
        stat_names = {
            IA_BOAT = '船'
        },
        char_messages = { },
        Announce = function(_, message)
            return Announce(message)
        end,
        AnnounceItem = function(_, slot)
            return AnnounceItem(slot,'invslot')
        end
    }
    setmetatable(PlayerHud._StatusAnnouncer.char_messages, {
        __index = function(_, k)
            return STRINGS._STATUS_ANNOUNCEMENTS.UNKNOWN[k]
        end
    })

    local oldOnUpdate = PlayerHud.OnUpdate
    local Text = require "widgets/text"
    function PlayerHud:OnUpdate(...)
        if self.controls and self.controls.foodcrafting and self.controls.foodcrafting.allfoods then
            for _, food_item in ipairs(self.controls.foodcrafting.allfoods) do
                if food_item.recipepopup then
                    if food_item.recipepopup.hunger and not food_item.recipepopup.hunger.hovertext then
                        food_item.recipepopup.hunger:SetString('-')
                        food_item.recipepopup.hunger:SetHoverText(STRINGS.NOMU_QA.HOVER_TEXT_ANNOUNCE)
                    end
                    if food_item.recipepopup.health and not food_item.recipepopup.health.hovertext then
                        food_item.recipepopup.health:SetString('-')
                        food_item.recipepopup.health:SetHoverText(STRINGS.NOMU_QA.HOVER_TEXT_ANNOUNCE)
                    end
                    if food_item.recipepopup.sanity and not food_item.recipepopup.sanity.hovertext then
                        food_item.recipepopup.sanity:SetString('-')
                        food_item.recipepopup.sanity:SetHoverText(STRINGS.NOMU_QA.HOVER_TEXT_ANNOUNCE)
                    end
                    if food_item.recipepopup.name and not food_item.recipepopup.name.hovertext then
                        food_item.recipepopup.name:SetHoverText(STRINGS.NOMU_QA.HOVER_TEXT_ANNOUNCE)
                    end
                end
            end
        end
        return oldOnUpdate(self, ...)
    end
end)

AddClassPostConstruct('widgets/redux/craftingmenu_pinslot', function(PinSlot)
    local oldOnControl = PinSlot.OnControl
    function PinSlot:OnControl(control, down, ...)
        if down and control == GLOBAL.CONTROL_ACCEPT and TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then
            return AnnounceRecipePinSlot(self)
        elseif not TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then
            return oldOnControl(self, control, down, ...)
        end
    end
end)

AddClassPostConstruct('widgets/redux/craftingmenu_widget', function(CMWidget)
    local grid = CMWidget.recipe_grid
    local oldOnControl = grid.OnControl
    function grid:OnControl(control, down, ...)
        if down and control == GLOBAL.CONTROL_ACCEPT and TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then
            return AnnounceRecipeGrid(self, CMWidget.owner)
        elseif not TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then
            return oldOnControl(self, control, down, ...)
        end
    end
end)

AddClassPostConstruct('widgets/redux/craftingmenu_ingredients', function(CMIngredients)
    local oldOnControl = CMIngredients.OnControl
    function CMIngredients:OnControl(control, down, ...)
        if down and control == GLOBAL.CONTROL_ACCEPT and TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then
            return AnnounceRecipeCMIngredients(self)
        elseif not TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then
            return oldOnControl(self, control, down, ...)
        end
    end
end)

AddClassPostConstruct('widgets/redux/craftingmenu_skinselector', function(CMSkinSelector)
    local oldOnControl = CMSkinSelector.OnControl
    function CMSkinSelector:OnControl(control, down, ...)
        if down and control == GLOBAL.CONTROL_ACCEPT and TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then
            return AnnounceSkin(self)
        elseif not TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then
            return oldOnControl(self, control, down, ...)
        end
    end
end)

for _, classname in pairs({ 'invslot', 'equipslot' }) do
    AddClassPostConstruct('widgets/' .. classname, function(SlotClass)
        local oldOnControl = SlotClass.OnControl
        function SlotClass:OnControl(control, down, ...)
            if down and control == GLOBAL.CONTROL_ACCEPT and TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) and TheInput:IsKeyDown(GLOBAL.KEY_LSHIFT) and self.tile then
                return AnnounceItem(self, classname)
            else
                return oldOnControl(self, control, down, ...)
            end
        end
    end)
end

-- 礼物
AddClassPostConstruct('widgets/giftitemtoast', function(self)
    local oldOnMouseButton = self.OnMouseButton
    function self:OnMouseButton(button, down, ...)
        local ret = oldOnMouseButton(self, button, down, ...)
        if button == MOUSEBUTTON_LEFT and down and TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then
            Announce(self.enabled and GLOBAL.NOMU_QA.SCHEME.GIFT.FORMATS.CAN_OPEN or GLOBAL.NOMU_QA.SCHEME.GIFT.FORMATS.NEED_SCIENCE)
        end
        return ret
    end
end)

-- Alt+Shift+鼠标左键宣告周围物品
AddComponentPostInit("playercontroller", function(self, inst)
    if inst ~= GLOBAL.ThePlayer then return end
    local PlayerControllerOnControl = self.OnControl
    self.OnControl = function(self, control, down, ...)

        if not (IsDefaultScreen() and TheInput:IsControlPressed(CONTROL_FORCE_INSPECT) and TheInput:IsKeyDown(KEY_LSHIFT) and down) then
            return PlayerControllerOnControl(self, control, down, ...)
        end

        local entity = ConsoleWorldEntityUnderMouse()
        local qa = GLOBAL.NOMU_QA.SCHEME.ENV
        if control == GLOBAL.CONTROL_PRIMARY then -- 鼠标左键点击
            if entity then
                if not TheInput:IsKeyDown(KEY_LCTRL) and entity:HasTag('player') then
                    Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.DEFAULT, { NAME = entity:GetDisplayName() }))
                    return
                end
                local px, py, pz = entity:GetPosition():Get()
                local entities = TheSim:FindEntities(px, py, pz, 40)
                local count_name = 0
                local count_prefab = 0
                for _, v in ipairs(entities) do
                    if v.entity:IsVisible() and v.prefab == entity.prefab then
                        if v.replica and v.replica.stackable ~= nil then
                            count_prefab = count_prefab + v.replica.stackable:StackSize()
                            if v:GetDisplayName() == entity:GetDisplayName() then
                                count_name = count_name + v.replica.stackable:StackSize()
                            end
                        else
                            count_prefab = count_prefab + 1
                            if v:GetDisplayName() == entity:GetDisplayName() then
                                count_name = count_name + 1
                            end
                        end
                    end
                end
                local prefab_name = entity.prefab and STRINGS.NAMES[entity.prefab:upper()]
                local no_whisper = entity:HasTag('player')
                local display_name = string.gsub(entity:GetDisplayName(), '\n', ' ')
                if SUSPICIOUS_MARBLE[entity.prefab] then
                    prefab_name = prefab_name .. ' ' .. SUSPICIOUS_MARBLE[entity.prefab]
                    display_name = prefab_name
                end

                local show_me = ''
                if SHOW_ME_ON and (GLOBAL.NOMU_QA.DATA.SHOW_ME == 1 or GLOBAL.NOMU_QA.DATA.SHOW_ME == 2 and entity:HasTag('unwrappable')) then
                    local n_line_name = #(string.split(entity:GetDisplayName(), '\n'))
                    local items = GLOBAL.QA_UTILS.ParseHoverText(n_line_name + 1, nil, nil, 2)
                    if #items > 0 then
                        show_me = subfmt(GetMapping(qa, 'WORDS', 'SHOW_ME'), { SHOW_ME = table.concat(items, STRINGS.NOMU_QA.COMMA) })
                    end
                end

                if not prefab_name then
                    if count_name == 1 then
                        Announce(subfmt(qa.FORMATS.SINGLE, { NAME = display_name, SHOW_ME = show_me }), no_whisper)
                        return
                    else
                        Announce(subfmt(qa.FORMATS.DEFAULT, { NUM = count_name, NAME = display_name, SHOW_ME = show_me }), no_whisper)
                        return
                    end
                else
                    if prefab_name ~= display_name then
                        Announce(subfmt(qa.FORMATS.NAMED, { NUM_PREFAB = count_prefab, PREFAB_NAME = prefab_name, NUM = count_name, NAME = display_name, SHOW_ME = show_me }), no_whisper)
                        return
                    else
                        Announce(subfmt(qa.FORMATS.DEFAULT, { NUM = count_prefab, NAME = prefab_name, SHOW_ME = show_me }), no_whisper)
                        return
                    end
                end
            end
        end
        return PlayerControllerOnControl(self, control, down, ...)
    end
end)

-- Alt+Shift+鼠标中键宣告
TheInput:AddMouseButtonHandler(function(button, down)
    if not (IsDefaultScreen() and TheInput:IsControlPressed(CONTROL_FORCE_INSPECT) and TheInput:IsKeyDown(KEY_LSHIFT) and down) then
        return
    end

    local entity = ConsoleWorldEntityUnderMouse()
    local qa = GLOBAL.NOMU_QA.SCHEME.ENV
    if button == MOUSEBUTTON_MIDDLE then -- 鼠标中键点击，上面的方法只能识别到鼠标左右键
        if entity then
            if not TheInput:IsKeyDown(KEY_LCTRL) and entity:HasTag('player') then
                if entity == ThePlayer then
                    Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.PING, { PING = TheNet:GetAveragePing() }))
                else
                    Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.GREET, { NAME = entity:GetDisplayName() }))
                end
                return
            end
            ThePlayer.components.talker:Say(subfmt(qa.FORMATS.CODE, { PREFAB = entity.prefab, NAME = entity:GetDisplayName() }), 5)
        end
    end
end)

-- TAB面板
AddClassPostConstruct('screens/playerstatusscreen', function(PlayerStatusScreen)
    local oldOnUpdate = PlayerStatusScreen.OnUpdate
    function PlayerStatusScreen:OnUpdate(...)
        if self.servertitle and not self.servertitle.hovertext then
            self.servertitle:SetHoverText(STRINGS.NOMU_QA.HOVER_TEXT_ANNOUNCE)
        end
        if self.serverstate and not self.serverstate.hovertext then
            self.serverstate:SetHoverText(STRINGS.NOMU_QA.HOVER_TEXT_ANNOUNCE)
        end
        if self.players_number and not self.players_number.hovertext then
            self.players_number:SetHoverText(STRINGS.NOMU_QA.HOVER_TEXT_ANNOUNCE)
        end
        for _, widget in ipairs(PlayerStatusScreen.player_widgets) do
            if widget.age and not widget.age.hovertext then
                widget.age:SetHoverText(STRINGS.NOMU_QA.HOVER_TEXT_ANNOUNCE)
            end
        end
        return oldOnUpdate(self, ...)
    end

    local oldOnControl = PlayerStatusScreen.OnControl
    function PlayerStatusScreen:OnControl(control, down, ...)
        if down and control == GLOBAL.CONTROL_ACCEPT and TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then
            if self.servertitle and self.servertitle.focus then
                return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.SERVER.FORMATS.NAME, { NAME = PlayerStatusScreen.servertitle:GetString() }))
            end
            if self.serverstate and self.serverstate.focus then
                return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.SERVER.FORMATS.AGE, { AGE = PlayerStatusScreen.serverage }))
            end
            if self.players_number and self.players_number.focus then
                return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.SERVER.FORMATS.NUM_PLAYER, { NUM = PlayerStatusScreen.players_number:GetString() }))
            end
            for _, widget in ipairs(PlayerStatusScreen.player_widgets) do
                if widget.focus and widget.displayName then
                    if widget.name and widget.name.focus then
                        return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.GREET, { NAME = widget.displayName }))
                    end
                    if widget.adminBadge and widget.adminBadge.shown and widget.adminBadge.focus then
                        return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.ADMIN, { NAME = widget.displayName }))
                    end
                    if widget.perf and widget.perf.shown and widget.perf.focus and widget.perf.hovertext then
                        return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.PERF, {
                            NAME = widget.displayName, PERF = widget.perf.hovertext:GetString(),
                            PING = (widget.userid == ThePlayer.userid and subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.PING, { PING = TheNet:GetAveragePing() }) or '')
                        }))
                    end
                    if widget.profileFlair and widget.profileFlair.shown and widget.profileFlair.focus and widget.characterBadge and widget.characterBadge.prefabname then
                        return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.NAME, { NAME = widget.displayName, CHARACTER = STRINGS.NAMES[widget.characterBadge.prefabname:upper()] or widget.characterBadge.prefabname }))
                    end
                    if widget.age and widget.age.shown and widget.age.focus then
                        local age = widget.age:GetString()
                        if #age > 0 then
                            return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.AGE, { NAME = widget.displayName, AGE = widget.age:GetString() }))
                        end
                    end
                end
            end
        end
        return oldOnControl(self, control, down, ...)
    end
end)

-- 审视自我面板
AddClassPostConstruct('widgets/playeravatarpopup', function(PlayerAvatarPopup)
    local items = { 'body', 'hand', 'legs', 'feet', 'base', 'head_equip', 'hand_equip', 'body_equip' }
    if PlayerAvatarPopup.age and not PlayerAvatarPopup.age.hovertext then
        PlayerAvatarPopup.age:SetHoverText(STRINGS.NOMU_QA.HOVER_TEXT_ANNOUNCE)
    end
    for _, item in ipairs(items) do
        if PlayerAvatarPopup[item .. '_image'] and PlayerAvatarPopup[item .. '_image']._text and not PlayerAvatarPopup[item .. '_image']._text.hovertext then
            PlayerAvatarPopup[item .. '_image']._text:SetHoverText(STRINGS.NOMU_QA.HOVER_TEXT_ANNOUNCE)
        end
    end

    local oldOnControl = PlayerAvatarPopup.OnControl
    function PlayerAvatarPopup:OnControl(control, down, ...)
        if down and control == GLOBAL.CONTROL_ACCEPT and TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) and self.player_name then
            if self.age and self.age.focus and self.currentcharacter then
                return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.AGE_SHORT, { NAME = self.player_name, AGE = self.age:GetString() }))
            end
            if self.character_name and self.character_name.focus and self.currentcharacter then
                return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.NAME, { NAME = self.player_name, CHARACTER = STRINGS.NAMES[self.currentcharacter:upper()] or self.currentcharacter }))
            end
            if self.puppet and self.puppet.rank and self.puppet.rank.focus and self.puppet.rank.flair and self.puppet.rank.flair.hovertext then
                return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.BADGE, { NAME = self.player_name, BADGE = self.puppet.rank.flair.hovertext:GetString() }))
            end
            if self.puppet and self.puppet.frame and self.puppet.frame.focus and self.puppet.frame.bg and self.puppet.frame.bg.hovertext then
                return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS.BACKGROUND, { NAME = self.player_name, BACKGROUND = self.puppet.frame.bg.hovertext:GetString() }))
            end
            for _, item in ipairs(items) do
                if self[item .. '_image'] and self[item .. '_image'].focus then
                    return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.PLAYER.FORMATS[item:upper()], { NAME = self.player_name, [item:upper()] = self[item .. '_image']._text:GetString() }))
                end
            end
        end
        return oldOnControl(self, control, down, ...)
    end
end)

--技能树
AddClassPostConstruct('widgets/redux/skilltreebuilder', function(SkillTreeBuilder)
    local oldOnControl = SkillTreeBuilder.OnControl
    function SkillTreeBuilder:OnControl(control, down, ...)
        if down and control == GLOBAL.CONTROL_ACCEPT and TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then
            for k, v in pairs(self.skillgraphics) do
                if v.button and v.button.focus and v.status and self.skilltreedef and self.skilltreedef[k] and self.skilltreedef[k].title then
                    local name = type(self.fromfrontend) == "table" and self.fromfrontend.data and self.fromfrontend.data.name or ''
                    if v.status.activated then
                        return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.SKILL_TREE.FORMATS.ACTIVATED, { NAME = name, SKILL = self.skilltreedef[k].title }))
                    elseif v.status.activatable then
                        return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.SKILL_TREE.FORMATS.CAN_ACTIVATE, { NAME = name, SKILL = self.skilltreedef[k].title }))
                    end
                end
            end
        end
        return oldOnControl(self, control, down, ...)
    end
end)

--食谱
AddClassPostConstruct('widgets/redux/cookbookpage_crockpot', function(CookbookPageCrockPot)
    local oldPopulateRecipeDetailPanel = CookbookPageCrockPot.PopulateRecipeDetailPanel
    function CookbookPageCrockPot:PopulateRecipeDetailPanel(data, ...)
        self.nomu_qa_data = data
        return oldPopulateRecipeDetailPanel(self, data, ...)
    end
    CookbookPageCrockPot.nomu_qa_data = CookbookPageCrockPot.all_recipes[(TheCookbook.selected ~= nil and TheCookbook.selected[CookbookPageCrockPot.category] or 1)]

    local oldOnControl = CookbookPageCrockPot.OnControl
    function CookbookPageCrockPot:OnControl(control, down, ...)
        if down and control == GLOBAL.CONTROL_ACCEPT and TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then
            if self.nomu_qa_data and self.details_root and self.details_root.focus then
                local data = self.nomu_qa_data
                return Announce(subfmt(GLOBAL.NOMU_QA.SCHEME.COOK.FORMATS.FOOD, {
                    NAME = data.name,
                    HUNGER = data.recipe_def.hunger ~= nil and math.floor(10 * data.recipe_def.hunger) / 10 or '-',
                    SANITY = data.recipe_def.sanity ~= nil and math.floor(10 * data.recipe_def.sanity) / 10 or '-',
                    HEALTH = data.recipe_def.health ~= nil and math.floor(10 * data.recipe_def.health) / 10 or '-'
                }))
            end
        end
        return oldOnControl(self, control, down, ...)
    end
end)

-- 界面
local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"
local ImageButton = require "widgets/imagebutton"
local Image = require "widgets/image"
local TextButton = require "widgets/textbutton"
local Text = require "widgets/text"

local NoMuScreen = Class(Screen, function(self, name, nomu_parent, width, height, title)
    Screen._ctor(self, name)
    self.nomu_parent = nomu_parent
    if nomu_parent then
        nomu_parent:Hide()
    end
    self.root = self:AddChild(TEMPLATES.RectangleWindow(width, height, title))
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetPosition(0, 0)
    --local r, g, b = unpack(UICOLOURS.BROWN_DARK)
    --self.root:SetBackgroundTint(r, g, b, 0.6)

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

    self.AddSpinner = function(text, list, fn, current, label_width, spinner_width, label_height, spacing)
        local key_options = {}
        for i, key in ipairs(list) do
            key_options[i] = {
                text = key,
                data = key
            }
        end
        local key_spinner = self.root:AddChild(TEMPLATES.LabelSpinner(text, key_options, label_width or 95, spinner_width or 260, label_height or 40, spacing or 5, NEWFONT, 26, 0, fn))
        key_spinner.spinner:SetSelected(current)
        return key_spinner
    end
end)

function NoMuScreen:Close()
    if self.nomu_parent then
        self.nomu_parent:Show()
    end
    TheFrontEnd:PopScreen(self)
end

function NoMuScreen:OnControl(control, down)
    if NoMuScreen._base.OnControl(self, control, down) then
        return true
    end
    if not down then
        if control == CONTROL_PAUSE or control == CONTROL_CANCEL then
            self:Close()
        end
    end
    return true
end

local NoMuList = Class(Widget, function(self, list_item_fn, x, y, item_width, item_height, cols, rows)
    Widget._ctor(self, "NoMuList")
    self.x = x or 0
    self.y = y or 0
    self.item_width = item_width or 200
    self.item_height = item_height or 80
    self.cols = cols or 1
    self.rows = rows or 10
    self.scroll_lists = nil
    self.list_item_fn = list_item_fn
end)

function NoMuList:Refresh(list_data, override)
    override = override or {}
    local function ScrollWidgetsCtor(_, index)
        local widget = Widget("widget-" .. index)
        widget:SetOnGainFocus(function()
            if self.scroll_lists then
                self.scroll_lists:OnWidgetFocus(widget)
            end
        end)
        widget.nomu_list_item = widget:AddChild(self.list_item_fn(self))
        widget.focus_forward = widget.nomu_list_item
        return widget
    end

    local function ApplyDataToWidget(_, widget, data)
        widget.data = data
        widget.nomu_list_item:Hide()
        if not data then
            widget.focus_forward = nil
            return
        end
        widget.focus_forward = widget.nomu_list_item
        widget.nomu_list_item:Show()
        widget.nomu_list_item:SetInfo(data)
    end

    if self.scroll_lists then
        self.scroll_lists:Kill()
    end
    self.scroll_lists = self:AddChild(
            TEMPLATES.ScrollingGrid(list_data, {
                context = {},
                widget_width = override.item_width or self.item_width,
                widget_height = override.item_height or self.item_height,
                num_visible_rows = override.rows or self.rows,
                num_columns = override.cols or self.cols,
                item_ctor_fn = ScrollWidgetsCtor,
                apply_fn = ApplyDataToWidget,
                scrollbar_offset = 10,
                scrollbar_height_offset = -60,
                peek_percent = 0,
                allow_bottom_empty_row = true
            }))
    self.scroll_lists:SetPosition(override.x or self.x, override.y or self.y)
end

local GetInputString = Class(NoMuScreen, function(self, nomu_parent, title, value, callback, limit, width)
    width = width or 200
    limit = limit or 50
    NoMuScreen._ctor(self, "GetInputString", nomu_parent, width, 130)

    self.config_label = self.root:AddChild(Text(BODYTEXTFONT, 32))
    self.config_label:SetString(title)
    self.config_label:SetHAlign(ANCHOR_MIDDLE)
    self.config_label:SetRegionSize(200, 40)
    self.config_label:SetPosition(0, 40)

    self.config_input = self.root:AddChild(TEMPLATES.StandardSingleLineTextEntry("", width, 40))
    self.config_input.textbox:SetTextLengthLimit(limit)
    self.config_input.textbox:SetString(tostring(value))
    self.config_input:SetPosition(0, 0, 0)

    self.AddButton(-50, -40, 100, 40, STRINGS.NOMU_QA.BUTTON_TEXT_APPLY, function()
        callback(self.config_input.textbox:GetLineEditString())
        self:Close()
    end)

    self.AddButton(50, -40, 100, 40, STRINGS.NOMU_QA.BUTTON_TEXT_CLOSE, function()
        self:Close()
    end)
end)

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

local CharacterPicker = Class(NoMuScreen, function(self, nomu_parent, callback)
    local iw, ih = 120, 40
    local width, height = iw + 10, 80 + ih * 4
    NoMuScreen._ctor(self, "CharacterPicker", nomu_parent, width, height + 10)

    self.character_list = self.root:AddChild(NoMuList(function()
        local item = Widget('character-list-item')
        item.backing = item:AddChild(TEMPLATES.ListItemBackground(iw, ih, function()
        end))
        item.backing.move_on_click = true

        item.text = item:AddChild(Text(BODYTEXTFONT, 26, nil, UICOLOURS.WHITE))
        item.SetInfo = function(_, character)
            local name = character == 'DEFAULT' and STRINGS.NOMU_QA.TITLE_TEXT_MAPPING_DEFAULT or STRINGS.NAMES[character:upper()] or character:upper()
            item.text:SetString(name)
            item.backing:SetOnClick(function()
                callback(character)
                self:Close()
            end)
        end

        item.focus_forward = item.backing
        return item
    end, 0, 0, iw, ih, math.floor(width / iw), math.floor((height - 80) / ih)))

    self.AddButton(0, -height / 2 + 20, 120, 40, STRINGS.NOMU_QA.BUTTON_TEXT_CLOSE, function()
        self:Close()
    end)
    local character_list = { 'DEFAULT' }
    for _, character in ipairs(DST_CHARACTERLIST) do
        table.insert(character_list, character)
    end
    self.character_list:Refresh(character_list)
end)

local QAConfigPanel = Class(NoMuScreen, function(self, nomu_parent)
    local width, height = 200, 200
    NoMuScreen._ctor(self, "QAConfigPanel", nomu_parent, width, height + 10)

    local sy = height / 2 - 20
    local row = 0

    self.AddButton(0, sy - row * 40, 200, 40, function()
        return GLOBAL.NOMU_QA.DATA.DEFAULT_WHISPER and STRINGS.NOMU_QA.BUTTON_TEXT_DEFAULT_WHISPER_ON or STRINGS.NOMU_QA.BUTTON_TEXT_DEFAULT_WHISPER_OFF
    end, function()
        GLOBAL.NOMU_QA.DATA.DEFAULT_WHISPER = not GLOBAL.NOMU_QA.DATA.DEFAULT_WHISPER
        GLOBAL.NOMU_QA.SaveData()
    end)
    row = row + 1

    self.AddButton(0, sy - row * 40, 200, 40, function()
        return GLOBAL.NOMU_QA.DATA.CHARACTER_SPECIFIC and STRINGS.NOMU_QA.BUTTON_TEXT_CHARACTER_SPECIFIC_ON or STRINGS.NOMU_QA.BUTTON_TEXT_CHARACTER_SPECIFIC_OFF
    end, function()
        GLOBAL.NOMU_QA.DATA.CHARACTER_SPECIFIC = not GLOBAL.NOMU_QA.DATA.CHARACTER_SPECIFIC
        GLOBAL.NOMU_QA.SaveData()
    end)
    row = row + 1

    self.AddButton(0, sy - row * 40, 200, 40, function()
        return GLOBAL.NOMU_QA.DATA.FREQ_AUTO_CLOSE and STRINGS.NOMU_QA.BUTTON_TEXT_FREQ_AUTO_CLOSE_ON or STRINGS.NOMU_QA.BUTTON_TEXT_FREQ_AUTO_CLOSE_OFF
    end, function()
        GLOBAL.NOMU_QA.DATA.FREQ_AUTO_CLOSE = not GLOBAL.NOMU_QA.DATA.FREQ_AUTO_CLOSE
        GLOBAL.NOMU_QA.SaveData()
    end)
    row = row + 1

    self.AddButton(0, sy - row * 40, 200, 40, function()
        return GLOBAL.NOMU_QA.DATA.SHOW_ME == 1 and STRINGS.NOMU_QA.BUTTON_TEXT_SHOW_ME_ON or GLOBAL.NOMU_QA.DATA.SHOW_ME == 2 and STRINGS.NOMU_QA.BUTTON_TEXT_SHOW_ME_GIFT or STRINGS.NOMU_QA.BUTTON_TEXT_SHOW_ME_OFF
    end, function()
        if GLOBAL.NOMU_QA.DATA.SHOW_ME == 1 then
            GLOBAL.NOMU_QA.DATA.SHOW_ME = 2
        elseif GLOBAL.NOMU_QA.DATA.SHOW_ME == 2 then
            GLOBAL.NOMU_QA.DATA.SHOW_ME = 0
        else
            GLOBAL.NOMU_QA.DATA.SHOW_ME = 1
        end
        GLOBAL.NOMU_QA.SaveData()
    end)
    row = row + 1

    self.AddButton(0, sy - row * 40, 200, 40, STRINGS.NOMU_QA.BUTTON_TEXT_CLOSE, function()
        self:Close()
    end)
end)

local function CreateDefaultScheme()
    local scheme = json.decode(json.encode(GLOBAL.STRINGS.DEFAULT_NOMU_QA))
    for k in pairs(scheme) do
        if scheme[k].MAPPINGS.DEFAULT then
            scheme[k].MAPPINGS = {
                DEFAULT = scheme[k].MAPPINGS.DEFAULT
            }
        end
    end
    return scheme
end

local function ValidateScheme(scheme)
    -- TODO: 更多的验证
    return scheme.name ~= nil and scheme.data ~= nil and scheme.version ~= nil
end

local QACustomizePanel = Class(NoMuScreen, function(self, nomu_parent)
    local width, height = 860, 480
    local sy, sx, dy = height / 2 - 20, -width / 2, 40
    self.sx = sx
    self.sy = sy
    self.dy = dy
    NoMuScreen._ctor(self, "QACustomizePanel", nomu_parent, width, height + 10)

    self.scheme_idx = 1

    self.title_text_schemes = self.root:AddChild(Text(BODYTEXTFONT, 32))
    self.title_text_schemes:SetString(STRINGS.NOMU_QA.TITLE_TEXT_SCHEMES)
    self.title_text_schemes:SetHAlign(ANCHOR_MIDDLE)
    self.title_text_schemes:SetRegionSize(200, dy)
    self.title_text_schemes:SetPosition(sx + 100, sy)

    self.AddButton(sx + 100, sy - dy, 200, dy, STRINGS.NOMU_QA.BUTTON_TEXT_NEW_SCHEME, function()
        TheFrontEnd:PushScreen(GetInputString(self, STRINGS.NOMU_QA.BUTTON_TEXT_NEW_SCHEME, '', function(value)
            table.insert(GLOBAL.NOMU_QA.DATA.SCHEMES, {
                name = value,
                data = CreateDefaultScheme(),
                version = VERSION
            })
            GLOBAL.NOMU_QA.SaveData()
            self:RefreshSchemeList()
            self:RefreshScheme(#GLOBAL.NOMU_QA.DATA.SCHEMES)
        end))
    end)

    self.scheme_list = self.root:AddChild(NoMuList(function()
        local item = Widget('scheme-list-item')
        item.backing = item:AddChild(TEMPLATES.ListItemBackground(200, 40, function()
        end))
        item.backing.move_on_click = true

        item.text = item:AddChild(Text(BODYTEXTFONT, 20, nil, UICOLOURS.WHITE))

        item.delete = item:AddChild(TextButton())
        item.delete:SetFont(CHATFONT)
        item.delete:SetTextSize(20)
        item.delete:SetText(STRINGS.NOMU_QA.BUTTON_TEXT_DELETE)
        item.delete:SetPosition(70, 0, 0)
        item.delete:SetTextFocusColour({ 1, 1, 1, 1 })
        item.delete:SetTextColour({ 1, 0, 0, 1 })
        item.delete:Hide()

        item.rename = item:AddChild(TextButton())
        item.rename:SetFont(CHATFONT)
        item.rename:SetTextSize(20)
        item.rename:SetText(STRINGS.NOMU_QA.BUTTON_TEXT_RENAME)
        item.rename:SetPosition(-70, 0, 0)
        item.rename:SetTextFocusColour({ 1, 1, 1, 1 })
        item.rename:SetTextColour({ 0, 1, 0, 1 })
        item.rename:Hide()

        function item:OnGainFocus()
            self.delete:Show()
            if not item.no_rename then
                item.rename:Show()
            end
        end

        function item:OnLoseFocus()
            self.delete:Hide()
            if not item.no_rename then
                item.rename:Hide()
            end
        end

        item.SetInfo = function(_, data)
            item.text:SetString(data.name)
            item.backing:SetOnClick(function()
                self:RefreshScheme(data.idx)
            end)

            if data.idx == 1 then
                item.rename:Hide()
                item.no_rename = true
                item.delete:SetText(STRINGS.NOMU_QA.BUTTON_TEXT_RESET)
                item.delete:SetOnClick(function()
                    TheFrontEnd:PushScreen(ConfirmDialog(nil, STRINGS.NOMU_QA.TITLE_TEXT_SURE_TO_RESET_DEFAULT, function()
                        GLOBAL.NOMU_QA.DATA.SCHEMES[1].data = json.decode(json.encode(GLOBAL.STRINGS.DEFAULT_NOMU_QA))
                        GLOBAL.NOMU_QA.SaveData()
                        self:RefreshScheme(1)
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
                    TheFrontEnd:PushScreen(GetInputString(nil, STRINGS.NOMU_QA.BUTTON_TEXT_RENAME, data.name, function(value)
                        GLOBAL.NOMU_QA.DATA.SCHEMES[data.idx].name = value
                        GLOBAL.NOMU_QA.SaveData()
                        self:RefreshSchemeList()
                        self:RefreshScheme(data.idx)
                    end))
                end)
            end
        end

        item.focus_forward = item.backing
        return item
    end, sx + 100, -20, 200, 40, 1, 9))

    self.AddButton(sx + 100, -sy, 200, 40, STRINGS.NOMU_QA.BUTTON_TEXT_IMPORT_SCHEME, function()
        TheFrontEnd:PushScreen(GetInputString(nil, STRINGS.NOMU_QA.TITLE_TEXT_SCHEME_FILENAME, '', function(filename)
            if string.sub(filename, -5) ~= '.json' then
                TheFrontEnd:PushScreen(ConfirmDialog(nil, STRINGS.NOMU_QA.JSON_NEEDED, function() end))
                return
            end
            local file = io.open('unsafedata/' .. filename)
            if file then
                local json_str = file:read('*a')
                file:close()
                local scheme = json.decode(json_str)
                if ValidateScheme(scheme) then
                    table.insert(GLOBAL.NOMU_QA.DATA.SCHEMES, scheme)
                    GLOBAL.NOMU_QA.SaveData()
                    self:RefreshSchemeList()
                    self:RefreshScheme(#GLOBAL.NOMU_QA.DATA.SCHEMES)
                    ThePlayer.components.talker:Say(STRINGS.NOMU_QA.MESSAGE_IMPORT_SUCCEED)
                    return
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

    --self.AddButton(sx + 100, sy - dy, 200, 40, STRINGS.NOMU_QA.BUTTON_TEXT_RESET_SCHEME, function()
    --    TheFrontEnd:PushScreen(ConfirmDialog(nil, subfmt(STRINGS.NOMU_QA.TITLE_TEXT_SURE_TO_RESET_SCHEME, { NAME = self.scheme.name }), function()
    --        if self.scheme_idx == 1 then
    --            GLOBAL.NOMU_QA.DATA.SCHEMES[1].data = json.decode(json.encode(GLOBAL.STRINGS.DEFAULT_NOMU_QA))
    --            GLOBAL.NOMU_QA.SaveData()
    --        end
    --        self:RefreshScheme()
    --    end))
    --end)

    self.AddButton(sx + 300, -sy, 200, 40, STRINGS.NOMU_QA.BUTTON_TEXT_APPLY_SCHEME, function()
        TheFrontEnd:PushScreen(ConfirmDialog(nil, subfmt(STRINGS.NOMU_QA.TITLE_TEXT_SURE_TO_APPLY_SCHEME, { NAME = self.scheme.name }), function()
            GLOBAL.NOMU_QA.DATA.CURRENT_SCHEME = GLOBAL.NOMU_QA.DATA.SCHEMES[self.scheme_idx]
            GLOBAL.NOMU_QA.SaveData()
            GLOBAL.NOMU_QA.ApplyScheme(GLOBAL.NOMU_QA.DATA.CURRENT_SCHEME)
        end))
    end)

    --self.AddButton(sx + 300, sy - dy, 200, 40, STRINGS.NOMU_QA.BUTTON_TEXT_SAVE_SCHEME, function()
    --    TheFrontEnd:PushScreen(ConfirmDialog(nil, subfmt(STRINGS.NOMU_QA.TITLE_TEXT_SURE_TO_SAVE_SCHEME, { NAME = self.scheme.name }), function()
    --        GLOBAL.NOMU_QA.DATA.SCHEMES[self.scheme_idx] = json.decode(json.encode(self.scheme))
    --        GLOBAL.NOMU_QA.SaveData()
    --    end))
    --end)
    --
    --self.AddButton(sx + 500, sy - dy, 200, 40, STRINGS.NOMU_QA.BUTTON_TEXT_SAVE_AND_APPLY_SCHEME, function()
    --    TheFrontEnd:PushScreen(ConfirmDialog(nil, subfmt(STRINGS.NOMU_QA.TITLE_TEXT_SURE_TO_SAVE_APPLY_SCHEME, { NAME = self.scheme.name }), function()
    --        GLOBAL.NOMU_QA.DATA.SCHEMES[self.scheme_idx] = json.decode(json.encode(self.scheme))
    --        GLOBAL.NOMU_QA.DATA.CURRENT_SCHEME = GLOBAL.NOMU_QA.DATA.SCHEMES[self.scheme_idx]
    --        GLOBAL.NOMU_QA.SaveData()
    --        GLOBAL.NOMU_QA.ApplyScheme(GLOBAL.NOMU_QA.DATA.CURRENT_SCHEME)
    --end)

    local function save_and_apply()
        GLOBAL.NOMU_QA.DATA.SCHEMES[self.scheme_idx] = json.decode(json.encode(self.scheme))
        GLOBAL.NOMU_QA.DATA.CURRENT_SCHEME = GLOBAL.NOMU_QA.DATA.SCHEMES[self.scheme_idx]
        GLOBAL.NOMU_QA.SaveData()
        GLOBAL.NOMU_QA.ApplyScheme(GLOBAL.NOMU_QA.DATA.CURRENT_SCHEME)
    end

    self.AddButton(sx + 100, -sy, 200, 40, STRINGS.NOMU_QA.BUTTON_TEXT_EXPORT_SCHEME, function()
        TheFrontEnd:PushScreen(GetInputString(nil, STRINGS.NOMU_QA.TITLE_TEXT_SCHEME_FILENAME, '', function(filename)
            if string.sub(filename, -5) ~= '.json' then
                TheFrontEnd:PushScreen(ConfirmDialog(nil, STRINGS.NOMU_QA.JSON_NEEDED, function() end))
                return
            end
            local json_str = json.encode(GLOBAL.NOMU_QA.DATA.SCHEMES[self.scheme_idx])
            local file = io.open('unsafedata/' .. filename, 'w')
            if file then
                file:write(json_str)
                file:close()
                ThePlayer.components.talker:Say(STRINGS.NOMU_QA.MESSAGE_EXPORT_SUCCEED)
            else
                ThePlayer.components.talker:Say(STRINGS.NOMU_QA.MESSAGE_EXPORT_FAILED)
            end
        end))
    end)

    self.AddButton(sx + 500, -sy, 200, 40, STRINGS.NOMU_QA.BUTTON_TEXT_CLOSE, function()
        self:Close()
    end)

    self.title_text_func = self.root:AddChild(Text(BODYTEXTFONT, 32))
    self.title_text_func:SetHAlign(ANCHOR_MIDDLE)
    self.title_text_func:SetRegionSize(120, dy)
    self.title_text_func:SetPosition(sx + 60, sy - dy)
    self.title_text_func:SetString(STRINGS.NOMU_QA.TITLE_TEXT_FUNC)

    self.func_list = self.root:AddChild(NoMuList(function()
        local item = Widget('func-list-item')
        item.backing = item:AddChild(TEMPLATES.ListItemBackground(120, 40, function()
        end))
        item.backing.move_on_click = true

        item.text = item:AddChild(Text(BODYTEXTFONT, 20, nil, UICOLOURS.WHITE))

        item.SetInfo = function(_, func)
            item.text:SetString(STRINGS.NOMU_QA.FUNC[func])
            item.backing:SetOnClick(function()
                self:RefreshFunc(func)
            end)
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
        item.backing = item:AddChild(TEMPLATES.ListItemBackground(420, 40, function()
        end))
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
                self.scheme.data[self.scheme_func].MAPPINGS[mapping] = json.decode(json.encode(self.scheme.data[self.scheme_func].MAPPINGS.DEFAULT))
            end
            self:RefreshFunc(nil, mapping)
        end))
    end)

    if not GLOBAL.NOMU_QA.DATA.CHARACTER_SPECIFIC then
        self.btn_mapping:Disable()
    end

    self.mapping_list = self.root:AddChild(NoMuList(function()
        local item = Widget('mapping-list-item')
        item.backing = item:AddChild(TEMPLATES.ListItemBackground(420, 40, function()
        end))
        item.backing.move_on_click = true

        item.text = item:AddChild(Text(BODYTEXTFONT, 20, nil, UICOLOURS.WHITE))

        item.SetInfo = function(_, mapping)
            item.text:SetString(mapping.category .. '-' .. mapping.name .. ': ' .. mapping.value)
            item.backing:SetOnClick(function()
                TheFrontEnd:PushScreen(GetInputString(nil, mapping.category .. '-' .. mapping.name, mapping.value, function(value)
                    self.scheme.data[self.scheme_func].MAPPINGS[self.scheme_mapping][mapping.category][mapping.name] = value
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
    local scheme_list = {}
    for idx, scheme in ipairs(GLOBAL.NOMU_QA.DATA.SCHEMES) do
        table.insert(scheme_list, { idx = idx, name = scheme.name })
    end
    self.scheme_list:Refresh(scheme_list)
end

function QACustomizePanel:RefreshScheme(idx)
    self.scheme_idx = idx or self.scheme_idx
    self.scheme = json.decode(json.encode(GLOBAL.NOMU_QA.DATA.SCHEMES[self.scheme_idx]))
    self.title_text_editing:SetString(STRINGS.NOMU_QA.TITLE_TEXT_EDITING .. self.scheme.name)
    local func_list = {}
    for func in pairs(self.scheme.data) do
        table.insert(func_list, func)
    end
    self.func_list:Refresh(func_list)
    self:RefreshFunc(func_list[1], 'DEFAULT')
end

function QACustomizePanel:RefreshFunc(func, mapping)
    self.scheme_func = func or self.scheme_func
    self.title_text_format:SetString(subfmt(STRINGS.NOMU_QA.TITLE_TEXT_FORMAT, { NAME = STRINGS.NOMU_QA.FUNC[self.scheme_func] }))
    local format_list = {}
    for name, format in pairs(self.scheme.data[self.scheme_func].FORMATS) do
        table.insert(format_list, { name = name, value = format })
    end

    local mapping_list = {}
    if self.scheme.data[self.scheme_func].MAPPINGS.DEFAULT then
        self.scheme_mapping = mapping or self.scheme_mapping
        if not self.scheme.data[self.scheme_func].MAPPINGS[self.scheme_mapping] then
            self.scheme_mapping = 'DEFAULT'
        end
        self.mapping_list:Show()
        self.btn_mapping:Show()
        self.btn_mapping:SetText(subfmt(STRINGS.NOMU_QA.BUTTON_TEXT_MAPPING, {
            NAME = (self.scheme_mapping == 'DEFAULT' and STRINGS.NOMU_QA.TITLE_TEXT_MAPPING_DEFAULT or STRINGS.NAMES[self.scheme_mapping] or self.scheme_mapping)
        }))
        for category, items in pairs(self.scheme.data[self.scheme_func].MAPPINGS[self.scheme_mapping]) do
            for name, value in pairs(items) do
                table.insert(mapping_list, { category = category, name = name, value = value })
            end
        end
    else
        self.mapping_list:Hide()
        self.btn_mapping:Hide()
    end

    local n_format = math.min(8 - math.min(#mapping_list, 4), #format_list)
    self.format_list:Refresh(format_list, {
        rows = n_format, y = self.sy - self.dy * (1.5 + 0.5 * n_format)
    })

    self.btn_mapping:SetPosition(self.sx + 630, self.sy - (2 + n_format) * self.dy)

    local n_mapping = 8 - n_format
    self.mapping_list:Refresh(mapping_list, {
        rows = n_mapping, y = self.sy - (2.5 + 0.5 * n_mapping + n_format) * self.dy
    })
end

local QAPanel = Class(Widget, function(self)
    local width, height = 400, 480
    local sy = height / 2 - 20
    local dy = 40

    Widget._ctor(self, "QAPanel")

    self.root = self:AddChild(TEMPLATES.RectangleWindow(width, height + 10))
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetPosition(0, 0)

    local function AddButton(x, y, w, h, text, fn)
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

    self.title_text = self.root:AddChild(Text(BODYTEXTFONT, 32))
    self.title_text:SetString(STRINGS.NOMU_QA.TITLE_TEXT_QA)
    self.title_text:SetHAlign(ANCHOR_MIDDLE)
    self.title_text:SetRegionSize(width, dy)
    self.title_text:SetPosition(0, sy)

    AddButton(-100, sy - dy, 200, dy, STRINGS.NOMU_QA.BUTTON_TEXT_NEW_FREQ, function()
        TheFrontEnd:PushScreen(GetInputString(self, STRINGS.NOMU_QA.BUTTON_TEXT_NEW_FREQ, '', function(value)
            table.insert(GLOBAL.NOMU_QA.DATA.FREQ_LIST, value)
            GLOBAL.NOMU_QA.SaveData()
            self:Refresh()
        end, 256, 420))
    end)

    AddButton(100, sy - dy, 200, dy, STRINGS.NOMU_QA.BUTTON_TEXT_CUSTOMIZE, function()
        TheFrontEnd:PushScreen(QACustomizePanel(self))
    end)

    self.freq_list = self.root:AddChild(NoMuList(function()
        local item = Widget('freq-list-item')
        item.backing = item:AddChild(TEMPLATES.ListItemBackground(200, 40, function()
        end))
        item.backing.move_on_click = true

        item.text = item:AddChild(Text(BODYTEXTFONT, 20, nil, UICOLOURS.WHITE))

        item.delete = item:AddChild(TextButton())
        item.delete:SetFont(CHATFONT)
        item.delete:SetTextSize(20)
        item.delete:SetText(STRINGS.NOMU_QA.BUTTON_TEXT_DELETE)
        item.delete:SetPosition(80, 0, 0)
        item.delete:SetTextFocusColour({ 1, 1, 1, 1 })
        item.delete:SetTextColour({ 1, 0, 0, 1 })
        item.delete:Hide()

        function item:OnGainFocus()
            self.delete:Show()
        end

        function item:OnLoseFocus()
            self.delete:Hide()
        end

        item.SetInfo = function(_, data)
            item.text:SetString(data.freq)
            item.backing:SetOnClick(function()
                Announce(data.freq)
                if GLOBAL.NOMU_QA.DATA.FREQ_AUTO_CLOSE then
                    self:Hide()
                end
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
    end, 0, 0, 200, 40, 2, 8))

    AddButton(-100, -sy, 200, dy, STRINGS.NOMU_QA.BUTTON_TEXT_OPTIONS, function()
        TheFrontEnd:PushScreen(QAConfigPanel(self))
    end)

    AddButton(100, -sy, 200, dy, STRINGS.NOMU_QA.BUTTON_TEXT_CLOSE, function()
        self:Hide()
    end)

    self:Refresh()
end)

function QAPanel:Refresh()
    local freq_list = {}
    for idx, freq in ipairs(GLOBAL.NOMU_QA.DATA.FREQ_LIST) do
        table.insert(freq_list, { idx = idx, freq = freq })
    end
    self.freq_list:Refresh(freq_list)
end

function QAPanel:OnGainFocus()
    self.camera_controllable_reset = TheCamera:IsControllable()
    TheCamera:SetControllable(false)
end

function QAPanel:OnLoseFocus()
    TheCamera:SetControllable(self.camera_controllable_reset)
end

function QAPanel:OnControl(control, down)
    if QAPanel._base.OnControl(self, control, down) then
        return true
    end
    if not down then
        if control == CONTROL_PAUSE or control == CONTROL_CANCEL then
            self:Hide()
        end
    end
    return true
end

local controls
AddClassPostConstruct("widgets/controls", function(self)
    controls = self
    if controls and controls.top_root then
        controls.nomu_qa_panel = controls.top_root:AddChild(QAPanel())
        controls.nomu_qa_panel:Hide()
    end
end)

local key_toggle = GetModConfigData("key_toggle") ~= -1 and GLOBAL[GetModConfigData("key_toggle")] or -1
TheInput:AddKeyUpHandler(key_toggle, function()
    if IsDefaultScreen() then
        if controls and controls.nomu_qa_panel then
            if controls.nomu_qa_panel.shown then
                controls.nomu_qa_panel:Hide()
            else
                controls.nomu_qa_panel:Show()
            end
        end
    end
end)
