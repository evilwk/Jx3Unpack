Introduce = 
{
	bDisableAll = false,
	aDisable = {},
}
Introduce.tBossEquip = {}
RegisterCustomData("Introduce.aDisable")
RegisterCustomData("Introduce.bDisableAll")

local g_aCopyID = {}

function Introduce.OnFrameCreate()
	this:RegisterEvent("ON_APPLY_PLAYER_SAVED_COPY_RESPOND")
	
end

function Introduce.OnEvent(event)
	if event == "ON_APPLY_PLAYER_SAVED_COPY_RESPOND" then
		g_aCopyID = arg0
		Introduce.UpdateID(this)
	end
end

function Introduce.UpdateID(frame)
	local szID = g_DungeonStrings.STR_DUNGEON_NO_RECORD
    if g_aCopyID and g_aCopyID[Introduce.dwID] and g_aCopyID[Introduce.dwID][1] then
        szID = FormatString(g_tStrings.AREA_ID, g_aCopyID[Introduce.dwID][1])
    end
    frame:Lookup("", "Text_ID"):SetText(szID)
end

function Introduce.GetBossEquip(dwID)
	local aResult = {}
	local aEquip = EquipInquire_GetDungeonEquip(dwID) or {}
	for k, v in pairs(aEquip) do
		local aName = {}
		for i, j in ipairs(v) do
			local itemInfo = GetItemInfo(j.dwTabType, j.nItemID)
			if itemInfo then
				local szName = GetItemNameByItemInfo(itemInfo)
				local nLevel = itemInfo.nLevel or 0
				if aName[szName] then
					if aName[szName][3] < nLevel then
						aName[szName] = {j.dwTabType, j.nItemID, nLevel}
					end
				else
					aName[szName] = {j.dwTabType, j.nItemID, nLevel}
				end
			end
		end
		local c = {}
		for a, b in pairs(aName) do
			table.insert(c, {dwTabType = b[1], nItemID = b[2]})
		end
		aResult[k] = c
	end
	
	return aResult
end

function Introduce.UpdateEquip(hI)
	if hI.bCollapse then
		hI:Lookup("Text_Title"):SetText(g_tStrings.STR_CILCK_EQUIP_DROP) --g_tStrings.EQUIP_DROP
	else
		hI:Lookup("Text_Title"):SetText(g_tStrings.EQUIP_DROP) --g_tStrings.EQUIP_DROP
	end
	
	if not hI.bHaveContent then
		hI.bHaveContent = true
		local dwID = Introduce.dwID
		local hC = hI:Lookup("Handle_Content")
		local aBoss = Introduce.GetBossArray(dwID) or {}
		if not Introduce.tBossEquip[dwID] then
			Introduce.tBossEquip[dwID] = Introduce.GetBossEquip(dwID)
		end
		local aEquip = Introduce.tBossEquip[dwID] or {}
		for i, szBoss in ipairs(aBoss) do
			hC:AppendItemFromString("<text>text="..EncodeComponentsString(FormatString(g_tStrings.BOSS_DROP, i, szBoss)).."</text>")
			local t = aEquip[szBoss]
			for j, v in ipairs(t) do
				local itemInfo = GetItemInfo(v.dwTabType, v.nItemID)
				if itemInfo then
					local szLink = "<box>w=48 h=48 eventid=341 ".."name=\"iteminfolink\" eventid=341 script="..
					EncodeComponentsString("this.nVersion=0\nthis.dwTabType="..v.dwTabType.."\nthis.dwIndex="..v.nItemID).."</box>"
					--[[
					local szLink = "<text>text="..EncodeComponentsString("["..GetItemNameByItemInfo(itemInfo).."]")..
						"font=0"..GetItemFontColorByQuality(itemInfo.nQuality, true).."name=\"iteminfolink\" eventid=341 script="..
							EncodeComponentsString("this.nVersion=0\nthis.dwTabType="..v.dwTabType.."\nthis.dwIndex="..v.nItemID).."</text>"					
							]]
					hC:AppendItemFromString(szLink)
					local box = hC:Lookup(hC:GetItemCount()-1)
					box:SetObject(UI_OBJECT_ITEM_INFO, v.dwTabType, v.nItemID)
					box:SetObjectIcon(Table_GetItemIconID(itemInfo.nUiId))
					UpdateItemBoxExtend(box, itemInfo, itemInfo.nQuality)
				end
			end
			hC:AppendItemFromString("<text>text=\"\\\n\\\n\"</text>")
		end
		hC:FormatAllItemPos()
	end
	Introduce.UpdateSize(hI)
	Introduce.UpdateScrollInfo(hI:GetParent())
end

function Introduce.UpdateContent(frame, bFromDungeon, dwID, szPath)
	Introduce.bFromDungeon = bFromDungeon
	Introduce.dwID = dwID
	Introduce.bBattleField = false
	
	Introduce.UpdateID(frame)
	
	frame:Lookup("", "Text_TitleS"):SetText(g_tStrings.DRUNGON_INFO_INTRODUCE)
	frame:Lookup("CheckBox_Choose"):Show()
	
	local szName = Table_GetMapName(dwID)	
	frame:Lookup("", "Text_Name"):SetText(szName)
	
	if Introduce.aDisable[dwID] then
		frame:Lookup("CheckBox_Choose"):Check(true)
	else
		frame:Lookup("CheckBox_Choose"):Check(false)
	end
	
	local hList = frame:Lookup("", "Handle_List")
	hList:Clear()
	
	local szRecommend, szDesc = "", ""
	local tInfo = KG_Table.Load(szPath, {{f="S", t="szRecommend"}, {f="S", t="szDesc"}}, FILE_OPEN_MODE.NORMAL)
	if tInfo then
		local tRow = tInfo:GetRow(1)
		if tRow then
			szRecommend = tRow.szRecommend
			szDesc = tRow.szDesc
		end
		tInfo = nil
	end
	szRecommend = szRecommend or ""
	szDesc = szDesc or ""

	local szIniFile = "/ui/Config/Default/Introduce.ini"
	local hR = hList:AppendItemFromIni(szIniFile, "Handle_Info", "Recommend")
	hR:Lookup("Text_Title"):SetText(g_tStrings.SCHOOL_RECOMMEND)
	local hC = hR:Lookup("Handle_Content")
	hC:AppendItemFromString(szRecommend)
	hC:FormatAllItemPos()
	Introduce.UpdateSize(hR)

	local hD = hList:AppendItemFromIni(szIniFile, "Handle_Info", "Desc")
	hD:Lookup("Text_Title"):SetText(g_tStrings.COPY_INTRODUCE)
	local hC = hD:Lookup("Handle_Content")
	hC:AppendItemFromString(szDesc)
	hC:FormatAllItemPos()
	local w, h = hC:GetSize()
	local _, h = hC:GetAllItemSize()
	Introduce.UpdateSize(hD)

	local _, _, szVersionLineName = GetVersion()
	if szVersionLineName ~= "zhkr" then
		local hI = hList:AppendItemFromIni(szIniFile, "Handle_Info", "Item")
		hI:Lookup("Text_Title"):SetText(g_tStrings.STR_CILCK_EQUIP_DROP) --g_tStrings.EQUIP_DROP
		hI.bEquip = true
		
		if not Introduce.bFromDungeon or Introduce.tBossEquip[dwID] then
			hI.bCollapse = false
			Introduce.UpdateEquip(hI)
		else
			hI.bCollapse = true
			local hC = hI:Lookup("Handle_Content")
			hC:FormatAllItemPos()
			Introduce.UpdateImgState(hI)
			Introduce.UpdateSize(hI)
		end
	end
	
	Introduce.UpdateScrollInfo(hList)
end

function Introduce.UpdateBattleField(frame, dwID)
	Introduce.bFromDungeon = true
	Introduce.dwID = dwID
	Introduce.bBattleField = true

	frame:Lookup("", "Text_ID"):SetText("")
		
	frame:Lookup("", "Text_TitleS"):SetText(g_tStrings.BATTLE_FIELD_INTRODUCE)
	frame:Lookup("CheckBox_Choose"):Hide()
	
	local szName = Table_GetMapName(dwID)	
	frame:Lookup("", "Text_Name"):SetText(szName)
	
	if Introduce.aDisable[dwID] then
		frame:Lookup("CheckBox_Choose"):Check(true)
	else
		frame:Lookup("CheckBox_Choose"):Check(false)
	end
		
	local hList = frame:Lookup("", "Handle_List")
	hList:Clear()

	local _, szHelp = Table_GetBattleFieldHelpInfo(dwID)
	hList:AppendItemFromString(szHelp)

	Introduce.UpdateScrollInfo(hList)
end

function Introduce.GetBossArray(dwID)
	local t = g_tEquipInquireStrings.DUNGEON
	for i, v in ipairs(t) do
		local tSub = v.tDungeon
		for j, vSub in ipairs(tSub) do
			if dwID == vSub.nNormalID then
				return vSub.tNormalBoss
			elseif dwID == vSub.nHardID then
				return vSub.tHardBoss
			end
		end
	end
	return {}
end

function Introduce.UpdateSize(hI)
	local hC = hI:Lookup("Handle_Content")
	local w, h = hC:GetSize()
	local _, h = hC:GetAllItemSize()
	hC:SetSize(w, h)
	if hI.bCollapse then
		hC:Hide()
		local img = hI:Lookup("Image_RankBg")
		img:Hide()
		local w, _ = img:GetSize()
		img:SetSize(w, 30)
		local w, _ = hI:GetSize()
		hI:SetSize(w, 28)		
	else
		hC:Show()
		local img = hI:Lookup("Image_RankBg")
		img:Show()
		local w, _ = img:GetSize()
		img:SetSize(w, h + 46)
		local w, _ = hI:GetSize()
		hI:SetSize(w, h + 46)
	end
end

function Introduce.OnLButtonClick()
    local szName = this:GetName()
    if szName == "Btn_Close" or szName == "Btn_Exit" then
    	if Introduce.dwID then
	    	if this:GetParent():Lookup("CheckBox_Choose"):IsCheckBoxChecked() then
	    		Introduce.aDisable[Introduce.dwID] = true
	    	else
	    		Introduce.aDisable[Introduce.dwID] = false
	    	end
    	end
        CloseIntroduce()
    end
end

function Introduce.OnCheckBoxCheck()
	local szName = this:GetName()
	if szName == "CheckBox_Choose" then
	end
end

function Introduce.OnCheckBoxUncheck()
	local szName = this:GetName()
	if szName == "CheckBox_Choose" then
	end
end

function Introduce.UpdateScrollInfo(hList)
	local frame = hList:GetRoot()
	local scroll = frame:Lookup("Scroll_List")
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


function Introduce.OnLButtonDown()
	Introduce.OnLButtonHold()
end

function Introduce.OnLButtonHold()
	local szName = this:GetName()
	if szName == "Btn_Up" then
		this:GetParent():Lookup("Scroll_List"):ScrollPrev()
	elseif szName == "Btn_Down" then
		this:GetParent():Lookup("Scroll_List"):ScrollNext()
	end	
end

function Introduce.OnMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	local szName = this:GetName()	
	if szName == "Introduce" then
		this:Lookup("Scroll_List"):ScrollNext(nDistance)
		return true
	end	
end

function Introduce.OnScrollBarPosChanged()
	local nCurrentValue = this:GetScrollPos()
	local szName = this:GetName()
	if szName == "Scroll_List" then
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
        local hInfo = this:GetParent():Lookup("", "Handle_List");
        local x, y = hInfo:GetItemStartRelPos()
        hInfo:SetItemStartRelPos(x, - nCurrentValue * 10)		
	end
end

function Introduce.UpdateImgState(hI)
	local img = hI:Lookup("Image_Up")
	if not img then
		return
	end
	if hI.bOver then
		if hI.bCollapse then
			img:SetFrame(12)
		else
			img:SetFrame(18)
		end
	else
		if hI.bCollapse then
			img:SetFrame(11)
		else
			img:SetFrame(17)
		end
	end
end

function Introduce.OnItemLButtonDown()
	local szName = this:GetName()
	if szName == "Text_Title" then
		local hI = this:GetParent()
		if hI.bCollapse then
			hI.bCollapse = false
		else
			hI.bCollapse = true
		end
		Introduce.UpdateImgState(hI)
		if hI.bEquip then
			Introduce.UpdateEquip(hI)
		else
			Introduce.UpdateSize(hI)
		end
		Introduce.UpdateScrollInfo(hI:GetParent())
	elseif szName == "iteminfolink" then
		if IsCtrlKeyDown() then
			OnItemLinkDown(this)
		end
	end
end

function Introduce.OnItemLButtonDBClick()
	local szName = this:GetName()
	if szName == "Text_Title" then
		Introduce.OnItemLButtonDown()
	end
end

function Introduce.OnItemMouseEnter()
	local szName = this:GetName()
	if szName == "Text_Title" then
		local hI = this:GetParent()
		hI.bOver = true
		Introduce.UpdateImgState(hI)
	elseif szName == "iteminfolink" then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputItemTip(UI_OBJECT_ITEM_INFO, this.nVersion, this.dwTabType, this.dwIndex, {x, y, w, h}, nil, nil, nil, nil, nil)				
	end
end

function Introduce.OnItemMouseLeave()
	local szName = this:GetName()
	if szName == "Text_Title" then
		local hI = this:GetParent()
		hI.bOver = false
		Introduce.UpdateImgState(hI)
	elseif szName == "iteminfolink" then
		HideTip()
	end
end

function OpenIntroduce(dwID, bFromDungeon, bBattleField, bDisableSound)
	if not bFromDungeon then
		if Introduce.bDisableAll or Introduce.aDisable[dwID] then
			CloseIntroduce(true)
			return
		end
	end

	local szPath = GetMapParams(dwID)	
	if not bBattleField then
		if not szPath then
			CloseIntroduce(true)
			return
		end
		
		szPath = szPath.."minimap\\information.tab"
		if not IsFileExist(szPath) then
			CloseIntroduce(true)
			return		
		end
	end
	
	local frame = Station.Lookup("Normal/Introduce")
	if frame then
		frame:Show()
	else
		frame = Wnd.OpenWindow("Introduce")
	end
	if bBattleField then
		Introduce.UpdateBattleField(frame, dwID)
	else
		Introduce.UpdateContent(frame, bFromDungeon, dwID, szPath)
	end
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
	
	if bFromDungeon then
		frame:SetPoint("TOPLEFT", 0, 0, "Normal/DungeonInfoPanel", "TOPRIGHT", 0, 0)
	else
		frame:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	end
	
	RemoteCallToServer("OnApplyPlayerSavedCopysRequest")
end

function IsIntroduceOpened()
    local hFrame = Station.Lookup("Normal/Introduce")
    if hFrame and hFrame:IsVisible() then
        return true
    end
    return false
end

function CloseIntroduce(bDisableSound)
    if not IsIntroduceOpened() then
        return
    end
    
    Wnd.CloseWindow("Introduce")
    if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function Introduce_SetContent(szTitle, szContentText)
    Introduce.szTitle = szTitle
    Introduce.szContentText = szContentText
    
    if IsIntroduceOpened() then
        Introduce.UpdateContent()
    else
        OpenIntroduce();
    end
end

local function OnClientLoadingEnd()
	local scene = GetClientScene();
	OpenIntroduce(scene.dwMapID, false, false)
end

RegisterEvent("LOADING_END", OnClientLoadingEnd)

local Anchor = {s = "TOPLEFT", r = "TOPRIGHT", x = 0, y = 0}
RegisterFollowPanel("Normal/DungeonInfoPanel", "Normal/Introduce", Anchor) 

