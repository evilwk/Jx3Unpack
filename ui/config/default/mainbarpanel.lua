MainBarPanel = 
{
	bShowValue = true,
	DefaultAnchor = {s = "BOTTOMCENTER", r = "BOTTOMCENTER",  x = 0, y = 0},
	Anchor = {s = "BOTTOMCENTER", r = "BOTTOMCENTER", x = 0, y = 0},
	DefaultAnchorEdge = "BOTTOM",
	AnchorEdge = "BOTTOM"
}

RegisterCustomData("MainBarPanel.bShowValue")
RegisterCustomData("MainBarPanel.AnchorEdge")
RegisterCustomData("MainBarPanel.Anchor")

function MainBarPanel.OnFrameCreate()
	local player = GetClientPlayer()
	
	this:RegisterEvent("SKILL_MOUNT_KUNG_FU")
	this:RegisterEvent("SKILL_UNMOUNT_KUNG_FU")
	this:RegisterEvent("SKILL_UPDATE")
	this:RegisterEvent("ON_ACTIONBAR_LOCK")
	this:RegisterEvent("ON_OPEN_ACTIONBAR")
	this:RegisterEvent("ON_CLOSE_ACTIONBAR")
	this:RegisterEvent("ON_SELECT_MAIN_ACTIONBAR_PAGE")
	this:RegisterEvent("SYNC_ROLE_DATA_END")
	this:RegisterEvent("PLAYER_EXPERIENCE_UPDATE")
	this:RegisterEvent("ON_SET_SHOW_EXP_VALUE")
	this:RegisterEvent("SET_SHOW_VALUE_BY_PERCENTAGE")
	
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("MAINBAR_PANEL_ANCHOR_CHANGED")
	this:RegisterEvent("MAINBAR_PANEL_ANCHOR_EDGE_CHANGED")
	
	this:RegisterEvent("CUSTOM_DATA_LOADED")
	this:RegisterEvent("HELP_SPARK_EVENT_OPEN_BAG")
    this:RegisterEvent("PLAYER_LEVEL_UPDATE")
	
	local c = this:Lookup("CheckBox_UpDown")
	c.bDisable = true
	c:Check(IsActionBarOpened(2))
	c.bDisable = false

	local c = this:Lookup("CheckBox_Lock")
	c.bDisable = true
	c:Check(IsActionBarLocked())
	c.bDisable = false
	
	this:Lookup("", "Text_Page"):SetText(GetMainActionBarPage())
	
	MainBarPanel.UpdatePingState(this)
	MainBarPanel.UpdateStaminaAndThew(this)
	MainBarPanel.UpdateExp(this)
	MainBarPanel.UpdateKungfu(this)
	
	MainBarPanel.UpdateAnchorEdge(this)
	MainBarPanel.UpdateAnchor(this)
	UpdateCustomModeWindow(this, g_tStrings.ACTIONBAR_MAIN, nil, nil, true)	
end

function MainBarPanel.UpdateAnchorEdge(frame)
	local btnBag = frame:Lookup("Btn_Bag")
	local cLock = frame:Lookup("CheckBox_Lock")
	local cUpDown = frame:Lookup("CheckBox_UpDown")
	local btnUp = frame:Lookup("Btn_PageUp")
	local btnDown = frame:Lookup("Btn_PageDown")
	local handle = frame:Lookup("", "")
	
	local szPath = "ui/Image/Minimap/Minimap.UITex"
	if MainBarPanel.AnchorEdge == "TOP" then
		btnBag:SetRelPos(970, 24)
		cLock:SetRelPos(112, 16)
		cUpDown:SetRelPos(130, 56)
		cUpDown:SetAnimation(szPath, 92, 88, 87, 91, 88, 92, 89, 93, 91, 87)		
		btnUp:SetRelPos(952, 32)
		btnDown:SetRelPos(952, 58)
		handle:SetRelPos(0, 0)
		local x, y = frame:GetAbsPos()
		handle:SetAbsPos(x, y)		
		for i = 0, 19, 1 do
			local img = handle:Lookup(i)
			img:SetImageType(IMAGE.FLIP_VERTICAL)
			img:SetPosType(ITEM_POSITION.RIGHT_TOP)
		end
		handle:Lookup("Image_ServerRed"):SetRelPos(913, 13)
		handle:Lookup("Image_ServerYellow"):SetRelPos(913, 13)
		handle:Lookup("Image_ServerGreen"):SetRelPos(913, 13)
		handle:Lookup("Image_TP"):SetRelPos(114, 13)
		handle:Lookup("Image_Cut"):SetRelPos(225, 11)
		handle:Lookup("Image_SP"):SetRelPos(231, 13)
		handle:Lookup("Image_Cut2"):SetRelPos(348, 11)
		handle:Lookup("Animate_KfAni"):SetRelPos(68, 17)
		handle:Lookup("Box_Kungfu"):SetRelPos(74, 24)
		handle:Lookup("Text_Kungfu"):SetRelPos(74, 24)
		handle:Lookup("Image_CD"):SetRelPos(71, 20)
		handle:Lookup("Image_KFBright"):SetRelPos(73, 17)
		handle:Lookup("Image_ExpBar"):SetRelPos(353, 13)
		handle:Lookup("Text_TP"):SetRelPos(106, 3)
		handle:Lookup("Text_SP"):SetRelPos(229, 3)
		handle:Lookup("Text_ExpBar"):SetRelPos(352, 3)
		handle:Lookup("Text_Page"):SetRelPos(958, 48)
		frame:SetAreaTestFile("ui/Image/UICommon/MainAreaTop.area")
	else
		btnBag:SetRelPos(970, 48)
		cLock:SetRelPos(112, 88)
		cUpDown:SetRelPos(130, 60)
		cUpDown:SetAnimation(szPath, 88, 92, 91, 87, 92, 88, 93, 89, 87, 91)
		btnUp:SetRelPos(952, 58)
		btnDown:SetRelPos(952, 80)
		handle:SetRelPos(0, 52)
		local x, y = frame:GetAbsPos()
		handle:SetAbsPos(x, y + 52)
		for i = 0, 19, 1 do
			local img = handle:Lookup(i)
			img:SetImageType(IMAGE.NORMAL)
			img:SetPosType(ITEM_POSITION.RIGHT_BOTTOM)
		end
		handle:Lookup("Image_ServerRed"):SetRelPos(913, 62)
		handle:Lookup("Image_ServerYellow"):SetRelPos(913, 62)
		handle:Lookup("Image_ServerGreen"):SetRelPos(913, 62)
		handle:Lookup("Image_TP"):SetRelPos(114, 62)
		handle:Lookup("Image_Cut"):SetRelPos(225, 58)
		handle:Lookup("Image_SP"):SetRelPos(231, 62)
		handle:Lookup("Image_Cut2"):SetRelPos(348, 58)
		handle:Lookup("Animate_KfAni"):SetRelPos(68, 4)
		handle:Lookup("Box_Kungfu"):SetRelPos(74, 9)
		handle:Lookup("Text_Kungfu"):SetRelPos(74, 9)
		handle:Lookup("Image_CD"):SetRelPos(71, 7)
		handle:Lookup("Image_KFBright"):SetRelPos(73, 6)
		handle:Lookup("Image_ExpBar"):SetRelPos(353, 62)
		handle:Lookup("Text_TP"):SetRelPos(110, 55)
		handle:Lookup("Text_SP"):SetRelPos(230, 55)
		handle:Lookup("Text_ExpBar"):SetRelPos(353, 55)
		handle:Lookup("Text_Page"):SetRelPos(958, 20)
		frame:SetAreaTestFile("ui/Image/UICommon/MainAreaBottom.area")
	end
	handle:FormatAllItemPos()
end

function MainBarPanel.OnFrameDrag()
end

function MainBarPanel.OnFrameDragSetPosEnd()
	MainBarPanel.AnchorEdge = GetFrameAnchorEdge(this, "VERTICAL")
	FireEvent("MAINBAR_PANEL_ANCHOR_EDGE_CHANGED")
	FireEvent("MAINBAR_PANEL_POS_CHANGED")
end

function MainBarPanel.OnFrameDragEnd()
	this:CorrectPos()
	MainBarPanel.AnchorEdge = GetFrameAnchorEdge(this, "VERTICAL")
	FireEvent("MAINBAR_PANEL_ANCHOR_EDGE_CHANGED")
	MainBarPanel.Anchor = GetFrameAnchor(this)
	FireEvent("MAINBAR_PANEL_POS_CHANGED")
end

function MainBarPanel.UpdateAnchor(frame)
	frame:SetPoint(MainBarPanel.Anchor.s, 0, 0, MainBarPanel.Anchor.r, MainBarPanel.Anchor.x, MainBarPanel.Anchor.y)
	frame:CorrectPos()
	MainBarPanel.AnchorEdge = GetFrameAnchorEdge(this, "VERTICAL")
	FireEvent("MAINBAR_PANEL_ANCHOR_EDGE_CHANGED")
	FireEvent("MAINBAR_PANEL_POS_CHANGED")
end

function MainBarPanel.OnFrameBreathe()
	local player = GetClientPlayer()
	if player then
		local handle = this:Lookup("", "")
		local box = handle:Lookup("Box_Kungfu")
		local img = handle:Lookup("Image_CD")
		if box:IsEmpty() then
			img:Hide()
		else
			local dwID, dwLevel = box:GetObjectData()
		    local bCool, nLeft, nTotal = player.GetSkillCDProgress(dwID, dwLevel)
		    if bCool then
		        if nLeft == 0 and nTotal == 0 then
		            img:Hide()
		        else
		        	img:Show()
		            img:SetPercentage(1 - nLeft / nTotal)
		        end
		    else
		        img:Hide()
		    end	
		end
	end
	
	if not this.nPingValue then
		this.nPingValue = 100
	end
	local nThisValue = GetPingValue()
	this.nPingValue = this.nPingValue * 0.7 + nThisValue * 0.3
	this.nPingTime = math.floor(this.nPingValue / 2)
	MainBarPanel.UpdatePingState(this)
end

function MainBarPanel.UpdateKungfu(frame)
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local ani = frame:Lookup("", "Animate_KfAni")
	local text = frame:Lookup("", "Text_Kungfu")
	local skill = player.GetKungfuMount()
	if skill then
		local box = frame:Lookup("", "Box_Kungfu")
		box:SetObject(UI_OBJECT_SKILL, skill.dwSkillID, skill.dwLevel)
		box:SetObjectIcon(Table_GetSkillIconID(skill.dwSkillID, skill.dwLevel))
		local nPage = GetKungfuActionBarPage(skill.dwSkillID)
		if nPage then
			SelectMainActionBarPage(nPage)
		end
		ani:SetAlpha(150)
		text:Hide()
	else
		local box = frame:Lookup("", "Box_Kungfu")
		box:ClearObject()
		ani:SetAlpha(255)
		text:Show()
	end
end

function MainBarPanel.OnEvent(event)
	if event == "SKILL_MOUNT_KUNG_FU" then
		MainBarPanel.UpdateKungfu(this)
	elseif event == "SKILL_UNMOUNT_KUNG_FU" then
		MainBarPanel.UpdateKungfu(this)
	elseif event == "SKILL_UPDATE" then
		local box = this:Lookup("", "Box_Kungfu")
		if not box:IsEmpty() then
			local dwSkilID, dwSkillLevel = box:GetObjectData()
			if dwSkilID == arg0 then
				box:SetObject(UI_OBJECT_SKILL, arg0, arg1)
				box:SetObjectIcon(Table_GetSkillIconID(arg0, arg1))
			end
		end
		
		if arg1 == 1 then	
			local hSkill = GetSkill(arg0, arg1)
			local hPlayer = GetClientPlayer()
			if hPlayer and hPlayer.dwForceID > 0 and hSkill and hSkill.nUIType == 2 and hSkill.dwBelongKungfu == 0 then
				FireHelpEvent("OnCommentKungFu", box)
			end
		end
		
	elseif event == "PLAYER_EXPERIENCE_UPDATE" then
		if arg0 == GetClientPlayer().dwID then
			MainBarPanel.UpdateStaminaAndThew(this)
			MainBarPanel.UpdateExp(this)
		end
	elseif event == "ON_ACTIONBAR_LOCK" then
		local c = this:Lookup("CheckBox_Lock")
		c.bDisable = true
		c:Check(IsActionBarLocked())
		c.bDisable = false
	elseif event == "ON_OPEN_ACTIONBAR" then
		if arg0 == 2 then
			local c = this:Lookup("CheckBox_UpDown")
			c.bDisable = true
			c:Check(true)
			c.bDisable = false
		end
	elseif event == "ON_CLOSE_ACTIONBAR" then
		if arg0 == 2 then
			local c = this:Lookup("CheckBox_UpDown")
			c.bDisable = true
			c:Check(false)
			c.bDisable = false
		end
	elseif event == "ON_SELECT_MAIN_ACTIONBAR_PAGE" then
		this:Lookup("", "Text_Page"):SetText(GetMainActionBarPage())
	elseif event == "SYNC_ROLE_DATA_END" then
		MainBarPanel.UpdateKungfu(this)
		MainBarPanel.UpdateStaminaAndThew(this)
		MainBarPanel.UpdateExp(this)
	elseif event == "ON_SET_SHOW_EXP_VALUE" then
		MainBarPanel.UpdateStaminaAndThew(this)
		MainBarPanel.UpdateExp(this)
	elseif event == "SET_SHOW_VALUE_BY_PERCENTAGE" then
		MainBarPanel.UpdateStaminaAndThew(this)
		MainBarPanel.UpdateExp(this)
	elseif event == "UI_SCALED" then
		MainBarPanel.UpdateAnchor(this)
	elseif event == "ON_ENTER_CUSTOM_UI_MODE" or event == "ON_LEAVE_CUSTOM_UI_MODE" then
		UpdateCustomModeWindow(this, nil, nil, nil, true)
	elseif event == "MAINBAR_PANEL_ANCHOR_CHANGED" then
		MainBarPanel.UpdateAnchor(this)
	elseif event == "MAINBAR_PANEL_ANCHOR_EDGE_CHANGED" then
		MainBarPanel.UpdateAnchorEdge(this)
	elseif event == "CUSTOM_DATA_LOADED" then
		MainBarPanel.UpdateStaminaAndThew(this)
		MainBarPanel.UpdateExp(this)
		MainBarPanel.UpdateAnchor(this)
		MainBarPanel.UpdateAnchorEdge(this)
	elseif event == "HELP_SPARK_EVENT_OPEN_BAG" then
		local hBtn = this:Lookup("Btn_Bag")
		FireHelpEvent("OnCommentToOpenBag", hBtn)
    elseif event == "PLAYER_LEVEL_UPDATE" then
        local hPlayer = GetClientPlayer()
        if hPlayer and arg0 == hPlayer.dwID then
            if hPlayer.nLevel == 10 then
                local hCheckUpDown = this:Lookup("CheckBox_UpDown")
                if not hCheckUpDown:IsCheckBoxChecked() then
                    hCheckUpDown:Check(true)
                end
            end
        end
	end
end

function MainBarPanel.UpdateStaminaAndThew(frame)
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local textT = frame:Lookup("", "Text_TP")
	local textS = frame:Lookup("", "Text_SP")
	local imageT = frame:Lookup("", "Image_TP")
	local imageS = frame:Lookup("", "Image_SP")

	if not IsExpShowStateValue() then
		textT:SetText("")
		textS:SetText("")
	elseif IsShowStateValueByPercentage() then
		textT:SetText(string.format("%d", 100 * player.nCurrentThew / player.nMaxThew).."%")
		textS:SetText(string.format("%d", 100 * player.nCurrentStamina / player.nMaxStamina).."%")
	else
		textT:SetText(player.nCurrentThew.."/"..player.nMaxThew)
		textS:SetText(player.nCurrentStamina.."/"..player.nMaxStamina)
	end
	
	imageT:SetPercentage(player.nCurrentThew / player.nMaxThew)
	imageS:SetPercentage(player.nCurrentStamina / player.nMaxStamina)	
end

function MainBarPanel.UpdateExp(frame)
    if MainBarPanel.ExpText and MainBarPanel.ExpText ~= "Exp" then
        return
    end
    
	local player = GetClientPlayer()
	if not player then
		return
	end

	local text = frame:Lookup("", "Text_ExpBar")
	local img = frame:Lookup("", "Image_ExpBar")
	local levelUp = GetLevelUpData(player.nRoleType, player.nLevel)
	local nMaxExp = levelUp['Experience']
    MainBarPanel_UpdateExpBar(player.nExperience, nMaxExp, "Exp", nil, frame)
end

function MainBarPanel.OnItemMouseEnter()
	local szName = this:GetName()
	local x, y = this:GetAbsPos()
	local w, h = this:GetSize()
	if szName == "Box_Kungfu" then
		if this:IsEmpty() then
			local player = GetClientPlayer()
			local szTip = "<text>text="..EncodeComponentsString(g_tStrings.STR_SKILL_NG).." font=65 </text><text>text="
				..EncodeComponentsString(g_tStrings.MAIN_CHOOSE_NG_TIP).." font=106 </text>"
			OutputTip(szTip, 400, {x, y, w, h, 1})
		else
			local dwSkilID, dwSkillLevel = this:GetObjectData()
			OutputSkillTip(dwSkilID, dwSkillLevel, {x, y, w, h, 1}, false)		
		end
	elseif szName == "Image_ServerRed" or szName == "Image_ServerYellow" or szName == "Image_ServerGreen" then
		local szTip = ""
		local nFont = 105
		local szUserRegion , szUserSever = GetUserServer()
		local frame = this:GetRoot()
		if frame.nPingTime <= 300 then
			nFont = 105
		elseif frame.nPingTime <= 800 then
			nFont = 101
		else
			nFont = 102
		end
		local nFFont = 105
		local fps = GetFPS()
		if fps >= 40 then
			nFFont = 105
		elseif fps >= 20 then
			nFFont = 101
		else
			nFFont = 102
		end
		szTip = "<text>text="..EncodeComponentsString(g_tStrings.TIP_CURRENT_SEVER).."font=165</text>"
			.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MSG_BRACKET, szUserRegion, szUserSever).. "\n").."font=163</text>"
			.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MAIN_SERVER_DELAY, frame.nPingTime)).."font="..nFont.."</text>"
			.."<text>text="..EncodeComponentsString(g_tStrings.MAIN_TIP1).."font=100</text>"
			.."<text>text="..EncodeComponentsString(FormatString(g_tStrings.MAIN_SERVER_FPS, fps)).."font="..nFFont.."</text>"
			.."<text>text="..EncodeComponentsString(g_tStrings.MAIN_TIP2).."font=100</text>"
		OutputTip(szTip, 400, {x, y, w, h, 1})
	elseif szName == "Text_TP" then
		local player = GetClientPlayer()
		if not IsExpShowStateValue() then
			if IsShowStateValueByPercentage() then
				this:SetText(string.format("%d", 100 * player.nCurrentThew / player.nMaxThew).."%")
			else
				this:SetText(player.nCurrentThew.."/"..player.nMaxThew)
			end
		end
		local szTip = "<text>text="..EncodeComponentsString(FormatString(g_tStrings.CURRENT_THEW, player.nCurrentThew.."/"..player.nMaxThew)).." font=65 </text><text>text="
			..EncodeComponentsString(g_tStrings.MAIN_TIP3).." font=106 </text>"
		OutputTip(szTip, 400, {x, y, w, h, 1})
	elseif szName == "Text_SP" then
		local player = GetClientPlayer()
		if not IsExpShowStateValue() then
			if IsShowStateValueByPercentage() then
				this:SetText(string.format("%d", 100 * player.nCurrentStamina / player.nMaxStamina).."%")
			else
				this:SetText(player.nCurrentStamina.."/"..player.nMaxStamina)
			end
		end
		local szTip = "<text>text="..EncodeComponentsString(FormatString(g_tStrings.CURRENT_STAMINA, player.nCurrentStamina.."/"..player.nMaxStamina)).." font=65 </text><text>text="
			..EncodeComponentsString(g_tStrings.MAIN_TIP4).." font=106 </text>"
		OutputTip(szTip, 400, {x, y, w, h, 1})
	elseif szName == "Text_ExpBar" then
        local szTip = ""
        if MainBarPanel.ExpText == "Exp" then
            local player = GetClientPlayer()
            local levelUp = GetLevelUpData(player.nRoleType, player.nLevel)
            local nMaxExp = levelUp['Experience']
            if not IsExpShowStateValue() then
                if IsShowStateValueByPercentage() then
                    this:SetText(string.format("%d", 100 * player.nExperience / nMaxExp).."%")
                else
                    this:SetText(player.nExperience.."/"..nMaxExp)
                end
            end
            szTip = "<text>text="..EncodeComponentsString(FormatString(g_tStrings.CURRENT_EXP, player.nExperience.."/"..nMaxExp)).." font=65 </text><text>text="
                ..EncodeComponentsString(g_tStrings.MAIN_TIP5).." font=106 </text>"
        elseif MainBarPanel.fnGetTip then
            szTip = MainBarPanel.fnGetTip()
        end
		OutputTip(szTip, 400, {x, y, w, h, 1})
	end
	
end

function MainBarPanel.UpdatePingState(frame)
	if not frame.nPingTime then
		frame.nPingTime = math.floor(GetPingValue() / 2)
	end
	local handle = frame:Lookup("", "")
	if frame.nPingTime < 300 then
		handle:Lookup("Image_ServerRed"):Hide()
		handle:Lookup("Image_ServerYellow"):Hide()
		handle:Lookup("Image_ServerGreen"):Show()
	elseif frame.nPingTime < 800 then
		handle:Lookup("Image_ServerRed"):Hide()
		handle:Lookup("Image_ServerYellow"):Show()
		handle:Lookup("Image_ServerGreen"):Hide()
	else
		handle:Lookup("Image_ServerRed"):Show()
		handle:Lookup("Image_ServerYellow"):Hide()
		handle:Lookup("Image_ServerGreen"):Hide()
	end
end

function MainBarPanel.OnItemMouseLeave()
	local szName = this:GetName()
	if szName == "Box_Kungfu" then
		HideTip()
	elseif szName == "Text_TP" then
		if not IsExpShowStateValue() then
			this:SetText("")
		end
		HideTip()
	elseif szName == "Text_SP" then
		if not IsExpShowStateValue() then
			this:SetText("")
		end
		HideTip()
	elseif szName == "Text_ExpBar" then
		if not IsExpShowStateValue() then
			this:SetText("")
		end
		HideTip()
	elseif szName == "Image_ServerRed" or szName == "Image_ServerYellow" or szName == "Image_ServerGreen" then
		HideTip()
	end
end

function MainBarPanel.OnItemLButtonDown()
	if this:GetName() == "Box_Kungfu" then
		OpenOrCloseKungfuList()
	end
end

function MainBarPanel.OnItemLButtonUp()
end

function MainBarPanel.OnItemLButtonClick()
end

function MainBarPanel.OnItemLButtonDBClick()
	if this:GetName() == "Box_Kungfu" then
		OpenOrCloseKungfuList()
	end
end

function MainBarPanel.OnItemRButtonDown()
	if this:GetName() == "Box_Kungfu" then
		OpenOrCloseKungfuList()
	end
end

function MainBarPanel.OnItemRButtonUp()
end

function MainBarPanel.OnItemRButtonClick()
end

function MainBarPanel.OnItemRButtonDBClick()
	if this:GetName() == "Box_Kungfu" then
		OpenOrCloseKungfuList()
	end
end

function MainBarPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_MainBarPanel" then
		if IsAllMainBarPanelPanelOpened() then
			CloseAllMainBarPanelPanel()
		else
			OpenAllMainBarPanelPanel()
		end
	elseif szName == "Btn_PageUp" then
		SelectMainActionBarPage(GetMainActionBarPage() - 1)
		PlaySound(SOUND.UI_SOUND,g_sound.Button)
	elseif szName == "Btn_PageDown" then
		SelectMainActionBarPage(GetMainActionBarPage() + 1)
		PlaySound(SOUND.UI_SOUND,g_sound.Button)
	elseif szName == "Btn_Bag" then
		if IsAllBagPanelOpened() then
			CloseAllBagPanel()
		else
			OpenAllBagPanel()
		end
	end
end

function MainBarPanel.OnCheckBoxCheck()
	if this.bDisable then
		return
	end
	PlaySound(SOUND.UI_SOUND,g_sound.Button)
	local szName = this:GetName()
	if szName == "CheckBox_Lock" then
		LockActionBar(true)
	elseif szName == "CheckBox_UpDown" then
		OpenActionBar(2)
	end
end

function MainBarPanel.OnCheckBoxUncheck()
	if this.bDisable then
		return
	end
	PlaySound(SOUND.UI_SOUND,g_sound.Button)
	local szName = this:GetName()
	if szName == "CheckBox_Lock" then
		LockActionBar(false)
	elseif szName == "CheckBox_UpDown" then
		CloseActionBar(2)
	end
end

function GetMainBarPanelFrame()
	return Station.Lookup("Lowest1/MainBarPanel")
end

function SetExpShowStateValue(bShow)
	if MainBarPanel.bShowValue == bShow then
		return
	end
	
	MainBarPanel.bShowValue = bShow
	FireEvent("ON_SET_SHOW_EXP_VALUE")
end

function IsExpShowStateValue()
	return MainBarPanel.bShowValue
end

function GetMainBarPanelAnchorEdge()
	return MainBarPanel.AnchorEdge
end

function MainBarPanel_SetAnchorDefault()
	MainBarPanel.Anchor.s = MainBarPanel.DefaultAnchor.s
	MainBarPanel.Anchor.r = MainBarPanel.DefaultAnchor.r
	MainBarPanel.Anchor.x = MainBarPanel.DefaultAnchor.x
	MainBarPanel.Anchor.y = MainBarPanel.DefaultAnchor.y
	FireEvent("MAINBAR_PANEL_ANCHOR_CHANGED")
	
	MainBarPanel.AnchorEdge = MainBarPanel.DefaultAnchorEdge
	FireEvent("MAINBAR_PANEL_ANCHOR_EDGE_CHANGED")	
	
end

function MainBarPanel_UpdateExpBar(nValue1, nValue2, szExpText, fnGetTip, frame)
    if not frame then
        frame = Station.Lookup("Lowest1/MainBarPanel")
    end
    
    if not szExpText then
        MainBarPanel.ExpText = nil
        MainBarPanel.UpdateExp(frame)
        return
    end
    
    MainBarPanel.ExpText = szExpText
    MainBarPanel.fnGetTip = fnGetTip
    
    local text = frame:Lookup("", "Text_ExpBar")
	local img = frame:Lookup("", "Image_ExpBar")
	if not IsExpShowStateValue() then
		text:SetText("")
	elseif IsShowStateValueByPercentage() then
		text:SetText(string.format("%d", 100 * nValue1 / nValue2).."%")
	else
		text:SetText(nValue1.."/"..nValue2)
	end
	img:SetPercentage(nValue1 / nValue2)
end

RegisterEvent("CUSTOM_UI_MODE_SET_DEFAULT", MainBarPanel_SetAnchorDefault)

function GetPing()
	local frame = GetMainBarPanelFrame()
	if frame then
		if frame.nPingTime then
			return frame.nPingTime
		else
			return math.floor(GetPingValue() / 2)
		end
	end
end
