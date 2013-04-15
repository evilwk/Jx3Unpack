CraftReaderPanel = 
{
	nBookID     = -1,
	nSegmentID  = -1,
	nItemID     = -1,
	nRecipeID   = -1,
	nPageID     = -1,
	nTotalPages = 0,
	bForce      = false,
	nMark       = -1,
	szType      = nil
}

function CraftReaderPanel.OnFrameCreate()
	InitFrameAutoPosInfo(this, 2, nil, nil, function() CloseCraftReaderPanel(true) end)
end

function CraftReaderPanel.Init(frame, nBookID, nSegmentID, nItemID, nRecipeID, bForce)
	CraftReaderPanel.nBookID 	 = nBookID
	CraftReaderPanel.nSegmentID  = nSegmentID
	CraftReaderPanel.nItemID 	 = nItemID
	CraftReaderPanel.nRecipeID 	 = nRecipeID
	CraftReaderPanel.nPageID     = 1
	CraftReaderPanel.bForce 	 = bForce
	CraftReaderPanel.nTotalPages = Table_GetBookPageNumber(CraftReaderPanel.nBookID, CraftReaderPanel.nSegmentID)
	
	
	frame:Lookup("Wnd_Her"):Hide()
	frame:Lookup("Wnd_Ver"):Hide()
	frame:Lookup("Wnd_Pic"):Hide()
	
	local nMark = Table_GetBookMark(CraftReaderPanel.nBookID, CraftReaderPanel.nSegmentID)
	if nMark == 1 then
		CraftReaderPanel.szType = "Her"
		frame:Lookup("Wnd_Her"):Show()
	elseif nMark == 2 then
		CraftReaderPanel.szType = "Ver"
		frame:Lookup("Wnd_Ver"):Show()
	elseif nMark == 3 then
		CraftReaderPanel.szType = "Pic"
		frame:Lookup("Wnd_Pic"):Show()
	end
	
	CraftReaderPanel.UpdateTitle(frame)
	CraftReaderPanel.UpdateInfo(frame)
end

function CraftReaderPanel.UpdateTitle(frame)
	local szType = CraftReaderPanel.szType
	local textT = frame:Lookup("Wnd_"..szType, "Text_"..szType.."Title")
	local szName = Table_GetSegmentName(CraftReaderPanel.nBookID, CraftReaderPanel.nSegmentID)
	
	textT:SetText(szName)
	textT:SetFontScheme(40)
end

function CraftReaderPanel.UpdateInfo(frame, bPrev)
	local szType = CraftReaderPanel.szType
	if szType == "Her" then
		CraftReaderPanel.UpdateHerInfo(frame, bPrev)
	elseif szType == "Ver" then
		CraftReaderPanel.UpdateVerInfo(frame, bPrev)	
	elseif szType == "Pic" then
		CraftReaderPanel.UpdatePicInfo(frame, bPrev)
	end
end

function CraftReaderPanel.UpdateHerInfo(frame, bPrev)
	local handle = frame:Lookup("Wnd_Her", "")
	local textL = handle:Lookup("Text_HerPNumL")
	local textR = handle:Lookup("Text_HerPNumR")
	local textLInfo = handle:Lookup("Text_HerL")
	local textRInfo = handle:Lookup("Text_HerR")
	local nValue = CraftReaderPanel.nPageID
	
	if bPrev == true then
		nValue = nValue - 2
	elseif bPrev == false then
		nValue = nValue + 2		
	end

	if nValue >= 1 and nValue <= CraftReaderPanel.nTotalPages then
		CraftReaderPanel.nPageID = nValue 
		local szLeft = FormatString(g_tStrings.STR_THE_PAGE_NUMBER, NumberToChinese(nValue))
		local szLeftInfo = Table_GetBookContent(Table_GetBookPageID(CraftReaderPanel.nBookID, CraftReaderPanel.nSegmentID, nValue - 1))
		
		textL:SetText(szLeft)
		textL:SetFontScheme(160)
		
		szLeftInfo = string.gsub(szLeftInfo, "\\n", "\n")
		textLInfo:SetText(szLeftInfo)
		textLInfo:SetFontScheme(160)
		
	else
		textL:SetText("")
		textLInfo:SetText("")
	end
	
	if nValue >= 1 and nValue + 1 <= CraftReaderPanel.nTotalPages then
		local szRight = FormatString(g_tStrings.STR_THE_PAGE_NUMBER, NumberToChinese(nValue + 1))
		local szRightInfo = Table_GetBookContent(Table_GetBookPageID(CraftReaderPanel.nBookID, CraftReaderPanel.nSegmentID, nValue))
		
		
		textR:SetText(szRight)
		textR:SetFontScheme(160)
		
		szRightInfo = string.gsub(szRightInfo, "\\n", "\n")	
		textRInfo:SetText(szRightInfo)
		textRInfo:SetFontScheme(160)
	else
		textR:SetText("")
		textRInfo:SetText("")
	end
	
	CraftReaderPanel.UpdateBtns(frame)
end

function CraftReaderPanel.UpdateVerInfo(frame, bPrev)	
	local handle = frame:Lookup("Wnd_Ver", "")
	local textNum = handle:Lookup("Text_VerPNum")
	local textContent = handle:Lookup("Text_VerContent")
	local nValue = CraftReaderPanel.nPageID
	
	if bPrev == true then
		nValue = nValue - 1
	elseif bPrev == false then
		nValue = nValue + 1
	end
	
	if nValue >= 1 and nValue <= CraftReaderPanel.nTotalPages then
		CraftReaderPanel.nPageID = nValue
		local szPage = FormatString(g_tStrings.STR_THE_PAGE_NUMBER, NumberToChinese(nValue))
		local szContent = Table_GetBookContent(Table_GetBookPageID(CraftReaderPanel.nBookID, CraftReaderPanel.nSegmentID, nValue - 1))
	
		szContent = string.gsub(szContent, "\\n", "\n")
		textContent:SetText(szContent)
		textContent:SetFontScheme(180)
		
		textNum:SetText(szPage)
	else		
		textNum:SetText("")
		textContent:SetText("")
	end
	
	CraftReaderPanel.UpdateBtns(frame)
end

function CraftReaderPanel.UpdatePicInfo(frame, bPrev)
	local handle  = frame:Lookup("Wnd_Pic", "")
	local hContent = handle:Lookup("Handle_PicContent")
	local textNum  = handle:Lookup("Text_PicPNum")
	local nValue  = CraftReaderPanel.nPageID
	
	if bPrev == true then
		nValue = nValue - 1
	elseif bPrev == false then
		nValue = nValue + 1
	end
	
	if nValue >= 1 and nValue <= CraftReaderPanel.nTotalPages then
		CraftReaderPanel.nPageID = nValue
		local szPage = FormatString(g_tStrings.STR_THE_PAGE_NUMBER, NumberToChinese(nValue))
		local szContent = Table_GetBookContent(Table_GetBookPageID(CraftReaderPanel.nBookID, CraftReaderPanel.nSegmentID, nValue - 1))

		hContent:Clear()
		hContent:AppendItemFromString("<image>path=\"fromiconid\" frame="..szContent.."</image>")		
		local image = hContent:Lookup(0)
		local wC, hC = hContent:GetSize()
		local wI, hI = image:GetSize()
		local wScale = wI / wC
		local hScale = hI / hC
		
		if wScale > 1.0 or hScale > 1.0 then
			if wScale > hScale then
				wI = wI / wScale
				hI = hI / wScale
			else
				wI = wI / hScale
				hI = hI / hScale
			end
		end
		
		image:SetSize(wI, hI)
		image:SetRelPos((wC - wI) / 2, (hC - hI) / 2)
		hContent:FormatAllItemPos()
		
		textNum:SetText(szPage)
		textNum:SetFontScheme(0)
	else	
		hContent:Clear()
		textNum:SetText("")
	end
	
	CraftReaderPanel.UpdateBtns(frame)
end


function CraftReaderPanel.UpdateBtns(frame)
	local szType = CraftReaderPanel.szType
	local hWnd = frame:Lookup("Wnd_"..szType)
	local btnPrec = hWnd:Lookup("Btn_"..szType.."Prev")
	local btnNext = hWnd:Lookup("Btn_"..szType.."Next")
	local btnFinish = hWnd:Lookup("Btn_"..szType.."Finish")
	local nValue = CraftReaderPanel.nPageID
	
	if CraftReaderPanel.bForce then
		btnFinish:Show()
	else
		btnFinish:Hide()
	end
	
	if nValue > 1 then
		btnPrec:Show()
	else
		btnPrec:Hide()
	end
	
	if szType == "Her" then
		nValue = nValue + 1
	end
	
	if nValue < CraftReaderPanel.nTotalPages then
		btnNext:Show()
	else
		btnNext:Hide()
	end
end

function CraftReaderPanel.OnLButtonClick()
	local szType = CraftReaderPanel.szType
	local szName = this:GetName()
	
	if szName == "Btn_"..szType.."Finish" then
		GetClientPlayer().CastProfessionSkill(8, CraftReaderPanel.nRecipeID, TARGET.ITEM, CraftReaderPanel.nItemID)
		CloseCraftReaderPanel()
	elseif szName == "Btn_"..szType.."Exit" or szName == "Btn_"..szType.."Close" then
		CloseCraftReaderPanel()
	elseif szName == "Btn_"..szType.."Prev" then
		CraftReaderPanel.UpdateInfo(this:GetRoot(), true)
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	elseif szName == "Btn_"..szType.."Next" then
		CraftReaderPanel.UpdateInfo(this:GetRoot(), false)
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	end
end

function OpenCraftReaderPanel(nBookID, nSegmentID, nItemID, nRecipeID, bForce, bDisableSound)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end

	local frame
	if IsCraftReaderPanelOpened() then
		if CraftReaderPanel.nBookID == nBookID and CraftReaderPanel.nSegmentID == nSegmentID then
			return 
		end
		frame =  Station.Lookup("Normal/CraftReaderPanel")
	else
		frame =  Wnd.OpenWindow("CraftReaderPanel")
	end
	CraftReaderPanel.Init(frame, nBookID, nSegmentID, nItemID, nRecipeID, bForce)
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end		
end

function CloseCraftReaderPanel(bDisableSound)
	if IsCraftReaderPanelOpened() then
		Wnd.CloseWindow("CraftReaderPanel")
	end
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end		
end

function IsCraftReaderPanelOpened()
	local frame = Station.Lookup("Normal/CraftReaderPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

