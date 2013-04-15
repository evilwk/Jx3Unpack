KungFuPanel={}
KungFuPanel.aIDToActionBar = {}
	
function KungFuPanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("ON_UNDATE_KONGFU_ACTION_BAR_BINDING")
end

function KungFuPanel.Update(frame, aKf)
	local szIniFile = "UI/Config/Default/KungFuPanel.ini"
	local handle = frame:Lookup("", "")
	local hBg = handle:Lookup("Handle_Bg")
	local hKf = handle:Lookup("Handle_Kf")
	hKf:Clear()

	local nCount = #aKf
	local bUp = true
	if GetMainBarPanelAnchorEdge() == "TOP" then
		bUp = false
	end
	local wAll, hAll = 66, 10 + 56 * nCount + 2
	hKf:SetSize(wAll, hAll)
	hBg:Lookup("Image_Bg"):SetSize(wAll, hAll)
	
	for k, v in pairs(aKf) do
		local hI = hKf:AppendItemFromIni(szIniFile, "Handle_KfItem")
		
		local box = hI:Lookup("Box_Kf")
		box:SetObject(UI_OBJECT_SKILL, v[1], v[2])
		box:SetObjectIcon(Table_GetSkillIconID(v[1], v[2]))
		if bUp then
			hI:SetRelPos(4, 10 + 56 * (k - 1) + 2)
		else
			hI:SetRelPos(4, hAll - (56 * k + 8))		
		end
		
		local textKey = hI:Lookup("Text_Key")
		
		textKey:SetText(GetKungfuHotkey(v[1]))
		
		local textAction = hI:Lookup("Text_Action")
		local nPage = GetKungfuActionBarPage(v[1])
		if nPage then
			textAction:SetText(nPage)
		else
			textAction:SetText("")
		end
		
		local hPlayer = GetClientPlayer()
		if hPlayer and hPlayer.dwForceID > 0 then
			FireHelpEvent("OnCommentOneKungFu", box)
		end
	end
	hKf:FormatAllItemPos()
	
	hBg:SetSize(wAll, hAll)
	hBg:FormatAllItemPos()
	
	handle:SetSize(wAll, hAll)
	handle:FormatAllItemPos()
	
	frame:SetSize(wAll, hAll)
	
	local thisSave = this
	this = frame
	KungFuPanel.OnEvent("UI_SCALED")
	this = thisSave
end

function KungFuPanel.OnFrameKeyDown()
	local szKey = GetKeyName(Station.GetMessageKey())
	if szKey == "Esc" then
		Wnd.CloseWindow("KungFuPanel")
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
		return 1
	end
end

function KungFuPanel.OnEvent(event)
	if event == "UI_SCALED" then
		if GetMainBarPanelAnchorEdge() == "TOP" then
			this:SetPoint("TOPLEFT", 0, 0, GetMainBarPanelFrame(), "TOPLEFT", 74, 80)
		else
			this:SetPoint("BOTTOMLEFT", 0, 0, GetMainBarPanelFrame(), "BOTTOMLEFT", 74, -80)
		end
		
		this:CorrectPos()
	elseif event == "ON_UNDATE_KONGFU_ACTION_BAR_BINDING" then
		local handle = this:Lookup("", "Handle_Kf")
		local nCount = handle:GetItemCount() - 1
		for i = 0, nCount, 1 do
			local text = handle:Lookup(i):Lookup("Text_Action")
			local box = handle:Lookup(i):Lookup("Box_Kf")
			local _, dwID = box:GetObject()
			local nPage = GetKungfuActionBarPage(dwID)
			if nPage then
				text:SetText(nPage)
			else
				text:SetText("")
			end
		end
	end
end

function KungFuPanel.OnFrameBreathe() 
	if this ~= Station.GetActiveFrame() then
		Wnd.CloseWindow("KungFuPanel")
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	else
		local player = GetClientPlayer()
		if player then
			local handle = this:Lookup("", "Handle_Kf")
			local nCount = handle:GetItemCount() - 1
			for i = 0, nCount, 1 do
				UpdateKungfuCDProgress(player, handle:Lookup(i):Lookup("Box_Kf"))
			end
		end
	end
end

function KungFuPanel.OnItemLButtonDown()
	if this:GetType() == "Box" then
		this:SetObjectPressed(1)
	end
end

function KungFuPanel.OnItemLButtonUp()
	if this:GetType() == "Box" then
		this:SetObjectPressed(0)
	end
end

function KungFuPanel.OnItemLButtonClick()
    local szName = this:GetName()
    if szName == "Handle_A1" then
        this:Lookup("Image_C1"):Show()
        local hP = this:GetParent()
        hP:Lookup("Handle_A2/Image_C2"):Hide()
        hP:Lookup("Handle_A3/Image_C3"):Hide()
        hP:Lookup("Handle_A4/Image_C4"):Hide()
        hP:Lookup("Handle_AN/Image_CN"):Hide()
        KungFuPanel.UpdateKfBind(hP.dwID, 1)
        hP:Hide()
    elseif szName == "Handle_A2" then
        this:Lookup("Image_C2"):Show()
        local hP = this:GetParent()
        hP:Lookup("Handle_A1/Image_C1"):Hide()
        hP:Lookup("Handle_A3/Image_C3"):Hide()
        hP:Lookup("Handle_A4/Image_C4"):Hide()
        hP:Lookup("Handle_AN/Image_CN"):Hide()
        KungFuPanel.UpdateKfBind(hP.dwID, 2)
        hP:Hide()
    elseif szName == "Handle_A3" then
        this:Lookup("Image_C3"):Show()
        local hP = this:GetParent()
        hP:Lookup("Handle_A1/Image_C1"):Hide()
        hP:Lookup("Handle_A2/Image_C2"):Hide()
        hP:Lookup("Handle_A4/Image_C4"):Hide()
        hP:Lookup("Handle_AN/Image_CN"):Hide()
        KungFuPanel.UpdateKfBind(hP.dwID, 3)
        hP:Hide()
    elseif szName == "Handle_A4" then
        this:Lookup("Image_C4"):Show()
        local hP = this:GetParent()
        hP:Lookup("Handle_A1/Image_C1"):Hide()
        hP:Lookup("Handle_A2/Image_C2"):Hide()
        hP:Lookup("Handle_A3/Image_C3"):Hide()
        hP:Lookup("Handle_AN/Image_CN"):Hide()
        KungFuPanel.UpdateKfBind(hP.dwID, 4)
        hP:Hide()
    elseif szName == "Handle_AN" then
        this:Lookup("Image_CN"):Show()
        local hP = this:GetParent()
        hP:Lookup("Handle_A1/Image_C1"):Hide()
        hP:Lookup("Handle_A2/Image_C2"):Hide()
        hP:Lookup("Handle_A3/Image_C3"):Hide()
        hP:Lookup("Handle_A4/Image_C4"):Hide()
        KungFuPanel.UpdateKfBind(hP.dwID, 0)
        hP:Hide()
    elseif szName == "Image_ActionBar" then
        KungFuPanel.ShowBindPanel(this:GetParent():Lookup("Box_Kf"))
    elseif this:GetType() == "Box" then
        this:SetObjectMouseOver(1)
        local dwSkillID, dwSkillLevel = this:GetObjectData()
        local player = GetClientPlayer()
        local Kungfu = player.GetKungfuMount()
        if not Kungfu or Kungfu.dwSkillID ~= dwSkillID  then
            OpenKFActionBarPanel(dwSkillID, dwSkillLevel)
            player.MountKungfu(dwSkillID, dwSkillLevel, true)
        end

        Wnd.CloseWindow("KungFuPanel")
        PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
    end
end

function KungFuPanel.OnItemLButtonDBClick()
	KungFuPanel.OnItemLButtonClick()
end

function KungFuPanel.OnItemRButtonClick()
	local szName = this:GetName()
	if szName == "Image_ActionBar" then
		KungFuPanel.ShowBindPanel(this:GetParent():Lookup("Box_Kf"))
	elseif this:GetType() == "Box" then
		KungFuPanel.ShowBindPanel(this)
	end
end

function KungFuPanel.OnItemRButtonDBClick()
	KungFuPanel.OnItemRButtonClick()
end

function KungFuPanel.OnItemMouseEnter()
	local szName = this:GetName()
	if szName == "Handle_A1" then
		this:Lookup("Image_Over1"):Show()
	elseif szName == "Handle_A2" then
		this:Lookup("Image_Over2"):Show()
	elseif szName == "Handle_A3" then
		this:Lookup("Image_Over3"):Show()
	elseif szName == "Handle_A4" then
		this:Lookup("Image_Over4"):Show()
	elseif szName == "Handle_AN" then
		this:Lookup("Image_OverN"):Show()
	elseif szName == "Image_ActionBar" then
		this:SetFrame(9)
	elseif this:GetType() == "Box" then
		this:SetObjectMouseOver(1)
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		local dwSkilID, dwSkillLevel = this:GetObjectData()
		OutputSkillTip(dwSkilID, dwSkillLevel, {x, y, w, h, 1})	
	end	
end

function KungFuPanel.OnItemRefreshTip()
	return KungFuPanel.OnItemMouseEnter()
end

function KungFuPanel.OnItemMouseLeave()
	local szName = this:GetName()
	if szName == "Handle_A1" then
		this:Lookup("Image_Over1"):Hide()
	elseif szName == "Handle_A2" then
		this:Lookup("Image_Over2"):Hide()
	elseif szName == "Handle_A3" then
		this:Lookup("Image_Over3"):Hide()
	elseif szName == "Handle_A4" then
		this:Lookup("Image_Over4"):Hide()
	elseif szName == "Handle_AN" then
		this:Lookup("Image_OverN"):Hide()
	elseif szName == "Image_ActionBar" then
		this:SetFrame(10)
	elseif this:GetType() == "Box" then
		this:SetObjectMouseOver(0)
		HideTip()
	end
end

function KungFuPanel.ShowBindPanel(box)
	local handle = box:GetRoot():Lookup("", "Handle_Bind")
	handle.dwID = box:GetObjectData()
	
	local img = box:GetParent():Lookup("Image_ActionBar")
	
	local nActionBind = KungFuPanel.GetActionBind(handle.dwID)
	handle:Lookup("Handle_A1/Image_C1"):Hide()
	handle:Lookup("Handle_A2/Image_C2"):Hide()
	handle:Lookup("Handle_A3/Image_C3"):Hide()
	handle:Lookup("Handle_A4/Image_C4"):Hide()
	handle:Lookup("Handle_AN/Image_CN"):Hide()
	if nActionBind == 1 then
		handle:Lookup("Handle_A1/Image_C1"):Show()
	elseif nActionBind == 2 then
		handle:Lookup("Handle_A2/Image_C2"):Show()
	elseif nActionBind == 3 then
		handle:Lookup("Handle_A3/Image_C3"):Show()
	elseif nActionBind == 4 then
		handle:Lookup("Handle_A4/Image_C4"):Show()
	elseif nActionBind == 0 then
		handle:Lookup("Handle_AN/Image_CN"):Show()
	end
	handle:Show()
	local wA, hA = handle:GetSize()
	local x, y = img:GetAbsPos()
	local w, h = img:GetSize()
	handle:SetAbsPos(x + w, y + h - hA)
	local xB, yB = box:GetParent():GetAbsPos()
	handle:SetRelPos(x + w - xB, y + h - hA - yB)
end

function KungFuPanel.UpdateKfBind(dwID, nValue)
	KungFuPanel.aIDToActionBar[dwID] = nValue
	KungFuPanel_Save()
	FireEvent("ON_UNDATE_KONGFU_ACTION_BAR_BINDING")
end

function KungFuPanel.GetActionBind(dwID)
	if KungFuPanel.aIDToActionBar[dwID] then
		return KungFuPanel.aIDToActionBar[dwID]
	end
	return 0
end

function OpenOrCloseKungfuList(bDisbleSound)
	if Station.Lookup("Topmost/KungFuPanel") then
		Wnd.CloseWindow("KungFuPanel")
		if not bDisbleSound then
			PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
		end
		return
	end
	local aKf = {}
	local player = GetClientPlayer()
	local aSchool = player.GetSchoolList()
	for k, v in pairs(aSchool) do
		local aKungfu = player.GetKungfuList(v)
		for dwID, dwLevel in pairs(aKungfu) do
			if Table_IsSkillShow(dwID, dwLevel) then
				local skill = GetSkill(dwID, dwLevel)
				if skill and skill.nUIType == 2 then
					table.insert(aKf, {dwID, dwLevel})
				end
			end
		end
	end
	
	if #aKf == 0 then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_NO_KF_LEARNED)
		return
	end
		
	local frame = Wnd.OpenWindow("KungFuPanel")
	if frame then
		KungFuPanel.Update(frame, aKf)
		Station.SetActiveFrame(frame)
		if not bDisbleSound then
			PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
		end
	end
end

function GetKungfuActionBarPage(dwID)
	local nPage = KungFuPanel.GetActionBind(dwID)
	if nPage ~= 0 then
		return nPage
	end
	return nil
end

function KungFuPanel_Save()
	local nCount = 0
	local nPos = 960
	for k, v in pairs(KungFuPanel.aIDToActionBar) do
		nCount = nCount + 1
	end	
	SetUserPreferences(nPos, "c", nCount)
	nPos = nPos + 1
	for k, v in pairs(KungFuPanel.aIDToActionBar) do
		SetUserPreferences(nPos, "dc", k, v)
		nPos = nPos + 5
	end
end

function KungFuPanel_OnLoadSave()
	local nPos = 960
	local nCount = GetUserPreferences(nPos, "c")
	nPos = nPos + 1
	KungFuPanel.aIDToActionBar = {}
	for i = 1, nCount, 1 do
		local dwID = GetUserPreferences(nPos, "d")
		nPos = nPos + 4
		local nPage = GetUserPreferences(nPos, "c")
		nPos = nPos + 1
		KungFuPanel.aIDToActionBar[dwID] = nPage
	end	
end

function GetKungfuHotkey(dwID)
	local a = 
	{
		[10003] = "KUNG_FU_YIJIN",
		[10002] = "KUNG_FU_XISUI",
		[10015] = "KUNG_FU_TAIXU",
		[10014] = "KUNG_FU_ZIXIA",
		[10021] = "KUNG_FU_HUAJIAN",
		[10028] = "KUNG_FU_LIJING",
		[10026] = "KUNG_FU_AOXUE",
		[10062] = "KUNG_FU_TIELAO",
		[10081] = "KUNG_FU_BINGXIN",
		[10080] = "KUNG_FU_YUNSHANG",
	}
	
	if not a[dwID] then
		return ""
	end
	
	local nKey, bShift, bCtrl, bAlt = Hotkey.Get(a[dwID])
	return GetKeyShow(nKey, bShift, bCtrl, bAlt, true)
end

RegisterEvent("LOADING_END", KungFuPanel_OnLoadSave)
