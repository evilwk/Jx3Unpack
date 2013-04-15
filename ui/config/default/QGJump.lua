QGJump = 
{
	bInSprint = false,
	bPlayAnimation = false,
	nPreJumpCount = 0,
	Anchor = {s = "TOPLEFT", r = "CENTER", x = 280, y = -250}
}

function QGJump.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	
	QGJump.UpdateAnchor(this)
end
 
function QGJump.OnFrameBreathe()
	if QGJump.bInSprint then
		QGJump.Update(this)
	end
	
	if QGJump.bPlayAnimation then --之前是否有轻功动画播放
		QGJump.stopAnimation(this)
	end
end

function QGJump.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		QGJump.UpdateAnchor(this)
	end
end

function QGJump.UpdateAnchor(hFrame)
	hFrame:SetPoint(QGJump.Anchor.s, 0, 0, QGJump.Anchor.r, QGJump.Anchor.x, QGJump.Anchor.y)
	hFrame:CorrectPos()
end

function QGJump.EnterSprint()
	QGJump.bInSprint = true
	OpenQGJump(true)
end

function QGJump.LeaveSprint()
	QGJump.bInSprint = false
	QGJump.nPreJumpCount = 0
end

function QGJump.Update(hFrame)
	local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
	
	local nJumpCount = hPlayer.nJumpCount
	if QGJump.nPreJumpCount ~= nJumpCount then
		QGJump.nPreJumpCount = nJumpCount
		QGJump.playAnimation(hFrame, nJumpCount)
	end
end

function QGJump.playAnimation(hFrame, nJumpCount)
	local hAnimateQGJump = hFrame:Lookup("", "Animate_QGJump")
	if nJumpCount == 0 then 
		return 
	end
	
	QGJump.bPlayAnimation = true
	hAnimateQGJump:SetAnimate("ui/Image/Common/QingGong" .. nJumpCount .. ".UITex", 0, 1)
	hAnimateQGJump:SetIdenticalInterval(100)
	hAnimateQGJump:Show()
end

function QGJump.stopAnimation(hFrame)
	local hAnimateQGJump = hFrame:Lookup("", "Animate_QGJump")

	if hAnimateQGJump:IsFinished() then
		QGJump.bPlayAnimation = false
		hAnimateQGJump:Hide()
		if not QGJump.bInSprint then
			CloseQGJump(true)
		end
	end
end

function OpenQGJump(bDiableSound)
	if IsQGJumpOpen() then
		return
	end
	
	local hFrame = Wnd.OpenWindow("QGJump")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function CloseQGJump(bDisableSound)
	if not IsQGJumpOpen() then
		return
	end

	Wnd.CloseWindow("QGJump")
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function IsQGJumpOpen()
	local hFrame = Station.Lookup("Normal/QGJump")
	if hFrame and hFrame:IsVisible() then
		return true
	end
	
	return false
end

-- RegisterEvent("ENABLE_SPRINT", function() QGJump.EnterSprint() end)
-- RegisterEvent("DISABLE_SPRINT", function() QGJump.LeaveSprint() end)