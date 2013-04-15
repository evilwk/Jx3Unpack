LoadScene()
LoadCell()
LoadPlayer()
LoadNpc()
LoadNpcTemplate()
LoadDoodad()
LoadDoodadTemplate()
if LoadItemHouse then
	LoadItemHouse()
end
LoadSkill()
LoadProfession()
--LoadRecipe()
LoadQuestInfo()
LoadShop()
LoadTeamClient()
LoadGameCardClient()

if LoadAuctionClient then
	LoadAuctionClient()
end

if LoadScriptClient then
	LoadScriptClient();
end

if LoadCampInfo then
	LoadCampInfo()
end

if LoadTongClient then
	LoadTongClient()
end

if LoadMailClient then
	LoadMailClient()
end

if LoadMailInfo then
	LoadMailInfo()
end

if LoadActivityMgrClient then
	LoadActivityMgrClient()
end

if LoadHairShop then
	LoadHairShop()
end

if LoadExterior then
	LoadExterior()
end

ROLE_TYPE_INVALID 			= 0
ROLE_TYPE_STANDARDMALE		= 1
ROLE_TYPE_STANDARDFEMALE	= 2
ROLE_TYPE_STRONGMALE		= 3
ROLE_TYPE_SEXYFEMALE		= 4
ROLE_TYPE_LITTLEBOY			= 5
ROLE_TYPE_LITTLEGIRL		= 6

------------人物相关
QUEST_OPERATION_ACCEPT = 1;
QUEST_OPERATION_FINISH = 2;

QUEST_STATE_NO_MARK             = 1;
QUEST_STATE_YELLOW_QUESTION     = 2;
QUEST_STATE_BLUE_QUESTION       = 3;
QUEST_STATE_HIDE                = 4;
QUEST_STATE_WHITE_EXCLAMATION   = 5;
QUEST_STATE_YELLOW_EXCLAMATION  = 6;
QUEST_STATE_BLUE_EXCLAMATION	= 7;
QUEST_STATE_WHITE_QUESTION      = 8;
QUEST_STATE_DUN_DIA				= 9;

QUEST_WHITE_LEVEL               = 10;
QUEST_HIDE_LEVEL                = 10;

ITEM_SUBTYPE_SKILL_RECIPE		= 4;
ITEM_SUBTYPE_RECIPE				= 5;

MAX_SKILL_REICPE_COUNT = 4;
MAX_BATTLE_FIELD_SIDE_COUNT = 4;
MAX_BATTLE_FIELD_OVERTIME = 30; --秒
MAX_CAMP_LEVEL = 10;
MAX_CAMP_PRIZE = 1024;
MAX_CAMP_PRESTIGE = 150000;
MAX_USABLE_MENTOR = 10000;
MAX_DAILY_QUEST_COUNT = 20
MAX_QUEST_COUNT = 25


CONVERT_RAID_PLAYER_MIN_LEVEL = 30;

SKILL_SELECT_POINT_UNNORMAL = --像纯阳六合独尊这类的技能，当超出范围时，显示这空技能所绑的特效
{
	nSkillID = 1919,
	nLevel = 1,
}

function GetQuestIndex(dwQuestID)
	local player = GetClientPlayer();
	for nQuestIndex = 0, QUEST_COUNT.MAX_ACCEPT_QUEST_COUNT - 1 do
		if player.GetQuestID(nQuestIndex) == dwQuestID then
			return nQuestIndex;
		end;
	end;

	return -1;
end;

function GetQuestState(dwQuestID, dwTargetType, dwTargetID)
    local player = GetClientPlayer();
    local eState = player.GetQuestState(dwQuestID);
    local eCanAccept = player.CanAcceptQuest(dwQuestID, dwTargetType, dwTargetID);
    local questInfo = GetQuestInfo(dwQuestID);
    local nQuestLevel = questInfo.nLevel;
    local nPlayerLevel = player.nLevel;
    local eCanFinish = player.CanFinishQuest(dwQuestID, dwTargetType, dwTargetID);
    
	if (eCanAccept == QUEST_RESULT.SUCCESS) then
		if ((nPlayerLevel - nQuestLevel) > QUEST_HIDE_LEVEL) then
			return QUEST_STATE_HIDE, nQuestLevel;
		else
			return QUEST_STATE_YELLOW_EXCLAMATION, nQuestLevel;
		end;
	elseif (eCanFinish == QUEST_RESULT.SUCCESS) then
		return QUEST_STATE_YELLOW_QUESTION, nQuestLevel;
	else
		if (eCanFinish == QUEST_RESULT.ERROR_END_NPC_TARGET
				or eCanFinish == QUEST_RESULT.ERROR_END_DOODAD_TARGET) then
			return QUEST_STATE_DUN_DIA, nQuestLevel;
		elseif (eCanAccept == QUEST_RESULT.TOO_LOW_LEVEL and ((questInfo.nMinLevel - nPlayerLevel) < QUEST_WHITE_LEVEL)) then
			return QUEST_STATE_WHITE_EXCLAMATION, nQuestLevel;
		else
			if (eCanAccept == QUEST_RESULT.ALREADY_ACCEPTED) then
				return QUEST_STATE_WHITE_QUESTION, nQuestLevel;
			elseif eCanAccept == QUEST_RESULT.NO_NEED_ACCEPT then
				if eCanFinish == QUEST_RESULT.TOO_LOW_LEVEL or eCanFinish == QUEST_RESULT.PREQUEST_UNFINISHED or 
				eCanFinish == QUEST_RESULT.ERROR_REPUTE or eCanFinish == QUEST_RESULT.ERROR_CAMP or eCanFinish == QUEST_RESULT.ERROR_GENDER or 
				eCanFinish == QUEST_RESULT.ERROR_ROLETYPE or eCanFinish == QUEST_RESULT.ERROR_FORCE_ID or eCanFinish == QUEST_RESULT.COOLDOWN or 
				eCanFinish == QUEST_RESULT.ERROR_REPUTE  then
					return QUEST_STATE_NO_MARK, nQuestLevel;
				else
					if not questInfo.bRepeat and eState == QUEST_STATE.FINISHED then
						return QUEST_STATE_NO_MARK, nQuestLevel;
					else
						return QUEST_STATE_WHITE_QUESTION, nQuestLevel;
					end
				end
			end	
		end
	end
		
	return QUEST_STATE_NO_MARK, nQuestLevel
end



function IsPlayerManaHide(dwMountType, dwID)
	if not dwMountType and dwID then
		local player = GetPlayer(dwID)
		if not player then
			return false;
		end
		dwMountType = player.GetKungfuMount().dwMountType
	end
	if not dwMountType then
		return false
	end
	
	if dwMountType == 6 or dwMountType == 10 then --藏剑
		return true;
	end
	
	return false;
end