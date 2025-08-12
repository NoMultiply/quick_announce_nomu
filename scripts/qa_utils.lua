GLOBAL.QA_UTILS = {
    -- 降雨预测
    PredictRainStart = function()
        local MOISTURE_RATES = {
            MIN = { autumn = .25, winter = .25, spring = 3, summer = .1 },
            MAX = { autumn = 1.0, winter = 1.0, spring = 3.75, summer = .5 }
        }
        local world = TheWorld.net.components.weather ~= nil and "SURFACE" or "CAVES"
        local remainingsecondsinday = TUNING.TOTAL_DAY_TIME - (TheWorld.state.time * TUNING.TOTAL_DAY_TIME)
        local totalseconds = 0
        local rain = false

        local season = TheWorld.state.season
        local seasonprogress = TheWorld.state.seasonprogress
        local elapseddaysinseason = TheWorld.state.elapseddaysinseason
        local remainingdaysinseason = TheWorld.state.remainingdaysinseason
        local totaldaysinseason = remainingdaysinseason / (1 - seasonprogress)
        local _totaldaysinseason = elapseddaysinseason + remainingdaysinseason

        local moisture = TheWorld.state.moisture
        local moistureceil = TheWorld.state.moistureceil

        while elapseddaysinseason < _totaldaysinseason do
            local moisturerate

            if world == "Surface" and season == "winter" and elapseddaysinseason == 2 then
                moisturerate = 50
            else
                local p = 1 - math.sin(PI * seasonprogress)
                moisturerate = MOISTURE_RATES.MIN[season] + p * (MOISTURE_RATES.MAX[season] - MOISTURE_RATES.MIN[season])
            end

            local _moisture = moisture + (moisturerate * remainingsecondsinday)

            if _moisture >= moistureceil then
                totalseconds = totalseconds + ((moistureceil - moisture) / moisturerate)
                rain = true
                break
            else
                moisture = _moisture
                totalseconds = totalseconds + remainingsecondsinday
                remainingsecondsinday = TUNING.TOTAL_DAY_TIME
                elapseddaysinseason = elapseddaysinseason + 1
                remainingdaysinseason = remainingdaysinseason - 1
                seasonprogress = 1 - (remainingdaysinseason / totaldaysinseason)
            end
        end
        return world, totalseconds, rain
    end,

    -- 停雨预测
    PredictRainStop = function()
        local PRECIP_RATE_SCALE = 10
        local MIN_PRECIP_RATE = .1

        local world = TheWorld.net.components.weather ~= nil and "SURFACE" or "CAVES"
        local dbgstr = (TheWorld.net.components.weather ~= nil and TheWorld.net.components.weather:GetDebugString()) or
                TheWorld.net.components.caveweather:GetDebugString()
        local _, _, moisture, moisturefloor, moistureceil, _, preciprate, peakprecipitationrate = string.find(
                dbgstr, "[.\n]*moisture: (%d+.%d+) %((%d+.%d+)/(%d+.%d+)%) %+ (%d+.%d+)[.%s]*preciprate: %((%d+.%d+) of (%d+.%d+)%)[.\n]*")
        --print(dbgstr)
        --print(string.find(dbgstr, "[.\n]*moisture: (%d+.%d+) %((%d+.%d+)/(%d+.%d+)%) %+ (%d+.%d+)[.%s]*preciprate: %((%d+.%d+) of (%d+.%d+)%)[.\n]*"))
        --print('>>>', moisture, moisturefloor, moistureceil, preciprate, peakprecipitationrate)

        moisture = tonumber(moisture)
        moistureceil = tonumber(moistureceil)
        moisturefloor = tonumber(moisturefloor)
        preciprate = tonumber(preciprate)
        peakprecipitationrate = tonumber(peakprecipitationrate)

        local totalseconds = 0

        if moisture == nil or moisturefloor == nil then
            return world, 0
        end
        while moisture > moisturefloor do
            if preciprate > 0 then
                local p = math.max(0, math.min(1, (moisture - moisturefloor) / (moistureceil - moisturefloor)))
                local rate = MIN_PRECIP_RATE + (1 - MIN_PRECIP_RATE) * math.sin(p * PI)

                preciprate = math.min(rate, peakprecipitationrate)
                moisture = math.max(moisture - preciprate * FRAMES * PRECIP_RATE_SCALE, 0)

                totalseconds = totalseconds + FRAMES
            else
                break
            end
        end
        return world, totalseconds
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

AddComponentPostInit('clock', function(clock)
    local oldGetDebugString = clock.GetDebugString
    local oldDump = clock.Dump
    local name, value

    name, value = debug.getupvalue(oldGetDebugString, 3)
    local _phase
    if name == '_phase' then
        clock._phase = value
        _phase = value
    end

    local _remainingtimeinphase
    name, value = debug.getupvalue(oldGetDebugString, 4)
    if name == '_remainingtimeinphase' then
        clock._remainingtimeinphase = value
        _remainingtimeinphase = value
    end

    local _segs
    name, value = debug.getupvalue(oldDump, 2)
    if name == '_segs' then
        _segs = value
    end

    local _totaltimeinphase
    name, value = debug.getupvalue(oldDump, 9)
    if name == '_totaltimeinphase' then
        _totaltimeinphase = value
    end

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

