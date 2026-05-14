GLOBAL.STRINGS.NOMU_QA.TITLE_TEXT_CAT_SCHEME = '猫娘方案'

GLOBAL.STRINGS.CAT_NOMU_QA = {
    SEASON = {
        FORMATS = { DEFAULT = '主人～{SEASON}的尾巴尖尖还剩{DAYS_LEFT}个毛线球长度喵󰀍～' },
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
            START_RAIN = '喵呜～{WORLD}气温：{TEMPERATURE}，{WEATHER}来了喵：第{DAYS}天（{MINUTES}分{SECONDS}秒）',
            NO_RAIN = '嗅嗅……{WORLD}气温：{TEMPERATURE}，肉垫预报{WEATHER}还没来喵󰀍～',
            STOP_RAIN = '喵！{WORLD}气温：{TEMPERATURE}，放晴啦：第{DAYS}天（{MINUTES}分{SECONDS}秒）～',
        },
        MAPPINGS = {
            DEFAULT = {
                WORLD = { SURFACE = '地表', CAVES = '洞穴', SHIPWRECKED = '海难', VOLCANO = '火山', PORKLAND = '猪镇', WINTERLAND = '冰岛' },
                WEATHER = { SPRING = '降雨', SUMMER = '降雨', AUTUMN = '降雨', WINTER = '降雪', GREEN = '降雨', DRY = '降雨', MILD = '降雨', WET = '飓风', TEMPERATE = '降雨', HUMID = '降雨', LUSH = '降雨', APORKALYPSE = '降雨' },
            }
        }
    },
    TEMPERATURE = {
        FORMATS = { DEFAULT = '({TEMPERATURE}°) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    BURNING = '肉垫要融化惹喵󰀍～主人的尾巴能当扇子用嘛？',
                    HOT = '胡须都打卷啦～人家需要冰冻小鱼干降温喵！',
                    WARM = '绒毛太蓬松惹～在阳光毯上打滚散热喵󰀍～',
                    GOOD = '呼噜呼噜～这个温度最适合蜷成猫面包睡午觉喵󰀍～',
                    COOL = '尾巴尖尖在发抖～需要热牛奶蒸汽熏胡须喵󰀍～',
                    COLD = '耳朵变成冰片片啦～急需用主人的掌心温度解冻喵！',
                    FREEZING = '彻底变成冰镇猫猫啦～急需十个暖宝宝贴贴喵！',
                }
            }
        }
    },
    MOON_PHASE = {
        FORMATS = {
            DEFAULT = '喵󰀍～{RECENT}{PHASE1}{INTERVAL}距离下个{PHASE2}还有{LEFT}天呢。',
            MOON = '主人快看喵！{RECENT}{PHASE1}啦󰀍～',
            FAILED = '喵呜……云层太厚啦，胡须雷达测不出月相喵！'
        },
        MAPPINGS = {
            DEFAULT = {
                MOON = { FULL = '满月大玉盘', NEW = '月黑风高' },
                INTERVAL = { COMMA = '，', NONE = '' },
                RECENT = { TODAY = '今晚是', TOMORROW = '明晚是', AFTER = '我们刚度过' },
            }
        }
    },
    CLOCK = {
        FORMATS = {
            DEFAULT = '{PHASE}还剩{PHASE_REMAIN}喵～今天还有{DAY_REMAIN}打盹时间󰀍。',
            NIGHTMARE = '{PHASE}还剩{PHASE_REMAIN}喵～今天还有{DAY_REMAIN}，{NIGHTMARE}还有{REMAIN}结束啦！',
            NIGHTMARE_LOCK = '{PHASE}还剩{PHASE_REMAIN}喵～今天还有{DAY_REMAIN}，{NIGHTMARE}喵！'
        },
        MAPPINGS = {
            DEFAULT = {
                TIME = { MINUTES = '分', SECONDS = '秒' },
                PHASE = { DAY = '晒太阳的白天', DUSK = '抓虫虫的黄昏', NIGHT = '黑漆漆的夜晚' },
                NIGHTMARE = {
                    CALM = "暗影泡泡平息阶段",
                    WARN = "喵嗷！暗影警告阶段",
                    WILD = "坏家伙们暴动阶段",
                    DAWN = "喵呼，马上就过去的过渡阶段",
                },
            }
        }
    },
    COOK = {
        FORMATS = {
            CAN = '只要挥挥尾巴～人家就能变出{NAME}喵󰀍～',
            NEED = '肚子饿饿喵～人家需要做个{NAME}󰀍～',
            MIN_INGREDIENT = '制作美味的{NAME}需要{NUM}个{INGREDIENT}喵！',
            MAX_INGREDIENT = '煮{NAME}最多只能加{NUM}个{INGREDIENT}哦～',
            ZERO_INGREDIENT = '喵呜！{NAME}里面绝对不可以放{INGREDIENT}啦！',
            HUNGER = '{NAME}料理{TYPE}饱食度{VALUE}点喵󰀍～',
            SANITY = '{NAME}料理{TYPE}精神值{VALUE}点喵󰀍～',
            HEALTH = '{NAME}料理{TYPE}生命值{VALUE}点喵󰀍～',
            FOOD = '当当！{NAME}：饱食度{HUNGER}，精神值{SANITY}，生命值{HEALTH}喵󰀍～',
            FOOD_LOCK = '喵？人家的肉垫还没解锁{NAME}呢。',
            FOOD_NO_EATEN = '需要主人喂人家试吃一口{NAME}才能知道味道喵󰀍～',
        },
        MAPPINGS = {
            DEFAULT = {
                TYPE = { POS = '会涨', NEG = '会掉' }
            }
        }
    },
    BOAT = {
        FORMATS = { DEFAULT = '(猫爪号：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '甲板干净到能晒鱼干～航海模式准备完毕喵󰀍！',
                    HIGH = '发现两个爪印漏水点～已用临时小鱼干补丁修复！',
                    MID = '厨房舱室渗水啦～储备的小鱼干要泡汤了喵！',
                    LOW = '警报！底舱进水～启动自动炸毛浮力系统喵！',
                    EMPTY = '启动紧急猫囊逃生系统～喵生筏充气中！',
                }
            }
        }
    },
    ABIGAIL = {
        FORMATS = { DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '姐姐大人的幽灵尾巴在守护人家喵󰀍～',
                    HIGH = '月光下能看见姐姐透明的猫耳轮廓喵󰀍～',
                    MID = '姐姐的铃铛声从彼岸传来～要仔细听喵！',
                    LOW = '姐姐的幻影开始模糊了……不要受伤喵……',
                    EMPTY = '最后一根相连的绒毛……也断开了喵！快回来！',
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
                    FULL = '兽耳滚烫的喵󰀍～爪爪痒痒的想挠点什么！',
                    HIGH = '尾巴变得毛茸茸的～能当围巾用了喵！',
                    MID = '开始喜欢生鱼片了喵󰀍～三分熟带血丝的最棒！',
                    LOW = '兽耳耷拉下来了喵󰀍～要用小鱼干能量补充！',
                    EMPTY = '最后一丝兽力用来给主人比心啦～变回普通猫娘喵󰀍～',
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
                    MIGHTY = '尾巴能举起十个毛线球喵󰀍～！',
                    NORMAL = '给主人表演肉垫深蹲～嘿咻！',
                    WIMPY = '肚肚上的肉肉在抗议运动啦～需要主人抱抱喵！',
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
                    EMPTY = '喵呜，嗓子干干的唱不出来喵。',
                    LOW = '喵星之神赐予力量～能唱一首喵喵歌！',
                    MID = '对面的坏蛋～听人家唱两首喵喵歌！',
                    HIGH = '主人的小鱼干是最棒的补给～火力全开连唱三首喵！'
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
            DEFAULT = '(电量：{CURRENT}/{MAX}，已占用：{USED}格) 喵呜～能量储备{MESSAGE}喵！',
            CHIP = '{NUM}个{ITEM}喵',
            ALL_MODULES = '肉垫感应到～人家尾巴上装配了：{MODULES}喵！',
            NO_MODULES = '喵呜……人家的插槽空空的，还没装任何电路喵。'
        },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    ZERO = '耗尽惹',
                    ONE = '极低喵',
                    TWO = '有点低喵',
                    THREE = '还有一半喵',
                    FOUR = '挺充足喵',
                    FIVE = '很有精神喵',
                    SIX = '满格啦喵'
                }
            }
        }
    },
    GIFT = {
        FORMATS = {
            CAN_OPEN = '嗅嗅……有礼物的味道！许愿！开红喵！！！',
            NEED_SCIENCE = '人家的喵力不够，需要科学猫爬架才能拆礼物喵󰀍～',
        },
        MAPPINGS = {}
    },
    PLAYER = {
        FORMATS = {
            DEFAULT = '{NAME}正在人家这里喵󰀍～',
            ADMIN = '{NAME}是管理员铲屎官耶！',
            NAME = '{NAME}是{CHARACTER}喵。',
            AGE = '{NAME}在这里生存了{AGE}喵。',
            AGE_SHORT = '{NAME}{AGE}喵。',
            PERF = '{NAME} 的{PERF}喵～{PING}',
            GREET = '主人的脚步声最好认了喵󰀍～你好吖，{NAME}。',
            PING = '喵呜通道延迟：{PING}',
            BADGE = '{NAME}戴着{BADGE}的头牌喵。',
            BACKGROUND = '{NAME}的背景是{BACKGROUND}。',
            BODY = '{NAME}的绒毛穿着{BODY}。',
            HAND = '{NAME}的爪爪套着{HAND}。',
            LEGS = '{NAME}的腿腿穿着{LEGS}。',
            FEET = '{NAME}的小脚垫着{FEET}。',
            BASE = '{NAME}的脑袋顶着{BASE}。',
            HEAD_EQUIP = '{NAME}头上戴着{HEAD_EQUIP}喵。',
            HAND_EQUIP = '{NAME}爪子捏着{HAND_EQUIP}喵。',
            BODY_EQUIP = '{NAME}身上穿着{BODY_EQUIP}喵。',
            GIVE_ITEM = "{NAME}乖乖别动～人家用尾巴卷来了{NUM}个{ITEM_NAME}给你喵󰀍～",
            BOTH_GHOST = "呜呜呜，{NAME}，我们变成幽灵小伙伴了喵󰀍～",
            ME_GHOST = "拜托{NAME}救救我，人家需要一颗温暖的心复活喵󰀍～",
            THEY_GHOST = "{NAME}撑住！人家的猫爪救援马上就到喵！",
            I_AM_HERE = "{NAME}，人家就在这里喵󰀍～！",
            ME_FISHING = '嘘——{NAME}正在用肉垫屏息钓鱼鱼喵，快咬钩吧！',
            THEY_FISHING = '喵󰀍～{NAME}正在专注钓鱼鱼呢，希望能钓到超大号小鱼干喵！',
        },
        MAPPINGS = {}
    },
    SERVER = {
        FORMATS = {
            NAME = '我们的猫窝叫：{NAME}喵～',
            AGE = '猫窝已经运转：{AGE}次打盹周期喵。',
            NUM_PLAYER = '现在有：{NUM}只猫猫喵。'
        },
        MAPPINGS = {}
    },
    SKILL_TREE = {
        FORMATS = {
            ACTIVATED = '{NAME}已经点亮『{SKILL}』啦喵󰀍～尾巴自动生成光效中！',
            CAN_ACTIVATE = '{NAME}快用爪爪戳亮『{SKILL}』喵呜󰀍～',
            NOT_ACTIVATED = '{NAME}的绒毛蓬松度不足，还没解锁『{SKILL}』喵󰀍～',
            XP = '{NAME}的洞察还有{XP}点喵󰀍～',
        },
        MAPPINGS = {}
    },
    PORTAL = {
        FORMATS = {
            ON = '肉垫已经在摸{NAME}了喵！',
            OFF = '{NAME}在人家这里，快准备触摸传送喵！'
        },
        MAPPINGS = {}
    },
    SPACE = {
        FORMATS = {
            PLAYER = "人家的尾巴测量到～包包还能卷起{COUNT}个毛线球的空间喵！",
            INV = "用胡须探了探包里的{CONTAINER_NAME}～还能塞下{COUNT}个会发光的小玩意喵󰀍～",
            CONTAINER = "这个{CONTAINER_NAME}足够装下{COUNT}只打滚的猫猫幼崽喵！"
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
                    HEALTH_HIGH = "喵󰀍～牛牛像小鱼干堆一样壮实！（生命：{PCT}%）",
                    HEALTH_NORMAL = "牛牛状态还可以喵，能驮着人家跑！（生命：{PCT}%）",
                    HEALTH_LOW = "喵嗷！牛牛快倒下了，快救救它！（生命：{PCT}%）",
                    
                    HUNGER_FULL = "嗝喵～牛牛吃得肚皮圆圆的，塞不下了！（饥饿：{VAL}）",
                    HUNGER_NORMAL = "牛牛现在不饿喵～（饥饿：{VAL}）",
                    HUNGER_HUNGRY = "牛牛肚子咕咕叫啦，想吃草草喵！（饥饿：{VAL}）",
                    HUNGER_STARVING = "牛牛饿得想啃人家的尾巴了喵！快喂它！（饥饿：{VAL}）",
                    
                    OBEDIENCE_HIGH = "看喵！牛牛像小猫一样听话！（顺从：{PCT}%）",
                    OBEDIENCE_NORMAL = "牛牛还算听话喵，没发脾气。（顺从：{PCT}%）",
                    OBEDIENCE_LOW = "牛牛眼神凶凶的，要把人家甩飞了喵！（顺从：{PCT}%）",
                    
                    DOMESTICATION_FULL = "喵哈哈！人家已经是驯牛大师猫了！（已驯服）",
                    DOMESTICATION_HIGH = "牛牛马上就要变成人家的专属坐骑了喵！（驯化：{PCT}%）",
                    DOMESTICATION_NORMAL = "驯牛还得继续努力喵～（驯化：{PCT}%）",
                    DOMESTICATION_LOW = "牛牛太野啦！都不让人家摸摸喵。（驯化：{PCT}%）",
                    
                    TIMER_RIDING = "抓紧牛角喵！还能再骑{TIME}哦！",
                    TIMER_LOW = "喵嗷！牛牛要生气了，快抱紧！（剩余：{TIME}）"
                },
                TENDENCY_NAME = {
                    DEFAULT = "普通喵",
                    RIDER = "跑跑喵",
                    ORNERY = "凶凶喵",
                    PUDGY = "胖胖喵",
                    UNKNOWN = "未知喵"
                }
            }
        }
    },
    TREE = {
        FORMATS = {
            EQUAL = '喵󰀍～人家发现这{COUNT}棵{NAME}全都是{ADJ}{SHOW_ME}喵，是完美的天然猫爬架呢！',
            DESCRIBE = '嗅嗅……这{COUNT}棵{NAME}里有{NUM}棵{ADJ}{SHOW_ME}喵󰀍～'
        },
        MAPPINGS = {
            DEFAULT = {
                ADJ = {
                    STUMP = "光秃秃的树桩",
                    SAPLING = "可爱的小树苗",
                    SHORT = "刚刚长出的小树",
                    NORMAL = "长得不错的树",
                    TALL = "长得高高大大的",
                    BOULDER = "被砍成了矿床的",
                    SEED = "刚种下的种子",
                    ANCIENT_READY = "挂满果实的",
                    ANCIENT_EMPTY = "果子被吃光了的",
                    MARBLE_TALL = "完全长大的大理石",
                    MARBLE_NORMAL = "中等大小的大理石",
                    MARBLE_SHORT = "刚刚长出的大理石",
                    MARBLE_TREE = "大理石雕刻的漂亮树喵"
                }
            }
        }
    },
    CROP = {
        FORMATS = {
            EQUAL = '喵󰀍～人家发现附近有{COUNT}个{NAME}，它们全都{ADJ}{SHOW_ME}喵！',
            DESCRIBE = '喵󰀍～人家发现附近有{COUNT}个{NAME}，其中有{NUM}个{ADJ}{SHOW_ME}喵！'
        },
        MAPPINGS = {
            DEFAULT = {
                ADJ = {
                    WITH_BARNACLES = "长着小藤壶的",
                    NO_BARNACLES = "光秃秃的",
                    SEED = "还是小种子",
                    GROW = "还在努力长大",
                    FULL = "已经成熟啦",
                    OVER = "长得超级巨大",
                    ROT = "已经坏掉了",
                    SALT_FULL = "长满了咸咸的盐块",
                    SALT_MED = "正在结出小盐矿",
                    SALT_LOW = "只长出一点盐晶",
                    SALT_EMPTY = "盐块都被挖走啦",
                    MARBLE_TALL = "完全长大的大理石",
                    MARBLE_NORMAL = "中等大小的大理石",
                    MARBLE_SHORT = "刚刚长出的大理石",
                    BEEBOX_FULL = "挂满了甜甜的蜂蜜",
                    BEEBOX_SOME = "攒了一点点蜂蜜",
                    BEEBOX_EMPTY = "空空的没有蜂蜜",
                    PICKABLE_READY = "长好啦，快去采摘",
                    PICKABLE_EMPTY = "还在努力生长",
                    NEST_HAS_EGG = "有圆滚滚的高鸟蛋",
                    NEST_EMPTY = "是个空鸟窝",
                    MUSHROOMFARM_ROTTEN = "变成烂木头啦",
                    MUSHROOMFARM_EMPTY = "里面空空的",
                    MUSHROOMFARM_STAGE1 = "刚刚种下小蘑菇",
                    MUSHROOMFARM_STAGE2 = "蘑菇长得不错",
                    MUSHROOMFARM_STAGE3 = "蘑菇完全长大啦",
                    MUSHROOMFARM_STAGE4 = "哇！蘑菇多得要掉下来啦"
                }
            }
        }
    },
    SPIDERDEN = {
        FORMATS = {
            EQUAL = '喵󰀍～这{COUNT}个{NAME}全都是{ADJ}{SHOW_ME}，长着毛茸茸的蜘蛛先生喵！',
            DESCRIBE = '喵呜，这{COUNT}个{NAME}里有{NUM}个是{ADJ}{SHOW_ME}喵！'
        },
        MAPPINGS = {
            DEFAULT = {
                ADJ = {
                    L1 = "一级的",
                    L2 = "二级的",
                    L3 = "三级的",
                    L1_BEDAZZLED = "被装饰的一级",
                    L2_BEDAZZLED = "被装饰的二级",
                    L3_BEDAZZLED = "被装饰的三级",
                }
            }
        }
    },
    ENV = {
        FORMATS = {
            SINGLE = '主人的猫猫雷达发现附近有1个{NAME}{SHOW_ME}{DISTANCE}喵󰀍～',
            DEFAULT = '检测到{NUM}个{NAME}{SHOW_ME}{DISTANCE}～人家耳朵竖起来了喵！',
            NAMED = '胡须测量仪显示，附近有{NUM_PREFAB}个{PREFAB_NAME}，其中有{NUM}个叫{NAME}{SHOW_ME}{DISTANCE}喵！',
            CODE = '这玩意叫：{NAME}，猫星代码是：{PREFAB}',
            BURNT_EQUAL = '喵……这里有{TOTAL}个{NAME}，全都被烧成黑炭了{SHOW_ME}{DISTANCE}喵……',
            BURNT_DESCRIBE = '这里有{TOTAL}个{NAME}，有{NUM}个被烧成黑炭了{SHOW_ME}{DISTANCE}喵……',
            FIRE_EQUAL = '喵呜！这里有{TOTAL}个{NAME}，全都在起火快跑{SHOW_ME}{DISTANCE}喵！',
            FIRE_DESCRIBE = '呜喵！这里有{TOTAL}个{NAME}，其中有{NUM}个起火了快跑{SHOW_ME}{DISTANCE}喵！',
            WITHERED_EQUAL = '喵……这里有{TOTAL}个{NAME}，全都被热得枯萎了{SHOW_ME}{DISTANCE}喵……',
            WITHERED_DESCRIBE = '呜喵！这里有{TOTAL}个{NAME}，其中有{NUM}个被热得枯萎了{SHOW_ME}{DISTANCE}喵……',
            BARREN_EQUAL = '喵呜～{TOTAL}个{NAME}全都没施肥{SHOW_ME}{DISTANCE}，需要主人去捡臭臭的肥料喵󰀍～',
            BARREN_DESCRIBE = '喵呜～这里有{TOTAL}个{NAME}，其中有{NUM}个还没施肥{SHOW_ME}{DISTANCE}，需要主人去捡臭臭的肥料喵󰀍～',
            SMOLDER_EQUAL = '喵嗷！{TOTAL}个{NAME}全都在冒黑烟了{SHOW_ME}{DISTANCE}，肉垫觉得很危险喵，快拿冰块！',
            SMOLDER_DESCRIBE = '喵嗷！这里有{TOTAL}个{NAME}，其中有{NUM}个冒黑烟了{SHOW_ME}{DISTANCE}，肉垫觉得很危险喵，快拿冰块！',
            GOAT_CHARGED_EQUAL = '喵呜！这里有{TOTAL}个{NAME}，全都带电了{SHOW_ME}{DISTANCE}，快把毛收起来！',
            GOAT_CHARGED_DESCRIBE = '这里有{TOTAL}个{NAME}，其中有{NUM}只是带电状态{SHOW_ME}{DISTANCE}，快把毛收起来！',
            GOAT_NORMAL_EQUAL = '这里有{TOTAL}个{NAME}，全都是普通的羊羊{SHOW_ME}{DISTANCE}喵。',
            GOAT_NORMAL_DESCRIBE = '这里有{TOTAL}个{NAME}，其中有{NUM}只是普通的羊羊{SHOW_ME}{DISTANCE}喵。',
            FISH_SHOAL = '嗅嗅……这里有群{FISH}，共有{NUM}条{FISH}{SHOW_ME}{DISTANCE}喵！',
            FISH_HOLE = '嗅嗅……人家发现了一处{NAME}{SHOW_ME}{DISTANCE}喵󰀍～要开始钓鱼鱼了吗？',
            HOTSPRING_BOMBED_EQUAL = '这里有{TOTAL}个{NAME}，水温全都棒极了{SHOW_ME}{DISTANCE}喵！',
            HOTSPRING_BOMBED_DESCRIBE = '这里有{TOTAL}个{NAME}，其中有{NUM}个水温很棒{SHOW_ME}{DISTANCE}喵！',
            HOTSPRING_GLASSED_EQUAL = '这里有{TOTAL}个{NAME}，全变成石头了没法洗澡{SHOW_ME}{DISTANCE}喵！',
            HOTSPRING_GLASSED_DESCRIBE = '这里有{TOTAL}个{NAME}，其中有{NUM}个变成石头了{SHOW_ME}{DISTANCE}喵！',
            HOTSPRING_EMPTY_EQUAL = '这里有{TOTAL}个{NAME}，全都干干的没有水{SHOW_ME}{DISTANCE}喵！',
            HOTSPRING_EMPTY_DESCRIBE = '这里有{TOTAL}个{NAME}，其中有{NUM}个干干的没有水{SHOW_ME}{DISTANCE}喵！',
            FRUITDRAGON_RIPE_EQUAL = '这里有{TOTAL}个{NAME}，全都变成红彤彤的啦{SHOW_ME}{DISTANCE}喵！',
            FRUITDRAGON_RIPE_DESCRIBE = '这里有{TOTAL}个{NAME}，其中有{NUM}个变成红彤彤的啦{SHOW_ME}{DISTANCE}喵！',
            FRUITDRAGON_UNRIPE_EQUAL = '这里有{TOTAL}个{NAME}，全都是普通的颜色{SHOW_ME}{DISTANCE}喵！',
            FRUITDRAGON_UNRIPE_DESCRIBE = '这里有{TOTAL}个{NAME}，其中有{NUM}个是普通的颜色{SHOW_ME}{DISTANCE}喵！',
            BIRDCAGE_EMPTY = '这里有{TOTAL}个{NAME}，这个里面空空的{SHOW_ME}{DISTANCE}喵。',
            BIRDCAGE_FULL = '这里有{TOTAL}个{NAME}，这个里面有一只小鸟{SHOW_ME}{DISTANCE}喵。',
            BIRDCAGE_SICK = '这里有{TOTAL}个{NAME}，这个里面的鸟生病了{SHOW_ME}{DISTANCE}喵。',
            BIRDCAGE_DEAD = '这里有{TOTAL}个{NAME}，这个里面的鸟已经饿死了……{SHOW_ME}{DISTANCE}喵。',
            ARCHIVE_SWITCH_FULL_EQUAL = '这里有{TOTAL}个{NAME}，全都已经激活了{SHOW_ME}{DISTANCE}喵。',
            ARCHIVE_SWITCH_FULL_DESCRIBE = '这里有{TOTAL}个{NAME}，其中有{NUM}个已经激活了{SHOW_ME}{DISTANCE}喵。',
            ARCHIVE_SWITCH_EMPTY_EQUAL = '这里有{TOTAL}个{NAME}，全都没有激活{SHOW_ME}{DISTANCE}喵。',
            ARCHIVE_SWITCH_EMPTY_DESCRIBE = '这里有{TOTAL}个{NAME}，其中有{NUM}个还没激活{SHOW_ME}{DISTANCE}喵。',
            TOADSTOOL_EMPTY = '雷达扫描完毕喵󰀍～这里有蟾蜍洞穴，目前里面空空的{SHOW_ME}{DISTANCE}，大蛤蟆不在家喵。',
            TOADSTOOL_NORMAL = '喵嗷！锁定目标！这里有蟾蜍洞穴，里面有一只大蛤蟆{SHOW_ME}{DISTANCE}，准备启动猫猫拳喵！',
            TOADSTOOL_DARK = '警报！高能反应喵！这里有蟾蜍洞穴，里面是悲惨毒菌蟾蜍{SHOW_ME}{DISTANCE}，肉垫发抖惹喵！',
            OASISLAKE_EMPTY = '喵呜……水分探测仪显示，这1个{NAME}已经干涸掉啦{SHOW_ME}{DISTANCE}，没法抓鱼鱼了喵……',
            OASISLAKE_FULL = '喵󰀍～探测到充沛的水源！这1个{NAME}满满的都是水{SHOW_ME}{DISTANCE}，可以玩水花啦！',
        },
        MAPPINGS = {
            DEFAULT = {
                WORDS = {
                    SHOW_ME = '（这个有 {SHOW_ME}）',
                    DISTANCE_FAR = '，距离人家大概{DIST}个毛线球（格）的距离喵～',
                    DISTANCE_CLOSE = '，就在人家肉垫旁边喵！',
                    DISTANCE_FAR_WATER = '，在距离人家约{DIST}格的水面上喵，人家才不要下水！',
                    DISTANCE_CLOSE_WATER = '，就在人家旁边的水面上喵～',
                }
            }
        }
    },
    SKIN = {
        FORMATS = {
            DEFAULT = '我有{NUM}个{ITEM}皮肤（共{TOTAL}个），这个叫『{SKIN}』喵！',
            NO_SKIN = '喵嗷！科雷什么时候才给人家出『{ITEM}』的皮肤呀！',
            HAS_NO_SKIN = '呜呜呜……人家连一个『{ITEM}』的漂亮衣服都没有喵！'
        },
        MAPPINGS = {}
    },
    RECIPE = {
        FORMATS = {
            BUFFERED = '人家用尾巴卷着刚做好的{ITEM}准备放置喵󰀍～',
            WILL_MAKE = '材料像毛线球一样到位啦～人家随时可以开爪制作{ITEM}喵！',
            WE_NEED = '人家的耳朵接收到需求～我们需要制造个{ITEM}喵！',
            CAN_SOMEONE = '有人能帮人家做一个{ITEM}喵？人家需要{PROTOTYPE}才能造出它喵！',
        },
        MAPPINGS = {
            DEFAULT = {
                PROTOTYPER = {
                    UNKNOWN_PROTOTYPE = "一个未知的喵星科技",
                    CANTRESEARCH = "一份全是乱码的毛线图纸",
                    NEEDSTECH = "一份亮闪闪的喵力图纸",
                    NEEDSSCIENCEMACHINE = "一台科学猫爬架",
                    NEEDSALCHEMYMACHINE = "一个炼金猫砂盆",
                    NEEDSPRESTIHATITATOR = "一顶灵子魔术帽",
                    NEEDSSHADOWMANIPULATOR = "一台暗影逗猫棒",
                    NEEDSELECOURMALINE_THREE = "激活灵感的充电猫抓板",
                    NEEDSELECOURMALINE_ONE = "充电猫抓板",
                    NEEDSSIVING_ONE = "子圭神木猫抓柱",
                    NEEDSSKILL = "学会新的喵喵翻滚技巧",
                    NEEDSCELESTIAL_THREE = "一个大型的月亮冻干",
                    NEEDSCELESTIAL_ONE = "一个小型的月亮冻干",
                    NEEDSMOON_ALTAR_FULL = "一个完整的月光猫窝",
                    NEEDSMOONORB_LOW = "一个月光球球",
                    NEEDSCHARACTER = "另一只两脚兽的帮忙",
                    NEEDSCRITTERLAB = "在岩石宠物小窝旁",
                    NEEDSTUFF_PROTOTYPE = "找齐所有发光小玩意",
                    NEEDSFISHING = "一个钓鱼鱼的箱子",
                    NEEDSSHADOWFORGING_TWO = "一个暗影猫爪基座",
                    NEEDSTUFF = "找齐所有小鱼干材料",
                    NEEDSCHARACTERSKILL = "制作这个小玩意的专属喵力",
                    NEEDSANCIENTALTAR_HIGH = "找到完整的远古猫爬架",
                    NEEDSFOODPROCESSING = "一个便携猫饭研磨器",
                    NEEDSANCIENTALTAR_LOW = "找到破损的远古猫爬架",
                    NEEDSTURFCRAFTING = "一个踩奶专用夯实器",
                    NEEDSHERMITCRABSHOP_L4 = "寄居蟹老奶奶",
                    NEEDSHERMITCRABSHOP_L3 = "寄居蟹老奶奶",
                    NEEDSHERMITCRABSHOP_L2 = "寄居蟹老奶奶",
                    NEEDSHERMITCRABSHOP_L1 = "寄居蟹老奶奶",
                    NEEDSHERMITCRABHELP_CRAFTING = "寄居蟹老奶奶",
                    NEEDSHERMITCRAB_TEASHOP = "珍珠奶奶的猫薄荷茶店",
                    NEEDSSHELLWEAVER_L1= "一台盐晶洗爪机",
                    NEEDSSHELLWEAVER_L2= "一台升级的盐晶洗爪机",
                    NEEDSHALLOWED_NIGHTS = "在万圣夜的捣蛋时间",
                    NEEDSCARNIVAL_PRIZESHOP = "在良羽鸦的玩具摊位",
                    NEEDSCARNIVAL_HOSTSHOP_PLAZA = "买一棵鸦年华猫抓树",
                    NEEDSCARNIVAL_HOSTSHOP_WANDER = "在鸦年华上找到那个鸟人",
                    NEEDSWINTERSFEASTCOOKING = "用热乎乎的砖砌烤炉",
                    NEEDSWARGSHRINE = "在座狼神龛放上肉肉",
                    NEEDSMADSCIENCE = "疯狂猫咪科学家实验室",
                    NEEDSRABBITKINGSHOP = "找到兔子国王",
                    NEEDSYOTG = "在火鸡跑跑之年",
                    NEEDSYOTR = "在兔人蹦蹦之年",
                    NEEDSYOTV = "在座狼汪汪之年",
                    NEEDSYOTS = "在洞穴蠕虫扭扭之年",
                    NEEDSYOTD = "在龙蝇喷火之年",
                    NEEDSYOTP = "在猪王哼哼之年",
                    NEEDSYOTC = "在胡萝卜鼠窜窜之年",
                    NEEDSYOTB = "在牛牛哞哞之年",
                    NEEDSYOTH = "在发条骑士哒哒之年",
                    NEEDSWINTERS_FEAST = "在冬季盛宴时",
                    NEEDSYOTCATCOON = "在咱们浣猫喵喵之年！",
                    NEEDSBEEFSHRINE = "在牛牛神龛放上供品",
                    NEEDSRABBITSHRINE = "在兔人神龛放上供品",
                    NEEDSCATCOONSHRINE = "在浣猫神龛放上供品喵！",
                    NEEDSKNIGHTSHRINE = "在发条骑士神龛放上供品",
                    NEEDSPERDSHRINE = "在火鸡神龛放上供品",
                    NEEDSWORMSHRINE = "在洞穴蠕虫神龛献上供品",
                    NEEDSCARRATSHRINE = "在胡萝卜鼠神龛献上供品",
                    NEEDSDRAGONSHRINE = "在龙蝇神龛献上供品",
                    NEEDSSHRINE = "在节日神龛献上供品",
                    NEEDSPIGSHRINE = "在猪猪神龛献上肉肉",
                    NEEDSROBOTMODULECRAFT = "扫描滴滴滴的生物",
                    NEEDSBOOKCRAFT = "一个装满故事的书架",
                    NEEDSSEAFARING_STATION = "一个思考猫生智囊团",
                    NEEDSSPIDERCRAFT = "交个多腿蜘蛛好朋友",
                    NEEDSSHADOW_FORGE = "暗影猫爪基座",
                    NEEDSLUNAR_FORGE = "亮闪闪的辉煌铁匠铺",
                    NEEDSCARTOGRAPHYDESK = "画画的制图桌",
                    NEEDSCARPENTRY_STATION = "一个磨爪木工锯马",
                    NEEDSCARPENTRY_STATION_STONE = "带有月光玻璃的磨爪锯马"
                }
            }
        }
    },
    MEDAL_BUFF = {
        FORMATS = {
            DEFAULT = '喵󰀍～人家现在有"{BUFF_NAME}"BUFF加持哦，还能持续{TIME}喵！',
            FOREVER = '喵󰀍～人家现在有"{BUFF_NAME}"BUFF的永久加持喵！',
        },
        MAPPINGS = {}
    },
    ITEM = {
        FORMATS = {
            INV_SLOT = '{PRONOUN}的包包里偷偷藏了{NUM}个{ITEM}{ITEM_NAME}{IN_CONTAINER}{WITH_PERCENT}{POST_STATE}{SHOW_ME}喵󰀍～',
            EQUIP_SLOT = '{PRONOUN}装备了{EQUIP_NUM}个{ITEM}{ITEM_NUM}{ITEM_NAME}{IN_CONTAINER}{WITH_PERCENT}{POST_STATE}{SHOW_ME}喵󰀍～',
            EQUIP_SLOT_POS = '{PRONOUN}的{SLOT_POS}装备了{EQUIP_NUM}个{ITEM}{ITEM_NUM}{ITEM_NAME}{WITH_PERCENT}{POST_STATE}{SHOW_ME}喵󰀍～',
            EQUIP_SLOT_EMPTY = '{PRONOUN}的{SLOT_POS}光秃秃的，没有装备任何东西喵󰀍～'
        },
        MAPPINGS = {
            DEFAULT = {
                PRONOUN = { I = '人家', WE = '喵喵小队' },
                HEAT_ROCK = {
                    COLD = '，冷冰冰的',
                    COOL = '，清凉凉的',
                    NORMAL = '，常温的',
                    WARM = '，热乎乎的',
                    HOT = '，滚烫烫的'
                },
                RECHARGE = {
                    CHARGING = '，还差{TIME}就能发光喵',
                    FULL = '，尾巴能量已就绪喵'
                },
                PERCENT_TYPE = { DURABILITY = '的耐久度', FRESHNESS = '新鲜小鱼干味' },
                TIME = { MINUTES = '分', SECONDS = '秒' },
                WORDS = {
                    THIS_ONE = '其中这个',
                    ITEM_NAME = ' (有{NUM}个叫{NAME})',
                    ITEM_NUM = ' (一共屯了{NUM}个)',
                    IN_CONTAINER = ' 藏在这个{NAME}里',
                    WITH_PERCENT = '，{THIS_ONE}散发着{PERCENT}{TYPE}喵',
                    SUSPICIOUS_MARBLE = '，喵呜这是{NAME}',
                    SHOW_ME = '（这个有 {SHOW_ME}）',

                    SLOT_HEAD = '小脑袋上',
                    SLOT_HANDS = '肉垫里',
                    SLOT_BODY = '绒毛上',
                    SLOT_BACK = '背背上',
                    SLOT_NECK = '脖颈上',
                    SLOT_BELLY = '小肚肚上',
                    SLOT_MEDAL = '胸前勋章处',
                }
            }
        }
    },
    INGREDIENT = {
        FORMATS = {
            NEED_MULTIPLE = "我们需要{INGREDIENT}才能把{RECIPE}弄出来喵{AND_PROTOTYPE}！",
            HAVE_ALL = "用肉垫拍拍{INGREDIENT}～马上就能变出{RECIPE}喵{BUT_PROTOTYPE}！",
        },
        MAPPINGS = {
            DEFAULT = {
                WORDS = {
                    ITEM_AMOUNT_FORMAT = "{NUM}个{ITEM}",
                    COMMA = "，",
                    ALL_MATERIALS = "所有发光材料",
                    AND_PROTOTYPE = '，而且需要{PROTOTYPE}的认证喵',
                    BUT_PROTOTYPE = '，不过现在就差{PROTOTYPE}的认证啦喵'
                }
            }
        }
    },
    CONSTRUCTION = {
        FORMATS = {
            NEED = "我们需要{INGREDIENT}才能把{RECIPE}建好喵󰀍～",
            HAVE = "所有毛线球都备齐啦～{RECIPE}随时可以拔地而起喵！",
            HAVE_ITEM = "人家的小爪爪已经准备好{INGREDIENT}来建{RECIPE}了喵󰀍～", 
        },
        MAPPINGS = {
            DEFAULT = {
                WORDS = { AMOUNT_FMT = "{NUM}个{ITEM}" }
            }
        }
    },
    TRADE = {
        FORMATS = {
            NEED = "喵呜……想要和{RECIPE}换东西，人家的小兜兜里还缺{INGREDIENT}喵󰀍～",
            HAVE = "有足够的{INGREDIENT}和{RECIPE}交易喵！快去快去～",
            HAVE_ITEM = "人家有足够的{INGREDIENT}可以和{RECIPE}换小礼物了喵！", 
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
                    FULL = '高于75%……沃比的小肚肚圆滚滚的喵󰀍～',
                    HIGH = '55%……沃比还能背着主人跑好远喵！',
                    MID = '35%……沃比的肚子在咕咕叫啦喵󰀍～',
                    LOW = '15%……沃比需要怪物肉肉紧急补给喵！',
                    EMPTY = '低于15%……沃比饿趴下了喵󰀍～快喂它小鱼干！',
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
                    FULL = '高于75%……肚子圆滚滚的喵󰀍～主人投喂的小鱼干堆成山啦！',
                    HIGH = '55%……刚吃过罐头～但人家还能塞下零食喵󰀍～',
                    MID = '35%……肚皮贴后背啦喵󰀍～求主人投喂鱼条！',
                    LOW = '15%……爪爪发抖喵󰀍～急需小鱼干续命！',
                    EMPTY = '低于15%……将启动喵星传送～马上饿得扑街了喵！',
                },
                SYMBOL = { EMOJI = 'hunger', TEXT = '小肚肚' }
            },
            WILSON = {
                MESSAGE = {
                    FULL = '人家的肚子圆滚滚的喵󰀍～被主人的爱心料理填满啦！',
                    HIGH = '肉垫感应到能量充足󰀍～暂时不需要投食喵󰀍～',
                    MID = '小肚子开始打鼓了喵󰀍～想来块香煎秋刀鱼嘛？',
                    LOW = '饿到尾巴都竖不直了喵󰀍～求主人紧急空运小鱼干！',
                    EMPTY = '视线开始模糊惹喵󰀍～连毛线球都看成鱼罐头了……',
                }
            },
            WILLOW = {
                MESSAGE = {
                    FULL = '再吃就要变成圆滚滚的毛球啦喵󰀍～',
                    HIGH = '尾巴火焰燃烧稳定～暂时不需要燃料喵！',
                    MID = '生命之火的火苗变小了～需要小鱼干助燃剂喵󰀍～',
                    LOW = '饿到尾巴火焰都要熄灭惹～求投喂求投喂！',
                    EMPTY = '骨头都要饿得打结啦～伯尼快帮人家找罐头喵！',
                }
            },
            WOLFGANG = {
                MESSAGE = {
                    FULL = '吃饱饱的喵󰀍～肉垫力量能举起整个主人！',
                    HIGH = '储备能量足够表演胸口碎大石喵！',
                    MID = '需要补充蛋白质～来三文鱼刺身喵！',
                    LOW = '饿到肌肉都要融化惹～求投喂巨型猫粮！',
                    EMPTY = '连尾巴都举不动了喵󰀍～急需能量注射！',
                }
            },
            WENDY = {
                MESSAGE = {
                    FULL = '和姐姐大人的绒毛一样完美无瑕喵󰀍～',
                    HIGH = '姐姐大人～要不要分你一半小鱼干喵？',
                    MID = '这个猫罐头是独享～还是其他猫姐妹都有呀？',
                    LOW = '饿着肚子看夕阳～旧愁未解又添新饿喵……',
                    EMPTY = '姐姐……人家的肉垫快抬不起来了喵……',
                }
            },
            WX78 = {
                MESSAGE = {
                    FULL = '能量小鱼干储量：MAX喵󰀍～尾巴涡轮全速运转中！',
                    HIGH = '燃料计量器显示正常喵󰀍～还能表演火箭跳跃喵！',
                    MID = '核心能量需要补充喵󰀍～建议投喂充电小鱼干～',
                    LOW = '警报！能量槽极低喵󰀍～即将启动省电撒娇模式～',
                    EMPTY = '进入休眠状态……最后电量要留给主人的摸摸……',
                }
            },
            WICKERBOTTOM = {
                MESSAGE = {
                    FULL = '知识已经填满肚子啦～暂时不需要投喂喵󰀍～',
                    HIGH = '魔法书库能量充足～能继续研究猫薄荷星图喵！',
                    MID = '学术能量下降～需要补充智慧小鱼干喵󰀍～',
                    LOW = '饿到看不清古喵文字啦～求主人投喂应急！',
                    EMPTY = '即将启动纸箱避难协议……遗产是魔法书库的钥匙喵……',
                }
            },
            WOODIE = {
                MESSAGE = {
                    FULL = '树汁能量充满～能砍倒十棵猫抓树喵！',
                    HIGH = '肉垫充满力量～继续挑战巨无霸猫抓柱喵！',
                    MID = '爪爪有点钝啦～需要小鱼干磨爪服务喵！',
                    LOW = '肚子饿到能啃木头啦～开饭铃在哪里喵？',
                    EMPTY = '饿到年轮眼睛都变成蚊香圈啦喵！',
                }
            },
            WES = {
                MESSAGE = {
                    FULL = '(用尾巴拍拍圆滚滚的小肚子)喵呜～',
                    HIGH = '(肉垫在肚皮上弹钢琴)叮咚～饱足感满分喵󰀍～',
                    MID = '(耳朵耷拉成飞机耳)喵嗷～投食雷达有反应！',
                    LOW = '(瞳孔放大紧抓主人衣角)ฅ(๑*д*๑)ฅ',
                    EMPTY = '(瘫成猫饼用爪爪比划小鱼干形状)喵……喵……',
                }
            },
            WAXWELL = {
                MESSAGE = {
                    FULL = '魔法胃袋被主人的盛宴填满喵󰀍～尾巴卷成爱心啦！',
                    HIGH = '优雅的淑女猫需要保持身材～暂时不需要下午茶喵󰀍～',
                    MID = '绅士的肚子开始打鼓～想来份皇家猫罐头喵？',
                    LOW = '饿到魔术帽都变形成餐盘啦～求主人变出小鱼干！',
                    EMPTY = '黑暗料理军团来袭！人家的自由要被饿肚子夺走惹喵！',
                }
            },
            WEBBER = {
                MESSAGE = {
                    FULL = '毛毛和球球的小肚子都圆滚滚的喵󰀍～完美的投喂！',
                    HIGH = '八条腿的我们还能再塞下小布丁喵！',
                    MID = '蜘蛛感应到午餐时间～要排排坐等投喂喵󰀍～',
                    LOW = '饿到蛛丝都织不出爱心啦～求妈妈味的小鱼干！',
                    EMPTY = '两个胃袋同时哀鸣～变成纸片猫猫惹喵……',
                }
            },
            WATHGRITHR = {
                MESSAGE = {
                    FULL = '战矛都吃饱饱的喵󰀍～现在能打十个怪喵！',
                    HIGH = '呼吸间都是小鱼干香气～战斗欲望MAX喵！',
                    MID = '闻到魔法猫罐头的香气啦～尾巴自己动起来了喵！',
                    LOW = '饿到能吞下整个猫粮仓库喵󰀍～盛宴在哪里呀？',
                    EMPTY = '就算饿成纸片猫～也绝对不吃胡萝卜喵！',
                }
            },
            WINONA = {
                MESSAGE = {
                    FULL = '喵力引擎补充完毕～机械小鱼干能量满格喵！',
                    HIGH = '扳手尾巴还能再拧开十个罐头喵！',
                    MID = '需要给齿轮胃补充润滑猫条啦～',
                    LOW = '饿到螺丝刀耳朵都耷拉了～食堂在哪喵？',
                    EMPTY = '即将启动罢工模式～除非有金枪鱼补给！',
                }
            },
            WARLY = {
                MESSAGE = {
                    FULL = '秘制猫饭太好吃惹喵󰀍～幸福到快晕倒！',
                    HIGH = '嗝～连胡须都沾着奶油香气喵󰀍～',
                    MID = '是时候研发沙漠风味冻干啦～',
                    LOW = '错过饭点的厨师猫要饿哭惹喵󰀍～',
                    EMPTY = '饿到看见锅铲在煎太阳蛋啦……(幻觉)',
                }
            },
            WORMWOOD = {
                MESSAGE = {
                    FULL = '光合作用满格喵󰀍～叶子都幸福地舒展开啦！',
                    HIGH = '叶绿素引擎全速运转中～能进行光合午睡喵󰀍～',
                    MID = '土壤养分探测器显示需要施肥喵󰀍～',
                    LOW = '急需阳光浴和主人牌营养液补给喵！',
                    EMPTY = '叶片蔫成抹布啦～快用治愈摸摸复活喵！',
                }
            },
            WURT = {
                MESSAGE = {
                    FULL = '咕噜噜～人家的鱼鳍肚皮装不下啦喵󰀍～',
                    HIGH = '鳞片探测器显示还能塞下小虾米喵！',
                    MID = '鱼尾摇摆频率降低～需要投喂恢复活力！',
                    LOW = '饿到腮帮子都瘪下去惹～求喂食FLORP喵！',
                    EMPTY = '眼睛变成漩涡状啦～看见海底星空喵（幻觉）',
                }
            },
            WORTOX = {
                MESSAGE = {
                    FULL = '恶魔尾巴撑成气球啦～暂时不能恶作剧喵Hyuyu！',
                    HIGH = '灵魂甜点吃太多～要绕着月亮飞三圈消化喵！',
                    MID = '需要补充灵魂小鱼干能量喵󰀍～恶作剧蓄力中！',
                    LOW = '灵魂饥饿警报！看见主人的影子都想咬喵！',
                    EMPTY = '瞳孔变成饿狼模式～要黑化扑倒零食柜喵！',
                }
            }
        }
    },
    BLOOMNESS = {
        FORMATS = { DEFAULT = '({SYMBOL} Lv：{LEVEL} | {CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    STAGE_0 = '尾巴需要肥料喵󰀍～',
                    STAGE_1 = '小花花要开了喵！',
                    STAGE_2 = '花苞正在努力长大喵！',
                    STAGE_3 = '当当！花花完美盛开啦喵󰀍！',
                    STAGE_4 = '花瓣变黄了喵……',
                    STAGE_5 = '花花要谢了喵……',
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
            LUCK = '喵󰀍～人家现在的幸运值是：{CURRENT}喔！' 
        },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '喵嗷！雷达警报！坎普斯马上要来偷东西了喵！',
                    HIGH = '尾巴尖尖感觉到坎普斯危险的注视喵……',
                    MID = '嗅嗅……人家干了一点小坏事喵。',
                    LOW = '人家还是个善良的乖猫猫喵。',
                    EMPTY = '纯洁得像一碗白开水喵～是最守法的好市民！',
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
                    FULL = '高于75%……胡须感应器全开～脑容量巅峰喵󰀍～',
                    HIGH = '55%……精神很好，还能给主人表演后空翻喵！',
                    MID = '35%……毛线球打结了喵󰀍～感觉有点焦虑！',
                    LOW = '15%……尾巴有自己的想法啦～这里有点疯狂喵！',
                    EMPTY = '低于15%……尾巴炸成蒲公英啦～暗影恶魔在追人家喵！',
                },
                SYMBOL = { EMOJI = 'sanity', TEXT = '脑阔' }
            },
            WILSON = {
                MESSAGE = {
                    FULL = '胡须导航系统运转正常喵󰀍～理智满分！',
                    HIGH = '耳朵偶尔听到次元波动～但人家会好起来的喵！',
                    MID = '脑袋像被猫薄荷轰炸过一样～头好痛喵󰀍～',
                    LOW = '看见影子在跳踢踏舞喵󰀍～那是什么怪物？！',
                    EMPTY = '救命喵！黑暗料理军团要把人家吃掉啦！',
                }
            },
            WILLOW = {
                MESSAGE = {
                    FULL = '精神火焰旺盛到能烤棉花糖啦喵󰀍～',
                    HIGH = '刚才伯尼的耳朵是不是动了一下喵？不用介意～',
                    MID = '寒意从尾巴尖蔓延上来～感觉好冷喵！',
                    LOW = '伯尼，为什么人家觉得如此寒冷喵！？',
                    EMPTY = '伯尼快护驾喵󰀍～有可怕的东西要咬人家的尾巴！',
                }
            },
            WOLFGANG = {
                MESSAGE = {
                    FULL = '脑内小剧场正在播放，沃尔夫冈的头感觉良好喵󰀍～',
                    HIGH = '听见云朵在讲冷笑话～脑袋感觉很有趣喵！',
                    MID = '脑袋像被猫抓板刮过一样，好疼喵󰀍～',
                    LOW = '看见石头在跳芭蕾喵󰀍～看到了可怕的怪物！',
                    EMPTY = '救命！到处都是可怕的怪物喵！',
                }
            },
            WENDY = {
                MESSAGE = {
                    FULL = '胡须像兰叶般优雅～思维晶莹剔透喵󰀍～',
                    HIGH = '思维渐渐变得阴郁了喵……',
                    MID = '心思细腻到能数清猫砂～极度兴奋喵󰀍～',
                    LOW = '阿比盖尔快看！黑影恶魔要让人家加入你喵！',
                    EMPTY = '带人家去姐姐大人那里吧，黑暗的生物喵……',
                }
            },
            WX78 = {
                MESSAGE = {
                    FULL = '喵脑CPU状态：全面运转喵󰀍～能解所有谜题！',
                    HIGH = '逻辑CPU状态：功能正常喵󰀍～规划舔毛路线中！',
                    MID = '系统CPU状态：破损的喵󰀍～需要冰镇散热！',
                    LOW = '检测到异常数据流～故障迫近喵！',
                    EMPTY = '核心CPU状态：多重故障检测！绒毛乱码惹喵！',
                }
            },
            WICKERBOTTOM = {
                MESSAGE = {
                    FULL = '胡须感应精确～没有什么行为是非理智的喵！',
                    HIGH = '次元波动在可控范围内～有一点令人头痛喵󰀍～',
                    MID = '古喵语看太多～偏头痛难以忍受喵󰀍～',
                    LOW = '看见书页墨水在跳舞～分不清虚构现实了喵！',
                    EMPTY = '禁忌知识溢出！帮帮人家逃离可憎的敌人喵！',
                }
            },
            WOODIE = {
                MESSAGE = {
                    FULL = '精神好到犹如一把小提琴曲喵󰀍～',
                    HIGH = '精力充沛，可以来杯猫薄荷咖啡喵！',
                    MID = '树洞午觉时间到～需要一个午睡喵󰀍～',
                    LOW = '连尾巴都懒得摇晃～退后噩梦东西喵！',
                    EMPTY = '所有恐惧和伤害都是真实的～救命喵！',
                }
            },
            WES = {
                MESSAGE = {
                    FULL = '(行屈膝礼时尾巴划出爱心轨迹)喵󰀍～',
                    HIGH = '(用胡须比出OK的翘起拇指)ฅ^•ﻌ•^ฅ',
                    MID = '(用肉垫按摩太阳穴)呼噜……头晕喵……',
                    LOW = '(尾巴炸毛四处扫视)喵嗷！疯狂的家伙！',
                    EMPTY = '(摇篮一样的头来回摇摆)喵呜呜……救命……',
                }
            },
            WAXWELL = {
                MESSAGE = {
                    FULL = '礼帽角度完美～衣冠楚楚的可以喵！',
                    HIGH = '胡须感应到波动～智慧似乎在摇摆喵󰀍～',
                    MID = '脑袋像被袭击过～Ugh，头好痛喵！',
                    LOW = '看见影子在跳舞～人家需要明确头脑喵！',
                    EMPTY = '救命！这些暗影触手是真正的野兽喵！',
                }
            },
            WEBBER = {
                MESSAGE = {
                    FULL = '八只眼睛看到的都是美好世界，感觉健康喵󰀍～',
                    HIGH = '毛毛和球球说，小睡一会可以回复一下喵！',
                    MID = '十六只耳朵听到奇怪声音～头好痛喵！',
                    LOW = '上次午睡是什么时候喵？！记忆乱了……',
                    EMPTY = '才不怕你们这些可怕的怪物！(炸毛防御喵)',
                }
            },
            WATHGRITHR = {
                MESSAGE = {
                    FULL = '尾巴扫过的地方毫无凡人恐惧喵！',
                    HIGH = '聚光灯打好啦～战场上感觉更好喵！',
                    MID = '迷离的思绪～喵爪审判官要晕了喵！',
                    LOW = '阴影穿过战矛生锈惹～人家要招架不住了喵！',
                    EMPTY = '退后，黑暗怪兽！战神猫娘要发威了喵！',
                }
            },
            WINONA = {
                MESSAGE = {
                    FULL = '检测到零件运转完美～永远保持理智喵󰀍～',
                    HIGH = '头巾以下全都还好喵󰀍～',
                    MID = '核心螺丝松动了～想法有点乱喵！',
                    LOW = '心碎了，人家该拿扳手修修脑袋喵！',
                    EMPTY = '系统崩溃！这是一场真实的噩梦喵！',
                }
            },
            WARLY = {
                MESSAGE = {
                    FULL = '烹饪的香味让人家神智清醒喵󰀍～',
                    HIGH = '闻到迷迭香～觉得有点头晕喵～',
                    MID = '菜谱文字在跳舞～脑筋不能转弯了喵！',
                    LOW = '听见窃窃私语～救命啊喵！',
                    EMPTY = '锅碗成精啦～再也受不了这种精神错乱喵！',
                }
            },
            WORMWOOD = {
                MESSAGE = {
                    FULL = '花苞绽放～感觉很棒喵󰀍～',
                    HIGH = '头感觉很好，听唱片机喵～',
                    MID = '头痛，但叶子感觉还好喵！',
                    LOW = '恐怖的东西在看着人家喵！',
                    EMPTY = '恐怖的影子活过来了在伤害人家喵！',
                }
            },
            WURT = {
                MESSAGE = {
                    FULL = '泡泡歌唱团好开心喵󰀍～！',
                    HIGH = '精神很好，小花喵！',
                    MID = '格鲁，人家的头部受伤了喵。',
                    LOW = '可怕的黑影要游过来了喵！',
                    EMPTY = '格鲁，海底噩梦怪物要吃猫了喵！！',
                }
            },
            WORTOX = {
                MESSAGE = {
                    FULL = '头脑清醒，欢乐的恶作剧时光来了喵Hyuyu！',
                    HIGH = '能吸点小鱼干灵魂保持清醒吗喵？',
                    MID = '刚跳太快，现在脑袋有点痛喵……',
                    LOW = '好羡慕这些影子的恶作剧戏法喵！',
                    EMPTY = '思想处于纯粹疯狂的新境界啦喵Hyuyu！',
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
                    FULL = '100%……绒毛闪闪发亮喵󰀍～血槽满了！',
                    HIGH = '75%……爪垫擦伤了一点点～挂了些彩喵！',
                    MID = '50%……缠着绷带也要守护主人喵󰀍～严重挂彩！',
                    LOW = '25%……一瘸一拐的喵󰀍～血肉模糊了！',
                    EMPTY = '低于25%……猫命循环最后一条！看好财产喵！',
                },
                SYMBOL = { EMOJI = 'heart', TEXT = '猫命' },
            },
            WILSON = {
                MESSAGE = {
                    FULL = '绒毛闪亮亮，健康的如一把小提琴喵󰀍！',
                    HIGH = '爪垫擦伤，但人家可以继续行动喵。',
                    MID = '绷带歪歪扭扭～人家需要注意治疗喵。',
                    LOW = '血珠珠渗出来惹～人家失去了很多血喵……',
                    EMPTY = '九命快用完啦～人家不能走完路程了喵……',
                }
            },
            WILLOW = {
                MESSAGE = {
                    FULL = '完美的绒毛战袍就应该没有伤痕喵！',
                    HIGH = '有擦伤～人家该用小火苗点燃它们消毒喵！',
                    MID = '伤口让尾巴火焰变小，人家需要个医生喵……',
                    LOW = '生命之火像风中残烛～人家可能会熄灭喵……',
                    EMPTY = '最后的小火苗……几乎要熄灭了喵……',
                }
            },
            WOLFGANG = {
                MESSAGE = {
                    FULL = '肌肉绒毛完美，现在不需要修理喵！',
                    HIGH = '有擦伤，需要点小修理喵。',
                    MID = '伤口在抗议啦～沃尔夫冈受伤了喵。',
                    LOW = '血珠珠粘住绒毛了，需要很多绷带喵！',
                    EMPTY = '进入节能模式……或许要死了喵……',
                }
            },
            WENDY = {
                MESSAGE = {
                    FULL = '痊愈了喵，但人家相信很快又会受伤的喵。',
                    HIGH = '感到一点疼痛，但是不多喵。',
                    MID = '生存带来痛苦，但人家不习惯这么多喵。',
                    LOW = '流了很多血……放弃会很容易喵……',
                    EMPTY = '姐姐……人家很快将与阿比盖尔团聚喵……',
                }
            },
            WX78 = {
                MESSAGE = {
                    FULL = '底盘状态：完美反光理想状况喵',
                    HIGH = '底盘状态：表层刮痕裂纹检测喵',
                    MID = '底盘状态：电线外露中度损坏喵',
                    LOW = '底盘状态：完全性损坏警告喵',
                    EMPTY = '底盘状态：只读模式无功能喵',
                }
            },
            WICKERBOTTOM = {
                MESSAGE = {
                    FULL = '魔法长袍零损伤～健康可以预计年龄喵！',
                    HIGH = '受些羽毛笔划痕擦伤，无关紧要喵。',
                    MID = '知识反噬受伤，医疗需要装配喵。',
                    LOW = '不治疗的话，这将是学者的结局喵。',
                    EMPTY = '最后一丝魔力……人家需要立刻就医喵！',
                }
            },
            WOODIE = {
                MESSAGE = {
                    FULL = '喵哈哈～合适的犹如一个哨子喵！',
                    HIGH = '大难不死，必有后福喵继续冒险！',
                    MID = '用松果绷带包扎，需要物品变得健康喵。',
                    LOW = '爪子裂开了，这是痛苦真正的开始喵……',
                    EMPTY = '让我永眠……在这棵猫抓树下喵……',
                }
            },
            WES = {
                MESSAGE = {
                    FULL = '(尾巴比出爱心)喵󰀍～手结成心！',
                    HIGH = '(展示小爪爪)喵呜～触摸脉搏竖大拇指！',
                    MID = '(玩绷带)喵呀～手在手臂示意包扎！',
                    LOW = '(摇晃尾巴SOS)喵……摇晃手臂……',
                    EMPTY = '(抛出小纸团倒下)遗书……大幅摇摆摔倒喵……',
                }
            },
            WAXWELL = {
                MESSAGE = {
                    FULL = '燕尾服零损伤～人家完全安然无恙喵。',
                    HIGH = '它只是一个袖口擦伤喵。',
                    MID = '魔法斗篷裂口了，需要打个补丁喵。',
                    LOW = '手套染红了，这还没到天鹅之歌喵。',
                    EMPTY = '最后的谢幕礼……人家没有逃避而死在这喵！',
                }
            },
            WEBBER = {
                MESSAGE = {
                    FULL = '蛛丝铠甲闪闪发亮～连划痕也没有喵！',
                    HIGH = '爪爪擦伤，我们需要一个创可贴喵。',
                    MID = '缠满绷带～我们需要再贴一个创可贴喵……',
                    LOW = '医疗包用完啦，我们身体剧痛喵……',
                    EMPTY = '毛毛球球……我们还不想死喵……',
                }
            },
            WATHGRITHR = {
                MESSAGE = {
                    FULL = '无敌猫娘的皮肤是无懈可击的喵！',
                    HIGH = '它只是一个肉垫轻伤喵！',
                    MID = '人家受伤了，但还能用猫猫拳战斗喵。',
                    LOW = '战矛生锈，没有援助很快要去瓦尔哈拉喵……',
                    EMPTY = '最后的谢幕姿势……传奇人生结束了喵……',
                }
            },
            WINONA = {
                MESSAGE = {
                    FULL = '工业装甲满格～健康的如汗血宝马喵！',
                    HIGH = '擦伤画成小花～嗯人家来解决它喵。',
                    MID = '漏油啦～人家仍然不能放弃喵。',
                    LOW = '关节悲鸣～可以领工人退休金吗喵？',
                    EMPTY = '最后的电力比心……我想轮班结束了喵……',
                }
            },
            WARLY = {
                MESSAGE = {
                    FULL = '料理猫娘非常健康喵。',
                    HIGH = '切洋葱切到手了，人家很糟糕喵。',
                    MID = '烫伤了……人家流血了喵。',
                    LOW = '虚弱拿不动锅～可以用些援助喵！',
                    EMPTY = '最后的便当……这就是结局了挚友们喵……',
                }
            },
            WORMWOOD = {
                MESSAGE = {
                    FULL = '枝头开花～沃姆伍德没有受伤喵。',
                    HIGH = '树皮蹭掉一点，但还好喵。',
                    MID = '年轮渗液，感到虚弱喵。',
                    LOW = '吸引坏虫子了，疼痛严重喵。',
                    EMPTY = '最后一片叶子……救救我好朋友喵！',
                }
            },
            WURT = {
                MESSAGE = {
                    FULL = '铠甲探照灯～我很健康小花喵！',
                    HIGH = '鱼鳍划伤一丢丢，感觉很好喵！',
                    MID = '需要珍珠粉，鳞片掉了一些喵……',
                    LOW = '呼吸泡泡快没了，呜咽疼得厉害喵……',
                    EMPTY = '最后的气泡戒指……救命啊喵！！！',
                }
            },
            WORTOX = {
                MESSAGE = {
                    FULL = '肉垫充满力量，状态绝佳尽情捣蛋喵！',
                    HIGH = '只是纸划伤，一个灵魂就能修复喵！',
                    MID = '需要灵魂小鱼干抚平伤口喵Hyuyu！',
                    LOW = '魔力流失，人家的灵魂变得脆弱喵……',
                    EMPTY = '最后的爱心烟花，灵魂不再属于我喵……',
                }
            }
        }
    },
    THIRST = {
        FORMATS = { DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '舔吧舔吧～小水壶喝得饱饱的喵󰀍～',
                    HIGH = '还不渴喵～嘴巴湿润润的！',
                    MID = '肉垫干干的，需要甜甜的泉水补水喵󰀍～',
                    LOW = '我要渴死了，救命水水喵！',
                    EMPTY = '身体严重脱水变成小鱼干惹喵！',
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
                    FULL = '高于75%……绒毛湿成海带啦完全湿身喵！',
                    HIGH = '55%……尾巴吸满水湿透了！把人家装进包包喵！',
                    MID = '35%……胡须挂着水珠，我很湿！背包也湿了喵！',
                    LOW = '15%……只有尾巴尖沾水，湿了一小块不足为惧喵！',
                    EMPTY = '肉垫干干爽爽的，只有一点点潮湿喵。',
                },
                SYMBOL = {
                    TEXT = '潮湿度'
                },
            },

            WILSON = {
                MESSAGE = {
                    FULL = '彻底变成水煮猫猫啦～达到饱和点喵！',
                    HIGH = '水快滚出去喵！',
                    MID = '绒毛结成缕，衣服几乎渗透喵。',
                    LOW = '胡须挂着露珠，Oh，H2O喵。',
                    EMPTY = '干爽得能当镜子，比较干燥喵。',
                }
            },
            WILLOW = {
                MESSAGE = {
                    FULL = 'Ugh，这雨水是最坏的喵！',
                    HIGH = '全身湿透，人家讨厌这水喵！',
                    MID = '雨水成河，这雨太多了喵。',
                    LOW = 'Uh oh，如果雨持续下尾巴要熄灭了喵……',
                    EMPTY = '干燥到能擦火星，没雨能灭火喵。',
                }
            },
            WOLFGANG = {
                MESSAGE = {
                    FULL = '变成水球，沃尔夫冈可能是水做的喵！',
                    HIGH = '就像坐在池塘里一样喵……',
                    MID = '洗澡时间没到，沃尔夫冈不喜欢洗澡喵。',
                    LOW = '雨水时代来啦喵。',
                    EMPTY = '沃尔夫冈是干燥的喵。',
                }
            },
            WENDY = {
                MESSAGE = {
                    FULL = '满是雨水和眼泪的末世喵。',
                    HIGH = '长久的湿润和悲伤的落汤猫喵。',
                    MID = '和姐姐大人一样湿软又悲伤喵。',
                    LOW = '或许这些水分能填补心灵虚空喵。',
                    EMPTY = '皮肤和心灵一样干燥喵。',
                }
            },
            WX78 = {
                MESSAGE = {
                    FULL = '受潮状况：短路到达临界值喵',
                    HIGH = '受潮状况：天线进水接近临界喵',
                    MID = '受潮状况：长蘑菇无法接受的喵',
                    LOW = '受潮状况：露珠可容许的喵',
                    EMPTY = '受潮状况：干燥完美合意的喵',
                }
            },
            WICKERBOTTOM = {
                MESSAGE = {
                    FULL = '保护罩失效！完全绝对浸湿喵！',
                    HIGH = '我是湿的，湿的，湿的！重要说三遍喵！',
                    MID = '长袍吸水，想知道我的最高承受力喵。',
                    LOW = '书页卷边了，水膜开始形成喵。',
                    EMPTY = '羊皮纸完美，水分足够缺乏喵。',
                }
            },
            WOODIE = {
                MESSAGE = {
                    FULL = '这鬼天气导致人家不能砍树喵！',
                    HIGH = '格子披风吸水，不再保暖了喵。',
                    MID = '储水罐装满，获得了相当水分喵。',
                    LOW = '格子花纹很温暖，也很潮湿喵。',
                    EMPTY = '对我几乎不受影响的喵。',
                }
            },
            WES = {
                MESSAGE = {
                    FULL = '*疯狂地像蝶泳一样向上游泳喵*',
                    HIGH = '*把耳朵当螺旋桨向上游泳喵*',
                    MID = '*歪头悲惨地看向乌云天空喵*',
                    LOW = '*保护头部把尾巴当伞武装喵*',
                    EMPTY = '*微笑，拿着无形的空气伞喵*',
                }
            },
            WAXWELL = {
                MESSAGE = {
                    FULL = '湿润的好比落在水里的黑猫本身喵。',
                    HIGH = '燕尾服吸水，不认为我会再干燥喵。',
                    MID = '这水会毁了我的定制西装喵。',
                    LOW = '领结的潮湿使我变得不整洁喵。',
                    EMPTY = '绒毛干燥而整洁的喵。',
                }
            },
            WEBBER = {
                MESSAGE = {
                    FULL = '哇哈，八条腿都在划水，湿透了喵！',
                    HIGH = '绒毛变成海胆，被浸泡了喵！',
                    MID = '吊床变水床，我们很湿喵！',
                    LOW = '我们湿润地不讨猫喜欢喵。',
                    EMPTY = '我们在沙坑玩耍干燥得很喵。',
                }
            },
            WATHGRITHR = {
                MESSAGE = {
                    FULL = '绒毛拖把，我完全湿透了喵！',
                    HIGH = '一个猫娘战士雨天无法战斗喵！',
                    MID = '我的铁爪子护甲会生锈喵！',
                    LOW = '人家不需要洗澡喵。',
                    EMPTY = '干燥够了继续水上漂战斗喵！',
                }
            },
            WINONA = {
                MESSAGE = {
                    FULL = '工具箱生锈，不能在这种湿度工作喵！',
                    HIGH = '工作服变成潜水服吸收水分喵！',
                    MID = '太空步滑倒，该放湿地板标志喵。',
                    LOW = '工作补充水分总是好的喵。',
                    EMPTY = '摩擦起电这里没有什么喵。',
                }
            },
            WARLY = {
                MESSAGE = {
                    FULL = '变成海鲜浓汤，感觉鱼在衬衫游泳喵。',
                    HIGH = '小金鱼游出，水会毁了完美的菜喵！',
                    MID = '当雨刷，在感冒前要把衣服烘干喵。',
                    LOW = '现在不是厨师猫洗澡的时间喵。',
                    EMPTY = '只有几滴在围裙上没有坏处喵。',
                }
            },
            WORMWOOD = {
                MESSAGE = {
                    FULL = '储水系统满载，真的真的湿了喵！',
                    HIGH = '叶子淋浴，真的湿了喵！',
                    MID = '夜露收集，感觉有点湿喵。',
                    LOW = '下雨发芽啦！哦吼喵！',
                    EMPTY = '树皮感到干燥喵。',
                }
            },
            WURT = {
                MESSAGE = {
                    FULL = '跳水上芭蕾，水花溅呀溅喵！！',
                    HIGH = '泡澡舒服，鳞片很舒服喵！',
                    MID = '鱼鳍舒展，美人鱼喜欢水，小花喵！',
                    LOW = '啊哈……有点水更好，小花喵！',
                    EMPTY = '尾巴变鱼干，太干燥了，格鲁喵。',
                }
            },
            WORTOX = {
                MESSAGE = {
                    FULL = '翅膀变降落伞，完全湿透了喵！',
                    HIGH = '我是街上最潮湿的恶魔喵Hyuyu！',
                    MID = '尾巴好重，这有湿漉漉恶魔喵！',
                    LOW = '世界正赐予我一场恶作剧淋浴喵！',
                    EMPTY = '保持干燥，摩擦闪电留意天气喵！',
                }
            }
        }
    },
}