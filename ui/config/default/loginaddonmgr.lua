g_tAddonEnable = {}
g_tAddonDisable = {}
g_tAddonVersion = {}
g_tAddOnEnbaleOverdue = {}

RegisterCustomData("LoginAccount/g_tAddonEnable")
RegisterCustomData("LoginAccount/g_tAddonDisable")
RegisterCustomData("LoginAccount/g_tAddonVersion")
RegisterCustomData("LoginAccount/g_tAddOnEnbaleOverdue")

function InitRoleAddonSetting(szRole)
	InitAddOn()
	if not szRole then
		Log("[UI]  function InitRoleAddonSetting(szRole)  szRole == nil")
		return
	end
	
	local aEnable = g_tAddonEnable[szRole] or {}
	local aDisable = g_tAddonDisable[szRole] or {}
	local szVersion = g_tAddonVersion[szRole] or "0.0"
	local szCurrentVersion = GetAddOnVersion()
	SetCurrentAddOnVersion(szCurrentVersion)
	local bEnableOverdue = g_tAddOnEnbaleOverdue[szRole]
    --[[
	if szVersion ~= szCurrentVersion then
		bEnableOverdue = false
	end
    ]]
	EnableOverdueAddOn(bEnableOverdue)
		
	Log("[UI ADDON] Init Addon ......")
	local nCount = GetAddOnCount() - 1
	for i = 0, nCount, 1 do
		local aInfo = GetAddOnInfo(i)
		if aEnable[aInfo.szID] then
			EnableAddOn(i, true)
			Log("[UI ADDON] Enable Addon: " .. tostring(aInfo.szName) .. " (" .. tostring(aInfo.szVersion) .. ")")
		end
		if aDisable[aInfo.szID] then
			DisableAddOn(i, true)
		end
	end
end

function LoadLoginRoleAddon()
	local szRoleName = GetUserRoleName()
	InitRoleAddonSetting(szRoleName)
	LoadAddOn()
	g_tAddonVersion[szRoleName] = GetAddOnVersion()
end

function OnManageRoleAddon(szRoleName)
	InitRoleAddonSetting(szRoleName)

	local frame = Wnd.OpenWindow("LoginAddonMgr")
	if not frame then
		return
	end
	frame:RegisterEvent("UI_SCALED")
	frame.OnEvent = function(event)
		if event == "UI_SCALED" then
			local wndAll = this:Lookup("Wnd_All")
			if wndAll then
				local w, h = wndAll:GetSize()
				local wAll, hAll = Station.GetClientSize()
				wndAll:SetRelPos((wAll - w) / 2, (hAll - h) / 2)
				this:SetSize(wAll, hAll)
			end
			this:UpdateScrollInfo()
		end
	end
	frame.OnFrameKeyDown = function()
		local szKey = GetKeyName(Station.GetMessageKey())
		if szKey == "Esc" then
			Wnd.CloseWindow("LoginAddonMgr")
			PlaySound(SOUND.UI_SOUND, g_sound.Button)
		end
		return 1
	end
	frame.UpdateScrollInfo = function(frame)
		local wndAll = frame:Lookup("Wnd_All")
		local handle = wndAll:Lookup("", "Handle_Addon")
		local scroll = wndAll:Lookup("Scroll_Addon")
	    local w, h = handle:GetSize()
	    local wAll, hAll = handle:GetAllItemSize()
	    local nStep = math.ceil((hAll - h) / 10)
		if nStep > 0 then
			scroll:Show()
			wndAll:Lookup("Btn_Up"):Show()
			wndAll:Lookup("Btn_Down"):Show()
			handle:GetParent():Lookup("Image_Scroll"):Show()
		else
			scroll:Hide()
			wndAll:Lookup("Btn_Up"):Hide()
			wndAll:Lookup("Btn_Down"):Hide()	
			handle:GetParent():Lookup("Image_Scroll"):Hide()
		end
	    scroll:SetStepCount(nStep)
	end
	
	local thisSave = this
	this = frame
	this.OnEvent("UI_SCALED")
	this = thisSave
	
	local wndAll = frame:Lookup("Wnd_All")
	
	local szVersion = GetAddOnVersion()
	wndAll:Lookup("", "Text_Version"):SetText(FormatString(g_tStrings.STR_ADDON_CURRENT_VERSION,  szVersion))
	
	Station.SetFocusWindow(wndAll)
	wndAll.szRoleName = szRoleName
	local handle = wndAll:Lookup("", "Handle_Addon")
	handle:Clear()
	handle.nCkeck = 6
	handle.nUnCkeck = 5

	local szIniFile = "ui\\Config\\Default\\LoginAddonMgr.ini"	
	local nAddonCount = GetAddOnCount() - 1
	

	for i = 0, nAddonCount, 1 do
		local aInfo = GetAddOnInfo(i)
		local hI = handle:AppendItemFromIni(szIniFile, "Handle_Item", "")
		hI.nIndex = i
		hI.bEnable = aInfo.bEnable or (aInfo.bDefault and not aInfo.bDisable)
		hI.bDisable = aInfo.bDisable
		hI.bDefault = aInfo.bDefault
		hI.szDependence = aInfo.szDependence
		hI.szWeakDependence = aInfo.szWeakDependence
		hI.szVersion = aInfo.szVersion
		hI.szID = aInfo.szID
		hI.szName = aInfo.szName
		hI.szDesc = aInfo.szDesc
		local nFrame = handle.nUnCkeck
		if hI.bEnable then
			nFrame = handle.nCkeck
		end
		local imgCheck = hI:Lookup("Image_Check")
		imgCheck:SetFrame(nFrame)
		imgCheck.OnItemLButtonDown = function()
		end
		imgCheck.OnItemLButtonUp = function()
		end
		imgCheck.OnItemLButtonClick = function()
			local hP = this:GetParent()
			local hPP = hP:GetParent()
			if hP.bEnable then
				hP:DisableAddOn()
				--数据分析
				if hP.bNowEnable then
					hP.bNowEnable = false
					FireDataAnalysisEvent("USE_PLUGIN",{false})
				end
			else
				local fnEnableAddOnSure = function ()
					if hP:IsValid() then
						hP:EnableAddOn()
						--数据分析
						hP.bNowEnable = true
						FireDataAnalysisEvent("USE_PLUGIN",{true})
					end
				end
				local szAddonName = hP:Lookup("Text_Name"):GetText()
				local szMsg = FormatString(g_tStrings.STR_ADDON_ENABLE_SURE, szAddonName)
				local hItem = this
				local tMsg = 
				{
					szMessage = szMsg, 
					szName = "Addon_Enable_Sure", 
					fnAutoClose = function() return not hItem:IsValid() end,
					{
						szOption = g_tStrings.STR_HOTKEY_SURE, 
						fnAction = fnEnableAddOnSure,
					},
					{
						szOption = g_tStrings.STR_HOTKEY_CANCEL, 
					}
				}
				MessageBox(tMsg)
			end
			
			PlaySound(SOUND.UI_SOUND, g_sound.Button)
		end
		
		hI.DisableAddOn = function(hI)
			if not hI:IsValid() then
				return
			end

			local hP = hI:GetParent()
			hI.bEnable = false
			hI:Lookup("Image_Check"):SetFrame(hP.nUnCkeck)
			
			EnableAddOn(hI.nIndex, hI.bEnable)
			DisableAddOn(hI.nIndex, not hI.bEnable)
			
			hP:GetRoot():Lookup("Wnd_All"):Lookup("CheckBox_Allchoose"):UpdateState()
		end
		
		hI.EnableAddOn = function(hI)
			if not hI:IsValid() then
				return
			end
			
			local hP = hI:GetParent()
			hI.bEnable = true
			hI:Lookup("Image_Check"):SetFrame(hP.nCkeck)
			
			EnableAddOn(hI.nIndex, hI.bEnable)
			DisableAddOn(hI.nIndex, not hI.bEnable)
			
			hI:GetDependence()
			
			for k, v in pairs(hI.aStrong) do
				local nIndex = GetAddOnIndexByID(v)
				local hD = hP:Lookup(nIndex)
				if hD and not hD.bEnable then
					hD:EnableAddOn()
				end
			end

			for k, v in pairs(hI.aWeak) do
				local nIndex = GetAddOnIndexByID(v)
				local hD = hP:Lookup(nIndex)
				if hD and not hD.bEnable then
					hD:EnableAddOn()
				end
			end
			hP:GetRoot():Lookup("Wnd_All"):Lookup("CheckBox_Allchoose"):UpdateState()
		end
		
		hI.GetDependence = function(hI)
			if hI.aStrong and hI.aWeak then
				return
			end
			hI.aStrong = {}
			local szDependence = hI.szDependence..";"	
			local nStart = 1
			local nEnd = StringFindW(szDependence, ";")
			while nEnd do
				local w = string.sub(szDependence, nStart, nEnd - 1)
				if w and w ~= "" then
					table.insert(hI.aStrong, w)
				end
				nStart = nEnd + 1
				nEnd = StringFindW(szDependence, ";", nStart)
			end

			hI.aWeak = {}
			local szDependence = hI.szWeakDependence..";"	
			local nStart = 1
			local nEnd = StringFindW(szDependence, ";")
			while nEnd do
				local w = string.sub(szDependence, nStart, nEnd - 1)
				if w and w ~= "" then
					table.insert(hI.aWeak, w)
				end
				nStart = nEnd + 1
				nEnd = StringFindW(szDependence, ";", nStart)
			end			
		end

		local textName = hI:Lookup("Text_Name")
		local textDesc = hI:Lookup("Text_Desc")
		textName:SetText(hI.szName)
		textDesc:SetText(hI.szDesc)
		if hI.szVersion ~= szVersion then
			textName:SetFontScheme(161)
			textDesc:SetFontScheme(161)
		else
			textName:SetFontScheme(18)
			textDesc:SetFontScheme(18)
		end
		
		hI.OnItemMouseEnter = function()
			this:Lookup("Image_Over"):Show()
			
			this:GetDependence()
			
			local szTip = GetFormatText(this.szName.."\n", 65)
			
			if this.szVersion ~= GetAddOnVersion() then
				szTip = szTip..GetFormatText(FormatString(g_tStrings.STR_ADDON_VERSION1.."\n",  this.szVersion), 161)
			else
				szTip = szTip..GetFormatText(FormatString(g_tStrings.STR_ADDON_VERSION.."\n",  this.szVersion), 106)
			end
			
			szTip = szTip..GetFormatText(this.szDesc.."\n", 106)
			
			if #(this.aStrong) > 0 then
				szTip = szTip..GetFormatText(g_tStrings.STR_ADDON_STRONG_DEPENDENCE.."\n", 106)
				for k, v in ipairs(this.aStrong) do
					local nIndex = GetAddOnIndexByID(v)
					local aInfo = GetAddOnInfo(nIndex)
					if aInfo then
						szTip = szTip..GetFormatText(g_tStrings.STR_TWO_CHINESE_SPACE..aInfo.szName.."("..v..")".."\n", 106)
					else
						szTip = szTip..GetFormatText(g_tStrings.STR_TWO_CHINESE_SPACE..v.."\n", 102)
					end
				end
			end

			if #(this.aStrong) > 0 then
				szTip = szTip..GetFormatText(g_tStrings.STR_ADDON_WEAK_DEPENDENCE.."\n", 106)
				for k, v in ipairs(this.aStrong) do
					local nIndex = GetAddOnIndexByID(v)
					local aInfo = GetAddOnInfo(nIndex)
					if aInfo then
						szTip = szTip..GetFormatText(g_tStrings.STR_TWO_CHINESE_SPACE..aInfo.szName.."("..v..")".."\n", 106)
					else
						szTip = szTip..GetFormatText(g_tStrings.STR_TWO_CHINESE_SPACE..v.."\n", 102)
					end
				end
			end
			
			local x, y = Cursor.GetPos()
			OutputTip(szTip, 400, {x, y, 40, 40})
		end
		hI.OnItemMouseLeave = function()
			this:Lookup("Image_Over"):Hide()
			HideTip()
		end
	end
	handle:FormatAllItemPos()
	
	handle.OnItemMouseWheel = function()
		local nDistance = Station.GetMessageWheelDelta()
		this:GetParent():GetParent():Lookup("Scroll_Addon"):ScrollNext(nDistance)
		return 1
	end	
    
	wndAll:Lookup("Btn_Up").OnLButtonDown = function()
		this.OnLButtonHold()
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	end
	wndAll:Lookup("Btn_Up").OnLButtonHold = function()
		this:GetParent():Lookup("Scroll_Addon"):ScrollPrev()
	end
	wndAll:Lookup("Btn_Down").OnLButtonDown = function()
		this.OnLButtonHold()
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	end
	wndAll:Lookup("Btn_Down").OnLButtonHold = function()
		this:GetParent():Lookup("Scroll_Addon"):ScrollNext()
	end
	
    local scroll = wndAll:Lookup("Scroll_Addon")
	scroll.OnScrollBarPosChanged = function()
		local nCurrentValue = this:GetScrollPos()
		local wndParent = this:GetParent()
		if nCurrentValue == 0 then
			wndParent:Lookup("Btn_Up"):Enable(false)
		else
			wndParent:Lookup("Btn_Up"):Enable(true)
		end
		
		if nCurrentValue == this:GetStepCount() then
			wndParent:Lookup("Btn_Down"):Enable(false)
		else
			wndParent:Lookup("Btn_Down"):Enable(true)
		end
		
		wndParent:Lookup("", "Handle_Addon"):SetItemStartRelPos(0, -nCurrentValue * 10)
	end
	frame:UpdateScrollInfo()
    
	wndAll:Lookup("Btn_Close").OnLButtonClick = function()
		Wnd.CloseWindow("LoginAddonMgr")
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	end
	
	wndAll:Lookup("Btn_Cancel").OnLButtonClick = function()
		Wnd.CloseWindow("LoginAddonMgr")
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	end
	
	wndAll:Lookup("Btn_Sure").OnLButtonClick = function()
		local szRoleName = this:GetParent().szRoleName
		
		g_tAddonEnable[szRoleName] = {}
		g_tAddonDisable[szRoleName] = {}
		local nCount = GetAddOnCount() - 1
		for i = 0, nCount, 1 do
			local aInfo = GetAddOnInfo(i)
			if aInfo.bEnable and not aInfo.bDefault then
				g_tAddonEnable[szRoleName][aInfo.szID] = true
			end
			if aInfo.bDisable then
				g_tAddonDisable[szRoleName][aInfo.szID] = true
			end
		end
		
		g_tAddonVersion[szRoleName] = GetAddOnVersion()
		g_tAddOnEnbaleOverdue[szRoleName] = this:GetParent():Lookup("CheckBox_Allpast"):IsCheckBoxChecked()
		
		Wnd.CloseWindow("LoginAddonMgr")
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	end
	
	local checkBox = wndAll:Lookup("CheckBox_Allchoose")
	checkBox.OnCheckBoxCheck = function()
		if this.bDisable then
			return
		end
		local hItem = this
		local fnEnableALLAddOnSure = function ()
			if hItem:IsValid() then
				local wndAll = hItem:GetParent()
				local handle = wndAll:Lookup("", "Handle_Addon")
				local nCount = handle:GetItemCount() - 1
				for i = 0, nCount, 1 do
					local hI = handle:Lookup(i)
					if not hI.bEnable then
						hI:EnableAddOn()
					end
				end
			end
		end
		local tMsg = 
		{
			szMessage = g_tStrings.STR_ADDON_ENABLE_All_SURE, 
			szName = "Addon_Enable_Sure", 
			fnAutoClose = function() return not hItem:IsValid() end,
			{
				szOption = g_tStrings.STR_HOTKEY_SURE, 
				fnAction = fnEnableALLAddOnSure,
			},
			{
				szOption = g_tStrings.STR_HOTKEY_CANCEL, 
			}
		}
		MessageBox(tMsg)
	end
	checkBox.OnCheckBoxUncheck = function()
		if this.bDisable then
			return
		end
		local wndAll = this:GetParent()
		local handle = wndAll:Lookup("", "Handle_Addon")
		local nCount = handle:GetItemCount() - 1
		for i = 0, nCount, 1 do
			local hI = handle:Lookup(i)
			if hI.bEnable then
				hI:DisableAddOn()
			end
		end
	end
	
	checkBox.UpdateState = function(checkBox)
		local wndAll = checkBox:GetParent()
		local handle = wndAll:Lookup("", "Handle_Addon")
		local nCount = handle:GetItemCount() - 1
		
		checkBox.bDisable = true
		local bAll = true
		for i = 0, nCount, 1 do
			local hI = handle:Lookup(i)
			if not hI.bEnable then
				bAll = false
				break
			end
		end
		checkBox:Check(bAll and nCount ~= 0)
		checkBox.bDisable = false
	end
	
	checkBox:UpdateState()

	local checkBox = wndAll:Lookup("CheckBox_Allpast")
	checkBox:Check(IsEnableOverdueAddOn())
	checkBox.OnCheckBoxCheck = function()
		local checkBox = this
		local msg = 
		{
			szMessage = g_tStrings.STR_ADDON_WARING, 
			szName = "Addon_Old_Sure", 
			fnAutoClose = function() return not checkBox:IsValid() end,
			{
				szOption = g_tStrings.STR_HOTKEY_SURE, 
				fnAction = function()
					if checkBox:IsValid() then
						checkBox:GetParent():Lookup("CheckBox_Allchoose"):UpdateState()
					end
				end 
			},
			{
				szOption = g_tStrings.STR_HOTKEY_CANCEL, 
				fnAction = function()
					if checkBox:IsValid() then
						checkBox:Check(false)
						checkBox:GetParent():Lookup("CheckBox_Allchoose"):UpdateState()
					end
				end
			}
		}
		MessageBox(msg)
	end
end

function AddOnMgr_setAddOnLoadParam(szRole, bEnableOverdue, szVersion)
	g_tAddOnEnbaleOverdue[szRole] = bEnableOverdue
	EnableOverdueAddOn(bEnableOverdue)
	g_tAddonVersion[szRole] = szVersion
end

function AddOnMgr_GetRoleAddonSaveVersion(szRole)
	local szVersion = g_tAddonVersion[szRole] or "0.0"
	return szVersion
end
