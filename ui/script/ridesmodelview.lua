RidesModelView = class()

function RidesModelView:ctor()
	self.m_camera = nil;
	self.m_modelMgr = nil;
	self.m_RidesMDL = nil;
	self.m_aRidesEquipRes = {};
	self.m_aRidesAnimationRes = { Idle = {} };
	self.m_aRidesAnimation = { Idle = 10000 };
end;

function RidesModelView:init()
	self:Init3D()
end;

function RidesModelView:release()
	self:Free3D()
end;

function RidesModelView:Init3D()
	self.m_scene = KG3DEngine.NewScene()
	self.m_modelMgr = KG3DEngine.GetModelMgr()
		
	-- Camera
	self.m_camera = self.m_scene:GetCamera()
	self:SetCamera({ 0, 150, -200, 0, 50, 150 })
end;

function RidesModelView:Free3D()
	self:UnloadRidesModel()

	KG3DEngine.DeleteScene(self.m_scene)
	self.m_scene=nil
end;

function RidesModelView:SetCamera(aParams)
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
	
	if bPerspective then
		self.m_camera:SetPerspective(p1, p2, p3, p4)
	else
		self.m_camera:SetOrthogonal(p1, p2, p3, p4)
	end
end;

function RidesModelView:LoadRidesRes(dwPlayerID, bPortraitOnly)
	-- load model and mesh
	local player=GetPlayer(dwPlayerID)
	if not player then
		return
	end

	local aRepresentID = player.GetRepresentID()
	
	self.m_aRidesEquipRes = Player_GetRidesEquipResource(
		aRepresentID[EQUIPMENT_REPRESENT.HORSE_STYLE],  
		aRepresentID[EQUIPMENT_REPRESENT.HORSE_STYLE],
		aRepresentID[EQUIPMENT_REPRESENT.HORSE_STYLE],
		aRepresentID[EQUIPMENT_REPRESENT.HORSE_ADORNMENT1], 
		aRepresentID[EQUIPMENT_REPRESENT.HORSE_ADORNMENT2], 
		aRepresentID[EQUIPMENT_REPRESENT.HORSE_ADORNMENT3], 
		aRepresentID[EQUIPMENT_REPRESENT.HORSE_ADORNMENT4]) 

	local res = self.m_aRidesEquipRes
	if bPortraitOnly then
		res["EquipMain"]["Socket"], res["EquipMain"]["Mesh"], res["EquipMain"]["Mtl"], res["EquipMain"]["MeshScale"] = nil, nil, nil, nil
		res["SocketMain"]["Socket"], res["SocketMain"]["Mesh"], res["SocketMain"]["Mtl"], res["SocketMain"]["MeshScale"] = nil, nil, nil, nil
		res["Socket1"]["Socket"], res["Socket1"]["Mesh"], res["Socket1"]["Mtl"], res["Socket1"]["MeshScale"] = nil, nil, nil, nil
		res["Socket2"]["Socket"], res["Socket2"]["Mesh"], res["Socket2"]["Mtl"], res["Socket2"]["MeshScale"] = nil, nil, nil, nil
		res["Socket3"]["Socket"], res["Socket3"]["Mesh"], res["Socket3"]["Mtl"], res["Socket3"]["MeshScale"] = nil, nil, nil, nil
		res["Socket4"]["Socket"], res["Socket4"]["Mesh"], res["Socket4"]["Mtl"], res["Socket4"]["MeshScale"] = nil, nil, nil, nil
	end
	
	-- load animation
	for szAniName, v in pairs(self.m_aRidesAnimationRes) do
		self.m_aRidesAnimationRes[szAniName] = { 
			Ani = nil, AniSound = nil, AniPlayType = "loop", AniPlaySpeed = 1, AniSoundRange = 0,
			SFX = nil, SFXBone = nil, SFXPlayType = "loop", SFXPlaySpeed = 1, SFXScale = 1 
		}
	
		local aAniRes = self.m_aRidesAnimationRes[szAniName]
		
		aAniRes["Ani"], aAniRes["AniSound"], aAniRes["AniPlayType"], aAniRes["AniPlaySpeed"], aAniRes["AniSoundRange"],
		aAniRes["SFX"], aAniRes["SFXBone"], aAniRes["SFXPlayType"], aAniRes["SFXPlaySpeed"], aAniRes["SFXScale"]
		= Player_GetRidesAnimationResource(aRepresentID[EQUIPMENT_REPRESENT.HORSE_STYLE], self.m_aRidesAnimation[szAniName])
	end
end;

function RidesModelView:LoadRidesModel()
	if self.m_RidesMDL then
		return
	end
	
	local aEquipRes = self.m_aRidesEquipRes

	if aEquipRes["MDL"] then
		self.m_RidesMDL = {}
		
		self.m_RidesMDL["MDL"] = self.m_modelMgr:NewModel(aEquipRes["MDL"])
		if not self.m_RidesMDL["MDL"] then
			return
		end
		
		-- load part
		for equipType, equipRes in pairs(aEquipRes) do
			if not aEquipRes[equipType]["Socket"] and aEquipRes[equipType]["Mesh"] then
				local model = self.m_modelMgr:NewModel(aEquipRes[equipType]["Mesh"])
				self.m_RidesMDL[equipType] = model
				if model then
					if aEquipRes[equipType]["Mtl"] then
						model:LoadMaterialFromFile(aEquipRes[equipType]["Mtl"])
					end

					local scale = aEquipRes[equipType]["MeshScale"]

					self.m_RidesMDL["MDL"]:Attach(model)
					model:SetScaling(scale, scale, scale)
					model:SetDetail(aEquipRes[equipType]["ColorChannelTable"], aEquipRes[equipType]["ColorChannel"])
					--self:LoadModelSFX(model, equipType)
				end
			end
		end

		-- load socket
		for equipType, equipRes in pairs(aEquipRes) do
			if aEquipRes[equipType]["Socket"] and aEquipRes[equipType]["Mesh"] then
				local model = self.m_modelMgr:NewModel(aEquipRes[equipType]["Mesh"])
				self.m_RidesMDL[equipType] = model
				if model then
					if aEquipRes[equipType]["Mtl"] then
						model:LoadMaterialFromFile(aEquipRes[equipType]["Mtl"])
					end
					
					local scale = aEquipRes[equipType]["MeshScale"]
					
					model:BindToSocket(self.m_RidesMDL["MDL"], aEquipRes[equipType]["Socket"])
					model:SetScaling(scale, scale, scale)		
					model:SetDetail(aEquipRes[equipType]["ColorChannelTable"], aEquipRes[equipType]["ColorChannel"])			
					--self:LoadModelSFX(model, equipType)
				end
			end
		end

		self.m_RidesMDL["MDL"]:SetTranslation(0, 0, 0)
		self.m_scene:AddRenderEntity(self.m_RidesMDL["MDL"])
	end
end;

function RidesModelView:UnloadRidesModel()
	if not self.m_RidesMDL or not self.m_RidesMDL["MDL"] then
		return
	end
	for equipType, model in pairs(self.m_RidesMDL) do
		if model and self.m_aRidesEquipRes[equipType]["Socket"] then
			--self:UnloadModelSFX(equipType)			
			model:UnbindFromOther()
			model:Release()
			model = nil
		end
	end
	
	for equipType, model in pairs(self.m_RidesMDL) do
		if model and not self.m_aRidesEquipRes[equipType]["Socket"] and equipType ~= "MDL" then
			--self:UnloadModelSFX(equipType)			
			self.m_RidesMDL["MDL"]:Detach(model)
			model:Release()
			model = nil
		end
	end
	
	self.m_scene:RemoveRenderEntity(self.m_RidesMDL["MDL"])
	self.m_RidesMDL["MDL"]:Release()
	self.m_RidesMDL["MDL"] = nil
	self.m_RidesMDL = nil
end;

function RidesModelView:PlayRidesAnimation(szAniName, szLoopType)
	if not self.m_RidesMDL or not self.m_RidesMDL["MDL"] then
		return
	end
	if not szAniName or not self.m_aRidesAnimationRes[szAniName].Ani then
		return
	end
	self.m_RidesMDL["MDL"]:PlayAnimation(szLoopType, self.m_aRidesAnimationRes[szAniName].Ani, 1, 0)
end;
