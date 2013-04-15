local tNpcList = {}

g_bHideQuestShowFlag = true
RegisterCustomData("g_bHideQuestShowFlag")

function SetHideQuestShow(bShow)
	g_bHideQuestShowFlag = bShow
	UpdateAllNpcTitleEffect()
end

function IsHideQuestShow()
	return g_bHideQuestShowFlag
end

function OnNpcEnterScene(dwNpcID)
	table.insert(tNpcList, dwNpcID)
end

function OnNpcLeaveScene(dwNpcID)
	for key, value in pairs(tNpcList) do
		if value == dwNpcID then
			table.remove(tNpcList, key)
			break
		end
	end
end

function UpdateAllNpcTitleEffect()
	for _, dwNpcID in pairs(tNpcList) do
		UpdateNpcTitleEffect(dwNpcID)
	end
end

function GetNpcList()
	return tNpcList
end

local QUEST_MARK = -- see "represent/common/global_effect.txt"
{
	["normal_unaccept_proper"] = 1,
	["repeat_unaccept_proper"] = 2,
	["unaccept_high"] = 5,
	["unaccept_low"] = 6,
	["unaccept_lower"] = 43,
	["accpeted"] = 44,
	["normal_finished"] = 3,
	["repeat_finished"] = 4,
	["normal_notneedaccept"] = 44,
	["repeat_notneedaccept"] = 4,
}

function GetNpcQuestState(hNpc)
	local aQuestState = {}
	
	if not hNpc then
		return aQuestState
	end

	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return aQuestState
	end
	
	if IsEnemy(hPlayer.dwID, hNpc.dwID) then
		return aQuestState
	end
	
	if not hNpc.bDialogFlag then
		return aQuestState
	end
	
	local aQuestList = hNpc.GetNpcQuest()
	for _, dwQuestID in pairs(aQuestList) do
		local hQuestInfo = GetQuestInfo(dwQuestID)
		if hQuestInfo then
			local szKey = nil
			if hQuestInfo.bRepeat then
				szKey = "repeat"
			else
				szKey = "normal"
			end
			
			local eCanFinish = hPlayer.CanFinishQuest(dwQuestID, TARGET.NPC, hNpc.dwID)
			local eCanAccept = hPlayer.CanAcceptQuest(dwQuestID, TARGET.NPC, hNpc.dwID)
			
			if eCanFinish == QUEST_RESULT.SUCCESS then
				szKey = szKey .. "_finished"
			elseif eCanAccept == QUEST_RESULT.NO_NEED_ACCEPT
			and eCanFinish ~= QUEST_RESULT.TOO_LOW_LEVEL 
			and eCanFinish ~= QUEST_RESULT.PREQUEST_UNFINISHED 
			and eCanFinish ~= QUEST_RESULT.ERROR_REPUTE 
			and eCanFinish ~= QUEST_RESULT.ERROR_CAMP 
			and eCanFinish ~= QUEST_RESULT.ERROR_GENDER 
			and eCanFinish ~= QUEST_RESULT.ERROR_ROLETYPE 
			and eCanFinish ~= QUEST_RESULT.ERROR_FORCE_ID 
			and eCanFinish ~= QUEST_RESULT.ERROR_QUEST_STATE
			and eCanFinish ~= QUEST_RESULT.COOLDOWN 
			and eCanFinish ~= QUEST_RESULT.ERROR_REPUTE then
				szKey = szKey .. "_notneedaccept"
			elseif eCanAccept == QUEST_RESULT.SUCCESS
			and hQuestInfo.dwStartNpcTemplateID == hNpc.dwTemplateID then
				szKey = szKey .. "_unaccept"
			elseif eCanAccept == QUEST_RESULT.ALREADY_ACCEPTED
			and hQuestInfo.dwEndNpcTemplateID == hNpc.dwTemplateID then
				szKey = szKey .. "_accepted"
			else
				szKey = szKey .. "_none"
			end
			
			local nDifficult = hPlayer.GetQuestDiffcultyLevel(dwQuestID)
			if nDifficult == QUEST_DIFFICULTY_LEVEL.PROPER_LEVEL then
				szKey = szKey .. "_proper"
			elseif nDifficult == QUEST_DIFFICULTY_LEVEL.HIGH_LEVEL then
				szKey = szKey .. "_high"
			elseif nDifficult == QUEST_DIFFICULTY_LEVEL.HIGHER_LEVEL then
				szKey = szKey .. "_higher"				
			elseif nDifficult == QUEST_DIFFICULTY_LEVEL.LOW_LEVEL then
				szKey = szKey .. "_low"
			elseif nDifficult == QUEST_DIFFICULTY_LEVEL.LOWER_LEVEL then
				szKey = szKey .. "_lower"
			end
			
			if not aQuestState[szKey] then
				aQuestState[szKey] = {}
			end
			
			table.insert(aQuestState[szKey], dwQuestID)
		end
	end
	
	return aQuestState
end

function UpdateNpcTitleEffect(dwNpcID)
	local nInScene = false	-- confirm the npc is in the scene or not
	for _, dwID in pairs(tNpcList) do
		if dwID == dwNpcID then
			nInScene = true
			break
		end
	end
	if not nInScene then
		return
	end
	
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end

	local hNpc = GetNpc(dwNpcID)
	if not hNpc then
		return
	end
		
	local aQuestState = GetNpcQuestState(hNpc)
	
	if aQuestState.normal_finished_proper
	or aQuestState.normal_finished_high
	or aQuestState.normal_finished_higher
	or aQuestState.normal_finished_low
	or aQuestState.normal_finished_lower 
	or aQuestState.repeat_finished_proper
	or aQuestState.repeat_finished_high
	or aQuestState.repeat_finished_higher
	or aQuestState.repeat_finished_low
	or aQuestState.repeat_finished_lower then
		SceneObject_SetTitleEffect(TARGET.NPC, dwNpcID, QUEST_MARK.normal_finished)
		return
	end
	
	if aQuestState.normal_unaccept_proper then
		SceneObject_SetTitleEffect(TARGET.NPC, dwNpcID, QUEST_MARK.normal_unaccept_proper)
		return
	end
	
	if aQuestState.repeat_unaccept_proper then
		SceneObject_SetTitleEffect(TARGET.NPC, dwNpcID, QUEST_MARK.repeat_unaccept_proper)
		return
	end
	
	if aQuestState.repeat_notneedaccept_proper
	or aQuestState.repeat_notneedaccept_low
	or aQuestState.repeat_notneedaccept_lower
	or aQuestState.repeat_notneedaccept_high
	or aQuestState.repeat_notneedaccept_higher then
		SceneObject_SetTitleEffect(TARGET.NPC, dwNpcID, QUEST_MARK.repeat_notneedaccept)
		return
	end	
	
	if aQuestState.normal_notneedaccept_proper then 
--	or aQuestState.normal_notneedaccept_low
--	or aQuestState.normal_notneedaccept_lower
--	or aQuestState.normal_notneedaccept_high
--	or aQuestState.normal_notneedaccept_higher
		SceneObject_SetTitleEffect(TARGET.NPC, dwNpcID, QUEST_MARK.normal_notneedaccept)
		return
	end
	
	if hPlayer.IsInParty() then	-- party mark
		local tPartyMark = GetClientTeam().GetTeamMark()
		if tPartyMark and tPartyMark[dwNpcID] then
			local nPartyMark = tPartyMark[dwNpcID]
			assert(nPartyMark > 0 and nPartyMark <= #PARTY_TITLE_MARK_EFFECT_LIST)
			SceneObject_SetTitleEffect(TARGET.NPC, dwNpcID, PARTY_TITLE_MARK_EFFECT_LIST[nPartyMark])
			return
		end
	end
    
	-- npc type mark
	local tNpc = g_tTable.Npc:Search(hNpc.dwTemplateID)
	local dwNpcTypeID = nil
	if tNpc then
		dwNpcTypeID = tNpc.dwTypeID
	end
	if dwNpcTypeID and IsSearchTypeNpc(dwNpcTypeID) then
		local tNpcType = g_tTable.NpcType:Search(dwNpcTypeID)
		if tNpcType and tNpcType.dwEffectID > 0 then
			SceneObject_SetTitleEffect(TARGET.NPC, dwNpcID, tNpcType.dwEffectID)
			return
		end
	end
    
	if aQuestState.normal_unaccept_high or aQuestState.repeat_unaccept_high then
		SceneObject_SetTitleEffect(TARGET.NPC, dwNpcID, QUEST_MARK.unaccept_high)
		return
	end
		
	if g_bHideQuestShowFlag and (aQuestState.normal_unaccept_low or aQuestState.repeat_unaccept_low) then
		SceneObject_SetTitleEffect(TARGET.NPC, dwNpcID, QUEST_MARK.unaccept_low)
		return
	end
	
	if g_bHideQuestShowFlag and (aQuestState.normal_unaccept_lower or aQuestState.repeat_unaccept_lower) then
		SceneObject_SetTitleEffect(TARGET.NPC, dwNpcID, QUEST_MARK.unaccept_lower)
		return
	end
		
	if aQuestState.normal_accepted_proper
	or aQuestState.normal_accepted_low
	or aQuestState.normal_accepted_lower
	or aQuestState.normal_accepted_high
--	or aQuestState.normal_accepted_higher
	or aQuestState.repeat_accepted_proper
	or aQuestState.repeat_accepted_high
--	or aQuestState.repeat_accepted_higher
	or aQuestState.repeat_accepted_low
	or aQuestState.repeat_accepted_lower then
		SceneObject_SetTitleEffect(TARGET.NPC, dwNpcID, QUEST_MARK.accpeted)
		return
	end
		
	SceneObject_SetTitleEffect(TARGET.NPC, dwNpcID, 0)	-- none effect
end

function OutputNpcTip(dwNpcID, Rect)
	local npc = GetNpc(dwNpcID)
	if not npc then
		return
	end
	 
	if not npc.IsSelectable() then
		return
	end
	
	local clientPlayer = GetClientPlayer()
	local r, g, b=GetForceFontColor(dwNpcID, clientPlayer.dwID)

	local szTip = ""

	--------------名字-------------------------
	    
    szTip = szTip.."<Text>text="..EncodeComponentsString(npc.szName.."\n").." font=80".." r="..r.." g="..g.." b="..b.." </text>"

    -------------称号----------------------------        
    if npc.szTitle ~= "" then
    	szTip = szTip.."<Text>text="..EncodeComponentsString("<"..npc.szTitle..">\n").." font=0 </text>"
    end
    
    -------------等级----------------------------
    if npc.nLevel - clientPlayer.nLevel > 10 then
    	szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.STR_PLAYER_H_UNKNOWN_LEVEL).." font=82 </text>"
    else	
    	szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_NPC_H_WHAT_LEVEL, npc.nLevel)).." font=0 </text>"
    end
    
   	-------------势力------------------------
	if g_tReputation.tReputationTable[npc.dwForceID] then
		szTip = szTip.."<Text>text="..EncodeComponentsString(g_tReputation.tReputationTable[npc.dwForceID].szName.."\n").." font=0 </text>"
	end	
    
    local szNpcQuestTip = GetNpcQuestTip(npc.dwTemplateID)
    szTip = szTip .. szNpcQuestTip
    ------------模版ID-----------------------
    if IsCtrlKeyDown() then
    	szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.TIP_NPC_ID, npc.dwID)).."font=102 </text>" 
    	szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.TIP_TEMPLATE_ID_NPC_INTENSITY, npc.dwTemplateID, npc.nIntensity)).." font=102 </text>"
    	szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.TIP_REPRESENTID_ID, npc.dwModelID)).." font=102 </text>" 
    	if IsShiftKeyDown() then
    		local tState = GetNpcQuestState(npc) or {}
    		for szKey, tQuestList in pairs(tState) do
    			tState[szKey] = table.concat(tQuestList, ",")
    		end
    		szTip = szTip .. GetFormatText(var2str(tState), 102)
    	end
    end
    
    OutputTip(szTip, 345, Rect)
end

function GetNpcQuestTip(dwNpcTemplateID)
	local nTargetFont = 0
	szTip = ""
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return szTip
	end
	
	local tQuestList = hPlayer.GetQuestList()
	for _, dwQuestID in pairs(tQuestList) do
		local szTarget = ""
		local tQuestTrace = hPlayer.GetQuestTraceInfo(dwQuestID)
		for _, v in ipairs(tQuestTrace.kill_npc) do
			if dwNpcTemplateID == v.template_id then
				if v.have < v.need then
					local szName = Table_GetNpcTemplateName(v.template_id)
					if not szName or szName == "" then
						szName = "Unknown Npc"
					end
					szTarget = GetFormatText(g_tStrings.STR_TWO_CHINESE_SPACE.. szName .."："..v.have.."/"..v.need .. "\n", nTargetFont)
				end
				break
			end
		end
		
		local tQuestInfo = GetQuestInfo(dwQuestID)
		for i = 1, QUEST_COUNT.QUEST_PARAM_COUNT do
			if tQuestInfo["dwDropItemNpcTemplateID" .. i] ~= 0 
			and tQuestInfo["dwDropItemNpcTemplateID" .. i] == dwNpcTemplateID 
			then
				for _, v in ipairs(tQuestTrace.need_item) do
					if v.type == tQuestInfo["dwEndRequireItemType" .. i] 
					and v.index == tQuestInfo["dwEndRequireItemIndex" .. i] 
					and v.need == tQuestInfo["dwEndRequireItemAmount" .. i]  
					then
						local tItemInfo = GetItemInfo(v.type, v.index)
						local nBookID = v.need
						if tItemInfo.nGenre == ITEM_GENRE.BOOK then
							v.need = 1
						end
						if v.have < v.need then
							local szName = "Unknown Item"
							if tItemInfo then
								szName = GetItemNameByItemInfo(tItemInfo, nBookID)
							end
							szTarget = szTarget .. GetFormatText(g_tStrings.STR_TWO_CHINESE_SPACE.. szName .."："..v.have.."/"..v.need .. "\n", nTargetFont)
						end						
						break
					end
				end
			end
		end
		if szTarget ~= "" then
			local tQuestStringInfo = Table_GetQuestStringInfo(dwQuestID)
			szTip = szTip .. GetFormatText("[" .. tQuestStringInfo.szName .. "]\n", 65) .. szTarget
		end
	end
	return szTip
end

--需要攻击返回flase，否则返回true
function InteractNpc(dwNpcID)
	local npc = GetNpc(dwNpcID)
	if not npc then
		return false
	end

	local player = GetClientPlayer()
	local dwPlayerID = player.dwID

	if npc.IsSelectable() then
		if IsEnemy(dwPlayerID, dwNpcID) then
			return false
		elseif npc.bDialogFlag then
		  	if player.bCannotDialogWithNPC then
		  		OutputMessage("MSG_SYS", g_tStrings.MSG_CAN_NOT_DIALOG_WITH_NPC);
		  		return true
		  	end
		  
			DoAction(dwNpcID, CHARACTER_ACTION_TYPE.DIALOGUE)
			return true
		else
			return true
		end
	else
		return true
	end
end


function NeedHightlightNpc(dwNpcID)
	--TODO:可能会根据技能，势力，自身状态之类的条件做
	local npc = GetNpc(dwNpcID)
	
	if not npc then
		return false
	end
	
	if not npc.IsSelectable() then
		return false
	end
	return true
end


function CanSelectNpc(dwNpcID)
	local npc = GetNpc(dwNpcID)
	if not npc then
		return false
	end
	if not npc.IsSelectable() then
		return false
	end
	return true
end

function ChangeCursorWhenOverNpc(dwNpcID)
	if IsCursorInExclusiveMode() then
		return
	end
	
	local player = GetClientPlayer()
	local dwPlayerID = player.dwID
	local npc = GetNpc(dwNpcID)
	if not npc then
		Cursor.Switch(CURSOR.NORMAL)
		return
	end
	
--	local tNpc = g_tTable.Npc:Search(hNpc.dwTemplateID)
--  local dwNpcTypeID = nil
--	if tNpc then
--		dwNpcTypeID = tNpc.dwTypeID
--	end
--	if dwNpcTypeID then
--		local tNpcType = g_tTable.NpcType:Search(dwNpcTypeID)
--		if tNpcType and tNpcType.dwCursorID > 0 then
--			Cursor.Switch(tNpcType.dwCursorID)
--			return
--		end
--	end
		
	local bCan = npc.CanDialog(player)
	
	if npc.IsSelectable() then
		if IsEnemy(dwPlayerID, dwNpcID) then
			Cursor.Switch(CURSOR.ATTACK)
		elseif npc.bDialogFlag then
			if bCan then
				Cursor.Switch(CURSOR.SPEAK)
			else
				Cursor.Switch(CURSOR.UNABLESPEAK)
			end
		else
			Cursor.Switch(CURSOR.NORMAL)
		end	
	else
		Cursor.Switch(CURSOR.NORMAL)
	end
end

function NeedHightlightNpcWhenOver(dwNpcID)
	local dwPlayerID = GetClientPlayer().dwID
	local npc = GetNpc(dwNpcID)
	if not npc then
		return false
	end
	
	if npc.IsSelectable() then
		return true
	end	
	return false
end

