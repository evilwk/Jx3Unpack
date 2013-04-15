AchievementTipList = {}

function OutputAchievementTip(dwAchievementID, Rect)
	local aAchievement = g_tTable.Achievement:Search(dwAchievementID)
	if not aAchievement then
		return
	end

	local szName = "AchievementTip"..dwAchievementID
	
	local frame = Station.Lookup("Topmost/"..szName)
	if not frame then
		frame = Station.OpenWindow("AchievementTip", szName)
	end

	AchievementTipList[szName] = true
	
	frame.dwAchievementID = dwAchievementID
	frame:RegisterEvent("UI_SCALED")
	
	frame.OnEvent = function(event)
		if event == "UI_SCALED" then
			this:SetPoint(this.Anchor.s, 0, 0, this.Anchor.r, this.Anchor.x, this.Anchor.y)
			this:CorrectPos()
		end
	end
	
	frame.OnFrameDrag = function()
		this.x, this.y = this:GetAbsPos()
	end
	
	frame.OnFrameDragSetPosEnd = function()
		local x, y = this:GetAbsPos()
		x, y = x - this.x, y - this.y
		local nDis = x * x + y + y
		if not this.nDis then
			this.nDis = nDis
		elseif nDis > this.nDis then
			this.nDis = nDis
		end
	end

	local btn = frame:Lookup("Btn_Close")
	btn.OnLButtonClick = function()
		local szName = this:GetParent():GetName()
		AchievementTipList[szName] = nil
		Station.CloseWindow(szName)
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end

	local h = frame:Lookup("", "")
	
	h.OnItemLButtonDown = function()
		this.x, this.y = Cursor.GetPos()
	end
	
	h.OnItemLButtonClick = function()
		local frame = this:GetRoot()
		if not frame.nDis or frame.nDis < 10 then
			OpenAchievementPanel(nil, frame.dwAchievementID)
		end
		frame.nDis = 0
	end
	
	h:Lookup("Text_Name"):SetText(aAchievement.szName)
	h:Lookup("Text_Tip"):SetText(aAchievement.szShortDesc)
	
	local _, nP = GetAchievementInfo(dwAchievementID)
	h:Lookup("Text_Point"):SetText(nP or 0)
	
	h:Lookup("Image_Finish"):Show(GetClientPlayer().IsAchievementAcquired(dwAchievementID))
	
	local box = h:Lookup("Box_Icon")
	box:SetObject(UI_OBJECT_NOT_NEED_KNOWN, 0)
	box:SetObjectIcon(aAchievement.nIconID)
	
	frame:CorrectPos(Rect[1], Rect[2], Rect[3], Rect[4], ALW.CENTER)
	frame.Anchor = GetFrameAnchor(frame)
end

function CloseAllAchievementTip()
	local bClose = false
	for k, v in pairs(AchievementTipList) do
		Station.CloseWindow(k)
		bClose = true
	end
	if bClose then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
	AchievementTipList = {}
	return bClose
end