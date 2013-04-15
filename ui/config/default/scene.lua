Scene = 
{
	dwObjType = TARGET.NO_TARGET, 
	dwObjID = 0, 
	bHaveScene = false,
}

g_Scene_tCameraStatic = {}
g_Scene_tCameraRuntime = {}
g_Scene_bMouseMove = false

RegisterCustomData("g_Scene_tCameraStatic")
RegisterCustomData("g_Scene_tCameraRuntime")
RegisterCustomData("g_Scene_bMouseMove")

local thisParam = {}

function Scene.OnFrameCreate()
	this:RegisterEvent("PLAYER_ENTER_SCENE")
	this:RegisterEvent("PLAYER_LEAVE_SCENE")
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("STOP_AUTO_MOVE_TO_TARGET")
	this:RegisterEvent("STOP_FOLLOW")
	this:RegisterEvent("PLAYER_EXIT_GAME")
	
	Scene.UpdateSceneSize(this)
end

function Scene.UpdateSceneSize(frame)
	local w, h = Station.GetClientSize()
	frame:SetSize(w, h)
	frame:Lookup("Scene_Main"):SetSize(w, h)
	frame:SetRelPos(0, 0)

	Login.UpdateSdoaTaskBarPosition("GAME")
end

function Scene.OnEvent(event)
	if event == "PLAYER_ENTER_SCENE" then
		local player = GetClientPlayer()
		if arg0 == player.dwID then
			local p3DScene = KG3DEngine.GetScene(player.GetScene().dwID)
			this:Lookup("Scene_Main"):SetScene(p3DScene)
			thisParam.bHaveScene = true
			
			Scene.FixCameraParams()
			
			Scene.ApplyCameraParam()
			
			Scene.OnKillFocus()

			collectgarbage("collect")
		end
	elseif event == "PLAYER_LEAVE_SCENE" then
		local clientPlayer = GetClientPlayer()
		if clientPlayer == nil or arg0 == clientPlayer.dwID then
			Scene.SaveCameraParam()

			this:Lookup("Scene_Main"):SetScene(nil)
			thisParam.bHaveScene = false
			Scene.OnKillFocus()
		end
	elseif event == "PLAYER_EXIT_GAME" then
		local pScene = GetClientScene()
		if pScene then
			Scene.SaveCameraParam()
		end
	elseif event == "UI_SCALED" then
		Scene.UpdateSceneSize(this)
	elseif event == "STOP_AUTO_MOVE_TO_TARGET" then
		if arg0 == "REACH" then
			if arg1 == TARGET.DOODAD then
				Scene.dwNeedOpenDoodad = arg2
			else
				Scene.dwNeedOpenDoodad = nil
				if not InteractTarget(arg1, arg2) then
					CastCommonSkill(true)
				end
			end
		else
			Scene.dwNeedOpenDoodad = nil
		end
	elseif event == "STOP_FOLLOW" then
		Scene.dwNeedOpenDoodad = nil
		if arg0 == "MISS_TARGET" then
			OutputMessage("MSG_SYS", g_tStrings.STR_FOLLOW_STOPED)
		end
	end
end

function Scene.FixCameraParams()
	local fDragSpeed, fMaxCameraDistance, fSpringResetSpeed, fCameraResetSpeed, nResetMode = Camera_GetParams()
	if not g_Scene_tCameraStatic.fDragSpeed then
		g_Scene_tCameraStatic.fDragSpeed = fDragSpeed
	end
	if not g_Scene_tCameraStatic.fMaxCameraDistance then
		g_Scene_tCameraStatic.fMaxCameraDistance = fMaxCameraDistance
	end
	if not g_Scene_tCameraStatic.fSpringResetSpeed then
		g_Scene_tCameraStatic.fSpringResetSpeed = fSpringResetSpeed
	end
	if not g_Scene_tCameraStatic.fCameraResetSpeed then
		g_Scene_tCameraStatic.fCameraResetSpeed = fCameraResetSpeed
	end
	if not g_Scene_tCameraStatic.nResetMode then
		g_Scene_tCameraStatic.nResetMode = nResetMode
	end

	local fCameraToObjectEyeScale, fYaw, fPitch = Camera_GetRTParams()
	if not g_Scene_tCameraRuntime.fCameraToObjectEyeScale then
		g_Scene_tCameraRuntime.fCameraToObjectEyeScale = fCameraToObjectEyeScale
	end
	if not g_Scene_tCameraRuntime.fYaw then
		g_Scene_tCameraRuntime.fYaw = fYaw
	end
	if not g_Scene_tCameraRuntime.fPitch then
		g_Scene_tCameraRuntime.fPitch = fPitch
	end	
end

function Scene.OnFrameBreathe()
	if Scene.bMouseIn and thisParam.bHaveScene then
		Scene.RefreshMouseOverObj()
	end
	
	if Scene.dwNeedOpenDoodad then
		local player = GetClientPlayer()
	    if player.nMoveState == MOVE_STATE.ON_STAND or player.nMoveState == MOVE_STATE.ON_FLOAT then
			if not InteractTarget(TARGET.DOODAD, Scene.dwNeedOpenDoodad) then
				CastCommonSkill(true)
			end
			Scene.dwNeedOpenDoodad = nil
	    end
	end
end

function Scene.OnMouseEnter()
	Scene.bMouseIn = true
	Scene.RefreshMouseOverObj()
end

function Scene.OnMouseLeave()
	Scene.bMouseIn = false
	if UserSelect.IsSelectPoint() then
		UserSelect.SatisfySelectPoint(0, 0, 0, true)
	elseif UserSelect.IsSelectCharacter() then
		UserSelect.SatisfySelectCharacter(TARGET.NO_TARGET, 0)
	end

	if Scene.dwObjType ~= TARGET.NO_TARGET then
		local player = GetClientPlayer()
		local dwTargetType, dwTargetID = TARGET.NO_TARGET, 0
		if player then
			dwTargetType, dwTargetID = GetClientPlayer().GetTarget()
		end
		if dwTargetType ~= Scene.dwObjType or dwTargetID ~= Scene.dwObjID then
			SceneObject_SetBrightness(Scene.dwObjType, Scene.dwObjID, 0)
		end
		Scene.dwObjType, Scene.dwObjID = TARGET.NO_TARGET, 0
	end

	HideTip(true)
	
	if not IsCursorInExclusiveMode() then
		Cursor.Switch(CURSOR.NORMAL)
	end	
end

function Scene.RefreshMouseOverObj()
	local tSelectObject = Scene_SelectObject("nearest")
	if not tSelectObject then
		return
	end
	
	local dwObjType, dwObjID = tSelectObject[1]["Type"], tSelectObject[1]["ID"]

	if UserSelect.IsSelectPoint() then
		local x, y, z = Scene_SelectGround()
		UserSelect.SatisfySelectPoint(x, y, z)
	elseif UserSelect.IsSelectCharacter() then
		UserSelect.SatisfySelectCharacter(dwObjType, dwObjID)
	end
	
	if Scene.dwObjType ~= TARGET.NO_TARGET then
		local dwTargetType, dwTargetID = GetClientPlayer().GetTarget()
		if dwTargetType ~= Scene.dwObjType or dwTargetID ~= Scene.dwObjID then
			SceneObject_SetBrightness(Scene.dwObjType, Scene.dwObjID, 0)
		end
		Scene.dwObjType, Scene.dwObjID = TARGET.NO_TARGET, 0
	end

	if not Cursor.IsVisible() then
		HideTip(true)
		return
	end
	
	if dwObjType == TARGET.PLAYER then
		if NeedHightlightPlayerWhenOver(dwObjID) then
			SceneObject_SetBrightness(dwObjType, dwObjID, 0.75)
			Scene.dwObjType, Scene.dwObjID = dwObjType, dwObjID
		end
		ChangeCursorWhenOverPlayer(dwObjID)
		OutputPlayerTip(dwObjID)
	elseif dwObjType == TARGET.NPC then
		if NeedHightlightNpcWhenOver(dwObjID) then
			SceneObject_SetBrightness(dwObjType, dwObjID, 0.75)
			Scene.dwObjType, Scene.dwObjID = dwObjType, dwObjID
		end
		ChangeCursorWhenOverNpc(dwObjID)
		OutputNpcTip(dwObjID)
	elseif dwObjType == TARGET.DOODAD then
		if NeedHightlightDoodadWhenOver(dwObjID) then
			SceneObject_SetBrightness(dwObjType, dwObjID, 0.75)
			Scene.dwObjType, Scene.dwObjID = dwObjType, dwObjID
		end
		ChangeCursorWhenOverDoodad(dwObjID)
		OutputDoodadTip(dwObjID)
	else
		if not IsCursorInExclusiveMode() then
			Cursor.Switch(CURSOR.NORMAL)
		end
		HideTip(true)
	end
end

function Scene.OnKillFocus()
	if thisParam.bLDown then
		Scene.OnSceneLButtonUp()
	end
	
	if thisParam.bRDown then
		Scene.OnSceneRButtonUp()
	end
end

function Scene.OnSceneLButtonDown()
	local x, y = Station.GetMessagePos(false)
	if not thisParam.bRDown then
	
		----------------------------------------
		if thisParam.nCX and x == thisParam.nCX  and y == thisParam.nCY and GetTickCount() - thisParam.nUpTime < 20 then --20ms
			x, y = thisParam.x, thisParam.y
		end
		----------------------------------------
	    
		local tSelectObject = Scene_SelectObject("all")
		thisParam.dwObjType, thisParam.dwObjID = GetFitObject(tSelectObject)
		
		Cursor.Show(false)
		thisParam.x, thisParam.y = x, y
		thisParam.bDownTime = GetTickCount()
		Camera_BeginDrag()
	end
	Camera_EnableControl(CONTROL_CAMERA, true)
	Station.SetCapture(this)
	if thisParam.bRDown then
		Camera_EnableControl(CONTROL_AUTO_RUN, false)
	end
	thisParam.bLDown	= true
end

function Scene.OnSceneLButtonUp()
	local x, y = Station.GetMessagePos(false)
	if not thisParam.bLDown then
--		if not thisParam.bRDown then
--			Hand_DropHandObj()
--		end
		return
	end
	thisParam.bLDown	= false
	Camera_EnableControl(CONTROL_CAMERA, false)
	if not thisParam.bRDown then
	
		----------------------------------------
		thisParam.nCX, thisParam.nCY = Cursor.GetPos(false)
		thisParam.nUpTime = GetTickCount()
		----------------------------------------
	
		local bDrag, _, mX, mY, fX, fY = Camera_HasDragged()
		bDrag = (bDrag and mX * mX + mY * mY > 9) or (GetTickCount() - thisParam.bDownTime > 500)
		Camera_EndDrag(thisParam.x, thisParam.y)
		Cursor.Show(true)
		Station.SetCapture(nil)
		
		if not bDrag then
			if Hand_DropHandObj() then
				return
			end
			
			if UserSelect.IsSelectPoint() then
				local x, y, z = Scene_SelectGround()
				if UserSelect.DoSelectPoint(x, y, z) then
					return
				end
			end
			
			if UserSelect.DoSelectCharacter(thisParam.dwObjType, thisParam.dwObjID) then
				return
			end
			
			if g_Scene_bMouseMove then
				local dwObjType, dwObjID = thisParam.dwObjType, thisParam.dwObjID
				local player = GetClientPlayer()
				local dwTargetType, dwTargetID = player.GetTarget()
				if dwObjType == TARGET.NPC or dwObjType == TARGET.PLAYER then
					if dwTargetType == dwObjType and dwTargetID == dwObjID then
						Scene.dwNeedOpenDoodad = nil
						AutoMoveToTarget(dwTargetType, dwTargetID)
					else
						SelectTarget(dwObjType, dwObjID)
					end
				elseif dwObjType == TARGET.DOODAD then
					Scene.dwNeedOpenDoodad = nil
					AutoMoveToTarget(dwObjType, dwObjID)
				else
					Scene.dwNeedOpenDoodad = nil
					local x, y, z = Scene_SelectGround()
					if x and y and z then
						x, y, z = Scene_GameWorldPositionToScenePosition(x, y, z, 0)
						AutoMoveToPoint(x, y, z)
					end
				end
			else
				SelectTarget(thisParam.dwObjType, thisParam.dwObjID)
			end
		end
	end
end

function Scene.OnSceneRButtonDown()
	local x, y = Station.GetMessagePos(false)
	if not thisParam.bLDown then
	
		----------------------------------------
		if thisParam.nCX and x == thisParam.nCX  and y == thisParam.nCY and GetTickCount() - thisParam.nUpTime < 20 then --20ms
			x, y = thisParam.x, thisParam.y
		end
		----------------------------------------
		
		local tSelectObject = Scene_SelectObject("all")
		thisParam.dwObjType, thisParam.dwObjID = GetFitObject(tSelectObject)
	
		Cursor.Show(false)
		thisParam.x, thisParam.y = x, y
		thisParam.bDownTime = GetTickCount()
		Camera_BeginDrag()
	end
	Camera_EnableControl(CONTROL_OBJECT_STICK_CAMERA, true)	
	Station.SetCapture(this)
		
	if thisParam.bLDown then
		Camera_EnableControl(CONTROL_AUTO_RUN, false)
	end
	
	thisParam.bRDown	= true
end

function Scene.OnSceneRButtonUp()
	local x, y = Station.GetMessagePos(false)
	if not thisParam.bRDown then
		return
	end
	thisParam.bRDown	= false
	Camera_EnableControl(CONTROL_OBJECT_STICK_CAMERA, false)
	if not thisParam.bLDown then
	
		----------------------------------------
		thisParam.nCX, thisParam.nCY = Cursor.GetPos(false)
		thisParam.nUpTime = GetTickCount()
		----------------------------------------
	
		local _, bDrag, mX, mY, fX, fY = Camera_HasDragged()
		bDrag = (bDrag and mX * mX + mY * mY > 9) or (GetTickCount() - thisParam.bDownTime > 500)
		Camera_EndDrag(thisParam.x, thisParam.y)
		Cursor.Show(true)
		Station.SetCapture(nil)
		
		if not bDrag then
			local bInteracted = false
			
			if thisParam.dwObjType ~= TARGET.NO_TARGET then
				if thisParam.dwObjType ~= TARGET.DOODAD then --对doodad进行操作不切换目标。
					SelectTarget(thisParam.dwObjType, thisParam.dwObjID)
				end
				if InteractTarget(thisParam.dwObjType, thisParam.dwObjID) then
					bInteracted = true
				end
				if not bInteracted then --右键攻击
					 CastCommonSkill(true)
				end
			end
		end
	end
end

function Scene.SaveCameraParam()
	g_Scene_tCameraStatic = {}
	g_Scene_tCameraStatic.fDragSpeed, 
	g_Scene_tCameraStatic.fMaxCameraDistance, 
	g_Scene_tCameraStatic.fSpringResetSpeed, 
	g_Scene_tCameraStatic.fCameraResetSpeed, 
	g_Scene_tCameraStatic.nResetMode = Camera_GetParams()
	
	g_Scene_tCameraRuntime = {}
	g_Scene_tCameraRuntime.fCameraToObjectEyeScale, 
	g_Scene_tCameraRuntime.fYaw, 
	g_Scene_tCameraRuntime.fPitch = Camera_GetRTParams()
end

function Scene.ApplyCameraParam()
	Camera_SetParams(
		g_Scene_tCameraStatic.fDragSpeed, 
		g_Scene_tCameraStatic.fMaxCameraDistance, 
		g_Scene_tCameraStatic.fSpringResetSpeed, 
		g_Scene_tCameraStatic.fCameraResetSpeed, 
		g_Scene_tCameraStatic.nResetMode
	)
	
	Camera_SetRTParams(
		g_Scene_tCameraRuntime.fCameraToObjectEyeScale, 
		g_Scene_tCameraRuntime.fYaw, 
		g_Scene_tCameraRuntime.fPitch
	)
end

function SceneMain_ToggleVisible()
	local frame = Station.Lookup("Lowest/Scene")
	if frame then
		frame:ToggleVisible()
	else
		Wnd.OpenWindow("Scene")
	end
end

function SceneMain_IsCursorIn()
	return Scene.bMouseIn
end

function SceneMain_GetFrame()
	return Station.Lookup("Lowest/Scene")
end

function IsMouseMove()
	return g_Scene_bMouseMove
end

function SetMouseMove(bMouseMove)
	g_Scene_bMouseMove = bMouseMove
	SetUserPreferences(1451, "b", true)
	SetUserPreferences(1452, "b", bMouseMove)
end

function SetMouseMoveData()
	if not GetUserPreferences(1451, "b") then
		SetUserPreferences(1452, "b", g_Scene_bMouseMove)
		SetUserPreferences(1451, "b", true)
	else
		g_Scene_bMouseMove = GetUserPreferences(1452, "b")
	end
end

RegisterEvent("LOADING_END", SetMouseMoveData)
