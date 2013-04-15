-------------LULU的师徒界面------------------
---------Created by Hu Chang Yin-------------
--           云想衣裳花想容                --
--           春风拂栏露华浓                --
--           若非群玉山头见                --
--           会向瑶台月下逢                --
---------------------------------------------

MentorPanel = 
{
	aMyMaster = {},
	aMyDirectMaster = {},
	aMyApprentice = {},
	aMyDirectApprentice = {},
	aMaster = {},
	aApprentice = {},
	nMinPlayerLevelAsMentor = 80,
}

RegisterCustomData("MentorPanel.aMaster")
RegisterCustomData("MentorPanel.aApprentice")

function MentorPanel.OnFrameCreate()
	InitFrameAutoPosInfo(this, 2, nil, nil, function() CloseMentorPanel(true) end)
	
	this:RegisterEvent("ON_GET_MENTOR_LIST")
	this:RegisterEvent("ON_GET_DIRECT_MENTOR_LIST")
	this:RegisterEvent("ON_GET_APPRENTICE_LIST")
	this:RegisterEvent("ON_GET_DIRECT_APPRENTICE_LIST")
	this:RegisterEvent("ON_SYNC_MENTOR_DATA")
	this:RegisterEvent("ON_SYNC_ACQUIRED_MVALUE")
	this:RegisterEvent("ON_SYNC_LEFT_EVOKE_NUM")
	this:RegisterEvent("ON_SYNC_MAX_APPRENTICE_NUM")
	this:RegisterEvent("ON_SYNC_USABLE_MVALUE")
	this:RegisterEvent("NEED_REQUAIRE_MENTOR_LIST")
	this:RegisterEvent("NEED_REQUAIRE_DIRECT_MENTOR_LIST")
	this:RegisterEvent("NEED_REQUAIRE_APPRENTICE_LIST")
	this:RegisterEvent("NEED_REQUAIRE_DIRECT_APPRENTICE_LIST")
	this:RegisterEvent("ON_BREAK_MENTOR_RESULT")
	this:RegisterEvent("ON_BREAK_APPRENTICE_RESULT")
	this:RegisterEvent("ON_CANCEL_BREAK_MENTOR_RESULT")
	this:RegisterEvent("ON_CANCEL_BREAK_APPRENTICE_RESULT")
	this:RegisterEvent("UPDATE_MENTOR_DATA")
	this:RegisterEvent("UPDATE_APPRENTICE_DATA")
    this:RegisterEvent("ON_GET_DIRECT_MENTOR_RIGHT")
    this:RegisterEvent("BREAK_MENTOR_NOTIFY")
    this:RegisterEvent("BREAK_APPRENTICE_NOTIFY")
    this:RegisterEvent("ON_IS_ACCOUNT_DIRECT_APPRENTICE")
end

function MentorPanel.OnEvent(event)
	if event == "ON_GET_MENTOR_LIST" then
		if arg0 == GetClientPlayer().dwID then
			MentorPanel.aMyMaster = arg1 or {}
			table.sort(MentorPanel.aMyMaster, function (a, b) return a.nCreateTime < b.nCreateTime end)
			for k, v in pairs(MentorPanel.aMyMaster) do
				v.szRelation = g_tStrings.aMaster[k]
				v.bOnLine = v.nOfflineTime == 0
				v.bDelete = not v.szName or v.szName == ""
				if v.bDelete then
					v.szName = g_tStrings.MENTOR_DELETE_ROLE
				end
				RemoteCallToServer("OnGetApprenticeListRequest", v.dwID)
			end
			table.sort(MentorPanel.aMyMaster, function (a, b) return a.bOnLine and not b.bOnLine end)
			MentorPanel.UpdateMaster(this)
		end
	elseif event == "ON_GET_DIRECT_MENTOR_LIST" then
		if arg0 == GetClientPlayer().dwID then
			MentorPanel.aMyDirectMaster = arg1 or {}
			table.sort(MentorPanel.aMyDirectMaster, function (a, b) return a.nCreateTime < b.nCreateTime end)
			for k, v in pairs(MentorPanel.aMyDirectMaster) do
				v.szRelation = g_tStrings.DIRECT_MASTER --g_tStrings.aMaster[k]
				v.bOnLine = v.nOfflineTime == 0
				v.bDelete = not v.szName or v.szName == ""
				if v.bDelete then
					v.szName = g_tStrings.MENTOR_DELETE_ROLE
				end
				RemoteCallToServer("OnGetDirApprenticeListRequest", v.dwID)
			end
			table.sort(MentorPanel.aMyDirectMaster, function (a, b) return a.bOnLine and not b.bOnLine end)
			MentorPanel.UpdateMaster(this)
		end
	elseif event == "ON_GET_APPRENTICE_LIST" then
		if arg0 == GetClientPlayer().dwID then
			MentorPanel.aMyApprentice = arg1 or {}
			table.sort(MentorPanel.aMyApprentice, function (a, b) return a.nCreateTime < b.nCreateTime end)
			for k, v in pairs(MentorPanel.aMyApprentice) do
				v.bOnLine = v.nOfflineTime == 0
				v.bDelete = not v.szName or v.szName == ""
				if v.bDelete then
					v.szName = g_tStrings.MENTOR_DELETE_ROLE
				end
			end
			table.sort(MentorPanel.aMyApprentice, function (a, b) return a.bOnLine and not b.bOnLine end)
			MentorPanel.UpdateApprentice(this)
		else
			MentorPanel.aMyMaster = MentorPanel.aMyMaster or {}
			for k, v in pairs(MentorPanel.aMyMaster) do
				if v.dwID == arg0 then
					arg1 = arg1 or {}
					table.sort(arg1, function (a, b) return a.nCreateTime < b.nCreateTime end)
					
					local bOlder = true
					local szName = GetClientPlayer().szName
					for k, v in pairs(arg1) do
						if v.szName == szName then
							v.szRelation = g_tStrings.MENTOR_SELF
							v.bOnLine = true
							v.bSelf = true
							bOlder = false
						else
							if bOlder then
								if IsRoleMale(v.nRoleType) then
									v.szRelation = g_tStrings.aApprentice1[k]
								else
									v.szRelation = g_tStrings.aApprentice2[k]
								end
							else
								if IsRoleMale(v.nRoleType) then
									v.szRelation = g_tStrings.aApprentice3[k]
								else
									v.szRelation = g_tStrings.aApprentice4[k]
								end
							end
							v.bOnLine = v.nOfflineTime == 0
							v.bDelete = not v.szName or v.szName == ""
							if v.bDelete then
								v.szName = g_tStrings.MENTOR_DELETE_ROLE
							end							
						end
					end
					table.sort(MentorPanel.aMyMaster, function (a, b) return a.bOnLine and not b.bOnLine end)
					v.aApprentice = arg1
					MentorPanel.UpdateMaster(this)
					break
				end
			end
		end
	elseif event == "ON_GET_DIRECT_APPRENTICE_LIST" then
		if arg0 == GetClientPlayer().dwID then
			MentorPanel.aMyDirectApprentice = arg1 or {}
			table.sort(MentorPanel.aMyDirectApprentice, function (a, b) return a.nCreateTime < b.nCreateTime end)
			for k, v in pairs(MentorPanel.aMyDirectApprentice) do
				v.bOnLine = v.nOfflineTime == 0
				v.bDelete = not v.szName or v.szName == ""
				if v.bDelete then
					v.szName = g_tStrings.MENTOR_DELETE_ROLE
				end
			end
			table.sort(MentorPanel.aMyDirectApprentice, function (a, b) return a.bOnLine and not b.bOnLine end)
			MentorPanel.UpdateApprentice(this)
		else
			MentorPanel.aMyDirectMaster = MentorPanel.aMyDirectMaster or {}
			for k, v in pairs(MentorPanel.aMyDirectMaster) do
				if v.dwID == arg0 then
					arg1 = arg1 or {}
					table.sort(arg1, function (a, b) return a.nCreateTime < b.nCreateTime end)
					
					local bOlder = true
					local szName = GetClientPlayer().szName
					for k, v in pairs(arg1) do
						if v.szName == szName then
							v.szRelation = g_tStrings.MENTOR_SELF
							v.bOnLine = true
							v.bSelf = true
							bOlder = false
						else
							if bOlder then
								if IsRoleMale(v.nRoleType) then
									v.szRelation = g_tStrings.aApprentice1[k]
								else
									v.szRelation = g_tStrings.aApprentice2[k]
								end
							else
								if IsRoleMale(v.nRoleType) then
									v.szRelation = g_tStrings.aApprentice3[k]
								else
									v.szRelation = g_tStrings.aApprentice4[k]
								end
							end
							v.bOnLine = v.nOfflineTime == 0
							v.bDelete = not v.szName or v.szName == ""
							if v.bDelete then
								v.szName = g_tStrings.MENTOR_DELETE_ROLE
							end							
						end
					end
					table.sort(MentorPanel.aMyDirectMaster, function (a, b) return a.bOnLine and not b.bOnLine end)
					v.aApprentice = arg1
					MentorPanel.UpdateMaster(this)
					break
				end
			end
		end	
	elseif event == "ON_SYNC_MENTOR_DATA" then
		MentorPanel.UpdateCallTime(this)
		MentorPanel.UpdateMentorValue(this)
		MentorPanel.UpdateApprenticeAndMentorCount(this)
		MentorPanel.UpdateFindBtnState(this)
	elseif event == "ON_SYNC_ACQUIRED_MVALUE" then -- 已获得师徒数据更新
		MentorPanel.UpdateMentorValue(this)
	elseif event == "ON_SYNC_LEFT_EVOKE_NUM" then
		MentorPanel.UpdateCallTime(this)
	elseif event == "ON_SYNC_MAX_APPRENTICE_NUM" then
		MentorPanel.UpdateApprenticeAndMentorCount(this)
		MentorPanel.UpdateFindBtnState(this)
	elseif event == "ON_SYNC_USABLE_MVALUE" then
		-- 可用师徒值变了 
		MentorPanel.UpdateMentorValue(this)
	elseif event == "NEED_REQUAIRE_MENTOR_LIST" or event == "NEED_REQUAIRE_APPRENTICE_LIST" then
		local dwID = GetClientPlayer().dwID
		RemoteCallToServer("OnGetMentorListRequest", dwID)
		RemoteCallToServer("OnGetApprenticeListRequest", dwID)
	elseif event == "NEED_REQUAIRE_DIRECT_MENTOR_LIST" or event == "NEED_REQUAIRE_DIRECT_APPRENTICE_LIST" then
		local dwID = GetClientPlayer().dwID
		RemoteCallToServer("OnGetDirectMentorListRequest", dwID)
		RemoteCallToServer("OnGetDirApprenticeListRequest", dwID)
	elseif event == "ON_BREAK_MENTOR_RESULT" or 
    event == "ON_CANCEL_BREAK_MENTOR_RESULT" or 
    event == "BREAK_MENTOR_NOTIFY" or 
    event == "BREAK_APPRENTICE_NOTIFY" then
		if arg0.nState == 0 then
			local dwID = GetClientPlayer().dwID
			RemoteCallToServer("OnGetMentorListRequest", dwID)
			RemoteCallToServer("OnGetApprenticeListRequest", dwID)		
		else
			for k, v in pairs(MentorPanel.aMyMaster) do
				if v.dwID == arg0.dwID then
					v.nState = arg0.nState
					v.nEndTime = arg0.nEndTime
					MentorPanel.UpdateMasterState(this, v)
					break
				end
			end
		end
	elseif event == "ON_BREAK_APPRENTICE_RESULT" or event == "ON_CANCEL_BREAK_APPRENTICE_RESULT" then
		if arg0.nState == 0 then
			local dwID = GetClientPlayer().dwID
			RemoteCallToServer("OnGetMentorListRequest", dwID)
			RemoteCallToServer("OnGetApprenticeListRequest", dwID)		
		else
			for k, v in pairs(MentorPanel.aMyApprentice) do
				if v.dwID == arg0.dwID then
					v.nState = arg0.nState
					v.nEndTime = arg0.nEndTime
					MentorPanel.UpdateApprenticeState(this, v)
					break
				end
			end
		end
	elseif event == "UPDATE_MENTOR_DATA" then
		RemoteCallToServer("OnGetMentorListRequest", arg0)
	elseif event == "UPDATE_APPRENTICE_DATA" then
		RemoteCallToServer("OnGetApprenticeListRequest", arg0)
    elseif event == "ON_GET_DIRECT_MENTOR_RIGHT" then
        MentorPanel.bCanBeDirectMentor = arg0
        MentorPanel.bCanBeDirectApprentice = arg1
        MentorPanel.UpdateRoleState(this)
    elseif event == "ON_IS_ACCOUNT_DIRECT_APPRENTICE" then
        local szAccountTip = ""
        if arg0 then
            szAccountTip = g_tStrings.MENTOR_ACCOUNT_DIRECT_MENTOR_TIP
        else
            szAccountTip = g_tStrings.MENTOR_ACCOUNT_DIRECT_APPRENTICE_TIP
        end
        this.szAccountTip = GetFormatText(szAccountTip, 106)
	end
end

function MentorPanel.UpdateRoleState(hFrame)
    local hPageTotal = hFrame:Lookup("PageSet_Total")
    local szText = g_tStrings.MENTOR_ROLE_STATE
    if MentorPanel.bCanBeDirectMentor then
        szText = szText .. g_tStrings.MENTOR_CAN_BE_DIRECT_MENTOR
    elseif MentorPanel.bCanBeDirectApprentice then
        szText = szText .. g_tStrings.MENTOR_CAN_BE_DIRECT_APPRENTICE
    else
        szText = szText .. g_tStrings.MENTOR_CAN_NOT_BE_DIRECT
    end
    local hTextRoleState = hPageTotal:Lookup("Page_Master", "Text_MasterNum1")
    hTextRoleState:SetText(szText)
    
    hTextRoleState = hPageTotal:Lookup("Page_Apprentice", "Text_MasterNum2")
    hTextRoleState:SetText(szText)
end

function MentorPanel.UpdateMasterState(frame, v)
	local hList = frame:Lookup("PageSet_Total/Page_Master", "Handle_MasterList")	
	local nCount = hList:GetItemCount()	- 1
	for i = 0, nCount, 1 do
		local hI = hList:Lookup(i)
		if hI.bMaster and hI.dwID == v.dwID then
			MentorPanel.UpdateMasterStateSingle(hI, v)
			if hI.bSel then
				hI.bSel = false
				MentorPanel.Sel(hI)
			end
			break
		end
	end
end

function MentorPanel.UpdateApprenticeState(frame, v)
	local hList = frame:Lookup("PageSet_Total/Page_Apprentice", "Handle_ApprenticeList")	
	local nCount = hList:GetItemCount()	- 1
	for i = 0, nCount, 1 do
		local hI = hList:Lookup(i)
		if hI.dwID == v.dwID then
			MentorPanel.UpdateApprenticeStateSingle(hI, v)
			if hI.bSel then
				hI.bSel = false
				MentorPanel.Sel(hI)
			end
			break
		end
	end
end

function MentorPanel.Update(frame)
	local dwNow = GetTickCount()
	if not MentorPanel.dwLast or dwNow - MentorPanel.dwLast > 1000 then
		MentorPanel.dwLast = dwNow

		MentorPanel.aMyMaster = {}
		MentorPanel.aMyApprentice = {}
		MentorPanel.aMyDirectMaster = {}
		MentorPanel.aMyDirectApprentice = {}

		local dwID = GetClientPlayer().dwID
		RemoteCallToServer("OnGetMentorListRequest", dwID)
		RemoteCallToServer("OnGetApprenticeListRequest", dwID)
		RemoteCallToServer("OnGetDirectMentorListRequest", dwID)
		RemoteCallToServer("OnGetDirApprenticeListRequest", dwID)
		RemoteCallToServer("OnApplyEvokeMentorCount")
	end	
	RemoteCallToServer("OnGetDirectMentorRight")
    RemoteCallToServer("OnIsAccountDirectApprentice")

	MentorPanel.UpdateMaster(frame)
	MentorPanel.UpdateApprentice(frame)
    MentorPanel.UpdateFindMaster(frame)
    MentorPanel.UpdateFindApprentice(frame)
	MentorPanel.UpdateMentorValue(frame)
	MentorPanel.UpdateApprenticeAndMentorCount(frame)
	MentorPanel.UpdateFindBtnState(frame)
end

function MentorPanel.InitCheckPage(hFrame)
    local dwTime = GetTickCount()
    if dwTime - MentorPanel.dwOpenTime > 500 then
        return
    end
    local hPlayer = GetClientPlayer()
	if hPlayer.nLevel < MentorPanel.nMinPlayerLevelAsMentor then
        if #MentorPanel.aMyMaster > 0 then
            hFrame:Lookup("PageSet_Total"):ActivePage("Page_Master")
        else
            hFrame:Lookup("PageSet_Total"):ActivePage("Page_FindMaster")
        end
	else
        if #MentorPanel.aMyDirectMaster > 0 then
            hFrame:Lookup("PageSet_Total"):ActivePage("Page_Master")
        else 
            if MentorPanel.bCanBeDirectApprentice then
                hFrame:Lookup("PageSet_Total"):ActivePage("Page_FindMaster")
            end
        end
        
        if #MentorPanel.aMyDirectApprentice > 0 then
            hFrame:Lookup("PageSet_Total"):ActivePage("Page_Apprentice")
        else
            if MentorPanel.bCanBeDirectMentor then
                hFrame:Lookup("PageSet_Total"):ActivePage("Page_FindApprentice")
            end
        end
	end
end

function MentorPanel.UpdateMentorValue(hFrame)
    local szAll = FormatString(g_tStrings.MENTOR_VALUE, GetClientPlayer().nAcquiredMentorValue)
    local hMentorValue = hFrame:Lookup("", "Text_AllValue")
    hMentorValue:SetText(szAll)
end

function MentorPanel.UpdateCallTime(frame)
	local player = GetClientPlayer()
	local page = frame:Lookup("PageSet_Total/Page_Master")
	local btn = page:Lookup("Btn_MasterCall")
	local nLeftEvokeMentorCount = 3 - player.nEvokeMentorCount;
	btn:Enable(page.bMaster and page.bOnLine and GetClientPlayer().nEvokeMentorCount < 3 and not page.bDelete)
	btn:Lookup("", "Text_MasterCall"):SetText(FormatString(g_tStrings.MENTOR_CALL, nLeftEvokeMentorCount))
	
	local page = frame:Lookup("PageSet_Total/Page_Apprentice")
	local btn = page:Lookup("Btn_ApprenticeCall")
	local nLeftEvokeMentorCount = 3 - player.nEvokeMentorCount;
	btn:Enable(page.bApprentice and page.bOnLine and GetClientPlayer().nEvokeMentorCount < 3 and not page.bDelete)
	btn:Lookup("", "Text_ApprenticeCall"):SetText(FormatString(g_tStrings.MENTOR_CALL_APPRENTICE, nLeftEvokeMentorCount))
end

function MentorPanel.UpdateApprenticeAndMentorCount(hFrame)
	local hPlayer = GetClientPlayer()
	local hMasterNum = hFrame:Lookup("PageSet_Total/Page_Master", "Text_MasterNum")
    local nMasterNum = #MentorPanel.aMyMaster
    local nMasterCount = 3
    local nDirectMasterNum = #MentorPanel.aMyDirectMaster
    local nDirectMasterCount = 1
    hMasterNum:SetText(FormatString(g_tStrings.MENTOR_NUM, nDirectMasterNum, nDirectMasterCount, nMasterNum, nMasterCount))
    
    local hApprenticeNum = hFrame:Lookup("PageSet_Total/Page_Apprentice", "Text_ApprenticerNum")
    local nApprenticeNum = #MentorPanel.aMyApprentice
    local nApprenticeCount = hPlayer.nMaxApprenticeNum
    local nDirectApprenticeNum = #MentorPanel.aMyDirectApprentice
    local nDirectApprenticeCount = hPlayer.GetMaxDirectApprenticeNum()
    hApprenticeNum:SetText(FormatString(g_tStrings.APPRENTICE_NUM, nDirectApprenticeNum, nDirectApprenticeCount, nApprenticeNum, nApprenticeCount))
end

function MentorPanel.OnCheckBoxCheck()
	local szName = this:GetName()
	if szName == "CheckBox_Help" then
		local argSave = arg0
		
		arg0 = "Library/14/0/0"
		FireEvent("EVENT_LINK_NOTIFY")
		arg0 = argSave
	end
end

function MentorPanel.OnCheckBoxUncheck()
	local szName = this:GetName()
	if szName == "CheckBox_Help" then
		local argSave = arg0
		
		arg0 = "Library/14/0/0"
		FireEvent("EVENT_LINK_NOTIFY")
		arg0 = argSave
	end
end

function MentorPanel.OnMouseEnter()
	local player = GetClientPlayer()
	local szName = this:GetName()
	if szName == "CheckBox_Master" then
		local nHave = 0
		if MentorPanel.aMyMaster then
			nHave = #(MentorPanel.aMyMaster)
		end
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		local player = GetClientPlayer()
		if player.nLevel < MentorPanel.nMinPlayerLevelAsMentor then
			local szTip = GetFormatText(FormatString(g_tStrings.MENTOR_TIP, nHave, 3), 106)
			OutputTip(szTip, 345, {x, y, w, h})
		end
	elseif szName == "CheckBox_Apprentice" then
		local nHave = 0
		if MentorPanel.aMyApprentice then
			nHave = #(MentorPanel.aMyApprentice)
		end				
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		local player = GetClientPlayer()
		if player.nLevel >= MentorPanel.nMinPlayerLevelAsMentor then
			local szTip = GetFormatText(FormatString(g_tStrings.APPRENTICE_TIP, nHave, player.nMaxApprenticeNum), 106)
			OutputTip(szTip, 345, {x, y, w, h})
		end
	end
end

function MentorPanel.OnMouseLeave()
	local szName = this:GetName()
	if szName == "CheckBox_Master" then
		HideTip()
	elseif szName == "CheckBox_Apprentice" then
		HideTip()
	end
end

function MentorPanel.UpdateMasterStateSingle(hI, v)
	hI.bMaster = true
	hI.szName = v.szName
	hI.dwID = v.dwID
	hI.nState = v.nState
	hI.bOnLine = v.bOnLine
	hI.bDelete = v.bDelete
	
	local textName = hI:Lookup("Text_Name")
	local textLevel = hI:Lookup("Text_Level")
	local textRelation = hI:Lookup("Text_Relation")
	local textGuild = hI:Lookup("Text_Guild")
	local textTime = hI:Lookup("Text_Time")
	local textOnLine = hI:Lookup("Text_Online")
	local textValue = hI:Lookup("Text_Value")
	local imgSchool = hI:Lookup("Image_School")
	
	local nFont = 161
	if v.bOnLine then
		nFont = 18
	end
	if v.nState == MENTOR_RECORD_STATE.MENTOR_BREAK or v.nState == MENTOR_RECORD_STATE.APPRENTICE_BREAK then
		nFont = 166
	elseif v.nState == MENTOR_RECORD_STATE.BROKEN or v.nState == MENTOR_RECORD_STATE.GRADUATED then
		nFont = 165
	end
	
	imgSchool:FromUITex(GetForceImage(v.dwForceID))

	textName:SetFontScheme(nFont)
	textLevel:SetFontScheme(nFont)
	textRelation:SetFontScheme(nFont)
	textGuild:SetFontScheme(nFont)
	textTime:SetFontScheme(nFont)
	textOnLine:SetFontScheme(nFont)
	textValue:SetFontScheme(nFont)
		
	textName:SetText(v.szName)	
	textValue:SetText(v.nMentorValue)
	if v.bDelete then
		textLevel:SetText("")
		textRelation:SetText("")
		textGuild:SetText("")
		textTime:SetText("")
		textOnLine:SetText("")
		return
	end
	
	textLevel:SetText(v.nLevel)
	textRelation:SetText(v.szRelation)
	textGuild:SetText(v.szTongName)
	
	if v.nEndTime then
		local nEndTime = v.nEndTime - GetCurrentTime() - 120
		if nEndTime < 0 then
			nEndTime = 0
		end	
		if v.nState == MENTOR_RECORD_STATE.MENTOR_BREAK or v.nState == DIRECT_MENTOR_RECORD_STATE.GRADUATE_BY_MENTOR then
			textTime:SetText(FormatString(g_tStrings.MENTOR_BREAK_1, GetTimeText(nEndTime, nil, true, false, true)))
		elseif v.nState == MENTOR_RECORD_STATE.APPRENTICE_BREAK or v.nState == DIRECT_MENTOR_RECORD_STATE.GRADUATE_BY_APPRENTICE then
			textTime:SetText(FormatString(g_tStrings.MENTOR_BREAK_0, GetTimeText(nEndTime, nil, true, false, true)))
		elseif v.nState == MENTOR_RECORD_STATE.BROKEN then
			textTime:SetText(g_tStrings.MENTOR_BREAK_2)
		elseif v.nState == MENTOR_RECORD_STATE.GRADUATED then
			textTime:SetText(g_tStrings.MENTOR_BREAK_3)
		else
			local time = TimeToDate(v.nCreateTime)
			textTime:SetText(FormatString(g_tStrings.STR_TIME_3, string.format("%02d", time.year - 2000), time.month, time.day))
		end
	else
		local time = TimeToDate(v.nCreateTime)
		textTime:SetText(FormatString(g_tStrings.STR_TIME_3, string.format("%02d", time.year - 2000), time.month, time.day))
	end
	
	if v.bOnLine then
		textOnLine:SetText(g_tStrings.STR_GUILD_ONLINE)
	else
		textOnLine:SetText(MentorPanel.GetLastOnLineTimeText(v.nOfflineTime))
	end
end

function MentorPanel.AppendMasterList(hList, aMaster, bDirect)
    if not aMaster then
        aMaster = {}
    end
	local szIniFile = "UI/Config/Default/MentorPanelMaster.ini"
	
	for k, v in pairs(aMaster) do
		local hI = hList:AppendItemFromIni(szIniFile, "TreeLeaf_Master")
		hI:Expand()
		MentorPanel.UpdateMasterStateSingle(hI, v)
		hI.bDirect = bDirect
		local aApprentice = v.aApprentice or {}
		for kB, vB in pairs(aApprentice) do
			local hI = hList:AppendItemFromIni(szIniFile, "TreeLeaf_Apprentice")
			hI.bBrother = true
			hI.szName = vB.szName
			hI.dwID = vB.dwID
			hI.nState = vB.nState
			hI.bOnLine = vB.bOnLine
			hI.bDelete = vB.bDelete
			hI.bSelf = vB.bSelf
            hI.nLevel = vB.nLevel
			
			local textName = hI:Lookup("Text_NameA")
			local textLevel = hI:Lookup("Text_LevelA")
			local textRelation = hI:Lookup("Text_RelationA")
			local textGuild = hI:Lookup("Text_GuildA")
			local textTime = hI:Lookup("Text_TimeA")
			local textOnLine = hI:Lookup("Text_OnlineA")
			local textValue = hI:Lookup("Text_ValueA")
			local imgSchool = hI:Lookup("Image_SchoolA")
			local imgSel = hI:Lookup("Image_SelA")

			textName:SetName("Text_Name")
			textLevel:SetName("Text_Level")
			textRelation:SetName("Text_Relation")
			textGuild:SetName("Text_Guild")
			textTime:SetName("Text_Time")
			textOnLine:SetName("Text_Online")
			textValue:SetName("Text_Value")
			imgSchool:SetName("Image_School")
			imgSel:SetName("Image_Sel")
			
			imgSchool:FromUITex(GetForceImage(vB.dwForceID))
			
			local nFont = 161
			if vB.bOnLine then
				nFont = 18
			end
	
			textName:SetFontScheme(nFont)
			textLevel:SetFontScheme(nFont)
			textRelation:SetFontScheme(nFont)
			textGuild:SetFontScheme(nFont)
			textTime:SetFontScheme(nFont)
			textOnLine:SetFontScheme(nFont)
			textValue:SetFontScheme(nFont)
			
			textName:SetText(vB.szName)
            if bDirect then
            
            end
			textValue:SetText(vB.nMentorValue)
			if vB.bDelete then
				textLevel:SetText("")
				textRelation:SetText("")
				textGuild:SetText("")
				textTime:SetText("")
				textOnLine:SetText("")
			else
				textLevel:SetText(vB.nLevel)
				textRelation:SetText(vB.szRelation)
				textGuild:SetText(vB.szTongName)
				
				local time = TimeToDate(vB.nCreateTime)
				textTime:SetText(FormatString(g_tStrings.STR_TIME_3, string.format("%02d", time.year - 2000), time.month, time.day))
				if vB.bOnLine then
					textOnLine:SetText(g_tStrings.STR_GUILD_ONLINE)
				else
					textOnLine:SetText(MentorPanel.GetLastOnLineTimeText(vB.nOfflineTime))
				end			
			end			
		end
	end
end

function MentorPanel.UpdateMaster(frame)
	local page = frame:Lookup("PageSet_Total/Page_Master")
    local hList = page:Lookup("", "Handle_MasterList")
    hList:Clear()
    
    MentorPanel.AppendMasterList(hList, MentorPanel.aMyDirectMaster, true)
    MentorPanel.AppendMasterList(hList, MentorPanel.aMyMaster, false)
    hList:FormatAllItemPos()
    FireUIEvent("SCROLL_UPDATE_LIST", "Handle_MasterList", "MentorPanel", true)
	
    MentorPanel.SelByName(hList, page.szName)
	MentorPanel.UpdateApprenticeAndMentorCount(frame)

	MentorPanel.UpdateCallTime(frame)
    MentorPanel.InitCheckPage(frame)
end

function MentorPanel.GetTimeNeed(nDelta)
	local szTime = ""
	local nD = math.floor(nDelta / (3600 * 24))
	if nD > 0 then
		szTime = FormatString(g_tStrings.STR_MAIL_LEFT_DAY, nD)
	else
		local nH = math.floor(nDelta / 3600)
		if nH > 0 then
			szTime = FormatString(g_tStrings.STR_MAIL_LEFT_HOURE, nH)
		else
			local nM = math.floor(nDelta / 60)
			if nM > 0 then
				szTime = FormatString(g_tStrings.STR_MAIL_LEFT_MINUTE, nM)
			else
				szTime = g_tStrings.STR_MAIL_LEFT_LESS_ONE_M
			end
		end
	end
	return szTime
end

function MentorPanel.GetLastOnLineTimeText(nDelta)
	local szTime = ""
	if nDelta < 0 then
		nDelta = 0
	end
	
	local nYear = math.floor(nDelta / (3600 * 24 * 365))
	if nYear > 0 then
		szTime = FormatString(g_tStrings.STR_GUILD_TIME_YEAR_BEFORE, nYear)
	else
		local nD = math.floor(nDelta / (3600 * 24))
		if nD > 0 then
			szTime = FormatString(g_tStrings.STR_GUILD_TIME_DAY_BEFORE, nD)
		else
			local nH = math.floor(nDelta / 3600)
			if nH > 0 then
				szTime = FormatString(g_tStrings.STR_GUILD_TIME_HOUR_BEFORE, nH)
			else
				szTime = g_tStrings.STR_GUILD_TIME_IN_ONE_HOUR
			end
		end
	end
	return szTime
end

function MentorPanel.UpdateApprenticeStateSingle(hI, v)
	hI.bApprentice = true
	hI.szName = v.szName
	hI.dwID = v.dwID
	hI.nState = v.nState
	hI.nMentorValue = v.nMentorValue
	hI.bDelete = v.bDelete
	hI.bOnLine = v.bOnLine
	hI.nLevel = v.nLevel
	
	local textName = hI:Lookup("Text_Name")
	local textLevel = hI:Lookup("Text_Level")
	local textSex = hI:Lookup("Text_Sex")
	local textGuild = hI:Lookup("Text_Guild")
	local textTime = hI:Lookup("Text_Time")
	local textOnLine = hI:Lookup("Text_OnLineTime")
	local textValue = hI:Lookup("Text_Value")
	local imgSchool = hI:Lookup("Image_School")
    local hImageDirect = hI:Lookup("Image_Master")
    hImageDirect:Hide()

	
	local nFont = 161
	if v.bOnLine then
		nFont = 18
	end
	if v.nState == MENTOR_RECORD_STATE.MENTOR_BREAK or v.nState == MENTOR_RECORD_STATE.APPRENTICE_BREAK then
		nFont = 166
	elseif v.nState == MENTOR_RECORD_STATE.BROKEN or v.nState == MENTOR_RECORD_STATE.GRADUATED then
		nFont = 165
	end
	
	imgSchool:FromUITex(GetForceImage(v.dwForceID))	

	textName:SetFontScheme(nFont)
	textLevel:SetFontScheme(nFont)
	textSex:SetFontScheme(nFont)
	textGuild:SetFontScheme(nFont)
	textTime:SetFontScheme(nFont)
	textOnLine:SetFontScheme(nFont)
	textValue:SetFontScheme(nFont)
	
	textName:SetText(v.szName)
	textValue:SetText(v.nMentorValue)
	if v.bDelete then
		textLevel:SetText("")
		textSex:SetText("")
		textGuild:SetText("")
		textTime:SetText("")
		textOnLine:SetText("")
		return
	end	
	
	textLevel:SetText(v.nLevel)
	if IsRoleMale(v.nRoleType) then
		textSex:SetText(g_tStrings.STR_MALE)
	else
		textSex:SetText(g_tStrings.STR_FEMALE)
	end
	textGuild:SetText(v.szTongName)
	
	if v.nEndTime then
		local nEndTime = v.nEndTime - GetCurrentTime() - 120
		if nEndTime < 0 then
			nEndTime = 0
		end
		if v.nState == MENTOR_RECORD_STATE.MENTOR_BREAK then
			textTime:SetText(FormatString(g_tStrings.MENTOR_BREAK_0, GetTimeText(nEndTime, nil, true, false, true)))
		elseif v.nState == MENTOR_RECORD_STATE.APPRENTICE_BREAK then
			textTime:SetText(FormatString(g_tStrings.MENTOR_BREAK_1, GetTimeText(nEndTime, nil, true, false, true)))
		elseif v.nState == MENTOR_RECORD_STATE.BROKEN then
			textTime:SetText(g_tStrings.MENTOR_BREAK_2)
		elseif v.nState == MENTOR_RECORD_STATE.GRADUATED then
			textTime:SetText(g_tStrings.MENTOR_BREAK_3)			
		else
			local time = TimeToDate(v.nCreateTime)
			textTime:SetText(FormatString(g_tStrings.STR_TIME_3, string.format("%02d", time.year - 2000), time.month, time.day))
		end		
	else
		local time = TimeToDate(v.nCreateTime)
		textTime:SetText(FormatString(g_tStrings.STR_TIME_3, string.format("%02d", time.year - 2000), time.month, time.day))	
	end
	
	if v.bOnLine then
		textOnLine:SetText(g_tStrings.STR_GUILD_ONLINE)
	else
		textOnLine:SetText(MentorPanel.GetLastOnLineTimeText(v.nOfflineTime))
	end
end

function MentorPanel.UpdateApprentice(frame)
	local page = frame:Lookup("PageSet_Total/Page_Apprentice")
	local hList = page:Lookup("", "Handle_ApprenticeList")
	local szIniFile = "UI/Config/Default/MentorPanelApprentice.ini"
	
	hList:Clear()
	
    
	for k, v in pairs(MentorPanel.aMyDirectApprentice) do
		local hI = hList:AppendItemFromIni(szIniFile, "Handle_Player")
		MentorPanel.UpdateDirectApprenticeStateSingle(hI, v)
	end

	for k, v in pairs(MentorPanel.aMyApprentice) do
		local hI = hList:AppendItemFromIni(szIniFile, "Handle_Player")
		MentorPanel.UpdateApprenticeStateSingle(hI, v)
	end
    
	FireUIEvent("SCROLL_UPDATE_LIST", "Handle_ApprenticeList", "MentorPanel", true)
	MentorPanel.SelByName(hList, page.szName)
	MentorPanel.UpdateApprenticeAndMentorCount(frame)
	MentorPanel.UpdateFindBtnState(frame)
    MentorPanel.InitCheckPage(frame)
end

function MentorPanel.UpdateDirectApprenticeStateSingle(hI, v)
	hI.bDirectApprentice = true
    hI.bApprentice = true
	hI.szName = v.szName
	hI.dwID = v.dwID
	hI.nState = v.nState
	hI.nMentorValue = v.nMentorValue
	hI.bDelete = v.bDelete
	hI.bOnLine = v.bOnLine
	hI.nLevel = v.nLevel
    hI.bDirect = true
	
	local textName = hI:Lookup("Text_Name")
	local textLevel = hI:Lookup("Text_Level")
	local textSex = hI:Lookup("Text_Sex")
	local textGuild = hI:Lookup("Text_Guild")
	local textTime = hI:Lookup("Text_Time")
	local textOnLine = hI:Lookup("Text_OnLineTime")
	local textValue = hI:Lookup("Text_Value")
	local imgSchool = hI:Lookup("Image_School")
    local hImageDirect = hI:Lookup("Image_Master")
    hImageDirect:Show()
	
	local nFont = 161
	if v.bOnLine then
		nFont = 18
	end
	if v.nState == DIRECT_MENTOR_RECORD_STATE.GRADUATE_BY_MENTOR or v.nState == DIRECT_MENTOR_RECORD_STATE.GRADUATE_BY_APPRENTICE then
		nFont = 166
	elseif v.nState == DIRECT_MENTOR_RECORD_STATE.GRADUATE_SUCCEED then
		nFont = 165
	end
	
	imgSchool:FromUITex(GetForceImage(v.dwForceID))	

	textName:SetFontScheme(nFont)
	textLevel:SetFontScheme(nFont)
	textSex:SetFontScheme(nFont)
	textGuild:SetFontScheme(nFont)
	textTime:SetFontScheme(nFont)
	textOnLine:SetFontScheme(nFont)
	textValue:SetFontScheme(nFont)
	
	textName:SetText(v.szName)
	textValue:SetText("")
	if v.bDelete then
		textLevel:SetText("")
		textSex:SetText("")
		textGuild:SetText("")
		textTime:SetText("")
		textOnLine:SetText("")
		return
	end	
	
	textLevel:SetText(v.nLevel)
	if IsRoleMale(v.nRoleType) then
		textSex:SetText(g_tStrings.STR_MALE)
	else
		textSex:SetText(g_tStrings.STR_FEMALE)
	end
	textGuild:SetText(v.szTongName)
	
	if v.nEndTime then
		local nEndTime = v.nEndTime - GetCurrentTime() - 120
		if nEndTime < 0 then
			nEndTime = 0
		end
		if v.nState == DIRECT_MENTOR_RECORD_STATE.GRADUATE_BY_MENTOR then
			textTime:SetText(FormatString(g_tStrings.MENTOR_BREAK_0, GetTimeText(nEndTime, nil, true, false, true)))
		elseif v.nState == DIRECT_MENTOR_RECORD_STATE.GRADUATE_BY_APPRENTICE then
			textTime:SetText(FormatString(g_tStrings.MENTOR_BREAK_1, GetTimeText(nEndTime, nil, true, false, true)))
		elseif v.nState == DIRECT_MENTOR_RECORD_STATE.GRADUATE_SUCCEED then
			textTime:SetText(g_tStrings.MENTOR_BREAK_2)			
		else
			local time = TimeToDate(v.nCreateTime)
			textTime:SetText(FormatString(g_tStrings.STR_TIME_3, string.format("%02d", time.year - 2000), time.month, time.day))
		end		
	else
		local time = TimeToDate(v.nCreateTime)
		textTime:SetText(FormatString(g_tStrings.STR_TIME_3, string.format("%02d", time.year - 2000), time.month, time.day))	
	end
	
	if v.bOnLine then
		textOnLine:SetText(g_tStrings.STR_GUILD_ONLINE)
	else
		textOnLine:SetText(MentorPanel.GetLastOnLineTimeText(v.nOfflineTime))
	end
end

function MentorPanel.UpdateFindMaster(hFrame)
	local hPageFindMaster = hFrame:Lookup("PageSet_Total/Page_FindMaster")
	local hList = hPageFindMaster:Lookup("", "Handle_FindList")
	
    MentorPanel.UpdateFindList(hList, MentorPanel.aMaster, true, false)
    
    MentorPanel.SelByName(hList, hPageFindMaster.szName)
    FireUIEvent("SCROLL_UPDATE_LIST", "Handle_FindList", "MentorPanel", true)
end

function MentorPanel.UpdateFindApprentice(hFrame)
	local hPageFindMaster = hFrame:Lookup("PageSet_Total/Page_FindApprentice")
	local hList = hPageFindMaster:Lookup("", "Handle_FindApprenticeList")
	
    MentorPanel.UpdateFindList(hList, MentorPanel.aApprentice, false, true)
    
    MentorPanel.SelByName(hList, hPageFindMaster.szName)
    FireUIEvent("SCROLL_UPDATE_LIST", "Handle_FindApprenticeList", "MentorPanel", true)
end

function MentorPanel.UpdateFindList(hList, aFind, bFindMaster, bFindApprentice)
	local szIniFile = "UI/Config/Default/MentorPanelFind.ini"
	if not aFind then
        aFind = {}
    end
	hList:Clear()
	
	for k, v in pairs(aFind) do
		local hI = hList:AppendItemFromIni(szIniFile, "Handle_Player")
		hI.szName = v[1]
		hI.bFindMaster = bFindMaster
		hI.bFindApprentice = bFindApprentice
        hI.bDirect = v[6]
		hI:Lookup("Text_Name"):SetText(v[1])
		hI:Lookup("Text_Level"):SetText(v[2])
		if IsRoleMale(v[4]) then
			hI:Lookup("Text_Sex"):SetText(g_tStrings.STR_MALE)
		else
			hI:Lookup("Text_Sex"):SetText(g_tStrings.STR_FEMALE)
		end
		hI:Lookup("Text_Guild"):SetText(v[5])
		hI:Lookup("Image_School"):FromUITex(GetForceImage(v[3]))
        local hImageDirect = hI:Lookup("Image_Master")
        if hI.bDirect then
            hImageDirect:Show()
        else
            hImageDirect:Hide()
        end
	end
end

function MentorPanel.UpdateListItemShow(hI)
	local img = hI:Lookup("Image_Sel")
	if not img then
		return
	end
	if hI.bSel then
		img:Show()
		img:SetAlpha(255)
	elseif hI.bOver then
		img:Show()
		img:SetAlpha(128)
	else
		img:Hide()
	end
end

function MentorPanel.OnItemMouseEnter()
    local szName = this:GetName()
    local hFrame = this:GetRoot()
    if szName == "Text_MasterNum1" or szName == "Text_MasterNum2" then
        if hFrame.szAccountTip then
            local x, y = this:GetAbsPos()
            local w, h = this:GetSize()
			OutputTip(hFrame.szAccountTip, 345, {x, y, w, h})
        end
	elseif this.bMaster or this.bApprentice or this.bBrother or this.bFindApprentice or this.bFindMaster then
		this.bOver = true
		MentorPanel.UpdateListItemShow(this)
	end
end

function MentorPanel.OnItemMouseLeave()
    local szName = this:GetName()
    if szName == "Text_MasterNum1" or szName == "Text_MasterNum2" then
        HideTip()
	elseif this.bMaster or this.bApprentice or this.bBrother or this.bFindApprentice or this.bFindMaster then
		this.bOver = false
		MentorPanel.UpdateListItemShow(this)
	end
end

function MentorPanel.SelByName(hList, szName)
	local nCount = hList:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = hList:Lookup(i)
		if hI.szName == szName then
			MentorPanel.Sel(hI)
			return
		end
	end
	local page = hList:GetParent():GetParent()
	MentorPanel.UnSel(page)
end

function MentorPanel.Sel(hI)
	if hI.bSel then
		return
	end
	local hP = hI:GetParent()
	local nCount = hP:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hB = hP:Lookup(i)
		if hB.bSel then
			hB.bSel = false
			MentorPanel.UpdateListItemShow(hB)
			break
		end
	end
	
	hI.bSel = true
	MentorPanel.UpdateListItemShow(hI)
	
	local page = hP:GetParent():GetParent()
	page.bSel = true
	page.szName = hI.szName
	page.dwID = hI.dwID
	page.nMentorValue = hI.nMentorValue
	page.bOnLine = hI.bOnLine
	page.bDelete = hI.bDelete
	page.bMaster = hI.bMaster
	page.bApprentice = hI.bApprentice
	page.bSelf = hI.bSelf
	page.nLevel = hI.nLevel
    page.bDirect = hI.bDirect
	if hI.bMaster then
        local bBreakEnable = true
        local szBreakText = g_tStrings.MENTOR_BREAK
        local bCancelBreak = false
        if hI.bDirect then
             if hI.nState == DIRECT_MENTOR_RECORD_STATE.GRADUATE_BY_APPRENTICE then
                szBreakText = g_tStrings.MENTOR_BREAK_CANCLE
                bCancelBreak = true
            end
        else
            if hI.nState == MENTOR_RECORD_STATE.APPRENTICE_BREAK then
                szBreakText = g_tStrings.MENTOR_BREAK_CANCLE
                bCancelBreak = true
            end
        end
        local hBtnMasterBreak = page:Lookup("Btn_MasterBreak")
		hBtnMasterBreak:Enable(bBreakEnable)
        hBtnMasterBreak:Lookup("", "Text_MasterBreak"):SetText(szBreakText)
        hBtnMasterBreak.bCancelBreak = bCancelBreak
		page:Lookup("Btn_MasterCall"):Enable(page.bOnLine and GetClientPlayer().nEvokeMentorCount < 3 and not page.bDelete)
	elseif hI.bBrother then
        local hBtnMasterBreak = page:Lookup("Btn_MasterBreak")
		hBtnMasterBreak:Enable(false)
		hBtnMasterBreak:Lookup("", "Text_MasterBreak"):SetText(g_tStrings.MENTOR_BREAK)
        hBtnMasterBreak.bCancelBreak = false
		page:Lookup("Btn_MasterCall"):Enable(false)
	elseif hI.bApprentice then
        local bBreakEnable = true
        local szBreakText = g_tStrings.MENTOR_BREAK
        local bCancelBreak = false
        if hI.bDirect then
            if hI.nState == DIRECT_MENTOR_RECORD_STATE.GRADUATE_BY_MENTOR then
                szBreakText = g_tStrings.MENTOR_BREAK_CANCLE
                bCancelBreak = true
            end
        else
            if hI.nState == MENTOR_RECORD_STATE.MENTOR_BREAK then
                szBreakText = g_tStrings.MENTOR_BREAK_CANCLE
                bCancelBreak = true
            end
        end
        local hBtnMasterBreak = page:Lookup("Btn_ApprenticeBreak")
		hBtnMasterBreak:Enable(bBreakEnable)
        hBtnMasterBreak:Lookup("", "Text_ApprenticeBreak"):SetText(szBreakText)
        hBtnMasterBreak.bCancelBreak = bCancelBreak
		page:Lookup("Btn_ApprenticeCall"):Enable(page.bOnLine and GetClientPlayer().nEvokeMentorCount < 3 and not page.bDelete)
	elseif hI.bFindApprentice then
        local bCollect = MentorPanel.CanFindApprentice()
        page:Lookup("Btn_Collect"):Enable(bCollect)
    elseif hI.bFindMaster then
		page:Lookup("Btn_FindDoDirect"):Enable(hI.bDirect and MentorPanel.bCanBeDirectApprentice)
        page:Lookup("Btn_FindDo"):Enable(not hI.bDirect)
	end
end

function MentorPanel.UpdateFindBtnState(hFrame)
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return
    end
    local hBtnFindMaster = hFrame:Lookup("PageSet_Total/Page_FindMaster/Btn_FindMsg")
	local bCanFind = false
    if hPlayer.nLevel < MentorPanel.nMinPlayerLevelAsMentor and (not MentorPanel.aMyMaster or #(MentorPanel.aMyMaster) < 3) then
        bCanFind = true
    end
    hBtnFindMaster:Enable(bCanFind)
    local hBtnFindApprentice = hFrame:Lookup("PageSet_Total/Page_FindApprentice/Btn_FindApp")
    bCanFind = false
    if MentorPanel.CanFindApprentice() or MentorPanel.CanFindDirectApprentice() then
        bCanFind = true
    end
	hBtnFindApprentice:Enable(bCanFind)
end

function MentorPanel.CanFindDirectApprentice()
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return false
    end
    
    if hPlayer.nLevel < MentorPanel.nMinPlayerLevelAsMentor then
        return false
    end
    
    if MentorPanel.bCanBeDirectMentor and 
    (
        not MentorPanel.aMyDirectApprentice 
        or #(MentorPanel.aMyDirectApprentice) < hPlayer.GetMaxDirectApprenticeNum()
    )
    then
        return true
    end
    
    return false
end

function MentorPanel.CanFindApprentice()
     local hPlayer = GetClientPlayer()
     if not hPlayer then
        return false
     end
     
     if hPlayer.nLevel < MentorPanel.nMinPlayerLevelAsMentor  then
        return false
     end 
     
     if not MentorPanel.aMyApprentice or #(MentorPanel.aMyApprentice) < hPlayer.nMaxApprenticeNum then
        return true
     end
    
     return false
end

function MentorPanel.UnSel(page)
	local szName = page:GetName()
	if szName == "Page_Master" then
        local hBtnBreak = page:Lookup("Btn_MasterBreak")
		hBtnBreak:Enable(false)
        hBtnBreak:Lookup("", "Text_MasterBreak"):SetText(g_tStrings.MENTOR_BREAK)
        hBtnBreak.bCancelBreak = false
		page:Lookup("Btn_MasterCall"):Enable(false)
	elseif szName == "Page_Apprentice" then
        local hBtnBreak = page:Lookup("Btn_ApprenticeBreak")
		hBtnBreak:Enable(false)
        hBtnBreak:Lookup("", "Text_ApprenticeBreak"):SetText(g_tStrings.MENTOR_BREAK)
        hBtnBreak.bCancelBreak = false
		page:Lookup("Btn_ApprenticeCall"):Enable(false)
	elseif szName == "Page_FindMaster" then
		page:Lookup("Btn_FindDoDirect"):Enable(false)
        page:Lookup("Btn_FindDo"):Enable(false)
    elseif szName == "Page_FindApprentice" then
		page:Lookup("Btn_Collect"):Enable(false)
	end
	page.bSel = false
end

function MentorPanel.OnItemLButtonDown()
	if this.bMaster then
		local x, y = Station.GetMessagePos()
		if this:PtInIcon(x, y) then
			if this:IsExpand() then
				this:Collapse()
			else
				this:Expand()
			end
		end
		MentorPanel.Sel(this)
        FireUIEvent("SCROLL_UPDATE_LIST", "Handle_MasterList", "MentorPanel", false)
	elseif this.bBrother then
		MentorPanel.Sel(this)
	elseif this.bApprentice then
		MentorPanel.Sel(this)
	elseif this.bFindApprentice then
		MentorPanel.Sel(this)
	elseif this.bFindMaster then
		MentorPanel.Sel(this)
	end
end

function MentorPanel.OnItemLButtonDBClick()
	if this.bMaster then
		if this:IsExpand() then
			this:Collapse()
		else
			this:Expand()
		end		
		MentorPanel.Sel(this)
		FireUIEvent("SCROLL_UPDATE_LIST", "Handle_MasterList", "MentorPanel", false)
	else
		MentorPanel.OnItemLButtonDown()
	end
end

function MentorPanel.OnItemRButtonDown()
	MentorPanel.OnItemLButtonDown()
	if this.bMaster or this.bBrother then
		local szName = this.szName
		local menu =
		{
			fnAutoClose = function() return not IsMentorPanelOpened() end,
			{szOption = g_tStrings.STR_SAY_SECRET, bDisable = this.bSelf or this.bDelete, fnAction = function() EditBox_TalkToSomebody(szName) end},
			{szOption = g_tStrings.STR_MAKE_PARTY, bDisable = this.bSelf or this.bDelete or not CanMakeParty(), fnAction = function() GetClientTeam().InviteJoinTeam(szName) AddContactPeople(szName) end},
			{szOption = g_tStrings.STR_MAKE_FRIEND, bDisable = this.bSelf or this.bDelete, fnAction = function() GetClientPlayer().AddFellowship(szName) AddContactPeople(szName) end},
			{szOption = g_tStrings.INVITE_ADD_GUILD, bDisable = this.bSelf or this.bDelete or GetClientPlayer().dwTongID == 0, fnAction = function() InvitePlayerJoinTong(szName) AddContactPeople(szName) end},		
		}
		PopupMenu(menu)
	elseif this.bApprentice then
		local szName = this.szName
		local menu =
		{
			fnAutoClose = function() return not IsMentorPanelOpened() end,
			{szOption = g_tStrings.STR_SAY_SECRET, fnAction = function() EditBox_TalkToSomebody(szName) end},
			{szOption = g_tStrings.STR_MAKE_PARTY, bDisable = not CanMakeParty(), fnAction = function() GetClientTeam().InviteJoinTeam(szName) AddContactPeople(szName) end},
			{szOption = g_tStrings.STR_MAKE_FRIEND, fnAction = function() GetClientPlayer().AddFellowship(szName) AddContactPeople(szName) end},			
			{szOption = g_tStrings.INVITE_ADD_GUILD, bDisable = GetClientPlayer().dwTongID == 0, fnAction = function() InvitePlayerJoinTong(szName) AddContactPeople(szName) end},
		}
		PopupMenu(menu)
	elseif this.bFindApprentice then
		local szName = this.szName
		local menu =
		{
			fnAutoClose = function() return not IsMentorPanelOpened() end,
			{szOption = g_tStrings.STR_SAY_SECRET, fnAction = function() EditBox_TalkToSomebody(szName) end},
			{szOption = g_tStrings.STR_MAKE_FRIEND, fnAction = function() GetClientPlayer().AddFellowship(szName) AddContactPeople(szName) end},			
			{szOption = g_tStrings.MENTOR_GET_APPRENTICE, fnAction = function() RemoteCallToServer("OnApplyApprentice", szName) end},
--			{szOption = g_tStrings.MENTOR_GET_DIRECT_APPRENTICE, fnAction = function() RemoteCallToServer("OnApplyDirectApprentice", szName) end},
		}
		PopupMenu(menu)
	elseif this.bFindMaster then
		local szName = this.szName
		local menu =
		{
			fnAutoClose = function() return not IsMentorPanelOpened() end,
			{szOption = g_tStrings.STR_SAY_SECRET, fnAction = function() EditBox_TalkToSomebody(szName) end},
			{szOption = g_tStrings.STR_MAKE_FRIEND, fnAction = function() GetClientPlayer().AddFellowship(szName) AddContactPeople(szName) end},			
			{szOption = g_tStrings.MENTOR_GET_MASTER, fnAction = function() RemoteCallToServer("OnApplyMentor", szName) end},
			{szOption = g_tStrings.MENTOR_GET_DIRECT_MASTER, fnAction = function() RemoteCallToServer("OnApplyDirectMentor", szName) end},
		}
		PopupMenu(menu)
	end
end

function MentorPanel.OnLButtonClick()
	local szName = this:GetName()
	local page = this:GetParent()
	local szPlayer, dwID, nMentorValue, bDirect, nLevel = page.szName, page.dwID, page.nMentorValue, page.bDirect, page.nLevel
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return
    end
	if szName == "Btn_Close" then
		CloseMentorPanel()
	elseif szName == "Btn_MasterBreak" then
        if bDirect then
            if this.bCancelBreak then
                RemoteCallToServer("OnCancelGraduateByApprentice", dwID)
            else
                local tMsg = 
                {
                    szMessage = FormatString(g_tStrings.MENTOR_BREAK_SURE_4, szPlayer), 
                    szName = "MentorMasterBreak", 
                }
                if hPlayer.nLevel >= MentorPanel.nMinPlayerLevelAsMentor then
                   table.insert(tMsg, {szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() RemoteCallToServer("OnGraduateByDirectApprentice", dwID) end})
                else
                   table.insert(tMsg, {szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() RemoteCallToServer("OnBreakDirectMentor", dwID) end})
                end
                table.insert(tMsg, {szOption = g_tStrings.STR_HOTKEY_CANCEL})
                MessageBox(tMsg)
            end
        else
            if this.bCancelBreak then
                RemoteCallToServer("OnCancelBreakMentor", dwID) 
                PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
            else
                local tMsg = 
                {
                    szMessage = FormatString(g_tStrings.MENTOR_BREAK_SURE_2, szPlayer), 
                    szName = "MentorMasterBreak", 
                    {szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() RemoteCallToServer("OnBreakMentor", dwID) end},
                    {szOption = g_tStrings.STR_HOTKEY_CANCEL},
                }
                MessageBox(tMsg)
            end
        end
	elseif szName == "Btn_MasterCall" then
		local msg = 
		{
			szMessage = FormatString(g_tStrings.MENTOR_CALL_SURE, szPlayer, 3, 3 - GetClientPlayer().nEvokeMentorCount), 
			szName = "MentorMasterBreak", 
			{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() RemoteCallToServer("OnApplyEvoke", dwID) end},
			{szOption = g_tStrings.STR_HOTKEY_CANCEL},
		}
		MessageBox(msg)
	elseif szName == "Btn_ApprenticeBreak" then
        if bDirect then
            if this.bCancelBreak then
                RemoteCallToServer("OnCancelGraduateByMentor", dwID)
            else
                local tMsg = 
                {
                    szMessage = FormatString(g_tStrings.MENTOR_BREAK_SURE_3, szPlayer), 
                    szName = "MentorApprenticeBreak", 
                }
                if nLevel >= MentorPanel.nMinPlayerLevelAsMentor then
                    table.insert(tMsg, {szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() RemoteCallToServer("OnGraduateByDirectMentor", dwID) end})
                else
                    table.insert(tMsg, {szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() RemoteCallToServer("OnBreakDirectApprentice", dwID) end})
                end
                table.insert(tMsg, {szOption = g_tStrings.STR_HOTKEY_CANCEL})
                MessageBox(tMsg)
            end
        else
            if this.bCancelBreak then
                RemoteCallToServer("OnCancelBreakApprentice", dwID)
                PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
            else
                local tMsg = 
                {
                    szMessage = FormatString(g_tStrings.MENTOR_BREAK_SURE_1, szPlayer), 
                    szName = "MentorApprenticeBreak", 
                    {szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() RemoteCallToServer("OnBreakApprentice", dwID) end},
                    {szOption = g_tStrings.STR_HOTKEY_CANCEL},
                }
                MessageBox(tMsg)
            end
        end
        
	elseif szName == "Btn_ApprenticeCall" then
		if page.nLevel < 20 then
			local msg = 
			{
				szMessage = g_tStrings.MENTOR_CALL_APPRENTICE_LIMIT, 
				szName = "MentorApprenticeCallError", 
				{szOption = g_tStrings.STR_HOTKEY_SURE},
			}
			MessageBox(msg)
		else
			local msg = 
			{
				szMessage = FormatString(g_tStrings.MENTOR_CALL_APPRENTICE_SURE, szPlayer, 3, 3 - GetClientPlayer().nEvokeMentorCount), 
				szName = "MentorApprenticeCallSuccess", 
				{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() RemoteCallToServer("OnApplyEvoke", dwID) end},
				{szOption = g_tStrings.STR_HOTKEY_CANCEL},
			}
			MessageBox(msg)
		end
	elseif szName == "Btn_FindMsg" then
		local dwNow = GetTickCount()
		if not MentorPanel.dwFind or dwNow - MentorPanel.dwFind > 60 * 1000 then
			MentorPanel.dwFind = dwNow
            RemoteCallToServer("OnSeekMentorYell")
            OutputMessage("MSG_SYS", g_tStrings.MENTOR_MSG.ON_SEEK_MENTOR_YELL_SUCESS)
		else
            OutputMessage("MSG_SYS", g_tStrings.MENTOR_MSG.ON_SEEK_MENTOR_YELL_LIMIT)
		end
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
    elseif szName == "Btn_FindApp" then
        local dwNow = GetTickCount()
		if not MentorPanel.dwFind or dwNow - MentorPanel.dwFind > 60 * 1000 then
			MentorPanel.dwFind = dwNow
            local fnSeekApprenticeYell = function()
                RemoteCallToServer("OnSeekApprenticeYell")
                OutputMessage("MSG_SYS", g_tStrings.MENTOR_MSG.ON_SEEK_APPRENTICE_YELL_SUCESS)
            end
            local fnSeekDirectApprenticeYell = function()
                RemoteCallToServer("OnSeekDirectApprenticeYell")
                OutputMessage("MSG_SYS", g_tStrings.DIRECT_MENTOR_MSG.ON_SEEK_DAPPRENTICE_YELL_SUCESS)
            end
            local tMsg = 
            {
                szMessage = g_tStrings.MENTOR_FIND_APPRENTICE_OR_DIRECT, 
                szName = "MentorFindApprentice",
            }
            if MentorPanel.CanFindApprentice() then
                table.insert(tMsg, {szOption = g_tStrings.MENTOR_FIND_APPRENTICE_MSG, fnAction = fnSeekApprenticeYell})
            end
            if MentorPanel.CanFindDirectApprentice() then
                table.insert(tMsg, {szOption = g_tStrings.MENTOR_FIND_DIRECT_APPRENTICE_MSG, fnAction = fnSeekDirectApprenticeYell})
            end
            table.insert(tMsg, {szOption = g_tStrings.STR_HOTKEY_CANCEL})
            MessageBox(tMsg)
		else
			OutputMessage("MSG_SYS", g_tStrings.MENTOR_MSG.ON_SEEK_APPRENTICE_YELL_LIMIT)
		end
    elseif szName == "Btn_FindDoDirect" then
        RemoteCallToServer("OnApplyDirectMentor", szPlayer)
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	elseif szName == "Btn_FindDo" then
		RemoteCallToServer("OnApplyMentor", szPlayer)
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
    elseif szName == "Btn_Collect" then
        RemoteCallToServer("OnApplyApprentice", szPlayer)
        PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
    elseif szName == "Btn_MsgHelp" then
        local tMsg = 
        {
            szMessage = g_tStrings.MENTOR_FIND_MASTER_HELP_MSG, 
            szName = "MentorFindMasterHelpMsg",
            {szOption = g_tStrings.STR_HOTKEY_SURE},
            {szOption = g_tStrings.STR_HOTKEY_CANCEL},
        }
        MessageBox(tMsg)
    elseif szName == "Btn_AppHelp" then
        local tMsg = 
        {
            szMessage = g_tStrings.MENTOR_FIND_APPRENTICE_HELP_MSG, 
            szName = "MentorFindApprenticeHelpMsg",
            {szOption = g_tStrings.STR_HOTKEY_SURE},
            {szOption = g_tStrings.STR_HOTKEY_CANCEL},
        }
        MessageBox(tMsg)
	end
end

function Mentor_AddMaster(szName, nLevel, dwForceID, nRoleType, szGuild, bDirect)
	for k, v in pairs(MentorPanel.aMaster) do
		if v[1] == szName and ((v[6] and bDirect) or (not v[6] and not bDirect))then
			table.remove(MentorPanel.aMaster, k)
			break
		end
	end
	table.insert(MentorPanel.aMaster, 1, {szName, nLevel, dwForceID, nRoleType, szGuild, bDirect})
	local nCount = #(MentorPanel.aMaster)
	if nCount > 50 then
		table.remove(MentorPanel.aMaster, nCount)
	end
end

function Mentor_AddApprentice(szName, nLevel, dwForceID, nRoleType, szGuild)
	for k, v in pairs(MentorPanel.aApprentice) do
		if v[1] == szName then
			table.remove(MentorPanel.aApprentice, k)
			break
		end
	end
	table.insert(MentorPanel.aApprentice, 1, {szName, nLevel, dwForceID, nRoleType, szGuild})	
	local nCount = #(MentorPanel.aApprentice)
	if nCount > 50 then
		table.remove(MentorPanel.aApprentice, nCount)
	end
end

function OpenMentorPanel(bDisableSound)
    if CheckPlayerIsRemote(nil, g_tStrings.STR_REMOTE_NOT_TIP1) then
        return
    end
    
	if IsMentorPanelOpened() then
		return
	end
	
    MentorPanel.dwOpenTime = GetTickCount()
	local frame = Station.OpenWindow("MentorPanel")
	MentorPanel.Update(frame)
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end	
end

function IsMentorPanelOpened()
	local frame = Station.Lookup("Normal/MentorPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseMentorPanel(bDisableSound)
	if not IsMentorPanelOpened() then
		return
	end
	
	Station.CloseWindow("MentorPanel")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end	
end

local function OnSeekMentorYell()
	local szName, szGuild, dwForceID, nLevel, nRoleType = arg0, arg1, arg2, arg3, arg4
	Mentor_AddApprentice(szName, nLevel, dwForceID, nRoleType, szGuild)
	local szFont = GetMsgFontString("MSG_SEEK_MENTOR")
	local szSex
	if IsRoleMale(nRoleType) then
		szSex = g_tStrings.STR_APPRENTICE_MALE
	else
		szSex = g_tStrings.STR_APPRENTICE_FEMALE
	end
	if szGuild == "" then
		szGuild = g_tStrings.MENTOR_GUILD_NO
	end
	local szMsg = FormatLinkString(g_tStrings.MENTOR_MSG_LOGIN_1,
		szFont, MakeNameLink("["..szName.."]", szFont), szSex, nLevel, GetForceTitle(dwForceID), szGuild)
	OutputMessage("MSG_SEEK_MENTOR", szMsg, true)
end

local function OnSeekApprenticeYell()
	local szName, szGuild, dwForceID, nLevel, nRoleType, nDirect = arg0, arg1, arg2, arg3, arg4, arg5
    local bDirect = true
    if not nDirect or nDirect == 0 then
        bDirect = false
    end
	Mentor_AddMaster(szName, nLevel, dwForceID, nRoleType, szGuild, bDirect)
	local szFont = GetMsgFontString("MSG_SEEK_MENTOR")
	local szSex
	if IsRoleMale(nRoleType) then
		szSex = g_tStrings.STR_MENTOR_MALE
	else
		szSex = g_tStrings.STR_MENTOR_FEMALE
	end
	if szGuild == "" then
		szGuild = g_tStrings.MENTOR_GUILD_NO
	end
	local szMsg = FormatLinkString(g_tStrings.MENTOR_MSG_LOGIN_2,
		szFont, MakeNameLink("["..szName.."]", szFont), szSex, nLevel, GetForceTitle(dwForceID), szGuild)
	OutputMessage("MSG_SEEK_MENTOR", szMsg, true)
end

RegisterEvent("SEEK_MENTOR_YELL", OnSeekMentorYell)
RegisterEvent("SEEK_APPRENTICE_YELL", OnSeekApprenticeYell)

function OnMentorValueChanged()
	if arg0 > 0 then
		OutputMessage("MSG_MENTOR_VALUE", FormatString(g_tStrings.GET_MENTOR_VALUE, arg0))
	elseif arg0 < 0 then
		OutputMessage("MSG_MENTOR_VALUE", FormatString(g_tStrings.LOST_MENTOR_VALUE, -arg0))
	end
end
RegisterEvent("MENTOR_VALUE_CHANGE", OnMentorValueChanged)

do  
    RegisterScrollEvent("MentorPanel")
    
    UnRegisterScrollAllControl("MentorPanel")
        
    local szFramePath = "Normal/MentorPanel"
    local szPageTotal = "PageSet_Total"
    local szPageMaster = szPageTotal .. "/Page_Master"
    RegisterScrollControl(
        szFramePath, 
        szPageMaster.."/Btn_UpMaster", szPageMaster.."/Btn_DownMaster", 
        szPageMaster.."/Scroll_Master", 
        {szPageMaster, "Handle_MasterList"}
    )

    local szPageApprentice = szPageTotal .. "/Page_Apprentice"
    RegisterScrollControl(
        szFramePath, 
        szPageApprentice.."/Btn_UpApprentice", szPageApprentice.."/Btn_DownApprentice", 
        szPageApprentice.."/Scroll_Apprentice", 
        {szPageApprentice, "Handle_ApprenticeList"}
   )
   
    local szPageFindMaster = szPageTotal .. "/Page_FindMaster"
    RegisterScrollControl(
        szFramePath, 
        szPageFindMaster.."/Btn_UpFind", szPageFindMaster.."/Btn_DownFind", 
        szPageFindMaster.."/Scroll_FindMaster", 
        {szPageFindMaster, "Handle_FindList"}
   )
   
     local szPageFindApprentice = szPageTotal .. "/Page_FindApprentice"
    RegisterScrollControl(
        szFramePath, 
        szPageFindApprentice.."/Btn_UpFindApprentice", szPageFindApprentice.."/Btn_DownFindApprentice", 
        szPageFindApprentice.."/Scroll_FindApprentice", 
        {szPageFindApprentice, "Handle_FindApprenticeList"}
   )
end