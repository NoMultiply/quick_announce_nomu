GLOBAL.STRINGS.NOMU_QA = {
    UNKNOWN_NAME = '未知名称',
    UNKNOWN_PROTOTYPE = '未知科技',
    FISHING = '钓具容器',
    COMMA = '，',
    CARNIVAL_HOST_SHOP_PLAZA = '鸦年华树苗',
    SEAFARING_STATION = '智囊团',
    SPIDER_FRIENDSHIP = '特殊蜘蛛',
    BEARD_SACK_1 = '胡子',
    BEARD_SACK_2 = '胡子',
    BEARD_SACK_3 = '胡子',
    SHADOW_CONTAINER = '暗影空间',
    SCULPTURE_BISHOPHEAD = '主教头',
    SCULPTURE_KNIGHTHEAD = '骑士头',
    SCULPTURE_ROOKNOSE = '战车鼻子',
    SCULPTURE_BISHOPBODY = '主教身体',
    SCULPTURE_KNIGHTBODY = '骑士身体',
    SCULPTURE_ROOKBODY = '战车身体',
    HOVER_TEXT_ANNOUNCE = 'ALT + ' .. STRINGS.LMB .. ' 宣告',


    TITLE_TEXT_QA = '快捷宣告 (NoMu)',
    TITLE_TEXT_SURE_TO_DELETE = '确认删除该项？',
    TITLE_TEXT_SCHEMES = '宣告方案',
    TITLE_TEXT_DEFAULT_SCHEME = '默认方案',
    TITLE_TEXT_EDITING = '正在编辑：',
    --TITLE_TEXT_SURE_TO_RESET_SCHEME = '确认重置方案：{NAME}？',
    TITLE_TEXT_SURE_TO_RESET_DEFAULT = '确认重置默认方案？',
    TITLE_TEXT_SURE_TO_SAVE_SCHEME = '确认保存方案：{NAME}？',
    TITLE_TEXT_SURE_TO_APPLY_SCHEME = '确认启用方案：{NAME}？',
    TITLE_TEXT_SURE_TO_SAVE_APPLY_SCHEME = '确认保存并启用方案：{NAME}？',
    TITLE_TEXT_SCHEME_FILENAME = '请输入方案文件名',
    JSON_NEEDED = '文件名需以".json"结尾',

    BUTTON_TEXT_APPLY = '应用',
    BUTTON_TEXT_CLOSE = '关闭',
    BUTTON_TEXT_YES = '是的',
    BUTTON_TEXT_NO = '取消',
    BUTTON_TEXT_DELETE = '删除',
    BUTTON_TEXT_RESET = '重置',
    BUTTON_TEXT_RENAME = '重命名',

    BUTTON_TEXT_OPTIONS = '选项',
    BUTTON_TEXT_CUSTOMIZE = '自定义宣告',
    BUTTON_TEXT_NEW_FREQ = '新建常用语',
    BUTTON_TEXT_NEW_SCHEME = '新建方案',
    BUTTON_TEXT_APPLY_SCHEME = '使用方案',
    --BUTTON_TEXT_RESET_SCHEME = '取消修改',
    BUTTON_TEXT_SAVE_SCHEME = '保存修改',
    BUTTON_TEXT_SAVE_AND_APPLY_SCHEME = '保存并使用',
    BUTTON_TEXT_EXPORT_SCHEME = '导出方案',
    BUTTON_TEXT_IMPORT_SCHEME = '导入方案',

    MESSAGE_EXPORT_SUCCEED = '导出方案成功！',
    MESSAGE_EXPORT_FAILED = '导出方案失败！',
    MESSAGE_IMPORT_SUCCEED = '导入方案成功！',
    MESSAGE_IMPORT_FAILED = '导入方案失败！',

    BUTTON_TEXT_DEFAULT_WHISPER_ON = '默认宣告（私聊）',
    BUTTON_TEXT_DEFAULT_WHISPER_OFF = '默认宣告（公开）',
    BUTTON_TEXT_CHARACTER_SPECIFIC_ON = '人物定制（开）',
    BUTTON_TEXT_CHARACTER_SPECIFIC_OFF = '人物定制（关）',
    BUTTON_TEXT_FREQ_AUTO_CLOSE_ON = '常用语（宣告后关闭）',
    BUTTON_TEXT_FREQ_AUTO_CLOSE_OFF = '常用语（宣告后保留）',
    BUTTON_TEXT_SHOW_ME_OFF = 'Show Me（关）',
    BUTTON_TEXT_SHOW_ME_ON = 'Show Me（开）',
    BUTTON_TEXT_SHOW_ME_GIFT = 'SHOW ME（仅礼物）',

    FREQ_EXAMPLE = '常用语示例，点击可宣告喔~',

    TITLE_TEXT_FUNC = '功能',
    TITLE_TEXT_FORMAT = '句型：{NAME}',
    TITLE_TEXT_MAPPING_DEFAULT = '人物通用',
    BUTTON_TEXT_MAPPING = '当前映射：{NAME}',

    FUNC = {
        SEASON = '季节',
        WORLD_TEMPERATURE_AND_RAIN = '世界温度',
        TEMPERATURE = '人物温度',
        MOON_PHASE = '月相',
        COOK = '料理',
        CLOCK = '时钟',
        BOAT = '船',
        ABIGAIL = '阿比盖尔',
        LOG_METER = '野兽值',
        MIGHTINESS = '力量值',
        INSPIRATION = '灵感值',
        ENERGY = '电路',
        GIFT = '每周礼物',
        PLAYER = '玩家',
        SERVER = '服务器',
        SKILL_TREE = '技能树',
        ENV = '周围环境',
        SKIN = '皮肤',
        RECIPE = '配方',
        ITEM = '物品',
        INGREDIENT = '材料',
        STOMACH = '饥饿值',
        SANITY = '精神值',
        HEALTH = '生命值',
        WETNESS = '潮湿度',
    }
}

GLOBAL.STRINGS.DEFAULT_NOMU_QA = {
    SEASON = {
        FORMATS = { DEFAULT = '{SEASON}天还有{DAYS_LEFT}天。' },
        MAPPINGS = {}
    },
    WORLD_TEMPERATURE_AND_RAIN = {
        FORMATS = {
            START_RAIN = '{WORLD}气温：{TEMPERATURE}°，{WEATHER}：第{DAYS}天（{MINUTES}分{SECONDS}秒）',
            NO_RAIN = '{WORLD}气温：{TEMPERATURE}°，{SEASON}天不再{WEATHER}',
            STOP_RAIN = '{WORLD}气温：{TEMPERATURE}°，放晴：第{DAYS}天（{MINUTES}分{SECONDS}秒）',
        },
        MAPPINGS = {
            DEFAULT = {
                WORLD = { SURFACE = '地表', CAVES = '洞穴' },
                WEATHER = { SPRING = '降雨', SUMMER = '降雨', AUTUMN = '降雨', WINTER = '降雪' },
            }
        }
    },
    TEMPERATURE = {
        FORMATS = { DEFAULT = '({TEMPERATURE}°) 我{MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    BURNING = '过热了！',
                    HOT = '几乎过热！',
                    WARM = '有点热。',
                    GOOD = '在一个舒适的温度。',
                    COOL = '稍微有点冷。',
                    COLD = '几乎冻结！',
                    FREEZING = '“凝固”了！',
                }
            }
        }
    },
    MOON_PHASE = {
        FORMATS = {
            DEFAULT = '{RECENT}{PHASE1}{INTERVAL}距离下个{PHASE2}还有{LEFT}天。',
            MOON = '{RECENT}{PHASE1}。',
            FAILED = '上线时间太短，无法判明月相！'
        },
        MAPPINGS = {
            DEFAULT = {
                MOON = { FULL = '月圆', NEW = '月黑' },
                INTERVAL = { COMMA = '，', NONE = '' },
                RECENT = { TODAY = '今晚', TOMORROW = '明晚', AFTER = '我们刚度过' },
            }
        }
    },
    CLOCK = {
        FORMATS = {
            DEFAULT = '{PHASE}还有{PHASE_REMAIN}，今天还有{DAY_REMAIN}',
            NIGHTMARE = '{PHASE}还有{PHASE_REMAIN}，今天还有{DAY_REMAIN}，{NIGHTMARE}还有{REMAIN}结束。',
            NIGHTMARE_LOCK = '{PHASE}还有{PHASE_REMAIN}，今天还有{DAY_REMAIN}，{NIGHTMARE}'
        },
        MAPPINGS = {
            DEFAULT = {
                TIME = { MINUTES = '分', SECONDS = '秒' },
                PHASE = { DAY = '白天', DUSK = '黄昏', NIGHT = '夜晚' },
                NIGHTMARE = {
                    CALM = "平息阶段",
                    WARN = "警告阶段",
                    WILD = "暴动阶段",
                    DAWN = "过渡阶段",
                },
            }
        }
    },
    COOK = {
        FORMATS = {
            CAN = '我可以做料理 {NAME} 。',
            NEED = '我需要做料理 {NAME} 。',
            MIN_INGREDIENT = '制作料理 {NAME} 需要 {NUM} {INGREDIENT}。',
            MAX_INGREDIENT = '制作料理 {NAME} 至多可添加 {NUM} {INGREDIENT}。',
            ZERO_INGREDIENT = '制作料理 {NAME} 不可添加 {INGREDIENT}。',
            HUNGER = '料理 {NAME} {TYPE} 饱食度 {VALUE} 点。',
            SANITY = '料理 {NAME} {TYPE} 精神值 {VALUE} 点。',
            HEALTH = '料理 {NAME} {TYPE} 生命值 {VALUE} 点。',
            FOOD = '料理 {NAME}：饱食度 {HUNGER}，精神值 {SANITY}，生命值 {HEALTH}。',
            FOOD_LOCK = '我还没解锁料理 {NAME}。',
            FOOD_NO_EATEN = '我需要试吃 {NAME} 才能获得更多信息。',
        },
        MAPPINGS = {
            DEFAULT = {
                TYPE = { POS = '可以回复', NEG = '会扣除' }
            }
        }
    },
    BOAT = {
        FORMATS = { DEFAULT = '(船: {CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '我要当海贼王！',
                    HIGH = '来啊，玩碰碰船啊！',
                    MID = '就这，不慌！',
                    LOW = '越是残血我越浪！',
                    EMPTY = '啊~~~水！',
                }
            }
        }
    },
    ABIGAIL = {
        FORMATS = { DEFAULT = '({SYMBOL}: {CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '阿比盖尔可以保护我！',
                    HIGH = '你受伤了，阿比盖尔！',
                    MID = '你还好吗？阿比盖尔！',
                    LOW = '小心啊！阿比盖尔！',
                    EMPTY = '阿比盖尔！别离开我！',
                },
                SYMBOL = {
                    EMOJI = 'ghost',
                    TEXT = '姐姐'
                }
            }
        }
    },
    LOG_METER = {
        FORMATS = { DEFAULT = '({SYMBOL}: {CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '我兽性大发！嗷呜呜！',
                    HIGH = '野兽还能大战三百回合！',
                    MID = '扶我起来，野兽还能战斗！',
                    LOW = '我感受到了对兽性的渴望。',
                    EMPTY = '我快变回人类了！',
                },
                SYMBOL = {
                    TEXT = '兽性'
                }
            }
        }
    },
    MIGHTINESS = {
        FORMATS = { DEFAULT = '({SYMBOL}: {CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    MIGHTY = '我是最强壮的！',
                    NORMAL = '我需要锻炼！',
                    WIMPY = '我只是一个弱鸡…',
                },
                SYMBOL = {
                    EMOJI = 'flex',
                    TEXT = '力量值'
                }
            }
        }
    },
    INSPIRATION = {
        FORMATS = { DEFAULT = '({SYMBOL}: {CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    EMPTY = '我开不了嗓',
                    LOW = '我可以唱1首歌！',
                    MID = '我可以唱2首歌！',
                    HIGH = '我可以唱3首歌！'
                },
                SYMBOL = {
                    EMOJI = 'horn',
                    TEXT = '灵感'
                }
            }
        }
    },
    ENERGY = {
        FORMATS = {
            DEFAULT = '(电量: {CURRENT}/{MAX}，已占用电量：{USED}) {MESSAGE}',
            CHIP = '电路装载：{NUM} {ITEM}。',
        },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    ZERO = '电量：耗尽',
                    ONE = '电量：极低',
                    TWO = '电量：低',
                    THREE = '电量：高',
                    FOUR = '电量：较高',
                    FIVE = '电量：充足',
                    SIX = '电量：满格'
                }
            }
        }
    },
    GIFT = {
        FORMATS = {
            CAN_OPEN = '我有一个礼物，我要打开它！',
            NEED_SCIENCE = '我需要额外的科学来打开这个礼物！',
        },
        MAPPINGS = {}
    },
    PLAYER = {
        FORMATS = {
            DEFAULT = '{NAME} 在我这。',
            ADMIN = '{NAME} 是管理员耶！',
            NAME = '{NAME} 是 {CHARACTER}',
            AGE = '{NAME} 生存了 {AGE}。',
            AGE_SHORT = '{NAME} {AGE}。',
            PERF = '{NAME} 的 {PERF}。{PING}',
            GREET = '你好吖，{NAME}。',
            PING = 'Ping: {PING}',
            BADGE = '{NAME} 的头像是 {BADGE}。',
            BACKGROUND = '{NAME} 的背景是 {BACKGROUND}。',
            BODY = '{NAME} 的身体皮肤是 {BODY}。',
            HAND = '{NAME} 的手部皮肤是 {HAND}。',
            LEGS = '{NAME} 的腿部皮肤是 {LEGS}。',
            FEET = '{NAME} 的脚部皮肤是 {FEET}。',
            BASE = '{NAME} 的头部皮肤是 {BASE}。',
            HEAD_EQUIP = '{NAME} 的头部装备是 {HEAD_EQUIP}。',
            HAND_EQUIP = '{NAME} 的手部装备是 {HAND_EQUIP}。',
            BODY_EQUIP = '{NAME} 的身体装备是 {BODY_EQUIP}。',
        },
        MAPPINGS = {}
    },
    SERVER = {
        FORMATS = {
            NAME = '房间名：{NAME}',
            AGE = '服务器运行：{AGE}天',
            NUM_PLAYER = '服务器人数：{NUM}'
        },
        MAPPINGS = {}
    },
    SKILL_TREE = {
        FORMATS = {
            ACTIVATED = '{NAME} 已点亮技能 {SKILL}。',
            CAN_ACTIVATE = '{NAME} 可点亮技能 {SKILL}。',
        },
        MAPPINGS = {}
    },
    ENV = {
        FORMATS = {
            SINGLE = '我附近有{NAME}{SHOW_ME}。',
            DEFAULT = '我附近有{NUM} {NAME}{SHOW_ME}。',
            NAMED = '我附近有{NUM_PREFAB} {PREFAB_NAME}，其中有{NUM} 名为{NAME}{SHOW_ME}。',
            CODE = '名称：{NAME}，代码：{PREFAB}',
        },
        MAPPINGS = {
            DEFAULT = {
                WORDS = {
                    SHOW_ME = '（这个有 {SHOW_ME}）',
                }
            }
        }
    },
    SKIN = {
        FORMATS = {
            DEFAULT = '我有{NUM}个 {ITEM} 皮肤（共{TOTAL}个），这个叫『{SKIN}』。',
            NO_SKIN = '科雷什么时候出『{ITEM}』的皮肤啊！',
            HAS_NO_SKIN = '呜呜呜，我一个『{ITEM}』的皮肤都没有！'
        },
        MAPPINGS = {}
    },
    RECIPE = {
        FORMATS = {
            BUFFERED = '我做好了一个 {ITEM} 准备放置。',
            WILL_MAKE = '我可以制作一个 {ITEM}。',
            WE_NEED = '我需要制造个 {ITEM}。',
            CAN_SOMEONE = '有人可以帮我做一个 {ITEM} 吗？我需要一个 {PROTOTYPE} 才能制造它',
        },
        MAPPINGS = {}
    },
    ITEM = {
        FORMATS = {
            INV_SLOT = '{PRONOUN}拥有 {NUM} {ITEM}{ITEM_NAME}{IN_CONTAINER}{WITH_PERCENT}{POST_STATE}{SHOW_ME}。',
            EQUIP_SLOT = '{PRONOUN}装备了 {EQUIP_NUM} {ITEM}{ITEM_NUM}{ITEM_NAME}{IN_CONTAINER}{WITH_PERCENT}{POST_STATE}{SHOW_ME}。'
        },
        MAPPINGS = {
            DEFAULT = {
                PRONOUN = { I = '我', WE = '我们' },
                HEAT_ROCK = {
                    COLD = '，而且是冰冷的',
                    COOL = '，而且是有点冷的',
                    NORMAL = '，而且是常温的',
                    WARM = '，而且是有点热的',
                    HOT = '，而且是炙热的'
                },
                RECHARGE = {
                    CHARGING = '，还需充能{TIME}',
                    FULL = '，已充能完毕'
                },
                PERCENT_TYPE = { DURABILITY = '的耐久度', FRESHNESS = '新鲜度' },
                TIME = { MINUTES = '分', SECONDS = '秒' },
                WORDS = {
                    THIS_ONE = '这个',
                    ITEM_NAME = ' (有{NUM}个名为{NAME})',
                    ITEM_NUM = ' (共拥有{NUM}个)',
                    IN_CONTAINER = ' 在这个 {NAME} 里',
                    WITH_PERCENT = '，{THIS_ONE}拥有 {PERCENT} {TYPE}',
                    SUSPICIOUS_MARBLE = '，这个是 {NAME}',
                    SHOW_ME = '（这个有 {SHOW_ME}）',
                }
            }
        }
    },
    INGREDIENT = {
        FORMATS = {
            NEED = '我需要 {NUM} {INGREDIENT}{AND_PROTOTYPE} 来制造 {RECIPE}。',
            HAVE = '我有足够的 {INGREDIENT} 来制造 {NUM} {RECIPE}{BUT_PROTOTYPE}。'
        },
        MAPPINGS = {
            DEFAULT = {
                WORDS = {
                    AND_PROTOTYPE = ' 和一个 {PROTOTYPE}',
                    BUT_PROTOTYPE = '，但我还需要一个 {PROTOTYPE}'
                }
            }
        }
    },
    STOMACH = {
        FORMATS = { DEFAULT = '({SYMBOL}: {CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '高于75%…我完全饱了！',
                    HIGH = '55%…我可以吃一点！',
                    MID = '35%…我肚子饿瘪了！',
                    LOW = '15%…我非常饿！',
                    EMPTY = '低于15%…我马上要饿扑街了！',
                },
                SYMBOL = {
                    EMOJI = 'hunger',
                    TEXT = '饥饿'
                }
            },
            WILSON = {
                MESSAGE = {
                    FULL = '我填满了肚子！',
                    HIGH = '我还不缺乏吃的。',
                    MID = '我可以去吃一点儿。',
                    LOW = '我真的饿了！',
                    EMPTY = '我……需要……食物……',
                }
            },
            WILLOW = {
                MESSAGE = {
                    FULL = '如果我不停止吃会发胖的。',
                    HIGH = '愉快又饱满的。',
                    MID = '我的生命之火需要一点燃料。',
                    LOW = 'Ugh，我要饿死在这里了！',
                    EMPTY = '我现在已经饿的几乎皮包骨！',
                }
            },
            WOLFGANG = {
                MESSAGE = {
                    FULL = '沃尔夫冈是充实而强大的！',
                    HIGH = '沃尔夫冈必须吃饱，才能变得更加强大！！',
                    MID = '沃尔夫冈需要吃很多。',
                    LOW = '沃尔夫冈的肚子饿的开洞了。',
                    EMPTY = '沃尔夫冈现在急需要食物！！！',
                }
            },
            WENDY = {
                MESSAGE = {
                    FULL = '即使再多的食物也不会填补我心中的空洞。',
                    HIGH = '我饱了，但仍渴望没有朋友可以提供的东西。',
                    MID = '我不饿，但也不饱。很奇怪的感觉。',
                    LOW = '我的肚子就像心灵一样充满了空虚。',
                    EMPTY = '我发现最慢的死法——饿死。',
                }
            },
            WX78 = {
                MESSAGE = {
                    FULL = '  燃料 状态：最大容量',
                    HIGH = '  燃料 状态：高的',
                    MID = '  燃料 状态：合意的',
                    LOW = '  燃料 状态：低的',
                    EMPTY = '  燃料 状态：危险的 ',
                }
            },
            WICKERBOTTOM = {
                MESSAGE = {
                    FULL = '我应该从事研究工作，而不是填充自己。',
                    HIGH = '充斥的，但不是臃肿的。',
                    MID = '我感觉到有一点饥饿。',
                    LOW = '这个图书管理员需要食物，我是担心害怕的！',
                    EMPTY = '如果我不马上进食，就将会饿死！',
                }
            },
            WOODIE = {
                MESSAGE = {
                    FULL = '全部都满了！',
                    HIGH = '对于砍树仍然足够。',
                    MID = '能力需要一个小吃！',
                    LOW = '正餐铃响了！ ',
                    EMPTY = '我正在挨饿！',
                }
            },
            WES = {
                MESSAGE = {
                    FULL = '*拍拍肚子*',
                    HIGH = '*拍拍肚子*',
                    MID = '*手张开嘴*',
                    LOW = '*手张开嘴，眼睛瞪得大大的*',
                    EMPTY = '*紧抓凹陷的胃绝望的一个眼神*',
                }
            },
            WAXWELL = {
                MESSAGE = {
                    FULL = '我已经吃了完美的盛宴。',
                    HIGH = '我很满足，但是不要过量。',
                    MID = '吃个快餐可能很合适。',
                    LOW = '我的内心已经空了。',
                    EMPTY = '不！我没有挣到我得到自由将在饿死在这里！',
                }
            },
            WEBBER = {
                MESSAGE = {
                    FULL = '我们两者的胃部都爆满了。',
                    HIGH = '我们可以再多啃一点。',
                    MID = '我们认为是时候吃午饭了！',
                    LOW = '我们此时会吃妈妈的剩菜……',
                    EMPTY = '我们的胃是空的！',
                }
            },
            WATHGRITHR = {
                MESSAGE = {
                    FULL = '我渴望战斗，无需肉！',
                    HIGH = '我足够满足于战斗。',
                    MID = '我可以有一个肉类零食。',
                    LOW = '我渴望一场盛宴！',
                    EMPTY = '没有一些肉我就饿死了！',
                }
            },
            WINONA = {
                MESSAGE = {
                    FULL = '我今天吃了一顿正餐。',
                    HIGH = '我的胃总是有地方放存放更多食物！',
                    MID = '我的午餐休息时间还没到吗？',
                    LOW = '我快没油了，老板。',
                    EMPTY = '如果再不给点东西吃，工厂就没有了工人！',
                }
            },
            WARLY = {
                MESSAGE = {
                    FULL = '我的烹饪将会是我的死亡！',
                    HIGH = '我想现在我已经受够了。',
                    MID = '是时候在沙漠里吃晚餐了。',
                    LOW = '我错过了晚饭时间！',
                    EMPTY = '饥饿……是最难受的死亡方式！',
                }
            },
            WORMWOOD = {
                MESSAGE = {
                    FULL = '太多了。',
                    HIGH = '不需要肚子里的东西。',
                    MID = '可以给腹部填加肥料。',
                    LOW = '肚子需要东西。',
                    EMPTY = '哦，肚子疼……',
                }
            },
            WURT = {
                MESSAGE = {
                    FULL = '格鲁，我不要了。',
                    HIGH = '我不饿, 小花。',
                    MID = '我还能吃得下一些。',
                    LOW = '我很需要食物！',
                    EMPTY = '我真的很饿很饿！',
                }
            },
            WORTOX = {
                MESSAGE = {
                    FULL = '就不应该吃这么饱，肚子撑的要命！',
                    HIGH = '“魂”足饭饱，去恶作剧吧！Hyuyu!',
                    MID = '需要少量的灵... 如此致命。',
                    LOW = '我想要一个美味的灵魂！恶作剧暂且延后！',
                    EMPTY = '我对灵魂的渴望越来越贪婪！',
                }
            }
        }
    },
    SANITY = {
        FORMATS = { DEFAULT = '({SYMBOL}: {CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '高于75%…我的大脑在巅峰状态！',
                    HIGH = '55%…我感觉还不错！',
                    MID = '35%…我有点焦虑！',
                    LOW = '15%…我感觉，这里有点疯狂！',
                    EMPTY = '低于15%…啊哒，好疼！暗影恶魔在追我！',
                },
                SYMBOL = {
                    EMOJI = 'sanity',
                    TEXT = '脑残'
                }
            },
            WILSON = {
                MESSAGE = {
                    FULL = '视理智为还可以。',
                    HIGH = '我会好起来的。',
                    MID = '我的头很痛……',
                    LOW = 'Wha——那些行走的是什么！？',
                    EMPTY = '需要帮助！这些东西将要吃掉我！！',
                }
            },
            WILLOW = {
                MESSAGE = {
                    FULL = '我认为我现在有充足的精神烧火。',
                    HIGH = '我刚才看到伯尼在行走了么？……没有，不用介意。',
                    MID = '我感觉寒冷无比，我很可能……',
                    LOW = '伯尼，为什么我觉得如此寒冷！？',
                    EMPTY = '伯尼，保护我不受那些可怕的事物咬伤！',
                }
            },
            WOLFGANG = {
                MESSAGE = {
                    FULL = '沃尔夫冈的头感觉良好！',
                    HIGH = '沃尔夫冈的头感觉很有趣。',
                    MID = '沃尔夫冈的头很疼',
                    LOW = '沃尔夫冈看到可怕的怪物……',
                    EMPTY = '到处都是可怕的怪物！！',
                }
            },
            WENDY = {
                MESSAGE = {
                    FULL = '我的思维运转地晶莹剔透。',
                    HIGH = '我的思维渐渐变得阴郁。',
                    MID = '我的思维是极度兴奋的……',
                    LOW = '阿比盖尔！你看到它们了么？这些恶魔可能很快能使我加入你。',
                    EMPTY = '带我去阿比盖尔那里，黑暗和夜晚的生物！',
                }
            },
            WX78 = {
                MESSAGE = {
                    FULL = '  CPU 状态：全面运转',
                    HIGH = '  CPU 状态：功能的',
                    MID = '  CPU 状态：破损的',
                    LOW = '  CPU 状态：故障迫近',
                    EMPTY = '  CPU 状态：多重故障检测',
                }
            },
            WICKERBOTTOM = {
                MESSAGE = {
                    FULL = '在这里没有什么行为是非理智的。',
                    HIGH = '我相信我有一点令人头痛之事。',
                    MID = '这些偏头痛是难以忍受的。',
                    LOW = '我不确定哪些事物是虚构的，再也不！',
                    EMPTY = '帮帮我！这些深不可测又令人可憎的敌人！',
                }
            },
            WOODIE = {
                MESSAGE = {
                    FULL = '好的犹如一把小提琴曲',
                    HIGH = '还好，可以来一小杯咖啡',
                    MID = '我想我需要一个午睡！',
                    LOW = '退后，噩梦一般的东西！',
                    EMPTY = '所有恐惧都是真实的，还有伤害！',
                }
            },
            WES = {
                MESSAGE = {
                    FULL = '*行礼*',
                    HIGH = '*翘起姆指*',
                    MID = '*按摩太阳穴*',
                    LOW = '*扫视四处疯狂似地*',
                    EMPTY = '*摇篮一样的头，来回摇摆*',
                }
            },
            WAXWELL = {
                MESSAGE = {
                    FULL = '衣冠楚楚的可以。',
                    HIGH = '我通常坚定的智慧似乎是……摇摆不定。',
                    MID = 'Ugh，我头好痛。',
                    LOW = '我需要明确我的头脑，我开始看到……它们。',
                    EMPTY = 'Help！这些阴影是真正的野兽，你要知道！',
                }
            },
            WEBBER = {
                MESSAGE = {
                    FULL = '我们感觉健康又精力充沛。',
                    HIGH = '小睡一会可以回复一下。',
                    MID = '我们的头好痛……',
                    LOW = '我们上一次有午睡吗？！',
                    EMPTY = '我们不害怕你，可怕的东西！',
                }
            },
            WATHGRITHR = {
                MESSAGE = {
                    FULL = '我担心没有凡人！',
                    HIGH = '我会在战场上感觉更好！',
                    MID = '我迷离的思绪……',
                    LOW = '这些阴影穿过我的矛……',
                    EMPTY = '退后，黑暗怪兽！',
                }
            },
            WINONA = {
                MESSAGE = {
                    FULL = '我会永远保持理智。',
                    HIGH = '全部还好但低于我的头巾！',
                    MID = '我想我的螺丝松了……',
                    LOW = '我的心碎了，我应该把它修好。',
                    EMPTY = '这是一场噩梦！哈！但它很真实。',
                }
            },
            WARLY = {
                MESSAGE = {
                    FULL = '我做菜的香味让我神智清醒。',
                    HIGH = '我觉得有点头晕。',
                    MID = '我的脑筋不能转弯了。',
                    LOW = '窃窃私语……救命啊！',
                    EMPTY = '我再也受不了这种精神错乱了！',
                }
            },
            WORMWOOD = {
                MESSAGE = {
                    FULL = '感觉很棒！',
                    HIGH = '头感觉很好。',
                    MID = '头痛，但感觉还好。',
                    LOW = '恐怖的东西在看着我。',
                    EMPTY = '恐怖的东西在伤害我！',
                }
            },
            WURT = {
                MESSAGE = {
                    FULL = '好开心！',
                    HIGH = '精神很好, 小花。',
                    MID = '格鲁, 我的头部受伤了。',
                    LOW = '可怕的黑影要过来了！',
                    EMPTY = '格鲁, 可怕的噩梦怪物！！',
                }
            },
            WORTOX = {
                MESSAGE = {
                    FULL = '头脑清醒...欢乐时光即将到来！Hyuyu!',
                    HIGH = '我能吸点灵魂来保持我头脑清醒吗?',
                    MID = '害！刚太跳了，现在有点头痛...',
                    LOW = '我好羡慕这些影子的戏法! Hyuyu!',
                    EMPTY = '我的思想处于一个纯粹疯狂的新境界!',
                }
            }
        }
    },
    HEALTH = {
        FORMATS = { DEFAULT = '({SYMBOL}: {CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '100%…我去，血槽满了！',
                    HIGH = '75%…我挂了一些彩！',
                    MID = '50%…我靠，严重挂彩！',
                    LOW = '25%…血肉模糊，我已写好遗书！',
                    EMPTY = '低于25%…看管好我的财产！',
                },
                SYMBOL = {
                    EMOJI = 'heart',
                    TEXT = '生命'
                },
            },
            WILSON = {
                MESSAGE = {
                    FULL = '健康的如一把小提琴！',
                    HIGH = '我受伤了，但我可以继续行动。',
                    MID = '我……我想我需要注意治疗。',
                    LOW = '我失去了很多血……',
                    EMPTY = '我……我将不能走完路程……',
                }
            },
            WILLOW = {
                MESSAGE = {
                    FULL = '完美的我就应该没有一块伤痕！',
                    HIGH = '我有一两处擦伤。我或许应该点燃它们。',
                    MID = '这些裂口使我不再燃烧，我需要个医生……',
                    LOW = '我觉得虚弱……我可能会……熄灭。',
                    EMPTY = '我的生命之火几乎要熄灭……',
                }
            },
            WOLFGANG = {
                MESSAGE = {
                    FULL = '沃尔夫冈现在不需要修理！',
                    HIGH = '沃尔夫冈需要点小修理',
                    MID = '沃尔夫冈受伤了。',
                    LOW = '沃尔夫冈需要很多的绷带来治疗伤口。',
                    EMPTY = '沃尔夫冈或许要死了……',
                }
            },
            WENDY = {
                MESSAGE = {
                    FULL = '我痊愈了，但我相信我将再次受到伤害。',
                    HIGH = '我感到疼痛，但是不多。',
                    MID = '生存带来了痛苦，但是我不习惯这么多。',
                    LOW = '流了很多血……将会很容易……',
                    EMPTY = '我很快将与阿比盖尔……',
                }
            },
            WX78 = {
                MESSAGE = {
                    FULL = '  底盘 状态：理想状况',
                    HIGH = '  底盘 状态：裂纹检测',
                    MID = '  底盘 状态：中度损坏',
                    LOW = '  底盘 状态：完全性损坏',
                    EMPTY = '  底盘 状态：无功能的',
                }
            },
            WICKERBOTTOM = {
                MESSAGE = {
                    FULL = '我的健康可以预计我的年龄！',
                    HIGH = '受一些擦伤，但是无关紧要。',
                    MID = '我的医疗需要装配。',
                    LOW = '如果不治疗，这将是我的结局。',
                    EMPTY = '我需要立刻马上就医！',
                }
            },
            WOODIE = {
                MESSAGE = {
                    FULL = '合适的犹如一个哨子！',
                    HIGH = '大难不死，必有后福。',
                    MID = '可以和使用一些物品来变得健康',
                    LOW = '这是痛苦真正的开始……',
                    EMPTY = '让我永眠…… 在这颗树下……',
                }
            },
            WES = {
                MESSAGE = {
                    FULL = '*手结成心*',
                    HIGH = '*触摸脉搏，竖起大拇指*',
                    MID = '*手在手臂来回移动，示意包扎它*',
                    LOW = '*摇晃手臂*',
                    EMPTY = '*大幅摇摆，然后摔倒了*',
                }
            },
            WAXWELL = {
                MESSAGE = {
                    FULL = '我完全安然无恙。',
                    HIGH = '它只是一个擦伤。',
                    MID = '我可能需要给自己打个补丁。',
                    LOW = '这不是我的天鹅之歌，但是我已经接近。',
                    EMPTY = '不！我没有逃避而死在这里！',
                }
            },
            WEBBER = {
                MESSAGE = {
                    FULL = '我们甚至没有划痕一丝！',
                    HIGH = '我们需要一个创可贴。',
                    MID = '我们需要再贴一个创可贴……',
                    LOW = '我们的身体剧痛……',
                    EMPTY = '我们还不想死……',
                }
            },
            WATHGRITHR = {
                MESSAGE = {
                    FULL = '我的皮肤是无懈可击的！',
                    HIGH = '它只是一个轻伤！',
                    MID = '我受伤了，但我还能战斗。',
                    LOW = '没有援助，我很快就会在瓦尔哈拉殿堂……',
                    EMPTY = '我的传奇人生即将结束……',
                }
            },
            WINONA = {
                MESSAGE = {
                    FULL = '我健康的犹如一匹汗血宝马！',
                    HIGH = '嗯，我来解决它。',
                    MID = '我仍然不能放弃。',
                    LOW = '我可以领取工人的退休金吗…？',
                    EMPTY = '我想我的轮班已经结束了……',
                }
            },
            WARLY = {
                MESSAGE = {
                    FULL = '我非常健康。',
                    HIGH = '在切洋葱时我很糟糕。',
                    MID = '我流血了……',
                    LOW = '我可以用一些援助！',
                    EMPTY = '我猜这就是我的结局了，挚友们……',
                }
            },
            WORMWOOD = {
                MESSAGE = {
                    FULL = '苦艾没有受伤。',
                    HIGH = '缺一点，但还好。',
                    MID = '感到虚弱。',
                    LOW = '疼痛的非常严重。',
                    EMPTY = '救救我，好朋友！',
                }
            },
            WURT = {
                MESSAGE = {
                    FULL = '我很健康, 小花!',
                    HIGH = '我感觉很好!',
                    MID = '我需要帮助，我的鳞片掉了一些……',
                    LOW = '呜咽，疼得厉害……',
                    EMPTY = '救……命……啊！！！',
                }
            },
            WORTOX = {
                MESSAGE = {
                    FULL = '我现在状态绝佳，可以尽情捣蛋！',
                    HIGH = '只是擦伤，一个灵魂就可以把它修复！',
                    MID = '我需要一些灵魂来抚平这些伤口... Hyuyu!',
                    LOW = '我自己的灵魂开始变得脆弱...',
                    EMPTY = '我的灵魂将不再属于我! Hyuyu...',
                }
            }
        }
    },
    WETNESS = {
        FORMATS = { DEFAULT = '({SYMBOL}: {CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '高于75%…完全湿身！',
                    HIGH = '55%…我湿透了，哇！背包好隔水，把我装进去吧！',
                    MID = '35%…我很湿！我去，背包也湿了！',
                    LOW = '15%…我只湿了一小块，还不足为惧！',
                    EMPTY = '我有一点点潮湿……',
                },
                SYMBOL = {
                    TEXT = '雨露'
                },
            },
            WILSON = {
                MESSAGE = {
                    FULL = '我已经达到了饱和点！',
                    HIGH = '水快滚出去！',
                    MID = '我的衣服几乎渗透。',
                    LOW = 'Oh， H2O。',
                    EMPTY = '我比较干燥。',
                }
            },
            WILLOW = {
                MESSAGE = {
                    FULL = 'Ugh，这雨是最——坏——的！',
                    HIGH = '我讨厌这一切水！',
                    MID = '这场雨太多了。',
                    LOW = 'Uh oh，如果这场雨持续上升……',
                    EMPTY = '没有足够的雨水能灭了火。',
                }
            },
            WOLFGANG = {
                MESSAGE = {
                    FULL = '沃尔夫冈现在可能是水做的！',
                    HIGH = '这就像坐在池塘里……',
                    MID = '沃尔夫冈不喜欢洗澡。',
                    LOW = '雨水时代。',
                    EMPTY = '沃尔夫冈是干燥的。',
                }
            },
            WENDY = {
                MESSAGE = {
                    FULL = '满是水的末世。',
                    HIGH = '长久的湿润和悲伤。',
                    MID = '湿软而又悲伤。',
                    LOW = '或许这些水分能填补我心灵的虚空。',
                    EMPTY = '我的皮肤和我的心灵一样干。',
                }
            },
            WX78 = {
                MESSAGE = {
                    FULL = '  受潮 状况：已达临界值',
                    HIGH = '  受潮 状况：接近临界值',
                    MID = '  受潮 状况：无法接受的',
                    LOW = '  受潮 状况：可容许的',
                    EMPTY = '  受潮 状况：合意的',
                }
            },
            WICKERBOTTOM = {
                MESSAGE = {
                    FULL = '完全绝对浸湿！',
                    HIGH = '我是湿的，湿的，湿的！重要的事情说三遍！',
                    MID = '我想知道我的最高承受力是……',
                    LOW = '水膜开始形成了 。',
                    EMPTY = '我的水分是足够缺乏的。',
                }
            },
            WOODIE = {
                MESSAGE = {
                    FULL = '这鬼天气导致我不能砍树。',
                    HIGH = '因为这些雨水让格子花呢不再保暖。',
                    MID = '我获得了相当的水分。',
                    LOW = '格子花呢很温暖，也很潮湿。',
                    EMPTY = '对我几乎不受影响。',
                }
            },
            WES = {
                MESSAGE = {
                    FULL = '*疯狂地向上游泳*',
                    HIGH = '*向上游泳*',
                    MID = '*悲惨地看向天空*',
                    LOW = '*保护头部武装起来*',
                    EMPTY = '*微笑，拿着无形的保护伞*',
                }
            },
            WAXWELL = {
                MESSAGE = {
                    FULL = '湿润的好比水本身。',
                    HIGH = '我不认为我会再次干燥。',
                    MID = '这水会毁了我的西装。',
                    LOW = '潮湿使我变得不整洁。',
                    EMPTY = '干燥而整洁的。',
                }
            },
            WEBBER = {
                MESSAGE = {
                    FULL = '哇哈，我们湿透了！',
                    HIGH = '我们的毛皮被浸泡了！',
                    MID = '我们很湿！',
                    LOW = '我们湿润地不讨人喜欢。',
                    EMPTY = '我们喜欢在坑里玩耍。',
                }
            },
            WATHGRITHR = {
                MESSAGE = {
                    FULL = '我完全湿透了！',
                    HIGH = '一个战士在这雨天无法战斗！',
                    MID = '我的护甲会生锈！',
                    LOW = '我不需要洗澡。',
                    EMPTY = '干澡够了继续战斗！',
                }
            },
            WINONA = {
                MESSAGE = {
                    FULL = '我不能在这种湿度下工作！',
                    HIGH = '我的工作服正在吸收水份！',
                    MID = '有人应该放下一个湿地板标志。',
                    LOW = '在工作的时候补充水分是总是好的。',
                    EMPTY = '这里没有什么。',
                }
            },
            WARLY = {
                MESSAGE = {
                    FULL = '我能感觉到鱼在我的衬衫里游泳。',
                    HIGH = '水会毁了我完美的菜肴！',
                    MID = '在我感冒之前，我应该把衣服烘干。',
                    LOW = '现在不是洗澡的时间或地点。',
                    EMPTY = '只有几滴在我身上，没有坏处。',
                }
            },
            WORMWOOD = {
                MESSAGE = {
                    FULL = '真的真的湿了！',
                    HIGH = '真的湿了！',
                    MID = '感觉有点湿。',
                    LOW = '下雨了！哦吼！',
                    EMPTY = '感到干燥。',
                }
            },
            WURT = {
                MESSAGE = {
                    FULL = '啊哈哈，水花溅呀溅！！',
                    HIGH = '我的鳞片很舒服！',
                    MID = '美人鱼 喜欢水, 小花!',
                    LOW = '啊哈……有点水更好, 小花!',
                    EMPTY = '太干燥了, 格鲁.',
                }
            },
            WORTOX = {
                MESSAGE = {
                    FULL = '我完全湿透了!',
                    HIGH = '我就是这条街最潮湿的恶魔!',
                    MID = '不久的将来这会有一只湿漉漉的恶魔！',
                    LOW = '世界正赐予我一场淋浴!',
                    EMPTY = '如果我想保持干燥的话，我应该都留意一下天气！',
                }
            }
        }
    },
}
