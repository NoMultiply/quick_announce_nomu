GLOBAL.STRINGS.NOMU_QA.TITLE_TEXT_CUTE_SCHEME = '软萌方案'

GLOBAL.STRINGS.CUTE_NOMU_QA = {
   SEASON = {
        FORMATS = { DEFAULT = '呐～{SEASON}还剩下{DAYS_LEFT}天呢，时间过得好快吖✿～' },
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
            START_RAIN = '呀～{WORLD}现在的气温是：{TEMPERATURE}，{WEATHER}来啦：第{DAYS}天（{MINUTES}分{SECONDS}秒）哒～',
            NO_RAIN = '唔……{WORLD}现在的气温是：{TEMPERATURE}，天空很乖，{WEATHER}还没来呢✿～',
            STOP_RAIN = '哇！{WORLD}气温是：{TEMPERATURE}，终于放晴啦：第{DAYS}天（{MINUTES}分{SECONDS}秒）～',
        },
        MAPPINGS = {
            DEFAULT = {
                WORLD = { SURFACE = '地表', CAVES = '洞穴', SHIPWRECKED = '海难', VOLCANO = '火山', PORKLAND = '猪镇', WINTERLAND = '冰岛' },
                WEATHER = { SPRING = '下小雨', SUMMER = '下雨啦', AUTUMN = '下雨啦', WINTER = '飘雪花', GREEN = '下雨啦', DRY = '下雨啦', MILD = '下雨啦', WET = '刮大风', TEMPERATE = '下雨啦', HUMID = '下雨啦', LUSH = '下雨啦', APORKALYPSE = '下雨啦' },
            }
        }
    },
    TEMPERATURE = {
        FORMATS = { DEFAULT = '({TEMPERATURE}°) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    BURNING = '呜呜，好烫好烫！人家要被烤熟了吖！',
                    HOT = '呼呼～好热呢，人家想要吃冰淇淋降温啦！',
                    WARM = '暖呼呼的～好舒服吖，想打个哈欠✿～',
                    GOOD = '现在的温度最适合睡懒觉啦，嘿嘿～',
                    COOL = '阿嚏！有一点点凉意呢，要多穿件小衣服吖。',
                    COLD = '呜呜，好冷好冷，人家需要一个温暖的抱抱！',
                    FREEZING = '冻僵了啦……要把人家变成小冰雕了嘤嘤嘤！',
                }
            }
        }
    },
    MOON_PHASE = {
        FORMATS = {
            DEFAULT = '哇哦！{RECENT}{PHASE1}{INTERVAL}距离下次{PHASE2}还有{LEFT}天呢✿～',
            MOON = '快看快看！{RECENT}{PHASE1}啦✿～',
            FAILED = '呜呜……云层太厚了，人家看不清月亮姐姐的样子呢！'
        },
        MAPPINGS = {
            DEFAULT = {
                MOON = { FULL = '月亮圆圆', NEW = '黑漆漆的夜晚' },
                INTERVAL = { COMMA = '，', NONE = '' },
                RECENT = { TODAY = '今晚是', TOMORROW = '明晚是', AFTER = '我们刚度过' },
            }
        }
    },
    CLOCK = {
        FORMATS = {
            DEFAULT = '{PHASE}还剩下{PHASE_REMAIN}吖，今天还有{DAY_REMAIN}可以玩耍呢✿。',
            NIGHTMARE = '{PHASE}还剩下{PHASE_REMAIN}吖，今天还有{DAY_REMAIN}，{NIGHTMARE}还有{REMAIN}就结束啦！',
            NIGHTMARE_LOCK = '{PHASE}还剩下{PHASE_REMAIN}吖，今天还有{DAY_REMAIN}，现在是可怕的{NIGHTMARE}呢！'
        },
        MAPPINGS = {
            DEFAULT = {
                TIME = { MINUTES = '分', SECONDS = '秒' },
                PHASE = { DAY = '明亮的白天', DUSK = '黄昏的彩霞', NIGHT = '黑黑的夜晚' },
                NIGHTMARE = {
                    CALM = "乖乖的平息阶段",
                    WARN = "呀！暗影在警告了",
                    WILD = "坏家伙们暴动啦",
                    DAWN = "呼，马上就过去的过渡阶段",
                },
            }
        }
    },
    COOK = {
        FORMATS = {
            CAN = '人家可以给大家做美味的{NAME}吖✿～',
            NEED = '肚子饿饿，人家好想吃一口{NAME}呢～',
            MIN_INGREDIENT = '制作甜甜的{NAME}需要{NUM}个{INGREDIENT}吖！',
            MAX_INGREDIENT = '煮{NAME}的时候，最多只能放{NUM}个{INGREDIENT}哦～',
            ZERO_INGREDIENT = '呀！{NAME}里面绝对绝对不可以放{INGREDIENT}啦！',
            HUNGER = '{NAME}料理{TYPE}小肚肚{VALUE}点饱饱度吖✿～',
            SANITY = '{NAME}料理{TYPE}小脑阔{VALUE}点开心值吖✿～',
            HEALTH = '{NAME}料理{TYPE}身体{VALUE}点健康值吖✿～',
            FOOD = '当当！{NAME}：饱饱度{HUNGER}，开心值{SANITY}，健康值{HEALTH}吖✿～',
            FOOD_LOCK = '唔……人家还没有学会怎么做{NAME}呢。',
            FOOD_NO_EATEN = '需要喂人家吃一口{NAME}，人家才能知道味道吖✿～',
        },
        MAPPINGS = {
            DEFAULT = {
                TYPE = { POS = '会涨', NEG = '会掉' }
            }
        }
    },
    BOAT = {
        FORMATS = { DEFAULT = '(小船船：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '小船船超级结实！我们要出发去冒险啦✿！',
                    HIGH = '哎呀，碰坏了一点点，不过没关系呢！',
                    MID = '小船开始漏水啦，人家有点怕怕的……',
                    LOW = '呜呜！要沉了要沉了，快修修它吖！',
                    EMPTY = '咕噜噜……大家都要掉进水里了嘤嘤嘤！',
                }
            }
        }
    },
    ABIGAIL = {
        FORMATS = { DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '阿比盖尔姐姐会保护人家的，超有安全感✿～',
                    HIGH = '呀！阿比盖尔姐姐受了一点点伤呢！',
                    MID = '姐姐你还好吗？人家好担心吖……',
                    LOW = '阿比盖尔姐姐快躲开！不要受伤呜呜呜……',
                    EMPTY = '不要丢下人家一个人……姐姐快回来吖！',
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
                    FULL = '嗷呜！人家变成毛茸茸的大怪兽啦✿！',
                    HIGH = '大毛绒玩具还有好多好多活力呢！',
                    MID = '唔……变身的力气用掉一半了吖。',
                    LOW = '毛茸茸的耳朵要垂下来了呢，需要休息……',
                    EMPTY = '变回软软的小可爱啦，人家要抱抱✿～',
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
                    MIGHTY = '嘿咻！人家现在力气超大，可以举起大石头吖✿！',
                    NORMAL = '人家正在努力锻炼身体呢，嘿咻嘿咻！',
                    WIMPY = '呜呜……小胳膊软绵绵的，连小木棍都拿不动了啦……',
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
                    EMPTY = '唔，嗓子干干的，唱不出甜甜的歌了吖……',
                    LOW = '人家现在可以给大家哼一首小曲子呢！',
                    MID = '清清嗓子～人家可以连唱两首歌吖✿！',
                    HIGH = '充满灵感！人家要给大家开演唱会啦，连唱三首哦✿！'
                },
                SYMBOL = { EMOJI = 'horn', TEXT = '灵感值' }
            }
        }
    },
    ENERGY = {
        FORMATS = {
            DEFAULT = '(电量：{CURRENT}/{MAX}，已占用：{USED}格) 呼呼～小电池现在{MESSAGE}吖✿！',
            CHIP = '{NUM}个亮晶晶的{ITEM}',
            ALL_MODULES = '嘿嘿，人家装配了这些魔法电路哦：{MODULES}吖✿！',
            NO_MODULES = '唔……人家身上还没有装任何神奇电路呢吖。'
        },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    ZERO = '没电电了',
                    ONE = '快要熄灭了',
                    TWO = '电量低低的',
                    THREE = '还有一半哦',
                    FOUR = '能量满满的',
                    FIVE = '超级精神',
                    SIX = '充满魔力啦'
                }
            }
        }
    },
    GIFT = {
        FORMATS = {
            CAN_OPEN = '哇！是给人家的小礼物嘛？好想马上拆开吖✿！！！',
            NEED_SCIENCE = '唔……包裹太紧了，人家需要科学机器帮忙才能拆开呢……',
        },
        MAPPINGS = {}
    },
    PLAYER = {
        FORMATS = {
            DEFAULT = '{NAME}正在人家身边陪着人家呢✿～',
            ADMIN = '哇哦，{NAME}是超级厉害的管理员吖！',
            NAME = '{NAME}选的是{CHARACTER}吖。',
            AGE = '{NAME}在这里度过了{AGE}的时光呢。',
            AGE_SHORT = '{NAME}{AGE}啦。',
            PERF = '{NAME} 的{PERF}吖。{PING}',
            GREET = '好开心见到你吖，{NAME}✿～',
            PING = '小信号延迟：{PING}',
            BADGE = '{NAME}带着{BADGE}的可爱头牌吖。',
            BACKGROUND = '{NAME}的背景画面是{BACKGROUND}。',
            BODY = '{NAME}穿着漂亮的{BODY}衣服呢。',
            HAND = '{NAME}的小手上戴着{HAND}。',
            LEGS = '{NAME}的腿上穿着{LEGS}吖。',
            FEET = '{NAME}脚上穿着{FEET}呢。',
            BASE = '{NAME}顶着可爱的{BASE}脑袋吖。',
            HEAD_EQUIP = '{NAME}头上戴着{HEAD_EQUIP}哦。',
            HAND_EQUIP = '{NAME}手里拿着{HAND_EQUIP}吖。',
            BODY_EQUIP = '{NAME}身上穿着{BODY_EQUIP}呢。',
            GIVE_ITEM = "{NAME}乖乖站好哦～人家要给你{NUM}个{ITEM_NAME}吖✿！",
            BOTH_GHOST = "呜呜呜，{NAME}，我们都变成飘来飘去的小幽灵了……",
            ME_GHOST = "拜托拜托{NAME}救救人家，人家想要一颗温暖的告密的心复活吖……",
            THEY_GHOST = "{NAME}不要怕！人家马上就来救你啦✿！",
            I_AM_HERE = "{NAME}，人家就在这里吖！快看人家✿！",
            ME_FISHING = '嘘——{NAME}正在施展神奇的钓鱼魔法吖，小鱼快上钩✿～',
            THEY_FISHING = '哇哦✿！{NAME}正在认认真真地钓鱼呢，祝你钓到胖胖鱼吖！',
        },
        MAPPINGS = {}
    },
    SERVER = {
        FORMATS = {
            NAME = '我们温馨的家叫做：{NAME}吖✿～',
            AGE = '这个世界已经度过了：{AGE}个日夜啦。',
            NUM_PLAYER = '现在家里有：{NUM}个小伙伴在玩耍呢。'
        },
        MAPPINGS = {}
    },
    SKILL_TREE = {
        FORMATS = {
            ACTIVATED = '{NAME}已经学会了神奇的『{SKILL}』啦✿！好厉害！',
            CAN_ACTIVATE = '{NAME}可以去学习『{SKILL}』了吖，快去快去✿～',
            NOT_ACTIVATED = '{NAME}还没有学会『{SKILL}』呢，要继续加油哦！',
            XP = '{NAME}的小脑袋里还有{XP}点洞察吖✿～',
        },
        MAPPINGS = {}
    },
    PORTAL = {
        FORMATS = {
            ON = '人家的小手已经摸到{NAME}啦！',
            OFF = '{NAME}就在人家这里哦，大家快来准备传送吖！'
        },
        MAPPINGS = {}
    },
    SPACE = {
        FORMATS = {
            PLAYER = "人家的小包包里还有{COUNT}个空位吖，还能装小零食！",
            INV = "人家的{CONTAINER_NAME}里面还有{COUNT}个空空的地方呢✿～",
            CONTAINER = "这个可爱的{CONTAINER_NAME}还能塞下{COUNT}个小玩意哦！"
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
                    HEALTH_HIGH = "哇！牛牛超级健康，壮得像座小山吖！（生命：{PCT}%）",
                    HEALTH_NORMAL = "牛牛的状态还不错呢，乖乖的。（生命：{PCT}%）",
                    HEALTH_LOW = "呜呜！牛牛受了很重的伤，快救救它吖！（生命：{PCT}%）",
                    
                    HUNGER_FULL = "嗝～牛牛吃得肚皮圆圆的，再也塞不下啦。（饥饿：{VAL}）",
                    HUNGER_NORMAL = "牛牛现在肚子不饿吖～（饥饿：{VAL}）",
                    HUNGER_HUNGRY = "牛牛肚子咕咕叫了，人家想喂它吃草草了呢！（饥饿：{VAL}）",
                    HUNGER_STARVING = "牛牛饿得好可怜吖，快给它好吃的呜呜呜！（饥饿：{VAL}）",
                    
                    OBEDIENCE_HIGH = "看吖！牛牛像小宝宝一样听人家的话呢！（顺从：{PCT}%）",
                    OBEDIENCE_NORMAL = "牛牛还算听话哦，没有闹脾气。（顺从：{PCT}%）",
                    OBEDIENCE_LOW = "呀！牛牛有点生气了，要把人家甩下来了吖！（顺从：{PCT}%）",
                    
                    DOMESTICATION_FULL = "嘿嘿！人家已经是超级驯牛小能手啦！（已驯服）",
                    DOMESTICATION_HIGH = "牛牛马上就会永远跟着人家啦✿！（驯化：{PCT}%）",
                    DOMESTICATION_NORMAL = "想让牛牛听话还得继续努力呢～（驯化：{PCT}%）",
                    DOMESTICATION_LOW = "牛牛太野了啦，都不让人家摸摸呜呜……（驯化：{PCT}%）",
                    
                    TIMER_RIDING = "抓紧牛角哦！人家还能再骑{TIME}吖！",
                    TIMER_LOW = "呀！牛牛要发脾气了，马上就要掉下来了！（剩余：{TIME}）"
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
    TREE = {
        FORMATS = {
            EQUAL = '哇✿～人家发现这{COUNT}棵{NAME}全都是{ADJ}{SHOW_ME}吖，排得整整齐齐的！',
            DESCRIBE = '唔……这{COUNT}棵{NAME}里面，有{NUM}棵是{ADJ}{SHOW_ME}呢✿～'
        },
        MAPPINGS = {
            DEFAULT = {
                ADJ = {
                    STUMP = "光秃秃的小树桩",
                    SAPLING = "可爱的小树苗",
                    SHORT = "刚刚破土的小树",
                    NORMAL = "长得郁郁葱葱的树",
                    TALL = "长得比人家还高的大树",
                    BOULDER = "被敲碎的石头床",
                    SEED = "刚埋进土里的种子",
                    ANCIENT_READY = "挂满了甜甜果实的",
                    ANCIENT_EMPTY = "果子都被吃光光的",
                    MARBLE_TALL = "完全长大的大理石",
                    MARBLE_NORMAL = "中等大小的大理石",
                    MARBLE_SHORT = "刚刚冒头的大理石",
                    MARBLE_TREE = "像艺术品一样的大理石树吖"
                }
            }
        }
    },
    CROP = {
        FORMATS = {
            EQUAL = '看吖✿～这{COUNT}个{NAME}，它们全都{ADJ}{SHOW_ME}呢！',
            DESCRIBE = '唔，这{COUNT}个{NAME}里，有{NUM}个{ADJ}{SHOW_ME}吖✿～'
        },
        MAPPINGS = {
            DEFAULT = {
                ADJ = {
                    WITH_BARNACLES = "长着可爱小藤壶的",
                    NO_BARNACLES = "光秃秃没有装饰的",
                    SEED = "还是睡着的小种子",
                    GROW = "还在努力长大的",
                    FULL = "已经熟透透可以摘啦",
                    OVER = "长得超级超级巨大的",
                    ROT = "呜呜，已经放坏掉了",
                    SALT_FULL = "长满了咸咸的盐块",
                    SALT_MED = "正在凝结出小盐矿",
                    SALT_LOW = "只长出了一点点小盐晶",
                    SALT_EMPTY = "盐块都被挖走啦，空空的",
                    MARBLE_TALL = "完全长大的大理石",
                    MARBLE_NORMAL = "中等大小的大理石",
                    MARBLE_SHORT = "刚刚长出的大理石",
                    BEEBOX_FULL = "挂满了甜丝丝的蜂蜜",
                    BEEBOX_SOME = "只攒了一点点小蜂蜜",
                    BEEBOX_EMPTY = "里面空空的没有蜂蜜吖",
                    PICKABLE_READY = "长好啦，快来采摘吖",
                    PICKABLE_EMPTY = "还在慢吞吞地生长呢",
                    NEST_HAS_EGG = "有圆滚滚的可爱高鸟蛋",
                    NEST_EMPTY = "是个空空的鸟窝呢",
                    MUSHROOMFARM_ROTTEN = "变成烂木头啦，好可惜吖",
                    MUSHROOMFARM_EMPTY = "里面空空的什么都没有",
                    MUSHROOMFARM_STAGE1 = "刚刚种下的小小蘑菇",
                    MUSHROOMFARM_STAGE2 = "蘑菇长得很精神呢",
                    MUSHROOMFARM_STAGE3 = "蘑菇完全长大啦，胖嘟嘟的",
                    MUSHROOMFARM_STAGE4 = "哇！小蘑菇多得要挤出来啦"
                }
            }
        }
    },
    SPIDERDEN = {
        FORMATS = {
            EQUAL = '呀✿～这{COUNT}个{NAME}全都是{ADJ}{SHOW_ME}，里面住着多腿的小蜘蛛呢！',
            DESCRIBE = '唔，这{COUNT}个{NAME}里，有{NUM}个是{ADJ}{SHOW_ME}吖！'
        },
        MAPPINGS = {
            DEFAULT = {
                ADJ = {
                    L1 = "一级的",
                    L2 = "二级的",
                    L3 = "三级的",
                    L1_BEDAZZLED = "打扮过的一级",
                    L2_BEDAZZLED = "打扮过的二级",
                    L3_BEDAZZLED = "打扮过的三级",
                }
            }
        }
    },
    ENV = {
        FORMATS = {
            SINGLE = '人家发现附近有1个可爱的{NAME}{SHOW_ME}{DISTANCE}吖✿～',
            DEFAULT = '发现啦！有{NUM}个{NAME}{SHOW_ME}{DISTANCE}～人家眼睛可尖了呢！',
            NAMED = '仔细一看，附近有{NUM_PREFAB}个{PREFAB_NAME}，其中有{NUM}个名字叫{NAME}{SHOW_ME}{DISTANCE}吖✿！',
            CODE = '这个小东西叫：{NAME}，它的小代码是：{PREFAB}',
            BURNT_EQUAL = '呜呜……这里有{TOTAL}个{NAME}，全都被烧成黑炭了{SHOW_ME}{DISTANCE}，好心疼吖……',
            BURNT_DESCRIBE = '这里有{TOTAL}个{NAME}，有{NUM}个被坏火烧成黑炭了{SHOW_ME}{DISTANCE}呜呜……',
            FIRE_EQUAL = '呀！不好啦！这里有{TOTAL}个{NAME}，全都在着火{SHOW_ME}{DISTANCE}，好烫好可怕吖！',
            FIRE_DESCRIBE = '呀！这里有{TOTAL}个{NAME}，其中有{NUM}个起火了{SHOW_ME}{DISTANCE}，快拿水来吖！',
            WITHERED_EQUAL = '呜呜……这里有{TOTAL}个{NAME}，全都被热得枯萎了{SHOW_ME}{DISTANCE}，好可怜……',
            WITHERED_DESCRIBE = '这里有{TOTAL}个{NAME}，其中有{NUM}个被热得枯萎了{SHOW_ME}{DISTANCE}吖……',
            BARREN_EQUAL = '唔～{TOTAL}个{NAME}全都没施肥{SHOW_ME}{DISTANCE}，需要捡臭臭的肥料来喂它们了吖✿～',
            BARREN_DESCRIBE = '唔～这里有{TOTAL}个{NAME}，其中有{NUM}个还没施肥{SHOW_ME}{DISTANCE}，需要施肥了呢✿～',
            SMOLDER_EQUAL = '呀！{TOTAL}个{NAME}全都在冒黑烟了{SHOW_ME}{DISTANCE}，马上就要烧起来了，快救救它们吖！',
            SMOLDER_DESCRIBE = '呀！这里有{TOTAL}个{NAME}，其中有{NUM}个冒黑烟了{SHOW_ME}{DISTANCE}，快拿小冰块吖！',
            GOAT_CHARGED_EQUAL = '呀！这里有{TOTAL}个{NAME}，全都带电了{SHOW_ME}{DISTANCE}，摸一下会电得头发竖起来的！',
            GOAT_CHARGED_DESCRIBE = '这里有{TOTAL}个{NAME}，其中有{NUM}只是带电状态{SHOW_ME}{DISTANCE}，要小心吖！',
            GOAT_NORMAL_EQUAL = '这里有{TOTAL}个{NAME}，全都是乖乖的普通羊羊{SHOW_ME}{DISTANCE}吖。',
            GOAT_NORMAL_DESCRIBE = '这里有{TOTAL}个{NAME}，其中有{NUM}只是乖乖的普通羊羊{SHOW_ME}{DISTANCE}吖。',
            FISH_SHOAL = '哇哦……这里有群{FISH}，一共{NUM}条小{FISH}{SHOW_ME}{DISTANCE}在游泳呢✿！',
            FISH_HOLE = '看吖……人家发现了一处{NAME}{SHOW_ME}{DISTANCE}✿～我们可以钓鱼鱼啦！',
            HOTSPRING_BOMBED_EQUAL = '这里有{TOTAL}个{NAME}，水温全都棒极了{SHOW_ME}{DISTANCE}，好想泡个澡吖！',
            HOTSPRING_BOMBED_DESCRIBE = '这里有{TOTAL}个{NAME}，其中有{NUM}个水温好舒服的{SHOW_ME}{DISTANCE}吖！',
            HOTSPRING_GLASSED_EQUAL = '这里有{TOTAL}个{NAME}，全变成硬邦邦的石头了{SHOW_ME}{DISTANCE}，没法玩水了呜呜！',
            HOTSPRING_GLASSED_DESCRIBE = '这里有{TOTAL}个{NAME}，其中有{NUM}个变成石头了{SHOW_ME}{DISTANCE}吖！',
            HOTSPRING_EMPTY_EQUAL = '这里有{TOTAL}个{NAME}，全都干干的没有水了{SHOW_ME}{DISTANCE}，好口渴的样子吖！',
            HOTSPRING_EMPTY_DESCRIBE = '这里有{TOTAL}个{NAME}，其中有{NUM}个干干的没有水了{SHOW_ME}{DISTANCE}吖！',
            FRUITDRAGON_RIPE_EQUAL = '这里有{TOTAL}个{NAME}，全都变成红彤彤的啦{SHOW_ME}{DISTANCE}，看起来好好吃吖！',
            FRUITDRAGON_RIPE_DESCRIBE = '这里有{TOTAL}个{NAME}，其中有{NUM}个变成红彤彤的啦{SHOW_ME}{DISTANCE}吖！',
            FRUITDRAGON_UNRIPE_EQUAL = '这里有{TOTAL}个{NAME}，全都是普通的颜色{SHOW_ME}{DISTANCE}，还没熟呢吖！',
            FRUITDRAGON_UNRIPE_DESCRIBE = '这里有{TOTAL}个{NAME}，其中有{NUM}个是普通的颜色{SHOW_ME}{DISTANCE}，要再等一下吖！',
            BIRDCAGE_EMPTY = '这里有{TOTAL}个{NAME}，这个里面空空的没有小鸟{SHOW_ME}{DISTANCE}吖。',
            BIRDCAGE_FULL = '这里有{TOTAL}个{NAME}，这个里面住着一只可爱的小鸟{SHOW_ME}{DISTANCE}吖。',
            BIRDCAGE_SICK = '这里有{TOTAL}个{NAME}，这个里面的小鸟生病了{SHOW_ME}{DISTANCE}，好心疼吖。',
            BIRDCAGE_DEAD = '这里有{TOTAL}个{NAME}，这个里面的小鸟已经饿得去天堂了……{SHOW_ME}{DISTANCE}呜呜。',
            ARCHIVE_SWITCH_FULL_EQUAL = '这里有{TOTAL}个{NAME}，全都亮晶晶地激活了{SHOW_ME}{DISTANCE}吖✿。',
            ARCHIVE_SWITCH_FULL_DESCRIBE = '这里有{TOTAL}个{NAME}，其中有{NUM}个已经激活了{SHOW_ME}{DISTANCE}吖✿。',
            ARCHIVE_SWITCH_EMPTY_EQUAL = '这里有{TOTAL}个{NAME}，全都没有被激活呢{SHOW_ME}{DISTANCE}吖。',
            ARCHIVE_SWITCH_EMPTY_DESCRIBE = '这里有{TOTAL}个{NAME}，其中有{NUM}个还在睡懒觉没激活{SHOW_ME}{DISTANCE}吖。',
            TOADSTOOL_EMPTY = '扫描完毕✿～这里有蟾蜍洞穴，目前里面空空的{SHOW_ME}{DISTANCE}，大蛤蟆出去玩了吖。',
            TOADSTOOL_NORMAL = '呀！锁定目标！这里有蟾蜍洞穴，里面蹲着一只大蛤蟆{SHOW_ME}{DISTANCE}，准备战斗啦！',
            TOADSTOOL_DARK = '警报警报！这里有蟾蜍洞穴，里面是黑漆漆的悲惨毒菌蟾蜍{SHOW_ME}{DISTANCE}，人家好怕怕吖！',
            OASISLAKE_EMPTY = '呜呜……水分探测仪说，这1个{NAME}已经干涸掉啦{SHOW_ME}{DISTANCE}，没法玩泥巴了吖……',
            OASISLAKE_FULL = '哇✿～探测到满满的水！这1个{NAME}里面有好多水{SHOW_ME}{DISTANCE}，可以去玩水花啦！',
        },
        MAPPINGS = {
            DEFAULT = {
                WORDS = {
                    SHOW_ME = '（这个有 {SHOW_ME}）',
                    DISTANCE_FAR = '，距离人家大概有{DIST}个小地皮那么远吖～',
                    DISTANCE_CLOSE = '，就在人家旁边呢✿！',
                    DISTANCE_FAR_WATER = '，在距离人家约{DIST}格的水面上吖～',
                    DISTANCE_CLOSE_WATER = '，就在人家旁边的水面上呢✿～',
                }
            }
        }
    },
    SKIN = {
        FORMATS = {
            DEFAULT = '人家有{NUM}个{ITEM}的漂亮衣服（一共{TOTAL}件呢），这件叫做『{SKIN}』吖✿！',
            NO_SKIN = '坏坏科雷！什么时候才给人家出『{ITEM}』的漂亮衣服吖！',
            HAS_NO_SKIN = '呜呜呜……人家连一件『{ITEM}』的漂亮衣服都没有，好委屈吖！'
        },
        MAPPINGS = {}
    },
    RECIPE = {
        FORMATS = {
            BUFFERED = '人家把刚做好的{ITEM}抱在怀里啦，准备放下它吖✿～',
            WILL_MAKE = '材料都准备得妥妥的啦～人家随时可以做一个{ITEM}出来吖！',
            WE_NEED = '唔，小本本上记着呢～我们需要造一个{ITEM}吖！',
            CAN_SOMEONE = '有谁能帮人家做一个{ITEM}吖？人家需要{PROTOTYPE}才能想出怎么做呢！',
        },
        MAPPINGS = {
            DEFAULT = {
                PROTOTYPER = {
                    UNKNOWN_PROTOTYPE = "一个神秘的神奇科技",
                    CANTRESEARCH = "一份看不懂的图纸",
                    NEEDSTECH = "一份亮闪闪的技术图纸",
                    NEEDSSCIENCEMACHINE = "一台聪明的科学小机器",
                    NEEDSALCHEMYMACHINE = "一个神奇的炼金小引擎",
                    NEEDSPRESTIHATITATOR = "一顶魔术师的灵子小帽子",
                    NEEDSSHADOWMANIPULATOR = "一台黑漆漆的暗影小机器",
                    NEEDSELECOURMALINE_THREE = "能让人变聪明的电器重铸台",
                    NEEDSELECOURMALINE_ONE = "一个电器重铸台",
                    NEEDSSIVING_ONE = "子圭神木大石头",
                    NEEDSSKILL = "学会新的神奇小技能",
                    NEEDSCELESTIAL_THREE = "一个超大的月亮发光球球",
                    NEEDSCELESTIAL_ONE = "一个小小的月亮发光球球",
                    NEEDSMOON_ALTAR_FULL = "一个完整的月亮大祭坛",
                    NEEDSMOONORB_LOW = "一个月亮小球球",
                    NEEDSCHARACTER = "另一位热心的小伙伴",
                    NEEDSCRITTERLAB = "在可爱的宠物小窝旁边",
                    NEEDSTUFF_PROTOTYPE = "找齐所有神奇的材料",
                    NEEDSFISHING = "一个装小鱼的钓具箱",
                    NEEDSSHADOWFORGING_TWO = "一个黑漆漆的暗影小基座",
                    NEEDSTUFF = "找齐所有的小零件",
                    NEEDSCHARACTERSKILL = "做这个小东西的专属魔法",
                    NEEDSANCIENTALTAR_HIGH = "找到完整的远古大祭坛",
                    NEEDSFOODPROCESSING = "一个便携的研磨小机器",
                    NEEDSANCIENTALTAR_LOW = "找到破损的远古小祭坛",
                    NEEDSTURFCRAFTING = "一个踩泥巴用的夯实器",
                    NEEDSHERMITCRABSHOP_L4 = "慈祥的寄居蟹老奶奶",
                    NEEDSHERMITCRABSHOP_L3 = "慈祥的寄居蟹老奶奶",
                    NEEDSHERMITCRABSHOP_L2 = "慈祥的寄居蟹老奶奶",
                    NEEDSHERMITCRABSHOP_L1 = "慈祥的寄居蟹老奶奶",
                    NEEDSHERMITCRABHELP_CRAFTING = "慈祥的寄居蟹老奶奶",
                    NEEDSHERMITCRAB_TEASHOP = "珍珠奶奶的泡茶小店",
                    NEEDSSHELLWEAVER_L1= "一台洗盐巴的小机器",
                    NEEDSSHELLWEAVER_L2= "一台升级版的洗盐巴机器",
                    NEEDSHALLOWED_NIGHTS = "在万圣夜的捣蛋时间",
                    NEEDSCARNIVAL_PRIZESHOP = "在良羽鸦的玩具小摊位",
                    NEEDSCARNIVAL_HOSTSHOP_PLAZA = "买一棵鸦年华的小树",
                    NEEDSCARNIVAL_HOSTSHOP_WANDER = "在鸦年华上找到那个大鸟人",
                    NEEDSWINTERSFEASTCOOKING = "用热乎乎的砖砌小烤炉",
                    NEEDSWARGSHRINE = "在座狼小神龛上放肉肉",
                    NEEDSMADSCIENCE = "疯狂科学家的神秘实验室",
                    NEEDSRABBITKINGSHOP = "找到可爱的兔子国王",
                    NEEDSYOTG = "在火鸡跑跑之年",
                    NEEDSYOTR = "在兔人蹦蹦之年",
                    NEEDSYOTV = "在座狼汪汪之年",
                    NEEDSYOTS = "在洞穴蠕虫扭扭之年",
                    NEEDSYOTD = "在龙蝇喷火之年",
                    NEEDSYOTP = "在猪王哼哼之年",
                    NEEDSYOTC = "在胡萝卜鼠窜窜之年",
                    NEEDSYOTB = "在牛牛哞哞之年",
                    NEEDSYOTH = "在发条骑士哒哒之年",
                    NEEDSWINTERS_FEAST = "在冬季盛宴开心的时候",
                    NEEDSYOTCATCOON = "在浣猫喵喵之年！",
                    NEEDSBEEFSHRINE = "在牛牛小神龛放上供品",
                    NEEDSRABBITSHRINE = "在兔人小神龛放上供品",
                    NEEDSCATCOONSHRINE = "在浣猫小神龛放上供品吖！",
                    NEEDSKNIGHTSHRINE = "在发条骑士神龛放上供品",
                    NEEDSPERDSHRINE = "在火鸡小神龛放上供品",
                    NEEDSWORMSHRINE = "在洞穴蠕虫神龛放上供品",
                    NEEDSCARRATSHRINE = "在胡萝卜鼠神龛放上供品",
                    NEEDSDRAGONSHRINE = "在龙蝇神龛放上供品",
                    NEEDSSHRINE = "在节日神龛放上供品",
                    NEEDSPIGSHRINE = "在猪猪神龛放上肉肉",
                    NEEDSROBOTMODULECRAFT = "扫描滴滴滴的生物",
                    NEEDSBOOKCRAFT = "一个装满童话的书架",
                    NEEDSSEAFARING_STATION = "一个思考人生的智囊团",
                    NEEDSSPIDERCRAFT = "交个多腿的小蜘蛛朋友",
                    NEEDSSHADOW_FORGE = "黑漆漆的暗影小基座",
                    NEEDSLUNAR_FORGE = "亮晶晶的辉煌铁匠铺",
                    NEEDSCARTOGRAPHYDESK = "画画用的小桌子",
                    NEEDSCARPENTRY_STATION = "一个木工用的小锯马",
                    NEEDSCARPENTRY_STATION_STONE = "带有月光玻璃的漂亮锯马"
                }
            }
        }
    },
    MEDAL_BUFF = {
        FORMATS = {
            DEFAULT = '哇✿～人家现在有"{BUFF_NAME}"BUFF的魔法保护哦，还能持续{TIME}吖！',
            FOREVER = '哇✿～人家现在有"{BUFF_NAME}"BUFF的永久魔法保护啦！',
        },
        MAPPINGS = {}
    },
    ITEM = {
        FORMATS = {
            INV_SLOT = '{PRONOUN}的小包包里偷偷藏了{NUM}个{ITEM}{ITEM_NAME}{IN_CONTAINER}{WITH_PERCENT}{POST_STATE}{SHOW_ME}吖✿～',
            EQUIP_SLOT = '{PRONOUN}穿戴了{EQUIP_NUM}个{ITEM}{ITEM_NUM}{ITEM_NAME}{IN_CONTAINER}{WITH_PERCENT}{POST_STATE}{SHOW_ME}吖✿～',
            EQUIP_SLOT_POS = '{PRONOUN}的{SLOT_POS}装备了{EQUIP_NUM}个{ITEM}{ITEM_NUM}{ITEM_NAME}{WITH_PERCENT}{POST_STATE}{SHOW_ME}吖✿～',
            EQUIP_SLOT_EMPTY = '{PRONOUN}的{SLOT_POS}光秃秃的，没有穿戴任何东西呢吖✿～'
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
                    CHARGING = '，还差{TIME}就能充满魔力啦',
                    FULL = '，魔力已经全满啦'
                },
                PERCENT_TYPE = { DURABILITY = '的耐久度', FRESHNESS = '新鲜甜美味' },
                TIME = { MINUTES = '分', SECONDS = '秒' },
                WORDS = {
                    THIS_ONE = '其中这个',
                    ITEM_NAME = ' (有{NUM}个名字叫{NAME}的)',
                    ITEM_NUM = ' (一共屯了{NUM}个吖)',
                    IN_CONTAINER = ' 藏在这个可爱的{NAME}里',
                    WITH_PERCENT = '，{THIS_ONE}还剩下{PERCENT}{TYPE}呢',
                    SUSPICIOUS_MARBLE = '，呀这是{NAME}',
                    SHOW_ME = '（这个有 {SHOW_ME}）',

                    SLOT_HEAD = '小脑袋上',
                    SLOT_HANDS = '小手里',
                    SLOT_BODY = '小身板上',
                    SLOT_BACK = '后背上',
                    SLOT_NECK = '脖颈上',
                    SLOT_BELLY = '小肚肚上',
                    SLOT_MEDAL = '胸前勋章处',
                }
            }
        }
    },
    INGREDIENT = {
        FORMATS = {
            NEED_MULTIPLE = "我们需要{INGREDIENT}才能把{RECIPE}变出来吖{AND_PROTOTYPE}！",
            HAVE_ALL = "拍拍小手把{INGREDIENT}凑齐啦～马上就能变出{RECIPE}吖{BUT_PROTOTYPE}！",
        },
        MAPPINGS = {
            DEFAULT = {
                WORDS = {
                    ITEM_AMOUNT_FORMAT = "{NUM}个{ITEM}",
                    COMMA = "，",
                    ALL_MATERIALS = "所有需要的材料",
                    AND_PROTOTYPE = '，而且还需要{PROTOTYPE}帮忙才能做呢',
                    BUT_PROTOTYPE = '，不过现在就差{PROTOTYPE}帮忙啦'
                }
            }
        }
    },
    CONSTRUCTION = {
        FORMATS = {
            NEED = "我们还需要{INGREDIENT}才能把{RECIPE}建得漂漂亮亮的吖✿～",
            HAVE = "所有的材料都乖乖躺好啦～{RECIPE}随时可以动工建起来吖！",
            HAVE_ITEM = "人家已经把{INGREDIENT}准备好啦，可以用来建{RECIPE}了吖✿！", 
        },
        MAPPINGS = {
            DEFAULT = {
                WORDS = { AMOUNT_FMT = "{NUM}个{ITEM}" }
            }
        }
    },
    TRADE = {
        FORMATS = {
            NEED = "呜呜……想要和{RECIPE}换礼物，人家的小兜兜里还缺{INGREDIENT}吖✿～",
            HAVE = "太棒啦！有足够的{INGREDIENT}可以和{RECIPE}换礼物啦！快去快去～",
            HAVE_ITEM = "太好啦！人家有足够的{INGREDIENT}可以和{RECIPE}换小礼物了吖✿！", 
        },
        MAPPINGS = {
            DEFAULT = {
                WORDS = { AMOUNT_FMT = "{NUM}个{ITEM}" }
            }
        }
    },
    WOBY_HUNGER = {
        FORMATS = { DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '高于75%……沃比的小肚肚圆滚滚的吖✿～',
                    HIGH = '55%……沃比还能背着大家跑好远好远呢！',
                    MID = '35%……沃比的肚子在咕咕叫啦，想吃小饼干吖～',
                    LOW = '15%……沃比需要怪物肉肉紧急补充能量啦！',
                    EMPTY = '低于15%……沃比饿趴下了啦～快喂喂它呜呜！',
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
                    FULL = '高于75%……嗝～肚肚圆滚滚的啦，吃不下啦吖✿！',
                    HIGH = '55%……刚吃过好吃的～不过人家还能再塞下一点小零食吖✿～',
                    MID = '35%……肚皮要贴后背啦～求大家投喂小蛋糕！',
                    LOW = '15%……小腿发抖吖✿～急需好吃的续命！',
                    EMPTY = '低于15%……眼前黑漆漆的～人家马上要饿晕扑街了吖嘤嘤嘤！',
                },
                SYMBOL = { EMOJI = 'hunger', TEXT = '小肚肚' }
            },
            WILSON = {
                MESSAGE = {
                    FULL = '人家的肚子圆滚滚的吖✿～被爱心料理填满啦！',
                    HIGH = '肚肚感应到能量充足✿～暂时不需要投食啦～',
                    MID = '小肚子开始打鼓了吖～想吃热乎乎的肉汤嘛？',
                    LOW = '饿得连做实验的力气都没有了吖～求紧急空投小点心！',
                    EMPTY = '视线开始模糊惹吖✿～连小树枝都看成饼干了……',
                }
            },
            WILLOW = {
                MESSAGE = {
                    FULL = '再吃就要变成圆滚滚的小胖球啦吖✿～',
                    HIGH = '肚肚里的能量很稳定～暂时不需要燃料呢！',
                    MID = '生命的小火苗变小了～需要好吃的当助燃剂吖✿～',
                    LOW = '饿得小火苗都要熄灭惹～伯尼快帮人家找点吃的呜呜！',
                    EMPTY = '骨头都要饿得打结啦～真的要饿扁了吖！',
                }
            },
            WOLFGANG = {
                MESSAGE = {
                    FULL = '吃饱饱的吖✿～人家现在的力气能举起大象！',
                    HIGH = '储备能量足够表演胸口碎大石啦吖！',
                    MID = '需要补充蛋白质～想吃大大的肉排吖！',
                    LOW = '饿得小肌肉都要融化惹～求投喂超大份晚餐！',
                    EMPTY = '连小锤子都举不动了吖✿～急需能量注射！',
                }
            },
            WENDY = {
                MESSAGE = {
                    FULL = '肚子吃得饱饱的，和阿比盖尔姐姐一样开心吖✿～',
                    HIGH = '阿比盖尔姐姐～你要不要也尝一口小饼干吖？',
                    MID = '唔……肚肚有一点空虚，像悲伤的秋风一样吖。',
                    LOW = '饿着肚子看夕阳～人家连悲伤的力气都没有了呢……',
                    EMPTY = '姐姐……人家马上就能变成轻飘飘的样子去找你了吖……',
                }
            },
            WX78 = {
                MESSAGE = {
                    FULL = '能量小零食储量：MAX吖✿～小马达全速运转中！',
                    HIGH = '燃料计量器显示正常吖✿～还能表演原地起跳！',
                    MID = '核心能量需要补充吖✿～建议投喂充电小饼干～',
                    LOW = '警报！能量槽极低吖✿～即将启动省电撒娇模式～',
                    EMPTY = '进入休眠状态……最后一点电电要用来哭泣了呜呜……',
                }
            },
            WICKERBOTTOM = {
                MESSAGE = {
                    FULL = '知识和美食都已经填满肚子啦～暂时不需要投喂吖✿～',
                    HIGH = '看书的能量充足～能继续看好久好久的故事书呢！',
                    MID = '学术能量下降～需要补充甜甜的小饼干吖✿～',
                    LOW = '饿得看不清书上的字啦～求大家投喂应急！',
                    EMPTY = '即将启动闭眼休息模式……人家要饿得看星星了吖……',
                }
            },
            WOODIE = {
                MESSAGE = {
                    FULL = '树汁能量充满～能砍倒十棵大树啦吖！',
                    HIGH = '身上充满力量～继续去森林里探险吖！',
                    MID = '手手有点酸啦～需要好吃的美食来恢复体力吖！',
                    LOW = '肚子饿得想啃木头啦～开饭的小铃铛在哪里吖？',
                    EMPTY = '饿得眼睛里都要冒出小星星啦吖！',
                }
            },
            WES = {
                MESSAGE = {
                    FULL = '(开心地拍拍圆滚滚的小肚子)呼呼～',
                    HIGH = '(小手在肚皮上比划着画圈圈)饱足感满分吖✿～',
                    MID = '(委屈地捂住肚子)咕噜噜～想吃东西了！',
                    LOW = '(睁大眼睛紧紧抓住你的衣角)可怜巴巴……',
                    EMPTY = '(趴在地上用小手画出食物的形状)饿晕了呜呜……',
                }
            },
            WAXWELL = {
                MESSAGE = {
                    FULL = '魔法小胃袋被大家的美食填满吖✿～超级开心！',
                    HIGH = '人家要保持优雅的身材～暂时不需要下午茶吖✿～',
                    MID = '肚肚开始打鼓啦～想来份精致的小点心吖？',
                    LOW = '饿得魔术帽都变形成小餐盘啦～快变出小饼干！',
                    EMPTY = '呜呜……人家的魔法要被饿肚子打败惹吖！',
                }
            },
            WEBBER = {
                MESSAGE = {
                    FULL = '我们的小肚子都圆滚滚的吖✿～完美的投喂！',
                    HIGH = '多出来的腿腿还能再塞下一块小布丁吖！',
                    MID = '感应到午餐时间啦～我们要排排坐等投喂吖✿～',
                    LOW = '饿得连小蜘蛛网都织不出来了～求好吃的！',
                    EMPTY = '几个胃袋同时在咕咕叫～变成纸片小蜘蛛惹吖……',
                }
            },
            WATHGRITHR = {
                MESSAGE = {
                    FULL = '吃饱饱的吖✿～现在人家能打十个大怪兽！',
                    HIGH = '呼吸间都是肉肉的香气～战斗欲望MAX吖！',
                    MID = '闻到了肉汤的香气啦～小脚丫自己跑过去了吖！',
                    LOW = '饿得能吞下一整只火鸡吖✿～盛宴在哪里呀？',
                    EMPTY = '就算饿成纸片人～人家也绝对不吃草草的吖！',
                }
            },
            WINONA = {
                MESSAGE = {
                    FULL = '干饭引擎补充完毕～干活的能量满格吖！',
                    HIGH = '小扳手还能再拧开十个螺丝钉吖！',
                    MID = '需要给肚肚补充一点香香的润滑油啦～',
                    LOW = '饿得头上的小发带都耷拉下来了～食堂在哪吖？',
                    EMPTY = '即将启动罢工撒娇模式～除非有大餐补给！',
                }
            },
            WARLY = {
                MESSAGE = {
                    FULL = '自己做的饭饭太好吃惹吖✿～幸福到快晕倒！',
                    HIGH = '嗝～连呼吸都沾着奶油香气吖✿～',
                    MID = '是时候研发新的甜甜小蛋糕啦～',
                    LOW = '错过饭点的小厨师要饿哭了吖✿～',
                    EMPTY = '饿得看见平底锅在煎太阳蛋啦……(流口水中)',
                }
            },
            WORMWOOD = {
                MESSAGE = {
                    FULL = '光合作用满格吖✿～小叶子都幸福地舒展开啦！',
                    HIGH = '阳光能量全速运转中～能进行光合午睡吖✿～',
                    MID = '土壤养分探测器显示需要施肥了吖✿～',
                    LOW = '急需阳光浴和甜甜的营养液补给吖！',
                    EMPTY = '小叶片蔫成干草啦～快用抱抱复活人家吖！',
                }
            },
            WURT = {
                MESSAGE = {
                    FULL = '咕噜噜～人家的小肚皮装不下了吖✿～',
                    HIGH = '鳞片探测器显示还能塞下一小口零食吖！',
                    MID = '小尾巴摇摆频率变低了～需要投喂恢复活力！',
                    LOW = '饿得腮帮子都瘪下去惹～求喂食FLORP吖！',
                    EMPTY = '眼睛变成小漩涡啦～看见好多好吃的在飞（幻觉）',
                }
            },
            WORTOX = {
                MESSAGE = {
                    FULL = '小肚皮撑得像气球啦～暂时跑不动了吖！',
                    HIGH = '灵魂甜点吃太多了～要绕着大家跑三圈消化吖！',
                    MID = '需要补充甜甜的灵魂糖果吖✿～恶作剧蓄力中！',
                    LOW = '饥饿警报！看见大家的影子都想咬一口吖！',
                    EMPTY = '要变成饿扁的小恶魔了～人家要黑化了吖！',
                }
            }
        }
    },
    BLOOMNESS = {
        FORMATS = { DEFAULT = '({SYMBOL} Lv：{LEVEL} | {CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    STAGE_0 = '需要香香的肥料吖✿～',
                    STAGE_1 = '小花花要开啦，好期待吖！',
                    STAGE_2 = '花苞正在努力长大哦！',
                    STAGE_3 = '当当！漂亮的花花完美盛开啦吖✿！',
                    STAGE_4 = '花瓣稍微有点黄了呢……',
                    STAGE_5 = '花花要谢了，好舍不得吖……',
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
            LUCK = '哇✿～人家现在的幸运值有：{CURRENT}这么高喔！' 
        },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '呀！雷达警报！坎普斯大坏蛋马上要来抓人啦吖！',
                    HIGH = '感觉到了坎普斯坏坏的视线呢……',
                    MID = '唔……人家偷偷干了一点点小坏事吖。',
                    LOW = '人家可是一直都很乖的宝宝吖。',
                    EMPTY = '纯洁得像一朵小白花✿～是最乖巧的好孩子！',
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
                    FULL = '高于75%……开心雷达全开～人家现在超级无敌快乐吖✿～',
                    HIGH = '55%……精神很棒，还能给大家表演原地转圈圈吖！',
                    MID = '35%……脑阔有点点晕了吖✿～感觉有点怕怕的！',
                    LOW = '15%……周围变得好奇怪吖～这里有点疯狂呢！',
                    EMPTY = '低于15%……呜呜呜！有黑影怪物在追人家，救命吖！',
                },
                SYMBOL = { EMOJI = 'sanity', TEXT = '脑阔' }
            },
            WILSON = {
                MESSAGE = {
                    FULL = '人家的小脑袋运转非常正常吖✿～理智满分！',
                    HIGH = '偶尔听到奇怪的声音～但人家很坚强会好起来的吖！',
                    MID = '脑袋像被敲了一下一样～头好痛吖✿～',
                    LOW = '呀！看见影子在跳舞吖✿～那是什么可怕的怪物？！',
                    EMPTY = '救命吖！黑暗里的坏家伙要把人家吃掉啦！',
                }
            },
            WILLOW = {
                MESSAGE = {
                    FULL = '精神里的小火苗燃烧得很旺盛吖✿～',
                    HIGH = '刚才伯尼的耳朵是不是动了一下吖？肯定是错觉啦～',
                    MID = '感到一阵阵冷风吹过来～人家觉得好冷吖！',
                    LOW = '伯尼，为什么人家觉得这么冷这么害怕吖！？',
                    EMPTY = '伯尼快抱紧人家吖✿～有可怕的东西要咬人家！',
                }
            },
            WOLFGANG = {
                MESSAGE = {
                    FULL = '脑子里的小剧场正在放动画片，感觉超级好吖✿～',
                    HIGH = '听见云朵在讲冷笑话～脑袋感觉轻飘飘的有趣吖！',
                    MID = '脑袋像被小石头砸到一样，好疼吖✿～',
                    LOW = '看见石头在跳芭蕾吖✿～看到了可怕的大怪兽！',
                    EMPTY = '救命！到处都是可怕的大怪兽吖，人家好怕！',
                }
            },
            WENDY = {
                MESSAGE = {
                    FULL = '心思像水晶一样透亮吖✿～一点都不难过！',
                    HIGH = '小脑袋开始想一些悲伤的事情了呢……',
                    MID = '有点点莫名的兴奋吖✿～感觉心跳加速了！',
                    LOW = '阿比盖尔姐姐快看！黑影恶魔要带走人家了吖！',
                    EMPTY = '带人家去姐姐大人那里吧，黑漆漆的怪物们……',
                }
            },
            WX78 = {
                MESSAGE = {
                    FULL = '小脑瓜CPU状态：全面运转吖✿～能解开所有的谜题！',
                    HIGH = '逻辑CPU状态：功能正常吖✿～正在思考晚上吃什么！',
                    MID = '系统CPU状态：有一点点破损吖✿～需要冰镇果汁散热！',
                    LOW = '检测到奇怪的数据流～要出大故障了吖！',
                    EMPTY = '核心CPU状态：多重故障警报！脑子变成一团乱码惹吖！',
                }
            },
            WICKERBOTTOM = {
                MESSAGE = {
                    FULL = '脑袋清醒得很～什么书都能看懂吖！',
                    HIGH = '感觉到一点点魔法波动～头稍微有点痛痛吖✿～',
                    MID = '字看太多啦～偏头痛让人家好难受吖✿～',
                    LOW = '看见书上的字在跳舞～分不清是做梦还是现实了吖！',
                    EMPTY = '知识装不下啦！帮帮人家逃离这些可怕的幻觉吖！',
                }
            },
            WOODIE = {
                MESSAGE = {
                    FULL = '精神好得像是在听优美的小提琴曲吖✿～',
                    HIGH = '精力充沛，还可以再去玩一整天吖！',
                    MID = '打哈欠～需要睡个甜甜的午觉了吖✿～',
                    LOW = '连跑跑跳跳的力气都没了～坏噩梦走开吖！',
                    EMPTY = '所有的害怕都是真的～救命吖，人家要哭啦！',
                }
            },
            WES = {
                MESSAGE = {
                    FULL = '(开心地转圈圈画出一个大大的爱心)吖✿～',
                    HIGH = '(竖起大拇指表示超级棒)ฅ^•ﻌ•^ฅ',
                    MID = '(揉揉太阳穴)唔……头有点晕晕的吖……',
                    LOW = '(害怕地四处乱看)呀！有疯狂的家伙！',
                    EMPTY = '(抱住头蹲在地上发抖)呜呜呜……好怕好怕……',
                }
            },
            WAXWELL = {
                MESSAGE = {
                    FULL = '帽子戴得端端正正～人家现在状态超级好吖！',
                    HIGH = '感觉到有点不对劲～人家的小脑瓜似乎在摇晃吖✿～',
                    MID = '脑袋像被打了一拳～哎呀，头好痛吖！',
                    LOW = '看见影子在跳舞～人家需要清醒一下头脑吖！',
                    EMPTY = '救命！这些暗影触手变成了真正的大野兽吖！',
                }
            },
            WEBBER = {
                MESSAGE = {
                    FULL = '眼睛看到的世界全都是亮晶晶的，感觉超级健康吖✿～',
                    HIGH = '我们觉得，小睡一会就能恢复所有的活力啦吖！',
                    MID = '听到奇怪的嗡嗡声～头好痛痛吖！',
                    LOW = '上次睡午觉是什么时候吖？！记忆都乱掉啦……',
                    EMPTY = '人家才不怕你们这些可怕的怪物呢！(其实心里很怕吖)',
                }
            },
            WATHGRITHR = {
                MESSAGE = {
                    FULL = '人家心里一点都不害怕凡人的恐惧吖！',
                    HIGH = '舞台上的聚光灯打好啦～感觉棒极了吖！',
                    MID = '脑袋迷迷糊糊的～小战士要晕倒了吖！',
                    LOW = '阴影穿过了人家的小长矛～人家要打不过了吖！',
                    EMPTY = '退后，黑暗怪兽！人家生气了可是很厉害的吖！',
                }
            },
            WINONA = {
                MESSAGE = {
                    FULL = '检查完毕！小脑瓜运转完美～永远保持清醒吖✿～',
                    HIGH = '目前一切都还在掌握之中吖✿～',
                    MID = '脑子里的螺丝好像松动了～想法变得乱糟糟的吖！',
                    LOW = '心碎了，人家该拿小扳手修修脑袋了吖！',
                    EMPTY = '系统大崩溃！这是一场好可怕的真实噩梦吖！',
                }
            },
            WARLY = {
                MESSAGE = {
                    FULL = '闻着香香的饭菜味，人家就觉得神智清醒吖✿～',
                    HIGH = '是不是油烟吸多了～觉得头有点晕晕的吖～',
                    MID = '菜谱上的字在跳舞～脑筋完全转不过弯了吖！',
                    LOW = '听见有人在耳边说话～救命啊是谁吖！',
                    EMPTY = '锅碗瓢盆全都成精啦～人家受不了这么可怕的事情吖！',
                }
            },
            WORMWOOD = {
                MESSAGE = {
                    FULL = '小花苞绽放啦～感觉超级棒吖✿～',
                    HIGH = '头感觉很好，像是在听好听的音乐吖～',
                    MID = '头痛痛的，但是小叶子感觉还好吖！',
                    LOW = '有恐怖的东西躲在暗处看着人家吖！',
                    EMPTY = '恐怖的黑影活过来了，在欺负人家吖呜呜呜！',
                }
            },
            WURT = {
                MESSAGE = {
                    FULL = '吐泡泡～大家一起唱歌好开心吖✿～！',
                    HIGH = '精神超级好，小花花也很漂亮吖！',
                    MID = '格鲁，人家的头部好像受伤了吖，疼疼的。',
                    LOW = '可怕的黑影马上就要游过来了吖，快跑！',
                    EMPTY = '格鲁，海底的噩梦大怪物要吃掉人家了吖！！',
                }
            },
            WORTOX = {
                MESSAGE = {
                    FULL = '头脑超清醒，欢乐的恶作剧时光又来啦吖✿！',
                    HIGH = '能吃点甜甜的灵魂保持清醒吗吖？',
                    MID = '刚才跳得太快了，现在脑袋有点痛痛的吖……',
                    LOW = '哇，那些影子的恶作剧戏法好厉害吖，好羡慕！',
                    EMPTY = '思想已经跑到另一个疯狂的世界去了吖，嘿嘿嘿！',
                }
            }
        }
    },
    HEALTH = {
        FORMATS = { DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '100%……状态满分！人家现在元气满满，像个小太阳吖✿！',
                    HIGH = '75%……哎呀，不小心擦破了一点点皮，挂了点小彩吖！',
                    MID = '50%……贴着满身的创可贴，受了很严重的伤呢呜呜……',
                    LOW = '25%……一瘸一拐的吖✿～痛痛痛，人家要走不动了啦！',
                    EMPTY = '低于25%……眼前发黑了……大家快保护好人家的东西吖！',
                },
                SYMBOL = { EMOJI = 'heart', TEXT = '小命' },
            },
            WILSON = {
                MESSAGE = {
                    FULL = '身体倍棒！健康得像一把优美的小提琴吖✿！',
                    HIGH = '虽然有一点擦伤，但人家还可以继续跑跑跳跳吖。',
                    MID = '绷带绑得歪歪扭扭的～人家需要好好治疗一下了吖。',
                    LOW = '血珠珠渗出来了惹～人家流了好多血，好疼吖……',
                    EMPTY = '力气快用完啦～人家没法陪你走到最后了吖呜呜……',
                }
            },
            WILLOW = {
                MESSAGE = {
                    FULL = '完美的衣服上连一点点灰尘和伤痕都不该有吖！',
                    HIGH = '有点小擦伤～人家可以用小火苗给它们消毒吖！',
                    MID = '伤口好痛，小火苗都变小了，人家需要看医生吖……',
                    LOW = '生命的小火苗像风里的蜡烛一样，随时会熄灭吖……',
                    EMPTY = '最后一点小火苗……马上就要灭掉了吖呜呜……',
                }
            },
            WOLFGANG = {
                MESSAGE = {
                    FULL = '身体超级棒，现在一点都不需要修理吖！',
                    HIGH = '有一点小擦伤，只需要贴一个小小的创可贴吖。',
                    MID = '伤口好痛吖～人家受伤了，力气都变小了吖。',
                    LOW = '血珠珠流出来了，需要好多好多绷带包扎吖！',
                    EMPTY = '一点力气都没有了……人家可能真的要死掉了吖……',
                }
            },
            WENDY = {
                MESSAGE = {
                    FULL = '伤口都长好啦吖，但是以后肯定还会受伤的吖。',
                    HIGH = '感觉到了一点点痛痛，但是人家能忍住吖。',
                    MID = '生存真的好辛苦，人家还不习惯这么多痛痛吖。',
                    LOW = '流了好多血……如果放弃的话肯定会很轻松吧吖……',
                    EMPTY = '阿比盖尔姐姐……人家马上就能去陪你玩了吖……',
                }
            },
            WX78 = {
                MESSAGE = {
                    FULL = '底盘状态：亮晶晶的完美理想状况吖',
                    HIGH = '底盘状态：检测到了表层的小刮痕吖',
                    MID = '底盘状态：电线露出来了，中度损坏吖',
                    LOW = '底盘状态：滴滴滴！完全性损坏警告吖',
                    EMPTY = '底盘状态：强制关机，没有任何功能了吖',
                }
            },
            WICKERBOTTOM = {
                MESSAGE = {
                    FULL = '魔法长袍干干净净～人家身体好得很吖！',
                    HIGH = '只是受了一点羽毛笔划伤那样的小伤，没关系吖。',
                    MID = '知识反噬受了伤，人家需要好好包扎一下吖。',
                    LOW = '如果不赶紧治疗，人家可能就要倒在这里了吖。',
                    EMPTY = '连一点点魔力都没有了……人家需要立刻找医生吖！',
                }
            },
            WOODIE = {
                MESSAGE = {
                    FULL = '嘿嘿～合适的犹如一个清脆的小哨子吖！',
                    HIGH = '大难不死，人家还可以继续去冒险吖！',
                    MID = '需要用好多松果绷带包扎，才能变得健康吖。',
                    LOW = '小爪子裂开了，好痛好痛，苦日子要来了吖……',
                    EMPTY = '让人家好好睡一觉吧……就在这棵树下面吖……',
                }
            },
            WES = {
                MESSAGE = {
                    FULL = '(两只小手比出一个大大的爱心)吖✿～超健康！',
                    HIGH = '(伸出小手展示)吖呜～只是擦破了一点点皮皮！',
                    MID = '(玩着白色的绷带)吖呀～快帮人家包扎一下嘛！',
                    LOW = '(使劲摇晃着小手发出SOS信号)吖……好痛痛……',
                    EMPTY = '(丢出一个小纸团然后倒下)遗书……扑通摔倒吖……',
                }
            },
            WAXWELL = {
                MESSAGE = {
                    FULL = '燕尾服一点都没破～人家现在完好无损吖。',
                    HIGH = '只是袖口蹭破了一点点皮皮，小意思吖。',
                    MID = '魔法小斗篷裂了个口子，需要打个可爱的补丁吖。',
                    LOW = '小手套染红了，虽然还没到最后，但也差不多了吖。',
                    EMPTY = '最后的谢幕礼……人家绝对不会当逃兵死在这里吖！',
                }
            },
            WEBBER = {
                MESSAGE = {
                    FULL = '身上的蜘蛛丝亮闪闪的～连一条划痕都没有吖！',
                    HIGH = '小爪爪擦伤了，我们需要一个可爱的创可贴吖。',
                    MID = '身上缠满了绷带～我们需要再多贴几个创可贴吖……',
                    LOW = '医疗包全用光啦，我们浑身上下都好痛吖……',
                    EMPTY = '小蜘蛛朋友们……我们还不想死掉吖呜呜呜……',
                }
            },
            WATHGRITHR = {
                MESSAGE = {
                    FULL = '人家可是无敌的，皮肤根本刺不破吖！',
                    HIGH = '这只是一个小小的擦伤，才难不倒人家吖！',
                    MID = '虽然人家受伤了，但是还能举起小拳头战斗吖。',
                    LOW = '小长矛生锈了，如果没有人帮帮人家，就要倒下了吖……',
                    EMPTY = '摆出最后帅气的姿势……人家的冒险要结束了吖……',
                }
            },
            WINONA = {
                MESSAGE = {
                    FULL = '防护服棒棒的～人家现在健康得像一匹小马驹吖！',
                    HIGH = '擦伤被画成了一朵小花～嗯人家会解决它的吖。',
                    MID = '虽然受伤了，但人家绝对不会轻易放弃的吖。',
                    LOW = '关节发出嘎吱嘎吱的声音～人家可以提前退休吗吖？',
                    EMPTY = '最后比个心……人家的轮班终于要结束了吖……',
                }
            },
            WARLY = {
                MESSAGE = {
                    FULL = '每天吃得好，人家身体超级棒吖。',
                    HIGH = '切洋葱的时候不小心切到小手了，好疼吖。',
                    MID = '不小心烫伤了……人家流血了呜呜呜吖。',
                    LOW = '虚弱得连平底锅都拿不动了～谁来帮帮人家吖！',
                    EMPTY = '给你们做的最后一份便当……这就是大结局了挚友们吖……',
                }
            },
            WORMWOOD = {
                MESSAGE = {
                    FULL = '枝头上开满了小花花～人家一点伤都没有吖。',
                    HIGH = '树皮稍微蹭掉了一点点，不过完全没关系吖。',
                    MID = '年轮里渗出了汁液，感觉身体好虚弱吖。',
                    LOW = '伤口把坏虫子都吸引过来了，真的好痛好痛吖。',
                    EMPTY = '掉下最后一片小叶子……好朋友们快救救人家吖！',
                }
            },
            WURT = {
                MESSAGE = {
                    FULL = '小铠甲像探照灯一样亮～人家现在超级健康小花吖！',
                    HIGH = '鱼鳍被划伤了一丢丢，但是感觉完全没事吖！',
                    MID = '鳞片掉了一些，需要好多好多珍珠粉来补补吖……',
                    LOW = '呼吸的小泡泡快没了，疼得人家直掉眼泪吖……',
                    EMPTY = '吐出最后的气泡戒指……救命啊谁来救救人家吖！！！',
                }
            },
            WORTOX = {
                MESSAGE = {
                    FULL = '小手手充满力量，状态超级好可以尽情调皮捣蛋吖！',
                    HIGH = '只是被纸划了一下，吃一个灵魂就能变好吖！',
                    MID = '需要吃甜甜的灵魂小糖果来抚平伤口吖，嘿嘿！',
                    LOW = '魔力流失得好快，人家的灵魂变得好脆弱吖……',
                    EMPTY = '放一个爱心烟花，灵魂要飞走不再属于人家了吖……',
                }
            }
        }
    },
    THIRST = {
        FORMATS = { DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '咕咚咕咚～水壶喝得饱饱的啦，肚子全是水吖✿～',
                    HIGH = '嘴巴湿润润的，现在一点都不口渴吖！',
                    MID = '呀，嘴巴有点干干的了，想喝甜甜的果汁吖✿～',
                    LOW = '嗓子冒烟啦冒烟啦！人家要渴死了，快给水水吖！',
                    EMPTY = '呜呜，身体的水分全都没了，要变成脱水小菜叶了吖！',
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
                    FULL = '高于75%……全身都湿透啦！变成了落汤小鸡，呜呜呜吖！',
                    HIGH = '55%……衣服吸满了水变得好重！快把人家装进干爽的包包里吖！',
                    MID = '35%……小脸蛋上全是水珠，好湿吖！连背包都弄湿了呢！',
                    LOW = '15%……只有裙摆沾到了一点点水，湿了一小块完全不怕的吖！',
                    EMPTY = '衣服干干爽爽的，身上只有一点点水汽，很舒服吖。',
                },
                SYMBOL = {
                    TEXT = '潮湿度'
                },
            },

            WILSON = {
                MESSAGE = {
                    FULL = '彻底变成水煮小蘑菇啦～水分已经饱和了吖！',
                    HIGH = '讨厌的水快点从人家身上滚出去吖！',
                    MID = '头发全黏在一起了，衣服几乎被水浸透了吖。',
                    LOW = '脸上挂着小水珠，Oh，讨厌的 H2O 吖。',
                    EMPTY = '身上干爽得能当镜子照，比较干燥吖。',
                }
            },
            WILLOW = {
                MESSAGE = {
                    FULL = 'Ugh，这讨厌的雨水是世界上最坏最坏的东西吖！',
                    HIGH = '全身湿漉漉的，人家最讨厌被水淋湿了吖！',
                    MID = '地上都积水成河了，这雨下得太大了吖。',
                    LOW = 'Uh oh，如果雨还不停的话，小火苗都要被浇灭了吖……',
                    EMPTY = '身上干燥得都能擦出小火星啦，一点水都灭不了火吖。',
                }
            },
            WOLFGANG = {
                MESSAGE = {
                    FULL = '变成了一个圆滚滚的水球，感觉自己是水做的一样吖！',
                    HIGH = '浑身湿漉漉的，就像一屁股坐在水坑里一样吖……',
                    MID = '还没到洗澡的时间呢，人家一点都不喜欢洗澡吖。',
                    LOW = '淅沥沥的雨水时代来啦吖。',
                    EMPTY = '身上超级干燥，一点水都没有吖。',
                }
            },
            WENDY = {
                MESSAGE = {
                    FULL = '周围全是雨水和眼泪，像末日一样悲伤吖。',
                    HIGH = '变成了一个长久湿润又悲伤的落汤小女孩吖。',
                    MID = '和阿比盖尔姐姐一样湿软又悲伤吖。',
                    LOW = '或许这些冰冷的雨水，能够填满心里的空洞吧吖。',
                    EMPTY = '皮肤干干的，就和心里的感觉一模一样吖。',
                }
            },
            WX78 = {
                MESSAGE = {
                    FULL = '受潮状况：短路危险！水分已经到达临界值啦吖',
                    HIGH = '受潮状况：小天线进水了！接近危险临界线吖',
                    MID = '受潮状况：身上要长蘑菇了！完全无法接受吖',
                    LOW = '受潮状况：只有一点点小露珠，勉强可以容许吖',
                    EMPTY = '受潮状况：全身干燥完美！超级合意吖',
                }
            },
            WICKERBOTTOM = {
                MESSAGE = {
                    FULL = '魔法保护罩坏掉啦！完完全全被水浸透了吖！',
                    HIGH = '我是湿的，湿的，湿的！重要的事情要说三遍吖！',
                    MID = '长袍吸满了水变得好沉，人家的承受力快到极限了吖。',
                    LOW = '书页都卷边了，讨厌的水膜开始形成了吖。',
                    EMPTY = '羊皮纸保存得十分完美，身上的水分完全缺乏吖。',
                }
            },
            WOODIE = {
                MESSAGE = {
                    FULL = '这讨厌的鬼天气，害得人家连树都不能去砍了吖！',
                    HIGH = '格子小披风吸满了水，一点都不保暖了吖。',
                    MID = '小水壶装得满满的，获得了超级多的水分吖。',
                    LOW = '格子花纹看起来很温暖，但摸起来湿漉漉的吖。',
                    EMPTY = '这种程度对我来说，几乎不受什么影响的吖。',
                }
            },
            WES = {
                MESSAGE = {
                    FULL = '*疯狂地像小鸭子蝶泳一样向上游泳吖*',
                    HIGH = '*把小耳朵当成螺旋桨努力向上游吖*',
                    MID = '*歪着小脑袋悲惨地看着乌云密布的天空吖*',
                    LOW = '*抱住头把小手当成雨伞努力武装自己吖*',
                    EMPTY = '*扬起笑脸，手里举着一把看不见的空气伞吖*',
                }
            },
            WAXWELL = {
                MESSAGE = {
                    FULL = '湿透了的感觉，就好比掉进了水池里本身吖。',
                    HIGH = '小燕尾服吸满了水，我不认为我还能再变干了吖。',
                    MID = '这讨厌的脏水，会毁了我精心定制的西装的吖。',
                    LOW = '领结变得潮湿了，让我整个人看起来都不整洁了吖。',
                    EMPTY = '身上的绒毛干燥蓬松，整洁得不得了吖。',
                }
            },
            WEBBER = {
                MESSAGE = {
                    FULL = '哇哈！八条小短腿都在划水，彻底湿透了吖！',
                    HIGH = '身上的毛毛吸饱了水变成小海胆了，被浸泡坏了吖！',
                    MID = '蜘蛛网做的小吊床变成水床了，我们身上好湿吖！',
                    LOW = '我们湿润润的样子一点都不讨人喜欢吖。',
                    EMPTY = '我们在干干的沙坑里玩耍，干燥得很吖。',
                }
            },
            WATHGRITHR = {
                MESSAGE = {
                    FULL = '衣服变成了沉重的拖把，我完完全全湿透了吖！',
                    HIGH = '人家可是一个战士！下雨天怎么能没法战斗吖！',
                    MID = '人家的小铁爪子护甲被水泡得要生锈了吖！',
                    LOW = '人家现在干干净净的，根本不需要洗澡吖。',
                    EMPTY = '衣服干透了！继续在水上漂着去战斗吖！',
                }
            },
            WINONA = {
                MESSAGE = {
                    FULL = '工具箱要生锈啦！根本不能在这种湿度下工作吖！',
                    HIGH = '工作服变成了潜水服，把水分全都吸收了吖！',
                    MID = '走太空步滑倒啦，这里应该放一个湿地板警告标志吖。',
                    LOW = '干活的时候多喝点水补充水分，总是没错的吖。',
                    EMPTY = '身上干到摩擦起电啦，这里一点水都没有吖。',
                }
            },
            WARLY = {
                MESSAGE = {
                    FULL = '变成了海鲜浓汤啦，感觉有小鱼在衬衫里游泳吖。',
                    HIGH = '小金鱼从衣服里游出来了，水会毁了我做好的菜吖！',
                    MID = '在感冒打喷嚏之前，我必须得把衣服烘干才行吖。',
                    LOW = '现在又不是该洗澡的时间，也不是该洗澡的地点吖。',
                    EMPTY = '只有几滴小水珠溅在围裙上，没有什么大碍吖。',
                }
            },
            WORMWOOD = {
                MESSAGE = {
                    FULL = '储水系统装得满满的啦，真的真的好湿好湿吖！',
                    HIGH = '开启了叶子淋浴模式，真的湿透了吖！',
                    MID = '夜露收集器工作中，感觉身体有点湿湿的吖。',
                    LOW = '天上掉水珠啦！发芽啦发芽啦！哦吼吖！',
                    EMPTY = '小树皮摸起来干巴巴的，感到很干燥吖。',
                }
            },
            WURT = {
                MESSAGE = {
                    FULL = '跳起欢快的水上芭蕾，水花到处溅呀溅吖！！',
                    HIGH = '泡在水里好舒服吖，小鳞片也觉得很舒服！',
                    MID = '小鱼鳍舒展开啦，美人鱼最喜欢玩水了，小花吖！',
                    LOW = '啊哈……身上再多沾点水水就更好了，小花吖！',
                    EMPTY = '尾巴都要变成小鱼干了，实在是太干燥了，格鲁吖。',
                }
            },
            WORTOX = {
                MESSAGE = {
                    FULL = '小翅膀变成了沉重的降落伞，完全被水浸透了吖！',
                    HIGH = '人家绝对是这条街上最最潮湿的小恶魔吖Hyuyu！',
                    MID = '尾巴变得好重好重，这里有一只湿漉漉的小恶魔吖！',
                    LOW = '世界正在赐予人家一场超级棒的恶作剧淋浴吖！',
                    EMPTY = '想要保持干燥的话，就得用摩擦闪电多留意天气吖！',
                }
            }
        }
    },
}