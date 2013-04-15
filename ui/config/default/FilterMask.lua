----------------------------------------------------------------------
-- 通用的淡入淡出的屏幕效果
-- Date:	2010.02.26
-- Author:	Danexx
-- Comment:	当你不能够再拥有的时候，你唯一能做的，就是令自己不要忘记。
----------------------------------------------------------------------
FilterMask = {}
FilterMask.nStepCount = 0;
FilterMask.frameSelf = nil;
FilterMask.handleMask = nil;
FilterMask.shadowMask = nil;
FilterMask.shadowMoveMask = nil;

FilterMask.nProtectTime = 0;
FilterMask.nFadeOutTime = 0;
FilterMask.nFadeInTime = 0;
FilterMask.nFadeOutTimeOrg = 0;
FilterMask.nFadeInTimeOrg = 0;
FilterMask.fFadeOutScale = 0.0;
FilterMask.fFadeInScale = 0.0;
FilterMask.nKeepTime = 0;
FilterMask.nKeepTimeOrg = 0;
FilterMask.tFadeColor = {0, 0, 0};
FilterMask.bLastVisibleState = true;
FilterMask.bHideUI = false;
FilterMask.bRENDER = true;
FilterMask.tText = {};

FilterMask.OldFont = {}

local SHADOWCOLOR = {
	BLACK = {0, 0, 0},
	RED = {255, 0, 0},
}

function FilterMask.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("RENDER_FRAME_UPDATE")
	FilterMask.UpdateSize()
end

function FilterMask.OnEvent(event)
	if event == "UI_SCALED" then
		FilterMask.UpdateSize()
	elseif event == "RENDER_FRAME_UPDATE" and FilterMask.bRENDER then
		FilterMask.UpdateFade()
	end
end

function FilterMask.OnFrameBreathe()
	FilterMask.nStepCount = FilterMask.nStepCount - 1
	if FilterMask.nStepCount <= 0 then
		CloseFilterMask()
		return
	end
	if not FilterMask.bRENDER then
		FilterMask.UpdateFade()
	end
end

-----------------------------------------------------------------------------------------
function FilterMask.UpdateFade()
	if not FilterMask.frameSelf:IsVisible() then
		return
	end
	if FilterMask.nFadeOutTime and FilterMask.nFadeOutTime > 0 then
		FilterMask.nFadeOutTime = FilterMask.nFadeOutTime - 1
		FilterMask.SetShadowMaskAlpha()	
	elseif FilterMask.nKeepTime and FilterMask.nKeepTime > 0 then
		if FilterMask.nKeepTime == FilterMask.nKeepTimeOrg then
			FilterMask.SetBackgroundText()
		end

		FilterMask.nKeepTime = FilterMask.nKeepTime - 1
		FilterMask.SetShadowMaskAlpha()	
		FilterMask.SetBackgroundTextAlpha()
	elseif FilterMask.nFadeInTime and FilterMask.nFadeInTime > 0 then
		if FilterMask.nFadeInTime == FilterMask.nFadeInTimeOrg then
			FilterMask.handleText:Clear()
			FilterMask.shadowMoveMask:Hide()
		end

		FilterMask.nFadeInTime = FilterMask.nFadeInTime - 1
		FilterMask.SetShadowMaskAlpha()
	else
		CloseFilterMask()
	end
end

function FilterMask.UpdateSize()
	if not FilterMask.frameSelf then
		return
	end
	local nClientWidth, nClientHeight = Station.GetClientSize()
	
	FilterMask.frameSelf:SetSize(nClientWidth, nClientHeight)
	FilterMask.handleMask:SetSize(nClientWidth, nClientHeight)
end

function FilterMask.SetBackgroundText(tText)
	tText = tText or FilterMask.tText
	handleText = FilterMask.handleText
	handleText:Clear()

	for i = 1, #tText do
		local szText = "<text>text=" .. EncodeComponentsString(tText[i]).." font=13 intpos=1 x=" .. (100 + i * 65) .. " y=" .. (150 + i * 10) .. "</text>"
		handleText:AppendItemFromString(szText)
	end
	
	handleText:SetItemStartRelPos(0, 0)
	handleText:FormatAllItemPos()
	
	local tShadowColor = FilterMask.tFadeColor
	local nR, nG, nB, nA = tShadowColor[1], tShadowColor[2], tShadowColor[3], tShadowColor[4] or 255;
	FilterMask.shadowMoveMask:SetTriangleFan(true)
	FilterMask.shadowMoveMask:ClearTriangleFanPoint()
	FilterMask.shadowMoveMask:SetRelPos(0, 0)
	FilterMask.shadowMoveMask:Show()

	FilterMask.shadowMoveMask:AppendTriangleFanPoint(128, 0, nR, nG, nB, 255)
	FilterMask.shadowMoveMask:AppendTriangleFanPoint(0, 0, nR, nG, nB, 0)
	FilterMask.shadowMoveMask:AppendTriangleFanPoint(0, 2048, nR, nG, nB, 0)
	FilterMask.shadowMoveMask:AppendTriangleFanPoint(128, 2048, nR, nG, nB, 255)
	FilterMask.shadowMoveMask:AppendTriangleFanPoint(2048, 2048, nR, nG, nB, 255)
	FilterMask.shadowMoveMask:AppendTriangleFanPoint(2048, 0, nR, nG, nB, 255)
end

function FilterMask.SetBackgroundTextAlpha()
	local nClientWidth, nClientHeight = Station.GetClientSize()
	local nX, nY = FilterMask.shadowMoveMask:GetRelPos()
	local nFadeTime = FilterMask.nKeepTimeOrg / 1.25
	
	local nSpeed = (#FilterMask.tText * 65 + 150) / nFadeTime
	if FilterMask.nKeepTime > (FilterMask.nKeepTimeOrg - nFadeTime) then
		FilterMask.shadowMoveMask:SetRelPos(nX + nSpeed, nY)
	elseif FilterMask.nKeepTime < (nFadeTime / 35) then
		FilterMask.shadowMoveMask:SetRelPos(nX - (nSpeed * 35), nY)
	end
	FilterMask.handleMask:FormatAllItemPos()
end

function FilterMask.SetShadowMaskAlpha(tShadowColor)
	tShadowColor = tShadowColor or FilterMask.tFadeColor
	local nR, nG, nB, nA = tShadowColor[1], tShadowColor[2], tShadowColor[3], tShadowColor[4] or 255;
	local nAlpha = 0;
	local nClientWidth, nClientHeight = Station.GetClientSize()

	if FilterMask.nFadeOutTime and FilterMask.nFadeOutTime > 0 then
		nAlpha = (FilterMask.nFadeOutTimeOrg - FilterMask.nFadeOutTime) * FilterMask.fFadeOutScale
		if nAlpha >= nA then
			FilterMask.nFadeOutTime = 0
			nAlpha = nA
		end
	elseif FilterMask.nKeepTime and FilterMask.nKeepTime > 0 then
		nAlpha = nA
	elseif FilterMask.nFadeInTime and FilterMask.nFadeInTime > 0 then
		nAlpha = FilterMask.nFadeInTime * FilterMask.fFadeInScale
		if nAlpha >= nA then
			FilterMask.nFadeInTime = FilterMask.nFadeInTime - ((nAlpha - nA) / FilterMask.fFadeInScale)
			nAlpha = nA
		end
	end

	FilterMask.shadowMask:SetTriangleFan(true)
	FilterMask.shadowMask:ClearTriangleFanPoint()

	FilterMask.shadowMask:AppendTriangleFanPoint(0, 0, nR, nG, nB, nAlpha)
	FilterMask.shadowMask:AppendTriangleFanPoint(nClientWidth, 0, nR, nG, nB, nAlpha)
	FilterMask.shadowMask:AppendTriangleFanPoint(nClientWidth, nClientHeight, nR, nG, nB, nAlpha)
	FilterMask.shadowMask:AppendTriangleFanPoint(0, nClientHeight, nR, nG, nB, nAlpha)
end

function FilterMask.SetFadeTime(nFadeOutTime, nFadeInTime, nKeepTime, tFadeColor)
	FilterMask.nFadeOutTime = nFadeOutTime
	FilterMask.nFadeInTime = nFadeInTime
	FilterMask.nKeepTime = nKeepTime
	FilterMask.tFadeColor = tFadeColor or SHADOWCOLOR.BLACK
	
	FilterMask.nFadeOutTimeOrg = FilterMask.nFadeOutTime;
	FilterMask.nFadeInTimeOrg = FilterMask.nFadeInTime;
	FilterMask.nKeepTimeOrg = FilterMask.nKeepTime;
	
	if nFadeOutTime ~= 0 then
		FilterMask.fFadeOutScale = 255 / nFadeOutTime
	end
	if nFadeInTime ~= 0 then
		FilterMask.fFadeInScale = 255 / nFadeInTime
	end
end

-- /gm RemoteCallToClient(player.dwID, "StartFilterMask", 64, 128, 800, {0, 0, 0}, true, true, {})
function OpenFilterMask(nFadeOutTime, nFadeInTime, nKeepTime, tFadeColor, bRENDER, bHideUI, tText)
	FilterMask.nStepCount = 16 * 60
	FilterMask.frameSelf = Station.Lookup("Lowest/FilterMask")
	if not FilterMask.frameSelf then
		FilterMask.frameSelf 		= Wnd.OpenWindow("FilterMask")
	end
	FilterMask.handleMask			= FilterMask.frameSelf:Lookup("", "")
	FilterMask.shadowMask			= FilterMask.frameSelf:Lookup("", "Shadow_BlackMask")
	FilterMask.shadowMoveMask		= FilterMask.frameSelf:Lookup("", "Shadow_MoveMask")
	FilterMask.handleText			= FilterMask.frameSelf:Lookup("", "Handle_Text")
	
	FilterMask.handleText:Clear()

	FilterMask.SetFadeTime(nFadeOutTime, nFadeInTime, nKeepTime, tFadeColor)
	FilterMask.frameSelf:Show()
	FilterMask.bLastVisibleState = Station.IsVisible()
	FilterMask.bHideUI = bHideUI
	FilterMask.bRENDER = bRENDER
	FilterMask.tText = tText

	if FilterMask.bHideUI and FilterMask.bLastVisibleState then
		Station.Hide()
	end
	
	FilterMask.tOldFont = {}
	FilterMask.tOldFont.szName, FilterMask.tOldFont.szFile, FilterMask.tOldFont.nSize, FilterMask.tOldFont.aStyle = Font.GetFont(2)
	Font.SetFont(2, FilterMask.tOldFont.szName, FilterMask.tOldFont.szFile, 50, FilterMask.tOldFont.aStyle)
end

function CloseFilterMask()
	FilterMask.nStepCount = 0
	if not FilterMask.frameSelf then
		return
	end
	FilterMask.frameSelf:Hide()
	Station.Show()
	FilterMask.bHideUI = false;
	
	FilterMask.handleText:Clear()
	FilterMask.shadowMoveMask:Hide()
	
	if FilterMask.tOldFont then
		Font.SetFont(2, FilterMask.tOldFont.szName, FilterMask.tOldFont.szFile, FilterMask.tOldFont.nSize, FilterMask.tOldFont.aStyle)
		FilterMask.OldFont = nil
	end
end
