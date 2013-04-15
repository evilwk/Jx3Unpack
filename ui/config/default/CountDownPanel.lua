CountDownPanel = {
	tExistPanel = {},
}

function CountDownPanel.UpdateCountDown(nLeftTime, szPanelName)
	if not szPanelName then 
		szPanelName = "Common"
	end
	
	if nLeftTime == "Close" then 
		CountDownPanel.EndCountDownPanel(szPanelName)
		return
	end
	
	if CountDownPanel.tExistPanel[szPanelName] then 
		local hFrame = IsCommonBlankPanelOpened(szPanelName)
		if hFrame then 
			hFrame.nLeft = nLeftTime
		end
	else
		local szImagePath, szAnchorS, szAnchorR, nOffsetX, nOffsetY, nSizeX, nSizeY
		local nRowCount = g_tTable.CountDown:GetRowCount()
		for index = 1, nRowCount do 
			local v = g_tTable.CountDown:GetRow(index)
			if v.szName == szPanelName then 
				szImagePath = v.szImagePath
				szAnchorS = v.szAnchorS
				szAnchorR = v.szAnchorR
				nOffsetX = v.nOffsetX
				nOffsetY = v.nOffsetY
				nSizeX = v.nSizeX
				nSizeY = v.nSizeY
				break
			end
		end
		if szImagePath then 
			local tAnchor = {s = szAnchorS, r = szAnchorR, x = nOffsetX, y = nOffsetY}
			CountDownPanel.StarCountDownPanel(szPanelName, nLeftTime, szImagePath, tAnchor, nSizeX, nSizeY);
		end	
	end
end

function CountDownPanel.StarCountDownPanel(szPanelName, nTotalCount, szImagePath, tAnchor, nSizeX, nSizeY)
	CountDownPanel.tExistPanel[szPanelName] = true;
	
	local hFrame = OpenCommonBlankPanel(nil, szPanelName, tAnchor, CountDownPanel.OnFrameBreath)
	hFrame.szName = szPanelName
	hFrame.nLeft = nTotalCount
	hFrame.szImagePath = szImagePath
	
	local hTotal = CommonBlankPanel_GetTotHandle(szPanelName)
	hTotal:Clear()
	hTotal:AppendItemFromString("<image></image>")
	hFrame.bAutoSize = (nSizeX == 0)
	
	if not hFrame.bAutoSize then
		hTotal:Lookup(0):SetSize(nSizeX, nSizeY)
	end
	
	hTotal:GetRoot():SetMousePenetrable(true)
	
	hTotal:FormatAllItemPos()
end

function CountDownPanel.EndCountDownPanel(szPanelName)
	if CountDownPanel.tExistPanel[szPanelName] then 
		local hTotal = CommonBlankPanel_GetTotHandle(szPanelName)
		local img = hTotal:Lookup(0)
		img:SetAlpha(255)
	end
	
	CountDownPanel.tExistPanel[szPanelName] = nil;
	CloseCommonBlankPanel(nil, szPanelName)
end

function CountDownPanel.OnFrameBreath()
	local szPanelName = this.szName
	local nLeftTime = this.nLeft
	local szImagePath = this.szImagePath
	
	if nLeftTime >= 0 then
		local nLeft = nLeftTime
		local hTotal = CommonBlankPanel_GetTotHandle(szPanelName)
		local img = hTotal:Lookup(0)
		if img.nCountDown ~= nLeft then
			if nLeft == 0 then
				img:FromTextureFile(szImagePath.."start.tga")
			else
				img:FromTextureFile(szImagePath..nLeft..".tga")
			end
			if this.bAutoSize then 
				img:AutoSize()
			end
			
			img.nCountDown = nLeft
			img:SetAlpha(255)
		else
			local nAlpha = img:GetAlpha()
			nAlpha = nAlpha - 14
			if nAlpha <= 0 and nLeftTime == 0 then
				CountDownPanel.EndCountDownPanel(szPanelName)
				return
			end
			
			if nAlpha < 0 then
				nAlpha = 255
			end
			img:SetAlpha(nAlpha)
		end
	end
end
