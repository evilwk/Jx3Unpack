PlayerModelView = class()

function MaskModelImage(image)
	local dwImageID = image:GetImageID()
	local dwMaskImageID = LoadImage("ui\\Image\\Common\\PortraitMask.tga")
	if dwMaskImageID then
		MaskImage(dwImageID, dwMaskImageID)
		UnloadImage(dwMaskImageID)
	end
end;

function DrawPlayerModelImage(dwPlayerID, aCameraParams, image, bPortraitOnly)
	local modelView = PlayerModelView.new()
	
	modelView:init()
	modelView:SetCamera(aCameraParams)
	
	modelView:UnloadModel()
	modelView:LoadPlayerRes(dwPlayerID, bPortraitOnly)
	modelView:LoadModel()
	modelView:PlayAnimation("Idle", "loop")

	image:FromScene(modelView.m_scene)

	MaskModelImage(image)
	image:ToManagedImage()

	modelView:release()		
end;

function DrawMemberModelImage(helm, face, nRoleType, aCameraParams, image, bPortraitOnly)
	local modelView = PlayerModelView.new()
	
	modelView:init()
	modelView:SetCamera(aCameraParams)
	
	modelView:UnloadModel()
	modelView:LoadMemberRes(helm, face, nRoleType, bPortraitOnly)
	modelView:LoadModel()
	modelView:PlayAnimation("Idle", "loop")

	image:FromScene(modelView.m_scene)

	MaskModelImage(image)
	image:ToManagedImage()

	modelView:release()		
end;

function PlayerModelView:ctor()
	self.m_camera = nil;
	self.m_modelMgr = nil;
	self.m_modelRole = nil;
	self.m_modelRoleSFX = nil;
	self.m_aEquipRes = {};
	self.m_aAnimationRes = { Idle = {}, Standard = {}};
	self.m_aRoleAnimation = { Idle = 100 , Standard = 30};
	self.m_aRepresentID = nil;
	self.m_nRoleType = nil;
end;

function PlayerModelView:release()
	self:Free3D()
end;

function PlayerModelView:init()
	self:Init3D()
end;

function PlayerModelView:Init3D()
--	Trace("Init3D\n")
	
	self.m_scene = KG3DEngine.NewScene()
	self.m_modelMgr = KG3DEngine.GetModelMgr()
		
	-- Camera
	self.m_camera = self.m_scene:GetCamera()
	self:SetCamera({ 0, 150, -200, 0, 50, 150 })
end;

function PlayerModelView:Free3D()
--	Trace("Free3D()\n")
	
	self:UnloadModel()

	KG3DEngine.DeleteScene(self.m_scene)
	self.m_scene=nil
end;

function PlayerModelView:SetCamera(aParams)
	local xp = aParams[1]
	local yp = aParams[2]
	local zp = aParams[3]
	local xl = aParams[4]
	local yl = aParams[5]
	local zl = aParams[6]
	local p1 = aParams[7]
	local p2 = aParams[8]
	local p3 = aParams[9]
	local p4 = aParams[10]
	local bPerspective = aParams[11]
	
	self.m_camera:SetLookAtPosition(xl, yl, zl)
	self.m_camera:SetPosition(xp, yp, zp)
	--self.m_scene:SetFocus(xl, yl, zl)
	if bPerspective then
		self.m_camera:SetPerspective(p1, p2, p3, p4)
	else
		self.m_camera:SetOrthogonal(p1, p2, p3, p4)
	end
end;

function PlayerModelView:LoadModelSFX(model, equipType)
	--Load SFX1
	if self.m_aEquipRes[equipType]["SFX1"] then
		local modelsfx = self.m_modelMgr:NewModel(self.m_aEquipRes[equipType]["SFX1"])
		self.m_modelRoleSFX[equipType.."SFX1"] = modelsfx
		if modelsfx then
			modelsfx:BindToBone(model)
		end
	end
	--Load SFX2
	if self.m_aEquipRes[equipType]["SFX2"] then
		local modelsfx = self.m_modelMgr:NewModel(self.m_aEquipRes[equipType]["SFX2"])
		self.m_modelRoleSFX[equipType.."SFX2"] = modelsfx
		if modelsfx then
			modelsfx:BindToBone(model)
		end
	end
end;

function PlayerModelView:UnloadModelSFX(equipType)
	--Unload SFX2
	if self.m_modelRoleSFX[equipType.."SFX2"] then
		self.m_modelRoleSFX[equipType.."SFX2"]:UnbindFromOther()
		self.m_modelRoleSFX[equipType.."SFX2"]:Release()
		self.m_modelRoleSFX[equipType.."SFX2"] = nil
	end
	--Unload SFX1
	if self.m_modelRoleSFX[equipType.."SFX1"] then
		self.m_modelRoleSFX[equipType.."SFX1"]:UnbindFromOther()
		self.m_modelRoleSFX[equipType.."SFX1"]:Release()
		self.m_modelRoleSFX[equipType.."SFX1"] = nil
	end
end;

function PlayerModelView:LoadModel()
	
	if self.m_modelRole then
		return
	end
	
	local aEquipRes = self.m_aEquipRes

	if aEquipRes["MDL"] then
		self.m_modelRole = {}
		self.m_modelRoleSFX = {}
		
		self.m_modelRole["MDL"] = self.m_modelMgr:NewModel(aEquipRes["MDL"])
		
		local scale = aEquipRes["MDLScale"]
		self.m_modelRole["MDL"]:SetScaling(scale, scale, scale)
		
		self.m_modelRole["MDL"]:SetTranslation(0, 0, 0)
		self.m_scene:AddRenderEntity(self.m_modelRole["MDL"])
		
		-- load part and sfx
		for equipType, equipRes in pairs(aEquipRes) do
			if equipType ~= "MDL" and equipType ~= "MDLScale" and
				not aEquipRes[equipType]["Socket"] and aEquipRes[equipType]["Mesh"] then
				local model = self.m_modelMgr:NewModel(aEquipRes[equipType]["Mesh"])
				self.m_modelRole[equipType] = model
				if model then
					self.m_modelRole["MDL"]:Attach(model)

					if aEquipRes[equipType]["Mtl"] then
						model:LoadMaterialFromFile(aEquipRes[equipType]["Mtl"])
					end

					model:SetDetail(self.m_nRoleType, aEquipRes[equipType]["ColorChannel"])

					local scale = aEquipRes[equipType]["MeshScale"]

					model:SetScaling(scale, scale, scale)
					self:LoadModelSFX(model, equipType)
				end
			end
		end

		-- load socket and sfx
		for equipType, equipRes in pairs(aEquipRes) do
			if equipType ~= "MDL" and equipType ~= "MDLScale" and
				aEquipRes[equipType]["Socket"] and aEquipRes[equipType]["Mesh"] then
				local model = self.m_modelMgr:NewModel(aEquipRes[equipType]["Mesh"])
				self.m_modelRole[equipType] = model
				if model then
					model:BindToSocket(self.m_modelRole["MDL"], aEquipRes[equipType]["Socket"])

					if aEquipRes[equipType]["Mtl"] then
						model:LoadMaterialFromFile(aEquipRes[equipType]["Mtl"])
					end
					
					if equipType == "RL_WEAPON_LH" or equipType == "RL_WEAPON_RH" or equipType == "HeavySword" then
						local nColorChannelTable = Player_GetColorChannelTable()
						model:SetDetail(nColorChannelTable, aEquipRes[equipType]["ColorChannel"])
					else
						model:SetDetail(self.m_nRoleType, aEquipRes[equipType]["ColorChannel"])
					end
					
					local scale = aEquipRes[equipType]["MeshScale"]
					
					model:SetScaling(scale, scale, scale)					
					self:LoadModelSFX(model, equipType)
				end
			end
		end
		
		self:PlayWeaponAnimation(self.m_nRoleType, self.m_aRepresentID[EQUIPMENT_REPRESENT.WEAPON_STYLE])
	end
end;

function PlayerModelView:UnloadModel()
	if not self.m_modelRole then
		return
	end
	for equipType, model in pairs(self.m_modelRole) do
		if model and self.m_aEquipRes[equipType]["Socket"] then
			self:UnloadModelSFX(equipType)			
			model:UnbindFromOther()
			model:Release()
			model = nil
		end
	end
	
	for equipType, model in pairs(self.m_modelRole) do
		if model and not self.m_aEquipRes[equipType]["Socket"] and equipType ~= "MDL" then
			self:UnloadModelSFX(equipType)			
			self.m_modelRole["MDL"]:Detach(model)
			model:Release()
			model = nil
		end
	end
	
	self.m_scene:RemoveRenderEntity(self.m_modelRole["MDL"])
	self.m_modelRole["MDL"]:Release()
	self.m_modelRole["MDL"] = nil
	
	self.m_modelRoleSFX = nil
	self.m_modelRole = nil
end;

function PlayerModelView:PlayAnimation(szAniName, szLoopType)
	if not self.m_modelRole or not self.m_modelRole["MDL"] then
		return
	end
	if not szAniName or not self.m_aAnimationRes[szAniName].Ani then
		return
	end
	self.m_modelRole["MDL"]:PlayAnimation(szLoopType, self.m_aAnimationRes[szAniName].Ani, 1, 0)
end;

function PlayerModelView:UpdateRepresentID(aRepresentID, nRoleType)
	local bModified = false
	
	if not self.m_aRepresentID then
		self.m_aRepresentID = aRepresentID
		self.m_nRoleType = nRoleType
		bModified = true
	else
        for i, v in pairs(aRepresentID) do
			if v ~= self.m_aRepresentID[i] then
				self.m_aRepresentID[i] = v
				bModified = true
			end
		end
		if self.m_nRoleType ~= nRoleType then
		    self.m_nRoleType = nRoleType
			bModified = true
		end
	end
	
	return bModified
end;

function PlayerModelView:LoadRes(dwPlayerID, tRepresentID)
	local hPlayer = GetPlayer(dwPlayerID)
	
	self:UpdateRepresentID(tRepresentID, hPlayer.nRoleType)
	
	self.m_aEquipRes = Player_GetEquipResource(
		hPlayer.nRoleType,
		unpack(tRepresentID, 0 , EQUIPMENT_REPRESENT.TOTAL - 1)
    )
	
	self:LoadPlayerAnimation(dwPlayerID)
end

function PlayerModelView:LoadPlayerRes(dwPlayerID, bPortraitOnly)
	-- load model and mesh
	local player=GetPlayer(dwPlayerID)
	if not player then
		return
	end

	local aRepresentID = player.GetRepresentID()
    
	local bModified = self:UpdateRepresentID(aRepresentID, player.nRoleType)
	
	if bModified then
		self.m_aEquipRes = Player_GetEquipResource(
            player.nRoleType,
            unpack(aRepresentID, 0 , EQUIPMENT_REPRESENT.TOTAL - 1)
        )
	
		local res = self.m_aEquipRes
		if bPortraitOnly then
			res["WAIST"]["Socket"], res["WAIST"]["Mesh"], res["WAIST"]["Mtl"], res["WAIST"]["MeshScale"], res["WAIST"]["SFX1"], res["WAIST"]["SFX2"] = nil, nil, nil, nil, nil, nil
			res["PANTS"]["Socket"], res["PANTS"]["Mesh"], res["PANTS"]["Mtl"], res["PANTS"]["MeshScale"], res["PANTS"]["SFX1"], res["PANTS"]["SFX2"] = nil, nil, nil, nil, nil, nil
			res["BANGLE"]["Socket"], res["BANGLE"]["Mesh"], res["BANGLE"]["Mtl"], res["BANGLE"]["MeshScale"], res["BANGLE"]["SFX1"], res["BANGLE"]["SFX2"] = nil, nil, nil, nil, nil, nil
			res["MELEE_WEAPON_LH"]["Socket"], res["MELEE_WEAPON_LH"]["Mesh"], res["MELEE_WEAPON_LH"]["Mtl"], res["MELEE_WEAPON_LH"]["MeshScale"], res["MELEE_WEAPON_LH"]["SFX1"], res["MELEE_WEAPON_LH"]["SFX2"] = nil, nil, nil, nil, nil, nil
			res["MELEE_WEAPON_RH"]["Socket"], res["MELEE_WEAPON_RH"]["Mesh"], res["MELEE_WEAPON_RH"]["Mtl"], res["MELEE_WEAPON_RH"]["MeshScale"], res["MELEE_WEAPON_RH"]["SFX1"], res["MELEE_WEAPON_RH"]["SFX2"] = nil, nil, nil, nil, nil, nil
			res["BACK_EXTEND"]["Socket"], res["BACK_EXTEND"]["Mesh"], res["BACK_EXTEND"]["Mtl"], res["BACK_EXTEND"]["MeshScale"], res["BACK_EXTEND"]["SFX1"], res["BACK_EXTEND"]["SFX2"] = nil, nil, nil, nil, nil, nil
			res["WAIST_EXTEND"]["Socket"], res["WAIST_EXTEND"]["Mesh"], res["WAIST_EXTEND"]["Mtl"], res["WAIST_EXTEND"]["MeshScale"], res["WAIST_EXTEND"]["SFX1"], res["WAIST_EXTEND"]["SFX2"] = nil, nil, nil, nil, nil, nil
		end
		
		-- load animation
		self:LoadPlayerAnimation(dwPlayerID)
	end
end;

function PlayerModelView:LoadPlayerAnimation(dwPlayerID)
	local hPlayer = GetPlayer(dwPlayerID)
	for szAniName, v in pairs(self.m_aAnimationRes) do
		self.m_aAnimationRes[szAniName] = { 
			Ani = nil, AniSound = nil, AniPlayType = "loop", AniPlaySpeed = 1, AniSoundRange = 0,
			SFX = nil, SFXBone = nil, SFXPlayType = "loop", SFXPlaySpeed = 1, SFXScale = 1 
		}
	
		local aAniRes = self.m_aAnimationRes[szAniName]
		
		aAniRes["Ani"], aAniRes["AniSound"], aAniRes["AniPlayType"], aAniRes["AniPlaySpeed"]
		= Player_GetAnimationResource(hPlayer.nRoleType, self.m_aRoleAnimation[szAniName])
	end
end

function PlayerModelView:LoadMemberRes(helm, face, nRoleType, bPortraitOnly)
	-- load model and mesh   
	local aRepresentID = {}
	local i = 0
	for i = 0, EQUIPMENT_REPRESENT.TOTAL - 1 do   
		aRepresentID[i] = 0
	end
	aRepresentID[EQUIPMENT_REPRESENT.FACE_STYLE] = face
	aRepresentID[EQUIPMENT_REPRESENT.HELM_STYLE] = helm
	
	local bModified = self:UpdateRepresentID(aRepresentID, nRoleType)
	if bModified then
		self.m_aEquipRes = Player_GetEquipResource(
            nRoleType, 
            unpack(aRepresentID, 0 , EQUIPMENT_REPRESENT.TOTAL - 1)
        )
        
		local res = self.m_aEquipRes
	
		if bPortraitOnly then
			res["WAIST"]["Socket"], res["WAIST"]["Mesh"], res["WAIST"]["Mtl"], res["WAIST"]["MeshScale"], res["WAIST"]["SFX1"], res["WAIST"]["SFX2"] = nil, nil, nil, nil, nil, nil
			res["PANTS"]["Socket"], res["PANTS"]["Mesh"], res["PANTS"]["Mtl"], res["PANTS"]["MeshScale"], res["PANTS"]["SFX1"], res["PANTS"]["SFX2"] = nil, nil, nil, nil, nil, nil
			res["BANGLE"]["Socket"], res["BANGLE"]["Mesh"], res["BANGLE"]["Mtl"], res["BANGLE"]["MeshScale"], res["BANGLE"]["SFX1"], res["BANGLE"]["SFX2"] = nil, nil, nil, nil, nil, nil
			res["MELEE_WEAPON_LH"]["Socket"], res["MELEE_WEAPON_LH"]["Mesh"], res["MELEE_WEAPON_LH"]["Mtl"], res["MELEE_WEAPON_LH"]["MeshScale"], res["MELEE_WEAPON_LH"]["SFX1"], res["MELEE_WEAPON_LH"]["SFX2"] = nil, nil, nil, nil, nil, nil
			res["MELEE_WEAPON_RH"]["Socket"], res["MELEE_WEAPON_RH"]["Mesh"], res["MELEE_WEAPON_RH"]["Mtl"], res["MELEE_WEAPON_RH"]["MeshScale"], res["MELEE_WEAPON_RH"]["SFX1"], res["MELEE_WEAPON_RH"]["SFX2"] = nil, nil, nil, nil, nil, nil
			res["BACK_EXTEND"]["Socket"], res["BACK_EXTEND"]["Mesh"], res["BACK_EXTEND"]["Mtl"], res["BACK_EXTEND"]["MeshScale"], res["BACK_EXTEND"]["SFX1"], res["BACK_EXTEND"]["SFX2"] = nil, nil, nil, nil, nil, nil
			res["WAIST_EXTEND"]["Socket"], res["WAIST_EXTEND"]["Mesh"], res["WAIST_EXTEND"]["Mtl"], res["WAIST_EXTEND"]["MeshScale"], res["WAIST_EXTEND"]["SFX1"], res["WAIST_EXTEND"]["SFX2"] = nil, nil, nil, nil, nil, nil
		end
		
		-- load animation
		for szAniName, v in pairs(self.m_aAnimationRes) do
			self.m_aAnimationRes[szAniName] = { 
				Ani = nil, AniSound = nil, AniPlayType = "loop", AniPlaySpeed = 1, AniSoundRange = 0,
				SFX = nil, SFXBone = nil, SFXPlayType = "loop", SFXPlaySpeed = 1, SFXScale = 1 
			}
		
			local aAniRes = self.m_aAnimationRes[szAniName]
			
			aAniRes["Ani"], aAniRes["AniSound"], aAniRes["AniPlayType"], aAniRes["AniPlaySpeed"], aAniRes["AniSoundRange"],
			aAniRes["SFX"], aAniRes["SFXBone"], aAniRes["SFXPlayType"], aAniRes["SFXPlaySpeed"], aAniRes["SFXScale"]
			= Player_GetAnimationResource(nRoleType, self.m_aRoleAnimation[szAniName])
		end
	end
end;

function PlayerModelView:PlayWeaponAnimation(nRoleType, nWeaponID)
	local szSocketName = self.m_aEquipRes["RL_WEAPON_RH"]["Socket"]
	local mesh = self.m_aEquipRes["RL_WEAPON_RH"]["Mesh"]
	local model = self.m_modelRole["RL_WEAPON_RH"]

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
