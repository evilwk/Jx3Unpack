RandomReward = {}

local MAX_TYPE_COUNT = 4
local lc_tAdvanceBox = 
{
    [1] = {true, true, true, true},
    [2] = {true, true, true, true},
    [3] = {true, true, true, true},
    [4] = {true, true, true, true},
    [5] = {true, true, true, true},
}

local function IsImmediacyOpenBox(dwBoxTemplateID)
    if (not lc_tAdvanceBox[dwBoxTemplateID]) then
        return true;
    end
    return false
end

function RandomReward.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:Lookup("Btn_Sure"):Enable(false)
end

function RandomReward.OnFrameBreathe()
	local player = GetClientPlayer()
	local itemBox = player.GetItem(RandomReward.dwBoxBox, RandomReward.dwBoxX)
	local itemKey = player.GetItem(RandomReward.dwKeyBox, RandomReward.dwKeyX)
	
	if not itemBox or not itemKey or itemBox.dwID ~= RandomReward.dwBoxID or itemKey.dwID ~= RandomReward.dwKeyID then
		CloseRandomRewardPanel()
	end
end

function RandomReward.OnEvent(event)
	if event == "UI_SCALED" then
		if not LootList_IsOpenPosNearMouse() then
			this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
		end
	end
end

function RandomReward.InitState(frame)
    local hBtn = frame:Lookup("Btn_Sure")
    local handle = frame:Lookup("", "")
    local imagBg = handle:Lookup("Image_BackMiddle")
    local nID = RandomReward.dwBoxTemplateID
    --local boxInfo = GetAdvanceBoxInfo(nID) or {}
    local tCurrentInfo = lc_tAdvanceBox[nID] or {}
    --boxInfo.nCount or {}
    local hList = handle:Lookup("Handle_Reward")
    hList:Clear()
    for i=1, MAX_TYPE_COUNT, 1 do
        if tCurrentInfo[i] then
            local hItem = hList:AppendItemFromIni("ui/Config/Default/RandomReward.ini", "Handle_Reward"..i)
            if hItem then
                hItem.nID = i;
            end
        end
    end
    local nCount = hList:GetItemCount()
    local nSub = (44 * (MAX_TYPE_COUNT - nCount))
    local w, h = imagBg:GetSize()
    imagBg:SetSize( w, h - nSub)
    
    w, h = hList:GetSize()
    hList:SetSize(w, h - nSub)
    
    local x, y = hBtn:GetRelPos()
    hBtn:SetRelPos(x, y - nSub)
    
    w, h = handle:GetSize()
    handle:SetSize(w, h - nSub)
    
    w, h = frame:GetSize()
    frame:SetSize(w, h - nSub)
    
    hList:FormatAllItemPos()
    handle:FormatAllItemPos()
end

function RandomReward.OnItemMouseEnter()
	local szName = this:GetName()
	local img, imgB = nil
    local nIndex = nil
    for i=1, MAX_TYPE_COUNT, 1 do
        local szHandleName = "Handle_Reward"..i
        if szName == szHandleName then
            this.bOver = true
            img = this:Lookup("Image_Reward"..i.."C")
            imgB = this:Lookup("Image_Reward"..i)
            break;
        end
    end
    
	if img and imgB then
		img:Show()
		imgB:Hide()
		if this.bSel then
			img:SetAlpha(255)
		else
			img:SetAlpha(128)
		end
	end
end

function RandomReward.OnItemMouseLeave()
	local szName = this:GetName()
	local img, imgB = nil
    for i=1, MAX_TYPE_COUNT, 1 do
        local szHandleName = "Handle_Reward"..i
        if szName == szHandleName then
            this.bOver = false
            img = this:Lookup("Image_Reward"..i.."C")
            imgB = this:Lookup("Image_Reward"..i)
            break;
        end
    end

	if img and imgB then
		if this.bSel then
			img:Show()
			imgB:Hide()
			img:SetAlpha(255)
		else
			img:Hide()
			imgB:Show()
			img:SetAlpha(128)
		end
	end
end

function RandomReward.OnItemLButtonClick()
	local szName = this:GetName()
	local img, imgB = nil
    for i=1, MAX_TYPE_COUNT, 1 do
        local szHandleName = "Handle_Reward"..i
        if szName == szHandleName then
            img = this:Lookup("Image_Reward"..i.."C")
            imgB = this:Lookup("Image_Reward"..i)
            break;
        end
    end

	if img then
		local hLast, imgLast, imgLastB = nil, nil
		local handle = this:GetParent()
		for i = 1, MAX_TYPE_COUNT, 1 do
			local h = handle:Lookup("Handle_Reward"..i)
			if h and h.bSel then
				hLast = h
				imgLast = h:Lookup("Image_Reward"..i.."C")
				imgLastB = h:Lookup("Image_Reward"..i)
				break
			end
		end
		
		if hLast then
			hLast.bSel = false
			if hLast.bOver then
				imgLast:Show()
				imgLastB:Hide()
				imgLast:SetAlpha(128)
			else
				imgLast:Hide()
				imgLastB:Show()
			end
		end
		
		this.bSel = true
		img:Show()
		img:SetAlpha(255)
		imgB:Hide()
		this:GetRoot():Lookup("Btn_Sure"):Enable(true)
	end
end

function RandomReward.OnItemLButtonDBClick()
	local szName = this:GetName()
	local nIndex = nil
    for i=1, MAX_TYPE_COUNT, 1 do
        local szHandleName = "Handle_Reward"..i
        if szName == szHandleName then
            nIndex = i - 1
            break;
        end
    end
	
	if nIndex then
		UseItem(RandomReward.dwKeyBox, RandomReward.dwKeyX, SKILL_CAST_MODE.ITEM, RandomReward.dwBoxBox, RandomReward.dwBoxX, nIndex)
		CloseRandomRewardPanel()
	end
end

function RandomReward.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Sure" then
		local handle = this:GetRoot():Lookup("", "Handle_Reward")
		local nIndex = nil
		for i = 1, MAX_TYPE_COUNT, 1 do
			local h = handle:Lookup("Handle_Reward"..i)
			if h and h.bSel then
				nIndex = i - 1
				break
			end
		end
		
		if nIndex then
			UseItem(RandomReward.dwKeyBox, RandomReward.dwKeyX, SKILL_CAST_MODE.ITEM, RandomReward.dwBoxBox, RandomReward.dwBoxX, nIndex)
		end
		CloseRandomRewardPanel()
	elseif szName == "Btn_Close" then
		CloseRandomRewardPanel()
	end
end

function OpenRandomRewardPanel(dwKeyBox, dwKeyX, dwBoxBox, dwBoxX, rc, bDisableSound)
	RemoveUILockItem("RandomReward")
		
	local player = GetClientPlayer()
	local itemBox = player.GetItem(dwBoxBox, dwBoxX)
	local itemKey = player.GetItem(dwKeyBox, dwKeyX)
	
	if not itemBox or not itemKey then
		return
	end
	
	if not itemKey.nGenre == ITEM_GENRE.BOX_KEY or itemBox.nGenre ~= ITEM_GENRE.BOX or itemBox.nSub ~= BOX_SUB_TYPE.NEED_KEY then
		return
	end
	
    local itemBoxInfo = GetItemInfo(itemBox.dwTabType, itemBox.dwIndex)
    local itemkeyInfo = GetItemAdvanceBoxKeyInfo(itemBoxInfo.dwBoxTemplateID);
    if itemkeyInfo.dwID ~= itemKey.dwIndex then
    	return
    end
    
	AddUILockItem("RandomReward", dwKeyBox, dwKeyX)
	AddUILockItem("RandomReward", dwBoxBox, dwBoxX)

    RandomReward.dwBoxTemplateID = itemBoxInfo.dwBoxTemplateID
	RandomReward.dwKeyBox = dwKeyBox
	RandomReward.dwKeyX = dwKeyX
	RandomReward.dwKeyID = itemKey.dwID
	RandomReward.dwBoxBox = dwBoxBox
	RandomReward.dwBoxX = dwBoxX
	RandomReward.dwBoxID = itemBox.dwID
    
    if IsImmediacyOpenBox(itemBoxInfo.dwBoxTemplateID) then
        UseItem(RandomReward.dwKeyBox, RandomReward.dwKeyX, SKILL_CAST_MODE.ITEM, RandomReward.dwBoxBox, RandomReward.dwBoxX, 0)
        RemoveUILockItem("RandomReward")
        return
    end
    
    if IsRandomRewardPanelOpened() then
        CloseRandomRewardPanel();
    end
    
	local frame = Station.OpenWindow("RandomReward")
	RandomReward.InitState(frame);
    
	if LootList_IsOpenPosNearMouse() then
		if not rc then
			rc = {}
			rc[1], rc[2] = Cursor.GetPos()
			rc[3] = 40
			rc[4] = 40
		else
			rc[3] = math.max(rc[3], 40)
			rc[4] = math.max(rc[4], 40)
		end
		frame:CorrectPos(rc[1], rc[2], rc[3], rc[4], nPosType)
	else
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	end
	
	frame:Lookup("", "Text_Title"):SetText(GetItemNameByItem(GetPlayerItem(GetClientPlayer(), RandomReward.dwBoxBox, RandomReward.dwBoxX)))	
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end	
end

function CloseRandomRewardPanel(bDisableSound)
	RemoveUILockItem("RandomReward")
	
	Station.CloseWindow("RandomReward")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end	
end

function IsRandomRewardPanelOpened()
	local frame = Station.Lookup("Normal/RandomReward")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end