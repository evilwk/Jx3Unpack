local BATTLE_FIELD_GROUP_COUNT = 4
local BATTLE_FIELD_PQOPTIONICON_COUNT = 4
local PQOBJECTIVE_COUNT = 8
local SUGGEST_QUEST_AREA_COUNT = 22
local SUGGEST_COPY_COUNT = 20
local SUGGEST_BATTLE_FIELD_COUNT = 10
local CAREER_MAP_LIMIT_COUNT = 5
local CAREER_TAP_COUNT = 8
local CAREER_IMAGE_COUNT = 3 
local PET_SKILL_COUNT = 15
local PUPPET_SKILL_COUNT = 8

local tAllSceneQuest = {}
local tAllSceneFieldPQ = {}
local tAllSkillRecipeMap = {}

local tTableFile = 
{
	
	LoginScript = 
	{
		Path = "\\UI\\loginscript.txt",
		Title = 
		{
			{f = "s", t = "script"},			
			{f = "i", t = "kingsoft"},
			{f = "i", t = "exp"},
			{f = "i", t = "snda"},
		}
	},
    
	DefaultScript = 
	{
		Path = "\\UI\\defaultscript.txt",
		Title = 
		{
			{f = "s", t = "script"},			
			{f = "i", t = "kingsoft"},
			{f = "i", t = "exp"},
			{f = "i", t = "snda"},
		}
	},
    
	GlobalStrings = 
	{
		Path = "\\UI\\Scheme\\Case\\string.txt",
		Title = 
		{
			{f = "s", t = "szID"},			
			{f = "i", t = "nLength"},
			{f = "S", t = "szText"},
		}
	},
			
	Quest = 
	{
		Path = "\\UI\\Scheme\\Case\\quest.txt",
		Title = 
		{
			{f = "i", t = "dwQuestID"},
			{f = "s", t = "szAccept"},
			{f = "s", t = "szFinish"},
			{f = "s", t = "szQuestState1"},
			{f = "s", t = "szQuestState2"},
			{f = "s", t = "szQuestState3"},
			{f = "s", t = "szQuestState4"},
			{f = "s", t = "szQuestState5"},
			{f = "s", t = "szQuestState6"},
			{f = "s", t = "szQuestState7"},
			{f = "s", t = "szQuestState8"},
			{f = "s", t = "szKillNpc1"},
			{f = "s", t = "szKillNpc2"},
			{f = "s", t = "szKillNpc3"},
			{f = "s", t = "szKillNpc4"},
			{f = "s", t = "szNeedItem1"},
			{f = "s", t = "szNeedItem2"},
			{f = "s", t = "szNeedItem3"},
			{f = "s", t = "szNeedItem4"},
		},
	},
	
	QuestNpc = 
	{
		Path = "\\UI\\Scheme\\Case\\questnpc.txt",
		Title = 
		{
			{f = "i", t = "dwTemplateID"},
			{f = "i", t = "dwMapID"},
			{f = "s", t = "szPositions"},
		},
	},
	
	QuestDoodad = 
	{
		Path = "\\UI\\Scheme\\Case\\questDoodad.txt",
		Title = 
		{
			{f = "i", t = "dwTemplateID"},
			{f = "i", t = "dwMapID"},
			{f = "s", t = "szPositions"},
		},
	},
	
	--任务全指引中可接任务显示需要屏蔽的任务
	ShieldQuest = 
	{
		Path = "\\UI\\Scheme\\Case\\shieldquest.txt",
		Title = 
		{
			{f = "i", t = "dwQuestID"},
		},
	},
	
	Npc = 
	{
		Path = "\\UI\\Scheme\\Case\\npc.txt",
		Title = 
		{
			{f = "i", t = "dwTemplateID"},
			{f = "i", t = "dwTypeID"},
		},
	},
	
	NpcType = 
	{
		Path = "\\UI\\Scheme\\Case\\npctype.txt",
		Title = 
		{
			{f = "i", t = "dwTypeID"},
			{f = "s", t = "szDesc"},
			{f = "i", t = "nMinimapImageFrame"},
			{f = "i", t = "dwEffectID"},
			{f = "i", t = "dwCursorID"},
		},
	},
	
	SkillRecipe = 
	{
		Path = "\\UI\\Scheme\\Case\\SkillRecipeTable.txt",
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "i", t = "dwLevel"},
			{f = "i", t = "dwTypeID"},
            {f = "i", t = "dwSkillID"},
			{f = "i", t = "nIconID"},
			{f = "s", t = "szName"},
			{f = "S", t = "szDesc"},
		},
	},
	
	SkillRecipeType = 
	{
		Path = "\\UI\\Scheme\\Case\\SkillRecipeType.txt",
		Title = 
		{
			{f = "i", t = "dwTypeID"},
			{f = "s", t = "szDesc"},
			{f = "i", t = "nAddToTip"},
		},
	},
	
	Item = 
	{
		Path = "\\UI\\Scheme\\Case\\item.txt",
		Title = 
		{
			{f = "i", t = "dwItemID"},
			{f = "i", t = "dwIconID"},
			{f = "i", t = "dwSoundID"},
			{f = "s", t = "szName"},
			{f = "S", t = "szDesc"},
			{f = "s", t = "szRequirement"},
		}
	},
		
	Achievement = 
	{	Path = "\\ui\\Scheme\\Case\\achievement.txt",
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "i", t = "dwGeneral"},
			{f = "i", t = "dwSub"},
			{f = "i", t = "dwDetail"},
			{f = "i", t = "nVisible"},
			{f = "i", t = "nIconID"},
			{f = "s", t = "szSubAchievements"},
			{f = "s", t = "szCounters"},
			{f = "s", t = "szName"},
			{f = "S", t = "szShortDesc"},
			{f = "S", t = "szDesc"},
			{f = "S", t = "szMsg"},
			{f = "i", t = "dwItemType"},
			{f = "i", t = "dwItemID"},
		}
	},
	
	AchievementGeneral = 
	{	Path = "\\ui\\Scheme\\Case\\achivementgeneral.txt",
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "s", t = "szName"},
			{f = "s", t = "szSubs"},
		}
	},

	AchievementSub = 
	{	Path = "\\ui\\Scheme\\Case\\achivementsub.txt",
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "s", t = "szName"},
			{f = "s", t = "szDetails"},
			{f = "s", t = "szAchievements"},
		}
	},

	AchievementDetail = 
	{	Path = "\\ui\\Scheme\\Case\\achivementsdetail.txt",
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "s", t = "szName"},
			{f = "s", t = "szAchievements"},
		}
	},
	
	AchievementCounter = 
	{
		Path = "\\UI\\Scheme\\Case\\AchievementCounter.txt",
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "S", t = "szDesc"},
		}
	},
	
	AchievementInfo = 
	{
		Path = "\\settings\\AchievementInfo.tab",
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "i", t = "nTriggerVal"},
			{f = "i", t = "nShiftID"},
			{f = "i", t = "nShiftType"},
			{f = "i", t = "nPoint"},
			{f = "i", t = "nExp"},
			{f = "s", t = "szNote"},
			{f = "i", t = "nPrefix"},
			{f = "i", t = "nPostfix"},
		}		
	},
	
	Skill = 
	{
		Path = "\\UI\\Scheme\\Case\\skill.txt",
		Title = 
		{
			{f = "i", t = "dwSkillID"},
			{f = "i", t = "dwLevel"},
			{f = "i", t = "dwIconID"},
			{f = "i", t = "bShow"},
			{f = "i", t = "bCombatShow"},
			{f = "i", t = "bFormation"},
			{f = "i", t = "bFormationCaster"},
			{f = "i", t = "dwPracticeID"},
			{f = "f", t = "fSortOrder"},
			{f = "s", t = "szName"},
			{f = "S", t = "szDesc"},
			{f = "S", t = "szShortDesc"},
			{f = "S", t = "szSpecialDesc"},
		}
	},
	
	SkillSchool = 
	{
		Path = "\\UI\\Scheme\\Case\\school.txt",
		Title = 
		{
			{f = "i", t = "dwSchoolID"},
			{f = "i", t = "dwIconID"},
			{f = "s", t = "szName"},
		}
	},
	
	LearnSkill = 
	{
		Path = "\\UI\\Scheme\\Case\\learnskill.txt",
		Title = 
		{
			{f = "i", t = "dwLevel"},
			{f = "i", t = "dwSchool"},
			{f = "s", t = "szSkill"},
		}
	},
	
	SchoolSkill = 
	{
		Path = "\\UI\\Scheme\\Case\\skill_school.txt",
		Title = 
		{
			{f = "i", t = "dwSchool"},
			{f = "s", t = "szSkill"},
		}	
	},
	
	KungfuSkill = 
	{
		Path = "\\UI\\Scheme\\Case\\skill_kungfu.txt",
		Title = 
		{
			{f = "i", t = "dwKungfu"},
			{f = "s", t = "szSkill"},
		}		
	},
	
	OpenSkillLevel = 
	{
		Path = "\\UI\\Scheme\\Case\\skill_open_level.txt",
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "i", t = "dwLevel"},
		}		
	},
	
	Buff = 
	{
		Path = "\\UI\\Scheme\\Case\\buff.txt",
		Title = 
		{
			{f = "i", t = "dwBuffID"},
			{f = "i", t = "dwLevel"},
			{f = "i", t = "dwIconID"},
			{f = "i", t = "bSparking"},
			{f = "i", t = "bShowTime"},
			{f = "i", t = "bShow"},
			{f = "s", t = "szName"},
			{f = "S", t = "szDesc"},
		}
	},
	
	BattleField = 
	{
		Path = "\\UI\\Scheme\\Case\\battlefield.txt",
		Title = 
		{
			{f = "i", t = "dwMapID"},
			{f = "s", t = "szName"},
			{f = "s", t = "szDesc"},
			{f = "s", t = "szGroup1"},
			{f = "s", t = "szGroup2"},
			{f = "s", t = "szGroup3"},
			{f = "s", t = "szGroup4"},
			{f = "s", t = "szPQOptionName1"},
			{f = "i", t = "nPQOptionIcon1"},
			{f = "s", t = "szPQOptionName2"},
			{f = "i", t = "nPQOptionIcon2"},
			{f = "s", t = "szPQOptionName3"},
			{f = "i", t = "nPQOptionIcon3"},
			{f = "s", t = "szPQOptionName4"},
			{f = "i", t = "nPQOptionIcon4"},
			{f = "i", t = "nRewardIcon1"},
			{f = "i", t = "nRewardIcon2"},
			{f = "i", t = "nRewardIcon3"},
			{f = "i", t = "nRewardIcon4"},
			{f = "s", t = "szHelpImagePath"},
			{f = "S", t = "szHelpText"},
		}
	},
	
	PQObjective = 
	{
		Path = "\\UI\\Scheme\\Case\\pqobjective.txt",
		Title = 
		{
			{f = "i", t = "dwPQTemplateID"},
			{f = "S", t = "szObjective1"},
			{f = "S", t = "szObjective2"},
			{f = "S", t = "szObjective3"},
			{f = "S", t = "szObjective4"},
			{f = "S", t = "szObjective5"},
			{f = "S", t = "szObjective6"},
			{f = "S", t = "szObjective7"},
			{f = "S", t = "szObjective8"},
		}
	},
	
	
	SkillEvent = 
	{
		Path = "\\UI\\Scheme\\Case\\skillevent.txt",
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "S", t = "szDesc"},
		}
	},
	
	BookSegment = 
	{
		Path = "\\UI\\Scheme\\Case\\RecipeBelong.txt",
		Title = 
		{
			{f = "i", t = "dwBookID"},
			{f = "i", t = "dwSegmentID"},
			{f = "i", t = "dwBookItemIndex"},
			{f = "i", t = "dwBookNumber"},
			{f = "i", t = "nSort"},
			{f = "i", t = "nSubSort"},
			{f = "i", t = "nType"},
			{f = "s", t = "szBookName"},
			{f = "s", t = "szSegmentName"},
			{f = "s", t = "szDesc"},
			{f = "i", t = "dwPageCount"},
			{f = "i", t = "dwPageID_0"},
			{f = "i", t = "dwPageID_1"},
			{f = "i", t = "dwPageID_2"},
			{f = "i", t = "dwPageID_3"},
			{f = "i", t = "dwPageID_4"},
			{f = "i", t = "dwPageID_5"},
			{f = "i", t = "dwPageID_6"},
			{f = "i", t = "dwPageID_7"},
			{f = "i", t = "dwPageID_8"},
			{f = "i", t = "dwPageID_9"},
		}
	},
	
	BookPage = 
	{
		Path = "\\UI\\Scheme\\Case\\Contents.txt",
		Title = 
		{
			{f = "i", t = "dwPageID"},
			{f = "S", t = "szContent"},
		}
	},
	
	Craft = 
	{
		Path = "\\UI\\Scheme\\Case\\craft.txt",
		Title = 
		{
			{f = "i", t = "dwProfessionID"},
			{f = "i", t = "dwCraftID"},
			{f = "i", t = "dwIconID"},
			{f = "i", t = "nType"},
			{f = "i", t = "dwRelateProfessionID"},
			{f = "i", t = "dwRelateCraftID"},
			{f = "s", t = "szName"},
			{f = "S", t = "szDesc"},
		}
	},
	
	CraftEnchant = 
	{
		
		Path = "\\UI\\Scheme\\Case\\CraftEnchant.txt",
		Title = 
		{
			{f = "i", t = "dwProfessionID"},
			{f = "i", t = "dwCraftID"},
			{f = "i", t = "dwRecipeID"},
			{f = "i", t = "dwIconID"},
			{f = "i", t = "nQuality"},
			{f = "s", t = "szName"},
			{f = "S", t = "szDesc"},
		}
	},
	
	CraftBelongName = 
	{
		
		Path = "\\UI\\Scheme\\Case\\CraftBelongName.txt",
		Title = 
		{
			{f = "i", t = "dwProfessionID"},
			{f = "i", t = "dwBelongID"},
			{f = "s", t = "szBelongName"},
		}
	},
	Attribute = 
	{
		Path = "\\UI\\Scheme\\Case\\attribute.txt",
		Title = 
		{
			{f = "s", t = "szAttributeName"},
			{f = "S", t = "szGeneratedBase"},
			{f = "S", t = "szGeneratedMagic"},
			{f = "S", t = "szPreviewBase"},
			{f = "S", t = "szPreviewMagic"},
		},
	},
	
	Require = 
	{
		Path = "\\UI\\Scheme\\Case\\require.txt",
		Title = 
		{
			{f = "s", t = "szRequireName"},
			{f = "S", t = "szGeneratedRequire"},
			{f = "S", t = "szPreviewRequire"},
		}
	},
	
	Designation_Prefix = 
	{
		Path = "\\UI\\Scheme\\Case\\Designation_Prefix.txt",
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "s", t = "szName"},
			{f = "i", t = "dwAchievement"},
			{f = "i", t = "dwTableIndex"},
			{f = "i", t = "nQuality"},
			{f = "S", t = "szDesc"},
		}	
	},
	
	Designation_Postfix = 
	{
		Path = "\\UI\\Scheme\\Case\\Designation_Postfix.txt",
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "s", t = "szName"},
			{f = "i", t = "dwAchievement"},
			{f = "i", t = "dwTableIndex"},
			{f = "i", t = "nQuality"},
			{f = "S", t = "szDesc"},
		}	
	},
	
	Designation_Generation = 
	{
		Path = "\\UI\\Scheme\\Case\\Designation_Generation.txt",
		Title = 
		{
			{f = "i", t = "dwForce"},
			{f = "i", t = "dwGeneration"},
			{f = "s", t = "szName"},
			{f = "s", t = "szCharacter"},
			{f = "S", t = "szDesc"},
		}	
	},
	
	Designation_Character_ChunYang = 
	{
		Path = "\\UI\\Scheme\\Case\\Designation_Character_ChunYang.txt",
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "s", t = "szName"},
		}
	},

	Designation_Character_Qixiu = 
	{
		Path = "\\UI\\Scheme\\Case\\Designation_Character_Qixiu.txt",
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "s", t = "szName"},
		}
	},

	Designation_Character_Shaolin = 
	{
		Path = "\\UI\\Scheme\\Case\\Designation_Character_Shaolin.txt",
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "s", t = "szName"},
		}
	},

	Designation_Character_Tiance = 
	{
		Path = "\\UI\\Scheme\\Case\\Designation_Character_Tiance.txt",
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "s", t = "szName"},
		}
	},

	Designation_Character_WanHua = 
	{
		Path = "\\UI\\Scheme\\Case\\Designation_Character_WanHua.txt",
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "s", t = "szName"},
		}
	},
	
	SuggestQuest = 
	{
		Path = "\\UI\\Scheme\\Case\\cyclopaedia\\suggestquest.txt",
		Title = 
		{
			{f = "i", t = "nLevel"},
			{f = "i", t = "dwForceID"},
			{f = "i", t = "dwMapID1"},
			{f = "i", t = "dwAreaID1"},
			{f = "i", t = "dwMapID2"},
			{f = "i", t = "dwAreaID2"},
			{f = "i", t = "dwMapID3"},
			{f = "i", t = "dwAreaID3"},
			{f = "i", t = "dwMapID4"},
			{f = "i", t = "dwAreaID4"},
			{f = "i", t = "dwMapID5"},
			{f = "i", t = "dwAreaID5"},
			{f = "i", t = "dwMapID6"},
			{f = "i", t = "dwAreaID6"},
			{f = "i", t = "dwMapID7"},
			{f = "i", t = "dwAreaID7"},
			{f = "i", t = "dwMapID8"},
			{f = "i", t = "dwAreaID8"},
			{f = "i", t = "dwMapID9"},
			{f = "i", t = "dwAreaID9"},
			{f = "i", t = "dwMapID10"},
			{f = "i", t = "dwAreaID10"},
			{f = "i", t = "dwMapID11"},
			{f = "i", t = "dwAreaID11"},
			{f = "i", t = "dwMapID12"},
			{f = "i", t = "dwAreaID12"},
			{f = "i", t = "dwMapID13"},
			{f = "i", t = "dwAreaID13"},
			{f = "i", t = "dwMapID14"},
			{f = "i", t = "dwAreaID14"},
			{f = "i", t = "dwMapID15"},
			{f = "i", t = "dwAreaID15"},
			{f = "i", t = "dwMapID16"},
			{f = "i", t = "dwAreaID16"},
			{f = "i", t = "dwMapID17"},
			{f = "i", t = "dwAreaID17"},
			{f = "i", t = "dwMapID18"},
			{f = "i", t = "dwAreaID18"},
			{f = "i", t = "dwMapID19"},
			{f = "i", t = "dwAreaID19"},
			{f = "i", t = "dwMapID20"},
			{f = "i", t = "dwAreaID20"},
			{f = "i", t = "dwMapID21"},
			{f = "i", t = "dwAreaID21"},
			{f = "i", t = "dwMapID22"},
			{f = "i", t = "dwAreaID22"},
		}
	},
	
	SuggestCopy = 
	{
		Path = "\\UI\\Scheme\\Case\\cyclopaedia\\suggestcopy.txt",
		Title = 
		{
			{f = "i", t = "nLevel"},
			{f = "i", t = "dwID1"},
			{f = "i", t = "dwID2"},
			{f = "i", t = "dwID3"},
			{f = "i", t = "dwID4"},
			{f = "i", t = "dwID5"},
			{f = "i", t = "dwID6"},
			{f = "i", t = "dwID7"},
			{f = "i", t = "dwID8"},
			{f = "i", t = "dwID9"},
			{f = "i", t = "dwID10"},
			{f = "i", t = "dwID11"},
			{f = "i", t = "dwID12"},
			{f = "i", t = "dwID13"},
			{f = "i", t = "dwID14"},
			{f = "i", t = "dwID15"},
			{f = "i", t = "dwID16"},
			{f = "i", t = "dwID17"},
			{f = "i", t = "dwID18"},
			{f = "i", t = "dwID19"},
			{f = "i", t = "dwID20"},
		},
	},
	
	SuggestBattlefield = 
	{
		Path = "\\UI\\Scheme\\Case\\cyclopaedia\\suggestbattlefield.txt",
		Title = 
		{
			{f = "i", t = "nLevel"},
			{f = "i", t = "dwID1"},
			{f = "i", t = "dwID2"},
			{f = "i", t = "dwID3"},
			{f = "i", t = "dwID4"},
			{f = "i", t = "dwID5"},
			{f = "i", t = "dwID6"},
			{f = "i", t = "dwID7"},
			{f = "i", t = "dwID8"},
			{f = "i", t = "dwID9"},
			{f = "i", t = "dwID10"},
		}
	},
	
	CombatTextPoint = 
	{
		Path = "\\ui\\scheme\\case\\combattextpoint.txt",
		Title = 
		{
			{f = "i", t = "nID"},
			{f = "i", t = "nType"},
			{f = "i", t = "nX"},
			{f = "i", t = "nY"},
			{f = "i", t = "fScale"},
			{f = "i", t = "nAlpha"},
			{f = "i", t = "nRed"},
			{f = "i", t = "nGreen"},
			{f = "i", t = "nBlue"},
			{f = "f", t = "fParam1"},
			{f = "f", t = "fParam2"},
			{f = "f", t = "fParam3"},
		}
	},
		
	CombatTextTrack = 
	{
		Path = "\\ui\\scheme\\case\\combattexttrack.txt",
		Title = 
		{
			{f = "i", t = "nID"},
			{f = "s", t = "szDesc"},
			{f = "s", t = "szPointList"},
			{f = "i", t = "nSelf"},
			{f = "i", t = "nOther"},
			{f = "i", t = "nDamagePhysics"},
			{f = "i", t = "nDamageSolarMagic"},
			{f = "i", t = "nDamageNeutralMagic"},
			{f = "i", t = "nDamageLunarMagic"},
			{f = "i", t = "nDamagePosion"},
			{f = "i", t = "nDamageReflectied"},
			{f = "i", t = "nDamageTherapy"},
			{f = "i", t = "nDamageStealLife"},
			{f = "i", t = "nDamageAbsorb"},
			{f = "i", t = "nDamageShield"},			
			{f = "i", t = "nDamageParry"},
			{f = "i", t = "nDamageInsight"},
			{f = "i", t = "nStateText"},
			{f = "i", t = "nBuff"},
			{f = "i", t = "nDeBuff"},
		}
	},
	
	Ranking = 
	{
		Path = "\\ui\\scheme\\case\\Ranking.txt",
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "i", t = "nType"},
			{f = "s", t = "szName"},
			{f = "s", t = "szKey"},
			{f = "s", t = "szValueName"},
			{f = "S", t = "szDesc"},
		}		
	},
	
	DoodadTemplate = 
	{
		Path = "\\ui\\scheme\\case\\DoodadTemplate.tab",
		Title = 
		{
			{f = "i", t = "nID"},
			{f = "s", t = "szName"},
			{f = "s", t = "szBarText"},
		}
	},
	
	NpcTemplate = 
	{
		Path = "\\ui\\scheme\\case\\NpcTemplate.tab",
		Title = 
		{
			{f = "i", t = "nID"},
			{f = "s", t = "szName"},
		}
	},
	
	MapList = 
	{
		Path = "\\ui\\scheme\\case\\MapList.tab",
		Title = 
		{
			{f = "i", t = "nID"},
            {f = "i", t = "nGroup"},
			{f = "s", t = "szName"},
			{f = "s", t = "szMiddleMap0"},
			{f = "s", t = "szMiddleMap1"},
			{f = "p", t = "szImagesPath"},
			{f = "S", t = "szTip"},
		}
	},
	
	CareerEvent = 
	{
		Path = "\\ui\\scheme\\case\\cyclopaedia\\CareerEvent.txt",
		Title = 
		{
			{f = "i", t = "nLevel"},
			{f = "s", t = "szName"},
			{f = "s", t = "szTitle"},
			{f = "s", t = "szIntroduction"},
			{f = "i", t = "nMapID1"},
			{f = "i", t = "nMapID2"},
			{f = "i", t = "nMapID3"},
			{f = "i", t = "nMapID4"},
			{f = "i", t = "nMapID5"},
			{f = "s", t = "szTab"},
		}
	},
	
	CareerGuide = 
	{
		Path = "\\ui\\scheme\\case\\cyclopaedia\\CareerGuide.txt",
		Title = 
		{
			{f = "i", t = "nLinkID"},
			{f = "i", t = "dwMapID"},
			{f = "i", t = "dwNpcID"},
			{f = "s", t = "szKind"},
			{f = "f", t = "fX"},
			{f = "f", t = "fY"},
			{f = "f", t = "fZ"},
			{f = "s", t = "szNpcName"}
		}
	},
	
	CareerTab = 
	{
		Path = "\\ui\\scheme\\case\\cyclopaedia\\CareerTab.txt",
		Title = 
		{
			{f = "i", t = "nTabID"},
			{f = "s", t = "szName"},
			{f = "s", t = "szTitle"},
			{f = "p", t = "szImage1"},
			{f = "s", t = "szNote1"},
			{f = "p", t = "szImage2"},
			{f = "s", t = "szNote2"},
			{f = "p", t = "szImage3"},
			{f = "s", t = "szNote3"},
			{f = "s", t = "szDescription"},
		}
	},
	
	Quests = 
	{
		Path = "\\ui\\scheme\\case\\Quests.tab",
		Title = 
		{
			{f = "i", t = "nID"},
			{f = "s", t = "szName"},
			{f = "s", t = "szObjective"},
			{f = "s", t = "szDescription"},
			{f = "s", t = "szDunningDialogue"},
			{f = "s", t = "szUnfinishedDialogue"},
			{f = "s", t = "szFinishedDialogue"},
			{f = "s", t = "szQuestDiff"},
			{f = "i", t = "nStartGossipType"},
			{f = "s", t = "szStartGossip1"},
			{f = "s", t = "szStartGossip2"},
			{f = "s", t = "szStartGossip3"},
			{f = "s", t = "szStartGossip4"},
			{f = "i", t = "nEndGossipType"},
			{f = "s", t = "szEndGossip1"},
			{f = "s", t = "szEndGossip2"},
			{f = "s", t = "szEndGossip3"},
			{f = "s", t = "szEndGossip4"},
			{f = "s", t = "szQuestValueStr1"},
			{f = "s", t = "szQuestValueStr2"},
			{f = "s", t = "szQuestValueStr3"},
			{f = "s", t = "szQuestValueStr4"},
			{f = "s", t = "szQuestValueStr5"},
			{f = "s", t = "szQuestValueStr6"},
			{f = "s", t = "szQuestValueStr7"},
			{f = "s", t = "szQuestValueStr8"},
			{f = "b", t = "bUseItem"},
            {f = "s", t = "szQuestFinishedObjective"},
            {f = "s", t = "szQuestFailedObjective"},
		}
	},
	
	QuestClass = 
	{
		Path = "\\ui\\scheme\\case\\QuestClass.tab",
		Title = 
		{
			{f = "i", t = "nID"},
			{f = "s", t = "szClass"},
		}
	},
	
	SmartDialog = 
	{
		Path = "\\ui\\scheme\\case\\SmartDialog.tab",
		Title = 
		{
			{f = "i", t = "nID"},
			{f = "s", t = "szTurnToFight_Text_1"},
			{f = "s", t = "szTurnToFight_Text_2"},
			{f = "s", t = "szTurnToFight_Text_3"},
			{f = "s", t = "szDeath_Text_1"},
			{f = "s", t = "szDeath_Text_2"},
			{f = "s", t = "szDeath_Text_3"},
			{f = "s", t = "szTeammateDeath_Text_1"},
			{f = "s", t = "szTeammateDeath_Text_2"},
			{f = "s", t = "szTeammateDeath_Text_3"},
			{f = "s", t = "szIdle_Text_1"},
			{f = "s", t = "szIdle_Text_2"},
			{f = "s", t = "szIdle_Text_3"},
			{f = "s", t = "szCustom_Text_1"},
			{f = "s", t = "szCustom_Text_2"},
			{f = "s", t = "szCustom_Text_3"},
			{f = "s", t = "szTurnToIdle_Text_1"},
			{f = "s", t = "szTurnToIdle_Text_2"},
			{f = "s", t = "szTurnToIdle_Text_3"},
			{f = "s", t = "szKillEnemy_Text_1"},
			{f = "s", t = "szKillEnemy_Text_2"},
			{f = "s", t = "szKillEnemy_Text_3"},
			{f = "s", t = "szEscape_Text_1"},
			{f = "s", t = "szEscape_Text_2"},
			{f = "s", t = "szEscape_Text_3"},
		}
	},
	
	ProfessionName = 
	{
		Path = "\\ui\\scheme\\case\\ProfessionName.txt",
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "s", t = "szName"},
		}
	},
	
	UICraft = 
	{
		Path = "\\ui\\scheme\\case\\UICraft.txt",
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "s", t = "szName"},
			{f = "s", t = "szPath"},
		}
	},
	
	BranchName = 
	{
		Path = "\\ui\\scheme\\case\\BranchName.txt",
		Title = 
		{
			{f = "i", t = "dwProfessionID"},
			{f = "i", t = "dwBranchID"},
			{f = "s", t = "szName"},
		}
	},
	
	PathList = 
	{
		Path = "\\ui\\scheme\\case\\pathlist.txt",
		Title = 
		{
			{f = "s", t = "szID"},
			{f = "p", t = "szPath"},		
		}
	},
	
	JX3Library = 
	{
		Path = "\\UI\\Scheme\\Case\\cyclopaedia\\JX3Library.txt",
		Title = 
		{
			{f = "i", t = "dwClassID"},
			{f = "i", t = "dwSubClassID"},
			{f = "i", t = "dwID"},
			{f = "s", t = "szClassName"},
			{f = "s", t = "szSubClassName"},
			{f = "s", t = "szTitle"},
			{f = "S", t = "szContent"},
			{f = "S", t = "szLink"},
		}
	},
	
	RecipeName = 
	{
		-- Path = ...,
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "s", t = "szName"},
		}
	},
	
	BoxInfo = 
	{
		Path = "\\UI\\Scheme\\Case\\boxinfo.txt",
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "s", t = "szTitle"},
			{f = "s", t = "szDesc"},
		}
	},
	
	ActivityInfo = 
	{
		Path = "\\UI\\Scheme\\Case\\cyclopaedia\\ActivityInfo.txt",
		Title = 
		{
			{f = "i", t = "dwClassID"},
			{f = "i", t = "dwActivityID"},
			{f = "s", t = "szClassName"},
			{f = "s", t = "szTitle"},
			{f = "S", t = "szContent"},
			{f = "S", t = "szLink"},
		}
	},
	
	DailyQuestInfo = 
	{
		Path = "\\UI\\Scheme\\Case\\cyclopaedia\\DailyQuestInfo.txt",
		Title = 
		{
			{f = "i", t = "dwTypeID"},
			{f = "i", t = "dwQuestID"},
			{f = "s", t = "szTypeName"},
			{f = "S", t = "szContent"},
			{f = "S", t = "szLink"},
		}
	},
	
	DungeonClass = 
	{
		Path = "\\UI\\Scheme\\Case\\cyclopaedia\\DungeonClass.txt",
		Title = 
		{
			{f = "i", t = "dwClassID"},
			{f = "s", t = "szClassName"},
			{f = "S", t = "szContent"},
			{f = "S", t = "szLink"},
		}
	},
	
	DungeonInfo = 
	{
		Path = "\\UI\\Scheme\\Case\\cyclopaedia\\DungeonInfo.txt",
		Title = 
		{
			{f = "i", t = "dwMapID"},
			{f = "i", t = "dwClassID"},
			{f = "i", t = "nMinLevel"},
			{f = "i", t = "nFitMinLevel"},
			{f = "i", t = "nFitMaxLevel"},
			{f = "s", t = "szLayer3Name"},
			{f = "s", t = "szOtherName"},
			{f = "s", t = "szVersionName"},
			{f = "S", t = "szEnterWay"},
			{f = "S", t = "szBossInfo"},
			{f = "S", t = "szIntroduction"},
			{f = "S", t = "szTutorial"},
			{f = "S", t = "szHelpImage"},
			{f = "S", t = "szHelpText"},
		}
	},
	
	FaceIcon= 
	{
		Path = "\\UI\\Scheme\\Case\\FaceIcon.txt",
		Title = 
		{
			{f = "s", t = "szCommand"},
			{f = "s", t = "szType"},
			{f = "i", t = "nFrame"},
			{f = "i", t = "bShow"},
		}
	},
	
	BackPendant=
	{
		Path = "\\UI\\Scheme\\Case\\pendant_back.txt",
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "i", t = "dwType"},
			{f = "i", t = "dwIndex"},
		}
	},

	WaistPendant=
	{
		Path = "\\UI\\Scheme\\Case\\pendant_waist.txt",
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "i", t = "dwType"},
			{f = "i", t = "dwIndex"},
		}
	},
	
	EquipRecommend = 
	{
		Path = "\\UI\\Scheme\\Case\\equip_recommend.txt",
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "s", t = "szDesc"},
		}
	},
	
	CalenderActivity = 
	{
		Path = "\\UI\\Scheme\\Case\\cyclopaedia\\ActicityUI.tab",
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "s", t = "szName"},
			{f = "s", t = "szTimeRepresent"},
			{f = "i", t = "nClass"},
			{f = "s", t = "szLevel"},
			{f = "s", t = "szAwardType"},
			{f = "i", t = "nShowPosition"},
			{f = "b", t = "bHighlight"},
			{f = "s", t = "szHighlightPath"},
			{f = "i", t = "nFrame"},
			{f = "i", t = "nShowPriority"},
			{f = "s", t = "szDetailPath"},
			{f = "s", t = "szHard"},
			{f = "S", t = "szDetailMap"},
			{f = "S", t = "szDetailAwards"},
			{f = "S", t = "szText"},
			{f = "i", t = "nEvent"},
            {f = "s", t = "szAdvancedTime"},
            {f = "i", t = "nLabel"},
            {f = "p", t = "szBackgroundImage"},
            {f = "p", t = "szBackgroundImageExpend"},
            {f = "i", t = "nLuckdraw"},
            {f = "p", t = "szLuckPath"},
            {f = "i", t = "nLuckFrame"},
            {f = "S", t = "szLuckdrawText"},
		}
	},
	
	CalenderAward = 
	{
		Path = "\\UI\\Scheme\\Case\\cyclopaedia\\CalenderAward.txt",
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "s", t = "szName"},
		}
	},
	
	FAQ = 
	{
		Path = "\\UI\\Scheme\\Case\\cyclopaedia\\FAQ.txt",
		Title = 
		{
			{f = "i", t = "dwClassID"},
			{f = "i", t = "dwSubClassID"},
			{f = "s", t = "szClassName"},
			{f = "S", t = "szQuestion"},
			{f = "S", t = "szAnswer"},
		},
	},
	
	PlayerAvatar = 
	{
		Path="\\UI\\Scheme\\Case\\player_miniavatar.txt",
		Title = 
		{
			{f = "i", t = "dwPlayerMiniAvatarID"},
			{f = "i", t = "dwType"},
			{f = "i", t = "dwKindID"},
			{f = "s", t = "szFileName"},
			{f = "s", t = "szDesc"},
		},
	},
	Currency = 
	{
		Path = "\\UI\\Scheme\\Case\\Currency.txt",
		Title = 
		{
		        {f = "i", t = "dwID"},
			{f = "s", t = "szName"},
			{f = "i", t = "dwGroupID"},
			{f = "i", t = "dwType"},
			{f = "i", t = "dwTabIndex"},
			{f = "i", t = "nItemID"},
		        {f = "i", t = "nFrame"},
		        {f = "s", t = "szDesc1"},
		        {f = "s", t = "szDesc2"},
			{f = "s", t = "szLinkInfo"},
		},
	},
	
	TitleRank = 
	{
		Path = "\\UI\\Scheme\\Case\\TitleRank.txt",
		Title = 
		{
			{f = "i", t = "dwRank"},
			{f = "i", t = "dwTitlePoint"},
			{f = "s", t = "szTip"},
		}
	},
	EquipmentRecipe  = 
	{
		Path="\\UI\\Scheme\\Case\\equipmentrecipe.txt",
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "i", t = "nLevel"},
			{f = "s", t = "szDesc"},
		},
	},
	
	PetSkill = 
	{
		Path = "\\UI\\Scheme\\Case\\PetSkill.txt",
		Title = 
		{
			{f = "i", t = "dwNpcTemplateID"},
			{f = "p", t = "szAvatarPath"},
			{f = "i", t = "nSkillID1"},
			{f = "i", t = "nLevel1"},
			{f = "i", t = "nSkillID2"},
			{f = "i", t = "nLevel2"},
			{f = "i", t = "nSkillID3"},
			{f = "i", t = "nLevel3"},
			{f = "i", t = "nSkillID4"},
			{f = "i", t = "nLevel4"},
			{f = "i", t = "nSkillID5"},
			{f = "i", t = "nLevel5"},
			{f = "i", t = "nSkillID6"},
			{f = "i", t = "nLevel6"},
			{f = "i", t = "nSkillID7"},
			{f = "i", t = "nLevel7"},
			{f = "i", t = "nSkillID8"},
			{f = "i", t = "nLevel8"},
			{f = "i", t = "nSkillID9"},
			{f = "i", t = "nLevel9"},
			{f = "i", t = "nSkillID10"},
			{f = "i", t = "nLevel10"},
			{f = "i", t = "nSkillID11"},
			{f = "i", t = "nLevel11"},
			{f = "i", t = "nSkillID12"},
			{f = "i", t = "nLevel12"},
			{f = "i", t = "nSkillID13"},
			{f = "i", t = "nLevel13"},
			{f = "i", t = "nSkillID14"},
			{f = "i", t = "nLevel14"},
			{f = "i", t = "nSkillID15"},
			{f = "i", t = "nLevel15"},
		}
	},
	
	VideoSetting = 
	{
		Path="\\UI\\Scheme\\Case\\videosetting.txt",
		Title = 
		{
			{f = "i", t = "nConfigureLevel"},
			{f = "s", t = "szDesc"},
			{f = "b", t = "bFullScreen"},
			{f = "b", t = "bPanauision"},
			{f = "b", t = "bExclusiveMode"},
			{f = "i", t = "nWidth"},
			{f = "i", t = "nHeight"},
			{f = "i", t = "nRefreshRate"},
			{f = "i", t = "nMultiSampleType"},
			{f = "b", t = "bFXAA"},
			{f = "i", t = "nFXAALevel"},
			{f = "i", t = "nForceShaderModel"},
			{f = "i", t = "nMDLRenderLimit"},
			{f = "i", t = "nClientSFXLimit"},
			{f = "b", t = "bOptimizeQiChang"},
			{f = "b", t = "bOptimizeUniform"},
			{f = "b", t = "bOptimizeRide"},
			{f = "b", t = "bOptimizeWeapon"},
			{f = "b", t = "bEnableScaleOutput"},
			{f = "b", t = "bScaleOutputSmooth"},
			{f = "i", t = "nScaleOutputSize"},
            
			{f = "b", t = "bRenderGrass"},
			{f = "b", t = "bGrassAnimation"},
			{f = "b", t = "bGrassAlphaBlend"},
			{f = "b", t = "bShockWaveEnable"},
			{f = "b", t = "bDOF"},
			{f = "b", t = "bHDR"},
			{f = "b", t = "bBloomEnable"},
			{f = "b", t = "bGodRay"},
			{f = "b", t = "bMotionBlur"},

			{f = "i", t = "nWaterDetail"},
			{f = "i", t = "nTextureScale"},
			{f = "i", t = "dwMaxAnisotropy"},
			{f = "i", t = "fCameraDistance"},
			{f = "i", t = "nVegetationDensity"},
			{f = "i", t = "nShadowType"},
			{f = "i", t = "nTerrainDetail"},
		}

	},
	EquipDB= 
	{
		Path = "\\UI\\Scheme\\Case\\equipdb.txt",
		Title = 
		{
			{f="i", t="dwTabType"},
			{f="i", t="nItemID"},
			{f="i", t="nLevel"},
			{f="i", t="nAucType"},
			{f="i", t="nAucSubType"},
			{f="s", t="szName"},
			{f="i", t="nSchoolID"},
			{f="i", t="nSetID"},
			{f="s", t="szMagicKind"},
			{f="s", t="szMagicType"},
			{f="s", t="szSourceType"},
			{f="s", t="szPvePvp"},
			{f="s", t="szSourceForce"},
			{f="s", t="szSourceDesc"},
			{f="s", t="szBelongMapID"},
			{f="s", t="szPrestigeRequire"},
		}
	},
	
	FieldPQ  = 
	{
		Path="\\UI\\Scheme\\Case\\cyclopaedia\\fieldpq.txt",
		Title = 
		{
			{f = "i", t = "dwPQTemplateID"},
			{f = "i", t = "dwMapID"},
			{f = "i", t = "nTotalStep"},
			{f = "S", t = "szName"},
			{f = "S", t = "szDesc"},
			{f = "i", t = "fX"},
			{f = "i", t = "fY"},
			{f = "i", t = "fZ"},
		},
	},
	
	FieldPQSetp  = 
	{
		Path="\\UI\\Scheme\\Case\\cyclopaedia\\fieldpqstep.txt",
		Title = 
		{
			{f = "i", t = "dwPQTemplateID"},
			{f = "i", t = "nSetpID"},
			{f = "S", t = "szName"},
			{f = "S", t = "szDesc"},
			{f = "i", t = "nKillNpcTemplateID1"},
			{f = "i", t = "nAmount1"},
			{f = "i", t = "nKillNpcTemplateID2"},
			{f = "i", t = "nAmount2"},
			{f = "i", t = "nKillNpcTemplateID3"},
			{f = "i", t = "nAmount3"},
			{f = "i", t = "nKillNpcTemplateID4"},
			{f = "i", t = "nAmount4"},
			{f = "i", t = "nKillNpcTemplateID5"},
			{f = "i", t = "nAmount5"},
			{f = "i", t = "nKillNpcTemplateID6"},
			{f = "i", t = "nAmount6"},
			{f = "i", t = "nKillNpcTemplateID7"},
			{f = "i", t = "nAmount7"},
			{f = "i", t = "nKillNpcTemplateID8"},
			{f = "i", t = "nAmount8"},
			{f = "i", t = "nPQvalue1"},
			{f = "s", t = "szPQValueStr1"},
			{f = "i", t = "nPQvalue2"},
			{f = "s", t = "szPQValueStr2"},
			{f = "i", t = "nPQvalue3"},
			{f = "s", t = "szPQValueStr3"},
			{f = "i", t = "nPQvalue4"},
			{f = "s", t = "szPQValueStr4"},
			{f = "i", t = "nPQvalue5"},
			{f = "s", t = "szPQValueStr5"},
			{f = "i", t = "nPQvalue6"},
			{f = "s", t = "szPQValueStr6"},
			{f = "i", t = "nPQvalue7"},
			{f = "s", t = "szPQValueStr7"},
			{f = "i", t = "nPQvalue8"},
			{f = "s", t = "szPQValueStr8"},
		},
	},
	
	CyclopaediaSkill = 
	{
		Path="\\UI\\Scheme\\Case\\cyclopaedia\\CyclopaediaSkill.txt",
		Title = 
		{
			{f = "i", t = "nSectionID"},
			{f = "i", t = "nForceID"},
			{f = "s", t = "szSkill"},
		},
	},
	
	ActivitySymbolInfo = 
	{
		Path="\\UI\\Scheme\\Case\\ActivitySymbolInfo.txt",
		Title = 
		{
			{f = "i", t = "dwMapID"},
			{f = "i", t = "nSymbolID"},
			{f = "p", t = "szImagePath"},
			{f = "i", t = "nFrame"},
			{f = "s", t = "szName"},
			{f = "s", t = "szDesc"},
			{f = "s", t = "szPositions"},
		},
	},
	
	TongTechTreeNode = 
	{
		Path = "\\UI\\Scheme\\Case\\TongTechTreeNode.txt",
		Title = 
		{
			{f = "i", t = "nNodeID"},
			{f = "i", t = "nLevel"},
			{f = "s", t = "szName"},
			{f = "s", t = "szDesc"},
		}
	},
    
	Talent = 
	{
   		Path = "\\UI\\Scheme\\Case\\talent.txt",
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "i", t = "dwForceID"},
			{f = "s", t = "szTalentName"},
			{f = "i", t = "nTalentType"},
			{f = "i", t = "nIconID"},
			{f = "s", t = "szImage"},
		}     
	},
	
	CGList = 
	{
   		Path = "\\UI\\Scheme\\Case\\CGList.txt",
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "s", t = "szDesc"},
			{f = "p", t = "szBgPath"},
			{f = "i", t = "nNormalFrame"},
			{f = "i", t = "nHightLightFrame"},
			{f = "i", t = "nDisableFrame"},
			{f = "p", t = "szCGPath"},
			{f = "p", t = "szDowloadUrl"},
		}     
	},
	
	TongActivity = 
	{
   		Path = "\\UI\\Scheme\\Case\\TongActivity.txt",
		Title = 
		{
			{f = "i", t = "dwClassID"},
			{f = "i", t = "dwSubClassID"},
			{f = "i", t = "dwID"},
			{f = "s", t = "szName"},
			{f = "s", t = "szTime"},
			{f = "s", t = "szPlace"},
			{f = "s", t = "szReward"},
			{f = "s", t = "szJoinLevel"},
			{f = "S", t = "szContent"},
		}     
	},
	
	EquipSet = 
	{
   		Path = "\\UI\\Scheme\\Case\\equipset.txt",
		Title = 
		{
			{f = "i", t = "nSetID"},
			{f = "i", t = "nUIID"},
			{f = "i", t = "nReplaceUIID"},
		}  
	},
	
	BattleFieldData = 
	{
   		Path = "\\UI\\Scheme\\Case\\battlefielddata.txt",
		Title = 
		{
			{f = "i", t = "nType"},
			{f = "s", t = "szDesc"},
			{f = "p", t = "szImage"},
			{f = "i", t = "nFrame"},
			{f = "s", t = "szTip"},
		}  
	},
	
	ActivityTip = 
	{
   		Path = "\\UI\\Scheme\\Case\\ActivityTip.txt",
		Title = 
		{
			{f = "i", t = "dwActivityID"},
			{f = "s", t = "szName"},
			{f = "s", t = "szTimeDesc"},
            {f = "S", t = "szLink"},
            {f = "s", t = "szTip1"},
            {f = "s", t = "szTip2"},
            {f = "s", t = "szTip3"},
            {f = "s", t = "szTip4"},
            {f = "s", t = "szTip5"},
		}  
	},
    
    PuppetSkill = 
	{
		Path = "\\UI\\Scheme\\Case\\PuppetSkill.txt",
		Title = 
		{
			{f = "i", t = "dwNpcTemplateID"},
            {f = "s", t = "szGroup"},
			{f = "i", t = "nSkillID1"},
			{f = "i", t = "nLevel1"},
			{f = "i", t = "nSkillID2"},
			{f = "i", t = "nLevel2"},
			{f = "i", t = "nSkillID3"},
			{f = "i", t = "nLevel3"},
			{f = "i", t = "nSkillID4"},
			{f = "i", t = "nLevel4"},
			{f = "i", t = "nSkillID5"},
			{f = "i", t = "nLevel5"},
			{f = "i", t = "nSkillID6"},
			{f = "i", t = "nLevel6"},
			{f = "i", t = "nSkillID7"},
			{f = "i", t = "nLevel7"},
			{f = "i", t = "nSkillID8"},
			{f = "i", t = "nLevel8"},
		}
	},
    
    AwardRemind = 
	{
		Path = "\\UI\\Scheme\\Case\\AwardRemind.txt",
		Title = 
		{
			{f = "i", t = "dwID"},
            {f = "s", t = "szName"},
			{f = "S", t = "szTimeRepresent"},
			{f = "s", t = "szLevel"},
			{f = "S", t = "szDetails"},
			{f = "S", t = "szAward"},
			{f = "S", t = "szLink"},
			{f = "i", t = "dwQuestID"},
		}
	},
	
	Map_DynamicData = 
	{
		Path = "\\UI\\Scheme\\Case\\map_dynamicdata.txt",
		Title = 
		{
			{f = "i", t = "nType"},
			{f = "s", t = "szDesc"},
			{f = "p", t = "szImage"},
			{f = "i", t = "nFrame"},
			{f = "i", t = "nWidth"},
			{f = "i", t = "nHeight"},
			{f = "s", t = "szTip"},
		}  
	},
	
	CreateRole_Param = 
	{
		Path = "\\ui\\scheme\\case\\createrole_param.txt",
		Title = 
		{
			{f = "s", t = "szSchoolType"},
            {f = "i", t = "nHard"},
			
			{f = "i", t = "dwKungfuIndex"},
			
			{f = "s", t = "szMale2JumpAni"},
			{f = "s", t = "szFemale1JumpAni"},
			{f = "s", t = "szFemale2JumpAni"},
			
			{f = "p", t = "szSchoolImage"},
			{f = "i", t = "nSchoolFrame"},
			
			{f = "s", t = "szRoute1Name"},
			{f = "p", t = "szRoute1Image"},
			{f = "i", t = "nRoute1Frame"},
			
			{f = "s", t = "szRoute2Name"},
			{f = "p", t = "szRoute2Image"},
			{f = "i", t = "nRoute2Frame"},
			
			{f = "i", t = "dwSkillID1"},
			{f = "s", t = "szMaleAniID1"},
			{f = "s", t = "szFemaleAniID1"},
			{f = "i", t = "dwPlayCount1"},
			
			{f = "i", t = "dwSkillID2"},
			{f = "s", t = "szMaleAniID2"},
			{f = "s", t = "szFemaleAniID2"},
			{f = "i", t = "dwPlayCount2"},
			
			{f = "i", t = "dwSkillID3"},
			{f = "s", t = "szMaleAniID3"},
			{f = "s", t = "szFemaleAniID3"},
			{f = "i", t = "dwPlayCount3"},
			
			{f = "i", t = "dwSkillID4"},
			{f = "s", t = "szMaleAniID4"},
			{f = "s", t = "szFemaleAniID4"},
			{f = "i", t = "dwPlayCount4"},
			
			{f = "S", t = "szIntroduce"},
		}
	},
	
	MapGroup = 
	{
		Path = "\\UI\\Scheme\\Case\\MapGroup.txt",
		Title = 
		{
			{f = "i", t = "dwID"},
            {f = "s", t = "szName"},
		}
	},
    
    FirstLoginSkill = 
	{
		Path = "\\UI\\Scheme\\Case\\FirstLoginSkill.txt",
		Title = 
		{
			{f = "i", t = "dwKungfuID"},
            {f = "i", t = "dwSkillID1"},
            {f = "i", t = "dwSkillID2"},
            {f = "i", t = "dwSkillID3"},
            {f = "i", t = "dwSkillID4"},
            {f = "i", t = "dwSkillID5"},
            {f = "i", t = "dwSkillID6"},
            {f = "i", t = "dwSkillID7"},
            {f = "i", t = "dwSkillID8"},
            {f = "i", t = "dwSkillID9"},
            {f = "i", t = "dwSkillID10"},
            {f = "i", t = "dwSkillID11"},
            {f = "i", t = "dwSkillID12"},
            {f = "i", t = "dwSkillID13"},
            {f = "i", t = "dwSkillID14"},
            {f = "i", t = "dwSkillID15"},
            {f = "i", t = "dwSkillID16"},
		}
	},
	CountDown =
	{
		Path = "\\UI\\Scheme\\Case\\CountDown.txt", 
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "s", t = "szName"},
			{f = "s", t = "szImagePath"},
			{f = "s", t = "szAnchorS"},
			{f = "s", t = "szAnchorR"},
			{f = "i", t = "nOffsetX"},
			{f = "i", t = "nOffsetY"},
			{f = "i", t = "nSizeX"},
			{f = "i", t = "nSizeY"},
		}
	},
	
	DispelBuff =
	{
		Path = "\\UI\\Scheme\\Case\\dispelbuffer.txt", 
		Title = 
		{
			{f = "i", t = "dwSkillID"},	
			{f = "s", t = "szName"},
			{f = "i", t = "szBuffTye1"},
			{f = "i", t = "szBuffTye2"},
			{f = "i", t = "szBuffTye3"},
			{f = "i", t = "szBuffTye4"},
			{f = "i", t = "szBuffTye5"},
			{f = "i", t = "szBuffTye6"},
			{f = "i", t = "szBuffTye7"},
			{f = "i", t = "szBuffTye8"},
			{f = "i", t = "szBuffTye9"},
			{f = "i", t = "szBuffTye10"},
			{f = "i", t = "szBuffTye11"},
			{f = "i", t = "szBuffTye12"},
			{f = "i", t = "szBuffTye13"},
			{f = "i", t = "szBuffTye14"},
		}
	},
	SkillTip_Kungfu =
	{
		Path = "\\UI\\Scheme\\Case\\skilltip_kungfu.txt", 
		Title = 
		{
			{f = "i", t = "dwKungfuID"},	
			{f = "s", t = "szName"},
			{f = "s", t = "szTargetBuff"},
			{f = "s", t = "szPlayerBuff"},
			{f = "s", t = "szTargetLife"},
			{f = "s", t = "szPlayerLife"},
			{f = "s", t = "szTargetMana"},
			{f = "s", t = "szPlayerMana"},
			{f = "s", t = "szDoSkill"},
			{f = "s", t = "szPlayerAccumulate"},
			{f = "s", t = "szTeammateLife"},
		}
	},
	SkillTip_Event =
	{
		Path = "\\UI\\Scheme\\Case\\skilltip_event.txt", 
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "s", t = "szName"},
			{f = "s", t = "szCondition"},
			{f = "i", t = "dwSkillID"},
			{f = "i", t = "dwSkillLevel"},
			{f = "s", t = "szShowType"},
			{f = "i", t = "dwMaxTime"},
			{f = "s", t = "szShowData"},
			{f = "f", t = "fScale"},
		}
	},
	SkillTip_Condition =
	{
		Path = "\\UI\\Scheme\\Case\\skilltip_condition.txt", 
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "s", t = "szType"},
			{f = "s", t = "szName"},
			{f = "s", t = "szArg1"},
			{f = "s", t = "szArg2"},
			{f = "s", t = "szArg3"},
			{f = "s", t = "szArg4"},
		}
	},
    
    SprintHelp = 
    {
        Path = "\\UI\\Scheme\\Case\\SprintHelp.txt", 
		Title = 
		{
			{f = "i", t = "dwID"},
			{f = "s", t = "szTitle"},
			{f = "S", t = "szContentTop"},
			{f = "S", t = "szContentBottom"},
		}
    },
    
    ExteriorBox = 
    {
        Path = "\\UI\\Scheme\\Case\\Exterior\\ExteriorBox.txt",
        Title = 
        {
            
            {f = "i", t = "nGenre"},
            {f = "i", t = "nSet"},
            {f = "i", t = "nForce"},
            {f = "s", t = "szGenreName"},
            {f = "s", t = "szSetName"},
            {f = "i", t = "nSub1"}, --头部
            {f = "i", t = "nSub2"}, -- 上衣
            {f = "i", t = "nSub3"}, -- 护手
            {f = "i", t = "nSub4"}, -- 腰带
            {f = "i", t = "nSub5"}, -- 鞋子
        }  
    },
	
	Chapters = 
	{
		Path = "\\UI\\Scheme\\Case\\Chapters.txt",
		Title = 
		{
			{f = "i", t = "dwChapterID"},
			{f = "s", t = "szTitlePath"},
			{f = "s", t = "szContentPath"},
			{f = "s", t = "szNote"},
		}
	},

}
-------------------------------------------------------------------------------------------------
g_tTable = {}

local tLoadedTable = {}
local tMetatable = {}
tMetatable.__index = function(tTable, szKey)
	if not tLoadedTable[szKey] then
		tLoadedTable[szKey] = KG_Table.Load(tTableFile[szKey].Path, tTableFile[szKey].Title, FILE_OPEN_MODE.NORMAL)
	end
	return tLoadedTable[szKey]
end

--just for release table
tMetatable.__newindex = function(tTable, szKey, Value)
	if type(Value) ~= "nil" then	
		assert(false)
	end
	
	tLoadedTable[szKey] = nil
end

setmetatable(g_tTable, tMetatable)

function RegisterUITable(szKey, szPath, tTitle)
	if tTableFile[szKey] then
		Log("table file szKey = " .. szKey .. " is aleady Exist, please check")
	end
	tTableFile[szKey] = {}
	tTableFile[szKey].Path = szPath
	tTableFile[szKey].Title = tTitle
end

function IsUITableRegister(szKey)
	if tTableFile[szKey] then
		return true
	end
	return false
end

--------------------------------------------------------------------------------------------------------

-------------------- Item ------------------------
function Table_GetItemIconID(nUIID)
	local nIconID = -1
	local tItem = g_tTable.Item:Search(nUIID)
	if tItem then
		nIconID = tItem.dwIconID
	end
	return nIconID
end

function Table_GetItemName(nUIID)
	local szName = ""
	local tItem = g_tTable.Item:Search(nUIID)
	if tItem then
		szName = tItem.szName
	end
	
	return szName
end

function Table_GetItemDesc(nUIID)
	local szDesc = ""
	local tItem = g_tTable.Item:Search(nUIID)
	if tItem then
		szDesc = tItem.szDesc
	end
	
	return szDesc
end

function Table_GetItemSoundID(nUIID)
	local nSoundID = -1
	local tItem = g_tTable.Item:Search(nUIID)
	if tItem then
		nSoundID = tItem.dwSoundID
	end
	return nSoundID
end


---------------------- skill -------------------
function Table_GetSkillRecipe(dwID, dwLevel)
	local tSkillRecipe = nil
	
	tSkillRecipe = g_tTable.SkillRecipe:Search(dwID, dwLevel)
	
	if not tSkillRecipe then
		dwLevel = 0
		tSkillRecipe = g_tTable.SkillRecipe:Search(dwID, dwLevel)
	end
	
	return tSkillRecipe
end


local function Table_LoadAllSkillRecipe()
    
    local nRow = g_tTable.SkillRecipe:GetRowCount()
    for i = 2, nRow do
        tSkillRecipe = g_tTable.SkillRecipe:GetRow(i)
        if tSkillRecipe.dwSkillID > 0 then
            if not tAllSkillRecipeMap[tSkillRecipe.dwSkillID] then
                tAllSkillRecipeMap[tSkillRecipe.dwSkillID] = {}
            end
            table.insert(tAllSkillRecipeMap[tSkillRecipe.dwSkillID], {recipe_id = tSkillRecipe.dwID, recipe_level = tSkillRecipe.dwLevel})
        end
    end
end

Table_LoadAllSkillRecipe()
function Table_GetRecipeList(dwSkillID)
    return tAllSkillRecipeMap[dwSkillID]
end

function Table_GetSkill(dwSkillID, dwSkillLevel)
	local tSkill = nil
	if dwSkillLevel then
		tSkill = g_tTable.Skill:Search(dwSkillID, dwSkillLevel)
		
		if not tSkill then
			dwSkillLevel = 0
			tSkill = g_tTable.Skill:Search(dwSkillID, dwSkillLevel)
		end
	else
		tSkill = g_tTable.Skill:Search(dwSkillID)
	end
	
	return tSkill
end

function Table_GetSkillIconID(dwSkillID, dwSkillLevel)
	local nIconID = -1
	
	local tSkill = Table_GetSkill(dwSkillID, dwSkillLevel)
	if tSkill then
		nIconID = tSkill.dwIconID
	end
	
	return nIconID
end

function Table_GetSkillSchoolName(dwSkillSchoolID)
	local szName = ""
	
	local tSkillSchool = g_tTable.SkillSchool:Search(dwSkillSchoolID)
	if tSkillSchool then
		szName = tSkillSchool.szName
	end
	
	return szName
end

function Table_GetSkillSchoolIconID(dwSkillSchoolID)
	local nIconID = 0
	
	local tSkillSchool = g_tTable.SkillSchool:Search(dwSkillSchoolID)
	if tSkillSchool then
		nIconID = tSkillSchool.dwIconID
	end
	
	return nIconID
end

function Table_IsSkillFormation(dwSkillID, dwSkillLevel)
	local bFormation = false
	
	local tSkill = Table_GetSkill(dwSkillID, dwSkillLevel)
	if tSkill and tSkill.bFormation ~= 0 then
		bFormation = true
	end
	
	return bFormation
end

function Table_IsSkillFormationCaster(dwSkillID, dwSkillLevel)
	local bFormationCaster = false
	
	local tSkill = Table_GetSkill(dwSkillID, dwSkillLevel)
	if tSkill and tSkill.bFormationCaster ~= 0 then
		bFormationCaster = true
	end
	
	return bFormationCaster
end

function Table_GetSkillName(dwSkillID, dwSkillLevel)
	local szName = ""
	
	local tSkill = nil
	
	tSkill = Table_GetSkill(dwSkillID, dwSkillLevel)
	
	if tSkill then
		szName = tSkill.szName
	end
	
	return szName
end

function Table_GetSkillDesc(dwSkillID, dwSkillLevel)
	local szDesc = ""
	
	local tSkill = Table_GetSkill(dwSkillID, dwSkillLevel)
	
	if tSkill then
		szDesc = tSkill.szDesc
	end
	
	return szDesc
end

function Table_GetSkillShortDesc(dwSkillID, dwSkillLevel)
	local szShortDesc = ""
	
	local tSkill = Table_GetSkill(dwSkillID, dwSkillLevel)
	
	if tSkill then
		szShortDesc = tSkill.szShortDesc
	end
	
	return szShortDesc
end

function Table_GetSkillSpecialDesc(dwSkillID, dwSkillLevel)
	local szSpecialDesc = ""
	
	local tSkill = Table_GetSkill(dwSkillID, dwSkillLevel)
	
	if tSkill then
		szSpecialDesc = tSkill.szSpecialDesc
	end
	
	return szSpecialDesc
end

function Table_GetSkillSortOrder(dwSkillID, dwSkillLevel)
	local fOrder = 0
	
	local tSkill = Table_GetSkill(dwSkillID, dwSkillLevel)
	
	if tSkill then
		fOrder = tSkill.fSortOrder
	end
	
	return fOrder
end

function Table_IsSkillShow(dwSkillID, dwSkillLevel)
	local bShow = false 
	
	if not dwSkillLevel then
		dwSkillLevel = 0
	end
	
	local tSkill = Table_GetSkill(dwSkillID, dwSkillLevel)
	
	if tSkill and tSkill.bShow ~= 0 then
		bShow = true
	end
	
	return bShow
end

function Table_IsSkillCombatShow(dwSkillID, dwSkillLevel)
	local bCombatShow = false 
	
	if not dwSkillLevel then
		dwSkillLevel = 0
	end
	
	local tSkill = Table_GetSkill(dwSkillID, dwSkillLevel)
	
	if tSkill and tSkill.bCombatShow ~= 0 then
		bCombatShow = true
	end
	
	return bCombatShow
end

function Table_GetSkillPracticeID(dwSkillID, dwSkillLevel)
	local dwPracticeID = 0 
	
	if not dwSkillLevel then
		dwSkillLevel = 0
	end
	
	local tSkill = Table_GetSkill(dwSkillID, dwSkillLevel)
	
	if tSkill then
		dwPracticeID = tSkill.dwPracticeID
	end
	
	return dwPracticeID
end


function Table_GetLearnSkillInfo(dwLevel, dwSchool)
	local szSkill = ""
	
	local tSkill = g_tTable.LearnSkill:Search(dwLevel, dwSchool)
	
	if tSkill then
		szSkill = tSkill.szSkill
	end

	return szSkill
end

local function LoadSkillNameToIDMap()
	g_SkillNameToID = {}
	
	local nCount = g_tTable.Skill:GetRowCount()
	for i = 1, nCount do
		local tLine = g_tTable.Skill:GetRow(i)
		if tLine.bShow and tLine.dwSkillID > 0 and not g_SkillNameToID[tLine.szName] then
			local skill = GetSkill(tLine.dwSkillID, 1)
			if skill and skill.dwBelongSchool >= 0 and skill.dwBelongSchool <= 10 then
				g_SkillNameToID[tLine.szName] = tLine.dwSkillID
			end
		end
	end
end

local function CorrectSkillNameToIDMap(dwID, dwLevel)
	local player = GetClientPlayer()
	if not player then
		return
	end

	if dwID and dwLevel then
		if dwLevel > 0 and Table_IsSkillShow(dwID, dwLevel) then
			local szName = Table_GetSkillName(dwID, dwLevel)
			if szName then
				g_SkillNameToID[szName] = dwID
			end
		end
		return
	end
	
	local aSkill = player.GetAllSkillList() or {}
	for dwID, dwLevel in pairs(aSkill) do
		if Table_IsSkillShow(dwID, dwLevel) then
			local szName = Table_GetSkillName(dwID, dwLevel)
			if szName then
				g_SkillNameToID[szName] = dwID
			end
		end
	end
end

------------------------------Buff-------------------------------

local tBuffCache = {}
function Table_GetBuff(dwBuffID, dwLevel)
	local szKey = dwBuffID.."_"..dwLevel
	if not tBuffCache[szKey] then
		tBuffCache[szKey] = g_tTable.Buff:Search(dwBuffID, dwLevel)
	end
	local tBuff = tBuffCache[szKey]
	
	if not tBuff then
		dwLevel = 0
		tBuff = g_tTable.Buff:Search(dwBuffID, dwLevel)
	end
	
	return tBuff
end

function Table_GetBuffIconID(dwBuffID, dwLevel)
	local nIconID = -1
	
	local tBuff = Table_GetBuff(dwBuffID, dwLevel)
	
	if tBuff then
		nIconID = tBuff.dwIconID
	end
	
	return nIconID
end

function Table_GetBuffName(dwBuffID, dwLevel)
	local szName = ""
	
	local tBuff = Table_GetBuff(dwBuffID, dwLevel)
	
	if tBuff then
		szName = tBuff.szName
	end
	
	return szName
end

function Table_GetBuffDesc(dwBuffID, dwLevel)
	local szDesc = ""
	
	local tBuff = Table_GetBuff(dwBuffID, dwLevel)
	
	if tBuff then
		szDesc = tBuff.szDesc
	end
	
	return szDesc
end

function Table_BuffNeedSparking(dwBuffID, dwLevel)
	local bSparking = false
	
	local tBuff = Table_GetBuff(dwBuffID, dwLevel)
	
	if tBuff and tBuff.bSparking ~= 0 then
		bSparking = true
	end
	
	return bSparking
end

function Table_BuffNeedShowTime(dwBuffID, dwLevel)
	local bShowTime = false
	
	local tBuff = Table_GetBuff(dwBuffID, dwLevel)
	
	if tBuff and tBuff.bShowTime ~= 0 then
		bShowTime = true
	end
	
	return bShowTime
end

function Table_BuffNeedShow(dwBuffID, dwLevel)
	local bShow = false
	 
	local tBuff = Table_GetBuff(dwBuffID, dwLevel)
	
	if tBuff then
		bShow = true
	end
	
	return bShow
end

function Table_BuffIsVisible(dwBuffID, dwLevel)
	local bShow = false
	local tBuff = Table_GetBuff(dwBuffID, dwLevel)
	
	if tBuff and tBuff.bShow ~= 0 then
		bShow = true
	end
	return bShow
end

-------------------------BattleField---------------------------------------

function Table_IsBattleFieldMap(dwMapID)
	local bBattleFieldMap = false
	
	local tMap = g_tTable.BattleField:Search(dwMapID)
	
	if tMap then
		bBattleFieldMap = true
	end
	
	return bBattleFieldMap
end

function Table_GetBattleFieldName(dwMapID)
	local tMap = g_tTable.BattleField:Search(dwMapID)
	assert(tMap)
	
	return tMap.szName
end


function Table_GetBattleFieldDesc(dwMapID)
	local tMap = g_tTable.BattleField:Search(dwMapID)
	assert(tMap)
	
	return tMap.szDesc
end

function Table_GetBattleFieldGroupInfo(dwMapID)
	local tMap = g_tTable.BattleField:Search(dwMapID)
	assert(tMap)
	
	local tGroupInfo = {}
	for i = 1, BATTLE_FIELD_GROUP_COUNT do
		table.insert(tGroupInfo, tMap["szGroup" .. i])
	end
	
	return tGroupInfo
end

function Table_GetBattleFieldPQOptionInfo(dwMapID)
	local tMap = g_tTable.BattleField:Search(dwMapID)
	assert(tMap)
	
	local tPQOptionInfo = {}
	for i = 1, BATTLE_FIELD_PQOPTIONICON_COUNT do
		tPQOptionInfo["szPQOptionName" .. i] = tMap["szPQOptionName" .. i]
		tPQOptionInfo["nPQOptionIcon" .. i] = tMap["nPQOptionIcon" .. i]
	end
	
	return tPQOptionInfo
end

function Table_GetBattleFieldRewardIconInfo(dwMapID)
	local tMap = g_tTable.BattleField:Search(dwMapID)
	assert(tMap)
	
	return tMap.nRewardIcon1, tMap.nRewardIcon2, tMap.nRewardIcon3, tMap.nRewardIcon4
end


function Table_GetBattleFieldHelpInfo(dwMapID)
	local tMap = g_tTable.BattleField:Search(dwMapID)
	assert(tMap)
	
	return tMap.szHelpImagePath, tMap.szHelpText
end

-----------------------------Quest-------------------------------
local function ParseNumberList(szNumberList)	-- 23,544;234,345,342,334;
	local tNumberList = {}
	for szData in string.gmatch(szNumberList, "([%d,]+);?") do
		local tNumber = {}
		for szNumber in string.gmatch(szData, "(%d+),?") do
			table.insert(tNumber, tonumber(szNumber))
		end
		table.insert(tNumberList, tNumber)
	end
	return tNumberList
end

local function GetQuestPoint(szPointList)
	local tPointList = {}
	for szType, szData in string.gmatch(szPointList, "<(%a) ([%d,;|]+)>") do
		local szFrame, szSource = string.match(szData, "([%d]+)|([%d,;]+)")
		local nFrame
		if szFrame and szFrame ~= "" and szSource and szSource ~= "" then
			szData = szSource
			nFrame = tonumber(szFrame)
		end
		if szType == "N" or szType == "D" then	-- npc
			local tData = ParseNumberList(szData)
			for _, tInfo in ipairs(tData) do
				local dwMapID = tInfo[1]
				local dwObject = tInfo[2]
				local tQuestPos = nil
				if szType == "N" then
					tQuestPos = g_tTable.QuestNpc:Search(dwObject, dwMapID)
				else
					tQuestPos = g_tTable.QuestDoodad:Search(dwObject, dwMapID)
				end
				if tQuestPos and tQuestPos.szPositions ~= "" then
					if not tPointList[dwMapID] then
						tPointList[dwMapID] = {}
					end
					local tPosList = ParseNumberList(tQuestPos.szPositions)
					for _, tPosition in ipairs(tPosList) do
						table.insert(tPointList[dwMapID], {tPosition[1], tPosition[2], szType, dwObject, nFrame})			
					end
				end
			end
		elseif szType == "P" then	-- postion
			local tData = ParseNumberList(szData)
			for _, tPosition in ipairs(tData) do
				local dwMapID = tPosition[1]
				if not tPointList[dwMapID] then
					tPointList[dwMapID] = {}
				end
				table.insert(tPointList[dwMapID], {tPosition[2], tPosition[3], szType, nil, nFrame})
			end
		else
			Log("[UI DEBUG] Error Quest Point Type: " .. tostring(szType))
		end
	end
	return tPointList
end

function Table_GetQuestPosInfo(dwQuestID, szType, nIndex)
	local tQuestPosInfo = g_tTable.Quest:Search(dwQuestID)
	if not tQuestPosInfo then
		return
	end
	
	local szQuestPos = nil
	if szType == "accept" then
		szQuestPos = tQuestPosInfo.szAccept
	elseif szType == "finish" then
		szQuestPos = tQuestPosInfo.szFinish
	elseif szType == "quest_state" then
		szQuestPos = tQuestPosInfo["szQuestState" .. nIndex + 1]
	elseif szType == "kill_npc" then
		szQuestPos = tQuestPosInfo["szKillNpc" .. nIndex + 1]
	elseif szType == "need_item" then
		szQuestPos = tQuestPosInfo["szNeedItem" .. nIndex + 1]
	end
	
	if szQuestPos == "" then
		szQuestPos = nil
	end
	
	return szQuestPos
end

function Table_GetQuestPoint(dwQuestID, szType, nIndex)
	local szPosInfo = Table_GetQuestPosInfo(dwQuestID, szType, nIndex)
	if not szPosInfo then
		return
	end
	return GetQuestPoint(szPosInfo)
end

local function IsQuestNameShield(szName)
	for _, szShield in ipairs(g_tStrings.tQuestShieldName) do
		if szName == szShield then
			return true
		end
	end
	return false
end

function Table_GetAllSceneQuest(dwMapID)
	local tSceneQuest = {}
	if tAllSceneQuest[dwMapID] then
		tSceneQuest = tAllSceneQuest[dwMapID]
	end
	
	return tSceneQuest
end

function Table_LoadSceneQuest()
	local nRow = g_tTable.Quest:GetRowCount()
	
	-- Row 1 for default Row
	for i = 2, nRow  do
		local tQuestPosInfo = g_tTable.Quest:GetRow(i)
		dwQuestID = tQuestPosInfo.dwQuestID
		local tQuestStringInfo = Table_GetQuestStringInfo(dwQuestID)
		if tQuestStringInfo then
			local tShield = g_tTable.ShieldQuest:Search(dwQuestID)
			local bQuestNameShield = IsQuestNameShield(tQuestStringInfo.szName)
			if not bQuestNameShield and not tShield then
				
				local szPosInfo = tQuestPosInfo.szAccept
				for szType, szData in string.gmatch(szPosInfo, "<(%a) ([%d,;|]+)>") do
					local szFrame, szSource = string.match(szData, "([%d]+)|([%d,;]+)")
					local nFrame
					if szFrame and szFrame ~= "" and szSource and szSource ~= "" then
						szData = szSource
						nFrame = tonumber(szFrame)
					end
					if szType == "N" or szType == "D" then	-- npc
						local tData = ParseNumberList(szData)
						for _, tInfo in ipairs(tData) do
							local dwQuestMapID = tInfo[1]
							local dwObject = tInfo[2]
							if not tAllSceneQuest[dwQuestMapID] then
								tAllSceneQuest[dwQuestMapID] = {}
							end
							if not tAllSceneQuest[dwQuestMapID][dwQuestID] then
								tAllSceneQuest[dwQuestMapID][dwQuestID] = {}
							end
							table.insert(tAllSceneQuest[dwQuestMapID][dwQuestID], {szType, dwObject})
						end
					end
				end
			end
		end
	end
end
-----------------------------Book--------------------------
function Table_GetBookSort(dwBookID, dwSegmentID)
	local nSort = -1
	
	local tBookSegment = g_tTable.BookSegment:Search(dwBookID, dwSegmentID)
	if tBookSegment then
		nSort = tBookSegment.nSort
	end
	
	return nSort
end

function Table_GetBookSubSort(dwBookID, dwSegmentID)
	local nSubSort = -1
	
	local tBookSegment = g_tTable.BookSegment:Search(dwBookID, dwSegmentID)
	if tBookSegment then
		nSubSort = tBookSegment.nSubSort
	end
	
	return nSubSort
end

function Table_GetBookMark(dwBookID, dwSegmentID)
	local nType = -1
	
	local tBookSegment = g_tTable.BookSegment:Search(dwBookID, dwSegmentID)
	if tBookSegment then
		nType = tBookSegment.nType
	end
	
	return nType
end

function Table_GetBookPageNumber(dwBookID, dwSegmentID)
	local dwPageCount = 0
	
	local tBookSegment = g_tTable.BookSegment:Search(dwBookID, dwSegmentID)
	if tBookSegment then
		dwPageCount = tBookSegment.dwPageCount
	end
	
	return dwPageCount
end


function Table_GetBookPageID(dwBookID, dwSegmentID, nPageIndex)
	local nPageID = -1
	
	local tBookSegment = g_tTable.BookSegment:Search(dwBookID, dwSegmentID)
	if tBookSegment then
		nPageID = tBookSegment["dwPageID_"..nPageIndex]
	end
	
	return nPageID
end

function Table_GetBookName(dwBookID, dwSegmentID)
	local szBookName = ""
	
	local tBookSegment = g_tTable.BookSegment:Search(dwBookID, dwSegmentID)
	if tBookSegment then
		szBookName = tBookSegment.szBookName
	end
	
	return szBookName
end

function Table_GetSegmentName(dwBookID, dwSegmentID)
	local szSegmentName = ""
	
	local tBookSegment = g_tTable.BookSegment:Search(dwBookID, dwSegmentID)
	if tBookSegment then
		szSegmentName = tBookSegment.szSegmentName
	end
	
	return szSegmentName
end

function Table_GetBookDesc(dwBookID, dwSegmentID)
	local szDesc = ""
	
	local tBookSegment = g_tTable.BookSegment:Search(dwBookID, dwSegmentID)
	if tBookSegment then
		szDesc = tBookSegment.szDesc
	end
	
	return szDesc
end

function Table_GetBookItemIndex(dwBookID, dwSegmentID)
	local dwBookItemIndex = 0
	
	local tBookSegment = g_tTable.BookSegment:Search(dwBookID, dwSegmentID)
	if tBookSegment then
		dwBookItemIndex = tBookSegment.dwBookItemIndex
	end
	
	return dwBookItemIndex
end

function Table_GetBookNumber(dwBookID, dwSegmentID)
	local dwBookNumber = 0
	
	local tBookSegment = g_tTable.BookSegment:Search(dwBookID, dwSegmentID)
	if tBookSegment then
		dwBookNumber = tBookSegment.dwBookNumber
	end
	
	return dwBookNumber
end

function Table_GetBookContent(dwPageID)
	local szContent = ""
	
	local tBookPage = g_tTable.BookPage:Search(dwPageID)
	if tBookPage then
		szContent = tBookPage.szContent
	end
	
	return szContent
end

------------------------------craft------------------------

function Table_GetCraftIconID(dwProfessionID, dwCraftID)
	local dwIconID = -1
	
	local tCraft = g_tTable.Craft:Search(dwProfessionID, dwCraftID)
	if tCraft then
		dwIconID = tCraft.dwIconID
	end
	
	return dwIconID
end

function Table_GetCraftDesc(dwProfessionID, dwCraftID)
	local szDesc = ""
	
	local tCraft = g_tTable.Craft:Search(dwProfessionID, dwCraftID)
	if tCraft then
		szDesc = tCraft.szDesc
	end
	
	return szDesc
end

function Table_GetEnchantIconID(dwProfessionID, dwCraftID, dwRecipeID)
	local dwIconID = -1
	
	local tCraft = g_tTable.CraftEnchant:Search(dwProfessionID, dwCraftID, dwRecipeID)
	if tCraft then
		dwIconID = tCraft.dwIconID
	end
	
	return dwIconID
end

function Table_GetEnchantQuality(dwProfessionID, dwCraftID, dwRecipeID)
	local nQuality = -1
	
	local tCraft = g_tTable.CraftEnchant:Search(dwProfessionID, dwCraftID, dwRecipeID)
	if tCraft then
		nQuality = tCraft.nQuality
	end
	
	return nQuality
end

function Table_GetEnchantName(dwProfessionID, dwCraftID, dwRecipeID)
	local szName = ""
	
	local tCraft = g_tTable.CraftEnchant:Search(dwProfessionID, dwCraftID, dwRecipeID)
	if tCraft then
		szName = tCraft.szName
	end
	return szName
end

function Table_GetEnchantDesc(dwProfessionID, dwCraftID, dwRecipeID)
	local szDesc = ""
	
	local tCraft = g_tTable.CraftEnchant:Search(dwProfessionID, dwCraftID, dwRecipeID)
	if tCraft then
		szDesc = tCraft.szDesc
	end
	return szDesc
end

function Table_GetCraftBelongName(dwProfessionID, dwBelongID)
	local szBelongName = ""
	
	local tCraft = g_tTable.CraftBelongName:Search(dwProfessionID, dwBelongID)
	if tCraft then
		szBelongName = tCraft.szBelongName
	end
	
	return szBelongName
end

-----------------------------------------------------------------
function GetAttributeIndex()
	if not tLoadedTable.tAttributeIndex then
		tLoadedTable.tAttributeIndex = {}
		local nCount = g_tTable.Attribute:GetRowCount()
		
		for i = 1, nCount do
			local tAttribute = g_tTable.Attribute:GetRow(i)
			local nID = AttributeStringToID(tAttribute.szAttributeName)
			tLoadedTable.tAttributeIndex[nID] = i
		end
	end
	
	return tLoadedTable.tAttributeIndex
end

function GetRequireIndex()
	if not tLoadedTable.tRequireIndex then
		tLoadedTable.tRequireIndex = {}
		local nCount = g_tTable.Require:GetRowCount()
		
		for i = 1, nCount do
			local tRequire = g_tTable.Require:GetRow(i)
			local nID = RequireStringToID(tRequire.szRequireName)
			tLoadedTable.tRequireIndex[nID] = i
		end
	end
	
	return tLoadedTable.tRequireIndex
end

function GetAttribute(nAttributeID)
	local tAttributeIndex = GetAttributeIndex()
	local tAttribute = nil
	local nIndex = tAttributeIndex[nAttributeID]
	if nIndex then
		tAttribute = g_tTable.Attribute:GetRow(nIndex)
	end

	return tAttribute
end

function GetRequire(nRequireID)
	local tRequireIndex = GetRequireIndex()
	local tRequire = nil
	
	local nIndex = tRequireIndex[nRequireID]
	if nIndex then
		tRequire = g_tTable.Require:GetRow(nIndex)
	end
	
	return tRequire
end

function Table_GetBaseAttributeInfo(nID, bExist)
	local szBase = ""
	local tAttribute = GetAttribute(nID)
	if tAttribute then
		if bExist then
			szBase = tAttribute.szGeneratedBase
		else
			szBase = tAttribute.szPreviewBase
		end
	end
	
	return szBase
end

function Table_GetRequireAttributeInfo(nID, bExist)
	local szRequire = ""
	local tRequire = GetRequire(nID)
	if tRequire then
		if bExist then
			szRequire = tRequire.szGeneratedRequire
		else
			szRequire = tRequire.szPreviewRequire
		end
	end
	
	return szRequire
end


function Table_GetMagicAttributeInfo(nID, bExist)
	local szMagic = ""
	local tAttribute = GetAttribute(nID)
	if tAttribute then
		if bExist then
			szMagic = tAttribute.szGeneratedMagic
		else
			szMagic = tAttribute.szPreviewMagic
		end
	end
	
	return szMagic
end


-----------------------------QuestSuggest, CopySuggest, BattleFieldSuggest----------------------------------------------

function Table_GetQuestSuggest(nLevel, dwForceID)
	local tSuggestQuest = {}
	
	local tSuggest = g_tTable.SuggestQuest:Search(nLevel, dwForceID)
	if tSuggest then
		for i = 1, SUGGEST_QUEST_AREA_COUNT do
			if tSuggest["dwMapID" .. i] > 0 then
				local tArea = {}
				tArea.dwMapID = tSuggest["dwMapID" .. i]
				tArea.dwAreaID = tSuggest["dwAreaID" .. i]
				tArea.szAreaName = tSuggest["szAreaName" .. i]
				table.insert(tSuggestQuest, tArea)
			end
		end
	end
	
	if dwForceID ~= 0 then 
		dwForceID = 0
		tSuggest = g_tTable.SuggestQuest:Search(nLevel, dwForceID)
		if tSuggest then
			for i = 1, SUGGEST_QUEST_AREA_COUNT do
				if tSuggest["dwMapID" .. i] > 0 then
					local tArea = {}
					tArea.dwMapID = tSuggest["dwMapID" .. i]
					tArea.dwAreaID = tSuggest["dwAreaID" .. i]
					table.insert(tSuggestQuest, tArea)
				end
			end
		end
	end
	
	return tSuggestQuest
end

function Table_GetSuggestMap(dwForceID, nStartLevel, nEndLevel)
	local tMark = {}
	local tMap = {}
	
	for i = nStartLevel, nEndLevel do
		local tSuggestArea = Table_GetQuestSuggest(i, dwForceID)
		for _, tArea in ipairs(tSuggestArea) do
			if not tMark[tArea.dwMapID] then
				table.insert(tMap, tArea)
				tMark[tArea.dwMapID] = true
			end
		end
	end
	return tMap
end

function Table_GetCopyMap(nStartLevel, nEndLevel)
	local tMark = {}
	local tMap = {}
	
	for i = nStartLevel, nEndLevel do
		local tSuggestCopy = Table_GetCopySuggest(i)
		for _, dwMapID in ipairs(tSuggestCopy) do
			if not tMark[dwMapID] then
				table.insert(tMap, dwMapID)
				tMark[dwMapID] = true
			end
		end
	end
	return tMap
end

function Table_GetCopySuggest(nLevel)
	local tSuggestCopy = {}
	local tSuggest = g_tTable.SuggestCopy:Search(nLevel)
	if tSuggest then
		for i = 1, SUGGEST_COPY_COUNT do
			if tSuggest["dwID" .. i] > 0 then
				table.insert(tSuggestCopy, tSuggest["dwID" .. i])
			end
		end
	end
	
	return tSuggestCopy
end

function Table_GetBattleFieldSuggest(nLevel)
	local tSuggestBattleField = {}
	local tSuggest = g_tTable.SuggestBattlefield:Search(nLevel)
	if tSuggest then
		for i = 1, SUGGEST_BATTLE_FIELD_COUNT do
			if tSuggest["dwID" .. i] > 0 then
				table.insert(tSuggestBattleField, tSuggest["dwID" .. i])
			end
		end
	end
	
	return tSuggestBattleField
end

----------------------------------------------------------------------
function Table_GetDoodadTemplateName(dwTemplateID)
	local szName = ""
	local tDoodad = g_tTable.DoodadTemplate:Search(dwTemplateID)
	if tDoodad then
		szName = tDoodad.szName
	end
	
	return szName
end

function Table_GetDoodadTemplateBarText(dwTemplateID)
	local szBarText = ""
	local tDoodad = g_tTable.DoodadTemplate:Search(dwTemplateID)
	if tDoodad then
		szBarText = tDoodad.szBarText
	end
	
	return szBarText
end

function Table_GetNpcTemplateName(dwTemplateID)
	local szName = ""
	local tNpc = g_tTable.NpcTemplate:Search(dwTemplateID)
	if tNpc then
		szName = tNpc.szName
	end
	
	return szName
end

function Table_GetDoodadName(dwTemplateID, dwNpcTemplateID)
	local szName = ""
	if dwNpcTemplateID ~= 0 then
		szName = Table_GetNpcTemplateName(dwNpcTemplateID)
	else
		szName = Table_GetDoodadTemplateName(dwTemplateID)
	end
	
	return szName
end

function Table_GetMapName(dwMapID)
	local szName = ""
	local tMap = g_tTable.MapList:Search(dwMapID)
	if tMap then
		szName = tMap.szName
	end
	
	return szName
end

function Table_GetMiddleMap(dwMapID)
	local szMap0, szMap1 = "", ""
	local tMap = g_tTable.MapList:Search(dwMapID)
	if tMap then
		szMap0, szMap1 = tMap.szMiddleMap0, tMap.szMiddleMap1
	end
	
	return szMap0, szMap1
end

function Table_GetMapTip(dwMapID)
	local szTip = ""
	local tMap = g_tTable.MapList:Search(dwMapID)
	if tMap then
		szTip = tMap.szTip
	end
	
	return szTip
end

function Table_GetMapGroupID(dwMapID)
	local tMap = g_tTable.MapList:Search(dwMapID)
    if not tMap then
        return
    end
	
	return tMap.nGroup
end
---------------------------以下是帮助相关的所有内容--------------------------------------
----------------------CareerComment---------------------------
function Tagle_IsExitCareerEvent(nLevel)
	local bExit = false
	local tEvent = g_tTable.CareerEvent:Search(nLevel)
	if tEvent then
		bExit = true
	end
	return bExit
end

local function ParseCareerEventTab(szTab)
    local tTab = {}
    for szTabID in string.gmatch(szTab, "([%d]+);?") do
        local nTabID = tonumber(szTabID)
        table.insert(tTab, nTabID)
    end
    return tTab
end

function Table_GetCareerEvent(nLevel)
	local tCareerEvent = {}
	local tEvent = g_tTable.CareerEvent:Search(nLevel)
	tCareerEvent.nLevel = nLevel
	tCareerEvent.szTitle = tEvent.szTitle
	tCareerEvent.tTab = ParseCareerEventTab(tEvent.szTab)
    
	return tCareerEvent
end

function Table_GetCareerInfo(nLevel)
	local tInfo = {}
	local tEvent = g_tTable.CareerEvent:Search(nLevel)
    
	if tEvent then
        local tTabs = ParseCareerEventTab(tEvent.szTab)
		tInfo.szIntroduction = tEvent.szIntroduction
		local tTabInfo = Table_GetCareerTab(tTabs[1])
		tInfo.szImage = tTabInfo.tContent[1].szImage  --江湖指南历程分页里的图用的是历程提示界面首页的图
	end
	
	return tInfo
end

function Table_GetCareerAllEventTitle()
	local tCareer = {}
	local nCount = g_tTable.CareerEvent:GetRowCount()
	
	--Row One for default value
	for i = 2, nCount do
		local tEvent = g_tTable.CareerEvent:GetRow(i)
		local tTitle = {["szName"] = tEvent.szName, ["nLevel"] = tEvent.nLevel}
		table.insert(tCareer, tTitle)
	end
	
	return tCareer
end

function Table_GetCareerMap(nLevel)
	local tCareerMap = {}
	local tEvent = g_tTable.CareerEvent:Search(nLevel)
	if tEvent then		
		for i = 1, CAREER_MAP_LIMIT_COUNT do
			if tEvent["nMapID" .. i] >= 0 then
				table.insert(tCareerMap, tEvent["nMapID" .. i])
			end
		end
	end
	return tCareerMap
end

function Table_GetCareerTab(nTabID)
	local tCareerTab = {}
	local tTab = g_tTable.CareerTab:Search(nTabID)
	
	if tTab then
		tCareerTab.nTabID = nTabID
		tCareerTab.szName = tTab.szName
		tCareerTab.szTitle = tTab.szTitle
		tCareerTab.szDescription = tTab.szDescription
		tCareerTab.tContent = {}
		
		for i = 1, CAREER_IMAGE_COUNT do
			local tCon = {}
			tCon.szImage = tTab["szImage" .. i]
			tCon.szNote = tTab["szNote" .. i]
			if tCon.szImage ~= "" then
				table.insert(tCareerTab.tContent, tCon)
			end
		end	
	end
	return tCareerTab
end

function Table_GetCareerTabTitle(nTabID)
	local szTitle = ""
	local tTab = g_tTable.CareerTab:Search(nTabID)
	
	if tTab then
		szTitle = tTab.szTitle
	end
	
	return szTitle
end

function Table_GetCareerTabName(nTabID)
	local szName = ""
	local tTab = g_tTable.CareerTab:Search(nTabID)
	
	if tTab then
		szName = tTab.szName
	end
	
	return szName
end

function Table_GetCareerLinkNpcInfo(nLinkID, dwMapID)
	local dwNpcID = nil
	
	local tLink = nil
	if dwMapID then
		tLink = g_tTable.CareerGuide:Search(nLinkID, dwMapID)
	else
		tLink = g_tTable.CareerGuide:Search(nLinkID)
	end
	
	return tLink
end

function Table_GetLinkCount()
	local nCount = g_tTable.CareerGuide:GetRowCount()
	local tCount = {}
	local tDefaultMap = {}
	
	--Row One for default value
	for i = 2, nCount do
		tLink = g_tTable.CareerGuide:GetRow(i)
		if not tCount[tLink.nLinkID] then
			tCount[tLink.nLinkID] = 0
		end
		tCount[tLink.nLinkID] = tCount[tLink.nLinkID] + 1
		if not tDefaultMap[tLink.nLinkID] then
			tDefaultMap[tLink.nLinkID] = tLink.dwMapID
		end
	end
	return tCount, tDefaultMap
end

function Table_GetCurrentCareer(nLevel)
	local tCareer
	local nCount = g_tTable.CareerEvent:GetRowCount()
	for i = nCount, 2 , -1 do
		local tEvent = g_tTable.CareerEvent:GetRow(i)
		if tEvent.nLevel <= nLevel then
			tCareer = tEvent
			break
		end
	end

	return tCareer
end


-------------------------JX3知道-----------------------------------

function Table_GetJX3LibraryList()
	local nCount = g_tTable.JX3Library:GetRowCount()
	local tJX3Library = {}
	
	-- Row 1 for default
	local tClass
	local tSubClass
	for i = 2, nCount do
		local tLine = g_tTable.JX3Library:GetRow(i)
		
		local dwClassID = tLine.dwClassID
		local dwSubClassID = tLine.dwSubClassID
		local dwID = tLine.dwID
		
		local tRecord = {}
		tRecord.tInfo = {}
		tRecord.tInfo.dwClassID = dwClassID
		tRecord.tInfo.dwSubClassID = dwSubClassID
		tRecord.tInfo.dwID = dwID
		tRecord.tList = {}
		if dwSubClassID == 0 and dwID == 0 then
			tRecord.tInfo.szName = tLine.szClassName
			
			tClass = tRecord
			table.insert(tJX3Library, tRecord)
		elseif dwID == 0 then
			tRecord.tInfo.szName = tLine.szSubClassName
			
			tSubClass = tRecord
			table.insert(tClass.tList, tRecord)
		else
			
			tRecord.tInfo.szName = tLine.szTitle
			
			table.insert(tSubClass.tList, tRecord)
		end  
	end
	
	return tJX3Library
end

function Table_GetJX3LibraryContent(dwClassID, dwSubClassID, dwID)	
	local tRecord = g_tTable.JX3Library:Search(dwClassID, dwSubClassID, dwID)
	return tRecord
end

----------------------------------活动--------------------------------------
function Table_GetActivityList()
	local nCount = g_tTable.ActivityInfo:GetRowCount()
	
	local tActivity = {}
	
	-- Row 1 for default
	for i = 2, nCount do
		local tLine = g_tTable.ActivityInfo:GetRow(i)
		if not tActivity.tInfo then
			tActivity.tInfo = {}
			tActivity.tInfo.szName = tLine.szClassName
			tActivity.tInfo.dwClassID = tLine.dwClassID
			tActivity.tInfo.dwID = tLine.dwActivityID
			tActivity.tInfo.bActivity = true
			tActivity.tList = {}
		elseif not tActivity.tList[tLine.dwClassID] then
			tActivity.tList[tLine.dwClassID] = {}
			local tClass = tActivity.tList[tLine.dwClassID]
			tClass.tInfo = {}
			tClass.tInfo.szName = tLine.szClassName
			tClass.tInfo.dwClassID = tLine.dwClassID
			tClass.tInfo.dwID = tLine.dwActivityID
			tClass.tInfo.bActivity = true
			tClass.tList = {}
		else
			tActivity.tList[tLine.dwClassID].tList[tLine.dwActivityID] = {}
			tRecord = tActivity.tList[tLine.dwClassID].tList[tLine.dwActivityID]
			tRecord.tInfo = {}
			tRecord.tInfo.szName = tLine.szTitle
			tRecord.tInfo.dwClassID = tLine.dwClassID
			tRecord.tInfo.dwID = tLine.dwActivityID
			tRecord.tInfo.bActivity = true
			tRecord.tList = {}
		end
	end
	
	return tActivity
end

function Table_GetActivityContent(dwClassID, dwActivityID)
	local tRecord = g_tTable.ActivityInfo:Search(dwClassID, dwActivityID)
	return tRecord
end

--------------------日常任务---------------------------------------
function Table_GetDailyQuestList()
	local nCount = g_tTable.DailyQuestInfo:GetRowCount()
	
	local tQuest = {}
	-- Row 1 for default
	for i = 2, nCount do
		local tLine = g_tTable.DailyQuestInfo:GetRow(i)
		local dwClassID = tLine.dwTypeID
		local dwID = tLine.dwQuestID
		if not tQuest.tInfo then
			tQuest.tInfo = {}
			tQuest.tInfo.szName = tLine.szTypeName 
			tQuest.tInfo.dwClassID = dwClassID
			tQuest.tInfo.dwID = dwID
			tQuest.tInfo.bDailyQuest = true
			tQuest.tList = {}
		elseif not tQuest.tList[dwClassID] then
			tQuest.tList[dwClassID] = {}
			local tClass = tQuest.tList[dwClassID]
			tClass.tInfo = {}
			tClass.tInfo.dwClassID = dwClassID
			tClass.tInfo.dwID = dwID
			tClass.tInfo.szName = tLine.szTypeName
			tClass.tInfo.bDailyQuest = true
			tClass.tList = {}
		else
			tQuest.tList[dwClassID].tList[dwID] = {}
			local tRecord = tQuest.tList[dwClassID].tList[dwID]
			tRecord.tInfo = {}
			tRecord.tInfo.dwClassID = dwClassID
			tRecord.tInfo.dwID = dwID
			local tQuestStringInfo = Table_GetQuestStringInfo(dwID)
			tRecord.tInfo.szName = tQuestStringInfo.szName
			
			tRecord.tInfo.bDailyQuest = true
			tRecord.tList = {}
		end
	end
	
	return tQuest
end 

function Table_GetDailyQuestContent(dwTypeID, dwQuestID)
	local tRecord = g_tTable.DailyQuestInfo:Search(dwTypeID, dwQuestID)
	return tRecord
end

------------------------副本介绍---------------------------------
function Table_GetDungeonList()
	local tDungeon = {}
	
	local nCount = g_tTable.DungeonClass:GetRowCount()
	
	-- this tab file has no default row
	for i = 1, nCount do
		local tLine = g_tTable.DungeonClass:GetRow(i)
		if not tDungeon.tInfo then
			tDungeon.tInfo = {}
			tDungeon.tInfo.dwClassID = tLine.dwClassID
			tDungeon.tInfo.szName = tLine.szClassName
			tDungeon.tInfo.bDungeon = true
			tDungeon.tList = {}
		else
			tDungeon.tList[tLine.dwClassID] = {}
			local tClass = tDungeon.tList[tLine.dwClassID]
			tClass.tInfo = {}
			tClass.tInfo.dwClassID = tLine.dwClassID
			tClass.tInfo.szName = tLine.szClassName
			tClass.tInfo.bDungeon = true
			tClass.tList =  {}
		end
	end
	
	nCount = g_tTable.DungeonInfo:GetRowCount()
	
	--row 1 for default
	for i = 2, nCount do
		local tLine = g_tTable.DungeonInfo:GetRow(i)
		tDungeon.tList[tLine.dwClassID].tList[tLine.dwMapID] = {}
		local tRecord = tDungeon.tList[tLine.dwClassID].tList[tLine.dwMapID]
		tRecord.tInfo = {}
		tRecord.tInfo.dwClassID = tLine.dwClassID
		tRecord.tInfo.dwID = tLine.dwMapID
		tRecord.tInfo.szName = Table_GetMapName(tLine.dwMapID)
		tRecord.tInfo.bDungeon = true
		tRecord.tList = {}
	end
	
	return tDungeon
end

function Table_GetDungeonClass(dwClassID)
	local tLine = g_tTable.DungeonClass:Search(dwClassID)
	
	return tLine
end

function Table_GetDungeonInfo(dwMapID)
	local tLine = g_tTable.DungeonInfo:Search(dwMapID)
	
	return tLine
end

-------------------------FAQ------------------------
function Table_GetFAQList()
	local tFAQ = {}
	
	local nCount = g_tTable.FAQ:GetRowCount()
	--row 1 for default
	for i = 3, nCount do
		local tLine = g_tTable.FAQ:GetRow(i)
		
		if not tFAQ[tLine.dwClassID] then
			tFAQ[tLine.dwClassID] = {}
		else
			table.insert(tFAQ[tLine.dwClassID], tLine.dwSubClassID)
		end
	end
	
	return tFAQ
end

function Table_GetFAQClassName(dwClassID)
	local szName = ""
	
	local tResult = g_tTable.FAQ:Search(dwClassID, 0)
	
	if tResult then
		szName = tResult.szClassName
	end
	
	return szName
end

function Table_GetFAQContent(dwClassID, dwSubClassID)
	local tResult = g_tTable.FAQ:Search(dwClassID, dwSubClassID)
	
	return tResult
end

----------------------------------------------------------------------------------------

function Table_GetQuestStringInfo(dwQuestID)
	local tQuestStringInfo = g_tTable.Quests:Search(dwQuestID)
	
	return tQuestStringInfo
end

function Table_GetQuestClass(dwClassID)
	local szClass = ""
	local tQuestClass = g_tTable.QuestClass:Search(dwClassID)
	
	if tQuestClass then
		szClass = tQuestClass.szClass
	end
	
	return szClass
end

function Table_GetSmartDialog(dwDialogID, szKey)
	local szDialog = ""
	local tDialog = g_tTable.SmartDialog:Search(dwDialogID)
	if szKey and szKey ~= "" and tDialog["sz" .. szKey] then
		szDialog = tDialog["sz" .. szKey]
	end
	
	return szDialog
end

function Table_GetProfessionName(dwProfessionID)
	local szName = ""
	local tProfession = g_tTable.ProfessionName:Search(dwProfessionID)
	if tProfession then
		szName = tProfession.szName
	end
	
	return szName
end

function Table_GetCraftName(dwCraftID)
	local szName = ""
	local tCraft = g_tTable.UICraft:Search(dwCraftID)
	if tCraft then
		szName = tCraft.szName
	end
	
	return szName
end

function Table_GetBranchName(dwProfessionID, dwBranchID)
	local szName = ""
	local tBranch = g_tTable.BranchName:Search(dwProfessionID, dwBranchID)
	if tBranch then
		szName = tBranch.szName
	end
	
	return szName
end

function Table_GetPath(szPathID)
	local nCount = g_tTable.PathList:GetRowCount()
	for i = 1, nCount do
		local tPath = g_tTable.PathList:GetRow(i)
		if tPath.szID == szPathID then
			return tPath.szPath
		end
	end
end

local function LoadGlobalStrings()
	ClearGlobalString()
	local nCount = g_tTable.GlobalStrings:GetRowCount()
	for i = 1, nCount do
		local tLine = g_tTable.GlobalStrings:GetRow(i)
		RegisterGlobalString(tLine.szID, tLine.szText)
	end
	g_tTable.GlobalStrings = nil
end

-----------------配方----------------------------------------------------------------

function Table_GetRecipeName(dwCraftID, dwRecipeID)
	local szName = ""
	
	---- 阅读和抄录用Table_GetBookName接口
	local tCraft = GetCraft(dwCraftID)
	if tCraft.CraftType == ALL_CRAFT_TYPE.COPY or tCraft.CraftType == ALL_CRAFT_TYPE.READ then
		local dwBookID, dwSegmentID = GlobelRecipeID2BookID(dwRecipeID)
		szName = Table_GetBookName(dwBookID, dwSegmentID)
	else
		local tCraft = g_tTable.UICraft:Search(dwCraftID)
		if tCraft.szPath ~= "" then	
			tTableFile["RecipeName"].Path = tCraft.szPath
			local tRecipe = g_tTable.RecipeName:Search(dwRecipeID)
			if tRecipe then
				szName = tRecipe.szName
			end
			g_tTable.RecipeName = nil
		else
			Trace("KLUA[ERROR] ui\Script\table.lua dwCraftID = " .. dwCraftID .. "dwRecipeID = ".. dwRecipeID .. " craft Path is nil!!\n")
		end
	end
	
	return szName
end

-------------表情图标--------------------------------------------------

function Table_GetFaceIconList()
	local tFaceIcon = {}
	local nCount = g_tTable.FaceIcon:GetRowCount()
	for i = 1, nCount do
		local tLine = g_tTable.FaceIcon:GetRow(i)
		table.insert(tFaceIcon, tLine)
	end
	return tFaceIcon
end

----------------货币界面------------------------
function Table_GetCurrencyList()
	local tCurrency = {}
	local nCount = g_tTable.Currency:GetRowCount()
	for i = 2, nCount do
		local tLine = g_tTable.Currency:GetRow(i)
		table.insert(tCurrency, tLine)
	end
	return tCurrency
end

----------------战阶排名TIP------------------------
function Table_GetTitleRankTip(dwRank)
	local szTip = ""
	local tTitleRank = g_tTable.TitleRank:Search(dwRank)
	if tTitleRank then
		szTip = tTitleRank.szTip
	end
	
	return szTip
end

function Table_GetNextTitleRankPoint(dwRank)
	local dwTitlePoint = 0
	local tTitleRank = g_tTable.TitleRank:Search(dwRank)
	if tTitleRank then
		dwTitlePoint = tTitleRank.dwTitlePoint
	end
	
	return dwTitlePoint
end



RegisterEvent("GAME_START", LoadGlobalStrings)
RegisterEvent("GAME_START", LoadSkillNameToIDMap)
RegisterEvent("SYNC_ROLE_DATA_END", CorrectSkillNameToIDMap)
RegisterEvent("SKILL_UPDATE", function() CorrectSkillNameToIDMap(arg0, arg1) end)


-----------------------------日历系统----------------------------------
function GetJoinLevel(szData)
	local tLevel = {}
	local nSortLevel
	for szLevel in string.gmatch(szData, "([%d~]+);?") do
		local szStart, szEnd = string.match(szLevel, "([%d]+)~([%d]+)")
		local nSrartLevel, nEndLevel
		if szStart and szEnd then 
			nSrartLevel = tonumber(szStart)
			nEndLevel = tonumber(szEnd)
			if not nSortLevel then
				nSortLevel = nSrartLevel
			end
		else
			nSrartLevel = tonumber(szLevel)
			nEndLevel = nSrartLevel
			if not nSortLevel then
				nSortLevel = nSrartLevel
			end
		end
		table.insert(tLevel, {nSrartLevel,nEndLevel})
	end
	return nSortLevel, tLevel -- 第一个等级段的最低等级作为排序依据
end

local function GetAwardContent(szAwardType)
	local szAward = ""
	local nFirstAward = -1
    local tAward = {}
    
    for szID, szPercentage in string.gmatch(szAwardType, "([%d]+):([%d]+);?") do
        local dwID = tonumber(szID)
        local nPercentage = tonumber(szPercentage)
        if nFirstAward < 0 then
            nFirstAward = dwID
        else
            szAward = szAward .. g_tStrings.STR_COMMA
        end
        local tLine = g_tTable.CalenderAward:Search(dwID)
        szAward = szAward .. tLine.szName
        tAward[dwID] = nPercentage
        bFirst = false
    end
    
	return nFirstAward, szAward, tAward
end

local function GetAdvancedTime(szAdvancedTime)
    local tAdvancedTime = {}
    for szTime in string.gmatch(szAdvancedTime, "([%d]+);?") do
        local nTime = tonumber(szTime)
        table.insert(tAdvancedTime, nTime)
    end
    return tAdvancedTime
end

function Table_ParseCalenderActivity(tActive)
	tActive.nSortLevel, tActive.tLevel = GetJoinLevel(tActive.szLevel)
	tActive.nSortAward, tActive.szAward, tActive.tAward = GetAwardContent(tActive.szAwardType)
	tActive.szClass = g_tStrings.tActiveClass[tActive.nClass]
	tActive.tAdvancedTime = GetAdvancedTime(tActive.szAdvancedTime)
	return tActive
end

function Table_GetCalenderOfDay(nYear, nMonth, nDay, nPosition)
	if not nPosition then
		nPosition = 1
	end
	local tDailyCalender = {}
	local nCount = g_tTable.CalenderActivity:GetRowCount()
	local nTime = DateToTime(nYear, nMonth, nDay, 7, 0, 0)
	for i = 2, nCount do -- row 1 for default
		local tLine = g_tTable.CalenderActivity:GetRow(i)
		if tLine.nEvent == 2 and BitwiseAnd(tLine.nShowPosition, nPosition) > 0 then
			tLine = Table_ParseCalenderActivity(tLine)
			tLine.nStartTime = nTime
			table.insert(tDailyCalender, tLine)
		end
	end
	local hCalendar = GetActivityMgrClient()
	local tActivityList = hCalendar.GetActivityOfDay(nYear, nMonth, nDay)
	for _, tActivity in ipairs(tActivityList) do
		local tLine = g_tTable.CalenderActivity:Search(tActivity.dwID)
		if BitwiseAnd(tLine.nShowPosition, nPosition) > 0 then
			tLine = Table_ParseCalenderActivity(tLine)
			tLine.nStartTime = tActivity.nStartTime
			tLine.nEndTime = tActivity.nEndTime
			table.insert(tDailyCalender, tLine)
		end
	end
	return tDailyCalender
end

function  Table_GetCalenderActivity(dwID)
	local tActive = g_tTable.CalenderActivity:Search(dwID)
	tActive = ParseCalenderActivity(tActive)
	
	return tActive
end

Table_LoadSceneQuest()

----------------------------Avatar-----------------------------
function Table_GetPlayerMiniAvatars()
	local tAvatar = {}
	local nCount = g_tTable.PlayerAvatar:GetRowCount()
	
	for i = 1, nCount do
		local tLine = g_tTable.PlayerAvatar:GetRow(i)
		local dwIndex = tLine.dwPlayerMiniAvatarID
		tAvatar[dwIndex] = {}
		tAvatar[dwIndex]["dwType"] = tLine.dwType
		tAvatar[dwIndex]["dwKindID"] = tLine.dwKindID
		tAvatar[dwIndex]["szFileName"] = tLine.szFileName
	end
	
	return tAvatar
end

function Table_GetPlayerMiniAvatarsFromType(dwType)
	local tAvatar = {}
	local nCount = g_tTable.PlayerAvatar:GetRowCount()
	local dwIndex = 1
	
	for i = 1, nCount do
		local tLine = g_tTable.PlayerAvatar:GetRow(i)
		if tLine.dwType == dwType then
			tAvatar[dwIndex] = {}
			tAvatar[dwIndex]["dwID"] = tLine.dwPlayerMiniAvatarID
			tAvatar[dwIndex]["dwKindID"] = tLine.dwKindID
			tAvatar[dwIndex]["szFileName"] = tLine.szFileName
			dwIndex = dwIndex + 1
		end
	end
	
	return tAvatar
end

function Table_GetPlayerMiniAvatarsFromKindID(dwKindID)
	local tAvatar = {}
	local nCount = g_tTable.PlayerAvatar:GetRowCount()
	local dwIndex = 1
	
	for i = 1, nCount do
		local tLine = g_tTable.PlayerAvatar:GetRow(i)
		if tLine.dwKindID == dwKindID then
			tAvatar[dwIndex] = {}
			tAvatar[dwIndex]["dwID"] = tLine.dwPlayerMiniAvatarID
			tAvatar[dwIndex]["dwType"] = tLine.dwType
			tAvatar[dwIndex]["szFileName"] = tLine.szFileName
			dwIndex = dwIndex + 1
		end
	end
	
	return tAvatar
end

function Table_GetPlayerMiniAvatarsFromTypeAndKindID(dwType, dwKindID)
	local tAvatar = {}
	local nCount = g_tTable.PlayerAvatar:GetRowCount()
	local dwIndex = 1
	
	for i = 1, nCount do
		local tLine = g_tTable.PlayerAvatar:GetRow(i)
		
		if tLine.dwKindID == dwKindID and tLine.dwType == dwType then
			tAvatar[dwIndex] = {}
			tAvatar[dwIndex]["dwID"] = tLine.dwPlayerMiniAvatarID
			tAvatar[dwIndex]["szFileName"] = tLine.szFileName
			dwIndex = dwIndex + 1
		end
	end
	
	return tAvatar
end

local tSchoolColor = 
{
	[0] = { R = 255, G = 255, B = 255 },
	[1] = { R = 255, G = 111, B = 83 },
	[2] = { R = 196, G = 152, B = 255 },
	[3] = { R = 89, G = 224, B = 232 },
	[4] = { R = 255, G = 129, B = 176 },
	[5] = { R = 255, G = 178, B = 95 },
	[6] = { R = 214, G = 249, B = 93 },
}

function Table_GetSchoolColor(dwSchoolID)
	if not tSchoolColor[dwSchoolID] then
		dwSchoolID = 0
	end
	return tSchoolColor[dwSchoolID].R, tSchoolColor[dwSchoolID].G, tSchoolColor[dwSchoolID].B
end

local tForceName = 
{
	[0] = "江湖",
	[1] = "少林",
	[2] = "万花",
	[3] = "天策",
	[4] = "纯阳",
	[5] = "七秀",
	[6] = "五毒",
	[8] = "藏剑",
}

function Table_GetForceImageName(dwForceID)
	if not tForceName[dwForceID] then
		dwForceID = 0
	end
	return tForceName[dwForceID]
end

-----------------宠物技能-----------

function Table_GetPetSkill(dwNpcTemplateID)
	local tPetSkill = g_tTable.PetSkill:Search(dwNpcTemplateID)
	if not tPetSkill then
		return
	end
	local tSkill = {}
	for i = 1, PET_SKILL_COUNT do 
		if tPetSkill["nSkillID" .. i] <= 0 then
			break
		end
		table.insert(tSkill, {tPetSkill["nSkillID" .. i], tPetSkill["nLevel" .. i]})
	end
	return tSkill
end

function Table_GetPetAvatar(dwNpcTemplateID)
	local tPet = g_tTable.PetSkill:Search(dwNpcTemplateID)
	if not tPet then
		return
	end
	return tPet.szAvatarPath
end

----------------------FieldPQ------------------------------
function Table_GetFieldPQ(dwPQTemplateID)
	local tFieldPQ = g_tTable.FieldPQ:Search(dwPQTemplateID)
	
	return tFieldPQ
end

function Table_GetFieldPQString(dwPQTemplateID, nStep)
	local tPQString = g_tTable.FieldPQSetp:Search(dwPQTemplateID, nStep)
	
	return tPQString
end

function Table_GetFieldPQList() 
	local tFieldPQ = {}
	
	local nCount = g_tTable.FieldPQ:GetRowCount()
	
	--row 1 for default
	for i = 2, nCount do
		local tLine = g_tTable.FieldPQ:GetRow(i)
		if not tFieldPQ.tInfo then
			tFieldPQ.tInfo = {}
			tFieldPQ.tInfo.dwClassID = tLine.dwPQTemplateID
			tFieldPQ.tInfo.szName = tLine.szName
			tFieldPQ.tInfo.bFieldPQ = true
			tFieldPQ.tList = {}
		else
			tFieldPQ.tList[tLine.dwPQTemplateID] = {}
			local tClass = tFieldPQ.tList[tLine.dwPQTemplateID]
			tClass.tInfo = {}
			tClass.tInfo.dwClassID = tLine.dwPQTemplateID
			tClass.tInfo.szName = tLine.szName
			tClass.tInfo.bFieldPQ = true
			tClass.tList =  {}
		end
	end
	
	nCount = g_tTable.FieldPQSetp:GetRowCount()
	
	--row 1 for default
	for i = 2, nCount do
		local tLine = g_tTable.FieldPQSetp:GetRow(i)
		tFieldPQ.tList[tLine.dwPQTemplateID].tList[tLine.nSetpID] = {}
		local tRecord = tFieldPQ.tList[tLine.dwPQTemplateID].tList[tLine.nSetpID]
		tRecord.tInfo = {}
		tRecord.tInfo.dwClassID = tLine.dwPQTemplateID
		tRecord.tInfo.dwID = tLine.nSetpID
		tRecord.tInfo.szName = tLine.szName
		tRecord.tInfo.bFieldPQ = true
		tRecord.tList = {}
	end
	
	return tFieldPQ
end

function Table_LoadSceneFieldPQ()
	local nCount = g_tTable.FieldPQ:GetRowCount()
	
	-- 第三行开始才是真正的PQ，第一行是默认值，第二行是对PQ的介绍
	for i = 3, nCount do
		local tLine = g_tTable.FieldPQ:GetRow(i)
		if not tAllSceneFieldPQ[tLine.dwMapID] then
			tAllSceneFieldPQ[tLine.dwMapID] = {}
		end
		table.insert(tAllSceneFieldPQ[tLine.dwMapID], tLine.dwPQTemplateID)
	end
end

function Table_GetSceneFieldPQ(dwMapID)
	local tSceneFieldPQ = {}
	if tAllSceneFieldPQ[dwMapID] then
		tSceneFieldPQ = tAllSceneFieldPQ[dwMapID]
	end
	
	return tSceneFieldPQ
end

Table_LoadSceneFieldPQ()

---------------------------------------------------------------------------
local function GetCyclopaediaSkills(szSkill)
	local tSkill = {}
	for nSkillID, nLevel in string.gmatch(szSkill, "([%d]+),([%d]+);?") do 
		table.insert(tSkill, {nSkillID, nLevel})
	end
	return tSkill
end
function Table_GetCyclopaediaSkill()
	local nCount = g_tTable.CyclopaediaSkill:GetRowCount()
	local tCyclopaediaSkill = {}
	--row 1 for default
	for i = 2, nCount do
		local tLine = g_tTable.CyclopaediaSkill:GetRow(i)
		if not tCyclopaediaSkill[tLine.nSectionID] then
			tCyclopaediaSkill[tLine.nSectionID] = {}
		end
		local tSkill = GetCyclopaediaSkills(tLine.szSkill)
		tCyclopaediaSkill[tLine.nSectionID][tLine.nForceID] = tSkill
	end
	return tCyclopaediaSkill
end


------------------------------------------------------
-------------------------------------天工树--------------------------------

function Table_GetTongTechTreeNodeInfo(nNodeID, nLevel)
	local tNode = g_tTable.TongTechTreeNode:Search(nNodeID, nLevel)
	
	return tNode
end

---------------------------------活动标记--------------------
local function GetSymbolList(szPosition)
	local tPointList = {}
	for nX, nY in string.gmatch(szPosition, "([%d]+),([%d]+);?") do 
		table.insert(tPointList, {nX, nY})
	end
	return tPointList
end

function Table_GetActivitySymbol(dwMapID, nSymbolID)
	local tLine = g_tTable.ActivitySymbolInfo:Search(dwMapID, nSymbolID)
	local tPointList = {}
	if tLine then
		tLine.tPointList = GetSymbolList(tLine.szPositions)
	end
	
	return tLine
end


---------------------------CG选择列表------------------
function Table_GetCGList()
	local nCount = g_tTable.CGList:GetRowCount()
	--row 1 for default
	local tList = {}
	for i = 2, nCount do
		local tLine = g_tTable.CGList:GetRow(i)
		tLine.bDisable = false
		if tLine.szCGPath == "" and tLine.szDowloadUrl == "" then
			tLine.bDisable = true
		end
		table.insert(tList, tLine)
	end
	
	return tList
end

------------------------帮会活动---------------------------------
function Table_GetTongActivityList()
	local nCount = g_tTable.TongActivity:GetRowCount()
	local tTongActivity = {}
	
	-- Row 1 for default
	local tClass
	local tSubClass
	for i = 2, nCount do
		local tLine = g_tTable.TongActivity:GetRow(i)
		
		local dwClassID = tLine.dwClassID
		local dwSubClassID = tLine.dwSubClassID
		local dwID = tLine.dwID
		
		local tRecord = {}
		tRecord.tInfo = {}
		tRecord.tInfo.dwClassID = dwClassID
		tRecord.tInfo.dwSubClassID = dwSubClassID
		tRecord.tInfo.dwID = dwID
		tRecord.tList = {}
		tRecord.tInfo.szName = tLine.szName
		if dwSubClassID == 0 and dwID == 0 then
			tClass = tRecord
			table.insert(tTongActivity, tRecord)
		elseif dwID == 0 then
			tSubClass = tRecord
			table.insert(tClass.tList, tRecord)
		else
			table.insert(tSubClass.tList, tRecord)
		end  
	end
	
	return tTongActivity
end

function Table_GetTongActivityContent(dwClassID, dwSubClassID, dwID)	
	local tRecord = g_tTable.TongActivity:Search(dwClassID, dwSubClassID, dwID)
	return tRecord
end

function Table_GetActiviyTipDesc(dwActivityID)
    local tLine = g_tTable.ActivityTip:Search(dwActivityID)
    if not tLine then
        Log("ActivityTip no tip dwActivityID " .. dwActivityID)
    end
    
    return tLine
end

function Table_GetActiviyTimeDesc(dwActivityID)
    local tLine = g_tTable.ActivityTip:Search(dwActivityID)
    if not tLine then
        Log("ActivityTip no tip dwActivityID " .. dwActivityID)
    end
    
    return tLine.szTimeDesc
end

-----------------机关技能-----------

local function ParsePuppetGroup(szGroup)
    local tGroup
    for szCount in string.gmatch(szGroup, "([%w]+);?") do
        local nCount = tonumber(szCount)
        if not tGroup then
            tGroup = {}
        end
        table.insert(tGroup, nCount)
    end
    return tGroup
end

function Table_GetPuppetSkill(dwNpcTemplateID)
	local tPuppetSkill = g_tTable.PuppetSkill:Search(dwNpcTemplateID)
	if not tPuppetSkill then
		return
	end
	local tSkill = {}
	for i = 1, PUPPET_SKILL_COUNT do 
		if tPuppetSkill["nSkillID" .. i] <= 0 then
			break
		end
		table.insert(tSkill, {tPuppetSkill["nSkillID" .. i], tPuppetSkill["nLevel" .. i]})
	end
    
    local tGroup = ParsePuppetGroup(tPuppetSkill.szGroup)
    if not tGroup then
        tGroup = {}
        table.insert(tGroup, #tSkill)
    end
	return tSkill, tGroup
end

function Table_GetPlayerAwardRemind()
    local tRemind = {}
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return tRemind
    end
    
    local nCount = g_tTable.AwardRemind:GetRowCount()
    for i = 2 , nCount do
        local tLine = g_tTable.AwardRemind:GetRow(i)
        if hPlayer.GetQuestState(tLine.dwQuestID) ~= QUEST_STATE.FINISHED then
            _, tLine.tLevel = GetJoinLevel(tLine.szLevel)
            tLine.szLevel = string.sub(tLine.szLevel, 1, #tLine.szLevel - 1)
            table.insert(tRemind, tLine)
        end
    end
    
    return tRemind
end

function Table_GetCreateRoleParam()
	local tResult = {}
    local nRow = g_tTable.CreateRole_Param:GetRowCount()
    for i = 2, nRow do
        local tLine = g_tTable.CreateRole_Param:GetRow(i)
		tResult[tLine.szSchoolType] = tLine
    end
	return tResult;
end

function Table_GetMapGroup(dwID)
    local tLine = g_tTable.MapGroup:Search(dwID)
    
    return tLine
end

function Table_GetFirstLoginSkill(dwKungfuID)
    local tLine = g_tTable.FirstLoginSkill:Search(dwKungfuID)
    
    return tLine
end

function Table_GetSprintHelp(dwID)

    local tLine = g_tTable.SprintHelp:Search(dwID)
    
    return tLine
end

function Table_GetAllExteriorBox()
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return 
    end
    local nCount = g_tTable.ExteriorBox:GetRowCount()
    local tAllExteriorBox = {}
    tAllExteriorBox.tSetMap = {}
    tAllExteriorBox.tGenres = {}
    
    local tAllInfo = {}
    tAllInfo.nTotalCount = 0
    tAllInfo.tSubArray = {}
    tAllInfo.tCountMap = {}
    tAllExteriorBox.tAllInfo = tAllInfo
    local tCount = tAllInfo.tCountMap
    local tSetMap = tAllExteriorBox.tSetMap
    local tGenre
    local tGenreAllInfo
    local nIndex = 1
    for i = 2, nCount do
        local tLine = g_tTable.ExteriorBox:GetRow(i)
        if tLine.nSet == 0 then
            tGenre = {}
            tGenre.nGenre = tLine.nGenre
            tGenre.szName = tLine.szGenreName
            tGenreAllInfo = {}
            tGenreAllInfo.nStartIndex = nIndex
            tGenreAllInfo.nEndIndex = -1
            tGenreAllInfo.nTotalCount = 0
            tGenre.tAllInfo = tGenreAllInfo
            tGenre.tSetArray = {}
            table.insert(tAllExteriorBox.tGenres, tGenre)
            tCount[tLine.nGenre] = {}
            tCount[tLine.nGenre][0] = 0
        else 
            if tLine.nGenre ~= EXTERIOR_GENRE.SCHOOL or hPlayer.dwForceID == tLine.nForce then
                local nCount = 0
                tSetMap[tLine.nSet] = {tLine.szSetName, {}}
                local tAllSetInfo = {}
                local tSet = {}
                tSet.nSet = tLine.nSet
                tSet.tAllInfo = tAllSetInfo
                tAllSetInfo.nStartIndex = nIndex
                tAllSetInfo.nEndIndex = -1
                tAllSetInfo.nTotalCount = 0
                tCount[tLine.nGenre][tLine.nSet] = 0
                for i = 1, 5 do
                    tSetMap[tLine.nSet][2][i] = tLine["nSub" .. i]
                    
                    if tLine["nSub" .. i] > 0 then
                        nCount = nCount + 1
                        
                        table.insert(tAllExteriorBox.tAllInfo.tSubArray, tLine["nSub" .. i])
                        tGenreAllInfo.nEndIndex = nIndex
                        tAllSetInfo.nEndIndex = nIndex
                        nIndex = nIndex + 1
                    end
                end
                tCount[tLine.nGenre][tLine.nSet] = nCount
                tGenreAllInfo.nTotalCount = tGenreAllInfo.nTotalCount + nCount
                tAllSetInfo.nTotalCount = nCount
                tCount[tLine.nGenre][0] = tGenreAllInfo.nTotalCount
                tAllInfo.nTotalCount = tAllInfo.nTotalCount + nCount
                table.insert(tGenre.tSetArray, tSet)
             end
        end
    end
    return tAllExteriorBox
end

function Table_GetExteriorGenreName(nGenre)
    local szGenreName = ""
    local tLine = g_tTable.ExteriorBox:Search(nGenre, 0)
    if tLine then
        szGenreName = tLine.szGenreName
    end
    return szGenreName
end

function Table_GetExteriorSetName(nGenre, nSet)
    local szSetName = ""
    local tLine = g_tTable.ExteriorBox:Search(nGenre, nSet)
    if tLine then
        szSetName = tLine.szSetName
    end
    return szSetName
end

function Table_GetExteriorSet(nGenre, nSet)
    local tLine = g_tTable.ExteriorBox:Search(nGenre, nSet)
    
    return tLine
end

function Table_GetChaptersInfo(dwChapterID)
    local tLine = g_tTable.Chapters:Search(dwChapterID)
    return tLine
end