ANNOUNCE_STRINGS = {
	-- 这些不是特定于字符的字符串，而是用于缓解翻译。
	-- 注意！在开始和结尾的空格都是重要的，应该保留。
	_NOMU = {
		getArticle = function(name)
			--如果名称以元音字母开头，则使用“an”，否则就使用“a” ——中文用不到，但有很多量词，愿有朝一日能做到区分开，而不全是“个”。
			return "1 个"
		end,
		--如果项目有多个(复数)，词后加{S} ——中文用不到
		--即使在英语中，这也不是完美的，但它已经足够接近了
		S = "个",
		STAT_NAMES = {
			Hunger = "饥饿",
			Sanity = "脑残",
			Health = "生命",
			["Log Meter"] = "木头",
			Wetness = "雨露",
			--其他mod统计数据不会有翻译，但至少我们可以支持这些
		},
		ANNOUNCE_MOON = {
            TODAY = "今晚",
            TOMORROW = "明晚",
            AFTER = "我们刚度过",
            FULLMOON = "月圆",
            NEWMOON = "月黑",
            INTERVAL = "，",
            FORMAT_STRING = "{RECENT}{PHASE1}{INTERVAL}距离下个 {PHASE2} 还有{MOONLEFT}天。",
            FORMAT_FULLMOON = "{RECENT}{PHASE1}{INTERVAL}。",
            FORMAT_NEWMOON = "{RECENT}{PHASE1}{INTERVAL}。"
        },
		ANNOUNCE_ITEM = {
			-- 这需要反映翻译语言的语法
			-- 例如，这可能变成“我的箱子装有6个纸莎草。”
			FORMAT_STRING = "{I_HAVE}{THIS_MANY} {S}{ITEM}{IN_THIS}{CONTAINER}{WITH}{PERCENT}{DURABILITY}{NOMU_STATE}。",

			--其中一个进入了{I_HAVE}
			I_HAVE = "我拥有 ",
			WE_HAVE = "我们拥有 ",

			--{THIS_MANY}是一个数字如有多个，但是单数会因语言而异
			--所以我们用getArticle来得到它

			--{ITEM}是从item.name获得的

			--{S} uses S above

			--进入{IN_THIS}，如果存在
			IN_THIS = " 在这个 ",

			--{CONTAINER}是从 container.name 中获取的

			--其中一个进入{WITH}
			WITH = " 拥有 ", --如果只是一个事物
			AND_THIS_ONE_HAS = ", 这个拥有 ", --如果有多个，只显示一个的耐久性

			--{PERCENT} 是否从产品的耐用性中获得

			--进入 {DURABILITY}
			DURABILITY = " 的耐久度",
			FRESHNESS = " 新鲜度",
		},
		ANNOUNCE_RECIPE = {
			-- 这需要反映翻译语言的语法
			-- 这是一个例子:
			-- "我有一台预制的科学机器，准备就绪" -> 已制作且未放置
			-- "我将做一把斧头。" -> 已知，且有足够原材料
			-- "有人能给我做个炼金术引擎吗？我需要一台科学机器。" -> 未知
			-- "我们需要更多的干燥架。" -> 已知，但没有足够原材料
			FORMAT_STRING = "{START_Q}{TO_DO}{THIS_MANY}{S}{ITEM}{PRE_BUILT}{END_Q}{I_NEED}{A_PROTO}{PROTOTYPER}{FOR_IT}。",

			--{START_Q} 是为那些匹配的语言吗？ 在两端
			START_Q = "", --英语不这么做

			--其中一个进入 {TO_DO}
			I_HAVE = "我做好了 ", --对预构建
			ILL_MAKE = "我可以制作 ", --对于已知的配方，你有原料
			CAN_SOMEONE = "有人可以帮我做 ", --对未知的配方
			WE_NEED = "我需要制造 ", --对于已知的配方，你没有原料

			--{THIS_MANY} 使用getArticle来获得正确的文章 ("a", "an")

			--{ITEM} 来自 recipe.name

			--{S} uses S above

			--进入 {PRE_BUILT}
			PRE_BUILT = " 准备放置",

			--此进入 {END_Q} 如果它是一个问题
			END_Q = "吗？",

			--进入 {I_NEED}
			I_NEED = " 我需要 ",

			--{PROTOTYPER} 来自 recipepopup.teaser:GetString 利用这函数
			getPrototyper = function(teaser)
				--这是句子的精华 "Use a (science machine) to..." 和 "Use an (alchemy engine) to..."
				return teaser:gmatch("<.*>")() or teaser:gmatch("需要(.*)来")()
			end,

			--进入 {FOR_IT}
			FOR_IT = " 才能制造它",
		},
		ANNOUNCE_INGREDIENTS = {
			-- 这就需要反映翻译语言的语法
			-- 这样做的例子:
			-- "我还需要两块石头和一台科学机器来制造炼金术引擎。"
			FORMAT_NEED = "我需要 {NUM_ING} {S}{INGREDIENT}{AND}{A_PROTO}{PROTOTYPER} 来制造 {RECIPE}。",

			--If a prototyper is needed, goes into {AND}
			AND = " 和 ",

			-- 这就需要反映翻译语言的语法
			-- 这样做的例子:
			-- "我有足够的树枝做9个捕鸟器，但我需要一个科学机器。"
			FORMAT_HAVE = "我有足够的 {INGREDIENT} 来制造 {A_REC}{REC_S}{RECIPE}{BUT_NEED}{A_PROTO}{PROTOTYPER}。",
			---{A_REC}
			--如果需要原型，则进入{BUT_NEED}
			BUT_NEED = ", 我还需要 ",
		},
		ANNOUNCE_SKIN = {
			-- 这就需要反映翻译语言的语法
			-- 例如，这可能会变成"我有悲惨的火炬皮肤"
			FORMAT_STRING = "我有 {ITEM} 的『{SKIN}』皮肤。",

			--{SKIN} 来自皮肤的名字

			--{ITEM} 来自物品的名称
		},
		ANNOUNCE_TEMPERATURE = {
			-- 这就需要反映翻译语言的语法
			-- 例如，这可能会变成"我处于一个舒适的温度"
			-- 或者“野兽是冰冷的！”
			FORMAT_STRING = "{PRONOUN} {TEMPERATURE}",

			--{PRONOUN} 是从这里挑选出来的
			PRONOUN = {
				DEFAULT = "我 ",
				BEAST = "这个怪物是 ", --对于 Werebeaver
			},

			--{TEMPERATURE} 是从这里挑选出来的
			TEMPERATURE = {
				BURNING = "过热了！",
				HOT = "几乎过热！",
				WARM = "有点热。",
				GOOD = "在一个舒适的温度。",
				COOL = "稍微有点冷。",
				COLD = "几乎冻结！",
				FREEZING = "“凝固”了！",
			},
		},
		ANNOUNCE_WORLDTEMP = {

			FORMAT_STRING = "{PRONOUN} {TEMPERATURE}",

			PRONOUN = {
				DEFAULT = "我 ",
				BEAST = "这个怪物是 ", --对于 Werebeaver
				WORLD = "这个气候 ", --世界温度宣告-Shang
			},

			--世界温度宣告-Shang
			WORLDTEMP = {
				BURNING = "空调已经停止工作了！",
				HOT = "需要稍微开开空调吧！",
				WARM = "可能需要几台电风扇！",
				GOOD = "很适合安逸生活嬉戏玩耍！",
				COOL = "可以生个火堆！",
				COLD = "需要生个大火堆！",
				FREEZING = "……世界已经冰天雪地了！",
			},
		},
		ANNOUNCE_SEASON = "{SEASON}天还有{DAYS_LEFT}天。",
		ANNOUNCE_GIFT = {
			CAN_OPEN = "我有一个礼物，我要打开它！",
			NEED_SCIENCE = "我需要额外的科学来打开这个礼物！",
		},
		ANNOUNCE_HINT = "宣告",
	},
	-- 下面是一切 character-specific
	UNKNOWN = {
		HUNGER = {
			FULL  = "高于75%…我完全饱了！", 				-- >75%
			HIGH  = "55%…我可以吃一点！",				-- >55%
			MID   = "35%…我肚子饿瘪了！", 				-- >35%
			LOW   = "15%…我非常饿！", 				-- >15%
			EMPTY = "低于15%…我马上要饿扑街了！", 	-- <15%
		},
		SANITY = {
			FULL  = "高于75%…我的大脑在巅峰状态！", 					-- >75%
			HIGH  = "55%…我感觉还不错！", 							-- >55%
			MID   = "35%…我有点焦虑！", 							-- >35%
			LOW   = "15%…我感觉，这里有点疯狂！", 				-- >15%
			EMPTY = "低于15%…啊哒，好疼！暗影恶魔在追我！",		-- <15%
		},
		HEALTH = {
			FULL  = "100%…我去，血槽满了！", 				-- 100%
			HIGH  = "75%…我挂了一些彩！", 				-- >75%
			MID   = "50%…我靠，严重挂彩！", 			-- >50%
			LOW   = "25%…血肉模糊，我已写好遗书！", 	-- >25%
			EMPTY = "低于25%…看管好我的财产！", 	-- <25%
		},
		WETNESS = {
			FULL  = "高于75%…完全湿身！", 					-- >75%
			HIGH  = "55%…我湿透了，哇！背包好隔水，把我装进去吧！",	-- >55%
			MID   = "35%…我很湿！我去，背包也湿了！", 			-- >35%
			LOW   = "15%…我只湿了一小块，还不足为惧！", 			-- >15%
			EMPTY = "我有一点点潮湿……", 								-- <15%
		},
	},
	WILSON = {
		HUNGER = {
			FULL  = "我填满了肚子！",
			HIGH  = "我还不缺乏吃的。",
			MID   = "我可以去吃一点儿。",
			LOW   = "我真的饿了！",
			EMPTY = "我……需要……食物……",
		},
		SANITY = {
			FULL  = "视理智为还可以。",
			HIGH  = "我会好起来的。",
			MID   = "我的头很痛……",
			LOW   = "Wha——那些行走的是什么！？",
			EMPTY = "需要帮助！这些东西将要吃掉我！！",
		},
		HEALTH = {
			FULL  = "健康的如一把小提琴！",
			HIGH  = "我受伤了，但我可以继续行动。",
			MID   = "我……我想我需要注意治疗。",
			LOW   = "我失去了很多血……",
			EMPTY = "我……我将不能走完路程……",
		},
		WETNESS = {
			FULL  = "我已经达到了饱和点！",
			HIGH  = "水快滚出去！",
			MID   = "我的衣服几乎渗透。",
			LOW   = "Oh， H2O。",
			EMPTY = "我比较干燥。",
		},
	},
	WILLOW = {
		HUNGER = {
			FULL  = "如果我不停止吃会发胖的。",
			HIGH  = "愉快又饱满的。",
			MID   = "我的生命之火需要一点燃料。",
			LOW   = "Ugh，我要饿死在这里了！",
			EMPTY = "我现在已经饿的几乎皮包骨！",
		},
		SANITY = {
			FULL  = "我认为我现在有充足的精神烧火。",
			HIGH  = "我刚才看到伯尼在行走了么？……没有，不用介意。",
			MID   = "我感觉寒冷无比，我很可能……",
			LOW   = "伯尼，为什么我觉得如此寒冷！？",
			EMPTY = "伯尼，保护我不受那些可怕的事物咬伤！",
		},
		HEALTH = {
			FULL  = "完美的我就应该没有一块伤痕！",
			HIGH  = "我有一两处擦伤。我或许应该点燃它们。",
			MID   = "这些裂口使我不再燃烧，我需要个医生……",
			LOW   = "我觉得虚弱……我可能会……熄灭。",
			EMPTY = "我的生命之火几乎要熄灭……",
		},
		WETNESS = {
			FULL  = "Ugh，这雨是最——坏——的！",
			HIGH  = "我讨厌这一切水！",
			MID   = "这场雨太多了。",
			LOW   = "Uh oh，如果这场雨持续上升……",
			EMPTY = "没有足够的雨水能灭了火。",
		},
	},
	WOLFGANG = {
		HUNGER = {
			FULL  = "沃尔夫冈是充实而强大的！",
			HIGH  = "沃尔夫冈必须吃饱，才能变得更加强大！！",
			MID   = "沃尔夫冈需要吃很多。",
			LOW   = "沃尔夫冈的肚子饿的开洞了。",
			EMPTY = "沃尔夫冈现在急需要食物！！！",
		},
		SANITY = {
			FULL  = "沃尔夫冈的头感觉良好！",
			HIGH  = "沃尔夫冈的头感觉很有趣。",
			MID   = "沃尔夫冈的头很疼",
			LOW   = "沃尔夫冈看到可怕的怪物……",
			EMPTY = "到处都是可怕的怪物！！",
		},
		HEALTH = {
			FULL  = "沃尔夫冈现在不需要修理！",
			HIGH  = "沃尔夫冈需要点小修理",
			MID   = "沃尔夫冈受伤了。",
			LOW   = "沃尔夫冈需要很多的绷带来治疗伤口。",
			EMPTY = "沃尔夫冈或许要死了……",
		},
		WETNESS = {
			FULL  = "沃尔夫冈现在可能是水做的！",
			HIGH  = "这就像坐在池塘里……",
			MID   = "沃尔夫冈不喜欢洗澡。",
			LOW   = "雨水时代。",
			EMPTY = "沃尔夫冈是干燥的。",
		},
	},
	WENDY = {
		HUNGER = {
			FULL  = "即使再多的食物也不会填补我心中的空洞。",
			HIGH  = "我饱了，但仍渴望没有朋友可以提供的东西。",
			MID   = "我不饿，但也不饱。很奇怪的感觉。",
			LOW   = "我的肚子就像心灵一样充满了空虚。",
			EMPTY = "我发现最慢的死法——饿死。",
		},
		SANITY = {
			FULL  = "我的思维运转地晶莹剔透。",
			HIGH  = "我的思维渐渐变得阴郁。",
			MID   = "我的思维是极度兴奋的……",
			LOW   = "阿比盖尔！你看到它们了么？这些恶魔可能很快能使我加入你。",
			EMPTY = "带我去阿比盖尔那里，黑暗和夜晚的生物！",
		},
		HEALTH = {
			FULL  = "我痊愈了，但我相信我将再次受到伤害。",
			HIGH  = "我感到疼痛，但是不多。",
			MID   = "生存带来了痛苦，但是我不习惯这么多。",
			LOW   = "流了很多血……将会很容易……",
			EMPTY = "我很快将与阿比盖尔……",
		},
		WETNESS = {
			FULL  = "满是水的末世。",
			HIGH  = "长久的湿润和悲伤。",
			MID   = "湿软而又悲伤。",
			LOW   = "或许这些水分能填补我心灵的虚空。",
			EMPTY = "我的皮肤和我的心灵一样干。",
		},
	},
	WX78 = {
		HUNGER = {
			FULL  = "  燃料 状态：最大容量",
			HIGH  = "  燃料 状态：高的 ",
			MID   = "  燃料 状态：合意的 ",
			LOW   = "  燃料 状态：低的 ",
			EMPTY = "  燃料 状态：危险的 ",
		},
		SANITY = {
			FULL  = "  CPU 状态：全面运转",
			HIGH  = "  CPU 状态：功能的",
			MID   = "  CPU 状态：破损的",
			LOW   = "  CPU 状态：故障迫近",
			EMPTY = "  CPU 状态：多重故障检测",
		},
		HEALTH = {
			FULL  = "  底盘 状态：理想状况",
			HIGH  = "  底盘 状态：裂纹检测",
			MID   = "  底盘 状态：中度损坏",
			LOW   = "  底盘 状态：完全性损坏",
			EMPTY = "  底盘 状态：无功能的",
		},
		WETNESS = {
			FULL  = "  受潮 状况：已达临界值",
			HIGH  = "  受潮 状况：接近临界值",
			MID   = "  受潮 状况：无法接受的",
			LOW   = "  受潮 状况：可容许的",
			EMPTY = "  受潮 状况：合意的",
		},
	},
	WICKERBOTTOM = {
		HUNGER = {
			FULL  = "我应该从事研究工作，而不是填充自己。",
			HIGH  = "充斥的，但不是臃肿的。",
			MID   = "我感觉到有一点饥饿。",
			LOW   = "这个图书管理员需要食物，我是担心害怕的！",
			EMPTY = "如果我不马上进食，就将会饿死！",
		},
		SANITY = {
			FULL  = "在这里没有什么行为是非理智的。",
			HIGH  = "我相信我有一点令人头痛之事。",
			MID   = "这些偏头痛是难以忍受的。",
			LOW   = "我不确定哪些事物是虚构的，再也不！",
			EMPTY = "帮帮我！这些深不可测又令人可憎的敌人！",
		},
		HEALTH = {
			FULL  = "我的健康可以预计我的年龄！",
			HIGH  = "受一些擦伤，但是无关紧要。",
			MID   = "我的医疗需要装配。",
			LOW   = "如果不治疗，这将是我的结局。",
			EMPTY = "我需要立刻马上就医！",
		},
		WETNESS = {
			FULL  = "完全绝对浸湿！",
			HIGH  = "我是湿的，湿的，湿的！重要的事情说三遍！",
			MID   = "我想知道我的最高承受力是……",
			LOW   = "水膜开始形成了 。",
			EMPTY = "我的水分是足够缺乏的。",
		},
	},
	WOODIE = {
		HUMAN = { -- 人类形态
			HUNGER = {
				FULL  = "全部都满了！",
				HIGH  = "对于砍树仍然足够。",
				MID   = "能力需要一个小吃！",
				LOW   = "正餐铃响了！ ",
				EMPTY = "我正在挨饿！",
			},
			SANITY = {
				FULL  = "好的犹如一把小提琴曲",
				HIGH  = "还好，可以来一小杯咖啡",
				MID   = "我想我需要一个午睡！",
				LOW   = "退后，噩梦一般的东西！",
				EMPTY = "所有恐惧都是真实的，还有伤害！",
			},
			HEALTH = {
				FULL  = "合适的犹如一个哨子！",
				HIGH  = "大难不死，必有后福。",
				MID   = "可以和使用一些物品来变得健康",
				LOW   = "这是痛苦真正的开始……",
				EMPTY = "让我永眠…… 在这颗树下……",
			},
			WETNESS = {
				FULL  = "这鬼天气导致我不能砍树。",
				HIGH  = "因为这些雨水让格子花呢不再保暖。",
				MID   = "我获得了相当的水分。",
				LOW   = "格子花呢很温暖，也很潮湿。",
				EMPTY = "对我几乎不受影响。",
			},
			["LOG METER"] = {
				FULL  = "一直有更多的木头，但不是在我的肚子里。",
				HIGH  = "我渴望有一个小树枝。",
				MID   = "木头看起来真的很好吃。",
				LOW   = "我能感觉到诅咒即将来临。",
				EMPTY = "一般这个宣告不可能出现，除非没有成功变身",	--(this shouldn't be possible, he'll become a werebeaver)
			},
		},
		WEREBEAVER = {
			-- HUNGER = { -- werebeaver 没有饥饿值
				-- FULL  = "",
				-- HIGH  = "",
				-- MID   = "",
				-- LOW   = "",
				-- EMPTY = "",
			-- },
			SANITY = {
                FULL  = "野兽的眼睛又大又机灵。",
                HIGH  = "野兽似乎看到了黑色的影子。",
                MID   = "野兽回头因为这里有很多不存在的东西。",
                LOW   = "野兽颤抖着，它的眼睛在抽搐。",
                EMPTY = "野兽在咆哮，似乎被倍增的阴影猎杀。",
			},
			HEALTH = {
				FULL  = "野兽蹦蹦跳跳非常活泼。",
				HIGH  = "野兽受到一些擦伤。",
				MID   = "野兽在舔自己的伤口。",
				LOW   = "野兽折断了它的胳膊。",
				EMPTY = "野兽一拐一拐地走着非常可怜。",
			},
			WETNESS = {
				FULL  = "野兽的皮毛完全湿透了。",
				HIGH  = "野兽留下一串小水坑。",
				MID   = "野兽的毛皮有点湿。",
				LOW   = "野兽头上一点水滴。",
				EMPTY = "野兽的毛皮是干燥的。",
			},
			["LOG METER"] = {
				FULL  = "野兽看起来和人类几乎差不多了。",	-- > 90%
				HIGH  = "野兽要咀嚼一个树木。",	-- > 70%
				MID   = "野兽要用力咀嚼一个树枝。",	-- > 50%
				LOW   = "野兽看起来渴望咀嚼那些树。",	-- > 25%
				EMPTY = "野兽看起来很空腹。",	-- < 25%
			},
		},
	},
	WES = {
		HUNGER = {
			FULL  = "*拍拍肚子*",
			HIGH  = "*拍拍肚子*",
			MID   = "*手张开嘴*",
			LOW   = "*手张开嘴，眼睛瞪得大大的*",
			EMPTY = "*紧抓凹陷的胃绝望的一个眼神*",
		},
		SANITY = {
			FULL  = "*行礼*",
			HIGH  = "*翘起姆指*",
			MID   = "*按摩太阳穴*",
			LOW   = "*扫视四处疯狂似地*",
			EMPTY = "*摇篮一样的头，来回摇摆*",
		},
		HEALTH = {
			FULL  = "*手结成心*",
			HIGH  = "*触摸脉搏，竖起大拇指*",
			MID   = "*手在手臂来回移动，示意包扎它*",
			LOW   = "*摇晃手臂*",
			EMPTY = "*大幅摇摆，然后摔倒了*",
		},
		WETNESS = {
			FULL  = "*疯狂地向上游泳*",
			HIGH  = "*向上游泳*",
			MID   = "*悲惨地看向天空*",
			LOW   = "*保护头部武装起来*",
			EMPTY = "*微笑，拿着无形的保护伞*",
		},
	},
	WAXWELL = {
		HUNGER = {
			FULL  = "我已经吃了完美的盛宴。",
			HIGH  = "我很满足，但是不要过量。",
			MID   = "吃个快餐可能很合适。",
			LOW   = "我的内心已经空了。",
			EMPTY = "不！我没有挣到我得到自由将在饿死在这里！",
		},
		SANITY = {
			FULL  = "衣冠楚楚的可以。",
			HIGH  = "我通常坚定的智慧似乎是……摇摆不定。",
			MID   = "Ugh，我头好痛。",
			LOW   = "我需要明确我的头脑，我开始看到……它们。",
			EMPTY = "Help！这些阴影是真正的野兽，你要知道！",
		},
		HEALTH = {
			FULL  = "我完全安然无恙。",
			HIGH  = "它只是一个擦伤。",
			MID   = "我可能需要给自己打个补丁。",
			LOW   = "这不是我的天鹅之歌，但是我已经接近。",
			EMPTY = "不！我没有逃避而死在这里！",
		},
		WETNESS = {
			FULL  = "湿润的好比水本身。",
			HIGH  = "我不认为我会再次干燥。",
			MID   = "这水会毁了我的西装。",
			LOW   = "潮湿使我变得不整洁。",
			EMPTY = "干燥而整洁的。",
		},
	},
	WEBBER = {
		HUNGER = {
			FULL  = "我们两者的胃部都爆满了。",
			HIGH  = "我们可以再多啃一点。",
			MID   = "我们认为是时候吃午饭了！",
			LOW   = "我们此时会吃妈妈的剩菜……",
			EMPTY = "我们的胃是空的！",
		},
		SANITY = {
			FULL  = "我们感觉健康又精力充沛。",
			HIGH  = "小睡一会可以回复一下。",
			MID   = "我们的头好痛……",
			LOW   = "我们上一次有午睡吗？！",
			EMPTY = "我们不害怕你，可怕的东西！",
		},
		HEALTH = {
			FULL  = "我们甚至没有划痕一丝！",
			HIGH  = "我们需要一个创可贴。",
			MID   = "我们需要再贴一个创可贴……",
			LOW   = "我们的身体剧痛……",
			EMPTY = "我们还不想死……",
		},
		WETNESS = {
			FULL  = "哇哈，我们湿透了！",
			HIGH  = "我们的毛皮被浸泡了！",
			MID   = "我们很湿！",
			LOW   = "我们湿润地不讨人喜欢。",
			EMPTY = "我们喜欢在坑里玩耍。",
		},
	},
	WATHGRITHR = {
		HUNGER = {
			FULL  = "我渴望战斗，无需肉！",
			HIGH  = "我足够满足于战斗。",
			MID   = "我可以有一个肉类零食。",
			LOW   = "我渴望一场盛宴！",
			EMPTY = "没有一些肉我就饿死了！",
		},
		SANITY = {
			FULL  = "我担心没有凡人！",
			HIGH  = "我会在战场上感觉更好！",
			MID   = "我迷离的思绪……",
			LOW   = "这些阴影穿过我的矛……",
			EMPTY = "退后，黑暗怪兽！",
		},
		HEALTH = {
			FULL  = "我的皮肤是无懈可击的！",
			HIGH  = "它只是一个轻伤！",
			MID   = "我受伤了，但我还能战斗。",
			LOW   = "没有援助，我很快就会在瓦尔哈拉殿堂……",
			EMPTY = "我的传奇人生即将结束……",
		},
		WETNESS = {
			FULL  = "我完全湿透了！",
			HIGH  = "一个战士在这雨天无法战斗！",
			MID   = "我的护甲会生锈！",
			LOW   = "我不需要洗澡。",
			EMPTY = "干澡够了继续战斗！",
		},
	},
	WINONA = {
		HUNGER = {
			FULL  = "我今天吃了一顿正餐。",
			HIGH  = "我的胃总是有地方放存放更多食物！",
			MID   = "我的午餐休息时间还没到吗？",
			LOW   = "我快没油了，老板。",
			EMPTY = "如果再不给点东西吃，工厂就没有了工人！",
		},
		SANITY = {
			FULL  = "我会永远保持理智。",
			HIGH  = "全部还好但低于我的头巾！",
			MID   = "我想我的螺丝松了……",
			LOW   = "我的心碎了，我应该把它修好。",
			EMPTY = "这是一场噩梦！哈！但它很真实。",
		},
		HEALTH = {
			FULL  = "我健康的犹如一匹汗血宝马！",
			HIGH  = "嗯，我来解决它。",
			MID   = "我仍然不能放弃。",
			LOW   = "我可以领取工人的退休金吗…？",
			EMPTY = "我想我的轮班已经结束了……",
		},
		WETNESS = {
			FULL  = "我不能在这种湿度下工作！",
			HIGH  = "我的工作服正在吸收水份！",
			MID   = "有人应该放下一个湿地板标志。",
			LOW   = "在工作的时候补充水分是总是好的。",
			EMPTY = "这里没有什么。",
		},
	},
	WARLY = {
		HUNGER = {
			FULL  = "我的烹饪将会是我的死亡！",
			HIGH  = "我想现在我已经受够了。",
			MID   = "是时候在沙漠里吃晚餐了。",
			LOW   = "我错过了晚饭时间！",
			EMPTY = "饥饿……是最难受的死亡方式！",
		},
		SANITY = {
			FULL  = "我做菜的香味让我神智清醒。",
			HIGH  = "我觉得有点头晕。",
			MID   = "我的脑筋不能转弯了。",
			LOW   = "窃窃私语……救命啊！",
			EMPTY = "我再也受不了这种精神错乱了！",
		},
		HEALTH = {
			FULL  = "我非常健康。",
			HIGH  = "在切洋葱时我很糟糕。",
			MID   = "我流血了……",
			LOW   = "我可以用一些援助！",
			EMPTY = "我猜这就是我的结局了，挚友们……",
		},
		WETNESS = {
			FULL  = "我能感觉到鱼在我的衬衫里游泳。",
			HIGH  = "水会毁了我完美的菜肴！",
			MID   = "在我感冒之前，我应该把衣服烘干。",
			LOW   = "现在不是洗澡的时间或地点。",
			EMPTY = "只有几滴在我身上，没有坏处。",
		},
	},
	WALANI = {
		HUNGER = {
			FULL  = "嗯，那是在天堂做的一顿饭。",
			HIGH  = "我还可以去吃点小吃。",
			MID   = "食物，食物，食物，重要的事情说三遍！",
			LOW   = "这样我可能会得胃炎！",
			EMPTY = "请……我什么都可以吃！",
		},
		SANITY = {
			FULL  = "没有比冲浪更能让我保持清醒的了。",
			HIGH  = "海浪在呼唤我。",
			MID   = "我的头有点晕。",
			LOW   = "啊~ 我需要我的冲浪板！",
			EMPTY = "那些是什么……东西！？",
		},
		HEALTH = {
			FULL  = "从未有如此美好的感觉！",
			HIGH  = "只有几处刮痕，没什么大惊小怪的。",
			MID   = "我可以用一些治疗药膏！",
			LOW   = "感觉就像我的内脏已经放弃了我。",
			EMPTY = "我身上的每根骨头都碎了！",
		},
		WETNESS = {
			FULL  = "我是彻底湿透了！",
			HIGH  = "我的衣服好像很湿。",
			MID   = "我可能需要一条毛巾。",
			LOW   = "这一点点水不会使任何人受伤。",
			EMPTY = "我看到一场暴风雨即将来临！",
		},
	},
	WOODLEGS = {
		HUNGER = {
			FULL  = "Yarr，那是一顿美餐，拉迪！",
			HIGH  = "我肚子很饱了。",
			MID   = "这是我每天吃饭的时间。",
			LOW   = "啊！你们这些饭桶，让我吃什么呢！？",
			EMPTY = "我要饿死了！",
		},
		SANITY = {
			FULL  = "是的，大海，她是个漂亮的女人！",
			HIGH  = "是时候在海上旅行了！",
			MID   = "我想念我的大海……",
			LOW   = "记不起上次我去航海是什么时候了。",
			EMPTY = "我是一个挥舞弯刀的海盗船长，不是陆地上的傻大个！",
		},
		HEALTH = {
			FULL  = "Yarr，我是个难对付的家伙！",
			HIGH  = "这就是你们所得到的吗？",
			MID   = "我还没有放弃！",
			LOW   = "伍德莱格不是懦夫！",
			EMPTY = "Arr！你赢了，无赖！",
		},
		WETNESS = {
			FULL  = "我浑身湿透了！",
			HIGH  = "我喜欢我的水留在我的船上。",
			MID   = "我的海盗衬衫被水打了。",
			LOW   = "我裤子湿透了！",
			EMPTY = "Arr！正在酝酿一场暴风雨。",
		},
	},
	WILBUR = {
		HUNGER = {
			FULL  = "*跳来跳去拍他的手*",
			HIGH  = "*高兴地拍手*",
			MID   = "*揉肚子*",
			LOW   = "*悲伤的眼神和揉皱的肚皮*",
			EMPTY = "OOAOE! *按摩赫利*",
		},
		SANITY = {
			FULL  = "*敲敲头部*",
			HIGH  = "*竖起大拇指*",
			MID   = "*看起来害怕*",
			LOW   = "*尖叫令人难以忘怀*",
			EMPTY = "OOAOE! OOOAH!",
		},
		HEALTH = {
			FULL  = "*用两只手来做箱子*",
			HIGH  = "*猛击箱子*",
			MID   = "*温柔地按摩缺失的补丁的皮毛*",
			LOW   = "*艰难地惨*",
			EMPTY = "OAOOE! OOOOAE!",
		},
		WETNESS = {
			FULL  = "*打喷嚏*",
			HIGH  = "*按摩手臂在一起*",
			MID   = "Ooo! Ooae!",
			LOW   = "Oooh?",
			EMPTY = "Ooae Oooh Oaoa! Ooooe.",
		},
	},
	WORMWOOD = {
		HUNGER = {
			FULL  = "太多了。",
			HIGH  = "不需要肚子里的东西。",
			MID   = "可以给腹部填加肥料。",
			LOW   = "肚子需要东西。",
			EMPTY = "哦，肚子疼……",
		},
		SANITY = {
			FULL  = "感觉很棒！",
			HIGH  = "头感觉很好。",
			MID   = "头痛，但感觉还好。",
			LOW   = "恐怖的东西在看着我。",
			EMPTY = "恐怖的东西在伤害我！",
		},
		HEALTH = {
			FULL  = "苦艾没有受伤。",
			HIGH  = "缺一点，但还好。",
			MID   = "感到虚弱。",
			LOW   = "疼痛的非常严重。",
			EMPTY = "救救我，好朋友！",
		},
		WETNESS = {
			FULL  = "真的真的湿了！",
			HIGH  = "真的湿了！",
			MID   = "感觉有点湿。",
			LOW   = "下雨了！哦吼！",
			EMPTY = "感到干燥。",
		},
	},
	WURT = {
		HUNGER = {
			FULL  = "格鲁，我不要了。",
			HIGH  = "我不饿, 小花。",
			MID   = "我还能吃得下一些。",
			LOW   = "我很需要食物！",
			EMPTY = "我真的很饿很饿！",
		},
		SANITY = {
			FULL  = "好开心！",
			HIGH  = "精神很好, 小花。",
			MID   = "格鲁, 我的头部受伤了。",
			LOW   = "可怕的黑影要过来了！",
			EMPTY = "格鲁, 可怕的噩梦怪物！！",
		},
		HEALTH = {
			FULL  = "我很健康, 小花!",
			HIGH  = "我感觉很好!",
			MID   = "我需要帮助，我的鳞片掉了一些……",
			LOW   = "呜咽，疼得厉害……",
			EMPTY = "救……命……啊！！！",
		},
		WETNESS = {
			FULL  = "啊哈哈，水花溅呀溅！！",
			HIGH  = "我的鳞片很舒服！",
			MID   = "美人鱼 喜欢水, 小花!",
			LOW   = "啊哈……有点水更好, 小花!",
			EMPTY = "太干燥了, 格鲁.",
		}
	},
	WORTOX = {
		HUNGER = {
			FULL  = "就不应该吃这么饱，肚子撑的要命！",
			HIGH  = "“魂”足饭饱，去恶作剧吧！Hyuyu!",
			MID   = "需要少量的灵... 如此致命。",
			LOW   = "我想要一个美味的灵魂！恶作剧暂且延后！",
			EMPTY = "我对灵魂的渴望越来越贪婪！",
		},
		SANITY = {
			FULL  = "头脑清醒...欢乐时光即将到来！Hyuyu!",
			HIGH  = "我能吸点灵魂来保持我头脑清醒吗?",
			MID   = "害！刚太跳了，现在有点头痛...",
			LOW   = "我好羡慕这些影子的戏法! Hyuyu!",
			EMPTY = "我的思想处于一个纯粹疯狂的新境界!",
		},
		HEALTH = {
			FULL  = "我现在状态绝佳，可以尽情捣蛋！",
			HIGH  = "只是擦伤，一个灵魂就可以把它修复！",
			MID   = "我需要一些灵魂来抚平这些伤口... Hyuyu!",
			LOW   = "我自己的灵魂开始变得脆弱...",
			EMPTY = "我的灵魂将不再属于我! Hyuyu...",
		},
		WETNESS = {
			FULL  = "我完全湿透了!",
			HIGH  = "我就是这条街最潮湿的恶魔!",
			MID   = "不久的将来这会有一只湿漉漉的恶魔！",
			LOW   = "世界正赐予我一场淋浴!",
			EMPTY = "如果我想保持干燥的话，我应该都留意一下天气！",
		}
	},
}
