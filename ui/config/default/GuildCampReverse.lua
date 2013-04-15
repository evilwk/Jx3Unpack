GuildCampReverse = {}

function GuildCampReverse.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	GuildCampReverse.UpdatePos(this)

	this.dwStartTime = GetTickCount()
end

function GuildCampReverse.OnFrameBreathe()
	if not this.dwStartTime then
		return
	end

	local dwTime = GetTickCount() - this.dwStartTime
	local hText = this:Lookup("", "Text_Time")
	if dwTime < this.nCountDownTime * 1000 then

		local nTime = this.nCountDownTime - dwTime/ 1000
		local dwMinutes = nTime / 60 - nTime / 60 % 1
		local dwSeconds = nTime % 60 - nTime % 60 % 1

		hText:SetText(FormatString(g_tStrings.CAMP_REVERSE_COUNT_DOWN, dwMinutes .. ":" .. dwSeconds))
		return
	end

	hText:SetText("")
	CloseGuildCampReverse()
	this.dwStartTime = nil
end

function GuildCampReverse.OnEvent(szEvent)
	if szEvent == "UI_SCALED" then
		GuildCampReverse.UpdatePos(this)
	end
end

function GuildCampReverse.UpdatePos(hFrame)
	local fWidthAll, fHeightAll = Station.GetClientSize()
	local fPosX, fPosY = hFrame:GetAbsPos()
	local fWidth, fHeight = hFrame:GetSize()

	hFrame:SetRelPos((fWidthAll - fWidth) / 2, (fHeightAll - fHeight) / 2)
	hFrame:SetAbsPos((fWidthAll - fWidth) / 2, (fHeightAll - fHeight) / 2)
end

function GuildCampReverse.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Sure" then
		local hFrame = this:GetRoot()
		RemoteCallToServer("TongCampReverse", hFrame.nCamp)
		CloseGuildCampReverse()
	elseif szName == "Btn_LeaveGuild" then
		GetTongClient().Quit()
		CloseGuildCampReverse()
	end
end

function CloseGuildCampReverse(bDisableSound)
	if not IsGuildCampReverseOpened() then
		return
	end

	Wnd.CloseWindow("GuildCampReverse")

	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end

function OpenGuildCampReverse(nCamp, nCountDownTime, bDisableSound)
	if not IsGuildCampReverseOpened() then
		Wnd.OpenWindow("GuildCampReverse")
	end
	local hFrame = Station.Lookup("Normal/GuildCampReverse")

	hFrame.nCamp = nCamp
	hFrame.nCountDownTime = nCountDownTime
	local hText = hFrame:Lookup("", "Text_Message")
	local szText = FormatString(g_tStrings.CAMP_REVERSE_SHOW, g_tStrings.STR_CAMP_TITLE[nCamp])
	hText:SetText(szText)
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function IsGuildCampReverseOpened()
	local hFrame = Station.Lookup("Normal/GuildCampReverse")
	if hFrame then
		return true
	end

	return false
end
