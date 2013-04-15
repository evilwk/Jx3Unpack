ExaminationPanel = {}
ExaminationPanel.frameSelf = nil;
ExaminationPanel.handleContents = nil;
ExaminationPanel.handleIconList = nil;
ExaminationPanel.wndExamPage = {};

ExaminationPanel.nCurrentQuestionIndex = 0;
ExaminationPanel.nLastQuestionIndex = 0;

ExaminationPanel.bCheckSystemCall = false;
ExaminationPanel.nPromoteTime = 0;				RegisterCustomData("ExaminationPanel.nPromoteTime")
ExaminationPanel.nTestType = 0;					RegisterCustomData("ExaminationPanel.nTestType")
ExaminationPanel.tExamContentList = {}; 		RegisterCustomData("ExaminationPanel.tExamContentList")

local EXAM_LISTCOUNT = 20
local EXAM_TYPE = {
	SIMPLE_SELECTION = 1,
	MULTIPLE_SELECTION = 2,
	GAP_FILLING = 3,
	IMAGE_SELECTION = 4,
}
local EXAM_TYPE_ICON_PATH = "ui\\Image\\UICommon\\CommonPanel4.UITex"
local EXAM_TYPE_ICON = {
	[EXAM_TYPE.SIMPLE_SELECTION] = {41, 37, 38, 19},
	[EXAM_TYPE.MULTIPLE_SELECTION] = {20, 21, 22, 23},
	[EXAM_TYPE.GAP_FILLING] = {32, 33, 34, 36},
	[EXAM_TYPE.IMAGE_SELECTION] = {28, 29, 30, 31},
}

function ExaminationPanel.OnFrameCreate()
	this:RegisterEvent("CUSTOM_DATA_LOADED", ExaminationPanel.OnCustomDataLoaded)
end

function ExaminationPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		ExaminationPanel:ClosePanel()
	elseif szName == "Btn_Back" then
		ExaminationPanel.RequestQuestionContent(ExaminationPanel.nCurrentQuestionIndex - 1)
	elseif szName == "Btn_Next" then
		ExaminationPanel.RequestQuestionContent(ExaminationPanel.nCurrentQuestionIndex + 1)
	end
end

function ExaminationPanel.OnItemMouseEnter()
	local nMouseX, nMouseY = Cursor.GetPos()
	local szTipInfo = g_tStrings.EXAM_TYPE_ICON_NAME[this.nType] .. "\n"
	OutputTip("<Text>text=" .. EncodeComponentsString(szTipInfo) .. " font=100 </text>", 1000, {nMouseX, nMouseY, 0, 0})	
	ExaminationPanel.UpdateExamIconsList(this, true)
end
function ExaminationPanel.OnItemMouseLeave()
	HideTip()
	ExaminationPanel.UpdateExamIconsList(this, false)
end

function ExaminationPanel.OnItemLButtonClick()
	ExaminationPanel.RequestQuestionContent(this.nOrderIndex)
end

function ExaminationPanel.OnCheckBoxCheck(event)
	if ExaminationPanel.bCheckSystemCall then
		return
	end

	local nType, nIndex = this:GetName():match("CheckBox_T(%d)No(%d)")
	nType, nIndex = tonumber(nType), tonumber(nIndex)
	if not nType then
		return
	end
	local nQuestionIndex = ExaminationPanel.nCurrentQuestionIndex
	local tExamContent = ExaminationPanel.tExamContentList[nQuestionIndex]
	
	if nType == EXAM_TYPE.SIMPLE_SELECTION or nType == EXAM_TYPE.IMAGE_SELECTION then
		for i = 1, 4 do
			if i == nIndex then
				tExamContent.tSelectionAnswer[i] = true
				if not tExamContent.bFinished then
					tExamContent.bFinished = true
					ExaminationPanel.UpdateExamIconsList()
				end
			else
				tExamContent.tSelectionAnswer[i] = false
				local checkBox = ExaminationPanel.wndExamPage[nType]:Lookup(("CheckBox_T%dNo%d"):format(nType, i))
				ExaminationPanel:SetCheckBoxState(checkBox, false)
			end
		end
	elseif nType == EXAM_TYPE.MULTIPLE_SELECTION then
		tExamContent.tSelectionAnswer[nIndex] = true
		if not tExamContent.bFinished then
			tExamContent.bFinished = true
			ExaminationPanel.UpdateExamIconsList()
		end
	end
end

function ExaminationPanel.OnCheckBoxUncheck(event)
	if ExaminationPanel.bCheckSystemCall then
		return
	end

	local nType, nIndex = this:GetName():match("CheckBox_T(%d)No(%d)")
	nType, nIndex = tonumber(nType), tonumber(nIndex)
	if not nType then
		return
	end
	local nQuestionIndex = ExaminationPanel.nCurrentQuestionIndex
	local tExamContent = ExaminationPanel.tExamContentList[nQuestionIndex]
	
	if nType == EXAM_TYPE.MULTIPLE_SELECTION then
		tExamContent.tSelectionAnswer[nIndex] = false
		for i = 1, 4 do 
			if tExamContent.tSelectionAnswer[i] then
				return
			end
		end
		
		tExamContent.bFinished = false
		ExaminationPanel.UpdateExamIconsList()
	end
end

function ExaminationPanel.OnEditChanged()
	local nQuestionIndex = ExaminationPanel.nCurrentQuestionIndex
	local tExamContent = ExaminationPanel.tExamContentList[nQuestionIndex]
	local editBox = ExaminationPanel.wndExamPage[EXAM_TYPE.GAP_FILLING]:Lookup("Edit_Anwer")
	local szAnswerText = editBox:GetText()

	tExamContent.szFillAnswer = szAnswerText
	
	if tExamContent.bFinished and szAnswerText == "" then
		tExamContent.bFinished = false
	elseif not tExamContent.bFinished and szAnswerText ~= "" then
		tExamContent.bFinished = true
	end

	ExaminationPanel.UpdateExamIconsList()
end

--------------------------------------------------------------------
function ExaminationPanel.CloneAnswerTable()
	local tClone = {}
	for i = 1, #ExaminationPanel.tExamContentList do
		tClone[i] = {}
		if ExaminationPanel.tExamContentList[i] and ExaminationPanel.tExamContentList[i].tSelectionAnswer then
			tClone[i].tSelectionAnswer = {}
			for j = 1, 4 do
				tClone[i].tSelectionAnswer[j] = ExaminationPanel.tExamContentList[i].tSelectionAnswer[j]
			end
		end
		if ExaminationPanel.tExamContentList[i] and ExaminationPanel.tExamContentList[i].szFillAnswer then
			tClone[i].dwFillAnswerHash = GetFileNameHash(ExaminationPanel.tExamContentList[i].szFillAnswer)
		end
	end
	return tClone
end

function ExaminationPanel.RequestQuestionContent(nQuestionIndex)
	if nQuestionIndex < 1 then 
		return
	end
	
	if nQuestionIndex > #ExaminationPanel.tExamContentList then
		OutputMessage("MSG_ANNOUNCE_YELLOW", "如果你已完成了答题，请向主考官申请交卷。")
		OutputMessage("MSG_SYS", "如果你已完成了答题，请向主考官申请交卷。\n")
		ExaminationPanel:ClosePanel()
		return
	end
	
	ExaminationPanel.nLastQuestionIndex = nQuestionIndex
	if ExaminationPanel.tExamContentList[nQuestionIndex].szContent then
		local image = ExaminationPanel.handleIconList:Lookup(("Image_List%02d"):format(nQuestionIndex))
		ExaminationPanel.UpdateExamContent(image)
		ExaminationPanel.UpdateTitle()
	else
		RemoteCallToServer("OnExamContentRequest", nQuestionIndex)
		ExaminationPanel.UpdateTitle(true)
	end
end

function ExaminationPanel.UpdateTitle(bIsRequesting)
	local szRequestNote = ""
	if bIsRequesting then
		szRequestNote = g_tStrings.EXAM_TITLES.REQUEST_NOTE
	end
	ExaminationPanel.frameSelf:Lookup("", "Text_Title"):SetText(g_tStrings.EXAM_TITLES.NAME:format(
		ExaminationPanel.ConversionNumber(ExaminationPanel.nPromoteTime),
		g_tStrings.EXAM_TITLES.TYPE[ExaminationPanel.nTestType],
		ExaminationPanel.ConversionNumber(ExaminationPanel.nLastQuestionIndex),
		szRequestNote
	))
end

function ExaminationPanel.OnCustomDataLoaded()
	if arg0 ~= "Role" then
		return
	end
	ExaminationPanel.UpdateExamIconsList()
end

function ExaminationPanel:SetCheckBoxState(checkBox, bCheck)
	ExaminationPanel.bCheckSystemCall = true;
	checkBox:Check(bCheck)
	ExaminationPanel.bCheckSystemCall = false;
end

function ExaminationPanel.InitExamContents(szQuestionList, nPromoteTime, nTestType)
	if ExaminationPanel.nPromoteTime == nPromoteTime and ExaminationPanel.nTestType == nTestType then
		ExaminationPanel.UpdateExamIconsList()
		return
	end
	szQuestionList = szQuestionList or ""
	ExaminationPanel.tExamContentList = {};	-- 清空原有数据
	
	for i = 1, #szQuestionList do
		local nType = tonumber(szQuestionList:sub(i, i))
		ExaminationPanel.tExamContentList[i] = {}
		ExaminationPanel.tExamContentList[i].nType = nType
		ExaminationPanel.tExamContentList[i].bFinished = false
	end
	ExaminationPanel.nPromoteTime = nPromoteTime
	ExaminationPanel.nTestType = nTestType
	ExaminationPanel.UpdateExamIconsList()
end

function ExaminationPanel.ClearExamContent()
	if not ExaminationPanel.wndExamPage then
		return
	end
	for _, wndPage in pairs(ExaminationPanel.wndExamPage) do
		if wndPage then
			local nWndPageIndex = tonumber(wndPage:GetName():match("Wnd_Type(%d)"))
			if nWndPageIndex and nWndPageIndex ~= EXAM_TYPE.GAP_FILLING then
				for i = 1, 4 do
					local checkBox = wndPage:Lookup(("CheckBox_T%dNo%d"):format(nWndPageIndex, i))
					ExaminationPanel:SetCheckBoxState(checkBox, false)
				end
			end
			wndPage:Hide()
		end
	end
end

function ExaminationPanel.UpdateExamContent(image)
	local nType = image.nType
	local tExamContent = ExaminationPanel.tExamContentList[image.nOrderIndex]
	ExaminationPanel.nCurrentQuestionIndex = image.nOrderIndex
	if not tExamContent then
		return
	end
	
	ExaminationPanel.ClearExamContent()
	ExaminationPanel.wndExamPage[nType]:Show()
	ExaminationPanel.FillContent(tExamContent.szContent)
	
	local UpdateSelectionString = function()
		if not tExamContent or not tExamContent.tSelections then
			return
		end
		
		for i = 1, 4 do
			local checkBox = ExaminationPanel.wndExamPage[nType]:Lookup(("CheckBox_T%dNo%d"):format(nType, i))
			local text = checkBox:Lookup("", ("Text_T%dNo%d"):format(nType, i))
			if tExamContent.tSelections[i] then
				text:SetText(tExamContent.tSelections[i])
				checkBox:Show()
			else
				checkBox:Hide()
			end
		end
	end
	local UpdateSelectionAnswer = function()
		if not tExamContent then
			return
		end
		if not tExamContent.tSelectionAnswer then
			tExamContent.tSelectionAnswer = {false, false, false, false}
		end
		
		for i = 1, 4 do
			local checkBox = ExaminationPanel.wndExamPage[nType]:Lookup(("CheckBox_T%dNo%d"):format(nType, i))
			tExamContent.tSelectionAnswer[i] = tExamContent.tSelectionAnswer[i] or false
			ExaminationPanel:SetCheckBoxState(checkBox, tExamContent.tSelectionAnswer[i])
		end
	end

	if nType == EXAM_TYPE.SIMPLE_SELECTION then
		UpdateSelectionString()
		UpdateSelectionAnswer()
	elseif nType == EXAM_TYPE.MULTIPLE_SELECTION then
		UpdateSelectionString()
		UpdateSelectionAnswer()
	elseif nType == EXAM_TYPE.GAP_FILLING then
		local editBox = ExaminationPanel.wndExamPage[nType]:Lookup("Edit_Anwer")
		if tExamContent.szFillAnswer then
			editBox:SetText(tExamContent.szFillAnswer)
		else
			editBox:SetText("")
		end
	elseif nType == EXAM_TYPE.IMAGE_SELECTION then
		UpdateSelectionString()
		UpdateSelectionAnswer()
		local imageQuestion = ExaminationPanel.wndExamPage[nType]:Lookup("", "Image_Type4")
		local nIconID = tonumber(Table_GetBookContent(Table_GetBookPageID(tExamContent.nBookID, tExamContent.nSegmentID, 0)))
		imageQuestion:FromIconID(nIconID)
		
		local handleImageCover = ExaminationPanel.wndExamPage[nType]:Lookup("", "Handle_Type4Cover")
		for i = 1, 9 do
			local imageCover = handleImageCover:Lookup(("Image_C%d"):format(i))
			if tExamContent.tImageMask[i] then
				imageCover:Show()
			else
				imageCover:Hide()
			end
		end
	else
		ExaminationPanel.wndExamPage[nType]:Hide()
	end
	
	-- TODO: 箭头
	local nX, nY = image:GetRelPos()
	nX = nX + 152
	nY = nY + 55
	ExaminationPanel.frameSelf:Lookup("", "Image_Arrow"):SetRelPos(nX, nY)
	ExaminationPanel.frameSelf:Lookup("", "Image_Arrow"):Show()
	ExaminationPanel.frameSelf:Lookup("", "Animate_Arrow"):SetRelPos(nX, nY)
	ExaminationPanel.frameSelf:Lookup("", "Animate_Arrow"):Show()
	ExaminationPanel.frameSelf:Lookup("", ""):FormatAllItemPos()
end

function ExaminationPanel.UpdateExamIconsList(image, bHighlight)
	local tExamContentList = ExaminationPanel.tExamContentList
	if not tExamContentList or #tExamContentList == 0 then
		return
	end
	
	if image then
		if bHighlight then
			if image.nIconState % 2 == 1 then
				image.nIconState = image.nIconState + 1
			end
		else
			if image.nIconState % 2 == 0 and image.nIconState ~= 0 then
				image.nIconState = image.nIconState - 1
			end
		end
		image.nFrame = EXAM_TYPE_ICON[image.nType][image.nIconState]
		image:SetFrame(image.nFrame)
	else
		for i = 1, EXAM_LISTCOUNT do
			local image = ExaminationPanel.handleIconList:Lookup(("Image_List%02d"):format(i))
			image.nOrderIndex = i
			if tExamContentList[i] then
				image.nType = tExamContentList[i].nType
				image.nIconState = 1
				if tExamContentList[i].bFinished then
					image.nIconState = 3
				end
				image.nFrame = EXAM_TYPE_ICON[image.nType][image.nIconState]
			
				image:SetFrame(image.nFrame)
				image:Show()
			else
				image:Hide()
			end
		end
	end
end

function ExaminationPanel.FillContent(szContents, handle)
	szContents = szContents or ""
	handle = handle or ExaminationPanel.handleContents
	if not handle then
		return
	end
	handle:Clear()
	handle:SetItemStartRelPos(0, 0)
	
	local _, tInfo = GWTextEncoder_Encode(szContents)
	for i = 1, #tInfo do
		local v = tInfo[i]
		if v.name == "text" then			--普通文本
			handle:AppendItemFromString("<text>text=" .. EncodeComponentsString(v.context) .. "font=160</text>")
		elseif v.name == "N" then			--自己的名字
        	handle:AppendItemFromString("<text>text=" .. EncodeComponentsString(GetClientPlayer().szName) .. "font=160</text>")
        elseif v.name == "C" then			--自己的体型对应的称呼
        	handle:AppendItemFromString("<text>text=" .. EncodeComponentsString(g_tStrings.tRoleTypeToName[GetClientPlayer().nRoleType]) .. "font=160</text>")
		elseif v.name == "F" then			--字体
			handle:AppendItemFromString("<text>text=" .. EncodeComponentsString(v.attribute.text) .. "font=" .. v.attribute.fontid .. "</text>")
		elseif v.name == "G" then			--4个英文空格
			local szSpace = g_tStrings.STR_TWO_CHINESE_SPACE
			if v.attribute.english then
				szSpace = "    "
			end
			handle:AppendItemFromString("<text>text=\"" .. szSpace .. "\" font=160</text>")
		else								--错误的解析，还原文本
			if v.context then
				handle:AppendItemFromString("<text>text=" .. EncodeComponentsString("<" .. v.context.. ">") .. "font=160</text>")
			end
		end
	end
	handle:FormatAllItemPos()
end

function ExaminationPanel.OpenPanel(szQuestionList, nPromoteTime, nTestType)
	ExaminationPanel.frameSelf = Station.Lookup("Normal/ExaminationPanel")
	if not ExaminationPanel.frameSelf then
		ExaminationPanel.frameSelf = Wnd.OpenWindow("ExaminationPanel")
	end
	ExaminationPanel.handleContents = ExaminationPanel.frameSelf:Lookup("", "Handle_ExamContents")
	ExaminationPanel.handleIconList = ExaminationPanel.frameSelf:Lookup("", "Handle_List")
	ExaminationPanel.wndExamPage = {
		[EXAM_TYPE.SIMPLE_SELECTION] = ExaminationPanel.frameSelf:Lookup("Wnd_Type1"),
		[EXAM_TYPE.MULTIPLE_SELECTION] = ExaminationPanel.frameSelf:Lookup("Wnd_Type2"),
		[EXAM_TYPE.GAP_FILLING] = ExaminationPanel.frameSelf:Lookup("Wnd_Type3"),
		[EXAM_TYPE.IMAGE_SELECTION] = ExaminationPanel.frameSelf:Lookup("Wnd_Type4"),
	}

	ExaminationPanel.ClearExamContent()
	ExaminationPanel.frameSelf:Show()
	ExaminationPanel.InitExamContents(szQuestionList, nPromoteTime, nTestType)
	ExaminationPanel.UpdateTitle()
	if ExaminationPanel.nCurrentQuestionIndex == 0 then
		ExaminationPanel.RequestQuestionContent(1)
	else
		ExaminationPanel.RequestQuestionContent(ExaminationPanel.nCurrentQuestionIndex)
	end
end

function ExaminationPanel:ClosePanel()
	if not ExaminationPanel.frameSelf or not ExaminationPanel.frameSelf:IsVisible() then
		return
	end
	ExaminationPanel.frameSelf:Hide()
end

function ExaminationPanel.IsOpened()
	if ExaminationPanel.frameSelf and ExaminationPanel.frameSelf:IsVisible() then
		return true
	end
	return false
end

ExaminationPanel.ConversionNumber = function(num, szSeparator, tDigTable)
	local szNum = tostring(num)
	if szNum then
		local Conversion = function(nLen, szSeparator)
			local bZero = false
			local szValidLevel = ""
			szSeparator = szSeparator or ""
			if tDigTable then
				tCharNum = tDigTable.tCharNum
				tCharDiH = tDigTable.tCharDiH
				tCharDiL = tDigTable.tCharDiL
			else
				tCharNum = g_tStrings.DIGTABLE.tCharNum
				tCharDiH = g_tStrings.DIGTABLE.tCharDiH
				tCharDiL = g_tStrings.DIGTABLE.tCharDiL
			end
			
			if num == 0 then
				return tCharNum[0]
			end
			
			return function(matched)
				local nQuotient, nRemainder = math.modf(nLen / #tCharDiL) + 1, nLen % #tCharDiL
				local szCharNum = tCharNum[tonumber(matched)]
				if nRemainder == 0 then
					nRemainder = #tCharDiL
					nQuotient = nQuotient - 1
				end

				if szCharNum == tCharNum[0] then
					bZero = true
					szCharNum = ""
				else
					if bZero then
						bZero = false
						szCharNum = tCharNum[0] .. szCharNum
					end
					szCharNum = szCharNum .. tCharDiL[nRemainder]
					szValidLevel = tCharDiH[nQuotient]
				end
		
				if nRemainder == 1 then
					szCharNum = szCharNum .. szValidLevel .. szSeparator
					szValidLevel = ""
					bZero = false
				end
				
				nLen = nLen - 1
				return szCharNum
			end
		end
		
		return (szNum:gsub("%d", Conversion(#szNum, szSeparator)))
	end
end

--ExaminationPanel.OpenPanel()
ExaminationPanel.UpdateExamIconsList()