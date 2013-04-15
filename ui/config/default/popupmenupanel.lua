PopupMenuPanel = 
{
	ColorTable = 
	{
		{r = 255	,g = 128	,b = 128},
		{r = 255	,g = 255	,b = 128},
		{r = 128	,g = 255	,b = 128},
		{r = 0		,g = 255	,b = 128},
		{r = 128	,g = 255	,b = 255},
		{r = 0		,g = 128	,b = 255},
		{r = 255	,g = 128	,b = 192},
		{r = 255	,g = 128	,b = 255},
		{r = 255	,g = 0		,b = 0  },
		{r = 255	,g = 255	,b = 0  },
		{r = 128	,g = 255	,b = 0  },
		{r = 0		,g = 255	,b = 64 },
		{r = 0		,g = 255	,b = 255},
		{r = 0		,g = 128	,b = 192},
		{r = 128	,g = 128	,b = 192},
		{r = 255	,g = 0		,b = 255},
		{r = 128	,g = 64		,b = 64 },
		{r = 255	,g = 128	,b = 64 },
		{r = 0		,g = 255	,b = 0  },
		{r = 0		,g = 128	,b = 128},
		{r = 0		,g = 64		,b = 128},
		{r = 128	,g = 128	,b = 255},
		{r = 128	,g = 0		,b = 64 },
		{r = 255	,g = 0		,b = 128},
		{r = 128	,g = 0		,b = 0  },
		{r = 255	,g = 128	,b = 0  },
		{r = 0		,g = 128	,b = 0  },
		{r = 0		,g = 128	,b = 64 },
		{r = 0		,g = 0		,b = 255},
		{r = 0		,g = 0		,b = 160},
		{r = 128	,g = 0		,b = 128},
		{r = 128	,g = 0		,b = 255},
		{r = 64		,g = 0		,b = 0  },
		{r = 128	,g = 64		,b = 0  },
		{r = 0		,g = 64		,b = 0  },
		{r = 0		,g = 64		,b = 64 },
		{r = 0		,g = 0		,b = 128},
		{r = 0		,g = 0		,b = 64 },
		{r = 64		,g = 0		,b = 64 },
		{r = 64		,g = 0		,b = 128},
		{r = 0		,g = 0		,b = 0  },
		{r = 64		,g = 64		,b = 64 },
		{r = 128	,g = 128	,b = 128},
		{r = 255	,g = 255	,b = 255},
		{r = 64		,g = 128	,b = 128},
		{r = 128	,g = 128	,b = 0},
		{r = 128	,g = 128	,b = 64 },
		{r = 64		,g = 32		,b = 64}			
	}
}

function PopupMenuPanel.OnFrameCreate()
	this:Lookup("", ""):Clear()
end

function PopupMenuPanel.OnFrameKeyDown()
	if GetKeyName(Station.GetMessageKey()) == "Esc" then
		if this.fnCancelAction then
			this.fnCancelAction()
		end	
		Wnd.CloseWindow(this:GetName())
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
		return 1
	end
	
	return 0
end

function PopupMenuPanel.OnFrameShow()
	PopupMenuPanel.OnFrameBreathe()
end

function PopupMenuPanel.OnFrameBreathe()
	if this.fnAutoClose and this.fnAutoClose() then
		if this.fnCancelAction then
			this.fnCancelAction()
		end
		Wnd.CloseWindow(this:GetName())
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
	
	local hTotal = this:Lookup("", "")
	local nMenuCount = hTotal:GetItemCount()
	for i = 0, nMenuCount - 1 do
		local hSubMenu = hTotal:Lookup(i)
		if hSubMenu.szType == "menu" then
			local hItemGroup = hSubMenu:Lookup("Handle_Item_Group")
			local nItemCount = hItemGroup:GetItemCount()
			for j = 0, nItemCount - 1 do
				local hItem = hItemGroup:Lookup(j)
				if hItem.tData and hItem.tData.fnDisable then	-- maybe devide
					local bDisable  = hItem.tData.fnDisable()
					if hItem.tData.bDisable ~= bDisable then
						hItem.tData.bDisable = bDisable
						local hText = hItem:Lookup("Text_Content")
						if bDisable then
							hText:SetFontScheme(POPUPMENU_DISABLE_FONT)
						elseif hItem.tData.nFont then
							hText:SetFontScheme(hItem.tData.nFont)
						else
							hText:SetFontScheme(POPUPMENU_ENABLE_FONT)
						end
					end
				end
			end
		end
	end
end
	
function PopupMenuPanel.OnKillFocus()
	if this.fnCancelAction then
		this.fnCancelAction()
	end
	Wnd.CloseWindow(this:GetName())
	PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
end

function PopupMenuPanel.OnItemLButtonDown()
	return 1
end

function PopupMenuPanel.OnItemLButtonClick()
	local frame = this:GetRoot()
	local handle = frame:Lookup("", "")
	local szFrameName = frame:GetName()
	if this:GetParent().bColor then --色盘里的颜色
		local hP = this:GetParent()
		local hFrom = nil
		if hP.hFrom and hP.hFrom:IsValid() then
			hFrom = hP.hFrom
		end
		hP.hFrom = nil
		if hFrom and hFrom.tData then
			local vI = hFrom.tData
			local r, g, b = this:GetColorRGB()
			
			if not vI.bNotChangeSelfColor then
				hFrom:Lookup("Text_Content"):SetFontColor(r, g, b)
			end
			if vI.fnChangeColor then
				vI.fnChangeColor(vI.UserData, r, g, b)
			elseif frame.fnChangeColor then
				frame.fnChangeColor(vI.UserData, r, g, b)
			end
		end
		hP:Hide()
		PlaySound(SOUND.UI_SOUND,g_sound.Button)
		return 1
	end
	
	if this:GetName() == "Image_Color" then
		if this:GetParent().tData.bDisable then
			PlaySound(SOUND.UI_SOUND,g_sound.Button)
			return 1
		end
		
		local szName = this:GetParent():GetName()
		local hC
		if handle.szColor then
			hC = handle:Lookup(handle.szColor)
		end
		if hC then
			hC:SetName(szName)
			handle.szColor = szName
			if hC:IsVisible() then
				hC:Hide()
				PlaySound(SOUND.UI_SOUND,g_sound.Button)
				return 1
			end
		else
			local szIniFile = "UI/Config/default/PopupMenuPanel.ini"	
			handle:AppendItemFromIni(szIniFile, "Handle_Color", szName)
			hC = handle:Lookup(szName)
			handle.szColor = szName
			
			local sH0 = hC:Lookup("Shadow_Color")
			local x, y = sH0:GetRelPos()
			hC:RemoveItem(sH0)

			local nStart = hC:GetItemCount() - 1
			local nX = 0
			for k, v in pairs(PopupMenuPanel.ColorTable) do
				hC:AppendItemFromIni(szIniFile, "Shadow_Color", k)
				local sH = hC:Lookup(nStart + k)
				sH:SetSize(25, 25)
				sH:SetColorRGB(v.r, v.g, v.b)
				sH:SetRelPos(x + nX * 28, y)
				nX = nX + 1
				if nX > 7 then
					nX = 0
					y = y + 28
				end
			end
			nStart = hC:GetItemCount() - 1
			hC:Lookup("Shadow_CCOver"):SetIndex(nStart)
			hC:Lookup("Image_COver"):SetIndex(nStart)
			hC:Lookup("Text_RGB"):SetIndex(nStart)
			hC:FormatAllItemPos()
			PlaySound(SOUND.UI_SOUND,g_sound.Button)
		end
		
		--调整位置
		local hP = this:GetParent()
		local x, y = hP:GetAbsPos()
		local w, h = hP:GetSize()
		x = x + w
		w, h = hC:GetSize()		
		local wCL, hCL = Station.GetClientSize()
		if y + h > hCL then
			local wT, hT = hP:GetSize()
			y = y + hT
			if y - h < 0 then
				y = hCL - h
			else
				y = y - h
			end
		end
		if x + w > wCL then
			x = x - hP:GetSize()
			if x - w < 0 then
				x = wCL - w
			else
				x = x - w
			end
		end
		local x1, y1 = hC:GetParent():GetAbsPos()
		hC:SetRelPos(x - x1, y - y1)
		hC:SetAbsPos(x, y)
		hC:Show()
		hC.hFrom = this:GetParent()
		hC.bColor = true
		
		local nPCEIndex = hC:GetParent():GetItemCount() - 1
		if hC:GetIndex() ~= nPCEIndex then
			hC:SetIndex(nPCEIndex)
			hC:GetRoot():RebuildEventArray()
		end
		return 1
	end
	
	local v = this.tData
	
	if v.bDisable then
		PlaySound(SOUND.UI_SOUND,g_sound.Button)
		return
	end
	
	if v.bMCheck then
		this:Lookup("Image_MCheck"):Show()
		local hParent = this:GetParent()
		local nCount = hParent:GetItemCount() - 1
		local nIndex = this:GetIndex()
		for i = nIndex - 1, 0, -1 do
			local hB = hParent:Lookup(i)
			if not hB.tData then
				break
			end
			hB:Lookup("Image_MCheck"):Hide()
		end
		for i = nIndex + 1, nCount, 1 do
			local hB = hParent:Lookup(i)
			if not hB.tData then
				break
			end
			hB:Lookup("Image_MCheck"):Hide()
		end
		
		if v.fnAction then
			v.fnAction(v.UserData, true)
		elseif frame.fnAction then
			frame.fnAction(v.UserData, true)
		end
		PlaySound(SOUND.UI_SOUND,g_sound.Button)
		return				
	end
	
	if v.bCheck then
		local img = this:Lookup("Image_Check")
		local bCheck
		if img:IsVisible() then
			img:Hide()
			bCheck = false
		else
			img:Show()
			bCheck = true
		end
		if v.fnAction then
			v.fnAction(v.UserData, bCheck)
		elseif frame.fnAction then
			frame.fnAction(v.UserData, bCheck)			
		end
		PlaySound(SOUND.UI_SOUND,g_sound.Button)
		return
	end
	
	if v[1] then
		return
	end
	
	if v.fnAction then
		v.fnAction(v.UserData, true)
	elseif frame.fnAction then
		frame.fnAction(v.UserData, true)		
	end
	Wnd.CloseWindow(szFrameName)
	PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
end

function PopupMenuPanel.OnItemMouseEnter()
	local frame = this:GetRoot()
	local handle = frame:Lookup("", "")
	
	if this.fnMouseEnter then
		this.fnMouseEnter(this)
	end
	
	if this.bColor then
		return
	end
	if this:GetParent().bColor then --色盘里的颜色
		local hP = this:GetParent()
		local x, y = this:GetAbsPos()
		local xR, yR = this:GetRelPos()
		local w, h = this:GetSize()
		local imgO = hP:Lookup("Image_COver")
		imgO:SetSize(w, h)
		imgO:SetAbsPos(x, y) 
		imgO:SetRelPos(xR, yR)
		imgO:Show()
		local r, g, b = this:GetColorRGB()
		local sO = hP:Lookup("Shadow_CCOver")
		sO:SetColorRGB(r, g, b)
		sO:Show()
		local text = hP:Lookup("Text_RGB")
		text:SetText("r="..r..", g="..g..", b="..b..".")
		text:Show()
		return
	end
	
	
	--隐藏低于自己层的子项
	local szSelfName = this:GetName()
	local nLevel = 0
	for w in string.gfind(szSelfName, "%d+") do
		nLevel = nLevel + 1
	end
	local nCount = handle:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hS = handle:Lookup(i)
		if hS:IsVisible() then
			local szLayerName = hS:GetName() 
			local nS = 0
			for w in string.gfind(szLayerName, "%d+") do
				nS = nS + 1
			end
			if nS >= nLevel and szSelfName ~= szLayerName then
				hS:Hide()
			end
		end
	end
	
	local hParent = this:GetParent()
	local nCount = hParent:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = hParent:Lookup(i)
		if hI.tData then
			hI:Lookup("Image_Over"):Hide()
		end
	end
	
	if this.tData.bDisable then
		return
	end
		
	this:Lookup("Image_Over"):Show()
	if this:Lookup("Image_Child"):IsVisible() then
		local szName = this:GetName()
		local hS = handle:Lookup(szName)
		if not hS then
			frame.AppendChildMenu(handle, szName, this.tData)
			hS = handle:Lookup(szName)
		end
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		x = x + w
		w, h = hS:GetSize()		
		local wC, hC = Station.GetClientSize()
		if y + h > hC then
			local wT, hT = this:GetSize()
			y = y + hT
			if y - h < 0 then
				y = hC - h
			else
				y = y - h
			end
		end
		if x + w > wC then
			x = x - this:GetSize()
			if x - w < 0 then
				x = wC - w
			else
				x = x - w
			end
		end
		local x1, y1 = hS:GetParent():GetAbsPos()
		hS:SetRelPos(x - x1, y - y1)
		hS:SetAbsPos(x, y)
		hS:Show()
	end
end

function PopupMenuPanel.OnItemMouseLeave()
	local handle = this:GetRoot():Lookup("", "")
	
	if this.fnMouseEnter then
		HideTip()
	end
	
	if this.bColor then
		return
	end	
	if this:GetParent().bColor then --色盘里的颜色
		local hP = this:GetParent()
		hP:Lookup("Image_COver"):Hide()
		hP:Lookup("Shadow_CCOver"):Hide()
		hP:Lookup("Text_RGB"):Hide()
		return
	end
	local hC = handle:Lookup(this:GetName())
	if hC and hC:IsVisible() then
		return
	end

	this:Lookup("Image_Over"):Hide()
end
					
					
function InsertMarkMenu(tMenu, dwCharacterID, bDisable)
	tSubMenu = { szOption = g_tStrings.STR_MARK_TARGET, bDisable = bDisable}
	for nKey, nVal in pairs(PARTY_MARK_ICON_FRAME_LIST) do
		table.insert(
			tSubMenu, 
			{
				szIcon = PARTY_MARK_ICON_PATH, 
				nFrame = nVal, 
				szLayer = "ICON_CENTER", 
				fnAction = function() GetClientTeam().SetTeamMark(nKey, dwCharacterID) end
			}
		)	
	end
	table.insert(
		tSubMenu, 
		{
			szOption = g_tStrings.STR_MARK_TARGET_NONE, 
			fnAction = function() GetClientTeam().SetTeamMark(0, dwCharacterID) end
		}
	)	
	table.insert(tMenu, tSubMenu)
	return true
end

function InsertPlayerCommonMenu(tMenu, dwPlayerID, szPlayerName)
	local hPlayer = GetPlayer(dwPlayerID)
	local hClientPlayer = GetClientPlayer()
	local tSubMenu = nil
	
	tSubMenu =
	{
		szOption = g_tStrings.STR_SAY_SECRET, 
		fnAction = function() EditBox_TalkToSomebody(szPlayerName) end
	}
	table.insert(tMenu, tSubMenu)
	
	tSubMenu =
	{
		szOption = g_tStrings.STR_MAKE_FRIEND, 
		fnAction = function() 
            if CheckPlayerIsRemote() or CheckPlayerIsRemote(dwPlayerID) then 
                return 
            end
            GetClientPlayer().AddFellowship(szPlayerName) 
        end
	}
	table.insert(tMenu, tSubMenu)
	
	local bGuildDisable = hClientPlayer.dwTongID == 0
	if hClientPlayer.IsPlayerInMyParty(dwPlayerID) then
		local hTeam = GetClientTeam()
		local tMemberInfo = hTeam.GetMemberInfo(dwPlayerID)
		if not tMemberInfo.bIsOnLine then
			bGuildDisable = true
		end
	end
	tSubMenu =
	{
		szOption = g_tStrings.INVITE_ADD_GUILD, 
		bDisable = bGuildDisable, 
		fnAction = function() 
            if CheckPlayerIsRemote() or CheckPlayerIsRemote(dwPlayerID) then 
                return 
            end
            InvitePlayerJoinTong(szPlayerName) 
        end
	}
	table.insert(tMenu, tSubMenu)
	
	tSubMenu =
	{
		szOption = g_tStrings.STR_FOLLOW, 
		bDisable = (hPlayer == nil), 
		fnAction = function() StartFollow(TARGET.PLAYER, dwPlayerID) 
			if not GetClientPlayer().IsAchievementAcquired(1002) then
				RemoteCallToServer("OnClientAddAchievement", "Fellow")
			end
		end
	}
	table.insert(tMenu, tSubMenu)	
end

function InsertDistributeMenu(menu, bDisable)
	local fnIsCLootMode = function(nMode)
		local nC = GetClientTeam().nLootMode
		if not nC then
			return false
		end
		if nMode == nC then
			return true
		end
		return false
	end
	local fnIsCRquallty = function(nQuallity)
		local nQ = GetClientTeam().nRollQuality
		if not nQ then
			return false
		end
		if nQuallity == nQ then
			return true
		end
		return false
	end

	local mL = 	{
		szOption = g_tStrings.STR_LOOT_MODE, 
		{szOption = g_tStrings.STR_LOOTMODE_FREE_FOR_ALL, bDisable = bDisable, bMCheck = true, bChecked = fnIsCLootMode(PARTY_LOOT_MODE.FREE_FOR_ALL), fnAction = function() GetClientTeam().SetTeamLootMode(PARTY_LOOT_MODE.FREE_FOR_ALL) end },
		{szOption = g_tStrings.STR_LOOTMODE_DISTRIBUTE, bDisable = bDisable, bMCheck = true, bChecked = fnIsCLootMode(PARTY_LOOT_MODE.DISTRIBUTE), fnAction = function() GetClientTeam().SetTeamLootMode(PARTY_LOOT_MODE.DISTRIBUTE) end },
		{szOption = g_tStrings.STR_LOOTMODE_GROUP_LOOT, bDisable = bDisable, bMCheck = true, bChecked = fnIsCLootMode(PARTY_LOOT_MODE.GROUP_LOOT), fnAction = function() GetClientTeam().SetTeamLootMode(PARTY_LOOT_MODE.GROUP_LOOT) end }
	}		
	table.insert(menu, mL)
	
	local mQ = 	{
		szOption = g_tStrings.STR_LOOT_LEVEL, 
		{szOption = g_tStrings.STR_ROLLQUALITY_GREEN, nFont = 79, bDisable = bDisable, bMCheck = true, bChecked = fnIsCRquallty(2), fnAction = function() GetClientTeam().SetTeamRollQuality(2) end },
		{szOption = g_tStrings.STR_ROLLQUALITY_BLUE, nFont = 76, bDisable = bDisable, bMCheck = true, bChecked = fnIsCRquallty(3), fnAction = function() GetClientTeam().SetTeamRollQuality(3) end },
		{szOption = g_tStrings.STR_ROLLQUALITY_PURPLE, nFont = 73, bDisable = bDisable, bMCheck = true, bChecked = fnIsCRquallty(4), fnAction = function() GetClientTeam().SetTeamRollQuality(4) end },
		{szOption = g_tStrings.STR_ROLLQUALITY_NACARAT, nFont = 70, bDisable = bDisable, bMCheck = true, bChecked = fnIsCRquallty(5), fnAction = function() GetClientTeam().SetTeamRollQuality(5) end }
	}
	table.insert(menu, mQ)	
end

function InsertPlayerCampMenu(tMenu)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	
	if hPlayer.nCamp == CAMP.NEUTRAL then
		return
	end
	
	local tSubMenu = nil
	if hPlayer.bCampFlag then
		tSubMenu = 
		{
			szOption = g_tStrings.STR_CLOSE_CAMP_FLAG, 
			bDisable = not (GetClientPlayer().CanCloseCampFlag()), 
			fnAction = function()
				RemoteCallToServer("OnCloseCampFlag")
			end
		}
	else
		local tMsg = 
		{
			szMessage = g_tStrings.STR_CONFIRM_MSG_CAMP_FLAG,
			szName = "Camp_Flag_Confirm_Msg",
			{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() RemoteCallToServer("OnOpenCampFlag") end, },
			{szOption = g_tStrings.STR_HOTKEY_CANCEL, },
		}
		tSubMenu = 
		{
			szOption = g_tStrings.STR_OPEN_CAMP_FLAG, 
			bDisable = not (GetClientPlayer().CanOpenCampFlag()), 
			fnAction = function() MessageBox(tMsg) end
		}
	end
	table.insert(tMenu, tSubMenu)
	return true
end

function InsertPlayerMenu(menu)
	local frame = this:GetRoot()
	local player = GetClientPlayer()
	local dwID = player.dwID
	if player.IsInParty() then
		local hTeam = GetClientTeam()
		local dwDistribute = hTeam.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.DISTRIBUTE)
		local dwMark = hTeam.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.MARK)
		
		InsertDistributeMenu(menu, dwDistribute ~= dwID or hTeam.bSystem)
		
		if dwMark == dwID then
			InsertMarkMenu(menu, dwID)
		end
		
		if player.IsPartyLeader() then
			local tSubMenu = 
			{
				szOption = g_tStrings.STR_TEAMMATE_LEVELUP_RAID, 
				bDisable = (player.nLevel < CONVERT_RAID_PLAYER_MIN_LEVEL or hTeam.nGroupNum > 1),
				fnAction = function() ConvertToRaid() end
			}
			table.insert(menu, tSubMenu)
			
			if dwDistribute ~= dwID then
				table.insert(menu, {szOption = g_tStrings.STR_LEADER_OPTION_TAKEBACK_DISTRIBUTE_RIGHT, fnAction = function() GetClientTeam().SetAuthorityInfo(TEAM_AUTHORITY_TYPE.DISTRIBUTE, dwID) end})
			end
			
			if dwMark ~= dwID then
				table.insert(menu, {szOption = g_tStrings.STR_LEADER_OPTION_TAKEBACK_MARK_RIGHT, fnAction = function() GetClientTeam().SetAuthorityInfo(TEAM_AUTHORITY_TYPE.MARK, dwID) end})
			end
			
			local nGroupID = hTeam.GetMemberGroupIndex(player.dwID)
			local tGroupInfo = hTeam.GetGroupInfo(nGroupID)
			if tGroupInfo.dwFormationLeader ~= dwID then
				table.insert(menu, {szOption = g_tStrings.STR_LEADER_OPTION_TAKEBACK_PARTY_LEADER, fnAction = function() GetClientTeam().SetTeamFormationLeader(dwID, nGroupID) end})
			end	
			table.insert(menu, {szOption = g_tStrings.STR_LEAVE_PARTY, bDisable = hTeam.bSystem, fnAction = function() GetClientTeam().RequestLeaveTeam() end})		
			
		else
			table.insert(menu, {szOption = g_tStrings.STR_LEAVE_PARTY, bDisable = hTeam.bSystem, fnAction = function() GetClientTeam().RequestLeaveTeam() end})
		end
		
		--local _,_,szVersionLineName,szVersionType = GetVersion()
		--if szVersionLineName == "zhcn" and szVersionType == "exp" then
			if IsInUseYY() then
				table.insert(menu, {szOption = g_tStrings.END_USE_TEAM_YY, fnAction = function() EndUseYY() end})
			else
				table.insert(menu, {szOption = g_tStrings.BEGIN_USE_TEAM_YY, fnAction = function() BeginUseYY() end})
			end
		--end
		
		table.insert(menu, {bDevide = true})
		local tSubMenu = { 
			szOption = g_tStrings.STR_TEAM_PARTY_SYNC_CLOSE,
			bCheck = true,
			bChecked = (not IsSyncTeamFightData()),
			UserData = "",
			fnAction = function(UserData, bCheck) 
				SetTeamSkillEffectSyncOption(not bCheck) 
				SetSyncTeamFightDataState(not bCheck) 
			end,
			
			fnMouseEnter = function(hItem)
				local x, y = hItem:GetAbsPos()
				local w, h = hItem:GetSize()
				local szTip = g_tStrings.STR_TEAM_PARTY_SYNC
				OutputTip(szTip, 335, {x, y, w, h})
			end
		}
		table.insert(menu, tSubMenu)
	else
		--local _,_,szVersionLineName,szVersionType = GetVersion()
		--if szVersionLineName == "zhcn" and szVersionType == "exp" then
			table.insert(menu, {szOption = g_tStrings.BEGIN_USE_TEAM_YY, bDisable = true, fnAction = function() BeginUseYY() end})	
		--end
	end
		
	table.insert(menu, {bDevide = true})
	--[[
	local mD = 
	{	
		szOption = g_tStrings.STR_DUNGEON_MODE, 
		{szOption = g_tStrings.STR_DUNGEON_NORMAL_MODE, bMCheck = true, bChecked = not player.bHeroFlag, fnAction = function() player.bHeroFlag = false end, fnAutoClose = function() return true end},
		{szOption = g_tStrings.STR_DUNGEON_HARD_MODE, bMCheck = true,  bDisable = (player.nLevel < 70), bChecked = player.bHeroFlag, fnAction = function() player.bHeroFlag = true end, fnAutoClose = function() return true end},
	}
	table.insert(menu, mD)
	]]
    if not player.IsInParty() or player.IsPartyLeader() then
        table.insert(menu, {szOption = g_tStrings.STR_DUNGEON_REFRESH_ALL,  fnAction = function() DungeonInfoPanel.RefreshAll(); end})
    end
    
	local tMsg = 
	{
		szMessage = FormatString(g_tStrings.STR_SLAY_CONFIRM_MSG, g_tStrings.STR_START_SLAY),
		szName = "Slay_Confirm_Msg",
		{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() GetClientPlayer().ApplySlay(); FireHelpEvent("OnSlaughter") end, },
		{szOption = g_tStrings.STR_HOTKEY_CANCEL, },
	}		
	
	
	-- slay
	if player.IsOnSlay() then
		table.insert(menu, {bDevide = true})
		table.insert(menu, {szOption = g_tStrings.STR_CLOSE_SLAY, bDisable = not (GetClientPlayer().CanCloseSlay()), fnAction = function() GetClientPlayer().CloseSlay(); end})
	end
	--[[
	else
		table.insert(menu, {szOption = g_tStrings.STR_START_SLAY, bDisable = not (GetClientPlayer().CanApplySlay()), fnAction = function() MessageBox(tMsg) end})	
	end
	--]]
	-- camp
	if player.nCamp ~= CAMP.NEUTRAL then
		table.insert(menu, {bDevide = true})
		InsertPlayerCampMenu(menu)
	end
	
	--mini avatar
	table.insert(menu, {szOption = g_tStrings.STR_CHANGE_MINI_AVATAR, fnAction = function() OpenRoleChangePanel() end})
	
	if IsCanBulletShow() then --唐门
		table.insert(menu, {bDevide = true})
		table.insert(menu, {szOption = g_tStrings.STR_OPEN_BULLET, bCheck = true, bChecked=IsBulletOpen(),
			fnAction = function(UserData, bCheck) 
				SetBulletShow(bCheck)
				if bCheck then 
					OpenBullet() 
				else
					CloseBullet()
				end
		    end})
	end
	return true
end

function InsertPlayerKungfuMenu(tMenu, player)
	local szNow = g_tStrings.STR_CURRENT_KUNGFU
	local curKungfu = player.GetKungfuMount()
	local listKungfu, nCount = player.GetAllMountKungfu()
	
	szNow = szNow .. curKungfu.szSkillName
	table.insert(tMenu, {szOption = szNow})
end

function InsertTeammateLeaderMenu(tMenu, dwMemberID)
	local hPlayer = GetClientPlayer()
	if not hPlayer.IsInParty() or not hPlayer.IsPlayerInMyParty(dwMemberID) then
		return false
	end
	
	local hTeam = GetClientTeam()
	local tMemberInfo = hTeam.GetMemberInfo(dwMemberID)
	local bOffline = not tMemberInfo.bIsOnLine
	local nMemberGroupID = hTeam.GetMemberGroupIndex(dwMemberID)
	local nMyGroupID = hTeam.GetMemberGroupIndex(hPlayer.dwID)
	local tMyGroupInfo = hTeam.GetGroupInfo(nMyGroupID)

	if hPlayer.IsPartyLeader() then		
		tSubMenu = 
		{
			szOption = g_tStrings.STR_TEAMMATE_CHANGE_PARTY_LEADER, 
			bDisable = bOffline, 
			fnAction = function() GetClientTeam().SetAuthorityInfo(TEAM_AUTHORITY_TYPE.LEADER, dwMemberID) end
		}
		table.insert(tMenu, tSubMenu)

		if hTeam.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.DISTRIBUTE) == dwMemberID then
			tSubMenu = 
			{
				szOption = g_tStrings.STR_LEADER_OPTION_TAKEBACK_DISTRIBUTE_RIGHT, 
				bDisable = bOffline, 
				fnAction = function() GetClientTeam().SetAuthorityInfo(TEAM_AUTHORITY_TYPE.DISTRIBUTE, GetClientPlayer().dwID) end
			}
			table.insert(tMenu, tSubMenu)
		else
			tSubMenu = 
			{
				szOption = g_tStrings.STR_LEADER_OPTION_CHANGE_DISTRIBUTE_RIGHT, 
				bDisable = bOffline, 
				fnAction = function() GetClientTeam().SetAuthorityInfo(TEAM_AUTHORITY_TYPE.DISTRIBUTE, dwMemberID) end
			}
			table.insert(tMenu, tSubMenu)
		end
		
		if hTeam.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.MARK) == dwMemberID then
			tSubMenu = 
			{
				szOption = g_tStrings.STR_LEADER_OPTION_TAKEBACK_MARK_RIGHT, 
				bDisable = bOffline, 
				fnAction = function() GetClientTeam().SetAuthorityInfo(TEAM_AUTHORITY_TYPE.MARK, GetClientPlayer().dwID) end
			}
			table.insert(tMenu, tSubMenu)
		else
			tSubMenu = 
			{
				szOption = g_tStrings.STR_LEADER_OPTION_CHANGE_MARK_RIGHT, 
				bDisable = bOffline, 
				fnAction = function() GetClientTeam().SetAuthorityInfo(TEAM_AUTHORITY_TYPE.MARK, dwMemberID) end
			}
			table.insert(tMenu, tSubMenu)
		end
		
		if tMyGroupInfo.dwFormationLeader == dwMemberID then
			tSubMenu = 
			{
				szOption = g_tStrings.STR_LEADER_OPTION_TAKEBACK_PARTY_LEADER, 
				bDisable = bOffline, 
				fnAction = function() GetClientTeam().SetTeamFormationLeader(GetClientPlayer().dwID, nMyGroupID) end
			}
			table.insert(tMenu, tSubMenu)
			
		else
			tSubMenu = 
			{
				szOption = g_tStrings.STR_LEADER_OPTION_CHANGE_PARTY_LEADER, 
				bDisable = bOffline, 
				fnAction = function() GetClientTeam().SetTeamFormationLeader(dwMemberID, nMemberGroupID) end
			}
			table.insert(tMenu, tSubMenu)
		end
		
		tSubMenu = 
		{
			szOption = g_tStrings.STR_TEAMMATE_KICKOUT_MENBER, 
			bDisable = hTeam.bSystem, 
			fnAction = function() GetClientTeam().TeamKickoutMember(tMemberInfo.szName) end
		}
		table.insert(tMenu, tSubMenu)
	else
		if hTeam.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.DISTRIBUTE) == hPlayer.dwID then
			tSubMenu = 
			{
				szOption = g_tStrings.STR_LEADER_OPTION_CHANGE_DISTRIBUTE_RIGHT, 
				fnAction = function() GetClientTeam().SetAuthorityInfo(TEAM_AUTHORITY_TYPE.DISTRIBUTE, dwMemberID) end
			}
			table.insert(tMenu, tSubMenu)
		end
		if hTeam.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.MARK) == hPlayer.dwID then
			tSubMenu = 
			{
				szOption = g_tStrings.STR_LEADER_OPTION_CHANGE_MARK_RIGHT, 
				fnAction = function() GetClientTeam().SetAuthorityInfo(TEAM_AUTHORITY_TYPE.MARK, dwMemberID) end
			}
			table.insert(tMenu, tSubMenu)
		end
		if tMyGroupInfo.dwFormationLeader == hPlayer.dwID and nMyGroupID == nMemberGroupID then
			tSubMenu =
			{
				szOption = g_tStrings.STR_LEADER_OPTION_CHANGE_PARTY_LEADER, 
				fnAction = function() GetClientTeam().SetTeamFormationLeader(dwMemberID, nMemberGroupID) end
			}
			table.insert(tMenu, tSubMenu)
		end
	end
	return true
end

function InsertTeammateMenu(tMenu, dwMemberID)
	local tSubMenu = nil
	
	local hPlayer = GetClientPlayer()
	if not hPlayer.IsInParty() or not hPlayer.IsPlayerInMyParty(dwMemberID) then
		return false
	end
	
	local hTeam = GetClientTeam()
	local tMemberInfo = hTeam.GetMemberInfo(dwMemberID)
		
	if hTeam.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.MARK) ==  hPlayer.dwID then
		InsertMarkMenu(tMenu, dwMemberID, not tMemberInfo.bIsOnLine)
	end
	
	if InsertTeammateLeaderMenu(tMenu, dwMemberID) then
		table.insert(tMenu, {bDevide = true})
	end
	
	local szMemberName = GetTeammateName(dwMemberID)
	InsertPlayerCommonMenu(tMenu, dwMemberID, szMemberName)
	
	return true
end
