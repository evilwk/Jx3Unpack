ActiveMessage0 = {}

function ActiveMessage0.OnFrameCreate()
--	Trace("ActiveMessage0.OnFrameCreate()\n")
	
	this:RegisterEvent("UI_SCALED")
	this:SetPoint("TOPRIGHT", 0, 0, "TOPRIGHT", 0, 0)
end

function ActiveMessage0.OnEvent(event)
	if event == "UI_SCALED" then
		this:SetPoint("TOPRIGHT", 0, 0, "TOPRIGHT", 0, 0)
	end
end

function ActiveMessage0.OnFrameBreathe()
	local player = GetClientPlayer()	
	if not player then
		return
	end
    local nX0=player.nX
    local nY0=player.nY
    local nZ0=player.nZ
    local nX1=player.nDestX
    local nY1=player.nDestY
    local eMoveState = player.nMoveState
    
    local aMoveStateName =
    {
		g_tStrings.STR_CONTROL_H_STATE_INVALID,
		g_tStrings.STR_CONTROL_H_STATE_STAND,
		g_tStrings.STR_CONTROL_H_STATE_WALK,
		g_tStrings.STR_CONTROL_H_STATE_RUN,
		g_tStrings.STR_CONTROL_H_STATE_JUMP,
		g_tStrings.STR_CONTROL_H_STATE_SWIM,
		g_tStrings.STR_CONTROL_H_STATE_SWIM_JUMP,
		g_tStrings.STR_CONTROL_H_STATE_FLOAT,
		g_tStrings.STR_CONTROL_H_STATE_SIT,
		g_tStrings.STR_CONTROL_H_STATE_KNOCKEDDOWN,
		g_tStrings.STR_CONTROL_H_STATE_KNOCKEDBACK,
		g_tStrings.STR_CONTROL_H_STATE_KNOCKEDOFF,
		g_tStrings.STR_CONTROL_H_STATE_HALT,
		g_tStrings.STR_CONTROL_H_STATE_FREEZE,
		g_tStrings.STR_CONTROL_H_STATE_ENTRAP,
		g_tStrings.STR_CONTROL_H_STATE_AUTO_FLY,
		g_tStrings.STR_CONTROL_H_STATE_DEATH,
		g_tStrings.STR_CONTROL_H_STATE_DASH,
		g_tStrings.STR_CONTROL_H_STATE_PULL,
		g_tStrings.STR_CONTROL_H_STATE_REPULSED,
		g_tStrings.STR_CONTROL_H_STATE_RISE,
		g_tStrings.STR_CONTROL_H_STATE_SKID
	}
	
	local fYaw, fPitch, fRoll = Camera_GetYawPitchRoll()
	local szYaw = string.format("%.2f", fYaw)
	local szPitch = string.format("%.2f", fPitch)
	local szText = "["..nX0..","..nY0..","..nZ0.."]->["..nX1..","..nY1.."] "..aMoveStateName[player.nMoveState + 1]
	szText = szText.."Yaw = "..szYaw..", Pitch = "..szPitch.." Face = "..player.nFaceDirection
	this:Lookup("", "Text_Message"):SetText(szText)
end
