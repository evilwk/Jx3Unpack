MystiqueInfomation = 
{
	bDisableAll = false,
	aDisable = {},
}

RegisterCustomData("MystiqueInfomation.aDisable")
RegisterCustomData("MystiqueInfomation.bDisableAll")

function MystiqueInfomation.OnFrameCreate()
	this:RegisterEvent("CUSTOM_DATA_LOADED")
	this:RegisterEvent("UI_SCALED")
	this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
end

function MystiqueInfomation.OnEvent(event)
	if event == "UI_SCALED" then
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
		MystiqueInfomation.UpdateScrollInfo(this:Lookup("", "Handle_Infomation"))
		--this:CorrectPos()
	elseif event == "CUSTOM_DATA_LOADED" then
		if not MystiqueInfomation.bDisableAll or not MystiqueInfomation.aDisable[this.dwID] then
			CloseMystiqueInfomation(true)
		end
	end
end

function MystiqueInfomation.Update(frame, dwID, szPath)
	frame.dwID = dwID
	local hInfo = frame:Lookup("", "Handle_Infomation")
	hInfo:Clear()
	local szInfo = ""
	local tInfo = KG_Table.Load(szPath, {{f="S", t="szInfomation"}}, FILE_OPEN_MODE.NORMAL)
	if tInfo then
		local tRow = tInfo:GetRow(1)
		if tRow then
			szInfo = tRow.szInfomation
		end
		tInfo = nil
	end
	szInfo = szInfo or ""
	hInfo:AppendItemFromString(szInfo)
	
	local szName = Table_GetMapName(dwID)
	frame:Lookup("", "Text_Name"):SetText(szName)
	
	MystiqueInfomation.UpdateScrollInfo(hInfo)
end

function MystiqueInfomation.OnItemLButtonDown()
	OnItemLinkDown(this)
end

function MystiqueInfomation.OnCheckBoxCheck()
	local szName = this:GetName()
	if szName == "CheckBox_Disable" then
	end
end

function MystiqueInfomation.OnCheckBoxUncheck()
	local szName = this:GetName()
	if szName == "CheckBox_Disable" then
	end
end

function MystiqueInfomation.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		local frame = this:GetRoot()
		if this:GetParent():Lookup("CheckBox_Disable"):IsCheckBoxChecked() then
			MystiqueInfomation.aDisable[frame.dwID] = true
		else
			MystiqueInfomation.aDisable[frame.dwID] = nil
		end
		CloseMystiqueInfomation()
	end
end

function MystiqueInfomation.UpdateScrollInfo(hList)
	local frame = hList:GetRoot()
	local scroll = frame:Lookup("Scroll_Infomation")
	hList:FormatAllItemPos()
	local wAll, hAll = hList:GetAllItemSize()
    local w, h = hList:GetSize()
    local nCountStep = math.ceil((hAll - h) / 10)
    scroll:SetStepCount(nCountStep)
    if nCountStep > 0 then
    	scroll:Show()
    	frame:Lookup("Btn_Up"):Show()
    	frame:Lookup("Btn_Down"):Show()
    else
    	scroll:Hide()
    	frame:Lookup("Btn_Up"):Hide()
    	frame:Lookup("Btn_Down"):Hide()
    end
end


function MystiqueInfomation.OnLButtonDown()
	MystiqueInfomation.OnLButtonHold()
end

function MystiqueInfomation.OnLButtonHold()
	local szName = this:GetName()
	if szName == "Btn_Up" then
		this:GetParent():Lookup("Scroll_Infomation"):ScrollPrev()
	elseif szName == "Btn_Down" then
		this:GetParent():Lookup("Scroll_Infomation"):ScrollNext()
	end	
end

function MystiqueInfomation.OnMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	local szName = this:GetName()	
	if szName == "MystiqueInfomation" then
		this:Lookup("Scroll_Infomation"):ScrollNext(nDistance)
		return true
	end	
end

function MystiqueInfomation.OnScrollBarPosChanged()
	local nCurrentValue = this:GetScrollPos()
	local szName = this:GetName()
	if szName == "Scroll_Infomation" then
        if nCurrentValue == 0 then
            this:GetParent():Lookup("Btn_Up"):Enable(false)
        else
            this:GetParent():Lookup("Btn_Up"):Enable(true)
        end
        if nCurrentValue == this:GetStepCount() then
            this:GetParent():Lookup("Btn_Down"):Enable(false)
        else
            this:GetParent():Lookup("Btn_Down"):Enable(true)
        end
        local hInfo = this:GetParent():Lookup("", "Handle_Infomation");
        local x, y = hInfo:GetItemStartRelPos()
        hInfo:SetItemStartRelPos(x, - nCurrentValue * 10)		
	end
end

function OpenMystiqueInfomation(dwID, bDisableSound)
	if MystiqueInfomation.bDisableAll or MystiqueInfomation.aDisable[dwID] then
		CloseMystiqueInfomation(true)
		return
	end
	
	local szPath = GetMapParams(dwID)
	if not szPath then
		CloseMystiqueInfomation(true)
		return
	end
	
	szPath = szPath.."minimap\\information.tab"
	if not IsFileExist(szPath) then
		CloseMystiqueInfomation(true)
		return		
	end
	
	local frame = Station.Lookup("Normal/MystiqueInfomation")
	if frame then
		frame:Show()
	else
		frame = Wnd.OpenWindow("MystiqueInfomation")
	end
--	MystiqueInfomation.Update(frame, dwID, szPath)
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end	
end

function IsMystiqueInfomationOpened()
	local frame = Station.Lookup("Normal/MystiqueInfomation")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseMystiqueInfomation(bDisableSound)
	Wnd.CloseWindow("MystiqueInfomation")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function IsShowMystiqueInfomation(dwID)
	if MystiqueInfomation.aDisable[dwID] then
		return false
	end
	return true
end

function SetShowMystiqueInfomation(dwID, bShow)
	if bShow then
		MystiqueInfomation.aDisable[dwID] = nil
	else
		MystiqueInfomation.aDisable[dwID] = true
	end
end

local function OnClientPlayerEnterScene()
	local player = GetClientPlayer()
	if player and arg0 == player.dwID then
		OpenMystiqueInfomation(player.GetScene().dwMapID)
	end
end

RegisterEvent("PLAYER_ENTER_SCENE", OnClientPlayerEnterScene)