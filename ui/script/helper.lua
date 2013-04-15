local HELPER_START = 1200
local BIT_NUMBER = 8

Helper = {}

function Helper.GetLoadingStory()
	local nPos = math.random(1, #(g_tLoad.aStory))
	nPos = math.floor(nPos)
	return g_tLoad.aStory[nPos]
end

function Helper.GetLoadingMsg(bOnlyLoading)
	if bOnlyLoading then
		local nPos = math.random(1, #(g_tLoad.aLodingMsg))
		nPos = math.floor(nPos)
		return g_tLoad.aLodingMsg[nPos]
	end
	local nCount = #(g_tLoad.aLodingMsg) + #(g_tLoad.aHotkeyMsg)
	local nPos = math.random(1, nCount)
	nPos = math.floor(nPos)
	if nPos > #(g_tLoad.aLodingMsg) then
		nPos = nPos - #g_tLoad.aLodingMsg
		local szMsg = g_tLoad.aHotkeyMsg[nPos]
		szMsg = string.gsub(szMsg, "<KEY (.-)>", Helper.GetHotkey)
		return szMsg
	end
	return g_tLoad.aLodingMsg[nPos]
end

function Helper.GetHotkey(s, bSecond)
	if bSecond then
		local nKey, bShift, bCtrl, bAlt = Hotkey.Get(s, 2)
		local szKey = GetKeyShow(nKey, bShift, bCtrl, bAlt)
		if not szKey or szKey == "" then
			szKey = "<" .. s .. ">"
		end
		return szKey
	end
	local nKey, bShift, bCtrl, bAlt = Hotkey.Get(s)
	local szkey = GetKeyShow(nKey, bShift, bCtrl, bAlt)
	if not szkey or szkey == "" then
		nKey, bShift, bCtrl, bAlt = Hotkey.Get(s, 2)
		szkey = GetKeyShow(nKey, bShift, bCtrl, bAlt)		
	end
	
	if not szkey or szkey == "" then
		szkey = "<" .. s .. ">"
	end
	return szkey
end

function Helper.IsFirstTimeDo(szName)
	local nEvent = Helper.aFirst[szName] - HELPER_START + 1
	local nBit = nEvent % BIT_NUMBER
	if nBit == 0 then
		nBit = BIT_NUMBER
	end
	local nIndex = math.ceil(nEvent / BIT_NUMBER) + HELPER_START
	local nNumber = GetUserPreferences(nIndex, "c")
	
	if not GetNumberBit(nNumber, nBit) then
		return true
	end
	return false
end

function Helper.SetHasDo(szName)
	local nEvent = Helper.aFirst[szName] - HELPER_START + 1
	local nBit = nEvent % BIT_NUMBER
	if nBit == 0 then
		nBit = BIT_NUMBER
	end
	local nIndex = math.ceil(nEvent / BIT_NUMBER) + HELPER_START
	local nNumber = GetUserPreferences(nIndex, "c")
	nNumber = SetNumberBit(nNumber, nBit, true)
	
	SetUserPreferences(nIndex, "c", nNumber)
end

function Helper.GetFormatedText(szText)
	local szResult = ""
	local nFirst, nLast, szKey = string.find(szText, "<(.-)>")
	while nFirst do
		local szPrev = string.sub(szText, 1, nFirst - 1)
		if szPrev and szPrev ~= "" then
			szResult = szResult .. szPrev
		end
		if szKey and szKey ~= "" then
			szResult = szResult .. Helper.GetHotkey(szKey)
		end
		
		szText = string.sub(szText, nLast + 1, -1)		
		nFirst, nLast, szKey = string.find(szText, "<(.-)>")
	end 
	if szText and szText ~= "" then
		szResult = szResult .. szText
	end
	
	return szResult
end


-- 这里定义了第一次做XX事情用的标志位名, 默认读取 ConditionDefine 表的第一行自动生成;
Helper.aFirst = {
	EnterGame = 1200,
	HealthLow = 1201,
	EnterFight = 1202,
	AcceptQuest = 1203,
	Death = 1204,
	ApplyFight = 1205,
	Slaughter = 1206,
	Vendetta = 1207,
	GetMeleeWeapon = 1208,
	GetPackage = 1209,
	GetPotion = 1210,
	DoTargetStub = 1211,
	OpenTradePanel = 1212,
	EquipMeleeWeapon = 1213,
	DoTargetLiudahai = 1214,
	MakeParty = 1215,
	DragSkill10ToActionBar = 1216,
	TalkToFlyer = 1217,
	GetBook = 1218,
	ProTo25Lv = 1219,
	TailorTo45Lv = 1220,
	LeechcraftTo45Lv = 1221,
	SmithingTo45Lv = 1222,
	ChangeSceneNew = 1223,
	GetArrow = 1224,
	GetHorse = 1225,
	MiningTo25Lv = 1226,
	HerbalTo25Lv = 1227,
	CorpseTo25Lv = 1228,
	CookTo25Lv = 1229,
	TailorTo25Lv = 1230,
	SmithingTo25Lv = 1231,
	LeechtTo25Lv = 1232,
	LearnNeiGong = 1233,
	UseNeiGong = 1234,
	UseProps = 1235,
	CommentChooseQuest = 1236,
	CommentAcceptQuest = 1237,
	CommentFinishQuest = 1238,
	CommentOnDragSkill = 1239,
	Add482Buff = 1240,
	OpenMiddleMap = 1241,
	On20LevelMakeParty = 1242,
	OpenEditBox = 1243,
	OpenShopPanel = 1244,
	KillEnemy = 1245,
	OpenLootPanel = 1246,
	BagFull = 1247,
	OpenMatrixPanel = 1248,
	OpenMailPanel = 1249,
	OpenBankPanel = 1250,
	BagPanelFull = 1251,
	QuestPanelFull = 1252,
	OneBookListReaded = 1253,
	ClickReadedBook = 1254,
	DoTargetPlayer = 1255,
	ReadTo25Lv = 1256,
	ReadTo45Lv = 1257,
	TailorMaxLvTo70Lv = 1258,
	LeechcraftMaxLvTo70Lv = 1259,
	SmithingMaxLvTo70Lv = 1260,
	Accpet803Quest = 1261,
	Accpet806Quest = 1262,
	Accpet808Quest = 1263,
	Accpet3059Quest = 1264,
	Accpet815Quest = 1265,
	CanLearnVenation = 1266,
	EquipWarning = 1267,
	EquipDamage = 1268,
	ComprehendSkill = 1269,
	HerbalTo45Lv = 1270,
	CorpseTo45Lv = 1271,
	CookTo45Lv = 1272,
	DissectingTo25Lv = 1273,
	MiningTo45Lv = 1274,
	DissectingTo45Lv = 1275,
	ReadTo15Lv = 1276,
	CommentKungFu = 1277,
	CommentOneKungFu = 1278,
	AssistQuestFull = 1279,
	AcceptAssistQuest = 1280,
	WithoutStaminaOrThew = 1281,
	AddFriend = 1282,
	CommentAssistQuest = 1283,
	CommentAssistQuestFull = 1284,
	CommentRenmai = 1285,
	CanLearnThreeVenation = 1286,
	NPCBusyFirstTime = 1287,
	NPCBusySecondTime = 1288,
	Accpet812Quest = 1289,
	Accpet831Quest = 1290,
	Accpet801Quest = 1291,
	CanLearnQiXue = 1292,
	GetContribute = 1293,
	OpenRaidPanel = 1294,
	TraceFinishQuest = 1295,
	GetContribution = 1296,
	OpenLootRoolPanel = 1297,
	QuestFailed = 1298,
	Accept1048Quest = 1299,
	GetBookBag = 1300,
	DialogeToMaster = 1301,
	CommentToMining = 1302,
	CommjentToHerbal = 1303,
	Accept835Quest = 1304,
	Accept849Quest = 1305,
	JoinTong = 1306,
	CreateTong = 1307,
	AcceptMail = 1308,
	ByCarriage = 1309,
	CloseCoures = 1310,
	Accept818Quest = 1311,
	GetPackageTwo = 1312,
	GetPackageThree = 1313,
	OpenLootPanelSecond = 1314,
	OpenLootPanelThird = 1315,
	CommentChooseQuestSecond = 1316,
	CommentChooseQuestThird = 1317,
	CommentAcceptQuestSecond = 1318,
	CommentAcceptQuestTird = 1319,
	CommentFinishQuestSecond = 1320,
	CommentFinishQuestThird = 1321,
	TraceFinishQuestSecond = 1322,
	TraceFinishQuestThird = 1323,
	LearnSkillPanel = 1324,
	LearnSkillPanelSecond = 1325,
	LearnSkillPanelThird = 1326,
	GetClothes = 1327,
	GetClothesSecond = 1328,
	GetClothesThird = 1329,
	DialogeToMasterSecond = 1330,
	DialogeToMasterThird = 1331,
	ChooseCompleteQuest = 1332,
	ChooseCompleteQuestSecond = 1333,
	ChooseCompleteQuestThird = 1334,
	CloseUserActionChoose = 1335,
	Accept833Quest = 1336,
	Accept813Quest = 1337,
	Accept825Quest = 1338,
	Accept839Quest = 1339,
	Accept832Quest = 1340,
	Accept800Quest = 1341,
	Accept827Quest = 1342,
	MidMapGuideFirst = 1343,
	MidMapGuideSecond = 1344,
	MidMapGuideThird = 1345,
	GetPackageFour = 1346,
	GetPackageFive = 1347,
	GetGrayThings = 1348,
	GetGreenThings = 1349,
	GetBlueThings = 1350,
	Accept3032Quest = 1351,
	Accept1032Quest = 1352,
	PackageLearn = 1353,
	Accept844Quest = 1354,
	CommentToOpenPartyRecruit = 1355,
	GetQuestGuideIcon = 1356,
	CommentToSwithSword = 1357,
	LearnFuYaoOne = 1358,
	LearnFuYaoSeven = 1359,
	GetNewPresentOne = 1360,
	GetNewPresentTwo = 1361,
	GetNewPresentThree = 1362,
	KnowGuild = 1363,
	GuildCont55000 = 1364,
	FirstGetJustice = 1365,
	FirstGetPrestige = 1366,
	FirstGetPointTitle = 1367,
	FirstGetArenaAware = 1368,
	FirstGetExamPrint = 1369,
	FirstGetCoin = 1370,
	FirstGetJHZILI = 1371,
	LearnSkill537 = 1372,
	LearnSkill415 = 1373,
	LearnSkill301 = 1374,
	LearnSkill1656 = 1375,
	LearnSkill233 = 1376,
	FirstGetMentorScore = 1377,
	Accept8385Quest = 1378,
};

-- 任务接受
Helper.OnAcceptQuest = function(dwQuestID)
	-- 接受任务：桩畔逝水调息授
	if (true and true) then
	end
	-- 凝血草
	if ((dwQuestID == 829 and Helper.IsFirstTimeDo("Accpet815Quest")) and true) then
		Helper.SetHasDo("Accpet815Quest")
		PlayHelpSound("13")
		PopHelp(Helper.GetFormatedText(g_tTotur.tOperator.COLLECT_ITEM.Text))
		return
	end
	-- 接受任务急中生智火烧贼
	if ((Helper.IsFirstTimeDo("Accept835Quest") and dwQuestID == 835) and true) then
		Helper.SetHasDo("Accept835Quest")
		PlayHelpSound("16")
		PopHelp(Helper.GetFormatedText(g_tTotur.tOperator.DOT.Text))
		return
	end
	-- 接受任务：生天之术
	if ((dwQuestID == 853) and true) then
		PopHelp(Helper.GetFormatedText(g_tTotur.tFight.BUFF.Text))
		return
	end
	-- 接受任务：寻找梁师农
	if ((Helper.IsFirstTimeDo("Accept3032Quest") and dwQuestID == 3032) and true) then
		Helper.SetHasDo("Accept3032Quest")
		PlayHelpSound("21")
		PopHelp(Helper.GetFormatedText(g_tTotur.tQuest.YellowNameNPC.Text))
		return
	end
	-- 接受打木桩任务
	if ((Helper.IsFirstTimeDo("Accpet801Quest") and dwQuestID == 801) and true) then
		Helper.SetHasDo("Accpet801Quest")
		PlayHelpSound("02")
		PopHelp(Helper.GetFormatedText(g_tTotur.tFight.ATTACK.Text))
		return
	end
	-- 接受果子狸任务
	if (true and true) then
	end
	-- 接受任务杀小毛贼
	if (true and true) then
	end
	-- 接受杀八角寨杀手
	if ((Helper.IsFirstTimeDo("Accept844Quest") and dwQuestID == 844) and true) then
		Helper.SetHasDo("Accept844Quest")
		PlayHelpSound("21")
		PopHelp(Helper.GetFormatedText(g_tTotur.tQuest.YellowNameNPC.Text))
		return
	end
	-- 少林轻功
	if (true and true) then
	end
	-- 万花轻功
	if (true and true) then
	end
	-- 天策轻功
	if (true and true) then
	end
	-- 纯阳轻功
	if (true and true) then
	end
	-- 七秀轻功
	if (true and true) then
	end
	-- 五毒轻功
	if (true and true) then
	end
	-- 唐门轻功
	if (true and true) then
	end
	-- 藏剑轻功
	if (true and true) then
	end
end

-- 血量低
Helper.OnHealthLow = function(hObject)
	-- 濒死
	if ((Helper.IsFirstTimeDo("HealthLow")) and true) then
		Helper.SetHasDo("HealthLow")
		PlayHelpSound("04")
		PopHelp(Helper.GetFormatedText(g_tTotur.tFight.HEALTH_LOW.Text))
		local hComment = CreateComment("Comment_HeathLow")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetHoldTime(hComment, 7 * 1000)
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.HEALTH.Text))
		return
	end
end

-- 角色升级
Helper.OnLevelUp = function()
	-- 升到15级
	if ((GetClientPlayer().nLevel == 15) and true) then
		if IsShowHelpPanel() then
	OpenCharacterPanel()
end
		PopHelp(Helper.GetFormatedText(g_tTotur.tKungfu.INTO_DOOR.Text))
		PopHelp(Helper.GetFormatedText(g_tTotur.tCommunicate.START_TRADE.Text))
		return
	end
	-- 升到40级
	if ((GetClientPlayer().nLevel == 40) and true) then
		PlayHelpSound("39")
		PopHelp(Helper.GetFormatedText(g_tTotur.tKungfu.POINT_FOUR.Text))
		Helper.SetHasDo("CanLearnThreeVenation")
		return
	end
	-- 升到30级
	if ((GetClientPlayer().nLevel == 30) and true) then
		PlayHelpSound("44")
		PopHelp(Helper.GetFormatedText(g_tTotur.tCommunicate.TONG.Text))
		return
	end
end

-- 技能学习
Helper.OnLearnSkill = function(dwID, dwLevel)
	-- 一重扶摇
	if ((Helper.IsFirstTimeDo("LearnFuYaoOne") and dwID == 9002) and true) then
		Helper.SetHasDo("LearnFuYaoOne")
		PlayHelpSound("58")
		PopHelp(Helper.GetFormatedText(g_tTotur.tQuest.LearnFuYaoOne.Text))
		return
	end
end

-- 技能升级
Helper.OnSkillLevelUp = function(dwID, dwLevel)
	-- 一重扶摇
	if ((Helper.IsFirstTimeDo("LearnFuYaoOne") and dwID == 9002 and dwLevel == 1) and true) then
		Helper.SetHasDo("LearnFuYaoOne")
		PlayHelpSound("58")
		PopHelp(Helper.GetFormatedText(g_tTotur.tQuest.LearnFuYaoOne.Text))
		return
	end
	-- 七重扶摇
	if ((Helper.IsFirstTimeDo("LearnFuYaoSeven") and dwID == 9002 and dwLevel == 7) and true) then
		Helper.SetHasDo("LearnFuYaoSeven")
		PlayHelpSound("58")
		PopHelp(Helper.GetFormatedText(g_tTotur.tQuest.LearnFuYaoSeven.Text))
		return
	end
end

-- 进入战斗
Helper.OnEnterFight = function(hObject)
	-- 进入战斗
	if ((Helper.IsFirstTimeDo("EnterFight")) and true) then
		Helper.SetHasDo("EnterFight")
		local hComment = CreateComment("Comment_FightState")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetHoldTime(hComment, 7 * 1000)
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.FIGHT.Text))
		return
	end
end

-- 重伤
Helper.OnDeath = function()
	-- 重伤
	if ((Helper.IsFirstTimeDo("Death")) and true) then
		Helper.SetHasDo("Death")
		PlayHelpSound("05")
		PopHelp(Helper.GetFormatedText(g_tTotur.tFight.DEATH.Text))
		return
	end
end

-- 切磋
Helper.OnApplyFight = function()
	-- 切磋
	if ((Helper.IsFirstTimeDo("ApplyFight")) and true) then
		Helper.SetHasDo("ApplyFight")
		PopHelp(Helper.GetFormatedText(g_tTotur.tFight.PK.Text))
		return
	end
end

-- 屠杀
Helper.OnSlaughter = function()
	-- 屠杀
	if ((Helper.IsFirstTimeDo("Slaughter")) and true) then
		Helper.SetHasDo("Slaughter")
		PopHelp(Helper.GetFormatedText(g_tTotur.tFight.SLAUGHTER.Text))
		return
	end
end

-- 仇杀
Helper.OnVendetta = function()
	-- 仇杀
	if ((Helper.IsFirstTimeDo("Vendetta")) and true) then
		Helper.SetHasDo("Vendetta")
		PlayHelpSound("30")
		PopHelp(Helper.GetFormatedText(g_tTotur.tFight.VENDETTA.Text))
		return
	end
end

-- 声望等级改变
Helper.OnReputationUpdate = function(dwForceID)
end

-- 技艺学习
Helper.OnLearnCraft = function(nProfessionID)
	-- 学习到采金
	if ((nProfessionID == 1) and true) then
		PlayHelpSound("31")
		PopHelp(Helper.GetFormatedText(g_tTotur.tCraft.MINNING.Text))
		if IsShowHelpPanel() then
	OpenCraftPanel()
end
		if IsShowHelpPanel() then
	MakeCraftSparking(nProfessionID)
end
		return
	end
	-- 学习到神农
	if ((nProfessionID == 2) and true) then
		PlayHelpSound("31")
		PopHelp(Helper.GetFormatedText(g_tTotur.tCraft.HERBALISM.Text))
		if IsShowHelpPanel() then
	OpenCraftPanel()
end
		if IsShowHelpPanel() then
	MakeCraftSparking(nProfessionID)
end
		return
	end
end

-- 技艺升级
Helper.OnCraftLevelUp = function(nProfessionID, nLevel, nMaxLevel)
	-- 缝纫25级
	if ((nLevel >= 25 and GetClientPlayer().nLevel >= 25 and nProfessionID == 5 and Helper.IsFirstTimeDo("TailorTo25Lv") and nMaxLevel < 50) and true) then
		PopHelp(Helper.GetFormatedText(g_tTotur.tCraft.LEAR_MIDDLE_NEEDLE.Text))
		Helper.SetHasDo("TailorTo25Lv")
		return
	end
	-- 缝纫45级
	if ((nProfessionID == 5 and nLevel >= 45 and GetClientPlayer().nLevel >= 45 and Helper.IsFirstTimeDo("TailorTo45Lv") and nMaxLevel < 70) and true) then
		PopHelp(Helper.GetFormatedText(g_tTotur.tCraft.LEAR_HIGHT_NEEDLE.Text))
		Helper.SetHasDo("TailorTo45Lv")
		return
	end
	-- 医术45级
	if ((nProfessionID == 7 and nLevel >= 45 and GetClientPlayer().nLevel >= 45 and Helper.IsFirstTimeDo("LeechcraftTo45Lv") and nMaxLevel < 70) and true) then
		PopHelp(Helper.GetFormatedText(g_tTotur.tCraft.LEAR_HIGHT_PHYSIC.Text))
		Helper.SetHasDo("LeechcraftTo45Lv")
		return
	end
	-- 铸造45级
	if ((nProfessionID == 6 and nLevel >= 45 and GetClientPlayer().nLevel >= 45 and Helper.IsFirstTimeDo("SmithingTo45Lv") and nMaxLevel < 70) and true) then
		PopHelp(Helper.GetFormatedText(g_tTotur.tCraft.LEAR_HIGHT_FORGING.Text))
		Helper.SetHasDo("SmithingTo45Lv")
		return
	end
	-- 阅读25级
	if ((nProfessionID == 8 and nLevel >= 25 and GetClientPlayer().nLevel >= 25 and Helper.IsFirstTimeDo("ReadTo25Lv") and nMaxLevel < 50) and true) then
		PopHelp(Helper.GetFormatedText(g_tTotur.tCraft.READ_MIDDLE.Text))
		Helper.SetHasDo("ReadTo25Lv")
		if IsShowHelpPanel() then
	OpenCraftReadPanel()
end
		return
	end
	-- 采金25级
	if ((GetClientPlayer().nLevel >= 25 and nLevel >= 25 and nProfessionID == 1 and Helper.IsFirstTimeDo("MiningTo25Lv") and nMaxLevel < 50) and true) then
		PopHelp(Helper.GetFormatedText(g_tTotur.tCraft.LEAR_MIDDLE_GATHER.Text))
		Helper.SetHasDo("MiningTo25Lv")
		return
	end
	-- 神农25级
	if ((nProfessionID == 2 and nLevel >= 25 and GetClientPlayer().nLevel >= 25 and Helper.IsFirstTimeDo("HerbalTo25Lv") and nMaxLevel < 50) and true) then
		PopHelp(Helper.GetFormatedText(g_tTotur.tCraft.LEAR_MIDDLE_AGRICULTURE.Text))
		Helper.SetHasDo("HerbalTo25Lv")
		return
	end
	-- 庖丁术25级
	if ((GetClientPlayer().nLevel >= 25 and nProfessionID == 3 and nLevel >= 25 and Helper.IsFirstTimeDo("DissectingTo25Lv") and nMaxLevel < 50) and true) then
		PopHelp(Helper.GetFormatedText(g_tTotur.tCraft.LEAR_MIDDLE_SEARCH.Text))
		Helper.SetHasDo("DissectingTo25Lv")
		return
	end
	-- 烹饪25级
	if ((nProfessionID == 4 and nLevel >= 25 and GetClientPlayer().nLevel >= 25 and Helper.IsFirstTimeDo("CookTo25Lv") and nMaxLevel < 50) and true) then
		PopHelp(Helper.GetFormatedText(g_tTotur.tCraft.LEAR_MIDDLE_COOKING.Text))
		Helper.SetHasDo("CookTo25Lv")
		return
	end
	-- 铸造25级
	if ((nProfessionID == 6 and nLevel >= 25 and GetClientPlayer().nLevel >= 25 and Helper.IsFirstTimeDo("SmithingTo25Lv") and nMaxLevel < 50) and true) then
		PopHelp(Helper.GetFormatedText(g_tTotur.tCraft.LEAR_MIDDLE_FORGING.Text))
		Helper.SetHasDo("SmithingTo25Lv")
		return
	end
	-- 医术25级
	if ((GetClientPlayer().nLevel >= 25 and nProfessionID == 7 and nLevel >= 25 and Helper.IsFirstTimeDo("LeechtTo25Lv") and nMaxLevel < 50) and true) then
		PopHelp(Helper.GetFormatedText(g_tTotur.tCraft.LEAR_MIDDLE_PHYSIC.Text))
		Helper.SetHasDo("LeechtTo25Lv")
		return
	end
	-- 采金45级
	if ((nLevel >= 45 and GetClientPlayer().nLevel >= 45 and nProfessionID == 1 and Helper.IsFirstTimeDo("MiningTo45Lv") and nMaxLevel < 70) and true) then
		PopHelp(Helper.GetFormatedText(g_tTotur.tCraft.LEAR_HIGHT_GATHER.Text))
		Helper.SetHasDo("MiningTo45Lv")
		return
	end
	-- 神农45级
	if ((nProfessionID == 2 and nLevel >= 45 and GetClientPlayer().nLevel >= 45 and Helper.IsFirstTimeDo("HerbalTo45Lv") and nMaxLevel < 70) and true) then
		PopHelp(Helper.GetFormatedText(g_tTotur.tCraft.LEAR_HIGHT_AGRICULTURE.Text))
		Helper.SetHasDo("HerbalTo45Lv")
		return
	end
	-- 庖丁术45级
	if ((nProfessionID == 3 and nLevel >= 45 and GetClientPlayer().nLevel >= 45 and Helper.IsFirstTimeDo("DissectingTo45Lv") and nMaxLevel < 70) and true) then
		PopHelp(Helper.GetFormatedText(g_tTotur.tCraft.LEAR_HIGHT_SEARCH.Text))
		Helper.SetHasDo("DissectingTo45Lv")
		return
	end
	-- 烹饪45级
	if ((nProfessionID == 4 and nLevel >= 45 and GetClientPlayer().nLevel >= 45 and Helper.IsFirstTimeDo("CookTo45Lv") and nMaxLevel < 70) and true) then
		PopHelp(Helper.GetFormatedText(g_tTotur.tCraft.LEAR_HIGHT_COOKING.Text))
		Helper.SetHasDo("CookTo45Lv")
		return
	end
	-- 阅读45级
	if ((nProfessionID == 8 and nLevel >= 45 and GetClientPlayer().nLevel >= 45 and Helper.IsFirstTimeDo("ReadTo45Lv") and nMaxLevel < 70) and true) then
		PopHelp(Helper.GetFormatedText(g_tTotur.tCraft.READ_HIGHT.Text))
		Helper.SetHasDo("ReadTo45Lv")
		return
	end
	-- 阅读15级
	if ((GetClientPlayer().nLevel >= 15 and nLevel >= 15 and nProfessionID == 8 and Helper.IsFirstTimeDo("ReadTo15Lv")) and true) then
		PopHelp(Helper.GetFormatedText(g_tTotur.tCraft.EXCERPTION.Text))
		Helper.SetHasDo("ReadTo15Lv")
		return
	end
end

-- 学习配方
Helper.OnLearnRecipe = function(nProfessionID, nRecipeID)
end

-- 道具获得
Helper.OnGetItem = function(dwID)
	-- 获得第一个背包
	if ((Helper.IsFirstTimeDo("GetPackage") and GetItem(dwID).nGenre == ITEM_GENRE.EQUIPMENT and GetItem(dwID).nSub == EQUIPMENT_SUB.PACKAGE and GetItem(dwID).dwIndex ~= 33) and true) then
		Helper.SetHasDo("GetPackage")
		if IsShowHelpPanel() then
	OpenAllBagPanel()
end
				local hItem = GetItem(dwID)
		local dwBox, dwX = GetItemPosByItemTypeIndex(hItem.dwTabType, hItem.dwIndex)
		local hObject = nil
		if dwBox and dwX then
		    hObject = GetUIItemBox(dwBox, dwX)
		end
		if not hObject then
			return
		end
		local hComment = CreateComment("Comment_UseBag")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "RButtonClick")
		PlayHelpSound("26")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tQuest.USE_BAG.Text))
		BeginStaring(hObject)
		return
	end
	-- 获得书页
	if ((Helper.IsFirstTimeDo("GetBook") and GetItem(dwID).nGenre == ITEM_GENRE.BOOK) and true) then
		Helper.SetHasDo("GetBook")
		PopHelp(Helper.GetFormatedText(g_tTotur.tCraft.READ.Text))
				local hItem = GetItem(dwID)
		local dwBox, dwX = GetItemPosByItemTypeIndex(hItem.dwTabType, hItem.dwIndex)
		local hObject = nil
		if dwBox and dwX then
		    hObject = GetUIItemBox(dwBox, dwX)
		end
		if not hObject then
			return
		end
		BeginStaring(hObject)
		return
	end
	-- 使用道具
	if ((Helper.IsFirstTimeDo("UseProps") and GetItem(dwID).nGenre == ITEM_GENRE.TASK_ITEM and GetItem(dwID).dwIndex == 426) and true) then
		Helper.SetHasDo("UseProps")
		PopHelp(Helper.GetFormatedText(g_tTotur.tItem.USE_ITEM.Text))
				local hItem = GetItem(dwID)
		local dwBox, dwX = GetItemPosByItemTypeIndex(hItem.dwTabType, hItem.dwIndex)
		local hObject = nil
		if dwBox and dwX then
		    hObject = GetUIItemBox(dwBox, dwX)
		end
		if not hObject then
			return
		end
		BeginStaring(hObject)
		return
	end
	-- 获得马匹
	if ((Helper.IsFirstTimeDo("GetHorse") and GetItem(dwID).nGenre == ITEM_GENRE.EQUIPMENT and GetItem(dwID).nSub == EQUIPMENT_SUB.HORSE) and true) then
		Helper.SetHasDo("GetHorse")
		PlayHelpSound("41")
		PopHelp(Helper.GetFormatedText(g_tTotur.tItem.SIT.Text))
				local hItem = GetItem(dwID)
		local dwBox, dwX = GetItemPosByItemTypeIndex(hItem.dwTabType, hItem.dwIndex)
		local hObject = nil
		if dwBox and dwX then
		    hObject = GetUIItemBox(dwBox, dwX)
		end
		if not hObject then
			return
		end
		local hComment = CreateComment("CommentToHorse")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "RButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.HORSES.Text))
		BeginStaring(hObject)
		return
	end
	-- 获得书箱
	if ((GetItem(dwID).nGenre == ITEM_GENRE.EQUIPMENT and GetItem(dwID).nSub == EQUIPMENT_SUB.PACKAGE and GetItem(dwID).dwIndex == 33 and Helper.IsFirstTimeDo("GetBookBag")) and true) then
		Helper.SetHasDo("GetBookBag")
		PlayHelpSound("49")
				local hItem = GetItem(dwID)
		local dwBox, dwX = GetItemPosByItemTypeIndex(hItem.dwTabType, hItem.dwIndex)
		local hObject = nil
		if dwBox and dwX then
		    hObject = GetUIItemBox(dwBox, dwX)
		end
		if not hObject then
			return
		end
		local hComment = CreateComment("CommentToBoolBag")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "RButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.BOOKBOX.Text))
		return
	end
	-- 再次获得背包
	if ((not Helper.IsFirstTimeDo("GetPackage") and Helper.IsFirstTimeDo("GetPackageTwo") and GetItem(dwID).nGenre == ITEM_GENRE.EQUIPMENT and GetItem(dwID).nSub == EQUIPMENT_SUB.PACKAGE and GetItem(dwID).dwIndex ~= 33) and true) then
		Helper.SetHasDo("GetPackageTwo")
		PlayHelpSound("26")
		if IsShowHelpPanel() then
	OpenAllBagPanel()
end
				local hItem = GetItem(dwID)
		local dwBox, dwX = GetItemPosByItemTypeIndex(hItem.dwTabType, hItem.dwIndex)
		local hObject = nil
		if dwBox and dwX then
		    hObject = GetUIItemBox(dwBox, dwX)
		end
		if not hObject then
			return
		end
		local hComment = CreateComment("Comment_UseBag")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "RButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tQuest.USE_BAG.Text))
		BeginStaring(hObject)
		return
	end
	-- 第三次获得背包
	if ((not Helper.IsFirstTimeDo("GetPackageTwo") and Helper.IsFirstTimeDo("GetPackageThree") and GetItem(dwID).nGenre == ITEM_GENRE.EQUIPMENT and GetItem(dwID).nSub == EQUIPMENT_SUB.PACKAGE and GetItem(dwID).dwIndex ~= 33) and true) then
		Helper.SetHasDo("GetPackageThree")
		if IsShowHelpPanel() then
	OpenAllBagPanel()
end
		PlayHelpSound("26")
				local hItem = GetItem(dwID)
		local dwBox, dwX = GetItemPosByItemTypeIndex(hItem.dwTabType, hItem.dwIndex)
		local hObject = nil
		if dwBox and dwX then
		    hObject = GetUIItemBox(dwBox, dwX)
		end
		if not hObject then
			return
		end
		local hComment = CreateComment("Comment_UseBag")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "RButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tQuest.USE_BAG.Text))
		BeginStaring(hObject)
		return
	end
	-- 第一次获得装备
	if ((Helper.IsFirstTimeDo("GetClothes") and GetItem(dwID).nGenre == ITEM_GENRE.EQUIPMENT and GetItem(dwID).dwIndex ~= 602 and GetItem(dwID).nSub ~= EQUIPMENT_SUB.PACKAGE) and true) then
		Helper.SetHasDo("GetClothes")
		PlayHelpSound("54")
		if IsShowHelpPanel() then
	OpenAllBagPanel()
end
				local hItem = GetItem(dwID)
		local dwBox, dwX = GetItemPosByItemTypeIndex(hItem.dwTabType, hItem.dwIndex)
		local hObject = nil
		if dwBox and dwX then
		    hObject = GetUIItemBox(dwBox, dwX)
		end
		if not hObject then
			return
		end
		local hComment = CreateComment("CommentToChangeClothes")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "RButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.CHANGECLOTHES.Text))
		BeginStaring(hObject)
		return
	end
	-- 第二次获得装备
	if ((not Helper.IsFirstTimeDo("GetClothes") and Helper.IsFirstTimeDo("GetClothesSecond") and GetItem(dwID).nGenre == ITEM_GENRE.EQUIPMENT and GetItem(dwID).dwIndex ~= 602 and GetItem(dwID).nSub ~= EQUIPMENT_SUB.PACKAGE) and true) then
		Helper.SetHasDo("GetClothesSecond")
		PlayHelpSound("54")
		if IsShowHelpPanel() then
	OpenAllBagPanel()
end
				local hItem = GetItem(dwID)
		local dwBox, dwX = GetItemPosByItemTypeIndex(hItem.dwTabType, hItem.dwIndex)
		local hObject = nil
		if dwBox and dwX then
		    hObject = GetUIItemBox(dwBox, dwX)
		end
		if not hObject then
			return
		end
		local hComment = CreateComment("CommentToChangeClothes")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "RButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.CHANGECLOTHES.Text))
		BeginStaring(hObject)
		return
	end
	-- 第三次获得装备
	if ((not Helper.IsFirstTimeDo("GetClothesSecond") and Helper.IsFirstTimeDo("GetClothesThird") and GetItem(dwID).nGenre == ITEM_GENRE.EQUIPMENT and GetItem(dwID).dwIndex ~= 602 and GetItem(dwID).nSub ~= EQUIPMENT_SUB.PACKAGE) and true) then
		Helper.SetHasDo("GetClothesThird")
		PlayHelpSound("54")
		if IsShowHelpPanel() then
	OpenAllBagPanel()
end
				local hItem = GetItem(dwID)
		local dwBox, dwX = GetItemPosByItemTypeIndex(hItem.dwTabType, hItem.dwIndex)
		local hObject = nil
		if dwBox and dwX then
		    hObject = GetUIItemBox(dwBox, dwX)
		end
		if not hObject then
			return
		end
		local hComment = CreateComment("CommentToChangeClothes")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "RButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.CHANGECLOTHES.Text))
		BeginStaring(hObject)
		return
	end
	-- 第四次获得背包
	if ((Helper.IsFirstTimeDo("GetPackageFour") and not Helper.IsFirstTimeDo("GetPackageThree") and GetItem(dwID).nGenre == ITEM_GENRE.EQUIPMENT and GetItem(dwID).nSub == EQUIPMENT_SUB.PACKAGE and GetItem(dwID).dwIndex ~= 33) and true) then
		Helper.SetHasDo("GetPackageFour")
		if IsShowHelpPanel() then
	OpenAllBagPanel()
end
		PlayHelpSound("26")
				local hItem = GetItem(dwID)
		local dwBox, dwX = GetItemPosByItemTypeIndex(hItem.dwTabType, hItem.dwIndex)
		local hObject = nil
		if dwBox and dwX then
		    hObject = GetUIItemBox(dwBox, dwX)
		end
		if not hObject then
			return
		end
		local hComment = CreateComment("Comment_UseBag")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "RButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tQuest.USE_BAG.Text))
		BeginStaring(hObject)
		return
	end
	-- 获得灰色物品
	if ((Helper.IsFirstTimeDo("GetGrayThings") and GetItem(dwID).nQuality == 0) and true) then
		Helper.SetHasDo("GetGrayThings")
		PlayHelpSound("19")
		if IsShowHelpPanel() then
	OpenAllBagPanel()
end
				local hItem = GetItem(dwID)
		local dwBox, dwX = GetItemPosByItemTypeIndex(hItem.dwTabType, hItem.dwIndex)
		local hObject = nil
		if dwBox and dwX then
		    hObject = GetUIItemBox(dwBox, dwX)
		end
		if not hObject then
			return
		end
		local hComment = CreateComment("CommentToGrayThings")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "All")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tItem.GrayThingsMessege.Text))
		hComment:GetSelf().SetHoldTime(hComment, 7 * 1000)
		BeginStaring(hObject)
		return
	end
	-- 获得绿色物品
	if ((Helper.IsFirstTimeDo("GetGreenThings") and GetItem(dwID).nQuality == 2 and GetItem(dwID).nGenre == ITEM_GENRE.EQUIPMENT and GetItem(dwID).nSub ~= EQUIPMENT_SUB.PACKAGE) and true) then
		Helper.SetHasDo("GetGreenThings")
		if IsShowHelpPanel() then
	OpenAllBagPanel()
end
				local hItem = GetItem(dwID)
		local dwBox, dwX = GetItemPosByItemTypeIndex(hItem.dwTabType, hItem.dwIndex)
		local hObject = nil
		if dwBox and dwX then
		    hObject = GetUIItemBox(dwBox, dwX)
		end
		if not hObject then
			return
		end
		local hComment = CreateComment("CommentToGreenThings")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "All")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tItem.GreenThingsMessege.Text))
		hComment:GetSelf().SetHoldTime(hComment, 7 * 1000)
		BeginStaring(hObject)
		return
	end
	-- 获得蓝色物品
	if ((Helper.IsFirstTimeDo("GetBlueThings") and GetItem(dwID).nQuality == 3 and GetItem(dwID).nGenre == ITEM_GENRE.EQUIPMENT and GetItem(dwID).nSub ~= EQUIPMENT_SUB.PACKAGE) and true) then
		Helper.SetHasDo("GetBlueThings")
		if IsShowHelpPanel() then
	OpenAllBagPanel()
end
				local hItem = GetItem(dwID)
		local dwBox, dwX = GetItemPosByItemTypeIndex(hItem.dwTabType, hItem.dwIndex)
		local hObject = nil
		if dwBox and dwX then
		    hObject = GetUIItemBox(dwBox, dwX)
		end
		if not hObject then
			return
		end
		local hComment = CreateComment("CommentToblueThings")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "All")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tItem.BlueThingsMessege.Text))
		hComment:GetSelf().SetHoldTime(hComment, 7 * 1000)
		BeginStaring(hObject)
		return
	end
	-- 获得第五个背包
	if ((Helper.IsFirstTimeDo("GetPackageFive") and not Helper.IsFirstTimeDo("GetPackageFour") and GetItem(dwID).nGenre == ITEM_GENRE.EQUIPMENT and GetItem(dwID).nSub == EQUIPMENT_SUB.PACKAGE and GetItem(dwID).dwIndex ~= 33) and true) then
		Helper.SetHasDo("GetPackageFive")
		FireEvent("HELP_SPARK_EVENT_OPEN_BAG")
		return
	end
	-- 第一次获得新手包
	if ((Helper.IsFirstTimeDo("GetNewPresentOne") and GetItem(dwID).dwTabType == 5 and GetItem(dwID).dwIndex == 6746) and true) then
		Helper.SetHasDo("GetNewPresentOne")
		if IsShowHelpPanel() then
	OpenAllBagPanel()
end
				local hItem = GetItem(dwID)
		local dwBox, dwX = GetItemPosByItemTypeIndex(hItem.dwTabType, hItem.dwIndex)
		local hObject = nil
		if dwBox and dwX then
		    hObject = GetUIItemBox(dwBox, dwX)
		end
		if not hObject then
			return
		end
		local hComment = CreateComment("CommentToPresentOne")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "RButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tQuest.NEWPRESENT.Text))
		BeginStaring(hObject)
		return
	end
	-- 第二次获得新手包
	if ((Helper.IsFirstTimeDo("GetNewPresentTwo") and GetItem(dwID).dwTabType == 5 and GetItem(dwID).dwIndex == 6747) and true) then
		Helper.SetHasDo("GetNewPresentTwo")
		if IsShowHelpPanel() then
	OpenAllBagPanel()
end
				local hItem = GetItem(dwID)
		local dwBox, dwX = GetItemPosByItemTypeIndex(hItem.dwTabType, hItem.dwIndex)
		local hObject = nil
		if dwBox and dwX then
		    hObject = GetUIItemBox(dwBox, dwX)
		end
		if not hObject then
			return
		end
		local hComment = CreateComment("CommentToPresentOne")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tQuest.NEWPRESENTTWO.Text))
		hComment:GetSelf().SetHoldTime(hComment, 7 * 1000)
		BeginStaring(hObject)
		return
	end
	-- 第三次获得新手包
	if ((Helper.IsFirstTimeDo("GetNewPresentThree") and GetItem(dwID).dwTabType == 5 and GetItem(dwID).dwIndex == 6748) and true) then
		Helper.SetHasDo("GetNewPresentThree")
		if IsShowHelpPanel() then
	OpenAllBagPanel()
end
				local hItem = GetItem(dwID)
		local dwBox, dwX = GetItemPosByItemTypeIndex(hItem.dwTabType, hItem.dwIndex)
		local hObject = nil
		if dwBox and dwX then
		    hObject = GetUIItemBox(dwBox, dwX)
		end
		if not hObject then
			return
		end
		local hComment = CreateComment("CommentToPresentOne")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tQuest.NEWPRESENTTHREE.Text))
		hComment:GetSelf().SetHoldTime(hComment, 7 * 1000)
		BeginStaring(hObject)
		return
	end
end

-- 选择目标
Helper.OnSelectTarget = function(dwType, dwID, hObject)
	-- 选择玩家
	if ((Helper.IsFirstTimeDo("DoTargetPlayer") and dwType == TARGET.PLAYER and GetClientPlayer().nLevel >= 15 and GetClientPlayer().dwID ~= dwID) and true) then
		Helper.SetHasDo("DoTargetPlayer")
		local hComment = CreateComment("Comment_SelectPlayer")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "RButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.CAN_TRADE.Text))
		return
	end
end

-- 打开界面
Helper.OnOpenpanel = function(szName, hObject, dwQuestID)
	-- 交易
	if ((Helper.IsFirstTimeDo("OpenTradePanel") and szName == "TRADE") and true) then
		Helper.SetHasDo("OpenTradePanel")
		PopHelp(Helper.GetFormatedText(g_tTotur.tCommunicate.TRADE.Text))
		local hComment = CreateComment("Comment_Trade")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.COMMENT_TRADE.Text))
		return
	end
	-- 商店
	if ((szName == "SHOP" and Helper.IsFirstTimeDo("OpenShopPanel")) and true) then
		Helper.SetHasDo("OpenShopPanel")
		PopHelp(Helper.GetFormatedText(g_tTotur.tOperator.NPC_BUY.Text))
		return
	end
	-- 仓库
	if ((Helper.IsFirstTimeDo("OpenBankPanel") and szName == "BANK") and true) then
		Helper.SetHasDo("OpenBankPanel")
		PopHelp(Helper.GetFormatedText(g_tTotur.tOperator.USE_BANK.Text))
		local hComment = CreateComment("Comment_Bank")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().SetHoldTime(hComment, 7 * 1000)
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.BANK.Text))
		return
	end
	-- 打开邮箱
	if ((Helper.IsFirstTimeDo("OpenMailPanel") and szName == "MAIL") and true) then
		Helper.SetHasDo("OpenMailPanel")
		PlayHelpSound("35")
		PopHelp(Helper.GetFormatedText(g_tTotur.tOperator.USE_EMAIL.Text))
		return
	end
	-- 第一次打开大地图
	if ((szName == "MIDDLEMAP") and true) then
		local hComment = CreateComment("Comment_MapSelf")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetHoldTime(hComment, 7 * 1000)
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.FIND_NPC.Text))
		return
	end
	-- 打开阵法界面
	if ((szName == "MATRIX" and Helper.IsFirstTimeDo("OpenMatrixPanel")) and true) then
		Helper.SetHasDo("OpenMatrixPanel")
		local hComment = CreateComment("Comment_Matrix")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "All")
		hComment:GetSelf().SetHoldTime(hComment, 7 * 1000)
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.MATRIX.Text))
		return
	end
	-- 第一次拾取
	if ((szName == "LOOT" and Helper.IsFirstTimeDo("OpenLootPanel")) and true) then
		Helper.SetHasDo("OpenLootPanel")
		PlayHelpSound("15")
		local hComment = CreateComment("Comment_OpenLoot")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.FIX.Text))
		BeginStaring(hObject)
		return
	end
	-- 聊天输入框
	if ((szName == "EDITBOX" and Helper.IsFirstTimeDo("OpenEditBox")) and true) then
		Helper.SetHasDo("OpenEditBox")
		PlayHelpSound("43")
		local hComment = CreateComment("Comment_EditBox")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.CHATPANEL.Text))
		return
	end
	-- 打开团队界面
	if ((true and szName == "RaidPanel") and true) then
		Helper.SetHasDo("OpenRaidPanel")
		local hComment = CreateComment("Comment_RaidOption")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.TEAMS.Text))
		return
	end
	-- 第一次任务界面提示交任务指引
	if ((Helper.IsFirstTimeDo("TraceFinishQuest") and szName == "QuestFinishTrace") and true) then
		Helper.SetHasDo("TraceFinishQuest")
		local hComment = CreateComment("Comment_QuestFinishTrace")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetHoldTime(hComment, 7 * 1000)
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.JOIN.Text))
		return
	end
	-- 选择任务
	if ((Helper.IsFirstTimeDo("CommentChooseQuest") and szName == "QuestChoose") and true) then
		Helper.SetHasDo("CommentChooseQuest")
		local hComment = CreateComment("Comment_ChooseQuest")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.QUEST_NAME.Text))
		return
	end
	-- Rool物品
	if ((Helper.IsFirstTimeDo("OpenLootRoolPanel") and szName == "LOOTROOL") and true) then
		Helper.SetHasDo("OpenLootRoolPanel")
		PopHelp(Helper.GetFormatedText(g_tTotur.tOperator.ROOL_ITEM.Text))
		return
	end
	-- 第一次和武学训练师对话
	if ((Helper.IsFirstTimeDo("DialogeToMaster") and szName == "SkillMaster" and GetClientPlayer().dwForceID == 0 and GetClientPlayer().nLevel == 2) and true) then
		Helper.SetHasDo("DialogeToMaster")
		PlayHelpSound("11")
		PopHelp(Helper.GetFormatedText(g_tTotur.tQuest.NEWER_SKILL.Text))
		local hComment = CreateComment("CommentToMaster")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.ART.Text))
		return
	end
	-- 第二次拾取
	if ((szName == "LOOT" and not Helper.IsFirstTimeDo("OpenLootPanel") and Helper.IsFirstTimeDo("OpenLootPanelSecond")) and true) then
		Helper.SetHasDo("OpenLootPanelSecond")
		PlayHelpSound("15")
		local hComment = CreateComment("Comment_OpenLoot")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.FIX.Text))
		BeginStaring(hObject)
		return
	end
	-- 第三次拾取
	if ((szName == "LOOT" and not Helper.IsFirstTimeDo("OpenLootPanelSecond") and Helper.IsFirstTimeDo("OpenLootPanelThird")) and true) then
		Helper.SetHasDo("OpenLootPanelThird")
		PlayHelpSound("15")
		local hComment = CreateComment("Comment_OpenLoot")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.FIX.Text))
		BeginStaring(hObject)
		return
	end
	-- 第二次选择任务
	if ((not Helper.IsFirstTimeDo("CommentChooseQuest") and Helper.IsFirstTimeDo("CommentChooseQuestSecond") and szName == "QuestChoose") and true) then
		Helper.SetHasDo("CommentChooseQuestSecond")
		local hComment = CreateComment("Comment_ChooseQuest")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.QUEST_NAME.Text))
		return
	end
	-- 第三次选择任务
	if ((not Helper.IsFirstTimeDo("CommentChooseQuestSecond") and Helper.IsFirstTimeDo("CommentChooseQuestThird") and szName == "QuestChoose") and true) then
		Helper.SetHasDo("CommentChooseQuestThird")
		local hComment = CreateComment("Comment_ChooseQuest")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.QUEST_NAME.Text))
		return
	end
	-- 第二次任务界面提示交任务指引
	if ((not Helper.IsFirstTimeDo("TraceFinishQuest") and Helper.IsFirstTimeDo("TraceFinishQuestSecond") and szName == "QuestFinishTrace") and true) then
		Helper.SetHasDo("TraceFinishQuestSecond")
		local hComment = CreateComment("Comment_QuestFinishTrace")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetHoldTime(hComment, 7 * 1000)
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.JOIN.Text))
		return
	end
	-- 第三次任务界面提示交任务指引
	if ((not Helper.IsFirstTimeDo("TraceFinishQuestSecond") and Helper.IsFirstTimeDo("TraceFinishQuestThird") and szName == "QuestFinishTrace") and true) then
		Helper.SetHasDo("TraceFinishQuestThird")
		local hComment = CreateComment("Comment_QuestFinishTrace")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetHoldTime(hComment, 7 * 1000)
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.JOIN.Text))
		return
	end
	-- 第一次打开招式学习界面
	if ((szName == "SkillFormulaPanel" and Helper.IsFirstTimeDo("LearnSkillPanel")) and true) then
		Helper.SetHasDo("LearnSkillPanel")
		local hComment = CreateComment("CommentToSkillStudy")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tQuest.LEARN_SKILL.Text))
		BeginStaring(hObject)
		return
	end
	-- 第二次打开招式学习界面
	if ((not Helper.IsFirstTimeDo("LearnSkillPanel") and Helper.IsFirstTimeDo("LearnSkillPanelSecond") and szName == "SkillFormulaPanel") and true) then
		Helper.SetHasDo("LearnSkillPanelSecond")
		local hComment = CreateComment("CommentToSkillStudy")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tQuest.LEARN_SKILL.Text))
		BeginStaring(hObject)
		return
	end
	-- 第三次打开招式学习界面
	if ((not Helper.IsFirstTimeDo("LearnSkillPanelSecond") and Helper.IsFirstTimeDo("LearnSkillPanelThird") and szName == "SkillFormulaPanel") and true) then
		Helper.SetHasDo("LearnSkillPanelThird")
		local hComment = CreateComment("CommentToSkillStudy")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tQuest.LEARN_SKILL.Text))
		BeginStaring(hObject)
		return
	end
	-- 第二次和武学训练师对话
	if ((not Helper.IsFirstTimeDo("DialogeToMaster") and Helper.IsFirstTimeDo("DialogeToMasterSecond") and szName == "SkillMaster" and GetClientPlayer().dwForceID == 0 and GetClientPlayer().nLevel >= 4) and true) then
		Helper.SetHasDo("DialogeToMasterSecond")
		local hComment = CreateComment("CommentToMaster")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.ART.Text))
		return
	end
	-- 第三次和武学训练师对话
	if ((not Helper.IsFirstTimeDo("DialogeToMasterSecond") and Helper.IsFirstTimeDo("DialogeToMasterThird") and szName == "SkillMaster" and GetClientPlayer().dwForceID == 0) and true) then
		Helper.SetHasDo("DialogeToMasterThird")
		local hComment = CreateComment("CommentToMaster")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.ART.Text))
		return
	end
	-- 第一次选择已完成任务
	if ((Helper.IsFirstTimeDo("ChooseCompleteQuest") and szName == "QuestFinishChoose") and true) then
		Helper.SetHasDo("ChooseCompleteQuest")
		local hComment = CreateComment("CommentToChooseFinishQuest")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.CHOOSECOMPLETEQUEST.Text))
		return
	end
	-- 第二次打开大地图
	if (true and true) then
	end
end

-- 将招式拖至快捷栏
Helper.OnDragSkillToActionBar = function(dwID, dwLevel, hObject)
	-- 使用横扫千军
	if ((Helper.IsFirstTimeDo("DragSkill10ToActionBar") and dwID == 10) and true) then
		Helper.SetHasDo("DragSkill10ToActionBar")
		local hComment = CreateComment("Comment_Use49Skill")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tKungfu.ALL.Text))
		BeginStaring(hObject)
		return
	end
end

-- 组队
Helper.OnMakeParty = function(hObject)
	-- 组队
	if ((Helper.IsFirstTimeDo("MakeParty")) and true) then
		Helper.SetHasDo("MakeParty")
		PopHelp(Helper.GetFormatedText(g_tTotur.tCommunicate.TEAM_SET.Text))
		local hComment = CreateComment("Comment_SelectPlayer")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "RButtonClick")
		hComment:GetSelf().SetHoldTime(hComment, 7 * 1000)
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.FIRST_TEAM_HEAD.Text))
		return
		PlayHelpSound("28")
	end
	-- 阵法
	if ((Helper.IsFirstTimeDo("On20LevelMakeParty") and GetClientPlayer().nLevel >= 20) and true) then
		Helper.SetHasDo("On20LevelMakeParty")
		PlayHelpSound("33")
		PopHelp(Helper.GetFormatedText(g_tTotur.tFight.USE_MATRIX.Text))
		return
	end
end

-- 和NPC对话
Helper.OnDialogue = function(dwType, dwID)
	-- 与车夫王富对话
	if ((Helper.IsFirstTimeDo("TalkToFlyer") and dwType == TARGET.NPC and dwID and GetNpc(dwID) and GetNpc(dwID).szName == g_tStrings.NPC_WANGFU) and true) then
		Helper.SetHasDo("TalkToFlyer")
		PlayHelpSound("06")
		PopHelp(Helper.GetFormatedText(g_tTotur.tTraffic.DRIVERS.Text))
		return
	end
end

-- 场景切换
Helper.OnEnterScene = function(dwID)
	-- 进入新场景
	if ((Helper.IsFirstTimeDo("ChangeSceneNew") and dwID ~= 1) and true) then
		Helper.SetHasDo("ChangeSceneNew")
		PlayHelpSound("29")
		PopHelp(Helper.GetFormatedText(g_tTotur.tTraffic.ACCEPT_NEW.Text))
		PopHelp(Helper.GetFormatedText(g_tTotur.tOperator.NEWSPAPER.Text))
		return
	end
end

-- 进行装备
Helper.OnEquipItemUpdate = function(dwID)
end

-- 开始坐马车
Helper.OnStartAutoFly = function()
end

-- 在马车上切换场景
Helper.OnStartAutoChangeMap = function()
end

-- 结束坐马车
Helper.OnEndAutoFly = function()
end

-- 装备内功
Helper.OnMountKungfu = function(dwID, dwLevel)
	-- 装备内功
	if ((Helper.IsFirstTimeDo("UseNeiGong")) and true) then
		Helper.SetHasDo("UseNeiGong")
		PlayHelpSound("37")
		PopHelp(Helper.GetFormatedText(g_tTotur.tKungfu.SWITCH.Text))
		return
	end
end

-- 控件指向接任务
Helper.OnCommentAcceptQuest = function(hObject)
	-- 接取任务
	if ((Helper.IsFirstTimeDo("CommentAcceptQuest")) and true) then
		Helper.SetHasDo("CommentAcceptQuest")
		local hComment = CreateComment("Comment_AcceptQuest")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.QUEST_ACCESS.Text))
		BeginStaring(hObject)
		return
	end
	-- 第二次接取任务
	if ((not Helper.IsFirstTimeDo("CommentAcceptQuest") and Helper.IsFirstTimeDo("CommentAcceptQuestSecond")) and true) then
		Helper.SetHasDo("CommentAcceptQuestSecond")
		local hComment = CreateComment("Comment_AcceptQuest")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.QUEST_ACCESS.Text))
		BeginStaring(hObject)
		return
	end
	-- 第三次接取任务
	if ((not Helper.IsFirstTimeDo("CommentAcceptQuestSecond") and Helper.IsFirstTimeDo("CommentAcceptQuestTird")) and true) then
		Helper.SetHasDo("CommentAcceptQuestTird")
		local hComment = CreateComment("Comment_AcceptQuest")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.QUEST_ACCESS.Text))
		BeginStaring(hObject)
		return
	end
end

-- 控件指向交任务
Helper.OnCommentFinishQuest = function(hObject)
	-- 交任务
	if ((Helper.IsFirstTimeDo("CommentFinishQuest")) and true) then
		local hComment = CreateComment("Comment_FinishQuest")
		Helper.SetHasDo("CommentFinishQuest")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.QUEST_FINISH.Text))
		BeginStaring(hObject)
		return
	end
	-- 第二次交任务
	if ((not Helper.IsFirstTimeDo("CommentFinishQuest") and Helper.IsFirstTimeDo("CommentFinishQuestSecond")) and true) then
		Helper.SetHasDo("CommentFinishQuestSecond")
		local hComment = CreateComment("Comment_FinishQuest")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.QUEST_FINISH.Text))
		BeginStaring(hObject)
		return
	end
	-- 第三次交任务
	if ((not Helper.IsFirstTimeDo("CommentFinishQuestSecond") and Helper.IsFirstTimeDo("CommentFinishQuestThird")) and true) then
		Helper.SetHasDo("CommentFinishQuestThird")
		local hComment = CreateComment("Comment_FinishQuest")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.QUEST_FINISH.Text))
		BeginStaring(hObject)
		return
	end
end

-- 控件指向拖拽技能图标
Helper.OnCommentDragSkill = function(dwID, hObject)
	-- 拖拽招式图标
	if ((Helper.IsFirstTimeDo("CommentOnDragSkill") and dwID == 10) and true) then
		Helper.SetHasDo("CommentOnDragSkill")
		PlayHelpSound("24")
		local hComment = CreateComment("Comment_Drag10Skill")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.DRAG_SKILL.Text))
		BeginStaring(hObject)
		return
	end
	-- 七秀剑舞
	if ((Helper.IsFirstTimeDo("LearnSkill537") and dwID == 537) and true) then
		Helper.SetHasDo("LearnSkill537")
		local hComment = CreateComment("CommentToSkill537")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetHoldTime(hComment, 7 * 1000)
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tOperator.LearnSkill537.Text))
		BeginStaring(hObject)
		return
	end
	-- 天策龙牙
	if ((Helper.IsFirstTimeDo("LearnSkill415") and dwID == 415) and true) then
		Helper.SetHasDo("LearnSkill415")
		local hComment = CreateComment("CommentToSkill415")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetHoldTime(hComment, 7 * 1000)
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tOperator.LearnSkill415.Text))
		BeginStaring(hObject)
		return
	end
	-- 纯阳两仪
	if ((Helper.IsFirstTimeDo("LearnSkill301") and dwID == 301) and true) then
		Helper.SetHasDo("LearnSkill301")
		local hComment = CreateComment("CommentToSkill301")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetHoldTime(hComment, 7 * 1000)
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tOperator.LearnSkill301.Text))
		BeginStaring(hObject)
		return
	end
	-- 藏剑啸日
	if ((Helper.IsFirstTimeDo("LearnSkill1656") and dwID == 1656) and true) then
		Helper.SetHasDo("LearnSkill1656")
		local hComment = CreateComment("CommentToSkill1656")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetHoldTime(hComment, 7 * 1000)
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tOperator.LearnSkill1565.Text))
		BeginStaring(hObject)
		return
	end
	-- 少林韦陀
	if ((Helper.IsFirstTimeDo("LearnSkill233") and dwID == 233) and true) then
		Helper.SetHasDo("LearnSkill233")
		local hComment = CreateComment("CommentToSkill233")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetHoldTime(hComment, 7 * 1000)
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tOperator.LearnSkill233.Text))
		BeginStaring(hObject)
		return
	end
end

-- 关闭控件
Helper.OnCloseComment = function(szName)
	-- 关闭控件
	if (true and true) then
		CloseComment(szName)
		return
	end
end

-- 杀死敌人
Helper.OnKillEnemy = function(szKiller, dwID)
	-- 杀死果子狸提示拾取
	if ((Helper.IsFirstTimeDo("KillEnemy") and GetClientPlayer().szName == szKiller and dwID and GetNpc(dwID) and GetNpc(dwID).dwTemplateID == 1) and true) then
		PopHelp(Helper.GetFormatedText(g_tTotur.tItem.GET_QUESTTHING.Text))
		PlayHelpSound("14")
		Helper.SetHasDo("KillEnemy")
		return
	end
end

-- 背包满
Helper.OnBagFull = function()
	-- 出售物品
	if ((Helper.IsFirstTimeDo("BagFull")) and true) then
		Helper.SetHasDo("BagFull")
		PlayHelpSound("19")
		PopHelp(Helper.GetFormatedText(g_tTotur.tOperator.SELL.Text))
		return
	end
end

-- 任务列表满
Helper.OnQuestPanelFull = function()
	-- 删除任务
	if ((Helper.IsFirstTimeDo("QuestPanelFull")) and true) then
		Helper.SetHasDo("QuestPanelFull")
		PopHelp(Helper.GetFormatedText(g_tTotur.tQuest.DELETE.Text))
		return
	end
end

-- 背包位满
Helper.OnBagPanelFull = function()
	-- 仓库存放
	if ((Helper.IsFirstTimeDo("BagPanelFull")) and true) then
		Helper.SetHasDo("BagPanelFull")
		PlayHelpSound("34")
		PopHelp(Helper.GetFormatedText(g_tTotur.tItem.BUG_FULL.Text))
		return
	end
end

-- 阅读完一套书
Helper.OnOneBookListReaded = function()
	-- 兑换书籍
	if ((Helper.IsFirstTimeDo("OneBookListReaded")) and true) then
		Helper.SetHasDo("OneBookListReaded")
		PopHelp(Helper.GetFormatedText(g_tTotur.tCraft.CHANGE_BOOK.Text))
		return
	end
end

-- 点击已经阅读过的书
Helper.OnClickReadBook = function(hObject)
	-- 重复阅读
	if ((Helper.IsFirstTimeDo("ClickReadedBook")) and true) then
		Helper.SetHasDo("ClickReadedBook")
		local hComment = CreateComment("Comment_ClickReadedBook")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "RButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.READ_AGAIN.Text))
		BeginStaring(hObject)
		return
	end
end

-- 技艺等级上限提高
Helper.OnProfessionMaxLevelUp = function(nProfessionID, nMaxLevel)
	-- 缝纫分支
	if ((nProfessionID == 5 and nMaxLevel == 70 and Helper.IsFirstTimeDo("TailorMaxLvTo70Lv")) and true) then
		Helper.SetHasDo("TailorMaxLvTo70Lv")
		PopHelp(Helper.GetFormatedText(g_tTotur.tCraft.CHOOSE_NEEDLE.Text))
		return
	end
	-- 医术分支
	if ((Helper.IsFirstTimeDo("LeechcraftMaxLvTo70Lv") and nProfessionID == 7 and nMaxLevel == 70) and true) then
		Helper.SetHasDo("LeechcraftMaxLvTo70Lv")
		PopHelp(Helper.GetFormatedText(g_tTotur.tCraft.CHOOSE_PHYSIC.Text))
		return
	end
	-- 铸造分支
	if ((Helper.IsFirstTimeDo("SmithingMaxLvTo70Lv") and nProfessionID == 6 and nMaxLevel == 70) and true) then
		Helper.SetHasDo("SmithingMaxLvTo70Lv")
		PopHelp(Helper.GetFormatedText(g_tTotur.tCraft.CHOOSE_FORGING.Text))
		return
	end
end

-- 装备耐久损失
Helper.OnLossDurability = function(szDurability, hObject)
	-- 装备黄了
	if ((Helper.IsFirstTimeDo("EquipWarning") and szDurability == "Warning") and true) then
		Helper.SetHasDo("EquipWarning")
		PlayHelpSound("42")
		PopHelp(Helper.GetFormatedText(g_tTotur.tEquip.WARNING.Text))
		return
	end
	-- 装备红了
	if ((szDurability == "Damage" and Helper.IsFirstTimeDo("EquipDamage")) and true) then
		Helper.SetHasDo("EquipDamage")
		local hComment = CreateComment("Comment_EquipDamage")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetHoldTime(hComment, 7 * 1000)
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.DAMAGE.Text))
		return
	end
end

-- 领悟招式
Helper.OnComprehendSkill = function()
	-- 领悟招式
	if ((Helper.IsFirstTimeDo("ComprehendSkill")) and true) then
		PlayHelpSound("18")
		PopHelp(Helper.GetFormatedText(g_tTotur.tKungfu.KNOW.Text))
		Helper.SetHasDo("ComprehendSkill")
		return
	end
end

-- 抄录书籍
Helper.OnCanCopyBook = function(hObject)
end

-- 控件指向装备内功
Helper.OnCommentKungFu = function(hObject)
	-- 装备内功第一步
	if ((Helper.IsFirstTimeDo("CommentKungFu")) and true) then
		local hComment = CreateComment("Comment_KungFu")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "All")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.MOUNT_KONGFU.Text))
		Helper.SetHasDo("CommentKungFu")
		return
	end
end

-- 控件指向内功
Helper.OnCommentOneKungFu = function(hObject)
	-- 装备内功第二步
	if ((Helper.IsFirstTimeDo("CommentOneKungFu")) and true) then
		Helper.SetHasDo("CommentOneKungFu")
		local hComment = CreateComment("Comment_OneKungFu")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.MOUNT_ONE_KONGFU.Text))
		BeginStaring(hObject)
		return
	end
end

-- 协助任务满
Helper.OnAssistQuestFull = function()
	-- 协助任务满
	if ((Helper.IsFirstTimeDo("AssistQuestFull")) and true) then
		Helper.SetHasDo("AssistQuestFull")
		PopHelp(Helper.GetFormatedText(g_tTotur.tQuest.FULL_HELP.Text))
		return
	end
end

-- 接到协助任务
Helper.OnAcceptAssistQuest = function()
	-- 接到协助任务
	if ((Helper.IsFirstTimeDo("AcceptAssistQuest") and GetClientPlayer().nLevel >= 10) and true) then
		Helper.SetHasDo("AcceptAssistQuest")
		PopHelp(Helper.GetFormatedText(g_tTotur.tQuest.GET_HELP.Text))
		return
	end
end

-- 精力体力用完
Helper.OnWithoutStaminaOrThew = function()
	-- 精力或体力用完
	if ((Helper.IsFirstTimeDo("WithoutStaminaOrThew")) and true) then
		Helper.SetHasDo("WithoutStaminaOrThew")
		PopHelp(Helper.GetFormatedText(g_tTotur.tCraft.NO_HAVE.Text))
		return
	end
end

-- 第一次加好友
Helper.OnAddFriend = function()
	-- 添加好友
	if ((Helper.IsFirstTimeDo("AddFriend")) and true) then
		Helper.SetHasDo("AddFriend")
		PopHelp(Helper.GetFormatedText(g_tTotur.tQuest.GOODFRIEND.Text))
		return
	end
end

-- 控件指向协助任务
Helper.OnCommentAssistQuest = function(hObject)
	-- 控件指向协助任务
	if ((Helper.IsFirstTimeDo("CommentAssistQuest") and GetClientPlayer().nLevel >= 10) and true) then
		Helper.SetHasDo("CommentAssistQuest")
		local hComment = CreateComment("Comment_AcceptAssistQuest")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetHoldTime(hComment, 7 * 1000)
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.GET_A_HELP.Text))
		return
	end
end

-- 控件指向协助任务满
Helper.OnCommentAssistQuestFull = function(hObject)
	-- 控件指向协助任务满
	if ((Helper.IsFirstTimeDo("CommentAssistQuestFull")) and true) then
		Helper.SetHasDo("CommentAssistQuestFull")
		local hComment = CreateComment("Comment_AssistQuestFull")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetHoldTime(hComment, 7 * 1000)
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.FULL_A_HELP.Text))
		return
	end
end

-- NPC忙
Helper.OnSceneAnimation = function(szTime)
	-- NPC第一次忙碌
	if ((szTime == "First" and Helper.IsFirstTimeDo("NPCBusyFirstTime")) and true) then
		Helper.SetHasDo("NPCBusyFirstTime")
		PopHelp(Helper.GetFormatedText(g_tTotur.tOperator.NPC_BUSY.Text))
		return
	end
	-- NPC第二次忙碌
	if ((szTime == "Second" and Helper.IsFirstTimeDo("NPCBusySecondTime")) and true) then
		Helper.SetHasDo("NPCBusySecondTime")
		PopHelp(Helper.GetFormatedText(g_tTotur.tOperator.NPC_BUSY.Text))
		return
	end
end

-- 获得贡献
Helper.OnGetContribution = function()
	-- 获得贡献
	if ((Helper.IsFirstTimeDo("GetContribution")) and true) then
		Helper.SetHasDo("GetContribution")
		PlayHelpSound("46")
		PopHelp(Helper.GetFormatedText(g_tTotur.tCommunicate.CONTRIBUTION.Text))
		return true
	end
end

-- 任务失败
Helper.OnQuestFailed = function()
	-- 任务失败
	if ((Helper.IsFirstTimeDo("QuestFailed")) and true) then
		Helper.SetHasDo("QuestFailed")
		PopHelp(Helper.GetFormatedText(g_tTotur.tQuest.QUEST_FAILED.Text))
		return
	end
end

-- 学习到内功
Helper.OnLearnNeiGong = function()
	-- 学习内功
	if ((Helper.IsFirstTimeDo("LearnNeiGong")) and true) then
		Helper.SetHasDo("LearnNeiGong")
		PopHelp(Helper.GetFormatedText(g_tTotur.tKungfu.INTERNAL_WORK.Text))
		return
	end
end

-- 帮会信息
Helper.OnTongChanged = function(nReason)
	-- 加入帮会
	if ((Helper.IsFirstTimeDo("JoinTong") and nReason == TONG_CHANGE_REASON.JOIN) and true) then
		Helper.SetHasDo("JoinTong")
		PlayHelpSound("51")
		PopHelp(Helper.GetFormatedText(g_tTotur.tCommunicate.JOINBANG.Text))
		return
	end
	-- 创建帮会
	if ((Helper.IsFirstTimeDo("CreateTong") and nReason ==  TONG_CHANGE_REASON.CREATE) and true) then
		Helper.SetHasDo("CreateTong")
		PopHelp(Helper.GetFormatedText(g_tTotur.tCommunicate.BASED.Text))
		return
	end
end

-- 收到信件
Helper.OnAcceptMail = function(hObject)
	-- 收到信件
	if ((Helper.IsFirstTimeDo("AcceptMail") and GetClientPlayer().nLevel >= 10) and true) then
		Helper.SetHasDo("AcceptMail")
		PlayHelpSound("52")
		PopHelp(Helper.GetFormatedText(g_tTotur.tOperator.EARNING.Text))
		local hComment = CreateComment("CommentToMail")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.DRAWIN.Text))
		return
	end
end

-- 控件指向技艺图标
Helper.OnCommentToCraft = function(nProfessionID, hObject)
	-- 控件指向采金图标
	if ((Helper.IsFirstTimeDo("CommentToMining") and nProfessionID == 1) and true) then
		Helper.SetHasDo("CommentToMining")
		local hComment = CreateComment("CommentToMining")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "All")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.PICK.Text))
		return
	end
	-- 控件指向神农图标
	if ((Helper.IsFirstTimeDo("CommjentToHerbal") and nProfessionID == 2) and true) then
		Helper.SetHasDo("CommjentToHerbal")
		local hComment = CreateComment("CommentToHerbal")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "All")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.CULL.Text))
		return
	end
end

-- 关闭界面
Helper.OnClosePanel = function(szName, hObject)
	-- 第一次关闭历程提示界面
	if ((Helper.IsFirstTimeDo("CloseCoures") and szName == "COURES") and true) then
		Helper.SetHasDo("CloseCoures")
		local hComment = CreateComment("Comment_ChooseQuest")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tCommunicate.JIANGHU_GUIDE.Text))
		return
	end
	-- 第一次关闭操作选择界面
	if ((Helper.IsFirstTimeDo("CloseUserActionChoose") and szName == "UserActionChoose") and true) then
		Helper.SetHasDo("CloseUserActionChoose")
		PlayHelpSound("01")
		OpenHelperTipPanel(Helper.GetFormatedText(g_tTotur.tQuest.CHOOSE.Text))
		return
	end
end

-- 进入游戏
Helper.OnEnterGame = function()
	-- 第一次进入游戏
	if ((Helper.IsFirstTimeDo("EnterGame")) and true) then
		Helper.SetHasDo("EnterGame")
		if IsShowHelpPanel() then
	OpenUserActionChoose()
end
		return
	end
end

-- 控件指向打开任务面板按钮
Helper.OnCommentToOpenQuest = function(dwQuestID, hObject)
	-- 接受重伤谢君恩指向任务按钮（键盘走）
	if ((Helper.IsFirstTimeDo("Accept800Quest") and IsMouseMove() == false and dwQuestID == 800) and true) then
		Helper.SetHasDo("Accept800Quest")
		OpenHelperTipPanel(Helper.GetFormatedText(g_tTotur.tOperator.MOVE.Text))
		return
	end
	-- 接受重伤谢君恩指向任务按钮（鼠标走）
	if ((Helper.IsFirstTimeDo("Accept800Quest") and IsMouseMove() == true and dwQuestID == 800) and true) then
		Helper.SetHasDo("Accept800Quest")
		OpenHelperTipPanel(Helper.GetFormatedText(g_tTotur.tPicture.MOUSE_MOVE.Text))
		return
	end
	-- 接受任务寻找刘大海
	if ((Helper.IsFirstTimeDo("Accpet812Quest") and dwQuestID == 812) and true) then
		Helper.SetHasDo("Accpet812Quest")
		local hComment = CreateComment("CommentToQuestIcon")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tOperator.Click_QuestIcon.Text))
		return
	end
	-- 接受任务杀小混混
	if ((Helper.IsFirstTimeDo("Accept813Quest") and dwQuestID == 813) and true) then
		Helper.SetHasDo("Accept813Quest")
		local hObject = GetSkillActionBarBox(49)
if not hObject then
	return
end
		PlayHelpSound("12")
		local hComment = CreateComment("Comment_Use49Skill")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.KUNGFU_USE.Text))
		BeginStaring(hObject)
		return
	end
	-- 接受任务：寻找权逝水
	if ((Helper.IsFirstTimeDo("Accept833Quest") and dwQuestID == 833) and true) then
		Helper.SetHasDo("Accept833Quest")
		PlayHelpSound("09")
		OpenHelperTipPanel(Helper.GetFormatedText(g_tTotur.tPicture.TURNSHOT.Text))
		local hComment = CreateComment("CommentToQuestIcon")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tOperator.Click_QuestIcon.Text))
		return
	end
end

-- 控件指向打开中地图按钮
Helper.OnCommentToOpenMiddlemap = function(dwQuestID, hObject)
	-- 接受找紫晴任务指向地图按钮
	if (true and true) then
	end
	-- 接受寻张强任务
	if (true and true) then
	end
	-- 接受寻找小月任务
	if (true and true) then
	end
end

-- 控件指向任务怪区域指引
Helper.OnCommentToMarkKillNpc = function(dwQuestID, hObject)
	-- 接受果子狸任务
	if ((dwQuestID == 827 and not Helper.IsFirstTimeDo("Accept827Quest")) and true) then
		local hComment = CreateComment("CommentToQuestArea")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tQuest.QuestArea.Text))
		hComment:GetSelf().SetHoldTime(hComment, 15 *1000)
		return
	end
	-- 接受任务打木桩
	if ((dwQuestID == 801 and not Helper.IsFirstTimeDo("Accpet801Quest")) and true) then
		local hComment = CreateComment("CommentToQuestArea")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetHoldTime(hComment, 15 *1000)
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tQuest.QuestArea.Text))
		return
	end
	-- 接受杀小毛贼
	if ((not Helper.IsFirstTimeDo("Accept1032Quest") and dwQuestID == 1032) and true) then
		local hComment = CreateComment("CommentToQuestArea")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetHoldTime(hComment, 15 *1000)
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tQuest.QuestArea.Text))
		return
	end
end

-- 控件指向大地图完成任务指引
Helper.OnCommentToMarkQuestFinish = function(dwQuestID, hObject)
	-- 第一次指向
	if ((dwQuestID == 800 and Helper.IsFirstTimeDo("MidMapGuideFirst")) and true) then
		Helper.SetHasDo("MidMapGuideFirst")
		local hComment = CreateComment("CommentToMidMapMessege")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tOperator.MidMapGuide.Text))
		return
	end
	-- 第二次指向
	if ((dwQuestID == 812 and Helper.IsFirstTimeDo("MidMapGuideSecond")) and true) then
		Helper.SetHasDo("MidMapGuideSecond")
		local hComment = CreateComment("CommentToMidMapMessege")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tOperator.MidMapGuide.Text))
		return
	end
	-- 第三次指向
	if ((dwQuestID == 833 and Helper.IsFirstTimeDo("MidMapGuideThird")) and true) then
		Helper.SetHasDo("MidMapGuideThird")
		local hComment = CreateComment("CommentToMidMapMessege")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tOperator.MidMapGuide.Text))
		return
	end
end

-- 控件指向打开背包
Helper.OnCommentToOpenBag = function(hObject)
	-- 指向背包图标
	if ((Helper.IsFirstTimeDo("PackageLearn")) and true) then
		Helper.SetHasDo("PackageLearn")
		local hComment = CreateComment("CommentToPackageIcon")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tOperator.Click_PackageIcon.Text))
		return
	end
end

-- 控件指向打开寻求组队界面
Helper.OnCommentToOpenPartyRecruit = function(hObject)
	-- 控件指向打开寻求组队界面
	if ((Helper.IsFirstTimeDo("CommentToOpenPartyRecruit") and GetClientPlayer().nLevel >= 31) and true) then
		Helper.SetHasDo("CommentToOpenPartyRecruit")
		local hComment = CreateComment("CommentToPartyRecruit")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		PlayHelpSound("56")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.PartyRecruit.Text))
		return
	end
end

-- 控件指向任务指向针
Helper.OnCommentToQuestGPS = function(hObject)
	-- 控件指向任务指向针（键盘走路）
	if ((Helper.IsFirstTimeDo("GetQuestGuideIcon")) and true) then
		Helper.SetHasDo("GetQuestGuideIcon")
		local hComment = CreateComment("CommentToQuestGPS")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetHoldTime(hComment, 45 * 1000)
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tQuest.QuestGuide.Text))
		return
		PlayHelpSound("08")
	end
end

-- 控件指向切换轻重剑
Helper.OnCommentToSwitchSword = function(hObject)
	-- 控件指向切换轻重剑
	if ((Helper.IsFirstTimeDo("CommentToSwithSword")) and true) then
		Helper.SetHasDo("CommentToSwithSword")
		local hComment = CreateComment("CommentToSwithSword")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().SetHoldTime(hComment, 45 * 1000)
		PlayHelpSound("57")
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tOperator.ChangeWeapon.Text))
		return
	end
end

-- 控件指向没入过帮会
Helper.OnCommentToKnowGuild = function(hObject, nFlag)
	-- 控件指向没入过帮会
	if ((GetClientPlayer().nLevel >= 10 and nFlag == 1) and true) then
		local hComment = CreateComment("CommentToKnowGuild")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().SetHoldTime(hComment, 45 * 1000)
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.KNOWGUILD.Text))
		FireUIEvent("COMMENT_TO_KNOW_GUILD", "success")
	end
	-- 控件指向帮贡首次达到55000
	if ((Helper.IsFirstTimeDo("GuildCont55000") and GetClientPlayer().nContribution >= 55000 and nFlag == 2) and true) then
		Helper.SetHasDo("GuildCont55000")
		local hComment = CreateComment("CommentToGuild55000")
		hComment:GetSelf().SetObject(hComment, hObject)

		hComment:GetSelf().SetResponse(hComment, "LButtonClick")
		hComment:GetSelf().SetHoldTime(hComment, 45 * 1000)
		hComment:GetSelf().OutputComment(hComment,Helper.GetFormatedText(g_tTotur.tComment.GUILD55000.Text))
		return
	end
end

-- 第一次获取侠义值
Helper.OnFirstGetJustice = function()
	-- 第一次获取
	if ((Helper.IsFirstTimeDo("FirstGetJustice")) and true) then
		Helper.SetHasDo("FirstGetJustice")
		return true
	end
end

-- 第一次获取威望值
Helper.OnFirstGetPrestige = function()
	-- 第一次获取
	if ((Helper.IsFirstTimeDo("FirstGetPrestige")) and true) then
		Helper.SetHasDo("FirstGetPrestige")
		return true
	end
end

-- 第一次获取战阶积分
Helper.OnFirstGetPointTitle = function()
	-- 第一次获取
	if ((Helper.IsFirstTimeDo("FirstGetPointTitle")) and true) then
		Helper.SetHasDo("FirstGetPointTitle")
		return true
	end
end

-- 第一次获取名剑币
Helper.OnFirstGetArenaAware = function()
	-- 第一次获取
	if ((Helper.IsFirstTimeDo("FirstGetArenaAware")) and true) then
		Helper.SetHasDo("FirstGetArenaAware")
		return true
	end
end

-- 第一次获取监本印文
Helper.OnFirstGetExamPrint = function()
	-- 第一次获取
	if ((Helper.IsFirstTimeDo("FirstGetExamPrint")) and true) then
		Helper.SetHasDo("FirstGetExamPrint")
		return true
	end
end

-- 第一次获取通宝
Helper.OnFirstGetCoin = function()
	-- 第一次获取
	if ((Helper.IsFirstTimeDo("FirstGetCoin")) and true) then
		Helper.SetHasDo("FirstGetCoin")
		return true
	end
end

-- 第一次获取江湖资历
Helper.OnFirstGetJHZILI = function()
	-- 第一次获取
	if ((Helper.IsFirstTimeDo("FirstGetJHZILI")) and true) then
		Helper.SetHasDo("FirstGetJHZILI")
		return true
	end
end

-- 第一次获取师徒装备分数
Helper.OnFirstGetMentorScore = function()
	-- 第一次获取
	if ((Helper.IsFirstTimeDo("FirstGetMentorScore")) and true) then
		Helper.SetHasDo("FirstGetMentorScore")
		return true
	end
end

tEvent = 
{
	["OnAcceptQuest"] = Helper.OnAcceptQuest,
	["OnEnterGame"] = Helper.OnEnterGame,
	["OnHealthLow"] = Helper.OnHealthLow,
	["OnLevelUp"] = Helper.OnLevelUp,
	["OnLearnSkill"] = Helper.OnLearnSkill,
	["OnSkillLevelUp"] = Helper.OnSkillLevelUp,
	["OnEnterFight"] = Helper.OnEnterFight,
	["OnDeath"] = Helper.OnDeath,
	["OnApplyFight"] = Helper.OnApplyFight,
	["OnSlaughter"] = Helper.OnSlaughter,
	["OnVendetta"] = Helper.OnVendetta,
	["OnReputationUpdate"] = Helper.OnReputationUpdate,
	["OnLearnCraft"] = Helper.OnLearnCraft,
	["OnCraftLevelUp"] = Helper.OnCraftLevelUp,
	["OnLearRecipe"] = Helper.OnLearRecipe,
	["OnGetItem"] = Helper.OnGetItem,
	["OnSelectTarget"] = Helper.OnSelectTarget,
	["OnOpenpanel"] = Helper.OnOpenpanel,
	["OnDragSkillToActionBar"] = Helper.OnDragSkillToActionBar,
	["OnAddBuff"] = Helper.OnAddBuff,
	["OnMakeParty"] = Helper.OnMakeParty,
	["OnDialogue"] = Helper.OnDialogue,
	["OnChangeScene"] = Helper.OnEnterScene,
	["OnEquipItemUpdate"] = Helper.OnEquipItemUpdate,
	["OnStartAutoFly"] = Helper.OnStartAutoFly,
	["OnStartAutoChangeMap"] = Helper.OnStartAutoChangeMap,
	["OnEndAutoFly"] = Helper.OnEndAutoFly,
	["OnMountKungfu"] = Helper.OnMountKungfu,
	["OnBagFull"] = Helper.OnBagFull,
	["OnCommentChooseQuest"] = Helper.OnCommentChooseQuest,
	["OnCommentAcceptQuest"] = Helper.OnCommentAcceptQuest,
	["OnCommentFinishQuest"] = Helper.OnCommentFinishQuest,
	["OnCommentDragSkill"] = Helper.OnCommentDragSkill,
	["OnCloseComment"] = Helper.OnCloseComment,
	["OnKillEnemy"] = Helper.OnKillEnemy,
	["OnBagFull"] = Helper.OnBagFull,
	["OnQuestPanelFull"] = Helper.OnQuestPanelFull,
	["OnBagPanelFull"] = Helper.OnBagPanelFull,
	["OnOneBookListReaded"] = Helper.OnOneBookListReaded,
	["OnClickReadBook"] = Helper.OnClickReadBook,
	["OnProfessionMaxLevelUp"] = Helper.OnProfessionMaxLevelUp,
	["OnLossDurability"] = Helper.OnLossDurability,
	["OnComprehendSkill"] = Helper.OnComprehendSkill,
	["OnCanCopyBook"] = Helper.OnCanCopyBook,
	["OnCommentKungFu"] = Helper.OnCommentKungFu,
	["OnCommentOneKungFu"] = Helper.OnCommentOneKungFu,
	["OnAssistQuestFull"] = Helper.OnAssistQuestFull,
	["OnAcceptAssistQuest"] = Helper.OnAcceptAssistQuest,
	["OnWithoutStaminaOrThew"] = Helper.OnWithoutStaminaOrThew,
	["OnAddFriend"] = Helper.OnAddFriend,
	["OnCommentAssistQuest"] = Helper.OnCommentAssistQuest,
	["OnCommentAssistQuestFull"] = Helper.OnCommentAssistQuestFull,
	["OnCommentRenmai"] = Helper.OnCommentRenmai,
	["OnSceneAnimation"] = Helper.OnSceneAnimation,
	["OnGetContribution"] = Helper.OnGetContribution,
	["OnQuestFailed"] = Helper.OnQuestFailed,
	["OnAcceptMail"] = Helper.OnAcceptMail,
	["OnCommentToCraft"] = Helper.OnCommentToCraft,
	["OnClosePanel"] = Helper.OnClosePanel,
	["OnCommentToOpenMiddlemap"] = Helper.OnCommentToOpenMiddlemap,
	["OnCommentToOpenQuest"] = Helper.OnCommentToOpenQuest,
	["OnCommentToMarkKillNpc"] = Helper.OnCommentToMarkKillNpc,
	["OnCommentToMarkQuestFinish"] = Helper.OnCommentToMarkQuestFinish,
	["OnCommentToOpenBag"] = Helper.OnCommentToOpenBag,
	["OnCommentToOpenPartyRecruit"] = Helper.OnCommentToOpenPartyRecruit,
	["OnCommentToQuestGPS"] = Helper.OnCommentToQuestGPS,
	["OnCommentToSwitchSword"] = Helper.OnCommentToSwitchSword,
	["OnCommentToKnowGuild"] = Helper.OnCommentToKnowGuild,
	
	["OnFirstGetJustice"] = Helper.OnFirstGetJustice,
	["OnFirstGetPrestige"] = Helper.OnFirstGetPrestige,
	["OnFirstGetPointTitle"] = Helper.OnFirstGetPointTitle,
	["OnFirstGetArenaAware"] = Helper.OnFirstGetArenaAware,
	["OnFirstGetExamPrint"] = Helper.OnFirstGetExamPrint,
	["OnFirstGetCoin"] = Helper.OnFirstGetCoin,
	["OnFirstGetJHZILI"] = Helper.OnFirstGetJHZILI,
	["OnFirstGetMentorScore"] = Helper.OnFirstGetMentorScore,
}

function FireHelpEvent(...)
	local argSave = {}
	local arg = {...}
	for nIndex, value in ipairs(arg) do
		argSave[nIndex] = _G["arg" .. nIndex - 1]
		_G["arg" .. nIndex - 1] = arg[nIndex]
	end
	
	FireEvent("HELP_EVENT")
	
	for nIndex, value in ipairs(argSave) do
		_G["arg" .. nIndex - 1] = argSave[nIndex]
	end
end

function Helper.SkillUpdate(dwID, dwLevel)
	if dwLevel > 1 then
		Helper.OnSkillLevelUp(dwID, dwLevel)
	elseif dwLevel == 1 then
		Helper.OnLearnSkill(dwID, dwLevel)
		local hPlayer = GetClientPlayer()
		local tSkill = GetSkill(dwID, dwLevel)
		if hPlayer and hPlayer.dwForceID > 0 and tSkill and tSkill.nUIType == 2 and tSkill.dwBelongKungfu == 0 then
			Helper.OnLearnNeiGong()
		end
	end
	if dwLevel == 2 then
		Helper.OnComprehendSkill()
	end
end

function Helper.LevelUp(dwID)
	local hPlayer = GetClientPlayer()
	if hPlayer and dwID == hPlayer.dwID then
		Helper.OnLevelUp()
		
		tProfession = hPlayer.GetProfession()
		for key, tValue in pairs(tProfession) do
			Helper.OnCraftLevelUp(tValue.ProfessionID, tValue.Level, tValue.MaxLevel)
		end
	end
end

function Helper.EquipItemUpdate(dwBox, dwX)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	local hItem = GetPlayerItem(hPlayer, dwBox, dwX)
	if hItem then 
		Helper.OnEquipItemUpdate(hItem.dwID)
	end
end

function Helper.OnEvent(szEvent)
	if szEvent == "HELP_EVENT" then
		if tEvent[arg0] then
			tEvent[arg0](arg1, arg2, arg3, arg4)
		end
	elseif szEvent == "QUEST_ACCEPTED" then
		Helper.OnAcceptQuest(arg1)
	elseif szEvent == "PLAYER_LEVEL_UPDATE" then
		Helper.LevelUp(arg0)
	elseif szEvent == "SKILL_UPDATE" then
		Helper.SkillUpdate(arg0, arg1)
	elseif szEvent == "UPDATE_REPUTATION" then
		Helper.OnReputationUpdate()
	elseif szEvent == "UI_START_AUTOFLY" then
		Helper.OnStartAutoFly()
	elseif szEvent == "UI_END_AUTOFLY" then
		Helper.OnEndAutoFly()
	elseif szEvent == "UI_AUTOFLY_SWITCH_MAP" then
		Helper.OnStartAutoChangeMap()
	elseif szEvent == "SKILL_MOUNT_KUNG_FU" then
		local hPlayer = GetClientPlayer()
		if hPlayer and hPlayer.dwForceID > 0 then
			Helper.OnMountKungfu(arg0, arg1)
		end
	elseif szEvent == "EQUIP_ITEM_UPDATE" then
		Helper.EquipItemUpdate(arg0, arg1)
	elseif szEvent == "LOADING_END" then
        local hPlayer = GetClientPlayer()
        local hScene = hPlayer.GetScene()
        if hScene then
            Helper.OnEnterScene(hScene.dwMapID)
        end
        Helper.OnEnterGame()
	elseif szEvent == "PLAYER_FELLOWSHIP_CHANGE" then
		if arg0 == PLAYER_FELLOWSHIP_RESPOND.SUCCESS_ADD then
			Helper.OnAddFriend()
		end
	elseif szEvent == "QUEST_FAILED" then
		Helper.OnQuestFailed()
	elseif szEvent == "CHANGE_TONG_NOTIFY" then
		Helper.OnTongChanged(arg1)
	end
end

local function OnCurrencyUpdate(szFun)
	if tEvent[szFun] then
		local bFirst = tEvent[szFun]()
		if bFirst then
			FireUIEvent("CURRENCY_FIRST_GET", szFun)
		end
	end
end

RegisterEvent("HELP_EVENT", function(szEvent) Helper.OnEvent(szEvent) end)
RegisterEvent("QUEST_ACCEPTED", function(szEvent) Helper.OnEvent(szEvent) end)
RegisterEvent("QUEST_CANCELED", function(szEvent) Helper.OnEvent(szEvent) end)
RegisterEvent("PLAYER_LEVEL_UPDATE", function(szEvent) Helper.OnEvent(szEvent) end)
RegisterEvent("SKILL_UPDATE", function(szEvent) Helper.OnEvent(szEvent) end)
RegisterEvent("UPDATE_REPUTATION", function(szEvent) Helper.OnEvent(szEvent) end)
RegisterEvent("UI_START_AUTOFLY", function(szEvent) Helper.OnEvent(szEvent) end)
RegisterEvent("UI_END_AUTOFLY", function(szEvent) Helper.OnEvent(szEvent) end)
RegisterEvent("UI_AUTOFLY_SWITCH_MAP", function(szEvent) Helper.OnEvent(szEvent) end)
RegisterEvent("SKILL_MOUNT_KUNG_FU", function(szEvent) Helper.OnEvent(szEvent) end)
RegisterEvent("EQUIP_ITEM_UPDATE", function(szEvent) Helper.OnEvent(szEvent) end)
RegisterEvent("LOADING_END", function(szEvent) Helper.OnEvent(szEvent) end)
RegisterEvent("PLAYER_FELLOWSHIP_CHANGE", function(szEvent) Helper.OnEvent(szEvent) end)
RegisterEvent("QUEST_FAILED", function(szEvent) Helper.OnEvent(szEvent) end)
RegisterEvent("CHANGE_TONG_NOTIFY", function(szEvent) Helper.OnEvent(szEvent) end)

RegisterEvent("CURRENCY_GET", function() OnCurrencyUpdate(arg0) end)

