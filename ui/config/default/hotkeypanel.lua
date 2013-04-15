HotkeyPanel = 
{
	nNormalFrame = 53,
	nMouseOverFrame = 54,
	nDownFrame = 55,
	nDisableFrame = 56,
	nAutoModifiedFrame = 54,	--被替换的
	nSelfModifiedFrame = 56,	--已修改的
	nSelFrame = 55,			--当前修改的
	nUnchangeableFrame = 56,
	bSaveToServer = true,
}

RegisterCustomData("HotkeyPanel.bSaveToServer")

function HotkeyPanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")

	HotkeyPanel.Init(this)
	HotkeyPanel.SetChanged(this, false)
	HotkeyPanel.OnEvent("UI_SCALED")
end

function HotkeyPanel.OnEvent(event)
	if event == "UI_SCALED" then
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	end
end

function HotkeyPanel.SetChanged(frame, bChanged)
	frame.bChanged = bChanged
	frame:Lookup("Btn_Apply"):Enable(frame.bChanged)
end

function HotkeyPanel.Init(frame, bDefault)
	local handle = frame:Lookup("", "")
	local hList = handle:Lookup("Handle_List")
	local hKey = handle:Lookup("Handle_Hotkey")
	
	local aGroup = {}
	local aKey = {}
	local bindings = Hotkey.GetBinding(bDefault)
	
	if not bDefault then
		HotkeyPanel.tInitKeys = clone(bindings)
	end
	for k, v in pairs(bindings) do
		if v.szHeader ~= "" then	--添加组名
			aKey = {}
			table.insert(aGroup, {name = v.szHeader, key = aKey})
		end
		if not v.Hotkey1 then
			v.Hotkey1 = {nKey = 0, bShift = false, bCtrl = false, bAlt = false}
		end
		if not v.Hotkey2 then
			v.Hotkey2 = {nKey = 0, bShift = false, bCtrl = false, bAlt = false}
		end
		table.insert(aKey, v)
	end
	HotkeyPanel.aGroup = aGroup
	HotkeyPanel.UpdateList(hList)
	HotkeyPanel.Tip(handle, "")
	
	local checkBox = frame:Lookup("CheckBox_SaveToServer")
	checkBox.bDisable = true
	checkBox:Check(HotkeyPanel.bSaveToServer)
	checkBox.bDisable = false
end

function HotkeyPanel.UpdateList(hList)
	hList:Clear()
	local szIniFile = "UI/Config/default/HotkeyPanel.ini"
	for k, v in ipairs(HotkeyPanel.aGroup) do
		hList:AppendItemFromIni(szIniFile, "Handle_Group")
		local hI = hList:Lookup(k - 1)
		hI.bListGroup = true
		hI.nGroupIndex = k
		hI:Lookup("Text_Group"):SetText(v.name)		
	end
	HotkeyPanel.UpdataListScrollInfo(hList)
	HotkeyPanel.SelGroup(hList:Lookup(0))
end

function HotkeyPanel.UpdataListScrollInfo(hList)
	hList:FormatAllItemPos()
	local wAll, hAll = hList:GetAllItemSize()
    local w, h = hList:GetSize()
    local scroll = hList:GetParent():GetParent():Lookup("Scroll_List")
    local nCountStep = math.ceil((hAll - h) / 10)
    scroll:SetStepCount(nCountStep)
	scroll:SetScrollPos(0)
	if nCountStep > 0 then
		scroll:Show()
    	scroll:GetParent():Lookup("Btn_UpList"):Show()
    	scroll:GetParent():Lookup("Btn_DownList"):Show()
    else
    	scroll:Hide()
    	scroll:GetParent():Lookup("Btn_UpList"):Hide()
    	scroll:GetParent():Lookup("Btn_DownList"):Hide()
    end
end

function HotkeyPanel.UpdataContentScrollInfo(hkey)
	hkey:FormatAllItemPos()
	local wAll, hAll = hkey:GetAllItemSize()
    local w, h = hkey:GetSize()
    local scroll = hkey:GetParent():GetParent():Lookup("Scroll_Key")
    local nCountStep = math.ceil((hAll - h) / 10)
    scroll:SetStepCount(nCountStep)
	scroll:SetScrollPos(0)
	if nCountStep > 0 then
		scroll:Show()
    	scroll:GetParent():Lookup("Btn_Up"):Show()
    	scroll:GetParent():Lookup("Btn_Down"):Show()
    else
    	scroll:Hide()
    	scroll:GetParent():Lookup("Btn_Up"):Hide()
    	scroll:GetParent():Lookup("Btn_Down"):Hide()
    end
end


function HotkeyPanel.SelGroup(hI)
	if hI.bSel then
		return false
	end
	local hP = hI:GetParent()
	local nCount = hP:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hB = hP:Lookup(i)
		if hB.bSel then
			hB.bSel = false
			if hB.IsOver then
				hB:Lookup("Image_Sel"):SetAlpha(128)
				hB:Lookup("Image_Sel"):Show()
			else
				hB:Lookup("Image_Sel"):Hide()
			end
		end
	end
	hI.bSel = true
	hI:Lookup("Image_Sel"):SetAlpha(255)
	hI:Lookup("Image_Sel"):Show()
	HotkeyPanel.UpdateContent(hI:GetParent():GetParent():Lookup("Handle_Hotkey"), hI.nGroupIndex)
end

function HotkeyPanel.UpdateContent(hKey, nGroupIndex)
	Hotkey.SetCapture(false)
	hKey:Clear()
	hKey.nGroupIndex = nGroupIndex
	local aGroup = HotkeyPanel.aGroup[nGroupIndex]
	local szIniFile = "UI/Config/default/HotkeyPanel.ini"
	hKey:AppendItemFromIni(szIniFile, "Text_GroupName")
	hKey:Lookup(0):SetText(aGroup.name)
	hKey:Lookup(0).bGroup = true
	for k, v in ipairs(aGroup.key) do
		hKey:AppendItemFromIni(szIniFile, "Handle_Binding")
		local hI = hKey:Lookup(k)
		hI.bBinding = true
		hI.nIndex = k
		hI.szTip = v.szTip
		hI:Lookup("Text_Name"):SetText(v.szDesc)
		for i = 1, 2, 1 do
			local hK = hI:Lookup("Handle_Key"..i)
			hK.bKey = true
			hK.nIndex = i
			local hotkey = v["Hotkey"..i]
			hotkey.bUnchangeable = v.bUnchangeable
			hK.bUnchangeable = v.bUnchangeable
			local text = hK:Lookup("Text_Key"..i)
			text:SetText(GetKeyShow(hotkey.nKey, hotkey.bShift, hotkey.bCtrl, hotkey.bAlt))
			HotkeyPanel.UpdateBtnState(hK)
		end
	end
	HotkeyPanel.UpdataContentScrollInfo(hKey)
end

function HotkeyPanel.OnItemLButtonDown()
	if this.bListGroup then
		HotkeyPanel.bList = true
		HotkeyPanel.SelGroup(this)
	elseif this.bKey then
		HotkeyPanel.bList = false
		this.bDown = true
		HotkeyPanel.UpdateBtnState(this)
	elseif this:GetName() == "Handle_List" then
		HotkeyPanel.bList = true
	else
		HotkeyPanel.bList = false
	end
end

function HotkeyPanel.OnItemLButtonUp()
	if this.bKey then
		this.bDown = false
		HotkeyPanel.UpdateBtnState(this)
	end
end

function HotkeyPanel.UpdateBtnState(handle)
	local hotkey = HotkeyPanel.aGroup[handle:GetParent():GetParent().nGroupIndex]["key"][handle:GetParent().nIndex]["Hotkey"..handle.nIndex]
	if handle.bUnchangeable then
		handle:Lookup("Image_Key"..handle.nIndex):SetFrame(HotkeyPanel.nUnchangeableFrame)
	elseif handle.bDown then
		handle:Lookup("Image_Key"..handle.nIndex):SetFrame(HotkeyPanel.nDownFrame)
	elseif handle.bRDown then
		handle:Lookup("Image_Key"..handle.nIndex):SetFrame(HotkeyPanel.nDownFrame)
	elseif handle.bSel then
		handle:Lookup("Image_Key"..handle.nIndex):SetFrame(HotkeyPanel.nSelFrame)
	elseif handle.bOver then
		handle:Lookup("Image_Key"..handle.nIndex):SetFrame(HotkeyPanel.nMouseOverFrame)
	elseif hotkey.bChange then
		handle:Lookup("Image_Key"..handle.nIndex):SetFrame(HotkeyPanel.nSelfModifiedFrame)
	elseif hotkey.bConflict then
		handle:Lookup("Image_Key"..handle.nIndex):SetFrame(HotkeyPanel.nAutoModifiedFrame)
	else
		handle:Lookup("Image_Key"..handle.nIndex):SetFrame(HotkeyPanel.nNormalFrame)
	end
end

function HotkeyPanel.OnItemLButtonClick()
	if this.bKey and not this.bUnchangeable then
		HotkeyPanel.CancelSetHotkey(this:GetParent():GetParent())
		this.bSel = true
		HotkeyPanel.UpdateBtnState(this)		
		Hotkey.SetCapture(true)
		PlaySound(SOUND.UI_SOUND, g_sound.Button)	
	end
end

function HotkeyPanel.OnItemLButtonDBClick()
	HotkeyPanel.OnItemLButtonClick()
end

-----------右键操作-------------
function HotkeyPanel.OnItemRButtonDown()
	if this.bKey then
		this.bRDown = true
		HotkeyPanel.UpdateBtnState(this)
	end
end

function HotkeyPanel.OnItemRButtonUp(nNotInMe)
	if this.bKey then
		this.bRDown = false
		HotkeyPanel.UpdateBtnState(this)
	end
end

function HotkeyPanel.OnItemRButtonClick()
	if this.bKey and not this.bUnchangeable then
		this.bSel = false
		local hotkey = HotkeyPanel.aGroup[this:GetParent():GetParent().nGroupIndex]["key"][this:GetParent().nIndex]["Hotkey"..this.nIndex]
		if hotkey.nKey ~= 0 then
			hotkey.bChange = true
			hotkey.nKey = 0
			hotkey.bAlt = false
			hotkey.bCtrl = false
			hotkey.bShift = false
			this:Lookup("Text_Key"..this.nIndex):SetText("")
		end
		
		HotkeyPanel.UpdateBtnState(this)
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		HotkeyPanel.SetChanged(this:GetRoot(), true)
	end
end

function HotkeyPanel.OnItemRButtonDBClick()
	HotkeyPanel.OnItemRButtonClick()
end

function HotkeyPanel.OnItemMouseEnter()
	if this.bListGroup then
		this.bOver = true
		if not this.bSel then
			local img = this:Lookup("Image_Sel")
			img:SetAlpha(128)
			img:Show()
		end
	elseif this.bKey then
		this.bOver = true
		HotkeyPanel.UpdateBtnState(this)	
	end
end

function HotkeyPanel.OnItemMouseLeave()
	if this.bListGroup then
		this.bOver = false
		if not this.bSel then
			this:Lookup("Image_Sel"):Hide()
		end
	elseif this.bKey then
		this.bOver = false
		HotkeyPanel.UpdateBtnState(this)
	end
end

function HotkeyPanel.OnScrollBarPosChanged()
	local handle, btnUp, btnDown = nil, nil, nil
	if this:GetName() == "Scroll_Key" then
		handle = this:GetParent():Lookup("", "Handle_Hotkey")
		btnUp = this:GetParent():Lookup("Btn_Up")
		btnDown = this:GetParent():Lookup("Btn_Down")
	else
		handle = this:GetParent():Lookup("", "Handle_List")
		btnUp = this:GetParent():Lookup("Btn_UpList")
		btnDown = this:GetParent():Lookup("Btn_DownList")	
	end
	local nCurrentValue = this:GetScrollPos()
	if nCurrentValue == 0 then
		btnUp:Enable(0)
	else
		btnUp:Enable(1)
	end	
	
	if nCurrentValue == this:GetStepCount() then
		btnDown:Enable(0)
	else
		btnDown:Enable(1)
	end
	
	handle:SetItemStartRelPos(0, -10 * nCurrentValue)
end

function HotkeyPanel.OnLButtonDown()
	HotkeyPanel.OnLButtonHold()
end

function HotkeyPanel.OnLButtonHold()
	local szSelfName = this:GetName()
	if szSelfName == "Btn_Up" then
		this:GetParent():Lookup("Scroll_Key"):ScrollPrev(1)	
	elseif szSelfName == "Btn_Down" then
		this:GetParent():Lookup("Scroll_Key"):ScrollNext(1)
	elseif szSelfName == "Btn_UpList" then
		this:GetParent():Lookup("Scroll_List"):ScrollPrev(1)	
	elseif szSelfName == "Btn_DownList" then
		this:GetParent():Lookup("Scroll_List"):ScrollNext(1)
    end
end

function HotkeyPanel.OnLButtonClick()
	local szSelfName = this:GetName()
	if szSelfName == "Btn_Close" or szSelfName == "Btn_Cancel" then
		Hotkey.SetCapture(false)
		CloseHotkeyPanel()
	elseif szSelfName == "Btn_Default" then
		local msg = 
		{
			szName = "LoadDefaultHotkeySet", 
			szMessage = g_tStrings.STR_HOTKEY_LOAD_DEFAULT_SURE, 
			fnAutoClose = function() if IsHotkeyPanelOpened() then return false else return true end end,
			{szOption = g_tStrings.STR_HOTKEY_SURE, 	fnAction = function()
												local frame = Station.Lookup("Topmost/HotkeyPanel")
												if frame and frame:IsVisible() then
													HotkeyPanel.Init(frame, true)
													HotkeyPanel.SetChanged(frame, true)
												end
											end },
			{szOption = g_tStrings.STR_HOTKEY_CANCEL},
		}
		MessageBox(msg)
	elseif szSelfName == "Btn_Clear" then
		Hotkey.SetCapture(false)
		local handle = this:GetRoot():Lookup("", "Handle_Hotkey")
		HotkeyPanel.ClearCurrentSelKey(handle)
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	elseif szSelfName == "Btn_Sure" then
		Hotkey.SetCapture(false)
		local frame = this:GetRoot()
		HotkeyPanel.bSaveToServer = frame:Lookup("CheckBox_SaveToServer"):IsCheckBoxChecked()
		if frame.bChanged then
			HotkeyPanel.Save(frame)
		end
		CloseHotkeyPanel()
	elseif szSelfName == "Btn_Apply" then
		Hotkey.SetCapture(false)
		local frame = this:GetRoot()
		HotkeyPanel.bSaveToServer = frame:Lookup("CheckBox_SaveToServer"):IsCheckBoxChecked()
		HotkeyPanel.Save(frame)
		HotkeyPanel.SetChanged(frame, false)
		PlaySound(SOUND.UI_SOUND,g_sound.Button)
    end
end

function HotkeyPanel.OnCheckBoxCheck()
	local szName = this:GetName()
	if szName == "CheckBox_SaveToServer" then
		if not this.bDisable then
			HotkeyPanel.SetChanged(this:GetParent(), true)
		end
	end
end

function HotkeyPanel.OnCheckBoxUncheck()
	local szName = this:GetName()
	if szName == "CheckBox_SaveToServer" then
		if not this.bDisable then
			HotkeyPanel.SetChanged(this:GetParent(), true)
		end
	end
end

function HotkeyPanel.ClearCurrentSelKey(handle)
	local frame = handle:GetRoot()
	local bChange = false
	local nCount = handle:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = handle:Lookup(i)
		if hI.bBinding then
			local hK = hI:Lookup("Handle_Key1")
			if hK.bSel then
				hK.bSel = false
				local hotkey = HotkeyPanel.aGroup[handle.nGroupIndex]["key"][hI.nIndex]["Hotkey"..hK.nIndex]
				if hotkey.nKey ~= 0 then
					hotkey.bChange = true
					hotkey.nKey = 0
					hotkey.bAlt = false
					hotkey.bCtrl = false
					hotkey.bShift = false
					hK:Lookup("Text_Key"..hK.nIndex):SetText("")
					bChange = true
				end
				HotkeyPanel.UpdateBtnState(hK)
				break
			end
			local hK = hI:Lookup("Handle_Key2")
			if hK.bSel then
				hK.bSel = false
				local hotkey = HotkeyPanel.aGroup[handle.nGroupIndex]["key"][hI.nIndex]["Hotkey"..hK.nIndex]
				if hotkey.nKey ~= 0 then
					hotkey.bChange = true
					hotkey.nKey = 0
					hotkey.bAlt = false
					hotkey.bCtrl = false
					hotkey.bShift = false
					hK:Lookup("Text_Key"..hK.nIndex):SetText("")
					bChange = true
				end
				HotkeyPanel.UpdateBtnState(hK)
				break
			end
		end
	end
	if bChange then
		HotkeyPanel.SetChanged(frame, true)
	end
end

function HotkeyPanel.SaveToServer()
	local t = Hotkey.SaveToLuaAsAdd() or {}
	local nCount, nAdd, nPos, tValue = #t, 0, 1502, {}
	if nCount > 200 then
		OutputMessage("MSG_ANNOUNCE_RED", FormatString(g_tStrings.HOT_KEY_TO_LIMIT, nCount))
		nCount = 200
	end
	
	for i = 1, nCount, 1 do
		nAdd = nAdd + 1
		table.insert(tValue, t[i][1])
		table.insert(tValue, t[i][2])
		if nAdd == 10 then
			SetUserPreferences(nPos, "nnnnnnnnnnnnnnnnnnnn", unpack(tValue))
			nAdd, nPos, tValue = 0, nPos + 80, {}			
		end
	end
	if nAdd > 0 then
		local szTitle = ""
		for i = 1, nAdd, 1 do
			szTitle = szTitle.."nn"
		end
		SetUserPreferences(nPos, szTitle, unpack(tValue))
	end
	SetUserPreferences(1500, "bc", true, nCount)
end

function HotkeyPanel.Save(frame)
	Hotkey.Clear()
	for k, v in ipairs(HotkeyPanel.aGroup) do
		for i, vKey in ipairs(v.key) do
			if vKey.Hotkey1.nKey ~= 0 then
				Hotkey.Set(vKey.szCommand, 1, vKey.Hotkey1.nKey, vKey.Hotkey1.bShift, vKey.Hotkey1.bCtrl, vKey.Hotkey1.bAlt)
			end
			if vKey.Hotkey2.nKey ~= 0 then
				Hotkey.Set(vKey.szCommand, 2, vKey.Hotkey2.nKey, vKey.Hotkey2.bShift, vKey.Hotkey2.bCtrl, vKey.Hotkey2.bAlt)
			end
		end
	end

	if HotkeyPanel.bSaveToServer then	
		HotkeyPanel.SaveToServer()
	else
		local szPath = GetUserDataPath()
		if szPath == "" then
			return
		end
		Hotkey.SaveAsAdd(szPath.."\\hotkey_add.txt")
	end
end

function HotkeyPanel.OnItemMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	if HotkeyPanel.bList then
		local scroll = this:GetRoot():Lookup("Scroll_List")
		if scroll:IsVisible() then
			scroll:ScrollNext(nDistance)
		else
			this:GetRoot():Lookup("Scroll_Key"):ScrollNext(nDistance)
		end
	else
		local scroll = this:GetRoot():Lookup("Scroll_Key")
		if scroll:IsVisible() then
			scroll:ScrollNext(nDistance)
		else	
			this:GetRoot():Lookup("Scroll_List"):ScrollNext(nDistance)
		end
	end
	return 1
end

function HotkeyPanel.Tip(any, szMessage)
	any:GetRoot():Lookup("", "Text_Tip"):SetText(szMessage)
end

function HotkeyPanel.SetCurrentHotkey(handle, nKey, bShift, bCtrl, bAlt)
	local frame = handle:GetRoot()
	local bChange = false
	local bStop = false
	for k, v in ipairs(HotkeyPanel.aGroup) do
		for i, vKey in ipairs(v.key) do
			for j = 1, 2, 1 do
				local hotkey = vKey["Hotkey"..j]
				if hotkey.nKey == nKey and hotkey.bShift == bShift and hotkey.bCtrl == bCtrl and hotkey.bAlt == bAlt then
					if vKey.bUnchangeable then
						HotkeyPanel.Tip(handle, FormatString(g_tStrings.STR_HOTKEY_UNCHANGEDABLE, GetKeyShow(nKey, bShift, bCtrl, bAlt)))
						return
					else
						HotkeyPanel.Tip(handle, FormatString(g_tStrings.STR_HOTKEY_AUTO_CHANGED, v.name, vKey.szDesc))					
						hotkey.bConflict = true
						hotkey.bChange = false
						hotkey.nKey = 0
						hotkey.bCtrl = false
						hotkey.bAlt = false
						hotkey.bShift = false
						bChange = true
						if handle.nGroupIndex == k then
							local hK = handle:Lookup(i):Lookup("Handle_Key"..j)
							hK:Lookup("Text_Key"..j):SetText("")
							HotkeyPanel.UpdateBtnState(hK)
						end
					end
					bStop = true
					break
				end
			end
			if bStop then
				break
			end
		end
		if bStop then
			break
		end		
	end
	
	bStop = false
	local nCount = handle:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = handle:Lookup(i)
		if hI.bBinding then
			for i = 1, 2, 1 do
				local hK = hI:Lookup("Handle_Key"..i)
				if hK.bSel then
					hK.bSel = false
					local hotkey = HotkeyPanel.aGroup[handle.nGroupIndex]["key"][hI.nIndex]["Hotkey"..hK.nIndex]
					hotkey.bConflict = false
					hotkey.bChange = true
					hotkey.nKey = nKey
					hotkey.bAlt = bAlt
					hotkey.bCtrl = bCtrl
					hotkey.bShift = bShift
					hK:Lookup("Text_Key"..hK.nIndex):SetText(GetKeyShow(nKey, bShift, bCtrl, bAlt))
					HotkeyPanel.UpdateBtnState(hK)
					bChange = true
					bStop = true
					break
				end
			end
			if bStop then
				break
			end
		end
		if bStop then
			break
		end		
	end
	Hotkey.SetCapture(false)
	if bChange then
		HotkeyPanel.SetChanged(frame, true)
	end
end

function HotkeyPanel.CancelSetHotkey(handle)
	Hotkey.SetCapture(false)
	local nCount = handle:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = handle:Lookup(i)
		if hI.bBinding then
			local hK = hI:Lookup("Handle_Key1")
			if hK.bSel then
				hK.bSel = false
				HotkeyPanel.UpdateBtnState(hK)
				break
			end
			local hK = hI:Lookup("Handle_Key2")
			if hK.bSel then
				hK.bSel = false
				HotkeyPanel.UpdateBtnState(hK)
				break
			end
		end
	end	
end

--------------------------------插件重新实现方法:-----------------------------------
--1, HotkeyPanel = nil
--2, 重载下面函数
------------------------------------------------------------------------------------
function HotkeyPanel_SetHotkey(nKey, bShift, bCtrl, bAlt)
	local frame = Station.Lookup("Topmost/HotkeyPanel")
	if frame and frame:IsVisible() and nKey and nKey ~= 0 then
		HotkeyPanel.SetCurrentHotkey(frame:Lookup("", "Handle_Hotkey"), nKey, bShift, bCtrl, bAlt)
	end
end

function HotkeyPanel_CancelSetHotkey()
	local frame = Station.Lookup("Topmost/HotkeyPanel")
	if frame and frame:IsVisible() then
		HotkeyPanel.CancelSetHotkey(frame:Lookup("", "Handle_Hotkey"))
	end
end

function OpenHotkeyPanel(bDisableSound)
	if IsHotkeyPanelOpened() then
		return
	end
	Wnd.OpenWindow("HotkeyPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function CloseHotkeyPanel(bDisableSound)
	Hotkey.SetCapture(false)
	if not IsHotkeyPanelOpened() then
		return
	end
	
	FireDataAnalysisEvent("MEND_SHOTCUT", {HotkeyPanel.tInitKeys or {}})
	FireDataAnalysisEvent("FIRST_SET_SHOTCUT", {HotkeyPanel.tInitKeys or {}})
		
	Wnd.CloseWindow("HotkeyPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function IsHotkeyPanelOpened()
	local frame = Station.Lookup("Topmost/HotkeyPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

local function LoadHotkeySetting(event)
	Hotkey.LoadDefault()
	
	if not HotkeyPanel.bSaveToServer then
		local szFile = GetUserDataPath().."\\hotkey_add.txt"
		if IsFileExist(szFile) then
			Hotkey.LoadAsAdd(szFile)
		end
		return
	end
	
	if not GetUserPreferences(1500, "b") then
		local szFile = GetUserDataPath().."\\hotkey_add.txt"
		if IsFileExist(szFile) then
			Hotkey.LoadAsAdd(szFile)
		end
		HotkeyPanel.SaveToServer()
		return
	end
	
	local nCount = GetUserPreferences(1501, "c")
	if nCount > 0 then
		local t = {}
		for i = 1, nCount, 1 do
			local k = GetUserPreferences(1502 + (i - 1) * 8, "n")
			local v = GetUserPreferences(1502 + (i - 1) * 8 + 4, "n")
			table.insert(t, {k, v})
		end
		Hotkey.LoadFromLuaAsAdd(t)
	end
end

RegisterEvent("LOADING_END", LoadHotkeySetting)