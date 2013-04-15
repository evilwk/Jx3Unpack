--[[
SFX=
{
	Ttl=32,
	Camera={ 0, 0, -200, 0, 0, 0, nil, nil, nil, nil, false }, 
	Models={
		[1]={ 
			Model={
				Name="SkillLevelUp",
				File="data/source/other/特效/系统/SFX/其他/aaaaaaaa.Sfx",
				Translation={x=0, y=100, z=0},
		
				Ani={
					File="",
					PlayType="once",
					Speed=1,
					StartTime=0
				}
			}
		}
	}
},
]]

--在场景控件中播放上面格式的动画
function PlaySFX(s, sfx, bHandleEvent)
	if not s.m_scene then
		s.m_scene = KG3DEngine.NewScene()
	end
	
	if not s.m_modelMgr then
		s.m_modelMgr = KG3DEngine.GetModelMgr()
	end
	
	s:SetScene(s.m_scene)
	
	-----------设置摄像机参数------------------
	local c = s.m_scene:GetCamera()
	
	local cParam = sfx.Camera
	c:SetLookAtPosition(cParam[4], cParam[5], cParam[6])
	c:SetPosition(cParam[1], cParam[2], cParam[3])
	
	if cParam[11] then
		c:SetPerspective(cParam[7], cParam[8], cParam[9], cParam[10])
	else
		local p1, p2, p3, p4 = cParam[7], cParam[8], cParam[9], cParam[10]
		if not p1 or not p2 then
			p1, p2 = s:GetSize()
			p1 = p1 * Station.GetUIScale()
			p2 = p2 * Station.GetUIScale()
		end
		if not p3 or not p4 then
			p3, p4 = 0, 400
		end
		c:SetOrthogonal(p1, p2, p3, p4)
	end
	
	s.m_models = s.m_models or {}
	for k,v in pairs(s.m_models) do
		s.m_scene:RemoveRenderEntity(v)
		v:Release()
	end
	s.m_models={}
	
	s.m_ttl = sfx.Ttl
	for i,v in ipairs(sfx.Models) do
		if v.Model then
			local m = s.m_modelMgr:NewModel(v.Model.File)
			if m then
				m:SetTranslation(0, 0, 0)
				s.m_scene:AddRenderEntity(m)
				s.m_models[v.Model.Name] = m
		
				if v.Model.Translation then
					local T = v.Model.Translation
					m:SetTranslation(T.x, T.y, T.z)
				end	
				if v.Model.Rotation then
					local R = v.Model.Rotation
					m:SetRotation(R.x, R.y, R.z, R.w)
				end
				if v.Model.Scaling then
					local S = v.Model.Scaling
					m:SetScaling(S.x, S.y, S.z)
				end
				if v.Model.Ani then
					local A = v.Model.Ani
					if bHandleEvent then
						m:RegisterEventHandler()
					end
					m:PlayAnimation(A.PlayType, A.File, A.Speed, A.StartTime)
				end
			end
		end
	end
end

--清除场景控件中的动画
function ClearSFX(s)
	if s.m_models then
		for k,v in pairs(s.m_models) do
			s.m_scene:RemoveRenderEntity(v)
			v:Release()
		end
		s.m_models={}
	end

	if s.m_scene then
		KG3DEngine.DeleteScene(s.m_scene)
		s.m_scene=nil
	end
end
