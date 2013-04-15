function OutputDoodadTip(dwDoodadID, Rect)
	local doodad = GetDoodad(dwDoodadID)
	if not doodad then
		return
	end
	
	local player = GetClientPlayer()
	local bQuestDoodad = doodad.nKind == DOODAD_KIND.QUEST
	if bQuestDoodad and not doodad.HaveQuest(player.dwID) then
	    return
	end

	if not doodad.IsSelectable() then
	    return
	end

	local szTip = ""

	--------------名字-------------------------    
	local szDoodadName = Table_GetDoodadName(doodad.dwTemplateID, doodad.dwNpcTemplateID)
	
    if doodad.nKind == DOODAD_KIND.CORPSE then
    	szName = szDoodadName .. g_tStrings.STR_DOODAD_CORPSE
    end
    
    szTip = szTip.."<Text>text="..EncodeComponentsString(szDoodadName.."\n").." font=37 </text>"
    
	if (doodad.nKind == DOODAD_KIND.CORPSE and not doodad.CanLoot(player.dwID)) or doodad.nKind == DOODAD_KIND.CRAFT_TARGET then
    	local doodadTemplate = GetDoodadTemplate(doodad.dwTemplateID);
    	if doodadTemplate.dwCraftID ~= 0 then
    		local dwRecipeID = doodad.GetRecipeID()
	    	local recipe = GetRecipe(doodadTemplate.dwCraftID, dwRecipeID);
	    	if recipe then
	    		--生活技能等级--
	    		local profession = GetProfession(recipe.dwProfessionID);
	    		local requireLevel = recipe.dwRequireProfessionLevel;
	    		
	    		--local playMaxLevel               = player.GetProfessionMaxLevel(recipe.dwProfessionID)
	            local playerLevel                = player.GetProfessionLevel(recipe.dwProfessionID)
	            --local playExp                    = player.GetProfessionProficiency(recipe.dwProfessionID)
	    		local nBranchID = player.GetProfessionBranch(recipe.dwProfessionID)
	    		
	    		local nDis = playerLevel - requireLevel
	    		local nFont = 102
	    		if nDis >= 20 then
	    			nFont = 109
	    		elseif nDis >= 14 then
	    			nFont = 105
	    		elseif nDis >= 7 then
	    			nFont = 100
	    		elseif nDis >= 0 then
	    			nFont = 101
	    		else
	    			nFont = 102
	    		end
	    		szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_MSG_NEED_CRAFT, Table_GetProfessionName(recipe.dwProfessionID), requireLevel)).." font="..nFont.." </text>"
--[[
				if recipe.dwRequireBranchID ~= 0 then
					local nFont = 105
					if nBranchID ~= recipe.dwRequireBranchID then
						nFont = 102
					end			
		    		szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_MSG_NEED_BRANCH, Table_GetBranchName(recipe.dwProfessionID, recipe.dwRequireBranchID))).." font="..nFont.." </text>"
				end
]]				
                if recipe.nCraftType == ALL_CRAFT_TYPE.COPY then
                    if recipe.dwProfessionIDExt ~= 0 then
            		    local ProfessionExt = GetProfession(recipe.dwProfessionIDExt);
            		    if ProfessionExt then
            		        local nExtLevel    = player.GetProfessionLevel(recipe.dwProfessionIDExt)
            		        
            		        local nDis = nExtLevel - recipe.dwRequireProfessionLevelExt
            	    		local nFont = 102
            	    		if nDis >= 20 then
            	    			nFont = 109
            	    		elseif nDis >= 14 then
            	    			nFont = 105
            	    		elseif nDis >= 7 then
            	    			nFont = 100
            	    		elseif nDis >= 0 then
            	    			nFont = 101
            	    		else
            	    			nFont = 102
            	    		end
            	    		
                    		szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_MSG_NEED_CRAFT, Table_GetProfessionName(recipe.dwProfessionIDExt), recipe.dwRequireProfessionLevelExt)).." font="..nFont.." </text>"
            		    end        
            		    
            		    local nBookID, nSegmentID = GlobelRecipeID2BookID(dwRecipeID)
          				if player.IsBookMemorized(nBookID, nSegmentID) then
							szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.TIP_ALREADY_READ).." font=108 </text>"
						else
							szTip = szTip.."<Text>text="..EncodeComponentsString(g_tStrings.TIP_UNREAD).." font=105 </text>"
						end
						
            		   	if recipe.dwCoolDownID > 0 then
            		  		local CDTotalTime  = player.GetCDInterval(recipe.dwCoolDownID)
							local CDRemainTime = player.GetCDLeft(recipe.dwCoolDownID) or 0
							
							local szText = ""
							local nH, nM, nS = 0, 0, 0
							if CDRemainTime > 0 then
								nH, nM, nS = GetTimeToHourMinuteSecond(CDRemainTime, true)
								szText = g_tStrings.TIME_CD1
							else
								nH, nM, nS = GetTimeToHourMinuteSecond(CDTotalTime, true)
								szText = g_tStrings.TIME_CD
							end
							
							local szTime = ""
							if nH >= 1 then
								if nM > 0 or nS > 0 then
									nH = nH + 1
								end
								local nD = math.floor(nH / 24)
								if nD > 0 then
									szTime = szTime..nD..g_tStrings.STR_BUFF_H_TIME_D
								end
								nH = (nH - nD * 24)
								if nH > 0 then
									szTime = szTime..nH..g_tStrings.STR_BUFF_H_TIME_H
								end
							else
								if nS > 0 then
									nM = nM + 1
								end
								if nM == 60 then
									szTime = math.floor(nM/60)..g_tStrings.STR_BUFF_H_TIME_H
								else
									szTime = nM..g_tStrings.STR_BUFF_H_TIME_M
								end
							end
							szText = szText..szTime
							local nFont = 162
							if CDRemainTime ~= 0 then
								nFont = 102
							end
							szTip = szTip.."<Text>text="..EncodeComponentsString(szText.."\n").." font="..nFont.." </text>"
            		    end   
        		    end
        		end
		
	    		if recipe.dwToolItemType ~= 0 and recipe.dwToolItemIndex ~= 0 then
	    			local hasItem = player.GetItemAmount(recipe.dwToolItemType, recipe.dwToolItemIndex);
	    			local toolItemInfo = GetItemInfo(recipe.dwToolItemType, recipe.dwToolItemIndex);
	    			local nFont = 102
	    			if hasItem > 0 then
	    				nFont = 106
	    			end	
	    			szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_MSG_NEED_TOOL, GetItemNameByItemInfo(toolItemInfo))).." font="..nFont.." </text>"
				end
				
				if recipe.nCraftType == ALL_CRAFT_TYPE.COLLECTION or recipe.nCraftType == ALL_CRAFT_TYPE.COPY then
            		local nFont = 102
    	    	    if player.nCurrentThew >= recipe.nThew  then
    	    		    nFont = 106
    	    			end
            		szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_MSG_NEED_COST_THEW, recipe.nThew)).." font="..nFont.." </text>"
            	elseif recipe.nCraftType == ALL_CRAFT_TYPE.PRODUCE  or recipe.nCraftType == ALL_CRAFT_TYPE.READ or recipe.nCraftType == ALL_CRAFT_TYPE.ENCHANT then
            	    local nFont = 102
    	    	    if player.nCurrentStamina >= recipe.nStamina then
    	    		    nFont = 106
    	    		end
            		szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_MSG_NEED_COST_STAMINA, recipe.nStamina)).." font="..nFont.." </text>"
            	end
		
				if recipe.nCraftType == ALL_CRAFT_TYPE.COPY then
					local szRequre = "<Text>text="..EncodeComponentsString(g_tStrings.STR_NEED).." font=106 </text>"
					local bHave = false
    				if recipe.dwRequireItemType1 ~= 0 and recipe.dwRequireItemIndex1 ~= 0 then
    	    			local nItemAmount = player.GetItemAmount(recipe.dwRequireItemType1, recipe.dwRequireItemIndex1);
    	    			local ItemInfo = GetItemInfo(recipe.dwRequireItemType1, recipe.dwRequireItemIndex1);
    	    			local nFont = 102
    	    			if nItemAmount >= recipe.dwRequireItemCount1 then
    	    				nFont = 106
    	    			end	
    	    			szRequre = szRequre.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_NEED_WHAT_NUM, GetItemNameByItemInfo(ItemInfo), recipe.dwRequireItemCount1)).." font="..nFont.." </text>"
    	    			bHave = true
    				end
    				
    				if recipe.dwRequireItemType2 ~= 0 and recipe.dwRequireItemIndex2 ~= 0 then
    	    			local nItemAmount = player.GetItemAmount(recipe.dwRequireItemType2, recipe.dwRequireItemIndex2);
    	    			local ItemInfo = GetItemInfo(recipe.dwRequireItemType2, recipe.dwRequireItemIndex2);
    	    			local nFont = 102
    	    			if nItemAmount >= recipe.dwRequireItemCount2  then
    	    				nFont = 106
    	    			end	
    	    			if bHave then
    	    				szRequre = szRequre.."<Text>text="..EncodeComponentsString(g_tStrings.STR_COMMA).." font=106 </text>"
    	    			end
    	    			szRequre = szRequre.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_NEED_WHAT_NUM, GetItemNameByItemInfo(ItemInfo), recipe.dwRequireItemCount2)).." font="..nFont.." </text>"
    	    			bHave = true
    				end
    				
    				if recipe.dwRequireItemType3 ~= 0 and recipe.dwRequireItemIndex3 ~= 0 then
    	    			local nItemAmount = player.GetItemAmount(recipe.dwRequireItemType3, recipe.dwRequireItemIndex3);
    	    			local ItemInfo = GetItemInfo(recipe.dwRequireItemType3, recipe.dwRequireItemIndex3);
    	    			local nFont = 102
    	    			if nItemAmount >= recipe.dwRequireItemCount3  then
    	    				nFont = 106
    	    			end	
    	    			if bHave then
    	    				szRequre = szRequre.."<Text>text="..EncodeComponentsString(g_tStrings.STR_COMMA).." font=106 </text>"
    	    			end    	    			
    	    			szRequre = szRequre.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_NEED_WHAT_NUM, GetItemNameByItemInfo(ItemInfo), recipe.dwRequireItemCount3)).." font="..nFont.." </text>"
    	    			bHave = true
    				end
    				
    				if recipe.dwRequireItemType4 ~= 0 and recipe.dwRequireItemIndex4 ~= 0 then
    	    			local nItemAmount = player.GetItemAmount(recipe.dwRequireItemType4, recipe.dwRequireItemIndex4);
    	    			local ItemInfo = GetItemInfo(recipe.dwRequireItemType4, recipe.dwRequireItemIndex4);
    	    			local nFont = 102
    	    			if nItemAmount >= recipe.dwRequireItemCount4  then
    	    				nFont = 106
    	    			end	
    	    			if bHave then
    	    				szRequre = szRequre.."<Text>text="..EncodeComponentsString(g_tStrings.STR_COMMA).." font=106 </text>"
    	    			end    	    			
    	    			szRequre = szRequre.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.STR_NEED_WHAT_NUM, GetItemNameByItemInfo(ItemInfo), recipe.dwRequireItemCount4)).." font="..nFont.." </text>"
    	    			bHave = true
    				end
    				if bHave then
    					szTip = szTip..szRequre
    				end
				end
	    	end
	    end
    end	
    
    local szDoodadQuestTip = GetDoodadQuestTip(doodad.dwTemplateID)
    szTip = szTip .. szDoodadQuestTip
    
    ------------模版ID-----------------------
    if IsCtrlKeyDown() then
    	szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.TIP_DOODAD_ID, doodad.dwID)).." font=102 </text>" 
    	szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.TIP_TEMPLATE_ID, doodad.dwTemplateID)).." font=102 </text>" 
    	szTip = szTip.."<Text>text="..EncodeComponentsString(FormatString(g_tStrings.TIP_REPRESENTID_ID, doodad.dwRepresentID)).." font=102 </text>" 
    end
    
    if doodad.nKind == DOODAD_KIND.GUIDE then
		local x, y = Cursor.GetPos()	
		w, h = 40, 40
		Rect = {x, y, w, h}
    end
    OutputTip(szTip, 345, Rect)
end

function GetDoodadQuestTip(dwDoodadTemplateID)
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
		local tQuestInfo = GetQuestInfo(dwQuestID)
		for i = 1, QUEST_COUNT.QUEST_PARAM_COUNT do
			if tQuestInfo["dwDropItemDoodadTemplateID" .. i] ~= 0 
			and tQuestInfo["dwDropItemDoodadTemplateID" .. i] == dwDoodadTemplateID 
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

function CheckDistanceAndDirection(player, doodad)
	if not doodad.CanDialog(player) then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.TIP_TOO_FAR)
		return false
	end
	
	return true
end

function OpenDoodad(player, doodad)
	local bResult = CheckDistanceAndDirection(player, doodad)
	if not bResult then
			return true
	end
  player.Open(doodad.dwID)
  return true
end

--需要攻击返回flase，否则返回true
function InteractDoodad(dwDoodadID)
--	Trace("InteractDoodad("..dwDoodadID..")\n")
	
	local doodad = GetDoodad(dwDoodadID)
	if not doodad then
        Trace("[UI InteractDoodad] error get dooad("..dwDoodadID..")\n")
		return true
	end

	local player = GetClientPlayer()
	local dwPlayerID = player.dwID
	
	LootList_SetPickupAll(false)
	if IsShiftKeyDown() or LootList_IsRButtonPickupAll() then
		LootList_SetPickupAll(true)
	end
	
	doodadTemplate = GetDoodadTemplate(doodad.dwTemplateID)
	if not doodadTemplate then
        Trace("[UI InteractDoodad] error get dooadTemplate("..doodad.dwTemplateID..")\n")
		return true
	end
	
	if doodad.nKind == DOODAD_KIND.CORPSE or doodad.nKind == DOODAD_KIND.NPCDROP then
		if doodad.CanLoot(dwPlayerID) then
				OpenDoodad(player, doodad)
		elseif doodad.CanSearch() and (doodadTemplate.dwCraftID ~= 0 and player.IsProfessionLearnedByCraftID(doodadTemplate.dwCraftID)) then
				OpenDoodad(player, doodad)
	  end
	  return true
	end

	if doodad.nKind == DOODAD_KIND.QUEST then
		if doodad.HaveQuest(dwPlayerID) then
			OpenDoodad(player, doodad)
    end
    return true
	end
	
	if doodad.nKind == DOODAD_KIND.CRAFT_TARGET then
		local doodadTemp = GetDoodadTemplate(doodad.dwTemplateID)
		if doodadTemp and doodadTemp.dwCraftID ~= 0 and player.IsProfessionLearnedByCraftID(doodadTemp.dwCraftID) then
			OpenDoodad(player, doodad)
		end
		return true
	end
	
	if doodad.IsSelectable() then
			OpenDoodad(player, doodad)
	    return true
	end
    
	return true
end

function IsCorpseAndCanLoot(dwDoodadID)
	local doodad = GetDoodad(dwDoodadID)
	if not doodad then
		return false
	end

	local player = GetClientPlayer()
	local dwPlayerID = player.dwID
	
	return (doodad.nKind == DOODAD_KIND.CORPSE and doodad.CanLoot(dwPlayerID))
end

function NeedHightlightDoodad(dwDoodadID)
	--TODO:可能会根据技能，势力，自身状态之类的条件做
	return CanSelectDoodad(dwDoodadID)
end


function CanSelectDoodad(dwDoodadID)
	local doodad = GetDoodad(dwDoodadID)
	if not doodad then
		return false
	end
	
	if not doodad.IsSelectable() then
		return false
	end

	local player = GetClientPlayer()
	local dwPlayerID = player.dwID
	local bCorpse = doodad.nKind == DOODAD_KIND.CORPSE
	local bQuestDoodad = doodad.nKind == DOODAD_KIND.QUEST
	
	if bCorpse and not doodad.CanLoot(dwPlayerID) then
		return false
	elseif bQuestDoodad and not doodad.HaveQuest(dwPlayerID) then
		return false
	end
	
	return true
end

--根据doodad的类型显示不同的鼠标。
function ChangeCursorWhenOverDoodad(dwDoodadID)
	if IsCursorInExclusiveMode() then
		return
	end
	
	local player = GetClientPlayer()
	local dwPlayerID = player.dwID
	local doodad = GetDoodad(dwDoodadID)
	if not doodad then
		Cursor.Switch(CURSOR.NORMAL)
		return
	end
	
	local bCan = doodad.CanDialog(player)
	
	if doodad.nKind == DOODAD_KIND.INVALID then
		Cursor.Switch(CURSOR.NORMAL)
	elseif doodad.nKind == DOODAD_KIND.NORMAL then
		Cursor.Switch(CURSOR.NORMAL)
	elseif doodad.nKind == DOODAD_KIND.CORPSE or doodad.nKind == DOODAD_KIND.NPCDROP then
		if doodad.CanLoot(dwPlayerID) then
			if bCan then
				Cursor.Switch(CURSOR.LOOT)
			else
				Cursor.Switch(CURSOR.UNABLELOOT)
			end
		elseif doodad.CanSearch() then
			local doodadTemp = GetDoodadTemplate(doodad.dwTemplateID)
			if doodadTemp and doodadTemp.dwCraftID == 3 and player.IsProfessionLearnedByCraftID(doodadTemp.dwCraftID) then --搜索
				if bCan then
					Cursor.Switch(CURSOR.SEARCH)
				else
					Cursor.Switch(CURSOR.UNABLESEARCH)
				end
			else
				Cursor.Switch(CURSOR.NORMAL)
			end
		end
	elseif doodad.nKind == DOODAD_KIND.QUEST then
		if doodad.HaveQuest(dwPlayerID) then
			if bCan then
				Cursor.Switch(CURSOR.QUEST)
			else
				Cursor.Switch(CURSOR.UNABLEQUEST)
			end
		else
			Cursor.Switch(CURSOR.NORMAL)
		end
	elseif doodad.nKind == DOODAD_KIND.READ then
		if bCan then
			Cursor.Switch(CURSOR.READ)
		else
			Cursor.Switch(CURSOR.UNABLEREAD)
		end
	elseif doodad.nKind == DOODAD_KIND.DIALOG then
		if bCan then
			Cursor.Switch(CURSOR.SPEAK)
		else
			Cursor.Switch(CURSOR.UNABLESPEAK)
		end
	elseif doodad.nKind == DOODAD_KIND.ACCEPT_QUEST then
		if bCan then
			Cursor.Switch(CURSOR.QUEST)
		else
			Cursor.Switch(CURSOR.UNABLEQUEST)
		end
	elseif doodad.nKind == DOODAD_KIND.TREASURE then
		if bCan then
			Cursor.Switch(CURSOR.LOCK)
		else
			Cursor.Switch(CURSOR.UNABLELOCK)
		end
	elseif doodad.nKind == DOODAD_KIND.ORNAMENT then
		Cursor.Switch(CURSOR.NORMAL)
	elseif doodad.nKind == DOODAD_KIND.CRAFT_TARGET then
		local doodadTemp = GetDoodadTemplate(doodad.dwTemplateID)
		if doodadTemp and player.IsProfessionLearnedByCraftID(doodadTemp.dwCraftID) then
			if doodadTemp.dwCraftID == 1 then	--采矿
				if bCan then
					Cursor.Switch(CURSOR.MINE)
				else
					Cursor.Switch(CURSOR.UNABLEMINE)
				end		
			elseif doodadTemp.dwCraftID == 2 then --采花
				if bCan then
					Cursor.Switch(CURSOR.FLOWER)
				else
					Cursor.Switch(CURSOR.UNABLEFLOWER)
				end
			elseif doodadTemp.dwCraftID == 3 then --搜索
				if bCan then
					Cursor.Switch(CURSOR.SEARCH)
				else
					Cursor.Switch(CURSOR.UNABLESEARCH)
				end
			elseif doodadTemp.dwCraftID == 12 then --抄录
				if bCan then
					Cursor.Switch(CURSOR.INSPECT)				
				else
					Cursor.Switch(CURSOR.UNABLEINSPECT)				
				end
			else
				Cursor.Switch(CURSOR.NORMAL)
			end
		else
			Cursor.Switch(CURSOR.NORMAL)
		end
	elseif doodad.nKind == DOODAD_KIND.CLIENT_ONLY then
		Cursor.Switch(CURSOR.NORMAL)
	elseif doodad.nKind == DOODAD_KIND.CHAIR and doodad.CanSit() then
		Cursor.Switch(CURSOR.QUEST)
	elseif doodad.nKind == DOODAD_KIND.DOOR then
		if not doodad.IsSelectable() then
			Cursor.Switch(CURSOR.NORMAL)
			return
		end
		
		if bCan then
			Cursor.Switch(CURSOR.LOCK)
		else
			Cursor.Switch(CURSOR.UNABLELOCK)
		end
	else
		Cursor.Switch(CURSOR.NORMAL)
	end
end

function NeedHightlightDoodadWhenOver(dwDoodadID)
	local dwPlayerID = GetClientPlayer().dwID
	local doodad = GetDoodad(dwDoodadID)
	if not doodad then
		return false
	end
	
	if doodad.nKind == DOODAD_KIND.INVALID then
		return false
	elseif doodad.nKind == DOODAD_KIND.NORMAL then
		return true
	elseif doodad.nKind == DOODAD_KIND.CORPSE then
		if doodad.CanLoot(dwPlayerID) then
			return true
		else
			local doodadTemp = GetDoodadTemplate(doodad.dwTemplateID)
			if doodadTemp and doodadTemp.dwCraftID == 3 then --搜索
				return true
			else
				return false
			end
		end
	elseif doodad.nKind == DOODAD_KIND.QUEST then
		if doodad.HaveQuest(dwPlayerID) then
			return true
		else
			return false
		end
	elseif doodad.nKind == DOODAD_KIND.READ then
		return true
	elseif doodad.nKind == DOODAD_KIND.DIALOG then
		return true
	elseif doodad.nKind == DOODAD_KIND.ACCEPT_QUEST then
		return true
	elseif doodad.nKind == DOODAD_KIND.TREASURE then
		return true
	elseif doodad.nKind == DOODAD_KIND.ORNAMENT then
		return true
	elseif doodad.nKind == DOODAD_KIND.CRAFT_TARGET then
		return true
	elseif doodad.nKind == DOODAD_KIND.CRAFT_TARGET then
		return true
	elseif doodad.nKind == DOODAD_KIND.GUIDE then
		return true
	elseif doodad.nKind == DOODAD_KIND.DOOR then
		if not doodad.IsSelectable() then
			return false
		end
		return true
	else
		return false
	end
	return false
end
