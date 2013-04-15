LoginServerList = {}

LoginServerList.tServerList = {}

LoginServerList.tLocalServerList = {}

LoginServerList.tServerServerList = {}

LoginServerList.tServerState = 
{
    [0] = {szState = g_tGlue.STR_SERVER_STATUS_COMMEND, font = 163},
    {szState = g_tGlue.STR_SERVER_STATUS_SMOOTHLY, font = 165},
    {szState = g_tGlue.STR_SERVER_STATUS_FULL, font = 166},
    {szState = g_tGlue.STR_SERVER_STATUS_SERVICING, font = 161},
}

function LoginServerList.OnFrameCreate()
	this:RegisterEvent("INTERACTION_REQUEST_RESULT")
	this:RegisterEvent("UI_SCALED")
	
	LoginServerList.OnEvent("UI_SCALED")
	
	LoginServerList.szRegion, LoginServerList.szServer = "", ""
	
    LoginServerList.GetLocalRegionListInfo()
    
	LoginServerList.UpdateRegionList(this:Lookup("Wnd_Region", "Handle_RList"))
end

function LoginServerList.OnFrameDestory()
	LoginServerList.focus = nil
end

function LoginServerList.OnFrameShow()
	LoginServerList.UpdateSelectionHightlight()	

	local focus = Station.GetFocusWindow()
	if focus and focus:IsValid() then
		this:BringToTop()
		Station.SetFocusWindow(this)

		local szFocusRoot = focus:GetRoot():GetName()
		if szFocusRoot == "LoginMessage" then
			focus:Hide()
			Station.SetFocusWindow("Topmost/LoginServerList/Wnd_Region")
			focus:Show()
		end
	else
		if LoginServerList.focus then
			Station.SetFocusWindow(LoginServerList.focus)
		else
			Station.SetFocusWindow("Topmost/LoginServerList/Wnd_Region")
		end
	end
	
	LoginServerList.RequestRemoteServerList()

	local _,_,_,szVersionType = GetVersion()
	if szVersionType == "snda" then
		Login.ShowSdoaWindows(false)
	end
end

function LoginServerList.OnFrameHide()

	local _,_,_,szVersionType = GetVersion()
	if szVersionType == "snda" and Login.m_StateLeaveFunction == Login.LeavePassword then
		Login.ShowSdoaWindows(true)
	end

	local focus = Station.GetFocusWindow()
	
	if focus and focus:IsValid() and focus:GetRoot():GetName() == "LoginServerList" then
		LoginServerList.focus = focus
	else
		LoginServerList.focus = nil
	end
end

function LoginServerList.HandleInteractionRequestResult()
	LoginServerList.RequestRoleNum()
	
	if LoginPassword.bRequestUpdateServerName then
		LoginPassword.bRequestUpdateServerName = false
		LoginPassword.UpdateServerName()
	end
	
	if LoginRoleList.bRequestUpdateServerName then
		LoginRoleList.bRequestUpdateServerName = false
		LoginRoleList.UpdateServerName()
	end
	
	if LoginCustomRoleNext.bRequestUpdateServerName then
		LoginCustomRoleNext.bRequestUpdateServerName = false
		LoginCustomRoleNext.UpdateServerName()
	end
	
	if Login.bRequestRelogin then
		Login.bRequestRelogin = false
		Login.Relogin()
	end
	
	Station.Lookup("Topmost1/LoginWaitServerList"):Hide()
end

function LoginServerList.OnEvent(event)
	if event == "UI_SCALED" then
		this:SetSize(Station.GetClientSize())
		this:Lookup("Wnd_Region"):SetPoint("CENTER", 0, 0, "CENTER", -210, 0)
		this:Lookup("Wnd_SvrList"):SetPoint("CENTER", 0, 0, "CENTER", 160, 0)
		this:Lookup("Wnd_Button"):SetPoint("CENTER", 0, 0, "CENTER", 255, 277)
		this:Lookup("Wnd_Bg"):SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
		this:Lookup("Btn_Search"):SetPoint("CENTER", 0, 0, "CENTER", -253, 277)

		LoginPassword.UpdateSdoaLoginDialogSize()
	elseif event == "INTERACTION_REQUEST_RESULT" then
	    if arg0 == "RoleNum" and arg1 and arg3 > 0 then
	        LoginServerList.UpdateRoleNum(arg2)
	    elseif arg0 == "SvrState" and arg1 and arg3 > 0 then
			g_bRequestRemoteServerList = false
			g_bRequestRemoteServerListSuccess = true
			
		    LoginServerList.GetRemoteServerListInfo(arg2)

			LoginServerList.HandleInteractionRequestResult()
	    end
	end
end

function LoginServerList.OnLButtonHold()
	local szName = this:GetName()
	if szName == "Btn_Up" then
		this:GetParent():Lookup("Scroll_ServerList"):ScrollPrev(1)
	elseif szName == "Btn_Down" then
		this:GetParent():Lookup("Scroll_ServerList"):ScrollNext(1)
	elseif szName == "Btn_UpR" then
		this:GetParent():Lookup("Scroll_Region"):ScrollPrev(1)
	elseif szName == "Btn_DownR" then
		this:GetParent():Lookup("Scroll_Region"):ScrollNext(1)
    end
end

function LoginServerList.OnLButtonUp()
	local szName = this:GetName()
	if szName == "Btn_Up" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	elseif szName == "Btn_Down" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	elseif szName == "Btn_UpR" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	elseif szName == "Btn_DownR" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	elseif szName == "Btn_Test" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	elseif szName == "Btn_Advise" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
    end
end

function LoginServerList.OnLButtonDown()
	LoginServerList.OnLButtonHold()
end

function LoginServerList.AcceptSelection()
	local szRegionName, szServerName, szIP, nPort = LoginServerList.GetSelectedServer()
	Login.m_szServerIP, Login.m_nServerPort = szIP, nPort

	LoginPassword.UpdateServerName()
	LoginCustomRoleNext.UpdateServerName()
	LoginRoleList.UpdateServerName()

	local _,_,_,szVersionEx = GetVersion()
	if szVersionEx == "snda" then
		Login.HideServerList()	
		LoginPassword.ShowSdoaLoginDialog()
	else
		Station.SetFocusWindow("Normal/LoginPassword/WndPassword/Edit_Account")
		Login.HideServerList()	
		Login.RequestLogin(g_tGlue.tLoginString["CONNECTING"], false)
	end
	
	Login.m_bSelectServer = true
end

function LoginServerList.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Ok" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		LoginServerList.AcceptSelection()
	elseif szName == "Btn_Cancel" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		Login.HideServerList()
	elseif szName == "Btn_Search" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		OpenInternetExplorer(tUrl.SearchServer, true)
	end
	LoginServerList.UpdateSelectionHightlight()
end

function LoginServerList.OnItemMouseWheel()
	local szName = this:GetName()
	local nDistance = Station.GetMessageWheelDelta()
	if szName == "Handle_ServerList" then
		this:GetParent():GetParent():Lookup("Scroll_ServerList"):ScrollNext(nDistance)
	elseif szName == "Handle_RList" then
		this:GetParent():GetParent():Lookup("Scroll_Region"):ScrollNext(nDistance)
	end
	return 1
end

function LoginServerList.OnScrollBarPosChanged()
	local szName = this:GetName()
	local nCurrentValue = this:GetScrollPos()
	
	local btnUp, btnDown, handle
	if szName == "Scroll_ServerList" then
		btnUp = this:GetParent():Lookup("Btn_Up")
		btnDown = this:GetParent():Lookup("Btn_Down")
		handle = this:GetParent():Lookup("", "Handle_ServerList")
	elseif szName == "Scroll_Region" then
		btnUp = this:GetParent():Lookup("Btn_UpR")
		btnDown = this:GetParent():Lookup("Btn_DownR")
		handle = this:GetParent():Lookup("", "Handle_RList")		
	end
	
	if nCurrentValue == 0 then
		btnUp:Enable(false)
	else
		btnUp:Enable(true)
	end	
	
	if nCurrentValue == this:GetStepCount() then
		btnDown:Enable(false)
	else
		btnDown:Enable(true)
	end
	
	local wI, hI = handle:Lookup(0):GetSize()
	handle:SetItemStartRelPos(0, -nCurrentValue * hI)	
end

function LoginServerList.UpdateScrollInfo(handle)
	handle:FormatAllItemPos()
	local w, h = handle:GetSize()
	local wI, hI = handle:Lookup(0):GetSize()
	local wAll, hAll = handle:GetAllItemSize()
	local nStep = (hAll - h) / hI
	local szName = handle:GetName()
	local wndRoot = handle:GetParent():GetParent()
	if szName == "Handle_ServerList" then
		wndRoot:Lookup("Scroll_ServerList"):SetStepCount(nStep)
		if nStep > 0 then
	    	wndRoot:Lookup("Scroll_ServerList"):Show()
	    	wndRoot:Lookup("Btn_Up"):Show()
	    	wndRoot:Lookup("Btn_Down"):Show()
	    	local imageBg = wndRoot:Lookup("", "Image_ScrollBg")
			if imageBg then
				imageBg:Show()		
			end
		else
	    	wndRoot:Lookup("Scroll_ServerList"):Hide()
	    	wndRoot:Lookup("Btn_Up"):Hide()
	    	wndRoot:Lookup("Btn_Down"):Hide()
	    	local imageBg = wndRoot:Lookup("", "Image_ScrollBg")
			if imageBg then
				imageBg:Hide()
			end
	    end
	elseif szName == "Handle_RList" then
		wndRoot:Lookup("Scroll_Region"):SetStepCount(nStep)
		if nStep > 0 then
	    	wndRoot:Lookup("Scroll_Region"):Show()
	    	wndRoot:Lookup("Btn_UpR"):Show()
	    	wndRoot:Lookup("Btn_DownR"):Show()
	    	local imageBg = wndRoot:Lookup("", "Image_ScrollBgR")
			if imageBg then
				imageBg:Show()		
			end
		else
	    	wndRoot:Lookup("Scroll_Region"):Hide()
	    	wndRoot:Lookup("Btn_UpR"):Hide()
	    	wndRoot:Lookup("Btn_DownR"):Hide()
	    	local imageBg = wndRoot:Lookup("", "Image_ScrollBgR")
			if imageBg then
				imageBg:Hide()
			end
	    end
	end	
end

function LoginServerList.OnItemMouseEnter()
	local szName = this:GetParent():GetName()
	local focus = Station.GetFocusWindow()
	local szFocus = ""
	if focus then
		szFocus = focus:GetName()
	end
	
	if szName == "Handle_ServerList" then
		local image = this:Lookup("Image_SelectBg")
		image:Show()
		if this.bSelected and szFocus == "Wnd_SvrList" then
			image:SetAlpha(255)
		else
			image:SetAlpha(127)
		end		
	elseif szName == "Handle_RList" then
		local image = this:Lookup("Image_Sel")
		image:Show()
		if this.bSelected and szFocus == "Wnd_Region" then
			image:SetAlpha(255)
		else
			image:SetAlpha(127)
		end
	elseif this:GetName() == "Text_RoleNum" then
	    if this:GetText() ~= "" then
    		local nX, nY = this:GetAbsPos()
    		local nWidth, nHeight = this:GetSize()
    		szTip = "<text>text="..EncodeComponentsString(g_tGlue.tLoginString.ROLE_NUMBER).." font=162 </text>"
    	    OutputTip(szTip, 345, {nX, nY, nWidth, nHeight})
    	end
	end
end

function LoginServerList.OnItemMouseLeave()
	local szName = this:GetParent():GetName()
	local focus = Station.GetFocusWindow()
	local szFocus = ""
	if focus then
		szFocus = focus:GetName()
	end
	if szName == "Handle_ServerList" then
		local image = this:Lookup("Image_SelectBg")
		if image then
			if this.bSelected then
				if szFocus == "Wnd_SvrList" then
					image:SetAlpha(255)
				else
					image:SetAlpha(127)
				end
			else
				image:SetAlpha(0)
			end
		end
	elseif szName == "Handle_RList" then
		local image = this:Lookup("Image_Sel")
		if image then
			if this.bSelected then
				if szFocus == "Wnd_Region" then
					image:SetAlpha(255)
				else
					image:SetAlpha(127)
				end
			else
				image:SetAlpha(0)
			end
		end
	elseif this:GetName() == "Text_RoleNum" then
	    HideTip();
	end
end

function LoginServerList.OnFrameKeyDown()
	local szKey = GetKeyName(Station.GetMessageKey())
	
	if szKey == "Esc" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		Login.HideServerList()
		return 1
	elseif szKey == "Enter" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		LoginServerList.AcceptSelection()
		return 1
	elseif szKey == "Left" then
		local focus = Station.GetFocusWindow()
		if not focus or focus:GetName() ~= "Wnd_Region" then
			Station.SetFocusWindow("Topmost/LoginServerList/Wnd_Region")
			LoginServerList.UpdateSelectionHightlight()
		end
		return 1
	elseif szKey == "Right" then
		local focus = Station.GetFocusWindow()
		if not focus or focus:GetName() ~= "Wnd_SvrList" then
			Station.SetFocusWindow("Topmost/LoginServerList/Wnd_SvrList")
			LoginServerList.UpdateSelectionHightlight()
		end
		return 1
	elseif szKey == "Tab" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		local focus = Station.GetFocusWindow()
		if not focus or focus:GetName() ~= "Wnd_Region" then
			Station.SetFocusWindow("Topmost/LoginServerList/Wnd_Region")
		else
			Station.SetFocusWindow("Topmost/LoginServerList/Wnd_SvrList")
		end
		LoginServerList.UpdateSelectionHightlight()
		return 1
	elseif szKey == "Up" then
		local focus = Station.GetFocusWindow()
		local szFocus = focus:GetName()
		if szFocus == "Wnd_Region" then
			local handleList = focus:Lookup("", "Handle_RList")
			
			local nCount = handleList:GetItemCount() - 1
			for i = 0, nCount, 1 do
				local item = handleList:Lookup(i)
				if item.bSelected then
					if i > 0 then
						item = handleList:Lookup(i - 1)
						LoginServerList.SelectRegion(item)
						for i = nCount, 0, -1 do
							if not item:IsVisible() then
								this:Lookup("Wnd_Region/Scroll_Region"):ScrollPrev(1)
							else
								break
							end
						end
					end
					break
				end
			end
		elseif szFocus == "Wnd_SvrList" then
			local handleList = focus:Lookup("", "Handle_ServerList")
			
			local nCount = handleList:GetItemCount() - 1
			for i = 0, nCount, 1 do
				local item = handleList:Lookup(i)
				if item.bSelected then
					if i > 0 then
						item = handleList:Lookup(i - 1)
						LoginServerList.SelectServer(item)
						for i = nCount, 0, -1 do
							if not item:IsVisible() then
								this:Lookup("Wnd_SvrList/Scroll_ServerList"):ScrollPrev(1)
							else
								break
							end
						end
					end
					break
				end
			end
		end
		return 1
	elseif szKey == "Down" then
		local focus = Station.GetFocusWindow()
		local szFocus = focus:GetName()
		if szFocus == "Wnd_Region" then
			local handleList = focus:Lookup("", "Handle_RList")
			
			local nCount = handleList:GetItemCount() - 1
			for i = 0, nCount, 1 do
				local item = handleList:Lookup(i)
				if item.bSelected then
					if i < nCount then
						item = handleList:Lookup(i + 1)
						LoginServerList.SelectRegion(item)
						if not item:IsVisible() then
							this:Lookup("Wnd_Region/Scroll_Region"):ScrollNext(1)
						end
					end
					break
				end
			end
		elseif szFocus == "Wnd_SvrList" then
			local handleList = focus:Lookup("", "Handle_ServerList")
			
			local nCount = handleList:GetItemCount() - 1
			for i = 0, nCount, 1 do
				local item = handleList:Lookup(i)
				if item.bSelected then
					if i < nCount then
						item = handleList:Lookup(i + 1)
						LoginServerList.SelectServer(item)
						if not item:IsVisible() then
							this:Lookup("Wnd_SvrList/Scroll_ServerList"):ScrollNext(1)
						end
					end
					break
				end
			end
		end
		return 1
	end
	
	return 0
end

function LoginServerList.SelectServer(hServer)
	if not hServer.bSelected then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		
		local hP = hServer:GetParent()
		local nCount = hP:GetItemCount() - 1
		for i = 0, nCount, 1 do
			local hC = hP:Lookup(i)
			if hC.bSelected then
				hC.bSelected = false
				hC:Lookup("Image_SelectBg"):Hide()
				break
			end
		end
		
		hServer.bSelected = true
		hServer:Lookup("Image_SelectBg"):Show()
		hServer:Lookup("Image_SelectBg"):SetAlpha(255)
	end

	LoginServerList.szServer = hServer.szName
end

function LoginServerList.UpdateSelectionHightlight()
	local region = Station.Lookup("Topmost/LoginServerList/Wnd_Region")
	local server = Station.Lookup("Topmost/LoginServerList/Wnd_SvrList")
	local focus = Station.GetFocusWindow()
	
	if focus == region then
		local handle = server:Lookup("", "Handle_ServerList")
		local nCount = handle:GetItemCount() - 1
		for i = 0, nCount, 1 do
			local hI = handle:Lookup(i)
			if hI.bSelected then
				hI:Lookup("Image_SelectBg"):SetAlpha(127)
				break
			end
		end
		handle = region:Lookup("", "Handle_RList")
		nCount = handle:GetItemCount() - 1
		for i = 0, nCount, 1 do
			local hI = handle:Lookup(i)
			if hI.bSelected then
				hI:Lookup("Image_Sel"):SetAlpha(255)
				break
			end
		end
		return
	end
	if focus == server then
		local handle = region:Lookup("", "Handle_RList")
		local nCount = handle:GetItemCount() - 1
		for i = 0, nCount, 1 do
			local hI = handle:Lookup(i)
			if hI.bSelected then
				hI:Lookup("Image_Sel"):SetAlpha(127)
				break
			end
		end
		handle = server:Lookup("", "Handle_ServerList")
		nCount = handle:GetItemCount() - 1
		for i = 0, nCount, 1 do
			local hI = handle:Lookup(i)
			if hI.bSelected then
				hI:Lookup("Image_SelectBg"):SetAlpha(255)
				break
			end
		end
		return
	end
end;

function LoginServerList.SelectRegion(hRegion)
	if not hRegion.bSelected then
		local hP = hRegion:GetParent()
		local nCount = hP:GetItemCount() - 1
		for i = 0, nCount, 1 do
			local hC = hP:Lookup(i)
			if hC.bSelected then
				hC.bSelected = false
				hC:Lookup("Text_R"):SetFontScheme(162)
				hC:Lookup("Image_Sel"):Hide()
				break
			end
		end
		
		hRegion.bSelected = true
		hRegion:Lookup("Text_R"):SetFontScheme(163)
		hRegion:Lookup("Image_Sel"):Show()
		hRegion:Lookup("Image_Sel"):SetAlpha(255)
	    
	    local nRegionId = LoginServerList.GetRegionId(LoginServerList.tServerList, hRegion.szName)
	    if not nRegionId then
	        return
	    end
	    
		LoginServerList.UpdateServerList(hRegion:GetRoot():Lookup("Wnd_SvrList", "Handle_ServerList"), nRegionId)
		LoginServerList.UpdateSelectionHightlight()
	end	

	LoginServerList.szRegion = hRegion.szName
end

function LoginServerList.GetRegionId(tRegionList, szRegionName)
    local nId = nil
    if not tRegionList or not szRegionName then
        return nId
    end
    for i, aRegionInfo in pairs(tRegionList) do
        if aRegionInfo.szRegionName == szRegionName then
            nId = i
            break
        end
    end
    return nId
end

function LoginServerList.GetServerId(tServerList, szSvrName)
    local nId = nil
    if not tServerList or not szSvrName then
        return nId
    end
    for i, aServerInfo in pairs(tServerList) do
        if aServerInfo.szSvrName == szSvrName then
            nId = i
            break
        end
    end
    return nId
end

function LoginServerList.RequestRoleNum()
    local szUserName = Login.m_szAccount
    if not szUserName or szUserName == "" then
        return
    end
    local szUrl = "/info.php?"
    szUrl = szUrl.."UserName="..szUserName.."&type=2"
    Interaction_Request("RoleNum", tUrl.ServerList, szUrl, "", 80)
end

function LoginServerList.RequestRemoteServerList()
    local szUrl = GetServerListUrl()
    if not szUrl or szUrl == "" then
		g_bRequestRemoteServerList = false
		g_bRequestRemoteServerListSuccess = true
		LoginServerList.HandleInteractionRequestResult()
    	return
    end
    
    if not g_bRequestRemoteServerList then
	    g_bRequestRemoteServerList = true
	    g_bRequestRemoteServerListSuccess = false
	    
	    Station.Lookup("Topmost1/LoginWaitServerList"):Show()
	
	    Interaction_Request("SvrState", szUrl, "", "", 80)
	end
end

function LoginServerList.UpdateRoleNum(szValue)
    for szRegionName, szSvrName, nRoleNum in string.gfind(szValue, "([^\t]+)[\t]([^\t]+)[\t]([^\n]+)[\n]") do
        if szRegionName and szSvrName and nRoleNum then
            local nRegionId = LoginServerList.GetRegionId(LoginServerList.tServerList, szRegionName)
            local nServerId = LoginServerList.GetServerId(LoginServerList.tServerList[nRegionId], szSvrName)
            if nRegionId and nServerId and LoginServerList.tServerList[nRegionId][nServerId] then
                LoginServerList.tServerList[nRegionId][nServerId].nRoleNum = tonumber(nRoleNum)
            end
        end
    end
    
    local hRoot = Station.Lookup("Topmost/LoginServerList")
	if not hRoot then
		return
	end
	local hServerList = hRoot:Lookup("Wnd_SvrList", "Handle_ServerList")
	if not hServerList then
	    return
	end
	if LoginServerList.szRegion == "" then
	    return
	end
    local nRegionId = LoginServerList.GetRegionId(LoginServerList.tServerList, LoginServerList.szRegion)
    if not nRegionId then
        return
    end
    LoginServerList.UpdateServerList(hServerList, nRegionId)
end

local function ParseServerListFromString(szValue)
	local _, nLine, szLine = nil, 0, nil
	local tServerList = {}
	while true do
		_, nLine, szLine = string.find(szValue, "([^\n]+)[\n]", nLine + 1)
		if nLine == nil then
			break
		end
		local tServer = {}
		for k in string.gmatch(szLine, "([^\t]+)") do
			table.insert(tServer, k)
		end
		table.insert(tServerList, tServer)
	end
	return tServerList
end

function LoginServerList.GetRemoteServerListInfo(szValue)
	if not szValue then
		return
	end
	
	local tServerList = ParseServerListFromString(szValue)
	if not tServerList then
		return
	end

	local nRegionId = 0
	local nServerId = 0
	local nCommendId = 1
	for i,v in ipairs(tServerList) do
		local szRegionName = v[1]
		local szServerName = v[2]
		local szServerState = v[3]
		local szIP = v[4]
		local szPort = v[5]
		local szShowRegionName = v[6]
		local szShowServerName = v[7]
		local szAreaID = v[8]
		local szGroupID = v[9]
		
		if not szShowRegionName then
			szShowRegionName = szRegionName
		end
		
		if not szShowServerName then
			szShowServerName = szServerName
		end

		if szRegionName and szServerName and szServerState and szIP and szPort and szShowRegionName and szShowServerName then
			if nRegionId == 0 or LoginServerList.tServerServerList[nRegionId].szRegionName ~= szRegionName then
				nRegionId = nRegionId + 1;
				nServerId = 1;
				LoginServerList.tServerServerList[nRegionId] = {szRegionName = szRegionName, szShowRegionName = szShowRegionName}
			end
			
			local nPort = tonumber(szPort)
			local nState = tonumber(szServerState)
    		
			if nState == 0 then
				if nCommendId == 1 then
					LoginServerList.tServerServerList[0] = {szRegionName = g_tGlue.STR_SERVER_STATUS_COMMEND, szShowRegionName = g_tGlue.STR_SERVER_STATUS_COMMEND}
				end
    			LoginServerList.tServerServerList[0][nCommendId] = {
					nId = nCommendId,
					szSvrName = szRegionName.." "..szServerName,
					szShowSvrName = szShowRegionName.." "..szShowServerName,
					szIP = szIP,
					nPort = nPort,
					nState = nState,
					nRoleNum = 0,
					nAreaID = tonumber(szAreaID),
					nGroupID = tonumber(szGroupID),
				}
				nCommendId = nCommendId + 1
    		end
			
			LoginServerList.tServerServerList[nRegionId][nServerId] = {
        		nId = nServerId,
        		szSvrName = szServerName,
        		szShowSvrName = szShowServerName,
        		szIP = szIP,
        		nPort = nPort,
        		nState = nState,
        		nRoleNum = 0,
        		nAreaID = tonumber(szAreaID),
        		nGroupID = tonumber(szGroupID),
		}
		nServerId = nServerId + 1
		end
	end
    
    if #LoginServerList.tServerServerList > 0 then
    	LoginServerList.tServerList = LoginServerList.tServerServerList
    end
    
	local frame = Station.Lookup("Topmost/LoginServerList")
	if not frame then
		return
	end
	
	local handle = frame:Lookup("Wnd_Region", "Handle_RList")
	if not handle then
		return
	end
	LoginServerList.UpdateRegionList(handle)
end

function LoginServerList.GetLocalRegionListInfo()
	local iniRegion = Ini.AdjustOpen("ui/Scheme/Case/RegionList.ini")
	local nCommendId = 1
	if iniRegion then
		local szSection = iniRegion:GetNextSection("")
		local nId = 1;
		while szSection and szSection ~= "" do
			local szRegionName = iniRegion:ReadString(szSection, "$Name", "") 
			local szShowRegionName = iniRegion:ReadString(szSection, "$Label", "") 
			local szFile = iniRegion:ReadString(szSection, "SvrList", "") 
			
			if szShowRegionName == "" then
				szShowRegionName = szRegionName
			end
			
			LoginServerList.tLocalServerList[nId] = {szRegionName = szRegionName, szShowRegionName = szShowRegionName}
			
			nCommendId = LoginServerList.GetLocalServerListInfo(nId, nCommendId, szFile)

			szSection = iniRegion:GetNextSection(szSection)
			nId = nId + 1
		end
		iniRegion:Close()
		LoginServerList.tServerList = LoginServerList.tLocalServerList
	else
		Trace("UI Login Error open ui/Scheme/Case/RegionList.ini failed!\n")	
	end
end

function LoginServerList.GetLocalServerListInfo(nRegionId, nCommendId, szFile)
    local iniServer = Ini.AdjustOpen(szFile)
    if iniServer then
    	local szSection = iniServer:GetNextSection("")
    	local nId = 1;
    	while szSection and szSection ~= "" do
    		local szServerName = iniServer:ReadString(szSection, "$Name", "") 
    		local szServerIP = iniServer:ReadString(szSection, "IP", "")
    		local nServerPort = iniServer:ReadInteger(szSection, "Port", 5622)
    		local szServerState = iniServer:ReadString(szSection, "State", g_tGlue.STR_SERVER_STATUS_SMOOTHLY)
    		local szShowServerName = iniServer:ReadString(szSection, "$Label", "") 
    		local nServerAreaID = nil 
    		local nServerGroupID = nil
    		
    		if szShowServerName == "" then
    			szShowServerName = szServerName
    		end

    		local _,_,_,szVersionType = GetVersion()
    		if szVersionType == "snda" then
    			nServerAreaID, nServerGroupID = SdoaGetAreaInfo()

	    		nServerAreaID = iniServer:ReadInteger(szSection, "AreaID", nServerAreaID)
    			nServerGroupID = iniServer:ReadInteger(szSection, "GroupID", nServerGroupID)
    		end

    		local nServerState = nil
            for i, tServer in pairs(LoginServerList.tServerState) do
                if tServer.szState == szServerState then
                    nServerState = i
                    break
                end
            end
    		if not nServerState then
    		    Trace("ServerState: "..szServerState.." not exist!")
    		    return nCommendId
    		end
    		
    		if szServerState == g_tGlue.STR_SERVER_STATUS_COMMEND then
    			if nCommendId == 1 then
					LoginServerList.tLocalServerList[0] = {szRegionName = g_tGlue.STR_SERVER_STATUS_COMMEND, szShowRegionName = g_tGlue.STR_SERVER_STATUS_COMMEND}
				end
    			LoginServerList.tLocalServerList[0][nCommendId] = {
	        		nId = nCommendId,
	        		szSvrName = LoginServerList.tLocalServerList[nRegionId].szRegionName.." "..szServerName,
	        		szShowSvrName = LoginServerList.tLocalServerList[nRegionId].szShowRegionName.." "..szShowServerName,
	        		szIP = szServerIP,
	        		nPort = nServerPort,
	        		nState = nServerState,
	        		nAreaID = nServerAreaID,
	        		nGroupID = nServerGroupID,
	        		nRoleNum = 0,
				}
				nCommendId = nCommendId + 1
    		end
    		
    		LoginServerList.tLocalServerList[nRegionId][nId] = {
        		nId = nId,
        		szSvrName = szServerName,
        		szShowSvrName = szShowServerName,
        		szIP = szServerIP,
        		nPort = nServerPort,
        		nState = nServerState,
        		nAreaID = nServerAreaID,
        		nGroupID = nServerGroupID,
        		nRoleNum = 0,
    		}
    		
    		szSection = iniServer:GetNextSection(szSection)
    		nId = nId + 1
    	end
    	iniServer:Close()
    else
    	Trace("UI Login Error open server list file:"..tostring(szFile).." failed!\n")	
    end
    
    return nCommendId
end

function LoginServerList.UpdateRegionList(handle)
	handle:Clear()
	
	for _, aRegionInfo in pairs(LoginServerList.tServerList) do
		handle:AppendItemFromIni("UI/Config/Default/LoginServerList.ini", "Handle_R", "")
		local hI = handle:Lookup(handle:GetItemCount() - 1)
		if aRegionInfo.szShowRegionName == g_tGlue.STR_SERVER_STATUS_COMMEND then
			hI:SetIndex(0)
			hI = handle:Lookup(0)
		end
		hI:Lookup("Text_R"):SetText(aRegionInfo.szShowRegionName)
		hI.szName = aRegionInfo.szRegionName
		hI.szShowName = aRegionInfo.szShowRegionName
		hI.bSelected = false
	end
	
	LoginServerList.UpdateSelectedServer()
	LoginServerList.UpdateScrollInfo(handle)
end

function LoginServerList.SortServerList(nRegionId)
    if LoginServerList.tServerList[nRegionId] then
        local fnSort = function(tServer1, tServer2)
            if tServer1.nRoleNum == tServer2.nRoleNum then
                if tServer1.nState == tServer2.nState then
                    return tServer1.nId < tServer2.nId
                else
                    return tServer1.nState < tServer2.nState
                end
            else
                return tServer1.nRoleNum > tServer2.nRoleNum
            end
        end
        table.sort(LoginServerList.tServerList[nRegionId], fnSort)
    end
end

function LoginServerList.RandomCommendServers(nRegionId)
	if not LoginServerList.tServerList[nRegionId] then
		return
	end
	
	local nBeginIndex = nil
	local nEndIndex = nil
	for i, aSvrInfo in ipairs(LoginServerList.tServerList[nRegionId]) do
		if aSvrInfo.nState == 0 and aSvrInfo.nRoleNum == 0 then
			if not nBeginIndex then
				nBeginIndex = i
				nEndIndex = i
			else
				nEndIndex = nEndIndex + 1
			end
		else
			if nBeginIndex then
				break
			end
		end
	end
	
	if not nBeginIndex then
		return
	end
	
	if nBeginIndex == nEndIndex then
		return
	end
	
	for i = nBeginIndex, nEndIndex do
		local nRandIndex = math.random(i, nEndIndex)
		LoginServerList.tServerList[nRegionId][i], LoginServerList.tServerList[nRegionId][nRandIndex] =
		 		LoginServerList.tServerList[nRegionId][nRandIndex], LoginServerList.tServerList[nRegionId][i]
	end
end

function LoginServerList.UpdateServerList(handle, nRegionId)
    LoginServerList.SortServerList(nRegionId)
    LoginServerList.RandomCommendServers(nRegionId)
	handle:Clear()
	
    for _, aSvrInfo in ipairs(LoginServerList.tServerList[nRegionId]) do
		handle:AppendItemFromIni("UI/Config/Default/LoginServerList.ini", "Handle_Server", "")
		local hI = handle:Lookup(handle:GetItemCount() - 1)
		
		local font = LoginServerList.tServerState[aSvrInfo.nState].font
		hI:Lookup("Text_Name"):SetFontScheme(font)
		hI:Lookup("Text_Status"):SetFontScheme(font)
		hI:Lookup("Text_RoleNum"):SetFontScheme(font)
		
		if IsDebug() then
			hI:Lookup("Text_Name"):SetText(aSvrInfo.szShowSvrName.."("..aSvrInfo.szIP..")")
		else
			hI:Lookup("Text_Name"):SetText(aSvrInfo.szShowSvrName)
		end
    	hI:Lookup("Text_Status"):SetText(LoginServerList.tServerState[aSvrInfo.nState].szState)
    	if aSvrInfo.nRoleNum > 0 then
    	    hI:Lookup("Text_RoleNum"):SetText("("..aSvrInfo.nRoleNum..")")
    	end
    	
    	hI.szName = aSvrInfo.szSvrName
    	hI.szShowName = aSvrInfo.szShowSvrName
    	hI.szIP = aSvrInfo.szIP
    	hI.nPort = aSvrInfo.nPort
    	hI.nAreaID = aSvrInfo.nAreaID
    	hI.nGroupID = aSvrInfo.nGroupID
    	hI.bSelected = false
    end
    
	local bSel = false
	if LoginServerList.szServer then
		local nCount = handle:GetItemCount() - 1
		for i = 0, nCount, 1 do
			local hI = handle:Lookup(i)
			if hI.szName == LoginServerList.szServer then
				LoginServerList.SelectServer(hI)
				bSel = true
			end
		end
	end
	if not bSel then
		local hI = handle:Lookup(0)
		if hI then
			LoginServerList.SelectServer(hI)
		end	
	end
	
	LoginServerList.UpdateScrollInfo(handle)
end

function LoginServerList.SetSelectedServer(szRegion, szServer)
	LoginServerList.szRegion = szRegion
	LoginServerList.szServer = szServer
end

function LoginServerList.UpdateSelectedServer()	
	local frame = Station.Lookup("Topmost/LoginServerList")
	if not frame then
		return
	end
	local handle = frame:Lookup("Wnd_Region", "Handle_RList")
	local nCount = handle:GetItemCount() - 1
	local bSel = false
	for i = 0, nCount, 1 do
		local hI = handle:Lookup(i)
		if hI.szName == LoginServerList.szRegion then
			LoginServerList.SelectRegion(hI)
			bSel = true
			break
		end
	end
	if not bSel then
		local hI = handle:Lookup(0)
		if hI then
			LoginServerList.SelectRegion(hI)
		end
	end
	
	handle = frame:Lookup("Wnd_SvrList", "Handle_ServerList")
	nCount = handle:GetItemCount() - 1
	bSel = false
	for i = 0, nCount, 1 do
		local hI = handle:Lookup(i)
		if hI.szName == LoginServerList.szServer then
			LoginServerList.SelectServer(hI)
			bSel = true
			break
		end
	end
	if not bSel then
		local hI = handle:Lookup(0)
		if hI then
			LoginServerList.SelectServer(hI)
		end
	end
end

function LoginServerList.GetSelectedServer()
	local szRegion = LoginServerList.szRegion
	local szServer = LoginServerList.szServer
	local szIP = "127.0.0.1"
	local nPort = 5622
	local nAreaID = nil
	local nGroupID = nil
	
	LoginServerList.ConvertRegionNameAndServerName()
	LoginServerList.UpdateSelectedServer()
	
	local frame = Station.Lookup("Topmost/LoginServerList")
	if frame then
		local handle = frame:Lookup("Wnd_SvrList", "Handle_ServerList")
		local nCount = handle:GetItemCount() - 1
		for i = 0, nCount, 1 do
			local hI = handle:Lookup(i)
			if hI.bSelected then
				szIP = hI.szIP
				nPort = hI.nPort
				nAreaID = hI.nAreaID
				nGroupID = hI.nGroupID
				break
			end
		end
	end
	
	return szRegion, szServer, szIP, nPort, nAreaID, nGroupID
end

function LoginServerList.GetSelectedShowServer()
	local szRegion = LoginServerList.szRegion
	local szServer = LoginServerList.szServer
	local szIP = "127.0.0.1"
	local nPort = 5622
	local nAreaID = nil
	local nGroupID = nil
	
	LoginServerList.ConvertRegionNameAndServerName()
	LoginServerList.UpdateSelectedServer()
	
	local frame = Station.Lookup("Topmost/LoginServerList")
	
	if frame then
		local hRList = frame:Lookup("Wnd_Region", "Handle_RList")
		local nRCount = hRList:GetItemCount() - 1
		for i = 0, nRCount, 1 do
			local hI = hRList:Lookup(i)
			if hI.bSelected then
				szRegion = hI.szShowName
				break
			end
		end
		
		local hServerList = frame:Lookup("Wnd_SvrList", "Handle_ServerList")
		local nSCount = hServerList:GetItemCount() - 1
		for i = 0, nSCount, 1 do
			local hI = hServerList:Lookup(i)
			if hI.bSelected then
				szServer = hI.szShowName
				szIP = hI.szIP
				nPort = hI.nPort
				nAreaID = hI.nAreaID
				nGroupID = hI.nGroupID
				break
			end
		end
	end
	
	return szRegion, szServer, szIP, nPort, nAraaID, nGroupID
end

function LoginServerList.OnItemLButtonDown()
	local szName = this:GetParent():GetName()
	if szName == "Handle_ServerList" then
		LoginServerList.SelectServer(this)
	elseif szName == "Handle_RList" then
		LoginServerList.SelectRegion(this)
	end
	LoginServerList.UpdateSelectionHightlight()
end

function LoginServerList.OnItemLButtonDBClick()
	PlaySound(SOUND.UI_SOUND, g_sound.Button)
	LoginServerList.AcceptSelection()
end

function LoginServerList.CheckRoleCount()
	local nRealRoleCount = Login_GetRoleCount()
    local szRegion, szServer = LoginServerList.szRegion, LoginServerList.szServer
    local nRegionId = LoginServerList.GetRegionId(LoginServerList.tServerList, szRegion)
    local nServerId = LoginServerList.GetServerId(LoginServerList.tServerList[nRegionId], szServer)
    
    if nRegionId and nServerId and LoginServerList.tServerList[nRegionId][nServerId] then
        local nRoleCount = LoginServerList.tServerList[nRegionId][nServerId].nRoleNum
        if nRoleCount ~= nRealRoleCount then
            LoginServerList.SendRoleCount(nRealRoleCount)
        end
        LoginServerList.tServerList[nRegionId][nServerId].nRoleNum = nRealRoleCount
    end
end

function LoginServerList.SendRoleCount(nRoleCount)
    local szRegion, szServer = LoginServerList.szRegion, LoginServerList.szServer
    local szUserName = GetUserAccount()
    if szRegion and szRegion~= "" and szServer and szServer ~= "" and szUserName and szUserName ~= "" then
        szUrl = "/info.php?"
        szUrl = szUrl.."Server="..szRegion.."_"..szServer.."&UserName="..szUserName.."&Number="..nRoleCount.."&type=1"
        Interaction_Send("CheckRoleNum", tUrl.ServerList, szUrl, "", 80)
    end
end

function LoginServerList.ConvertRegionNameAndServerName()
	if LoginServerList.szRegion == g_tGlue.STR_SERVER_STATUS_COMMEND then
		_, _, LoginServerList.szRegion, LoginServerList.szServer = string.find(LoginServerList.szServer, "(%S+)%s+(%S+)")
	end
end
