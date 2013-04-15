local bWaintingRespond = false

HairShop = {}

local tCameraInfo = 
{
	[0] = {-30, 160, -25, 0, 150, 0 }, --rtInvalid = 0,
	[1] = {0, 160, -100, 0, 160, 150}, --rtStandardMale,     // 标准男
	[2] = {0, 155, -85, 0, 160, 150}, --rtStandardFemale,   // 标准女
	[3] = {-30, 160, -25, 0, 150, 0}, --rtStrongMale,       // 魁梧男
	[4] = {-30, 160, -25, 0, 150, 0}, --rtSexyFemale,       // 性感女
	[5] = {-30, 160, -25, 0, 150, 0}, --rtLittleBoy,        // 小男孩
	[6] = {0, 110, -80, 0, 110, 150}  --rtLittleGirl,       // 小孩女
}

local tRoleHairFileSuffix =
{
	[1] = "m2",
	[2] = "f2",
	[6] = "f1",
}

local tHairTable = 
{
	Path = "\\UI\\Scheme\\Case\\hairshop\\",
	Title = 
	{
		{f = "i", t = "nID"},
		{f = "i", t = "nRepresentID"},
	}  
}

local tHeadHairTable = 
{
	Path = "\\UI\\Scheme\\Case\\hairshop\\head_hair.txt",
	Title = 
	{
		{f = "i", t = "nHeadID"},
		{f = "b", t = "bBang"},
		{f = "b", t = "bPlait"},
	}  
}

local tReHeadIndex = 
{
	Path = "\\UI\\Scheme\\Case\\hairshop\\re_head_index.txt",
	Title = 
	{
		{f = "i", t = "nHeadID"},
		{f = "i", t = "nBangID"},
		{f = "i", t = "nPlaitID"},
		{f = "i", t = "nHairID"},
	}  
}

local tHairIndex = 
{
	[0] = "Head",  -- 头型
	[1] = "Plait", -- 辫子
	[2] = "Bang",  -- 刘海
	[3] = "Face",  -- 脸型
}

function HairShop.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
    this:RegisterEvent("MONEY_UPDATE")
	this:RegisterEvent("SYNC_COIN")
    this:RegisterEvent("HAIR_FREE_COUNT_UPDATE")
	
	HairShop.OnEvent("UI_SCALED")
end

function HairShop.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
    elseif szEvent == "MONEY_UPDATE" or 
    szEvent == "SYNC_COIN" or 
    szEvent == "HAIR_FREE_COUNT_UPDATE" 
    then
        HairShop.UpdateMyMoney(this)
	end
end

function HairShop.OnCheckBoxCheck()
    local szName = this:GetName()
    if szName == "CheckBox_HairFree" or szName == "CheckBox_FaceFree" then
        HairShop.UpdatePrice(this:GetRoot())
    end
end

function HairShop.OnCheckBoxUncheck()
    local szName = this:GetName()
    if szName == "CheckBox_HairFree" or szName == "CheckBox_FaceFree" then
        HairShop.UpdatePrice(this:GetRoot())
    end
end

function HairShop.OnLButtonClick()
	local szName = this:GetName()
	local hFrame = this:GetRoot()
	if szName == "Btn_Close" then
		CloseHairShop()
	elseif szName == "Btn_HeadL" then
		HairShop.SelectHead(hFrame, hFrame.nHeadIndex - 1)
	elseif szName == "Btn_HeadR" then
		HairShop.SelectHead(hFrame, hFrame.nHeadIndex + 1)
	elseif szName == "Btn_BangL" then
		HairShop.SelectBang(hFrame, hFrame.nBangIndex - 1)
	elseif szName == "Btn_BangR" then
		HairShop.SelectBang(hFrame, hFrame.nBangIndex + 1)
	elseif szName == "Btn_PlaitL" then
		HairShop.SelectPlait(hFrame, hFrame.nPlaitIndex - 1)
	elseif szName == "Btn_PlaitR" then
		HairShop.SelectPlait(hFrame, hFrame.nPlaitIndex + 1)
	elseif szName == "Btn_FaceL" then
		HairShop.SelectFace(hFrame, hFrame.nFaceIndex - 1)
	elseif szName == "Btn_FaceR" then
		HairShop.SelectFace(hFrame, hFrame.nFaceIndex + 1)
	elseif szName == "Btn_Cancel" then
		CloseHairShop()
	elseif szName == "Btn_Reset" then
		HairShop.Resert(hFrame)
	elseif szName == "Btn_Sure" then
		HairShop.SureBuy(hFrame)
	elseif szName == "Btn_ReCharge" then
		OpenInternetExplorer(tUrl.Recharge, true)
	end
end


function HairShop.SureBuy(hFrame)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	local nCoin = hFrame.nCoin
    local nFreeCount = hFrame.nFreeCount
	local szMsg = ""
	if nCoin > hPlayer.nCoin or nFreeCount > hPlayer.GetHairFreeCount() then
		szMsg = g_tStrings.HAIR_SHOP_LESS_COIN
		local tMsg = 
		{
			bModal = true,
			szName = "hair_shop_less_money",
			fnAutoClose = function() return not IsHairShopOpened() end,
			szMessage = szMsg,
			{szOption = g_tStrings.STR_HOTKEY_SURE},
		}
		MessageBox(tMsg)
	else
		local nFaceID, nHairID , bFaceFree, bHairFree = HairShop.GetSelectedHairRes(hFrame)
        RemoteCallToServer("OnBuyHair", nFaceID, bFaceFree, nHairID, bHairFree)
        SetHairShopWainting(true)
        local hBtnSure = hFrame:Lookup("Btn_Sure")
        hBtnSure:Enable(false)
        hFrame.bInHairBuy = true
	end
end

function HairShop.Resert(hFrame)
	hFrame.nFaceIndex = hFrame.nSelfFaceIndex
	hFrame.nHeadIndex = hFrame.nSelfHeadIndex
	hFrame.nBangIndex = hFrame.nSelfBangIndex
	hFrame.nPlaitIndex = hFrame.nSelfPlaitIndex
	
    local hHairFreeCheck = hFrame:Lookup("CheckBox_HairFree")
    local hFaceFreeCheck = hFrame:Lookup("CheckBox_FaceFree")
    hHairFreeCheck:Check(false)
    hHairFreeCheck:Check(false)
	HairShop.UpdateShop(hFrame)
	HairShop.UpdatePlayer(hFrame)
end

function HairShop.OnLButtonDown()
	local szName = this:GetName()
	local hFrame = this:GetRoot()
	if szName == "Btn_TurnRight" then
		hFrame.bTurnRight = true
	elseif szName == "Btn_TurnLeft" then
		hFrame.bTurnLeft = true
	end
end

function HairShop.OnLButtonUp()
	local szName = this:GetName()
	local hFrame = this:GetRoot()
	if szName == "Btn_TurnRight" then
		hFrame.bTurnRight = false
	elseif szName == "Btn_TurnLeft" then
		hFrame.bTurnLeft = false
	end
end

function HairShop.OnFrameBreathe()
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	if not this.dwNpcID then
		CloseHairShop()
		return
	end
	
	local hNpc = GetNpc(this.dwNpcID)
	if not hNpc or not hNpc.CanDialog(hPlayer) then
		CloseHairShop()
	end
	
	if this.bTurnRight then
		this.fRoleYaw = this.fRoleYaw - CHARACTER_ROLE_TURN_YAW
		HairShop.CharacterModelView.m_modelRole["MDL"]:SetYaw(this.fRoleYaw)
	elseif this.bTurnLeft then
		this.fRoleYaw = this.fRoleYaw + CHARACTER_ROLE_TURN_YAW
		HairShop.CharacterModelView.m_modelRole["MDL"]:SetYaw(this.fRoleYaw)
	end
end

function HairShop.InitFrame(hFrame)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	if not HairShop.tHairs then
		HairShop_InitHairs()
	end
	HairShop.InitSelfIndex(hFrame)
	HairShop.UpdateShop(hFrame)
	local hScene = hFrame:Lookup("Scene_Role")
	local nWidth, nHeight = hScene:GetSize()
	local tCamera = tCameraInfo[hPlayer.nRoleType]
	HairShop.CharacterModelView = PlayerModelView.new()
	HairShop.CharacterModelView:init()
	HairShop.CharacterModelView:SetCamera({tCamera[1], tCamera[2], tCamera[3], tCamera[4], tCamera[5], tCamera[6], math.pi / 4, nWidth / nHeight, nil, nil, true })
	hScene:SetScene(HairShop.CharacterModelView.m_scene)
	hFrame.fRoleYaw = 0
	hFrame.tRepresentID = nil
	hFrame.bTurnLeft = false
	hFrame.nTurnRight = false
	HairShop.UpdateMyMoney(hFrame)
	HairShop.ShowPlayer(hFrame)
end

function HairShop.UpdateMyMoney(hFrame)
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return
    end
    local hTotalHandle = hFrame:Lookup("", "")
    local hCoin = hTotalHandle:Lookup("Text_TongBaoCon")
    hCoin:SetText(hPlayer.nCoin)
    local nFreeCount = hPlayer.GetHairFreeCount()
    local hTextFreeCount = hTotalHandle:Lookup("Text_FreeTiemCon")
    hTextFreeCount:SetText(nFreeCount)
    
    if nFreeCount <= 0 then
        hTextFreeCount:Hide()
        hTotalHandle:Lookup("Image_FreeTimeIcon"):Hide()
        hTotalHandle:Lookup("Handle_Money2"):Hide()
    else
        hTextFreeCount:Show()
        hTotalHandle:Lookup("Image_FreeTimeIcon"):Show()
        hTotalHandle:Lookup("Handle_Money2"):Show()
    end
    HairShop.UpdateShop(hFrame)
end

function HairShop.UpdatePlayer(hFrame)
	local nFaceID, nHairID = HairShop.GetSelectedHairRes(hFrame)
	
	hFrame.tRepresentID[EQUIPMENT_REPRESENT.FACE_STYLE] = nFaceID
	hFrame.tRepresentID[EQUIPMENT_REPRESENT.HAIR_STYLE] = nHairID
	HairShop.ShowPlayer(hFrame)
end

function HairShop.GetSelectedHairRes(hFrame)
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return
    end
    
	local nFaceID = HairShop.tHairs["Face"][hFrame.nFaceIndex].nRepresentID
	local nHeadID = HairShop.tHairs["Head"][hFrame.nHeadIndex].nRepresentID
    
	local nBangID  = 0
	if hFrame.nBangIndex ~= 0 then
		nBangID = HairShop.tHairs["Bang"][hFrame.nBangIndex].nRepresentID
	end
	local nPlaitID = 0
	if hFrame.nPlaitIndex ~= 0 then
		nPlaitID = HairShop.tHairs["Plait"][hFrame.nPlaitIndex].nRepresentID
	end
	
	local tLine = g_tTable.ReHeadIndex:Search(nHeadID, nBangID, nPlaitID)
    local nHairID = tLine.nHairID
    
    local hHairFreeCheck = hFrame:Lookup("CheckBox_HairFree")
    local hFaceFreeCheck = hFrame:Lookup("CheckBox_FaceFree")
    
    local bHairFree = false
    if hHairFreeCheck:IsVisible() and hHairFreeCheck:IsCheckBoxChecked() then
        bHairFree = true
    end

    local bFaceFree = false
    if hFaceFreeCheck:IsVisible() and hFaceFreeCheck:IsCheckBoxChecked() then
        bFaceFree = true
    end
	return nFaceID, nHairID, bFaceFree, bHairFree
end

function HairShop.SelectFace(hFrame, nIndex)
	if nIndex > #HairShop.tHairs["Face"] then
		nIndex = 1
	end
	
	if nIndex < 1 then
		nIndex = #HairShop.tHairs["Face"]
	end
	hFrame.nFaceIndex = nIndex
	HairShop.UpdateShop(hFrame)
	HairShop.UpdatePlayer(hFrame)
end

function HairShop.SelectHead(hFrame, nIndex)
	if nIndex > #HairShop.tHairs["Head"] then
		nIndex = 1
	end
	
	if nIndex < 1 then
		nIndex = #HairShop.tHairs["Head"]
	end
	hFrame.nHeadIndex = nIndex
	HairShop.UpdateShop(hFrame)
	HairShop.UpdatePlayer(hFrame)
end

function HairShop.SelectPlait(hFrame, nIndex)
	if nIndex > #HairShop.tHairs["Plait"] then
		nIndex = 1
	end
	
	if nIndex < 1 then
		nIndex = #HairShop.tHairs["Plait"]
	end
	hFrame.nPlaitIndex = nIndex
	HairShop.UpdateShop(hFrame)
	HairShop.UpdatePlayer(hFrame)
end

function HairShop.SelectBang(hFrame, nIndex)
	if nIndex > #HairShop.tHairs["Bang"] then
		nIndex = 0
	end
	
	if nIndex < 0 then
		nIndex = #HairShop.tHairs["Bang"]
	end
	hFrame.nBangIndex = nIndex
	HairShop.UpdateShop(hFrame)
	HairShop.UpdatePlayer(hFrame)
end

function HairShop.CanBuyHead()
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	
	if hPlayer.dwForceID == 1 and hPlayer.GetQuestState(7440) ~= QUEST_STATE.FINISHED then
		return false
	end
	return true
end

function HairShop.UpdateShop(hFrame)
    local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end

    hHairShopClient = GetHairShop()
	if not hHairShopClient then
		return
	end
	local tFaceInfo = HairShop.tHairs["Face"][hFrame.nFaceIndex]
	local hText = hFrame:Lookup("", "Handle_CustomFace/Text_CustomFace")
	hText:SetText(g_tStrings.HAIR_SHOP_FACE .. "( " .. tFaceInfo.nID .. ")")
	local hBtnHeadL = hFrame:Lookup("Btn_HeadL")
	local hBtnHeadR = hFrame:Lookup("Btn_HeadR")
	local hBtnBangL = hFrame:Lookup("Btn_BangL")
	local hBtnBangR = hFrame:Lookup("Btn_BangR")
	local hBtnPlaitL = hFrame:Lookup("Btn_PlaitL")
	local hBtnPlaitR = hFrame:Lookup("Btn_PlaitR")
	local tHeadInfo = HairShop.tHairs["Head"][hFrame.nHeadIndex]
	hText = hFrame:Lookup("", "Handle_CustomHead/Text_CustomHead")
	hText:SetText(g_tStrings.HAIR_SHOP_HEAD .. "( " .. tHeadInfo.nID .. ")")
	local nHeadID = tHeadInfo.nRepresentID
	local bPlait, bBang = HairShop.GetHeadHairState(nHeadID)
	hText = hFrame:Lookup("", "Handle_CustomBang/Text_CustomBang")
	local szText = ""
	
	if bBang then
		hBtnBangL:Enable(true)
		hBtnBangR:Enable(true)
		if hFrame.nBangIndex == 0 then --刘海可以没有，下标为0标识没有刘海
			szText = g_tStrings.HAIR_SHOP_BAND .. "( " .. g_tStrings.STR_NONE .. ")"
		else
			local tBangInfo = HairShop.tHairs["Bang"][hFrame.nBangIndex]
			szText = g_tStrings.HAIR_SHOP_BAND .. "( " .. tBangInfo.nID .. ")"
		end
	else
		hFrame.nBangIndex = 0 --不能配刘海的发型，刘海下标置为0
		hBtnBangL:Enable(false)
		hBtnBangR:Enable(false)
		szText = g_tStrings.HAIR_SHOP_BAND .. "( " .. g_tStrings.STR_NONE .. ")"
	end
	hText:SetText(szText)
	hText = hFrame:Lookup("", "Handle_CustomPlait/Text_CustomPlait")
	szText = ""
	if bPlait then
		if hFrame.nPlaitIndex == 0 then --可以配辫子的发型，当没有选辫子时默认选择第一套辫子
			hFrame.nPlaitIndex = 1
		end
		hBtnPlaitL:Enable(true)
		hBtnPlaitR:Enable(true)
		local tPlaitInfo = HairShop.tHairs["Plait"][hFrame.nPlaitIndex]
		szText = g_tStrings.HAIR_SHOP_PLAIT .. "( " .. tPlaitInfo.nID .. ")"
	else
		hFrame.nPlaitIndex = 0 --不能配辫子的发型，辫子下标置为0
		hBtnPlaitL:Enable(false)
		hBtnPlaitR:Enable(false)
		szText = g_tStrings.HAIR_SHOP_PLAIT .. "( " .. g_tStrings.STR_NONE .. ")"
	end
	local bCanBuyHead = HairShop.CanBuyHead()
	local hTip = hFrame:Lookup("", "Text_Tip")
	if bCanBuyHead then
		hBtnHeadL:Enable(true)
		hBtnHeadR:Enable(true)
		hTip:Hide()
	else
		hBtnHeadL:Enable(false)
		hBtnHeadR:Enable(false)
		hBtnBangL:Enable(false)
		hBtnBangR:Enable(false)
		hBtnPlaitL:Enable(false)
		hBtnPlaitR:Enable(false)
		hTip:Show()
	end
	hText:SetText(szText)
	HairShop.UpdatePrice(hFrame)
	HairShop.UpdateHairBtnState(hFrame)
    local nMyFreeCount = hPlayer.GetHairFreeCount()
    local hHairFreeCheck = hFrame:Lookup("CheckBox_HairFree")
    local hFaceFreeCheck = hFrame:Lookup("CheckBox_FaceFree")
    local nRoleType = hPlayer.nRoleType
	local nFaceID, nHairID = HairShop.GetSelectedHairRes(hFrame)
    local _, nCoin, nFreeCount = hHairShopClient.GetHairPrice(nRoleType, HAIR_STYLE.FACE, nFaceID)
    local bHaveFace = hPlayer.IsHaveHair(HAIR_STYLE.FACE, nFaceID)
    if nMyFreeCount <=0 or nFreeCount <= 0 or bHaveFace then
        hFaceFreeCheck:Hide()
    else
        hFaceFreeCheck:Show()
        hFaceFreeCheck:Lookup("", "Text_FaceFree"):SetText(nFreeCount)
    end
    _, nCoin, nFreeCount = hHairShopClient.GetHairPrice(nRoleType, HAIR_STYLE.HAIR, nHairID)
    local bHaveHair = hPlayer.IsHaveHair(HAIR_STYLE.HAIR, nHairID)
    if nMyFreeCount<= 0 or nFreeCount <= 0 or bHaveHair then
        hHairFreeCheck:Hide()
    else
        hHairFreeCheck:Show()
        hHairFreeCheck:Lookup("", "Text_HairFree"):SetText(nFreeCount)
    end
end

function HairShop.UpdateHairBtnState(hFrame)
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return
    end
    
    local nFaceID, nHairID = HairShop.GetSelectedHairRes(hFrame)
    local bHaveFace = hPlayer.IsHaveHair(HAIR_STYLE.FACE, nFaceID)
    local bHaveHair = hPlayer.IsHaveHair(HAIR_STYLE.HAIR, nHairID)
    local hBtnSure = hFrame:Lookup("Btn_Sure")
    local hBtnReset = hFrame:Lookup("Btn_Reset")
    if (bHaveFace and bHaveHair) or
        hFrame.bInHairBuy
    then
        hBtnSure:Enable(false)
    else
        hBtnSure:Enable(true)
    end
    
    local tRepresentID = hPlayer.GetRepresentID()
    local nCurrentFaceID = tRepresentID[EQUIPMENT_REPRESENT.FACE_STYLE]
    local nCurrentHairID = tRepresentID[EQUIPMENT_REPRESENT.HAIR_STYLE]
	
    if nCurrentFaceID == nFaceID and nCurrentHairID == nHairID then
        hBtnReset:Enable(false)
    else
        hBtnReset:Enable(true)
    end
end

function HairShop.UpdatePrice(hFrame)
	hHairShopClient = GetHairShop()
	if not hHairShopClient then
		return
	end
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
    local hHairFreeCheck = hFrame:Lookup("CheckBox_HairFree")
    local hFaceFreeCheck = hFrame:Lookup("CheckBox_FaceFree")
	local nRoleType = hPlayer.nRoleType
	local nFaceID, nHairID = HairShop.GetSelectedHairRes(hFrame)
    local nTotalCoin = 0
    local nTotalFreeCount = 0
    local nMyFreeCount = hPlayer.GetHairFreeCount()
    local bHaveFace = hPlayer.IsHaveHair(HAIR_STYLE.FACE, nFaceID)
	if not bHaveFace then
		local _, nCoin, nFreeCount = hHairShopClient.GetHairPrice(nRoleType, HAIR_STYLE.FACE, nFaceID)
        if hFaceFreeCheck:IsCheckBoxChecked() then
            nTotalFreeCount = nTotalFreeCount + nFreeCount
        else
            nTotalCoin = nTotalCoin + nCoin
        end
	end
    
    local bHaveHair = hPlayer.IsHaveHair(HAIR_STYLE.HAIR, nHairID)
	if not bHaveHair then
		local _, nCoin, nFreeCount = hHairShopClient.GetHairPrice(nRoleType, HAIR_STYLE.HAIR, nHairID)
		if hHairFreeCheck:IsCheckBoxChecked() then
            nTotalFreeCount = nTotalFreeCount + nFreeCount
        else
            nTotalCoin = nTotalCoin + nCoin
        end
	end
	local hCoin = hFrame:Lookup("", "Handle_Money/Text_TongBao")
	hCoin:SetText(nTotalCoin)
    local hFreeCount = hFrame:Lookup("", "Handle_Money2/Text_FreeTime")
    hFreeCount:SetText(nTotalFreeCount)
    hFrame.nCoin = nTotalCoin
    hFrame.nFreeCount = nTotalFreeCount
end

function HairShop.InitSelfIndex(hFrame)
    local nFaceIndex, nHeadIndex, nBangIndex, nPlaitIndex = HairShop_GetCurrentHairIndex()
    hFrame.nSelfFaceIndex = nFaceIndex
    hFrame.nFaceIndex = nFaceIndex
    hFrame.nSelfHeadIndex = nHeadIndex
	hFrame.nHeadIndex = nHeadIndex
    hFrame.nSelfPlaitIndex = nPlaitIndex
	hFrame.nPlaitIndex = nPlaitIndex
    hFrame.nSelfBangIndex = nBangIndex
	hFrame.nBangIndex = nBangIndex
end

function HairShop_InitHairs()
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	
    if HairShop.tHairs then
        return
    end
	tHairTable.Path = tHairTable.Path .. "hairshop_" .. tRoleHairFileSuffix[hPlayer.nRoleType] ..  ".txt"
	RegisterUITable("Hair", tHairTable.Path, tHairTable.Title)
	RegisterUITable("HeadHair", tHeadHairTable.Path, tHeadHairTable.Title)
	RegisterUITable("ReHeadIndex", tReHeadIndex.Path, tReHeadIndex.Title)
	local nCount = g_tTable.Hair:GetRowCount()
	
	HairShop.tHairs = {}
	-- row one for default
	for i = 2, nCount do
		local tLine = g_tTable.Hair:GetRow(i)
		local nIndex = math.floor(tLine.nID/ 100)
		local nID = math.floor(tLine.nID % 100)
		if not HairShop.tHairs[tHairIndex[nIndex]] then
			HairShop.tHairs[tHairIndex[nIndex]] = {}
		end
        if not HairShop.tHairs["re" .. tHairIndex[nIndex]] then
            HairShop.tHairs["re" .. tHairIndex[nIndex]] = {}
        end
        HairShop.tHairs["re" .. tHairIndex[nIndex]][tLine.nRepresentID] = nID
		table.insert(HairShop.tHairs[tHairIndex[nIndex]], {["nID"] = nID, ["nRepresentID"] = tLine.nRepresentID})
	end
end

function HairShop.GetHeadHairState(nHeadID)
	local tLine = g_tTable.HeadHair:Search(nHeadID)
	if not tLine then
		return
	end
	
	return tLine.bPlait, tLine.bBang
end

function HairShop.ShowPlayer(hFrame)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	if not HairShop.CharacterModelView then
		return
	end

	if not hFrame.tRepresentID then
		local tRepresentID = hPlayer.GetRepresentID()
		tRepresentID[EQUIPMENT_REPRESENT.HELM_STYLE] = 0
		tRepresentID[EQUIPMENT_REPRESENT.HELM_COLOR] = 0
		tRepresentID[EQUIPMENT_REPRESENT.HELM_ENCHANT] = 0
		tRepresentID[EQUIPMENT_REPRESENT.WEAPON_STYLE] = 0
		tRepresentID[EQUIPMENT_REPRESENT.WEAPON_COLOR] = 0
		tRepresentID[EQUIPMENT_REPRESENT.WEAPON_ENCHANT1] = 0
		tRepresentID[EQUIPMENT_REPRESENT.WEAPON_ENCHANT2] = 0
		tRepresentID[EQUIPMENT_REPRESENT.BIG_SWORD_STYLE] = 0
		tRepresentID[EQUIPMENT_REPRESENT.BIG_SWORD_COLOR] = 0
		tRepresentID[EQUIPMENT_REPRESENT.BIG_SWORD_ENCHANT1] = 0
		tRepresentID[EQUIPMENT_REPRESENT.BIG_SWORD_ENCHANT2] = 0
		tRepresentID[EQUIPMENT_REPRESENT.BACK_EXTEND] = 0
		tRepresentID[EQUIPMENT_REPRESENT.WAIST_EXTEND] = 0
		hFrame.tRepresentID = tRepresentID
	end
	
	HairShop.CharacterModelView:UnloadModel()
	HairShop.CharacterModelView:LoadRes(hPlayer.dwID, hFrame.tRepresentID)
	HairShop.CharacterModelView:LoadModel()
	HairShop.CharacterModelView:PlayAnimation("Standard", "loop")
	
	if HairShop.CharacterModelView.m_modelRole then
		HairShop.CharacterModelView.m_modelRole["MDL"]:SetYaw(hFrame.fRoleYaw)
	end
end

function HairShop.OnFrameDestroy()
	if HairShop.CharacterModelView then
		HairShop.CharacterModelView:UnloadModel()
		HairShop.CharacterModelView:release()
		HairShop.CharacterModelView = nil
	end
end

function OpenHairShop(dwNpcID, bDisableSound)
	if not IsHairShopOpened() then
		Wnd.OpenWindow("HairShop")
	end
	
	local hFrame = Station.Lookup("Topmost/HairShop")
	hFrame:BringToTop()
	hFrame.dwNpcID = dwNpcID
	HairShop.InitFrame(hFrame)
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function IsHairShopOpened()
	local hFrame = Station.Lookup("Topmost/HairShop")
	if hFrame then
		return true
	end
	
	return false
end

function CloseHairShop(bDisableSound)
	if not IsHairShopOpened() then
		return 
	end
	if IsHairShopWainting() then
        local szMsg = g_tStrings.HAIR_SHOP_WAINTING_RESPOND
		local tMsg = 
		{
            bModal = true,
			szName = "hair_shop_waing_respond",
			szMessage = szMsg,
			{szOption = g_tStrings.STR_HOTKEY_SURE},
		}
		MessageBox(tMsg)
    end
	Wnd.CloseWindow("HairShop")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end	
end

function SetHairShopWainting(bWainting)
    bWaintingRespond = bWainting
end

function IsHairShopWainting()
    return bWaintingRespond
end

function HairShop_GetCurrentHairID()
    local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	local hHairShopClient = GetHairShop()
	if not hHairShopClient then
		return 
	end
	local tRepresentID = hPlayer.GetRepresentID()
	local nHairID = tRepresentID[EQUIPMENT_REPRESENT.HAIR_STYLE]
	local nFaceID = tRepresentID[EQUIPMENT_REPRESENT.FACE_STYLE]
	local nHeadID, nBangID, nPlaitID = hHairShopClient.GetHairIndex(nHairID)
    return nFaceID, nHeadID, nBangID, nPlaitID
end

function HairShop_GetCurrentHairIndex()
    local nFaceIndex
    local nHeadIndex
    local nPlaitIndex
    local nBangIndex
   
	local nFaceID, nHeadID, nBangID, nPlaitID = HairShop_GetCurrentHairID()
	for nIndex, tFace in ipairs(HairShop.tHairs["Face"]) do
		if tFace.nRepresentID == nFaceID then
			nFaceIndex = nIndex
			break
		end
	end
	
	for nIndex, tHead in ipairs(HairShop.tHairs["Head"]) do
		if tHead.nRepresentID == nHeadID then
			nHeadIndex = nIndex
			break
		end
	end
	
	if nPlaitID == 0 then
		nPlaitIndex = 0
	else
		for nIndex, tPlait in ipairs(HairShop.tHairs["Plait"]) do
			if tPlait.nRepresentID == nPlaitID then
				nPlaitIndex = nIndex
				break
			end
		end
	end
	
	if nBangID == 0 then
		nBangIndex = 0
	else
		for nIndex, tBand in ipairs(HairShop.tHairs["Bang"]) do
			if tBand.nRepresentID == nBangID then
				nBangIndex = nIndex
				break
			end
		end
	end
    return nFaceIndex, nHeadIndex, nBangIndex, nPlaitIndex
end

function HairShop_GetHairUIID(szHairType, nRepresentID)
    if nRepresentID == 0 then
        return 0
    end
    return HairShop.tHairs["re" .. szHairType][nRepresentID]
end

