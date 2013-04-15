----------------------------------------------------------------------
--生活技能总面板
----------------------------------------------------------------------
CraftPanel = {nLoopCount=0}

local l_tCraftSelected = {}
local l_bLearnCraft = {}
local szIniFile = "ui\\Config\\Default\\CraftPanel.ini"

local CRAFT_TABLE = 
{
    --[1] = {1, -- 采矿 2, --神农}
}

local CRAFT_TYPE =
{
    COMMON = 0,
    GATHER = 1,
    MAKE = 2,
}

local UP_FRAME =
{
    NORMAL = 17,
    OVER = 18,
    DOWN = 19,
    UNENABLE = 10,
}

local DOWN_FRAME =
{
    NORMAL = 11,
    OVER = 12,
    DOWN = 13,
    UNENABLE = 14,
}


local UP_OVER = 18
local UP_DOWN = 19
local UP_UNENABLE  = 10
local DOWN_NORMAL = 11
local DOWN_OVER = 12
local DOWN_DOWN = 13
local DOWN_UNENABLE  = 14
local FONT_DESC = 18
local FONT_NAME = 65

local l_hFrame 
local l_hPageGather
local l_hPageMake
local l_hPageCommon

local function InitObject(hFrame)
    l_hFrame = hFrame
    l_hPageGather = hFrame:Lookup("PageSet_Choose/Page_Gathering")
    l_hPageMake = hFrame:Lookup("PageSet_Choose/Page_Manufacturing")
    l_hPageCommon = hFrame:Lookup("PageSet_Choose/Page_General")
end

local function InitCraftTable()
    CRAFT_TABLE = {}
    local nCount = g_tTable.Craft:GetRowCount()
    
    for i = 2, nCount do
        local tLine = g_tTable.Craft:GetRow(i)
        CRAFT_TABLE[tLine.nType] = CRAFT_TABLE[tLine.nType]  or {}
        table.insert(CRAFT_TABLE[tLine.nType], tLine.dwProfessionID)
    end
end

InitCraftTable() --debug

local function GetCraftInfo(dwProfessionID, dwCraftID)
    local tCraft
    if not dwCraftID  then
        tCraft = g_tTable.Craft:Search(dwProfessionID)
    else
        tCraft = g_tTable.Craft:Search(dwProfessionID, dwCraftID)
    end
    
	if tCraft then
		return tCraft
	end
end

function CraftPanel.UpdateLearnCraft()
	local player = GetClientPlayer()
    local ProTab = player.GetProfession()
    for key, val in pairs(ProTab) do		
		local nProID = val.ProfessionID
        local tCraftTab = GetCraftInfo(nProID)
        if tCraftTab then
            l_bLearnCraft[tCraftTab.dwCraftID] = true
        end
    end
end

function CraftPanel.OnFrameCreate()
	this:RegisterEvent("PLAYER_EXPERIENCE_UPDATE")
	this:RegisterEvent("CRAFT_UPDATE")
	this:RegisterEvent("CRAFT_REMOVE")
	this:RegisterEvent("SYNC_ROLE_DATA_END")
	
    InitObject(this)
    InitCraftTable()
	InitFrameAutoPosInfo(this, 1, nil, nil, function() CloseCraftPanel(true) end)
end

local function UpdateCraftState(handle)
    local player = GetClientPlayer()
    if not player then
        return
	end
        
    local nCount = handle:GetItemCount() - 1
    for i = 0, nCount, 1 do
        local box = handle:Lookup(i):Lookup("Box_CraftIcon")
        OnUpdateCraftState(player, box)
    end	
end

function CraftPanel.OnFrameBreathe()
	CraftPanel.nLoopCount = CraftPanel.nLoopCount + 1
	if CraftPanel.nLoopCount == 8 then
		CraftPanel.nLoopCount = 0
        
        local hList = l_hPageGather:Lookup("", "")
        UpdateCraftState(hList)
        
        hList = l_hPageMake:Lookup("", "")
        UpdateCraftState(hList)
	end
end

function CraftPanel.OnEvent(event)
	if event == "PLAYER_EXPERIENCE_UPDATE" then
		if arg0 == GetClientPlayer().dwID then
			CraftPanel.UpdateStaminaAndThew(this)
		end
	elseif event == "SYNC_ROLE_DATA_END" then
        CraftPanel.UpdateLearnCraft()
		CraftPanel.UpdateStaminaAndThew(this)
		if l_hPageGather then
            CraftPanel.UpdateCraftList(l_hPageGather:Lookup("", ""), CRAFT_TYPE.GATHER)	
        end
        
        if l_hPageMake then
            CraftPanel.UpdateCraftList(l_hPageMake:Lookup("", ""), CRAFT_TYPE.MAKE)	
        end
        
        if l_hPageCommon then
            CraftPanel.UpdateCraftList(l_hPageCommon:Lookup("", ""), CRAFT_TYPE.COMMON)	
        end
	elseif event == "CRAFT_UPDATE" or event == "CRAFT_REMOVE" then
        CraftPanel.UpdateLearnCraft()
		if l_hPageGather then
            CraftPanel.UpdateCraftList(l_hPageGather:Lookup("", ""), CRAFT_TYPE.GATHER)	
        end
        
        if l_hPageMake then
            CraftPanel.UpdateCraftList(l_hPageMake:Lookup("", ""), CRAFT_TYPE.MAKE)	
        end
        
        if l_hPageCommon then
            CraftPanel.UpdateCraftList(l_hPageCommon:Lookup("", ""), CRAFT_TYPE.COMMON)	
        end
	end
end

function CraftPanel.OnLButtonClick()
	if this:GetName() == "Btn_Close" then
		CloseCraftPanel()
	end
end

function CraftPanel.UpdateStaminaAndThew(frame)
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local handle = frame:Lookup("", "")
	local textT  = handle:Lookup("Text_ThewExp")
	local textS  = handle:Lookup("Text_StraminaExp")
	local imageT = handle:Lookup("Image_ThewExp")
	local imageS = handle:Lookup("Image_StraminaExp")

	textT:SetText(player.nCurrentThew.."/"..player.nMaxThew)
	textT:SetFontScheme(7)	--体力字体
	imageT:SetPercentage(player.nCurrentThew/player.nMaxThew)
	
	textS:SetText(player.nCurrentStamina.."/"..player.nMaxStamina)
	textS:SetFontScheme(7)	--精力字体
	imageS:SetPercentage(player.nCurrentStamina/player.nMaxStamina)
end

function CraftPanel.SelectCraft(hList, nCraftID, szImageName)
    local nCount = hList:GetItemCount() - 1
    for i = 0,  nCount, 1 do
        local hItem = hList:Lookup(i)
        local hImage = hItem:Lookup(szImageName)
        hImage:Hide()
        if hItem.nCraftID == nCraftID then
            hImage:Show()
            l_tCraftSelected[hList.nUIType] = nCraftID
        end
    end
end

function CraftPanel.LinkCraft(nProID, nCraftID)
    local hPage, hList
    for nType, tInfo in pairs(CRAFT_TABLE) do
        for _ , nID in pairs(tInfo) do
            if nProID == nID then
                if nType == CRAFT_TYPE.GATHER then
                    hPage = l_hPageGather
                elseif nType == CRAFT_TYPE.MAKE then
                    hPage = l_hPageMake
                elseif nType == CRAFT_TYPE.COMMON then
                    hPage = l_hPageCommonx
                end
                break;
            end
        end
    end
    
    if hPage then
        hPage:GetParent():ActivePage(hPage:GetName());
    end
end

function CraftPanel.UpdateImageFunBg(hImage, szState)
    if hImage.bUnEnable then
        hImage:SetFrame(25)
        return
    end

    if szState == "Down" then
        hImage:SetFrame(24)
    elseif szState == "Over" then
        hImage:SetFrame(23)
    elseif szState == "Leave" or szState == "Normal" then
        hImage:SetFrame(22)
    end
end

function CraftPanel.OnItemMouseEnter()
	local szName = this:GetName()
	if szName == "Text_ThewExp" then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		local player = GetClientPlayer()
		local szTip = "<text>text="..EncodeComponentsString(FormatString(g_tStrings.CURRENT_THEW, player.nCurrentThew.."/"..player.nMaxThew)).." font=65 </text><text>text="
			..EncodeComponentsString(g_tStrings.MAIN_TIP3).." font=106 </text>"
		OutputTip(szTip, 400, {x, y, w, h, 1})
	elseif szName == "Text_StraminaExp" then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		local player = GetClientPlayer()
		local szTip = "<text>text="..EncodeComponentsString(FormatString(g_tStrings.CURRENT_STAMINA, player.nCurrentStamina.."/"..player.nMaxStamina)).." font=65 </text><text>text="
			..EncodeComponentsString(g_tStrings.MAIN_TIP4).." font=106 </text>"
		OutputTip(szTip, 400, {x, y, w, h, 1})
	elseif this.bCraftBox or this.bRelate then
		this:SetObjectMouseOver(true)
		local nProID, nBranchID, nCraftID = this:GetObjectData()
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputCraftTip(nProID, nBranchID, nCraftID, {x, y, w, h})
    elseif szName == "Btn_Master" then
        local szTitle = Table_GetBranchName(this.nProID, this.nBranchID)
        local x, y  = this:GetAbsPos()
        local w, h  = this:GetSize()
        local szTip = GetFormatText(szTitle..g_tStrings.STR_CRAFT_PROFESSION, 163)
        OutputTip(szTip, 400, {x, y - 40, w, 0})
    elseif szName == "Image_Fun" then
        local x, y  = this:GetAbsPos()
        local w, h  = this:GetSize()
        local szTip = g_tStrings.STR_WAI_BAO_RESET_TIP
        OutputTip(szTip, 400, {x, y, w, h})
            
        CraftPanel.UpdateImageFunBg(this, "Over")
	end
end

function  CraftPanel.OnItemLButtonDown()
    local szName = this:GetName()
	if this.bCraftBox then
		this:SetObjectPressed(true)
		this:SetObjectStaring(false)
    elseif szName == "Image_Fun" then
        CraftPanel.UpdateImageFunBg(this, "Down")
	end
end

function CraftPanel.OnItemLButtonDrag()
	if this.bCraftBox then
        if not this:IsObjectEnable() then
            return
        end
        				
		if Hand_IsEmpty() and IsCursorInExclusiveMode() then
			OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.SRT_ERROR_CANCEL_CURSOR_STATE)
			PlayTipSound("010")
		else
			Hand_Pick(this)
		end
	end
end

function CraftPanel.OnItemRButtonClick()
    local szName = this:GetName()
	if this.bCraftBox then
        if not this:IsObjectEnable() then
            return
        end
        
		local nProID, nBranchID, nCraftID = this:GetObjectData()
		OnUseCraft(nProID, nBranchID, nCraftID, this)
        
    elseif this.bRelate then
        local nProID, nBranchID, nCraftID = this:GetObjectData()
        CraftPanel.LinkCraft(nProID, nCraftID)
    
    elseif szName == "Image_Fun" then
        local msg = 
        {
            bRichText = true,
            szMessage = g_tStrings.STR_WAI_BAO_RESET_SURE,
            szName = "WAIBAO_RESET",
            fnAutoClose = function() if not IsCraftPanelOpened() then return true end end,
            { szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() RemoteCallToServer("On_Xunbao_DeleteXunbaodian")  end},
            { szOption = g_tStrings.STR_HOTKEY_CANCEL},
        }
        MessageBox(msg);
    end
end

function CraftPanel.OnItemLButtonClick()
	CraftPanel.OnItemRButtonClick()
end				

function CraftPanel.OnItemMouseLeave()
	local szName = this:GetName()
	if szName == "Text_ThewExp" or szName == "Text_StraminaExp" or szName == "Btn_Master" then
		HideTip()
	elseif this.bCraftBox or this.bRelate then
		this:SetObjectMouseOver(false)
		HideTip()
    elseif szName == "Image_Fun" then
        CraftPanel.UpdateImageFunBg(this, "Leave")
        HideTip()
	end
end

function CraftPanel.OnItemLButtonUp()
	if this.bCraftBox then
		this:SetObjectPressed(false)
	end
end

local function AddLearnGatherCraft(hList, tProInfo, nProID, nCraftID, nUIType)
    local bLearn = true
    if not tProInfo then
        tProInfo = {}
        bLearn = false
    end
    
    local nBranchID	   = tProInfo.BranchID or 0
    local nLevel	   = tProInfo.Level or 0
    local nMaxLevel	   = tProInfo.MaxLevel or 0
    local nAdjustLevel = tProInfo.AdjustLevel or 0
    local nExp		   = tProInfo.Proficiency or 0
    local Profession   = GetProfession(nProID)

    local tCraftInfo = GetCraftInfo(nProID, nCraftID)
    
    hList.nCraftID = nCraftID
    
    local nMaxExp	   
    if bLearn then
       nMaxExp =  Profession.GetLevelProficiency(nLevel)
    end
    local hItem = hList:AppendItemFromIni(szIniFile, "Handle_Craft1")
    local szName = Table_GetCraftName(nCraftID)
	local nType = GetCraft(nCraftID).CraftType
    hItem.nCraftID = nCraftID
    
    local hName = hItem:Lookup("Handle_Name")
    hName:Clear()
    local szText = "" 
    if bLearn then
        szText = GetFormatText(szName, FONT_DESC)
        
        if nAdjustLevel and nAdjustLevel ~= 0 then
            local nMinLevel = math.min((nLevel + nAdjustLevel), nMaxLevel)
            szText = szText..GetFormatText(nMinLevel, FONT_DESC, 0, 255, 0)
        else
            szText = szText..GetFormatText(nLevel, FONT_DESC)
        end
        szText = szText..GetFormatText(g_tStrings.STR_LEVEL.." / "..nMaxLevel..g_tStrings.STR_LEVEL, FONT_DESC)
    else
        szText = GetFormatText(szName, FONT_NAME)
        local szDesc = Table_GetCraftDesc(nProID, nCraftID)
        szText = szText..GetFormatText(g_tStrings.STR_COLON)..szDesc
    end
    hName:AppendItemFromString(szText)
    hName:FormatAllItemPos()
    
    local hExpText = hItem:Lookup("Text_Experience_1")
    hExpText:Hide()
    if bLearn then
        hExpText:Show()
        hExpText:SetText(nExp.." / "..nMaxExp)
        hExpText:SetFontScheme(7)	--Exp字体
    end
    
    --Show Image--
    local hImageBg = hItem:Lookup("Image_CraftExpBg")
    hImageBg:Hide()
    
    local hImage = hItem:Lookup("Image_CraftExp")
    hImage:Hide()
    if bLearn then
        hImage:Show()
        hImageBg:Show()
        hImage:SetPercentage(nExp/nMaxExp)
    end
    
    --Show Box --
    local hBox = hItem:Lookup("Box_CraftIcon")
    hBox.bCraftBox = true
    
    hBox:SetObject(UI_OBJECT_CRAFT, nProID, nBranchID, nCraftID)
    hBox:SetObjectIcon(Table_GetCraftIconID(nProID, nCraftID))
    hBox:EnableObject(bLearn)
    
    local player = GetClientPlayer()
    if player then
        OnUpdateCraftState(player, hBox)
    end
    
    if IsCraftManagePanelOpened() then
        if nProID == CraftManagePanel.nProfessionID then
            hBox:SetObjectSelected(true)
        end
    end
    
    local hImageMaster = hItem:Lookup("Btn_Master")
    hImageMaster:Hide()
    if nBranchID ~= 0 then
        hImageMaster.nProID = nProID
        hImageMaster.nBranchID = nBranchID
        hImageMaster.nCraftID = nCraftID
        hImageMaster:Show()
    end
    
    local hRecdBox = hItem:Lookup("Box_RecdIcon")
    local hRecdBg = hItem:Lookup("IconBgR")
    hRecdBox:Hide()
    hRecdBg:Hide()
    if bLearn then
        hRecdBox:Show()
        hRecdBg:Show()
        hRecdBox.bRelate = true
        hRecdBox:SetObject(UI_OBJECT_CRAFT, tCraftInfo.dwRelateProfessionID, 0, tCraftInfo.dwRelateCraftID)
        hRecdBox:SetObjectIcon(Table_GetCraftIconID(tCraftInfo.dwRelateProfessionID, tCraftInfo.dwRelateCraftID))   
        hRecdBox:EnableObject(l_bLearnCraft[tCraftInfo.dwRelateCraftID])
    end
    hItem:FormatAllItemPos()
end

local function AddLearnCommomCraft(hList, tProInfo, nProID, nCraftID, nUIType)
    local bLearn = true
    if not tProInfo then
        tProInfo = {}
        bLearn = false
    end
    
    hList.nCraftID = nCraftID
    local hItem = hList:AppendItemFromIni(szIniFile, "Handle_Craft3")
    local szName = Table_GetCraftName(nCraftID)
    hItem.nCraftID = nCraftID
    
    local hName = hItem:Lookup("Handle_Name_3")
    hName:Clear()
    local szText = GetFormatText(szName, FONT_NAME)
    local szDesc = Table_GetCraftDesc(nProID, nCraftID)
    szText = szText..GetFormatText(g_tStrings.STR_COLON)..szDesc
    hName:AppendItemFromString(szText)
    hName:FormatAllItemPos()
    --Show Box --
    local hBox = hItem:Lookup("Box_CraftIcon_3")
    hBox.bCraftBox = true
	
	if nProID == 100 then
		hBox:SetObject(-1, nProID, 0, nCraftID)
	else
		hBox:SetObject(UI_OBJECT_CRAFT, nProID, 0, nCraftID)
	end
    hBox:SetObjectIcon(Table_GetCraftIconID(nProID, nCraftID))
    hBox:EnableObject(bLearn or nProID == 100)
    hBox.bCraftBox = true
    
    local hImgFun = hItem:Lookup("Image_Fun")
    hImgFun:Hide()
    if nProID == 100 then
        hImgFun:Show()
    end
    hItem:FormatAllItemPos()
end

function CraftPanel.UpdateCraftList(hList, nType)
	local player = GetClientPlayer()
    hList:Clear()
    local ProTab = player.GetProfession()
    local tProMap = {}
    for key, val in pairs(ProTab) do		
		local nProID = val.ProfessionID
        tProMap[nProID] = val
    end
    
    for _, nProID in pairs(CRAFT_TABLE[nType]) do
        local tProInfo = tProMap[nProID]
        local tCraftTab = GetCraftInfo(nProID)
        
        hList.nUIType = nType
        if nProID == 100 or  hList:GetName() == "Handle_General" then --100 = 挖宝
            AddLearnCommomCraft(hList, tProInfo, nProID, tCraftTab.dwCraftID, nType)
        else
            AddLearnGatherCraft(hList, tProInfo, nProID, tCraftTab.dwCraftID, nType)
        end
    end
    FireUIEvent("SCROLL_UPDATE_LIST", hList:GetName(), "CraftPanel", false)
end

---------------------插件重新实现方法:--------------------------------
--2, CraftPanel = nil
--2, 重载下面函数
----------------------------------------------------------------------
function OpenCraftPanel(bDisableSound)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end

	if IsCraftPanelOpened() then
		return
	end
	local frame = Station.Lookup("Normal/CraftPanel")
    if frame then
        InitObject(frame)
    end
    
	if frame and not frame:IsVisible() then
        CraftPanel.UpdateLearnCraft()
		CraftPanel.UpdateStaminaAndThew(frame)
        local hList = l_hPageGather:Lookup("", "")
		CraftPanel.UpdateCraftList(hList, CRAFT_TYPE.GATHER)
        
        hList = l_hPageMake:Lookup("", "")
        CraftPanel.UpdateCraftList(hList, CRAFT_TYPE.MAKE)
        
        hList = l_hPageCommon:Lookup("", "")
        CraftPanel.UpdateCraftList(hList, CRAFT_TYPE.COMMON)
		
        frame:Show()
		frame:BringToTop()
	end
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end	
end

function CloseCraftPanel(bDisableSound)
	if not IsCraftPanelOpened() then
		return
	end
	local frame = Station.Lookup("Normal/CraftPanel")
	if frame and frame:IsVisible() then
		frame:Hide()
	end
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end		
end

function IsCraftPanelOpened()
	local frame = Station.Lookup("Normal/CraftPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function MakeCraftSparking(nProfessionID)
	local frame = Station.Lookup("Normal/CraftPanel")
	if not frame then
		return
	end
	
    local function Update(handle)
    	local nCount = handle:GetItemCount() - 1
        for i = 0, nCount, 1 do
            local box = handle:Lookup(i):Lookup("Box_CraftIcon")
            local nProID = box:GetObjectData()
            if nProID == nProfessionID then
                box:SetObjectStaring(true)
                FireHelpEvent("OnCommentToCraft", nProfessionID, box)
            end
        end	
    end
    local hList = l_hPageGather:Lookup("", "")
    Update(hList)
	
    hList = l_hPageMake:Lookup("", "")
    Update(hList)
end

do
    RegisterScrollEvent("CraftPanel")
    UnRegisterScrollAllControl("CraftPanel")
    
    local szFramePath = "Normal/CraftPanel"
    local szWndPath = "PageSet_Choose/Page_Gathering"
    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_Up", szWndPath.."/Btn_Down", 
        szWndPath.."/Scroll_List", 
        {szWndPath, "Handle_Gathering"})
    
    szWndPath = "PageSet_Choose/Page_Manufacturing"
    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_Up_2", szWndPath.."/Btn_Down_2", 
        szWndPath.."/Scroll_List_2", 
        {szWndPath, "Handle_Manufacturing"})
    
    szWndPath = "PageSet_Choose/Page_General"
    RegisterScrollControl(
        szFramePath, 
        szWndPath.."/Btn_Up_3", szWndPath.."/Btn_Down_3", 
        szWndPath.."/Scroll_List_3", 
        {szWndPath, "Handle_General"})
end