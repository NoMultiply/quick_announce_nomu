GLOBAL.STRINGS.NOMU_QA.TITLE_TEXT_TSUNDERE_SCHEME = '傲娇方案'

GLOBAL.STRINGS.TSUNDERE_NOMU_QA = {
    SEASON = {
        FORMATS = { DEFAULT = '听好了笨蛋，{SEASON}只剩下{DAYS_LEFT}天了。给、给我好好准备，别到时候哭着求我！' },
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
            START_RAIN = '喂！{WORLD}气温{TEMPERATURE}，{WEATHER}来了：第{DAYS}天（{MINUTES}分{SECONDS}秒）。自己记得撑伞，我才不管你！',
            NO_RAIN = '哼，{WORLD}气温{TEMPERATURE}，{WEATHER}暂时还没来。稍微放松一下也可以……就一下！',
            STOP_RAIN = '终于放晴了！{WORLD}气温{TEMPERATURE}：第{DAYS}天（{MINUTES}分{SECONDS}秒）。快出去干活，别偷懒！',
        },
        MAPPINGS = {
            DEFAULT = {
                WORLD = { SURFACE = '地表', CAVES = '洞穴', SHIPWRECKED = '海难', VOLCANO = '火山', PORKLAND = '猪镇', WINTERLAND = '冰岛' },
                WEATHER = { SPRING = '下雨', SUMMER = '下雨', AUTUMN = '下雨', WINTER = '暴雪', GREEN = '下雨', DRY = '下雨', MILD = '下雨', WET = '狂风暴雨', TEMPERATE = '下雨', HUMID = '下雨', LUSH = '下雨', APORKALYPSE = '下雨' },
            }
        }
    },
    TEMPERATURE = {
        FORMATS = { DEFAULT = '({TEMPERATURE}°) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    BURNING = '烫烫烫！你是要把我烤熟吗笨蛋！快找冰块！',
                    HOT = '热死了……还不快点想办法降温，你想热死我吗！',
                    WARM = '稍微有点热。别误会，我才不需要你帮忙扇风。',
                    GOOD = '哼，现在的温度勉强算及格吧。',
                    COOL = '阿嚏！才、才不是感冒呢！只是有一点点凉而已！',
                    COLD = '冷死了笨蛋！快点生火啊，你是想把我冻成冰块吗！',
                    FREEZING = '要冻僵了啦……还不快把你的外套给我披上，笨蛋！',
                }
            }
        }
    },
    MOON_PHASE = {
        FORMATS = {
            DEFAULT = '那个……{RECENT}{PHASE1}{INTERVAL}距离下次{PHASE2}还有{LEFT}天。别忘了记日子！',
            MOON = '喂，快看！{RECENT}{PHASE1}了，晚上别乱跑给我添麻烦！',
            FAILED = '云那么厚，我怎么可能看得清月相啊笨蛋！'
        },
        MAPPINGS = {
            DEFAULT = {
                MOON = { FULL = '满月', NEW = '朔月' },
                INTERVAL = { COMMA = '，', NONE = '' },
                RECENT = { TODAY = '今晚是', TOMORROW = '明晚是', AFTER = '刚度过' },
            }
        }
    },
    CLOCK = {
        FORMATS = {
            DEFAULT = '{PHASE}还有{PHASE_REMAIN}就结束了，今天还剩{DAY_REMAIN}。快点干活！',
            NIGHTMARE = '{PHASE}还剩{PHASE_REMAIN}，今天还剩{DAY_REMAIN}，{NIGHTMARE}还有{REMAIN}结束。给我撑住！',
            NIGHTMARE_LOCK = '{PHASE}还剩{PHASE_REMAIN}，今天还剩{DAY_REMAIN}，现在是{NIGHTMARE}！别死了啊！'
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
            CAN = '我可以顺手做个{NAME}。听好了，只是顺手而已！',
            NEED = '肚子饿了……喂，我需要做个{NAME}，快给我准备食材！',
            MIN_INGREDIENT = '做{NAME}必须要{NUM}个{INGREDIENT}，别少放了笨蛋！',
            MAX_INGREDIENT = '做{NAME}最多只能加{NUM}个{INGREDIENT}，放多了难吃死你！',
            ZERO_INGREDIENT = '喂！{NAME}里面绝对不能放{INGREDIENT}，你想毒死我吗！',
            HUNGER = '{NAME}料理{TYPE}饱食度{VALUE}点。勉强能吃吧。',
            SANITY = '{NAME}料理{TYPE}精神值{VALUE}点。别太感谢我。',
            HEALTH = '{NAME}料理{TYPE}生命值{VALUE}点。快吃，别死了。',
            FOOD = '听好了！{NAME}：饱食度{HUNGER}，精神{SANITY}，生命{HEALTH}。',
            FOOD_LOCK = '啧……我还没解锁怎么做{NAME}呢，少啰嗦。',
            FOOD_NO_EATEN = '你不喂我试吃一口{NAME}，我怎么知道什么味道！',
        },
        MAPPINGS = {
            DEFAULT = {
                TYPE = { POS = '能恢复', NEG = '会扣除' }
            }
        }
    },
    BOAT = {
        FORMATS = { DEFAULT = '(破船：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '船好好的！别乱动舵，听我指挥！',
                    HIGH = '磕掉了一点漆……你这笨蛋会不会开船啊！',
                    MID = '喂，船在漏水了，还不快拿木板来修！',
                    LOW = '要沉了要沉了！你这笨蛋船长快想办法啊！',
                    EMPTY = '咕噜噜……我就算淹死也不会要你救的……救命！',
                }
            }
        }
    },
    ABIGAIL = {
        FORMATS = { DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '阿比盖尔会保护我的……才不需要你呢！',
                    HIGH = '阿比盖尔受伤了！喂，别让她受伤啊！',
                    MID = '阿比盖尔……你没事吧？我、我才没担心！',
                    LOW = '笨蛋！快去帮帮阿比盖尔啊，她快撑不住了！',
                    EMPTY = '阿比盖尔！……呜，绝对不原谅你！',
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
                    FULL = '我现在可是头充满野性的怪兽，别惹我！',
                    HIGH = '我还精神着呢，还能再打十个！',
                    MID = '稍微有点累了……闭嘴，我还能打！',
                    LOW = '喂……我快没力气变身了，快准备吃的！',
                    EMPTY = '变回原样了……哼，才不是因为没力气呢！',
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
                    MIGHTY = '看到了吗！我现在力气最大，才不需要你保护！',
                    NORMAL = '只是普通状态而已，有什么好看的！',
                    WIMPY = '呜……手脚没力气了，稍微帮我拿一下东西会死啊！',
                },
                SYMBOL = { EMOJI = 'flex', TEXT = '力量' }
            }
        }
    },
    INSPIRATION = {
        FORMATS = { DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    EMPTY = '嗓子哑了，别指望我现在给你唱歌！',
                    LOW = '只能唱1首而已……听好了，只唱一遍！',
                    MID = '勉为其难可以唱2首，心怀感激地听吧！',
                    HIGH = '状态好极了！给你连唱3首，好好给我鼓掌笨蛋！'
                },
                SYMBOL = { EMOJI = 'horn', TEXT = '灵感值' }
            }
        }
    },
    ENERGY = {
        FORMATS = {
            DEFAULT = '(电量：{CURRENT}/{MAX}，已占用：{USED}格) 喂！给我看清楚，电量现在{MESSAGE}！',
            CHIP = '{NUM}个破{ITEM}',
            ALL_MODULES = '啧，勉为其难让你看看我装了什么：{MODULES}。别看太久！',
            NO_MODULES = '哼，我这种天才就算不装电路也很强，所以现在什么都没装！'
        },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    ZERO = '完全空了笨蛋',
                    ONE = '就要坏掉了',
                    TWO = '低得离谱',
                    THREE = '勉强一半',
                    FOUR = '还算凑合',
                    FIVE = '挺充裕的',
                    SIX = '全满状态'
                }
            }
        }
    },
    GIFT = {
        FORMATS = {
            CAN_OPEN = '有礼物？哼，既然你非要送，那我就勉为其难拆开看看吧！',
            NEED_SCIENCE = '打不开啦！还不快去弄个科学机器来帮我！',
        },
        MAPPINGS = {}
    },
    PLAYER = {
        FORMATS = {
            DEFAULT = '{NAME}在我这边。别误会，我没特意找他！',
            ADMIN = '啧，{NAME}是管理员。别以为管理员就能命令我！',
            NAME = '{NAME}是{CHARACTER}。',
            AGE = '{NAME}居然活了{AGE}这么久。',
            AGE_SHORT = '{NAME}存活{AGE}。',
            PERF = '{NAME} 的{PERF}。{PING}',
            GREET = '哟，{NAME}。才、才不是在等你呢！',
            PING = '延迟：{PING}',
            BADGE = '{NAME}戴着{BADGE}的头像。眼光真差。',
            BACKGROUND = '{NAME}的背景是{BACKGROUND}。',
            BODY = '{NAME}穿着{BODY}。勉强能看吧。',
            HAND = '{NAME}手上戴着{HAND}。',
            LEGS = '{NAME}腿上是{LEGS}。',
            FEET = '{NAME}脚上是{FEET}。',
            BASE = '{NAME}的脑袋是{BASE}。',
            HEAD_EQUIP = '{NAME}头上戴着{HEAD_EQUIP}。',
            HAND_EQUIP = '{NAME}拿着{HAND_EQUIP}。小心点别伤到自己！',
            BODY_EQUIP = '{NAME}穿着{BODY_EQUIP}。',
            GIVE_ITEM = "喂，{NAME}！这{NUM}个{ITEM_NAME}给你，别想多了，只是我拿不下了！",
            BOTH_GHOST = "真是的！{NAME}，都怪你害我们都变成鬼魂了！",
            ME_GHOST = "喂，{NAME}！还不快拿告密的心来救我，笨蛋！",
            THEY_GHOST = "{NAME}你这笨蛋站着别动，我这就去救你！",
            I_AM_HERE = "喂，{NAME}！我在这里，快跟上！",
            ME_FISHING = '喂！{NAME}在钓鱼，闭嘴别把鱼吓跑了！',
            THEY_FISHING = '{NAME}那家伙在钓鱼，别钓上来什么破鞋子！',
        },
        MAPPINGS = {}
    },
    SERVER = {
        FORMATS = {
            NAME = '这破房间叫：{NAME}。',
            AGE = '服务器运行了：{AGE}天。居然还没塌。',
            NUM_PLAYER = '现在有：{NUM}个人。人多眼杂的。'
        },
        MAPPINGS = {}
    },
    SKILL_TREE = {
        FORMATS = {
            ACTIVATED = '{NAME}已经点亮了『{SKILL}』。勉强夸你一句吧。',
            CAN_ACTIVATE = '{NAME}可以去点『{SKILL}』了，别磨蹭！',
            NOT_ACTIVATED = '{NAME}还没点『{SKILL}』，真是个笨蛋。',
            XP = '{NAME}还有{XP}点洞察没用。',
        },
        MAPPINGS = {}
    },
    PORTAL = {
        FORMATS = {
            ON = '我已经摸到{NAME}了，快点过来！',
            OFF = '{NAME}在我这，快点准备摸它笨蛋！'
        },
        MAPPINGS = {}
    },
    SPACE = {
        FORMATS = {
            PLAYER = "我的包里还有{COUNT}个空位，帮你拿点也可以啦。",
            INV = "我的{CONTAINER_NAME}还有{COUNT}个空位，快装进去！",
            CONTAINER = "这个{CONTAINER_NAME}还有{COUNT}个空位，瞎了吗自己看！"
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
                    HEALTH_HIGH = "这头笨牛结实得很！（生命：{PCT}%）",
                    HEALTH_NORMAL = "牛的状态还凑合。（生命：{PCT}%）",
                    HEALTH_LOW = "喂！牛快死了你瞎了吗！快给它加血！（生命：{PCT}%）",
                    
                    HUNGER_FULL = "它吃撑了，别再喂了浪费食物！（饥饿：{VAL}）",
                    HUNGER_NORMAL = "这笨牛现在不饿。（饥饿：{VAL}）",
                    HUNGER_HUNGRY = "喂，牛肚子叫了，还不快点拿草来！（饥饿：{VAL}）",
                    HUNGER_STARVING = "牛饿得都要咬我了，你这白痴主子还不喂它！（饥饿：{VAL}）",
                    
                    OBEDIENCE_HIGH = "哼，这头笨牛总算乖乖听话了。（顺从：{PCT}%）",
                    OBEDIENCE_NORMAL = "勉强算听话吧。（顺从：{PCT}%）",
                    OBEDIENCE_LOW = "这笨牛要发脾气了！快安抚它啊！（顺从：{PCT}%）",
                    
                    DOMESTICATION_FULL = "哼，我可是驯牛大师，它敢不听话？（已驯服）",
                    DOMESTICATION_HIGH = "马上就要被完全驯化了，算你有功劳。（驯化：{PCT}%）",
                    DOMESTICATION_NORMAL = "还在驯化中，别半途而废了！（驯化：{PCT}%）",
                    DOMESTICATION_LOW = "野性这么大，你到底会不会驯牛啊笨蛋！（驯化：{PCT}%）",
                    
                    TIMER_RIDING = "还能骑{TIME}。抓紧了别掉下去！",
                    TIMER_LOW = "喂！它要甩人了，快点准备下来笨蛋！（剩余：{TIME}）"
                },
                TENDENCY_NAME = {
                    DEFAULT = "普通",
                    RIDER = "骑行",
                    ORNERY = "战斗",
                    PUDGY = "圆润",
                    UNKNOWN = "未知"
                }
            }
        }
    },
    TREE = {
        FORMATS = {
            EQUAL = '喂！这{COUNT}棵{NAME}全都是{ADJ}{SHOW_ME}，长眼睛自己看！',
            DESCRIBE = '听好了，这{COUNT}棵{NAME}里，有{NUM}棵是{ADJ}{SHOW_ME}！'
        },
        MAPPINGS = {
            DEFAULT = {
                ADJ = {
                    STUMP = "只剩破树桩了",
                    SAPLING = "没用的小树苗",
                    SHORT = "才刚长出来",
                    NORMAL = "长得普普通通",
                    TALL = "长得老高的",
                    BOULDER = "被敲成破矿床了",
                    SEED = "刚种下的种子",
                    ANCIENT_READY = "果实都长满了",
                    ANCIENT_EMPTY = "果子全没了",
                    MARBLE_TALL = "完全长大的大理石",
                    MARBLE_NORMAL = "中等大小的大理石",
                    MARBLE_SHORT = "刚长出的大理石",
                    MARBLE_TREE = "大理石做的破树"
                }
            }
        }
    },
    CROP = {
        FORMATS = {
            EQUAL = '这{COUNT}个{NAME}，全都{ADJ}{SHOW_ME}，别让我重复第二遍！',
            DESCRIBE = '这{COUNT}个{NAME}里，有{NUM}个{ADJ}{SHOW_ME}，自己记好了！'
        },
        MAPPINGS = {
            DEFAULT = {
                ADJ = {
                    WITH_BARNACLES = "长着恶心藤壶的",
                    NO_BARNACLES = "光秃秃的",
                    SEED = "还是破种子",
                    GROW = "还在慢吞吞生长的",
                    FULL = "已经熟了还不快摘",
                    OVER = "长得巨大无比的",
                    ROT = "都已经腐烂了笨蛋",
                    SALT_FULL = "长满盐矿的",
                    SALT_MED = "正在结小盐矿的",
                    SALT_LOW = "只有一点盐晶的",
                    SALT_EMPTY = "被挖空了的",
                    MARBLE_TALL = "完全长大的大理石",
                    MARBLE_NORMAL = "中等大小的大理石",
                    MARBLE_SHORT = "刚长出的大理石",
                    BEEBOX_FULL = "满是蜂蜜的",
                    BEEBOX_SOME = "有点蜂蜜的",
                    BEEBOX_EMPTY = "空空如也的",
                    PICKABLE_READY = "长好了快去摘",
                    PICKABLE_EMPTY = "还没长好别碰",
                    NEST_HAS_EGG = "有高鸟蛋的",
                    NEST_EMPTY = "空鸟窝",
                    MUSHROOMFARM_ROTTEN = "变成烂木头了",
                    MUSHROOMFARM_EMPTY = "里面空的",
                    MUSHROOMFARM_STAGE1 = "刚种下的小蘑菇",
                    MUSHROOMFARM_STAGE2 = "长得凑合的",
                    MUSHROOMFARM_STAGE3 = "完全长大的",
                    MUSHROOMFARM_STAGE4 = "长得快爆出来的"
                }
            }
        }
    },
    SPIDERDEN = {
        FORMATS = {
            EQUAL = '这{COUNT}个{NAME}全都是{ADJ}{SHOW_ME}，当心被咬死笨蛋！',
            DESCRIBE = '这{COUNT}个{NAME}里有{NUM}个是{ADJ}{SHOW_ME}，小心点！'
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
            SINGLE = '喂，我旁边有1个{NAME}{SHOW_ME}{DISTANCE}，别告诉我你没看见！',
            DEFAULT = '听好了，附近有{NUM}个{NAME}{SHOW_ME}{DISTANCE}，自己长点心！',
            NAMED = '那个……附近有{NUM_PREFAB}个{PREFAB_NAME}，其中有{NUM}个叫{NAME}{SHOW_ME}{DISTANCE}，我只是顺便告诉你的！',
            CODE = '这东西叫：{NAME}，代码是：{PREFAB}。记不住就算了！',
            BURNT_EQUAL = '那里有{TOTAL}个{NAME}全烧成灰了，这就是你这笨蛋不小心的下场{SHOW_ME}{DISTANCE}！',
            BURNT_DESCRIBE = '那里有{TOTAL}个{NAME}，有{NUM}个烧成灰了{SHOW_ME}{DISTANCE}，气死我了！',
            FIRE_EQUAL = '喂！不好啦！{TOTAL}个{NAME}全着火了{SHOW_ME}{DISTANCE}，快拿灭火器救火啊笨蛋！',
            FIRE_DESCRIBE = '喂！{TOTAL}个{NAME}里有{NUM}个起火了{SHOW_ME}{DISTANCE}，你瞎了吗快点灭火！',
            WITHERED_EQUAL = '真是的……{TOTAL}个{NAME}全都被热枯萎了{SHOW_ME}{DISTANCE}，你到底有没有在照顾！',
            WITHERED_DESCRIBE = '有{TOTAL}个{NAME}，其中有{NUM}个被热枯萎了{SHOW_ME}{DISTANCE}，快点想想办法！',
            BARREN_EQUAL = '喂，{TOTAL}个{NAME}全都没施肥{SHOW_ME}{DISTANCE}，快去捡点大便来！',
            BARREN_DESCRIBE = '这{TOTAL}个{NAME}里有{NUM}个还没施肥{SHOW_ME}{DISTANCE}，还要我教你吗！',
            SMOLDER_EQUAL = '糟了！{TOTAL}个{NAME}全都在冒黑烟了{SHOW_ME}{DISTANCE}，马上就要着火了快救命！',
            SMOLDER_DESCRIBE = '喂！{TOTAL}个{NAME}里有{NUM}个冒黑烟了{SHOW_ME}{DISTANCE}，快拿冰块来砸它！',
            GOAT_CHARGED_EQUAL = '别靠近！{TOTAL}个{NAME}全都带电了{SHOW_ME}{DISTANCE}，你想被电死吗笨蛋！',
            GOAT_CHARGED_DESCRIBE = '这里有{TOTAL}个{NAME}，有{NUM}只是带电的{SHOW_ME}{DISTANCE}，离远点！',
            GOAT_NORMAL_EQUAL = '这里有{TOTAL}个{NAME}，全都是普通的羊{SHOW_ME}{DISTANCE}。',
            GOAT_NORMAL_DESCRIBE = '这里有{TOTAL}个{NAME}，其中{NUM}只是普通的羊{SHOW_ME}{DISTANCE}。',
            FISH_SHOAL = '喂，这里有群{FISH}，一共{NUM}条{SHOW_ME}{DISTANCE}！快点来抓！',
            FISH_HOLE = '看，这里有处{NAME}{SHOW_ME}{DISTANCE}。我才不是特意帮你找钓鱼点的！',
            HOTSPRING_BOMBED_EQUAL = '这里有{TOTAL}个{NAME}，水温刚好{SHOW_ME}{DISTANCE}。我、我才不是邀请你一起泡呢！',
            HOTSPRING_BOMBED_DESCRIBE = '这里有{TOTAL}个{NAME}，其中{NUM}个水温刚好{SHOW_ME}{DISTANCE}，别想多了！',
            HOTSPRING_GLASSED_EQUAL = '这{TOTAL}个{NAME}全变成硬石头了{SHOW_ME}{DISTANCE}，怎么泡啊笨蛋！',
            HOTSPRING_GLASSED_DESCRIBE = '这里有{TOTAL}个{NAME}，其中{NUM}个变成石头了{SHOW_ME}{DISTANCE}！',
            HOTSPRING_EMPTY_EQUAL = '这{TOTAL}个{NAME}全干了{SHOW_ME}{DISTANCE}，没水了你满意了吧！',
            HOTSPRING_EMPTY_DESCRIBE = '这里有{TOTAL}个{NAME}，其中{NUM}个干涸了{SHOW_ME}{DISTANCE}！',
            FRUITDRAGON_RIPE_EQUAL = '这里有{TOTAL}个{NAME}，全变红了{SHOW_ME}{DISTANCE}，快点去摘笨蛋！',
            FRUITDRAGON_RIPE_DESCRIBE = '这里有{TOTAL}个{NAME}，其中{NUM}个红透了{SHOW_ME}{DISTANCE}！',
            FRUITDRAGON_UNRIPE_EQUAL = '这{TOTAL}个{NAME}全是普通颜色{SHOW_ME}{DISTANCE}，急什么急没熟呢！',
            FRUITDRAGON_UNRIPE_DESCRIBE = '这里有{TOTAL}个{NAME}，其中{NUM}个还没熟{SHOW_ME}{DISTANCE}！',
            BIRDCAGE_EMPTY = '这{TOTAL}个{NAME}是空的{SHOW_ME}{DISTANCE}，连只鸟都没有！',
            BIRDCAGE_FULL = '这{TOTAL}个{NAME}里有只鸟{SHOW_ME}{DISTANCE}。',
            BIRDCAGE_SICK = '喂，这{TOTAL}个{NAME}里的鸟生病了{SHOW_ME}{DISTANCE}，快管管！',
            BIRDCAGE_DEAD = '这{TOTAL}个{NAME}里的鸟都饿死了{SHOW_ME}{DISTANCE}，你这没良心的！',
            ARCHIVE_SWITCH_FULL_EQUAL = '这{TOTAL}个{NAME}全都激活了{SHOW_ME}{DISTANCE}，算你干得不错。',
            ARCHIVE_SWITCH_FULL_DESCRIBE = '这{TOTAL}个{NAME}里有{NUM}个激活了{SHOW_ME}{DISTANCE}。',
            ARCHIVE_SWITCH_EMPTY_EQUAL = '这{TOTAL}个{NAME}全没激活{SHOW_ME}{DISTANCE}，还不快去！',
            ARCHIVE_SWITCH_EMPTY_DESCRIBE = '这{TOTAL}个{NAME}里有{NUM}个没激活{SHOW_ME}{DISTANCE}，别偷懒！',
            TOADSTOOL_EMPTY = '扫描过了，这里有蟾蜍洞穴，目前空的{SHOW_ME}{DISTANCE}，蛤蟆不在。',
            TOADSTOOL_NORMAL = '喂！准备战斗！蟾蜍洞穴里有大蛤蟆{SHOW_ME}{DISTANCE}，别拖后腿！',
            TOADSTOOL_DARK = '警报！这里有悲惨毒菌蟾蜍{SHOW_ME}{DISTANCE}，别死了啊笨蛋！',
            OASISLAKE_EMPTY = '你看，这1个{NAME}都干了{SHOW_ME}{DISTANCE}，钓个鬼的鱼！',
            OASISLAKE_FULL = '哼，这1个{NAME}里面满是水{SHOW_ME}{DISTANCE}，勉强陪你钓一会好了！',
        },
        MAPPINGS = {
            DEFAULT = {
                WORDS = {
                    SHOW_ME = '（这个有 {SHOW_ME}）',
                    DISTANCE_FAR = '，离我大约{DIST}格，自己走过去，我才不接你！',
                    DISTANCE_CLOSE = '，就在我旁边，你瞎了吗自己看！',
                    DISTANCE_FAR_WATER = '，在离我约{DIST}格的水面上，掉下去淹死你！',
                    DISTANCE_CLOSE_WATER = '，就在我旁边的水面上，当心点笨蛋！',
                }
            }
        }
    },
    SKIN = {
        FORMATS = {
            DEFAULT = '我有{NUM}个{ITEM}的皮肤（共{TOTAL}个），这件『{SKIN}』勉强还能看吧！',
            NO_SKIN = '喂！科雷什么时候才给『{ITEM}』出皮肤啊，真气人！',
            HAS_NO_SKIN = '真是的……我连一件『{ITEM}』的皮肤都没有，还不快给我去买！'
        },
        MAPPINGS = {}
    },
    RECIPE = {
        FORMATS = {
            BUFFERED = '我手里刚好准备好了{ITEM}，随时能放下。',
            WILL_MAKE = '材料齐了，我勉强可以给你做一个{ITEM}。',
            WE_NEED = '喂，我们需要造个{ITEM}，别问为什么，去拿材料就是了！',
            CAN_SOMEONE = '喂！谁来帮我做个{ITEM}啊！我需要{PROTOTYPE}才能造它！',
        },
        MAPPINGS = {
            DEFAULT = {
                PROTOTYPER = {
                    UNKNOWN_PROTOTYPE = "一个神秘科技",
                    CANTRESEARCH = "一份破烂图纸",
                    NEEDSTECH = "一份技术图纸",
                    NEEDSSCIENCEMACHINE = "一台科学机器",
                    NEEDSALCHEMYMACHINE = "一个炼金引擎",
                    NEEDSPRESTIHATITATOR = "一个灵子分解器",
                    NEEDSSHADOWMANIPULATOR = "一台暗影操纵器",
                    NEEDSELECOURMALINE_THREE = "激活灵感的电器重铸台",
                    NEEDSELECOURMALINE_ONE = "电器重铸台",
                    NEEDSSIVING_ONE = "子圭神木岩",
                    NEEDSSKILL = "学会新技能",
                    NEEDSCELESTIAL_THREE = "一个大型的月能来源",
                    NEEDSCELESTIAL_ONE = "一个小型的月能来源",
                    NEEDSMOON_ALTAR_FULL = "一个完整的天体科技",
                    NEEDSMOONORB_LOW = "一个天体科技",
                    NEEDSCHARACTER = "另一个笨蛋队友",
                    NEEDSCRITTERLAB = "在岩石巢穴旁",
                    NEEDSTUFF_PROTOTYPE = "找齐原型材料",
                    NEEDSFISHING = "一个钓具容器",
                    NEEDSSHADOWFORGING_TWO = "一个暗影术基座",
                    NEEDSTUFF = "找齐合成材料",
                    NEEDSCHARACTERSKILL = "制作这一物品的技能",
                    NEEDSANCIENTALTAR_HIGH = "找到完整远古结构",
                    NEEDSFOODPROCESSING = "一个便携研磨器",
                    NEEDSANCIENTALTAR_LOW = "找到远古结构",
                    NEEDSTURFCRAFTING = "一个土地夯实器",
                    NEEDSHERMITCRABSHOP_L4 = "寄居蟹老奶奶",
                    NEEDSHERMITCRABSHOP_L3 = "寄居蟹老奶奶",
                    NEEDSHERMITCRABSHOP_L2 = "寄居蟹老奶奶",
                    NEEDSHERMITCRABSHOP_L1 = "寄居蟹老奶奶",
                    NEEDSHERMITCRABHELP_CRAFTING = "寄居蟹老奶奶",
                    NEEDSHERMITCRAB_TEASHOP = "珍珠的茶店",
                    NEEDSSHELLWEAVER_L1= "一台盐晶组合机",
                    NEEDSSHELLWEAVER_L2= "一台升级的盐晶组合机",
                    NEEDSHALLOWED_NIGHTS = "在万圣夜的捣蛋时间",
                    NEEDSCARNIVAL_PRIZESHOP = "在良羽鸦的玩具摊位",
                    NEEDSCARNIVAL_HOSTSHOP_PLAZA = "买鸦年华树苗",
                    NEEDSCARNIVAL_HOSTSHOP_WANDER = "在鸦年华找到那个大鸟人",
                    NEEDSWINTERSFEASTCOOKING = "用热的砖砌烤炉",
                    NEEDSWARGSHRINE = "在座狼神龛献上供品",
                    NEEDSMADSCIENCE = "疯狂科学家实验室",
                    NEEDSRABBITKINGSHOP = "找到兔子国王",
                    NEEDSYOTG = "在火鸡之年",
                    NEEDSYOTR = "在兔人之年",
                    NEEDSYOTV = "在座狼之年",
                    NEEDSYOTS = "在洞穴蠕虫之年",
                    NEEDSYOTD = "在龙蝇之年",
                    NEEDSYOTP = "在猪王之年",
                    NEEDSYOTC = "在胡萝卜鼠之年",
                    NEEDSYOTB = "在皮弗娄牛之年",
                    NEEDSYOTH = "在发条骑士之年",
                    NEEDSWINTERS_FEAST = "在冬季盛宴时",
                    NEEDSYOTCATCOON = "在浣猫之年！",
                    NEEDSBEEFSHRINE = "在牛神龛献上供品",
                    NEEDSRABBITSHRINE = "在兔人神龛献上供品",
                    NEEDSCATCOONSHRINE = "在浣猫神龛献上供品",
                    NEEDSKNIGHTSHRINE = "在发条骑士神龛献上供品",
                    NEEDSPERDSHRINE = "在火鸡神龛献上供品",
                    NEEDSWORMSHRINE = "在洞穴蠕虫神龛献上供品",
                    NEEDSCARRATSHRINE = "在胡萝卜鼠神龛献上供品",
                    NEEDSDRAGONSHRINE = "在龙蝇神龛献上供品",
                    NEEDSSHRINE = "在节日神龛献上供品",
                    NEEDSPIGSHRINE = "在猪神龛献上供品",
                    NEEDSROBOTMODULECRAFT = "扫描生物",
                    NEEDSBOOKCRAFT = "一个书架",
                    NEEDSSEAFARING_STATION = "一个智囊团",
                    NEEDSSPIDERCRAFT = "交个蜘蛛朋友",
                    NEEDSSHADOW_FORGE = "暗影术基座",
                    NEEDSLUNAR_FORGE = "辉煌铁匠铺",
                    NEEDSCARTOGRAPHYDESK = "制图桌",
                    NEEDSCARPENTRY_STATION = "一个锯马",
                    NEEDSCARPENTRY_STATION_STONE = "带有月光玻璃的锯马"
                }
            }
        }
    },
    MEDAL_BUFF = {
        FORMATS = {
            DEFAULT = '听好了，我现在有"{BUFF_NAME}"BUFF加持，还能持续{TIME}！',
            FOREVER = '哼，我现在有"{BUFF_NAME}"BUFF的永久加持，厉害吧！',
        },
        MAPPINGS = {}
    },
    ITEM = {
        FORMATS = {
            INV_SLOT = '{PRONOUN}的包里有{NUM}个{ITEM}{ITEM_NAME}{IN_CONTAINER}{WITH_PERCENT}{POST_STATE}{SHOW_ME}。别打这些的主意！',
            EQUIP_SLOT = '{PRONOUN}穿戴了{EQUIP_NUM}个{ITEM}{ITEM_NUM}{ITEM_NAME}{IN_CONTAINER}{WITH_PERCENT}{POST_STATE}{SHOW_ME}。还挺好看的对吧！',
            EQUIP_SLOT_POS = '{PRONOUN}的{SLOT_POS}装备了{EQUIP_NUM}个{ITEM}{ITEM_NUM}{ITEM_NAME}{WITH_PERCENT}{POST_STATE}{SHOW_ME}。',
            EQUIP_SLOT_EMPTY = '{PRONOUN}的{SLOT_POS}光秃秃的，什么都没穿！'
        },
        MAPPINGS = {
            DEFAULT = {
                PRONOUN = { I = '我', WE = '我们' },
                HEAT_ROCK = {
                    COLD = '，冷冰冰的',
                    COOL = '，凉飕飕的',
                    NORMAL = '，常温的',
                    WARM = '，热乎乎的',
                    HOT = '，滚烫烫的'
                },
                RECHARGE = {
                    CHARGING = '，还差{TIME}才能充满，烦死了',
                    FULL = '，魔力已经满了'
                },
                PERCENT_TYPE = { DURABILITY = '的耐久度', FRESHNESS = '新鲜度' },
                TIME = { MINUTES = '分', SECONDS = '秒' },
                WORDS = {
                    THIS_ONE = '其中这个',
                    ITEM_NAME = ' (有{NUM}个名字叫{NAME}的)',
                    ITEM_NUM = ' (一共屯了{NUM}个)',
                    IN_CONTAINER = ' 藏在这个破{NAME}里',
                    WITH_PERCENT = '，{THIS_ONE}还剩下{PERCENT}{TYPE}',
                    SUSPICIOUS_MARBLE = '，喂这是{NAME}',
                    SHOW_ME = '（这个有 {SHOW_ME}）',

                    SLOT_HEAD = '头上',
                    SLOT_HANDS = '手里',
                    SLOT_BODY = '身上',
                    SLOT_BACK = '后背上',
                    SLOT_NECK = '脖颈上',
                    SLOT_BELLY = '服装栏',
                    SLOT_MEDAL = '勋章处',
                }
            }
        }
    },
    INGREDIENT = {
        FORMATS = {
            NEED_MULTIPLE = "喂！要造{RECIPE}还差{INGREDIENT}{AND_PROTOTYPE}，你自己去找啊笨蛋！",
            HAVE_ALL = "材料刚好凑齐了……顺便帮你造个{RECIPE}吧{BUT_PROTOTYPE}，感恩戴德吧！",
        },
        MAPPINGS = {
            DEFAULT = {
                WORDS = {
                    ITEM_AMOUNT_FORMAT = "{NUM}个{ITEM}",
                    COMMA = "，",
                    ALL_MATERIALS = "所有需要的破材料",
                    AND_PROTOTYPE = '，而且还需要{PROTOTYPE}帮忙',
                    BUT_PROTOTYPE = '，不过现在就差{PROTOTYPE}帮忙了'
                }
            }
        }
    },
    CONSTRUCTION = {
        FORMATS = {
            NEED = "我们还需要{INGREDIENT}才能把{RECIPE}建完，快点去干活！",
            HAVE = "材料都齐了，{RECIPE}随时可以动工，还不快点！",
            HAVE_ITEM = "我已经拿好{INGREDIENT}准备建{RECIPE}了，还不快夸我！", 
        },
        MAPPINGS = {
            DEFAULT = {
                WORDS = { AMOUNT_FMT = "{NUM}个{ITEM}" }
            }
        }
    },
    TRADE = {
        FORMATS = {
            NEED = "想要和{RECIPE}交易，兜里还缺{INGREDIENT}。穷鬼！",
            HAVE = "有足够的{INGREDIENT}可以和{RECIPE}交易了。快去啊，愣着干嘛！",
            HAVE_ITEM = "我有足够的{INGREDIENT}去和{RECIPE}换东西了，还不快跟上！", 
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
                    FULL = '高于75%……沃比吃得很饱，它才不饿呢！',
                    HIGH = '55%……沃比还能跑很久，你别虐待它！',
                    MID = '35%……沃比肚子叫了，喂它点零食啊！',
                    LOW = '15%……沃比饿坏了！你到底有没有在管它！',
                    EMPTY = '低于15%……沃比饿趴下了啦！你这没良心的主子！',
                },
                SYMBOL = { TEXT = '沃比' }
            }
        }
    },
    STOMACH = {
        FORMATS = { DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '高于75%……嗝，吃撑了！别再给我塞吃的了！',
                    HIGH = '55%……刚吃过，但我勉强还能再吃一点。',
                    MID = '35%……喂，我肚子饿了！还不快给我拿吃的！',
                    LOW = '15%……饿得头晕眼花……你想饿死我吗笨蛋！',
                    EMPTY = '低于15%……我要饿死了……你这没用的家伙！',
                },
                SYMBOL = { EMOJI = 'hunger', TEXT = '饥饿' }
            },
            WILSON = {
                MESSAGE = {
                    FULL = '我的肚子填满了。才不是因为贪吃！',
                    HIGH = '我还不怎么饿，少管我。',
                    MID = '肚子有点空了，给我点吃的也行。',
                    LOW = '我真的饿了笨蛋！快去拿吃的！',
                    EMPTY = '我、我要饿死了……救命……',
                }
            },
            WILLOW = {
                MESSAGE = {
                    FULL = '再吃就要胖了！我绝对不吃了！',
                    HIGH = '肚子很饱满，不饿！',
                    MID = '我的生命之火需要一点燃料了，你懂吧？',
                    LOW = 'Ugh，我要饿死在这里了，你这白痴！',
                    EMPTY = '我饿得皮包骨了！全怪你！',
                }
            },
            WOLFGANG = {
                MESSAGE = {
                    FULL = '沃尔夫冈现在很强壮！不需要吃东西！',
                    HIGH = '还不怎么饿，但再吃点才能更强！',
                    MID = '喂，沃尔夫冈需要吃肉了！',
                    LOW = '沃尔夫冈的肚子饿穿了，快点拿食物来！',
                    EMPTY = '沃尔夫冈急需食物！快点！',
                }
            },
            WENDY = {
                MESSAGE = {
                    FULL = '吃得再饱也填补不了空虚。但这食物勉强还行。',
                    HIGH = '我饱了，别再拿这些来烦我。',
                    MID = '我不饿，但也不饱。别看我。',
                    LOW = '我的肚子和心灵一样空虚了……好饿。',
                    EMPTY = '我快被饿死了……姐姐……',
                }
            },
            WX78 = {
                MESSAGE = {
                    FULL = '燃料状态：最大容量。算你这肉体有点用。',
                    HIGH = '燃料状态：高的。',
                    MID = '燃料状态：合意的。需要补充了蠢货。',
                    LOW = '燃料状态：低的。你想让机体停机吗！',
                    EMPTY = '燃料状态：危险！快给我充能笨蛋！',
                }
            },
            WICKERBOTTOM = {
                MESSAGE = {
                    FULL = '我应该从事研究，而不是把时间浪费在吃上！',
                    HIGH = '吃饱了，别再给我端盘子了。',
                    MID = '稍微感到了一点饥饿，快去准备。',
                    LOW = '图书管理员需要食物！别让我说第二遍！',
                    EMPTY = '再不进食我就要饿死了！你聋了吗！',
                }
            },
            WOODIE = {
                MESSAGE = {
                    FULL = '吃得太饱了！别塞了！',
                    HIGH = '砍树的力气还够，不用你操心。',
                    MID = '喂，我需要吃点零食来补充力气！',
                    LOW = '正餐时间到了！快把饭端上来！',
                    EMPTY = '我要饿死了！别逼我啃木头！',
                }
            },
            WES = {
                MESSAGE = {
                    FULL = '*拍拍肚子，傲慢地转过头去*',
                    HIGH = '*拍拍肚子，勉强比个手势*',
                    MID = '*指指嘴巴，狠狠地瞪你一眼*',
                    LOW = '*夸张地指着肚子，气呼呼的*',
                    EMPTY = '*绝望地看着你，倒在地上装死*',
                }
            },
            WAXWELL = {
                MESSAGE = {
                    FULL = '这盛宴勉强合我的胃口，别太得意。',
                    HIGH = '我已经满足了，适可而止吧。',
                    MID = '吃个快餐也不是不行。',
                    LOW = '我的胃空了，还不快去准备吃的！',
                    EMPTY = '不！我才不要在这里被活活饿死！',
                }
            },
            WEBBER = {
                MESSAGE = {
                    FULL = '我们的胃部都爆满了！不要了！',
                    HIGH = '我们还能再啃一点，如果有的话。',
                    MID = '午饭时间到了！别让我们等太久！',
                    LOW = '就算吃剩菜也可以……快给我们吃的！',
                    EMPTY = '我们的胃是空的！要饿扁了呜呜呜！',
                }
            },
            WATHGRITHR = {
                MESSAGE = {
                    FULL = '我已经吃饱了，随时可以战斗！',
                    HIGH = '这点食物勉强足够支撑战斗了。',
                    MID = '我需要肉类零食！去给我打猎！',
                    LOW = '我渴望一场盛宴！快点上菜！',
                    EMPTY = '没有肉我就要饿死了！你这白痴！',
                }
            },
            WINONA = {
                MESSAGE = {
                    FULL = '我今天吃得很饱，去干活了！',
                    HIGH = '胃里还有空间，别藏着掖着了。',
                    MID = '我的午休时间还没到吗？还不开饭！',
                    LOW = '我快没油了，你这黑心老板！',
                    EMPTY = '再不给饭吃，工人就要罢工了！',
                }
            },
            WARLY = {
                MESSAGE = {
                    FULL = '我自己的手艺简直太棒了，吃得好撑！',
                    HIGH = '我现在已经受够食物了。',
                    MID = '该吃晚餐了，别让我亲自动手！',
                    LOW = '我错过了饭点！全怪你这笨蛋！',
                    EMPTY = '饿死是最难受的死法！救命！',
                }
            },
            WORMWOOD = {
                MESSAGE = {
                    FULL = '太多了！装不下了！',
                    HIGH = '肚子里不需要东西。',
                    MID = '可以加点肥料了，喂。',
                    LOW = '肚子需要东西！快点！',
                    EMPTY = '肚子疼死了……救救我……',
                }
            },
            WURT = {
                MESSAGE = {
                    FULL = '格鲁，我吃不下了！别喂了！',
                    HIGH = '我不饿！别烦我！',
                    MID = '我还能吃得下一些，拿来！',
                    LOW = '我很需要食物！快给我！',
                    EMPTY = '我真的很饿很饿！你要饿死我吗！',
                }
            },
            WORTOX = {
                MESSAGE = {
                    FULL = '肚子撑得要命，都怪你喂那么多！',
                    HIGH = '可以去恶作剧了，别来烦我！',
                    MID = '我需要少量的灵魂，快点！',
                    LOW = '我想要一个美味的灵魂！快交出来！',
                    EMPTY = '我对灵魂的渴望要控制不住了！',
                }
            }
        }
    },
    BLOOMNESS = {
        FORMATS = { DEFAULT = '({SYMBOL} Lv：{LEVEL} | {CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    STAGE_0 = '需要肥料！还不快去拿！',
                    STAGE_1 = '感觉要开花了！别一直盯着看！',
                    STAGE_2 = '正在生长！别催！',
                    STAGE_3 = '盛开中！漂亮吧？哼！',
                    STAGE_4 = '正在枯萎！都是你没照顾好！',
                    STAGE_5 = '感觉要谢了！烦死了……',
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
            LUCK = '听着，我现在的幸运值是：{CURRENT}！别扯我后腿！' 
        },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '坎普斯要来了！这下被你这笨蛋害惨了！',
                    HIGH = '感觉到坎普斯的注视了……小心点啊你！',
                    MID = '稍微干了一点坏事而已，有什么大不了的！',
                    LOW = '我还算个好人，别拿那种眼神看我！',
                    EMPTY = '我可是个遵纪守法的好市民！别怀疑我！',
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
                    FULL = '高于75%……脑子清醒得很！我才没发疯呢！',
                    HIGH = '55%……感觉还不错！用不着你瞎操心！',
                    MID = '35%……我有点焦虑了！别烦我！',
                    LOW = '15%……这里太疯狂了！快想办法啊笨蛋！',
                    EMPTY = '低于15%……啊！暗影恶魔在追我！快救我啊笨蛋！',
                },
                SYMBOL = { EMOJI = 'sanity', TEXT = '脑残值' }
            },
            WILSON = {
                MESSAGE = {
                    FULL = '理智很正常！不需要你管！',
                    HIGH = '我会好起来的，别多嘴。',
                    MID = '我的头很痛……闭嘴别吵我！',
                    LOW = '那、那些行走的是什么怪物！？快赶走它们！',
                    EMPTY = '救命！这些东西要吃掉我了！！你还在看什么！',
                }
            },
            WILLOW = {
                MESSAGE = {
                    FULL = '我现在精神很好！能烧了这片林子！',
                    HIGH = '我看到伯尼走路了……绝对不是幻觉！',
                    MID = '我觉得好冷……快点生火啊！',
                    LOW = '伯尼，为什么我觉得这么冷！？',
                    EMPTY = '伯尼！保护我别被这些怪物咬到！',
                }
            },
            WOLFGANG = {
                MESSAGE = {
                    FULL = '沃尔夫冈头脑很清醒！不需要你操心！',
                    HIGH = '沃尔夫冈的头感觉有点奇怪……',
                    MID = '沃尔夫冈的头很疼，别来烦我！',
                    LOW = '沃尔夫冈看到了可怕的怪物！快躲开！',
                    EMPTY = '到处都是怪物！！沃尔夫冈要逃跑了！',
                }
            },
            WENDY = {
                MESSAGE = {
                    FULL = '我的思维运转得很清晰，用不着你管。',
                    HIGH = '我的思维变得阴郁了……离我远点。',
                    MID = '我的思维极度兴奋……别惹我。',
                    LOW = '阿比盖尔！你看到恶魔了吗？快把它们赶走！',
                    EMPTY = '别过来！暗影生物！阿比盖尔救我！',
                }
            },
            WX78 = {
                MESSAGE = {
                    FULL = 'CPU状态：全面运转。算你这肉体识相。',
                    HIGH = 'CPU状态：功能正常。',
                    MID = 'CPU状态：破损。快给我修理笨蛋！',
                    LOW = 'CPU状态：故障迫近。你耳朵聋了吗！',
                    EMPTY = 'CPU状态：多重故障！要完蛋了蠢货！',
                }
            },
            WICKERBOTTOM = {
                MESSAGE = {
                    FULL = '这里没有什么是非理智的，我清醒得很。',
                    HIGH = '我稍微有点头痛，别吵我。',
                    MID = '偏头痛难以忍受！还不快给我找点恢复的药！',
                    LOW = '哪些是虚构的？！快点帮帮我！',
                    EMPTY = '帮帮我！这些敌人太可憎了！别站在那里看戏！',
                }
            },
            WOODIE = {
                MESSAGE = {
                    FULL = '状态好极了，别来打扰我砍树。',
                    HIGH = '还好，给我来杯咖啡！',
                    MID = '我需要午睡！别出声！',
                    LOW = '退后！噩梦一样的东西！快来帮忙！',
                    EMPTY = '恐惧都是真实的！伤害也是！救命啊！',
                }
            },
            WES = {
                MESSAGE = {
                    FULL = '*傲慢地行了个礼，不再理你*',
                    HIGH = '*不情愿地竖起大拇指*',
                    MID = '*用力揉着太阳穴，瞪你一眼*',
                    LOW = '*疯狂扫视四周，吓得直发抖*',
                    EMPTY = '*抱着头来回摇摆，绝望求救*',
                }
            },
            WAXWELL = {
                MESSAGE = {
                    FULL = '状态不错。别以为这有什么大不了的。',
                    HIGH = '我的智慧似乎在摇摆……别多嘴！',
                    MID = 'Ugh，我头好痛。滚远点。',
                    LOW = '我需要清醒头脑！那些幻影来了！快想想办法！',
                    EMPTY = '救命！这些阴影是真的！你到底管不管我！',
                }
            },
            WEBBER = {
                MESSAGE = {
                    FULL = '我们健康又精力充沛！不用你操心！',
                    HIGH = '我们需要小睡一会！别吵！',
                    MID = '我们的头好痛……呜呜……',
                    LOW = '上次午睡是什么时候？！全怪你！',
                    EMPTY = '我们不害怕你！走开，可怕的东西！',
                }
            },
            WATHGRITHR = {
                MESSAGE = {
                    FULL = '我可不怕什么凡人的恐惧！哼！',
                    HIGH = '战场上我感觉更好！',
                    MID = '我思绪有点迷离……别趁机偷袭我！',
                    LOW = '阴影穿过了我的矛！快点来支援我！',
                    EMPTY = '退后，黑暗怪兽！喂，你也快点来帮忙啊！',
                }
            },
            WINONA = {
                MESSAGE = {
                    FULL = '我会永远保持理智，用不着你瞎操心。',
                    HIGH = '全部还好！不用你管！',
                    MID = '我的螺丝松了……快给我找扳手！',
                    LOW = '我的心碎了，我得修好它。帮帮忙啊！',
                    EMPTY = '这是场真实的噩梦！救命啊老板！',
                }
            },
            WARLY = {
                MESSAGE = {
                    FULL = '做菜的香味让我神智清醒，你可没这本事。',
                    HIGH = '我觉得有点头晕。别跟我说话。',
                    MID = '我脑筋转不过弯了！都怪你！',
                    LOW = '窃窃私语……救命啊！你还在等什么！',
                    EMPTY = '我受不了这种精神错乱了！快点想办法！',
                }
            },
            WORMWOOD = {
                MESSAGE = {
                    FULL = '感觉很棒！不用你管！',
                    HIGH = '头感觉很好，别碰我。',
                    MID = '头痛，但还可以忍受！',
                    LOW = '恐怖的东西在看我！快把它赶走！',
                    EMPTY = '恐怖的东西在伤害我！好痛啊！',
                }
            },
            WURT = {
                MESSAGE = {
                    FULL = '好开心！才不是因为你呢！',
                    HIGH = '精神很好，小花。',
                    MID = '格鲁，我的头受伤了，好疼！',
                    LOW = '可怕的黑影过来了！快保护我！',
                    EMPTY = '格鲁！可怕的噩梦怪物来了！救命！',
                }
            },
            WORTOX = {
                MESSAGE = {
                    FULL = '头脑清醒，欢乐时光来了！Hyuyu！',
                    HIGH = '给我吸点灵魂保持清醒！快点！',
                    MID = '跳太欢了，有点头痛……别笑我！',
                    LOW = '这影子的戏法真气人！快帮忙！',
                    EMPTY = '我陷入疯狂了！快点拿理智药来！',
                }
            }
        }
    },
    HEALTH = {
        FORMATS = { 
            DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}',
            WITH_SHIELD = '({SYMBOL}：{CURRENT}/{MAX}，破护盾：{SHIELD_CUR}/{SHIELD_MAX}) {MESSAGE}'
        },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '100%……满血啦！我才不需要你的治疗呢！',
                    HIGH = '75%……受了点小伤而已，用不着你大惊小怪！',
                    MID = '50%……严重挂彩了！还愣着干嘛，快给我找药！',
                    LOW = '25%……血肉模糊了……呜，好痛，你个笨蛋怎么不保护我！',
                    EMPTY = '低于25%……我快不行了……快救我啊笨蛋！',
                },
                SYMBOL = { EMOJI = 'heart', TEXT = '生命' },
            },
            WILSON = {
                MESSAGE = {
                    FULL = '我健康得很，别拿那种看病人的眼神看我！',
                    HIGH = '只是受了点轻伤，我可以继续走！',
                    MID = '我……我需要治疗了，还不快点拿药来！',
                    LOW = '流了好多血……好痛……笨蛋快救我……',
                    EMPTY = '我走不动了……你这笨蛋还不快想办法……',
                }
            },
            WILLOW = {
                MESSAGE = {
                    FULL = '完美的我怎么可能有伤痕！',
                    HIGH = '一点点擦伤，烧一下就好了！别管我！',
                    MID = '伤口好痛……我需要医生！你听到没有！',
                    LOW = '我好虚弱……快要熄灭了……救救我……',
                    EMPTY = '生命之火要熄灭了……呜呜……笨蛋快救我……',
                }
            },
            WOLFGANG = {
                MESSAGE = {
                    FULL = '沃尔夫冈不需要修理！我很强壮！',
                    HIGH = '需要一点小修理……就一点点！',
                    MID = '沃尔夫冈受伤了，好痛。',
                    LOW = '沃尔夫冈需要很多绷带！快拿来！',
                    EMPTY = '沃尔夫冈要死了……快救救我……',
                }
            },
            WENDY = {
                MESSAGE = {
                    FULL = '痊愈了。但我迟早还会受伤的。',
                    HIGH = '有点痛。但我能忍。',
                    MID = '好痛……我讨厌受伤。',
                    LOW = '流了好多血……是不是放弃比较好……',
                    EMPTY = '我要去见阿比盖尔了……再见，笨蛋……',
                }
            },
            WX78 = {
                MESSAGE = {
                    FULL = '底盘状态：理想。机体完美无缺，别碰我！',
                    HIGH = '底盘状态：轻微裂纹。算什么伤！',
                    MID = '底盘状态：中度损坏。快给我修理笨蛋！',
                    LOW = '底盘状态：严重损坏。你想看着我报废吗！',
                    EMPTY = '底盘状态：即将停机。救命啊蠢货！',
                }
            },
            WICKERBOTTOM = {
                MESSAGE = {
                    FULL = '我健康得很，不劳你费心！',
                    HIGH = '一点擦伤，无关紧要。',
                    MID = '我需要医疗装备！快去准备！',
                    LOW = '再不治疗我就完了！你还愣着！',
                    EMPTY = '立刻马上送我就医！快点！',
                }
            },
            WOODIE = {
                MESSAGE = {
                    FULL = '我健康得像个小伙子！',
                    HIGH = '大难不死，还能继续砍树！',
                    MID = '我需要吃点东西或者用药来恢复！',
                    LOW = '这是痛苦的开始……好痛……',
                    EMPTY = '让我死在树下吧……救命……',
                }
            },
            WES = {
                MESSAGE = {
                    FULL = '*傲娇地摆了个心形，转过头去*',
                    HIGH = '*摸着手臂，不情愿地竖起大拇指*',
                    MID = '*指着伤口，示意你快点给他包扎*',
                    LOW = '*疯狂摇晃受伤的手臂，眼泪汪汪*',
                    EMPTY = '*绝望地倒下，伸手向你求救*',
                }
            },
            WAXWELL = {
                MESSAGE = {
                    FULL = '我安然无恙，用不着你操心。',
                    HIGH = '只是个擦伤而已，大惊小怪。',
                    MID = '我需要打个补丁了，快给我药。',
                    LOW = '这还没到我的天鹅之歌……但也好痛！',
                    EMPTY = '我绝对不要死在这里！快救我！',
                }
            },
            WEBBER = {
                MESSAGE = {
                    FULL = '我们连一丝划痕都没有！哼！',
                    HIGH = '我们需要一个创可贴！快拿来！',
                    MID = '我们需要再贴一个创可贴……好痛。',
                    LOW = '我们浑身剧痛……快救救我们……',
                    EMPTY = '我们还不想死……呜呜呜……',
                }
            },
            WATHGRITHR = {
                MESSAGE = {
                    FULL = '我的皮肤无懈可击！才不怕受伤！',
                    HIGH = '轻伤而已！继续战斗！',
                    MID = '我受伤了，但我还能打！快给我药包扎一下！',
                    LOW = '没有你的援助，我就要去英灵殿了！快点！',
                    EMPTY = '我的传奇人生……快来救我啊笨蛋！',
                }
            },
            WINONA = {
                MESSAGE = {
                    FULL = '我壮得像头牛！不用你担心！',
                    HIGH = '这点小伤我自己能解决！',
                    MID = '我还不能放弃！拿绷带给我！',
                    LOW = '痛死我了，我能领工伤赔偿吗！',
                    EMPTY = '我的轮班要结束了……救命啊老板！',
                }
            },
            WARLY = {
                MESSAGE = {
                    FULL = '我非常健康，别咒我生病！',
                    HIGH = '切菜切到手了，好疼！',
                    MID = '我流血了……还不快给我包扎！',
                    LOW = '我需要援助！你瞎了吗！',
                    EMPTY = '这就是结局了吗……救救我啊笨蛋！',
                }
            },
            WORMWOOD = {
                MESSAGE = {
                    FULL = '没受伤！叶子好好的！',
                    HIGH = '掉了一点皮，没关系！',
                    MID = '好虚弱……好痛……',
                    LOW = '痛得非常严重！快帮忙！',
                    EMPTY = '救救我，好朋友！我要死啦！',
                }
            },
            WURT = {
                MESSAGE = {
                    FULL = '我很健康！小花！不用你管！',
                    HIGH = '感觉很好！哼！',
                    MID = '鳞片掉了一些……快帮我治治！',
                    LOW = '疼得厉害……呜咽……',
                    EMPTY = '救……命……啊！快来救我！',
                }
            },
            WORTOX = {
                MESSAGE = {
                    FULL = '状态绝佳！能尽情恶作剧！',
                    HIGH = '只是擦伤，给我个灵魂修复一下！',
                    MID = '好痛！我需要灵魂来抚平伤口！快给！',
                    LOW = '灵魂变得脆弱了……快救我……',
                    EMPTY = '灵魂要消散了……呜呜……救命……',
                }
            }
        }
    },
    THIRST = {
        FORMATS = { DEFAULT = '({SYMBOL}：{CURRENT}/{MAX}) {MESSAGE}' },
        MAPPINGS = {
            DEFAULT = {
                MESSAGE = {
                    FULL = '喝饱了！别再给我灌水了！',
                    HIGH = '还不怎么渴，你自己喝吧！',
                    MID = '嘴巴有点干了……喂，给我拿点水来！',
                    LOW = '渴死我了！你没看到我缺水吗！',
                    EMPTY = '身体严重脱水……救、救命……给我水……',
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
                    FULL = '高于75%……全身都湿透了！你这笨蛋怎么不给我打伞！',
                    HIGH = '55%……湿透了！背包也浸水了，快点想办法弄干！',
                    MID = '35%……我很湿！烦死了，快点生火啊！',
                    LOW = '15%……湿了一小块而已，别大惊小怪的！',
                    EMPTY = '完全干燥！哼，保持这样最好！',
                },
                SYMBOL = {
                    TEXT = '雨露值'
                },
            },

            WILSON = {
                MESSAGE = {
                    FULL = '彻底湿透了！快给我火堆烤干！',
                    HIGH = '这该死的水快滚出去！',
                    MID = '衣服几乎全湿了，冷死了笨蛋！',
                    LOW = '讨厌的 H2O。别拿滴水的伞靠近我！',
                    EMPTY = '我很干燥。别拿水泼我！',
                }
            },
            WILLOW = {
                MESSAGE = {
                    FULL = '这雨真是烦透了！快点把它停下来！',
                    HIGH = '我讨厌这水！全湿了！',
                    MID = '雨太大了！你要看着我熄灭吗！',
                    LOW = '雨再下大点，我就要熄灭了笨蛋！',
                    EMPTY = '身上干得很，没水能灭我的火！',
                }
            },
            WOLFGANG = {
                MESSAGE = {
                    FULL = '沃尔夫冈变成水做的了！讨厌！',
                    HIGH = '像坐在池塘里一样……沃尔夫冈不喜欢！',
                    MID = '沃尔夫冈讨厌洗澡！快把雨停了！',
                    LOW = '下雨了。沃尔夫冈不喜欢。',
                    EMPTY = '沃尔夫冈是干燥的。这样最好。',
                }
            },
            WENDY = {
                MESSAGE = {
                    FULL = '水世界的末日。烦死了。',
                    HIGH = '湿透了，让人心情烦躁。',
                    MID = '湿软的悲伤。别理我。',
                    LOW = '下雨了……无聊。',
                    EMPTY = '皮肤和心灵一样干巴巴的。',
                }
            },
            WX78 = {
                MESSAGE = {
                    FULL = '受潮状况：临界值！你要谋杀我吗笨蛋！',
                    HIGH = '受潮状况：接近临界！快给我擦干！',
                    MID = '受潮状况：无法接受！水是天敌不懂吗！',
                    LOW = '受潮状况：可容许的。别再弄湿我了！',
                    EMPTY = '受潮状况：合意的。完美干燥！',
                }
            },
            WICKERBOTTOM = {
                MESSAGE = {
                    FULL = '完全绝对浸湿！我的书全毁了你赔吗！',
                    HIGH = '我是湿的！湿的！湿的！听懂了吗快生火！',
                    MID = '快到我的承受极限了！快拿伞来！',
                    LOW = '水膜形成了，讨厌的天气。',
                    EMPTY = '我的水分非常缺乏，很好。',
                }
            },
            WOODIE = {
                MESSAGE = {
                    FULL = '这鬼天气我都不能砍树了！',
                    HIGH = '格子披风都不保暖了，冷死我了！',
                    MID = '获得了相当多的水分，太湿了！',
                    LOW = '格子花纹很温暖但也很潮湿，难受。',
                    EMPTY = '对我几乎没影响，继续干活！',
                }
            },
            WES = {
                MESSAGE = {
                    FULL = '*烦躁地像落水狗一样向上游泳*',
                    HIGH = '*用愤怒的眼神看着天空向上游*',
                    MID = '*悲惨又气愤地瞪着乌云*',
                    LOW = '*拿尾巴当伞，不情愿地武装头部*',
                    EMPTY = '*得意地拿着无形的伞，哼了一声*',
                }
            },
            WAXWELL = {
                MESSAGE = {
                    FULL = '湿透了。我的形象全毁了！',
                    HIGH = '我不认为我还能再变干，糟糕透顶！',
                    MID = '这水毁了我的高定西装！你这笨蛋！',
                    LOW = '潮湿让我变得不整洁，讨厌。',
                    EMPTY = '干燥而整洁，这才是我的风格。',
                }
            },
            WEBBER = {
                MESSAGE = {
                    FULL = '我们湿透了！好难受！',
                    HIGH = '毛皮全被浸泡了！快帮我们擦干！',
                    MID = '我们很湿！冷死了！',
                    LOW = '湿润得让人讨厌，讨厌下雨！',
                    EMPTY = '我们在坑里玩耍，很干燥！',
                }
            },
            WATHGRITHR = {
                MESSAGE = {
                    FULL = '我完全湿透了！铠甲好重！',
                    HIGH = '战士在这样的雨天没法战斗！快想办法！',
                    MID = '我的护甲要生锈了！还不快给我擦干！',
                    LOW = '我不需要洗澡，讨厌水！',
                    EMPTY = '干干净净！继续战斗！',
                }
            },
            WINONA = {
                MESSAGE = {
                    FULL = '我没法在湿度这么大的地方工作！',
                    HIGH = '工作服全吸满水了！重死了！',
                    MID = '放个湿地板标志！差点滑倒！',
                    LOW = '工作补充水分还行，但别太过分！',
                    EMPTY = '干爽得很，继续干活！',
                }
            },
            WARLY = {
                MESSAGE = {
                    FULL = '鱼在衬衫里游泳！快救我！',
                    HIGH = '水会毁了我的完美菜肴！快给我打伞！',
                    MID = '在我感冒前快把衣服烘干！',
                    LOW = '现在不是洗澡时间！讨厌水！',
                    EMPTY = '身上只有几滴水，无所谓。',
                }
            },
            WORMWOOD = {
                MESSAGE = {
                    FULL = '真的真的湿了！要泡烂了！',
                    HIGH = '真的湿了！',
                    MID = '感觉有点湿，不舒服。',
                    LOW = '下雨了！讨厌！',
                    EMPTY = '感到干燥，还算舒服。',
                }
            },
            WURT = {
                MESSAGE = {
                    FULL = '水花溅呀溅！才不是想玩水呢！',
                    HIGH = '鳞片很舒服！别误会！',
                    MID = '美人鱼喜欢水，才不是因为别的！',
                    LOW = '有点水更好……我可没求你下雨！',
                    EMPTY = '太干燥了！烦死了！',
                }
            },
            WORTOX = {
                MESSAGE = {
                    FULL = '我完全湿透了！糟糕透顶！',
                    HIGH = '我是最潮湿的恶魔！才不高兴呢！',
                    MID = '会有只湿漉漉的恶魔！快给我生火！',
                    LOW = '世界赐予我淋浴！讨厌！',
                    EMPTY = '保持干燥最好！离水远点！',
                }
            }
        }
    },
}