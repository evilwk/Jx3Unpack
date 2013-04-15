local COLOR_TABLE_ROW_COUNT = 7
local COLOR_WIDTH = 25
local COLOR_INTERVAL = 28

ColorTablePanel = 
{
	tColor = 
	{
		{r = 255	,g = 128	,b = 128},
		{r = 255	,g = 255	,b = 128},
		{r = 128	,g = 255	,b = 128},
		{r = 0		,g = 255	,b = 128},
		{r = 128	,g = 255	,b = 255},
		{r = 0		,g = 128	,b = 255},
		{r = 255	,g = 128	,b = 192},
		{r = 255	,g = 128	,b = 255},
		{r = 255	,g = 0		,b = 0  },
		{r = 255	,g = 255	,b = 0  },
		{r = 128	,g = 255	,b = 0  },
		{r = 0		,g = 255	,b = 64 },
		{r = 0		,g = 255	,b = 255},
		{r = 0		,g = 128	,b = 192},
		{r = 128	,g = 128	,b = 192},
		{r = 255	,g = 0		,b = 255},
		{r = 128	,g = 64		,b = 64 },
		{r = 255	,g = 128	,b = 64 },
		{r = 0		,g = 255	,b = 0  },
		{r = 0		,g = 128	,b = 128},
		{r = 0		,g = 64		,b = 128},
		{r = 128	,g = 128	,b = 255},
		{r = 128	,g = 0		,b = 64 },
		{r = 255	,g = 0		,b = 128},
		{r = 128	,g = 0		,b = 0  },
		{r = 255	,g = 128	,b = 0  },
		{r = 0		,g = 128	,b = 0  },
		{r = 0		,g = 128	,b = 64 },
		{r = 0		,g = 0		,b = 255},
		{r = 0		,g = 0		,b = 160},
		{r = 128	,g = 0		,b = 128},
		{r = 128	,g = 0		,b = 255},
		{r = 64		,g = 0		,b = 0  },
		{r = 128	,g = 64		,b = 0  },
		{r = 0		,g = 64		,b = 0  },
		{r = 0		,g = 64		,b = 64 },
		{r = 0		,g = 0		,b = 128},
		{r = 0		,g = 0		,b = 64 },
		{r = 64		,g = 0		,b = 64 },
		{r = 64		,g = 0		,b = 128},
		{r = 0		,g = 0		,b = 0  },
		{r = 64		,g = 64		,b = 64 },
		{r = 128	,g = 128	,b = 128},
		{r = 255	,g = 255	,b = 255},
		{r = 64		,g = 128	,b = 128},
		{r = 128	,g = 128	,b = 0},
		{r = 128	,g = 128	,b = 64 },
		{r = 64		,g = 32		,b = 64}			
	}
}

function ColorTablePanel.OnFrameCreate()
	
end

function ColorTablePanel.InitColorTable(hFrame, nPosX, nPosY)
	local szIniFile = "UI/Config/default/ColorTablePanel.ini"
	
	local hHandle = hFrame:Lookup("", "")	
	local hColorTable = hHandle:AppendItemFromIni(szIniFile, "Handle_Color", "Handle_ColorTable")
	
	local hShadow = hColorTable:Lookup("Shadow_Color")
	local nX, nY = hShadow:GetRelPos()
	hColorTable:RemoveItem(hShadow)
	
	local nIndex = 0
	for k, v in pairs(ColorTablePanel.tColor) do
		local hColor = hColorTable:AppendItemFromIni(szIniFile, "Shadow_Color", k)
		
		hColor:SetSize(COLOR_WIDTH, COLOR_WIDTH)
		hColor:SetColorRGB(v.r, v.g, v.b)
		hColor:SetRelPos(nX + nIndex * COLOR_INTERVAL, nY)
		hColor.bColor = true
		nIndex = nIndex + 1
		if nIndex > COLOR_TABLE_ROW_COUNT then
			nIndex = 0
			nY = nY + COLOR_INTERVAL
		end
	end
	nIndex = hColorTable:GetItemCount() - 1
	hColorTable:Lookup("Shadow_CCOver"):SetIndex(nIndex)
	hColorTable:Lookup("Image_COver"):SetIndex(nIndex)
	hColorTable:Lookup("Text_RGB"):SetIndex(nIndex)
	hColorTable:FormatAllItemPos()
	
	hHandle:FormatAllItemPos()
	local nWidth, nHeight = hHandle:GetSize()
	hFrame:SetSize(nWidth, nHeight)
	
	if not nPosX or not nPosY then
		nPosX, nPosY = Cursor.GetPos()
	end
	local nClientWidth, nClientHeight = Station.GetClientSize()
	local nColorTableWidth, nColorTableHeight = hFrame:GetSize()
	if nPosY + nColorTableHeight > nClientHeight then
		if nPosY - nColorTableHeight < 0 then
			nPosY = nClientHeight - nColorTableHeight
		else
			nPosY = nPosY - nColorTableHeight
		end
	end
	if nPosX + nColorTableWidth > nClientWidth then
		if nPosX - nColorTableWidth < 0 then
			nPosX = nClientWidth - nColorTableWidth
		else
			nPosX = nPosX - nColorTableWidth
		end
	end
	hFrame:SetAbsPos(nPosX, nPosY)
end

function ColorTablePanel.OnItemLButtonClick()
	if this.bColor then
		local hFrame = this:GetRoot()
		local r, g, b = this:GetColorRGB()
		if hFrame.fnChangeColor then
			hFrame.fnChangeColor(r, g ,b)
		end
		CloseColorTable()
	end
end

function ColorTablePanel.OnItemMouseEnter()
	if this.bColor then
		local hColor = this:GetParent()
		local nAbsX, nAbsY = this:GetAbsPos()
		local nRelX, nRelY = this:GetRelPos()
		local nWidth, nHeight = this:GetSize()
		local hSelectImage = hColor:Lookup("Image_COver")
		hSelectImage:SetSize(nWidth, nHeight)
		hSelectImage:SetAbsPos(nAbsX, nAbsY) 
		hSelectImage:SetRelPos(nRelX, nRelY)
		hSelectImage:Show()
		local r, g, b = this:GetColorRGB()
		local hShowColor = hColor:Lookup("Shadow_CCOver")
		hShowColor:SetColorRGB(r, g, b)
		hShowColor:Show()
		local hText = hColor:Lookup("Text_RGB")
		hText:SetText("r="..r..", g="..g..", b="..b..".")
		hText:Show()
	end
end

function ColorTablePanel.OnItemMouseLeave()
	if this.bColor then
		local hColor = this:GetParent()
		hColor:Lookup("Image_COver"):Hide()
		hColor:Lookup("Shadow_CCOver"):Hide()
		hColor:Lookup("Text_RGB"):Hide()
	end
end

function ColorTablePanel.OnKillFocus()
	Wnd.CloseWindow(this)
end

function ColorTablePanel.OnFrameKeyDown()
	if GetKeyName(Station.GetMessageKey()) == "Esc" then
		Wnd.CloseWindow(this)
		return 1
	end
end

function OpenColorTablePanel(fnChangeColor, nX, nY)
	if IsColorTablePanelOpened() then
		return
	end
	local hFrame = Wnd.OpenWindow("ColorTablePanel")
	hFrame.fnChangeColor = fnChangeColor
	ColorTablePanel.InitColorTable(hFrame, nX, nY)
	Station.SetFocusWindow(hFrame)
	hFrame:Show()
	hFrame:BringToTop()
end

function IsColorTablePanelOpened()
	local hFrame = Station.Lookup("Normal/ColorTablePanel")
	if hFrame and hFrame:IsVisible() then
		return true
	end
	
	return false
end

function CloseColorTable(bDisableSound)
	Wnd.CloseWindow("ColorTablePanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end	
end

function ColorTablePanel_GetColorIndex(r, g, b)
	for k , v in ipairs(ColorTablePanel.tColor) do
		if v.r == r  and v.g == g and v.b == b then
			return k
		end
	end
end