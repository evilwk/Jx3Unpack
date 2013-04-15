EmotionPanel = 
{
	bDisableImage = false,
	nVersion = 0,
}

local CURRENT_VERSION = 1
local PANEL_POS_RECT = {200, 200, 25, 25}
local MAX_JIANGHU_COUNTS = 300
local INI_FILE_PATH = "UI/Config/Default/EmotionPanel.ini" 
local UITEX_FILE_PATH = "ui/Image/UICommon/Talk_face.UITex"
local FACE_ONCE_SEND_MAX_COUNT = 10

local tFaceData = 
{
	nPageSize = 70,
	nPageID = 1,
}

local tHeXieVersion1 =
{
    ["/打劫"] = true,
    ["/劫财"] = true,
    ["/劫色"] = true,
    ["/艳照"] = true,
    ["/秃驴"] = true,
    ["/好色"] = true,
}

local tFaceIcon = {}
local tSortFaceIcon = {}
local tFIconMap = {}

RegisterCustomData("Account/g_tJiangHuClient")
RegisterCustomData("Account/EmotionPanel.bDisableImage")
RegisterCustomData("Account/EmotionPanel.nVersion")
-- TODO: wangbin4

local GetMaxPageID=function(nTotSize, nPageSize)
	local nMaxPageID = math.floor(nTotSize / nPageSize)
	if (nMaxPageID * nPageSize) ~= nTotSize then
		nMaxPageID = nMaxPageID + 1
	end
	return nMaxPageID
end
	
function EmotionPanel.OnFrameCreate()
   this:RegisterEvent("JIANGHU_TABLE_UPDATE")
   
   
   EmotionPanel.InitInfo(this)
end

function EmotionPanel.InitInfo(frame)
	frame.bIniting = true
	
	if #g_tJiangHuClient == 0 then
		for k, v in pairs(g_tExpression.tJiangHu) do
			table.insert(g_tJiangHuClient, v)
		end
    end
  	
	EmotionPanel.UpdateActionInfo(frame)
   	EmotionPanel.UpdateJHInfo(frame)
   
	--imageface
	local hImage = frame:Lookup("PageSet_Main/Page_Image", ""):Lookup("Handle_Image")
	local hItem  = hImage:Lookup("Handle_Item")
	local wImg, hImg = hImage:GetSize()
	local wItem, hItem = hItem:GetSize()
	
	tFaceData.nPageSize = math.floor(wImg / wItem) * math.floor(hImg / hItem)
	tFaceData.nMaxPageID = GetMaxPageID(#tFaceIcon, tFaceData.nPageSize)
    	
   	local hCheckBox = frame:Lookup("PageSet_Main/Page_Image/CheckBox_Show")
   	hCheckBox:Check(EmotionPanel.bDisableImage)
   	
	EmotionPanel.TurnFaceIconPage(frame, 1)
	
	frame.bIniting = false
end

function EmotionPanel.UpdateJHInfoState(hItem)
	local imgDown = hItem:Lookup("Image_JHDown")
	local imgOver = hItem:Lookup("Image_JHOver")
	local imgNormal = hItem:Lookup("Image_JHNormal")
	if hItem.bDown then
		imgDown:Show()
		imgOver:Hide()
		imgNormal:Hide()
	elseif hItem.bOver then
		imgDown:Hide()
		imgOver:Show()
		imgNormal:Hide()
	else    
		imgDown:Hide()
		imgOver:Hide()
		imgNormal:Show()
	end
end

function EmotionPanel.UpdateACInfoState(hItem)
	local imgDown = hItem:Lookup("Image_ACDown")
	local imgOver = hItem:Lookup("Image_ACOver")
	local imgNormal = hItem:Lookup("Image_ACNormal")
	if hItem.bDown then
		imgDown:Show()
		imgOver:Hide()
		imgNormal:Hide()
	elseif hItem.bOver then
		imgDown:Hide()
		imgOver:Show()
		imgNormal:Hide()
	else    
		imgDown:Hide()
		imgOver:Hide()
		imgNormal:Show()
	end
end

function EmotionPanel.UpdateFaceIconState(hItem)
	local imgOver = hItem:Lookup("Image_IMOver")
	if hItem.bOver then
		imgOver:Show()
	else    
		imgOver:Hide()
	end
end

function EmotionPanel.UpdateActionInfo(frame)
	local hContent = frame:Lookup("PageSet_Main/Page_Action", "")
	hContent:Clear()
	
	for i, v in ipairs(g_tExpression.tEmotion) do
		hContent:AppendItemFromIni(INI_FILE_PATH, "Handle_ACItem", "")
	    local hItem = hContent:Lookup(i - 1)
	    hItem.szCmd = v[1]
	    hItem.szNoTarget = v[2]
	    hItem.szTarget = v[3]
	    hItem.bAction = true
	    hItem:Lookup("Text_ACName"):SetText(hItem.szCmd)
	    EmotionPanel.UpdateACInfoState(hItem)	    
	end
	EmotionPanel.UpdateACListScrollInfo(hContent)
end

function EmotionPanel.UpdateJHInfo(frame)
  local hContent = frame:Lookup("PageSet_Main/Page_JiangHu", "")
  hContent:Clear()

  local tJiangHu = g_tJiangHuClient
  for i, v in ipairs(tJiangHu) do
	hContent:AppendItemFromIni(INI_FILE_PATH, "Handle_JHItem", "")
	local hItem = hContent:Lookup(i - 1)
    
	hItem.szCmd = v[1]
	hItem.szNoTarget = v[2]
	hItem.szTarget = v[3]
	hItem.bJiangHu = true
    
	hItem:Lookup("Text_JHName"):SetText(tJiangHu[i][1])
	EmotionPanel.UpdateJHInfoState(hItem)
  end  
  EmotionPanel.UpdateJHListScrollInfo(hContent)
end

function EmotionPanel.UpdateFaceIconList(frame)
	local hContent = frame:Lookup("PageSet_Main/Page_Image", "Handle_Image")
	hContent:Clear()
	
	local tFilterData = {}
	for k, v in ipairs(tFaceIcon) do
		if v.bShow == 1 then
			table.insert(tFilterData, {nFaceID=k, tInfo=v})
		end
	end
	
	local nSize  = #tFilterData 
	local nStart = (tFaceData.nPageID - 1) * tFaceData.nPageSize + 1
	local nEnd   = math.min(nStart + tFaceData.nPageSize - 1, nSize)
	
	for i=nStart, nEnd, 1 do
		local tInfo = tFilterData[i].tInfo
		hItem = hContent:AppendItemFromIni(INI_FILE_PATH, "Handle_Item", "")
	    hItem.bFace = true
	    hItem.szCmd = tInfo.szCommand
	    hItem.nFaceID = tFilterData[i].nFaceID
	    
	    local nItemW, nItemH = hItem:GetSize()
	    if tInfo.szType == "animate" then
	    	local hAni = hItem:Lookup("Animate_Face")
	    	if hAni then
	    		hAni:SetGroup(tInfo.nFrame)
	    		hAni:Show()
	    		
	    		hAni:AutoSize()
	    		local nW, nH = hAni:GetSize()
	    		hAni:SetRelPos(math.floor((nItemW - nW)/2), math.floor((nItemH - nH)/2))
	    		hAni:AutoSize()
	    	end
	    elseif tInfo.szType == "image" then
	    	local hImage = hItem:Lookup("Image_Face")
	    	if hImage then
	    		hImage:SetFrame(tInfo.nFrame)
				hImage:Show()
				
				hImage:AutoSize()
				local nW, nH = hImage:GetSize()
				hImage:SetRelPos(math.floor((nItemW - nW)/2), math.floor((nItemH - nH)/2))
				hImage:AutoSize()
	    	end
	    end
	    hItem:FormatAllItemPos()
	end
	hContent:FormatAllItemPos()
end

function EmotionPanel.UpdateACListScrollInfo(hList)
	local page = hList:GetParent()
	local scroll = page:Lookup("Scroll_Action")
	hList:FormatAllItemPos()
	local wAll, hAll = hList:GetAllItemSize()
	local w, h = hList:GetSize()
	local nCountStep = math.ceil((hAll - h) / 20)
	scroll:SetStepCount(nCountStep)
	if nCountStep > 0 then
		scroll:Show()
		page:Lookup("Btn_ACUp"):Show()
		page:Lookup("Btn_ACDown"):Show()
	else
		scroll:Hide()
		page:Lookup("Btn_ACUp"):Hide()
		page:Lookup("Btn_ACDown"):Hide()
	end
end

function EmotionPanel.UpdateJHListScrollInfo(hList)
	local page = hList:GetParent()
	local scroll = page:Lookup("Scroll_JiangHu")
	hList:FormatAllItemPos()
	local wAll, hAll = hList:GetAllItemSize()
	local w, h = hList:GetSize()
	local nCountStep = math.ceil((hAll - h) / 20)
	scroll:SetStepCount(nCountStep)
	if nCountStep > 0 then
		scroll:Show()
		page:Lookup("Btn_JHUp"):Show()
		page:Lookup("Btn_JHDown"):Show()
	else
		scroll:Hide()
		page:Lookup("Btn_JHUp"):Hide()
		page:Lookup("Btn_JHDown"):Hide()
	end
end

function EmotionPanel.TurnFaceIconPage(frame, nPageID)
	if nPageID < 1 then
		nPageID = tFaceData.nMaxPageID
	end
	
	if nPageID > tFaceData.nMaxPageID then
		nPageID = 1
	end
	
	tFaceData.nPageID = nPageID
	
	local hTextPage = frame:Lookup("PageSet_Main/Page_Image", "Text_PageNum")
	hTextPage:SetText(nPageID.."/"..tFaceData.nMaxPageID)
	EmotionPanel.UpdateFaceIconList(frame)
end

function EmotionPanel.OnEvent(event)
	if event == "JIANGHU_TABLE_UPDATE" then
  		EmotionPanel.UpdateJHInfo(this:GetRoot())
  		
  	elseif event == "CUSTOM_DATA_LOADED" then
  		if arg0 == "Account" then
	  		local tExistCmd = {}
	  		local tRemove = {}
	  		for k, v in pairs(g_tJiangHuClient) do
	  			if string.sub(v[1], 1, 1) == "/" and not EmotionPanel.IsSpaceString(string.sub(v[1], 2)) and
					not IsChannelHeader(v[1]) and not IsEmotion(v[1]) and not tExistCmd[v[1]] and 
					not EmotionPanel.IsSpaceString(v[2]) and not EmotionPanel.IsSpaceString(v[3]) then
					
					tExistCmd[v[1]] = true
					if not string.find(v[2], "$N") then
						g_tJiangHuClient[k][2] = "$N："..g_tJiangHuClient[k][2]
					end
					
					if not string.find(v[3], "$N") then
						g_tJiangHuClient[k][3] = "$N："..g_tJiangHuClient[k][3]
					end
				else
					tRemove[v[1]] = true
					Trace("KLUA[ERROR] ui/Config/Default/Emotion.lua szCmd = "..v[1].." szTarget= "..v[2].." szNoTarget= "..v[3].." is illegal\n")
				end
	  		end
	  		local nSize  = #g_tJiangHuClient
	  		for i = nSize, 1, -1 do
	  			if tRemove[g_tJiangHuClient[i][1]] then
	  				table.remove(g_tJiangHuClient, i)
	  			end
	  		end
            
	  		EmotionPanel.ProcessVerstion()
	  		FireEvent("JIANGHU_TABLE_UPDATE")
	  	end
	end
end

function EmotionPanel.ProcessVerstion()
    if CURRENT_VERSION ~= EmotionPanel.nVersion then
        EmotionPanel.nVersion = CURRENT_VERSION
        local tRemove = {}
        local nSize = #g_tJiangHuClient
        for i = nSize, 1, -1 do
            local cmd = g_tJiangHuClient[i][1]
            if tHeXieVersion1[cmd] then
                table.remove(g_tJiangHuClient, i)
            end
        end
    end
end

function EmotionPanel.OnItemMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	local szName = this:GetName()
	if szName == "Handle_Action" then
		this:GetParent():Lookup("Scroll_Action"):ScrollNext(nDistance)
	elseif szName == "Handle_JiangHu" then
		this:GetParent():Lookup("Scroll_JiangHu"):ScrollNext(nDistance)
	end
	return 1
end

function EmotionPanel.OnItemMouseEnter()
	if this.bAction then
    	this.bOver = true
    	EmotionPanel.UpdateACInfoState(this)
    	local szNoTarget = g_tExpression.STR_EMOTION_NO_TARGET..this.szNoTarget
    	local szTarget = g_tExpression.STR_EMOTION_HAVE_TARGET..this.szTarget
    	local x, y = this:GetAbsPos()
    	local w, h = this:GetSize()
    	
    	local szTip = "<text>text="..EncodeComponentsString(szNoTarget.."\n"..szTarget).." font=18 </text>"
		OutputTip(szTip, 300, {x, y, w, h})
	elseif this.bJiangHu then
    	this.bOver = true
    	EmotionPanel.UpdateJHInfoState(this)
    	local szNoTarget = g_tExpression.STR_EMOTION_NO_TARGET..this.szNoTarget
    	local szTarget = g_tExpression.STR_EMOTION_HAVE_TARGET..this.szTarget
    	local x, y = this:GetAbsPos()
    	local w, h = this:GetSize()
    	
    	local szTip = "<text>text="..EncodeComponentsString(szNoTarget.."\n"..szTarget).." font=18 </text>"
		OutputTip(szTip, 300, {x, y, w, h})
	elseif this.bFace then
		this.bOver = true
		EmotionPanel.UpdateFaceIconState(this)
		local x, y = this:GetAbsPos()
    	local w, h = this:GetSize()
    	local szTip = "<text>text="..EncodeComponentsString(this.szCmd).." font=18 </text>"
		OutputTip(szTip, 300, {x, y, w, h})
	end
end

function EmotionPanel.OnItemMouseLeave()
	if this.bAction then
		this.bOver = false
		EmotionPanel.UpdateACInfoState(this)
		HideTip()
	elseif this.bJiangHu then
		this.bOver = false
		EmotionPanel.UpdateJHInfoState(this)
		HideTip()
	elseif this.bFace then
		this.bOver = false
		EmotionPanel.UpdateFaceIconState(this)
		HideTip()
	end
end

function EmotionPanel.OnItemLButtonDown()
	if this.bAction then
		this.bDown = true
		EmotionPanel.UpdateACInfoState(this)
	elseif this.bJiangHu then
  		this.bDown = true
  		EmotionPanel.UpdateJHInfoState(this)
	end
end

function EmotionPanel.OnItemLButtonUp()
	if this.bAction then
		this.bDown = false
		EmotionPanel.UpdateACInfoState(this)
	elseif this.bJiangHu then
		this.bDown = false
  		EmotionPanel.UpdateJHInfoState(this)
	end
end

function EmotionPanel.OnItemLButtonClick()
	local szName = this:GetName()
	if this.bAction then
		ProcessEmotion(this.szCmd)
	elseif this.bJiangHu then
  		ProcessJiangHuWord(this.szCmd)
  	elseif this.bFace then
  		EditBox_TalkSomething({type = "faceicon", text = this.szCmd, nFaceID=this.nFaceID})
  		
  	elseif szName == "Handle_Show" then
  		EmotionPanel.bDisableImage = not EmotionPanel.bDisableImage
	end
end

function EmotionPanel.OnItemLButtonDBClick()
	EmotionPanel.OnItemLButtonClick()
end

function EmotionPanel.OnLButtonDown()
	EmotionPanel.OnLButtonHold()
end

function EmotionPanel.OnLButtonHold()
	local szName = this:GetName()
	if szName == "Btn_ACUp" then
		this:GetParent():Lookup("Scroll_Action"):ScrollPrev()
	elseif szName == "Btn_ACDown" then
		this:GetParent():Lookup("Scroll_Action"):ScrollNext()
	elseif szName == "Btn_JHUp" then
		this:GetParent():Lookup("Scroll_JiangHu"):ScrollPrev()
	elseif szName == "Btn_JHDown" then
		this:GetParent():Lookup("Scroll_JiangHu"):ScrollNext()
	end
end

function EmotionPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Action_Cancel" or szName == "Btn_JiangHu_Cancel" or szName == "Btn_Smilies_Cancel" or szName == "Btn_Close" then
		CloseEmotionPanel()
	elseif szName == "Btn_JiangHu_Manage" then
		OpenEmotionManagePanel(false, PANEL_POS_RECT)
		CloseEmotionPanel()
	elseif szName == "Btn_Image_Cancel" then
		CloseEmotionPanel()
	elseif szName == "Btn_Prev" then
		EmotionPanel.TurnFaceIconPage(this:GetRoot(), tFaceData.nPageID - 1)	
	elseif szName == "Btn_Next" then
		EmotionPanel.TurnFaceIconPage(this:GetRoot(), tFaceData.nPageID + 1)	
	end
end

function EmotionPanel.OnScrollBarPosChanged()
	local nCurrentValue = this:GetScrollPos()
	local page = this:GetParent()
	local szName = this:GetName()
	if szName == "Scroll_Action" then 
		if nCurrentValue == 0 then
			page:Lookup("Btn_ACUp"):Enable(false)
		else
			page:Lookup("Btn_ACUp"):Enable(true)
		end
		
		if nCurrentValue == this:GetStepCount() then
			page:Lookup("Btn_ACDown"):Enable(false)
		else
			page:Lookup("Btn_ACDown"):Enable(true)
		end
	    page:Lookup("", ""):SetItemStartRelPos(0, - nCurrentValue * 20)
	elseif szName == "Scroll_JiangHu" then 
		if nCurrentValue == 0 then
			page:Lookup("Btn_JHUp"):Enable(false)
		else
			page:Lookup("Btn_JHUp"):Enable(true)
		end
		local nTotal = this:GetStepCount()
		if nCurrentValue == nTotal then
			page:Lookup("Btn_JHDown"):Enable(false)
		else
			page:Lookup("Btn_JHDown"):Enable(true)
		end
		page:Lookup("", ""):SetItemStartRelPos(0, - nCurrentValue * 20)
	end
end

function EmotionPanel.IsSpaceString(szContent)
	local nSize = string.len(szContent)
	local szWord = ""
	for i = 1, nSize , 1 do
		szWord = szWord.." "
	end
	if szWord == szContent then
		return true
	end
	return false
end

function EmotionPanel_ParseFaceIcon(szText, szFont, nFaceCount)
	if EmotionPanel.bDisableImage  then
		return
	end
	
	if nFaceCount and nFaceCount >= FACE_ONCE_SEND_MAX_COUNT then
		return
	end
	
	local nFaceID = tFIconMap[szText]
	if nFaceID then
		local tInfo = tFaceIcon[tonumber(nFaceID)]
		if not tInfo then
			return
		end
		
		szCmd  = tInfo.szCommand
		nFrame = tInfo.nFrame
		
		if tInfo.szType == "animate" then
			return "<animate>path="..EncodeComponentsString(UITEX_FILE_PATH).." disablescale=1 group="..nFrame.." </animate>"	
		elseif tInfo.szType == "image" then
			return "<image>path="..EncodeComponentsString(UITEX_FILE_PATH).." disablescale=1 frame="..nFrame.." </image>"	
		end
	end
	return 
end

local function FaceIcon_GetParseText(szText)	
	local tResult ={}
	local nPos, nCount, szTmp = 1, 0, ""
	local nLen = string.len(szText)
	local nMaxLen = tSortFaceIcon[1].nLen
	
	local InserText = function(szTmp)
		if not szTmp or szTmp == "" then
			return
		end
		
		if nCount ~= 0 and tResult[nCount].type == "text" then
			tResult[nCount].text = tResult[nCount].text..szTmp
		else
			table.insert(tResult, {text=szTmp, type="text"})
			nCount = nCount + 1
		end
	end
	
	while nPos <= nLen do
		local nStart, nEnd = StringFindW(szText, "#", nPos)
		if not nStart then
			szTmp = string.sub(szText, nPos)
			InserText(szTmp)
			break
		end
		
		if nStart > nPos then
			szTmp = string.sub(szText, nPos, nStart - 1)
			InserText(szTmp)
		end
		
		local bFind = false
		for i=nMaxLen - 1, 1, -1 do
			szTmp = string.sub(szText, nStart, nStart + i)
			if szTmp and tFIconMap[szTmp] then
				table.insert(tResult, {text=szTmp, type="faceicon"})
				nCount = nCount + 1
				nPos = nStart + i + 1
				bFind = true
				break
			end
		end
		
		if not bFind then
			nPos = nStart + 1	
		end
	end
	return tResult
end

function EmotionPanel_ParseFaceIconCommand(tData)
	local tResult = {}
	for k, v in ipairs(tData) do
		if v.type == "text" then
			local tText = FaceIcon_GetParseText(v.text)
			for i, t in ipairs(tText) do
				table.insert(tResult, {type="text", text=t.text})
			end
		elseif v.type == "faceicon" then
			table.insert(tResult, {type="text", text=v.text})
		else
			table.insert(tResult, v)
		end
	end
	return tResult
end

function EmotionPanel_ParseBallonText(szText, r, g, b)
	if EmotionPanel.bDisableImage then
		return GetFormatText(szText, nil ,r,g ,b)
	end
	
	local szResult = ""
	local szAni1 = "<animate>path="..EncodeComponentsString(UITEX_FILE_PATH).." disablescale=1 group="
	local szAni2 = " </animate>"
	local szImg1 = "<image>path="..EncodeComponentsString(UITEX_FILE_PATH).." disablescale=1 frame="
	local szImg2 = " </image>"
	
	local tText = FaceIcon_GetParseText(szText)
	local nCount = 0;
	for k, v in ipairs(tText) do
		if v.type == "faceicon" then
			if nCount < FACE_ONCE_SEND_MAX_COUNT then
				local nFaceID = tFIconMap[v.text]
				local nFrame, szType = tFaceIcon[nFaceID].nFrame, tFaceIcon[nFaceID].szType
				if szType == "animate" then
					szResult = szResult..szAni1..nFrame..szAni2
				elseif szType == "image" then
					szResult = szResult..szImg1..nFrame..szImg2
				end
			else
				szResult = szResult..GetFormatText(v.text, nil ,r,g ,b)
			end
			nCount = nCount + 1
		elseif v.type == "text" then
			szResult = szResult..GetFormatText(v.text, nil ,r,g ,b)
		end
	end
	return szResult
end

function OpenEmotionPanel(bDisableSound, rect)
	if IsOpenEmotionPanel() or IsOpenEmotionManagePanel() then
		return
	end
	
	local frame = Station.Lookup("Normal/EmotionPanel")
	if frame then
		frame:Show()
	else
		frame = Wnd.OpenWindow("EmotionPanel")
	end
	PANEL_POS_RECT = rect
	local w, h = frame:GetSize()
	local wA, hA = Station.GetClientSize()
	local x, y = 0, 0
	if rect[2] > h then
		y = rect[2] - h
	else
		y = rect[2] + rect[4]
	end
	
	if rect[1] + w <= wA then  
		x = rect[1]
	else
		x =  wA - w
	end
	frame:SetAbsPos(x, y)
	frame:CorrectPos()
end

function CloseEmotionPanel(bDisableSound)
  if not IsOpenEmotionPanel() then
    return
  end
  
  local frame = Station.Lookup("Normal/EmotionPanel")
  if frame then
    frame:Hide()
  end
end

function IsOpenEmotionPanel()
  local frame = Station.Lookup("Normal/EmotionPanel")
  if frame and frame:IsVisible() then
    return true
  end
  return false
end

function EmotionPanel_Load()
	local szAccount = GetUserAccount()
	local szDataFloder = GetUserDataFloder()
	
	if szAccount == "" or szDataFloder == "" then
		return
	end
	
	local szIniFile = "\\"..szDataFloder.."\\"..szAccount
	szIniFile = szIniFile.."\\EmotionPanelSave.ini"
	
	local iniS = Ini.Open(szIniFile)
	if not iniS then
		return
	end

	local szSection = "EmotionPanel"
	
	while #g_tJiangHuClient > 0 do
		table.remove(g_tJiangHuClient)
	end
	
	local i = 1
	local tExistCmd = {}
	while i <= MAX_JIANGHU_COUNTS do
		local szCmd = iniS:ReadString(szSection, "Cmd"..i, "")
		local szNoTarget = iniS:ReadString(szSection, "NoTarget"..i, "")
		local szTarget = iniS:ReadString(szSection, "Target"..i, "")
		
		if not szCmd or not szNoTarget or not szTarget or szCmd == "" or szNoTarget == "" or szTarget == "" then
			break
		end
		
		if string.sub(szCmd,1, 1) == "/" and not EmotionPanel.IsSpaceString(string.sub(szCmd, 2)) and
			not IsChannelHeader(szCmd) and not IsEmotion(szCmd) and not tExistCmd[szCmd] and 
			not EmotionPanel.IsSpaceString(szNoTarget) and not EmotionPanel.IsSpaceString(szTarget) then
			
			tExistCmd[szCmd] = true
			if not string.find(szNoTarget, "$N") then
				szNoTarget = "$N："..szNoTarget
			end
			
			if not string.find(szTarget, "$N") then
				szTarget = "$N："..szTarget
			end
			
			table.insert(g_tJiangHuClient, {szCmd, szNoTarget, szTarget})
		end
		i = i + 1
	end
	
	if #g_tJiangHuClient == 0 then
		for k, v in pairs(g_tExpression.tJiangHu) do
			table.insert(g_tJiangHuClient, v)
		end
    end
	FireEvent("JIANGHU_TABLE_UPDATE")
  	iniS:Close()
end

local function InitFaceIcon()
	tFaceIcon = Table_GetFaceIconList()
	
	tSortFaceIcon = {}
	tFIconMap = {}
	for nFaceID, tFace in ipairs(tFaceIcon) do
		tFIconMap[tFace.szCommand] = nFaceID
		table.insert(tSortFaceIcon, {nFaceID = nFaceID, nLen = string.len(tFace.szCommand)})
	end
	table.sort(tSortFaceIcon, function(a, b) return  a.nLen > b.nLen end)
end

InitFaceIcon()

RegisterEvent("CUSTOM_DATA_LOADED", function(event) EmotionPanel.OnEvent(event) end)
RegisterLoadFunction(EmotionPanel_Load)
