TeamYYButton = {}

function TeamYYButton.OnFrameCreate()
	this:RegisterEvent("USE_YY_STATE_CHANGED")
	TeamYYButton.UpdateState(this)
end

function TeamYYButton.OnEvent(event)
	if event == "USE_YY_STATE_CHANGED" then
		TeamYYButton.UpdateState(this)
	end
end

function TeamYYButton.OnLButtonClick()
	if IsInUseYY() then
		EndUseYY()
	else
		BeginUseYY()
	end
	TeamYYButton.UpdateState(this:GetRoot())
end

function TeamYYButton.UpdateState(frame)
	if IsInUseYY() then
		frame:Lookup("Btn_YY", "Text_YY"):SetText(g_tStrings.CLOSE_YY)
	else
		frame:Lookup("Btn_YY", "Text_YY"):SetText(g_tStrings.OPEN_YY)
	end	
end

local tLoopCount = 0
local function YYBtnBreathe()
	tLoopCount = tLoopCount + 1
	if tLoopCount < 16 then
		return
	end
	tLoopCount = 0

	local player = GetClientPlayer()
	if player and player.IsInParty() then
		Wnd.OpenWindow("TeamYYButton")
	else
		Wnd.CloseWindow("TeamYYButton")
	end
end

--local _,_,szVersionLineName,szVersionType = GetVersion()
--if szVersionLineName == "zhcn" and szVersionType == "exp" then
RegisterBreatheEvent("YY_Btn_Breathe", YYBtnBreathe)
--end