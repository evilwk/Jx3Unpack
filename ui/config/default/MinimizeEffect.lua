local MINIMIZE_OVER_TIME = 1500
local MINIMIZE_SPEED = 1
local PANELSIZE_MINIMIZE_SPEED = 1
local nMinizeEffectPanelCount = 0

MinimizeEffect_Base = class()

function MinimizeEffect_Base.OnFrameCreate()
	
end

function MinimizeEffect_Base.OnFrameBreathe()
	local dwCurrentTime = GetTickCount()
	local dwMinimizeTime = dwCurrentTime - this.dwStartTime
	if dwMinimizeTime * MINIMIZE_SPEED > this.fTotalDis then
		if not this.dwMinimizeEndTime then
			this:GetSelf().UpdatePanel(this, this.fEndX, this.fEndY, this.fTargetWidth, this.fTargetHeight)
			this:GetSelf().SetEndAnimiateVisiable(this, true)
			this.dwMinimizeEndTime = dwCurrentTime
		end
		if dwCurrentTime - this.dwMinimizeEndTime > MINIMIZE_OVER_TIME then
			CloseMinimizeEffect(this, true)
		end
		return 
	end
	
	local fNewWidth = this.fWidth - PANELSIZE_MINIMIZE_SPEED * dwMinimizeTime * this.fWidth / this.fCatercorner
	if fNewWidth < this.fTargetWidth then
		fNewWidth = this.fTargetWidth
	end
	local fNewHeight = this.fHeight - PANELSIZE_MINIMIZE_SPEED * dwMinimizeTime * this.fHeight / this.fCatercorner
	if fNewHeight < this.fTargetHeight then
		fNewHeight = this.fTargetHeight
	end
	local fNewPosX = this.fStartX + (this.fEndX - this.fStartX) * MINIMIZE_SPEED * dwMinimizeTime / this.fTotalDis
	local fNewPosY = this.fStartY + (this.fEndY - this.fStartY) * MINIMIZE_SPEED * dwMinimizeTime / this.fTotalDis  
	this:GetSelf().UpdatePanel(this, fNewPosX, fNewPosY, fNewWidth, fNewHeight)
end

function MinimizeEffect_Base.UpdatePanel(hFrame, fPosX, fPosY, fWidth, fHeight)
	
	local hHandle = hFrame:Lookup("", "")
	local hImageBG = hHandle:Lookup("Image_BG")
	hImageBG:SetSize(fWidth, fHeight)
	hImageBG:Show()
	
	hHandle:SetSize(fWidth, fHeight)
	hHandle:FormatAllItemPos()
	
	hFrame:SetAbsPos(fPosX, fPosY)
	hFrame:SetSize(fWidth, fHeight)
end

function MinimizeEffect_Base.SetEndAnimiateVisiable(hFrame, bShow)
	local hHandle = hFrame:Lookup("", "")
	local fWidth, fHeight = hHandle:GetSize()
	local hAnimateEdge = hHandle:Lookup("Animate_MinimizeEdge")
	local hAnimateInside = hHandle:Lookup("Animate_MinimizeInside")
	local hImageBG = hHandle:Lookup("Image_BG")
	
	if bShow then
		hAnimateEdge:Show()
		hAnimateEdge:SetSize(fWidth, fHeight)
		hAnimateInside:Show()
		hAnimateInside:SetSize(fWidth, fHeight)
		hImageBG:Hide()
	else
		hAnimateEdge:Hide()
		hAnimateInside:Hide()
		hImageBG:Show()
	end
	
	hHandle:FormatAllItemPos()
end

function CreateMinimizeEffect(fStartX, fStartY, fWidth, fHeight, fEndX, fEndY, fTargetWidth, fTargetHeight)
	local hFrame = Wnd.OpenWindow("MinimizeEffect", "MinimizeEffect"..nMinizeEffectPanelCount)
	nMinizeEffectPanelCount = nMinizeEffectPanelCount + 1
	hFrame.fStartX = fStartX
	hFrame.fStartY = fStartY
	hFrame.fEndX = fEndX
	hFrame.fEndY = fEndY
	hFrame.fWidth = fWidth
	hFrame.fHeight = fHeight
	hFrame.fTargetWidth = fTargetWidth
	hFrame.fTargetHeight = fTargetHeight
	hFrame.dwStartTime = GetTickCount()
	hFrame.dwMinimizeEndTime = nil
	hFrame.fTotalDis = math.sqrt((fStartY - fEndY) * (fStartY - fEndY) + (fStartX - fEndX) * (fStartX - fEndX))
	hFrame.fCatercorner = math.sqrt(fWidth * fWidth + fHeight * fHeight)

	hFrame:GetSelf().UpdatePanel(hFrame, fStartX, fStartY, fWidth, fHeight)
	hFrame:GetSelf().SetEndAnimiateVisiable(hFrame, false)
	hFrame:Show()
end

function CloseMinimizeEffect(hFrame, bDisableSound)
	Wnd.CloseWindow(hFrame)
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end	
end
