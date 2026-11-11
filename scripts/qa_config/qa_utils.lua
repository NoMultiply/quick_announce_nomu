-- 季节顺序与积水曲线只定义一次，预测时直接复用
local CYCLES = {
    SURFACE = { "autumn", "winter", "spring", "summer" },
    SHIPWRECKED = { "mild", "wet", "green", "dry" },
    PORKLAND = { "temperate", "humid", "lush" },
    BWB = { "tranquil", "frost", "verdant", "umbral" },
}
local RATES = {
    autumn = { .25, 1 }, winter = { .25, 1 }, spring = { 3, 3.75 }, summer = { .1, .5 },
    mild = { 0, .1 }, wet = { 3, 3.75 }, green = { 3, 3.75 }, dry = { 0, -.2 },
    temperate = { .25, 1 }, humid = { 3, 3.75 }, lush = { 0, -.2 }, aporkalypse = { 0, 0 },
    tranquil = { .25, 1 }, frost = { .25, 1 }, verdant = { 3, 3.75 }, umbral = { .1, .5 },
}

local WEATHER_FIELDS = { "moisture", "moisturefloor", "moistureceil", "moisturerate",
    "peakprecipitationrate", "precipmode", "preciptype" }
local HURRICANE_FIELDS = { "hurricane", "hurricane_timer", "hurricane_duration", "hurricanetease_start" }

local function IsNumber(value)
    return type(value) == "number" and value == value and math.abs(value) < math.huge
end

local function ReadNet(fn, name)
    if type(fn) ~= "function" then return end
    local value = Upvaluehelper.GetUpvalue(fn, name)
    if value and type(value.value) == "function" then return value:value() end
end

-- 选择当前世界的天气组件，读取原始同步值，避免调试文本取整造成误差
local function ReadWeather(world)
    local components = TheWorld and TheWorld.net and TheWorld.net.components
    if not components then return end

    local component
    if world == "PORKLAND" then
        component = components.plateauweather
    elseif world == "SHIPWRECKED" or world == "VOLCANO" then
        component = components.shipwreckedweather
    elseif world == "CAVES" then
        component = components.caveweather or components.weather
    else
        component = components.weather
    end
    if not component or type(component.OnUpdate) ~= "function" then return end

    local fn = component.OnUpdate
    local data = { fn = fn }
    for _, key in ipairs(WEATHER_FIELDS) do
        data[key] = ReadNet(fn, "_" .. key)
    end
    if world == "SHIPWRECKED" or world == "VOLCANO" then
        for _, key in ipairs(HURRICANE_FIELDS) do
            data[key] = ReadNet(fn, "_" .. key)
        end
    end
    data.modes = Upvaluehelper.GetUpvalue(fn, "PRECIP_MODES")
    data.types = Upvaluehelper.GetUpvalue(fn, "PRECIP_TYPES")
    return data
end

-- 同时供降雨和海难停雨预测使用；直接读取时钟上值，不调用 GetDebugString
local function ReadSeasons(world)
    local state = TheWorld.state
    local cycle, clock = CYCLES.SURFACE, "default"
    if world == "SHIPWRECKED" or world == "VOLCANO" then
        cycle, clock = CYCLES.SHIPWRECKED, "tropical"
    elseif world == "PORKLAND" then
        cycle, clock = CYCLES.PORKLAND, "plateau"
    elseif state.season == "tranquil" or state.season == "frost"
        or state.season == "verdant" or state.season == "umbral" then
        cycle = CYCLES.BWB
    end

    local component = TheWorld.net.components.seasons
    local fn = component and (component["GetDebugString_" .. clock] or component.GetDebugString)
    if type(fn) ~= "function" then return end
    local names = Upvaluehelper.GetUpvalue(fn, "SEASON_NAMES")
    local index = ReadNet(fn, "_season")
    local season = names and index and names[index] or state.season
    local remaining = ReadNet(fn, "_remainingdaysinseason") or state.remainingdaysinseason
    local total = ReadNet(fn, "_totaldaysinseason")
    if not total and IsNumber(state.seasonprogress) and state.seasonprogress < 1 then
        total = remaining and remaining / (1 - state.seasonprogress)
    end
    if season ~= state.season then return end -- 时钟与当前世界不匹配时不跨天外推
    local elapsed = ReadNet(fn, "_elapseddaysinseason") or state.elapseddaysinseason
    if not IsNumber(total) or total <= 0 or not IsNumber(remaining) or not IsNumber(elapsed) then return end
    local lengths, count, onlyseason = {}, 0, nil
    for _, name in ipairs(cycle) do
        lengths[name] = state[name .. "length"]
        if IsNumber(lengths[name]) and lengths[name] > 0 then count, onlyseason = count + 1, name end
    end
    -- mode/premode 没有直接同步；根据网络中的永久标记与启用季节推断常规配置
    local endless = ReadNet(fn, "_endlessdaysinseason")
    if type(endless) ~= "boolean" then return end -- 不把未知的永久模式当成循环模式
    local mode = "cycle"
    local premode = not endless and count == 1 and onlyseason ~= season
    if endless then
        mode = total == 2 and "always" or "endless"
    elseif premode then
        mode = "endless"
    end
    return { season = season, total = total, remaining = remaining, elapsed = elapsed,
        lengths = lengths, cycle = cycle, mode = mode, premode = premode }
end

-- 跳过长度为 0 的季节；缺少长度时不继续猜测
local function NextSeason(seasons, season)
    for index, name in ipairs(seasons.cycle) do
        if name == season then
            for offset = 1, #seasons.cycle do
                local nextseason = seasons.cycle[(index + offset - 1) % #seasons.cycle + 1]
                local length = seasons.lengths[nextseason]
                if not IsNumber(length) then return end -- 缺少季节长度时，不猜测下一季
                if length > 0 then return nextseason end
            end
            return season
        end
    end
end

-- 计算当天未乘降雨倍率的积水速度；第二返回值表示冬季固定加水
local function BaseRate(season, elapsed, remaining, total, lengths, world)
    local limits = RATES[season]
    if not limits then return end
    if world == "SURFACE" and season == "winter" and elapsed == 2 then return 50, true end
    if season == "green" and elapsed <= 5 then return 0 end
    local progress = 1 - remaining / total
    if season == "green" then
        local length = lengths.green
        if not IsNumber(length) or length <= 5 then return end
        progress = (elapsed - 5) / (length - 5)
    elseif season == "wet" or season == "humid" then
        progress = progress * 1.5
    end
    return limits[1] + (1 - math.sin(math.pi * progress)) * (limits[2] - limits[1])
end

-- 预告风暴剩余秒数：0 表示客户端无法确认，math.huge 表示当前季节无需考虑
local function TeaseTime(data, seasons)
    if not seasons or seasons.season ~= "mild" then return math.huge end
    local percent = data.hurricanetease_start
    local minimum = TUNING.HURRICANE_TEASE_PERCENT_START_MIN
    if not IsNumber(percent) or percent <= 0 or not IsNumber(minimum) then return 0 end
    local function TriggerDay(p)
        if seasons.mode == "cycle" or seasons.premode then
            return math.ceil((seasons.elapsed + seasons.remaining) * p)
        end
        return p < 1 and math.ceil(10000 * p / (1 - p)) or math.huge
    end
    -- 已触发标记不在客户端同步；过了最早可能触发日后，非零日期也可能是已用过的重抽日期
    if seasons.elapsed >= TriggerDay(minimum) then return 0 end
    return math.max(0, (TriggerDay(percent) - seasons.elapsed - TheWorld.state.time) * TUNING.TOTAL_DAY_TIME)
end

------------------------------------------------------------------------------------------------------------------------

GLOBAL.QA_UTILS = {
    IsAltPressed = function()
        local mode = (GLOBAL.NOMU_QA and GLOBAL.NOMU_QA.DATA and GLOBAL.NOMU_QA.DATA.ALT_MODE) or 1
        if mode == 1 then
            return GLOBAL.TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT)
        elseif mode == 2 then
            return GLOBAL.TheInput:IsKeyDown(GLOBAL.KEY_LALT)
        else
            return GLOBAL.TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT)
                or GLOBAL.TheInput:IsKeyDown(GLOBAL.KEY_LALT)
        end
    end,

    IsShiftPressed = function()
        local mode = (GLOBAL.NOMU_QA and GLOBAL.NOMU_QA.DATA and GLOBAL.NOMU_QA.DATA.SHIFT_MODE) or 1
        if mode == 1 then
            return GLOBAL.TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_TRADE)
        elseif mode == 2 then
            return GLOBAL.TheInput:IsKeyDown(GLOBAL.KEY_LSHIFT)
        else
            return GLOBAL.TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_TRADE)
                or GLOBAL.TheInput:IsKeyDown(GLOBAL.KEY_LSHIFT)
        end
    end,

    GetWorldType = function()
        if not GLOBAL.TheWorld then return "SURFACE" end
        return GLOBAL.TheWorld:HasTag("porkland") and "PORKLAND"
        or GLOBAL.TheWorld:HasTag("island") and "SHIPWRECKED"
        or GLOBAL.TheWorld:HasTag("volcano") and "VOLCANO"
        or GLOBAL.TheWorld:HasTag("cave") and "CAVES"
        or "SURFACE"
    end,

    GetWorldLocalizedName = function()
        local world = GLOBAL.QA_UTILS.GetWorldType()
        local dict = GLOBAL.STRINGS.DEFAULT_NOMU_QA.WORLD_TEMPERATURE_AND_RAIN.MAPPINGS.DEFAULT.WORLD
        return dict and dict[world] or "未知"
    end,
    -- 孢子雾预测
    PredictFungusFog = function()
        if not GLOBAL.TheWorld then
            return false, -1
        end
        local fungusfog = GLOBAL.TheWorld.net and GLOBAL.TheWorld.net.components.fungusfog
        if not fungusfog then
            return false, -1
        end

        local is_active = fungusfog.net_fungusfogactive and fungusfog.net_fungusfogactive:value() or false
        local cd = fungusfog.net_fungusfogcd and fungusfog.net_fungusfogcd:value() or -1

        return is_active, cd
    end,

    -- 降雨预测：读取同步值 → 逐日累积水分 → 检查特殊事件，第四返回值表示暂无法预测
    PredictRainStart = function()
        local world = GLOBAL.QA_UTILS.GetWorldType()
        local data = ReadWeather(world)
        if not data or not data.modes then return world, nil, false, true end
        if data.precipmode == data.modes.never then return world, nil, false end
        if data.precipmode ~= data.modes.dynamic or not data.types or data.preciptype ~= data.types.none then
            return world, nil, false, true
        end
        if not IsNumber(data.moisture) or not IsNumber(data.moistureceil) or data.moistureceil <= 0
            or not IsNumber(data.moisturerate) or not IsNumber(data.moisturefloor) then
            return world, nil, false, true
        end
        local seasons = ReadSeasons(world)
        local seconds
        local needed = data.moistureceil - data.moisture
        local rate = data.moisturerate
        local duration = (1 - TheWorld.state.time) * TUNING.TOTAL_DAY_TIME

        -- 今天使用同步的实际速率；能在今天积满水时，不需要外推后续季节
        if needed <= 0 then
            seconds = 0
        elseif rate > 0 and needed <= rate * duration then
            seconds = needed / rate
        elseif seasons then
            local season, remaining = seasons.season, seasons.remaining
            local elapsed, total = seasons.elapsed, seasons.total
            local mode, premode = seasons.mode, seasons.premode
            local base, fixed = BaseRate(season, elapsed, remaining, total, seasons.lengths, world)
            -- 普通日可反推降雨倍率；零速率或冬季固定加水日无法反推
            local multiplier = base and not fixed and math.abs(base) > 1e-8 and rate / base or nil
            local floor = (world == "SHIPWRECKED" or world == "VOLCANO") and data.moisturefloor or 0
            local totalseconds = 0

            if not multiplier or IsNumber(multiplier) and multiplier >= 0 then
                for _ = 1, 1024 do
                    if rate > 0 and needed <= rate * duration then
                        seconds = totalseconds + needed / rate
                        break
                    end
                    needed = math.min(data.moistureceil - floor, needed - rate * duration)
                    totalseconds = totalseconds + duration
                    elapsed = elapsed + 1

                    -- 推进到下一天；永久季节保持进度，无尽季节在中点停止推进
                    if mode == "cycle" or premode then
                        remaining = remaining - 1
                        if remaining <= 0 then
                            if season == "aporkalypse" then break end
                            season = NextSeason(seasons, season)
                            if not season or season == "mild" then break end -- 下一轮温和季风暴日期未知
                            total = mode == "endless" and 20 or seasons.lengths[season]
                            remaining, elapsed, premode = total, 0, false
                        end
                    elseif mode == "endless" and remaining > 10 then
                        remaining = math.max(remaining - 1, 10)
                    end

                    base, fixed = BaseRate(season, elapsed, remaining, total, seasons.lengths, world)
                    if not base then break end
                    if fixed then
                        rate = base -- 冬季第 3 天固定加水 50/秒，不乘倍率
                    elseif base == 0 then
                        rate = 0
                    elseif multiplier then
                        rate = base * multiplier
                    else
                        break -- 无法确定未来速率，不提供虚假的倒计时
                    end
                    duration = TUNING.TOTAL_DAY_TIME
                end
            end
        end

        -- 普通积水算完后，再处理会改变下一场雨时间的风暴或灾变
        if world == "SHIPWRECKED" or world == "VOLCANO" then
            local tease = TeaseTime(data, seasons)
            if tease == 0 then seconds = nil
            elseif tease < math.huge then seconds = math.min(seconds or math.huge, tease) end
            if not seasons then seconds = nil end
        elseif world == "PORKLAND" and seconds then
            local apocalypse = TheWorld.net.components.aporkalypse
            local untilapocalypse = apocalypse and ReadNet(apocalypse.OnUpdate, "_timeuntilaporkalypse")
            if not IsNumber(untilapocalypse) or untilapocalypse <= seconds and seasons and seasons.season ~= "aporkalypse" then
                seconds = nil
            end
        end
        return world, seconds, IsNumber(seconds), not IsNumber(seconds)
    end,

    -- 停雨预测：先判断玻璃雨和飓风，再计算普通降水的耗水时间
    PredictRainStop = function()
        local world = GLOBAL.QA_UTILS.GetWorldType()
        local data = ReadWeather(world)
        if not data or not data.modes or data.precipmode ~= data.modes.dynamic or not data.types then return world end
        if data.types.lunarhail and data.preciptype == data.types.lunarhail then
            local level = ReadNet(data.fn, "_lunarhaillevel")
            local floor = Upvaluehelper.GetUpvalue(data.fn, "LUNAR_HAIL_FLOOR")
            local rates = Upvaluehelper.GetUpvalue(data.fn, "LUNAR_HAIL_EVENT_RATE")
            if IsNumber(level) and IsNumber(floor) and rates and IsNumber(rates.DURATION) and rates.DURATION > 0 then
                return world, math.max(0, (level - floor) / rates.DURATION)
            end
            return world
        end
        if data.preciptype == data.types.none then return world end
        local seasons, boundary, nextseason
        if world == "SHIPWRECKED" or world == "VOLCANO" then
            seasons = ReadSeasons(world)
            if not seasons then return world end

            -- 循环或过渡季节需要检查换季边界；永久季节不会因此截断风暴
            boundary = math.huge
            if seasons.mode == "cycle" or seasons.premode then
                nextseason = NextSeason(seasons, seasons.season)
                if not nextseason then
                    boundary = 0
                elseif nextseason ~= seasons.season then
                    boundary = math.max(0, (seasons.remaining - TheWorld.state.time) * TUNING.TOTAL_DAY_TIME)
                end
            end
            if data.hurricane then
                if not IsNumber(data.hurricane_duration) or not IsNumber(data.hurricane_timer) then return world end
                local seconds = math.max(0, data.hurricane_duration - data.hurricane_timer)
                if nextseason ~= "wet" then seconds = math.min(seconds, boundary) end
                return world, seconds
            end
        end
        if not IsNumber(data.moisture) or not IsNumber(data.moisturefloor) or not IsNumber(data.moistureceil)
            or data.moistureceil <= data.moisturefloor or not IsNumber(data.peakprecipitationrate)
            or data.peakprecipitationrate <= 0 then return world end
        -- 普通雨：水分降至下限就停雨，使用 256 段积分求耗水时间
        local range = data.moistureceil - data.moisturefloor
        local moisturefraction = math.min(1, (data.moisture - data.moisturefloor) / range)
        local peak = data.peakprecipitationrate
        local seconds = 0
        if moisturefraction > 0 then
            if peak <= .1 then
                seconds = moisturefraction * range / (peak * 10) -- 微雨全程按峰值匀速耗水
            else
                local step, sum = moisturefraction / 256, 0
                for i = 0, 256 do
                    local rate = math.min(.1 + .9 * math.sin(i * step * math.pi), peak)
                    local weight = (i == 0 or i == 256) and 1 or (i % 2 == 0 and 2 or 4)
                    sum = sum + weight / rate
                end
                seconds = sum * step / 3 * range / 10 -- 耗水速率为雨势 × 10
            end
        end
        if world == "SHIPWRECKED" or world == "VOLCANO" then
            -- 若普通雨会被风暴接管，原耗水曲线不能继续用于停雨预测
            if seasons.season == "wet" or TeaseTime(data, seasons) <= seconds
                or nextseason == "wet" and boundary <= seconds then return world end
        end
        return world, seconds
    end,
    -- 格式化降雨时间
    FormatSeconds = function(total_seconds)
        local d = TheWorld.state.cycles + 1 + TheWorld.state.time + (total_seconds / TUNING.TOTAL_DAY_TIME)
        local m = math.floor(total_seconds / 60)
        local s = total_seconds % 60
        return string.format('%.2f', d), string.format('%d', m), string.format('%d', s)
    end,
    -- 从hover里提取信息
    ParseHoverText = function(start_line, end_line, exclude, min_length)
        local text = ThePlayer and ThePlayer.HUD and ThePlayer.HUD.controls and ThePlayer.HUD.controls.hover and ThePlayer.HUD.controls.hover.text and ThePlayer.HUD.controls.hover.text.shown and ThePlayer.HUD.controls.hover.text:GetString() or ''
        local lines = string.split(text, '\n')
        local rs = {}
        if end_line and end_line < 0 then
            end_line = end_line + #lines
        end
        for idx, line in ipairs(lines) do
            if (start_line == nil or idx >= start_line) and (end_line == nil or idx <= end_line) and (exclude == nil or line:find(exclude) == nil) and (min_length == nil or #line >= min_length) then
                table.insert(rs, line)
            end
        end
        return rs
    end
}

------------------------------------------------------------------------------------------------------------------------

AddComponentPostInit('clock', function(clock)
    local SW = TheWorld:HasTag("island") or TheWorld:HasTag("volcano")
    local HAM = TheWorld:HasTag("porkland")
    local oldGetDebugString = SW and clock.GetDebugString_tropical or HAM and clock.GetDebugString_plateau or clock.GetDebugString
    local oldDump = SW and clock.Dump_tropical or HAM and clock.Dump_plateau or clock.Dump

    local value
    value = Upvaluehelper.GetUpvalue(oldGetDebugString, '_phase')
    local _phase
    clock._phase = value
    _phase = value

    local _remainingtimeinphase
    value = Upvaluehelper.GetUpvalue(oldGetDebugString, '_remainingtimeinphase')
    clock._remainingtimeinphase = value
    _remainingtimeinphase = value

    local _segs = Upvaluehelper.GetUpvalue(oldDump, '_segs')
    local _totaltimeinphase = Upvaluehelper.GetUpvalue(oldDump,'_totaltimeinphase')

    if _totaltimeinphase and _remainingtimeinphase and _segs and _phase then
        clock.CalcRemainTimeOfDay = function()
            local time_of_day = _totaltimeinphase:value() - _remainingtimeinphase:value()
            for i = 1, _phase:value() - 1 do
                time_of_day = time_of_day + _segs[i]:value() * TUNING.SEG_TIME
            end
            return TUNING.TOTAL_DAY_TIME - time_of_day
        end
    end
end)

AddComponentPostInit('nightmareclock', function(clock)
    local oldOnUpdate = clock.OnUpdate
    local name, value

    local _remainingtimeinphase
    name, value = debug.getupvalue(oldOnUpdate, 1)
    if name == '_remainingtimeinphase' then
        _remainingtimeinphase = value
    end

    local _phase
    name, value = debug.getupvalue(oldOnUpdate, 4)
    if name == '_phase' then
        _phase = value
    end

    local PHASE_NAMES
    name, value = debug.getupvalue(oldOnUpdate, 5)
    if name == 'PHASE_NAMES' then
        PHASE_NAMES = value
    end

    local _totaltimeinphase
    name, value = debug.getupvalue(oldOnUpdate, 7)
    if name == '_totaltimeinphase' then
        _totaltimeinphase = value
    end

    if _remainingtimeinphase and _phase and _totaltimeinphase and PHASE_NAMES then
        function TheWorld:GetNightmareData()
            return {
                phase = PHASE_NAMES[_phase:value()],
                remain = _remainingtimeinphase:value(),
                total = _totaltimeinphase:value()
            }
        end
    end
end)

AddClassPostConstruct("widgets/badge", function(self)
    local oldSetPercent = self.SetPercent
    function self:SetPercent(percent, max_health, ...)
        self.nomu_percent = percent
        self.nomu_max = max_health
        oldSetPercent(self, percent, max_health, ...)
    end
end)