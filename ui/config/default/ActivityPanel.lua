ActivityPanel = {
	ItemContentShowStep = 0
}

function ActivityPanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
end

function ActivityPanel.OnEvent(event)
	if event == "UI_SCALED" then
		ActivityPanel:SetPanelPos()
	end
end

function ActivityPanel.OnFrameBreathe()
	ActivityPanel:UpdateItemContent()
	
	ActivityPanel.ItemContentShowStep = ActivityPanel.ItemContentShowStep + 1
	if ActivityPanel.ItemContentShowStep >= 999999 then
		ActivityPanel.ItemContentShowStep = 999999
	end
end

function ActivityPanel.OnFrameShow()
	ActivityPanel:SetTitle(ActivityPanel.szTitle)
	ActivityPanel:SetMessage(ActivityPanel.szMessage)
	ActivityPanel:InitItemContent()
	
	CorrectAutoPosFrameWhenShow(this)
end

function ActivityPanel.OnFrameHide()
	CorrectAutoPosFrameWhenHide(this)
end

function ActivityPanel.OnLButtonClick()
	local szSelfName = this:GetName()
	
	if szSelfName == "Btn_Close" then
		ActivityPanel:ClosePanel()
	elseif szSelfName == "Btn_Sure" then
		ActivityPanel:ClosePanel()
	elseif szSelfName == "Btn_Up" then
		this:GetRoot():Lookup("Scroll_List"):ScrollNext(-100)
	elseif szSelfName == "Btn_Down" then
		this:GetRoot():Lookup("Scroll_List"):ScrollNext(100)
	end
end

function ActivityPanel.OnItemMouseEnter()
	if not this.nTableType or not this.dwTemplateID then
		return
	end

	local x, y = this:GetAbsPos()
	local w, h = this:GetSize()
	this:SetObjectMouseOver(1)
	OutputItemTip(UI_OBJECT_ITEM_INFO, this.nVersion, this.nTableType, this.dwTemplateID, {x, y, w, h})
end

function ActivityPanel.OnItemMouseLeave()
	this:SetObjectMouseOver(0)
	HideTip()
end


function ActivityPanel.UpdateScrollInfo(handle)
	local frame = this:GetRoot()
	local wAll, hAll = handle:GetAllItemSize()
    local w, h = handle:GetSize()
    local scroll = frame:Lookup("Scroll_List")
    local nCountStep = math.ceil(math.ceil((hAll - h) / 10) * 100)
    scroll:SetStepCount(nCountStep)
	scroll:SetScrollPos(0)
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

function ActivityPanel.OnItemMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	this:GetRoot():Lookup("Scroll_List"):ScrollNext(nDistance * 100)
	return 1
end

function ActivityPanel.OnScrollBarPosChanged()
	local nCurrentValue = this:GetScrollPos()
	local frame = this:GetParent()
	if nCurrentValue == 0 then
		frame:Lookup("Btn_Up"):Enable(0)
	else
		frame:Lookup("Btn_Up"):Enable(1)
	end
	local nTotal = this:GetStepCount()
	if nCurrentValue == nTotal then
		frame:Lookup("Btn_Down"):Enable(0)
	else
		frame:Lookup("Btn_Down"):Enable(1)
	end
	
	local handle = frame:Lookup("", "Handle_Message")
    handle:SetItemStartRelPos(0, - math.floor(nCurrentValue / 100) * 10)
end

-- ------------------------------------------------------------
-- Content 显示相关
-- ------------------------------------------------------------
function ActivityPanel:SetPanelPos(nX, nY)
	local framePanel = Station.Lookup("Normal/ActivityPanel")
	if not nX or not nY then
		framePanel:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	else
		framePanel:SetRelPos(nX, nY)
	end
end

function ActivityPanel:SetTitle(szTitleText)
	if not szTitleText then
		return
	end
	local textTitle = Station.Lookup("Normal/ActivityPanel", "Text_BookTitle")
	textTitle:SetText(szTitleText)
end

function ActivityPanel:SetMessage(szMessage)
	local handleMessage = Station.Lookup("Normal/ActivityPanel"):Lookup("", "Handle_Message")
	local player = GetClientPlayer()
	local _, tMessage = GWTextEncoder_Encode(szMessage)
	
	if not player then
		return
	end
	tMessage = tMessage or {}
	handleMessage:Clear()
	
	for i = 1, #tMessage do
		local tMessageSection = tMessage[i]
		if tMessageSection.name == "text" then			--普通文本
			handleMessage:AppendItemFromString("<text>text=" .. EncodeComponentsString(tMessageSection.context) .. "font=162</text>")
		elseif tMessageSection.name == "N" then			--自己的名字
			handleMessage:AppendItemFromString("<text>text=" .. EncodeComponentsString(player.szName) .. "font=162</text>")
		elseif tMessageSection.name == "C" then			--自己的体型对应的称呼
			handleMessage:AppendItemFromString("<text>text=" .. EncodeComponentsString(g_tStrings.tRoleTypeToName[player.nRoleType]) .. "font=162</text>")
		elseif tMessageSection.name == "F" then			--字体
			handleMessage:AppendItemFromString("<text>text=" .. EncodeComponentsString(tMessageSection.attribute.text) .. "font=" .. tMessageSection.attribute.fontid .. "</text>")
		elseif tMessageSection.name == "T" then			--图片
			if not tMessageSection.attribute.paramid then
				if tMessageSection.attribute.tipid then
					handleMessage:AppendItemFromString("<image>eventid=256 path=\"fromiconid\" frame=" .. handleMessage.attribute.picid .. "</image>")
					local img = handleMessage:Lookup(handleMessage:GetItemCount() - 1)
					img.nTipID = tonumber(handleMessage.attribute.tipid)
					img.bTipPic = true
				else
					handleMessage:AppendItemFromString("<image>path=\"fromiconid\" frame=" .. handleMessage.attribute.picid .. "</image>")
				end
			end
		elseif tMessageSection.name == "H" then			--控制行高，如果高度大于当前行高，调整为这个高度，否则，不变
			handleMessage:AppendItemFromString("<null>h=" .. tMessageSection.attribute.height .. "</null>")
		elseif tMessageSection.name == "G" then			--4个英文空格
			local szSpace = g_tStrings.STR_TWO_CHINESE_SPACE
			if tMessageSection.attribute.english then
				szSpace = "    "
			end
			handleMessage:AppendItemFromString("<text>text=\"".. szSpace .. "\" font=160</text>")
		elseif tMessageSection.name == "J" then			--金钱
			local nMoney = tonumber(tMessageSection.attribute.money)
			local nFontID = 162
			if tMessageSection.attribute.compare and nMoney > player.GetMoney() then
				nFontID = 166
			end
			handleMessage:AppendItemFromString(GetMoneyText(nMoney, "font=" .. nFontID))
		else											--错误的解析，还原文本
			if tMessageSection.context then
				handleMessage:AppendItemFromString("<text>text=" .. EncodeComponentsString("<" .. tMessageSection.context .. ">") .. "font=162</text>")
			end
		end
	end
	
	handleMessage:FormatAllItemPos()
	ActivityPanel.UpdateScrollInfo(handleMessage)
end

function ActivityPanel:InitItemContent()
	local nBoxWidth = 48
	local nBoxHeight = 48
	local handleItem = Station.Lookup("Normal/ActivityPanel"):Lookup("", "Handle_Item")
	handleItem:Clear()
	self.ItemContentShowStep = 0
	
	local szIniFile = "UI/Config/Default/BagPanel.ini"
	for nRow = 1, 2 do
		for nCol = 1, 6 do
			-- 对 box 进行创建和编号, 下标从 0 开始
			local nLastCreatedItemIndex = handleItem:GetItemCount()
			local box = handleItem:AppendItemFromIni(szIniFile, "Box", "Box_" .. nLastCreatedItemIndex)
			
			box:SetRelPos((nCol - 1) * (nBoxWidth + 5), (nRow - 1) * (nBoxHeight + 5))
			
			box:SetSize(nBoxWidth, nBoxHeight)
			box:SetBoxIndex(nLastCreatedItemIndex)
			box:SetObject(1, 0)
			box:ClearObjectIcon()
			
			box:SetObjectIcon(1435)
			box:SetObjectCoolDown(true)
			
			box.nTableType = nil
			box.dwTemplateID = nil
			box.nStack = nil
			box.nIconID = 1435
		end
	end
	handleItem:FormatAllItemPos()
end

function ActivityPanel:UpdateItemContent()
	local tItemList = self.tItemList
	local handleItem = Station.Lookup("Normal/ActivityPanel"):Lookup("", "Handle_Item")
	local nItemShowIndex = self.ItemContentShowStep
	local box = handleItem:Lookup(nItemShowIndex - 1)
	
	if self.ItemContentShowStep >= 7 then
		local boxLast = handleItem:Lookup(nItemShowIndex - 8)
		if boxLast then
			boxLast:SetObjectStaring(false)
		end
	end
	
	if not box or not tItemList[nItemShowIndex] then
		return
	end

	box.nTableType = tItemList[nItemShowIndex].nTableType
	box.dwTemplateID = tItemList[nItemShowIndex].dwTemplateID
	box.nStack = tItemList[nItemShowIndex].nStack
	
	local itemInfo = GetItemInfo(box.nTableType, box.dwTemplateID)
	box.nIconID = Table_GetItemIconID(itemInfo.nUiId)
	box.nVersion = 0
	
	box:SetObjectIcon(box.nIconID)
	box:SetObjectCoolDown(false)
	box:SetObjectStaring(true)
	if box.nStack > 1 then
		box:SetOverText(0, box.nStack)
	end
end

-- ------------------------------------------------------------
-- Panel 显示相关
-- ------------------------------------------------------------
function ActivityPanel:OpenPanel(szTitle, szMessage, tItemList, bDisableSound)
	self.szTitle = szTitle
	self.szMessage = szMessage
	self.tItemList = tItemList

	if IsOptionOrOptionChildPanelOpened() then
		return
	end

	if not GetClientPlayer() then
		return
	end

	local framePanel = Station.Lookup("Normal/ActivityPanel")
	if not framePanel then
		framePanel = Wnd.OpenWindow("ActivityPanel")
	end
	
	CloseQuestAcceptPanel(true)
	CloseShop(true)
	CloseMailPanel(true)
	CloseBankPanel(true)
	CloseSkillFormulaPanel(true)
	
	framePanel:Show()
	framePanel:BringToTop()
	self:SetPanelPos()
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)	
	end
end

function ActivityPanel:ClosePanel(bDisableSound)
	local framePanel = Station.Lookup("Normal/ActivityPanel")
	if not framePanel then
		return
	end
	
	framePanel:Hide()
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
end

function ActivityPanel:IsPanelOpened()
	local framePanel = Station.Lookup("Normal/ActivityPanel")
	if framePanel and framePanel:IsVisible() then
		return true
	end
	return false
end

function ActivityPanel:SwitchPanelOpenState()
	if self:IsPanelOpened() then
		self:ClosePanel()
	else
		self:OpenPanel()
	end
end