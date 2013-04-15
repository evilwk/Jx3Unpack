FightProgress = {}

local hFrame

function FightProgress.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	
	FightProgress.UpdateAnchor(this)
end

function FightProgress.OnEvent(event)
	if event == "UI_SCALED" then
		FightProgress.UpdateAnchor(this)
	end
end

function FightProgress.UpdateAnchor(frame)
	local Anchor = g_tUIConfig["FightProgress"]
	frame:SetPoint(Anchor.s, 0, 0, Anchor.r, Anchor.x, Anchor.y)
	frame:CorrectPos()
end

function FightProgress.UpdateProgress(nForceType, fPercent)
	local hImageGood = hFrame:Lookup("", "Image_Good")
	local hImageEvil = hFrame:Lookup("", "Image_Evil")
	
	if nForceType == CAMP.GOOD then
		hImageEvil:SetPercentage(0)
		hImageGood:SetPercentage(fPercent)
	else
		hImageEvil:SetPercentage(fPercent)
		hImageGood:SetPercentage(0)
	end
end

local function IsFightProgressOpen()
	local frame = Station.Lookup("Normal/FightProgress")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

local function OpenFightProgress()
	hFrame = Wnd.OpenWindow("FightProgress")
end

local function CloseFightProgress()
	Wnd.CloseWindow("FightProgress")
	hFrame = nil
end

local function OnFightProgressNotify()
	local nForceType = arg0
	local fPercent   = arg1
	if nForceType == "LeaveFight" then
		CloseFightProgress()
		return
	end
	
	if not IsFightProgressOpen() then
		OpenFightProgress()
	end
	FightProgress.UpdateProgress(tonumber(nForceType), fPercent)
end

RegisterEvent("OnFightProgressNotify", OnFightProgressNotify)