g_tLoginRenameHideTip = 
{
}

function FormatSecond(nSecond)
	local nD = math.floor(nSecond / 86400)
	local nH = math.floor((nSecond % 86400) / 3600)
	local nM = math.floor((nSecond % 3600) / 60)

	if nD ~= 0 then
		if nH ~= 0 then
			if nM ~= 0 then
				return nD..g_tStrings.STR_BUFF_H_TIME_D..nH..g_tStrings.STR_BUFF_H_TIME_H..nM..g_tStrings.STR_BUFF_H_TIME_M
			end
			return nD..g_tStrings.STR_BUFF_H_TIME_D..nH..g_tStrings.STR_BUFF_H_TIME_H
		end
		if nM ~= 0 then
			return nD..g_tStrings.STR_BUFF_H_TIME_D..nM..g_tStrings.STR_BUFF_H_TIME_M
		end
		return nD..g_tStrings.STR_BUFF_H_TIME_D
	end

	if nH ~= 0 then
		if nM ~= 0 then
			return nH..g_tStrings.STR_BUFF_H_TIME_H..nM..g_tStrings.STR_BUFF_H_TIME_M
		end
		return nH..g_tStrings.STR_BUFF_H_TIME_H
	end

	return nM..g_tStrings.STR_BUFF_H_TIME_M
end

LoginRoleList={
	m_aRoleEquip={};
	m_nSelectIndex=0;
	m_tLastLoginInfo = {};
	m_tCurrentLoginInfo = {};
	m_szLastLoginRole = "";

OnFrameCreate=function()
	this:RegisterEvent("INTERACTION_REQUEST_RESULT")

	this:RegisterEvent("UI_SCALED")
	LoginRoleList.OnEvent("UI_SCALED")
end;

OnEvent=function(event)
	if event == "UI_SCALED" then
		this:SetSize(Station.GetClientSize())

		this:Lookup("WndRoleList"):SetPoint("TOPRIGHT", 0, 0, "TOPRIGHT", -15, 230)
		this:Lookup("WndServer"):SetPoint("TOPRIGHT", 0, 0, "TOPRIGHT", -15, 80)
		this:Lookup("WndEnterGame"):SetPoint("BOTTOMCENTER", 0, 0, "BOTTOMCENTER", 0, -20)
		this:Lookup("WndBack"):SetPoint("BOTTOMRIGHT", 0, 0, "BOTTOMRIGHT", -70, -20)

		Login.UpdateSdoaTaskBarPosition("LOGIN")
	elseif event == "INTERACTION_REQUEST_RESULT" then
	    if arg0 == "IPCity" and arg1 then
			LoginRoleList.GetLoginInfo(arg2)
			LoginRoleList.SetLoginInfoText()
	    end
	end
end;

OnFrameShow=function()
	LoginRoleList.UpdateRoleList()
	LoginRoleList.RequestUpdateServerName()
end;

RequestIPCity = function(szIP)
    Interaction_Request("IPCity", tUrl.IPCity, "/info1.php?Ip="..szIP.."&type=3", "", 80)
end;

UpdateLoginInfo=function()
	-- 游戏时间
	if Login_GetZoneChargeFlag() and Login_GetChargeFlag() then
		local szEndTime = ""
		local nMonthEndTime, nPointLeftTime, nDayLeftTime = Login_GetTimeOfFee()
		
		if nMonthEndTime > 1229904000 then -- 只要曾经充过月卡，都给显示截止时间
			szEndTime = szEndTime..g_tGlue.STR_MONTH_END_TIME..FormatTime("%Y/%m/%d %H:%M", nMonthEndTime)
		end
		
		if nDayLeftTime > 0 then
			if szEndTime ~= "" then
				szEndTime = szEndTime.."\n"
			end
			szEndTime = szEndTime..g_tGlue.STR_DAY_LEFT_TIME..math.ceil(nDayLeftTime / 86400)..g_tGlue.STR_TIME_DAY
			szEndTime = szEndTime.."\n"..g_tGlue.STR_DAY_COMPUTING_METHOD
		end
		
		if nPointLeftTime > 0 then
			if szEndTime ~= "" then
				szEndTime = szEndTime.."\n"
			end
			szEndTime = szEndTime..g_tGlue.STR_POINT_LEFT_TIME..
						math.floor(nPointLeftTime / 3600)..g_tGlue.STR_TIME_HOUR..
						math.floor((nPointLeftTime % 3600) / 60)..g_tGlue.STR_TIME_MINUTE..
						(nPointLeftTime % 60)..g_tGlue.STR_TIME_SECOND
		end
		
		LoginRoleList.m_tLastLoginInfo.szEndTime = szEndTime
	else
		LoginRoleList.m_tLastLoginInfo.szEndTime = g_tGlue.STR_DEMO_ACCOUNT -- 试玩帐号
	end

	-- 上次登录信息
	local nYear, nMonth, nDay, nHour, nMinute = Login_GetLastLoginTime()
	if nYear == 1970 and nMonth == 1 and nDay == 1 then
		LoginRoleList.m_tLastLoginInfo.szTime = g_tGlue.LOGIN_INFO_NONE
		LoginRoleList.m_tLastLoginInfo.szIP = g_tGlue.LOGIN_INFO_NONE
	else
		LoginRoleList.m_tLastLoginInfo.szTime = string.format("%d/%d/%d %d:%d",nYear, nMonth, nDay, nHour, nMinute)
		local szIP = Login_GetLastLoginIP()
		LoginRoleList.m_tLastLoginInfo.szIP = szIP
	end
	LoginRoleList.m_tLastLoginInfo.szCity = g_tGlue.LOGIN_INFO_NONE
	
	-- 本次登录信息
	local nCurrentTime = Login_GetLoginTime()
	local tCurrentTime = TimeToDate(nCurrentTime)
	LoginRoleList.m_tCurrentLoginInfo.szTime = string.format("%d/%d/%d %d:%d", 
	tCurrentTime.year, tCurrentTime.month, tCurrentTime.day, tCurrentTime.hour, tCurrentTime.minute)
	LoginRoleList.m_tCurrentLoginInfo.szIP = g_tGlue.LOGIN_INFO_NONE
	LoginRoleList.m_tCurrentLoginInfo.szCity = g_tGlue.LOGIN_INFO_NONE
	
	LoginRoleList.SetLoginInfoText()
	LoginRoleList.RequestIPCity(LoginRoleList.m_tLastLoginInfo.szIP)
end;

GetLoginInfo=function(szMessage)
    local szCity, szIP
    
	if not szMessage or szMessage == "" then
		Log("Login info message error!\n Message = nil")
		LoginRoleList.m_tLastLoginInfo.szCity = g_tGlue.LOGIN_INFO_CANNOT_GET
		LoginRoleList.m_tCurrentLoginInfo.szIP = g_tGlue.LOGIN_INFO_CANNOT_GET
		LoginRoleList.m_tCurrentLoginInfo.szCity = g_tGlue.LOGIN_INFO_CANNOT_GET
		return 
	end
	
	_, _, szCity = string.find(szMessage, "JX3LastLoginCity:([^\n]+)")
	if not szCity then
		Log("Login info message error!\n Message = " .. szMessage)
		szCity = g_tGlue.LOGIN_INFO_CANNOT_GET
	end
	LoginRoleList.m_tLastLoginInfo.szCity = szCity
	
	_, _, szIP = string.find(szMessage, "JX3LoginIP:([^\n]+)")
	if not szIP then
		Log("Login info message error!\n Message = " .. szMessage)
		szIP = g_tGlue.LOGIN_INFO_CANNOT_GET
	end
	LoginRoleList.m_tCurrentLoginInfo.szIP = szIP
	
	_, _, szCity = string.find(szMessage, "JX3LoginCity:([^\n]+)")
	if not szCity then
		Log("Login info message error!\n Message = " .. szMessage)
		szCity = g_tGlue.LOGIN_INFO_CANNOT_GET
	end
	LoginRoleList.m_tCurrentLoginInfo.szCity = szCity
	
	if LoginRoleList.m_tLastLoginInfo.szTime == g_tGlue.LOGIN_INFO_NONE then
		LoginRoleList.m_tLastLoginInfo.szCity = g_tGlue.LOGIN_INFO_NONE
	end
end;

SetLoginInfoText=function()
	local hWndLoginInfo = Station.Lookup("Topmost/LoginRoleList"):Lookup("WndLoginInfo")
	hWndLoginInfo:Lookup("", "Text_EndTime"):SetText(LoginRoleList.m_tLastLoginInfo.szEndTime)
	hWndLoginInfo:Lookup("", "Text_LastLoginInfo"):SetText(g_tGlue.STR_LAST_LOGIN_INFO)
	hWndLoginInfo:Lookup("", "Text_LastLoginTime"):SetText(g_tGlue.STR_LOGIN_TIME..LoginRoleList.m_tLastLoginInfo.szTime)
	hWndLoginInfo:Lookup("", "Text_LastIP"):SetText(g_tGlue.STR_LOGIN_IP..LoginRoleList.m_tLastLoginInfo.szIP)
	hWndLoginInfo:Lookup("", "Text_LastIPCity"):SetText(g_tGlue.STR_LOGIN_CITY..LoginRoleList.m_tLastLoginInfo.szCity)
	hWndLoginInfo:Lookup("", "Text_CurrentLoginInfo"):SetText(g_tGlue.STR_CURRENT_LOGIN_INFO)
	hWndLoginInfo:Lookup("", "Text_CurrentTime"):SetText(g_tGlue.STR_LOGIN_TIME..LoginRoleList.m_tCurrentLoginInfo.szTime)
	hWndLoginInfo:Lookup("", "Text_CurrentIP"):SetText(g_tGlue.STR_LOGIN_IP..LoginRoleList.m_tCurrentLoginInfo.szIP)
	hWndLoginInfo:Lookup("", "Text_CurrentIPCity"):SetText(g_tGlue.STR_LOGIN_CITY..LoginRoleList.m_tCurrentLoginInfo.szCity)
end;

UpdateButtonState=function()
	local frame = Station.Lookup("Topmost/LoginRoleList")
	local btnDeleteRole = frame:Lookup("WndRoleList/Btn_DeleteRole")
	if LoginRoleList.m_nSelectIndex < #LoginRoleList.m_aRoleEquip then
		local nDeleteTime = LoginRoleList.m_aRoleEquip[LoginRoleList.m_nSelectIndex + 1]["DeleteTime"]
		if not nDeleteTime or nDeleteTime == 0 then
			btnDeleteRole:Enable(true)
		else
			btnDeleteRole:Enable(false)
		end
	else
		btnDeleteRole:Enable(false)
	end

	local btnCreateRole = frame:Lookup("WndRoleList/Btn_CreateRole")
	if Login_GetRoleCount() < 3 then
		btnCreateRole:Enable(true)
	else
		btnCreateRole:Enable(false)
	end

	local btnChangeServer = frame:Lookup("WndServer/Btn_ChangeServer")
	btnChangeServer:Enable(not Login.m_bRelogin)
end;


UpdateRoleList=function()
	local nRoleCount = Login_GetRoleCount()
	local nAppendRoleCount = nRoleCount
	
	if nAppendRoleCount < 3 then
		nAppendRoleCount = 3
	end
	
	local frame = Station.Lookup("Topmost/LoginRoleList")
	local handle = frame:Lookup("WndRoleList", "Handle_RoleList")

	handle:Clear()
	for nRoleIndex = 0, nAppendRoleCount - 1, 1 do
		handle:AppendItemFromIni("UI/Config/Default/LoginRoleList.ini", "Handle_Role0", "Handle_Role"..nRoleIndex)
		handle:Lookup(handle:GetItemCount() - 1):SetPosType(ITEM_POSITION.BOTTOM_LEFT)
	end

    handle:FormatAllItemPos()

	for nRoleIndex = 0, 2, 1 do
		LoginRoleList.SetRoleLabel(nRoleIndex, g_tGlue.tLoginString["CREATE_ROLE"], "", "", "", 0)
	end

	LoginRoleList.m_aRoleEquip={}
	for nRoleIndex = 0, nRoleCount - 1, 1 do
		local	szAccountName,    szRoleName,       nRoleType,		  nRoleLevel,
                wFaceStyle,       wHairStyle,
				wHelmStyle,	      wHelmColor,       wHelmEnchant,     
				wChestStyle,	  wChestColor,      wChestEnchant,	
				wWaistStyle,      wWaistColor,		wWaistEnchant,    
				wBangleStyle,	  wBangleColor,	    wBangleEnchant,
				wBootsStyle,      wBootsColor,	    
				wWeaponStyle,	  wWeaponColor, wWeaponEnchant1,  wWeaponEnchant2,  
				wBigSwordStyle,	wBigSwordColor,  wBigSwordEnchant1,  wBigSwordEnchant2,  
				wBackExtend,	  wWaistExtend,
                wHorseStyle,      wHorseAdornment1, wHorseAdornment2,
                wHorseAdornment3, wHorseAdornment4, wReserved,
				dwMapID,			nMapCopyIndex,  lLastSaveTime,    lTotalGameTime,
				szSchool, nFreezeTime, nDeleteTime, bRename
		= Login_GetRoleInfo(nRoleIndex)

		LoginRoleList.m_aRoleEquip[nRoleIndex + 1]={}
		local re = LoginRoleList.m_aRoleEquip[nRoleIndex + 1]
		re["AccountName"] = szAccountName
		re["RoleName"]=szRoleName
		re["RoleLevel"]=nRoleLevel
		re["RoleType"]=nRoleType

        re["FaceStyle"] = wFaceStyle
		re["HairStyle"] = wHairStyle
		re["HelmStyle"] = wHelmStyle
		re["HelmColor"] = wHelmColor
		re["HelmEnchant"] = wHelmEnchant
		re["ChestStyle"] = wChestStyle
		re["ChestColor"] = wChestColor
		re["ChestEnchant"] = wChestEnchant
		re["WaistStyle"] = wWaistStyle
		re["WaistColor"] = wWaistColor
		re["WaistEnchant"] = wWaistEnchant
		re["BangleStyle"] = wBangleStyle
		re["BangleColor"] = wBangleColor
		re["BangleEnchant"] = wBangleEnchant
		re["BootsStyle"] = wBootsStyle
		re["BootsColor"] = wBootsColor
		re["WeaponStyle"] = wWeaponStyle
		re["WeaponColor"] = wWeaponColor
		re["WeaponEnchant1"] = wWeaponEnchant1
		re["WeaponEnchant2"] = wWeaponEnchant2
		re["BigSwordStyle"] = wBigSwordStyle
		re["BigSwordColor"] = wBigSwordColor	
		re["BigSwordEnchant1"] = wBigSwordEnchant1
		re["BigSwordEnchant2"] = wBigSwordEnchant2
		re["BackExtend"] = wBackExtend
		re["WaistExtend"] = wWaistExtend
        re["HorseStyle"] = wHorseStyle
        re["HorseAdornment1"] = wHorseAdornment1
        re["HorseAdornment2"] = wHorseAdornment2
        re["HorseAdornment3"] = wHorseAdornment3
        re["HorseAdornment4"] = wHorseAdornment4
        re["Reserved"]        = wReserved
        re["FreezeTime"] = nFreezeTime
        re["DeleteTime"] = nDeleteTime
        re["NeedRename"] = bRename

		local szMapName = Table_GetMapName(dwMapID)

		LoginRoleList.SetRoleLabel(nRoleIndex, szRoleName, tostring(nRoleLevel)..g_tStrings.STR_LEVEL, szMapName, szSchool, nDeleteTime, bRename)
 	end

	if nRoleCount > 0 then
		local nSelectIndex = LoginRoleList.m_nSelectIndex
		if nSelectIndex >= nRoleCount then
			nSelectIndex = 0
		end

		LoginRoleList.UpdateSelection(nSelectIndex)
	end

	LoginRoleList.UpdateButtonState()

	local frame=Station.Lookup("Topmost/LoginRoleList")
	Station.SetFocusWindow(frame)
	frame:FocusHome()
	
	LoginRoleList.UpdateRoleScrollInfo()
end;

UpdateServerName=function()
	local szRegionName, szServerName = LoginServerList.GetSelectedShowServer()
	if not szRegionName then
		szRegionName = ""
	end
	if not szServerName then
		szServerName = ""
	end
	local frame = Station.Lookup("Topmost/LoginRoleList/WndServer")
	frame:Lookup("", "Text_Region"):SetText(szRegionName)
	frame:Lookup("", "Text_Server"):SetText(szServerName)
end;

RequestUpdateServerName = function()
	if g_bRequestRemoteServerListSuccess then
		LoginRoleList.UpdateServerName()
	else
		LoginRoleList.bRequestUpdateServerName = true
		LoginServerList.RequestRemoteServerList()
	end
end;

OnFrameHide=function()
	if not LoginRoleList.m_nSelectIndex then
		return
	end
	
	local hSelectBg = this:Lookup("WndRoleList", "Handle_RoleList/Handle_Role"..LoginRoleList.m_nSelectIndex.."/Image_SelectBg")
	if hSelectBg then
		hSelectBg:SetAlpha(0)
	end
end;

OnLButtonDBClick=function()
	PlaySound(SOUND.UI_SOUND, g_sound.Button)

	local szName=this:GetName()

	if szName == "Btn_CreateRole" then
		Login.EnterCustomRole()
	elseif szName == "Btn_DeleteRole" then
		Wnd.OpenWindow("LoginDeleteRole")
	elseif szName == "Btn_AddOn" then
		local szRoleName = LoginRoleList.m_aRoleEquip[LoginRoleList.m_nSelectIndex + 1]["RoleName"]
		if szRoleName then
			OnManageRoleAddon(szRoleName)
		end
	elseif szName == "Btn_Back" then
		Login.StepPrev()
	elseif szName == "Btn_EnterGame" then
		LoginRoleList.CheckRename()
	elseif szName == "Btn_ChangeServer" then
		local _,_,_,szVersionEx = GetVersion()
		if szVersionEx == "snda" then
			Login.EnterPassword()
		end
		Login.ShowServerList()
	end
end;

OnItemLButtonDown=function()
	if this:GetName() == "Image_Rename" then
		this:SetFrame(40)
	elseif this:GetParent():GetName() == "Handle_RoleList" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		LoginRoleList.SelectRole(this:GetName())
	end
end;

OnItemLButtonUp=function()
	if this:GetName() == "Image_Rename" then
		this:SetFrame(38)
	end
end;

OnItemLButtonClick = function()
	if this:GetName() == "Image_Rename" then
		local hRole = this:GetParent()
		local szRoleName = hRole:Lookup("Text_Role"):GetText()
		LoginRoleList.SelectRole(hRole:GetName())
		OpenLoginRename(szRoleName)
	end
end;

OnItemLButtonDBClick=function()
	if this:GetName() == "Image_Rename" then
		local hRole = this:GetParent()
		local szRoleName = hRole:Lookup("Text_Role"):GetText()
		LoginRoleList.SelectRole(hRole:GetName())
		OpenLoginRename(szRoleName)
	elseif this:GetParent():GetName() == "Handle_RoleList" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		LoginRoleList.SelectRole(this:GetName())
		LoginRoleList.CheckRename()
	end
end;

OnItemMouseEnter=function()
	if this:GetName() == "Image_Rename" then
		this:SetFrame(39)
		
	elseif this:GetParent():GetName() == "Handle_RoleList" then
		local image = this:Lookup("Image_SelectBg")
		image:Show()

		local nIndex = tonumber(string.sub(this:GetName(), string.len("Handle_Role") + 1))
		if nIndex == LoginRoleList.m_nSelectIndex then
			image:SetAlpha(255)
		else
			image:SetAlpha(127)
		end
	end
end;

OnItemMouseLeave=function()
	if this:GetName() == "Image_Rename" then
		this:SetFrame(38)
	elseif this:GetParent():GetName() == "Handle_RoleList" then
		local image = this:Lookup("Image_SelectBg")
		if not image then
			return
		end

		local nIndex = tonumber(string.sub(this:GetName(), string.len("Handle_Role") + 1))
		if nIndex == LoginRoleList.m_nSelectIndex then
			image:SetAlpha(255)
		else
			image:Hide()
		end
	end
end;

ScrollRoleList = function()			
	local wndRoleList = Station.Lookup("Topmost/LoginRoleList/WndRoleList")
	local hList = wndRoleList:Lookup("", "Handle_RoleList")
	local handle = hList:Lookup("Handle_Role"..LoginRoleList.m_nSelectIndex)
	local _, hL = hList:GetSize()
	local _, yL = hList:GetAbsPos()
	local _, h = handle:GetSize()
	local _, y = handle:GetAbsPos()
	if y < yL then
		wndRoleList:Lookup("Scroll_Role"):ScrollPrev(math.ceil(yL - y) / 10)
	elseif y + h > yL + hL then
		wndRoleList:Lookup("Scroll_Role"):ScrollNext(math.ceil((y + h - yL - hL) / 10))
	end
end;

OnFrameKeyDown=function()
	local szKey = GetKeyName(Station.GetMessageKey())

	if szKey == "Esc" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		Login.StepPrev()
		return 1
	elseif szKey == "Enter" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		if LoginRoleList.m_nSelectIndex >= Login_GetRoleCount() then
			Login.EnterCustomRole()
		else
			LoginRoleList.CheckRename()
		end
		return 1
	elseif szKey == "Up" then
		if LoginRoleList.m_nSelectIndex > 0 then
			PlaySound(SOUND.UI_SOUND, g_sound.Button)
			LoginRoleList.UpdateSelection(LoginRoleList.m_nSelectIndex - 1)

			LoginRoleList.ScrollRoleList()
		end
		return 1
	elseif szKey == "Down" then
		local nRoleCount = Login_GetRoleCount()
		local nAppendRoleCount = nRoleCount
		
		if nAppendRoleCount < 3 then
			nAppendRoleCount = 3
		end
		if LoginRoleList.m_nSelectIndex < nAppendRoleCount - 1 then
			PlaySound(SOUND.UI_SOUND, g_sound.Button)
			LoginRoleList.UpdateSelection(LoginRoleList.m_nSelectIndex + 1)
			
			LoginRoleList.ScrollRoleList()
		end
		return 1
	end

	return 0
end;

OnLButtonClick=function()
	local szName=this:GetName()

	if szName == "Btn_CreateRole" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		Login.EnterCustomRole()
		return 1
	elseif szName == "Btn_DeleteRole" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		Wnd.OpenWindow("LoginDeleteRole")
		return 1
	elseif szName == "Btn_AddOn" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		local szRoleName = LoginRoleList.m_aRoleEquip[LoginRoleList.m_nSelectIndex + 1]["RoleName"]
		if szRoleName then
			OnManageRoleAddon(szRoleName)
		end
		return 1
	elseif szName == "Btn_Back" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		Login.StepPrev()
		return 1
	elseif szName == "Btn_EnterGame" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		LoginRoleList.CheckRename()
		return 1
	elseif szName == "Btn_ChangeServer" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		local _,_,_,szVersionEx = GetVersion()
		if szVersionEx == "snda" then
			Login.EnterPassword()
		end
		Login.ShowServerList()
		return 1
	else
		LoginSingleRole.OnSceneLButtonUp()
		return 1
	end
	return 0
end;

OnLButtonDown = function()
	local szName = this:GetName()
	if szName == "Btn_UpRole" then
		LoginRoleList.OnLButtonHold()
	elseif szName == "Btn_DownRole" then
		LoginRoleList.OnLButtonHold()
	end
end;

OnLButtonHold = function()
	local szName = this:GetName()
	if szName == "Btn_UpRole" then
		this:GetParent():Lookup("Scroll_Role"):ScrollPrev()
	elseif szName == "Btn_DownRole" then
		this:GetParent():Lookup("Scroll_Role"):ScrollNext()
	end
end;

OnScrollBarPosChanged = function()
	local page = this:GetParent()
	local nCurrentValue = this:GetScrollPos()
	local szName = this:GetName()
	if szName == "Scroll_Role" then
		page:Lookup("Btn_UpRole"):Enable(nCurrentValue ~= 0)
		page:Lookup("Btn_DownRole"):Enable(nCurrentValue ~= this:GetStepCount())
		page:Lookup("", "Handle_RoleList"):SetItemStartRelPos(0, - 10 * nCurrentValue)
	end
end;

OnItemMouseWheel = function()
	local nDistance = Station.GetMessageWheelDelta()
	local page = this:GetParent():GetParent()
	local szName = page:GetName()
	if szName == "WndRoleList" then
		page:Lookup("Scroll_Role"):ScrollNext(nDistance)
	end
	
	return 1
end;

OnMouseWheel = function()
	return 1
end;

UpdateRoleScrollInfo = function()
	local hList=Station.Lookup("Topmost/LoginRoleList/WndRoleList", "Handle_RoleList")
	local page = hList:GetParent():GetParent()
	local scroll = page:Lookup("Scroll_Role")
	hList:FormatAllItemPos()
	local wAll, hAll = hList:GetAllItemSize()
    local w, h = hList:GetSize()
    local nCountStep = math.ceil((hAll - h) / 10)
    scroll:SetStepCount(nCountStep)
    if nCountStep > 0 then
    	scroll:Show()
    	page:Lookup("Btn_UpRole"):Show()
    	page:Lookup("Btn_DownRole"):Show()
    else
    	scroll:Hide()
    	page:Lookup("Btn_UpRole"):Hide()
    	page:Lookup("Btn_DownRole"):Hide()
    end
end;


---------------------------------------Private--------------------------------------------------------
UpdateModel=function()
	local re = LoginRoleList.m_aRoleEquip[LoginRoleList.m_nSelectIndex + 1]
	if re then
		LoginSingleRole.UpdateModel(re)
	else
		LoginSingleRole.ShowModel(false)
	end
end;

SetRoleLabel=function(nIndex, szRoleName, szLevel, szMapName, szSchool, nDeleteTime, bRename)
	local handle=Station.Lookup("Topmost/LoginRoleList/WndRoleList", "Handle_RoleList/Handle_Role"..nIndex)
	handle:Lookup("Text_Role"):SetText(szRoleName)
	handle:Lookup("Text_Level"):SetText(szLevel)
	handle:Lookup("Text_Map"):SetText(szMapName)
	handle:Lookup("Text_School"):SetText(szSchool)
	
	local hDel = handle:Lookup("Handle_DelTip")
	
	if nDeleteTime and nDeleteTime ~= 0 then
		hDel:Show()
		local szTime = FormatTime("%Y/%m/%d %H:%M", nDeleteTime)
		hDel:Lookup("Text_LastTime"):SetText(g_tGlue.STR_DELETE_TIME..szTime..g_tGlue.STR_CANCEL_DELETE)
	else
		hDel:Hide()
	end
	
	if bRename then
		local Img = handle:Lookup("Image_Rename")
		Img:SetFrame(38)
		Img:Show()
		handle:Lookup("Text_Rename"):Show()
	else
		handle:Lookup("Image_Rename"):Hide()
		handle:Lookup("Text_Rename"):Hide()
	end
end;

UpdateSelection=function(nIndex)
	local handle=Station.Lookup("Topmost/LoginRoleList/WndRoleList", "Handle_RoleList")

	handle:Lookup("Handle_Role"..LoginRoleList.m_nSelectIndex.."/Image_SelectBg"):SetAlpha(0)

	LoginRoleList.m_nSelectIndex = nIndex

	local image = handle:Lookup("Handle_Role"..LoginRoleList.m_nSelectIndex.."/Image_SelectBg")
	image:Show()
	image:SetAlpha(255)

	LoginRoleList.UpdateModel()

	LoginRoleList.UpdateButtonState()
end;

SelectRole=function(szHandleName)
	local nIndex = tonumber(string.sub(szHandleName, string.len("Handle_Role") + 1))

	if nIndex >= Login_GetRoleCount() then
		Login.EnterCustomRole()
	else
		if nIndex ~= LoginRoleList.m_nSelectIndex then
			LoginRoleList.UpdateSelection(nIndex)
		end
	end
end;

SelectLastLoginRole = function()
    if not LoginRoleList.m_szLastLoginRole or LoginRoleList.m_szLastLoginRole == "" then
        return
    end
    
	local nRoleCount = Login_GetRoleCount()
	for nRoleIndex = 2, nRoleCount, 1 do    --如果上次登录的是第一个角色，就不用调整
	    if LoginRoleList.m_aRoleEquip[nRoleIndex]["RoleName"] == LoginRoleList.m_szLastLoginRole then
	        LoginRoleList.m_aRoleEquip[nRoleIndex], LoginRoleList.m_aRoleEquip[1] = 
	        LoginRoleList.m_aRoleEquip[1], LoginRoleList.m_aRoleEquip[nRoleIndex]
	        LoginRoleList.SwapRoleLabel(0, nRoleIndex - 1)
	        
            LoginRoleList.UpdateSelection(0)
            return
	    end
	end
end;

SwapRoleLabel=function(nIndex1, nIndex2)
	local handle1=Station.Lookup("Topmost/LoginRoleList/WndRoleList", "Handle_RoleList/Handle_Role"..nIndex1)
	local szRoleName1 = handle1:Lookup("Text_Role"):GetText()
	local szLevel1 = handle1:Lookup("Text_Level"):GetText()
	local szMapName1 = handle1:Lookup("Text_Map"):GetText()
	local szSchool1 = handle1:Lookup("Text_School"):GetText()
	local hDelTip1 = handle1:Lookup("Handle_DelTip")
	local szDelTip1 = handle1:Lookup("Handle_DelTip/Text_LastTime"):GetText()
	local bDelTipVisible1 = hDelTip1:IsVisible()
	local bRename1 = handle1:Lookup("Image_Rename"):IsVisible()
	
	local handle2=Station.Lookup("Topmost/LoginRoleList/WndRoleList", "Handle_RoleList/Handle_Role"..nIndex2)
	local szRoleName2 = handle2:Lookup("Text_Role"):GetText()
	local szLevel2 = handle2:Lookup("Text_Level"):GetText()
	local szMapName2 = handle2:Lookup("Text_Map"):GetText()
	local szSchool2 = handle2:Lookup("Text_School"):GetText()
	local hDelTip2 = handle2:Lookup("Handle_DelTip")
	local szDelTip2 = handle2:Lookup("Handle_DelTip/Text_LastTime"):GetText()
	local bDelTipVisible2 = hDelTip2:IsVisible()
	local bRename2 = handle2:Lookup("Image_Rename"):IsVisible()
	
	handle1:Lookup("Text_Role"):SetText(szRoleName2)
	handle1:Lookup("Text_Level"):SetText(szLevel2)
	handle1:Lookup("Text_Map"):SetText(szMapName2)
	handle1:Lookup("Text_School"):SetText(szSchool2)
	
	handle2:Lookup("Text_Role"):SetText(szRoleName1)
	handle2:Lookup("Text_Level"):SetText(szLevel1)
	handle2:Lookup("Text_Map"):SetText(szMapName1)
	handle2:Lookup("Text_School"):SetText(szSchool1)

	if bDelTipVisible2 then
		hDelTip1:Show()
		hDelTip1:Lookup("Text_LastTime"):SetText(szDelTip2)
	else
		hDelTip1:Hide()
	end
	if bDelTipVisible1 then
		hDelTip2:Show()
		hDelTip2:Lookup("Text_LastTime"):SetText(szDelTip1)
	else
		hDelTip2:Hide()
	end
	
	if bRename2 then
		local Img = handle1:Lookup("Image_Rename")
		Img:SetFrame(38)
		Img:Show()
		handle1:Lookup("Text_Rename"):Show()
	else
		handle1:Lookup("Image_Rename"):Hide()
		handle1:Lookup("Text_Rename"):Hide()
	end
	
	if bRename1 then
		local Img = handle2:Lookup("Image_Rename")
		Img:SetFrame(38)
		Img:Show()
		handle2:Lookup("Text_Rename"):Show()
	else
		handle2:Lookup("Image_Rename"):Hide()
		handle2:Lookup("Text_Rename"):Hide()
	end
end;

CheckRename = function()
	local szRoleName = LoginRoleList.m_aRoleEquip[LoginRoleList.m_nSelectIndex + 1]["RoleName"]
	local bRename = LoginRoleList.m_aRoleEquip[LoginRoleList.m_nSelectIndex + 1]["NeedRename"]
	
	if not szRoleName or szRoleName == "" then
		return
	end

	if bRename and not g_tLoginRenameHideTip[szRoleName] then
		OpenLoginRename(szRoleName)
	else
		if IsShowPluginsWarning() then
            OpenPluginsWarning();
		else
            Login.StepNext()
		end
	end
end;
};

function GetLoginInfo()
	return LoginRoleList.m_tLastLoginInfo.szCity, LoginRoleList.m_tCurrentLoginInfo.szCity
end

function RoleList_GetSelectRole()
    return LoginRoleList.m_aRoleEquip[LoginRoleList.m_nSelectIndex + 1]["RoleName"]
end

RegisterCustomData("LoginAccount/LoginRoleList.m_szLastLoginRole")
RegisterCustomData("LoginAccount/g_tLoginRenameHideTip")
