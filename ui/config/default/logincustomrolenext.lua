LoginCustomRoleNext={
	m_nFace=1;
	m_nHair=1;
	m_nBang=1;
	m_nPlait=1;
	m_nDress=1;
	m_nBoots=1;
	m_nBangle=1;
	m_nWaist=1;
	m_nWeapon = 1;
	m_nChar=2;
	m_nHomeplace = 0;
	
OnFrameCreate=function()
	this:RegisterEvent("UI_SCALED")
	
	LoginCustomRoleNext.OnEvent("UI_SCALED")

	--LoginCustomRoleNext.PreloadAllRes()
end;

OnEvent=function(event)
	if event == "UI_SCALED" then
		this:SetSize(Station.GetClientSize())

		this:Lookup("WndCustomRole"):SetPoint("LEFTCENTER", 0, 0, "LEFTCENTER", 0, 0)
		this:Lookup("WndRoleName"):SetPoint("BOTTOMCENTER", 0, 0, "BOTTOMCENTER", 0, -65)
		
		this:Lookup("WndServer"):SetPoint("TOPRIGHT", 0, 0, "TOPRIGHT", 0, 80)
		this:Lookup("WndHomeplace"):SetPoint("TOPRIGHT", 0, 0, "TOPRIGHT", 0, 220)
		
		this:Lookup("WndEnterGame"):SetPoint("BOTTOMCENTER", 0, 0, "BOTTOMCENTER", 0, -20)
		this:Lookup("WndBack"):SetPoint("BOTTOMRIGHT", 0, 0, "BOTTOMRIGHT", -70, -20)
		
		this:Lookup("WndSingleRoleRotate"):SetPoint("BOTTOMCENTER", 0, 0, "BOTTOMCENTER", 0, -150)
		this:Lookup("WndSingleRoleControl"):SetPoint("BOTTOMCENTER", 0, 0, "BOTTOMCENTER", 175, -140)
		Login.UpdateSdoaTaskBarPosition("LOGIN")
	end
end;

StepNext=function(nChar, szSchoolType, nKungfuID)
	LoginSingleRole.StopPlayAni()
	
	LoginCustomRoleNext.m_nChar = nChar
	LoginCustomRoleNext.m_szSchoolType = szSchoolType
	LoginCustomRoleNext.m_nKungfuID = nKungfuID
	local nRepID = g_tGlue.tSchoolWeapon[szSchoolType]
	local nRoleType = LoginCustomRole.m_aChar[LoginCustomRoleNext.m_nChar]
	for nIndex, id in pairs(g_tGlue.tWeapon[nRoleType]) do
		if id == nRepID then
			LoginCustomRoleNext.m_nWeapon = nIndex
			break;
		end
	end
	
	LoginCustomRoleNext.m_nFace=1
	LoginCustomRoleNext.m_nHair=1
	LoginCustomRoleNext.m_nBang=1
	LoginCustomRoleNext.m_nPlait=1
	LoginCustomRoleNext.m_nDress=1
	LoginCustomRoleNext.m_nBoots=1
	LoginCustomRoleNext.m_nBangle=1
	LoginCustomRoleNext.m_nWaist=1

	Station.Lookup("Topmost/LoginCustomRole"):Hide()
	local frame = Station.Lookup("Topmost/LoginCustomRoleNext")

	frame:Show()	
	LoginCustomRoleNext.PlayUIAni(frame)
end;

StepPrev=function()
	local frame = Station.Lookup("Topmost/LoginCustomRole")
	frame:Show()
	LoginCustomRole.Init(frame, LoginCustomRoleNext.m_nChar, LoginCustomRoleNext.m_szSchoolType)
	
	Station.Lookup("Topmost/LoginCustomRoleNext"):Hide()
	LoginSingleRole.RestoreCameraState()
end;

PlayUIAni=function(frame)
	local fnSound = function()
		PlaySound(SOUND.UI_SOUND, g_sound.Enter)
	end
	local hWndRole = frame:Lookup("WndCustomRole")
	local fn=function()
		Animation_AppendLineAni(hWndRole, "Role_BodyStop")
	end
	Animation_StopAni(hWndRole);		
	Animation_AppendLineAni(hWndRole, "Role_BodyTile", nil, fn)
	
	local hWndHome = frame:Lookup("WndHomeplace")
	fn=function()
		fnSound()
		Animation_AppendLineAni(hWndHome, "Role_InfoStop")
	end
	Animation_StopAni(hWndHome);		
	Animation_AppendLineAni(hWndHome, "Role_Info", 200, fn)
	
	local hWndServer = frame:Lookup("WndServer")
	fn=function()
		fnSound()
		Animation_AppendLineAni(hWndServer, "Role_InfoStop")
	end
	Animation_StopAni(hWndServer);		
	Animation_AppendLineAni(hWndServer, "Role_Info", nil, fn)
end;

OnFrameShow=function()
	LoginCustomRoleNext.UpdateButtonState()
	LoginCustomRoleNext.UpdateSelection()
	LoginCustomRoleNext.RequestUpdateServerName()
	
	local focus = Station.GetFocusWindow()
	if focus and focus:IsValid() and focus:GetRoot():GetName() == "LoginMessage" then
		focus:Hide()
		Station.SetFocusWindow(this)
		this:FocusHome()
		focus:Show()
	else
		Station.SetFocusWindow(this)
		this:FocusHome()
	end	
end;

UpdateServerName=function()
	local szRegionName, szServerName = LoginServerList.GetSelectedShowServer()
	if not szRegionName then
		szRegionName = ""
	end
	if not szServerName then
		szServerName = ""
	end
	
	local frame = Station.Lookup("Topmost/LoginCustomRoleNext/WndServer")
	frame:Lookup("", "Text_Region"):SetText(szRegionName)
	frame:Lookup("", "Text_Server"):SetText(szServerName)
	
end;

RequestUpdateServerName = function()
	if g_bRequestRemoteServerListSuccess then
		LoginCustomRoleNext.UpdateServerName()
	else
		LoginCustomRoleNext.bRequestUpdateServerName = true
		LoginServerList.RequestRemoteServerList()
	end
end;

OnRButtonDown=function()
	local szName = this:GetName()
	if szName == "LoginCustomRoleNext" then 
		LoginSingleRole.OnSceneRButtonDown()
		return true
	end
	return false
end;

OnRButtonUp=function()
	local szName = this:GetName()
	if szName == "LoginCustomRoleNext" then 
		return LoginSingleRole.OnSceneRButtonUp()
	else
		return false
	end
end;

OnLButtonHold=function()
	local szName = this:GetName()
	if szName == "Btn_HomeplaceUp" then
		this:GetParent():Lookup("Scroll_HomeplaceList"):ScrollPrev(1)
	elseif szName == "Btn_HomeplaceDown" then
		this:GetParent():Lookup("Scroll_HomeplaceList"):ScrollNext(1)
    end	
end;

OnLButtonDown=function()
	local szName = this:GetName()
	if szName == "Btn_TurnLeft" then
		LoginSingleRole.m_bTurnLeft = true
		LoginSingleRole.m_bTurnRight = false
	elseif szName == "Btn_TurnRight" then
		LoginSingleRole.m_bTurnLeft = false
		LoginSingleRole.m_bTurnRight = true
	elseif szName == "LoginCustomRoleNext" then
		return LoginSingleRole.OnSceneLButtonDown()
	elseif szName == "Btn_HomeplaceUp" or szName == "Btn_HomeplaceDown" then
		return LoginCustomRoleNext.OnLButtonHold()
    end
end;

OnLButtonDBClick=function()
	PlaySound(SOUND.UI_SOUND, g_sound.Button)

	local szName=this:GetName()
	if szName == "Btn_ChangeServer" then
		local _,_,_,szVersionEx = GetVersion()
		if szVersionEx == "snda" then
			Login.EnterPassword()
		end
		Login.ShowServerList()
	end
end;

OnLButtonUp=function()
	local szName = this:GetName()
	if szName == "Btn_TurnLeft" then
		LoginSingleRole.m_bTurnLeft = false
	elseif szName == "Btn_TurnRight" then
		LoginSingleRole.m_bTurnRight = false
	end
end;

OnLButtonClick=function()
	local szName = this:GetName()
	local nRoleType = LoginCustomRole.m_aChar[LoginCustomRoleNext.m_nChar]
	
	if szName == "Btn_Back" then
		LoginCustomRoleNext.StepPrev()
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return true
	elseif szName == "Btn_EnterGame" then
		if this:IsEnabled() then
			Login.StepNext()
		end

		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return true
	elseif szName == "Btn_CharL" then
		if LoginCustomRoleNext.m_nChar > 1 then
			LoginCustomRoleNext.m_nChar = LoginCustomRoleNext.m_nChar - 1
		else
			LoginCustomRoleNext.m_nChar = #LoginCustomRole.m_aChar
		end
		LoginCustomRoleNext.CheckSelection()
	    LoginCustomRoleNext.UpdateSelection()

		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return true
	elseif szName == "Btn_CharR" then
		if LoginCustomRoleNext.m_nChar < #LoginCustomRole.m_aChar then
			LoginCustomRoleNext.m_nChar = LoginCustomRoleNext.m_nChar + 1
		else
			LoginCustomRoleNext.m_nChar = 1
		end
		LoginCustomRoleNext.CheckSelection()
	    LoginCustomRoleNext.UpdateSelection()

		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return true
	elseif szName == "Btn_FaceL" then
		if LoginCustomRoleNext.m_nFace > 1 then
			LoginCustomRoleNext.m_nFace = LoginCustomRoleNext.m_nFace - 1
		else
			LoginCustomRoleNext.m_nFace = #g_tGlue.tFace[nRoleType]
		end
	    LoginCustomRoleNext.UpdateSelection()

		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return true
	elseif szName == "Btn_FaceR" then
		if LoginCustomRoleNext.m_nFace < #g_tGlue.tFace[nRoleType] then
			LoginCustomRoleNext.m_nFace = LoginCustomRoleNext.m_nFace + 1
		else
			LoginCustomRoleNext.m_nFace = 1
		end
	    LoginCustomRoleNext.UpdateSelection()

		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return true
	elseif szName == "Btn_HairL" then
		if LoginCustomRoleNext.m_nHair > 1 then
			LoginCustomRoleNext.m_nHair = LoginCustomRoleNext.m_nHair - 1
		else
			LoginCustomRoleNext.m_nHair = #g_tGlue.tHair[nRoleType]
		end
		
		LoginCustomRoleNext.CheckBangAndPlait()
		
		LoginCustomRoleNext.UpdateSelection()

		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return true
	elseif szName == "Btn_HairR" then
		if LoginCustomRoleNext.m_nHair < #g_tGlue.tHair[nRoleType] then
			LoginCustomRoleNext.m_nHair = LoginCustomRoleNext.m_nHair + 1
		else
			LoginCustomRoleNext.m_nHair = 1
		end
		
		LoginCustomRoleNext.CheckBangAndPlait()
		
		LoginCustomRoleNext.UpdateSelection()

		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return true
	elseif szName == "Btn_BangL" then
		if LoginCustomRoleNext.m_nBang > 1 then
			LoginCustomRoleNext.m_nBang = LoginCustomRoleNext.m_nBang - 1
		else
			LoginCustomRoleNext.m_nBang = g_tGlue.tHair[nRoleType][LoginCustomRoleNext.m_nHair]["BangNum"]
		end
		LoginCustomRoleNext.UpdateSelection()

		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return true
	elseif szName == "Btn_BangR" then
		if LoginCustomRoleNext.m_nBang < g_tGlue.tHair[nRoleType][LoginCustomRoleNext.m_nHair]["BangNum"] then
			LoginCustomRoleNext.m_nBang = LoginCustomRoleNext.m_nBang + 1
		else
			LoginCustomRoleNext.m_nBang = 1
		end
		LoginCustomRoleNext.UpdateSelection()

		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return true
	elseif szName == "Btn_PlaitL" then
		if LoginCustomRoleNext.m_nPlait > 1 then
			LoginCustomRoleNext.m_nPlait = LoginCustomRoleNext.m_nPlait - 1
		else
			LoginCustomRoleNext.m_nPlait = g_tGlue.tHair[nRoleType][LoginCustomRoleNext.m_nHair]["PlaitNum"]
		end
		LoginCustomRoleNext.UpdateSelection()

		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return true
	elseif szName == "Btn_PlaitR" then
		if LoginCustomRoleNext.m_nPlait < g_tGlue.tHair[nRoleType][LoginCustomRoleNext.m_nHair]["PlaitNum"] then
			LoginCustomRoleNext.m_nPlait = LoginCustomRoleNext.m_nPlait + 1
		else
			LoginCustomRoleNext.m_nPlait = 1
		end
		LoginCustomRoleNext.UpdateSelection()

		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return true
	elseif szName == "Btn_DressL" then
		if LoginCustomRoleNext.m_nDress > 1 then
			LoginCustomRoleNext.m_nDress = LoginCustomRoleNext.m_nDress - 1
		else
			LoginCustomRoleNext.m_nDress = #g_tGlue.tDress[nRoleType]
		end
	    LoginCustomRoleNext.UpdateSelection()

		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return true
	elseif szName == "Btn_DressR" then
		if LoginCustomRoleNext.m_nDress < #g_tGlue.tDress[nRoleType] then
			LoginCustomRoleNext.m_nDress = LoginCustomRoleNext.m_nDress + 1
		else
			LoginCustomRoleNext.m_nDress = 1
		end
	    LoginCustomRoleNext.UpdateSelection()

		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return true
	elseif szName == "Btn_BootsL" then
		if LoginCustomRoleNext.m_nBoots > 1 then
			LoginCustomRoleNext.m_nBoots = LoginCustomRoleNext.m_nBoots - 1
		else
			LoginCustomRoleNext.m_nBoots = #g_tGlue.tBoots[nRoleType]
		end
	    LoginCustomRoleNext.UpdateSelection()

		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return true
	elseif szName == "Btn_BootsR" then
		if LoginCustomRoleNext.m_nBoots < #g_tGlue.tBoots[nRoleType] then
			LoginCustomRoleNext.m_nBoots = LoginCustomRoleNext.m_nBoots + 1
		else
			LoginCustomRoleNext.m_nBoots = 1
		end
	    LoginCustomRoleNext.UpdateSelection()

		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return true
	elseif szName == "Btn_BangleL" then
		if LoginCustomRoleNext.m_nBangle > 1 then
			LoginCustomRoleNext.m_nBangle = LoginCustomRoleNext.m_nBangle - 1
		else
			LoginCustomRoleNext.m_nBangle = #g_tGlue.tBangle[nRoleType]
		end
	    LoginCustomRoleNext.UpdateSelection()

		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return true
	elseif szName == "Btn_BangleR" then
		if LoginCustomRoleNext.m_nBangle < #g_tGlue.tBangle[nRoleType] then
			LoginCustomRoleNext.m_nBangle = LoginCustomRoleNext.m_nBangle + 1
		else
			LoginCustomRoleNext.m_nBangle = 1
		end
	    LoginCustomRoleNext.UpdateSelection()

		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return true
	elseif szName == "Btn_WaistL" then
		if LoginCustomRoleNext.m_nWaist > 1 then
			LoginCustomRoleNext.m_nWaist = LoginCustomRoleNext.m_nWaist - 1
		else
			LoginCustomRoleNext.m_nWaist = #g_tGlue.tWaist[nRoleType]
		end
	    LoginCustomRoleNext.UpdateSelection()

		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return true
	elseif szName == "Btn_WaistR" then
		if LoginCustomRoleNext.m_nWaist < #g_tGlue.tWaist[nRoleType] then
			LoginCustomRoleNext.m_nWaist = LoginCustomRoleNext.m_nWaist + 1
		else
			LoginCustomRoleNext.m_nWaist = 1
		end
	    LoginCustomRoleNext.UpdateSelection()

		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return true		
	elseif szName == "Btn_WeaponL" then
		if LoginCustomRoleNext.m_nWeapon > 1 then
			LoginCustomRoleNext.m_nWeapon = LoginCustomRoleNext.m_nWeapon - 1
		else
			LoginCustomRoleNext.m_nWeapon = #g_tGlue.tWeapon[nRoleType]
		end
	    LoginCustomRoleNext.UpdateSelection()

		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return true
	elseif szName == "Btn_WeaponR" then
		if LoginCustomRoleNext.m_nWeapon < #g_tGlue.tWeapon[nRoleType] then
			LoginCustomRoleNext.m_nWeapon = LoginCustomRoleNext.m_nWeapon + 1
		else
			LoginCustomRoleNext.m_nWeapon = 1
		end
	    LoginCustomRoleNext.UpdateSelection()

		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return true		
	elseif szName == "Btn_Random" then
		LoginCustomRoleNext.m_nFace=math.random(1, #g_tGlue.tFace[nRoleType])
		LoginCustomRoleNext.m_nHair=math.random(1, #g_tGlue.tHair[nRoleType])
		LoginCustomRoleNext.m_nDress=math.random(1, #g_tGlue.tDress[nRoleType])
		LoginCustomRoleNext.m_nBoots=math.random(1, #g_tGlue.tBoots[nRoleType])
		LoginCustomRoleNext.m_nBangle=math.random(1, #g_tGlue.tBangle[nRoleType])
		LoginCustomRoleNext.m_nWaist=math.random(1, #g_tGlue.tWaist[nRoleType])
		--LoginCustomRoleNext.m_nWeapon=math.random(1, #g_tGlue.tWeapon[nRoleType])
		if g_tGlue.tHair[nRoleType][LoginCustomRoleNext.m_nHair]["BangNum"] > 0 then
			LoginCustomRoleNext.m_nBang = math.random(1, g_tGlue.tHair[nRoleType][LoginCustomRoleNext.m_nHair]["BangNum"])
		else
			LoginCustomRoleNext.m_nBang = 1
		end
		
		if g_tGlue.tHair[nRoleType][LoginCustomRoleNext.m_nHair]["PlaitNum"] > 0 then
			LoginCustomRoleNext.m_nPlait = math.random(1, g_tGlue.tHair[nRoleType][LoginCustomRoleNext.m_nHair]["PlaitNum"])
		else
			LoginCustomRoleNext.m_nPlait = 1
		end
		
		LoginCustomRoleNext.CheckBangAndPlait()
		
	    LoginCustomRoleNext.UpdateSelection()

		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return true
	elseif szName == "Btn_RandomName" then
		local name = RandomName(nRoleType)
		if name ~="" then
			local frame = this:GetRoot()
			if frame then
				frame:Lookup("WndRoleName/Edit_Name"):SetText(name)
			end
		end
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return true
	elseif szName == "Btn_ZoomIn" then
		LoginSingleRole.SetCameraRadius(LoginSingleRole.MIN_RADIUS)
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return true
	elseif szName == "Btn_ZoomOut" then
		LoginSingleRole.SetCameraRadius(LoginSingleRole.MAX_RADIUS)
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return true
	elseif szName == "LoginCustomRoleNext" then
		return LoginSingleRole.OnSceneLButtonUp()
	elseif szName == "Btn_ChangeServer" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		local _,_,_,szVersionEx = GetVersion()
		if szVersionEx == "snda" then
			Login.EnterPassword()
		end
		Login.ShowServerList()
		return 1
	else
		return false
	end
end;

OnEditChanged=function()
	local szName = this:GetName()
	if szName == "Edit_Name" then
		LoginCustomRoleNext.UpdateButtonState()
	end
end;

UpdateButtonState=function()
	local frame = Station.Lookup("Topmost/LoginCustomRoleNext")
	if frame then
		local nRoleNameText = frame:Lookup("WndRoleName/Edit_Name"):GetTextLength()
		if nRoleNameText > 1  then
			frame:Lookup("WndEnterGame/Btn_EnterGame"):Enable(true)
		else
			frame:Lookup("WndEnterGame/Btn_EnterGame"):Enable(false)
		end

		local btnChangeServer = frame:Lookup("WndServer/Btn_ChangeServer")
		btnChangeServer:Enable(not Login.m_bRelogin)
	end
end;

OnFrameKeyDown=function()
	local szKey = GetKeyName(Station.GetMessageKey())
	if szKey == "Esc" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		LoginCustomRoleNext.StepPrev()
		return 1
	elseif szKey == "Enter" then
		if Station.Lookup("Topmost/LoginCustomRoleNext/WndEnterGame/Btn_EnterGame"):IsEnabled() then
			PlaySound(SOUND.UI_SOUND, g_sound.Button)
			Login.StepNext()
		end
		return 1
	elseif szKey == "Up" then
		local focus = Station.GetFocusWindow()
		local szFocus = focus:GetName()
		if szFocus == "WndHomeplace" then
			local handleList = focus:Lookup("", "Handle_HomeplaceList")
			
			local nCount = handleList:GetItemCount() - 1
			for i = 0, nCount, 1 do
				local item = handleList:Lookup(i)
				if item.bSelected then
					if i > 0 then
						item = handleList:Lookup(i - 1)
						LoginCustomRoleNext.SelectHomeplace(item)
						for i = nCount, 0, -1 do
							if not item:IsVisible() then
								this:Lookup("WndHomeplace/Scroll_HomeplaceList"):ScrollPrev(1)
							else
								break
							end
						end
					end
					break
				end
			end
			return 1
		end
	elseif szKey == "Down" then
		local focus = Station.GetFocusWindow()
		local szFocus = focus:GetName()
		if szFocus == "WndHomeplace" then
			local handleList = focus:Lookup("", "Handle_HomeplaceList")
			
			local nCount = handleList:GetItemCount() - 1
			for i = 0, nCount, 1 do
				local item = handleList:Lookup(i)
				if item.bSelected then
					if i < nCount then
						item = handleList:Lookup(i + 1)
						LoginCustomRoleNext.SelectHomeplace(item)
						if not item:IsVisible() then
							this:Lookup("WndHomeplace/Scroll_HomeplaceList"):ScrollNext(1)
						end
					end
					break
				end
			end
			return 1
		end
	end
	
	return 0
end;

OnMouseWheel=function()
	return LoginSingleRole.OnMouseWheel()
end;

OnItemMouseWheel=function()
	local nDistance = Station.GetMessageWheelDelta()
	local szName = this:GetName()
	if szName == "Handle_HomeplaceList" then
		this:GetParent():GetParent():Lookup("Scroll_HomeplaceList"):ScrollNext(nDistance)
		return 1
	end
end;

OnScrollBarPosChanged=function()
	local nCurrentValue = this:GetScrollPos()
	local szName = this:GetName()
	if szName == "Scroll_HomeplaceList" then
		local page = this:GetParent()
		local handle = page:Lookup("", "Handle_HomeplaceList")
		page:Lookup("Btn_HomeplaceUp"):Enable(nCurrentValue ~= 0)
		page:Lookup("Btn_HomeplaceDown"):Enable(nCurrentValue ~= this:GetStepCount())
		handle:SetItemStartRelPos(0, - 10 * nCurrentValue)
	end
end;

SetScrollInfo=function()
	local page = Station.Lookup("Topmost/LoginCustomRoleNext/WndHomeplace")
	local hList = page:Lookup("", ""):Lookup("Handle_HomeplaceList")
	local scroll = page:Lookup("Scroll_HomeplaceList")

	hList:FormatAllItemPos()
	local wAll, hAll = hList:GetAllItemSize()
    local w, h = hList:GetSize()
    local nCountStep = math.ceil((hAll - h) / 10)
    scroll:SetStepCount(nCountStep)
    if nCountStep > 0 then
    	scroll:Show()
    	page:Lookup("Btn_HomeplaceUp"):Show()
    	page:Lookup("Btn_HomeplaceDown"):Show()
    else
    	scroll:Hide()
    	page:Lookup("Btn_HomeplaceUp"):Hide()
    	page:Lookup("Btn_HomeplaceDown"):Hide()
    end
end;


GetRoleName=function()
	local edit = Station.Lookup("Topmost/LoginCustomRoleNext/WndRoleName/Edit_Name")
	local szRoleName = edit:GetText()
	local nRoleName = edit:GetTextLength()
	if szRoleName == "" then
		return nil, 0
	else
		return szRoleName, nRoleName
	end
end;

CheckSelection=function()
	--更换角色类型后可能由于部件资源数组大小不一需要重新检验一下
	local nRoleType = LoginCustomRole.m_aChar[LoginCustomRoleNext.m_nChar]
	
	if LoginCustomRoleNext.m_nFace > #g_tGlue.tFace[nRoleType] then
		LoginCustomRoleNext.m_nFace = #g_tGlue.tFace[nRoleType]
	end
	if LoginCustomRoleNext.m_nHair > #g_tGlue.tHair[nRoleType] then
		LoginCustomRoleNext.m_nHair = #g_tGlue.tHair[nRoleType]
	end
	if LoginCustomRoleNext.m_nDress > #g_tGlue.tDress[nRoleType] then
		LoginCustomRoleNext.m_nDress = #g_tGlue.tDress[nRoleType]
	end
	if LoginCustomRoleNext.m_nBoots > #g_tGlue.tBoots[nRoleType] then
		LoginCustomRoleNext.m_nBoots = #g_tGlue.tBoots[nRoleType]
	end
	if LoginCustomRoleNext.m_nBangle > #g_tGlue.tBangle[nRoleType] then
		LoginCustomRoleNext.m_nBangle = #g_tGlue.tBangle[nRoleType]
	end
	if LoginCustomRoleNext.m_nWaist > #g_tGlue.tWaist[nRoleType] then
		LoginCustomRoleNext.m_nWaist = #g_tGlue.tWaist[nRoleType]
	end
	if LoginCustomRoleNext.m_nWeapon > #g_tGlue.tWeapon[nRoleType] then
		LoginCustomRoleNext.m_nWeapon = #g_tGlue.tWeapon[nRoleType]
	end
	
	LoginCustomRoleNext.CheckBangAndPlait()
end;

CheckBangAndPlait = function()
	-- 发型变了，对应的刘海和辫子的数目会不一样，需要调整一下。有的发型是不能选刘海和辫子的，要把按钮灰掉
	local nRoleType = LoginCustomRole.m_aChar[LoginCustomRoleNext.m_nChar]
	
	if LoginCustomRoleNext.m_nBang > g_tGlue.tHair[nRoleType][LoginCustomRoleNext.m_nHair]["BangNum"] then
		LoginCustomRoleNext.m_nBang = 1
	end
	
	if LoginCustomRoleNext.m_nPlait > g_tGlue.tHair[nRoleType][LoginCustomRoleNext.m_nHair]["PlaitNum"] then
		LoginCustomRoleNext.m_nPlait = 1
	end
	local wndCustomRole=Station.Lookup("Topmost/LoginCustomRoleNext/WndCustomRole")
	if g_tGlue.tHair[nRoleType][LoginCustomRoleNext.m_nHair]["BangNum"] == 0 then
		wndCustomRole:Lookup("Btn_BangL"):Enable(false)
		wndCustomRole:Lookup("Btn_BangR"):Enable(false)
	else
		wndCustomRole:Lookup("Btn_BangL"):Enable(true)
		wndCustomRole:Lookup("Btn_BangR"):Enable(true)
	end
	
	if g_tGlue.tHair[nRoleType][LoginCustomRoleNext.m_nHair]["PlaitNum"] == 0 then
		wndCustomRole:Lookup("Btn_PlaitL"):Enable(false)
		wndCustomRole:Lookup("Btn_PlaitR"):Enable(false)
	else
		wndCustomRole:Lookup("Btn_PlaitL"):Enable(true)
		wndCustomRole:Lookup("Btn_PlaitR"):Enable(true)
	end
end;

UpdateSelection=function()
	--注意：登录选人界面的Face和Head的RepresentID是拼起来用的，因此两个ID均不可超过255

	local nRoleType = LoginCustomRole.m_aChar[LoginCustomRoleNext.m_nChar]
	local aRoleEquip = {}
	
	aRoleEquip["RoleType"]=nRoleType
	aRoleEquip["FaceStyle"]=g_tGlue.tFace[nRoleType][LoginCustomRoleNext.m_nFace]
	aRoleEquip["HairStyle"]=g_tGlue.tHair[nRoleType][LoginCustomRoleNext.m_nHair][LoginCustomRoleNext.m_nBang][LoginCustomRoleNext.m_nPlait]
	aRoleEquip["ChestStyle"]=g_tGlue.tDress[nRoleType][LoginCustomRoleNext.m_nDress][1]
	aRoleEquip["ChestColor"]=g_tGlue.tDress[nRoleType][LoginCustomRoleNext.m_nDress][2]
	aRoleEquip["BootsStyle"]=g_tGlue.tBoots[nRoleType][LoginCustomRoleNext.m_nBoots][1]
	aRoleEquip["BootsColor"]=g_tGlue.tBoots[nRoleType][LoginCustomRoleNext.m_nBoots][2]
	aRoleEquip["BangleStyle"]=g_tGlue.tBangle[nRoleType][LoginCustomRoleNext.m_nBangle][1]
	aRoleEquip["BangleColor"]=g_tGlue.tBangle[nRoleType][LoginCustomRoleNext.m_nBangle][2]
	aRoleEquip["WaistStyle"]=g_tGlue.tWaist[nRoleType][LoginCustomRoleNext.m_nWaist][1]
	aRoleEquip["WaistColor"]=g_tGlue.tWaist[nRoleType][LoginCustomRoleNext.m_nWaist][2]
	aRoleEquip["WeaponStyle"]=g_tGlue.tWeapon[nRoleType][LoginCustomRoleNext.m_nWeapon]
	
	if LoginCustomRoleNext.m_szSchoolType == "cj" then
		aRoleEquip["BigSwordStyle"] = g_tGlue.nBigSwordStyle
	end
	
	local wndCustomRole=this:GetRoot():Lookup("WndCustomRole")
	wndCustomRole:Lookup("", "Handle_CustomFace/Text_CustomFace"):SetText(g_tGlue.tFaceName[nRoleType][LoginCustomRoleNext.m_nFace])
	wndCustomRole:Lookup("", "Handle_CustomHair/Text_CustomHair"):SetText(g_tGlue.tHair[nRoleType][LoginCustomRoleNext.m_nHair]["HeadFormName"])
	wndCustomRole:Lookup("", "Handle_CustomBang/Text_CustomBang"):SetText(g_tGlue.tHair[nRoleType][LoginCustomRoleNext.m_nHair]["BangName"][LoginCustomRoleNext.m_nBang])
	wndCustomRole:Lookup("", "Handle_CustomPlait/Text_CustomPlait"):SetText(g_tGlue.tHair[nRoleType][LoginCustomRoleNext.m_nHair]["PlaitName"][LoginCustomRoleNext.m_nPlait])
	wndCustomRole:Lookup("", "Handle_CustomDress/Text_CustomDress"):SetText(g_tGlue.tDressName[nRoleType][LoginCustomRoleNext.m_nDress])
	wndCustomRole:Lookup("", "Handle_CustomBoots/Text_CustomBoots"):SetText(g_tGlue.tBootsName[nRoleType][LoginCustomRoleNext.m_nBoots])
	wndCustomRole:Lookup("", "Handle_CustomBangle/Text_CustomBangle"):SetText(g_tGlue.tBangleName[nRoleType][LoginCustomRoleNext.m_nBangle])
	wndCustomRole:Lookup("", "Handle_CustomWaist/Text_CustomWaist"):SetText(g_tGlue.tWaistName[nRoleType][LoginCustomRoleNext.m_nWaist])
	wndCustomRole:Lookup("", "Handle_CustomWeapon/Text_CustomWeapon"):SetText(g_tGlue.tWeaponName[nRoleType][LoginCustomRoleNext.m_nWeapon])
	
	LoginSingleRole.UpdateModel(aRoleEquip)
end;

GetSelectedHomeplaceInfo=function()
	local frame = Station.Lookup("Topmost/LoginCustomRoleNext/WndHomeplace")
	local handle = frame:Lookup("", ""):Lookup("Handle_HomeplaceList")

	local szHandleHomeplace = "Handle_Homeplace_"..LoginCustomRoleNext.m_nHomeplace
    local handleHomeplace = handle:Lookup(szHandleHomeplace)

	return handleHomeplace.dwMapID, handleHomeplace.nCopyIndex
end;

AppendHomeplace=function(handle, nIndex, szMapName, dwMapID, nCopyIndex, nLoadFactor)
	local szHandleHomeplace = "Handle_Homeplace_"..nIndex
    handle:AppendItemFromIni("UI/Config/Default/LoginCustomRoleNext.ini", "Handle_Homeplace", szHandleHomeplace)
    local handleHomeplace = handle:Lookup(szHandleHomeplace)
    
    if nIndex ~= 0 then
    	handleHomeplace:SetPosType(ITEM_POSITION.BOTTOM_LEFT)
		handleHomeplace:Lookup("Text_HomeplaceName"):SetFontScheme(163)
        handleHomeplace:Lookup("Image_HomeplaceSelectBg"):SetAlpha(0)
    else
    	handleHomeplace.bSelected = true
    	handleHomeplace:Lookup("Text_HomeplaceName"):SetFontScheme(162)
    	handleHomeplace:Lookup("Image_HomeplaceSelectBg"):Show()
        handleHomeplace:Lookup("Image_HomeplaceSelectBg"):SetAlpha(255)
    end

	handleHomeplace.dwMapID = dwMapID
	handleHomeplace.nCopyIndex = nCopyIndex
    handleHomeplace.nLoadFactor = nLoadFactor
    
    local szStatus = g_tGlue.STR_SERVER_STATUS_GOOD
    local nStatusFontScheme = 80
    if nLoadFactor < 64 then
    	szStatus = g_tGlue.STR_SERVER_STATUS_GOOD
    	nStatusFontScheme = 80
    elseif nLoadFactor < 128 then
    	szStatus = g_tGlue.STR_SERVER_STATUS_NORMAL
    	nStatusFontScheme = 65
    elseif nLoadFactor < 192 then
    	szStatus = g_tGlue.STR_SERVER_STATUS_CROWD
    	nStatusFontScheme = 68
    else
    	szStatus = g_tGlue.STR_SERVER_STATUS_BUSY
    	nStatusFontScheme = 71
    end

	if nCopyIndex == 0 then
		handleHomeplace:Lookup("Text_HomeplaceStatus"):SetText("")
		handleHomeplace:Lookup("Text_HomeplaceName"):SetText(g_tGlue.tLoginString["AUTO_SELECT"])
	else	
		handleHomeplace:Lookup("Text_HomeplaceStatus"):SetText(szStatus)
		handleHomeplace:Lookup("Text_HomeplaceName"):SetText(szMapName.."["..NumberToChinese(nCopyIndex).."]")
    end
end;

UpdateHomeplaceList=function(aHomeplaceList)
	local frame = Station.Lookup("Topmost/LoginCustomRoleNext/WndHomeplace")
	local handle = frame:Lookup("", ""):Lookup("Handle_HomeplaceList")

	--Clear old data
    handle:Clear()
    
	local nIndex = 0
	
	--新手村列表
	for k, v in pairs(aHomeplaceList) do
		local dwMapID = v["MapID"]

		local szMapName = Table_GetMapName(dwMapID)
	    
	    --自动选择
	    LoginCustomRoleNext.AppendHomeplace(handle, nIndex, szMapName, dwMapID, 0, 0)
		nIndex = nIndex + 1
		
		-- 副本列表下标随机排序
	    local tRandomIndex = {}
	    local i = 1
	    
	    for nIndex, _ in pairs(v["Copy"]) do
	        tRandomIndex[i] = {}
	        tRandomIndex[i]["ID"] = nIndex
	        tRandomIndex[i]["RandomNum"] = math.random(1, #v["Copy"])
	        i = i + 1
	    end
	    
	    table.sort(tRandomIndex, 
	        function(a, b)
	            return a["RandomNum"] < b["RandomNum"]
	        end
	    )
	    
	    --副本列表
	    for _, tIndex in pairs(tRandomIndex) do
	        local tCopy = v["Copy"][tIndex["ID"]]
	        local nCopyIndex = tCopy["CopyIndex"]
	        local nLoadFactor = tCopy["LoadFactor"]
			
	        LoginCustomRoleNext.AppendHomeplace(handle, nIndex, szMapName, dwMapID, nCopyIndex, nLoadFactor)

	        nIndex = nIndex + 1
	    end
	end

    handle:FormatAllItemPos()

    LoginCustomRoleNext.SetScrollInfo()
    
    LoginCustomRoleNext.m_nHomeplace=0
end;

OnItemMouseEnter=function()
	local image = this:Lookup("Image_HomeplaceSelectBg")
	image:Show()
	if this.bSelected then
		image:SetAlpha(255)
	else
		image:SetAlpha(127)
	end
end;

OnItemMouseLeave=function()
	local image = this:Lookup("Image_HomeplaceSelectBg")
	if this.bSelected then
		image:SetAlpha(255)
	else
		image:Hide()
	end
end;

OnItemLButtonDown=function()
	LoginCustomRoleNext.SelectHomeplace(this)
end;

OnItemLButtonDBClick=function()
	local szName = this:GetName()
	if szName == "Btn_EnterGame" and this:IsEnabled() then
		Login.StepNext()
	end
end;

SelectHomeplace=function(hHomeplace)
	if hHomeplace.bSelected then
		return
	end
		
	PlaySound(SOUND.UI_SOUND, g_sound.Button)

	local hP = hHomeplace:GetParent()
	local nCount = hP:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hC = hP:Lookup(i)
		if hC.bSelected then
			hC.bSelected = false
			hC:Lookup("Text_HomeplaceName"):SetFontScheme(163)
			hC:Lookup("Image_HomeplaceSelectBg"):Hide()
		end
	end

	local text = hHomeplace:Lookup("Text_HomeplaceName")
	text:SetFontScheme(162)
	hHomeplace:Lookup("Image_HomeplaceSelectBg"):Show()
	hHomeplace:Lookup("Image_HomeplaceSelectBg"):SetAlpha(255)
	hHomeplace.bSelected = true

	LoginCustomRoleNext.m_nHomeplace = tonumber(string.sub(hHomeplace:GetName(), string.len("Handle_Homeplace_") + 1))
end;

GetRoleEquip=function()
	local nRoleType = LoginCustomRole.m_aChar[LoginCustomRoleNext.m_nChar]
    local aRoleEquip = {}
    	
    aRoleEquip["FaceStyle"]=g_tGlue.tFace[nRoleType][LoginCustomRoleNext.m_nFace]
    aRoleEquip["HairStyle"]=g_tGlue.tHair[nRoleType][LoginCustomRoleNext.m_nHair][LoginCustomRoleNext.m_nBang][LoginCustomRoleNext.m_nPlait]
    aRoleEquip["ChestStyle"]=g_tGlue.tDress[nRoleType][LoginCustomRoleNext.m_nDress][1]
    aRoleEquip["ChestColor"]=g_tGlue.tDress[nRoleType][LoginCustomRoleNext.m_nDress][2]
    aRoleEquip["BootsStyle"]=g_tGlue.tBoots[nRoleType][LoginCustomRoleNext.m_nBoots][1]
    aRoleEquip["BootsColor"]=g_tGlue.tBoots[nRoleType][LoginCustomRoleNext.m_nBoots][2]
    aRoleEquip["BangleStyle"]=g_tGlue.tBangle[nRoleType][LoginCustomRoleNext.m_nBangle][1]
    aRoleEquip["BangleColor"]=g_tGlue.tBangle[nRoleType][LoginCustomRoleNext.m_nBangle][2]
    aRoleEquip["WaistStyle"]=g_tGlue.tWaist[nRoleType][LoginCustomRoleNext.m_nWaist][1]
    aRoleEquip["WaistColor"]=g_tGlue.tWaist[nRoleType][LoginCustomRoleNext.m_nWaist][2]
    aRoleEquip["WeaponStyle"]=g_tGlue.tWeapon[nRoleType][LoginCustomRoleNext.m_nWeapon]
    if LoginCustomRoleNext.m_szSchoolType == "cj" then
		aRoleEquip["BigSwordStyle"] = g_tGlue.nBigSwordStyle
	end
	
    return aRoleEquip
end;
};
