function InitDetectiveQuestTip()
	g_aGameWorldTip[1002] = function(rect)
		local nIconID, szCategory, szName = 0, "默认分类", "默认名字"
		local szTip = ColorText("李屠夫的证词\n", 0) .. ColorText("秀茹妹子那天的确在我这里买肉了，具体时间我记不住了，大概是中午之后吧", 7)
		OutputTip(szTip, 400, rect)
	end

	g_aGameWorldTip[1003] = function(rect)
		local nIconID, szCategory, szName = 0, "默认分类", "默认名字"
		local szTip = ColorText("王氏的证词\n", 0) .. ColorText("秀茹可是个好女孩，说话细声细语的，平时大门不出二门不迈，也就找几个闺房密友去家里下棋。", 7)
		OutputTip(szTip, 400, rect)
	end

	g_aGameWorldTip[1004] = function(rect)
		local nIconID, szCategory, szName = 0, "默认分类", "默认名字"
		local szTip = ColorText("仵作的证词\n", 0) .. ColorText("尸体被发现的时候是平躺在地面上，死亡时间大概是午时后一刻，致命死因是胸口的剪刀刀伤，刀口向上，应该是蓄意伤人，凶器就扔在旁边。周围有搏斗的痕迹。", 7)
		OutputTip(szTip, 400, rect)
	end

	g_aGameWorldTip[1005] = function(rect)
		local nIconID, szCategory, szName = 0, "默认分类", "默认名字"
		local szTip = ColorText("张屠夫的证词\n", 0) .. ColorText("那天啊，正好我家里有事，中午就没开张。", 7)
		OutputTip(szTip, 400, rect)
	end

	g_aGameWorldTip[1006] = function(rect)
		local nIconID, szCategory, szName = 0, "默认分类", "默认名字"
		local szTip = ColorText("焦枯的树枝\n", 0) .. ColorText("残留着冷石灰的烧焦的树枝。冷石是炼丹产物。有剧毒。", 7)
		OutputTip(szTip, 400, rect)
	end

	g_aGameWorldTip[1007] = function(rect)
		local nIconID, szCategory, szName = 0, "默认分类", "默认名字"
		local szTip = ColorText("炼丹道士的证词\n", 0) .. ColorText("有一位姓林的画师给我银子，让我给他炼制冷石。", 7)
		OutputTip(szTip, 400, rect)
	end

	g_aGameWorldTip[1008] = function(rect)
		local nIconID, szCategory, szName = 0, "默认分类", "默认名字"
		local szTip = ColorText("罗轩的证词\n", 0) .. ColorText("当年武及侵犯了张德的妻子，结果夫妇两被误杀，儿子张白尘失踪。\n武及被害的前天晚上有黑衣人行刺武及未遂，左手受伤。行刺之人极有可能是张白尘。", 7)
		OutputTip(szTip, 400, rect)
	end

	g_aGameWorldTip[1009] = function(rect)
		local nIconID, szCategory, szName = 0, "默认分类", "默认名字"
		local szTip = ColorText("夜行衣\n", 0) .. ColorText("藏在金水镇东北的空宅子里的夜行衣，左袖被划了一道口子，上面还沾着血渍。", 7)
		OutputTip(szTip, 400, rect)
	end

	g_aGameWorldTip[1010] = function(rect)
		local nIconID, szCategory, szName = 0, "默认分类", "默认名字"
		local szTip = ColorText("武及的验尸报告\n", 0) .. ColorText("死亡时间大概是昨日入夜戌时；死亡原因是有一根绣花针刺入脑门要害处。", 7)
		OutputTip(szTip, 400, rect)
	end

	g_aGameWorldTip[1011] = function(rect)
		local nIconID, szCategory, szName = 0, "默认分类", "默认名字"
		local szTip = ColorText("凶器·绣花针\n", 0) .. ColorText("这根绣花针有点特别，半银半铜所制，上半部分是银色，下半部分是金色。", 7)
		OutputTip(szTip, 400, rect)
	end

	g_aGameWorldTip[1012] = function(rect)
		local nIconID, szCategory, szName = 0, "默认分类", "默认名字"
		local szTip = ColorText("武晖的证词\n", 0) .. ColorText("罗轩急匆匆地从外头跑回来进房子里和爹说了什么，然后就出来带一群人往贡橘林去了。之后爹呆在房间里一直没什么动静，第二天起来发现爹爹已死去多时。", 7)
		OutputTip(szTip, 400, rect)
	end

	g_aGameWorldTip[1013] = function(rect)
		local nIconID, szCategory, szName = 0, "默认分类", "默认名字"
		local szTip = ColorText("小叫花的证词\n", 0) .. ColorText("那个人是个左撇子！嗯，没错！他给我冷石，付我银两都是用的左手，从来就没见他动过右手，这点我记得很清楚！我当时还纳闷的，金水镇我没见过有左撇子的啊！", 7)
		OutputTip(szTip, 400, rect)
	end

	g_aGameWorldTip[1014] = function(rect)
		local nIconID, szCategory, szName = 0, "默认分类", "默认名字"
		local szTip = ColorText("武晴的证词一\n", 0) .. ColorText("当天我吃完晚饭就买绣花针去了。我的绣花针被罗轩叔叔借去挑刺给弄丢了。", 7)
		OutputTip(szTip, 400, rect)
	end

	g_aGameWorldTip[1015] = function(rect)
		local nIconID, szCategory, szName = 0, "默认分类", "默认名字"
		local szTip = ColorText("武晴的证词二\n", 0) .. ColorText("罗轩叔叔右手被刺伤了，流了好多血！大夫说都伤到筋了。说不定，说不定右手就给废了。", 7)
		OutputTip(szTip, 400, rect)
	end

	g_aGameWorldTip[1016] = function(rect)
		local nIconID, szCategory, szName = 0, "默认分类", "默认名字"
		local szTip = ColorText("鉴定过的凶器\n", 0) .. ColorText("这正是被罗轩借去的武晴的绣花针。", 7)
		OutputTip(szTip, 400, rect)
	end

	g_aGameWorldTip[1017] = function(rect)
		local nIconID, szCategory, szName = 0, "默认分类", "默认名字"
		local szTip = ColorText("林白轩的画\n", 0) .. ColorText("林白轩作的画，上面白色的云雾皆是用冷石粉所图，吸入过多冷石粉便会中毒而死。", 7)
		OutputTip(szTip, 400, rect)
	end

	g_aGameWorldTip[1001] = function(rect)
		local nIconID, szCategory, szName = 0, "默认分类", "默认名字"
		local szTip = ColorText("成步堂的证词\n", 0) .. ColorText("将案件相关的证据出示给对方，用以引出新的话题或者指明矛盾等。", 7)
		OutputTip(szTip, 400, rect)
	end

	g_aGameWorldTip[1028] = function(rect)
		local nIconID, szCategory, szName = 0, "默认分类", "默认名字"
		local szTip = ColorText("封仵作的验尸报告\n", 0) .. ColorText("尸体被发现的时候是躺在床上，死亡时间大概是丑时三刻，致命死因是脖子上的刀伤，伤口极深，应该是蓄意杀人，凶器是胡府厨房的解腕尖刀。陈福生的遗体则是被发现悬吊在镇外的一颗大树上，口眼开，手散发乱，喉下血脉不行，痕迹浅淡，也不抵齿，项肉上有指爪痕，实为被人勒死再假作自缢。", 7)
		OutputTip(szTip, 400, rect)
	end

	g_aGameWorldTip[1040] = function(rect)
		local nIconID, szCategory, szName = 0, "默认分类", "默认名字"
		local szTip = ColorText("胡相仁的证词\n", 0) .. ColorText("那晚我把醉了的老爷扶回他的卧室后，便吩咐丫鬟金焕儿好生伺候，自己便回去继续喝酒直到喝醉。", 7)
		OutputTip(szTip, 400, rect)
	end

	g_aGameWorldTip[1031] = function(rect)
		local nIconID, szCategory, szName = 0, "默认分类", "默认名字"
		local szTip = ColorText("刻有“贺”字的玉佩\n", 0) .. ColorText("我在凶案现场捡到一个刻有“贺”字的玉佩，整个胡府我就只见过大奶奶贺玉琼戴过这种样式的。", 7)
		OutputTip(szTip, 400, rect)
	end

	g_aGameWorldTip[1032] = function(rect)
		local nIconID, szCategory, szName = 0, "默认分类", "默认名字"
		local szTip = ColorText("鉴定过的玉佩\n", 0) .. ColorText("这个玉佩我已经送给表哥章闻京了。", 7)
		OutputTip(szTip, 400, rect)
	end

	g_aGameWorldTip[1042] = function(rect)
		local nIconID, szCategory, szName = 0, "默认分类", "默认名字"
		local szTip = ColorText("贺玉琼的证词一\n", 0) .. ColorText("章闻京表哥前天晚上来见我的时候，身上还戴着我送给他的玉佩。", 7)
		OutputTip(szTip, 400, rect)
	end

	g_aGameWorldTip[1041] = function(rect)
		local nIconID, szCategory, szName = 0, "默认分类", "默认名字"
		local szTip = ColorText("贺玉琼的证词二\n", 0) .. ColorText("章闻京表哥说，他很快就能让我永远摆脱那可恶的胡唯年。", 7)
		OutputTip(szTip, 400, rect)
	end

	g_aGameWorldTip[1035] = function(rect)
		local nIconID, szCategory, szName = 0, "默认分类", "默认名字"
		local szTip = ColorText("乐逵的无声指证\n", 0) .. ColorText("乐逵表示，他打伤了凶手的右肩。", 7)
		OutputTip(szTip, 400, rect)
	end

	g_aGameWorldTip[1036] = function(rect)
		local nIconID, szCategory, szName = 0, "默认分类", "默认名字"
		local szTip = ColorText("景飞燕的珠钗\n", 0) .. ColorText("莫方毅在案发现场捡到这根珠钗，并认出是他妻子景飞燕的。", 7)
		OutputTip(szTip, 400, rect)
	end

	g_aGameWorldTip[1043] = function(rect)
		local nIconID, szCategory, szName = 0, "默认分类", "默认名字"
		local szTip = ColorText("景飞燕的证词\n", 0) .. ColorText("这支珠钗的确是我的，但半个月前它就被慕容芳菲借走了，她如今正在聚贤山庄做客。", 7)
		OutputTip(szTip, 400, rect)
	end

	g_aGameWorldTip[1039] = function(rect)
		local nIconID, szCategory, szName = 0, "默认分类", "默认名字"
		local szTip = ColorText("慕容芳菲的证词\n", 0) .. ColorText("我那不孝女儿钟颖抢走了这支珠钗，说是要拿去献给她师父公治菱。九天前钟颖说要去一趟灵蛇谷那边，我估计就是去莫家堡那边干些见不得光的事！", 7)
		OutputTip(szTip, 400, rect)
	end

end
