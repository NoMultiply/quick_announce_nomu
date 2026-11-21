-- scripts/qa_hud_hooks.lua
-- 负责 HUD 状态栏点击分发、外部模组 UI 适配以及各类游戏界面的 Alt 快捷键注入

local QA = GLOBAL.NOMU_QA
local LOCAL_STRINGS = GLOBAL.STRINGS.NOMU_QA or {}
local DEBUG_STR = LOCAL_STRINGS.DEBUG or {}

local QA_DEFAULT_THRESHOLDS = { .15, .35, .55, .75 }
local QA_BADGE_LEVELS = { "EMPTY", "LOW", "MID", "HIGH", "FULL" }

--------------------------------------------------------------------------------
-- 1. 外部模组 UI 处理（Insight & 勋章 Buff）
--------------------------------------------------------------------------------
function QA.HandleExternalMods(HUD, status, widget)
    if not (widget and widget.widget) then return false end
    local w = widget.widget

    local is_insight_menu = false
    local temp_w = w
    while temp_w do
        if HUD.controls and temp_w == HUD.controls.insight_menu then
            is_insight_menu = true
            break
        end
        temp_w = temp_w.parent
    end

    if is_insight_menu then
        local text_str, comp_name, item_detail = nil, nil, nil
        local curr = w

        while curr and curr ~= HUD.controls.insight_menu do
            if curr.componentName then comp_name = curr.componentName; item_detail = curr end
            if curr.data and curr.data.componentName then comp_name = curr.data.componentName end

            if curr.raw_text and type(curr.raw_text) == "string" then
                text_str = curr:GetString(); break
            elseif curr.text and curr.text.GetString then
                text_str = curr.text:GetString(); break
            end
            curr = curr.parent
        end

        if not text_str and w.GetString then text_str = w:GetString() end

        if text_str and text_str ~= "" then
            if item_detail and GLOBAL.Insight and GLOBAL.ThePlayer and GLOBAL.ThePlayer.replica.insight then
                local cmp = (item_detail.componentData and item_detail.componentData.source_descriptor) or item_detail.componentName
                if cmp then
                    local insight_rep = GLOBAL.ThePlayer.replica.insight
                    local special_data = insight_rep.world_data and insight_rep.world_data.special_data and insight_rep.world_data.special_data[item_detail.componentName]
                    local describer = special_data and (
                        (special_data.prefably and GLOBAL.Insight.prefab_descriptors and GLOBAL.Insight.prefab_descriptors[cmp] and GLOBAL.Insight.prefab_descriptors[cmp].StatusAnnouncementsDescribe)
                        or (GLOBAL.Insight.descriptors and GLOBAL.Insight.descriptors[cmp] and GLOBAL.Insight.descriptors[cmp].StatusAnnouncementsDescribe)
                    )
                    if describer then return false end
                end
            end

            local raw_code = text_str:match("<icon=([^>]+)>") or text_str:match("<prefab=([^>]+)>")
            if not raw_code and comp_name then
                raw_code = string.gsub(string.gsub(comp_name, "spawner$", ""), "manager$", "")
            end

            local INSIGHT_CODE_MAP = LOCAL_STRINGS.INSIGHT_CODE_MAP or {}
            local mapped_title = raw_code and INSIGHT_CODE_MAP[string.lower(raw_code)]
            local clean_info = QA.CleanInsightString(text_str)

            if mapped_title and not string.find(clean_info, mapped_title, 1, true) then
                clean_info = mapped_title .. "：" .. clean_info:gsub("^[ \t]+", "")
            end

            local debug_txt = raw_code and string.format(DEBUG_STR.CODE_TAG, raw_code) or nil
            return QA.Announce(clean_info, nil, debug_txt, QA.GetStatementLoc("MEDAL_BUFF", "INSIGHT"))
        end
    end

    local parent = w
    local buff_card = nil
    local is_medal_buff = false

    while parent do
        if parent.buff_time and parent.buff_name then buff_card = parent end
        if parent.name == "medalBuffPanel"
            or parent.name == "medal_buff_panel"
            or (HUD.owner and HUD.owner.medalBuffPanel == parent) then
            is_medal_buff = true
            break
        end
        parent = parent.parent
    end

    if is_medal_buff and buff_card then
        local buff_name = buff_card.buff_name:GetString() or LOCAL_STRINGS.UNKNOWN_BUFF
        local left_time = buff_card.buff_time:GetString() or ""
        local qa_medal = QA.SCHEME.MEDAL_BUFF

        if qa_medal then
            if left_time == "" or left_time == "--:--" then
                return QA.Announce(GLOBAL.subfmt(qa_medal.FORMATS.FOREVER, { BUFF_NAME = buff_name }), nil, nil, QA.GetStatementLoc("MEDAL_BUFF", "FOREVER"))
            else
                return QA.Announce(GLOBAL.subfmt(qa_medal.FORMATS.DEFAULT, {
                    BUFF_NAME = buff_name, TIME = left_time
                }), nil, nil, QA.GetStatementLoc("MEDAL_BUFF", "DEFAULT"))
            end
        end
    end

    return false
end

--------------------------------------------------------------------------------
-- 2. 皮弗娄牛状态栏处理
--------------------------------------------------------------------------------
function QA.HandleBeefaloStats(HUD, status, widget)
    local b_hud = HUD.controls and HUD.controls.BeefaloStatusBar
    local is_riding = GLOBAL.ThePlayer and GLOBAL.ThePlayer.replica.rider and GLOBAL.ThePlayer.replica.rider:IsRiding()
    if not (b_hud and (is_riding or (b_hud:IsVisible() and not b_hud.isHidden))) then
        return false
    end

    local w = widget and widget.widget
    local target_badge = nil
    while w do
        if w == b_hud.healthBadge
            or w == b_hud.domesticationBadge
            or w == b_hud.obedienceBadge
            or w == b_hud.timerBadge
            or w == b_hud.hungerBadge then
            target_badge = w
            break
        end
        w = w.parent
    end

    if not target_badge then return false end
    local qa_beef = QA.SCHEME.BEEFALO
    if not qa_beef then return false end

    if target_badge == b_hud.healthBadge then
        local pct = target_badge.percent or (b_hud.health and b_hud.health_max and (b_hud.health / b_hud.health_max)) or 0
        local state = pct < 0.25 and "HEALTH_LOW" or (pct > 0.8 and "HEALTH_HIGH" or "HEALTH_NORMAL")
        return QA.Announce(GLOBAL.subfmt(qa_beef.FORMATS.HEALTH, {
            MESSAGE = GLOBAL.subfmt(QA.GetMapping(qa_beef, "MESSAGE", state), { PCT = math.floor(pct * 100 + 0.5) })
        }), nil, nil, QA.GetStatementLoc("BEEFALO", "HEALTH"))

    elseif target_badge == b_hud.hungerBadge then
        local val = tonumber(target_badge.num and target_badge.num:GetString() or "0") or tonumber(b_hud.hunger or 0) or 0
        local state = val < 50 and "HUNGER_STARVING"
            or (val < 150 and "HUNGER_HUNGRY"
            or (val > 300 and "HUNGER_FULL" or "HUNGER_NORMAL"))
        return QA.Announce(GLOBAL.subfmt(qa_beef.FORMATS.HUNGER, {
            MESSAGE = GLOBAL.subfmt(QA.GetMapping(qa_beef, "MESSAGE", state), { VAL = val })
        }), nil, nil, QA.GetStatementLoc("BEEFALO", "HUNGER"))

    elseif target_badge == b_hud.obedienceBadge then
        local pct = (target_badge.percent or (b_hud.obedience and (b_hud.obedience / 100)) or 0) * 100
        local state = pct < 40 and "OBEDIENCE_LOW" or (pct > 80 and "OBEDIENCE_HIGH" or "OBEDIENCE_NORMAL")
        return QA.Announce(GLOBAL.subfmt(qa_beef.FORMATS.OBEDIENCE, {
            MESSAGE = GLOBAL.subfmt(QA.GetMapping(qa_beef, "MESSAGE", state), { PCT = math.floor(pct + 0.5) })
        }), nil, nil, QA.GetStatementLoc("BEEFALO", "OBEDIENCE"))

    elseif target_badge == b_hud.domesticationBadge then
        local pct = (target_badge.percent or (b_hud.domestication and (b_hud.domestication / 100)) or 0) * 100
        local state = pct >= 100 and "DOMESTICATION_FULL"
            or (pct > 90 and "DOMESTICATION_HIGH"
            or (pct < 10 and "DOMESTICATION_LOW" or "DOMESTICATION_NORMAL"))
        local tendency_str = ""
        if b_hud.tendency then
            local t_name = QA.GetMapping(qa_beef, "TENDENCY_NAME", b_hud.tendency) or b_hud.tendency
            local t_fmt = QA.GetMapping(qa_beef, "WORDS", "TENDENCY")
            tendency_str = GLOBAL.subfmt(t_fmt, { TENDENCY = t_name })
        end
        return QA.Announce(GLOBAL.subfmt(qa_beef.FORMATS.DOMESTICATION, {
            MESSAGE = GLOBAL.subfmt(QA.GetMapping(qa_beef, "MESSAGE", state), { PCT = string.format("%.1f", pct) }),
            TENDENCY = tendency_str
        }), nil, nil, QA.GetStatementLoc("BEEFALO", "DOMESTICATION"))

    elseif target_badge == b_hud.timerBadge then
        local timeStr = target_badge.num and target_badge.num:GetString() or "0:00"
        local timeLeft = 999
        if b_hud.bucktime and b_hud.bucktime_start then
            timeLeft = math.floor(b_hud.bucktime_start + b_hud.bucktime - GLOBAL.GetTime())
        end
        local state = timeLeft < 30 and "TIMER_LOW" or "TIMER_RIDING"
        return QA.Announce(GLOBAL.subfmt(qa_beef.FORMATS.TIMER, {
            MESSAGE = GLOBAL.subfmt(QA.GetMapping(qa_beef, "MESSAGE", state), { TIME = timeStr })
        }), nil, nil, QA.GetStatementLoc("BEEFALO", "TIMER"))
    end

    return false
end

--------------------------------------------------------------------------------
-- 3. 玩家状态徽章处理
--------------------------------------------------------------------------------
local BADGE_CONFIG_DEFS = {
    {
        btn_path = "pethungerbadge",
        comp_path = "pet_hunger_classified",
        qa = "WOBY_HUNGER",
        cur_fn = function(c) return c:GetPercent() * (c:Max() or 50) end,
        max_fn = function(c) return c:Max() or 50 end
    },
    {
        btn_path = "waterstomach",
        comp_path = "thirst",
        qa = "THIRST",
        cur_fn = function(c) return c:GetPercent() * (c:Max() or 100) end,
        max_fn = function(c) return c:Max() or 100 end
    },
    {
        btn_path = "stomach",
        comp_path = "player_classified",
        qa = "STOMACH",
        cur_fn = function(c) return c.currenthunger:value() end,
        max_fn = function(c) return c.maxhunger:value() end
    },
    {
        btn_path = "brain",
        comp_path = "player_classified",
        qa = "SANITY",
        cur_fn = function(c) return c.currentsanity:value() end,
        max_fn = function(c) return c.maxsanity:value() end
    },
    {
        btn_path = "heart",
        comp_path = "player_classified",
        qa = "HEALTH",
        thresholds = { .25, .5, .75, 1 },
        cur_fn = function(c) return c.currenthealth:value() end,
        max_fn = function(c) return c.maxhealth:value() end
    },
    {
        btn_path = "moisturemeter",
        comp_path = "player_classified",
        qa = "WETNESS",
        cur_fn = function(c) return c.moisture:value() end,
        max_fn = function(c) return c.maxmoisture:value() end
    },
    {
        btn_path = "wereness",
        comp_path = "player_classified",
        qa = "LOG_METER",
        thresholds = { .25, .5, .7, .9 },
        cur_fn = function(c) return c.currentwereness:value() end,
        max_fn = function() return 100 end
    },
    {
        btn_path = "fungusinfectionmeter",
        comp_path = "fungusinfection",
        qa = "FUNGUS_INFECTION",
        thresholds = { .25, .5, .75, 1 },
        cur_fn = function()
            local player = GLOBAL.ThePlayer
            if player.components.fungusinfection then
                return player.components.fungusinfection:GetFungusInfection()
            elseif player.player_classified and player.player_classified.fungusinfection then
                return player.player_classified.fungusinfection:value()
            end
            return 0
        end,
        max_fn = function() return 100 end
    }
}

function QA.HandlePlayerStats(HUD, status)
    local ThePlayer = GLOBAL.ThePlayer

    if status.bloombadge and status.bloombadge.focus and ThePlayer and ThePlayer.components._bloomness then
        local current = status.bloombadge.val or 0
        local max = status.bloombadge.max or 100
        local level = ThePlayer.components._bloomness:GetLevel()
        local stage = ((level == 1 or level == 2) and not ThePlayer.components._bloomness.is_blooming) and (level + 3) or level

        local qa_bloom = QA.SCHEME.BLOOMNESS
        return QA.Announce(GLOBAL.subfmt(qa_bloom.FORMATS.DEFAULT, {
            CURRENT = math.floor(current + 0.5),
            MAX = max,
            LEVEL = tostring(level),
            SYMBOL = QA.GetSymbolString(qa_bloom),
            MESSAGE = QA.GetMapping(qa_bloom, "MESSAGE", "STAGE_" .. tostring(stage))
        }), nil, nil, QA.GetStatementLoc("BLOOMNESS", "DEFAULT"))
    end

    if (status.naughtiness and status.naughtiness.focus) or (status.naughtybadge and status.naughtybadge.focus) then
        local current, max = 0, 50
        if status.naughtiness and status.naughtiness.num then
            local cur_str, max_str = string.match(status.naughtiness.num:GetString() or "", "(%d+)[ \t\r\n]*/[ \t\r\n]*(%d+)")
            if cur_str and max_str then current, max = tonumber(cur_str), tonumber(max_str) end
        end
        if max > 0 then
            return QA.AnnounceBadge(
                QA.SCHEME.NAUGHTINESS,
                current, max,
                QA_BADGE_LEVELS[QA.GetCategory(QA_DEFAULT_THRESHOLDS, current / max)],
                "NAUGHTINESS"
            )
        end
    end

    if (status.luck and status.luck.focus) or (status.luckbadge and status.luckbadge.focus) then
        return QA.Announce(GLOBAL.subfmt(QA.SCHEME.NAUGHTINESS.FORMATS.LUCK, {
            CURRENT = status.luck.num and status.luck.num:GetString() or "0.00"
        }), nil, nil, QA.GetStatementLoc("NAUGHTINESS", "LUCK"))
    end

    for _, cfg in ipairs(BADGE_CONFIG_DEFS) do
        local btn = status[cfg.btn_path]
        local comp = (cfg.comp_path == "thirst" and ThePlayer.replica.thirst)
            or (cfg.comp_path == "fungusinfection" and ThePlayer.replica.fungusinfection)
            or ThePlayer[cfg.comp_path]

        if btn and btn.focus and comp then
            local current = cfg.cur_fn(comp)
            local max = cfg.max_fn(comp)
            local category = QA_BADGE_LEVELS[QA.GetCategory(cfg.thresholds or QA_DEFAULT_THRESHOLDS, current / max)]

            if cfg.qa == "HEALTH" and ThePlayer.prefab == "wx78" and ThePlayer.wx78_classified then
                local shield_cur = ThePlayer.wx78_classified.currentshield:value()
                local shield_max = ThePlayer.wx78_classified.maxshield:value()
                if shield_max > 1 then
                    local qa_hp = QA.SCHEME[cfg.qa]
                    local fmt_key = qa_hp.FORMATS.WITH_SHIELD and "WITH_SHIELD" or "DEFAULT"
                    return QA.Announce(GLOBAL.subfmt(qa_hp.FORMATS[fmt_key], {
                        CURRENT = math.floor(current + 0.5),
                        MAX = max,
                        SHIELD_CUR = shield_cur,
                        SHIELD_MAX = shield_max,
                        SYMBOL = QA.GetSymbolString(qa_hp),
                        MESSAGE = QA.GetMapping(qa_hp, "MESSAGE", category)
                    }), nil, nil, QA.GetStatementLoc(cfg.qa, fmt_key))
                end
            end

            return QA.AnnounceBadge(QA.SCHEME[cfg.qa], current, max, category, cfg.qa)
        end
    end

    return false
end

--------------------------------------------------------------------------------
-- 4. 环境与时间信息处理
--------------------------------------------------------------------------------
function QA.HandleEnvironmentAndTime(HUD, status)
    local ThePlayer = GLOBAL.ThePlayer
    local TheWorld = GLOBAL.TheWorld

    if status.temperature and status.temperature.focus then
        local qa_temp = QA.SCHEME.TEMPERATURE
        local temp = ThePlayer:GetTemperature()
        local msg_key = "GOOD"
        if temp >= GLOBAL.TUNING.OVERHEAT_TEMP then msg_key = "BURNING"
        elseif temp >= GLOBAL.TUNING.OVERHEAT_TEMP - 5 then msg_key = "HOT"
        elseif temp >= GLOBAL.TUNING.OVERHEAT_TEMP - 15 then msg_key = "WARM"
        elseif temp <= 0 then msg_key = "FREEZING"
        elseif temp <= 5 then msg_key = "COLD"
        elseif temp <= 15 then msg_key = "COOL"
        end

        return QA.Announce(GLOBAL.subfmt(qa_temp.FORMATS.DEFAULT, {
            TEMPERATURE = string.format("%d", temp),
            MESSAGE = QA.GetMapping(qa_temp, "MESSAGE", msg_key)
        }), nil, nil, QA.GetStatementLoc("TEMPERATURE", "DEFAULT"))
    end

    local is_worldtemp_focus = status.worldtemp and status.worldtemp.focus
    local is_season_focus = (HUD.controls.seasonclock and HUD.controls.seasonclock.focus) or (status.season and status.season.focus)

    if is_worldtemp_focus or is_season_focus then
        local raw_season = TheWorld.state.season:upper()
        local SEASON = QA.GetMapping(QA.SCHEME.SEASON, "SEASON_NAMES", raw_season)
            or GLOBAL.STRINGS.UI.SERVERLISTINGSCREEN.SEASONS[raw_season]
            or raw_season

        if is_worldtemp_focus then
            local qa_wtemp = QA.SCHEME.WORLD_TEMPERATURE_AND_RAIN
            local display_temp = (status.worldtemp and status.worldtemp.num and status.worldtemp.num:GetString())
                or (math.floor(TheWorld.state.temperature + 0.5) .. "°")

            local px, py, pz = ThePlayer.Transform:GetWorldPosition()
            local is_winterland = TheWorld.components.winterlands_manager
                and TheWorld.components.winterlands_manager:IsWinterlandsAtPoint(px, py, pz)

            local is_cave = TheWorld:HasTag("cave")
            local is_bwb_cave = is_cave
                and (raw_season == "TRANQUIL" or raw_season == "FROST" or raw_season == "VERDANT" or raw_season == "UMBRAL")

            local is_acid_raining = TheWorld.state.isacidraining == true
            local is_cave_acid_env = is_cave and (is_acid_raining or TheWorld.state.islunarportalactive == true)
            local is_raining = (TheWorld.state.pop == 1) or (TheWorld.state.israining == true) or is_acid_raining

            local function BuildWeatherBlock(weather_name, is_active, has_approach, total_seconds, stop_seconds)
                if is_active then
                    local block = GLOBAL.subfmt(QA.GetMapping(qa_wtemp, "WORDS", "ACTIVE"), { WEATHER = weather_name })
                    if stop_seconds then
                        local d, m, s = GLOBAL.QA_UTILS.FormatSeconds(stop_seconds)
                        block = block .. GLOBAL.subfmt(QA.GetMapping(qa_wtemp, "WORDS", "STOP_RAIN"), {
                            DAYS = d, MINUTES = m, SECONDS = s
                        })
                    end
                    return block
                elseif has_approach then
                    local d, m, s = GLOBAL.QA_UTILS.FormatSeconds(total_seconds)
                    return GLOBAL.subfmt(QA.GetMapping(qa_wtemp, "WORDS", "APPROACH"), {
                        WEATHER = weather_name, DAYS = d, MINUTES = m, SECONDS = s
                    })
                else
                    return GLOBAL.subfmt(QA.GetMapping(qa_wtemp, "WORDS", "NONE"), {
                        WEATHER = weather_name
                    })
                end
            end

            local world_key = GLOBAL.QA_UTILS.GetWorldType()
            local weather_key = is_cave_acid_env and "ACID_RAIN" or raw_season
            local weather_name = QA.GetMapping(qa_wtemp, "WEATHER", weather_key) or LOCAL_STRINGS.ABNORMAL_WEATHER
            local weather_status = ""

            if not is_raining then
                local pred_world, total_seconds, rain = GLOBAL.QA_UTILS.PredictRainStart()
                world_key = pred_world or world_key
                weather_status = BuildWeatherBlock(weather_name, false, rain, total_seconds)
            else
                local pred_world, total_seconds = GLOBAL.QA_UTILS.PredictRainStop()
                world_key = pred_world or world_key
                if is_cave_acid_env then
                    weather_status = BuildWeatherBlock(weather_name, true, false, nil, total_seconds)
                else
                    local d, m, s = GLOBAL.QA_UTILS.FormatSeconds(total_seconds)
                    weather_status = GLOBAL.subfmt(QA.GetMapping(qa_wtemp, "WORDS", "STOP_RAIN"), {
                        DAYS = d, MINUTES = m, SECONDS = s
                    })
                end
            end

            local world_name = is_winterland
                and QA.GetMapping(qa_wtemp, "WORLD", "WINTERLAND")
                or QA.GetMapping(qa_wtemp, "WORLD", world_key)

            local fog_status = ""
            if is_bwb_cave then
                local fog_name = QA.GetMapping(qa_wtemp, "WEATHER", "SPORE_FOG")
                local is_fungusfog_active, fungusfog_cd = GLOBAL.QA_UTILS.PredictFungusFog()
                local fog_approaching = (raw_season == "VERDANT" and fungusfog_cd > 0)
                fog_status = BuildWeatherBlock(fog_name, is_fungusfog_active, fog_approaching, fungusfog_cd)
            end

            return QA.Announce(GLOBAL.subfmt(qa_wtemp.FORMATS.DEFAULT, {
                WORLD = world_name,
                TEMPERATURE = display_temp,
                WEATHER_STATUS = weather_status,
                FOG_STATUS = fog_status,
            }), nil, nil, QA.GetStatementLoc("WORLD_TEMPERATURE_AND_RAIN", "DEFAULT"))
        end

        if is_season_focus then
            local DAYS_LEFT = TheWorld.state.remainingdaysinseason
            if DAYS_LEFT == 10000 then DAYS_LEFT = "∞" end
            return QA.Announce(GLOBAL.subfmt(QA.SCHEME.SEASON.FORMATS.DEFAULT, {
                SEASON = SEASON,
                DAYS_LEFT = DAYS_LEFT
            }), nil, nil, QA.GetStatementLoc("SEASON", "DEFAULT"))
        end
    end

    if HUD.controls.clock and HUD.controls.clock._moonanim and HUD.controls.clock._moonanim.focus then
        local qa_moon = QA.SCHEME.MOON_PHASE
        local cur_moonphase = TheWorld.state.moonphase
        local is_waxing = TheWorld.state.iswaxingmoon
        local cycles = TheWorld.state.cycles
        if not cur_moonphase then return false end

        if cur_moonphase == "full" or cur_moonphase == "new" then
            local phase_key = (cur_moonphase == "full") and "FULL" or "NEW"
            return QA.Announce(GLOBAL.subfmt(qa_moon.FORMATS.MOON, {
                RECENT = QA.GetMapping(qa_moon, "RECENT", "TODAY"),
                PHASE1 = QA.GetMapping(qa_moon, "MOON", phase_key),
            }), nil, nil, QA.GetStatementLoc("MOON_PHASE", "MOON"))
        end

        local moon_data = QA.MOON_DATA
        if not (moon_data and moon_data.is_confident and moon_data.last_phase == cur_moonphase) then
            if ThePlayer and ThePlayer.components.talker then
                local failed_msg = (qa_moon.FORMATS and qa_moon.FORMATS.FAILED)
                    or GLOBAL.STRINGS.DEFAULT_NOMU_QA.MOON_PHASE.FORMATS.FAILED
                ThePlayer.components.talker:Say(failed_msg)
            end
            return true
        end

        local elapsed = math.max(0, cycles - (moon_data.phase_start_cycle or 0))
        local rem = math.max(1, 3 - elapsed)
        local days_to_full, days_to_new

        if is_waxing then
            days_to_full = rem + (cur_moonphase == "half" and 3 or (cur_moonphase == "quarter" and 6 or 0))
            days_to_new = days_to_full + 10
        else
            days_to_new = rem + (cur_moonphase == "half" and 3 or (cur_moonphase == "threequarter" and 6 or 0))
            days_to_full = days_to_new + 10
        end

        local target_is_full = (days_to_full <= days_to_new)
        local target_days = target_is_full and days_to_full or days_to_new
        local target_key = target_is_full and "FULL" or "NEW"
        local past_key = target_is_full and "NEW" or "FULL"

        local fmts = {
            INTERVAL = QA.GetMapping(qa_moon, "INTERVAL", "COMMA"),
            PHASE2 = QA.GetMapping(qa_moon, "MOON", target_key),
            LEFT = target_days,
        }

        if target_days == 1 then
            fmts.RECENT = QA.GetMapping(qa_moon, "RECENT", "TOMORROW")
            fmts.PHASE1 = QA.GetMapping(qa_moon, "MOON", target_key)
            return QA.Announce(GLOBAL.subfmt(qa_moon.FORMATS.MOON, fmts), nil, nil, QA.GetStatementLoc("MOON_PHASE", "MOON"))
        elseif target_days >= 8 then
            fmts.RECENT = QA.GetMapping(qa_moon, "RECENT", "AFTER")
            fmts.PHASE1 = QA.GetMapping(qa_moon, "MOON", past_key)
            return QA.Announce(GLOBAL.subfmt(qa_moon.FORMATS.DEFAULT, fmts), nil, nil, QA.GetStatementLoc("MOON_PHASE", "DEFAULT"))
        else
            fmts.RECENT = ""
            fmts.PHASE1 = ""
            fmts.INTERVAL = QA.GetMapping(qa_moon, "INTERVAL", "NONE")
            return QA.Announce(GLOBAL.subfmt(qa_moon.FORMATS.DEFAULT, fmts), nil, nil, QA.GetStatementLoc("MOON_PHASE", "DEFAULT"))
        end
    end

    if HUD.controls.clock and HUD.controls.clock.focus then
        local clock = TheWorld.net.components.clock
        if clock and clock._remainingtimeinphase and clock._phase and clock.CalcRemainTimeOfDay then
            local qa_clock = QA.SCHEME.CLOCK
            local phases = { "DAY", "DUSK", "NIGHT" }

            local function _fmt_time(secs)
                local m = math.modf(secs / 60)
                local s = math.modf(math.fmod(secs, 60))
                return (m > 0 and (m .. QA.GetMapping(qa_clock, "TIME", "MINUTES")) or "")
                    .. s .. QA.GetMapping(qa_clock, "TIME", "SECONDS")
            end

            local fmt_key = "DEFAULT"
            local fmts = {
                PHASE = QA.GetMapping(qa_clock, "PHASE", phases[clock._phase:value()]),
                PHASE_REMAIN = _fmt_time(clock._remainingtimeinphase:value()),
                DAY_REMAIN = _fmt_time(clock.CalcRemainTimeOfDay())
            }

            if TheWorld.GetNightmareData then
                local data = TheWorld:GetNightmareData()
                fmt_key = (data.remain == 0 and data.total ~= 0) and "NIGHTMARE_LOCK" or "NIGHTMARE"
                fmts.NIGHTMARE = QA.GetMapping(qa_clock, "NIGHTMARE", data.phase:upper())
                fmts.REMAIN = _fmt_time(data.remain)
                fmts.TOTAL = _fmt_time(data.total)
            end

            return QA.Announce(GLOBAL.subfmt(qa_clock.FORMATS[fmt_key], fmts), nil, nil, QA.GetStatementLoc("CLOCK", fmt_key))
        end
    end

    return false
end

--------------------------------------------------------------------------------
-- 5. 特殊机制处理（船、阿比盖尔、力量、灵感、电路等）
--------------------------------------------------------------------------------
function QA.HandleSpecificMechanics(HUD, status)
    if status.boatmeter and status.boatmeter.focus then
        local qa_boat = QA.SCHEME.BOAT
        local max = status.boatmeter.boat.components.healthsyncer.max_health
        local current = status.boatmeter.boat.components.healthsyncer:GetPercent() * max
        local idx = math.floor(current / (max / 5 + 1)) + 1

        return QA.Announce(GLOBAL.subfmt(qa_boat.FORMATS.DEFAULT, {
            CURRENT = math.floor(current + 0.5),
            MAX = max,
            MESSAGE = QA.GetMapping(qa_boat, "MESSAGE", QA_BADGE_LEVELS[idx])
        }), nil, nil, QA.GetStatementLoc("BOAT", "DEFAULT"))
    end

    if status.pethealthbadge and status.pethealthbadge.focus and status.pethealthbadge.nomu_max then
        local max = status.pethealthbadge.nomu_max
        local current = status.pethealthbadge.nomu_percent * max
        return QA.AnnounceBadge(
            QA.SCHEME.ABIGAIL,
            current, max,
            QA_BADGE_LEVELS[math.floor(current / (max / 5 + 1)) + 1],
            "ABIGAIL"
        )
    end

    if status.mightybadge and status.mightybadge.focus and status.mightybadge.nomu_percent then
        local max = status.mightybadge.nomu_max or 100
        local current = status.mightybadge.nomu_percent * max
        local idx = current >= GLOBAL.TUNING.MIGHTY_THRESHOLD and 3
            or (current >= GLOBAL.TUNING.WIMPY_THRESHOLD and 2 or 1)
        local mighty_states = { "WIMPY", "NORMAL", "MIGHTY" }
        return QA.AnnounceBadge(QA.SCHEME.MIGHTINESS, current, max, mighty_states[idx], "MIGHTINESS")
    end

    if status.inspirationbadge and status.inspirationbadge.focus and status.inspirationbadge.nomu_percent then
        local max = status.inspirationbadge.nomu_max or 100
        local pct = status.inspirationbadge.nomu_percent
        local idx = pct >= GLOBAL.TUNING.BATTLESONG_THRESHOLDS[3] and 4
            or (pct >= GLOBAL.TUNING.BATTLESONG_THRESHOLDS[2] and 3
            or (pct >= GLOBAL.TUNING.BATTLESONG_THRESHOLDS[1] and 2 or 1))
        return QA.AnnounceBadge(QA.SCHEME.INSPIRATION, pct * max, max, QA_BADGE_LEVELS[idx], "INSPIRATION")
    end

    if HUD.controls.secondary_status
        and HUD.controls.secondary_status.upgrademodulesdisplay
        and HUD.controls.secondary_status.upgrademodulesdisplay.focus then

        local qa_energy = QA.SCHEME.ENERGY
        local module_display = HUD.controls.secondary_status.upgrademodulesdisplay
        local current = module_display.energy_level or 0
        local energy_levels = { "ZERO", "ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX" }

        local used_slots = 0
        if module_display.chip_slotsinuse then
            for _, v in pairs(module_display.chip_slotsinuse) do
                used_slots = used_slots + (tonumber(v) or 0)
            end
        else
            used_slots = module_display.slots_in_use or 0
        end

        local min_x, max_x = math.huge, -math.huge
        local function find_bounds(w)
            if not w or not w.GetWorldPosition then return end
            local px = w:GetWorldPosition().x
            if px < min_x then min_x = px end
            if px > max_x then max_x = px end
            if w.children then
                for _, child in pairs(w.children) do find_bounds(child) end
            end
        end
        find_bounds(module_display)

        local mx = GLOBAL.TheInput:GetScreenPosition().x
        local is_circuit_area = (min_x < max_x)
            and (mx < min_x + (max_x - min_x) * 0.90)
            or (mx < module_display:GetWorldPosition().x - 20)

        if is_circuit_area then
            local counts = {}
            local player = GLOBAL.ThePlayer
            if player and player.wx78_classified and player.wx78_classified.upgrademodulebars then
                local GetWX78ModuleByNetID = GLOBAL.require("wx78_moduledefs").GetModuleDefinitionFromNetID
                for _, bars in pairs(player.wx78_classified.upgrademodulebars) do
                    for _, module_netvar in ipairs(bars) do
                        if module_netvar and type(module_netvar.value) == "function" then
                            local netid = 0
                            pcall(function() netid = module_netvar:value() end)
                            if netid > 0 then
                                local def = GetWX78ModuleByNetID(netid)
                                if def then counts[def.name] = (counts[def.name] or 0) + 1 end
                            end
                        end
                    end
                end
            end

            local modules_str_list = {}
            local chip_fmt = qa_energy.FORMATS.CHIP or ("{NUM}" .. (LOCAL_STRINGS.MEASURE_WORD or "个") .. "{ITEM}")
            for modname, count in pairs(counts) do
                local loc_name = GLOBAL.STRINGS.NAMES["WX78MODULE_" .. string.upper(modname)] or modname
                table.insert(modules_str_list, GLOBAL.subfmt(chip_fmt, { ITEM = loc_name, NUM = count }))
            end

            if #modules_str_list > 0 then
                return QA.Announce(GLOBAL.subfmt(qa_energy.FORMATS.ALL_MODULES, {
                    MODULES = table.concat(modules_str_list, LOCAL_STRINGS.COMMA or "，")
                }), nil, nil, QA.GetStatementLoc("ENERGY", "ALL_MODULES"))
            else
                return QA.Announce(qa_energy.FORMATS.NO_MODULES, nil, nil, QA.GetStatementLoc("ENERGY", "NO_MODULES"))
            end
        else
            return QA.Announce(GLOBAL.subfmt(qa_energy.FORMATS.DEFAULT, {
                CURRENT = math.floor(current + 0.5),
                MAX = module_display.max_energy or GLOBAL.TUNING.WX78_MAXELECTRICCHARGE or 6,
                USED = used_slots,
                MESSAGE = QA.GetMapping(qa_energy, "MESSAGE", energy_levels[math.min(math.max(math.floor(current) + 1, 1), 7)])
            }), nil, nil, QA.GetStatementLoc("ENERGY", "DEFAULT"))
        end
    end

    return false
end

--------------------------------------------------------------------------------
-- 6. 烹饪锅料理处理与 HUD 点击总分发
--------------------------------------------------------------------------------
local function HandleCooking(HUD)
    if not (HUD.controls and HUD.controls.foodcrafting and HUD.controls.foodcrafting.focus
        and HUD.controls.foodcrafting.focusItem and HUD.controls.foodcrafting.focusItem.focus) then
        return false
    end

    local qa_cook = QA.SCHEME.COOK
    local recipe = HUD.controls.foodcrafting.focusItem.recipe
    local popup = HUD.controls.foodcrafting.focusItem.recipepopup
    local name = QA.GetLocalizedName(recipe.name, recipe.name)

    if popup and popup.focus then
        local fmts = { TYPE = QA.GetMapping(qa_cook, "TYPE", "POS"), NAME = name }
        local fmt, value, fmt_key

        if popup.health and popup.health.focus then
            value = recipe.health; fmt = qa_cook.FORMATS.HEALTH; fmt_key = "HEALTH"
        elseif popup.sanity and popup.sanity.focus then
            value = recipe.sanity; fmt = qa_cook.FORMATS.SANITY; fmt_key = "SANITY"
        elseif popup.hunger and popup.hunger.focus then
            value = recipe.hunger; fmt = qa_cook.FORMATS.HUNGER; fmt_key = "HUNGER"
        end

        if value then
            if type(value) == "number" and value < 0 then
                fmts.TYPE = QA.GetMapping(qa_cook, "TYPE", "NEG")
                value = -value
            end
            fmts.VALUE = not recipe.unlocked and "?"
                or (type(value) == "number" and value ~= 0 and string.format("%g", math.floor(value * 10 + 0.5) / 10) or "-")
            return QA.Announce(GLOBAL.subfmt(fmt, fmts), nil, nil, QA.GetStatementLoc("COOK", fmt_key))
        end

        if popup.name and popup.name.focus and popup.hunger and popup.sanity and popup.health then
            return QA.Announce(GLOBAL.subfmt(qa_cook.FORMATS.FOOD, {
                NAME = name,
                HUNGER = popup.hunger:GetString(),
                SANITY = popup.sanity:GetString(),
                HEALTH = popup.health:GetString()
            }), nil, nil, QA.GetStatementLoc("COOK", "FOOD"))
        end

        if popup.ingredients then
            for _, ingredient in ipairs(popup.ingredients) do
                if ingredient.focus then
                    local ing_fmt = ingredient.is_min and "MIN_INGREDIENT"
                        or (ingredient.quantity > 0 and "MAX_INGREDIENT" or "ZERO_INGREDIENT")
                    return QA.Announce(GLOBAL.subfmt(qa_cook.FORMATS[ing_fmt], {
                        NAME = name,
                        INGREDIENT = ingredient.localized_name,
                        NUM = ingredient.quantity
                    }), nil, nil, QA.GetStatementLoc("COOK", ing_fmt))
                end
            end
        end
    else
        local can_cook = (recipe.readytocook or recipe.reqsmatch) and recipe.unlocked
        local fmt_key = can_cook and "CAN" or "NEED"
        return QA.Announce(GLOBAL.subfmt(qa_cook.FORMATS[fmt_key], { NAME = name }), nil, nil, QA.GetStatementLoc("COOK", fmt_key))
    end

    return false
end

local HUD_CLICK_HANDLERS = {
    QA.HandleExternalMods,
    QA.HandlePlayerStats,
    QA.HandleBeefaloStats,
    QA.HandleEnvironmentAndTime,
    QA.HandleSpecificMechanics,
    HandleCooking
}

local function OnHUDMouseButton(HUD)
    local status = HUD.controls and HUD.controls.status
    local widget = GLOBAL.TheInput:GetHUDEntityUnderMouse()

    if QA.DATA.DEBUG_MODE and widget and widget.widget then
        QA.CURRENT_HUD_DEBUG_STR = QA.GetUIDebugString(widget, status, HUD.controls)
        if GLOBAL.ThePlayer then
            GLOBAL.ThePlayer:DoTaskInTime(0, function()
                if QA.CURRENT_HUD_DEBUG_STR then
                    print(DEBUG_STR.UNADAPTED_UI_PREFIX .. QA.CURRENT_HUD_DEBUG_STR)
                    QA.CURRENT_HUD_DEBUG_STR = nil
                end
            end)
        end
    else
        QA.CURRENT_HUD_DEBUG_STR = nil
    end

    for _, handler in ipairs(HUD_CLICK_HANDLERS) do
        if handler(HUD, status, widget) then
            QA.CURRENT_HUD_DEBUG_STR = nil
            return true
        end
    end
    return false
end

--------------------------------------------------------------------------------
-- 7. UI Hook 助手与全界面注入
--------------------------------------------------------------------------------
local function InjectAltAccept(widget, logic_fn)
    if not widget then return end
    local old_OnControl = widget.OnControl
    widget.OnControl = function(w, control, down, ...)
        if down and control == GLOBAL.CONTROL_ACCEPT and GLOBAL.QA_UTILS.IsAltPressed() then
            if logic_fn(w, ...) then return true end
        end
        if old_OnControl then return old_OnControl(w, control, down, ...) end
        return false
    end
end

local function InjectAltShiftAccept(widget, logic_fn)
    if not widget then return end
    local old_OnControl = widget.OnControl
    widget.OnControl = function(w, control, down, ...)
        if down and control == GLOBAL.CONTROL_ACCEPT and GLOBAL.QA_UTILS.IsAltPressed() and GLOBAL.QA_UTILS.IsShiftPressed() then
            if logic_fn(w, ...) then return true end
        end
        if old_OnControl then return old_OnControl(w, control, down, ...) end
        return false
    end
end

local function HookScrollListWidgets(scroll_list, get_targets_fn, logic_fn, width, height)
    if not scroll_list or not scroll_list.widgets_to_update then return end
    for _, widget in ipairs(scroll_list.widgets_to_update) do
        for _, w in ipairs(get_targets_fn(widget)) do
            if w and not w._qa_hooked then
                w._qa_hooked = true
                w.focus_forward = nil
                if width and height and type(w.SetRegionSize) == "function" then
                    w:SetRegionSize(width, height)
                end
                if type(w.SetHoverText) == "function" then
                    w:SetHoverText(LOCAL_STRINGS.HOVER_TEXT_ANNOUNCE)
                end
                InjectAltAccept(w, function(...) return logic_fn(widget, ...) end)
            end
        end
    end
end

local function AnnouncePlayerField(action_type, target_name, userid, badge, score)
    local qa_player = QA.SCHEME.PLAYER
    if action_type == "perf" then
        local status_key = (score == nil and "UNKNOWN") or (score <= 0 and "GOOD") or (score == 1 and "OK") or "BAD"
        local status_str = (qa_player.MAPPINGS and qa_player.MAPPINGS.DEFAULT and qa_player.MAPPINGS.DEFAULT.PERF_STATUS and qa_player.MAPPINGS.DEFAULT.PERF_STATUS[status_key])
            or GLOBAL.STRINGS.DEFAULT_NOMU_QA.PLAYER.MAPPINGS.DEFAULT.PERF_STATUS[status_key]
            or LOCAL_STRINGS.UNKNOWN_STATUS or "未知"

        local is_self = (GLOBAL.ThePlayer and userid == GLOBAL.ThePlayer.userid) or (userid == GLOBAL.TheNet:GetUserID())
        local ping_val = (is_self and GLOBAL.TheNet:GetPing())
            or (GLOBAL.rawget(GLOBAL, "SayAboutYourPing_PlayerPings") and userid and GLOBAL.SayAboutYourPing_PlayerPings[userid])
        local ping_str = ping_val and GLOBAL.subfmt(qa_player.FORMATS.PING, { PING = ping_val }) or ""

        return QA.Announce(GLOBAL.subfmt(qa_player.FORMATS.PERF, {
            NAME = target_name, STATUS = status_str, PING = ping_str
        }), nil, nil, QA.GetStatementLoc("PLAYER", "PERF"))

    elseif action_type == "character" then
        local prefab = badge and badge.prefabname or ""
        local is_connecting = badge and type(badge.IsLoading) == "function" and badge:IsLoading()
        if is_connecting then
            return QA.Announce(GLOBAL.subfmt(qa_player.FORMATS.CONNECTING, { NAME = target_name }), nil, nil, QA.GetStatementLoc("PLAYER", "CONNECTING"))
        elseif prefab == "" then
            return QA.Announce(GLOBAL.subfmt(qa_player.FORMATS.CHOOSING, { NAME = target_name }), nil, nil, QA.GetStatementLoc("PLAYER", "CHOOSING"))
        else
            return QA.Announce(GLOBAL.subfmt(qa_player.FORMATS.NAME, {
                NAME = target_name,
                CHARACTER = GLOBAL.STRINGS.NAMES[prefab:upper()] or prefab
            }), nil, nil, QA.GetStatementLoc("PLAYER", "NAME"))
        end

    elseif action_type == "admin" then
        return QA.Announce(GLOBAL.subfmt(qa_player.FORMATS.ADMIN, { NAME = target_name }), nil, nil, QA.GetStatementLoc("PLAYER", "ADMIN"))

    elseif action_type == "greet" then
        return QA.Announce(GLOBAL.subfmt(qa_player.FORMATS.GREET, { NAME = target_name }), nil, nil, QA.GetStatementLoc("PLAYER", "GREET"))
    end
end

-- 存档初始化与勋章答题屏幕 Hook
AddSimPostInit(function()
    QA.LoadData()

    if GLOBAL.TheFrontEnd and GLOBAL.TheFrontEnd.PushScreen then
        local old_PushScreen = GLOBAL.TheFrontEnd.PushScreen
        GLOBAL.TheFrontEnd.PushScreen = function(self, screen, ...)
            if screen and screen.name == "MedalExamScreens" and not screen._nomu_qa_hooked then
                screen._nomu_qa_hooked = true
                if screen.content and not screen.content.hovertext then screen.content:SetHoverText(LOCAL_STRINGS.HOVER_TEXT_ANNOUNCE) end
                if screen.title and not screen.title.hovertext then screen.title:SetHoverText(LOCAL_STRINGS.HOVER_TEXT_ANNOUNCE) end

                InjectAltAccept(screen, function(w)
                    if (w.content and w.content.focus) or (w.title and w.title.focus) or (w.destspanel and w.destspanel.focus) then
                        local question = (w.content and w.content:GetString() or LOCAL_STRINGS.UNKNOWN_NAME):gsub("[\n\t]", "")
                        local opt_str_list = {}
                        local prefix = { "A.", "B.", "C.", "D." }
                        if w.menu and w.menu.items then
                            for i, v in ipairs(w.menu.items) do
                                local txt = v:GetText() or ""
                                if txt ~= "" then
                                    if not txt:match("^[A-D][%.、]") and prefix[i] then txt = prefix[i] .. " " .. txt end
                                    table.insert(opt_str_list, txt)
                                end
                            end
                        end
                        return QA.Announce(GLOBAL.subfmt(QA.SCHEME.MEDAL_BUFF.FORMATS.EXAM, {
                            QUESTION = question, OPTIONS = table.concat(opt_str_list, " ")
                        }), nil, nil, QA.GetStatementLoc("MEDAL_BUFF", "EXAM"))
                    end
                end)
            end
            return old_PushScreen(self, screen, ...)
        end
    end
end)

-- PlayerHud 月相追踪、鼠标点击、第三方兼容桩与烹饪锅悬浮提示
AddClassPostConstruct("screens/playerhud", function(self)
    local cur_moonphase = GLOBAL.TheWorld and GLOBAL.TheWorld.state and GLOBAL.TheWorld.state.moonphase
    if QA.MOON_DATA then
        QA.MOON_DATA.last_phase = cur_moonphase
        if cur_moonphase == "full" or cur_moonphase == "new" then
            QA.MOON_DATA.phase_start_cycle = GLOBAL.TheWorld.state.cycles
            QA.MOON_DATA.is_confident = true
        else
            QA.MOON_DATA.phase_start_cycle = 0
            QA.MOON_DATA.is_confident = false
        end
    end

    self.inst:ListenForEvent("moonphasechanged2", function(_, data)
        if QA.MOON_DATA and data and data.moonphase and data.moonphase ~= QA.MOON_DATA.last_phase then
            QA.MOON_DATA.last_phase = data.moonphase
            QA.MOON_DATA.phase_start_cycle = GLOBAL.TheWorld and GLOBAL.TheWorld.state and GLOBAL.TheWorld.state.cycles or 0
            QA.MOON_DATA.is_confident = true
        end
    end, GLOBAL.TheWorld)

    local oldOnMouseButton = self.OnMouseButton
    function self:OnMouseButton(button, down, ...)
        if button == GLOBAL.MOUSEBUTTON_LEFT and down and GLOBAL.QA_UTILS.IsAltPressed() then
            if OnHUDMouseButton(self) then return true end
        end
        return oldOnMouseButton(self, button, down, ...)
    end

    self._StatusAnnouncer = {
        stat_names = { IA_BOAT = "船" },
        char_messages = setmetatable({}, {
            __index = function(_, k)
                return GLOBAL.STRINGS._STATUS_ANNOUNCEMENTS and GLOBAL.STRINGS._STATUS_ANNOUNCEMENTS.UNKNOWN
                    and GLOBAL.STRINGS._STATUS_ANNOUNCEMENTS.UNKNOWN[k] or ""
            end
        }),
        Announce = function(_, message) return QA.Announce(message) end,
        AnnounceItem = function(_, slot) return QA.AnnounceItem(slot, "invslot") end
    }

    local oldOnUpdate = self.OnUpdate
    function self:OnUpdate(...)
        local fc = self.controls and self.controls.foodcrafting
        if fc and fc.allfoods then
            for _, food_item in ipairs(fc.allfoods) do
                if food_item.recipepopup then
                    for _, k in ipairs({ "hunger", "health", "sanity", "name" }) do
                        if food_item.recipepopup[k] and not food_item.recipepopup[k].hovertext then
                            if k ~= "name" then food_item.recipepopup[k]:SetString("-") end
                            food_item.recipepopup[k]:SetHoverText(LOCAL_STRINGS.HOVER_TEXT_ANNOUNCE)
                        end
                    end
                end
            end
        end
        return oldOnUpdate(self, ...)
    end
end)

-- 制作栏、物品栏与礼物 Hook
for _, hook in ipairs({
    { class = "widgets/redux/craftingmenu_pinslot",      fn = QA.AnnounceRecipePinSlot },
    { class = "widgets/redux/craftingmenu_ingredients",  fn = QA.AnnounceRecipeCMIngredients },
    { class = "widgets/redux/craftingmenu_skinselector", fn = QA.AnnounceSkin }
}) do
    AddClassPostConstruct(hook.class, function(self)
        InjectAltAccept(self, function() if hook.fn(self) then return true end end)
    end)
end

AddClassPostConstruct("widgets/redux/craftingmenu_widget", function(self)
    InjectAltAccept(self.recipe_grid or self, function()
        if QA.AnnounceRecipeGrid(self.recipe_grid, self.owner) then return true end
    end)
    if self.filter_buttons then
        for _, w in pairs(self.filter_buttons) do
            if w and w.button and w.filter_def then
                InjectAltAccept(w.button, function()
                    local raw_name = string.upper(w.filter_def.name)
                    local loc_name = LOCAL_STRINGS[raw_name] or GLOBAL.STRINGS.UI.CRAFTING_FILTERS[raw_name] or w.filter_def.name
                    QA.Announce(GLOBAL.subfmt(QA.SCHEME.RECIPE.FORMATS.FILTER_TAB, { TAB = loc_name }),
                        nil, string.format(DEBUG_STR.FILTER_CODE, tostring(raw_name)), QA.GetStatementLoc("RECIPE", "FILTER_TAB"))
                    return true
                end)
            end
        end
    end
end)

for _, classname in ipairs({ "invslot", "equipslot" }) do
    AddClassPostConstruct("widgets/" .. classname, function(self)
        InjectAltShiftAccept(self, function(w) return QA.AnnounceSlot(w, classname) end)
    end)
end

AddClassPostConstruct("widgets/giftitemtoast", function(self)
    local oldOnMouseButton = self.OnMouseButton
    function self:OnMouseButton(button, down, ...)
        local ret = oldOnMouseButton(self, button, down, ...)
        if button == GLOBAL.MOUSEBUTTON_LEFT and down and GLOBAL.QA_UTILS.IsAltPressed() then
            local fmt_name = self.enabled and "CAN_OPEN" or "NEED_SCIENCE"
            QA.Announce(QA.SCHEME.GIFT.FORMATS[fmt_name], nil, nil, QA.GetStatementLoc("GIFT", fmt_name))
        end
        return ret
    end
end)

-- 玩家状态屏幕（Tab 面板）Hook
AddClassPostConstruct("screens/playerstatusscreen", function(self)
    InjectAltAccept(self, function()
        if self.servertitle and self.servertitle.focus then
            return QA.Announce(GLOBAL.subfmt(QA.SCHEME.SERVER.FORMATS.NAME, { NAME = self.servertitle:GetString() }), nil, nil, QA.GetStatementLoc("SERVER", "NAME"))
        end
        if self.serverstate and self.serverstate.focus then
            return QA.Announce(GLOBAL.subfmt(QA.SCHEME.SERVER.FORMATS.AGE, { AGE = self.serverage }), nil, nil, QA.GetStatementLoc("SERVER", "AGE"))
        end
        if self.players_number and self.players_number.focus then
            return QA.Announce(GLOBAL.subfmt(QA.SCHEME.SERVER.FORMATS.NUM_PLAYER, { NUM = self.players_number:GetString() }), nil, nil, QA.GetStatementLoc("SERVER", "NUM_PLAYER"))
        end

        for _, w in ipairs(self.player_widgets) do
            if w.focus and w.displayName then
                if w.name and w.name.focus then
                    return AnnouncePlayerField("greet", w.displayName, w.userid)
                elseif w.adminBadge and w.adminBadge.shown and w.adminBadge.focus then
                    return AnnouncePlayerField("admin", w.displayName, w.userid)
                elseif w.perf and w.perf.shown and w.perf.focus then
                    local client = GLOBAL.TheNet:GetClientTableForUser(w.userid)
                    local score = client and (client.performance ~= nil and client.performance or client.netscore)
                    return AnnouncePlayerField("perf", w.displayName, w.userid, nil, score)
                elseif w.profileFlair and w.profileFlair.shown and w.profileFlair.focus and w.characterBadge then
                    return AnnouncePlayerField("character", w.displayName, w.userid, w.characterBadge)
                elseif w.age and w.age.shown and w.age.focus and #w.age:GetString() > 0 then
                    return QA.Announce(GLOBAL.subfmt(QA.SCHEME.PLAYER.FORMATS.AGE, {
                        NAME = w.displayName, AGE = w.age:GetString()
                    }), nil, nil, QA.GetStatementLoc("PLAYER", "AGE"))
                end
            end
        end
    end)

    local oldOnUpdate = self.OnUpdate
    function self:OnUpdate(...)
        if self.shown then
            for _, v in ipairs({ self.servertitle, self.serverstate, self.players_number }) do
                if v and not v.hovertext then v:SetHoverText(LOCAL_STRINGS.HOVER_TEXT_ANNOUNCE) end
            end
            for _, widget in ipairs(self.player_widgets or {}) do
                if widget.age and not widget.age.hovertext then widget.age:SetHoverText(LOCAL_STRINGS.HOVER_TEXT_ANNOUNCE) end
            end
        end
        return oldOnUpdate(self, ...)
    end
end)

-- Redux 玩家列表 Hook
AddClassPostConstruct("widgets/redux/playerlist", function(self)
    local old_BuildPlayerList = self.BuildPlayerList
    function self:BuildPlayerList(players, nextWidgets)
        if old_BuildPlayerList then old_BuildPlayerList(self, players, nextWidgets) end

        if self.players_number and not self.players_number._qa_hooked then
            self.players_number._qa_hooked = true
            self.players_number:SetClickable(true)
            self.players_number:SetHoverText(LOCAL_STRINGS.HOVER_TEXT_ANNOUNCE)
            InjectAltAccept(self.players_number, function()
                local ClientObjs = GLOBAL.TheNet:GetClientTable() or {}
                local actual_players = 0
                for _, v in ipairs(ClientObjs) do
                    if v.performance == nil then actual_players = actual_players + 1 end
                end
                if GLOBAL.TheNet:GetServerIsClientHosted() then actual_players = #ClientObjs end
                local max_players = GLOBAL.TheNet:GetServerMaxPlayers() or "?"
                QA.Announce(GLOBAL.subfmt(QA.SCHEME.SERVER.FORMATS.NUM_PLAYER, {
                    NUM = tostring(actual_players) .. "/" .. tostring(max_players)
                }), nil, nil, QA.GetStatementLoc("SERVER", "NUM_PLAYER"))
                return true
            end)
        end

        if self.scroll_list and self.scroll_list.widgets_to_update then
            for _, w in ipairs(self.scroll_list.widgets_to_update) do
                if not w._qa_hooked then
                    w._qa_hooked = true
                    local function HookChild(child, action_type)
                        if not child then return end
                        child:SetClickable(true)
                        child:SetHoverText(LOCAL_STRINGS.HOVER_TEXT_ANNOUNCE)
                        InjectAltAccept(child, function()
                            local client = GLOBAL.TheNet:GetClientTableForUser(w.userid)
                            local target_name = client and client.name or LOCAL_STRINGS.UNKNOWN_NAME
                            local score = client and (client.performance ~= nil and client.performance or client.netscore)
                            AnnouncePlayerField(action_type, target_name, w.userid, w.characterBadge, score)
                            return true
                        end)
                    end
                    HookChild(w.netscore, "perf")
                    HookChild(w.characterBadge, "character")
                    HookChild(w.adminBadge, "admin")
                    HookChild(w.name, "greet")
                end
            end
        end
    end
end)

-- 玩家头像弹窗 Hook
local AVATAR_EQUIP_ITEMS = { "body", "hand", "legs", "feet", "base", "head_equip", "hand_equip", "body_equip" }

AddClassPostConstruct("widgets/playeravatarpopup", function(self)
    if self.age and not self.age.hovertext then
        self.age:SetHoverText(LOCAL_STRINGS.HOVER_TEXT_ANNOUNCE)
    end
    for _, item in ipairs(AVATAR_EQUIP_ITEMS) do
        if self[item .. "_image"] and self[item .. "_image"]._text and not self[item .. "_image"]._text.hovertext then
            self[item .. "_image"]._text:SetHoverText(LOCAL_STRINGS.HOVER_TEXT_ANNOUNCE)
        end
    end

    InjectAltAccept(self, function()
        if not self.player_name then return false end
        local qa_player = QA.SCHEME.PLAYER

        if self.age and self.age.focus and self.currentcharacter then
            return QA.Announce(GLOBAL.subfmt(qa_player.FORMATS.AGE_SHORT, { NAME = self.player_name, AGE = self.age:GetString() }), nil, nil, QA.GetStatementLoc("PLAYER", "AGE_SHORT"))
        end
        if self.character_name and self.character_name.focus and self.currentcharacter then
            return QA.Announce(GLOBAL.subfmt(qa_player.FORMATS.NAME, {
                NAME = self.player_name, CHARACTER = GLOBAL.STRINGS.NAMES[self.currentcharacter:upper()] or self.currentcharacter
            }), nil, nil, QA.GetStatementLoc("PLAYER", "NAME"))
        end
        if self.puppet and self.puppet.rank and self.puppet.rank.focus and self.puppet.rank.flair and self.puppet.rank.flair.hovertext then
            return QA.Announce(GLOBAL.subfmt(qa_player.FORMATS.BADGE, {
                NAME = self.player_name, BADGE = self.puppet.rank.flair.hovertext:GetString()
            }), nil, nil, QA.GetStatementLoc("PLAYER", "BADGE"))
        end
        if self.puppet and self.puppet.frame and self.puppet.frame.focus and self.puppet.frame.bg and self.puppet.frame.bg.hovertext then
            return QA.Announce(GLOBAL.subfmt(qa_player.FORMATS.BACKGROUND, {
                NAME = self.player_name, BACKGROUND = self.puppet.frame.bg.hovertext:GetString()
            }), nil, nil, QA.GetStatementLoc("PLAYER", "BACKGROUND"))
        end

        for _, item in ipairs(AVATAR_EQUIP_ITEMS) do
            if self[item .. "_image"] and self[item .. "_image"].focus then
                local upper_item = item:upper()
                return QA.Announce(GLOBAL.subfmt(qa_player.FORMATS[upper_item], {
                    NAME = self.player_name, [upper_item] = self[item .. "_image"]._text:GetString()
                }), nil, nil, QA.GetStatementLoc("PLAYER", upper_item))
            end
        end
    end)
end)

-- 技能树 Hook
local function GetSkillTreeOwnerName(builder)
    if type(builder.fromfrontend) == "table" and builder.fromfrontend.data and builder.fromfrontend.data.name and builder.fromfrontend.data.name ~= "" then
        return builder.fromfrontend.data.name
    end
    if builder.player_name and builder.player_name ~= "" then
        return builder.player_name
    end
    local scr = GLOBAL.TheFrontEnd:GetActiveScreen()
    return (scr and scr.player_name) or LOCAL_STRINGS.THAT_PLAYER
end

AddClassPostConstruct("widgets/redux/skilltreebuilder", function(self)
    InjectAltAccept(self, function()
        local name = GetSkillTreeOwnerName(self)
        local qa_st = QA.SCHEME.SKILL_TREE

        if self.root and ((self.root.xpicon and self.root.xpicon.focus) or (self.root.xptotal and self.root.xptotal.focus) or (self.root.xp_tospend and self.root.xp_tospend.focus))
            and self.root.xptotal and self.root.xptotal:GetString() then
            return QA.Announce(GLOBAL.subfmt(qa_st.FORMATS.XP, { NAME = name, XP = self.root.xptotal:GetString() }), nil, nil, QA.GetStatementLoc("SKILL_TREE", "XP"))
        end

        for k, v in pairs(self.skillgraphics) do
            if v.button and v.button.focus and v.status and self.skilltreedef and self.skilltreedef[k] and self.skilltreedef[k].title then
                local node_def = self.skilltreedef[k]
                local fmt_name = "NOT_ACTIVATED"
                if v.status.lock or node_def.lock_open then
                    fmt_name = (v.status.lock_open == true) and "ACTIVATED" or "NOT_ACTIVATED"
                elseif not node_def.infographic then
                    fmt_name = v.status.activated and "ACTIVATED" or (v.status.activatable and "CAN_ACTIVATE" or "NOT_ACTIVATED")
                else
                    fmt_name = "ACTIVATED"
                end
                return QA.Announce(GLOBAL.subfmt(qa_st.FORMATS[fmt_name], { NAME = name, SKILL = node_def.title }), nil, nil, QA.GetStatementLoc("SKILL_TREE", fmt_name))
            end
        end
    end)

    if self.infopanel and self.infopanel.desc and not self.infopanel.desc.hovertext then
        self.infopanel.desc:SetHoverText(LOCAL_STRINGS.HOVER_TEXT_ANNOUNCE)
        InjectAltAccept(self.infopanel.desc, function(desc_self)
            local desc_str = desc_self:GetString()
            if desc_str and desc_str ~= "" then
                local title_str = self.infopanel.title and self.infopanel.title:GetString() or LOCAL_STRINGS.UNKNOWN_SKILL
                QA.Announce(GLOBAL.subfmt(QA.SCHEME.SKILL_TREE.FORMATS.DESC, {
                    NAME = GetSkillTreeOwnerName(self), SKILL = title_str, DESC = desc_str:gsub("[\n\t]", "")
                }), nil, nil, QA.GetStatementLoc("SKILL_TREE", "DESC"))
                return true
            end
        end)
    end
end)

-- 世界设置 / Mod 配置 / 启用列表 / 烹饪书 Hook
AddClassPostConstruct("widgets/redux/worldsettings/settingslist", function(self)
    local old_MakeScrollList = self.MakeScrollList
    function self:MakeScrollList(...)
        local res = old_MakeScrollList(self, ...)
        if GLOBAL.TheWorld == nil then return res end

        HookScrollListWidgets(self.scroll_list,
            function(widget)
                local targets = {}
                if widget.opt_spinner and widget.opt_spinner.image then table.insert(targets, widget.opt_spinner.image) end
                if widget.opt_textentry and widget.opt_textentry.image then table.insert(targets, widget.opt_textentry.image) end
                return targets
            end,
            function(widget)
                local data = widget.data
                if data and data.option then
                    local unknown_val = LOCAL_STRINGS.UNKNOWN_VALUE
                    local val_str = unknown_val
                    local real_value = (GLOBAL.TheWorld.topology and GLOBAL.TheWorld.topology.overrides and GLOBAL.TheWorld.topology.overrides[data.option.name])
                        or data.saved_value or data.initial_value or data.value

                    if widget.opt_spinner and widget.opt_spinner.spinner then
                        local spinner = widget.opt_spinner.spinner
                        if real_value ~= nil and spinner.options then
                            for _, opt in ipairs(spinner.options) do
                                if opt.data == real_value then val_str = opt.text; break end
                            end
                        end
                        if val_str == unknown_val and type(spinner.GetSelectedText) == "function" then
                            val_str = spinner:GetSelectedText()
                        end
                    elseif widget.opt_textentry and widget.opt_textentry.textbox then
                        val_str = real_value ~= nil and tostring(real_value) or widget.opt_textentry.textbox:GetString()
                    end

                    local name_str = GLOBAL.STRINGS.UI.CUSTOMIZATIONSCREEN[string.upper(data.option.name)] or data.option.name
                    QA.Announce(GLOBAL.subfmt(QA.SCHEME.SERVER.FORMATS.WORLD_SETTING, { SETTING = name_str, VALUE = val_str }),
                        nil, nil, QA.GetStatementLoc("SERVER", "WORLD_SETTING"))
                    return true
                end
            end, 50, 50
        )
        return res
    end
end)

local function FindSpinOptionText(options, val)
    if not options then return nil end
    for _, opt in ipairs(options) do
        if opt.data == val then
            return tostring(opt.text)
        end
    end
    return nil
end

AddClassPostConstruct("screens/redux/modconfigurationscreen", function(self)
    if GLOBAL.TheWorld == nil then return end

    HookScrollListWidgets(self.options_scroll_list,
        function(widget) return (widget.opt and widget.opt.label) and { widget.opt.label } or {} end,
        function(widget)
            local data = widget.opt.data
            if data and data.option then
                local val_str = nil
                local real_value = nil

                local server_listing = GLOBAL.TheNet:GetServerListing()
                if server_listing and type(server_listing.mods_config_data) == "string" then
                    local mod_config_data = server_listing._processed_mods_config_data
                    if mod_config_data == nil and GLOBAL.RunInSandboxSafe then
                        local success, parsed = GLOBAL.RunInSandboxSafe(server_listing.mods_config_data)
                        if success and type(parsed) == "table" then
                            server_listing._processed_mods_config_data = parsed
                            mod_config_data = parsed
                        end
                    end
                    if type(mod_config_data) == "table" and mod_config_data[self.modname] ~= nil then
                        real_value = mod_config_data[self.modname][data.option.name]
                    end
                end

                if real_value ~= nil then
                    val_str = FindSpinOptionText(data.spin_options, real_value) or tostring(real_value)
                elseif widget.opt.spinner and type(widget.opt.spinner.GetSelectedText) == "function" then
                    val_str = widget.opt.spinner:GetSelectedText()
                else
                    local val = (widget.opt.spinner and type(widget.opt.spinner.GetSelected) == "function") and widget.opt.spinner:GetSelected() or data.selected_value
                    val_str = FindSpinOptionText(data.spin_options, val) or tostring(val)
                end

                local modinfo = GLOBAL.KnownModIndex:GetModInfo(self.modname)
                QA.Announce(GLOBAL.subfmt(QA.SCHEME.SERVER.FORMATS.MOD_SETTING, {
                    MOD = modinfo and modinfo.name or self.modname,
                    SETTING = data.option.label or data.option.name,
                    VALUE = val_str or LOCAL_STRINGS.UNKNOWN_VALUE
                }), nil, nil, QA.GetStatementLoc("SERVER", "MOD_SETTING"))
                return true
            end
        end, 300, 40
    )
end)

AddClassPostConstruct("screens/redux/textlistpopup", function(self)
    if GLOBAL.TheWorld == nil then return end
    HookScrollListWidgets(self.scroll_list,
        function(widget) return { widget } end,
        function(widget)
            local mod_name = (type(widget.GetText) == "function" and widget:GetText())
                or (widget.text and type(widget.text.GetString) == "function" and widget.text:GetString()) or ""
            if mod_name ~= "" then
                QA.Announce(GLOBAL.subfmt(QA.SCHEME.SERVER.FORMATS.MOD_ENABLED, { MOD = mod_name }), nil, nil, QA.GetStatementLoc("SERVER", "MOD_ENABLED"))
                return true
            end
        end
    )
end)

AddClassPostConstruct("widgets/redux/cookbookpage_crockpot", function(self)
    InjectAltAccept(self, function()
        if self.nomu_qa_data and self.details_root and self.details_root.focus then
            local data = self.nomu_qa_data
            return QA.Announce(GLOBAL.subfmt(QA.SCHEME.COOK.FORMATS.FOOD, {
                NAME = data.name,
                HUNGER = data.recipe_def.hunger ~= nil and math.floor(10 * data.recipe_def.hunger) / 10 or "-",
                SANITY = data.recipe_def.sanity ~= nil and math.floor(10 * data.recipe_def.sanity) / 10 or "-",
                HEALTH = data.recipe_def.health ~= nil and math.floor(10 * data.recipe_def.health) / 10 or "-"
            }), nil, nil, QA.GetStatementLoc("COOK", "FOOD"))
        end
    end)

    local oldPopulateRecipeDetailPanel = self.PopulateRecipeDetailPanel
    function self:PopulateRecipeDetailPanel(data, ...)
        self.nomu_qa_data = data
        return oldPopulateRecipeDetailPanel(self, data, ...)
    end
    self.nomu_qa_data = self.all_recipes[(GLOBAL.TheCookbook.selected ~= nil and GLOBAL.TheCookbook.selected[self.category] or 1)]
end)