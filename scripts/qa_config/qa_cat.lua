GLOBAL.STRINGS.NOMU_QA.TITLE_TEXT_CAT_SCHEME = '猫娘方案'

GLOBAL.STRINGS.CAT_NOMU_QA = {
    SEASON = {
        FORMATS = { DEFAULT = '主人～{SEASON}还剩 {DAYS_LEFT} 天喵󰀍～' },
        MAPPINGS = {
            DEFAULT = {
                SEASON_NAMES = { 
                    AUTUMN = '秋天', WINTER = '冬天', SPRING = '春天', SUMMER = '夏天'
                }
            }
        }
    },
    WORLD_TEMPERATURE_AND_RAIN = {
        FORMATS = {
            START_RAIN = '喵呜～{WORLD}气温 {TEMPERATURE}，{WEATHER}第 {DAYS} 天来喵（剩：{MINUTES}分{SECONDS}秒）󰀍～',
            NO_RAIN = '嗅嗅……{WORLD}气温 {TEMPERATURE}，肉垫预报{WEATHER}还没来喵󰀍～',
            STOP_RAIN = '喵！{WORLD}气温 {TEMPERATURE}，第 {DAYS} 天放晴喵（剩：{MINUTES}分{SECONDS}秒）󰀍～',
            START_FOG = '{WORLD}气温 {TEMPERATURE}，孢子雾第 {DAYS} 天来喵（剩：{MINUTES}分{SECONDS}秒）󰀍～',
            FOGGING = '喵呜～{WORLD}气温 {TEMPERATURE}，起大浓雾看不清路喵󰀍～',
            BWB_CAVE_WEATHER = '{WORLD}气温 {TEMPERATURE}，{FOG_STATUS}，{RAIN_STATUS}󰀍～',
        },
        MAPPINGS = {
            DEFAULT = {
                WORLD = { SURFACE = '地表', CAVES = '洞穴', SHIPWRECKED = '海难', VOLCANO = '火山', PORKLAND = '猪镇', WINTERLAND = '冰岛' },
                WEATHER = { SPRING = '降雨', SUMMER = '降雨', AUTUMN = '降雨', WINTER = '降雪', GREEN = '降雨', DRY = '降雨', MILD = '降雨', WET = '大风', TEMPERATE = '降雨', HUMID = '降雨', LUSH = '降雨', APORKALYPSE = '降雨', TRANQUIL = '孢子雾', FROST = '落石', VERDANT = '孢子雾', UMBRAL = '异象' },
                BWB_WORDS = {
                    RAIN_APPROACH = "雨水第 {DAYS} 天来(剩 {MINUTES}分{SECONDS}秒)",
                    RAIN_STOP = "雨水第 {DAYS} 天停(剩 {MINUTES}分{SECONDS}秒)",
                    RAIN_NONE = "没下雨迹象喵",
                    FOG_ACTIVE = "陷在孢子雾中喵",
                    FOG_APPROACH = "孢子雾第 {DAYS} 天来(剩 {MINUTES}分{SECONDS}秒)",
                    FOG_NONE = "没孢子雾迹象喵"
                }
            }
        }
    },
    TEMPERATURE = {
        FORMATS = { DEFAULT = '({TEMPERATURE}°) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    BURNING = '肉垫要融化惹喵！快扇风󰀍～',
                    HOT = '胡须打卷啦～要吃冰鱼干降温喵󰀍～',
                    WARM = '暖呼呼～在阳光下打滚散热喵󰀍～',
                    GOOD = '呼噜呼噜～温度正适合蜷成猫窝睡午觉喵󰀍～',
                    COOL = '尾巴尖尖发抖～好凉喵󰀍～',
                    COLD = '耳朵变冰片啦～急需主人掌心捂捂喵󰀍～',
                    FREEZING = '冻成冰镇猫猫啦～快抱紧贴贴喵󰀍～',
                }
            }
        }
    },
    MOON_PHASE = {
        FORMATS = {
            DEFAULT = '喵～{RECENT}{PHASE1}{INTERVAL}离下个{PHASE2}还有 {LEFT} 天喵󰀍～',
            MOON = '主人快看喵！{RECENT}{PHASE1}啦󰀍～',
            FAILED = '喵呜……云层太厚，胡须雷达测不出月相喵󰀍～'
        },
        MAPPINGS = {
            DEFAULT = {
                MOON = { FULL = '满月大玉盘', NEW = '月黑风高' },
                INTERVAL = { COMMA = '，', NONE = '' },
                RECENT = { TODAY = '今晚是', TOMORROW = '明晚是', AFTER = '刚度过' },
            }
        }
    },
    CLOCK = {
        FORMATS = {
            DEFAULT = '{PHASE}还剩 {PHASE_REMAIN} 喵～今天还有 {DAY_REMAIN} 喵󰀍～',
            NIGHTMARE = '{PHASE}还剩 {PHASE_REMAIN} 喵～今天还有 {DAY_REMAIN}，{NIGHTMARE}还有 {REMAIN} 结束喵󰀍～',
            NIGHTMARE_LOCK = '{PHASE}还剩 {PHASE_REMAIN} 喵～今天还有 {DAY_REMAIN}，{NIGHTMARE}喵󰀍～'
        },
        MAPPINGS = {
            DEFAULT = {
                TIME = { MINUTES = '分', SECONDS = '秒' },
                PHASE = { DAY = '晒太阳的白天', DUSK = '抓虫子的黄昏', NIGHT = '黑漆漆的夜晚' },
                NIGHTMARE = {
                    CALM = "平息阶段",
                    WARN = "喵嗷！警告阶段",
                    WILD = "坏家伙暴动阶段",
                    DAWN = "过渡阶段",
                },
            }
        }
    },
    COOK = {
        FORMATS = {
            CAN = '挥挥尾巴～就能做出 {NAME} 喵󰀍～',
            NEED = '肚子饿饿～想做个 {NAME} 喵󰀍～',
            MIN_INGREDIENT = '煮美味的 {NAME} 至少要 {NUM} 个 {INGREDIENT} 喵󰀍～',
            MAX_INGREDIENT = '煮 {NAME} 最多只能加 {NUM} 个 {INGREDIENT} 喵󰀍～',
            ZERO_INGREDIENT = '喵呜！{NAME} 绝对不能放 {INGREDIENT} 喵󰀍～',
            HUNGER = '{NAME} {TYPE}饱食度 {VALUE} 点喵󰀍～',
            SANITY = '{NAME} {TYPE}精神值 {VALUE} 点喵󰀍～',
            HEALTH = '{NAME} {TYPE}生命值 {VALUE} 点喵󰀍～',
            FOOD = '{NAME}：饱食 {HUNGER}，精神 {SANITY}，生命 {HEALTH} 喵󰀍～',
            FOOD_LOCK = '喵？肉垫还没解锁 {NAME} 喵󰀍～',
            FOOD_NO_EATEN = '需要主人喂一口 {NAME} 才能尝出味道喵󰀍～',
        },
        MAPPINGS = {
            DEFAULT = {
                TYPE = { POS = '涨', NEG = '扣' }
            }
        }
    },
    BOAT = {
        FORMATS = { DEFAULT = '(猫爪号：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '甲板干净，航海模式就绪喵󰀍～',
                    HIGH = '发现小漏洞，用鱼干补丁修好啦喵󰀍～',
                    MID = '舱室渗水，小鱼干要泡汤了喵󰀍～',
                    LOW = '警报！底舱进水，启动炸毛浮力系统喵󰀍～',
                    EMPTY = '船要沉啦～启动喵生逃生筏喵󰀍～',
                }
            }
        }
    },
    ABIGAIL = {
        FORMATS = { DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '姐姐大人的幽灵尾巴在保护人家喵󰀍～',
                    HIGH = '看见姐姐透明的猫耳轮廓了喵󰀍～',
                    MID = '听见姐姐的铃铛声啦喵󰀍～',
                    LOW = '姐姐的幻影模糊了……别受伤喵󰀍～',
                    EMPTY = '姐姐！最后一根绒毛断开了喵！快回来󰀍～',
                },
                SYMBOL = {
                    EMOJI = 'ghost',
                    TEXT = '姐姐'
                }
            }
        }
    },
    LOG_METER = {
        FORMATS = { DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '兽耳滚烫喵！爪爪痒痒想挠人󰀍～',
                    HIGH = '尾巴变得毛茸茸的喵󰀍～',
                    MID = '想吃生鱼片了喵～带血丝的最棒󰀍～',
                    LOW = '兽耳耷拉下来了喵……要鱼干充能󰀍～',
                    EMPTY = '兽力耗尽～变回普通猫娘喵󰀍～',
                },
                SYMBOL = {
                    TEXT = '野兽值'
                }
            }
        }
    },
    MIGHTINESS = {
        FORMATS = { DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    MIGHTY = '尾巴能举起十个毛线球喵󰀍～',
                    NORMAL = '看人家表演肉垫深蹲～嘿咻󰀍～',
                    WIMPY = '肉肉在抗议～需要主人抱抱喵󰀍～',
                },
                SYMBOL = {
                    EMOJI = 'flex',
                    TEXT = '肌肉值'
                }
            }
        }
    },
    INSPIRATION = {
        FORMATS = { DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    EMPTY = '喵呜，嗓子干干唱不出喵󰀍～',
                    LOW = '能唱一首喵喵歌喵󰀍～',
                    MID = '坏蛋们～听人家连唱两首喵喵歌󰀍～',
                    HIGH = '小鱼干给力～火力全开连唱三首喵󰀍～'
                },
                SYMBOL = {
                    EMOJI = 'horn',
                    TEXT = '灵感值'
                }
            }
        }
    },
    ENERGY = {
        FORMATS = {
            DEFAULT = '(电量：{CURRENT}/{MAX}，已用：{USED}格) 能量{MESSAGE}喵󰀍～',
            CHIP = '{NUM}个 {ITEM} 喵',
            ALL_MODULES = '尾巴上装配了：{MODULES} 喵󰀍～',
            NO_MODULES = '喵呜……插槽空空的，还没装任何电路喵󰀍～'
        },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    ZERO = '耗尽惹',
                    ONE = '极低',
                    TWO = '偏低',
                    THREE = '剩半',
                    FOUR = '充足',
                    FIVE = '很足',
                    SIX = '满格啦'
                }
            }
        }
    },
    GIFT = {
        FORMATS = {
            CAN_OPEN = '嗅嗅……有礼物的味道！许愿开红喵󰀍～',
            NEED_SCIENCE = '喵力不足，需要科学猫爬架才能拆礼物喵󰀍～',
        },
        MAPPINGS = {}
    },
    PLAYER = {
        FORMATS = {
            DEFAULT = '{NAME} 在人家这里喵󰀍～',
            ADMIN = '{NAME} 是管理员铲屎官耶󰀍～',
            NAME = '{NAME} 正在扮演 {CHARACTER} 喵󰀍～',
            AGE = '{NAME} 生存了 {AGE} 喵󰀍～',
            AGE_SHORT = '{NAME} {AGE} 喵󰀍～',
            PERF = '{NAME} 的网络 {STATUS}～{PING}󰀍～',
            GREET = '主人的脚步声最好认啦喵～你好，{NAME}󰀍～',
            PING = '延迟：{PING}󰀍～',
            CHOOSING = '{NAME} 正在挑角色喵󰀍～',
            CONNECTING = '{NAME} 猫爪信号连接中喵󰀍～',
            ME_RIDING = '正在骑着 {MOUNT} 兜风喵󰀍～',
            ME_CARRYING = '呼哧呼哧～搬运沉重的 {ITEM}，走好慢喵󰀍～',
            BADGE = '{NAME} 戴着 {BADGE} 喵󰀍～',
            BACKGROUND = '{NAME} 的背景是 {BACKGROUND}󰀍～',
            BODY = '{NAME} 穿着 {BODY}󰀍～',
            HAND = '{NAME} 爪爪套着 {HAND}󰀍～',
            LEGS = '{NAME} 腿上穿着 {LEGS}󰀍～',
            FEET = '{NAME} 脚上套着 {FEET}󰀍～',
            BASE = '{NAME} 脑袋是 {BASE}󰀍～',
            HEAD_EQUIP = '{NAME} 头戴 {HEAD_EQUIP} 喵󰀍～',
            HAND_EQUIP = '{NAME} 爪拿 {HAND_EQUIP} 喵󰀍～',
            BODY_EQUIP = '{NAME} 身穿 {BODY_EQUIP} 喵󰀍～',
            GIVE_ITEM = "{NAME} 乖乖别动～尾巴卷了 {NUM}个 {ITEM_NAME} 给你喵󰀍～",
            BOTH_GHOST = "呜呜，{NAME}，我们变成幽灵猫了喵󰀍～",
            ME_GHOST = "拜托 {NAME} 救救我，需要救赎之心复活喵󰀍～",
            THEY_GHOST = "{NAME} 撑住！猫爪救援马上就到喵󰀍～",
            I_AM_HERE = "{NAME}，人家在这里喵󰀍～",
            I_AM_GHOST = "救命喵嗷～变成幽灵猫啦！谁来救救人家󰀍～",
            ME_FISHING = '嘘——{NAME} 在屏息钓鱼鱼喵，快咬钩󰀍～',
            THEY_FISHING = '{NAME} 正在专注钓鱼，祝钓到大鱼干喵󰀍～',
            PORTAL_ON = '肉垫已经在摸 {NAME} 了喵󰀍～',
            PORTAL_OFF = '{NAME} 在这里，快准备触摸传送喵󰀍～',
            ME_FROZEN = '救命喵呜！{NAME} 冻成冰镇猫猫啦󰀍～',
            THEY_FROZEN = '快拿火把来！{NAME} 被冻成大冰块啦喵󰀍～'
        },
        MAPPINGS = {}
    },
    SERVER = {
        FORMATS = {
            NAME = '猫窝叫：{NAME} 喵󰀍～',
            AGE = '猫窝已运行：{AGE} 天喵󰀍～',
            NUM_PLAYER = '当前有：{NUM} 只猫猫喵󰀍～',
            WORLD_SETTING = '猫窝【{SETTING}】规则为【{VALUE}】喵󰀍～',
            MOD_SETTING = '模组【{MOD}】的【{SETTING}】设为【{VALUE}】喵󰀍～',
            MOD_ENABLED = '猫窝开启了模组：{MOD} 喵󰀍～'
        },
        MAPPINGS = {
            DEFAULT = {
                PERF_STATUS = {
                    GOOD = '极佳喵',
                    OK = '尚可喵',
                    BAD = '卡顿喵',
                    UNKNOWN = '未知喵'
                }
            }
        }
    },
    SKILL_TREE = {
        FORMATS = {
            ACTIVATED = '{NAME} 已点亮『{SKILL}』喵～尾巴自动发光󰀍～',
            CAN_ACTIVATE = '{NAME} 快用爪爪戳亮『{SKILL}』喵󰀍～',
            NOT_ACTIVATED = '{NAME} 还没解锁『{SKILL}』喵󰀍～',
            XP = '{NAME} 还有 {XP} 点洞察喵󰀍～',
            DESC = '{NAME} 的『{SKILL}』能<{DESC}> 喵󰀍～',
        },
        MAPPINGS = {}
    },
    SPACE = {
        FORMATS = {
            PLAYER = "尾巴测得～背包还能塞 {COUNT} 个毛线球喵󰀍～",
            INV = "包里的 {CONTAINER_NAME} 还能塞 {COUNT} 个小物件喵󰀍～",
            CONTAINER = "{CONTAINER_NAME} 还能装 {COUNT} 只猫猫幼崽喵󰀍～"
        },
        MAPPINGS = {}
    },
    BEEFALO = {
        FORMATS = {
            HEALTH = '{MESSAGE}',
            HUNGER = '{MESSAGE}',
            OBEDIENCE = '{MESSAGE}',
            DOMESTICATION = '{MESSAGE}{TENDENCY}',
            TIMER = '{MESSAGE}'
        },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    HEALTH_HIGH = "牛牛壮得像座山！（生命：{PCT}%）󰀍～",
                    HEALTH_NORMAL = "牛牛状态尚可，还能驮人跑喵！（生命：{PCT}%）󰀍～",
                    HEALTH_LOW = "喵嗷！牛牛快倒下了，快救救它！（生命：{PCT}%）󰀍～",
                    
                    HUNGER_FULL = "嗝喵～牛牛吃圆了，塞不下啦！（饥饿：{VAL}）󰀍～",
                    HUNGER_NORMAL = "牛牛肚子不饿喵～（饥饿：{VAL}）󰀍～",
                    HUNGER_HUNGRY = "牛牛肚子叫了，想吃草草喵！（饥饿：{VAL}）󰀍～",
                    HUNGER_STARVING = "牛牛饿得要啃尾巴了喵！快喂它！（饥饿：{VAL}）󰀍～",
                    
                    OBEDIENCE_HIGH = "看喵！牛牛像小猫一样听话！（顺从：{PCT}%）󰀍～",
                    OBEDIENCE_NORMAL = "牛牛还算听话喵，没发脾气。（顺从：{PCT}%）󰀍～",
                    OBEDIENCE_LOW = "牛牛眼神凶凶的，要把人家甩飞了喵！（顺从：{PCT}%）󰀍～",
                    
                    DOMESTICATION_FULL = "喵哈哈！人家是驯牛大师猫了！（已驯服）󰀍～",
                    DOMESTICATION_HIGH = "牛牛快成专属坐骑了喵！（驯化：{PCT}%）󰀍～",
                    DOMESTICATION_NORMAL = "驯牛还得努力喵～（驯化：{PCT}%）󰀍～",
                    DOMESTICATION_LOW = "牛牛太野啦！都不让摸摸喵。（驯化：{PCT}%）󰀍～",
                    
                    TIMER_RIDING = "抓紧牛角喵！还能骑 {TIME} 喵󰀍～",
                    TIMER_LOW = "喵嗷！要被甩下来了，快抓紧！（剩：{TIME}）󰀍～"
                },
                TENDENCY_NAME = {
                    DEFAULT = "普通喵",
                    RIDER = "骑行喵",
                    ORNERY = "凶猛喵",
                    PUDGY = "圆润喵",
                    UNKNOWN = "未知喵"
                }
            }
        }
    },
    ENV = {
        FORMATS = {
            SINGLE = '主人～这里有 1个 {NAME} 喵{SHOW_ME}{DISTANCE}󰀍～',
            DEFAULT = '喵呜～附近共有 {NUM}个 {NAME} 喵{SHOW_ME}{DISTANCE}󰀍～',
            NAMED = '肉垫发现！有 {NUM_PREFAB}个 {PREFAB_NAME}，其中 {NUM}个 名叫 {NAME} 喵{SHOW_ME}{DISTANCE}󰀍～',
            CODE = '名称：{NAME}，代码：{PREFAB}{MOD_INFO}{ASSET_INFO}󰀍～',
            FISH_SHOAL = '快看喵！有一群 {FISH}（共 {NUM} 条）{SHOW_ME}{DISTANCE}󰀍～',

            STATE_EQUAL = '喵呜～这里有 {TOTAL}个 {NAME}，全都在{ADJ}喵{SHOW_ME}{DISTANCE}󰀍～',
            STATE_DESCRIBE = '有情况喵！{TOTAL}个 {NAME} 中有 {NUM}个 已经{ADJ}了喵{SHOW_ME}{DISTANCE}󰀍～',
            STATE_THIS = '发现特殊目标喵！{TOTAL}个 {NAME} 中这个{ADJ}喵{SHOW_ME}{DISTANCE}󰀍～',
            STATE_THIS_SINGLE = '这里有 1个 {NAME}，目前它{ADJ}喵{SHOW_ME}{DISTANCE}󰀍～',

            STORAGE_HAS = '这里有 {TOTAL}个 {NAME}，其中这个装有 {NUM}个 {ITEM}{SHOW_ME}{DISTANCE} 喵󰀍～',
            STORAGE_EMPTY = '这里有 {TOTAL}个 {NAME}，其中 {NUM}个 空空如也{SHOW_ME}{DISTANCE} 喵󰀍～',
        },
        MAPPINGS = {
            DEFAULT = {
                WORDS = {
                    SHOW_ME = '（里面有 {SHOW_ME}）',
                    DISTANCE_FAR = '，离主人约 {DIST} 格地皮喵',
                    DISTANCE_CLOSE = '，就在人家尾巴旁喵！',
                    DISTANCE_FAR_WATER = '，在距离约 {DIST} 格的水面上喵',
                    DISTANCE_CLOSE_WATER = '，就在爪边水面上喵',
                    MOD_INFO = '，模组：{MOD_NAME}',
                    ASSET_INFO = '，动画：{BANK}，贴图：{BUILD}',
                },
                ADJ = {
                    BURNT = '被烤焦了',
                    FIRE = '在燃烧',
                    WITHERED = '枯萎了',
                    BARREN = '缺肥料',
                    SMOLDER = '在冒烟',
                    GOAT_CHARGED = '带电中',
                    GOAT_NORMAL = '很温顺',
                    HOTSPRING_BOMBED = '水温正好',
                    HOTSPRING_GLASSED = '已结晶',
                    HOTSPRING_EMPTY = '干涸了',
                    FRUITDRAGON_RIPE = '熟透了',
                    FRUITDRAGON_UNRIPE = '未成熟',
                    BIRDCAGE_EMPTY = '空空的',
                    BIRDCAGE_FULL = '有关鸟',
                    BIRDCAGE_SICK = '生病了',
                    BIRDCAGE_DEAD = '死掉了',
                    ARCHIVE_SWITCH_FULL = '已激活',
                    ARCHIVE_SWITCH_EMPTY = '未激活',
                    TOADSTOOL_EMPTY = '空空的',
                    TOADSTOOL_NORMAL = '有毒菌蟾蜍',
                    TOADSTOOL_DARK = '有悲惨蟾蜍',
                    OASISLAKE_EMPTY = '干涸了',
                    OASISLAKE_FULL = '装满水',
                    BEEFALO_SHAVED = '剃光毛了',

                    WITH_BARNACLES = "长满藤壶",
                    NO_BARNACLES = "光秃秃",
                    SEED = "是种子",
                    GROW = "生长中",
                    FULL = "已成熟",
                    OVER = "巨型作物",
                    ROT = "腐烂了",
                    SALT_FULL = "长满盐晶",
                    SALT_MED = "结晶中",
                    SALT_LOW = "少许盐晶",
                    SALT_EMPTY = "已采空",
                    MARBLE_TALL = "已长大",
                    MARBLE_NORMAL = "中等体型",
                    MARBLE_SHORT = "刚破土",
                    BEEBOX_FULL = "蜜满了",
                    BEEBOX_SOME = "有点蜜",
                    BEEBOX_EMPTY = "没有蜜",
                    PICKABLE_READY = "可采摘",
                    PICKABLE_EMPTY = "生长中",
                    NEST_HAS_EGG = "有高鸟蛋",
                    NEST_EMPTY = "是空巢",
                    MUSHROOMFARM_ROTTEN = "烂木头",
                    MUSHROOMFARM_EMPTY = "未播种",
                    MUSHROOMFARM_STAGE1 = "刚种下",
                    MUSHROOMFARM_STAGE2 = "长势良好",
                    MUSHROOMFARM_STAGE3 = "已长大",
                    MUSHROOMFARM_STAGE4 = "长满了",

                    STUMP = "是树桩",
                    SAPLING = "是树苗",
                    SHORT = "刚长出",
                    NORMAL = "正茂盛",
                    TALL = "长得高",
                    BOULDER = "变矿床了",
                    ANCIENT_READY = "结满果实",
                    ANCIENT_EMPTY = "没有果实",
                    MARBLE_TREE = "大理石树",

                    TROPHYSCALE_EMPTY = '空空的',
                    TROPHYSCALE_HAS = '放着物品',

                    L1 = "一级",
                    L2 = "二级",
                    L3 = "三级",
                    L1_BEDAZZLED = "一级装饰",
                    L2_BEDAZZLED = "二级装饰",
                    L3_BEDAZZLED = "三级装饰",

                    HEATROCK_COLD = '冰冷',
                    HEATROCK_COOL = '微凉',
                    HEATROCK_NORMAL = '常温',
                    HEATROCK_WARM = '温热',
                    HEATROCK_HOT = '滚烫',
                }
            }
        }
    },
    SKIN = {
        FORMATS = {
            DEFAULT = '我有 {NUM}件 {ITEM} 衣服（共 {TOTAL} 件），这件叫『{SKIN}』喵󰀍～',
            NO_SKIN = '喵嗷！科雷什么时候给『{ITEM}』出皮肤喵󰀍～',
            HAS_NO_SKIN = '呜呜……人家一件『{ITEM}』的衣服都没有喵󰀍～'
        },
        MAPPINGS = {}
    },
    RECIPE = {
        FORMATS = {
            BUFFERED = '卷着刚做好的 {ITEM} 准备放置喵󰀍～',
            WILL_MAKE = '随时可以开爪制作 {ITEM} 喵󰀍～',
            WE_NEED = '我们需要制造一个 {ITEM} 喵󰀍～',
            CAN_SOMEONE = '有人能帮做个 {ITEM} 喵？我需要 {PROTOTYPE} 才能造喵󰀍～',
            FILTER_TAB = '在 {TAB} 栏刨一刨就能找到喵󰀍～',
        },
        MAPPINGS = {
            DEFAULT = {
                PROTOTYPER = {
                    UNKNOWN_PROTOTYPE = "未知科技",
                    CANTRESEARCH = "未知图纸",
                    NEEDSTECH = "技术图纸",
                    NEEDSSCIENCEMACHINE = "科学猫爬架",
                    NEEDSALCHEMYMACHINE = "炼金猫砂盆",
                    NEEDSPRESTIHATITATOR = "灵子魔术帽",
                    NEEDSSHADOWMANIPULATOR = "暗影逗猫棒",
                    NEEDSELECOURMALINE_THREE = "灵感充电猫抓板",
                    NEEDSELECOURMALINE_ONE = "充电猫抓板",
                    NEEDSSIVING_ONE = "子圭神木猫抓柱",
                    NEEDSSKILL = "新技能",
                    NEEDSCELESTIAL_THREE = "大型月亮能源",
                    NEEDSCELESTIAL_ONE = "小型月亮能源",
                    NEEDSMOON_ALTAR_FULL = "完整月光猫窝",
                    NEEDSMOONORB_LOW = "月光球",
                    NEEDSCHARACTER = "另一只两脚兽",
                    NEEDSCRITTERLAB = "宠物小窝旁",
                    NEEDSTUFF_PROTOTYPE = "原型材料",
                    NEEDSFISHING = "钓鱼箱",
                    NEEDSSHADOWFORGING_TWO = "暗影猫爪台",
                    NEEDSTUFF = "合成材料",
                    NEEDSCHARACTERSKILL = "专属技能",
                    NEEDSANCIENTALTAR_HIGH = "完整远古猫爬架",
                    NEEDSFOODPROCESSING = "便携猫饭研磨器",
                    NEEDSANCIENTALTAR_LOW = "远古猫爬架",
                    NEEDSTURFCRAFTING = "踩奶夯实器",
                    NEEDSHERMITCRABSHOP_L4 = "寄居蟹奶奶",
                    NEEDSHERMITCRABSHOP_L3 = "寄居蟹奶奶",
                    NEEDSHERMITCRABSHOP_L2 = "寄居蟹奶奶",
                    NEEDSHERMITCRABSHOP_L1 = "寄居蟹奶奶",
                    NEEDSHERMITCRABHELP_CRAFTING = "寄居蟹奶奶",
                    NEEDSHERMITCRAB_TEASHOP = "珍珠奶奶茶店",
                    NEEDSSHELLWEAVER_L1= "盐晶洗爪机",
                    NEEDSSHELLWEAVER_L2= "升级盐晶洗爪机",
                    NEEDSHALLOWED_NIGHTS = "万圣夜期间",
                    NEEDSCARNIVAL_PRIZESHOP = "良羽鸦玩具摊",
                    NEEDSCARNIVAL_HOSTSHOP_PLAZA = "鸦年华猫抓树",
                    NEEDSCARNIVAL_HOSTSHOP_WANDER = "鸦年华良羽鸦",
                    NEEDSWINTERSFEASTCOOKING = "砖砌烤炉",
                    NEEDSWARGSHRINE = "座狼神龛献祭",
                    NEEDSMADSCIENCE = "疯狂科学家实验室",
                    NEEDSRABBITKINGSHOP = "兔子国王",
                    NEEDSYOTG = "火鸡之年",
                    NEEDSYOTR = "兔人之年",
                    NEEDSYOTV = "座狼之年",
                    NEEDSYOTS = "蠕虫之年",
                    NEEDSYOTD = "龙蝇之年",
                    NEEDSYOTP = "猪王之年",
                    NEEDSYOTC = "胡萝卜鼠之年",
                    NEEDSYOTB = "皮弗娄牛之年",
                    NEEDSYOTH = "发条骑士之年",
                    NEEDSWINTERS_FEAST = "冬季盛宴期间",
                    NEEDSYOTCATCOON = "浣猫喵喵之年！",
                    NEEDSBEEFSHRINE = "牛牛神龛",
                    NEEDSRABBITSHRINE = "兔人神龛",
                    NEEDSCATCOONSHRINE = "浣猫神龛喵！",
                    NEEDSKNIGHTSHRINE = "发条骑士神龛",
                    NEEDSPERDSHRINE = "火鸡神龛",
                    NEEDSWORMSHRINE = "蠕虫神龛",
                    NEEDSCARRATSHRINE = "胡萝卜鼠神龛",
                    NEEDSDRAGONSHRINE = "龙蝇神龛",
                    NEEDSSHRINE = "节日神龛",
                    NEEDSPIGSHRINE = "猪神龛",
                    NEEDSROBOTMODULECRAFT = "扫描生物",
                    NEEDSBOOKCRAFT = "故事书架",
                    NEEDSSEAFARING_STATION = "智囊团",
                    NEEDSSPIDERCRAFT = "交个蜘蛛朋友",
                    NEEDSSHADOW_FORGE = "暗影猫爪台",
                    NEEDSLUNAR_FORGE = "辉煌铁匠铺",
                    NEEDSCARTOGRAPHYDESK = "制图桌",
                    NEEDSCARPENTRY_STATION = "磨爪锯马",
                    NEEDSCARPENTRY_STATION_STONE = "玻璃磨爪锯马"
                }
            }
        }
    },
    MEDAL_BUFF = {
        FORMATS = {
            DEFAULT = '拥有"{BUFF_NAME}"BUFF，还剩 {TIME} 喵󰀍～',
            FOREVER = '拥有"{BUFF_NAME}"BUFF，永久生效喵󰀍～',
            EXAM = '喵嗷求助～谁知道"{QUESTION}"的答案喵？选项：{OPTIONS} 喵󰀍～',
        },
        MAPPINGS = {}
    },
    ITEM = {
        FORMATS = {
            INV_SLOT = '{PRONOUN}藏了 {NUM}个 {ITEM}{ITEM_NAME}{IN_CONTAINER}{WITH_PERCENT}{POST_STATE}{SHOW_ME}喵󰀍～',
            EQUIP_SLOT = '{PRONOUN}装备了 {EQUIP_NUM}个 {ITEM}{ITEM_NUM}{ITEM_NAME}{IN_CONTAINER}{WITH_PERCENT}{POST_STATE}{SHOW_ME}喵󰀍～',
            EQUIP_SLOT_POS = '{PRONOUN}在{SLOT_POS}装备了 {EQUIP_NUM}个 {ITEM}{ITEM_NUM}{ITEM_NAME}{WITH_PERCENT}{POST_STATE}{SHOW_ME}喵󰀍～',
            EQUIP_SLOT_HEAVY = '嘿咻～{PRONOUN}搬运着 {EQUIP_NUM}个 {ITEM}{ITEM_NUM}{ITEM_NAME}{IN_CONTAINER}{WITH_PERCENT}{POST_STATE}{SHOW_ME}喵󰀍～',
            EQUIP_SLOT_HEAVY_POS = '嘿咻～{PRONOUN}搬运着 {EQUIP_NUM}个 {ITEM}{ITEM_NUM}{ITEM_NAME}{WITH_PERCENT}{POST_STATE}{SHOW_ME}喵󰀍～',
            EQUIP_SLOT_EMPTY = '{PRONOUN}的 {v} 空空如也，没装备东西喵󰀍～'
        },
        MAPPINGS = {
            DEFAULT = {
                PRONOUN = { I = '人家', WE = '猫猫队' },
                HEAT_ROCK = {
                    COLD = '，冷冰冰的',
                    COOL = '，微凉的',
                    NORMAL = '，常温的',
                    WARM = '，热乎的',
                    HOT = '，滚烫的'
                },
                RECHARGE = {
                    CHARGING = '，还差 {TIME} 充能喵',
                    FULL = '，能量就绪喵',
                    PERCENT = '，还差 {PERCENT}% 冷却喵'
                },
                PERCENT_TYPE = { DURABILITY = '耐久', FRESHNESS = '新鲜度' },
                TIME = { MINUTES = '分', SECONDS = '秒' },
                WORDS = {
                    THIS_ONE = '这个',
                    ITEM_NAME = ' ({NUM}个 名叫 {NAME})',
                    ITEM_NUM = ' (共 {NUM}个)',
                    IN_CONTAINER = ' 藏在 {NAME} 里',
                    WITH_PERCENT = '，{THIS_ONE}有 {PERCENT} {TYPE} 喵',
                    SUSPICIOUS_MARBLE = '，这是 {NAME} 喵',
                    SHOW_ME = '（含有 {SHOW_ME}）',

                    SLOT_HEAD = '头上',
                    SLOT_HANDS = '爪里',
                    SLOT_BODY = '身上',
                    SLOT_BACK = '背上',
                    SLOT_NECK = '脖子上',
                    SLOT_BELLY = '肚皮上',
                    SLOT_MEDAL = '胸前勋章',
                }
            }
        }
    },
    CONSTRUCTION_AND_TRADE = {
        FORMATS = {
            CRAFT_NEED = "需要 {INGREDIENT} 才能做 {RECIPE} 喵{AND_PROTOTYPE}󰀍～",
            CRAFT_HAVE = "准备了 {TOTAL_NUM}个/{REQ_NUM} {INGREDIENT} 做 {CRAFT_COUNT}次 {RECIPE} 喵{BUT_PROTOTYPE}󰀍～",
            CRAFT_HAVE_CATALYST = "准备好了 {INGREDIENT} 做 {RECIPE} 喵{BUT_PROTOTYPE}󰀍～",
            CRAFT_HAVE_ALL = "材料全齐啦～随时能变出 {RECIPE} 喵{BUT_PROTOTYPE}󰀍～",

            CONS_NEED = "需要 {INGREDIENT} 才能建造 {RECIPE} 喵󰀍～",
            CONS_HAVE = "材料齐备～{RECIPE} 随时能建好喵󰀍～",
            CONS_HAVE_ITEM = "爪爪备好 {INGREDIENT} 来建 {RECIPE} 喵󰀍～", 

            TRADE_NEED = "喵呜……和 {RECIPE} 换东西还缺 {INGREDIENT} 喵󰀍～",
            TRADE_HAVE = "有足够 {INGREDIENT} 和 {RECIPE} 交易喵󰀍～",
            TRADE_HAVE_ITEM = "有足够 {INGREDIENT} 和 {RECIPE} 换小鱼干喵󰀍～", 
        },
        MAPPINGS = {
            DEFAULT = {
                WORDS = {
                    AMOUNT_FMT = "{NUM}个 {ITEM}",
                    COMMA = "，",
                    ALL_MATERIALS = "所有发光材料",
                    AND_PROTOTYPE = '，且需 {PROTOTYPE} 认证喵',
                    BUT_PROTOTYPE = '，但还差 {PROTOTYPE} 认证喵'
                }
            }
        }
    },
    WOBY_HUNGER = {
        FORMATS = { DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '>75%……沃比肚肚圆滚滚喵󰀍～',
                    HIGH = '55%……沃比还能跑很久喵󰀍～',
                    MID = '35%……沃比肚子咕咕叫啦喵󰀍～',
                    LOW = '15%……沃比急需怪物肉肉喵󰀍～',
                    EMPTY = '<15%……沃比饿趴下了喵！快喂它󰀍～',
                },
                SYMBOL = { TEXT = '沃比饥饿值' }
            }
        }
    },
    STOMACH = {
        FORMATS = { DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '>75%……肚子圆滚滚喵～鱼干吃撑啦󰀍～',
                    HIGH = '55%……还能塞下一口小零食喵󰀍～',
                    MID = '35%……肚皮贴后背了喵！求投喂鱼条󰀍～',
                    LOW = '15%……爪爪发抖喵！急需小鱼干续命󰀍～',
                    EMPTY = '<15%……要回喵星了～马上饿扑街喵󰀍～',
                },
                SYMBOL = { EMOJI = 'hunger', TEXT = '小肚肚' }
            },
            WILSON = {
                MESSAGE = {
                    FULL = '肚子圆滚滚喵～料理真好吃󰀍～',
                    HIGH = '能量充足，暂不需要投喂喵󰀍～',
                    MID = '小肚打鼓啦喵～想吃秋刀鱼󰀍～',
                    LOW = '饿到尾巴竖不直了喵！求空投小鱼干󰀍～',
                    EMPTY = '视线模糊了喵……毛线球看成罐头了󰀍～',
                }
            },
            WILLOW = {
                MESSAGE = {
                    FULL = '再吃要变圆毛球啦喵󰀍～',
                    HIGH = '火焰燃烧稳定，不需要燃料喵󰀍～',
                    MID = '火苗变小了～需要鱼干助燃喵󰀍～',
                    LOW = '尾巴火要灭了～求投喂喵󰀍～',
                    EMPTY = '饿扁了～伯尼快帮找罐头喵󰀍～',
                }
            },
            WOLFGANG = {
                MESSAGE = {
                    FULL = '吃饱饱喵！肉垫能举起主人󰀍～',
                    HIGH = '能量足够胸口碎大石喵󰀍～',
                    MID = '要补蛋白质～来份三文鱼喵󰀍～',
                    LOW = '饿得肌肉要化了～求投喂大猫粮󰀍～',
                    EMPTY = '尾巴都举不动了喵！急需能量󰀍～',
                }
            },
            WENDY = {
                MESSAGE = {
                    FULL = '和姐姐的绒毛一样饱满喵󰀍～',
                    HIGH = '姐姐～分你一半小鱼干喵󰀍～',
                    MID = '肚子空落落，像悲伤的秋风喵󰀍～',
                    LOW = '饿着看夕阳，添了新饿喵󰀍～',
                    EMPTY = '姐姐……肉垫快抬不起来了喵󰀍～',
                }
            },
            WX78 = {
                MESSAGE = {
                    FULL = '能量鱼干储量：MAX喵！涡轮全开󰀍～',
                    HIGH = '燃料正常喵～能做火箭跳󰀍～',
                    MID = '需补充核心能量～投喂充电鱼干喵󰀍～',
                    LOW = '警报！能量极低，启动省电撒娇模式喵󰀍～',
                    EMPTY = '休眠中……最后电量留给摸摸喵󰀍～',
                }
            },
            WICKERBOTTOM = {
                MESSAGE = {
                    FULL = '知识填满肚子啦，暂不需投喂喵󰀍～',
                    HIGH = '能量充足，继续研究薄荷星图喵󰀍～',
                    MID = '学术能量下降～要补充智慧鱼干喵󰀍～',
                    LOW = '看不清古喵文字了～求应急投喂󰀍～',
                    EMPTY = '启动纸箱避难……钥匙交给你了喵󰀍～',
                }
            },
            WOODIE = {
                MESSAGE = {
                    FULL = '树汁能量满，能抓倒十棵树喵󰀍～',
                    HIGH = '肉垫充满力量，继续磨爪喵󰀍～',
                    MID = '爪子钝了～需要小鱼干补给喵󰀍～',
                    LOW = '饿得能啃木头～开饭铃在哪喵󰀍～',
                    EMPTY = '饿得眼睛转蚊香圈了喵󰀍～',
                }
            },
            WES = {
                MESSAGE = {
                    FULL = '(拍拍圆滚滚的小肚子) 喵呜󰀍～',
                    HIGH = '(肉垫在肚皮弹钢琴) 叮咚～满分喵󰀍～',
                    MID = '(耳朵耷拉成飞机耳) 喵嗷～求投食󰀍～',
                    LOW = '(瞳孔放大抓衣角) ฅ(๑*д*๑)ฅ󰀍～',
                    EMPTY = '(瘫成猫饼比划鱼干) 喵……喵󰀍～',
                }
            },
            WAXWELL = {
                MESSAGE = {
                    FULL = '盛宴填满胃袋喵～尾巴卷成心啦󰀍～',
                    HIGH = '优雅淑女保持身材，不吃下午茶喵󰀍～',
                    MID = '肚子打鼓～想来份皇家猫罐头喵󰀍～',
                    LOW = '帽子变餐盘啦～快变出小鱼干󰀍～',
                    EMPTY = '人家的自由要被饥饿夺走了喵󰀍～',
                }
            },
            WEBBER = {
                MESSAGE = {
                    FULL = '毛毛和球球都吃饱了喵！完美󰀍～',
                    HIGH = '八条腿还能再塞下一块小布丁喵󰀍～',
                    MID = '蜘蛛感应：该吃午饭了喵󰀍～',
                    LOW = '饿得织不出爱心网～求小鱼干󰀍～',
                    EMPTY = '胃袋哀鸣～变成纸片猫了喵󰀍～',
                }
            },
            WATHGRITHR = {
                MESSAGE = {
                    FULL = '长矛吃饱饱喵！能打十个怪󰀍～',
                    HIGH = '呼吸带鱼干香，战斗欲望MAX喵󰀍～',
                    MID = '闻到猫罐头香味，尾巴动了喵󰀍～',
                    LOW = '饿得能吞下仓库喵！大餐在哪󰀍～',
                    EMPTY = '饿成纸片猫也绝不吃素喵󰀍～',
                }
            },
            WINONA = {
                MESSAGE = {
                    FULL = '引擎补给完毕～小鱼干能量满格喵󰀍～',
                    HIGH = '扳手尾巴还能再拧十个罐头喵󰀍～',
                    MID = '需要给齿轮胃加点润滑猫条喵󰀍～',
                    LOW = '耳朵耷拉了～食堂在哪喵󰀍～',
                    EMPTY = '启动罢工模式～除非有金枪鱼󰀍～',
                }
            },
            WARLY = {
                MESSAGE = {
                    FULL = '秘制猫饭超好吃喵～幸福得要晕󰀍～',
                    HIGH = '嗝～胡须沾着奶油香喵󰀍～',
                    MID = '该研发新风味冻干了喵󰀍～',
                    LOW = '错过饭点要饿哭了喵󰀍～',
                    EMPTY = '饿得看见锅铲在煎蛋啦喵󰀍～',
                }
            },
            WORMWOOD = {
                MESSAGE = {
                    FULL = '光合作用满格喵～叶子舒展开啦󰀍～',
                    HIGH = '运转正常～进行光合午睡喵󰀍～',
                    MID = '土壤养分低，需要施肥喵󰀍～',
                    LOW = '急需阳光浴和营养液喵󰀍～',
                    EMPTY = '叶片蔫了～快用摸摸复活人家喵󰀍～',
                }
            },
            WURT = {
                MESSAGE = {
                    FULL = '咕噜噜～鱼鳍肚皮装不下了喵󰀍～',
                    HIGH = '还能再塞下几只小虾米喵󰀍～',
                    MID = '鱼尾摇不动了～要投喂恢复活力󰀍～',
                    LOW = '腮帮子瘪了～求喂食FLORP喵󰀍～',
                    EMPTY = '眼睛冒漩涡～看见海底星空了喵󰀍～',
                }
            },
            WORTOX = {
                MESSAGE = {
                    FULL = '恶魔尾巴撑圆了，暂不捣蛋喵Hyuyu󰀍～',
                    HIGH = '灵魂甜点吃多了，飞两圈消食喵󰀍～',
                    MID = '补点灵魂鱼干喵～恶作剧蓄力中󰀍～',
                    LOW = '饥饿警报！看见影子都想咬喵󰀍～',
                    EMPTY = '饿狼模式～要扑倒零食柜喵󰀍～',
                }
            }
        }
    },
    BLOOMNESS = {
        FORMATS = { DEFAULT = '({SYMBOL} Lv.{LEVEL} | {CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    STAGE_0 = '尾巴需要肥料喵󰀍～',
                    STAGE_1 = '小花花要开啦喵󰀍～',
                    STAGE_2 = '花苞努力长大中喵󰀍～',
                    STAGE_3 = '当当！花花盛开啦喵󰀍～',
                    STAGE_4 = '花瓣变黄了喵󰀍～',
                    STAGE_5 = '花花要谢了喵󰀍～',
                },
                SYMBOL = {
                    EMOJI = 'flower',
                    TEXT = '绽放状态'
                }
            }
        }
    },
    NAUGHTINESS = {
        FORMATS = { 
            DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}',
            LUCK = '喵～现在的幸运值是：{CURRENT} 喵󰀍～' 
        },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '喵嗷！警报！坎普斯要来偷东西了喵󰀍～',
                    HIGH = '尾巴感觉到坎普斯的注视了喵󰀍～',
                    MID = '嗅嗅……干了一点小坏事喵󰀍～',
                    LOW = '还是个善良的乖猫猫喵󰀍～',
                    EMPTY = '纯洁如水喵～守法好市民󰀍～',
                },
                SYMBOL = {
                    TEXT = '淘气值'
                }
            }
        }
    },
    SANITY = {
        FORMATS = { DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '>75%……胡须感应全开～脑力巅峰喵󰀍～',
                    HIGH = '55%……精神很好，能表演后空翻喵󰀍～',
                    MID = '35%……毛线球打结喵～有点焦虑󰀍～',
                    LOW = '15%……尾巴有自己想法了喵～好疯狂󰀍～',
                    EMPTY = '<15%……尾巴炸毛！暗影恶魔在追人家喵󰀍～',
                },
                SYMBOL = { EMOJI = 'sanity', TEXT = '脑阔' }
            },
            WILSON = {
                MESSAGE = {
                    FULL = '导航系统正常喵～理智满分󰀍～',
                    HIGH = '有点波动，但会好起来的喵󰀍～',
                    MID = '像被猫薄荷轰炸过～头好痛喵󰀍～',
                    LOW = '看见影子在跳舞喵～什么怪物󰀍～',
                    EMPTY = '救命喵！黑暗军团要把人家吃了󰀍～',
                }
            },
            WILLOW = {
                MESSAGE = {
                    FULL = '精神火旺，能烤棉花糖喵󰀍～',
                    HIGH = '刚才伯尼动了一下喵？不用在意󰀍～',
                    MID = '寒意爬上尾巴～感觉好冷喵󰀍～',
                    LOW = '伯尼，为什么觉得这么冷喵󰀍～',
                    EMPTY = '伯尼护驾喵！怪物要咬尾巴了󰀍～',
                }
            },
            WOLFGANG = {
                MESSAGE = {
                    FULL = '脑内放剧场，感觉良好喵󰀍～',
                    HIGH = '听见云朵讲冷笑话，挺有趣喵󰀍～',
                    MID = '脑袋像被刮过，好疼喵󰀍～',
                    LOW = '看见石头跳芭蕾～有怪物喵󰀍～',
                    EMPTY = '救命！到处都是可怕怪物喵󰀍～',
                }
            },
            WENDY = {
                MESSAGE = {
                    FULL = '思维晶莹剔透喵～优雅󰀍～',
                    HIGH = '思绪渐渐变阴郁了喵󰀍～',
                    MID = '心思细腻～极度亢奋中喵󰀍～',
                    LOW = '姐姐快看！黑影要抓人家了喵󰀍～',
                    EMPTY = '带我去找姐姐吧，黑暗生物喵󰀍～',
                }
            },
            WX78 = {
                MESSAGE = {
                    FULL = 'CPU状态：全速运转喵～逻辑满分󰀍～',
                    HIGH = 'CPU状态：功能正常喵～舔毛中󰀍～',
                    MID = 'CPU状态：破损喵～需要冰镇散热󰀍～',
                    LOW = '检测到异常流～故障迫近喵󰀍～',
                    EMPTY = 'CPU状态：多重故障！乱码了喵󰀍～',
                }
            },
            WICKERBOTTOM = {
                MESSAGE = {
                    FULL = '感应精确～一切都很理智喵󰀍～',
                    HIGH = '波动在控，稍微有点头痛喵󰀍～',
                    MID = '古文看多了～偏头痛难忍喵󰀍～',
                    LOW = '墨水在跳舞～分不清虚实了喵󰀍～',
                    EMPTY = '知识溢出！帮人家逃离敌人喵󰀍～',
                }
            },
            WOODIE = {
                MESSAGE = {
                    FULL = '状态好得像小提琴曲喵󰀍～',
                    HIGH = '精神足，能来杯薄荷咖啡喵󰀍～',
                    MID = '树洞午觉时间到喵～想睡午觉󰀍～',
                    LOW = '尾巴懒得摇了～退后噩梦怪喵󰀍～',
                    EMPTY = '所有恐惧都是真的～救命喵󰀍～',
                }
            },
            WES = {
                MESSAGE = {
                    FULL = '(行礼时尾巴画出爱心) 喵󰀍～',
                    HIGH = '(用胡须比出OK手势) ฅ^•ﻌ•^ฅ󰀍～',
                    MID = '(用肉垫揉太阳穴) 呼噜……头晕喵󰀍～',
                    LOW = '(尾巴炸毛四处看) 喵嗷！疯狂的家伙󰀍～',
                    EMPTY = '(抱头来回摇晃) 喵呜呜……救命󰀍～',
                }
            },
            WAXWELL = {
                MESSAGE = {
                    FULL = '礼帽端正～体面得很喵󰀍～',
                    HIGH = '智慧似乎在动摇喵󰀍～',
                    MID = '脑袋像挨了一击～头好痛喵󰀍～',
                    LOW = '影子在跳舞～需要清醒头脑喵󰀍～',
                    EMPTY = '救命！暗影触手是真正的野兽喵󰀍～',
                }
            },
            WEBBER = {
                MESSAGE = {
                    FULL = '看到的全是美好世界喵～很健康󰀍～',
                    HIGH = '小睡一会就能恢复精神喵󰀍～',
                    MID = '听到奇怪声音～头好痛喵󰀍～',
                    LOW = '上次午睡是什么时候喵？！记不清了󰀍～',
                    EMPTY = '才不怕你们！(炸毛防御喵)󰀍～',
                }
            },
            WATHGRITHR = {
                MESSAGE = {
                    FULL = '毫无畏惧喵！凡人退散󰀍～',
                    HIGH = '聚光灯就绪～战场上感觉更好喵󰀍～',
                    MID = '思绪迷离～审判官要晕了喵󰀍～',
                    LOW = '阴影穿透长矛～要招架不住了喵󰀍～',
                    EMPTY = '退后怪兽！战神猫娘要发威了喵󰀍～',
                }
            },
            WINONA = {
                MESSAGE = {
                    FULL = '零件运转完美～保持理智喵󰀍～',
                    HIGH = '头巾以下都很好喵󰀍～',
                    MID = '螺丝松了～想法有点乱喵󰀍～',
                    LOW = '心碎了，该拿扳手修修脑袋喵󰀍～',
                    EMPTY = '系统崩溃！这是一场真实噩梦喵󰀍～',
                }
            },
            WARLY = {
                MESSAGE = {
                    FULL = '菜肴香气让人神智清醒喵󰀍～',
                    HIGH = '闻到迷迭香，觉得有点晕喵󰀍～',
                    MID = '菜谱在跳舞～脑筋转不动了喵󰀍～',
                    LOW = '听见低语～救命啊喵󰀍～',
                    EMPTY = '锅碗成精了～受不了这错乱喵󰀍～',
                }
            },
            WORMWOOD = {
                MESSAGE = {
                    FULL = '花苞绽放～感觉很棒喵󰀍～',
                    HIGH = '脑袋很舒服，听唱片机喵󰀍～',
                    MID = '头痛，但叶子感觉还好喵󰀍～',
                    LOW = '恐怖的东西在盯着看喵󰀍～',
                    EMPTY = '恐怖黑影活过来在欺负人喵󰀍～',
                }
            },
            WURT = {
                MESSAGE = {
                    FULL = '泡泡合唱团好开心喵󰀍～',
                    HIGH = '精神很好，小花喵󰀍～',
                    MID = '格鲁，脑袋受伤了喵󰀍～',
                    LOW = '可怕黑影游过来了喵󰀍～',
                    EMPTY = '格鲁，海底噩梦怪物要吃猫了喵󰀍～',
                }
            },
            WORTOX = {
                MESSAGE = {
                    FULL = '头脑清醒，恶作剧时间到喵Hyuyu󰀍～',
                    HIGH = '吸点灵魂保持清醒喵󰀍～',
                    MID = '跳太快了，脑袋有点痛喵󰀍～',
                    LOW = '好羡慕影子的恶作剧戏法喵󰀍～',
                    EMPTY = '思想进入纯粹疯狂境界啦喵Hyuyu󰀍～',
                }
            }
        }
    },
    HEALTH = {
        FORMATS = { 
            DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}',
            WITH_SHIELD = '({SYMBOL}：{CURRENT}/{MAX}，护盾：{SHIELD_CUR}/{SHIELD_MAX}) {MESSAGE}'
        },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '100%……绒毛发亮喵～血槽全满󰀍～',
                    HIGH = '75%……爪垫擦伤，挂了点彩喵󰀍～',
                    MID = '50%……缠着绷带也要守护主人喵󰀍～',
                    LOW = '25%……一瘸一拐喵～严重受伤了󰀍～',
                    EMPTY = '<25%……最后一条猫命！看好家当喵󰀍～',
                },
                SYMBOL = { EMOJI = 'heart', TEXT = '猫命' },
            },
            WILSON = {
                MESSAGE = {
                    FULL = '毛发油亮，健康得像小提琴喵󰀍～',
                    HIGH = '爪垫擦伤，还能继续行动喵󰀍～',
                    MID = '绷带歪扭～需要好好治疗喵󰀍～',
                    LOW = '血珠渗出来了～流了好多血喵󰀍～',
                    EMPTY = '九命快尽～走不到终点了喵󰀍～',
                }
            },
            WILLOW = {
                MESSAGE = {
                    FULL = '完美毛皮就该没有一丝伤痕喵󰀍～',
                    HIGH = '有小擦伤～用火苗消毒喵󰀍～',
                    MID = '伤口让火变小，需要医生喵󰀍～',
                    LOW = '生命之火如风中残烛喵󰀍～',
                    EMPTY = '小火苗……几乎要熄灭了喵󰀍～',
                }
            },
            WOLFGANG = {
                MESSAGE = {
                    FULL = '肌肉完美，现在不需要修理喵󰀍～',
                    HIGH = '有小擦伤，贴个创可贴就好喵󰀍～',
                    MID = '伤口抗议啦～受伤了喵󰀍～',
                    LOW = '血粘住毛了，需要好多绷带喵󰀍～',
                    EMPTY = '进入节能模式……要不行了喵󰀍～',
                }
            },
            WENDY = {
                MESSAGE = {
                    FULL = '痊愈了喵，但确信还会再受伤喵󰀍～',
                    HIGH = '感到轻微疼痛，还能忍受喵󰀍～',
                    MID = '生存伴随痛苦，还不太习惯喵󰀍～',
                    LOW = '流了好多血……放弃会很轻松吧喵󰀍～',
                    EMPTY = '姐姐……很快就能团聚了喵󰀍～',
                }
            },
            WX78 = {
                MESSAGE = {
                    FULL = '底盘状态：反光理想状况喵󰀍～',
                    HIGH = '底盘状态：检测到表层刮痕喵󰀍～',
                    MID = '底盘状态：电线外露中度损坏喵󰀍～',
                    LOW = '底盘状态：完全损坏警告喵󰀍～',
                    EMPTY = '底盘状态：无功能宕机喵󰀍～',
                }
            },
            WICKERBOTTOM = {
                MESSAGE = {
                    FULL = '长袍零损伤～健康得很喵󰀍～',
                    HIGH = '受了些擦伤，无关紧要喵󰀍～',
                    MID = '反噬受伤，需要医疗装配喵󰀍～',
                    LOW = '不治疗的话就是学者的终局喵󰀍～',
                    EMPTY = '魔力耗尽……需要立刻就医喵󰀍～',
                }
            },
            WOODIE = {
                MESSAGE = {
                    FULL = '健康得像清脆小哨子喵󰀍～',
                    HIGH = '大难不死，继续去冒险喵󰀍～',
                    MID = '包好松果绷带，需要药草喵󰀍～',
                    LOW = '爪子裂开，痛苦开始了喵󰀍～',
                    EMPTY = '让我在猫抓树下永眠吧喵󰀍～',
                }
            },
            WES = {
                MESSAGE = {
                    FULL = '(尾巴比心) 喵～手结成心󰀍～',
                    HIGH = '(展示爪爪) 喵呜～竖大拇指󰀍～',
                    MID = '(比划绷带) 喵～示意包扎手臂󰀍～',
                    LOW = '(摇尾求救) 喵……摇晃手臂󰀍～',
                    EMPTY = '(抛出纸团倒下) 遗书……倒地不起喵󰀍～',
                }
            },
            WAXWELL = {
                MESSAGE = {
                    FULL = '燕尾服完好～安然无恙喵󰀍～',
                    HIGH = '只是个袖口小擦伤喵󰀍～',
                    MID = '斗篷破了，需要打个补丁喵󰀍～',
                    LOW = '手套染红，还没到绝唱喵󰀍～',
                    EMPTY = '谢幕礼……绝不在这倒下喵󰀍～',
                }
            },
            WEBBER = {
                MESSAGE = {
                    FULL = '蛛丝甲发亮～毫无划痕喵󰀍～',
                    HIGH = '爪爪擦伤，需要创可贴喵󰀍～',
                    MID = '缠满绷带～还要再贴一个喵󰀍～',
                    LOW = '医疗包空了，身体剧痛喵󰀍～',
                    EMPTY = '毛毛球球……还不想死喵󰀍～',
                }
            },
            WATHGRITHR = {
                MESSAGE = {
                    FULL = '无敌猫娘皮肤无懈可击喵󰀍～',
                    HIGH = '只是肉垫轻伤喵󰀍～',
                    MID = '受伤了，但还能用猫拳战斗喵󰀍～',
                    LOW = '长矛生锈，快要去瓦尔哈拉了喵󰀍～',
                    EMPTY = '谢幕姿势……传奇要结束了喵󰀍～',
                }
            },
            WINONA = {
                MESSAGE = {
                    FULL = '装甲满格～健康如骏马喵󰀍～',
                    HIGH = '擦伤画成小花～能搞定它喵󰀍～',
                    MID = '漏油了～依然不能放弃喵󰀍～',
                    LOW = '关节悲鸣～能领抚恤金吗喵󰀍～',
                    EMPTY = '电力比心……轮班彻底结束了喵󰀍～',
                }
            },
            WARLY = {
                MESSAGE = {
                    FULL = '料理猫娘非常健康喵󰀍～',
                    HIGH = '切洋葱切到手了喵󰀍～',
                    MID = '烫伤流血了喵󰀍～',
                    LOW = '拿不动锅了～急需援助喵󰀍～',
                    EMPTY = '最后的便当……到此为止了喵󰀍～',
                }
            },
            WORMWOOD = {
                MESSAGE = {
                    FULL = '枝头开花～没受伤喵󰀍～',
                    HIGH = '树皮蹭掉一点，还好喵󰀍～',
                    MID = '年轮渗液，感到虚弱喵󰀍～',
                    LOW = '引来坏虫子，疼得厉害喵󰀍～',
                    EMPTY = '最后一片叶……救救我好朋友喵󰀍～',
                }
            },
            WURT = {
                MESSAGE = {
                    FULL = '铠甲锃亮～我很健康小花喵󰀍～',
                    HIGH = '鱼鳍划伤一丢丢，还好喵󰀍～',
                    MID = '需要珍珠粉，掉鳞片了喵󰀍～',
                    LOW = '气泡快没了，疼得直哭喵󰀍～',
                    EMPTY = '吐出最后的气泡……救命啊喵󰀍～',
                }
            },
            WORTOX = {
                MESSAGE = {
                    FULL = '肉垫有力，状态绝佳尽情捣蛋喵󰀍～',
                    HIGH = '轻微擦伤，吃个灵魂就好喵󰀍～',
                    MID = '需要灵魂鱼干抚平伤口喵Hyuyu󰀍～',
                    LOW = '魔力流失，灵魂变脆弱了喵󰀍～',
                    EMPTY = '放个爱心烟花，灵魂要飞走啦喵󰀍～',
                }
            }
        }
    },
    THIRST = {
        FORMATS = { DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '水壶喝饱饱了喵～！󰀍～',
                    HIGH = '还不渴喵～嘴巴润润的󰀍～',
                    MID = '肉垫干干的，需要甜泉水补水喵󰀍～',
                    LOW = '要渴死了，救命水水喵󰀍～',
                    EMPTY = '身体严重脱水变成鱼干了喵󰀍～',
                },
                SYMBOL = {
                    EMOJI = 'water',
                    TEXT = '口渴值'
                }
            }
        }
    },
    WETNESS = {
        FORMATS = { DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '>75%……毛湿成海带啦完全湿透喵󰀍～',
                    HIGH = '55%……尾巴吸饱水了！把人家装包里喵󰀍～',
                    MID = '35%……胡须挂水珠，背包也湿了喵󰀍～',
                    LOW = '15%……只有尾巴尖沾水，不足为惧喵󰀍～',
                    EMPTY = '肉垫干爽，只有一点点湿气喵󰀍～',
                },
                SYMBOL = {
                    TEXT = '潮湿度'
                },
            },

            WILSON = {
                MESSAGE = {
                    FULL = '变成水煮猫猫了～水分饱和喵󰀍～',
                    HIGH = '讨厌的水快点蒸发喵󰀍～',
                    MID = '毛结成缕了，衣服全湿透了喵󰀍～',
                    LOW = '胡须挂水珠，讨厌的 H2O 喵󰀍～',
                    EMPTY = '身上干爽能当镜子照喵󰀍～',
                }
            },
            WILLOW = {
                MESSAGE = {
                    FULL = '雨水是世界上最讨厌的东西喵󰀍～',
                    HIGH = '浑身湿透，讨厌水喵󰀍～',
                    MID = '积水成河，雨下太大了喵󰀍～',
                    LOW = '雨再不停，尾巴火要灭了喵󰀍～',
                    EMPTY = '干燥得能擦出火星，浇不灭我的火喵󰀍～',
                }
            },
            WOLFGANG = {
                MESSAGE = {
                    FULL = '变成大水球，整个人是水做的喵󰀍～',
                    HIGH = '湿漉漉的，像坐在池塘里喵󰀍～',
                    MID = '没到洗澡时间，不喜欢洗澡喵󰀍～',
                    LOW = '雨水滴答滴答来了喵󰀍～',
                    EMPTY = '现在非常干燥喵󰀍～',
                }
            },
            WENDY = {
                MESSAGE = {
                    FULL = '满是雨水和眼泪，好悲伤喵󰀍～',
                    HIGH = '成了湿润又悲伤的落汤猫喵󰀍～',
                    MID = '和姐姐一样湿软又悲伤喵󰀍～',
                    LOW = '雨水能填满心里的空虚吧喵󰀍～',
                    EMPTY = '皮肤和心灵一样干燥喵󰀍～',
                }
            },
            WX78 = {
                MESSAGE = {
                    FULL = '受潮：短路危险！水分达临界值喵󰀍～',
                    HIGH = '受潮：天线进水！接近危险临界喵󰀍～',
                    MID = '受潮：要长蘑菇了，完全无法接受喵󰀍～',
                    LOW = '受潮：只有小露珠，尚可容许喵󰀍～',
                    EMPTY = '受潮：干燥完美，非常合意喵󰀍～',
                }
            },
            WICKERBOTTOM = {
                MESSAGE = {
                    FULL = '护罩失效！彻底湿透了喵󰀍～',
                    HIGH = '我是湿的！湿的！重要的事情说两遍喵󰀍～',
                    MID = '长袍吸水好沉，快到承受极限了喵󰀍～',
                    LOW = '书页卷边，水膜开始形成了喵󰀍～',
                    EMPTY = '羊皮纸保存完美，身上极度干燥喵󰀍～',
                }
            },
            WOODIE = {
                MESSAGE = {
                    FULL = '鬼天气害得树都砍不了喵󰀍～',
                    HIGH = '衬衫吸水，一点都不保暖了喵󰀍～',
                    MID = '吸了相当多水分喵󰀍～',
                    LOW = '衬衫虽然暖和但也有些湿喵󰀍～',
                    EMPTY = '对我几乎毫无影响喵󰀍～',
                }
            },
            WES = {
                MESSAGE = {
                    FULL = '*疯狂蝶泳向上游喵*󰀍～',
                    HIGH = '*耳朵当螺旋桨努力向上游喵*󰀍～',
                    MID = '*悲惨地仰望乌云喵*󰀍～',
                    LOW = '*拿尾巴当雨伞护住头喵*󰀍～',
                    EMPTY = '*微笑举着看不见的空气伞喵*󰀍～',
                }
            },
            WAXWELL = {
                MESSAGE = {
                    FULL = '湿得像掉进水里的黑猫喵󰀍～',
                    HIGH = '礼服吸满水，变不干了喵󰀍～',
                    MID = '脏水会毁了定制西装喵󰀍～',
                    LOW = '潮湿让我显得不整洁喵󰀍～',
                    EMPTY = '毛发蓬松干爽，体面得很喵󰀍～',
                }
            },
            WEBBER = {
                MESSAGE = {
                    FULL = '八条短腿在划水，全湿透了喵󰀍～',
                    HIGH = '毛吸水变小海胆了喵󰀍～',
                    MID = '蛛网吊床变水床了，身上好湿喵󰀍～',
                    LOW = '湿漉漉的样子真不讨喜喵󰀍～',
                    EMPTY = '在干沙坑里玩，干燥得很喵󰀍～',
                }
            },
            WATHGRITHR = {
                MESSAGE = {
                    FULL = '衣服变沉重拖把，彻底湿透了喵󰀍～',
                    HIGH = '战士在雨天怎么能没法战斗喵󰀍～',
                    MID = '铁爪护甲泡水要生锈了喵󰀍～',
                    LOW = '身上干干净净，不需要洗澡喵󰀍～',
                    EMPTY = '干燥完毕！继续去战斗喵󰀍～',
                }
            },
            WINONA = {
                MESSAGE = {
                    FULL = '工具要生锈了！无法在湿度下工作喵󰀍～',
                    HIGH = '工作服全吸饱水了喵󰀍～',
                    MID = '滑倒了，该放个防滑警示牌喵󰀍～',
                    LOW = '干活时补充点水分挺好喵󰀍～',
                    EMPTY = '干到起静电了，一点水都没有喵󰀍～',
                }
            },
            WARLY = {
                MESSAGE = {
                    FULL = '变海鲜汤了，有鱼在衬衫里游喵󰀍～',
                    HIGH = '水会毁了完美菜肴喵󰀍～',
                    MID = '感冒前必须把衣服烘干喵󰀍～',
                    LOW = '现在可不是洗澡的地方喵󰀍～',
                    EMPTY = '只有几滴水溅在围裙上，无碍喵󰀍～',
                }
            },
            WORMWOOD = {
                MESSAGE = {
                    FULL = '储水全满啦，真的好湿好湿喵󰀍～',
                    HIGH = '叶子淋浴，真的湿透了喵󰀍～',
                    MID = '夜露收集，身上有点湿漉漉喵󰀍～',
                    LOW = '掉水珠了！发芽了！哦吼喵󰀍～',
                    EMPTY = '树皮干巴巴，感到很干燥喵󰀍～',
                }
            },
            WURT = {
                MESSAGE = {
                    FULL = '跳水上芭蕾，水花溅四处喵󰀍～',
                    HIGH = '泡澡舒服，小鳞片也很舒服喵󰀍～',
                    MID = '舒展鱼鳍，美人鱼最爱玩水，小花喵󰀍～',
                    LOW = '再多沾点水就更好了，小花喵󰀍～',
                    EMPTY = '尾巴要变鱼干了，太干燥了格鲁喵󰀍～',
                }
            },
            WORTOX = {
                MESSAGE = {
                    FULL = '翅膀变降落伞，完全浸透了喵󰀍～',
                    HIGH = '全街最潮湿的小恶魔喵Hyuyu󰀍～',
                    MID = '尾巴好重，一只湿漉漉的小恶魔喵󰀍～',
                    LOW = '世界赐予一场恶作剧淋浴喵󰀍～',
                    EMPTY = '要保持干燥就多留意天气喵󰀍～',
                }
            }
        }
    },
}