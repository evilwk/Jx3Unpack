local INI_FILE_PATH = "UI/Config/Default/AuctionItem.ini"
local MAX_SELL_INFO_CACHE_SIZE = 60
local PRICE_LIMITED = PackMoney(800000, 0, 0)
local NO_BID_PRICE  = PackMoney(9000000, 0, 0)
local REQUEST_DATA_COUTN  = 50
local EXPAND_ITEM_TYPE = {}
local tInfoRequesting = {}

local tSearchInfoDefault =
{
	["Name"]     = g_tAuctionString.STR_ITEM_NAME,
	["Level"]    = {"", ""},
	["Quality"]  = g_tAuctionString.STR_ITEM_QUALITY,
	["Status"]   = g_tAuctionString.STR_ITEM_STATUS,
	["MaxPrice"] = {"", "" ,""},
}
local tSearchInfo = clone(tSearchInfoDefault)

local tItemDataInfo =
{
	["Search"] = {nStart = 1, nCurCount = 0, nTotCount = 0, nSortType = AUCTION_ORDER_TYPE.QUALITY, bDesc = 1, bUnitPrice=false, nRequestID = 0, szCheckName = "CheckBox_RName"},
	["Sell"]   = {nStart = 1, nCurCount = 0, nTotCount = 0, nSortType = AUCTION_ORDER_TYPE.QUALITY, bDesc = 1, bUnitPrice=false, nRequestID = 1, szCheckName = "CheckBox_AName"},
	["Bid"]    = {nStart = 1, nCurCount = 0, nTotCount = 0, nSortType = AUCTION_ORDER_TYPE.LEFT_TIME, bDesc = 1, bUnitPrice=false, nRequestID = 2, szCheckName = "CheckBox_BRemainTime"},
}

local tItemWidgetInfo =
{
	["Search"] =
	{
		Scroll="Scroll_Result", BtnUp="Btn_RUp", BtnDown="Btn_RDown", Box="Box_Box", Text="Text_BoxName", Level="Text_BoxLevel", Saler="Text_BoxSaler", Time="Text_BoxRemainTime",
		aBidText={"Text_BidGold", "Text_BidSilver", "Text_BidCopper", "Text_MyBid"},
		aBuyText={"Text_PrGold",  "Text_PrSilver",  "Text_PrCopper",  "Text_UnitPrice"},
		aBuyImg ={"Image_PrGold", "Image_PrSilver", "Image_PrCopper"},
		tCheck =
		{
			["CheckBox_RName"]      = {imgUp = "Image_RNameUp",     imgDown = "Image_RNameDown",     nSortType = AUCTION_ORDER_TYPE.QUALITY},
			["CheckBox_RLevel"]     = {imgUp = "Image_RLevelUp",    imgDown = "Image_RLevelDown",    nSortType = AUCTION_ORDER_TYPE.LEVEL},
			["CheckBox_RemainTime"] = {imgUp = "Image_ReNameUp",    imgDown = "Image_ReNameDown",    nSortType = AUCTION_ORDER_TYPE.LEFT_TIME},
			["CheckBox_Bid"]        = {imgUp = "Image_BidNameUp",   imgDown = "Image_BidNameDown",   nSortType = AUCTION_ORDER_TYPE.PRICE},
			["CheckBox_Price"]      = {imgUp = "Image_PriceNameUp", imgDown = "Image_PriceNameDown", nSortType = AUCTION_ORDER_TYPE.BUY_IT_NOW_PRICE},
		}
	},
	["Bid"] =
	{
		Scroll="Scroll_Bid", BtnUp="Btn_BUp", BtnDown="Btn_BDown", Box="Box_BidBox", Text="Text_BidBoxName", Level="Text_BidBoxLevel", Saler="Text_BidBoxSaler", Time="Text_BidBoxRemainTime",
		aBidText={"Text_BidBidGold", "Text_BidBidSilver", "Text_BidBidCopper", "Text_BidMyBid"},
		aBuyText={"Text_BidPrGold",  "Text_BidPrSilver",  "Text_BidPrCopper",  "Text_BUnitPrice"},
		aBuyImg ={"Image_BidPrGold", "Image_BidPrSilver", "Image_BidPrCopper"},
		tCheck =
		{
			["CheckBox_BName"]       = {imgUp = "Image_BNameUp",      imgDown = "Image_BNameDown",      nSortType = AUCTION_ORDER_TYPE.QUALITY},
			["CheckBox_BLevel"]      = {imgUp = "Image_BLevelUp",     imgDown = "Image_BLevelDown",     nSortType = AUCTION_ORDER_TYPE.LEVEL},
			["CheckBox_BRemainTime"] = {imgUp = "Image_BReNameUp",    imgDown = "Image_BReNameDown",    nSortType = AUCTION_ORDER_TYPE.LEFT_TIME},
			["CheckBox_BBid"]        = {imgUp = "Image_BBidNameUp",   imgDown = "Image_BBidNameDown",   nSortType = AUCTION_ORDER_TYPE.PRICE},
			["CheckBox_BPrice"]      = {imgUp = "Image_BPriceNameUp", imgDown = "Image_BPriceNameDown", nSortType = AUCTION_ORDER_TYPE.BUY_IT_NOW_PRICE},
		}
	},
	["Sell"] =
	{
		Scroll="Scroll_Auction", BtnUp="Btn_AUp", BtnDown="Btn_ADown", Box="Box_ABox", Text="Text_ABoxName", Level="Text_ABoxLevel", Saler="Text_ABoxSaler", Time="Text_ABoxRemainTime",
		aBidText={"Text_ABidGold", "Text_ABidSilver", "Text_ABidCopper", "Text_AMyBid",},
		aBuyText={"Text_APrGold",  "Text_APrSilver",  "Text_APrCopper",  "Text_AUnitPrice",},
		aBuyImg ={"Image_APrGold", "Image_APrSilver", "Image_APrCopper"},
		tCheck =
		{
			["CheckBox_AName"]       = {imgUp = "Image_ANameUp",      imgDown = "Image_ANameDown",      nSortType = AUCTION_ORDER_TYPE.QUALITY},
			["CheckBox_ALevel"]      = {imgUp = "Image_ALevelUp",     imgDown = "Image_ALevelDown",     nSortType = AUCTION_ORDER_TYPE.LEVEL},
			["CheckBox_ARemainTime"] = {imgUp = "Image_AReNameUp",    imgDown = "Image_AReNameDown",    nSortType = AUCTION_ORDER_TYPE.LEFT_TIME},
			["CheckBox_ABid"]        = {imgUp = "Image_ABidNameUp",   imgDown = "Image_ABidNameDown",   nSortType = AUCTION_ORDER_TYPE.PRICE},
			["CheckBox_APrice"]      = {imgUp = "Image_APriceNameUp", imgDown = "Image_APriceNameDown", nSortType = AUCTION_ORDER_TYPE.BUY_IT_NOW_PRICE},
		}
	}
}

local TabEditBusiness = 
{
	[1] = {"Edit_ItemName", "Wnd_Search"},
	[2] = {"Edit_Level1", "Wnd_Search"},
	[3] = {"Edit_Level2", "Wnd_Search"},
	[4] = {"Edit_HGold", "Wnd_Search"},
	[5] = {"Edit_HSilver", "Wnd_Search"},
	[6] = {"Edit_HCopper", "Wnd_Search"},
	[7] = {"Edit_BidGold", "Wnd_Result2"},
	[8] = {"Edit_BidSilver", "Wnd_Result2"},
	[9] = {"Edit_BidCopper", "Wnd_Result2"},
}

local TabEditSale = 
{         
	[1] = {"Edit_OPGold", "Wnd_Sale"},
	[2] = {"Edit_OPSilver", "Wnd_Sale"},
	[3] = {"Edit_OPCopper", "Wnd_Sale"},
	[4] = {"Edit_PGold", "Wnd_Sale"},
	[5] = {"Edit_PSilver", "Wnd_Sale"},
	[6] = {"Edit_PCopper", "Wnd_Sale"},
}   

AuctionPanel =
{
	tItemSellInfoCache = {},
}
RegisterCustomData("Account/AuctionPanel.tItemSellInfoCache")

local function FormatMoney(handle, bText)
	local szMoney = 0
	if bText then
		szMoney = handle
	else
		szMoney = handle:GetText()
	end
	if not szMoney or szMoney == "" then
		szMoney = 0
	end
	return tonumber(szMoney)
end

function AuctionPanel.OnFrameCreate()
	this:RegisterEvent("AUCTION_LOOKUP_RESPOND")
	this:RegisterEvent("AUCTION_SELL_RESPOND")
	this:RegisterEvent("AUCTION_BID_RESPOND")
	this:RegisterEvent("AUCTION_CANCEL_RESPOND")
	this:RegisterEvent("MONEY_UPDATE")

	AuctionPanel.Init(this)

	InitFrameAutoPosInfo(this, 1, nil, nil, function() AuctionPanel.Close(true) end)
	
	BlackMarket.OnFrameCreate()
end

function AuctionPanel.OnFrameBreathe()
	local player = GetClientPlayer()
	if not player or player.nMoveState == MOVE_STATE.ON_DEATH then
		AuctionPanel.Close()
		return
	end

    if AuctionPanel.dwTargetType == TARGET.NPC then
		local npc = GetNpc(AuctionPanel.dwTargetID)
		if not npc or not npc.CanDialog(player) then
			AuctionPanel.Close()
			return
		end
	end
	BlackMarket.OnFrameBreathe()
end

function AuctionPanel.OnEvent(szEvent)
	BlackMarket.OnEvent(szEvent)
	if szEvent == "AUCTION_LOOKUP_RESPOND" then
		local szDataType = ""
		for k, v in pairs(tItemDataInfo) do
			if v.nRequestID == arg1 then
				szDataType = k
				break
			end
		end

		if szDataType == "" then
			Log("KLUA[ERROR] ui/Config/Default/AuctionPanel.lua arg1 is error!!\n")
			return
		end
		AuctionPanel.UnLockOperate(this, szDataType)
		if arg0 == AUCTION_RESPOND_CODE.SUCCEED then
			local AuctionClient = GetAuctionClient()
			local nCounts, tItemInfo = AuctionClient.GetLookupResult(arg1)
			tItemDataInfo[szDataType].nTotCount = nCounts
			tItemDataInfo[szDataType].nCurCount = #tItemInfo
			AuctionPanel.UpdateItemList(this, szDataType, tItemInfo)
		elseif arg0 == AUCTION_RESPOND_CODE.SERVER_BUSY then
			OutputMessage("MSG_ANNOUNCE_RED", g_tAuctionString.STR_DATA_APPLY_SYSTEM_BUSY)
		end
	elseif szEvent == "AUCTION_SELL_RESPOND" then
		if arg0 == AUCTION_RESPOND_CODE.SUCCEED then
			local hBox = this:Lookup("PageSet_Totle/Page_Auction/Wnd_Sale", "Box_Item")
			local tBidPrice = MoneyOptDiv(hBox.tBidPrice, hBox.nCount)
			local tBuyPrice = MoneyOptDiv(hBox.tBuyPrice, hBox.nCount)
			if MoneyOptCmp(hBox.tBuyPrice, NO_BID_PRICE) == 0 then
				tBuyPrice = FormatMoneyTab(0)
			end
			
			AuctionPanel.UpdateItemSellInfo(hBox.szName, tBidPrice, tBuyPrice, hBox.szTime)
			
			AuctionPanel.ClearBox(hBox)

			AuctionPanel.UpdateSaleInfo(this, true)
			RemoveUILockItem("Auction")

			local tInfo = tItemDataInfo["Sell"]
			AuctionPanel.ApplyLookup(this, "Sell", tInfo.nSortType, GetClientPlayer().dwID, 1, tInfo.bDesc)

			OutputMessage("MSG_SYS", g_tAuctionString.STR_AUCTION_SELL_SUCCESS)
		else
			OutputMessage("MSG_SYS", g_tAuctionString.tAuctionRespond[arg0])
		end
	elseif szEvent == "AUCTION_BID_RESPOND" then
		AuctionPanel.UnLockOperate(this, tInfoRequesting.szRequestType)
		if arg0 == AUCTION_RESPOND_CODE.SUCCEED then
			AuctionPanel.UpateShowInfo(this)
			OutputMessage("MSG_SYS", g_tAuctionString.STR_AUCTION_BID_SUCCESS)
		else
			local szType = tInfoRequesting.szRequestType
			local tInfo = tItemDataInfo[szType]
			local szKey  = ""
			if szType == "Bid" then
				szKey = GetClientPlayer().dwID
			end
			AuctionPanel.ApplyLookup(this, szType, tInfo.nSortType, szKey, 1, tInfo.bDesc)
			tInfoRequesting = {}

			OutputMessage("MSG_SYS", g_tAuctionString.tAuctionRespond[arg0])
		end
	elseif szEvent == "AUCTION_CANCEL_RESPOND" then
		if arg0 == AUCTION_RESPOND_CODE.SUCCEED then
			AuctionPanel.UpateShowInfo(this)
			OutputMessage("MSG_SYS", g_tAuctionString.STR_AUCTION_CANCEL_SUCCESS)
		else
			OutputMessage("MSG_SYS", g_tAuctionString.tAuctionRespond[arg0])
		end

	elseif szEvent == "MONEY_UPDATE" then
		AuctionPanel.UpdateMoney(this)

	elseif szEvent == "CUSTOM_DATA_LOADED" then
		if arg0 == "Account" then
			local nSize = #AuctionPanel.tItemSellInfoCache
			while nSize > MAX_SELL_INFO_CACHE_SIZE do
				table.remove(AuctionPanel.tItemSellInfoCache)
				nSize = nSize - 1
			end
		end
	end
end

function AuctionPanel.Init(frame)
	frame.bIniting = true
	AuctionPanel.UpdateMoney(frame)
	AuctionPanel.InitBusinessInfo(frame)
	AuctionPanel.UpdateSaleInfo(frame, true)

	local hCheckBox = frame:Lookup("PageSet_Totle/Page_State/Wnd_Bid/CheckBox_PerValueBid")
	hCheckBox:Check(tItemDataInfo["Bid"].bUnitPrice)
	hCheckBox = frame:Lookup("PageSet_Totle/Page_Auction/Wnd_Auction/CheckBox_PerValueAuction")
	hCheckBox:Check(tItemDataInfo["Sell"].bUnitPrice)
	
	local function ShowSortImage(hWnd, szType)
		for k ,v in pairs(tItemWidgetInfo[szType].tCheck) do
			local hCheckBox = hWnd:Lookup(k)
			local imgDown = hCheckBox:Lookup("", v.imgDown)
			local imgUp = hCheckBox:Lookup("", v.imgUp)
			imgUp:Hide()
			imgDown:Hide()	
			if k == tItemDataInfo[szType].szCheckName then
				if tItemDataInfo[szType].bDesc == 1 then
					imgDown:Show()
				else
					imgUp:Show()
				end
			end
		end
	end
	
	local hWndRes = frame:Lookup("PageSet_Totle/Page_Business/Wnd_Result2")
	local hWndBid = frame:Lookup("PageSet_Totle/Page_State/Wnd_Bid")
	local hWndAct = frame:Lookup("PageSet_Totle/Page_Auction/Wnd_Auction")

	ShowSortImage(hWndRes, "Search")
	ShowSortImage(hWndBid, "Bid")
	ShowSortImage(hWndAct, "Sell")
	
		
	do
		RegisterScrollEvent("AuctionPanel")
		
		UnRegisterScrollAllControl("AuctionPanel")
			
		local szFramePath = "Normal/AuctionPanel"
		local szWndPath = "PageSet_Totle/Page_Contraband/Wnd_Contraband"
		RegisterScrollControl(
			szFramePath, 
			szWndPath.."/Btn_CUp", szWndPath.."/Btn_CDown", 
			szWndPath.."/ScrollBar_C", 
			{szWndPath, "Handle_CList"})
	end
	frame.bIniting = false
end

function AuctionPanel.InitBusinessInfo(frame)
	tItemDataInfo["Search"].nStart = 1
	tItemDataInfo["Search"].nCurCount = 0
	tItemDataInfo["Search"].nTotCount = 0

	local hWndRes = frame:Lookup("PageSet_Totle/Page_Business/Wnd_Result2")
	AuctionPanel.OnItemDataInfoUpdate(hWndRes, "Search")

	AuctionPanel.InitSearchInfo(frame, tSearchInfo)
	AuctionPanel.UpdateItemTypeList(frame)
	AuctionPanel.UpdateSelectedInfo(frame, "Search", true)

	local hList = hWndRes:Lookup("", "Handle_List")
	AuctionPanel.OnUpdateItemList(hList, "Search", true)

	hWndRes:Lookup("CheckBox_PerValue"):Check(tItemDataInfo["Search"].bUnitPrice)
end

function AuctionPanel.InitSearchInfo(frame, tInfo)
	frame.bIniting = true
	local hWndSch = frame:Lookup("PageSet_Totle/Page_Business/Wnd_Search")

	hWndSch:Lookup("Edit_ItemName"):SetText(tInfo["Name"])
	hWndSch:Lookup("Edit_Level1"):SetText(tInfo["Level"][1])
	hWndSch:Lookup("Edit_Level2"):SetText(tInfo["Level"][2])

	hWndSch:Lookup("Edit_HGold"):SetText(tInfo["MaxPrice"][1])
	hWndSch:Lookup("Edit_HSilver"):SetText(tInfo["MaxPrice"][2])
	hWndSch:Lookup("Edit_HCopper"):SetText(tInfo["MaxPrice"][3])

	hWndSch:Lookup("", "Text_Quality"):SetText(tInfo["Quality"])
	hWndSch:Lookup("", "Text_ItemState"):SetText(tInfo["Status"])
	frame.bIniting = false
end

function AuctionPanel.UpdateItemList(frame, szDataType, tItemInfo)
	if not tItemInfo then
		tItemInfo = {}
	end

	local player = GetClientPlayer()
	local hList, szItem = nil, nil
	if szDataType == "Search" then
		hList = frame:Lookup("PageSet_Totle/Page_Business/Wnd_Result2", "Handle_List")
		szItem = "Handle_ItemList"
	elseif szDataType == "Bid" then
		hList = frame:Lookup("PageSet_Totle/Page_State/Wnd_Bid", "Handle_BidList")
		szItem = "Handle_BidItemList"
	elseif szDataType == "Sell" then
		hList = frame:Lookup("PageSet_Totle/Page_Auction/Wnd_Auction", "Handle_AList")
		szItem = "Handle_AItemList"
	end

	hList:Clear()
	for k, v in pairs(tItemInfo) do
		if v["Item"] then
			local hItem = hList:AppendItemFromIni(INI_FILE_PATH, szItem)
			AuctionPanel.SetSaleInfo(hItem, szDataType, v)
		else
			Log("KLUA[ERROR] ui/Config/Default/AuctionPanel.lua UpdateItemList item is nil!!\n")
		end
	end
	AuctionPanel.OnUpdateItemList(hList, szDataType, true)
	AuctionPanel.UpdateItemPriceInfo(hList, szDataType)
	AuctionPanel.UpdateSelectedInfo(frame, szDataType)

	local hWnd = hList:GetParent():GetParent()
	AuctionPanel.OnItemDataInfoUpdate(hWnd, szDataType)
end

function AuctionPanel.OnUpdateItemList(hList, szDataType, bDefault)
	hList:FormatAllItemPos()
	local tInfo = tItemWidgetInfo[szDataType]
	local hWnd = hList:GetParent():GetParent()
	local scroll = hWnd:Lookup(tInfo.Scroll)
	local w, h = hList:GetSize()
	local wAll, hAll = hList:GetAllItemSize()
	local nStepCount = math.ceil((hAll - h) / 10)

	scroll:SetStepCount(nStepCount)
	if nStepCount > 0 then
		scroll:Show()
		hWnd:Lookup(tInfo.BtnUp):Show()
		hWnd:Lookup(tInfo.BtnDown):Show()
	else
		scroll:Hide()
		hWnd:Lookup(tInfo.BtnUp):Hide()
		hWnd:Lookup(tInfo.BtnDown):Hide()
	end
	if bStart then
		scroll:SetScrollPos(0)
	end
end

function AuctionPanel.UpateShowInfo(frame)
	local hList = nil
	local szType = tInfoRequesting.szRequestType
	if szType == "Search" then
		hList = frame:Lookup("PageSet_Totle/Page_Business/Wnd_Result2", "Handle_List")
	elseif szType == "Bid" then
		hList = frame:Lookup("PageSet_Totle/Page_State/Wnd_Bid", "Handle_BidList")
	elseif szType == "Sell" then
		hList = frame:Lookup("PageSet_Totle/Page_Auction/Wnd_Auction", "Handle_AList")
	end

	local hItem, nDelID = nil, nil
	local nCount = hList:GetItemCount()
	for i = 0, nCount - 1, 1 do
		local hI = hList:Lookup(i)
		if hI.nSaleID == tInfoRequesting.nSaleID then
			hItem = hI
			nDelID = i
			break
		end
	end
	if not hItem then
		return
	end

	local bDefault = false
	if szType == "Search" and MoneyOptCmp(tInfoRequesting.tPrice, hItem.tBuyPrice) < 0 then
		hItem.tBidPrice = tInfoRequesting.tPrice
		hItem.szBidderName = GetClientPlayer().szName
	else
		hList:RemoveItem(nDelID)
		hItem = hList:Lookup(nDelID)
		if not hItem then
			hItem = hList:Lookup(nDelID - 1)
			bDefault = true
	 	end
	 	if hItem then
	 		AuctionPanel.Selected(hItem)
	 		bDefault = true
	 	end
	 	tItemDataInfo[szType].nCurCount = tItemDataInfo[szType].nCurCount - 1
	 	tItemDataInfo[szType].nTotCount = tItemDataInfo[szType].nTotCount - 1
	end

	AuctionPanel.OnUpdateItemList(hList, szType)
	AuctionPanel.UpdateSelectedInfo(frame, szType, bDefault)
	AuctionPanel.OnItemDataInfoUpdate(hList:GetParent():GetParent(), szType)
	AuctionPanel.UpdateItemPriceInfo(hList, szType)

	tInfoRequesting = {}
end

function AuctionPanel.SetSaleInfo(hItem, szDataType, tItemData)
	local player = GetClientPlayer()
	local tInfo = tItemWidgetInfo[szDataType]
	local item = tItemData["Item"]

	local nIconID = Table_GetItemIconID(item.nUiId)
	local hBox = hItem:Lookup(tInfo.Box)
	local hTextName = hItem:Lookup(tInfo.Text)
	local hTextSaler = hItem:Lookup(tInfo.Saler)

	hBox.nItemID = item.dwID
	hItem.nItemID = item.dwID
	hItem.nSaleID = tItemData["ID"]
	hItem.nCRC = tItemData["CRC"]
	hItem.szItemName = GetItemNameByItem(item)
	hItem.szBidderName = tItemData["BidderName"] or ""
	hItem.tBidPrice = tItemData["Price"]
	hItem.tBuyPrice = tItemData["BuyItNowPrice"]
	
	if MoneyOptCmp(hItem.tBuyPrice, 0) == 0 then
		hItem.tBuyPrice = NO_BID_PRICE
	end
	local nCount = 1
	if item.nGenre == ITEM_GENRE.EQUIPMENT then
		if item.nSub == EQUIPMENT_SUB.ARROW then --远程武器
			nCount = item.nCurrentDurability
		end
	elseif item.bCanStack then
		nCount = item.nStackNum
	end
	if nCount == 1 then
		hBox:SetOverText(0, "")
	else
		hBox:SetOverText(0, nCount)
	end
	hItem.nCount = nCount

	hTextName:SetText(hItem.szItemName)
	hTextName:SetFontColor(GetItemFontColorByQuality(item.nQuality, false))

	hBox:SetObject(UI_OBJECT_ITEM_INFO, item.nVersion, item.dwTabType, item.dwIndex)
	hBox:SetObjectIcon(nIconID)
	UpdateItemBoxExtend(hBox, item.nGenre, item.nQuality, item.nStrengthLevel)
	hBox:SetOverTextPosition(0, ITEM_POSITION.RIGHT_BOTTOM)
	hBox:SetOverTextFontScheme(0, 15)

	hItem:Lookup(tInfo.Level):SetText(item.GetRequireLevel())
	if szDataType == "Sell" then
		if hItem.szBidderName == "" then
			hTextSaler:SetText(g_tAuctionString.STR_AUCTION_NO_ONE_BID)
			hTextSaler:SetFontScheme(102)
		else
			hTextSaler:SetText(hItem.szBidderName)
			hTextSaler:SetFontScheme(165)
		end
	else
		hTextSaler:SetText(tItemData["SellerName"])
	end

	local nGold, nSliver, nCopper = UnpackMoney(hItem.tBidPrice)
	hItem:Lookup(tInfo.aBidText[1]):SetText(nGold)
	hItem:Lookup(tInfo.aBidText[2]):SetText(nSliver)
	hItem:Lookup(tInfo.aBidText[3]):SetText(nCopper)

	if MoneyOptCmp(hItem.tBuyPrice, NO_BID_PRICE) ~= 0 then
		nGold, nSliver, nCopper = UnpackMoney(hItem.tBuyPrice)
		hItem:Lookup(tInfo.aBuyText[1]):SetText(nGold)
		hItem:Lookup(tInfo.aBuyText[2]):SetText(nSliver)
		hItem:Lookup(tInfo.aBuyText[3]):SetText(nCopper)
	else
		hItem:Lookup(tInfo.aBuyImg[1]):Hide()
		hItem:Lookup(tInfo.aBuyImg[2]):Hide()
		hItem:Lookup(tInfo.aBuyImg[3]):Hide()
		hItem:Lookup(tInfo.aBuyText[4]):Hide()
	end

	local nLeftTime = tItemData["LeftTime"]
	local hTextTime = hItem:Lookup(tInfo.Time)
	if nLeftTime <= 600 then
		hTextTime:SetFontScheme(137)
	end
	local szTime = AuctionPanel.FormatAuctionTime(nLeftTime)
	hTextTime:SetText(szTime)
	hItem:Show()
end

function AuctionPanel.UpdateItemPriceInfo(hList, szDataType)
	local tInfo = tItemWidgetInfo[szDataType]
	local bUnitPrice = tItemDataInfo[szDataType].bUnitPrice
	local nCount = hList:GetItemCount()
	local player = GetClientPlayer()

	for i=0, nCount-1, 1 do
		local hItem = hList:Lookup(i)
		local tBidPrice = hItem.tBidPrice
		local tBuyPrice = hItem.tBuyPrice

		local hTextBid = hItem:Lookup(tInfo.aBidText[4])
		if bUnitPrice then
			tBidPrice = MoneyOptDiv(hItem.tBidPrice, hItem.nCount)
			tBuyPrice = MoneyOptDiv(hItem.tBuyPrice, hItem.nCount)

			if szDataType == "Search" then
				if hItem.szBidderName == "" then
					hTextBid:SetText(g_tAuctionString.STR_AUCTION_UNIT_PRICE)
				elseif player.szName == hItem.szBidderName then
					hTextBid:SetText(g_tAuctionString.STR_AUCTION_MY_UNIT_BID)
				else
					hTextBid:SetText(g_tAuctionString.STR_AUCTION_CURRENT_UNIT_BID)
				end
			elseif szDataType == "Bid" then
				hTextBid:SetText(g_tAuctionString.STR_AUCTION_MY_UNIT_BID)
			elseif szDataType == "Sell" then
				hTextBid:SetText(g_tAuctionString.STR_AUCTION_UNIT_PRICE)
			end

			if MoneyOptCmp(hItem.tBuyPrice, NO_BID_PRICE) ~= 0 then
				hItem:Lookup(tInfo.aBuyText[4]):SetText(g_tAuctionString.STR_AUCTION_UNIT_PRICE)
			end
		else
			if szDataType == "Search" then
				if hItem.szBidderName == "" then
					hTextBid:SetText("")
				elseif player.szName == hItem.szBidderName then
					hTextBid:SetText(g_tAuctionString.STR_AUCTION_MY_BID)
				else
					hTextBid:SetText(g_tAuctionString.STR_AUCTION_CURRENT_BID)
				end
			elseif szDataType == "Bid" then
				hTextBid:SetText(g_tAuctionString.STR_AUCTION_MY_BID)
			elseif szDataType == "Sell" then
				hTextBid:SetText("")
			end

			if MoneyOptCmp(hItem.tBuyPrice, NO_BID_PRICE) ~= 0 then
				hItem:Lookup(tInfo.aBuyText[4]):SetText("")
			end
		end

		local nGold, nSliver, nCopper = UnpackMoney(tBidPrice)
		hItem:Lookup(tInfo.aBidText[1]):SetText(nGold)
		hItem:Lookup(tInfo.aBidText[2]):SetText(nSliver)
		hItem:Lookup(tInfo.aBidText[3]):SetText(nCopper)

		if MoneyOptCmp(hItem.tBuyPrice, NO_BID_PRICE) ~= 0 then
			nGold, nSliver, nCopper = UnpackMoney(tBuyPrice)
			hItem:Lookup(tInfo.aBuyText[1]):SetText(nGold)
			hItem:Lookup(tInfo.aBuyText[2]):SetText(nSliver)
			hItem:Lookup(tInfo.aBuyText[3]):SetText(nCopper)
		end
	end
end

function AuctionPanel.UpdateSelectedInfo(frame, szDataType, bDefault)
	if szDataType == "Search" then
		local hWndRes = frame:Lookup("PageSet_Totle/Page_Business/Wnd_Result2")
		local hList  = hWndRes:Lookup("", "Handle_List")
		local editBG = hWndRes:Lookup("Edit_BidGold")
		local editBS = hWndRes:Lookup("Edit_BidSilver")
		local editBC = hWndRes:Lookup("Edit_BidCopper")
		local btnBid = hWndRes:Lookup("Btn_Bid")
		local btnBuy = hWndRes:Lookup("Btn_BidDefault")

		local hItem = AuctionPanel.GetSelectedItem(hList)
		if hItem then
			local player = GetClientPlayer()
			local tMoney = player.GetMoney()

			if MoneyOptCmp(tMoney, hItem.tBuyPrice) >= 0 then
				btnBuy:Enable(true)
			else
				btnBuy:Enable(false)
			end
			
			if MoneyOptCmp(NO_BID_PRICE, hItem.tBuyPrice) == 0 then
				btnBuy:Enable(false)
			end
			
			local tBidPrice = FormatMoneyTab(0)
			local nGold, nSilver, nCopper = 0, 0, 0

			if bDefault then
				tBidPrice = hItem.tBidPrice
				if hItem.szBidderName ~= "" then
					tBidPrice = MoneyOptAdd(tBidPrice, 10)
				end
				if MoneyOptCmp(tBidPrice, PRICE_LIMITED) > 0 then
					tBidPrice = PRICE_LIMITED
				end
				nGold, nSilver, nCopper = UnpackMoney(tBidPrice)
				editBG:SetText(nGold)
				editBS:SetText(nSilver)
				editBC:SetText(nCopper)
			else
				nGold = FormatMoney(editBG)
				nSilver = FormatMoney(editBS)
				nCopper = FormatMoney(editBC)
				tBidPrice = PackMoney(nGold, nSilver, nCopper)
			end

			local nNeedPrice = hItem.tBidPrice
			if MoneyOptCmp(tMoney, tBidPrice) >= 0 and MoneyOptCmp(tBidPrice, nNeedPrice) >= 0 then
				btnBid:Enable(true)
			else
				btnBid:Enable(false)
			end
		else
			if bDefault then
				editBG:SetText("")
				editBS:SetText("")
				editBC:SetText("")
				btnBid:Enable(false)
				btnBuy:Enable(false)
			end
		end
	elseif szDataType == "Bid" then
		local hWndBid = frame:Lookup("PageSet_Totle/Page_State/Wnd_Bid")
		local hList  = hWndBid:Lookup("", "Handle_BidList")

		local btnBuy = hWndBid:Lookup("Btn_Buy")
		local hItem = AuctionPanel.GetSelectedItem(hList)
		if hItem then
			local player = GetClientPlayer()
			local tMoney = player.GetMoney()
			if MoneyOptCmp(tMoney, hItem.tBuyPrice) >= 0 then
				btnBuy:Enable(true)
			else
				btnBuy:Enable(false)
			end
			
			if MoneyOptCmp(NO_BID_PRICE, hItem.tBuyPrice) == 0 then
				btnBuy:Enable(false)
			end
		else
			btnBuy:Enable(false)
		end
	elseif szDataType == "Sell" then
		local hWndAct = frame:Lookup("PageSet_Totle/Page_Auction/Wnd_Auction")
		local hList  = hWndAct:Lookup("", "Handle_AList")

		local btnCancel = hWndAct:Lookup("Btn_ACancel")
		local hItem = AuctionPanel.GetSelectedItem(hList)
		if hItem then
			btnCancel:Enable(true)
		else
			btnCancel:Enable(false)
		end
	end
end

function AuctionPanel.SaveSearchInfo(frame)
	local hWndSch = frame:Lookup("PageSet_Totle/Page_Business/Wnd_Search")

	tSearchInfo["Name"] = hWndSch:Lookup("Edit_ItemName"):GetText() or ""
	tSearchInfo["Level"][1] = hWndSch:Lookup("Edit_Level1"):GetText() or ""
	tSearchInfo["Level"][2] = hWndSch:Lookup("Edit_Level2"):GetText() or ""

	tSearchInfo["MaxPrice"][1] = hWndSch:Lookup("Edit_HGold"):GetText() or ""
	tSearchInfo["MaxPrice"][2] = hWndSch:Lookup("Edit_HSilver"):GetText() or ""
	tSearchInfo["MaxPrice"][3] = hWndSch:Lookup("Edit_HCopper"):GetText() or ""

	tSearchInfo["Quality"] = hWndSch:Lookup("", "Text_Quality"):GetText() or ""
	tSearchInfo["Status"] = hWndSch:Lookup("", "Text_ItemState"):GetText() or ""
end

function AuctionPanel.UpdateSaleInfo(frame, bDefault)
	local hWndSale = frame:Lookup("PageSet_Totle/Page_Auction/Wnd_Sale")
	local handle = hWndSale:Lookup("", "")
	local box = handle:Lookup("Box_Item")

	local editOPG = hWndSale:Lookup("Edit_OPGold")
	local editOPS = hWndSale:Lookup("Edit_OPSilver")
	local editOPC = hWndSale:Lookup("Edit_OPCopper")
	local editPG  = hWndSale:Lookup("Edit_PGold")
	local editPS  = hWndSale:Lookup("Edit_PSilver")
	local editPC  = hWndSale:Lookup("Edit_PCopper")
	local btnSale = hWndSale:Lookup("Btn_Sale")

	local textCG = handle:Lookup("Text_ChargeGold")
	local textCS = handle:Lookup("Text_ChargeSliver")
	local textCC = handle:Lookup("Text_ChargeCopper")
	local textTime = handle:Lookup("Text_Time")

	local textUPG = handle:Lookup("Text_PVGold")
	local textUPS = handle:Lookup("Text_PVSliver")
	local textUPC = handle:Lookup("Text_PVCopper")

	if box:IsEmpty() then
		if bDefault then
			editOPG:SetText(0)
			editOPS:SetText(0)
			editOPC:SetText(0)
			editPG:SetText(0)
			editPS:SetText(0)
			editPC:SetText(0)
			textTime:SetText(g_tAuctionString.STR_DEFAULT_TIME)
		end
		btnSale:Enable(false)
		textCG:SetText(0)
		textCS:SetText(0)
		textCC:SetText(0)
		textUPG:SetText(0)
		textUPS:SetText(0)
		textUPC:SetText(0)
	else
		local player = GetClientPlayer()
		local item   = GetPlayerItem(player, box.dwBox, box.dwX)
		if not item then
			return
		end

		local szName = item.szName
		local tBidPrice = PackMoney(0, 0, 1)
		local tBuyPrice = FormatMoneyTab(0)
		if bDefault then
			local tItemInfo = AuctionPanel.GetItemSellInfo(szName)
			if tItemInfo then
				tBidPrice = MoneyOptMult(tItemInfo.tBidPrice, box.nCount)
				tBuyPrice = MoneyOptMult(tItemInfo.tBuyPrice, box.nCount)
				
				if MoneyOptCmp(tBidPrice, PRICE_LIMITED) > 0 then
					tBidPrice = clone(PRICE_LIMITED)
				end
				
				if MoneyOptCmp(tBuyPrice, PRICE_LIMITED) > 0 then
					tBuyPrice = clone(PRICE_LIMITED)
				end
				
				textTime:SetText(tItemInfo.szTime)
			else
				if item.bCanTrade then
					tBidPrice = FormatMoneyTab(item.nPrice * box.nCount * 2)
				else
					tBidPrice = FormatMoneyTab(box.nCount * 100)
				end
				textTime:SetText(g_tAuctionString.STR_DEFAULT_TIME)
			end
			
			local nGold, nSilver, nCopper = UnpackMoney(tBidPrice)
			editOPG:SetText(nGold)
			editOPS:SetText(nSilver)
			editOPC:SetText(nCopper)

			nGold, nSilver, nCopper = UnpackMoney(tBuyPrice)
			editPG:SetText(nGold)
			editPS:SetText(nSilver)
			editPC:SetText(nCopper)
		end

		if MoneyOptCmp(tBuyPrice, 0) == 0 then
			tBuyPrice = NO_BID_PRICE
		end

		local nTime = tonumber(string.sub(textTime:GetText(),1,2))
		local tSaveCost = PackMoney(0, 0, 10)
		if item.bCanTrade then
				--math.floor(item.nPrice * box.nCount * nTime / 12 * 0.4 )
			tSaveCost = MoneyOptDiv(MoneyOptMult(item.nPrice, box.nCount * nTime * 2), 12 * 5)
			if MoneyOptCmp(tSaveCost, 10) < 0 then
				tSaveCost = PackMoney(0, 0, 10)
			end
		end
		
		local tMoney = GetClientPlayer().GetMoney()
		if MoneyOptCmp(tMoney, tSaveCost) >= 0 then
			btnSale.bSave = true
			btnSale:Enable(btnSale.bPrice)
		else
			btnSale.bSave = false
			btnSale:Enable(false)
		end

		nGold, nSilver, nCopper = UnpackMoney(tSaveCost)
		textCG:SetText(nGold)
		textCS:SetText(nSilver)
		textCC:SetText(nCopper)

		nGold, nSilver, nCopper = UnpackMoney(MoneyOptDiv(tBidPrice, box.nCount))
		textUPG:SetText(nGold)
		textUPS:SetText(nSilver)
		textUPC:SetText(nCopper)
	end
end


function AuctionPanel.LockOperate(frame, szDataType)
	local hPageTot = frame:Lookup("PageSet_Totle")
	local hListWnd = nil
	if szDataType == "Search" then
		hListWnd = hPageTot:Lookup("Page_Business/Wnd_Result2")
		hPageTot:Lookup("Page_Business/Wnd_Search/Btn_Search"):Enable(false)
		hListWnd:Lookup("Btn_Bid"):Enable(false)
		hListWnd:Lookup("Btn_BidDefault"):Enable(false)
		hPageTot:Lookup("CheckBox_State"):Enable(false)
		hPageTot:Lookup("CheckBox_Auction"):Enable(false)

	elseif szDataType == "Bid" then
		hListWnd = hPageTot:Lookup("Page_State/Wnd_Bid")
		hListWnd:Lookup("Btn_Buy"):Enable(false)
		hPageTot:Lookup("CheckBox_Business"):Enable(false)
		hPageTot:Lookup("CheckBox_Auction"):Enable(false)

	elseif szDataType == "Sell" then
		hListWnd = hPageTot:Lookup("Page_Auction/Wnd_Auction")
		hPageTot:Lookup("Page_Auction/Wnd_Sale/Btn_Sale"):Enable(false)
		hListWnd:Lookup("Btn_ACancel"):Enable(false)
		hPageTot:Lookup("CheckBox_Business"):Enable(false)
		hPageTot:Lookup("CheckBox_State"):Enable(false)
	end

	local tInfo = tItemWidgetInfo[szDataType]
	hListWnd:Lookup(tInfo.BtnUp):Enable(false)
	hListWnd:Lookup(tInfo.BtnDown):Enable(false)
	for k, v in pairs(tInfo.tCheck) do
		hListWnd:Lookup(k):Enable(false)
	end
end

function AuctionPanel.UnLockOperate(frame, szDataType)
	local hPageTot = frame:Lookup("PageSet_Totle")
	local hListWnd = nil
	if szDataType == "Search" then
		hListWnd = hPageTot:Lookup("Page_Business/Wnd_Result2")
		hPageTot:Lookup("Page_Business/Wnd_Search/Btn_Search"):Enable(true)
		hPageTot:Lookup("CheckBox_State"):Enable(true)
		hPageTot:Lookup("CheckBox_Auction"):Enable(true)

	elseif szDataType == "Bid" then
		hListWnd = hPageTot:Lookup("Page_State/Wnd_Bid")

		hPageTot:Lookup("CheckBox_Business"):Enable(true)
		hPageTot:Lookup("CheckBox_Auction"):Enable(true)

	elseif szDataType == "Sell" then
		hListWnd = hPageTot:Lookup("Page_Auction/Wnd_Auction")
		local btnSale = hPageTot:Lookup("Page_Auction/Wnd_Sale/Btn_Sale")
		local hBox = hPageTot:Lookup("Page_Auction/Wnd_Sale", "Box_Item")
		if hBox:IsEmpty() then
			btnSale:Enable(false)
		else
			btnSale:Enable((btnSale.bSave and btnSale.bPrice))
		end

		hPageTot:Lookup("CheckBox_Business"):Enable(true)
		hPageTot:Lookup("CheckBox_State"):Enable(true)
	end

	AuctionPanel.UpdateSelectedInfo(frame, szDataType)
	AuctionPanel.OnItemDataInfoUpdate(hListWnd, szDataType)

	local tInfo = tItemWidgetInfo[szDataType]
	for k, v in pairs(tInfo.tCheck) do
		hListWnd:Lookup(k):Enable(true)
	end
end

function AuctionPanel.ApplyLookup(frame, szReqestType, nSortType, szKey, nStart, bDesc)
	local szItemName = ""
	local nMinLevel, nMaxLevel = 0, 0
	local nMaxPrice = 0
	local nSort, nSubSort = 0, 0
	local nAuction = AUCTION_SALE_STATE.IGNORE
	local nQuality = -1
	local szSellerName = ""
	local nBidderID = 0
	local nSellerID = 0
	local bUnitPrice = false
	local nGold = 0
	local nSliver = 0
	local nCopper = 0
	
	if nStart < 1 then
		nStart = 1
	end
	tItemDataInfo[szReqestType].nStart = nStart
	bUnitPrice = tItemDataInfo[szReqestType].bUnitPrice
	if szReqestType == "Search" then
		if tSearchInfo["Name"] ~= g_tAuctionString.STR_ITEM_NAME then
			szItemName = tSearchInfo["Name"]
		end

		if tSearchInfo["Level"][1] ~= "" then
			nMinLevel = tonumber(tSearchInfo["Level"][1])
		end

		if tSearchInfo["Level"][2] ~= "" then
			nMaxLevel = tonumber(tSearchInfo["Level"][2])
		end

		nGold   = FormatMoney(tSearchInfo["MaxPrice"][1], true)
		nSliver = FormatMoney(tSearchInfo["MaxPrice"][2], true)
		nCopper = FormatMoney(tSearchInfo["MaxPrice"][3], true)

		if EXPAND_ITEM_TYPE.szType then
			nSort = g_tAuctionString.tSearchSort[EXPAND_ITEM_TYPE.szType].nSortID or 0
		end

		if nSort ~= 0 then
			nSubSort = g_tAuctionString.tSearchSort[EXPAND_ITEM_TYPE.szType].tSubSort[EXPAND_ITEM_TYPE.szSubType] or 0
		end

		if tSearchInfo["Quality"] ~= g_tAuctionString.STR_ITEM_QUALITY then
			nQuality = g_tAuctionString.tSearchQuality[tSearchInfo["Quality"]]
		end

		if tSearchInfo["Status"] ~= g_tAuctionString.STR_ITEM_STATUS then
			nAuction = g_tAuctionString.tSearchStatus[tSearchInfo["Status"]]
		end
	elseif szReqestType == "Sell" then
		if szKey and szKey ~= "" then
			nSellerID = tonumber(szKey)
		end
	elseif szReqestType == "Bid" then
		if szKey and szKey ~= "" then
			nBidderID = tonumber(szKey)
		end
	end

	if nMinLevel ~=0 and nMaxLevel ~=0 and nMinLevel > nMaxLevel and szReqestType == "Search" then
		tItemDataInfo[szReqestType].nTotCount = 0
		tItemDataInfo[szReqestType].nCurCount = 0
		AuctionPanel.UpdateItemList(frame, "Search")
		return
	end
	
	if bUnitPrice then
		bUnitPrice = 1
	else
		bUnitPrice = 0
	end
	assert(tItemDataInfo[szReqestType].nRequestID)
	
	local AuctionClient = GetAuctionClient()
	AuctionClient.ApplyLookup(AuctionPanel.dwTargetID, tItemDataInfo[szReqestType].nRequestID, szItemName, nSort, nSubSort, nMinLevel, nMaxLevel, nQuality, szSellerName, nSellerID, nBidderID, nGold, nSliver, nCopper, nAuction, nStart - 1, nSortType, bDesc, bUnitPrice)

	AuctionPanel.LockOperate(frame, szReqestType)
end

function AuctionPanel.AuctionCancel(hItem)
	if not hItem then
		return
	end

	if hItem.szBidderName ~= "" then
		OutputMessage("MSG_ANNOUNCE_RED", g_tAuctionString.STR_CAN_NOT_CANCEL)
		return
	end

	local fun = function()
		if hItem:IsValid() then
			local AuctionClient = GetAuctionClient()
			AuctionClient.Cancel(AuctionPanel.dwTargetID, hItem.nSaleID)
			tInfoRequesting.szRequestType = "Sell"
			tInfoRequesting.nSaleID = hItem.nSaleID
	 	end
	end

	local szNotice = FormatString(g_tAuctionString.STR_CANCEL_AFFIRM, hItem.szItemName)
	AuctionPanel.ShowNotice(szNotice, true, fun, true)
end

function AuctionPanel.AuctionBid(hItem)
	if not hItem then
		return
	end

	if CheckHaveLocked(SAFE_LOCK_EFFECT_TYPE.AUCTION, "Bid") then
		return
	end
	
    local hWnd = hItem:GetParent():GetParent():GetParent()
	local nGold = FormatMoney(hWnd:Lookup("Edit_BidGold"))
	local nSilver = FormatMoney(hWnd:Lookup("Edit_BidSilver"))
	local nCopper = FormatMoney(hWnd:Lookup("Edit_BidCopper"))
	local tPrice = PackMoney(nGold, nSilver, nCopper)

	local tNeedPrice = hItem.tBidPrice
	if hItem.szBidderName ~= "" then
		tNeedPrice = MoneyOptAdd(tNeedPrice, 10)
	end

	if MoneyOptCmp(tPrice, tNeedPrice) < 0 then
		OutputMessage("MSG_ANNOUNCE_RED", g_tAuctionString.STR_BID_BIGGER_THAN_TEN)
		return
	end

	local fun = function()
		if hItem:IsValid() then
			AuctionPanel.LockOperate(hItem:GetRoot(), "Search")
			tInfoRequesting.szRequestType = "Search"
			tInfoRequesting.nSaleID = hItem.nSaleID
			tInfoRequesting.tPrice = tPrice
			FireEvent("BUY_AUCTION_ITEM")

			--==money remark=============================================
			local AuctionClient = GetAuctionClient()
 			AuctionClient.Bid(AuctionPanel.dwTargetID, hItem.nSaleID, hItem.nItemID, hItem.nCRC, tPrice.nGold, tPrice.nSilver, tPrice.nCopper)
			
 			PlaySound(SOUND.UI_SOUND, g_sound.Trade)
 		end
	end
	local szMoney = GetMoneyText(tPrice, 105)
	local szMsg = FormatString(g_tAuctionString.STR_BID_AFFIRM, szMoney, hItem.szItemName)
	AuctionPanel.ShowNotice(szMsg, true, fun, true, true)
end

function AuctionPanel.AuctionBuy(hItem, szDataType)
	if not hItem then
		return
	end
	
	if CheckHaveLocked(SAFE_LOCK_EFFECT_TYPE.AUCTION, "buy") then
		return
	end
	
	local fun = function()
		if hItem:IsValid() then
			AuctionPanel.LockOperate(hItem:GetRoot(), szDataType)
			tInfoRequesting.szRequestType = szDataType
			tInfoRequesting.nSaleID = hItem.nSaleID
			tInfoRequesting.tPrice = hItem.tBuyPrice
			FireEvent("BUY_AUCTION_ITEM")

			--==money remark=============================================
			local AuctionClient = GetAuctionClient()
			
			local tBuyPrice = hItem.tBuyPrice
			--local nBuyPrice = GoldSilverAndCopperToMoney(tBuyPrice.nGold, tBuyPrice.nSilver, tBuyPrice.nCopper)
	
 			AuctionClient.Bid(AuctionPanel.dwTargetID, hItem.nSaleID, hItem.nItemID, hItem.nCRC, tBuyPrice.nGold, tBuyPrice.nSilver, tBuyPrice.nCopper)
			
 			PlaySound(SOUND.UI_SOUND, g_sound.Trade)
 		end
	end
	local szMoney = GetMoneyText(hItem.tBuyPrice, 105)
	local szMsg = FormatString(g_tAuctionString.STR_BUY_AFFIRM, szMoney, hItem.szItemName)
	AuctionPanel.ShowNotice(szMsg, true, fun, true, true)
end

function AuctionPanel.AuctionSell(frame)
	if CheckHaveLocked(SAFE_LOCK_EFFECT_TYPE.AUCTION, "sell") then
		return
	end
	
	local hWndSale  = frame:Lookup("PageSet_Totle/Page_Auction/Wnd_Sale")
	local handle    = hWndSale:Lookup("", "")
	local box       = handle:Lookup("Box_Item")
	local text      = handle:Lookup("Text_Time")
	local szTime    = text:GetText()
	local nTime     = tonumber(string.sub(szTime, 1, 2))
	local tBidPrice = nil
	local tBuyPrice = nil
	local player    = GetClientPlayer()
	
	local item = GetPlayerItem(player, box.dwBox, box.dwX);
	if not item or item.szName ~= box.szName then
		AuctionPanel.ClearBox(box)
		AuctionPanel.UpdateSaleInfo(frame, true)
		RemoveUILockItem("Auction")
		OutputMessage("MSG_ANNOUNCE_RED", g_tAuctionString.STR_AUCTION_ITEM_INFO_CHANGE)
		return
	end
	
	local nGold   = FormatMoney(hWndSale:Lookup("Edit_OPGold"))
	local nSilver = FormatMoney(hWndSale:Lookup("Edit_OPSilver"))
	local nCopper = FormatMoney(hWndSale:Lookup("Edit_OPCopper"))
	tBidPrice 	  = PackMoney(nGold, nSilver, nCopper)

	nGold   	= FormatMoney(hWndSale:Lookup("Edit_PGold"))
	nSilver 	= FormatMoney(hWndSale:Lookup("Edit_PSilver"))
	nCopper 	= FormatMoney(hWndSale:Lookup("Edit_PCopper"))
	tBuyPrice 	= PackMoney(nGold, nSilver, nCopper)

	box.szTime = szTime
	box.tBidPrice = tBidPrice
	box.tBuyPrice = tBuyPrice

	--==money remark=============================================
	local AtClient = GetAuctionClient()
	FireEvent("SELL_AUCTION_ITEM")
	
	--local nBidPrice = GoldSilverAndCopperToMoney(tBidPrice.nGold, tBidPrice.nSilver, tBidPrice.nCopper)
	--local nBuyPrice = GoldSilverAndCopperToMoney(tBuyPrice.nGold, tBuyPrice.nSilver, tBuyPrice.nCopper)
	
	AtClient.Sell(AuctionPanel.dwTargetID, box.dwBox, box.dwX, tBidPrice.nGold, tBidPrice.nSilver, tBidPrice.nCopper, tBuyPrice.nGold, tBuyPrice.nSilver, tBuyPrice.nCopper, nTime)
	PlaySound(SOUND.UI_SOUND, g_sound.Trade)
end

function AuctionPanel.ShowNotice(szNotice, bSure, fun, bCancel, bText)
	local szContent = nil

	if bText then
		szContent = szNotice
	else
		szContent = "<text>text="..EncodeComponentsString(szNotice).." font=105 </text>"
	end

	if szContent then
		local msg = nil
		msg =
		{
		  	bRichText = true,
			szMessage = szContent,
			szName = "EmotionNotice",
			fnAutoClose = function() if not AuctionPanel.IsOpened() then return true end end,
		}
		if bSure then
			table.insert(msg, { szOption = g_tAuctionString.STR_NOTICE_SURE, fnAction = fun})
		end
		if bCancel then
			table.insert(msg, { szOption = g_tAuctionString.STR_NOTICE_CANCEL})
		end

		MessageBox(msg)
	end
end

function AuctionPanel.UpdateItemTypeList(frame)
	local tItemType = {}
	for k, tSubType in pairs(g_tAuctionString.tSearchSort) do
		tItemType[tSubType.nSortID] = {szType = k, tSubType = {}}
		for i, v in pairs(tSubType.tSubSort) do
			tItemType[tSubType.nSortID].tSubType[v] = i
		end
	end

	local hWnd = frame:Lookup("PageSet_Totle/Page_Business/Wnd_Search")
	local hListLv1 = hWnd:Lookup("", "Handle_SearchList")
	hListLv1:Clear()

	for k, v in pairs(tItemType) do
		local hListLv2 = hListLv1:AppendItemFromIni(INI_FILE_PATH, "Handle_ListContent")
		local imgBg1 = hListLv2:Lookup("Image_SearchListBg1")
		local imgBg2 = hListLv2:Lookup("Image_SearchListBg2")
		local imgCover = hListLv2:Lookup("Image_SearchListCover")
		local imgMin = hListLv2:Lookup("Image_Minimize")

		if EXPAND_ITEM_TYPE.szType == v.szType then
			hListLv2.bSel = true
			local hListLv3 = hListLv2:Lookup("Handle_Items")
	    	local w, h = AuctionPanel.AddItemSubTypeList(hListLv3, v.tSubType or {})
	    	imgBg1:Hide()
	    	imgBg2:Show()
	    	imgCover:Show()
	    	imgMin:SetFrame(8)

	    	local wB, _ = imgBg2:GetSize()
	    	imgBg2:SetSize(wB, h + 50)

	    	local wL, _ = hListLv2:GetSize()
	    	hListLv2:SetSize(wL, h + 50)
	    else
	    	imgBg1:Show()
	    	imgBg2:Hide()
	    	imgCover:Hide()
	    	imgMin:SetFrame(12)
	    	imgBg2:SetSize(0, 0)

	    	local w, h = imgBg1:GetSize()
	    	hListLv2:SetSize(w, h)
	    end

		hListLv2:Lookup("Text_ListTitle"):SetText(v.szType)
	end
	AuctionPanel.OnUpdateItemTypeList(hListLv1)
end

function AuctionPanel.AddItemSubTypeList(hList, tSubType)
	for k, v in pairs(tSubType) do
		local hItem = hList:AppendItemFromIni(INI_FILE_PATH, "Handle_List01")
		local imgCover =  hItem:Lookup("Image_SearchListCover01")
		if EXPAND_ITEM_TYPE.szSubType == v then
			hItem.bSel = true
			imgCover:Show()
		else
			imgCover:Hide()
		end

		hItem:Lookup("Text_List01"):SetText(v)

	end
	hList:Show()
	hList:FormatAllItemPos()
	hList:SetSizeByAllItemSize()
	return hList:GetSize()
end

function AuctionPanel.OnUpdateItemTypeList(hList)
	hList:FormatAllItemPos()
	local hWnd = hList:GetParent():GetParent()
	local scroll = hWnd:Lookup("Scroll_Search")
	local w, h = hList:GetSize()
	local wAll, hAll = hList:GetAllItemSize()
	local nStepCount = math.ceil((hAll - h) / 10)

	scroll:SetStepCount(nStepCount)
	if nStepCount > 0 then
		scroll:Show()
		hWnd:Lookup("Btn_SUp"):Show()
		hWnd:Lookup("Btn_SDown"):Show()
	else
		scroll:Hide()
		hWnd:Lookup("Btn_SUp"):Hide()
		hWnd:Lookup("Btn_SDown"):Hide()
	end
end

function AuctionPanel.ClearBox(hBox)
	hBox.dwBox = nil
	hBox.dwX = nil
	hBox.szName = nil
	hBox:ClearObject()
	hBox:SetOverText(0, "")
	hBox:GetParent():Lookup("Text_ItemName"):SetText("")
end

function AuctionPanel.UpdateMoney(frame)
	local hWndRes = frame:Lookup("PageSet_Totle/Page_Business/Wnd_Result2")
	local hWndBid = frame:Lookup("PageSet_Totle/Page_State/Wnd_Bid")
	local hWndAct = frame:Lookup("PageSet_Totle/Page_Auction/Wnd_Auction")
	local hWndSale = frame:Lookup("PageSet_Totle/Page_Auction/Wnd_Sale")
	local box = hWndSale:Lookup("", "Box_Item")
	local textTime = hWndSale:Lookup("", "Text_Time")

	local player = GetClientPlayer()
	local tMoney = player.GetMoney()
	local nGold, nSilver, nCopper = UnpackMoney(tMoney)

	hWndRes:Lookup("", "Text_ROwnGold"):SetText(nGold)
	hWndRes:Lookup("", "Text_ROwnSliver"):SetText(nSilver)
	hWndRes:Lookup("", "Text_ROwnCopper"):SetText(nCopper)

	hWndBid:Lookup("", "Text_BGold"):SetText(nGold)
	hWndBid:Lookup("", "Text_BSliver"):SetText(nSilver)
	hWndBid:Lookup("", "Text_BCopper"):SetText(nCopper)

	hWndAct:Lookup("", "Text_AGold"):SetText(nGold)
	hWndAct:Lookup("", "Text_ASliver"):SetText(nSilver)
	hWndAct:Lookup("", "Text_ACopper"):SetText(nCopper)

	if not box:IsEmpty() then
		local item   = GetPlayerItem(player, box.dwBox, box.dwX)
		if not item then
			return
		end
		local btnSale = hWndSale:Lookup("Btn_Sale")

		local nTime = tonumber(string.sub(textTime:GetText(),1,2))
		local tSaveCost = PackMoney(0, 0, 10)
		if item.bCanTrade then
			--math.floor(item.nPrice * box.nCount * nTime / 12 * 0.4 )
			tSaveCost = MoneyOptDiv(MoneyOptMult(item.nPrice, box.nCount * nTime * 2), 12 * 5)
			if MoneyOptCmp(tSaveCost, 10) < 0 then
				tSaveCost = PackMoney(0, 0, 10)
			end
		end

		if MoneyOptCmp(tMoney, tSaveCost) >= 0 then
			btnSale.bSave = true
			btnSale:Enable(btnSale.bPrice)
		else
			btnSale.bSave = false
			btnSale:Enable(false)
		end
	end
end

function AuctionPanel.UpdateBgStatus(hItem)
	local img = nil
	local szName = hItem:GetName()
	if szName == "Handle_ItemList" then
		img = hItem:Lookup("Image_Light")
	elseif szName == "Handle_AItemList" then
		img = hItem:Lookup("Image_ALight")
	elseif szName == "Handle_BidItemList" then
		img = hItem:Lookup("Image_BidLight")
	elseif szName == "Handle_ListContent" then
		img = hItem:Lookup("Image_SearchListCover")
	elseif szName == "Handle_List01" then
		img = hItem:Lookup("Image_SearchListCover01")
	end

	if not img then
		return
	end

	if hItem.bSel then
		img:Show()
		img:SetAlpha(255)
	elseif hItem.bOver then
		img:Show()
		img:SetAlpha(128)
	else
		img:Hide()
	end
end

function AuctionPanel.Selected(hItem)
	if hItem then
		local hList = hItem:GetParent()
		local nCount = hList:GetItemCount() - 1
		for i=0, nCount, 1 do
			local hI = hList:Lookup(i)
			if hI.bSel then
				hI.bSel = false
				AuctionPanel.UpdateBgStatus(hI)
			end
		end
		hItem.bSel = true
		AuctionPanel.UpdateBgStatus(hItem)
	end
end

function AuctionPanel.GetSelectedItem(hList)
	local nCount = hList:GetItemCount() - 1
	for i=0, nCount, 1 do
		local hI = hList:Lookup(i)
		if hI.bSel then
			return hI
		end
	end
	return nil
end

function AuctionPanel.GetItemSellInfo(szItemName)
	for k, v in pairs(AuctionPanel.tItemSellInfoCache) do
		if v.szName == szItemName then
			return v
		end
	end
	return nil
end

function AuctionPanel.UpdateItemSellInfo(szItemName, tBidPrice, tBuyPrice, szTime, bEarse)
	for k, v in pairs(AuctionPanel.tItemSellInfoCache) do
		if v.szName == szItemName then
			if bEarse then
				table.remove(AuctionPanel.tItemSellInfoCache, k)
			else
				AuctionPanel.tItemSellInfoCache[k].tBidPrice = tBidPrice
				AuctionPanel.tItemSellInfoCache[k].tBuyPrice = tBuyPrice
				AuctionPanel.tItemSellInfoCache[k].szTime = szTime
			end
			return
		end
	end

	local nSize = #AuctionPanel.tItemSellInfoCache
	if nSize == MAX_SELL_INFO_CACHE_SIZE then
		AuctionPanel.tItemSellInfoCache[1].szName = szItemName
		AuctionPanel.tItemSellInfoCache[1].tBidPrice = tBidPrice
		AuctionPanel.tItemSellInfoCache[1].tBuyPrice = tBuyPrice
		AuctionPanel.tItemSellInfoCache[1].szTime = szTime
	end
	table.insert(AuctionPanel.tItemSellInfoCache, {szName = szItemName, tBidPrice = tBidPrice, tBuyPrice = tBuyPrice, szTime = szTime})
end

function AuctionPanel.OnScrollBarPosChanged()
	local hWnd = this:GetParent()
	local nCurrentValue = this:GetScrollPos()
	local szName = this:GetName()
	local hBtnUp, hBtnDown, hList = nil, nil, nil
	if szName == "Scroll_Result" then
		hBtnUp = hWnd:Lookup("Btn_RUp")
		hBtnDown = hWnd:Lookup("Btn_RDown")
		hList = hWnd:Lookup("", "Handle_List")

	elseif szName == "Scroll_Auction" then
		hBtnUp = hWnd:Lookup("Btn_AUp")
		hBtnDown = hWnd:Lookup("Btn_ADown")
		hList = hWnd:Lookup("", "Handle_AList")

	elseif szName == "Scroll_Bid" then
		hBtnUp = hWnd:Lookup("Btn_BUp")
		hBtnDown = hWnd:Lookup("Btn_BDown")
		hList = hWnd:Lookup("", "Handle_BidList")

	elseif szName == "Scroll_Search" then
		hBtnUp = hWnd:Lookup("Btn_SUp")
		hBtnDown = hWnd:Lookup("Btn_SDown")
		hList = hWnd:Lookup("", "Handle_SearchList")
	elseif szName == "ScrollBar_C" then
		hBtnUp = hWnd:Lookup("Btn_CUp")
		hBtnDown = hWnd:Lookup("Btn_CDown")
		hList = hWnd:Lookup("", "Handle_CList")
	end

	if nCurrentValue == 0 then
		hBtnUp:Enable(false)
	else
		hBtnUp:Enable(true)
	end

	if nCurrentValue == this:GetStepCount() then
		hBtnDown:Enable(false)
	else
		hBtnDown:Enable(true)
	end
	hList:SetItemStartRelPos(0, -nCurrentValue * 10)
end

function AuctionPanel.OnExchangeBoxItem(boxItem, boxDsc, nHandCount, bHand)
	if not boxItem or not boxDsc then
		return
	end

	local nSourceType = boxDsc:GetObjectType()
	local _, dwBox1, dwX1 = boxDsc:GetObjectData()
	local player = GetClientPlayer()

	if nSourceType ~= UI_OBJECT_ITEM or (not dwBox1 or not IsObjectFromPackage(dwBox1)) then
		OutputMessage("MSG_ANNOUNCE_RED", g_tAuctionString.STR_ERROR_CANNOT_DRAG_ITEM_IN_AUCTION)
		return
	end

	local item = GetPlayerItem(player, dwBox1, dwX1)
	if not item then
		return
	end

	local itemInfo = GetItemInfo(item.dwTabType, item.dwIndex)
	if item.bBind then
		OutputMessage("MSG_ANNOUNCE_RED", g_tAuctionString.STR_ERROR_CANNOT_DRAG_BIND_IN_AUCTION)
		return
	elseif itemInfo.nExistType ~= ITEM_EXIST_TYPE.PERMANENT then
		OutputMessage("MSG_ANNOUNCE_RED", g_tAuctionString.STR_ERROR_CANNOT_DRAG_TIME_LIMIT_ITEM_IN_AUCTION)
		return
	--elseif item.nGenre == ITEM_GENRE.BOOK then
	--	OutputMessage("MSG_ANNOUNCE_RED", g_tAuctionString.STR_AUCTION_CANNOT_SELL_BOOK)
	--	return
	end


	local nCount = 1
	if item.nGenre == ITEM_GENRE.EQUIPMENT then
		if item.nSub == EQUIPMENT_SUB.ARROW then --远程武器
			nCount = item.nCurrentDurability
		elseif item.nSub ~= EQUIPMENT_SUB.HORSE and item.nCurrentDurability < item.nMaxDurability then
			OutputMessage("MSG_ANNOUNCE_RED", g_tAuctionString.STR_ERROR_CANNOT_SELL_BAD_ITEM)
			return
		end
	else
		if item.bCanStack then
			nCount = item.nStackNum
		end
	end

	if nHandCount and nHandCount ~= nCount then	--手里面是拆分后没有放入背包的物品
		OutputMessage("MSG_ANNOUNCE_RED", g_tAuctionString.STR_AUCTION_ONLY_SOLD_GLOUP)
		return
	end

	if not boxItem:IsEmpty() then
		RemoveUILockItem("Auction")
	end
	boxItem.szName = item.szName
	boxItem.dwBox = dwBox1
	boxItem.dwX   = dwX1
	boxItem.nCount = nCount

	UpdataItemBoxObject(boxItem, boxItem.dwBox, boxItem.dwX, item)

	local handle = boxItem:GetParent()
	textbox = handle:Lookup("Text_ItemName")
	textbox:SetText(GetItemNameByItem(item))
	textbox:SetFontColor(GetItemFontColorByQuality(item.nQuality, false))

	if bHand then
		Hand_Clear()
	end

	AddUILockItem("Auction", dwBox1, dwX1)
	AuctionPanel.UpdateSaleInfo(boxItem:GetRoot(), true)

end

function AuctionPanel.OnItemMouseEnter()
	local szName = this:GetName()
	if szName == "Box_Item" then
		if not this:IsEmpty() then
			local _, dwBox, dwX = this:GetObjectData()
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			OutputItemTip(UI_OBJECT_ITEM, dwBox, dwX, nil, {x, y, w, h})
		end
	elseif szName == "Box_Box" or szName == "Box_BidBox" or szName == "Box_ABox" then
		if not this:IsEmpty() then
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			OutputItemTip(UI_OBJECT_ITEM_ONLY_ID, this.nItemID, nil, nil, {x, y, w, h})
		end
	elseif szName == "Handle_ItemList"  or szName == "Handle_AItemList" or szName == "Handle_BidItemList" or
		   szName == "Handle_ListContent" or szName == "Handle_List01" then
		this.bOver = true
		AuctionPanel.UpdateBgStatus(this)
	else
		BlackMarket.OnItemMouseEnter()
	end
end

function AuctionPanel.OnItemMouseLeave()
	local szName = this:GetName()
	if szName == "Box_Item" or szName == "Box_Box" or szName == "Box_BidBox" or szName == "Box_ABox" then
		HideTip()
	elseif szName == "Handle_ItemList"  or szName == "Handle_AItemList" or szName == "Handle_BidItemList" or
		  szName == "Handle_ListContent" or szName == "Handle_List01" then
		this.bOver = false
		AuctionPanel.UpdateBgStatus(this)
	else
		BlackMarket.OnItemMouseLeave()
	end
end

function AuctionPanel.OnItemLButtonClick()
	local szName = this:GetName()
	if szName == "Handle_ListContent" then
		local szType = this:Lookup("Text_ListTitle"):GetText()
		if EXPAND_ITEM_TYPE.szType == szType then
			EXPAND_ITEM_TYPE = {}
		else
			EXPAND_ITEM_TYPE.szType = szType
		end
		AuctionPanel.UpdateItemTypeList(this:GetRoot())

		PlaySound(SOUND.UI_SOUND,g_sound.Button)
	elseif szName == "Handle_List01" then
		local szSubType = this:Lookup("Text_List01"):GetText()
		EXPAND_ITEM_TYPE.szSubType = szSubType
		AuctionPanel.UpdateItemTypeList(this:GetRoot())
	elseif szName == "Box_Item" then
		if Hand_IsEmpty() then
			if not this:IsEmpty() then
				if IsCursorInExclusiveMode() then
					OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CANCEL_CURSOR_STATE)
					PlayTipSound("010")
				else
					RemoveUILockItem("Auction")
					Hand_Pick(this)
					AuctionPanel.ClearBox(this)
					AuctionPanel.UpdateSaleInfo(this:GetRoot(), true)
				end
			end
		else
			local boxHand, nHandCount = Hand_Get()
			AuctionPanel.OnExchangeBoxItem(this, boxHand, nHandCount, true)
		end

	elseif szName == "Handle_ItemList" then
		AuctionPanel.Selected(this)
		AuctionPanel.UpdateSelectedInfo(this:GetRoot(), "Search", true)
	elseif szName == "Handle_AItemList" then
		AuctionPanel.Selected(this)
		AuctionPanel.UpdateSelectedInfo(this:GetRoot(), "Sell", true)
	elseif szName == "Handle_BidItemList" then
		AuctionPanel.Selected(this)
		AuctionPanel.UpdateSelectedInfo(this:GetRoot(), "Bid", true)
	end
end

function AuctionPanel.OnItemLButtonDBClick()
	local szName = this:GetName()
	if szName == "Handle_List01" then
		local hBtnSrch  = this:GetRoot():Lookup("PageSet_Totle/Page_Business/Wnd_Search/Btn_Search")
		if hBtnSrch:IsEnabled() then
			local thisSave = this
			this = hBtnSrch
			AuctionPanel.OnLButtonClick()
			this = thisSave
		end
	end
end

function AuctionPanel.OnItemLButtonUp()
	local szName = this:GetName()
	if szName == "Box_Item" then
		this:SetObjectPressed(0)
	else
		BlackMarket.OnItemLButtonUp()
	end
end

function AuctionPanel.OnItemLButtonDown()
	local szName = this:GetName()
	if szName == "Box_Item" then
		this:SetObjectStaring(false)
		this:SetObjectPressed(1)

	elseif szName == "Box_Box" or szName == "Box_BidBox" or szName == "Box_ABox" then
		if IsCtrlKeyDown() then
			EditBox_AppendLinkItem(this.nItemID)
        elseif IsAltKeyDown() then
            local hTheItem = GetItem(this.nItemID)
            if hTheItem then
                ExteriorViewByItemInfo(hTheItem.dwTabType, hTheItem.dwIndex)
            end
		end
	else
		BlackMarket.OnItemLButtonDown()
	end
end

function AuctionPanel.OnItemLButtonDragEnd()
	this.bIgnoreClick = true
	if not Hand_IsEmpty() then
		local boxHand, nHandCount = Hand_Get()
		AuctionPanel.OnExchangeBoxItem(this, boxHand, nHandCount, true)
	end
end

function AuctionPanel.OnItemLButtonDrag()
	this:SetObjectPressed(0)
	if Hand_IsEmpty() then
		if not this:IsEmpty() then
			if IsCursorInExclusiveMode() then
				OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CANCEL_CURSOR_STATE)
				PlayTipSound("010")
			else
				RemoveUILockItem("Auction")
				Hand_Pick(this)
				AuctionPanel.ClearBox(this)
				AuctionPanel.UpdateSaleInfo(this:GetRoot(), true)
			end
		end
	end
end

function AuctionPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Sale" then
		AuctionPanel.AuctionSell(this:GetRoot())
	elseif szName == "Btn_Bid" then
		local hList = this:GetParent():Lookup("", "Handle_List")
		local hItem = AuctionPanel.GetSelectedItem(hList)
		AuctionPanel.AuctionBid(hItem)

	elseif szName == "Btn_BidDefault" then
		local hList = this:GetParent():Lookup("", "Handle_List")
		local hItem = AuctionPanel.GetSelectedItem(hList)
		AuctionPanel.AuctionBuy(hItem, "Search")

	elseif szName == "Btn_ACancel" then
		local hList = this:GetParent():Lookup("", "Handle_AList")
		local hItem = AuctionPanel.GetSelectedItem(hList)
		AuctionPanel.AuctionCancel(hItem)

	elseif szName == "Btn_Buy" then
		local hList = this:GetParent():Lookup("", "Handle_BidList")
		local hItem = AuctionPanel.GetSelectedItem(hList)
		AuctionPanel.AuctionBuy(hItem, "Bid")

	elseif szName == "Btn_SDefault" then
		AuctionPanel.UpdateSaleInfo(this:GetRoot(), true)

	elseif szName == "Btn_SearchDefault" then
		AuctionPanel.InitSearchInfo(this:GetRoot(), tSearchInfoDefault)
		AuctionPanel.SaveSearchInfo(this:GetRoot())

	elseif szName == "Btn_Search" then
		local frame = this:GetRoot()
		AuctionPanel.SaveSearchInfo(frame)
		local tInfo = tItemDataInfo["Search"]
		AuctionPanel.ApplyLookup(frame, "Search", tInfo.nSortType, "", 1, tInfo.bDesc)

		if not GetClientPlayer().IsAchievementAcquired(993) then
			RemoteCallToServer("OnClientAddAchievement", "Auction_Frist_Sreach")
		end

	elseif szName == "Btn_Back" then
		local tInfo = tItemDataInfo["Search"]
		AuctionPanel.ApplyLookup(this:GetRoot(), "Search", tInfo.nSortType, "", tInfo.nStart - REQUEST_DATA_COUTN, tInfo.bDesc)

	elseif szName == "Btn_Next" then
		local tInfo = tItemDataInfo["Search"]
		AuctionPanel.ApplyLookup(this:GetRoot(), "Search", tInfo.nSortType, "", tInfo.nStart + REQUEST_DATA_COUTN, tInfo.bDesc)

	elseif szName == "Btn_ABack" then
		local tInfo = tItemDataInfo["Sell"]
		AuctionPanel.ApplyLookup(this:GetRoot(), "Sell", tInfo.nSortType, GetClientPlayer().dwID, tInfo.nStart - REQUEST_DATA_COUTN, tInfo.bDesc)

	elseif szName == "Btn_ANext" then
		local tInfo = tItemDataInfo["Sell"]
		AuctionPanel.ApplyLookup(this:GetRoot(), "Sell", tInfo.nSortType, GetClientPlayer().dwID, tInfo.nStart + REQUEST_DATA_COUTN, tInfo.bDesc)

	elseif szName == "Btn_BBack" then
		local tInfo = tItemDataInfo["Bid"]
		AuctionPanel.ApplyLookup(this:GetRoot(), "Bid", tInfo.nSortType, GetClientPlayer().dwID, tInfo.nStart - REQUEST_DATA_COUTN, tInfo.bDesc)

	elseif szName == "Btn_BNext" then
		local tInfo = tItemDataInfo["Bid"]
		AuctionPanel.ApplyLookup(this:GetRoot(), "Bid", tInfo.nSortType, GetClientPlayer().dwID, tInfo.nStart + REQUEST_DATA_COUTN, tInfo.bDesc)

	elseif szName == "Btn_Close" then
		AuctionPanel.Close()
	else
		BlackMarket.OnLButtonClick()
	end

	PlaySound(SOUND.UI_SOUND,g_sound.Button)
end

function AuctionPanel.OnItemMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	local szName = this:GetName()
	if szName == "Handle_List" then
		this:GetParent():GetParent():Lookup("Scroll_Result"):ScrollNext(nDistance)
	elseif szName == "Handle_AList" then
		this:GetParent():GetParent():Lookup("Scroll_Auction"):ScrollNext(nDistance)
	elseif szName == "Handle_BidList" then
		this:GetParent():GetParent():Lookup("Scroll_Bid"):ScrollNext(nDistance)
	elseif szName == "Handle_SearchList" then
		this:GetParent():GetParent():Lookup("Scroll_Search"):ScrollNext(nDistance)
	end
	return true
end

function AuctionPanel.OnLButtonDown()
	local szName = this:GetName()

	if szName == "Btn_Item" then
		local text = this:GetParent():Lookup("", "Text_Time")
		AuctionPanel.PopupMenu(this, text, g_tAuctionString.tAuctionTime)
		return true

	elseif szName == "Btn_Quality" then
		local tData = {}
		for k, v in pairs(g_tAuctionString.tSearchQuality) do
			table.insert(tData, k)
		end
		function Cmp(a, b)
			return g_tAuctionString.tSearchQuality[a] < g_tAuctionString.tSearchQuality[b]
		end
		table.sort(tData, Cmp)
		table.insert(tData, 1, g_tAuctionString.STR_ITEM_QUALITY)

		local text = this:GetParent():Lookup("", "Text_Quality")
		AuctionPanel.PopupMenu(this, text, tData)

		if not GetClientPlayer().IsAchievementAcquired(994) then
			RemoteCallToServer("OnClientAddAchievement", "Auction_Frist_Filter")
		end
		return true
	elseif szName == "Btn_ItemState" then
		local tData = {g_tAuctionString.STR_ITEM_STATUS,}
		for k, v in pairs(g_tAuctionString.tSearchStatus) do
			table.insert(tData, k)
		end

		local text = this:GetParent():Lookup("", "Text_ItemState")
		AuctionPanel.PopupMenu(this, text, tData)

		if not GetClientPlayer().IsAchievementAcquired(994) then
			RemoteCallToServer("OnClientAddAchievement", "Auction_Frist_Filter")
		end
		return true
	end
	AuctionPanel.OnLButtonHold()
end

function AuctionPanel.OnLButtonHold()
	local szName = this:GetName()
	if szName == "Btn_RUp" then
		this:GetParent():Lookup("Scroll_Result"):ScrollPrev()
	elseif szName == "Btn_RDown" then
		this:GetParent():Lookup("Scroll_Result"):ScrollNext()
	elseif szName == "Btn_AUp" then
		this:GetParent():Lookup("Scroll_Auction"):ScrollPrev()
	elseif szName == "Btn_ADown" then
		this:GetParent():Lookup("Scroll_Auction"):ScrollNext()
	elseif szName == "Btn_BUp" then
		this:GetParent():Lookup("Scroll_Bid"):ScrollPrev()
	elseif szName == "Btn_BDown" then
		this:GetParent():Lookup("Scroll_Bid"):ScrollNext()
	elseif szName == "Btn_SUp" then
		this:GetParent():Lookup("Scroll_Search"):ScrollPrev()
	elseif szName == "Btn_SDown" then
		this:GetParent():Lookup("Scroll_Search"):ScrollNext()
	end
end

local function TabFocusEdit(frame, page, tTabEdit)
	local focusEdit = Station.GetFocusWindow()
	local szName = nil
	if focusEdit then
		szName = focusEdit:GetName()
	end
				
	local nIndex = -1
	local nSize = #tTabEdit
	for k, v in ipairs(tTabEdit) do
		if v[1] == szName then
			nIndex = k + 1
			if nIndex > nSize then
				nIndex = 1
			end
			break;
		end
	end
	if nIndex == -1 then
		nIndex = 1
	end
	
	local edit = page:Lookup(tTabEdit[nIndex][2].."/"..tTabEdit[nIndex][1]);
	edit:SelectAll()
	Station.SetFocusWindow(edit)
end

function AuctionPanel.OnFrameKeyDown()
	local szKey = GetKeyName(Station.GetMessageKey())

	local pageBusin = this:Lookup("PageSet_Totle/Page_Business")   
	local pageAuction = this:Lookup("PageSet_Totle/Page_Auction")
	if szKey == "Enter" and pageBusin:IsVisible() then
		local hWnd = this:Lookup("PageSet_Totle/Page_Business/Wnd_Search")
		local btn  = hWnd:Lookup("Btn_Search")

		local thisSave = this
		this = btn
		if hWnd and hWnd:IsVisible() and btn:IsEnabled() then
			AuctionPanel.OnLButtonClick()
		end
		this = thisSave
		return 1
	
	elseif szKey == "Tab" then 
		if pageBusin and pageBusin:IsVisible()  then
			TabFocusEdit(frame, pageBusin, TabEditBusiness)
		elseif pageAuction and pageAuction:IsVisible() then
			TabFocusEdit(frame, pageAuction, TabEditSale)
		end
		return 1
	end
	return 0
end

function AuctionPanel.PopupMenu(hBtn, text, tData)
	if hBtn.bIgnor then
		hBtn.bIgnor = nil
		return
	end

	local szName = hBtn:GetName()
	local xT, yT = text:GetAbsPos()
	local wT, hT = text:GetSize()
	local menu =
	{
		nMiniWidth = wT,
		x = xT, y = yT + hT,
		fnCancelAction = function()
			if hBtn:IsValid() then
				local x, y = Cursor.GetPos()
				local xA, yA = hBtn:GetAbsPos()
				local w, h = hBtn:GetSize()
				if x >= xA and x < xA + w and y >= yA and y <= yA + h then
					hBtn.bIgnor = true
				end
			end
		end,
		fnAction = function(UserData)
			if text:IsValid() then
				text:SetText(UserData)
				local szTextName= text:GetName()
				if szTextName == "Text_Time" then
					AuctionPanel.UpdateSaleInfo(text:GetRoot())
				end
			end
		end,
		fnAutoClose = function() return not AuctionPanel.IsOpened() end,
	}
	if szName == "Btn_Quality" then
		for k, v in pairs(tData) do
			local r, g, b = 255, 255, 255
			if g_tAuctionString.tSearchQuality[v] then
				r, g, b = GetItemFontColorByQuality(g_tAuctionString.tSearchQuality[v])
			end
			table.insert(menu, {szOption = v, r = r, g = g, b = b ,UserData = v, rgb})
		end
	else
		for k, v in pairs(tData) do
			table.insert(menu, {szOption = v, UserData = v})
		end
	end
	PopupMenu(menu)
end

function AuctionPanel.FormatAuctionTime(nTime)
	if nTime < 600 then
		return g_tAuctionString.STR_AUCTION_NEAR_DUE
	end

	local szText = ""
	local nH, nM, nS = GetTimeToHourMinuteSecond(nTime, false)
	if nH and nH > 0 then
		if (nM and nM > 0) or (nS and nS > 0) then
			nH = nH + 1
		end
		szText = szText..nH..g_tStrings.STR_BUFF_H_TIME_H
	else
		nM = nM or 0
		nS = nS or 0
		if nM == 0 and nS == 0 then
			return szText
		end

		if nS > 0 then
			nM = nM + 1
		end

		if nM >= 60 then
			szText = szText..math.ceil(nM / 60)..g_tStrings.STR_BUFF_H_TIME_H
		else
			szText = szText..nM..g_tStrings.STR_BUFF_H_TIME_M
		end
	end

	return szText
end

local function CheckUnitPrice(frame, bUnitPrice, szType, tCheckName, hList)
	local szKey = ""
	if szType == "Bid" or szType == "Sell" then
		szKey = GetClientPlayer().dwID
	end
	
	local tInfo = tItemDataInfo[szType]
	tInfo.bUnitPrice = bUnitPrice
	if tInfo.szCheckName == tCheckName[1] or  tInfo.szCheckName == tCheckName[2] then
		if tInfo.nTotCount > 0 then
			AuctionPanel.ApplyLookup(frame, szType, tInfo.nSortType, szKey, 1, tInfo.bDesc)
		end
	else
		AuctionPanel.UpdateItemPriceInfo(hList, szType)
	end
end
	
function AuctionPanel.OnCheckBoxCheck()
	local frame = this:GetRoot()
	if frame.bIniting then
		return
	end
	
	local szName = this:GetName()
	if szName == "CheckBox_State" then
		local tInfo = tItemDataInfo["Bid"]
		AuctionPanel.ApplyLookup(this:GetRoot(), "Bid", tInfo.nSortType, GetClientPlayer().dwID, 1, tInfo.bDesc)
	elseif szName == "CheckBox_Auction" then
		local tInfo = tItemDataInfo["Sell"]
		AuctionPanel.ApplyLookup(this:GetRoot(), "Sell", tInfo.nSortType, GetClientPlayer().dwID, 1, tInfo.bDesc)
	elseif szName == "CheckBox_PerValue" then
		local hList = this:GetParent():Lookup("", "Handle_List")
		local tCheckName = {"CheckBox_Price", "CheckBox_Bid"}
		CheckUnitPrice(this:GetRoot(), true, "Search", tCheckName, hList)
		
	elseif szName == "CheckBox_PerValueBid" then
		local hList = this:GetParent():Lookup("", "Handle_BidList")
		local tCheckName = {"CheckBox_BPrice", "CheckBox_BBid"}
		CheckUnitPrice(this:GetRoot(), true, "Bid", tCheckName, hList)
		
	elseif szName == "CheckBox_PerValueAuction" then
		local hList = this:GetParent():Lookup("", "Handle_AList")
		local tCheckName = {"CheckBox_APrice", "CheckBox_ABid"}
		CheckUnitPrice(this:GetRoot(), true, "Sell", tCheckName, hList)
	elseif szName == "CheckBox_Contraband" then
		BlackMarket.Open(frame, AuctionPanel.dwTargetID)
	else
		AuctionPanel.OnSortStateUpdate(this)
	end
	PlaySound(SOUND.UI_SOUND, g_sound.Button)
end

function AuctionPanel.OnCheckBoxUncheck()
	local frame = this:GetRoot()
	if frame.bIniting then
		return
	end

	local szName = this:GetName()
	if szName == "CheckBox_PerValue" then
		local hList = this:GetParent():Lookup("", "Handle_List")
		local tCheckName = {"CheckBox_Price", "CheckBox_Bid"}
		CheckUnitPrice(this:GetRoot(), false, "Search", tCheckName, hList)

	elseif szName == "CheckBox_PerValueBid" then
		local hList = this:GetParent():Lookup("", "Handle_BidList")
		local tCheckName = {"CheckBox_BPrice", "CheckBox_BBid"}
		CheckUnitPrice(this:GetRoot(), false, "Bid", tCheckName, hList)
		
	elseif szName == "CheckBox_PerValueAuction" then
		local hList = this:GetParent():Lookup("", "Handle_AList")
		local tCheckName = {"CheckBox_APrice", "CheckBox_ABid"}
		CheckUnitPrice(this:GetRoot(), false, "Sell", tCheckName, hList)
		
	else
		AuctionPanel.OnSortStateUpdate(this)
	end

	PlaySound(SOUND.UI_SOUND, g_sound.Button)
end

function AuctionPanel.OnSortStateUpdate(hCheckBox)
	local szDataType, szKey = "", ""
	local hWnd = hCheckBox:GetParent()
	local szWndName = hWnd:GetName()
	if szWndName == "Wnd_Result2" then
		szDataType = "Search"
	elseif szWndName == "Wnd_Bid" then
		szDataType = "Bid"
		szKey = GetClientPlayer().dwID
	elseif szWndName == "Wnd_Auction" then
		szDataType = "Sell"
		szKey = GetClientPlayer().dwID
	else
		return
	end

	local tWdiget = tItemWidgetInfo[szDataType].tCheck
	local tInfo   = tItemDataInfo[szDataType]

	local szName = hCheckBox:GetName()
	for k, v in pairs(tWdiget) do
		local hCheckB = hWnd:Lookup(k)
		local imgUp   = hCheckB:Lookup("", v.imgUp)
		local imgDown = hCheckB:Lookup("", v.imgDown)
		if hCheckB:GetName() ~= szName then
			imgUp:Hide()
			imgDown:Hide()
		else
			if not imgDown:IsVisible() then
				imgDown:Show()
				imgUp:Hide()
				tItemDataInfo[szDataType].bDesc = 1
			else
				imgDown:Hide()
				imgUp:Show()
				tItemDataInfo[szDataType].bDesc = 0
			end
		end
	end
	tItemDataInfo[szDataType].szCheckName = szName
	tItemDataInfo[szDataType].nSortType = tWdiget[szName].nSortType

	if tInfo.nTotCount > 0 then
		AuctionPanel.ApplyLookup(hCheckBox:GetRoot(), szDataType, tInfo.nSortType, szKey, 1, tInfo.bDesc)
	end
end

function AuctionPanel.OnItemDataInfoUpdate(hWnd, szDataType)
	local player = GetClientPlayer()
	local btnBack, btnNext, text = nil, nil, nil
	if szDataType == "Search" then
		btnBack = hWnd:Lookup("Btn_Back")
		btnNext = hWnd:Lookup("Btn_Next")
		text    = hWnd:Lookup("", "Text_Page")
	elseif szDataType == "Sell" then
		btnBack = hWnd:Lookup("Btn_ABack")
		btnNext = hWnd:Lookup("Btn_ANext")
		text    = hWnd:Lookup("", "Text_APage")
	elseif szDataType == "Bid" then
		btnBack = hWnd:Lookup("Btn_BBack")
		btnNext = hWnd:Lookup("Btn_BNext")
		text    = hWnd:Lookup("", "Text_BidPage")
	end

	local nTotal    = tItemDataInfo[szDataType].nTotCount
	local nCurCount = tItemDataInfo[szDataType].nCurCount
	local nStart    = tItemDataInfo[szDataType].nStart

	local nEnd = nStart + nCurCount - 1
	btnBack:Enable(nStart ~= 1)
	btnNext:Enable(nEnd < nTotal)
	if nTotal == 0 then
		text:SetText("(0-0(0))")
	else
		if nEnd > nTotal then
			local szText = ""
			local nLargest = GetIntergerBit(nTotal)
			for i = 1, nLargest do
				szText = szText .. "?"
			end
			text:SetText(szText.."-"..szText.." ("..nTotal..")")
		else
			text:SetText(nStart.."-"..nEnd.." ("..nTotal..")")
		end
	end
end

function AuctionPanel.OnSetFocus()
  	local szName = this:GetName()
  	if szName == "Edit_ItemName" then
  		if not AuctionPanel.bEditItemName then
  			AuctionPanel.bEditItemName = true
  			this:SetText("")
  		else
  			this:SelectAll()
  		end
  	end
end

function AuctionPanel.OnKillFocus()
	local szName = this:GetName()
  	if szName == "Edit_ItemName" then
  		local szText = this:GetText()
  		if not szText or szText == "" then
  			AuctionPanel.bEditItemName = nil
  			this:SetText(g_tAuctionString.STR_ITEM_NAME)
  		end
  	end
end

function AuctionPanel.OnEditChanged()
	local szName = this:GetName()
	if szName == "Edit_OPGold" or szName == "Edit_OPSilver" or
	   szName == "Edit_OPCopper" or szName == "Edit_PGold" or
	   szName == "Edit_PSilver" or szName == "Edit_PCopper" then
		local hWnd = this:GetParent()
		local box = hWnd:Lookup("", "Box_Item")
		if box:IsEmpty() or hWnd.bSeting then
			return
		end
		
		local btnSale = hWnd:Lookup("Btn_Sale")
		local editOPG = hWnd:Lookup("Edit_OPGold")
		local editOPS = hWnd:Lookup("Edit_OPSilver")
		local editOPC = hWnd:Lookup("Edit_OPCopper")

		local editPG = hWnd:Lookup("Edit_PGold")
		local editPS = hWnd:Lookup("Edit_PSilver")
		local editPC = hWnd:Lookup("Edit_PCopper")
		local textUPG = hWnd:Lookup("", "Text_PVGold")
		local textUPS = hWnd:Lookup("", "Text_PVSliver")
		local textUPC = hWnd:Lookup("", "Text_PVCopper")

		local nGold   	= FormatMoney(editOPG)
		local nSliver 	= FormatMoney(editOPS)
		local nCopper 	= FormatMoney(editOPC)
		tBidPrice 		= PackMoney(nGold, nSliver, nCopper)

		nGold   	= FormatMoney(editPG)
		nSliver 	= FormatMoney(editPS)
		nCopper 	= FormatMoney(editPC)
		tBuyPrice 	= PackMoney(nGold, nSliver, nCopper)

		if MoneyOptCmp(tBidPrice, PRICE_LIMITED) > 0 then
			hWnd.bSeting = true
			
			editOPG:SetText(PRICE_LIMITED.nGold)
			editOPS:SetText(0)
			editOPC:SetText(0)
			tBidPrice = clone(PRICE_LIMITED)
			
			hWnd.bSeting = nil
		end
		
		if MoneyOptCmp(tBuyPrice, PRICE_LIMITED) > 0 then
			hWnd.bSeting = true
			
			editPG:SetText(PRICE_LIMITED.nGold)
			editPS:SetText(0)
			editPC:SetText(0)
			tBuyPrice = clone(PRICE_LIMITED)
			
			hWnd.bSeting = nil
		end
		
		if  MoneyOptCmp(tBuyPrice, 0) == 0 or (MoneyOptCmp(tBidPrice, 0) ~= 0 and MoneyOptCmp(tBuyPrice, tBidPrice) >= 0) then
			btnSale.bPrice = true
			btnSale:Enable(btnSale.bSave)
		else
			btnSale.bPrice = false
			btnSale:Enable(false)
		end

		nGold, nSliver, nCopper = UnpackMoney(MoneyOptDiv(tBidPrice, box.nCount))
		textUPG:SetText(nGold)
		textUPS:SetText(nSliver)
		textUPC:SetText(nCopper)

	elseif szName == "Edit_BidGold" or szName == "Edit_BidSilver" or szName == "Edit_BidCopper" then
		AuctionPanel.UpdateSelectedInfo(this:GetRoot(), "Search")
    end
end

-------------

function AuctionPanel.IsSearchOpened()
	local frame = Station.Lookup("Normal/AuctionPanel")
	if AuctionPanel.IsOpened() then
		local hWndSrch = frame:Lookup("PageSet_Totle/Page_Business/Wnd_Search")
		if hWndSrch:IsVisible() then
			return true
		end
	end
	return false
end

function AuctionPanel.IsSellOpened()
	local frame = Station.Lookup("Normal/AuctionPanel")
	if AuctionPanel.IsOpened() then
		local hWndSale = frame:Lookup("PageSet_Totle/Page_Auction/Wnd_Sale")
		if hWndSale:IsVisible() then
			return true
		end
	end
	return false
end

function AuctionPanel.SetItemName(szName)
	if AuctionPanel.IsOpened() then
		local frame = Station.Lookup("Normal/AuctionPanel")
		local page  = frame:Lookup("PageSet_Totle/Page_Business")
		local hWndSrch = page:Lookup("Wnd_Search")
		if page and page:IsVisible() and hWndSrch and hWndSrch:IsVisible() then
			local edit = hWndSrch:Lookup("Edit_ItemName")
			edit:SetText(szName)
			AuctionPanel.bEditItemName = true
		end
	end
end

function AuctionPanel.ExchangeBagAndAuctionItem(boxBag)
	if not boxBag then
		return
	end

	if AuctionPanel.IsOpened() then
		local frame = Station.Lookup("Normal/AuctionPanel")
		local page  = frame:Lookup("PageSet_Totle/Page_Auction")
		local hWnd  = page:Lookup("Wnd_Sale")
		if page and page:IsVisible() and hWnd and hWnd:IsVisible() then
			local box = hWnd:Lookup("", "Box_Item")
			AuctionPanel.OnExchangeBoxItem(box, boxBag)
		end
	end
end

function AuctionPanel.Open(dwTargetType, dwTargetID, bDisableSound)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end

	local player = GetClientPlayer()
	if not player or player.nMoveState == MOVE_STATE.ON_DEATH then
		return
	end

	AuctionPanel.dwTargetType = dwTargetType
	AuctionPanel.dwTargetID   = dwTargetID

	Wnd.OpenWindow("AuctionPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenAuction)
	end

	FireEvent("OPEN_AUCTION")
end

function AuctionPanel.Close(bDisableSound)
	BlackMarket.Close()
	
	RemoveUILockItem("Auction")
	if AuctionPanel.IsOpened() then
		Wnd.CloseWindow("AuctionPanel")
	end

	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseAuction)
	end
end

function AuctionPanel.IsOpened()
	local frame = Station.Lookup("Normal/AuctionPanel")
	if frame and frame:IsVisible() then
		return true, frame
	end
	return false
end

function AuctionPanel._OnLoad()
	local nSize = #AuctionPanel.tItemSellInfoCache
	while nSize > MAX_SELL_INFO_CACHE_SIZE do
		table.remove(AuctionPanel.tItemSellInfoCache)
		nSize = nSize - 1
	end
end

local _event_ref
function AuctionPanel._Exit()
	BlackMarket._Exit()
	if _event_ref then
		UnRegisterEvent("CUSTOM_DATA_LOADED", _event_ref)
	end
end

_event_ref = RegisterEvent("CUSTOM_DATA_LOADED", function(szEvent) AuctionPanel.OnEvent(szEvent) end)