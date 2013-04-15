LoginSingleRole={
	
	m_scene;
	m_camera;
	m_modelMgr;
	
	m_tModelRole = {};
	m_tModelRoleSFX = {};
	m_tModelPath = {};
	
	m_nX = 6853;
	m_nY = 530;
	m_nZ = 5670;
	m_nYaw = -0.4;
	m_nPitch = 0.0;
	m_xBeginDrag = 0;
	m_yBeginDrag = 0;
	m_bMouseIn = false;
	
	m_nCameraRadiusExpect = 550;
	m_nCameraRadius = 550;

	m_nCameraYaw = -1.5757050653161;
	m_bTurnLeft = false;
	m_bTurnRight = false;

	m_nCameraPitch = 0.079767000970054;

	TURN_YAW = math.pi / 18;
	
	MIN_RADIUS = 175;
	MAX_RADIUS = 800;
	
	m_tAllEquipRes = {};
	m_tAnimationRes = {
		Idle = {},
		Brief = {}
	};
	m_nInitYaw = -0.4;
	m_nInitPitch = 0.0;
	m_nInitCameraRadius = 550;
	m_nInitCameraYaw = -1.5757050653161;
	m_nInitCameraPitch = 0.079767000970054;
	m_nInitCameraRadiusExpect = 550;
	
	m_tSocketName=
	{
		[WEAPON_DETAIL.SWORD] = {RH="S_RC"}, --短兵类
		[WEAPON_DETAIL.DOUBLE_WEAPON] = {LH="S_LC", RH="S_RC"},  --双兵类
		[WEAPON_DETAIL.PEN] = {RH="S_RP"}, --笔类
		[WEAPON_DETAIL.BOW] = {RH="S_bow"},--千机匣
		[WEAPON_DETAIL.FLUTE] = {RH="S_flute"},  -- 笛类
		[WEAPON_DETAIL.SPEAR] = {RH="S_Long"}, --长兵类
		[WEAPON_DETAIL.WAND] = {RH="S_Long"},  --棍类
		[WEAPON_DETAIL.BIG_SWORD] = {RH="S_epee"},  --重剑
	};
	
	
RestoreCameraState=function(nRadiusDelta)
	nRadiusDelta = nRadiusDelta or 0
	LoginSingleRole.m_nCameraRadiusExpect = LoginSingleRole.m_nInitCameraRadiusExpect + nRadiusDelta
	LoginSingleRole.m_nYaw = LoginSingleRole.m_nInitYaw;
	LoginSingleRole.m_nPitch = LoginSingleRole.m_nInitPitch;
	LoginSingleRole.m_nCameraRadius = LoginSingleRole.m_nInitCameraRadius + nRadiusDelta
	LoginSingleRole.m_nCameraYaw = LoginSingleRole.m_nInitCameraYaw
	LoginSingleRole.m_nCameraPitch = LoginSingleRole.m_nInitCameraPitch
	LoginSingleRole.UpdateCameraPosition();
end;

SetCameraRadius=function(nRadius)
	LoginSingleRole.m_nCameraRadiusExpect = nRadius
end;
		
OnKillFocus = function()
	if LoginSingleRole.bLDown then
		LoginSingleRole.OnSceneLButtonUp()
	end
	
	if LoginSingleRole.bRDown then
		LoginSingleRole.OnSceneRButtonUp()
	end
end;

OnSceneLButtonDown = function()
	local x, y = Station.GetMessagePos(false)
	if not LoginSingleRole.bRDown then
		Cursor.Show(false)
		LoginSingleRole.x, LoginSingleRole.y = x, y
		Station.SetCapture(this)
	end
	LoginSingleRole.bLDown	= true
end;

OnSceneLButtonUp = function()
	local x, y = Station.GetMessagePos(false)
	if not LoginSingleRole.bLDown then
		return
	end
	LoginSingleRole.bLDown	= false
	
	if not LoginSingleRole.bRDown then
		Cursor.SetPos(LoginSingleRole.x, LoginSingleRole.y, false)
		Cursor.Show(true)
		Station.SetCapture(nil)
	end
end;

OnSceneRButtonDown = function()
	local x, y = Station.GetMessagePos(false)
	if not LoginSingleRole.bLDown then
		Cursor.Show(false)
		LoginSingleRole.x, LoginSingleRole.y = x, y
		Station.SetCapture(this)
	end
	LoginSingleRole.bRDown	= true
end;

OnSceneRButtonUp = function()
	local x, y = Station.GetMessagePos(false)
	if not LoginSingleRole.bRDown then
		return
	end
	LoginSingleRole.bRDown	= false
	
	if not LoginSingleRole.bLDown then
		Cursor.SetPos(LoginSingleRole.x, LoginSingleRole.y, false)
		Cursor.Show(true)
		Station.SetCapture(nil)
	end
end;

OnFrameBreathe=function()
	if LoginSingleRole.m_tModelRole then
		if LoginSingleRole.m_bTurnLeft or LoginSingleRole.m_bTurnRight then
			if LoginSingleRole.m_bTurnLeft then
				LoginSingleRole.m_nCameraYaw = LoginSingleRole.m_nCameraYaw + LoginSingleRole.TURN_YAW
				LoginSingleRole.UpdateCameraPosition()
			elseif LoginSingleRole.m_bTurnRight then
				LoginSingleRole.m_nCameraYaw = LoginSingleRole.m_nCameraYaw - LoginSingleRole.TURN_YAW
				LoginSingleRole.UpdateCameraPosition()
			end
		else
			if LoginSingleRole.bLDown or LoginSingleRole.bRDown then
				local x, y = Cursor.GetPos(false)
				if x ~= LoginSingleRole.x or y ~= LoginSingleRole.y then
					local cx, cy = Station.GetClientSize(false)
					local dx = -(x - LoginSingleRole.x) / cx * math.pi
					local dy = (y - LoginSingleRole.y) / cy * math.pi
			
					LoginSingleRole.m_nCameraYaw = LoginSingleRole.m_nCameraYaw + dx
					LoginSingleRole.m_nCameraPitch = LoginSingleRole.m_nCameraPitch + dy
					
					if LoginSingleRole.m_nCameraPitch < 0.001 then
						LoginSingleRole.m_nCameraPitch = 0.001
					elseif LoginSingleRole.m_nCameraPitch > math.pi / 2 - 0.001 then
						LoginSingleRole.m_nCameraPitch = math.pi / 2 - 0.001
					end
			
					LoginSingleRole.UpdateCameraPosition()
					
					Cursor.SetPos(LoginSingleRole.x, LoginSingleRole.y, false)			
				end
			end
		end
	end
	
	if LoginSingleRole.m_nTime then
	    local nTime = GetTickCount()
	    if nTime - LoginSingleRole.m_nTime > 10 then
			
        	local szSex = LoginCustomRole.GetRoleSex(LoginSingleRole.m_nRoleType)
        	local nSchoolAniId = LoginCustomRole.m_tSchoolAni[LoginSingleRole.m_szSchoolName][szSex]
			
			if LoginSingleRole.m_tModelRole["MDL"] then
				LoginSingleRole.tSeqAni[LoginSingleRole.m_tModelRole["MDL"]] = nil
			end
			
        	LoginSingleRole.PlaySchoolAni(
        	    LoginSingleRole.m_tModelRole["MDL"],
        	    LoginSingleRole.m_nRoleType,
        	    nSchoolAniId,
        	    "once"
        	)
    	    LoginSingleRole.m_nTime = nil
    	end
	end
	
	if LoginSingleRole.fModelAlpha then
		local model = LoginSingleRole.m_tModelRole["MDL"]
		if not model then
			LoginSingleRole.fModelAlpha = nil
			return
		end
		
		local fAlpha = model:GetAlpha() 
		if fAlpha > LoginSingleRole.fModelAlpha then
			model:SetAlpha(math.max(fAlpha - 0.2, 0.0))
		else
			model:SetAlpha(1.0)
			LoginSingleRole.fModelAlpha = nil
		end
	end
	
	if LoginSingleRole.m_nStartAlpha then
		if GetTickCount() >= LoginSingleRole.m_nStartAlpha then
			LoginSingleRole.fModelAlpha = 0.0
			LoginSingleRole.m_nStartAlpha = nil
		end
	end
end;

OnFrameCreate=function()
	Scene_New(Login.SCENE_SINGLE_ROLE, Table_GetPath("SCENE_LOGIN"))
	Scene_AddOutputWindow(Login.SCENE_SINGLE_ROLE)
	
	LoginSingleRole.m_scene = KG3DEngine.GetScene(Login.SCENE_SINGLE_ROLE)
	LoginSingleRole.m_modelMgr = KG3DEngine.GetModelMgr()
		
	this:Lookup("WndSingleRole/Scene_Role"):SetScene(LoginSingleRole.m_scene)
	
	-- Camera
	LoginSingleRole.m_camera = LoginSingleRole.m_scene:GetCamera()

	if not Login.m_bPlayingCameraMovement then
		LoginSingleRole.PlayCameraAnimation(Table_GetPath("CAMERA_ANI_LOGIN"), true)
		Login.m_bPlayingCameraMovement = true
	end

	this:RegisterEvent("RENDER_FRAME_UPDATE")
	this:RegisterEvent("UI_SCALED")
	LoginSingleRole.OnEvent("UI_SCALED")
	this:RegisterEvent("KG3D_PLAY_ANIMAION_FINISHED")
end;

OnFrameShow=function()
	LoginSingleRole.UpdateCameraPosition()
end;

OnEvent=function(event)
	if event == "UI_SCALED" then
		local w, h = Station.GetClientSize()
		this:SetSize(w, h)
		this:Lookup("WndSingleRole"):SetSize(w, h)
		this:Lookup("WndSingleRole/Scene_Role"):SetSize(w, h)
		
		this:Lookup("WndSingleRole"):SetPoint("TOPCENTER", 0, 0, "TOPCENTER", 0, 0)
	elseif event == "RENDER_FRAME_UPDATE" then
		local nCameraRadiusDelta = LoginSingleRole.m_nCameraRadiusExpect - LoginSingleRole.m_nCameraRadius
		if nCameraRadiusDelta ~= 0 then
			if nCameraRadiusDelta > 0 then
				LoginSingleRole.m_nCameraRadius = LoginSingleRole.m_nCameraRadius + nCameraRadiusDelta / 5
				if LoginSingleRole.m_nCameraRadius > LoginSingleRole.m_nCameraRadiusExpect then
					LoginSingleRole.m_nCameraRadius = LoginSingleRole.m_nCameraRadiusExpect
				end
			else
				LoginSingleRole.m_nCameraRadius = LoginSingleRole.m_nCameraRadius + nCameraRadiusDelta / 5
				if LoginSingleRole.m_nCameraRadius < LoginSingleRole.m_nCameraRadiusExpect then
					LoginSingleRole.m_nCameraRadius = LoginSingleRole.m_nCameraRadiusExpect
				end
			end
			LoginSingleRole.UpdateCameraPosition()
		end
	elseif event == "KG3D_PLAY_ANIMAION_FINISHED" then
		if LoginSingleRole.tSeqAni and not IsTableEmpty(LoginSingleRole.tSeqAni) then
			for model, v in pairs(LoginSingleRole.tSeqAni) do
				if argu == model then
					if LoginSingleRole.m_tModelRole["MDL"] ~= model then
						LoginSingleRole.tSeqAni[model] = nil
					else
						LoginSingleRole.StepSeqAni(model)
					end
					
					return
				end
			end
			LoginSingleRole.tSeqAni = {}
		end
	end
end;

OnFrameDestroy=function()
	Cursor.Show(1)

	LoginSingleRole.UnloadModel()

	Scene_RemoveOutputWindow(Login.SCENE_SINGLE_ROLE)
	Scene_Delete(Login.SCENE_SINGLE_ROLE)
end;

OnMouseWheel=function()
	local nDelta = Station.GetMessageWheelDelta()
	
	LoginSingleRole.m_nCameraRadius = LoginSingleRole.m_nCameraRadius + 50 * nDelta
	if LoginSingleRole.m_nCameraRadius > LoginSingleRole.MAX_RADIUS then
		LoginSingleRole.m_nCameraRadius = LoginSingleRole.MAX_RADIUS
	elseif LoginSingleRole.m_nCameraRadius < LoginSingleRole.MIN_RADIUS then
		LoginSingleRole.m_nCameraRadius = LoginSingleRole.MIN_RADIUS
	end
	
	LoginSingleRole.m_nCameraRadiusExpect = LoginSingleRole.m_nCameraRadius
	
	LoginSingleRole.UpdateCameraPosition()

	return 1
end;

OnFrameKeyDown=function()
	local frameRole = Station.Lookup("Topmost/LoginCustomRole")
	local frameRoleNext = Station.Lookup("Topmost/LoginCustomRoleNext")
	
	if frameRoleNext and frameRoleNext:IsVisible() then
		local saveThis = this;
		this = frameRoleNext
		local nRet = LoginCustomRoleNext.OnFrameKeyDown()
		this = saveThis
		if nRet == 1 then
			return 1
		end
	elseif frameRole and frameRole:IsVisible() then
		local saveThis = this;
		this = frameRole
		local nRet = LoginCustomRole.OnFrameKeyDown()
		this = saveThis
		if nRet == 1 then
			return 1
		end
	end
	
	local szKey = GetKeyName(Station.GetMessageKey())
	
	if szKey == "Esc" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		Login.StepPrev()
		return 1
	elseif szKey == "Enter" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		Login.StepNext()
		return 1
	end
	
	return 0
end;

BeginPlaySchoolAni=function(szSchoolName, nRoleType)
	if szSchoolName then
    	LoginSingleRole.m_nRoleType = nRoleType
    	LoginSingleRole.m_szSchoolName = szSchoolName
	    LoginSingleRole.m_nTime = GetTickCount()
		
		LoginSingleRole.m_nStartTime = LoginSingleRole.m_nTime
		LoginSingleRole.m_nTotalTime = 1500 + 1500
	else
	    LoginSingleRole.m_nTime = nil
	end
end;

UpdateModel=function(tRoleEquipID, szSchoolName, bSheath, nWeaponID)
	LoginSingleRole.ShowModel(false)
	
	LoginSingleRole.LoadRoleRes(tRoleEquipID)
	if nWeaponID and bSheath then
		local tSocket = LoginSingleRole.m_tSocketName[nWeaponID]
		if nWeaponID == WEAPON_DETAIL.BIG_SWORD then
			tSocket = LoginSingleRole.m_tSocketName[WEAPON_DETAIL.SWORD]
			LoginSingleRole.m_tAllEquipRes["HeavySword"]["Socket"] = "S_RH"
		end
		LoginSingleRole.m_tAllEquipRes["RL_WEAPON_LH"]["Socket"] = tSocket.LH
		LoginSingleRole.m_tAllEquipRes["RL_WEAPON_RH"]["Socket"] = tSocket.RH
		
	elseif nWeaponID and not bSheath then
		LoginSingleRole.m_tAllEquipRes["RL_WEAPON_LH"]["Socket"] = "S_LH"
		LoginSingleRole.m_tAllEquipRes["RL_WEAPON_RH"]["Socket"] = "S_RH"
	end
	
	LoginSingleRole.LoadModel(tRoleEquipID["RoleType"])
	
	LoginSingleRole.PlayAnimation("Idle", "loop")
	LoginSingleRole.PlayWeaponAnimation(tRoleEquipID["RoleType"], tRoleEquipID["WeaponStyle"])
end;


GetSkillCD=function()
	if LoginSingleRole.m_nStartTime and GetTickCount() - LoginSingleRole.m_nStartTime > LoginSingleRole.m_nTotalTime then
		LoginSingleRole.m_nStartTime = nil
	end
	return LoginSingleRole.m_nStartTime, LoginSingleRole.m_nTotalTime
end;

PlayCameraAnimation=function(szFilePath, bLoop)
	local cm = LoginSingleRole.m_scene:GetCameraMovement()
	cm:LoadFromFile(szFilePath)
	
	local ca = cm:GetCurrentAnimation()
	ca:Play(bLoop)
end;

StopCameraAnimation=function()
	local cm = LoginSingleRole.m_scene:GetCameraMovement()
	if not cm then
		return
	end
	local ca = cm:GetCurrentAnimation()
	if not ca then
		return
	end
	ca:Stop()
end;

PauseCameraAnimation=function(bNoStaticPos)
	local cm = LoginSingleRole.m_scene:GetCameraMovement()
	if not cm then
		return
	end
	local ca = cm:GetCurrentAnimation()
	if not ca then
		return
	end
	ca:Pause()

	if not bNoStaticPos then
		LoginSingleRole.UpdateCameraPosition()
	end
end;

---------------------------------- Private --------------------------------------------
UpdateCameraPosition=function()
	local ycos = LoginSingleRole.m_nCameraRadius * math.cos(LoginSingleRole.m_nCameraPitch)
	local ysin = LoginSingleRole.m_nCameraRadius * math.sin(LoginSingleRole.m_nCameraPitch)
	local x = LoginSingleRole.m_nX + ycos * math.cos(LoginSingleRole.m_nCameraYaw)
	local y = LoginSingleRole.m_nY + ysin + 120
	local z = LoginSingleRole.m_nZ + ycos * math.sin(LoginSingleRole.m_nCameraYaw)
	
	local xLookAt = LoginSingleRole.m_nX
	local yLookAt = LoginSingleRole.m_nY + 120
	local zLookAt = LoginSingleRole.m_nZ
	
	LoginSingleRole.m_camera:SetLookAtPosition(xLookAt, yLookAt, zLookAt)
	LoginSingleRole.m_camera:SetPosition(x, y, z)
	LoginSingleRole.m_scene:SetFocus(xLookAt, yLookAt, zLookAt)
end;

LoadRoleRes=function(tRoleEquipID)
	-- load model and mesh
	LoginSingleRole.m_tAllEquipRes = Player_GetEquipResource(
        tRoleEquipID["RoleType"], 
        tRoleEquipID["FaceStyle"],       tRoleEquipID["HairStyle"],    
        tRoleEquipID["HelmStyle"],       tRoleEquipID["HelmColor"],       tRoleEquipID["HelmEnchant"],  
        tRoleEquipID["ChestStyle"],      tRoleEquipID["ChestColor"],      tRoleEquipID["ChestEnchant"],    
        tRoleEquipID["WaistStyle"],      tRoleEquipID["WaistColor"],      tRoleEquipID["WaistEnchant"], 
        tRoleEquipID["BangleStyle"],     tRoleEquipID["BangleColor"],     tRoleEquipID["BangleEnchant"],
        tRoleEquipID["BootsStyle"],      tRoleEquipID["BootsColor"],	  
        tRoleEquipID["WeaponStyle"],     tRoleEquipID["WeaponColor"], tRoleEquipID["WeaponEnchant1"],  tRoleEquipID["WeaponEnchant2"],  
        tRoleEquipID["BigSwordStyle"],   tRoleEquipID["BigSwordColor"],  tRoleEquipID["BigSwordEnchant1"],  tRoleEquipID["BigSwordEnchant2"], 
        tRoleEquipID["BackExtend"],      tRoleEquipID["WaistExtend"],
        tRoleEquipID["HorseStyle"],      tRoleEquipID["HorseAdornment1"], tRoleEquipID["HorseAdornment2"], 
        tRoleEquipID["HorseAdornment3"], tRoleEquipID["HorseAdornment4"], tRoleEquipID["Reserved"]
    )   
        
	-- load animation
	for szAniName, v in pairs(LoginSingleRole.m_tAnimationRes) do
		LoginSingleRole.m_tAnimationRes[szAniName] = { 
			Ani = "", AniSound = "", AniPlayType = "loop", AniPlaySpeed = 1, AniSoundRange = 0,
			SFX = "", SFXBone = "", SFXPlayType = "loop", SFXPlaySpeed = 1, SFXScale = 1 
		}
	
		local aAniRes = LoginSingleRole.m_tAnimationRes[szAniName]
		
		aAniRes["Ani"], aAniRes["AniSound"], aAniRes["AniPlayType"], aAniRes["AniPlaySpeed"]
		= Player_GetAnimationResource(tRoleEquipID["RoleType"], Login.m_aRoleAnimation[szAniName])
	end
end;

StopPlayAni=function()
	LoginSingleRole.tSeqAni = {}
end;

BeginPlaySeqAni=function(nRoleType, aAniID)
	local model = LoginSingleRole.m_tModelRole["MDL"]
	if not model then
		Trace("BeginPlaySeqAni model is not exist")
		return
	end
	
	LoginSingleRole.m_nTime = nil
	LoginSingleRole.tSeqAni = LoginSingleRole.tSeqAni or {}
	LoginSingleRole.tSeqAni[model] = 
	{
		nIndex = 1,
		aAniID = aAniID,
		model = model,
		nRoleType = nRoleType,
	}
	LoginSingleRole.PlaySeqAni(model)
end;

StepSeqAni=function(model)
	local t = LoginSingleRole.tSeqAni[model]
	local nIndex = t.nIndex
	local fnAction = t.aAniID[nIndex].fnAction
	local nLen = #t.aAniID
	
	LoginSingleRole.tSeqAni[model].nIndex = nIndex + 1
	if LoginSingleRole.tSeqAni[model].nIndex > nLen then
		LoginSingleRole.tSeqAni[model] = nil
	end
	
	if fnAction then
		fnAction()
	end
	
	if LoginSingleRole.tSeqAni[model] then
		LoginSingleRole.PlaySeqAni(model)
	end
end;

PlaySeqAni=function(model)
	if model ~= LoginSingleRole.m_tModelRole["MDL"] then
		LoginSingleRole.tSeqAni[model] = nil
		return
	end
	
	local tSeqAni = LoginSingleRole.tSeqAni[model]
	local nIndex = tSeqAni.nIndex
	local aAniID = tSeqAni.aAniID
	local nLen = #aAniID
	
	if nIndex > nLen then
		Trace("PlaySeqAni index error")
		return
	end
	
	local szPlayType  = aAniID[nIndex].szType or "once"
	local nAniID = aAniID[nIndex].nAniID
	local nRoleType = tSeqAni.nRoleType
	local fTweenTime = aAniID[nIndex].fTweenTime or 0.0;
	local bPlay = false
	
	if nAniID and nAniID ~= 0 then
		local szAnimationName, _, _, _ = Player_GetAnimationResource(nRoleType, nAniID)
		if szAnimationName then
			model:PlayAnimation(szPlayType, szAnimationName, 1, 0, fTweenTime)
			bPlay = true
		end
	end
	
	if nIndex == nLen and szPlayType == "loop" then
		LoginSingleRole.StepSeqAni(model)
	elseif not bPlay then
		LoginSingleRole.StepSeqAni(model)
	end
end;

PlaySchoolAni = function(model, nRoleType, nAniId, szPlayType)
    if not model or not nRoleType or not nAniId or not szPlayType then
        return
    end
	
	local szAnimationName, _, _, _ = Player_GetAnimationResource(nRoleType, nAniId)
	if szAnimationName then
	    model:PlayAnimation(szPlayType, szAnimationName, 1, 0)
	end
end;

LoadModelSFX=function(model, equipType)
	--Load SFX1
	if LoginSingleRole.m_tAllEquipRes[equipType]["SFX1"] then
		local modelsfx = LoginSingleRole.m_modelMgr:NewModel(LoginSingleRole.m_tAllEquipRes[equipType]["SFX1"])
		LoginSingleRole.m_tModelRoleSFX[equipType.."SFX1"] = modelsfx
		if modelsfx then
			modelsfx:BindToBone(model)
		end
	end
	--Load SFX2
	if LoginSingleRole.m_tAllEquipRes[equipType]["SFX2"] then
		local modelsfx = LoginSingleRole.m_modelMgr:NewModel(LoginSingleRole.m_tAllEquipRes[equipType]["SFX2"])
		LoginSingleRole.m_tModelRoleSFX[equipType.."SFX2"] = modelsfx
		if modelsfx then
			modelsfx:BindToBone(model)
		end
	end
end;

UnloadModelSFX=function(equipType)
	--Unload SFX2
	if LoginSingleRole.m_tModelRoleSFX[equipType.."SFX2"] then
		LoginSingleRole.m_tModelRoleSFX[equipType.."SFX2"]:UnbindFromOther()
		LoginSingleRole.m_tModelRoleSFX[equipType.."SFX2"]:Release()
		LoginSingleRole.m_tModelRoleSFX[equipType.."SFX2"] = nil
	end
	--Unload SFX1
	if LoginSingleRole.m_tModelRoleSFX[equipType.."SFX1"] then
		LoginSingleRole.m_tModelRoleSFX[equipType.."SFX1"]:UnbindFromOther()
		LoginSingleRole.m_tModelRoleSFX[equipType.."SFX1"]:Release()
		LoginSingleRole.m_tModelRoleSFX[equipType.."SFX1"] = nil
	end
end;

SetModelVisible=function(bShow)
	if not LoginSingleRole.m_tModelRole["MDL"] then
		return
	end
	
	if bShow then
		LoginSingleRole.m_tModelRole["MDL"]:SetAlpha(1.0);
	else
		LoginSingleRole.m_tModelRole["MDL"]:SetAlpha(0.0);
	end
end;

LoadModel=function(nRoleType)
	local bUnloadMDL = false
	
	if LoginSingleRole.m_tAllEquipRes["MDL"] then
		if not LoginSingleRole.m_tModelPath["MDL"] or 
			LoginSingleRole.m_tModelPath["MDL"] ~= LoginSingleRole.m_tAllEquipRes["MDL"] then
			LoginSingleRole.UnloadModel()
			bUnloadMDL = true
			LoginSingleRole.m_tModelRole["MDL"] = LoginSingleRole.m_modelMgr:NewModel(LoginSingleRole.m_tAllEquipRes["MDL"], true)
			local scale = LoginSingleRole.m_tAllEquipRes["MDLScale"]
			LoginSingleRole.m_tModelRole["MDL"]:SetScaling(scale, scale, scale)
			LoginSingleRole.m_tModelPath["MDL"] = LoginSingleRole.m_tAllEquipRes["MDL"]
		end

		-- load part and sfx
		for equipType, equipRes in pairs(LoginSingleRole.m_tAllEquipRes) do
			if equipType ~= "MDL" and equipType ~= "MDLScale" and not LoginSingleRole.m_tAllEquipRes[equipType]["Socket"] then
				-- part
				LoginSingleRole.LoadPart(nRoleType, equipType)
			end
		end

		-- load socket and sfx
		for equipType, equipRes in pairs(LoginSingleRole.m_tAllEquipRes) do
			if equipType ~= "MDL" and equipType ~= "MDLScale" then
				-- socket
				LoginSingleRole.LoadSocket(nRoleType, equipType)
			end
		end
		
		local mdl = LoginSingleRole.m_tModelRole["MDL"]
		if mdl and bUnloadMDL then
			mdl:RegisterEventHandler()
			mdl:SetTranslation(LoginSingleRole.m_nX, LoginSingleRole.m_nY, LoginSingleRole.m_nZ)
		end
		LoginSingleRole.ShowModel(true)
	else
		UnloadModel()
	end
end;

LoadPart=function(nRoleType, equipType)
	if not LoginSingleRole.m_tModelPath[equipType] then
		LoginSingleRole.m_tModelPath[equipType] = {}
	end
	
	if LoginSingleRole.m_tAllEquipRes[equipType]["Mesh"] then
		if not LoginSingleRole.m_tModelPath[equipType]["Mesh"] or
		 	LoginSingleRole.m_tModelPath[equipType]["Mesh"] ~= LoginSingleRole.m_tAllEquipRes[equipType]["Mesh"] then
			LoginSingleRole.UnloadPart(equipType)
			
			local model = LoginSingleRole.m_modelMgr:NewModel(LoginSingleRole.m_tAllEquipRes[equipType]["Mesh"], true)
			LoginSingleRole.m_tModelRole[equipType] = model
			LoginSingleRole.m_tModelPath[equipType]["Mesh"] = LoginSingleRole.m_tAllEquipRes[equipType]["Mesh"]
			
			if model then
				LoginSingleRole.m_tModelRole["MDL"]:Attach(model)
			end
		end
		
		local model = LoginSingleRole.m_tModelRole[equipType]
		
		if model then
			if LoginSingleRole.m_tAllEquipRes[equipType]["Mtl"] then
				model:LoadMaterialFromFile(LoginSingleRole.m_tAllEquipRes[equipType]["Mtl"])
			end
	
			model:SetDetail(nRoleType, LoginSingleRole.m_tAllEquipRes[equipType]["ColorChannel"])
	
			local scale = LoginSingleRole.m_tAllEquipRes[equipType]["MeshScale"]
			model:SetScaling(scale, scale, scale)
			
			LoginSingleRole.UnloadModelSFX(equipType)
			LoginSingleRole.LoadModelSFX(model, equipType)
		end
	else
		LoginSingleRole.UnloadPart(equipType)
	end
end;

LoadSocket=function(nRoleType, equipType)
	if not LoginSingleRole.m_tModelPath[equipType] then
		LoginSingleRole.m_tModelPath[equipType] = {}
	end
	
	if LoginSingleRole.m_tAllEquipRes[equipType]["Mesh"] and LoginSingleRole.m_tAllEquipRes[equipType]["Socket"] then
		if not LoginSingleRole.m_tModelPath[equipType]["Mesh"] or
		 	LoginSingleRole.m_tModelPath[equipType]["Mesh"] ~= LoginSingleRole.m_tAllEquipRes[equipType]["Mesh"] then
		 	LoginSingleRole.UnloadSocket(equipType)	
		 	
			local model = LoginSingleRole.m_modelMgr:NewModel(LoginSingleRole.m_tAllEquipRes[equipType]["Mesh"], true)
			LoginSingleRole.m_tModelRole[equipType] = model
			LoginSingleRole.m_tModelPath[equipType]["Mesh"] = LoginSingleRole.m_tAllEquipRes[equipType]["Mesh"]
			LoginSingleRole.m_tModelPath[equipType]["Socket"] = LoginSingleRole.m_tAllEquipRes[equipType]["Socket"]
		end
		
		local model = LoginSingleRole.m_tModelRole[equipType]
		
		if model then
			model:BindToSocket(LoginSingleRole.m_tModelRole["MDL"], LoginSingleRole.m_tAllEquipRes[equipType]["Socket"])
			
			if LoginSingleRole.m_tAllEquipRes[equipType]["Mtl"] then
				model:LoadMaterialFromFile(LoginSingleRole.m_tAllEquipRes[equipType]["Mtl"])
			end
	
			if equipType == "RL_WEAPON_LH" or equipType == "RL_WEAPON_RH" or equipType == "HeavySword" then
				local nColorChannelTable = Player_GetColorChannelTable()
				model:SetDetail(nColorChannelTable, LoginSingleRole.m_tAllEquipRes[equipType]["ColorChannel"])
			else
				model:SetDetail(nRoleType, LoginSingleRole.m_tAllEquipRes[equipType]["ColorChannel"])
			end
			
			local scale = LoginSingleRole.m_tAllEquipRes[equipType]["MeshScale"]
			model:SetScaling(scale, scale, scale)
			
			LoginSingleRole.UnloadModelSFX(equipType)
			LoginSingleRole.LoadModelSFX(model, equipType)
		end
	else
		LoginSingleRole.UnloadSocket(equipType)	
	end
end;

ShowModel=function(bShow)
	if not LoginSingleRole.m_tModelRole then
		return
	end
	
	local mdl = LoginSingleRole.m_tModelRole["MDL"]
	if not mdl then
		return
	end

	if bShow then
		LoginSingleRole.m_scene:AddRenderEntity(mdl)
	else
		LoginSingleRole.m_scene:RemoveRenderEntity(mdl)
	end		
end;

UnloadModelAll=function()
	LoginSingleRole.UnloadModel()
end;

UnloadModel=function()
	if not LoginSingleRole.m_tModelRole["MDL"] then
		return
	end

	LoginSingleRole.ShowModel(false)

	for equipType, model in pairs(LoginSingleRole.m_tModelRole) do
		if model and LoginSingleRole.m_tModelPath[equipType]["Socket"] then
			LoginSingleRole.UnloadModelSFX(equipType)
			model:UnbindFromOther()
			model:Release()
			model = nil
		end
	end
	
	for equipType, model in pairs(LoginSingleRole.m_tModelRole) do
		if model and not LoginSingleRole.m_tModelPath[equipType]["Socket"] and equipType ~= "MDL" then
		    LoginSingleRole.UnloadModelSFX(equipType)
			LoginSingleRole.m_tModelRole["MDL"]:Detach(model)
			model:Release()
			model = nil
		end
	end
	
	LoginSingleRole.m_tModelRole["MDL"]:Release()
	LoginSingleRole.m_tModelRole["MDL"] = nil
	
	LoginSingleRole.m_tModelRole = {}
	LoginSingleRole.m_tModelRoleSFX = {}
	LoginSingleRole.m_tModelPath = {}
end;

UnloadPart=function(equipType)
	if not LoginSingleRole.m_tModelRole[equipType] then
		return
	end
	
	if LoginSingleRole.m_tModelPath[equipType]["Socket"] or equipType == "MDL" then
		return
	end
	
    LoginSingleRole.UnloadModelSFX(equipType)
	LoginSingleRole.m_tModelRole["MDL"]:Detach(LoginSingleRole.m_tModelRole[equipType])
	LoginSingleRole.m_tModelRole[equipType]:Release()
	LoginSingleRole.m_tModelRole[equipType] = nil
	LoginSingleRole.m_tModelPath[equipType] = {}
end;

UnloadSocket=function(equipType)	
	if not LoginSingleRole.m_tModelRole[equipType] then
		return
	end
	
	if not LoginSingleRole.m_tModelPath[equipType]["Socket"] or equipType == "MDL" then
		return
	end
	
    LoginSingleRole.UnloadModelSFX(equipType)
	LoginSingleRole.m_tModelRole[equipType]:UnbindFromOther()
	LoginSingleRole.m_tModelRole[equipType]:Release()
	LoginSingleRole.m_tModelRole[equipType] = nil
	LoginSingleRole.m_tModelPath[equipType] = {}
end;

PlayAnimation=function(szAniName, szLoopType)
	if not LoginSingleRole.m_tModelRole or not LoginSingleRole.m_tModelRole["MDL"] then
		return
	end
	if not szAniName or not LoginSingleRole.m_tAnimationRes[szAniName].Ani then
		return
	end
	LoginSingleRole.m_tModelRole["MDL"]:PlayAnimation(szLoopType, LoginSingleRole.m_tAnimationRes[szAniName].Ani, 1, 0)
end;

PlayWeaponAnimation=function(nRoleType, nWeaponID)
	local szSocketName = LoginSingleRole.m_tAllEquipRes["RL_WEAPON_RH"]["Socket"]
	local mesh = LoginSingleRole.m_tAllEquipRes["RL_WEAPON_RH"]["Mesh"]
	local model = LoginSingleRole.m_tModelRole["RL_WEAPON_RH"]

	if not mesh or string.sub(mesh, string.len(mesh) - 3) ~= ".mdl" then
		return
	end
	
	if not nWeaponID or nWeaponID == 0 then
		return
	end
	
	if not szSocketName or szSocketName == "" then
		return
	end
	
	if not model then
		return
	end
	
	local WeaponAni = Weapon_GetAnimation(nRoleType, nWeaponID, szSocketName)
	model:PlayAnimation("loop", WeaponAni, 1.0, 0)
end;

};