g_tTotur = {};
g_tTotur.tQuest = {};
g_tTotur.tKungfu = {};
g_tTotur.tOperator = {};
g_tTotur.tFight = {};
g_tTotur.tItem = {};
g_tTotur.tCommunicate = {};
g_tTotur.tTraffic = {};
g_tTotur.tCraft = {};
g_tTotur.tComment = {};
g_tTotur.tEquip = {};
g_tTotur.tAnounce = {};
g_tTotur.tPicture = {};

g_tTotur.tQuest.ACCEPT_QUEST = {Text = "<text>text=\"查看任务\" font=100</text><text>text=\"\\\n\" font=224</text><text>text=\"按（<TOGGLE_QUEST_PANEL>）打开任务界面，可以查看任务。\" font=106</text>", Level = 1}
g_tTotur.tKungfu.TRY = {Text = "<text>text=\"招式\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"使用招式“\" font=106</text><text>text=\"回风扫叶\" font=101</text><text>text=\"”\" font=106</text><text>text=\"\\\n\" font=128</text><text>text=\"需选中一个目标方可攻击。\" font=106</text>", Level = 1}
g_tTotur.tOperator.MOVE = {Text = "<text>text=\"\\\n\" font=100</text><image>path=\"ui/Image/Helper/test.UITex\" frame=2 w=251 h=248</image><text>text=\"\\\n\\\n交任务\\\n\" font=100</text><text>text=\"NPC头顶有\" font=106</text><text>text=\"黄色展开卷轴\" font=101</text><image>path=\"ui/Image/UICommon/CommonPanel2.UITex\" frame=123 w=28 h=21</image><text>text=\"表示有可以交的任务。只需按（\" font=106</text><text>text=\"W\" font=101</text><text>text=\"）键移动到他身边，\" font=106</text><text>text=\"鼠标右键\" font=101</text><image>path=\"ui/Image/UICommon/CommonPanel2.UITex\" frame=37 w=16 h=31</image><text>text=\" 点击 NPC即可 。\" font=106</text><text>text=\"   \" font=128</text>", Level = 1}
g_tTotur.tQuest.CHOOSE = {Text = "<image>path=\"ui/Image/Helper/HelpTip.UITex\" frame=1 w=251 h=247</image><text>text=\"\\\n\\\n 接取任务\\\n\" font=100</text><text>text=\" 头上如果有 \" font=106</text><image>path=\"ui/Image/UICommon/CommonPanel2.UITex\" frame=122 w=30 h=25</image><text>text=\" （\" font=106</text><text>text=\"任务卷轴\" font=101</text><text>text=\"）的NPC表示可以接取任务。\\\n走到NPC身旁，鼠标 \" font=106</text><image>path=\"ui/Image/UICommon/CommonPanel2.UITex\" frame=37 w=18 h=32</image><text>text=\"（\" font=106</text><text>text=\"右键\" font=101</text><text>text=\"）点击，可接取任务。接到的任务可按（<TOGGLE_QUEST_PANEL>）打开任务面板查看任务说明。\\\n\" font=106</text>", Level = 1}
g_tTotur.tFight.SELECT_TARGET = {Text = "<text>text=\"选定目标\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"将鼠标指向木桩，单击（\" font=106</text><text>text=\"鼠标左键\" font=101</text><text>text=\"）。\" font=106</text>", Level = 1}
g_tTotur.tFight.ATTACK = {Text = "<text>text=\"攻击\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"鼠标移到目标身上时变成“\" font=106</text><text>text=\"剑\" font=102</text><text>text=\"”形状，表示可以攻击。使用（\" font=106</text><text>text=\"鼠标右键\" font=101</text><text>text=\"）点击目标一次，或（\" font=106</text><text>text=\"鼠标左键\" font=101</text><text>text=\"）点击招式便可以对目标造成伤害。\" font=106</text>", Level = 1}
g_tTotur.tFight.CHARACTER = {Text = "<text>text=\"角色能力\\\n\" font=100</text><text>text=\"升级会提升你的角色能力。按（<TOGGLE_EQUIP_PANEL>）打开角色界面，可以查看角色能力。\" font=106</text>", Level = 5}
g_tTotur.tKungfu.NEW_SKILL = {Text = "<text>text=\"新招式\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"按（<TOGGLE_SKILL_PANEL>）可以打开武学界面。（\" font=106</text><text>text=\"鼠标左键\" font=101</text><text>text=\"）移到招式图标上，按下不放，可将招式拖至屏幕下方的招式栏。\" font=106</text>", Level = 3}
g_tTotur.tKungfu.USE_SKILL = {Text = "<text>text=\"使用招式\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"使用（\" font=106</text><text>text=\"鼠标左键\" font=101</text><text>text=\"）或（\" font=106</text><text>text=\"鼠标右键\" font=101</text><text>text=\"）单击快捷栏上的图标，可以使用这个招式。\" font=106</text>", Level = 3}
g_tTotur.tFight.FIGHT_STATE = {Text = "<text>text=\"战斗状态\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"当你发起攻击或被人攻击后，将进入战斗状态。\" font=106</text>", Level = 2}
g_tTotur.tFight.BUFF = {Text = "<text>text=\"效果\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"所有有益和有害效果，都会显示在自身头像的下方。有益的效果显示在上面，有害的效果显示在下面。\" font=106</text>", Level = 9}
g_tTotur.tFight.HEALTH_LOW = {Text = "<text>text=\"气血值\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"气血值过低时，小头像旁的气血条会闪烁表示危险，请尽快脱离战斗。\" font=106</text>", Level = 9}
g_tTotur.tOperator.MEDITATION = {Text = "<text>text=\"打坐\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"在非战斗状态下按（<TOGGLESITDOWN>）可以进行打坐，加速回复血气和内力。再按（<TOGGLESITDOWN>）可起身。\" font=106</text>", Level = 2}
g_tTotur.tOperator.JUMP = {Text = "<text>text=\"轻功\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"按（<JUMP>）一次即可跳跃，在空中时再按一次（<JUMP>）可使用二段跳。\" font=106</text>", Level = 2}
g_tTotur.tItem.BAG = {Text = "<text>text=\"背包\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"鼠标右键点击可以装备背包，装备后可是背包格数增加。按（<OPENORCLOSEALLBAGS>）可以打开查看背包。\" font=106</text>", Level = 4}
g_tTotur.tCommunicate.CHAT = {Text = "<text>text=\"聊天\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"按（<OPENCHAT>）可以打开聊天输入框。\" font=106</text>", Level = 4}
g_tTotur.tCommunicate.TEAM = {Text = "<text>text=\"组队\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"将对方选为目标，使用（\" font=106</text><text>text=\"鼠标右键\" font=101</text><text>text=\"）单击对方头像，可以找到“\" font=106</text><text>text=\"组队\" font=102</text><text>text=\"”选项，单击选项就可以进行组队。\" font=106</text>", Level = 5}
g_tTotur.tCommunicate.TEAM_SET = {Text = "<text>text=\"队伍设置\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"按（<TOGGLE_FRIEND_PANEL>）打开组队界面，可以更改队伍设置。\" font=106</text>", Level = 5}
g_tTotur.tCommunicate.START_TRADE = {Text = "<text>text=\"发起交易\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"将对方选为目标，使用（\" font=106</text><text>text=\"鼠标右键\" font=101</text><text>text=\"）单击对方头像，可以找到“交易”选项，单击选项即可邀请对方进行交易。\" font=106</text>", Level = 11}
g_tTotur.tCommunicate.TRADE = {Text = "<text>text=\"交易\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"（\" font=106</text><text>text=\"鼠标右键\" font=101</text><text>text=\"）单击背包内的物品，可以将物品移至交易位上。单击（\" font=106</text><text>text=\"交易按钮\" font=101</text><text>text=\"）将会进行交易。\" font=106</text>", Level = 11}
g_tTotur.tFight.DEATH = {Text = "<text>text=\"重伤\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"气血值降到零时表示身负重伤。选择“原地疗伤”会使你的装备受到10%的损坏，而“回营地休息”则降为5%。\" font=106</text>", Level = 10}
g_tTotur.tTraffic.DRIVERS = {Text = "<text>text=\"车夫\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"当你到达一个新的地点后，记得与车夫交谈，以后你就可以通过驿站回到这个地点。\" font=106</text>", Level = 10}
g_tTotur.tTraffic.ACCEPT_NEW = {Text = "<text>text=\"大地图\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"按（<TOGGLE_MIDDLEMAP>）打开大地图，可以查看当前地图的情况。\" font=106</text>", Level = 10}
g_tTotur.tCraft.READ = {Text = "<text>text=\"阅读书籍\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"右键单击书籍图标，可以打开\" font=106</text><text>text=\"阅读界面\" font=100</text><text>text=\"。\" font=106</text>", Level = 11}
g_tTotur.tFight.PK = {Text = "<text>text=\"切磋\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"发起切磋后，你将和目标进入一对一的战斗状态。\" font=106</text>", Level = 15}
g_tTotur.tFight.SLAUGHTER = {Text = "<text>text=\"屠杀\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"开启屠杀后，你对除队友外的所有人都进入敌对状态。\" font=106</text>", Level = 30}
g_tTotur.tFight.VENDETTA = {Text = "<text>text=\"仇杀\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"选中目标开启仇杀后，你会对该目标进入敌对状态。\" font=106</text>", Level = 30}
g_tTotur.tCraft.MINNING = {Text = "<text>text=\"采金\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"按（<TOGGLE_CRAFT_PANEL>）打开技艺界面，鼠标右键单击采金图标，可以自动搜索附近的矿石。\" font=106</text>", Level = 11}
g_tTotur.tCraft.HERBALISM = {Text = "<text>text=\"神农\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"按（<TOGGLE_CRAFT_PANEL>）打开技艺界面，鼠标右键单击神农图标，可以自动搜索附近的药材。\" font=106</text>", Level = 11}
g_tTotur.tCraft.LEAR_MIDDLE_NEEDLE = {Text = "<text>text=\"学习中级缝纫\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你可以到中级学习师那里去学习中级缝纫，通常他们在城市里。\" font=106</text>", Level = 25}
g_tTotur.tCraft.LEAR_HIGHT_NEEDLE = {Text = "<text>text=\"学习高级缝纫\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你可以到高级学习师那里去学习高级缝纫，高级缝纫师在某一城市里。\" font=106</text>", Level = 45}
g_tTotur.tCraft.LEAR_HIGHT_PHYSIC = {Text = "<text>text=\"学习高级医术\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你可以到高级学习师那里去学习高级医术，高级医术师在某一城市里。\" font=106</text>", Level = 45}
g_tTotur.tCraft.LEAR_HIGHT_FORGING = {Text = "<text>text=\"学习高级铸造\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你可以到高级学习师那里去学习高级锻造，高级铸造师在某一城市里。\" font=106</text>", Level = 45}
g_tTotur.tItem.USE_ITEM = {Text = "<text>text=\"使用道具\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"选择你要使用道具的目标，然后（\" font=106</text><text>text=\"鼠标右键\" font=101</text><text>text=\"）点击道具即可完成。\" font=106</text>", Level = 5}
g_tTotur.tOperator.COLLECT_ITEM = {Text = "<text>text=\"采集物品\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"使用（\" font=106</text><text>text=\"鼠标右键\" font=101</text><text>text=\"）点击\" font=106</text><text>text=\"闪光的植物\" font=102</text><text>text=\"便可采集到该物品。\" font=106</text>", Level = 5}
g_tTotur.tComment.QUEST_NAME = {Text = "<text>text=\"鼠标左键点击选择要领取的任务\" font=106</text>", Level = 0}
g_tTotur.tComment.QUEST_ACCESS = {Text = "<text>text=\"鼠标左键点击接取当前任务\" font=106</text>", Level = 0}
g_tTotur.tComment.QUEST_FINISH = {Text = "<text>text=\"鼠标左键点击此处可交任务\" font=106</text>", Level = 0}
g_tTotur.tComment.KUNGFU_USE = {Text = "<text>text=\"选中目标后，\" font=106</text><text>text=\"鼠标左键\" font=101</text><text>text=\"点击招式快捷栏中的“\" font=106</text><text>text=\"回风扫叶\" font=101</text><text>text=\"”招式，可对怪物造成高伤害。\" font=106</text>", Level = 0}
g_tTotur.tComment.DRAG_SKILL = {Text = "<text>text=\"使用鼠标左键拖至下方任一快捷栏\" font=106</text>", Level = 0}
g_tTotur.tComment.FIGHT = {Text = "<text>text=\"当前处于战斗状态\" font=106</text>", Level = 0}
g_tTotur.tComment.DEBUFF = {Text = "<text>text=\"当前处于疲劳状态\" font=106</text>", Level = 0}
g_tTotur.tComment.HEALTH = {Text = "<text>text=\"当前血量过低\" font=106</text>", Level = 0}
g_tTotur.tComment.SKILL_MEDITATION = {Text = "<text>text=\"单击可进行打坐回复\" font=106</text>", Level = 0}
g_tTotur.tComment.FIND_NPC = {Text = "<text>text=\"鼠标左键点击NPC名字，可标示其位置\" font=106</text>", Level = 0}
g_tTotur.tComment.FIRST_TEAM_HEAD = {Text = "<text>text=\"鼠标右键单击可获得更多操作\" font=106</text>", Level = 0}
g_tTotur.tComment.COMMENT_TRADE = {Text = "<text>text=\"鼠标左键点击按钮，将锁定物品并确认交易\" font=106</text>", Level = 0}
g_tTotur.tComment.MATRIX = {Text = "<text>text=\"鼠标左键点击开启阵法，开启前请确认你的队友在附近\" font=106</text>", Level = 0}
g_tTotur.tComment.BANK = {Text = "<text>text=\"你可以通过购买背包位来获得更多的存放位置\" font=106</text>", Level = 0}
g_tTotur.tOperator.SELL = {Text = "<text>text=\"贩卖物品\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你可以找到附近的商店出售背包里的灰色物品，所出售的物品在商店的回购栏里均可被购回。\" font=106</text>", Level = 15}
g_tTotur.tOperator.USE_BANK = {Text = "<text>text=\"使用仓库\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"使用（\" font=106</text><text>text=\"鼠标右键\" font=101</text><text>text=\"）点击背包里的物品可直接放入仓库存放。\" font=106</text>", Level = 16}
g_tTotur.tFight.USE_MATRIX = {Text = "<text>text=\"阵法\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"队伍中可以开启一个阵法，来提高队友间的战斗力。\" font=106</text>", Level = 20}
g_tTotur.tCraft.READ_MIDDLE = {Text = "<text>text=\"学习中级阅读\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你可以到中级教书先生那里去学习中级的阅读技艺，通常他们在城市里。\" font=106</text>", Level = 25}
g_tTotur.tOperator.USE_EMAIL = {Text = "<text>text=\"寄送信件\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"信件成功寄出后将在半小时后送达你的好友处。寄送信件需要消耗一定的金钱。\" font=106</text>", Level = 15}
g_tTotur.tCraft.LEAR_MIDDLE_GATHER = {Text = "<text>text=\"学习中级采金\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你可以到中级学习师那里去学习中级采金，通常他们在城市里。\" font=106</text>", Level = 25}
g_tTotur.tCraft.LEAR_MIDDLE_SEARCH = {Text = "<text>text=\"学习中级庖丁术\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你可以到中级学习师那里去学习中级庖丁术，通常他们在城市里。\" font=106</text>", Level = 25}
g_tTotur.tCraft.LEAR_MIDDLE_PHYSIC = {Text = "<text>text=\"学习中级医术\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你可以到中级学习师那里去学习中级医术，通常他们在城市里。\" font=106</text>", Level = 25}
g_tTotur.tCraft.LEAR_MIDDLE_COOKING = {Text = "<text>text=\"学习中级烹饪\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你可以到中级学习师那里去学习中级烹饪，通常他们在城市里。\" font=106</text>", Level = 25}
g_tTotur.tCraft.LEAR_MIDDLE_FORGING = {Text = "<text>text=\"学习中级铸造\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你可以到中级学习师那里去学习中级铸造，通常他们在城市里。\" font=106</text>", Level = 25}
g_tTotur.tCraft.LEAR_MIDDLE_AGRICULTURE = {Text = "<text>text=\"学习中级神农\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你可以到中级学习师那里去学习中级神农，通常他们在城市里。\" font=106</text>", Level = 25}
g_tTotur.tCraft.LEAR_HIGHT_GATHER = {Text = "<text>text=\"学习高级采金\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你可以到高级学习师那里去学习高级采金，高级采金师在某一城市里。\" font=106</text>", Level = 45}
g_tTotur.tCraft.LEAR_HIGHT_SEARCH = {Text = "<text>text=\"学习高级庖丁术\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你可以到高级学习师那里去学习高级庖丁术，高级庖丁师在某一城市里。\" font=106</text>", Level = 45}
g_tTotur.tCraft.LEAR_HIGHT_COOKING = {Text = "<text>text=\"学习高级烹饪\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你可以到高级学习师那里去学习高级烹饪，高级烹饪师在某一城市里。\" font=106</text>", Level = 45}
g_tTotur.tCraft.LEAR_HIGHT_AGRICULTURE = {Text = "<text>text=\"学习高级神农\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你可以到高级学习师那里去学习高级神农，高级神农师在某一城市里。\" font=106</text>", Level = 45}
g_tTotur.tCraft.READ_HIGHT = {Text = "<text>text=\"学习高级阅读\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你可以到高级教书先生那里去学习高级的阅读技艺,通常他们在城市里。\" font=106</text>", Level = 45}
g_tTotur.tCraft.CHOOSE_NEEDLE = {Text = "<text>text=\"选择分支\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你可以学习刺绣或者印染分支，这样就能学习到一些独有的分支配方，你只能学习一个分支。\" font=106</text>", Level = 45}
g_tTotur.tCraft.CHOOSE_PHYSIC = {Text = "<text>text=\"选择分支\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你可以学习万花医术或江湖医术分支，这样就能学习到一些独有的分支配方，你只能学习一个分支。\" font=106</text>", Level = 45}
g_tTotur.tCraft.CHOOSE_FORGING = {Text = "<text>text=\"选择分支\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你可以学习武器锻造或制甲分支，这样就能学习到一些独有的分支配方，你只能学习一个分支。\" font=106</text>", Level = 45}
g_tTotur.tOperator.GO = {Text = "<text>text=\"自动前行\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"当你进行长距离行进时，按下（<TOGGLEAUTORUN>）键可以使你的角色一直向前行进，再次按下（<TOGGLEAUTORUN>）键可停下。\" font=106</text>", Level = 6}
g_tTotur.tKungfu.INTERNAL_WORK = {Text = "<text>text=\"装备内功\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你需要装备内功才能使用本门对应的招式。在快捷栏左侧选择需要装备的内功。\" font=106</text>", Level = 15}
g_tTotur.tKungfu.SWITCH = {Text = "<text>text=\"内功切换\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"选择内功后，需要等待15分钟才能进行下一次内功切换。\" font=106</text>", Level = 15}
g_tTotur.tKungfu.INTO_DOOR = {Text = "<text>text=\"加入门派\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"15级可以选择门派加入。你可以在扬州再来镇、洛阳风雨镇、长安红衣教营地找到各大门派的武学训练师。\" font=106</text>", Level = 15}
g_tTotur.tKungfu.POINT = {Text = "<text>text=\"修习经脉\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"从现在开始可以修习经脉中的任脉。修习经脉会消耗你储存在气海里的修为值，消耗掉的修为会进入丹田。\" font=106</text>", Level = 20}
g_tTotur.tKungfu.POINT_FOUR = {Text = "<text>text=\"任脉、督脉、冲脉、带脉\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"任脉提高基础能力，督脉提高辅助能力，冲脉提高内功能力，而带脉则提高外功能力。\" font=106</text>", Level = 40}
g_tTotur.tCraft.EXCERPTION = {Text = "<text>text=\"抄录\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"抄录书籍可与别人分享交流，也可提升自身的阅读等级。抄录需要的材料工具可在书商处购买或由打怪掉落来获得。\" font=106</text>", Level = 15}
g_tTotur.tQuest.DELETE = {Text = "<text>text=\"删除任务\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"当任务达到上限25个时，你将不能接取新的任务。此时你可以通过删除灰色任务来解决这个问题。任务删除后可重新接取。\" font=106</text>", Level = 30}
g_tTotur.tItem.BUG_FULL = {Text = "<text>text=\"仓库存放\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你可以在任意一个门派、城市或新手镇找到仓库总管为你保管财物。\" font=106</text>", Level = 25}
g_tTotur.tCraft.CHANGE_BOOK = {Text = "<text>text=\"书籍兑换\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你已阅读了一套完整的书籍，将书籍全套抄录下来，可以找到城市的收书人兑换奖励。\" font=106</text>", Level = 20}
g_tTotur.tItem.SIT = {Text = "<text>text=\"坐骑\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"坐骑使用（\" font=106</text><text>text=\"鼠标右键\" font=101</text><text>text=\"）单击图标可以装备马匹，按下（<RIDEHORSE>）键可以快速上下马。\" font=106</text>", Level = 20}
g_tTotur.tComment.READ_AGAIN = {Text = "<text>text=\"鼠标左键点击此处，可再次阅读已读过的书籍\" font=106</text>", Level = 0}
g_tTotur.tOperator.KILL = {Text = "<text>text=\"拾取物品\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"使用（\" font=106</text><text>text=\"鼠标右键\" font=101</text><text>text=\"）点击闪光的尸体，可拾取地上的物品。\" font=106</text>", Level = 5}
g_tTotur.tKungfu.KNOW = {Text = "<text>text=\"招式领悟\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"在等级限制内，招式达到一定的熟练度时可自动领悟到更高的重数。\" font=106</text>", Level = 0}
g_tTotur.tComment.FIX = {Text = "<text>text=\"鼠标左键点击此处可获得全部物品\" font=106</text>", Level = 0}
g_tTotur.tKungfu.ALL = {Text = "<text>text=\"使用（\" font=106</text><text>text=\"鼠标左键\" font=101</text><text>text=\"）点击图标可施放“\" font=106</text><text>text=\"横扫千军\" font=100</text><text>text=\"”，可同时对4个目标造成外功伤害。此招式需要一定的调息时间。\" font=106</text>", Level = 5}
g_tTotur.tCommunicate.FRIEND = {Text = "<text>text=\"好友\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"将对方选为目标，使用（\" font=106</text><text>text=\"鼠标右键\" font=101</text><text>text=\"）单击对方头像，可以找到“\" font=106</text><text>text=\"好友\" font=102</text><text>text=\"”选项，单击选项就可以添加好友。\" font=106</text>", Level = 5}
g_tTotur.tEquip.WARNING = {Text = "<text>text=\"装备受损\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你当前的装备受损过度，请尽快找到武器商、服装商或杂货商为你修理。\" font=106</text>", Level = 0}
g_tTotur.tComment.DAMAGE = {Text = "<text>text=\"当前装备已损坏,失去效果\" font=106</text>", Level = 0}
g_tTotur.tComment.CHATPANEL = {Text = "<text>text=\"输入你要说的话，再按（回车）即可发送。\" font=106</text>", Level = 0}
g_tTotur.tComment.CAN_TRADE = {Text = "<text>text=\"鼠标右键单击此处，可以选择与该玩家交易\" font=106</text>", Level = 0}
g_tTotur.tComment.MOUNT_KONGFU = {Text = "<text>text=\"点击此处可选择内功\" font=106</text>", Level = 0}
g_tTotur.tComment.MOUNT_ONE_KONGFU = {Text = "<text>text=\"点击可装备内功\" font=106</text>", Level = 0}
g_tTotur.tQuest.GET_HELP = {Text = "<text>text=\"协助任务\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"当你帮助队友完成一个你已完成过的任务时，可以获得一定的协助奖励。这个任务必须是可被协助的，且在协助过程中和交任务时不能离队友太远。\" font=106</text>", Level = 2}
g_tTotur.tQuest.FULL_HELP = {Text = "<text>text=\"协助任务上限\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你的协助任务已经达到今日上限，你可以通过提升等级增加任务上限。\" font=106</text>", Level = 3}
g_tTotur.tCraft.NO_HAVE = {Text = "<text>text=\"精力体力\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你可以通过帮助队友完成协助任务来增加精力或体力。\" font=106</text>", Level = 2}
g_tTotur.tQuest.GOODFRIEND = {Text = "<text>text=\"好感度\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你可以通过组队、送礼、帮助好友完成协助任务，或者每日一次密聊来提升你与好友间的好感度。\" font=106</text>", Level = 0}
g_tTotur.tComment.GET_A_HELP = {Text = "<text>text=\"可协助任务。协助完成可获得体力4，精力4，好感度5的协助奖励\" font=106</text>", Level = 0}
g_tTotur.tComment.FULL_A_HELP = {Text = "<text>text=\"通过提升等级可以加大协助任务的上限\" font=106</text>", Level = 0}
g_tTotur.tComment.LEARN_RENMAI = {Text = "<text>text=\"点击为任脉中的冲穴注入修为\" font=106</text>", Level = 0}
g_tTotur.tCommunicate.TONG = {Text = "<text>text=\"帮会\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你现在可以去城市里找到帮会接引人帮助你创建帮会。创建帮会需要30金的费用。\" font=106</text>", Level = 0}
g_tTotur.tOperator.NPC_BUSY = {Text = "<text>text=\"剧情动画\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"该NPC正在演绎剧情中，请稍后点击与之对话。\" font=106</text>", Level = 7}
g_tTotur.tItem.USE = {Text = "<text>text=\"道具\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"在指定的位置，使用（\" font=106</text><text>text=\"鼠标右键\" font=101</text><text>text=\"）点击道具即可完成。\" font=106</text>", Level = 7}
g_tTotur.tOperator.NPC_BUY = {Text = "<text>text=\"购买物品\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"使用（\" font=106</text><text>text=\"鼠标右键\" font=101</text><text>text=\"）点击商店物品，即可购买。\" font=106</text>", Level = 12}
g_tTotur.tKungfu.RARE = {Text = "<text>text=\"奇穴\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你已激活了奇穴中的某个穴位，现在可以点击修习奇穴了。\" font=106</text>", Level = 30}
g_tTotur.tComment.TEAMS = {Text = "<text>text=\"左键点击可以获得更多操作\" font=106</text>", Level = 0}
g_tTotur.tComment.TONGGIVE = {Text = "<text>text=\"帮会贡献值可用于购买声望装\" font=106</text>", Level = 0}
g_tTotur.tComment.JOIN = {Text = "<text>text=\"鼠标左键\" font=101</text><text>text=\"点击此处可查看任务交还地点\" font=106</text>", Level = 0}
g_tTotur.tComment.QIXUE = {Text = "<text>text=\"现在可开始为奇穴注入修为\" font=106</text>", Level = 0}
g_tTotur.tCommunicate.CONTRIBUTION = {Text = "<text>text=\"帮会贡献\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"参与帮会活动可获得帮会贡献。帮会贡献可用于购买帮会商店的装备和物品。\" font=106</text>", Level = 25}
g_tTotur.tOperator.ROOL_ITEM = {Text = "<text>text=\"物品分配\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你可以点击界面上的“\" font=106</text><text>text=\"骰子\" font=102</text><text>text=\"”按钮来竞得你所需要的装备物品，也可以点击放弃你所不需要的。\" font=106</text>", Level = 6}
g_tTotur.tQuest.QUEST_FAILED = {Text = "<text>text=\"任务失败\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你可以从（<TOGGLE_QUEST_PANEL>）面板删除已失败的任务，任务删除后可以重新领取。\" font=106</text>", Level = 15}
g_tTotur.tOperator.WEAPO0N_LONG = {Text = "<text>text=\"远程攻击\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"使用远程招式“\" font=106</text><text>text=\"虹气长空\" font=101</text><text>text=\"”，需选中目标，在一定距离内可释放。\" font=106</text>", Level = 5}
g_tTotur.tComment.BOOKBOX = {Text = "<text>text=\"右键点击可装备书箱，书箱只可存放书籍\" font=106</text>", Level = 0}
g_tTotur.tComment.HORSES = {Text = "<text>text=\"右键点击装备马匹\" font=106</text>", Level = 0}
g_tTotur.tComment.ART = {Text = "<text>text=\"鼠标左键\" font=101</text><text>text=\"点击可打开招式学习面板。\" font=106</text>", Level = 0}
g_tTotur.tComment.PICK = {Text = "<text>text=\"单击图标，在小地图显示矿石的位置\" font=106</text>", Level = 0}
g_tTotur.tComment.CULL = {Text = "<text>text=\"单击图标，在小地图显示药材的位置\" font=106</text>", Level = 0}
g_tTotur.tKungfu.WUSHU = {Text = "<text>text=\"门派武学\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"进入门派后可在武学训练师处习得门派武学。往后角色每升2级都可在此学习新的武学招式。\" font=106</text>", Level = 15}
g_tTotur.tOperator.STRAW = {Text = "<text>text=\"稻草人\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"使用（\" font=106</text><text>text=\"鼠标右键\" font=101</text><text>text=\"）点击包裹里的“\" font=106</text><text>text=\"稻草人\" font=102</text><text>text=\"”，在指定的地方放置。\" font=106</text>", Level = 5}
g_tTotur.tCommunicate.JOINBANG = {Text = "<text>text=\"加入帮会\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你已加入了帮会，可以使用帮会频道。按“<TOGGLE_GUILD_PANEL>”可打开帮会界面查看当前帮会情况。\" font=106</text>", Level = 21}
g_tTotur.tOperator.EARNING = {Text = "<text>text=\"收取信件\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你当前收到了新的信件，请到城市、新手镇或门派处找到信使收取信件。\" font=106</text>", Level = 11}
g_tTotur.tComment.DRAWIN = {Text = "<text>text=\"当前收到了新的信件\" font=106</text>", Level = 0}
g_tTotur.tCommunicate.BASED = {Text = "<text>text=\"语音使用\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"使用语音软件（例如:歪歪），方便你更好地指挥帮会活动。\" font=106</text>", Level = 30}
g_tTotur.tOperator.DOT = {Text = "<text>text=\"点燃火堆\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"使用（\" font=106</text><text>text=\"鼠标右键\" font=101</text><text>text=\"）点击闪光的草垛，可直接点燃。\" font=106</text>", Level = 6}
g_tTotur.tComment.PAPER = {Text = "<text>text=\"点击可查看“大唐驿报”\" font=106</text>", Level = 10}
g_tTotur.tOperator.NEWSPAPER = {Text = "<text>text=\"侠客文摘\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"长路漫漫，阅读文摘打发时间，岂不快哉。你可以点击小地图旁边的“江湖指南”按钮中的大唐驿报开始阅读。\" font=106</text>", Level = 10}
g_tTotur.tCommunicate.RIPTIDE = {Text = "<text>text=\"传音入密\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"你可以到隐元会神秘商人“天字玖叁”处接取任务《传音入密》，完成后可参加抢夺“歪歪2.0激活码”活动。\" font=106</text>", Level = 8}
g_tTotur.tCommunicate.JIANGHU_GUIDE = {Text = "<text>text=\"点击“江湖指南”按钮可以再次打开历程提示\" font=106</text>", Level = 0}
g_tTotur.tQuest.LEARN_SKILL = {Text = "<text>text=\"鼠标左键点击可学习招式\" font=106</text>", Level = 0}
g_tTotur.tQuest.USE_SITSKILL = {Text = "<text>text=\"鼠标左键点击进行打坐\" font=106</text>", Level = 0}
g_tTotur.tQuest.USE_BAG = {Text = "<text>text=\"鼠标右键点击即可装备背包,按（<OPENORCLOSEALLBAGS>）可打开所有背包\" font=106</text>", Level = 0}
g_tTotur.tQuest.NEWER_SKILL = {Text = "<text>text=\"武学招式\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"每隔两级可到此处学习新的武学招式。\" font=106</text>", Level = 0}
g_tTotur.tAnounce.LEVELFOUR = {Text = "<text>text=\"恭喜您，已完成所有新手任务了\" font=100</text>", Level = 4}
g_tTotur.tAnounce.LEVELSIX = {Text = "<text>text=\"已6级，可向刘大海学习新招式了。\" font=24</text>", Level = 6}
g_tTotur.tAnounce.LEVELEIGHT = {Text = "<text>text=\"已8级，可向刘大海学新招式了。\" font=24</text>", Level = 0}
g_tTotur.tComment.CHANGECLOTHES = {Text = "<text>text=\"鼠标右键点击可直接更换装备，使自身属性得到提升\" font=106</text>", Level = 0}
g_tTotur.tComment.CHOOSECOMPLETEQUEST = {Text = "<text>text=\"鼠标左键点击选择已完成的任务\" font=106</text>", Level = 0}
g_tTotur.tPicture.TURNSHOT = {Text = "<image>path=\"ui/Image/Helper/HelpTip.UITex\" frame=0 w=251 h=247</image><text>text=\"\\\n\\\n如何转身\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"按住\" font=106</text><text>text=\"鼠标右键 \" font=101</text><image>path=\"ui/Image/UICommon/CommonPanel2.UITex\" frame=37 w=18 h=32</image><text>text=\" 拖动，可转身。\\\n\\\n\" font=106</text><text>text=\"如何看自己\\\n\" font=100</text><text>text=\"按住\" font=106</text><text>text=\"鼠标左键 \" font=101</text><image>path=\"ui/Image/UICommon/CommonPanel2.UITex\" frame=45 w=18 h=32</image><text>text=\" 拖动,可使自身朝向不变,而看到自己的正面。\" font=106</text>", Level = 0}
g_tTotur.tPicture.MOUSE_MOVE = {Text = "<text>text=\"\\\n\" font=100</text><image>path=\"ui/Image/Helper/test.UITex\" frame=2 w=251 h=248</image><text>text=\"\\\n\\\n交任务\\\n\" font=100</text><text>text=\"NPC头顶有黄色卷轴  \" font=106</text><image>path=\"ui/Image/UICommon/CommonPanel2.UITex\" frame=123 w=28 h=21</image><text>text=\" 表示有可以交的任务。点击远处的地面移动到NPC身边。\" font=106</text><text>text=\"鼠标右键 \" font=101</text><image>path=\"ui/Image/UICommon/CommonPanel2.UITex\" frame=37 w=16 h=31</image><text>text=\" 点击NPC即可。\\\n\" font=106</text>", Level = 0}
g_tTotur.tItem.GET_QUESTTHING = {Text = "<text>text=\"拾取任务物品\" font=100</text><text>text=\"\\\n\" font=128</text><text>text=\"（\" font=106</text><text>text=\"鼠标右键\" font=101</text><text>text=\"）点击地上\" font=106</text><text>text=\"闪光的果子狸\" font=102</text><text>text=\"尸体，可拾取到任务所需的物品。\" font=106</text>", Level = 0}
g_tTotur.tOperator.USE_SKILLSIT = {Text = "<text>text=\"鼠标左键\" font=101</text><text>text=\"点击招式快捷栏中的“\" font=106</text><text>text=\"调息\" font=101</text><text>text=\"”招式或按（<TOGGLESITDOWN>）可打坐或起立。\" font=106</text>", Level = 3}
g_tTotur.tOperator.Click_MidMapIconZQ = {Text = "<text>text=\"鼠标左键\" font=101</text><text>text=\"点击此图标，可打开大地图查找\" font=106</text><text>text=\"紫晴\" font=101</text><text>text=\"所在位置。\" font=106</text>", Level = 4}
g_tTotur.tOperator.Click_QuestIcon = {Text = "<text>text=\"鼠标左键\" font=101</text><text>text=\"点击此图标，可打开任务界面查看任务详细信息。\" font=106</text>", Level = 1}
g_tTotur.tQuest.QuestArea = {Text = "<text>text=\"鼠标左键\" font=101</text><text>text=\"点击此处，可打开大地图查看任务怪所在位置。\" font=106</text>", Level = 4}
g_tTotur.tOperator.MidMapGuide = {Text = "<text>text=\"地图中黄色展开卷轴图标为交任务NPC所在的位置。\" font=106</text>", Level = 0}
g_tTotur.tOperator.Click_MidMapIconZHQ = {Text = "<text>text=\"鼠标左键\" font=101</text><text>text=\"点击此图标，可打开大地图查找\" font=106</text><text>text=\"张强\" font=101</text><text>text=\"所在位置。\\\n\" font=106</text>", Level = 5}
g_tTotur.tOperator.Click_MidMapIconXY = {Text = "<text>text=\"鼠标左键\" font=101</text><text>text=\"点击此图标，可打开大地图查找\" font=106</text><text>text=\"小月\" font=101</text><text>text=\"所在位置。\" font=106</text>", Level = 6}
g_tTotur.tOperator.Click_PackageIcon = {Text = "<text>text=\"（\" font=106</text><text>text=\"鼠标左键\" font=101</text><text>text=\"）点击此处可打开背包，查看所获得物品。\" font=106</text>", Level = 0}
g_tTotur.tItem.GrayThingsMessege = {Text = "<text>text=\"灰色物品可卖入商店获得金钱。\" font=106</text>", Level = 0}
g_tTotur.tItem.GreenThingsMessege = {Text = "<text>text=\"名称显示为绿色的装备要比名称为白色的装备好。\" font=106</text>", Level = 0}
g_tTotur.tItem.BlueThingsMessege = {Text = "<text>text=\"名称显示为蓝色的装备要比名称为绿色的装备好。\" font=106</text>", Level = 0}
g_tTotur.tOperator.LearnMove = {Text = "<text>text=\"\\\n\" font=128</text><image>path=\"ui/Image/Helper/HelpTip.UITex\" frame=2 w=251 h=247</image><text>text=\"\\\n\\\n\" font=128</text><text>text=\"如何走路\" font=100</text><text>text=\"\\\n\\\n\" font=128</text><text>text=\"W：前进              S：后退              A：向左转            D：向右转\" font=106</text>", Level = 0}
g_tTotur.tQuest.YellowNameNPC = {Text = "<text>text=\"黄名怪\\\n\" font=100</text><text>text=\"黄色名字的怪物不会主动攻击你，可放心靠近。而红色名字的怪，只要你在其视线范围内被发现后，便会主动攻击你。\" font=106</text>", Level = 0}
g_tTotur.tComment.PartyRecruit = {Text = "<text>text=\"鼠标左键点击，可打开“秘境队伍招募”界面进行寻求组队\" font=106</text>", Level = 30}
g_tTotur.tQuest.QuestGuide = {Text = "<text>text=\"您可根据任务指向针的指示找到任务完成地点或任务目标所在。\" font=106</text>", Level = 0}
g_tTotur.tOperator.ChangeWeapon = {Text = "<text>text=\"点击头像边的“重剑”或“轻剑”图标可自动切换武器。\" font=106</text>", Level = 15}
g_tTotur.tQuest.LearnFuYaoOne = {Text = "<text>text=\"扶摇直上\\\n\" font=100</text><text>text=\"除在本门武学训练师处外，在五大门派、长安、枫华谷、洛道、洛阳、金水及寇岛处均可通过特殊方式习得各1重，最高11重的扶摇直上。\" font=106</text>", Level = 15}
g_tTotur.tQuest.LearnFuYaoSeven = {Text = "<text>text=\"扶摇直上\\\n\" font=100</text><text>text=\"在五大门派、长安、枫华谷、洛道、洛阳、金水及寇岛处均可通过特殊方式习得各1重，最高11重的扶摇直上。\" font=106</text>", Level = 40}
g_tTotur.tQuest.NEWPRESENT = {Text = "<text>text=\"右键点击\" font=100</text><text>text=\"可打开礼包，再点击“\" font=106</text><text>text=\"全部拾取\" font=100</text><text>text=\"”便可将所有物品放入背包。\" font=106</text>", Level = 2}
g_tTotur.tQuest.NEWPRESENTTWO = {Text = "<text>text=\"5级\" font=100</text><text>text=\"时可右键打开此礼包，拿取新手奖励。\" font=106</text>", Level = 5}
g_tTotur.tQuest.NEWPRESENTTHREE = {Text = "<text>text=\"10级\" font=100</text><text>text=\"时可右键打开此礼包，拿取新手奖励。\" font=106</text><text>text=\"\\\n\" font=128</text>", Level = 10}
g_tTotur.tComment.KNOWGUILD = {Text = "<text>text=\"鼠标左键点击，可查看帮会列表\" font=106</text>", Level = 10}
g_tTotur.tComment.GUILD55000 = {Text = "<text>text=\"鼠标左键点击，可了解帮会贡献值的用途\" font=106</text>", Level = 0}
g_tTotur.tOperator.LearnSkill537 = {Text = "<text>text=\"请先施展\" font=106</text><text>text=\"“名动四方”\" font=102</text><text>text=\"招式后进行剑舞状态才能施放其他招式。\" font=106</text>", Level = 5}
g_tTotur.tOperator.LearnSkill415 = {Text = "<text>text=\"此招式需先施放招式\" font=106</text><text>text=\"“穿云”\" font=102</text><text>text=\"，多次后方可使用。\" font=106</text>", Level = 10}
g_tTotur.tOperator.LearnSkill301 = {Text = "<text>text=\"施放此招式需要消耗角色头像处的\" font=106</text><text>text=\"“纯阳气劲”\" font=102</text><text>text=\"，气劲越多则威力越大。\" font=106</text>", Level = 5}
g_tTotur.tOperator.LearnSkill1565 = {Text = "<text>text=\"此招式可快速切换内功，并切换武器。\" font=106</text>", Level = 10}
g_tTotur.tOperator.LearnSkill233 = {Text = "<text>text=\"施放此招式需要消耗角色头像处的\" font=102</text><text>text=\"“禅那点”，禅那点越多则威力越大。\" font=106</text>", Level = 10}
