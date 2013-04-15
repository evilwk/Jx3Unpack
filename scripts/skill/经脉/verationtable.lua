------------------------------------------------
-- 文件名    :  Venation.lua
-- 创建人    :  Wangtao
-- 创建时间  :  2008-04-07
-- 用途(模块):  经脉系统
-- 武功门派  :  无
-- 武功类型  :  无
-- 武功套路  :  无
-- 技能名称  :  无
-- 技能效果  :  打通经脉的脚本表
------------------------------------------------
-- 经脉消费，结构为：[ID] = 消费修为数值
BASE_VENATION       = 0
PHYSICS_VENATION    = 1
MAGIC_VENATION      = 2
ASSIST_VENATION     = 3
--	TRAIN_PER_HOUR 穴位消耗的每小时点数,现在的设计是 每个穴位需要的修为=穴位小时数*每小时点数
TRAIN_PER_HOUR      = 20

USE_TRAIN_LIMIT = 100000;

ERR_OPEN_VENATION_SUCCESS = 1;
ERR_OPEN_VENATION_ERROR   = 2;
ERR_OPEN_VENATION_LEVEL_LOWER = 3;
ERR_OPEN_VENATION_NOT_ENOUGH_TRAIN = 4;
ERR_OPEN_VENATION_NOT_OPEN = 5;
ERR_OPEN_VENATION_LIMIT_TRAIN = 6;

tZhuanhuan = {300, 700, 1200, 1800, 2650, 3700, 5000, 10000, 20000, 40000} --奇穴等级对应修为
tVenationEffectID = {9,1206,40,41,42,43,44,45,46,170}
-- 旧经脉特殊效果
VenationEffectOld =
{
    [ 9]  = {Requirement = {75}, RequirementLevel = {1}}, -- 这个特效需要3条经脉被打通，分别是1、2、3号被动技能，获得特效的被动技能ID为512
    [1206]  = {Requirement = {76}, RequirementLevel = {1}},
    [40]  = {Requirement = {1571}, RequirementLevel = {1}},
    [41]  = {Requirement = {115}, RequirementLevel = {1}},
    [42]  = {Requirement = {116}, RequirementLevel = {1}},
    [43]  = {Requirement = {117}, RequirementLevel = {1}},
    [44]  = {Requirement = {154}, RequirementLevel = {1}},
    [45]  = {Requirement = {155}, RequirementLevel = {1}},
    [46]  = {Requirement = {168}, RequirementLevel = {1}},
    [170] = {Requirement = {169}, RequirementLevel = {1}},

};
-- 旧经脉ID
VenationDifficultOld =
{
    --基础系各经脉成功率
    [60] = {1024, 973, 921, 870, 819}, --33号经脉第一级的成功率为50%，第二级的成功率为100%
    [62] = {1024, 973, 921, 870, 819},
    [63] = {1024, 973, 921, 870, 819},
    [64] = {768},
    [65] = {768},
    [66] = {768},
    [67] = {1024, 973, 921, 870, 819},
    [68] = {1024, 973, 921, 870, 819},
    [69] = {1024, 973, 921, 870, 819},
    [70] = {921, 870, 819, 768, 717},
    [71] = {921, 870, 819, 768, 717},
    [72] = {614},
    [73] = {870, 819, 768, 717, 666},
    [74] = {819, 768, 717, 666, 614},
    [75] = {614, 512},
    [76] = {819, 768, 717, 666, 614},
    [77] = {1024, 973, 921, 870, 819},
    [78] = {1024, 973, 921, 870, 819},
    [79] = {921, 870, 819, 768, 717},
    [80] = {921, 870, 819, 768, 717},
    [1196] = {717},
    [82] = {921, 870, 819, 768, 717},
    [83] = {921, 870, 819, 768, 717},
    [84] = {717, 614},
    [85] = {870, 819, 768, 717, 666},
    [1572] = {819, 768, 717, 666, 614},
	 [1573] = {819, 768, 717, 666, 614},
    [86] = {870, 819, 768, 717, 666},
    [87] = {921, 870, 819, 768, 717},
    [88] = {921, 870, 819, 768, 717},
    [89] = {870, 819, 768, 717, 666},
    [90] = {819, 768, 717, 666, 614},
    [1571] = {768, 717, 666, 614, 563},
    [ 9] = {1024,1024,1024,1024,1024,1024,1024,1024,1024,1024},
    [1206] = {1024,1024,1024,1024,1024,1024,1024,1024,1024,1024},
    [40] = {1024,1024,1024,1024,1024,1024,1024,1024,1024,1024},

    --辅助系各经脉各级成功率
    [91] = {921, 870, 819, 768, 717},
    [92] = {870, 819, 768, 717, 666},
    [93] = {870, 819, 768, 717, 666},
    [94] = {870, 819, 768, 717, 666},
    [95] = {819, 768, 717, 666, 614},
    [96] = {819, 666, 563},
    [97] = {819, 666, 563},
    [98] = {819, 768, 717, 666, 614},
    [99] = {819, 768, 717, 666, 614},
    [110] = {768, 717, 666, 614, 563},
    [111] = {768, 717, 666, 614, 563},
    [112] = {768, 717, 666, 614, 563},
    [113] = {768, 717, 666, 614, 563},
    [114] = {614},
    [115] = {512},
    [116] = {512},
    [117] = {512},
    [41] = {1024,1024,1024,1024,1024,1024,1024,1024,1024,1024},
    [42] = {1024,1024,1024,1024,1024,1024,1024,1024,1024,1024},
    [43] = {1024,1024,1024,1024,1024,1024,1024,1024,1024,1024},

    --外功系各经脉各级成功率
    [118] = {921, 870, 819, 768, 717},
    [127] = {870, 819, 768, 717, 666},
    [126] = {819, 768, 717, 666, 614},
    [121] = {768, 717, 666},
    [122] = {768, 717, 666},
    [123] = {768, 717, 666},
    [124] = {768, 717, 666},
    [120] = {819, 768, 717, 666, 614},
    [119] = {819, 768, 717, 666, 614},
    [128] = {819, 768, 717, 666, 614},
    [129] = {768, 717, 666, 614, 563},
    [154] = {614},
    [153] = {614},
    [155] = {614},
    [44] = {1024,1024,1024,1024,1024,1024,1024,1024,1024,1024},
    [45] = {1024,1024,1024,1024,1024,1024,1024,1024,1024,1024},

    --内功系各经脉各级成功率
    [156] = {921, 870, 819, 768, 717},
    [164] = {870, 819, 768, 717, 666},
    [163] = {819, 768, 717, 666, 614},
    [159] = {768, 717, 666},
    [160] = {768, 717, 666},
    [161] = {768, 717, 666},
    [162] = {768, 717, 666},
    [158] = {819, 768, 717, 666, 614},
    [157] = {819, 768, 717, 666, 614},
    [165] = {819, 768, 717, 666, 614},
    [166] = {768, 717, 666, 614, 563},
    [167] = {614},
    [168] = {614},
    [169] = {614},
    [46] = {1024,1024,1024,1024,1024,1024,1024,1024,1024,1024},
    [170] = {1024,1024,1024,1024,1024,1024,1024,1024,1024,1024},

};

-- 经脉打通的需求
VenationRequireGongli =
{
    --基础系
    [60] = 0,-- 20级才能打通经脉
    [1960] = 0,
    [1958] = 0,
    [64] = 0,
    [65] = 0,
    [66] = 0,
    [1959] = 0,
    [68] = 0,
    [1961] = 0,
    [70] = 0,
    [1962] = 0,
    [1963] = 0,
    [1964] = 0,
    [1965] = 0,
    [75] = 0,
    [1966] = 0,
    [77] = 0,
    [78] = 0,
    [79] = 0,
    [80] = 0,
    [1196] = 0,
    [82] = 0,
    [83] = 0,
    [84] = 0,
    [85] = 0,
    [1572] = 0,
    [1573] = 0,
    [86] = 0,
    [87] = 0,
    [88] = 0,
    [89] = 0,
    [90] = 0,
    [1571] = 0,
    [ 9] = 0,
    [1206] = 0,
    [40] = 0,

    --辅助系
    [91] = 0,
    [92] = 0,
    [93] = 0,
    [1949] = 0,
    [1950] = 0,
    [1951] = 0,
    [1952] = 0,
    [95] = 0,
    [96] = 0,
    [97] = 0,
    [98] = 0,
    [99] = 0,
    [110] = 0,
    [111] = 0,
    [112] = 0,
    [113] = 0,
    [114] = 0,
    [115] = 0,
    [116] = 0,
    [117] = 0,
    [ 41] = 0,
    [42] = 0,
    [43] = 0,
    --外功系
    [118] = 0,
    [119] = 0,
    [120] = 0,
    [121] = 0,
    [122] = 0,
    [123] = 0,
    [124] = 0,
    [126] = 0,
    [127] = 0,
    [128] = 0,
    [129] = 0,
    [153] = 0,
    [154] = 0,
    [155] = 0,
    [44] = 0,
    [45] = 0,
    --内功系
    [156] = 0,
    [157] = 0,
    [158] = 0,
    [159] = 0,
    [160] = 0,
    [161] = 0,
    [162] = 0,
    [163] = 0,
    [164] = 0,
    [165] = 0,
    [166] = 0,
    [167] = 0,
    [168] = 0,
    [169] = 0,
    [46] = 0,
    [170] = 0,

};

VenationCost =
{

    --基础系
    [60] = {12*TRAIN_PER_HOUR, 18*TRAIN_PER_HOUR, 20*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR},-- ID为33的经脉被动技能第一级需要100点修为作为学习的消耗，此处，每个等级的消耗需要分别维护
    [1960] = {125*TRAIN_PER_HOUR},
    [1958] = {20*TRAIN_PER_HOUR, 25*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR},
    [64] = {12*TRAIN_PER_HOUR, 18*TRAIN_PER_HOUR, 20*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR},
    [65] = {12*TRAIN_PER_HOUR, 18*TRAIN_PER_HOUR, 20*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR},
    [66] = {12*TRAIN_PER_HOUR, 18*TRAIN_PER_HOUR, 20*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR},
    [1959] = {125*TRAIN_PER_HOUR},
    [68] = {12*TRAIN_PER_HOUR, 18*TRAIN_PER_HOUR, 20*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR},
    [1961] = {125*TRAIN_PER_HOUR},
    [70] = {18*TRAIN_PER_HOUR, 27*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR, 45*TRAIN_PER_HOUR, 54*TRAIN_PER_HOUR},
    [1962] = {150*TRAIN_PER_HOUR},
    [1963] = {125*TRAIN_PER_HOUR},
    [1964] = {150*TRAIN_PER_HOUR},
    [1965] = {125*TRAIN_PER_HOUR},
    [75] = {20*TRAIN_PER_HOUR, 25*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR},
    [1966] = {150*TRAIN_PER_HOUR},
    [77] = {6*TRAIN_PER_HOUR,  9*TRAIN_PER_HOUR,  12*TRAIN_PER_HOUR, 15*TRAIN_PER_HOUR, 18*TRAIN_PER_HOUR},
    [78] = {6*TRAIN_PER_HOUR,  9*TRAIN_PER_HOUR,  12*TRAIN_PER_HOUR, 15*TRAIN_PER_HOUR, 18*TRAIN_PER_HOUR},
    [79] = {12*TRAIN_PER_HOUR, 18*TRAIN_PER_HOUR, 20*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR},
    [80] = {12*TRAIN_PER_HOUR, 18*TRAIN_PER_HOUR, 20*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR},
    [1196] = {48*TRAIN_PER_HOUR},
    [82] = {12*TRAIN_PER_HOUR, 18*TRAIN_PER_HOUR, 20*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR},
    [83] = {12*TRAIN_PER_HOUR, 18*TRAIN_PER_HOUR, 20*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR},
    [84] = {36*TRAIN_PER_HOUR, 45*TRAIN_PER_HOUR},
    [85] = {18*TRAIN_PER_HOUR, 27*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR, 45*TRAIN_PER_HOUR, 54*TRAIN_PER_HOUR},
    [1572] = {20*TRAIN_PER_HOUR, 28*TRAIN_PER_HOUR, 40*TRAIN_PER_HOUR, 56*TRAIN_PER_HOUR, 76*TRAIN_PER_HOUR},
    [1573] = {20*TRAIN_PER_HOUR, 28*TRAIN_PER_HOUR, 40*TRAIN_PER_HOUR, 56*TRAIN_PER_HOUR, 76*TRAIN_PER_HOUR},
    [86] = {18*TRAIN_PER_HOUR, 27*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR, 45*TRAIN_PER_HOUR, 54*TRAIN_PER_HOUR},
    [87] = {12*TRAIN_PER_HOUR, 18*TRAIN_PER_HOUR, 20*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR},
    [88] = {12*TRAIN_PER_HOUR, 18*TRAIN_PER_HOUR, 20*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR},
    [89] = {12*TRAIN_PER_HOUR, 18*TRAIN_PER_HOUR, 20*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR},
    [90] = {18*TRAIN_PER_HOUR, 27*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR, 45*TRAIN_PER_HOUR, 54*TRAIN_PER_HOUR},
    [1571] = {24*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR, 48*TRAIN_PER_HOUR, 60*TRAIN_PER_HOUR, 72*TRAIN_PER_HOUR},
    [ 9]  = {15*TRAIN_PER_HOUR, 20*TRAIN_PER_HOUR, 25*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR, 42.5*TRAIN_PER_HOUR, 52.5*TRAIN_PER_HOUR, 65*TRAIN_PER_HOUR, 250*TRAIN_PER_HOUR, 500*TRAIN_PER_HOUR, 1000*TRAIN_PER_HOUR},
    [1206] = {15*TRAIN_PER_HOUR, 20*TRAIN_PER_HOUR, 25*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR, 42.5*TRAIN_PER_HOUR, 52.5*TRAIN_PER_HOUR, 65*TRAIN_PER_HOUR, 250*TRAIN_PER_HOUR, 500*TRAIN_PER_HOUR, 1000*TRAIN_PER_HOUR},
    [40] = {15*TRAIN_PER_HOUR, 20*TRAIN_PER_HOUR, 25*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR, 42.5*TRAIN_PER_HOUR, 52.5*TRAIN_PER_HOUR, 65*TRAIN_PER_HOUR, 250*TRAIN_PER_HOUR, 500*TRAIN_PER_HOUR, 1000*TRAIN_PER_HOUR},
    --辅助系
    [91] =  {12*TRAIN_PER_HOUR, 18*TRAIN_PER_HOUR, 20*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR},
    [92] =  {12*TRAIN_PER_HOUR, 18*TRAIN_PER_HOUR, 20*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR},
    [93] =  {18*TRAIN_PER_HOUR, 27*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR, 45*TRAIN_PER_HOUR, 54*TRAIN_PER_HOUR},
    [1949] =  {18*TRAIN_PER_HOUR, 27*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR, 45*TRAIN_PER_HOUR, 54*TRAIN_PER_HOUR},
    [1950] =  {18*TRAIN_PER_HOUR, 27*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR, 45*TRAIN_PER_HOUR, 54*TRAIN_PER_HOUR},
    [1951] =  {18*TRAIN_PER_HOUR, 27*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR, 45*TRAIN_PER_HOUR, 54*TRAIN_PER_HOUR},
    [1952] =  {18*TRAIN_PER_HOUR, 27*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR, 45*TRAIN_PER_HOUR, 54*TRAIN_PER_HOUR},
    [95] =  {20*TRAIN_PER_HOUR, 28*TRAIN_PER_HOUR, 40*TRAIN_PER_HOUR, 56*TRAIN_PER_HOUR, 76*TRAIN_PER_HOUR},
    [96] =  {40*TRAIN_PER_HOUR, 50*TRAIN_PER_HOUR, 60*TRAIN_PER_HOUR},
    [97] =  {40*TRAIN_PER_HOUR, 50*TRAIN_PER_HOUR, 60*TRAIN_PER_HOUR},
    [98] =  {18*TRAIN_PER_HOUR, 27*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR, 45*TRAIN_PER_HOUR, 54*TRAIN_PER_HOUR},
    [99] =  {20*TRAIN_PER_HOUR, 28*TRAIN_PER_HOUR, 40*TRAIN_PER_HOUR, 56*TRAIN_PER_HOUR, 76*TRAIN_PER_HOUR},
    [110] = {20*TRAIN_PER_HOUR, 28*TRAIN_PER_HOUR, 40*TRAIN_PER_HOUR, 56*TRAIN_PER_HOUR, 76*TRAIN_PER_HOUR},
    [111] = {18*TRAIN_PER_HOUR, 27*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR, 45*TRAIN_PER_HOUR, 54*TRAIN_PER_HOUR},
    [112] = {20*TRAIN_PER_HOUR, 28*TRAIN_PER_HOUR, 40*TRAIN_PER_HOUR, 56*TRAIN_PER_HOUR, 76*TRAIN_PER_HOUR},
    [113] = {20*TRAIN_PER_HOUR, 28*TRAIN_PER_HOUR, 40*TRAIN_PER_HOUR, 56*TRAIN_PER_HOUR, 76*TRAIN_PER_HOUR},
    [114] = {125*TRAIN_PER_HOUR},
    [115] = {125*TRAIN_PER_HOUR},
    [116] = {125*TRAIN_PER_HOUR},
    [117] = {125*TRAIN_PER_HOUR},
    [41] = {15*TRAIN_PER_HOUR, 20*TRAIN_PER_HOUR, 25*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR, 42.5*TRAIN_PER_HOUR, 52.5*TRAIN_PER_HOUR, 65*TRAIN_PER_HOUR, 250*TRAIN_PER_HOUR, 500*TRAIN_PER_HOUR, 1000*TRAIN_PER_HOUR},
    [42] = {15*TRAIN_PER_HOUR, 20*TRAIN_PER_HOUR, 25*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR, 42.5*TRAIN_PER_HOUR, 52.5*TRAIN_PER_HOUR, 65*TRAIN_PER_HOUR, 250*TRAIN_PER_HOUR, 500*TRAIN_PER_HOUR, 1000*TRAIN_PER_HOUR},
    [43] = {15*TRAIN_PER_HOUR, 20*TRAIN_PER_HOUR, 25*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR, 42.5*TRAIN_PER_HOUR, 52.5*TRAIN_PER_HOUR, 65*TRAIN_PER_HOUR, 250*TRAIN_PER_HOUR, 500*TRAIN_PER_HOUR, 1000*TRAIN_PER_HOUR},
		
    --外功系
    [118] = {12*TRAIN_PER_HOUR, 18*TRAIN_PER_HOUR, 20*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR},
    [119] = {20*TRAIN_PER_HOUR, 28*TRAIN_PER_HOUR, 40*TRAIN_PER_HOUR, 56*TRAIN_PER_HOUR, 76*TRAIN_PER_HOUR},
    [120] = {22*TRAIN_PER_HOUR, 33*TRAIN_PER_HOUR, 44*TRAIN_PER_HOUR, 55*TRAIN_PER_HOUR, 66*TRAIN_PER_HOUR},
    [121] = {20*TRAIN_PER_HOUR, 25*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR},
    [122] = {20*TRAIN_PER_HOUR, 25*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR},
    [123] = {20*TRAIN_PER_HOUR, 25*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR},
    [124] = {20*TRAIN_PER_HOUR, 25*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR},
    [126] = {18*TRAIN_PER_HOUR, 27*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR, 45*TRAIN_PER_HOUR, 54*TRAIN_PER_HOUR},
    [127] = {18*TRAIN_PER_HOUR, 27*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR, 45*TRAIN_PER_HOUR, 54*TRAIN_PER_HOUR},
    [128] = {20*TRAIN_PER_HOUR, 28*TRAIN_PER_HOUR, 40*TRAIN_PER_HOUR, 56*TRAIN_PER_HOUR, 76*TRAIN_PER_HOUR},
    [129] = {20*TRAIN_PER_HOUR, 28*TRAIN_PER_HOUR, 40*TRAIN_PER_HOUR, 56*TRAIN_PER_HOUR, 76*TRAIN_PER_HOUR},
    [153] = {125*TRAIN_PER_HOUR},
    [154] = {125*TRAIN_PER_HOUR},
    [155] = {125*TRAIN_PER_HOUR},
    [44] = {15*TRAIN_PER_HOUR, 20*TRAIN_PER_HOUR, 25*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR, 42.5*TRAIN_PER_HOUR, 52.5*TRAIN_PER_HOUR, 65*TRAIN_PER_HOUR, 250*TRAIN_PER_HOUR, 500*TRAIN_PER_HOUR, 1000*TRAIN_PER_HOUR},
    [45] = {15*TRAIN_PER_HOUR, 20*TRAIN_PER_HOUR, 25*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR, 42.5*TRAIN_PER_HOUR, 52.5*TRAIN_PER_HOUR, 65*TRAIN_PER_HOUR, 250*TRAIN_PER_HOUR, 500*TRAIN_PER_HOUR, 1000*TRAIN_PER_HOUR},
		

    --内功系
    [156] = {12*TRAIN_PER_HOUR, 18*TRAIN_PER_HOUR, 20*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR},
    [157] = {20*TRAIN_PER_HOUR, 28*TRAIN_PER_HOUR, 40*TRAIN_PER_HOUR, 56*TRAIN_PER_HOUR, 76*TRAIN_PER_HOUR},
    [158] = {22*TRAIN_PER_HOUR, 33*TRAIN_PER_HOUR, 44*TRAIN_PER_HOUR, 55*TRAIN_PER_HOUR, 66*TRAIN_PER_HOUR},
    [159] = {20*TRAIN_PER_HOUR, 25*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR},
    [160] = {20*TRAIN_PER_HOUR, 25*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR},
    [161] = {20*TRAIN_PER_HOUR, 25*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR},
    [162] = {20*TRAIN_PER_HOUR, 25*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR},
    [163] = {18*TRAIN_PER_HOUR, 27*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR, 45*TRAIN_PER_HOUR, 54*TRAIN_PER_HOUR},
    [164] = {18*TRAIN_PER_HOUR, 27*TRAIN_PER_HOUR, 36*TRAIN_PER_HOUR, 45*TRAIN_PER_HOUR, 54*TRAIN_PER_HOUR},
    [165] = {20*TRAIN_PER_HOUR, 28*TRAIN_PER_HOUR, 40*TRAIN_PER_HOUR, 56*TRAIN_PER_HOUR, 76*TRAIN_PER_HOUR},
    [166] = {20*TRAIN_PER_HOUR, 28*TRAIN_PER_HOUR, 40*TRAIN_PER_HOUR, 56*TRAIN_PER_HOUR, 76*TRAIN_PER_HOUR},
    [167] = {125*TRAIN_PER_HOUR},
    [168] = {125*TRAIN_PER_HOUR},
    [169] = {125*TRAIN_PER_HOUR},
    [46] = {15*TRAIN_PER_HOUR, 20*TRAIN_PER_HOUR, 25*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR, 42.5*TRAIN_PER_HOUR, 52.5*TRAIN_PER_HOUR, 65*TRAIN_PER_HOUR, 250*TRAIN_PER_HOUR, 500*TRAIN_PER_HOUR, 1000*TRAIN_PER_HOUR},
    [170] = {15*TRAIN_PER_HOUR, 20*TRAIN_PER_HOUR, 25*TRAIN_PER_HOUR, 30*TRAIN_PER_HOUR, 42.5*TRAIN_PER_HOUR, 52.5*TRAIN_PER_HOUR, 65*TRAIN_PER_HOUR, 250*TRAIN_PER_HOUR, 500*TRAIN_PER_HOUR, 1000*TRAIN_PER_HOUR},

};

-- 经脉打通的需求
VenationRequireLevel =
{
    --基础系
    [60] = 10,-- 20级才能打通经脉
    [1960] = 70,
    [1958] = 25,
    [64] = 15,
    [65] = 15,
    [66] = 15,
    [1959] = 50,
    [68] = 20,
    [1961] = 70,
    [70] = 10,
    [1962] = 70,
    [1963] = 70,
    [1964] = 70,
    [1965] = 70,
    [75] = 30,
    [1966] = 70,
    [77] = 10,
    [78] = 15,
    [79] = 15,
    [80] = 15,
    [86] = 15,
    [82] = 15,
    [83] = 15,
    [84] = 20,
    [85] = 15,
    [1572] = 20,
    [1573] = 50,
    [1196] = 20,
    [87] = 25,
    [88] = 25,
    [89] = 25,
    [90] = 30,
    [1571] = 35,
    [ 9] = 70,
    [1206] = 70,
    [40] = 70,

    --辅助系
    [91] = 15,
    [92] = 10,
    [93] = 15,
    [1949] = 20,
    [1950] = 20,
    [1951] = 20,
    [1952] = 20,
    [95] = 15,
    [96] = 30,
    [97] = 25,
    [98] = 20,
    [99] = 20,
    [110] = 25,
    [111] = 15,
    [112] = 25,
    [113] = 30,
    [114] = 50,
    [115] = 50,
    [116] = 50,
    [117] = 50,
    [ 41] = 70,
    [42] = 70,
    [43] = 70,
    --外功系
    [118] = 15,
    [119] = 30,
    [120] = 25,
    [121] = 25,
    [122] = 25,
    [123] = 25,
    [124] = 25,
    [126] = 20,
    [127] = 20,
    [128] = 30,
    [129] = 35,
    [153] = 50,
    [154] = 50,
    [155] = 50,
    [44] = 70,
    [45] = 70,
    --内功系
    [156] = 15,
    [157] = 30,
    [158] = 25,
    [159] = 25,
    [160] = 25,
    [161] = 25,
    [162] = 25,
    [163] = 20,
    [164] = 20,
    [165] = 30,
    [166] = 35,
    [167] = 50,
    [168] = 50,
    [169] = 50,
    [46] = 70,
    [170] = 70,

};

VenationRequirement =
{
    --基础系经脉
    [1960] = {
                {ID = 1573, Level = 1},-- 此处为ID为62的经脉打通它需要ID为60的经脉的2级
           },
    [1958] = {
                {ID = 68, Level = 1},
           },
    [64] = {
                {ID = 70, Level = 1},
           },
    [65] = {
                {ID = 70, Level = 1},
           },
    [66] = {
                {ID = 70, Level = 1},
           },
    [1959] = {
                {ID = 75, Level = 1},
           },
    [68] = {
                {ID = 1572, Level = 1},
           },
    [1961] = {
                {ID = 1573, Level = 1},
           },
    [70] = {
                {ID = 60, Level = 1},
           },
    [1962] = {
                {ID = 1961, Level = 1},
           },
    [1963] = {
                {ID = 1962, Level = 1},
                {ID = 1964, Level = 1},
                {ID = 1966, Level = 1},
           },
    [1964] = {
                {ID = 1960, Level = 1},
           },
    [1965] = {
                {ID = 1573, Level = 1},
           },
    [75] = {
                {ID = 1958, Level = 1},
           },
    [1966] = {
                {ID = 1965, Level = 1},
           },
    [77] = {
                {ID = 60, Level = 1},
           },
    [78] = {
                {ID = 77, Level = 1},
           },
    [79] = {
                {ID = 85, Level = 1},
           },
    [80] = {
                {ID = 85, Level = 1},
           },
    [86] = {
                {ID = 78, Level = 1},
           },
    [82] = {
                {ID = 79, Level = 1},
           },
    [83] = {
                {ID = 80, Level = 1},
           },
    [84] = {
                {ID = 86, Level = 1},
           },
    [85] = {
                {ID = 77, Level = 1},
           },
    [1572] = {
                {ID = 64, Level = 1},
                {ID = 65, Level = 1},
                {ID = 66, Level = 1},
           },
    [1573] = {
                {ID = 1572, Level = 1},
           },
    [1196] = {
                {ID = 82, Level = 1},
                {ID = 83, Level = 1},
                {ID = 84, Level = 1},
           },
    [87] = {
                {ID = 1196, Level = 1},
           },
    [88] = {
                {ID = 1196, Level = 1},
           },
    [89] = {
                {ID = 1196, Level = 1},
           },
    [90] = {
                {ID = 87, Level = 1},
                {ID = 88, Level = 1},
                {ID = 89, Level = 1},
           },
    [1571] = {
                {ID = 90, Level = 1},
           },
    --辅助系
    [91] = {
                {ID = 92, Level = 1},
           },
    [93] = {
                {ID = 92, Level = 1},
           },
    [1949] = {
                {ID = 93, Level = 1},
           },
    [1950] = {
                {ID = 93, Level = 1},
           },
    [1951] = {
                {ID = 93, Level = 1},
           },
    [1952] = {
                {ID = 93, Level = 1},
           },
    [95] = {
                {ID = 111, Level = 1},
           },
    [96] = {
                {ID = 97, Level = 1},
           },
    [97] = {
                {ID = 98, Level = 1},
           },
    [98] = {
                {ID = 91, Level = 1},
           },
    [99] = {
                {ID = 95, Level = 1},
           },
    [110] = {
                {ID = 1949, Level = 1},
                {ID = 1950, Level = 1},
                {ID = 1951, Level = 1},
                {ID = 1952, Level = 1},
           },
    [111] = {
                {ID = 92, Level = 1},
           },
    [112] = {
                {ID = 99, Level = 1},
           },
    [113] = {
                {ID = 110, Level = 1},
           },
    [114] = {
                {ID = 96, Level = 1},
           },
    [115] = {
                {ID = 112, Level = 1},
           },
    [116] = {
                {ID = 113, Level = 1},
           },
    [117] = {
                {ID = 114, Level = 1},
           },

    --外功系
    [127] = {
                {ID = 118, Level = 1},
           },
    [126] = {
                {ID = 118, Level = 1},
           },
    [121] = {
                {ID = 127, Level = 1},
           },
    [122] = {
                {ID = 127, Level = 1},
           },
    [123] = {
                {ID = 127, Level = 1},
           },
    [124] = {
                {ID = 127, Level = 1},
           },
    [120] = {
                {ID = 126, Level = 1},
           },
    [119] = {
                {ID = 121, Level = 1},
                {ID = 122, Level = 1},
                {ID = 123, Level = 1},
                {ID = 124, Level = 1},
           },
    [128] = {
                {ID = 120, Level = 1},
           },
    [129] = {
                {ID = 119, Level = 1},
           },
    [153] = {
                {ID = 128, Level = 1},
           },
    [154] = {
                {ID = 129, Level = 1},
           },
    [155] = {
                {ID = 153, Level = 1},
           },

    --内功系
    [164] = {
                {ID = 156, Level = 1},
           },
    [163] = {
                {ID = 156, Level = 1},
           },
    [159] = {
                {ID = 164, Level = 1},
           },
    [160] = {
                {ID = 164, Level = 1},
           },
    [161] = {
                {ID = 164, Level = 1},
           },
    [162] = {
                {ID = 164, Level = 1},
           },
    [158] = {
                {ID = 163, Level = 1},
           },
    [157] = {
                {ID = 159, Level = 1},
                {ID = 160, Level = 1},
                {ID = 161, Level = 1},
                {ID = 162, Level = 1},
           },
    [165] = {
                {ID = 158, Level = 1},
           },
    [166] = {
                {ID = 157, Level = 1},
           },
    [167] = {
                {ID = 165, Level = 1},
           },
    [168] = {
                {ID = 166, Level = 1},
           },
    [169] = {
                {ID = 167, Level = 1},
           },

};

VenationDifficult =
{
    --基础系各经脉成功率
    [60] = {1024, 1024, 1024, 1024, 1024}, --33号经脉第一级的成功率为50%，第二级的成功率为100%
    [1960] = {1024},
    [1958] = {1024, 1024, 1024},
    [64] = {1024, 1024, 1024, 1024, 1024},
    [65] = {1024, 1024, 1024, 1024, 1024},
    [66] = {1024, 1024, 1024, 1024, 1024},
    [1959] = {1024},
    [68] = {1024, 1024, 1024, 1024, 1024},
    [1961] = {1024},
    [70] = {1024, 1024, 1024, 1024, 1024},
    [1962] = {1024},
    [1963] = {1024},
    [1964] = {1024},
    [1965] = {1024},
    [75] = {1024, 1024, 1024},
    [1966] = {1024},
    [77] = {1024, 1024, 1024, 1024, 1024},
    [78] = {1024, 1024, 1024, 1024, 1024},
    [79] = {1024, 1024, 1024, 1024, 1024},
    [80] = {1024, 1024, 1024, 1024, 1024},
    [86] = {1024, 1024, 1024, 1024, 1024},
    [82] = {1024, 1024, 1024, 1024, 1024},
    [83] = {1024, 1024, 1024, 1024, 1024},
    [84] = {1024, 1024},
    [85] = {1024, 1024, 1024, 1024, 1024},
    [1572] = {1024, 1024, 1024, 1024, 1024},
    [1573] = {1024, 1024, 1024, 1024, 1024},
    [1196] = {1024},
    [87] = {1024, 1024, 1024, 1024, 1024},
    [88] = {1024, 1024, 1024, 1024, 1024},
    [89] = {1024, 1024, 1024, 1024, 1024},
    [90] = {1024, 1024, 1024, 1024, 1024},
    [1571] = {1024, 1024, 1024, 1024, 1024},
    [ 9] = {1024,1024,1024,1024,1024,1024,1024,1024,1024,1024},
    [1206] = {1024,1024,1024,1024,1024,1024,1024,1024,1024,1024},
    [40] = {1024,1024,1024,1024,1024,1024,1024,1024,1024,1024},

    --辅助系各经脉各级成功率
    [91] = {1024, 1024, 1024, 1024, 1024},
    [92] = {1024, 1024, 1024, 1024, 1024},
    [93] = {1024, 1024, 1024, 1024, 1024},
    [1949] = {1024, 1024, 1024, 1024, 1024},
    [1950] = {1024, 1024, 1024, 1024, 1024},
    [1951] = {1024, 1024, 1024, 1024, 1024},
    [1952] = {1024, 1024, 1024, 1024, 1024},
    [95] = {1024, 1024, 1024, 1024, 1024},
    [96] = {1024, 1024, 1024},
    [97] = {1024, 1024, 1024},
    [98] = {1024, 1024, 1024, 1024, 1024},
    [99] = {1024, 1024, 1024, 1024, 1024},
    [110] = {1024, 1024, 1024, 1024, 1024},
    [111] = {1024, 1024, 1024, 1024, 1024},
    [112] = {1024, 1024, 1024, 1024, 1024},
    [113] = {1024, 1024, 1024, 1024, 1024},
    [114] = {1024},
    [115] = {1024},
    [116] = {1024},
    [117] = {1024},
    [41] = {1024,1024,1024,1024,1024,1024,1024,1024,1024,1024},
    [42] = {1024,1024,1024,1024,1024,1024,1024,1024,1024,1024},
    [43] = {1024,1024,1024,1024,1024,1024,1024,1024,1024,1024},

    --外功系各经脉各级成功率
    [118] = {1024, 1024, 1024, 1024, 1024},
    [127] = {1024, 1024, 1024, 1024, 1024},
    [126] = {1024, 1024, 1024, 1024, 1024},
    [121] = {1024, 1024, 1024},
    [122] = {1024, 1024, 1024},
    [123] = {1024, 1024, 1024},
    [124] = {1024, 1024, 1024},
    [120] = {1024, 1024, 1024, 1024, 1024},
    [119] = {1024, 1024, 1024, 1024, 1024},
    [128] = {1024, 1024, 1024, 1024, 1024},
    [129] = {1024, 1024, 1024, 1024, 1024},
    [154] = {1024},
    [153] = {1024},
    [155] = {1024},
    [44] = {1024,1024,1024,1024,1024,1024,1024,1024,1024,1024},
    [45] = {1024,1024,1024,1024,1024,1024,1024,1024,1024,1024},

    --内功系各经脉各级成功率
    [156] = {1024, 1024, 1024, 1024, 1024},
    [164] = {1024, 1024, 1024, 1024, 1024},
    [163] = {1024, 1024, 1024, 1024, 1024},
    [159] = {1024, 1024, 1024},
    [160] = {1024, 1024, 1024},
    [161] = {1024, 1024, 1024},
    [162] = {1024, 1024, 1024},
    [158] = {1024, 1024, 1024, 1024, 1024},
    [157] = {1024, 1024, 1024, 1024, 1024},
    [165] = {1024, 1024, 1024, 1024, 1024},
    [166] = {1024, 1024, 1024, 1024, 1024},
    [167] = {1024},
    [168] = {1024},
    [169] = {1024},
    [46] = {1024,1024,1024,1024,1024,1024,1024,1024,1024,1024},
    [170] = {1024,1024,1024,1024,1024,1024,1024,1024,1024,1024},

};

-- 经脉特殊效果
VenationEffect =
{
    [ 9]  = {Requirement = {1959}, RequirementLevel = {1}}, -- 这个特效需要3条经脉被打通，分别是1、2、3号被动技能，获得特效的被动技能ID为512
    [1206]  = {Requirement = {1963}, RequirementLevel = {1}},
    [40]  = {Requirement = {1571}, RequirementLevel = {1}},
    [41]  = {Requirement = {115}, RequirementLevel = {1}},
    [42]  = {Requirement = {116}, RequirementLevel = {1}},
    [43]  = {Requirement = {117}, RequirementLevel = {1}},
    [44]  = {Requirement = {154}, RequirementLevel = {1}},
    [45]  = {Requirement = {155}, RequirementLevel = {1}},
    [46]  = {Requirement = {168}, RequirementLevel = {1}},
    [170] = {Requirement = {169}, RequirementLevel = {1}},

};

VenationType =
{
    --基础系
    [60] = BASE_VENATION,
    [1960] = BASE_VENATION,
    [1958] = BASE_VENATION,
    [64] = BASE_VENATION,
    [65] = BASE_VENATION,
    [66] = BASE_VENATION,
    [1959] = BASE_VENATION,
    [68] = BASE_VENATION,
    [1961] = BASE_VENATION,
    [70] = BASE_VENATION,
    [1962] = BASE_VENATION,
    [1963] = BASE_VENATION,
    [1964] = BASE_VENATION,
    [1965] = BASE_VENATION,
    [75] = BASE_VENATION,
    [1966] = BASE_VENATION,
    [77] = BASE_VENATION,
    [78] = BASE_VENATION,
    [79] = BASE_VENATION,
    [80] = BASE_VENATION,
    [86] = BASE_VENATION,
    [82] = BASE_VENATION,
    [83] = BASE_VENATION,
    [84] = BASE_VENATION,
    [85] = BASE_VENATION,
    [1572] = BASE_VENATION,
    [1573] = BASE_VENATION,
    [1196] = BASE_VENATION,
    [87] = BASE_VENATION,
    [88] = BASE_VENATION,
    [89] = BASE_VENATION,
    [90] = BASE_VENATION,
    [1571] = BASE_VENATION,
    [ 9] = BASE_VENATION,
    [1206] = BASE_VENATION,
    [40] = BASE_VENATION,
    --辅助系
    [91] = ASSIST_VENATION,
    [92] = ASSIST_VENATION,
    [93] = ASSIST_VENATION,
    [1949] = ASSIST_VENATION,
    [1950] = ASSIST_VENATION,
    [1951] = ASSIST_VENATION,
    [1952] = ASSIST_VENATION,
    [95] = ASSIST_VENATION,
    [96] = ASSIST_VENATION,
    [97] = ASSIST_VENATION,
    [98] = ASSIST_VENATION,
    [99] = ASSIST_VENATION,
    [110] = ASSIST_VENATION,
    [111] = ASSIST_VENATION,
    [112] = ASSIST_VENATION,
    [113] = ASSIST_VENATION,
    [114] = ASSIST_VENATION,
    [115] = ASSIST_VENATION,
    [116] = ASSIST_VENATION,
    [117] = ASSIST_VENATION,
    [41] = ASSIST_VENATION,
    [42] = ASSIST_VENATION,
    [43] = ASSIST_VENATION,
    --外功系
    [118] = PHYSICS_VENATION,
    [119] = PHYSICS_VENATION,
    [120] = PHYSICS_VENATION,
    [121] = PHYSICS_VENATION,
    [122] = PHYSICS_VENATION,
    [123] = PHYSICS_VENATION,
    [124] = PHYSICS_VENATION,
    [126] = PHYSICS_VENATION,
    [127] = PHYSICS_VENATION,
    [128] = PHYSICS_VENATION,
    [129] = PHYSICS_VENATION,
    [153] = PHYSICS_VENATION,
    [154] = PHYSICS_VENATION,
    [155] = PHYSICS_VENATION,
    [44] = PHYSICS_VENATION,
    [45] = PHYSICS_VENATION,
    --内功系
    [156] = MAGIC_VENATION,
    [157] = MAGIC_VENATION,
    [158] = MAGIC_VENATION,
    [159] = MAGIC_VENATION,
    [160] = MAGIC_VENATION,
    [161] = MAGIC_VENATION,
    [162] = MAGIC_VENATION,
    [163] = MAGIC_VENATION,
    [164] = MAGIC_VENATION,
    [165] = MAGIC_VENATION,
    [166] = MAGIC_VENATION,
    [167] = MAGIC_VENATION,
    [168] = MAGIC_VENATION,
    [169] = MAGIC_VENATION,
    [46] = MAGIC_VENATION,
    [170] = MAGIC_VENATION,
};

function CanOpenVenation(player, nVenationID)
    local i         = 1;
    local bCanOpen  = false;
    local ErrCode   = ERR_OPEN_VENATION_SUCCESS;
    local CurLevel  = player.GetSkillLevel(nVenationID);
    local nCost     = player.nMaxTrainValue + 1;
    local bEffect   = false;

    local nPlayerLevel = player.nLevel;
		local nPlayerGongli = GetGongliCount(player);
		
		if not VenationRequireGongli[nVenationID] then
				return false, ERR_OPEN_VENATION_ERROR;
    end
		
		if nPlayerGongli < VenationRequireGongli[nVenationID] then
	    return false, ERR_OPEN_VENATION_ERROR;
    end
		
    if not VenationRequireLevel[nVenationID] then
        return false, ERR_OPEN_VENATION_ERROR;
    end

	if nPlayerLevel < VenationRequireLevel[nVenationID] then
	    return false, ERR_OPEN_VENATION_LEVEL_LOWER;
    end

    for nEffectID, EffectInfo in pairs(VenationEffect) do
        if nEffectID == nVenationID then
            bEffect = true;
            local nLevel = player.GetSkillLevel(nEffectID);

            if nLevel == 10 then
                return false, ERR_OPEN_VENATION_ERROR;
            end
            
            if nLevel == 0 then
                for i, EffectRequirement in pairs(EffectInfo.Requirement) do
                    local nSkillLevel = player.GetSkillLevel(EffectRequirement);
    
                    if nSkillLevel < EffectInfo.RequirementLevel[i] then
                        return false, ERR_OPEN_VENATION_ERROR;
                    end
                end
            end
        end
    end

    if VenationCost[nVenationID] == nil then
        return false, ERR_OPEN_VENATION_ERROR;
    end

    if VenationCost[nVenationID][CurLevel + 1] then
        nCost = GetActualCostTrain(player, VenationCost[nVenationID][CurLevel + 1]);
    end

    if nCost > player.nCurrentTrainValue then
        return false, ERR_OPEN_VENATION_NOT_ENOUGH_TRAIN;
    end

    if bEffect == false and nCost + player.nUsedTrainValue > USE_TRAIN_LIMIT then
        return false, ERR_OPEN_VENATION_LIMIT_TRAIN;
    end

	if not VenationRequirement[nVenationID] then
		return true
	end

	ErrCode = ERR_OPEN_VENATION_NOT_OPEN;
    while VenationRequirement[nVenationID][i] do
        local nSkillLevel = player.GetSkillLevel(VenationRequirement[nVenationID][i].ID);
    	if nSkillLevel >= VenationRequirement[nVenationID][i].Level then -- 如果有一个前置的经脉符合条件，就可以打通
        	bCanOpen = true;
        	ErrCode  = ERR_OPEN_VENATION_SUCCESS;
        	break;
    	end
        i = i + 1;
    end

    return bCanOpen, ErrCode;
end;

function CalcVenationTrainvalue(player)
    return player.nUsedTrainValue, USE_TRAIN_LIMIT;
end;

function GetActualCostTrain(player, nCostTrain)
    local nReduceCostSkillLevelA = player.GetSkillLevel(73); --判断是否学到减少通穴损耗的被动技能
    local nReduceCostSkillLevelB = player.GetSkillLevel(9); --判断是否学到减少通穴损耗的被动技能(环通)
    local nReduceCostSkillLevel	=	nReduceCostSkillLevelA+nReduceCostSkillLevelB;
----20100729修改经脉 移除减少消耗的效果
    --nCostTrain = nCostTrain*(1-0.01*nReduceCostSkillLevel);
    nCostTrain = nCostTrain*(1-0*nReduceCostSkillLevel);
    return math.floor(nCostTrain);
end

function GetRestoreTrain(player, nCostTrain)
    local nLossTrainSkillLevel = player.GetSkillLevel(63);
    local nLossTrain = 0;
    if nLossTrainSkillLevel == 0 then
        nLossTrain = nCostTrain * 0;
    elseif nLossTrainSkillLevel == 1 then
	    nLossTrain = nCostTrain * 0;
    elseif nLossTrainSkillLevel == 2 then
	    nLossTrain = nCostTrain * 0;
    elseif nLossTrainSkillLevel == 3 then
	    nLossTrain = nCostTrain * 0;
    elseif nLossTrainSkillLevel == 4 then
	    nLossTrain = nCostTrain * 0;
    elseif nLossTrainSkillLevel == 5 then
	    nLossTrain = nCostTrain * 0;
    end

    return math.floor(nCostTrain - nLossTrain)
end

function CalcResetCost(player)
    return math.floor(player.nUsedTrainValue / 500 * 10000);
end

function CalcEffectResetCost(player)
		local nCostCount = 0
		for k, v in pairs(tVenationEffectID) do
			nCostCount = nCostCount + (tZhuanhuan[player.GetSkillLevel(v)] or 0)
		end
    return math.floor(nCostCount / 2000 * 10000);
end

function GetResetDiscount(player, nDiscountTrain)
    local nReduceDiscountSkillLevel = player.GetSkillLevel(71); --判断是否学到减少洗点损耗的被动技能
----20100729移除洗经伐脉折损修为的设计
--    if nReduceDiscountSkillLevel == 0 then
--        nDiscountTrain = nDiscountTrain * 0.9;
--    elseif nReduceDiscountSkillLevel == 1 then
--        nDiscountTrain = nDiscountTrain * 0.92;
--    elseif nReduceDiscountSkillLevel == 2 then
--	    nDiscountTrain = nDiscountTrain * 0.94;
--    elseif nReduceDiscountSkillLevel == 3 then
--        nDiscountTrain = nDiscountTrain * 0.96;
--    elseif nReduceDiscountSkillLevel == 4 then
--	    nDiscountTrain = nDiscountTrain * 0.98;
--    elseif nReduceDiscountSkillLevel == 5 then
--        nDiscountTrain = nDiscountTrain * 1;
--    end
    if nReduceDiscountSkillLevel == 0 then
        nDiscountTrain = nDiscountTrain * 1;
    elseif nReduceDiscountSkillLevel == 1 then
        nDiscountTrain = nDiscountTrain * 1;
    elseif nReduceDiscountSkillLevel == 2 then
	    nDiscountTrain = nDiscountTrain * 1;
    elseif nReduceDiscountSkillLevel == 3 then
        nDiscountTrain = nDiscountTrain * 1;
    elseif nReduceDiscountSkillLevel == 4 then
	    nDiscountTrain = nDiscountTrain * 1;
    elseif nReduceDiscountSkillLevel == 5 then
        nDiscountTrain = nDiscountTrain * 1;
    end

    return math.floor(nDiscountTrain);
end

function GetGongliCount(player)
	local tSkillPoint = {9, 1206,40,41,42,43,44,45,46,170}--奇穴对应技能
	--local tZhuanhuan = {300, 700, 1200, 1800, 2650, 3700, 5000, 10000, 20000, 40000} --奇穴等级对应修为
	local nDantian =  player.nUsedTrainValue --玩家丹田修为值
	local nQihai = player.nCurrentTrainValue --玩家气海修为值
	local nGongliCount = 0
	for k, v in pairs(tSkillPoint) do
		nGongliCount = nGongliCount + (tZhuanhuan[player.GetSkillLevel(v)] or 0)
	end
	nGongliCount = nGongliCount + nDantian + nQihai
	return nGongliCount
end

