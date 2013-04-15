NpcModelView = class()

function DrawNpcModelImage(dwNpcID, aCameraParams, image, bPortraitOnly)
	local modelView = NpcModelView.new()
	
	modelView:init()
	modelView:SetCamera(aCameraParams)
	
	modelView:UnloadModel()
	modelView:LoadNpcRes(dwNpcID, bPortraitOnly)
	modelView:LoadModel()
	modelView:PlayAnimation("Idle", "last")

	image:FromScene(modelView.m_scene)

	MaskModelImage(image)
	image:ToManagedImage()

	modelView:release()		
end;

function NpcModelView:ctor()
--	Trace("NpcModelView:ctor()\n")
	
	self.m_camera = nil;
	self.m_modelMgr = nil;
	self.m_modelRole = nil;
	self.m_aEquipRes = {};
	self.m_aAnimationRes = { Idle = {} };
	self.m_aRoleAnimation = { Idle = 30 };
end;

function NpcModelView:release()
	self:UnloadModel()

	KG3DEngine.DeleteScene(self.m_scene)
	self.m_scene=nil
end;

function NpcModelView:init()
	self.m_scene = KG3DEngine.NewScene()
	self.m_modelMgr = KG3DEngine.GetModelMgr()
		
	-- Camera
	self.m_camera = self.m_scene:GetCamera()
	self:SetCamera({ 0, 150, -200, 0, 50, 150 })
end;

function NpcModelView:SetCamera(aParams)
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
	
	if bPerspective ~= nil then
		self.m_camera:SetPerspective(p1, p2, p3, p4)
	else
		self.m_camera:SetOrthogonal(p1, p2, p3, p4)
	end
end;

function NpcModelView:LoadModel()
--	Trace("LoadModel()\n")
	
	if self.m_modelRole then
		return
	end
	
	local aEquipRes = self.m_aEquipRes

	if aEquipRes["Main"] and aEquipRes["Main"]["MDL"] then
--		Trace("MDL "..aEquipRes["Main"]["MDL"].."\n")
		
		local modelScale = aEquipRes["Main"]["ModelScale"]
		local socketScale = aEquipRes["Main"]["SocketScale"]
		
		self.m_modelRole = {}
		
		self.m_modelRole["MDL"] = self.m_modelMgr:NewModel(aEquipRes["Main"]["MDL"])
		self.m_modelRole["MDL"]:SetScaling(modelScale, modelScale, modelScale)
		self.m_modelRole["MDL"]:SetTranslation(0, 0, 0)
		self.m_scene:AddRenderEntity(self.m_modelRole["MDL"])

		-- load socket
		for equipType, equipRes in pairs(aEquipRes) do
			if aEquipRes[equipType]["Socket"] and aEquipRes[equipType]["Mesh"] then
--				Trace("["..equipType.." "..modelScale..", "..socketScale.." "..aEquipRes[equipType]["Socket"].."] "..aEquipRes[equipType]["Mesh"].."\n")
				
				local model = self.m_modelMgr:NewModel(aEquipRes[equipType]["Mesh"])
				self.m_modelRole[equipType] = model
				if model then
					if aEquipRes[equipType]["Mtl"] then
						model:LoadMaterialFromFile(aEquipRes[equipType]["Mtl"])
					end
					if equipType ~= "F" then
						model:SetScaling(socketScale, socketScale, socketScale)
					end
					model:BindToSocket(self.m_modelRole["MDL"], aEquipRes[equipType]["Socket"])
				end
			end
		end
	end
end;

function NpcModelView:UnloadModel()
	if not self.m_modelRole then
		return
	end

	for equipType, model in pairs(self.m_modelRole) do
		if model and equipType ~= "MDL" then
			model:UnbindFromOther()
			model:Release()
			model = nil
		end
	end
	
	self.m_scene:RemoveRenderEntity(self.m_modelRole["MDL"])
	self.m_modelRole["MDL"]:Release()
	self.m_modelRole["MDL"] = nil
	
	self.m_modelRole = nil
end;

function NpcModelView:PlayAnimation(szAniName, szLoopType)
--	Trace("PlayAnimation("..szAniName..","..szLoopType..")\n")
	
	if not self.m_modelRole or not self.m_modelRole["MDL"] then
		return
	end
	if not szAniName or not self.m_aAnimationRes[szAniName].Ani then
		return
	end
	self.m_modelRole["MDL"]:PlayAnimation(szLoopType, self.m_aAnimationRes[szAniName].Ani, 1, 0)
end;


function NpcModelView:LoadNpcRes(dwNpcID, bPortraitOnly)
	-- load model and mesh
	self.m_aEquipRes = {
		Main = { MDL = nil, ModelScale = 1, SocketScale = 1 },
		F = { Socket = "S_Face", Mesh = nil, Mtl = nil },
		H = { Socket = "S_Hat", Mesh = nil, Mtl = nil },
		LH = { Socket = "S_LH", Mesh = nil, Mtl = nil },
		LP = { Socket = "S_LP", Mesh = nil, Mtl = nil },
		RH = { Socket = "S_RH", Mesh = nil, Mtl = nil },
		RP = { Socket = "S_RP", Mesh = nil, Mtl = nil },
		S = { Socket = "S_Spine2", Mesh = nil, Mtl = nil },
	}
	
	local dwModelID = GetNpc(dwNpcID).dwModelID
	local res = self.m_aEquipRes
	
	if bPortraitOnly then
		res["Main"]["MDL"],
		res["Main"]["ModelScale"],
		res["Main"]["SocketScale"],
		res["F"]["Mesh"], res["F"]["Mtl"],
		res["H"]["Mesh"], res["H"]["Mtl"]
		= NPC_GetEquipResource(dwModelID)
	else
		res["Main"]["MDL"],
		res["Main"]["ModelScale"],
		res["Main"]["SocketScale"],
		res["F"]["Mesh"], res["F"]["Mtl"],
		res["H"]["Mesh"], res["H"]["Mtl"],
		res["LH"]["Mesh"], res["LH"]["Mtl"],
		res["LP"]["Mesh"], res["LP"]["Mtl"],
		res["RH"]["Mesh"], res["RH"]["Mtl"],
		res["RP"]["Mesh"], res["RP"]["Mtl"],
		res["S"]["Mesh"], res["S"]["Mtl"]
		= NPC_GetEquipResource(dwModelID)
	end
	
	-- load animation
	for szAniName, v in pairs(self.m_aAnimationRes) do
		self.m_aAnimationRes[szAniName] = { 
			Ani = "", AniSound = "", AniPlayType = "loop", AniPlaySpeed = 1, AniSoundRange = 0,
			SFX = "", SFXBone = "", SFXPlayType = "loop", SFXPlaySpeed = 1, SFXScale = 1 
		}
	
		local aAniRes = self.m_aAnimationRes[szAniName]
		
		aAniRes["Ani"], aAniRes["AniSound"], aAniRes["AniPlayType"], aAniRes["AniPlaySpeed"], aAniRes["AniSoundRange"],
		aAniRes["SFX"], aAniRes["SFXBone"], aAniRes["SFXPlayType"], aAniRes["SFXPlaySpeed"], aAniRes["SFXScale"]
		= NPC_GetAnimationResource(dwModelID, self.m_aRoleAnimation[szAniName])
	end
end;


