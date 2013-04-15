FullScreenSFX={
	m_scene = nil;
	m_camera = nil;
	m_modelMgr = nil;
	m_models = {};
	m_ttl = nil;
	m_w = 0;
	m_h = 0;
	m_near = 0;
	m_far = 400;

	m_args={
		[1]={
			Ttl=32,
			Camera={ 0, 0, -200, 0, 0, 0, nil, nil, nil, nil, false }, 
			Models={
				[1]={ 
					Model={
						Name="logo",
						File=Table_GetPath("SFX_LOGO"),
						Translation={x=0, y=0, z=0},
						Rotation={x=0,y=0,z=0,w=0},
						Scaling={x=0.2,y=0.2,z=0.2},
				
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
		[2]={
			Ttl=32,
			Camera={ 0, 0, -200, 0, 0, 0, nil, nil, nil, nil, false }, 
			Models={
				[1]={ 
					Model={
						Name="CriticalStrike",
						File=Table_GetPath("SFX_CRITICALSTRIKE"),
						Translation={x=0, y=100, z=0},
						Scaling={x=0.3,y=0.3,z=0.3},
				
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
		["CriticalStrike"]={
			Ttl=32,
			Camera={ 0, 0, -200, 0, 0, 0, nil, nil, nil, nil, false }, 
			Models={
				[1]={ 
					Model={
						Name="CriticalStrike",
						File=Table_GetPath("SFX_CRITICALSTRIKESHAKE"),
				
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

		["LevelUp"]={
			Ttl=32,
			Camera={ 0, 0, -200, 0, 0, 0, nil, nil, nil, nil, false }, 
			Models={
				[1]={ 
					Model={
						Name="LevelUp",
						File="",
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

		["SkillLevelUp"]={
			Ttl=32,
			Camera={ 0, 0, -200, 0, 0, 0, nil, nil, nil, nil, false }, 
			Models={
				[1]={ 
					Model={
						Name="SkillLevelUp",
						File=Table_GetPath("SFX_SKILLLEVELUP"),
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

		["FinishQuest"]={
			Ttl=32,
			Camera={ 0, 0, -200, 0, 0, 0, nil, nil, nil, nil, false }, 
			Models={
				[1]={ 
					Model={
						Name="FinishQuest",
						File=Table_GetPath("SFX_FINISHQUEST"),
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

		["FinishAssistQuest"]={
			Ttl=32,
			Camera={ 0, 0, -200, 0, 0, 0, nil, nil, nil, nil, false }, 
			Models={
				[1]={ 
					Model={
						Name="FinishAssistQuest",
						File=Table_GetPath("SFX_FINISHASSISTQUEST"),
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

		["LearnProfession"]={
			Ttl=32,
			Camera={ 0, 0, -200, 0, 0, 0, nil, nil, nil, nil, false }, 
			Models={
				[1]={ 
					Model={
						Name="LearnProfession",
						File=Table_GetPath("SFX_LEARNPROFESSION"),
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

		["ForgetProfession"]={
			Ttl=32,
			Camera={ 0, 0, -200, 0, 0, 0, nil, nil, nil, nil, false }, 
			Models={
				[1]={ 
					Model={
						Name="ForgetProfession",
						File=Table_GetPath("SFX_FORGETPROFESSION"),
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

		["LearnRecipe"]={
			Ttl=32,
			Camera={ 0, 0, -200, 0, 0, 0, nil, nil, nil, nil, false }, 
			Models={
				[1]={ 
					Model={
						Name="LearnRecipe",
						File=Table_GetPath("SFX_LEARNRECIPE"),
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

		["ProfessionLevelUp"]={
			Ttl=32,
			Camera={ 0, 0, -200, 0, 0, 0, nil, nil, nil, nil, false }, 
			Models={
				[1]={ 
					Model={
						Name="ProfessionLevelUp",
						File=Table_GetPath("SFX_PROFESSIONLEVELUP"),
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

		["ProfessionMaxLevelUp"]={
			Ttl=32,
			Camera={ 0, 0, -200, 0, 0, 0, nil, nil, nil, nil, false }, 
			Models={
				[1]={ 
					Model={
						Name="ProfessionMaxLevelUp",
						File=Table_GetPath("SFX_PROFESSIONMAXLEVELUP"),
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

		["ReputationLevelUp"]={
			Ttl=32,
			Camera={ 0, 0, -200, 0, 0, 0, nil, nil, nil, nil, false }, 
			Models={
				[1]={ 
					Model={
						Name="ReputationLevelUp",
						File=Table_GetPath("SFX_REPUTATIONLEVELUP"),
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

		["ReputationLevelDown"]={
			Ttl=32,
			Camera={ 0, 0, -200, 0, 0, 0, nil, nil, nil, nil, false }, 
			Models={
				[1]={ 
					Model={
						Name="ReputationLevelDown",
						File=Table_GetPath("SFX_REPUTATIONLEVELDOWN"),
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
		
		["NewAchievement"]={
			Ttl=32,
			Camera={ 0, 0, -200, 0, 0, 0, nil, nil, nil, nil, false }, 
			Models={
				[1]={ 
					Model={
						Name="NewAchievement",
						File=Table_GetPath("SFX_NEWACHIEVEMENT"),
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
	}
}

function FullScreenSFX.SetCamera(...)
  local xp, yp, zp, xl, yl, zl, p1, p2, p3, p4, bPerspective = select(1, ...)
	
	FullScreenSFX.m_camera:SetLookAtPosition(xl, yl, zl)
	FullScreenSFX.m_camera:SetPosition(xp, yp, zp)
	
	if bPerspective then
		FullScreenSFX.m_camera:SetPerspective(p1, p2, p3, p4)
	else
		if not p1 or not p2 then
			p1 = FullScreenSFX.m_w
			p2 = FullScreenSFX.m_h
		end
		if not p3 or not p4 then
			p3 = FullScreenSFX.m_near
			p4 = FullScreenSFX.m_far
		end
		FullScreenSFX.m_camera:SetOrthogonal(p1, p2, p3, p4)
	end
end;

function FullScreenSFX.LoadModel(k, file)
	if not file or file == "" then
		Log("[config\\default\\FullScreenSFX.lua LoadModel] SFX file of \""..k.."\" is empty!")
		return nil
	end
	
	FullScreenSFX.UnloadModel(k)
	local m = FullScreenSFX.m_modelMgr:NewModel(file)
	if m then
		m:SetTranslation(0, 0, 0)
		FullScreenSFX.m_scene:AddRenderEntity(m)
		FullScreenSFX.m_models[k]=m
	end
	return m
end;

function FullScreenSFX.UnloadModel(k)
	local m = FullScreenSFX.m_models[k]
	if m then
		FullScreenSFX.m_scene:RemoveRenderEntity(m)
		m:Release()
		FullScreenSFX.m_models[k] = nil
	end
end;

function FullScreenSFX.UnloadAllModel()
	for k,v in pairs(FullScreenSFX.m_models) do
		FullScreenSFX.m_scene:RemoveRenderEntity(v)
		v:Release()
	end
	FullScreenSFX.m_models={}
end;

function FullScreenSFX.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")

	FullScreenSFX.UpdateSceneSize(this)

	-- Scene
	FullScreenSFX.m_scene = KG3DEngine.NewScene()
	FullScreenSFX.m_modelMgr = KG3DEngine.GetModelMgr()

	local scene = this:Lookup("Scene_SFX")
	scene:SetScene(FullScreenSFX.m_scene)
	
	FullScreenSFX.m_w, FullScreenSFX.m_h = scene:GetSize()

	-- Camera
	FullScreenSFX.m_camera = FullScreenSFX.m_scene:GetCamera()
	FullScreenSFX.SetCamera(0, 0, -200, 0, 0, 0, nil, nil, nil, nil, false)
end;

function FullScreenSFX.OnFrameDestroy()
	FullScreenSFX.UnloadAllModel()

	KG3DEngine.DeleteScene(FullScreenSFX.m_scene)
	FullScreenSFX.m_scene=nil
end;

function FullScreenSFX.UpdateSceneSize(frame)
	local w, h = Station.GetClientSize()
	frame:SetSize(w, h)
	frame:Lookup("Scene_SFX"):SetSize(w, h)
	frame:SetRelPos(0, 0)

	FullScreenSFX.m_w = w
	FullScreenSFX.m_h = h
end;

function FullScreenSFX.OnEvent(event)
	if event == "UI_SCALED" then
		FullScreenSFX.UpdateSceneSize(this)
	end
end;

function FullScreenSFX.OnFrameBreathe()
	if FullScreenSFX.m_ttl then
		if FullScreenSFX.m_ttl > 0 then
			FullScreenSFX.m_ttl = FullScreenSFX.m_ttl - 1
		else
			FullScreenSFX.UnloadAllModel()
			this:Hide()
		end
	end
end;

function ShowFullScreenSFX(index)

	FullScreenSFX.UnloadAllModel()

	if FullScreenSFX.m_args[index] then
		local w=Wnd.OpenWindow("FullScreenSFX")
		w:BringToTop()
		w:Show()

		FullScreenSFX.m_ttl = FullScreenSFX.m_args[index].Ttl

		FullScreenSFX.SetCamera(unpack(FullScreenSFX.m_args[index].Camera))
		
		for i,v in ipairs(FullScreenSFX.m_args[index].Models) do
			if v.Model then
				local m = FullScreenSFX.LoadModel(v.Model.Name, v.Model.File)
				if m then
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
						m:PlayAnimation(A.PlayType, A.File, A.Speed, A.StartTime)
					end
				end
			end
		end
	end
end;

