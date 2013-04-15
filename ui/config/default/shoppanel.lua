
ShopPanel = {}

function ShopPanel.OnFrameCreate()
	this:RegisterEvent("SHOP_UPDATEITEM")
	this:RegisterEvent("MONEY_UPDATE")
	this:RegisterEvent("SOLD_ITEM_UPDATE")
	this:RegisterEvent("CONTRIBUTION_UPDATE")
	this:RegisterEvent("UPDATE_ACHIEVEMENT_POINT")
	this:RegisterEvent("UPDATE_ACHIEVEMENT_COUNT")
    
	local npc = GetNpc(ShopPanel.nNpcID)
	
    local handle = this:Lookup("PageSet_Main/Page_Sale", "Handle_Sale")
	if npc then
		handle:GetParent():Lookup("Text_TitleSale"):SetText(npc.szName)
	end	
    handle:Clear()
    if not ShopPanel.bCanRepair then
    	handle:GetParent():GetParent():Lookup("Btn_Repair"):Hide()
    	handle:GetParent():GetParent():Lookup("Btn_RepairAll"):Hide()
    else
    	local btnRA = handle:GetParent():GetParent():Lookup("Btn_RepairAll")
    	btnRA.OnMouseEnter = function()
    		if this:IsDisable() then
    			return
    		end
    		this.bEnter = true
    		local nMoney = GetRepairAllItemsPrice(ShopPanel.nNpcID, ShopPanel.nShopID) 
    		local szTip = "<text>text="..EncodeComponentsString(g_tStrings.STR_REPAIR_ALL).."font=65 </text>"..
    			"<text>text="..EncodeComponentsString(g_tStrings.STR_REPAIR_ALL_MONEY).."font=106 </text>"..GetMoneyTipText(nMoney, 106)..
    			"<text>text=\"\\\n\"</text>"
    		local x, y = this:GetAbsPos()
    		local w, h = this:GetSize()
    		OutputTip(szTip, 300, {x, y, w, h})
    		return 0
    	end
    	btnRA.OnMouseLeave = function()
    		this.bEnter = false
    		HideTip()
    		return 0
    	end
		btnRA.OnLButtonClick = function()
			RepairAllItems(ShopPanel.nNpcID, ShopPanel.nShopID)
			return 0
		end
		local nMoney = GetRepairAllItemsPrice(ShopPanel.nNpcID, ShopPanel.nShopID)
		if nMoney and nMoney ~= 0 then
			btnRA:Enable(true)
		else
			btnRA:Enable(false)
		end
   	end
   	ShopPanel.UpdateShopPageInfo(handle:GetParent():GetParent())

	if npc then
		this:Lookup("PageSet_Main/Page_Buy", "Text_TitleBuy"):SetText(npc.szName)
	end	
	ShopPanel.UpdateBuyBackList(this)
    
    ---------更新金钱数量----------------
    local player = GetClientPlayer()
    if player then
    	ShopPanel.UpdateMoneyShow(this, player.GetMoney())
    end
    
    InitFrameAutoPosInfo(this, 1, "Dialog", nil, function() CloseShop(true) end)  
end

function ShopPanel.UpdateBuyBackList(frame)
    local player = GetClientPlayer()
    handle = frame:Lookup("PageSet_Main/Page_Buy", "Handle_Buy")
    local dwSize = player.GetBoxSize(INVENTORY_INDEX.SOLD_LIST) - 1
    for i = 0, dwSize, 1 do
		local item = GetPlayerItem(player, INVENTORY_INDEX.SOLD_LIST, i)
		if item then
			local nCount = 1
			if item.bCanStack then
				nCount = item.nStackNum
			end
			local nPrice = GetShopItemSellPrice(ShopPanel.nNpcID, ShopPanel.nShopID, INVENTORY_INDEX.SOLD_LIST, i)
			ShopPanel.OnUpdataShopItemInfo(handle, i, item, nPrice, nCount, true)
		end
    end
    handle:FormatAllItemPos()
end

function ShopPanel.OnEvent(event)
	if event == "SHOP_UPDATEITEM" then
		ShopPanel.OnUpdataShopItemStatus(this, arg0, arg1, arg2)
	elseif event == "MONEY_UPDATE" then
		ShopPanel.UpdateMoneyShow(this, arg0)
		ShopPanel.UpdateSoldList(this)
		ShopPanel.UpdateBuyBackList(this)
	elseif event == "CONTRIBUTION_UPDATE" then
		ShopPanel.UpdateSoldList(this)
		ShopPanel.UpdateBuyBackList(this)
	elseif event == "SOLD_ITEM_UPDATE" then
		ShopPanel.OnSoldListItemUpdate(this, arg0, arg1)	
	elseif event == "UPDATE_ACHIEVEMENT_POINT" then
		ShopPanel.UpdateSoldList(this)
		ShopPanel.UpdateBuyBackList(this)
	elseif event == "UPDATE_ACHIEVEMENT_COUNT" then
		ShopPanel.UpdateSoldList(this)
		ShopPanel.UpdateBuyBackList(this)
	end
end

function ShopPanel.UpdateSoldList(frame)
    local handle = frame:Lookup("PageSet_Main/Page_Sale", "Handle_Sale")
    local nCount = handle:GetItemCount() - 1
    for i = 0, nCount, 1 do
    	local dwPos = handle:Lookup(i).dwPos
	    local dwItemID = GetShopItemID(ShopPanel.nShopID, ShopPanel.nCurrentOpenPage, dwPos)
	    local item = GetItem(dwItemID)
	    local nPrice = GetShopItemBuyPrice(ShopPanel.nNpcID, ShopPanel.nShopID, ShopPanel.nCurrentOpenPage, dwPos)
	    local nItemCount = GetShopItemCount(ShopPanel.nShopID, ShopPanel.nCurrentOpenPage, dwPos)
	
	    ShopPanel.OnUpdataShopItemInfo(handle, dwPos, item, nPrice, nItemCount)
    end
    handle:FormatAllItemPos()
    
    local thisSave = this
    this = frame
    ShopPanel.OnFrameBreathe()
    this = thisSave
end

function ShopPanel.OnFrameBreathe()
	local player = GetClientPlayer()
	if not player or player.nMoveState == MOVE_STATE.ON_DEATH then
		CloseShop()
		return
	end
	
	local npc = GetNpc(ShopPanel.nNpcID)
	if not npc or not npc.CanDialog(player) then
		CloseShop()
		return
	end
	
	local page = this:Lookup("PageSet_Main/Page_Sale")
	
	local btn = page:Lookup("Btn_RepairAll")
	if btn then
		local nMoney = GetRepairAllItemsPrice(ShopPanel.nNpcID, ShopPanel.nShopID)
		if nMoney and nMoney ~= 0 then
			btn:Enable(true)
		else
			btn:Enable(false)
		end
		if btn.bEnter then
			local thisSave = this
			this = btn
			this.OnMouseEnter()
			this = thisSave
		end
	end
	
    local nTotal, nLeft = GetBuyLimitItemCDLeftFrames()
    if nTotal and nLeft then
	    if nLeft < 0 then
	    	nLeft = 0
	    end
	    local handle = page:Lookup("", "Handle_Sale")
	    local nCount = handle:GetItemCount() - 1
	    for i = 0, nCount, 1 do
	    	local hI = handle:Lookup(i)
	    	if hI.bLimit then
		    	local box = hI:Lookup("Box_Item")  	
			    if nLeft == 0 then
			    	if box:IsObjectCoolDown() then
		                box:SetObjectCoolDown(false)
		                box:SetObjectSparking(true)	    	
			    	end
			    else
		            box:SetObjectCoolDown(true)
		            box:SetCoolDownPercentage(1 - nLeft / nTotal)
			    end
			end
	    end
	end	
end

function ShopPanel.OnActivePage()
	local nLast = this:GetLastActivePageIndex()
	local nPage = this:GetActivePageIndex()
	if nLast ~= -1 and nPage ~= nLast then
		PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
	end
end

function ShopPanel.OnSoldListItemUpdate(frame, nBoxIndex, nItemIndex)

	if nBoxIndex ~= INVENTORY_INDEX.SOLD_LIST then
		return
	end

    local handle = frame:Lookup("PageSet_Main/Page_Buy", "Handle_Buy")
    
    local player = GetClientPlayer()
	local item = GetPlayerItem(player, nBoxIndex, nItemIndex)
	if item then
		local nCount = 1
		if item.bCanStack then
			nCount = item.nStackNum
		end
		local nPrice = GetShopItemSellPrice(ShopPanel.nNpcID, ShopPanel.nShopID, nBoxIndex, nItemIndex)
		ShopPanel.OnUpdataShopItemInfo(handle, nItemIndex, item, nPrice, nCount, true)
	else
		handle:RemoveItem(tostring(nItemIndex))
	end
	handle:FormatAllItemPos()
end

function ShopPanel.OnUpdataShopItemStatus(frame, dwShopId, dwPageIndex, dwPos)
    if dwShopId ~= ShopPanel.nShopID or dwPageIndex ~= ShopPanel.nCurrentOpenPage then
        return
    end
    
    local page = frame:Lookup("PageSet_Main/Page_Sale")
    local handle = page:Lookup("", "Handle_Sale")
    
    local dwItemID = GetShopItemID(ShopPanel.nShopID, ShopPanel.nCurrentOpenPage, dwPos)
    local item = GetItem(dwItemID)
    local nPrice = GetShopItemBuyPrice(ShopPanel.nNpcID, ShopPanel.nShopID, ShopPanel.nCurrentOpenPage, dwPos)
    local nCount = GetShopItemCount(ShopPanel.nShopID, ShopPanel.nCurrentOpenPage, dwPos)

    ShopPanel.OnUpdataShopItemInfo(handle, dwPos, item, nPrice, nCount)
    handle:FormatAllItemPos()
end

function ShopPanel.OnUpdataShopItemInfo(handle, dwPos, item, nPrice, nCount, bByBack)
    local szName = tostring(dwPos)
    
    if not item then
    	--没有这个物品，变为不能购买
    	local handleItem = handle:Lookup(szName)
    	if handleItem then
    		handleItem:Lookup("Box_Item"):EnableObject(false)
    	end
    	
    	return
    end
    


    local handleItem = handle:Lookup(szName)
    if not handleItem then
        local szIniFile = "UI/Config/default/ShopPanel.ini"
        handle:AppendItemFromIni(szIniFile, "Handle_Item", szName)
        handleItem = handle:Lookup(szName)
    end
    ShopPanel.OnOnUpdataItemInfo(handleItem, dwPos, item, nPrice, nCount, bByBack)
    
    FireHelpEvent("OnOpenpanel", "SHOP")
end

function ShopPanel.OnOnUpdataItemInfo(handleItem, dwPos, item, nPrice, nCount, bByBack, nNumber)
    local player = GetClientPlayer()
    handleItem.dwPos = dwPos
    if not nNumber then
        nNumber = item.nCurrentDurability
    end
    -----------更新物品基本信息-----------------
    local box = handleItem:Lookup("Box_Item")
    local textName = handleItem:Lookup("Text_Name")
    
    local textG = handleItem:Lookup("Text_Gold")
    local textS = handleItem:Lookup("Text_Silver")
    local textC = handleItem:Lookup("Text_Copper")
    local imageG = handleItem:Lookup("Image_Gold")
    local imageS = handleItem:Lookup("Image_Silver")
    local imageC = handleItem:Lookup("Image_Copper")
    
	box:SetObject(UI_OBJECT_ITEM_ONLY_ID, item.nUiId, item.dwID, item.nVersion, item.dwTabType, item.dwIndex)			
	box:SetObjectIcon(Table_GetItemIconID(item.nUiId))
	UpdateItemBoxExtend(box, item)
	    
    box:SetUserData(dwPos)
    if bByBack then
		box:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
		box:SetOverTextFontScheme(0, 15)
	    if nCount < 1 then
	    	box:SetOverText(0, "")
	    else
	    	box:SetOverText(0, nCount)
	    end
    else
		box:SetOverTextPosition(0, ITEM_POSITION.LEFT_BOTTOM)
		box:SetOverTextFontScheme(0, 15)
	    if nCount < 0 then
	    	box:SetOverText(0, "")	--非限量物品
	    else
	    	box:SetOverText(0, nCount)
    		handleItem.bLimit = true
	    end
	    
		box:SetOverTextPosition(1, ITEM_POSITION.RIGHT_BOTTOM)
		box:SetOverTextFontScheme(1, 15)
	    if item.nGenre == ITEM_GENRE.BOOK or nNumber < 0 then
	    	box:SetOverText(1, "")
	    elseif item.bCanStack and nNumber > 1 then
	    	box:SetOverText(1, nNumber)
	    	box.bGroup = true
	    	nPrice = nPrice * nNumber
	    end
	end
    
    textName:SetText(GetItemNameByItem(item))
    textName:SetFontColor(GetItemFontColorByQuality(item.nQuality))
    
    local nGold, nSilver, nCopper = MoneyToGoldSilverAndCopper(nPrice)
    textG:SetText(nGold)
    textS:SetText(nSilver)
    textC:SetText(nCopper)
    imageG:Show()
    imageS:Show()
    imageC:Show()
    if nGold == 0 then
    	textG:SetText("")
    	imageG:Hide()
    	if nSilver == 0 then
    		textS:SetText("")
    		imageS:Hide()
    	end
    end
    
    local bSatisfy = true
    local nPrestige, nContribution, nJustice, nExamPrint, nArenaAward, nActivityAward, dwTabType, dwIndex, nRequireAmount, nRequireAchievementRecord, nAchievementPoint, nDurability, nMentorPoint, nCampTitle, nCoin, nRequireCorpsValue, dwMaskCorpsNeedToCheck
    if not bByBack then
    	nPrestige, nContribution, nJustice, nExamPrint, nArenaAward, nActivityAward, dwTabType, dwIndex, nRequireAmount, nRequireAchievementRecord, nAchievementPoint, nDurability, nMentorPoint, nCampTitle,  nCoin, nRequireCorpsValue, dwMaskCorpsNeedToCheck
    		= GetShopItemBuyOtherInfo(ShopPanel.nNpcID, ShopPanel.nShopID, ShopPanel.nCurrentOpenPage, dwPos)
    	if box.bGroup then
    		nPrestige = nPrestige * nNumber
    		nContribution = nContribution * nNumber
    		nRequireAmount = nRequireAmount * nNumber
    		nRequireAchievementRecord = nRequireAchievementRecord * nNumber
    		nAchievementPoint = nAchievementPoint * nNumber
    		nMentorPoint = nMentorPoint * nNumber
    		nArenaAward = nArenaAward * nNumber
    		nActivityAward = nActivityAward * nNumber
    	end
    end
    local nIndex = 1
    if nPrestige and nPrestige > 0 then
    	if player.nCurrentPrestige < nPrestige then
    		bSatisfy = false
    	end
		local text = handleItem:Lookup("Text_CoinNum"..nIndex)
		local img = handleItem:Lookup("Image_CoinIcon"..nIndex)
		text.nPrestige = nPrestige
		text:SetText(nPrestige)
		text:Show()
		text.OnItemMouseEnter = function()
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			local nFont = 106
			if this.nPrestige > GetClientPlayer().nCurrentPrestige then
				nFont = 102
			end
			OutputTip(FormatString(g_tStrings.SHOP_NEED_PRESTIGE_TIP, this.nPrestige, nFont, GetClientPlayer().nCurrentPrestige), 300, {x, y, w, h})
		end
		text.OnItemMouseLeave = function()
			HideTip()
		end
		img:FromUITex("ui/Image/UICommon/CommonPanel2.UITex", 99)
		img.nPrestige = nPrestige
		img:Show()
		img.OnItemMouseEnter = text.OnItemMouseEnter
		img.OnMouseLeave = text.OnMouseLeave
		nIndex = nIndex + 1
    end
    
    if nJustice and nJustice > 0 then
    	if player.nJustice < nJustice then
    		bSatisfy = false
    	end
		local text = handleItem:Lookup("Text_CoinNum"..nIndex)
		local img = handleItem:Lookup("Image_CoinIcon"..nIndex)
		text.nJustice = nJustice
		text:SetText(nJustice)
		text:Show()
		text.OnItemMouseEnter = function()
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			local nFont = 106
			if this.nJustice > GetClientPlayer().nJustice then
				nFont = 102
			end
			OutputTip(FormatString(g_tStrings.SHOP_NEED_JUSTICE_TIP, this.nJustice, nFont, GetClientPlayer().nJustice), 300, {x, y, w, h})
		end
		text.OnItemMouseLeave = function()
			HideTip()
		end
		img:FromUITex("ui\\Image\\Common\\Money.UITex", 25)
		img.nJustice = nJustice
		img:Show()
		img.OnItemMouseEnter = text.OnItemMouseEnter
		img.OnMouseLeave = text.OnMouseLeave
		nIndex = nIndex + 1
    end
    
    if nExamPrint and nExamPrint > 0 then
    	if player.nExamPrint < nExamPrint then
    		bSatisfy = false
    	end
		local text = handleItem:Lookup("Text_CoinNum"..nIndex)
		local img = handleItem:Lookup("Image_CoinIcon"..nIndex)
		text.nExamPrint = nExamPrint
		text:SetText(nExamPrint)
		text:Show()
		text.OnItemMouseEnter = function()
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			local nFont = 106
			if this.nExamPrint > GetClientPlayer().nExamPrint then
				nFont = 102
			end
			OutputTip(FormatString(g_tStrings.SHOP_NEED_EXAM_POINT_TIP, this.nExamPrint, nFont, GetClientPlayer().nExamPrint), 300, {x, y, w, h})
		end
		text.OnItemMouseLeave = function()
			HideTip()
		end
		img:FromUITex("ui\\Image\\Common\\Money.UITex", 18)
		img.nExamPrint = nExamPrint
		img:Show()
		img.OnItemMouseEnter = text.OnItemMouseEnter
		img.OnMouseLeave = text.OnMouseLeave
		nIndex = nIndex + 1    
    end
    
    if nArenaAward and nArenaAward > 0 then
    	if player.nArenaAward < nArenaAward then
    		bSatisfy = false
    	end
		local text = handleItem:Lookup("Text_CoinNum"..nIndex)
		local img = handleItem:Lookup("Image_CoinIcon"..nIndex)
		text.nArenaAward = nArenaAward
		text:SetText(nArenaAward)
		text:Show()
		text.OnItemMouseEnter = function()
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			local nFont = 106
			if this.nArenaAward > GetClientPlayer().nArenaAward then
				nFont = 102
			end
			OutputTip(FormatString(g_tStrings.SHOP_NEED_ARENA_AWARD_TIP, this.nArenaAward, nFont, GetClientPlayer().nArenaAward), 300, {x, y, w, h})
		end
		text.OnItemMouseLeave = function()
			HideTip()
		end
		img:FromUITex("ui\\Image\\Common\\Money.UITex", 167)
		img.nArenaAward = nArenaAward
		img:Show()
		img.OnItemMouseEnter = text.OnItemMouseEnter
		img.OnMouseLeave = text.OnMouseLeave
		nIndex = nIndex + 1    
    end
	
    if nActivityAward and nActivityAward > 0 then
    	if player.nActivityAward < nActivityAward then
    		bSatisfy = false
    	end
		local text = handleItem:Lookup("Text_CoinNum"..nIndex)
		local img = handleItem:Lookup("Image_CoinIcon"..nIndex)
		text.nActivityAward = nActivityAward
		text:SetText(nActivityAward)
		text:Show()
		text.OnItemMouseEnter = function()
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			local nFont = 106
			if this.nActivityAward > GetClientPlayer().nActivityAward then
				nFont = 102
			end
			OutputTip(FormatString(g_tStrings.SHOP_NEED_ACTIVITY_AWARD_TIP, this.nActivityAward, nFont, GetClientPlayer().nActivityAward), 300, {x, y, w, h})
		end
		text.OnItemMouseLeave = function()
			HideTip()
		end
		img:FromUITex("ui\\Image\\Common\\Money.UITex", 166)
		img.nActivityAward = nActivityAward
		img:Show()
		img.OnItemMouseEnter = text.OnItemMouseEnter
		img.OnMouseLeave = text.OnMouseLeave
		nIndex = nIndex + 1    
    end
	
    if nAchievementPoint and nAchievementPoint > 0 then
    	if player.GetAchievementPoint() < nAchievementPoint then
    		bSatisfy = false
    	end    
		local text = handleItem:Lookup("Text_CoinNum"..nIndex)
		local img = handleItem:Lookup("Image_CoinIcon"..nIndex)
		text.nAchievementPoint = nAchievementPoint
		text:SetText(nAchievementPoint)
		text:Show()
		text.OnItemMouseEnter = function()
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			local nFont = 106
			if this.nAchievementPoint > GetClientPlayer().GetAchievementPoint() then
				nFont = 102
			end
			OutputTip(FormatString(g_tStrings.SHOP_NEED_ACHIEVEMENT_POINT_TIP, this.nAchievementPoint, nFont, GetClientPlayer().GetAchievementPoint()), 300, {x, y, w, h})
		end
		text.OnItemMouseLeave = function()
			HideTip()
		end
		img:FromUITex("ui/Image/UICommon/LoginSchool.UITex", 24)
		img.nAchievementPoint = nAchievementPoint
		img:Show()
		img.OnItemMouseEnter = text.OnItemMouseEnter
		img.OnMouseLeave = text.OnMouseLeave
		nIndex = nIndex + 1
    end
    
    if nContribution and nContribution > 0 then
    	if player.nContribution < nContribution then
    		bSatisfy = false
    	end    
		local text = handleItem:Lookup("Text_CoinNum"..nIndex)
		local img = handleItem:Lookup("Image_CoinIcon"..nIndex)
		text.nContribution = nContribution
		text:SetText(nContribution)
		text:Show()
		text.OnItemMouseEnter = function()
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			local nFont = 106
			if this.nContribution > GetClientPlayer().nContribution then
				nFont = 102
			end
			OutputTip(FormatString(g_tStrings.SHOP_NEED_CONTRIBUTION_TIP, this.nContribution, nFont, GetClientPlayer().nContribution), 300, {x, y, w, h})
		end
		text.OnItemMouseLeave = function()
			HideTip()
		end
		img:FromUITex("ui/Image/UICommon/CommonPanel2.UITex", 64)
		img.nContribution = nContribution
		img:Show()
		img.OnItemMouseEnter = text.OnItemMouseEnter
		img.OnMouseLeave = text.OnMouseLeave
		nIndex = nIndex + 1 		
    end
    
    if nMentorPoint and nMentorPoint > 0 then
    	if player.nUsableMentorValue < nMentorPoint then
    		bSatisfy = false
    	end    
		local text = handleItem:Lookup("Text_CoinNum"..nIndex)
		local img = handleItem:Lookup("Image_CoinIcon"..nIndex)
		text.nMentorPoint = nMentorPoint
		text:SetText(nMentorPoint)
		text:Show()
		text.OnItemMouseEnter = function()
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			local nFont = 106
			if this.nMentorPoint > GetClientPlayer().nUsableMentorValue then
				nFont = 102
			end
			OutputTip(FormatString(g_tStrings.SHOP_NEED_MENTOR_TIP, this.nMentorPoint, nFont, GetClientPlayer().nUsableMentorValue), 300, {x, y, w, h})
		end
		text.OnItemMouseLeave = function()
			HideTip()
		end
		img:FromUITex("ui/Image/UICommon/CommonPanel2.UITex", 120)
		img.nMentorPoint = nMentorPoint
		img:Show()
		img.OnItemMouseEnter = text.OnItemMouseEnter
		img.OnMouseLeave = text.OnMouseLeave
		nIndex = nIndex + 1
    end
    
    if dwTabType and dwTabType > 0 and dwIndex and dwIndex > 0 and nRequireAmount and nRequireAmount > 0 then
        if player.GetItemAmount(dwTabType, dwIndex) < nRequireAmount then
    		bSatisfy = false
    	end
    	local itemInfo = GetItemInfo(dwTabType, dwIndex)
		local text = handleItem:Lookup("Text_CoinNum"..nIndex)
		local img = handleItem:Lookup("Image_CoinIcon"..nIndex)
		if text and img and itemInfo then
			text.dwTabType = dwTabType
			text.dwIndex = dwIndex
			text.nRequireAmount = nRequireAmount		
			text:SetText(nRequireAmount)
			text:Show()
			text.OnItemMouseEnter = function()
				local x, y = this:GetAbsPos()
				local w, h = this:GetSize()
				local nFont = 106
				if this.nRequireAmount <= GetClientPlayer().GetItemAmount(this.dwTabType, this.dwIndex) then
					nFont = 102
				end
				local itemInfo = GetItemInfo(this.dwTabType, this.dwIndex)
				local szTip = GetFormatText(g_tStrings.SHOP_NEED_ITEM_1, 102)..GetFormatText(this.nRequireAmount, nFont)..
				GetFormatText(g_tStrings.SHOP_NEED_ITEM_2, 102)..GetFormatText(GetItemNameByItemInfo(itemInfo), "102 "..GetItemFontColorByQuality(itemInfo.nQuality, true))..
				GetFormatText(FormatString(g_tStrings.SHOP_NEED_ITEM_3, GetClientPlayer().GetItemAmount(this.dwTabType, this.dwIndex)), 102)
				OutputTip(szTip, 300, {x, y, w, h})
			end
			text.OnItemMouseLeave = function()
				HideTip()
			end
			img:FromIconID(Table_GetItemIconID(itemInfo.nUiId))
			img:Show()
			img.dwTabType = dwTabType
			img.dwIndex = dwIndex
			img.nRequireAmount = nRequireAmount
			img.OnItemMouseEnter = function()
				local x, y = this:GetAbsPos()
				local w, h = this:GetSize()
				OutputItemTip(UI_OBJECT_ITEM_INFO, GLOBAL.CURRENT_ITEM_VERSION, this.dwTabType, this.dwIndex, {x, y, w, h})			
			end
			img.OnMouseLeave = text.OnMouseLeave
			nIndex = nIndex + 1
		end
    end
        
    while nIndex < 3 do
		local text = handleItem:Lookup("Text_CoinNum"..nIndex)
		local img = handleItem:Lookup("Image_CoinIcon"..nIndex)
		if text then
			text:Hide()
		end
		if img then
			img:Hide()
		end
    	nIndex = nIndex + 1
    end
    
    ----------能不能装备----------------
    box.bCanUse = ShopPanel.CanMeUseThisItem(player, item)
    box:EnableObjectEquip(box.bCanUse)
    
    ----------能不能购买----------------	
	local bReputeLimit = false
	if not bByBack then		
		local nReputeLevel = GetShopItemReputeLevel(ShopPanel.nShopID, ShopPanel.nCurrentOpenPage, dwPos)
		local npc = GetNpc(ShopPanel.nNpcID)
		local nPlayerReputeLevel = player.GetReputeLevel(npc.dwForceID)
		if nPlayerReputeLevel < nReputeLevel then
			bReputeLimit = true
		end
		box.aShopInfo = 
			{
				bSatisfy = not bReputeLimit, 
				dwNeedLevel = nReputeLevel, 
				dwNeedForce = npc.dwForceID, 
				dwPlayerReputeLevel = nPlayerReputeLevel,
				bLimit = handleItem.bLimit,
				nLeftCount = nCount,
			}
	end	
	
	if nRequireAchievementRecord and nRequireAchievementRecord > 0 then
		if not box.aShopInfo then
			box.aShopInfo = {}
		end
		box.aShopInfo.nRequireAchievementRecord = nRequireAchievementRecord
		box.aShopInfo.bSatisfyAchievementRecord = nRequireAchievementRecord <= player.GetAchievementRecord()
		if not box.aShopInfo.bSatisfyAchievementRecord then
			bSatisfy = false
		end
	end
	
	if nCampTitle and nCampTitle > 0 then
		if not box.aShopInfo then
			box.aShopInfo = {}
		end
		box.aShopInfo.nCampTitle = nCampTitle
		box.aShopInfo.bSatisfyCampTitle = nCampTitle <= player.nTitle
		if not box.aShopInfo.bSatisfyCampTitle then
			bSatisfy = false
		end
	end
	
	if nRequireCorpsValue and nRequireCorpsValue > 0 then
		if not box.aShopInfo then
			box.aShopInfo = {}
		end
		local player = GetClientPlayer()
		box.aShopInfo.nRequireCorpsValue = nRequireCorpsValue
		box.aShopInfo.dwMaskCorpsNeedToCheck = dwMaskCorpsNeedToCheck
		box.aShopInfo.bSatisfyCorpsValue = false
		
		local dwMask = dwMaskCorpsNeedToCheck % (2 ^ ARENA_TYPE.ARENA_END)
		for i = ARENA_TYPE.ARENA_END - 1, ARENA_TYPE.ARENA_BEGIN, -1 do
			if dwMask >= 2 ^ i then
				local nCorpsLevel = player.GetCorpsLevel(i)
				local nCorpsRoleLevel = player.GetCorpsRoleLevel(i)
				if nRequireCorpsValue <= nCorpsLevel and nRequireCorpsValue <= nCorpsRoleLevel then
					box.aShopInfo.bSatisfyCorpsValue = true
					break
				end
				
				dwMask = dwMask - 2 ^ i;
			end
		end

		if not box.aShopInfo.bSatisfyCorpsValue then
			bSatisfy = false
		end
	end
	
	
	box.bReputeLimit = bReputeLimit
	box.nCount = nCount
	box.nPrice = nPrice
	if not bSatisfy or nCount == 0 or nPrice > player.GetMoney() or bReputeLimit then
		box.bCanBuy = false
    	box:EnableObject(false)
    else
    	box.bCanBuy = true
    	box:EnableObject(true)
    end
    
	if box:IsObjectMouseOver() then
		local x, y = box:GetAbsPos()
		local w, h = box:GetSize()
		OutputItemTip(UI_OBJECT_ITEM_ONLY_ID, item.dwID, nil, nil, {x, y, w, h}, false, "shop", box.aShopInfo)
	end
end

function ShopPanel.CanMeUseThisItem(player, item)
	if item.nGenre ~= ITEM_GENRE.EQUIPMENT then
		return true
	end
	
	local requireAttrib = item.GetRequireAttrib()
	for k, v in pairs(requireAttrib) do
		if not player.SatisfyRequire(v.nID, v.nValue1, v.nValue2) then
			return false
		end
	end
	return true	
end

function ShopPanel.OnLButtonClick()
	local szName = this:GetName()
    if szName == "Btn_Close" then
    	CloseShop()
    elseif szName == "Btn_Repair" then
    	if not Hand_IsEmpty() then
    		Hand_Clear()
    	end	
    	Cursor.Switch(CURSOR.REPAIRE)
    	PlaySound(SOUND.UI_SOUND,g_sound.Button)
    elseif szName == "Btn_RepairAll" then
        if not GetClientPlayer().IsAchievementAcquired(998) then
    		RemoteCallToServer("OnClientAddAchievement", "Shop_Frist_Repair")
        end	
    	RepairItem(ShopPanel.nNpcID, ShopPanel.nShopID)
    elseif szName == "Btn_PagePrev" then
		if ShopPanel.nCurrentOpenPage > 0 then
	    	ShopPanel.nCurrentOpenPage = ShopPanel.nCurrentOpenPage - 1
	    	this:GetParent():Lookup("", "Handle_Sale"):Clear()
	    	QueryShopPageDirectly(ShopPanel.nShopID, ShopPanel.nCurrentOpenPage)
	    	ShopPanel.UpdateShopPageInfo(this:GetParent())
	    	PlaySound(SOUND.UI_SOUND,g_sound.Button)
	    end    	
    elseif szName == "Btn_PageNext" then
		if ShopPanel.nCurrentOpenPage < ShopPanel.nValidPageCount - 1 then
	    	ShopPanel.nCurrentOpenPage = ShopPanel.nCurrentOpenPage + 1
	    	this:GetParent():Lookup("", "Handle_Sale"):Clear()
	    	QueryShopPageDirectly(ShopPanel.nShopID, ShopPanel.nCurrentOpenPage)
	    	ShopPanel.UpdateShopPageInfo(this:GetParent())
	    	PlaySound(SOUND.UI_SOUND,g_sound.Button)
	    end
	end
end

function ShopPanel.UpdateShopPageInfo(page)
	if ShopPanel.nCurrentOpenPage <= 0 then
		page:Lookup("Btn_PagePrev"):Enable(false)
	else
		page:Lookup("Btn_PagePrev"):Enable(true)
	end

	if ShopPanel.nCurrentOpenPage >= ShopPanel.nValidPageCount - 1 then
		page:Lookup("Btn_PageNext"):Enable(false)
	else
		page:Lookup("Btn_PageNext"):Enable(true)
	end
	
	page:Lookup("", "Text_PageNum"):SetText((ShopPanel.nCurrentOpenPage + 1).."/"..ShopPanel.nValidPageCount)
end

function ShopPanel.UpdateMoneyShow(frame, nMoney)
    local handle = frame:Lookup("PageSet_Main/Page_Sale", "")
    ShopPanel.UpdateMoneyShowDetail(handle, "Sale", nMoney)
    handle = frame:Lookup("PageSet_Main/Page_Buy", "")
    ShopPanel.UpdateMoneyShowDetail(handle, "Buy", nMoney)
    if nMoney > 0 then
    	frame:Lookup("PageSet_Main/Page_Sale/Btn_Repair"):Enable(true)
    	frame:Lookup("PageSet_Main/Page_Sale/Btn_RepairAll"):Enable(true)
    else
    	frame:Lookup("PageSet_Main/Page_Sale/Btn_Repair"):Enable(false)
    	frame:Lookup("PageSet_Main/Page_Sale/Btn_RepairAll"):Enable(false)
    end
end

function ShopPanel.UpdateMoneyShowDetail(handle, szWay, nMoney)
	local nGold, nSilver, nCopper = MoneyToGoldSilverAndCopper(nMoney)
	
    local textG = handle:Lookup("Text_Gold"..szWay)
    local textS = handle:Lookup("Text_Silver"..szWay)
    local textC = handle:Lookup("Text_Copper"..szWay)
    local imageG = handle:Lookup("Image_Gold"..szWay)
    local imageS = handle:Lookup("Image_Silver"..szWay)
    local imageC = handle:Lookup("Image_Copper"..szWay)
    textG:SetText(nGold)
    textS:SetText(nSilver)
    textC:SetText(nCopper)
    imageG:Show()
    imageS:Show()
    imageC:Show()
    if nGold == 0 then
    	textG:SetText("")
    	imageG:Hide()
    	if nSilver == 0 then
    		textS:SetText("")
    		imageS:Hide()
    	end
    end    
end

function ShopPanel.OnItemLButtonDragEnd()
	if Hand_IsEmpty() then
		return
	end
		----出售手中的物品
	local box, nhandCount = Hand_Get()
	local player = GetClientPlayer()
	
	local nObjectType = box:GetObjectType()
	if nObjectType ~= UI_OBJECT_ITEM then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_SHOP_CANNOT_SALE_ITEM_NOT_IN_BAG)
		return	
	end
	local _, dwBox, dwX = box:GetObjectData()
	if not IsObjectFromBag(dwBox) then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_SHOP_CANNOT_SALE_ITEM_NOT_IN_BAG)
		return
	end
	
	local item = GetPlayerItem(player, dwBox, dwX)
	if not item then
		return
	end
	
	local nCount = 1
	if item.nGenre == ITEM_GENRE.EQUIPMENT then
		if item.nSub == EQUIPMENT_SUB.ARROW then --远程武器
			nCount = item.nCurrentDurability
		end
	else
		if item.bCanStack then
			nCount = item.nStackNum
		end
	end
	if nhandCount and nhandCount ~= nCount then	--手里面是拆分后没有放入背包的物品
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_SHOP_ONLY_SOLD_GLOUP)
		return
	end
		
	if not GetClientPlayer().IsAchievementAcquired(997) then
        RemoteCallToServer("OnClientAddAchievement", "Shop_Frist_Sell")
    end
    
    if item.nQuality >= 3 and item.bCanTrade then
		local msg =
		{
			szMessage = FormatLinkString(g_tStrings.SELL_ITEM_SURE, "font=162", GetFormatText("["..GetItemNameByItem(item).."]", 
				"166"..GetItemFontColorByQuality(item.nQuality, true))), 
			bRichText = true,
			szName = "SellItemSure",
			fnAutoClose = function() return not IsShopOpened() end,
			{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() SellItem(ShopPanel.nNpcID, ShopPanel.nShopID, dwBox, dwX, nCount) Hand_Clear() end},
			{szOption = g_tStrings.STR_HOTKEY_CANCEL}
		}
		MessageBox(msg)    	
    else
		SellItem(ShopPanel.nNpcID, ShopPanel.nShopID, dwBox, dwX, nCount)
		Hand_Clear()
	end
end

function ShopPanel.OnItemLButtonDown()
	if IsCtrlKeyDown() and this:GetName() == "Box_Item" then
		local _, dwID = this:GetObjectData()
		if IsGMPanelReceiveItem() then
			GMPanel_LinkItem(dwID)
		else		
			EditBox_AppendLinkItem(dwID)
		end
	end
end

function ShopPanel.OnItemLButtonClick()
	ShopPanel.OnItemLButtonDragEnd()
end

function ShopPanel.OnItemRButtonDown()
	this:SetObjectPressed(1)
end

function ShopPanel.OnItemRButtonUp()
	this:SetObjectPressed(0)
end

function ShopPanel.BuyItem(nNpcID, nShopID, nCurrentOpenPage, nIndex, nNumber, bCanBuy)
	if CheckHaveLocked(SAFE_LOCK_EFFECT_TYPE.SHOP, "buy") then
		return
	end
	
    local dwItemID = GetShopItemID(nShopID, nCurrentOpenPage, nIndex)
    local item = GetItem(dwItemID)
    if not item then
    	return
    end	
    if item.nQuality >= 3 and bCanBuy then
        --[[
		local msg =
		{
			szMessage = FormatLinkString(g_tStrings.BUY_ITEM_SURE, "font=162", GetFormatText("["..GetItemNameByItem(item).."]", 
				"166"..GetItemFontColorByQuality(item.nQuality, true))), 
			bRichText = true,
			szName = "BuyItemSure",
			fnAutoClose = function() return not IsShopOpened() end,
			{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() BuyItem(nNpcID, nShopID, nCurrentOpenPage, nIndex, nNumber) end},
			{szOption = g_tStrings.STR_HOTKEY_CANCEL}
		}
		MessageBox(msg)    	
        --]]
        OpenItemBuySure(nNpcID, nShopID, nCurrentOpenPage, nIndex, nNumber)
    else
    	BuyItem(nNpcID, nShopID, nCurrentOpenPage, nIndex, nNumber)
    end
end

function ShopPanel.OnItemRButtonClick()
	if this:IsEmpty() then
		return
	end
	
	local pageSet = Station.Lookup("Normal/ShopPanel/PageSet_Main")	
	if pageSet:GetActivePageIndex() == 1 then
		if CheckHaveLocked(SAFE_LOCK_EFFECT_TYPE.SHOP, "回购") then
			return
		end
	
		BuySoldListItem(ShopPanel.nNpcID, ShopPanel.nShopID, this:GetUserData())
		return
	end

    local dwItemID = GetShopItemID(ShopPanel.nShopID, ShopPanel.nCurrentOpenPage, this:GetUserData())
    local item = GetItem(dwItemID)
    if not item then
    	return
    end
    
    local nMaxCount = GetShopItemCount(ShopPanel.nShopID, ShopPanel.nCurrentOpenPage, this:GetUserData())
    if not nMaxCount then
    	return
    end
    
    if nMaxCount < 0 then
    	if item.bCanStack and item.nMaxStackNum > 1 then
    		nMaxCount = item.nMaxStackNum
    	else
    		nMaxCount = 1
    	end
    elseif nMaxCount == 0 then
    	OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_SHOP_ITEM_WAS_SALE_OUT)
    	return
    else
    	if item.bCanStack and item.nMaxStackNum > 1 then
			if nMaxCount > item.nMaxStackNum then
				nMaxCount = item.nMaxStackNum
			end    	
    	else
    		nMaxCount = 1
    	end
    end
	if IsShiftKeyDown() and (item.nGenre ~= ITEM_GENRE.EQUIPMENT or item.nSub == EQUIPMENT_SUB.ARROW) and nMaxCount > 1 then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		
		local nIndex = this:GetUserData()
		local bCanBuy = this.bCanBuy
		local nShopID, nCurrentOpenPage, nNpcID = ShopPanel.nShopID, ShopPanel.nCurrentOpenPage, ShopPanel.nNpcID
		local ActionSure = function(nNumber)
    		if not GetClientPlayer().IsAchievementAcquired(996) then
    			RemoteCallToServer("OnClientAddAchievement", "Shop_Frist_Buy")
    		end	
			ShopPanel.BuyItem(nNpcID, nShopID, nCurrentOpenPage, nIndex, nNumber, bCanBuy)
		end
		local AutoClose = function()
			return not IsShopOpened()
		end
		
		GetUserInputNumber(nMaxCount, nMaxCount, {x, y, x + w, y + h}, ActionSure, nil, AutoClose)
	else
		if this.bGroup then
		    if not GetClientPlayer().IsAchievementAcquired(996) then
    			RemoteCallToServer("OnClientAddAchievement", "Shop_Frist_Buy")
    		end	
			ShopPanel.BuyItem(ShopPanel.nNpcID, ShopPanel.nShopID, ShopPanel.nCurrentOpenPage, this:GetUserData(), item.nCurrentDurability, this.bCanBuy)
		else
		    if not GetClientPlayer().IsAchievementAcquired(996) then
    			RemoteCallToServer("OnClientAddAchievement", "Shop_Frist_Buy")
    		end	
			ShopPanel.BuyItem(ShopPanel.nNpcID, ShopPanel.nShopID, ShopPanel.nCurrentOpenPage, this:GetUserData(), 1, this.bCanBuy)
		end
	end
end

function ShopPanel.OnItemRefreshTip()
	return ShopPanel.OnItemMouseEnter()
end

function ShopPanel.OnItemMouseEnter()
	if this:GetType() == "Box" then
		if not IsCursorInExclusiveMode() then
			if this:GetParent():GetParent():GetName() == "Handle_Sale" then
				if this:IsObjectEnable() and not this:IsObjectCoolDown() then
					Cursor.Switch(CURSOR.BUYBACK)
				else
					Cursor.Switch(CURSOR.UNABLEBUYBACK)
				end
			else
				if this:IsObjectEnable() and not this:IsObjectCoolDown() then
					Cursor.Switch(CURSOR.BUYBACK)
				else
					Cursor.Switch(CURSOR.UNABLEBUYBACK)
				end
			end
		end
	
		this:SetObjectMouseOver(1)
		if not this:IsEmpty() then
			local _, dwID = this:GetObjectData()
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			OutputItemTip(UI_OBJECT_ITEM_ONLY_ID, dwID, nil, nil, {x, y, w, h}, false, "shop", this.aShopInfo)
		end
	end
end

function ShopPanel.OnItemMouseLeave()
	HideTip()
	if this:GetType() == "Box" then
		if not IsCursorInExclusiveMode() then
			Cursor.Switch(CURSOR.NORMAL)
		end
		this:SetObjectMouseOver(0)
	end
end

function OpenShop(nShopID, nShopType, nValidPageCount, bCanRepair, nNpcID, bDisableSound)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end

	local player = GetClientPlayer()
	if not player or player.nMoveState == MOVE_STATE.ON_DEATH then
		return
	end

	ShopPanel.nShopID = nShopID
	ShopPanel.nShopType = nShopType
	ShopPanel.nValidPageCount = nValidPageCount
	ShopPanel.nNpcID = nNpcID
	ShopPanel.bCanRepair = bCanRepair
	ShopPanel.nCurrentOpenPage = 0
	
	if not IsShopOpened() then
		Wnd.OpenWindow("ShopPanel")
		OpenAllBagPanel(true)
	end
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
	
    QueryShopPageDirectly(ShopPanel.nShopID, ShopPanel.nCurrentOpenPage)
end

function CloseShop(bDisableSound)
	if IsShopOpened() then
		CloseAllBagPanel(true)
	end
	Wnd.CloseWindow("ShopPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function IsShopOpened()
	local frame = Station.Lookup("Normal/ShopPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function SellItemToShop(nBoxIndex, nBoxItemIndex, nCount)
	if IsShopOpened() and ShopPanel then
		if CheckHaveLocked(SAFE_LOCK_EFFECT_TYPE.SHOP, "sell") then
			return
		end
	
	    if not GetClientPlayer().IsAchievementAcquired(997) then
    			RemoteCallToServer("OnClientAddAchievement", "Shop_Frist_Sell")
        end
        
        local item = GetClientPlayer().GetItem(nBoxIndex, nBoxItemIndex)
        if item.nQuality >= 3 and item.bCanTrade then
			local msg =
			{
				szMessage = FormatLinkString(g_tStrings.SELL_ITEM_SURE, "font=162", GetFormatText("["..GetItemNameByItem(item).."]", 
					"166"..GetItemFontColorByQuality(item.nQuality, true))), 
				bRichText = true,
				szName = "SellItemSure",
				fnAutoClose = function() return not IsShopOpened() end,
				{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() SellItem(ShopPanel.nNpcID, ShopPanel.nShopID, nBoxIndex, nBoxItemIndex, nCount) end},
				{szOption = g_tStrings.STR_HOTKEY_CANCEL}
			}
			MessageBox(msg)
 		else
			SellItem(ShopPanel.nNpcID, ShopPanel.nShopID, nBoxIndex, nBoxItemIndex, nCount)
		end
	end
end

function ShopRepairItem(nBoxIndex, nBoxItemIndex)
	if IsShopOpened() and ShopPanel then
	    if not GetClientPlayer().IsAchievementAcquired(998) then
    		RemoteCallToServer("OnClientAddAchievement", "Shop_Frist_Repair")
        end	
		RepairItem(ShopPanel.nNpcID, ShopPanel.nShopID, nBoxIndex, nBoxItemIndex)
	end
end

function ShopPanel_GetItemBox(dwBox, dwX, bEvenUnVisible)
	if dwBox == INVENTORY_INDEX.SOLD_LIST then
		local frame = Station.Lookup("Normal/ShopPanel")
		if frame and (frame:IsVisible() or bEvenUnVisible) then
		    local handle = this:Lookup("PageSet_Main/Page_Buy", "Handle_Buy")
			--TODO
			return nil			
		end
	end
	return nil
end

local SelItemOld = SellItem
function SellItem(...)
	if IsBagInSort() or IsBankInSort() then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_CANNOT_SELL_ITEM_INSORT)
		return
	end
	SelItemOld(...)
end

local RepairItemOld = RepairItem
function RepairItem(...)
	if IsBagInSort() or IsBankInSort() then
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_CANNOT_REPAIRE_ITEM_INSORT)
		return
	end
	RepairItemOld(...)
end

local dwQueryTime = nil
QueryShopPageDirectly = QueryShopPage
function QueryShopPage(...)
	if not dwQueryTime or GetTime() - dwQueryTime > 10000 then
		QueryShopPageDirectly(...)
	end
end
