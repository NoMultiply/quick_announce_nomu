GLOBAL.STRINGS.NOMU_QA.TITLE_TEXT_CUTE_SCHEME = '软萌方案'

GLOBAL.STRINGS.CUTE_NOMU_QA = {
    SEASON = {
        FORMATS = { DEFAULT = '呐～{SEASON}还剩 {DAYS_LEFT} 天呢，时间过得好快󰀜～' },
        MAPPINGS = {
            DEFAULT = {
                SEASON_NAMES = { 
                    AUTUMN = '秋季', WINTER = '冬季', SPRING = '春季', SUMMER = '夏季'
                }
            }
        }
    },
    WORLD_TEMPERATURE_AND_RAIN = {
        FORMATS = {
            START_RAIN = '呀～{WORLD}气温 {TEMPERATURE}，第 {DAYS} 天{WEATHER}（剩：{MINUTES}分{SECONDS}秒）要带小伞哦󰀜～',
            NO_RAIN = '唔……{WORLD}气温 {TEMPERATURE}，天空很乖，{WEATHER}还没来呢󰀜～',
            STOP_RAIN = '哇！{WORLD}气温 {TEMPERATURE}，第 {DAYS} 天放晴（剩：{MINUTES}分{SECONDS}秒）可以出去玩啦󰀜～',
            START_FOG = '呀～{WORLD}气温 {TEMPERATURE}，第 {DAYS} 天起孢子雾（剩：{MINUTES}分{SECONDS}秒）视野会变差呢󰀜～',
            FOGGING = '唔……{WORLD}气温 {TEMPERATURE}，现在起好大的孢子雾，看不清啦󰀜～',
            BWB_CAVE_WEATHER = '呀～{WORLD}气温 {TEMPERATURE}，{FOG_STATUS}，并且{RAIN_STATUS}呢󰀜～',
        },
        MAPPINGS = {
            DEFAULT = {
                WORLD = { SURFACE = '地表', CAVES = '洞穴', SHIPWRECKED = '海难', VOLCANO = '火山', PORKLAND = '猪镇', WINTERLAND = '冰岛' },
                WEATHER = { SPRING = '下小雨', SUMMER = '下雨啦', AUTUMN = '下雨啦', WINTER = '飘雪花', GREEN = '下雨啦', DRY = '下雨啦', MILD = '下雨啦', WET = '刮大风', TEMPERATE = '下雨啦', HUMID = '下雨啦', LUSH = '下雨啦', APORKALYPSE = '下雨啦', TRANQUIL = '起孢子雾', FROST = '掉小石头', VERDANT = '起孢子雾', UMBRAL = '奇怪天气' },
                BWB_WORDS = {
                    RAIN_APPROACH = "调皮的雨水第{DAYS}天来(剩{MINUTES}分{SECONDS}秒)",
                    RAIN_STOP = "雨水第{DAYS}天停下(剩{MINUTES}分{SECONDS}秒)",
                    RAIN_NONE = "天空乖乖的没下雨呢",
                    FOG_ACTIVE = "正处于朦胧孢子雾中呢",
                    FOG_APPROACH = "孢子雾第{DAYS}天飘过来(剩{MINUTES}分{SECONDS}秒)",
                    FOG_NONE = "空气清晰，没有孢子雾呢"
                }
            }
        }
    },
    TEMPERATURE = {
        FORMATS = { DEFAULT = '({TEMPERATURE}°) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    BURNING = '呜呜好烫好烫！要被烤熟啦󰀜～',
                    HOT = '呼呼～好热呢，想吃冰淇淋降温啦󰀜～',
                    WARM = '暖呼呼的～好舒服，想打个哈欠󰀜～',
                    GOOD = '温度刚刚好，适合睡懒觉呢，嘿嘿󰀜～',
                    COOL = '阿嚏！有一点点凉意，要多穿衣服呢󰀜～',
                    COLD = '呜呜好冷好冷，需要一个温暖的抱抱󰀜～',
                    FREEZING = '冻僵啦……要变成小冰雕了嘤嘤嘤󰀜～',
                }
            }
        }
    },
    MOON_PHASE = {
        FORMATS = {
            DEFAULT = '哇哦！{RECENT}{PHASE1}{INTERVAL}离下个{PHASE2}还有 {LEFT} 天呢󰀜～',
            MOON = '快看快看！{RECENT}{PHASE1}啦，月亮姐姐好漂亮󰀜～',
            FAILED = '呜呜……云层太厚，看不清月亮姐姐的样子呢󰀜～'
        },
        MAPPINGS = {
            DEFAULT = {
                MOON = { FULL = '月亮圆圆', NEW = '黑漆漆夜' },
                INTERVAL = { COMMA = '，', NONE = '' },
                RECENT = { TODAY = '今晚是', TOMORROW = '明晚是', AFTER = '刚度过' },
            }
        }
    },
    CLOCK = {
        FORMATS = {
            DEFAULT = '{PHASE}还剩 {PHASE_REMAIN}，今天还有 {DAY_REMAIN} 可以玩呢󰀜～',
            NIGHTMARE = '{PHASE}还剩 {PHASE_REMAIN}，今天还有 {DAY_REMAIN}，{NIGHTMARE}还有 {REMAIN} 就结束啦󰀜～',
            NIGHTMARE_LOCK = '{PHASE}还剩 {PHASE_REMAIN}，今天还有 {DAY_REMAIN}，现在是可怕的{NIGHTMARE}呢󰀜～'
        },
        MAPPINGS = {
            DEFAULT = {
                TIME = { MINUTES = '分', SECONDS = '秒' },
                PHASE = { DAY = '明亮的白天', DUSK = '黄昏的彩霞', NIGHT = '黑黑的夜晚' },
                NIGHTMARE = {
                    CALM = "乖乖的平息阶段",
                    WARN = "呀！暗影在警告了",
                    WILD = "坏家伙们暴动啦",
                    DAWN = "马上就过去的过渡阶段",
                },
            }
        }
    },
    COOK = {
        FORMATS = {
            CAN = '可以给大家做美味的 {NAME} 哦󰀜～',
            NEED = '肚子饿饿，好想吃一口 {NAME} 呢󰀜～',
            MIN_INGREDIENT = '做甜甜的 {NAME} 至少要 {NUM} 个 {INGREDIENT} 呢󰀜～',
            MAX_INGREDIENT = '煮 {NAME} 最多只能放 {NUM} 个 {INGREDIENT} 哦󰀜～',
            ZERO_INGREDIENT = '呀！{NAME} 里绝对不可以放 {INGREDIENT} 啦󰀜～',
            HUNGER = '{NAME} {TYPE}小肚肚 {VALUE} 点饱饱度呢󰀜～',
            SANITY = '{NAME} {TYPE}小脑阔 {VALUE} 点开心值呢󰀜～',
            HEALTH = '{NAME} {TYPE}身体 {VALUE} 点健康值呢󰀜～',
            FOOD = '当当！{NAME}：饱饱 {HUNGER}，开心 {SANITY}，健康 {HEALTH}󰀜～',
            FOOD_LOCK = '唔……人家还没学会做 {NAME} 呢󰀜～',
            FOOD_NO_EATEN = '喂我尝一口 {NAME} 才能知道味道呢󰀜～',
        },
        MAPPINGS = {
            DEFAULT = {
                TYPE = { POS = '涨', NEG = '掉' }
            }
        }
    },
    BOAT = {
        FORMATS = { DEFAULT = '(小船船：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '小船超级结实！出发去冒险啦󰀜～',
                    HIGH = '碰坏了一点点，不过没关系呢󰀜～',
                    MID = '小船漏水啦，有点怕怕的󰀜～',
                    LOW = '呜呜！要沉了要沉了，快修修它󰀜～',
                    EMPTY = '咕噜噜……大家要掉水里了嘤嘤嘤󰀜～',
                }
            }
        }
    },
    ABIGAIL = {
        FORMATS = { DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '阿比盖尔姐姐会保护我的，超有安全感󰀜～',
                    HIGH = '呀！阿比盖尔姐姐受了一点点伤呢󰀜～',
                    MID = '姐姐你还好吗？好担心呢󰀜～',
                    LOW = '阿比盖尔姐姐快躲开！别受伤呜呜󰀜～',
                    EMPTY = '别丢下我一个人……姐姐快回来󰀜～',
                },
                SYMBOL = { EMOJI = 'ghost', TEXT = '姐姐' }
            }
        }
    },
    LOG_METER = {
        FORMATS = { DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '嗷呜！变成毛茸茸大怪兽啦󰀜～',
                    HIGH = '大毛绒玩具还有好多活力呢󰀜～',
                    MID = '唔……变身的力气用掉一半了呢󰀜～',
                    LOW = '耳朵要垂下来了，需要休息󰀜～',
                    EMPTY = '变回软软小可爱啦，要抱抱󰀜～',
                },
                SYMBOL = { TEXT = '野兽值' }
            }
        }
    },
    MIGHTINESS = {
        FORMATS = { DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    MIGHTY = '嘿咻！现在力气超大，能举起大石头󰀜～',
                    NORMAL = '正在努力锻炼身体呢，嘿咻嘿咻󰀜～',
                    WIMPY = '呜呜……胳膊软绵绵的，拿不动木棍啦󰀜～',
                },
                SYMBOL = { EMOJI = 'flex', TEXT = '力气' }
            }
        }
    },
    INSPIRATION = {
        FORMATS = { DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    EMPTY = '唔，嗓子干干的，唱不出甜甜的歌了󰀜～',
                    LOW = '可以给大家哼一首小曲子呢󰀜～',
                    MID = '清清嗓子～可以连唱两首歌哦󰀜～',
                    HIGH = '灵感满满！给大家开演唱会连唱三首哦󰀜～'
                },
                SYMBOL = { EMOJI = 'horn', TEXT = '灵感值' }
            }
        }
    },
    ENERGY = {
        FORMATS = {
            DEFAULT = '(电量：{CURRENT}/{MAX}，已用：{USED}格) 呼呼～小电池现在{MESSAGE}呢󰀜～',
            CHIP = '{NUM}个亮晶晶的 {ITEM}',
            ALL_MODULES = '装配了这些魔法电路哦：{MODULES}󰀜～',
            NO_MODULES = '唔……身上还没装任何神奇电路呢󰀜～'
        },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    ZERO = '没电电了',
                    ONE = '快熄灭了',
                    TWO = '电量低低的',
                    THREE = '还有一半哦',
                    FOUR = '能量满满',
                    FIVE = '超级精神',
                    SIX = '充满魔力啦'
                }
            }
        }
    },
    GIFT = {
        FORMATS = {
            CAN_OPEN = '哇！是给我的小礼物嘛？好想马上拆开󰀜～',
            NEED_SCIENCE = '唔……包裹太紧，需要科学机器帮忙才能拆开呢󰀜～',
        },
        MAPPINGS = {}
    },
    PLAYER = {
        FORMATS = {
            DEFAULT = '{NAME} 在我身边陪着我呢󰀜～',
            ADMIN = '哇哦，{NAME} 是超级厉害的管理员󰀜～',
            NAME = '{NAME} 选的是 {CHARACTER} 哦󰀜～',
            CHOOSING = '{NAME} 正在纠结选哪个可爱角色呢󰀜～',
            CONNECTING = '{NAME} 正在连接中，稍等一下下󰀜～',
            ME_RIDING = '哇哦！正在骑着 {MOUNT} 开心兜风呢󰀜～',
            ME_CARRYING = '哎呀呀～正在搬运沉沉的 {ITEM}，走得好慢好慢󰀜～',
            AGE = '{NAME} 在这里度过了 {AGE} 时光呢󰀜～',
            AGE_SHORT = '{NAME} 活了 {AGE} 啦󰀜～',
            PERF = '{NAME} 的网络 {STATUS}，{PING}󰀜～',
            GREET = '好开心见到你，{NAME}󰀜～',
            PING = '延迟：{PING}󰀜～',
            BADGE = '{NAME} 戴着 {BADGE} 呢󰀜～',
            BACKGROUND = '{NAME} 的背景是 {BACKGROUND}󰀜～',
            BODY = '{NAME} 穿着漂亮的 {BODY}󰀜～',
            HAND = '{NAME} 小手上戴着 {HAND}󰀜～',
            LEGS = '{NAME} 腿上穿着 {LEGS}󰀜～',
            FEET = '{NAME} 脚上穿着 {FEET}󰀜～',
            BASE = '{NAME} 顶着可爱的 {BASE} 脑袋󰀜～',
            HEAD_EQUIP = '{NAME} 头上戴着 {HEAD_EQUIP} 哦󰀜～',
            HAND_EQUIP = '{NAME} 手里拿着 {HAND_EQUIP}󰀜～',
            BODY_EQUIP = '{NAME} 身上穿着 {BODY_EQUIP} 呢󰀜～',
            GIVE_ITEM = "{NAME} 站好哦～要给你 {NUM}个 {ITEM_NAME} 呢󰀜～",
            BOTH_GHOST = "呜呜呜，{NAME}，我们都变成小幽灵了󰀜～",
            ME_GHOST = "拜托拜托 {NAME} 救救我，想要一颗告密的心复活󰀜～",
            THEY_GHOST = "{NAME} 不要怕！这就来救你啦󰀜～",
            I_AM_HERE = "{NAME}，人家就在这里哦！快看󰀜～",
            I_AM_GHOST = "救命！人家变成轻飘飘小幽灵了！谁来救救我󰀜～",
            ME_FISHING = '嘘——{NAME} 在施展钓鱼魔法，小鱼快上钩󰀜～',
            THEY_FISHING = '哇哦！{NAME} 正在认真钓鱼呢，祝钓到胖胖鱼󰀜～',
            PORTAL_ON = '小手已经摸到 {NAME} 啦󰀜～',
            PORTAL_OFF = '{NAME} 就在这里，大家快来准备传送󰀜～',
            ME_FROZEN = "呜呜救命！{NAME} 被冻成硬邦邦小冰雕了󰀜～",
            THEY_FROZEN = "大家快来生火帮忙！{NAME} 被冻住了好可怜󰀜～"
        },
        MAPPINGS = {
            DEFAULT = {
                PERF_STATUS = {
                    GOOD = '绿油油的',
                    OK = '金灿灿的',
                    BAD = '红彤彤的',
                    UNKNOWN = '不知道呢'
                }
            }
        }
    },
    SERVER = {
        FORMATS = {
            NAME = '温馨小家叫：{NAME}󰀜～',
            AGE = '世界已度过：{AGE} 个日夜啦󰀜～',
            NUM_PLAYER = '现在家里有：{NUM} 个小伙伴在玩呢󰀜～',
            WORLD_SETTING = '小家的【{SETTING}】设置为【{VALUE}】󰀜～',
            MOD_SETTING = '模组【{MOD}】把【{SETTING}】设为【{VALUE}】󰀜～'
        },
        MAPPINGS = {}
    },
    SKILL_TREE = {
        FORMATS = {
            ACTIVATED = '{NAME} 学会了神奇的『{SKILL}』！好厉害󰀜～',
            CAN_ACTIVATE = '{NAME} 可以去学『{SKILL}』了，快去快去󰀜～',
            NOT_ACTIVATED = '{NAME} 还没学会『{SKILL}』呢，继续加油哦󰀜～',
            XP = '{NAME} 还有 {XP} 点洞察呢󰀜～',
            DESC = '{NAME} 学会『{SKILL}』可以<{DESC}>󰀜～',
        },
        MAPPINGS = {}
    },
    SPACE = {
        FORMATS = {
            PLAYER = "小包包还有 {COUNT} 个空位，还能装零食󰀜～",
            INV = "{CONTAINER_NAME} 还有 {COUNT} 个空位呢󰀜～",
            CONTAINER = "{CONTAINER_NAME} 还能塞下 {COUNT} 个小玩意哦󰀜～"
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
                    HEALTH_HIGH = "哇！牛牛超级健康，壮得像座小山！（生命：{PCT}%）󰀜～",
                    HEALTH_NORMAL = "牛牛状态还不错呢，乖乖的。（生命：{PCT}%）󰀜～",
                    HEALTH_LOW = "呜呜！牛牛受了重伤，快救救它！（生命：{PCT}%）󰀜～",
                    
                    HUNGER_FULL = "嗝～牛牛肚皮圆圆的，塞不下啦。（饥饿：{VAL}）󰀜～",
                    HUNGER_NORMAL = "牛牛现在肚子不饿呢～（饥饿：{VAL}）󰀜～",
                    HUNGER_HUNGRY = "牛牛肚子叫了，想喂它吃草草呢！（饥饿：{VAL}）󰀜～",
                    HUNGER_STARVING = "牛牛饿得好可怜，快给它好吃的呜呜！（饥饿：{VAL}）󰀜～",
                    
                    OBEDIENCE_HIGH = "看！牛牛像小宝宝一样听话呢！（顺从：{PCT}%）󰀜～",
                    OBEDIENCE_NORMAL = "牛牛还算听话哦，没有闹脾气。（顺从：{PCT}%）󰀜～",
                    OBEDIENCE_LOW = "呀！牛牛有点生气，要把我甩下来了！（顺从：{PCT}%）󰀜～",
                    
                    DOMESTICATION_FULL = "嘿嘿！我是超级驯牛小能手啦！（已驯服）󰀜～",
                    DOMESTICATION_HIGH = "牛牛马上就会永远跟着我啦！（驯化：{PCT}%）󰀜～",
                    DOMESTICATION_NORMAL = "想让牛牛听话还得继续努力呢～（驯化：{PCT}%）󰀜～",
                    DOMESTICATION_LOW = "牛牛太野了，都不让摸摸呜呜……（驯化：{PCT}%）󰀜～",
                    
                    TIMER_RIDING = "抓紧牛角哦！还能再骑 {TIME} 呢󰀜～",
                    TIMER_LOW = "呀！牛牛要发脾气了，马上掉下来了！（剩：{TIME}）󰀜～"
                },
                TENDENCY_NAME = {
                    DEFAULT = "普通宝宝",
                    RIDER = "跑跑宝宝",
                    ORNERY = "凶凶宝宝",
                    PUDGY = "胖胖宝宝",
                    UNKNOWN = "未知宝宝"
                }
            }
        }
    },
    ENV = {
        FORMATS = {
            SINGLE = '呐～这里有 1个 {NAME}{SHOW_ME}{DISTANCE}呢󰀜～',
            DEFAULT = '哇～附近一共有 {NUM}个 {NAME}{SHOW_ME}{DISTANCE}󰀜～',
            NAMED = '发现啦～有 {NUM_PREFAB}个 {PREFAB_NAME}，其中 {NUM}个 名叫 {NAME}{SHOW_ME}{DISTANCE}󰀜～',
            CODE = '名称：{NAME}，代码：{PREFAB}{MOD_INFO}{ASSET_INFO}󰀜～',
            FISH_SHOAL = '快来看！有一大群小 {FISH}（共 {NUM} 条）{SHOW_ME}{DISTANCE}󰀜～',

            STATE_EQUAL = '好神奇～{TOTAL}个 {NAME} 全都{ADJ}了呢{SHOW_ME}{DISTANCE}󰀜～',
            STATE_DESCRIBE = '哇～{TOTAL}个 {NAME} 中有 {NUM}个 已经{ADJ}了{SHOW_ME}{DISTANCE}󰀜～',
            STATE_THIS = '悄悄告诉你～{TOTAL}个 {NAME} 中这个{ADJ}了呢{SHOW_ME}{DISTANCE}󰀜～',
            STATE_THIS_SINGLE = '这里有 1个 {NAME}，目前它{ADJ}啦{SHOW_ME}{DISTANCE}󰀜～',
            STORAGE_HAS = '这里有 {TOTAL}个 {NAME}，其中这个藏了 {NUM}个 {ITEM}{SHOW_ME}{DISTANCE}󰀜～',
            STORAGE_EMPTY = '这里有 {TOTAL}个 {NAME}，其中 {NUM}个 是空肚子的{SHOW_ME}{DISTANCE}󰀜～',
        },
        MAPPINGS = {
            DEFAULT = {
                WORDS = {
                    SHOW_ME = '（这个有 {SHOW_ME}）',
                    DISTANCE_FAR = '，离大约有 {DIST} 步远哦',
                    DISTANCE_CLOSE = '，就在身边贴贴呢',
                    DISTANCE_FAR_WATER = '，在距离约 {DIST} 步的水面上',
                    DISTANCE_CLOSE_WATER = '，就在身边的小水花里哦',
                    MOD_INFO = '，模组：{MOD_NAME}',
                    ASSET_INFO = '，动画：{BANK}，贴图：{BUILD}',
                },
                ADJ = {
                    BURNT = '烧黑黑了',
                    FIRE = '在燃烧',
                    WITHERED = '枯萎了',
                    BARREN = '要施肥',
                    SMOLDER = '在冒烟',
                    GOAT_CHARGED = '带电中',
                    GOAT_NORMAL = '很乖巧',
                    HOTSPRING_BOMBED = '水温正好',
                    HOTSPRING_GLASSED = '变结晶了',
                    HOTSPRING_EMPTY = '干涸了',
                    FRUITDRAGON_RIPE = '熟透了',
                    FRUITDRAGON_UNRIPE = '未成熟',
                    BIRDCAGE_EMPTY = '空空的',
                    BIRDCAGE_FULL = '有关小鸟',
                    BIRDCAGE_SICK = '生病了',
                    BIRDCAGE_DEAD = '去睡觉了',
                    ARCHIVE_SWITCH_FULL = '已激活',
                    ARCHIVE_SWITCH_EMPTY = '未激活',
                    TOADSTOOL_EMPTY = '空空的',
                    TOADSTOOL_NORMAL = '有毒菌蟾蜍',
                    TOADSTOOL_DARK = '有悲惨蟾蜍',
                    OASISLAKE_EMPTY = '干涸了',
                    OASISLAKE_FULL = '装满水',
                    BEEFALO_SHAVED = '光溜溜',

                    WITH_BARNACLES = "长满藤壶",
                    NO_BARNACLES = "光秃秃",
                    SEED = "是小种子",
                    GROW = "生长中",
                    FULL = "已成熟",
                    OVER = "巨型胖宝宝",
                    ROT = "变烂烂了",
                    SALT_FULL = "长满盐晶",
                    SALT_MED = "结晶中",
                    SALT_LOW = "少许盐渣",
                    SALT_EMPTY = "掏空了",
                    MARBLE_TALL = "已长高",
                    MARBLE_NORMAL = "中等身材",
                    MARBLE_SHORT = "刚破土",
                    BEEBOX_FULL = "蜜满了",
                    BEEBOX_SOME = "有点蜜",
                    BEEBOX_EMPTY = "没有蜜",
                    PICKABLE_READY = "可采摘",
                    PICKABLE_EMPTY = "休息中",
                    NEST_HAS_EGG = "有高鸟蛋",
                    NEST_EMPTY = "是空巢",
                    MUSHROOMFARM_ROTTEN = "变朽木了",
                    MUSHROOMFARM_EMPTY = "未播种",
                    MUSHROOMFARM_STAGE1 = "刚种下",
                    MUSHROOMFARM_STAGE2 = "长势喜人",
                    MUSHROOMFARM_STAGE3 = "已长大",
                    MUSHROOMFARM_STAGE4 = "挤满啦",

                    STUMP = "是小树桩",
                    SAPLING = "是小树苗",
                    SHORT = "刚冒头",
                    NORMAL = "正漂亮",
                    TALL = "直戳云朵",
                    BOULDER = "变矿床了",
                    ANCIENT_READY = "结满果实",
                    ANCIENT_EMPTY = "没有果实",
                    MARBLE_TREE = "大理石树",

                    TROPHYSCALE_EMPTY = '空空如也',
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
                    HEATROCK_WARM = '暖呼呼',
                    HEATROCK_HOT = '滚烫烫',
                }
            }
        }
    },
    SKIN = {
        FORMATS = {
            DEFAULT = '我有 {NUM}件 {ITEM} 衣服（一共 {TOTAL} 件），这件叫『{SKIN}』󰀜～',
            NO_SKIN = '坏坏科雷！什么时候给『{ITEM}』出漂亮衣服󰀜～',
            HAS_NO_SKIN = '呜呜……连一件『{ITEM}』的漂亮衣服都没有，好委屈󰀜～'
        },
        MAPPINGS = {}
    },
    RECIPE = {
        FORMATS = {
            BUFFERED = '把刚做好的 {ITEM} 抱在怀里啦，准备放下它󰀜～',
            WILL_MAKE = '材料都准备好啦～随时可以变出 {ITEM} 哦󰀜～',
            WE_NEED = '小本本记着呢～我们需要造一个 {ITEM}󰀜～',
            CAN_SOMEONE = '有谁能帮做个 {ITEM} 吗？需要 {PROTOTYPE} 才能做呢󰀜～',
        },
        MAPPINGS = {
            DEFAULT = {
                PROTOTYPER = {
                    UNKNOWN_PROTOTYPE = "神秘科技",
                    CANTRESEARCH = "看不懂的图纸",
                    NEEDSTECH = "亮闪闪图纸",
                    NEEDSSCIENCEMACHINE = "科学小机器",
                    NEEDSALCHEMYMACHINE = "炼金小引擎",
                    NEEDSPRESTIHATITATOR = "灵子小帽子",
                    NEEDSSHADOWMANIPULATOR = "暗影小机器",
                    NEEDSELECOURMALINE_THREE = "电器重铸台",
                    NEEDSELECOURMALINE_ONE = "电器重铸台",
                    NEEDSSIVING_ONE = "子圭神木大石头",
                    NEEDSSKILL = "新技能",
                    NEEDSCELESTIAL_THREE = "超大月亮发光球",
                    NEEDSCELESTIAL_ONE = "小巧月亮发光球",
                    NEEDSMOON_ALTAR_FULL = "月亮大祭坛",
                    NEEDSMOONORB_LOW = "月亮小球",
                    NEEDSCHARACTER = "热心小伙伴",
                    NEEDSCRITTERLAB = "宠物小窝旁",
                    NEEDSTUFF_PROTOTYPE = "找齐原型材料",
                    NEEDSFISHING = "钓具箱",
                    NEEDSSHADOWFORGING_TWO = "暗影小基座",
                    NEEDSTUFF = "找齐小零件",
                    NEEDSCHARACTERSKILL = "专属魔法",
                    NEEDSANCIENTALTAR_HIGH = "远古大祭坛",
                    NEEDSFOODPROCESSING = "研磨小机器",
                    NEEDSANCIENTALTAR_LOW = "远古小祭坛",
                    NEEDSTURFCRAFTING = "夯实器",
                    NEEDSHERMITCRABSHOP_L4 = "寄居蟹老奶奶",
                    NEEDSHERMITCRABSHOP_L3 = "寄居蟹老奶奶",
                    NEEDSHERMITCRABSHOP_L2 = "寄居蟹老奶奶",
                    NEEDSHERMITCRABSHOP_L1 = "寄居蟹老奶奶",
                    NEEDSHERMITCRABHELP_CRAFTING = "寄居蟹老奶奶",
                    NEEDSHERMITCRAB_TEASHOP = "珍珠奶奶泡茶店",
                    NEEDSSHELLWEAVER_L1= "洗盐巴小机器",
                    NEEDSSHELLWEAVER_L2= "升级洗盐巴机器",
                    NEEDSHALLOWED_NIGHTS = "万圣夜捣蛋时间",
                    NEEDSCARNIVAL_PRIZESHOP = "良羽鸦玩具摊",
                    NEEDSCARNIVAL_HOSTSHOP_PLAZA = "鸦年华小树",
                    NEEDSCARNIVAL_HOSTSHOP_WANDER = "鸦年华良羽鸦",
                    NEEDSWINTERSFEASTCOOKING = "砖砌小烤炉",
                    NEEDSWARGSHRINE = "座狼小神龛",
                    NEEDSMADSCIENCE = "神秘实验室",
                    NEEDSRABBITKINGSHOP = "兔子国王",
                    NEEDSYOTG = "火鸡跑跑之年",
                    NEEDSYOTR = "兔人蹦蹦之年",
                    NEEDSYOTV = "座狼汪汪之年",
                    NEEDSYOTS = "蠕虫扭扭之年",
                    NEEDSYOTD = "龙蝇喷火之年",
                    NEEDSYOTP = "猪王哼哼之年",
                    NEEDSYOTC = "胡萝卜鼠窜窜之年",
                    NEEDSYOTB = "牛牛哞哞之年",
                    NEEDSYOTH = "发条骑士之年",
                    NEEDSWINTERS_FEAST = "冬季盛宴开心时",
                    NEEDSYOTCATCOON = "浣猫之年！",
                    NEEDSBEEFSHRINE = "牛牛小神龛",
                    NEEDSRABBITSHRINE = "兔人小神龛",
                    NEEDSCATCOONSHRINE = "浣猫小神龛！",
                    NEEDSKNIGHTSHRINE = "发条骑士神龛",
                    NEEDSPERDSHRINE = "火鸡小神龛",
                    NEEDSWORMSHRINE = "蠕虫神龛",
                    NEEDSCARRATSHRINE = "胡萝卜鼠神龛",
                    NEEDSDRAGONSHRINE = "龙蝇神龛",
                    NEEDSSHRINE = "节日神龛",
                    NEEDSPIGSHRINE = "猪猪神龛",
                    NEEDSROBOTMODULECRAFT = "扫描生物",
                    NEEDSBOOKCRAFT = "童话书架",
                    NEEDSSEAFARING_STATION = "智囊团",
                    NEEDSSPIDERCRAFT = "交个小蜘蛛朋友",
                    NEEDSSHADOW_FORGE = "暗影小基座",
                    NEEDSLUNAR_FORGE = "辉煌铁匠铺",
                    NEEDSCARTOGRAPHYDESK = "画画小桌子",
                    NEEDSCARPENTRY_STATION = "木工小锯马",
                    NEEDSCARPENTRY_STATION_STONE = "玻璃漂亮锯马"
                }
            }
        }
    },
    MEDAL_BUFF = {
        FORMATS = {
            DEFAULT = '哇～拥有"{BUFF_NAME}"BUFF保护，还剩 {TIME} 哦󰀜～',
            FOREVER = '哇～拥有"{BUFF_NAME}"BUFF的永久魔法保护啦󰀜～',
            EXAM = '求助求助～谁知道"{QUESTION}"的答案呀？选项：{OPTIONS}～帮帮我嘛󰀜～',
        },
        MAPPINGS = {}
    },
    ITEM = {
        FORMATS = {
            INV_SLOT = '{PRONOUN}小包包里藏了 {NUM}个 {ITEM}{ITEM_NAME}{IN_CONTAINER}{WITH_PERCENT}{POST_STATE}{SHOW_ME}󰀜～',
            EQUIP_SLOT = '{PRONOUN}穿戴了 {EQUIP_NUM}个 {ITEM}{ITEM_NUM}{ITEM_NAME}{IN_CONTAINER}{WITH_PERCENT}{POST_STATE}{SHOW_ME}󰀜～',
            EQUIP_SLOT_POS = '{PRONOUN}装备了 {EQUIP_NUM}个 {ITEM}{ITEM_NUM}{ITEM_NAME}{WITH_PERCENT}{POST_STATE}{SHOW_ME}󰀜～',
            EQUIP_SLOT_EMPTY = '{PRONOUN}的 {v} 空空的，没穿戴任何东西呢󰀜～',
            EQUIP_SLOT_HEAVY = '哎呀呀～{PRONOUN}吃力搬运着 {EQUIP_NUM}个 {ITEM}{ITEM_NUM}{ITEM_NAME}{IN_CONTAINER}{WITH_PERCENT}{POST_STATE}{SHOW_ME}󰀜～',
            EQUIP_SLOT_HEAVY_POS = '哎呀呀～{PRONOUN}吃力搬运着 {EQUIP_NUM}个 {ITEM}{ITEM_NUM}{ITEM_NAME}{WITH_PERCENT}{POST_STATE}{SHOW_ME}󰀜～',
        },
        MAPPINGS = {
            DEFAULT = {
                PRONOUN = { I = '人家', WE = '我们小队' },
                HEAT_ROCK = {
                    COLD = '，冷冰冰的',
                    COOL = '，凉丝丝的',
                    NORMAL = '，常温的',
                    WARM = '，热乎乎的',
                    HOT = '，滚烫烫的'
                },
                RECHARGE = {
                    CHARGING = '，还差 {TIME} 充满魔力',
                    FULL = '，魔力全满啦'
                },
                PERCENT_TYPE = { DURABILITY = '耐久', FRESHNESS = '新鲜度' },
                TIME = { MINUTES = '分', SECONDS = '秒' },
                WORDS = {
                    THIS_ONE = '其中这个',
                    ITEM_NAME = ' ({NUM}个 叫 {NAME} 的)',
                    ITEM_NUM = ' (一共屯了 {NUM}个)',
                    IN_CONTAINER = ' 藏在可爱的 {NAME} 里',
                    WITH_PERCENT = '，{THIS_ONE}还剩 {PERCENT} {TYPE} 呢',
                    SUSPICIOUS_MARBLE = '，这是 {NAME}',
                    SHOW_ME = '（含有 {SHOW_ME}）',

                    SLOT_HEAD = '小脑袋上',
                    SLOT_HANDS = '小手里',
                    SLOT_BODY = '小身板上',
                    SLOT_BACK = '后背上',
                    SLOT_NECK = '脖子上',
                    SLOT_BELLY = '小肚肚上',
                    SLOT_MEDAL = '胸前勋章',
                }
            }
        }
    },
    CONSTRUCTION_AND_TRADE = {
        FORMATS = {
            CRAFT_NEED = "需要 {INGREDIENT} 才能做出 {RECIPE}{AND_PROTOTYPE}󰀜～",
            CRAFT_HAVE = "准备好 {INGREDIENT} 可以做 {RECIPE} 啦{BUT_PROTOTYPE}󰀜～",
            CRAFT_HAVE_ALL = "拍拍小手准备好啦～马上能做出 {RECIPE}{BUT_PROTOTYPE}󰀜～",

            CONS_NEED = "还需要 {INGREDIENT} 才能把 {RECIPE} 建好呢󰀜～",
            CONS_HAVE = "材料都躺好啦～{RECIPE} 随时可以动工建起来󰀜～",
            CONS_HAVE_ITEM = "准备好了 {INGREDIENT} 来建 {RECIPE} 啦󰀜～", 

            TRADE_NEED = "呜呜……想和 {RECIPE} 换礼物，兜里还缺 {INGREDIENT} 呢󰀜～",
            TRADE_HAVE = "太棒啦！有足够 {INGREDIENT} 可以和 {RECIPE} 换礼物啦！快去快去󰀜～",
            TRADE_HAVE_ITEM = "太好啦！有足够 {INGREDIENT} 可以和 {RECIPE} 换礼物了󰀜～", 
        },
        MAPPINGS = {
            DEFAULT = {
                WORDS = {
                    AMOUNT_FMT = "{NUM}个 {ITEM}",
                    COMMA = "，",
                    ALL_MATERIALS = "所有需要的材料",
                    AND_PROTOTYPE = '，且需要 {PROTOTYPE} 帮忙才能做呢',
                    BUT_PROTOTYPE = '，不过就差 {PROTOTYPE} 帮忙啦'
                }
            }
        }
    },
    WOBY_HUNGER = {
        FORMATS = { DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '>75%……沃比肚肚圆滚滚的󰀜～',
                    HIGH = '55%……沃比还能跑好远好远呢󰀜～',
                    MID = '35%……沃比肚子叫啦，想吃小饼干󰀜～',
                    LOW = '15%……沃比需要怪物肉肉补充能量啦󰀜～',
                    EMPTY = '<15%……沃比饿趴下了～快喂喂它呜呜󰀜～',
                },
                SYMBOL = { TEXT = '沃比小肚肚' }
            }
        }
    },
    STOMACH = {
        FORMATS = { DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '>75%……嗝～肚肚圆滚滚，吃不下啦󰀜～',
                    HIGH = '55%……还能再塞下一丢丢小零食󰀜～',
                    MID = '35%……肚皮要贴后背啦～求投喂小蛋糕󰀜～',
                    LOW = '15%……小腿发抖～急需好吃的续命󰀜～',
                    EMPTY = '<15%……黑漆漆的～要饿晕扑街了嘤嘤嘤󰀜～',
                },
                SYMBOL = { EMOJI = 'hunger', TEXT = '小肚肚' }
            },
            WILSON = {
                MESSAGE = {
                    FULL = '肚子圆滚滚～被爱心料理填满啦󰀜～',
                    HIGH = '能量充足～暂不需要投喂啦󰀜～',
                    MID = '小肚子开始打鼓～想喝热肉汤󰀜～',
                    LOW = '做实验力气都没了～求空投点心󰀜～',
                    EMPTY = '视线模糊惹～树枝看成饼干了……󰀜～',
                }
            },
            WILLOW = {
                MESSAGE = {
                    FULL = '再吃要变圆滚滚小胖球啦󰀜～',
                    HIGH = '能量很稳定～暂不需要燃料呢󰀜～',
                    MID = '小火苗变小了～需要好吃的助燃󰀜～',
                    LOW = '火苗要熄灭了～伯尼快帮忙找吃的󰀜～',
                    EMPTY = '骨头饿打结了～真的要饿扁了󰀜～',
                }
            },
            WOLFGANG = {
                MESSAGE = {
                    FULL = '吃饱饱～现在的力气能举起大象󰀜～',
                    HIGH = '储备能量足够胸口碎大石啦󰀜～',
                    MID = '要补蛋白质～想吃大肉排󰀜～',
                    LOW = '小肌肉要化了～求投喂大份晚餐󰀜～',
                    EMPTY = '连小锤子都举不动了～急需能量󰀜～',
                }
            },
            WENDY = {
                MESSAGE = {
                    FULL = '吃得饱饱，和姐姐一样开心󰀜～',
                    HIGH = '姐姐～你要尝一口小饼干吗󰀜～',
                    MID = '肚肚微空，像悲伤的秋风󰀜～',
                    LOW = '饿着看夕阳～悲伤的力气都没了……󰀜～',
                    EMPTY = '姐姐……我要轻飘飘去找你了……󰀜～',
                }
            },
            WX78 = {
                MESSAGE = {
                    FULL = '零食储量：MAX～小马达全速运转󰀜～',
                    HIGH = '燃料显示正常～还能原地起跳󰀜～',
                    MID = '需补充能量～建议投喂充电小饼干󰀜～',
                    LOW = '警报！能量极低，启动省电撒娇模式󰀜～',
                    EMPTY = '休眠中……最后一点电电用来哭了呜呜……󰀜～',
                }
            },
            WICKERBOTTOM = {
                MESSAGE = {
                    FULL = '知识和美食填满肚子啦，暂不需投喂󰀜～',
                    HIGH = '看书能量充足～能看好久故事书呢󰀜～',
                    MID = '学术能量下降～要吃甜甜小饼干󰀜～',
                    LOW = '看不清书上的字啦～求应急投喂󰀜～',
                    EMPTY = '闭眼休息……要饿得看星星了……󰀜～',
                }
            },
            WOODIE = {
                MESSAGE = {
                    FULL = '树汁能量满～能砍倒十棵大树󰀜～',
                    HIGH = '身上充满力量～继续去森林探险󰀜～',
                    MID = '手酸啦～需要美食恢复体力󰀜～',
                    LOW = '饿得想啃木头～开饭铃在哪󰀜～',
                    EMPTY = '饿得眼睛冒出小星星啦󰀜～',
                }
            },
            WES = {
                MESSAGE = {
                    FULL = '(拍拍圆滚滚的小肚子) 呼呼󰀜～',
                    HIGH = '(小手在肚皮上画圈圈) 满分󰀜～',
                    MID = '(委屈捂住肚子) 咕噜噜～想吃东西󰀜～',
                    LOW = '(睁大眼睛抓衣角) 可怜巴巴……󰀜～',
                    EMPTY = '(趴地上画食物形状) 饿晕了呜呜……󰀜～',
                }
            },
            WAXWELL = {
                MESSAGE = {
                    FULL = '小胃袋被美食填满～超级开心󰀜～',
                    HIGH = '保持优雅身材～暂不吃下午茶󰀜～',
                    MID = '肚肚打鼓～想来份精致小点心󰀜～',
                    LOW = '帽子变餐盘啦～快变出小饼干󰀜～',
                    EMPTY = '呜呜……魔法要被饿肚子打败了󰀜～',
                }
            },
            WEBBER = {
                MESSAGE = {
                    FULL = '小肚子都圆滚滚的～完美投喂󰀜～',
                    HIGH = '多出来的腿还能再塞下一块布丁󰀜～',
                    MID = '午餐时间到～排排坐等投喂󰀜～',
                    LOW = '饿得蜘蛛网都织不出了～求好吃的󰀜～',
                    EMPTY = '几个胃袋都在叫～变纸片蜘蛛了……󰀜～',
                }
            },
            WATHGRITHR = {
                MESSAGE = {
                    FULL = '吃饱饱～现在能打十个大怪兽󰀜～',
                    HIGH = '呼吸都是肉香～战斗欲望MAX󰀜～',
                    MID = '闻到肉汤香味～小脚丫自己跑过去了󰀜～',
                    LOW = '饿得能吞下一整只火鸡～大餐在哪󰀜～',
                    EMPTY = '饿成纸片人也绝对不吃草草󰀜～',
                }
            },
            WINONA = {
                MESSAGE = {
                    FULL = '干饭引擎就绪～干活能量满格󰀜～',
                    HIGH = '小扳手还能再拧十个螺丝钉󰀜～',
                    MID = '给肚肚加点香香的润滑油󰀜～',
                    LOW = '发带都耷拉下来了～食堂在哪󰀜～',
                    EMPTY = '启动罢工撒娇模式～除非有大餐󰀜～',
                }
            },
            WARLY = {
                MESSAGE = {
                    FULL = '饭饭太好吃啦～幸福得要晕倒󰀜～',
                    HIGH = '嗝～呼吸都沾着奶油香气󰀜～',
                    MID = '该研发甜甜的新小蛋糕啦󰀜～',
                    LOW = '错过饭点的小厨师要饿哭了󰀜～',
                    EMPTY = '饿得看见平底锅在煎蛋啦……󰀜～',
                }
            },
            WORMWOOD = {
                MESSAGE = {
                    FULL = '光合作用满格～小叶子舒展开啦󰀜～',
                    HIGH = '运转中～能进行光合午睡了󰀜～',
                    MID = '土壤探测显示需要施肥了󰀜～',
                    LOW = '急需阳光浴和甜甜营养液󰀜～',
                    EMPTY = '小叶片蔫了～快抱抱复活我󰀜～',
                }
            },
            WURT = {
                MESSAGE = {
                    FULL = '咕噜噜～小肚皮装不下啦󰀜～',
                    HIGH = '还能再塞下一小口零食󰀜～',
                    MID = '小尾巴摇不动了～要投喂恢复活力󰀜～',
                    LOW = '腮帮子瘪了～求喂食FLORP󰀜～',
                    EMPTY = '眼睛冒小漩涡～看见好吃的在飞……󰀜～',
                }
            },
            WORTOX = {
                MESSAGE = {
                    FULL = '肚皮撑成气球～跑不动了󰀜～',
                    HIGH = '灵魂甜点吃多了～绕圈跑消食󰀜～',
                    MID = '需补充灵魂糖果～恶作剧蓄力中󰀜～',
                    LOW = '饥饿警报！看见影子都想咬一口󰀜～',
                    EMPTY = '要变饿扁小恶魔了～要黑化啦󰀜～',
                }
            }
        }
    },
    BLOOMNESS = {
        FORMATS = { DEFAULT = '({SYMBOL} Lv：{LEVEL} | {CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    STAGE_0 = '需要香香的肥料呢󰀜～',
                    STAGE_1 = '小花花要开了，好期待󰀜～',
                    STAGE_2 = '花苞努力长大中哦󰀜～',
                    STAGE_3 = '当当！漂亮花花盛开啦󰀜～',
                    STAGE_4 = '花瓣微黄了呢……󰀜～',
                    STAGE_5 = '花花要谢了，好舍不得……󰀜～',
                },
                SYMBOL = {
                    EMOJI = 'flower',
                    TEXT = '开花状态'
                }
            }
        }
    },
    NAUGHTINESS = {
        FORMATS = { 
            DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}',
            LUCK = '哇～幸运值有：{CURRENT} 这么高喔󰀜～' 
        },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '呀！坎普斯大坏蛋要来抓人啦󰀜～',
                    HIGH = '感觉到坎普斯坏坏的视线了……󰀜～',
                    MID = '唔……偷偷干了一点点小坏事󰀜～',
                    LOW = '可是一直都很乖的宝宝哦󰀜～',
                    EMPTY = '纯洁如小白花～最乖巧的好孩子󰀜～',
                },
                SYMBOL = {
                    TEXT = '调皮值'
                }
            }
        }
    },
    SANITY = {
        FORMATS = { DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '>75%……开心雷达全开～超级无敌快乐󰀜～',
                    HIGH = '55%……精神很棒，能原地转圈圈󰀜～',
                    MID = '35%……脑阔微晕～感觉有点怕怕的󰀜～',
                    LOW = '15%……周围变好奇怪～这里有点疯狂呢󰀜～',
                    EMPTY = '<15%……呜呜！黑影怪物在追我，救命󰀜～',
                },
                SYMBOL = { EMOJI = 'sanity', TEXT = '脑阔' }
            },
            WILSON = {
                MESSAGE = {
                    FULL = '小脑袋运转正常～理智满分󰀜～',
                    HIGH = '听到奇怪声音～但会好起来的󰀜～',
                    MID = '像被敲了一下～头好痛󰀜～',
                    LOW = '呀！影子在跳舞～可怕的怪物󰀜～',
                    EMPTY = '救命！黑夜里的坏家伙要吃我了󰀜～',
                }
            },
            WILLOW = {
                MESSAGE = {
                    FULL = '小火苗燃烧得很旺盛哦󰀜～',
                    HIGH = '刚才伯尼耳朵动了下？肯定是错觉󰀜～',
                    MID = '冷风吹过～觉得好冷呀󰀜～',
                    LOW = '伯尼，为什么我觉得这么冷这么怕󰀜～',
                    EMPTY = '伯尼抱紧我～有可怕东西要咬我󰀜～',
                }
            },
            WOLFGANG = {
                MESSAGE = {
                    FULL = '脑子放动画片，感觉超级好󰀜～',
                    HIGH = '听见云朵讲笑话～轻飘飘真有趣󰀜～',
                    MID = '像被小石头砸到，好疼󰀜～',
                    LOW = '石头在跳芭蕾～可怕的大怪兽󰀜～',
                    EMPTY = '救命！到处都是可怕怪兽，好怕󰀜～',
                }
            },
            WENDY = {
                MESSAGE = {
                    FULL = '心思像水晶般透亮～不难过󰀜～',
                    HIGH = '小脑袋开始想悲伤的事了……󰀜～',
                    MID = '莫名兴奋～心跳加速了󰀜～',
                    LOW = '姐姐快看！黑影要带走我了󰀜～',
                    EMPTY = '带我去找姐姐吧，黑漆漆的怪物……󰀜～',
                }
            },
            WX78 = {
                MESSAGE = {
                    FULL = 'CPU状态：全速运转～能解开所有谜题󰀜～',
                    HIGH = 'CPU状态：正常～在思考晚上吃什么󰀜～',
                    MID = 'CPU状态：微损～要冰镇果汁散热󰀜～',
                    LOW = '奇怪数据流～要出大故障了󰀜～',
                    EMPTY = 'CPU状态：多重警报！变成一团乱码了󰀜～',
                }
            },
            WICKERBOTTOM = {
                MESSAGE = {
                    FULL = '脑袋清醒～什么书都能看懂󰀜～',
                    HIGH = '有点魔法波动～头稍微有点痛󰀜～',
                    MID = '字看太多了～偏头痛好难受󰀜～',
                    LOW = '字在跳舞～分不清做梦还是现实了󰀜～',
                    EMPTY = '知识装不下了！帮我逃离这些幻觉󰀜～',
                }
            },
            WOODIE = {
                MESSAGE = {
                    FULL = '精神好得像听小提琴曲󰀜～',
                    HIGH = '精力充沛，能去玩一整天󰀜～',
                    MID = '打哈欠～需要睡个甜甜午觉了󰀜～',
                    LOW = '跑跳力气没了～坏噩梦走开󰀜～',
                    EMPTY = '害怕都是真的～救命，要哭啦󰀜～',
                }
            },
            WES = {
                MESSAGE = {
                    FULL = '(开心地转圈画出大爱心) 󰀜～',
                    HIGH = '(竖起大拇指表示超级棒) ฅ^•ﻌ•^ฅ󰀜～',
                    MID = '(揉揉太阳穴) 唔……头有点晕晕的……󰀜～',
                    LOW = '(害怕地四处看) 呀！疯狂的家伙󰀜～',
                    EMPTY = '(抱头蹲地发抖) 呜呜……好怕好怕……󰀜～',
                }
            },
            WAXWELL = {
                MESSAGE = {
                    FULL = '帽子戴得端正～状态超级好󰀜～',
                    HIGH = '不对劲～小脑瓜似乎在晃动󰀜～',
                    MID = '脑袋像挨了一拳～头好痛󰀜～',
                    LOW = '影子在跳舞～需要清醒下头脑󰀜～',
                    EMPTY = '救命！暗影触手变成大野兽了󰀜～',
                }
            },
            WEBBER = {
                MESSAGE = {
                    FULL = '世界全亮晶晶的，感觉超健康󰀜～',
                    HIGH = '小睡一会就能恢复所有活力啦󰀜～',
                    MID = '奇怪嗡嗡声～头好痛痛󰀜～',
                    LOW = '上次午睡是什么时候？！乱掉了……󰀜～',
                    EMPTY = '才不怕你们！(其实心里很怕)󰀜～',
                }
            },
            WATHGRITHR = {
                MESSAGE = {
                    FULL = '心里一点都不害怕凡人恐惧󰀜～',
                    HIGH = '舞台聚光灯就绪～感觉棒极了󰀜～',
                    MID = '脑袋迷糊～小战士要晕倒了󰀜～',
                    LOW = '阴影穿透小长矛～要打不过了󰀜～',
                    EMPTY = '退后怪兽！生气了可是很厉害的󰀜～',
                }
            },
            WINONA = {
                MESSAGE = {
                    FULL = '检查完毕！小脑瓜运转完美󰀜～',
                    HIGH = '目前一切都在掌握中󰀜～',
                    MID = '螺丝松动了～想法变得乱糟糟的󰀜～',
                    LOW = '心碎了，该拿扳手修修脑袋了󰀜～',
                    EMPTY = '系统大崩溃！好可怕的真实噩梦󰀜～',
                }
            },
            WARLY = {
                MESSAGE = {
                    FULL = '闻到饭菜香味，神智清醒󰀜～',
                    HIGH = '油烟吸多了？觉得头有点晕󰀜～',
                    MID = '菜谱在跳舞～脑筋完全转不动了󰀜～',
                    LOW = '耳边有人说话～救命是谁󰀜～',
                    EMPTY = '锅碗瓢盆全成精了～好可怕󰀜～',
                }
            },
            WORMWOOD = {
                MESSAGE = {
                    FULL = '小花苞绽放～感觉超级棒󰀜～',
                    HIGH = '头很舒服，像在听好听音乐󰀜～',
                    MID = '头痛痛，但小叶子感觉还好󰀜～',
                    LOW = '有恐怖东西躲在暗处看着󰀜～',
                    EMPTY = '恐怖黑影活过来在欺负人呜呜󰀜～',
                }
            },
            WURT = {
                MESSAGE = {
                    FULL = '吐泡泡唱歌好开心󰀜～',
                    HIGH = '精神超好，小花花也很漂亮󰀜～',
                    MID = '格鲁，脑袋好像受伤了，疼疼的󰀜～',
                    LOW = '可怕黑影游过来了，快跑󰀜～',
                    EMPTY = '格鲁，海底噩梦怪物要吃我了󰀜～',
                }
            },
            WORTOX = {
                MESSAGE = {
                    FULL = '头脑超清醒，恶作剧时间又来啦󰀜～',
                    HIGH = '吃点甜甜灵魂保持清醒󰀜～',
                    MID = '跳太快了，脑袋有点痛痛的……󰀜～',
                    LOW = '影子的恶作剧戏法好厉害，好羡慕󰀜～',
                    EMPTY = '思想跑到疯狂世界去了，嘿嘿󰀜～',
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
                    FULL = '100%……元气满满，像个小太阳󰀜～',
                    HIGH = '75%……擦破一点皮，挂了点小彩󰀜～',
                    MID = '50%……贴满创可贴，受了很重的伤呜呜……󰀜～',
                    LOW = '25%……一瘸一拐～痛痛痛，走不动了󰀜～',
                    EMPTY = '<25%……眼前发黑……保护好我的东西󰀜～',
                },
                SYMBOL = { EMOJI = 'heart', TEXT = '小命' },
            },
            WILSON = {
                MESSAGE = {
                    FULL = '身体倍棒！健康得像小提琴󰀜～',
                    HIGH = '有点小擦伤，还能继续跑跳󰀜～',
                    MID = '绷带绑得歪歪扭扭～需要治疗了󰀜～',
                    LOW = '血珠渗出来惹～流了好多血好疼……󰀜～',
                    EMPTY = '力气快用光了～没法陪你走到最后了……󰀜～',
                }
            },
            WILLOW = {
                MESSAGE = {
                    FULL = '漂亮衣服上不该有一点伤痕󰀜～',
                    HIGH = '有点小擦伤～可以用火苗消毒󰀜～',
                    MID = '伤口好痛，火苗变小，需要看医生……󰀜～',
                    LOW = '小火苗像风里的蜡烛，随时会灭……󰀜～',
                    EMPTY = '最后一点火苗……要灭掉了呜呜……󰀜～',
                }
            },
            WOLFGANG = {
                MESSAGE = {
                    FULL = '身体超级棒，现在不需修理󰀜～',
                    HIGH = '有点小擦伤，贴个创可贴就好󰀜～',
                    MID = '伤口好痛～受伤了，力气变小了󰀜～',
                    LOW = '血珠流出，需要好多绷带包扎󰀜～',
                    EMPTY = '没力气了……可能真的要死掉了……󰀜～',
                }
            },
            WENDY = {
                MESSAGE = {
                    FULL = '伤口长好了，但以后还会受伤的󰀜～',
                    HIGH = '感到一点点痛，但能忍住哦󰀜～',
                    MID = '生存好辛苦，还不习惯这么多痛󰀜～',
                    LOW = '流了好多血……放弃会很轻松吧……󰀜～',
                    EMPTY = '姐姐……马上就能去陪你玩了……󰀜～',
                }
            },
            WX78 = {
                MESSAGE = {
                    FULL = '底盘状态：亮晶晶理想状况󰀜～',
                    HIGH = '底盘状态：检测到表层小刮痕󰀜～',
                    MID = '底盘状态：电线露出，中度损坏󰀜～',
                    LOW = '底盘状态：滴滴！完全损坏警告󰀜～',
                    EMPTY = '底盘状态：强制关机，无功能了󰀜～',
                }
            },
            WICKERBOTTOM = {
                MESSAGE = {
                    FULL = '长袍干干净净～身体好得很󰀜～',
                    HIGH = '像受了羽毛笔划痕小伤，没关系󰀜～',
                    MID = '反噬受伤，需要好好包扎一下󰀜～',
                    LOW = '不赶紧治疗就要倒在这里了󰀜～',
                    EMPTY = '一点魔力都没了……立刻找医生󰀜～',
                }
            },
            WOODIE = {
                MESSAGE = {
                    FULL = '嘿嘿～健康得像清脆小哨子󰀜～',
                    HIGH = '大难不死，还能继续冒险󰀜～',
                    MID = '要用好多松果绷带包扎才行󰀜～',
                    LOW = '小爪裂开好痛，苦日子要来了……󰀜～',
                    EMPTY = '让我睡一觉吧……就在树下……󰀜～',
                }
            },
            WES = {
                MESSAGE = {
                    FULL = '(两只小手比大爱心) ～超健康󰀜～',
                    HIGH = '(伸小手展示) 呜～擦破一点皮󰀜～',
                    MID = '(玩白色绷带) 呀～快帮我包扎󰀜～',
                    LOW = '(摇手发出SOS) 好痛痛……󰀜～',
                    EMPTY = '(丢出小纸团倒下) 扑通摔倒……󰀜～',
                }
            },
            WAXWELL = {
                MESSAGE = {
                    FULL = '燕尾服没破～完好无损󰀜～',
                    HIGH = '袖口蹭破一点皮，小意思󰀜～',
                    MID = '斗篷裂了口子，需要打个可爱补丁󰀜～',
                    LOW = '手套染红，虽未到最后但也差不多了󰀜～',
                    EMPTY = '谢幕礼……绝不当逃兵死在这里󰀜～',
                }
            },
            WEBBER = {
                MESSAGE = {
                    FULL = '蜘蛛丝亮闪闪～连划痕都没󰀜～',
                    HIGH = '小爪擦伤，需要可爱创可贴󰀜～',
                    MID = '缠满绷带～还要多贴几个……󰀜～',
                    LOW = '医疗包用光了，浑身好痛……󰀜～',
                    EMPTY = '蜘蛛朋友们……还不想死掉呜呜……󰀜～',
                }
            },
            WATHGRITHR = {
                MESSAGE = {
                    FULL = '无敌的我皮肤根本刺不破󰀜～',
                    HIGH = '小擦伤而已，难不倒我󰀜～',
                    MID = '受伤了，但还能举起小拳头战斗󰀜～',
                    LOW = '小长矛生锈，没人帮就要倒下了……󰀜～',
                    EMPTY = '摆出帅气姿势……冒险要结束了……󰀜～',
                }
            },
            WINONA = {
                MESSAGE = {
                    FULL = '防护服棒棒的～健康得像小马驹󰀜～',
                    HIGH = '擦伤画成小花～会解决它的󰀜～',
                    MID = '虽然受伤了，但绝不轻易放弃󰀜～',
                    LOW = '关节嘎吱响～可以提前退休吗󰀜～',
                    EMPTY = '比个心……轮班终于要结束了……󰀜～',
                }
            },
            WARLY = {
                MESSAGE = {
                    FULL = '每天吃得好，身体超级棒󰀜～',
                    HIGH = '切洋葱切到手了，好疼󰀜～',
                    MID = '烫伤流血了呜呜呜󰀜～',
                    LOW = '虚弱得拿不动锅～谁来帮帮我󰀜～',
                    EMPTY = '最后的便当……大结局了挚友们……󰀜～',
                }
            },
            WORMWOOD = {
                MESSAGE = {
                    FULL = '枝头开满小花花～一点伤都没󰀜～',
                    HIGH = '树皮蹭掉一点，完全没关系󰀜～',
                    MID = '年轮渗出汁液，身体好虚弱󰀜～',
                    LOW = '引来坏虫子，真的好痛好痛󰀜～',
                    EMPTY = '掉下最后一片叶……快救救我󰀜～',
                }
            },
            WURT = {
                MESSAGE = {
                    FULL = '铠甲像探照灯～超健康小花󰀜～',
                    HIGH = '鱼鳍划伤一丢丢，感觉完全没事󰀜～',
                    MID = '掉鳞片了，要好多珍珠粉补补……󰀜～',
                    LOW = '小泡泡快没了，疼得直掉眼泪……󰀜～',
                    EMPTY = '吐出最后气泡……谁来救救我！！！󰀜～',
                }
            },
            WORTOX = {
                MESSAGE = {
                    FULL = '小手充满力量，尽情调皮捣蛋󰀜～',
                    HIGH = '纸划了一下，吃个灵魂就好󰀜～',
                    MID = '吃甜甜灵魂糖果来抚平伤口，嘿嘿󰀜～',
                    LOW = '魔力流失好快，灵魂变脆弱了……󰀜～',
                    EMPTY = '放个爱心烟花，灵魂飞走了……󰀜～',
                }
            }
        }
    },
    THIRST = {
        FORMATS = { DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '咕咚咕咚～水壶喝饱啦，肚子全是水󰀜～',
                    HIGH = '嘴巴润润的，一点都不渴󰀜～',
                    MID = '嘴巴有点干了，想喝甜甜果汁󰀜～',
                    LOW = '嗓子冒烟啦！要渴死了，快给水水󰀜～',
                    EMPTY = '呜呜水分全没了，要变脱水小菜叶了󰀜～',
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
                    FULL = '>75%……全身湿透！变落汤小鸡啦呜呜󰀜～',
                    HIGH = '55%……衣服好重！快把我装进干爽包包󰀜～',
                    MID = '35%……小脸蛋全是水珠，背包也湿了󰀜～',
                    LOW = '15%……裙摆沾到一点水，完全不怕呢󰀜～',
                    EMPTY = '干干爽爽，身上只有一点点水汽󰀜～',
                },
                SYMBOL = {
                    TEXT = '潮湿度'
                },
            },

            WILSON = {
                MESSAGE = {
                    FULL = '变水煮小蘑菇啦～水分饱和了󰀜～',
                    HIGH = '讨厌的水快点从身上滚出去󰀜～',
                    MID = '头发黏在一起，衣服全浸透了󰀜～',
                    LOW = '脸上挂着小水珠，讨厌的 H2O󰀜～',
                    EMPTY = '干爽得能当镜子照，比较干燥󰀜～',
                }
            },
            WILLOW = {
                MESSAGE = {
                    FULL = '雨水是世界上最坏最坏的东西󰀜～',
                    HIGH = '浑身湿漉漉，最讨厌被淋湿了󰀜～',
                    MID = '积水成河，这雨下得太大了󰀜～',
                    LOW = '雨再不停，小火苗要被浇灭了……󰀜～',
                    EMPTY = '干燥得能擦出火星，一点水灭不了火󰀜～',
                }
            },
            WOLFGANG = {
                MESSAGE = {
                    FULL = '变大水球了，感觉自己是水做的󰀜～',
                    HIGH = '湿漉漉的，像坐在水坑里……󰀜～',
                    MID = '还没到洗澡时间，不喜欢洗澡󰀜～',
                    LOW = '淅沥沥的雨水时代来啦󰀜～',
                    EMPTY = '身上超干燥，一点水都没有󰀜～',
                }
            },
            WENDY = {
                MESSAGE = {
                    FULL = '满是雨水和眼泪，像末日一样悲伤󰀜～',
                    HIGH = '成了湿润又悲伤的落汤小女孩󰀜～',
                    MID = '和姐姐一样湿软又悲伤󰀜～',
                    LOW = '冰冷雨水能填满心里的空洞吧󰀜～',
                    EMPTY = '皮肤干干的，和心里感觉一模一样󰀜～',
                }
            },
            WX78 = {
                MESSAGE = {
                    FULL = '受潮：短路危险！水分达临界值󰀜～',
                    HIGH = '受潮：小天线进水！接近危险临界󰀜～',
                    MID = '受潮：要长蘑菇了！完全无法接受󰀜～',
                    LOW = '受潮：只有小露珠，勉强可以容许󰀜～',
                    EMPTY = '受潮：全身干燥完美！超级合意󰀜～',
                }
            },
            WICKERBOTTOM = {
                MESSAGE = {
                    FULL = '魔法护罩坏掉啦！完全浸透了󰀜～',
                    HIGH = '我是湿的！湿的！重要事情说三遍󰀜～',
                    MID = '长袍吸水好沉，快到极限了󰀜～',
                    LOW = '书页卷边，讨厌的水膜形成了󰀜～',
                    EMPTY = '羊皮纸保存完美，身上水分匮乏󰀜～',
                }
            },
            WOODIE = {
                MESSAGE = {
                    FULL = '讨厌天气害得树都不能去砍了󰀜～',
                    HIGH = '衬衫吸满水，一点都不保暖了󰀜～',
                    MID = '获得了超级多的水分󰀜～',
                    LOW = '衬衫看起来暖和，摸起来湿漉漉󰀜～',
                    EMPTY = '对我来说几乎不受什么影响󰀜～',
                }
            },
            WES = {
                MESSAGE = {
                    FULL = '*像小鸭子蝶泳一样向上游*󰀜～',
                    HIGH = '*小耳朵当螺旋桨努力向上游*󰀜～',
                    MID = '*歪着小脑袋悲惨看着乌云*󰀜～',
                    LOW = '*抱住头把小手当雨伞努力护住*󰀜～',
                    EMPTY = '*扬起笑脸举着看不见的空气伞*󰀜～',
                }
            },
            WAXWELL = {
                MESSAGE = {
                    FULL = '湿透的感觉就好比掉进水池里󰀜～',
                    HIGH = '礼服吸满水，不认为还能变干了󰀜～',
                    MID = '脏水会毁了精心定制的西装󰀜～',
                    LOW = '领结潮湿让我整个人不整洁了󰀜～',
                    EMPTY = '干燥蓬松，整洁得不得了󰀜～',
                }
            },
            WEBBER = {
                MESSAGE = {
                    FULL = '八条小短腿都在划水，彻底湿透了󰀜～',
                    HIGH = '毛毛吸饱水变小海胆了󰀜～',
                    MID = '蛛网吊床变水床了，身上好湿󰀜～',
                    LOW = '湿润润的样子一点都不讨喜󰀜～',
                    EMPTY = '在干沙坑里玩耍，干燥得很󰀜～',
                }
            },
            WATHGRITHR = {
                MESSAGE = {
                    FULL = '衣服变沉重拖把，彻底湿透了󰀜～',
                    HIGH = '战士在雨天怎么能没法战斗󰀜～',
                    MID = '铁爪护甲被水泡得要生锈了󰀜～',
                    LOW = '干干净净，根本不需要洗澡󰀜～',
                    EMPTY = '衣服干透了！继续在水上漂着去战斗󰀜～',
                }
            },
            WINONA = {
                MESSAGE = {
                    FULL = '工具箱要生锈了！无法在湿度下工作󰀜～',
                    HIGH = '工作服变潜水服把水全吸了󰀜～',
                    MID = '滑倒了，该放个湿地板警示牌󰀜～',
                    LOW = '干活时多喝点水补充水分没错的󰀜～',
                    EMPTY = '干到起静电了，一点水都没有󰀜～',
                }
            },
            WARLY = {
                MESSAGE = {
                    FULL = '变海鲜汤了，有小鱼在衬衫里游󰀜～',
                    HIGH = '小金鱼游出来，水会毁了菜肴󰀜～',
                    MID = '感冒打喷嚏前必须把衣服烘干󰀜～',
                    LOW = '现在可不是洗澡的时间和地点󰀜～',
                    EMPTY = '只有几滴小水珠溅在围裙上，无大碍󰀜～',
                }
            },
            WORMWOOD = {
                MESSAGE = {
                    FULL = '储水装满满的，真的好湿好湿󰀜～',
                    HIGH = '开启叶子淋浴，真的湿透了󰀜～',
                    MID = '夜露收集工作中，身体有点湿湿的󰀜～',
                    LOW = '掉水珠了！发芽了！哦吼󰀜～',
                    EMPTY = '树皮摸起来干巴巴，感到很干燥󰀜～',
                }
            },
            WURT = {
                MESSAGE = {
                    FULL = '跳欢快水上芭蕾，水花到处溅󰀜～',
                    HIGH = '泡在水里舒服，小鳞片也很舒服󰀜～',
                    MID = '舒展鱼鳍，美人鱼最喜欢玩水啦，小花󰀜～',
                    LOW = '身上再多沾点水水就更好了，小花󰀜～',
                    EMPTY = '尾巴要变鱼干了，太干燥了格鲁󰀜～',
                }
            },
            WORTOX = {
                MESSAGE = {
                    FULL = '翅膀变沉重降落伞，完全浸透了󰀜～',
                    HIGH = '全街最最潮湿的小恶魔Hyuyu󰀜～',
                    MID = '尾巴好重，一只湿漉漉的小恶魔󰀜～',
                    LOW = '世界赐予一场超级棒的恶作剧淋浴󰀜～',
                    EMPTY = '想保持干燥就多留意天气󰀜～',
                }
            }
        }
    },
}