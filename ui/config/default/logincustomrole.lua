local g_tTreatWeapon = 
{
	[3003] = true,
	[1600] = true,
	[1593] = true,
}

LoginCustomRole={
	m_aChar={ 
		ROLE_TYPE.STANDARD_MALE,	--m1
		ROLE_TYPE.STANDARD_MALE,	--m2 ROLE_TYPE.LITTLE_BOY
		ROLE_TYPE.STANDARD_MALE,	--m3 ROLE_TYPE.STRONG_MALE 
		ROLE_TYPE.LITTLE_GIRL,		--f1
		ROLE_TYPE.STANDARD_FEMALE,	--f2
		ROLE_TYPE.STANDARD_FEMALE	--f3 ROLE_TYPE.SEXY_FEMALE
	};
	
	m_nFace=1;
	m_nHair=1;
	m_nBang=1;
	m_nPlait=1;
	m_nDress=1;
	m_nBoots=1;
	m_nBangle=1;
	m_nWaist=1;
	m_nWeapon = 1;
	--m_nChar=2;
	m_nHomeplace = 0;
	
	m_nKungfuID = 1,
	m_tKungfu = 
	{
		["wh"] = {1, 2}, -- 1 花间游 2 离经易道
		["cy"] = {3, 4}, -- 3 紫霞功 4 太虚剑意
		["tc"] = {5, 6}, -- 5 傲雪战意 6 铁牢律
		["sl"] = {7, 8}, -- 7 易筋经 8 洗髓经
		["qx"] = {9, 10}, -- 9 冰心诀 10 云裳心经
		["cj"] = {11, 12}, -- 11 问水诀 12 山居剑意
		["wd"] = {13, 14}, -- 13 毒经 14 补天诀
		["tm"] = {15, 16}, -- 15 惊羽决 16 太虚剑意
	};
	
	m_tSchoolEquip = {
    	["wh"] = {     -- 万花
    		["HelmStyle"] = 95,
    		["ChestStyle"] = 95,
    		["ChestColor"] = 1,
    		["WaistStyle"] = 95,
    		["WaistColor"] = 1,
    		["BangleStyle"] = 95,
    		["BangleColor"] = 1,
    		["BootsStyle"] = 95,
    		["BootsColor"] = 1,
    		["WeaponStyle"] = 585,
    		["WeaponColor"] = 8,
    		["WeaponEnchant2"] = 11,
        },
    	["cy"] = {     -- 纯阳
    		["HelmStyle"] = 55,
    		["ChestStyle"] = 55,
    		["ChestColor"] = 1,
    		["WaistStyle"] = 55,
    		["WaistColor"] = 1,
    		["BangleStyle"] = 55,
    		["BangleColor"] = 1,
    		["BootsStyle"] = 55,
    		["BootsColor"] = 1,
    		["WeaponStyle"] = 825,
    		["WeaponColor"] = 6,
    		["WeaponEnchant2"] = 7,
        },
    	["tc"] = {     -- 天策
    		["HelmStyle"] = 85,
    		["ChestStyle"] = 85,
    		["ChestColor"] = 1,
    		["WaistStyle"] = 85,
    		["WaistColor"] = 1,
    		["BangleStyle"] = 85,
    		["BangleColor"] = 1,
    		["BootsStyle"] = 85,
    		["BootsColor"] = 1,
    		["WeaponStyle"] = 183,
    		["WeaponColor"] = 7,
    		["WeaponEnchant2"] = 3,
        },
    	["sl"] = {     -- 少林
    		["HairStyle"] = 63,
    		["ChestStyle"] = 65,
    		["ChestColor"] = 1,
    		["WaistStyle"] = 65,
    		["WaistColor"] = 1,
    		["BangleStyle"] = 65,
    		["BangleColor"] = 1,
    		["BootsStyle"] = 65,
    		["BootsColor"] = 1,
    		["WeaponStyle"] = 87,
    		["WeaponColor"] = 5,
    		["WeaponEnchant2"] = 1,
        },
    	["qx"] = {     -- 七秀
    		["HelmStyle"] = 65,
    		["ChestStyle"] = 65,
    		["ChestColor"] = 1,
    		["WaistStyle"] = 65,
    		["WaistColor"] = 1,
    		["BangleStyle"] = 65,
    		["BangleColor"] = 1,
    		["BootsStyle"] = 65,
    		["BootsColor"] = 1,
    		["WeaponStyle"] = 904,
    		["WeaponColor"] = 6,
    		["WeaponEnchant2"] = 8,
        },
    	["cj"] = {     -- 藏剑
    		["HelmStyle"] = 67,
    		["ChestStyle"] = 67,
    		["ChestColor"] = 1,
    		["WaistStyle"] = 67,
    		["WaistColor"] = 1,
    		["BangleStyle"] = 67,
    		["BangleColor"] = 1,
    		["BootsStyle"] = 67,
    		["BootsColor"] = 1,
    		["WeaponStyle"] = 823,
    		["WeaponColor"] = 8,
    		["WeaponEnchant2"] = 13,
			
    		["BigSwordStyle"] = 635,
    		["BigSwordColor"] = 2,
    		["BigSwordEnchant2"] = 15,
			
        },
    	["gb"] = {     -- 丐帮
    		["HelmStyle"] = nil,
    		["ChestStyle"] = nil,
    		["WaistStyle"] = nil,
    		["BangleStyle"] = nil,
    		["BootsStyle"] = nil,
    		["WeaponStyle"] = nil,
        },
    	["mj"] = {     -- 明教
    		["HelmStyle"] = nil,
    		["ChestStyle"] = nil,
    		["WaistStyle"] = nil,
    		["BangleStyle"] = nil,
    		["BootsStyle"] = nil,
    		["WeaponStyle"] = nil,
        },
    	["wd"] = {     -- 五毒
    		["HelmStyle"] = 70,
    		["ChestStyle"] = 70,
			["ChestColor"] = 1,
    		["WaistStyle"] = 70,
			["WaistColor"] = 1,
    		["BangleStyle"] = 70,
			["BangleColor"] = 1,
    		["BootsStyle"] = 70,
			["BootsColor"] = 1,
    		["WeaponStyle"] = 742,
    		["WeaponColor"] = 5,
    		["WeaponEnchant2"] = 16,
        },
    	["tm"] = {     -- 唐门
    		["HelmStyle"] = 89,
    		["ChestStyle"] = 89,
			["ChestColor"] = 1,
    		["WaistStyle"] = 89,
			["WaistColor"] = 1,
    		["BangleStyle"] = 89,
			["BangleColor"] = 1,
    		["BootsStyle"] = 89,
			["BootsColor"] = 1,
    		["WeaponStyle"] = 1003,
    		["WeaponColor"] = 5,
    		["WeaponEnchant2"] = 19,
        },
    };
	
	m_tSchoolAni = {
	    ["wh"] = {["male"] = 1013, ["female"] = 1013},
	    ["cy"] = {["male"] = 1012, ["female"] = 1012},
	    ["tc"] = {["male"] = 1011, ["female"] = 1011},
	    ["sl"] = {["male"] = 1014, ["female"] = nil},
	    ["qx"] = {["male"] = nil, ["female"] = 1014},
	    ["cj"] = {["male"] = 2021, ["female"] = 2021},
	    ["gb"] = {["male"] = nil, ["female"] = nil},
	    ["mj"] = {["male"] = nil, ["female"] = nil},
	    ["wd"] = {["male"] = 853, ["female"] = 853},
	    ["tm"] = {["male"] = 1151, ["female"] = 1151},
	};
	
	m_tSchoolIdleAni =
	{
	    ["wh"] = 39,
	    ["cy"] = 33,
	    ["tc"] = 32,
	    ["sl"] = 31,
	    ["qx"] = 38,
	    ["cj"] = 34,
	    ["gb"] = nil,
	    ["mj"] = nil,
	    ["wd"] = 845,--30,
	    ["tm"] = 1141, 
	};
	
	m_tBodyCheckBox = 
	{
		["CheckBox_m2"] = 2,
		["CheckBox_f2"] = 5,
		["CheckBox_f1"] = 4,
	};
	
	m_tCenterImage = 
	{
		["Handle_Man"] = 2,
		["Handle_Woman"] = 5,
		["Handle_Loli"] = 4,
	};
	
	m_tSchoolCheckBox = 
	{
		["CheckBox_WH"] = "wh",
		["CheckBox_CY"] = "cy",
		["CheckBox_SL"] = "sl",
		["CheckBox_QX"] = "qx",
		["CheckBox_TC"] = "tc",
		["CheckBox_CJ"] = "cj",
		["CheckBox_WD"] = "wd",
		["CheckBox_TM"] = "tm",
	};
	
	m_tSchoolWeaponType =
	{
		["cy"] = WEAPON_DETAIL.SWORD,
		["wh"] = WEAPON_DETAIL.PEN,
		["tm"] = WEAPON_DETAIL.BOW,
		["wd"] = WEAPON_DETAIL.FLUTE,
		["tc"] = WEAPON_DETAIL.SPEAR,
		["cj"] = WEAPON_DETAIL.SWORD,
		["sl"] = WEAPON_DETAIL.WAND,
		["qx"] = WEAPON_DETAIL.DOUBLE_WEAPON,
	};
	
	m_tWeaponAni =
	{
		[WEAPON_DETAIL.SWORD] = 
		{--短兵类
			["male"]={Pick={270, 271, 34}, Insert={235, 236, 30} },
			["female"]={Pick={270, 271, 34}, Insert={235, 236, 30} } ,
		}, 
		[WEAPON_DETAIL.DOUBLE_WEAPON] = 
		{--双兵类
			["male"]={Pick={216, 217, 37}, Insert={241, 242, 30} },
			["female"]={Pick={216, 217, 37}, Insert={241, 242, 30} } ,
		},  
		[WEAPON_DETAIL.PEN] = 
		{--笔类
			["male"]={Pick={218, 219, 39}, Insert={227, 228, 30} },
			["female"]={Pick={218, 219, 39}, Insert={227, 228, 30} },
		}, 
		[WEAPON_DETAIL.BOW] = 
		{--千机匣
			["male"]={Pick={1147, 1148, 1141}, Insert={1149, 1150, 30} },
			["female"]={Pick={1147, 1148, 1141}, Insert={1149, 1150, 30} },
		},
		[WEAPON_DETAIL.FLUTE] = 
		{-- 笛类
			["male"]={Pick={849, 850, 845}, Insert={851, 852, 30} },
			["female"]={Pick={849, 850, 845}, Insert={851, 852, 30} },
		},  
		[WEAPON_DETAIL.SPEAR] = 
		{ --长兵类
			["male"]={Pick={210, 211, 32}, Insert={237, 238, 30} },
			["female"]={Pick={210, 211, 32}, Insert={237, 238, 30} },
		},
		[WEAPON_DETAIL.WAND] = 
		{--棍类		
			["male"]={Pick={536, 537, 31}, Insert={239, 240, 30} },
			["female"]={Pick={536, 537, 31}, Insert={239, 240, 30} },
		},  
	};
	
	tSchoolParam = Table_GetCreateRoleParam();
	
OnFrameCreate=function()
	this:RegisterEvent("UI_SCALED")

	LoginCustomRole.OnEvent("UI_SCALED")
	
	if not LoginCustomRole.bPreloadAllRes then
		LoginCustomRole.PreloadAllRes()
		LoginCustomRole.bPreloadAllRes = true
	end
end;

OnEvent=function(event)
	if event == "UI_SCALED" then
		LoginCustomRole.StopAllAni(this, nil, true)
		
		this:SetSize(Station.GetClientSize())
		
		this:Lookup("WndType_Body"):SetPoint("TOPLEFT", 0, 0, "TOPLEFT", 0, 80)
		this:Lookup("Wnd_Center"):SetPoint("CENTER", 0, 0, "CENTER", 0, -40)
		
		this:Lookup("WndNext"):SetPoint("BOTTOMCENTER", 0, 0, "BOTTOMCENTER", 0, -20)
		this:Lookup("WndBack"):SetPoint("BOTTOMRIGHT", 0, 0, "BOTTOMRIGHT", -70, -20)
		
		this:Lookup("Wnd_InformationUp"):SetPoint("TOPRIGHT", 0, 0, "TOPRIGHT", 0, 80)
		this:Lookup("Wnd_InformationDown"):SetPoint("BOTTOMRIGHT", 0, 0, "BOTTOMRIGHT", 0, -120)		
		this:Lookup("WndSingleRoleRotate"):SetPoint("BOTTOMCENTER", 0, 0, "BOTTOMCENTER", 0, -150)
		this:Lookup("WndSingleRoleControl"):SetPoint("BOTTOMCENTER", 0, 0, "BOTTOMCENTER", 175, -140)
		this:Lookup("WndType_School"):SetPoint("BOTTOMLEFT", 0, 0, "BOTTOMLEFT", 0, -100)
		Login.UpdateSdoaTaskBarPosition("LOGIN")
		
		LoginCustomRole.UpdateInitSize(this)
		LoginCustomRole.UpdateInitPos(this)
	end
end;

OnFrameShow=function()
	if not LoginCustomRole.bEnterCustomRole then
		return
	end
	
	LoginSingleRole.UnloadModel()
	LoginCustomRole.bBodyAni = nil
	LoginCustomRole.bSchoolAni = nil
	LoginCustomRole.bInfoUpAni = nil
	LoginCustomRole.bInfoDownAni = nil
	LoginCustomRole.m_nChar = nil
	LoginCustomRole.m_szSchoolType = nil
	LoginCustomRole.bCenterEnterAni = nil
	LoginCustomRole.bPlaying = nil
	
	LoginCustomRole.Init(this);
	LoginSingleRole.RestoreCameraState()
	local focus = Station.GetFocusWindow()
	if focus and focus:IsValid() and focus:GetRoot():GetName() == "LoginMessage" then
		focus:Hide()
		Station.SetFocusWindow(this)
		this:FocusHome()
		focus:Show()
	else
		Station.SetFocusWindow(this)
		this:FocusHome()
	end
	
	LoginCustomRole.UpdateBodyShow(this);
	LoginCustomRole.UpdateSchoolShow(this);
	LoginCustomRole.UpdateSchoolInfoShow(this);
end;

StopAllAni=function(frame, bStopRoleAni, bNotDelay)
	local hWnd = frame:Lookup("WndType_Body")
	if not hWnd then
		return
	end
	
	LoginCustomRole.bPlaying = false
	Animation_StopAni(hWnd:Lookup("", ""), bNotDelay)
	
	Animation_StopAni(hWnd:Lookup("CheckBox_m2"), bNotDelay)
	Animation_StopAni(hWnd:Lookup("CheckBox_f2"), bNotDelay)
	Animation_StopAni(hWnd:Lookup("CheckBox_f1"), bNotDelay)
	
	hWnd = frame:Lookup("WndType_School")
	Animation_StopAni(hWnd:Lookup("", ""), bNotDelay)
	for szName, _ in pairs(LoginCustomRole.m_tSchoolCheckBox) do
		Animation_StopAni(hWnd:Lookup(szName), bNotDelay)
	end
	
	Animation_StopAni(frame:Lookup("Wnd_InformationUp"), bNotDelay)
	Animation_StopAni(frame:Lookup("Wnd_InformationDown"), bNotDelay)
	local hCenter = frame:Lookup("Wnd_Center", "")
	
	LoginCustomRole.StopHandleUIAni(hCenter:Lookup("Handle_Man"), bNotDelay)
	LoginCustomRole.StopHandleUIAni(hCenter:Lookup("Handle_Woman"), bNotDelay)
	LoginCustomRole.StopHandleUIAni(hCenter:Lookup("Handle_Loli"), bNotDelay)
	
	Animation_StopAni(hCenter:Lookup("Image_CenterTitle"), bNotDelay)
	
	if bStopRoleAni then
		LoginSingleRole.StopPlayAni()
	end
end;

OnFrameHide=function()
	local hWnd = this:Lookup("WndType_Body")
	if not hWnd then
		return
	end
	LoginCustomRole.StopAllAni(this, true)
end;

StopHandleUIAni=function(handle)
	local nCount = handle:GetItemCount() - 1
	for i=0, nCount, 1 do
		Animation_StopAni(handle:Lookup(i))
	end
end;

UpdateInitSize=function(frame)
	local hWndBody = frame:Lookup("WndType_Body")
	local hBodyTotal = hWndBody:Lookup("", "")
	hBodyTotal.fInitW, hBodyTotal.fInitH = hBodyTotal:GetSize()
	for szName, _ in pairs(LoginCustomRole.m_tBodyCheckBox) do
		local hCheck = hWndBody:Lookup(szName)
		hCheck.fInitW, hCheck.fInitH = hCheck:GetSize()
	end
	
	local hWndUp = frame:Lookup("Wnd_InformationUp")
	hWndUp.fInitW, hWndUp.fInitH = hWndUp:GetSize()
	
	local hWndDown = frame:Lookup("Wnd_InformationDown")
	hWndDown.fInitW, hWndDown.fInitH = hWndDown:GetSize()
	
	local hWnd = frame:Lookup("WndType_School")
	local handle = hWnd:Lookup("", "")
	handle.fInitW, handle.fInitH = handle:GetSize()
	for szName, _ in pairs(LoginCustomRole.m_tSchoolCheckBox) do
		local hCheck = hWnd:Lookup(szName)
		hCheck.fInitW, hCheck.fInitH = hCheck:GetSize()
	end
	
	local hHandle = frame:Lookup("Wnd_Center", "")
	for szName, _ in pairs(LoginCustomRole.m_tCenterImage) do
		local hContent = hHandle:Lookup(szName)
		hContent.fInitW, hContent.fInitH = hContent:GetSize()
		nCount = hContent:GetItemCount() - 1
		for i=0, nCount, 1 do
			local hItem = hContent:Lookup(i)
			hItem.fInitW, hItem.fInitH = hItem:GetSize()
		end
	end
	
	local hImageTitle = hHandle:Lookup("Image_CenterTitle")
	hImageTitle.fInitW, hImageTitle.fInitH = hImageTitle:GetSize()
end;

UpdateInitPos=function(frame)
	local hWndBody = frame:Lookup("WndType_Body")
	local hBodyTotal = hWndBody:Lookup("", "")
	hBodyTotal.fInitX, hBodyTotal.fInitY = hBodyTotal:GetAbsPos()
	for szName, _ in pairs(LoginCustomRole.m_tBodyCheckBox) do
		local hCheck = hWndBody:Lookup(szName)
		hCheck.fInitX, hCheck.fInitY = hCheck:GetAbsPos()
	end
	
	local hWndUp = frame:Lookup("Wnd_InformationUp")
	hWndUp.fInitX, hWndUp.fInitY = hWndUp:GetAbsPos()
	
	local hWndDown = frame:Lookup("Wnd_InformationDown")
	hWndDown.fInitX, hWndDown.fInitY = hWndDown:GetAbsPos()
	
	local hWnd = frame:Lookup("WndType_School")
	local handle = hWnd:Lookup("", "")
	handle.fInitX, handle.fInitY = handle:GetAbsPos()
	for szName, _ in pairs(LoginCustomRole.m_tSchoolCheckBox) do
		local hCheck = hWnd:Lookup(szName)
		hCheck.fInitX, hCheck.fInitY = hCheck:GetAbsPos()
	end
	
	local hHandle = frame:Lookup("Wnd_Center", "")
	for szName, _ in pairs(LoginCustomRole.m_tCenterImage) do
		local hContent = hHandle:Lookup(szName)
		hContent.fInitX, hContent.fInitY = hContent:GetAbsPos()
		local nCount = hContent:GetItemCount() - 1
		for i=0, nCount, 1 do
			local hItem = hContent:Lookup(i)
			hItem.fInitX, hItem.fInitY = hItem:GetAbsPos()
		end
	end
	
	local hImageTitle = hHandle:Lookup("Image_CenterTitle")
	hImageTitle.fInitX, hImageTitle.fInitY = hImageTitle:GetAbsPos()
end;

Init=function(frame, nChar, szSchoolType)
	LoginCustomRole.m_nChar = nChar
	LoginCustomRole.m_szSchoolType = szSchoolType
	
	frame.bIniting = true
	
	if LoginCustomRole.bCorrentSide then
		local hWndBody = frame:Lookup("WndType_Body")
		for szCheckBox, nChar1 in pairs(LoginCustomRole.m_tBodyCheckBox) do
			if LoginCustomRole.m_nChar == nChar1 then
				local hCheckBox = hWndBody:Lookup(szCheckBox)
				hCheckBox:Check(true)
				LoginCustomRole.CheckBodyOrSchool(hCheckBox)
			else
				hWndBody:Lookup(szCheckBox):Check(false)
			end
		end
	end
	
	local hWnd = frame:Lookup("WndType_School")
	for szCheckBox, szType in pairs(LoginCustomRole.m_tSchoolCheckBox) do
		if LoginCustomRole.m_szSchoolType == szType then
			local hCheckBox = hWnd:Lookup(szCheckBox)
			hCheckBox:Check(true)
			LoginCustomRole.CheckBodyOrSchool(hCheckBox)
		else
			hWnd:Lookup(szCheckBox):Check(false)
		end
	end
	
	frame.bIniting = false
end;

StepPrev=function()
	LoginSingleRole.RestoreCameraState()
	LoginCustomRole.bCorrentSide = nil
	LoginCustomRole.bBodyInitAni = nil
	Login.StepPrev()
end;

RestoreBodyInitSize =function(frame)
	if not LoginCustomRole.bCorrentSide then
		for szName, v in pairs(LoginCustomRole.m_tBodyCheckBox) do
			local hCheck = frame:Lookup(szName)
			if hCheck.fInitW then
				hCheck:SetSize(hCheck.fInitW, hCheck.fInitH)
			end
		end
	end
end;

UpdateBodyShow=function(frame, bCheck)
	if not LoginCustomRole.bCorrentSide then
		frame:Lookup("WndType_Body"):Hide()
		frame:Lookup("Wnd_Center"):Show()
		LoginCustomRole.PlayCenterUIAni(frame, "enter")
	else
		frame:Lookup("Wnd_Center"):Hide()
		frame:Lookup("WndType_Body"):Show()
		if not LoginCustomRole.bBodyAni and not bCheck then
			LoginCustomRole.PlayBodyUIAni(frame);
			LoginCustomRole.bBodyAni = true
		end
	end
end;

UpdateSchoolShow=function(frame, bCheck)
	if LoginCustomRole.m_nChar then
		frame:Lookup("WndSingleRoleRotate"):Show()
		frame:Lookup("WndSingleRoleControl"):Show()
	else
		frame:Lookup("WndType_School"):Hide()
		frame:Lookup("WndSingleRoleRotate"):Hide()
		frame:Lookup("WndSingleRoleControl"):Hide()
	end
end;

UpdateSchoolInfoShow=function(frame)
	if LoginCustomRole.m_szSchoolType then
		local hWndUp = frame:Lookup("Wnd_InformationUp")
		local hWndDown = frame:Lookup("Wnd_InformationDown")
		
		hWndUp:Show()
		hWndDown:Show()
		frame:Lookup("WndNext"):Show()
		
		if not LoginCustomRole.bInfoUpAni then
			local fn=function()
				Animation_AppendLineAni(hWndUp, "Role_InfoStop")
			end
			Animation_StopAni(hWndUp);
			Animation_AppendLineAni(hWndUp, "Role_Info", nil, fn)
			LoginCustomRole.bInfoUpAni = true
		end
		
		if not LoginCustomRole.bInfoDownAni then
			local fn=function()
				PlaySound(SOUND.UI_SOUND, g_sound.Enter)
				Animation_AppendLineAni(hWndDown, "Role_InfoStop")
			end
			Animation_StopAni(hWndDown);
			Animation_AppendLineAni(hWndDown, "Role_Info", 200, fn)
			LoginCustomRole.bInfoDownAni = true
		end
	else
		frame:Lookup("Wnd_InformationUp"):Hide()
		frame:Lookup("Wnd_InformationDown"):Hide()
		frame:Lookup("WndNext"):Hide()
	end
end;

PlayCenterUIAni=function(frame, szType, hContent)
	if szType == "enter" then
		if LoginCustomRole.bCenterEnterAni then
			return
		end
		
		local tAniParam = 
		{
			["Handle_Man"]   = {nAniID = "Role_BodyIn3", fDelayTime=0, fnBegin= function() PlaySound(SOUND.UI_SOUND, g_sound.Fly_m2) end},
			["Handle_Woman"] = {nAniID = "Role_BodyIn2", fDelayTime=250, fnBegin= function() PlaySound(SOUND.UI_SOUND, g_sound.Fly_f2) PlaySound(SOUND.UI_SOUND, g_sound.PeiYin) end},
			["Handle_Loli"]  = {nAniID = "Role_BodyIn1", fDelayTime=500, fnAction= function()  LoginCustomRole.bPlaying = false end, fnBegin= function() PlaySound(SOUND.UI_SOUND, g_sound.Fly_f1) end},
		}

		LoginCustomRole.bPlaying = true
		
		local hWndCenter = frame:Lookup("Wnd_Center", "")
		local hTitle = hWndCenter:Lookup("Image_CenterTitle")
		for szName, v in pairs(tAniParam) do
			local hCheck = hWndCenter:Lookup(szName)
			local nCount = hCheck:GetItemCount() - 1
			for i=0, nCount, 1 do
				local hImage = hCheck:Lookup(i)
				hImage:SetSize(hImage.fInitW, hImage.fInitH)
				hImage:SetAbsPos(hImage.fInitX,hImage.fInitY)
			end
			Animation_AppendLineAni(hCheck:Lookup(0), v.nAniID, v.fDelayTime, v.fnAction, v.fnBegin)
		end
		
		local fnStop = function()
			PlaySound(SOUND.UI_SOUND, g_sound.Fly1)
			Animation_AppendLineAni(hTitle, "Role_BodyStop")
		end
		Animation_AppendLineAni(hTitle, "Role_BodyTile", 500, fnStop)
		
		LoginCustomRole.bCenterEnterAni = true
	elseif szType == "mouse" then
		local fn=function()
			Animation_AppendLineAni(hContent, "Role_ScaleSmall")	
		end
		
		for i=0, nCount, 1 do
			local hImage= hContent:Lookup(i)
			hImage:Show()
			Animation_AppendLineAni(hImage, "Role_ScaleBig")
		end
		
	elseif szType == "leave" then
		local fnEnd = function()
			frame:Lookup("Wnd_Center"):Hide()
			LoginCustomRole.PlayJumpIn(LoginCustomRole.m_nChar)
			LoginCustomRole.PlayBodyUIAni(frame)
		end
		
		local tAniParam = 
		{
			["Handle_Man"]   = {nAniID = "Role_Scale1",},
			["Handle_Woman"] = {nAniID = "Role_Scale2",},
			["Handle_Loli"]  = {nAniID = "Role_Scale3",},
		}
		local hHandle = hContent:GetParent()
		for szName, v in pairs(tAniParam) do
			local hCheck = hHandle:Lookup(szName)
			if hCheck ~= hContent then
				v.nAniID = "Role_FadeOut"
			else
				v.fnAction = fnEnd
			end
			
			local hImage = hCheck:Lookup(0)
			local hImage1 = hCheck:Lookup(1)
			hImage:SetSize(hImage.fInitW, hImage.fInitH)
			hImage:SetAbsPos(hImage.fInitX, hImage.fInitY)
			
			hImage1:SetSize(hImage1.fInitW, hImage1.fInitH)
			hImage1:SetAbsPos(hImage1.fInitX, hImage1.fInitY)
			hImage1:Hide()
			
			PlaySound(SOUND.UI_SOUND, g_sound.Disappear)
			Animation_AppendLineAni(hImage, v.nAniID, v.fDelayTime, v.fnAction)
		end
		
		LoginCustomRole.bPlaying = true
		LoginCustomRole.bCorrentSide = true
	end
end;

PlayBodyUIAni=function(frame)
	local hWndBody = frame:Lookup("WndType_Body")
	hWndBody:Show()
	local fn=function()
		Animation_AppendLineAni(hWndBody:Lookup("", ""), "Role_BodyStop")
	end
	Animation_AppendLineAni(hWndBody:Lookup("", ""), "Role_BodyTile", 200, fn)
	
	local fnEnd = function()
		if not LoginCustomRole.bSchoolAni then
			LoginCustomRole.PlaySchoolUIAni(frame:Lookup("WndType_School"))
			LoginCustomRole.bSchoolAni = true
		end
	end
	
	local tAniParam = 
	{
		["CheckBox_m2"] = {nAniID = "Role_Body1", fDelayTime=240, fnAction=fnEnd, },
		["CheckBox_f2"] = {nAniID = "Role_Body2", fDelayTime=120, },
		["CheckBox_f1"] = {nAniID = "Role_Body3", fDelayTime=0, },
	}
	
	local fnBegin=function() PlaySound(SOUND.UI_SOUND, g_sound.Fly) end
	for szName, v in pairs(tAniParam) do
		local hCheck = hWndBody:Lookup(szName)
		Animation_AppendLineAni(hCheck, v.nAniID, v.fDelayTime, v.fnAction, fnBegin)
	end
end;

PlaySchoolUIAni=function(hWnd)
	hWnd:Show()
	local fn=function()
		Animation_AppendLineAni(hWnd:Lookup("", ""), "Role_BodyStop")
	end
	Animation_AppendLineAni(hWnd:Lookup("", ""), "Role_BodyTile", 280, fn)
	
	local fnBegin=function() PlaySound(SOUND.UI_SOUND, g_sound.Fly) end
	local tAni =
	{
		["CheckBox_WH"] = {nAniID = "Role_SchoolUp1", fDelayTime=300, fnBegin=fnBegin},
		["CheckBox_CY"] = {nAniID = "Role_SchoolUp2", fDelayTime=220, fnBegin=fnBegin},
		["CheckBox_SL"] = {nAniID = "Role_SchoolUp3", fDelayTime=150, fnBegin=fnBegin},
		["CheckBox_QX"] = {nAniID = "Role_SchoolUp4", fDelayTime=0, fnBegin=fnBegin},
		["CheckBox_TC"] = {nAniID = "Role_SchoolDown1", fDelayTime=320},
		["CheckBox_CJ"] = {nAniID = "Role_SchoolDown2", fDelayTime=120},
		["CheckBox_WD"] = {nAniID = "Role_SchoolDown3", fDelayTime=50},
		["CheckBox_TM"] = {nAniID = "Role_SchoolDown4", fDelayTime=180},
	}
	for szName, v in pairs(tAni) do
		local hCheck = hWnd:Lookup(szName)
		Animation_AppendLineAni(hCheck, v.nAniID, v.fDelayTime, nil, v.fnBegin)
	end
end;

PlaySkillAni=function(dwSkillIndex)
	local szType = LoginCustomRole.m_szSchoolType
	local nRoleType = LoginCustomRole.m_aChar[LoginCustomRole.m_nChar]
	local szSex  = LoginCustomRole.GetRoleSex(nRoleType)
    local tLine = LoginCustomRole.tSchoolParam[szType]
	local szAni = ""
	local nCount = tLine["dwPlayCount"..dwSkillIndex]
	if szSex == "male" then
		szAni = tLine["szMaleAniID"..dwSkillIndex]
	else
		szAni = tLine["szFemaleAniID"..dwSkillIndex]
	end
	
	local aAni = {}
	local tRes = SplitString(szAni, ";")
	for _, dwID in pairs(tRes) do
		for i=1, nCount, 1 do
			table.insert(aAni, {nAniID=dwID})
		end
	end
	
	if #aAni > 0 then
		local nAniID = LoginCustomRole.m_tSchoolIdleAni[szType]
		if g_tTreatWeapon[tLine["dwSkillID"..dwSkillIndex]] then
			local nLen = #aAni
			aAni[nLen].fnAction = function() LoginCustomRole.PlaySheath(nRoleType, szType, false) end
			if szType == "cj" then
				LoginCustomRole.PlaySheath(nRoleType, szType, true, true)
			else
				LoginCustomRole.PlaySheath(nRoleType, szType, true)
			end
		else
			LoginCustomRole.PlaySheath(nRoleType, szType, false, false)
		end
		table.insert(aAni, {nAniID=nAniID, fTweenTime=300, szType="loop"})
		LoginSingleRole.BeginPlaySeqAni(nRoleType, aAni)
	end
end;

GetJumpAni=function(szSchoolType, nRoleType)
	if not szSchoolType then
		szSchoolType= "jh"
	end
	
	local tLine = LoginCustomRole.tSchoolParam[szSchoolType]
	local szAni
	if nRoleType == ROLE_TYPE.STANDARD_MALE then
		szAni = tLine.szMale2JumpAni
	elseif nRoleType == ROLE_TYPE.LITTLE_GIRL then
		szAni = tLine.szFemale1JumpAni
	elseif nRoleType == ROLE_TYPE.STANDARD_FEMALE then
		szAni = tLine.szFemale2JumpAni
	else
		return
	end
	
	local tRes = SplitString(szAni, ";")
	return tRes[1], tRes[2]
end;

PlayJumpIn=function(nChar, szSchoolType, nOldChar, szOldSchoolType)
	LoginSingleRole.StopPlayAni()
	local fnUpdateModel
	local nSchoolAniId

	local nRoleType = LoginCustomRole.m_aChar[nChar]
	local szSex = LoginCustomRole.GetRoleSex(nRoleType)
	
	if not szSchoolType then
		fnUpdateModel = function(bSheath) 
			LoginCustomRole.m_nModelType = nRoleType
			LoginCustomRole.m_szModelSchool = szSchoolType
			LoginCustomRole.UpdateSelection(nRoleType, bSheath) 
		end
	else
		fnUpdateModel = function(bSheath) 
			LoginCustomRole.m_nModelType = nRoleType
			LoginCustomRole.m_szModelSchool = szSchoolType
			LoginCustomRole.ShowSchoolEquip(szSchoolType, nRoleType, bSheath) 
		end
		nSchoolAniId = LoginCustomRole.m_tSchoolAni[szSchoolType][szSex]
	end
	
	if nChar == nOldChar and szSchoolType == szOldSchoolType then
		fnUpdateModel(false)
		if szSchoolType then
			LoginSingleRole.BeginPlaySeqAni(nRoleType, {{nAniID = LoginCustomRole.m_tSchoolIdleAni[szSchoolType], szType="loop"}})
		end
		return
	end
	
	if nOldChar then
		local nOldRoleType = LoginCustomRole.m_aChar[nOldChar]
		if LoginCustomRole.m_nModelType ~= nOldRoleType or LoginCustomRole.m_szModelSchool ~= szOldSchoolType then
			if szOldSchoolType then
				LoginCustomRole.ShowSchoolEquip(szOldSchoolType, nOldRoleType) 
			else
				LoginCustomRole.UpdateSelection(nOldRoleType) 
			end
			LoginCustomRole.m_nModelType = nOldRoleType
			LoginCustomRole.m_szModelSchool = szOldSchoolType
		end
	end
	
	local fnPickWeapon = function()
		LoginCustomRole.PlaySheath(nRoleType, szSchoolType, false);
	end
	
	local nJumpInAniID = LoginCustomRole.GetJumpAni(szSchoolType, nRoleType)
	local aJumpInAniID = {{nAniID=nJumpInAniID}}
	local nWeaponType = LoginCustomRole.GetWeaponType(szSchoolType)
	local tWeaponAni  = LoginCustomRole.m_tWeaponAni[nWeaponType][szSex]
	if tWeaponAni then
		if nSchoolAniId then
			aJumpInAniID[1].fnAction=fnPickWeapon
			table.insert(aJumpInAniID, {nAniID = nSchoolAniId,})
			table.insert(aJumpInAniID, {nAniID = LoginCustomRole.m_tSchoolIdleAni[szSchoolType],  fTweenTime=200, szType="loop"})
		else
			table.insert(aJumpInAniID, {nAniID = tWeaponAni.Pick[1], fnAction=fnPickWeapon})
			table.insert(aJumpInAniID, {nAniID = tWeaponAni.Pick[2],})
			table.insert(aJumpInAniID, {nAniID = tWeaponAni.Pick[3], fTweenTime=200, szType="loop"} )
		end
	else
		table.insert(aJumpInAniID, {nAniID=30, szType="loop"} )
	end
	
	if not nOldChar then
		fnUpdateModel(true)
		LoginSingleRole.BeginPlaySeqAni(nRoleType, aJumpInAniID)
	else
		local nOldRoleType = LoginCustomRole.m_aChar[nOldChar]
		local _, nJumpOutAniID = LoginCustomRole.GetJumpAni(szOldSchoolType, nOldRoleType)
		local aJumpOutAni = {{nAniID=nJumpOutAniID}}
		
		LoginCustomRole.PlaySheath(nOldRoleType, szOldSchoolType, true);
		aJumpOutAni[1].fnAction=function() 
				fnUpdateModel(true)
				LoginSingleRole.BeginPlaySeqAni(nRoleType, aJumpInAniID)
		end
		
		LoginSingleRole.BeginPlaySeqAni(nOldRoleType, aJumpOutAni)
	end
end;

UpdateSkillCD=function(frame)
	local nStartTime, nTotal = LoginSingleRole.GetSkillCD()
	if not nStartTime then
		if LoginCustomRole.nSkillCDLeft and LoginCustomRole.nSkillCDLeft ~= 0 then
			local hSkill = frame:Lookup("Wnd_InformationDown", "Handle_Skill")
			for i=1, 4, 1 do
				local box = hSkill:Lookup("Box_SkillIcon"..i)
				if not box:IsEmpty() then
					box:SetObjectCoolDown(0)
					box:SetObjectSparking(1)
				end
			end
			LoginCustomRole.nSkillCDLeft = 0
		end
		return
	end
	
	local nLeft = GetTickCount() - nStartTime
	LoginCustomRole.nSkillCDLeft = nLeft
	local hSkill = frame:Lookup("Wnd_InformationDown", "Handle_Skill")
	for i=1, 4, 1 do
		local box = hSkill:Lookup("Box_SkillIcon"..i)
		if not box:IsEmpty() then
			if nLeft == 0 and nTotal == 0 then
				if box:IsObjectCoolDown() then
					box:SetObjectCoolDown(0)
					box:SetObjectSparking(1)
				end
			else
				box:SetObjectCoolDown(1)
				box:SetCoolDownPercentage(nLeft / nTotal)
			end
		end
	end
end;

UpdateSchoolData=function(frame)
	if not LoginCustomRole.m_szSchoolType then
		return
	end
	
	local tParam = LoginCustomRole.tSchoolParam[LoginCustomRole.m_szSchoolType]
	
	--Info up==================================
	local hWndUp = frame:Lookup("Wnd_InformationUp")
	local imgSchool = hWndUp:Lookup("", "Image_TitleBg2")
	imgSchool:FromUITex(tParam.szSchoolImage, tParam.nSchoolFrame)
	
	for i=1, 5, 1 do
		if i <= tParam.nHard then
			hWndUp:Lookup("", "Handle_Easy/Image_Hard"..i):SetFrame(22)
		else
			hWndUp:Lookup("", "Handle_Easy/Image_Hard"..i):SetFrame(13)
		end
	end
	
	--info down =========================================
	local hWndDown = frame:Lookup("Wnd_InformationDown")
	local hHandle = hWndDown:Lookup("", "Handle_Content")
	hHandle:Clear()
	hHandle:AppendItemFromString(tParam.szIntroduce)
	hHandle:FormatAllItemPos();
	
	local hSkill = hWndDown:Lookup("", "Handle_Skill")
	for i=1, 4, 1 do
		local box = hSkill:Lookup("Box_SkillIcon"..i)
		if tParam["dwSkillID"..i] ~= 0 then
			box:SetObject(UI_OBJECT_SKILL, tParam["dwSkillID"..i], 1)
			box:SetObjectIcon(Table_GetSkillIconID(tParam["dwSkillID"..i], 1))
		end
	end
	
	hWndDown:Lookup("", "Handle_Route1/Text_RouteTitle1"):SetText(tParam.szRoute1Name)
	hWndDown:Lookup("", "Handle_Route2/Text_RouteTitle2"):SetText(tParam.szRoute2Name)
	
	local imgSchool = hWndDown:Lookup("", "Handle_Route1/Image_Route1")
	imgSchool:FromUITex(tParam.szRoute1Image, tParam.nRoute1Frame)
	
	imgSchool = hWndDown:Lookup("", "Handle_Route2/Image_Route2")
	imgSchool:FromUITex(tParam.szRoute2Image, tParam.nRoute2Frame)
	
end;

GetWeaponType=function(szSchoolType)
	local nWeaponType = WEAPON_DETAIL.SWORD
	if not szSchoolType then
		nWeaponType = g_tGlue.tWeaponType[LoginCustomRole.m_nWeapon]
	else
		nWeaponType = LoginCustomRole.m_tSchoolWeaponType[szSchoolType]
	end
	return nWeaponType
end;

PlaySheath=function(nRoleType, szSchoolType, bSheath, bBigSword)
	local szSex = LoginCustomRole.GetRoleSex(nRoleType)
	local aRoleEquip = {}
	local nWeaponType = WEAPON_DETAIL.SWORD
	if not szSchoolType then
		aRoleEquip["RoleType"]=nRoleType
		aRoleEquip["FaceStyle"]=g_tGlue.tFace[nRoleType][LoginCustomRole.m_nFace]
		aRoleEquip["HairStyle"]=g_tGlue.tHair[nRoleType][LoginCustomRole.m_nHair][LoginCustomRole.m_nBang][LoginCustomRole.m_nPlait]
		aRoleEquip["ChestStyle"]=g_tGlue.tDress[nRoleType][LoginCustomRole.m_nDress][1]
		aRoleEquip["ChestColor"]=g_tGlue.tDress[nRoleType][LoginCustomRole.m_nDress][2]
		aRoleEquip["BootsStyle"]=g_tGlue.tBoots[nRoleType][LoginCustomRole.m_nBoots][1]
		aRoleEquip["BootsColor"]=g_tGlue.tBoots[nRoleType][LoginCustomRole.m_nBoots][2]
		aRoleEquip["BangleStyle"]=g_tGlue.tBangle[nRoleType][LoginCustomRole.m_nBangle][1]
		aRoleEquip["BangleColor"]=g_tGlue.tBangle[nRoleType][LoginCustomRole.m_nBangle][2]
		aRoleEquip["WaistStyle"]=g_tGlue.tWaist[nRoleType][LoginCustomRole.m_nWaist][1]
		aRoleEquip["WaistColor"]=g_tGlue.tWaist[nRoleType][LoginCustomRole.m_nWaist][2]
		aRoleEquip["WeaponStyle"]=g_tGlue.tWeapon[nRoleType][LoginCustomRole.m_nWeapon]
		
		nWeaponType = g_tGlue.tWeaponType[LoginCustomRole.m_nWeapon]
	else
	    local tSchoolEquip = LoginCustomRole.m_tSchoolEquip[szSchoolType]
		aRoleEquip = clone(tSchoolEquip)
		
		aRoleEquip["RoleType"] = nRoleType
		aRoleEquip["FaceStyle"] = g_tGlue.tFace[nRoleType][LoginCustomRole.m_nFace]
		if szSchoolType ~= "sl" then
			aRoleEquip["HairStyle"] = g_tGlue.tHair[nRoleType][LoginCustomRole.m_nHair][LoginCustomRole.m_nBang][LoginCustomRole.m_nPlait]
		end
		
		nWeaponType = LoginCustomRole.m_tSchoolWeaponType[szSchoolType]
		
		if bBigSword then
			nWeaponType = WEAPON_DETAIL.BIG_SWORD 
		end
	end
	
	LoginSingleRole.UpdateModel(aRoleEquip, szSchoolType, bSheath, nWeaponType, bBigSword)
end;

SelectKungfuID=function(szSchoolType)
	local tParam = LoginCustomRole.tSchoolParam[szSchoolType]
	LoginCustomRole.m_nKungfuID = tParam.dwKungfuIndex
end;

CheckBodyOrSchool=function(hCheckBox)
	local frame = hCheckBox:GetRoot()
	local szName = hCheckBox:GetName()
	
	if LoginCustomRole.m_tCenterImage[szName] then
		LoginCustomRole.m_nChar = LoginCustomRole.m_tCenterImage[szName]
		
		local bIniting = frame.bIniting
		frame.bIniting = true
		local hWndBody = frame:Lookup("WndType_Body")
		for szCheckBox, nChar in pairs(LoginCustomRole.m_tBodyCheckBox) do
			local hCheck = hWndBody:Lookup(szCheckBox)
			if LoginCustomRole.m_nChar == nChar then
				hCheck:Check(true)
				LoginCustomRole.CheckBodyOrSchool(hCheck)
			else
				hCheck:Check(false)
			end
		end
		frame.bIniting = bIniting
		
		LoginCustomRole.PlayCenterUIAni(frame, "leave", this)
		
		return true
	end
	
	if LoginCustomRole.m_tBodyCheckBox[szName] then
		local nOldChar, szOldSchoolType = LoginCustomRole.m_nChar, LoginCustomRole.m_szSchoolType
		
		local hWndBody = frame:Lookup("WndType_Body")
		for szCheckBox, nChar in pairs(LoginCustomRole.m_tBodyCheckBox) do
			if szCheckBox == szName then
				LoginCustomRole.m_nChar = nChar
				LoginCustomRole.UpdateBodyShow(frame, true);
				LoginCustomRole.UpdateSchoolShow(frame, true);
			else
				hWndBody:Lookup(szCheckBox):Check(false)
			end
		end
		
		if not LoginCustomRole.m_szSchoolType and LoginCustomRole.bCorrentSide then
			LoginCustomRole.PlayJumpIn(LoginCustomRole.m_nChar, LoginCustomRole.m_szSchoolType, nOldChar, szOldSchoolType)
		end
		
		local hWndSchool = frame:Lookup("WndType_School")
		local szSex = LoginCustomRole.GetRoleSex(LoginCustomRole.m_aChar[LoginCustomRole.m_nChar])
		if szSex == "male" then
			hWndSchool:Lookup("CheckBox_SL"):Enable(true)
			hWndSchool:Lookup("CheckBox_QX"):Enable(false)
			if LoginCustomRole.m_szSchoolType == "qx" then
				LoginCustomRole.m_szSchoolType = nil
				hWndSchool:Lookup("CheckBox_WH"):Check(true)
			end
		else
			hWndSchool:Lookup("CheckBox_SL"):Enable(false)
			hWndSchool:Lookup("CheckBox_QX"):Enable(true)
			if LoginCustomRole.m_szSchoolType == "sl" then
				LoginCustomRole.m_szSchoolType = nil
				hWndSchool:Lookup("CheckBox_WH"):Check(true)
			end
		end
		
		if LoginCustomRole.m_szSchoolType then
			LoginCustomRole.PlayJumpIn(LoginCustomRole.m_nChar, LoginCustomRole.m_szSchoolType, nOldChar, szOldSchoolType)
		end
		return true
	end

	if LoginCustomRole.m_tSchoolCheckBox[szName] then
		local nOldChar, szOldSchoolType = LoginCustomRole.m_nChar, LoginCustomRole.m_szSchoolType
		local hWnd = frame:Lookup("WndType_School")
		for szCheckBox, m_szSchoolType in pairs(LoginCustomRole.m_tSchoolCheckBox) do
			if szCheckBox == szName then
				LoginCustomRole.m_szSchoolType = m_szSchoolType
				LoginCustomRole.bInfoUpAni = false
				LoginCustomRole.bInfoDownAni = false
				
				LoginCustomRole.UpdateSchoolInfoShow(frame);
				
				LoginCustomRole.UpdateSchoolData(frame)
				
				LoginCustomRole.PlayJumpIn(LoginCustomRole.m_nChar, m_szSchoolType, nOldChar, szOldSchoolType)
				
				if not frame.bIniting then
					LoginCustomRole.SelectKungfuID(m_szSchoolType)
				end
			else
				hWnd:Lookup(szCheckBox):Check(false)
			end
		end
		return true
	end
	return false
end;

OnRButtonDown=function()
	local szName = this:GetName()
	if szName == "LoginCustomRole" then 
		LoginSingleRole.OnSceneRButtonDown()
		return true
	end
	return false
end;

OnRButtonUp=function()
	local szName = this:GetName()
	if szName == "LoginCustomRole" then 
		return LoginSingleRole.OnSceneRButtonUp()
	else
		return false
	end
end;

OnLButtonDown=function()
	local szName = this:GetName()
	if szName == "Btn_TurnLeft" then
		LoginSingleRole.m_bTurnLeft = true
		LoginSingleRole.m_bTurnRight = false
	elseif szName == "Btn_TurnRight" then
		LoginSingleRole.m_bTurnLeft = false
		LoginSingleRole.m_bTurnRight = true
	elseif szName == "LoginCustomRole" then
		return LoginSingleRole.OnSceneLButtonDown()
    end
end;

OnLButtonUp=function()
	local szName = this:GetName()
	if szName == "Btn_TurnLeft" then
		LoginSingleRole.m_bTurnLeft = false
	elseif szName == "Btn_TurnRight" then
		LoginSingleRole.m_bTurnRight = false
	end
end;

OnLButtonClick=function()
	local szName = this:GetName()
	local nRoleType = LoginCustomRole.m_aChar[LoginCustomRole.m_nChar]
	
	if szName == "Btn_Back" then
		LoginCustomRole.StepPrev()
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return true
	elseif szName == "Btn_Next" then
		LoginCustomRoleNext.StepNext(LoginCustomRole.m_nChar, LoginCustomRole.m_szSchoolType, LoginCustomRole.m_nKungfuID);
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return true
	
	elseif szName == "Btn_ZoomIn" then
		LoginSingleRole.SetCameraRadius(LoginSingleRole.MIN_RADIUS)
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return true
	elseif szName == "Btn_ZoomOut" then
		LoginSingleRole.SetCameraRadius(LoginSingleRole.MAX_RADIUS)
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		return true
	elseif szName == "LoginCustomRole" then
		return LoginSingleRole.OnSceneLButtonUp()
	else
		return false
	end
end;

OnCheckBoxCheck=function()
	local szName = this:GetName()
	local frame  = this:GetRoot();
	
	if frame.bIniting then
		return
	end
	
	if LoginCustomRole.m_tSchoolCheckBox[szName] then
		PlaySound(SOUND.UI_SOUND, g_sound.ButtonDown)
	end
	
	if LoginCustomRole.m_tBodyCheckBox[szName] then
		PlaySound(SOUND.UI_SOUND, g_sound.Fly)
	end
	
	local nRet = LoginCustomRole.CheckBodyOrSchool(this)
	if nRet then
		return
	end
end;

OnFrameKeyDown=function()
	local szKey = GetKeyName(Station.GetMessageKey())
	if szKey == "Esc" then
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
		LoginCustomRole.StepPrev()
		return 1
	elseif szKey == "Enter" then
		if Station.Lookup("Topmost/LoginCustomRole/WndNext"):IsVisible() then
			PlaySound(SOUND.UI_SOUND, g_sound.Button)
			LoginCustomRoleNext.StepNext(LoginCustomRole.m_nChar, LoginCustomRole.m_szSchoolType, LoginCustomRole.m_nKungfuID)
		end
		return 1
	end
	
	return 0
end;

OnMouseWheel=function()
	return LoginSingleRole.OnMouseWheel()
end;
--LoginCustomRole.UpdateSelection()
UpdateSelection=function(nRoleType, bSheath)
	--注意：登录选人界面的Face和Head的RepresentID是拼起来用的，因此两个ID均不可超过255
	
	local aRoleEquip = {}
	
	aRoleEquip["RoleType"]=nRoleType
	aRoleEquip["FaceStyle"]=g_tGlue.tFace[nRoleType][LoginCustomRole.m_nFace]
	aRoleEquip["HairStyle"]=g_tGlue.tHair[nRoleType][LoginCustomRole.m_nHair][LoginCustomRole.m_nBang][LoginCustomRole.m_nPlait]
	aRoleEquip["ChestStyle"]=g_tGlue.tDress[nRoleType][LoginCustomRole.m_nDress][1]
	aRoleEquip["ChestColor"]=g_tGlue.tDress[nRoleType][LoginCustomRole.m_nDress][2]
	aRoleEquip["BootsStyle"]=g_tGlue.tBoots[nRoleType][LoginCustomRole.m_nBoots][1]
	aRoleEquip["BootsColor"]=g_tGlue.tBoots[nRoleType][LoginCustomRole.m_nBoots][2]
	aRoleEquip["BangleStyle"]=g_tGlue.tBangle[nRoleType][LoginCustomRole.m_nBangle][1]
	aRoleEquip["BangleColor"]=g_tGlue.tBangle[nRoleType][LoginCustomRole.m_nBangle][2]
	aRoleEquip["WaistStyle"]=g_tGlue.tWaist[nRoleType][LoginCustomRole.m_nWaist][1]
	aRoleEquip["WaistColor"]=g_tGlue.tWaist[nRoleType][LoginCustomRole.m_nWaist][2]
	aRoleEquip["WeaponStyle"]=g_tGlue.tWeapon[nRoleType][LoginCustomRole.m_nWeapon]
	
	local nWeaponType = g_tGlue.tWeaponType[LoginCustomRole.m_nWeapon]
	LoginSingleRole.UpdateModel(aRoleEquip, nil, bSheath, nWeaponType)
end;

OnMouseEnter=function()
	local szName = this:GetName()
	
	if LoginCustomRole.m_tBodyCheckBox[szName] or LoginCustomRole.m_tSchoolCheckBox[szName] then
		if not this:IsCheckBoxChecked() then
			PlaySound(SOUND.UI_SOUND, g_sound.Hover)
		end
	end
end;

OnItemMouseEnter=function()
	local szName = this:GetName()
	for i=1, 4, 1 do
		if szName == "Box_SkillIcon"..i then
			this:SetObjectMouseOver(1)
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			local dwSkillID, dwSkillLevel = this:GetObjectData()
			local szSkillName = Table_GetSkillName(dwSkillID, dwSkillLevel)
			OutputTip(GetFormatText(szSkillName),  400,{x, y, w, h})
			return
		end
	end
	
	if LoginCustomRole.m_tCenterImage[szName] and not LoginCustomRole.bPlaying then
		this:Lookup(1):Show()
		local nCount = this:GetItemCount() - 1
		for i=0, nCount, 1 do
			local hImage = this:Lookup(i)
			
			hImage:SetSize(hImage.fInitW + 20, hImage.fInitH + 30)
			hImage:SetAbsPos(hImage.fInitX - 10, hImage.fInitY - 15)
		end
		PlaySound(SOUND.UI_SOUND, g_sound.Hover)
		--LoginCustomRole.PlayCenterUIAni(this:GetRoot(), "mouse", this)
		---LoginCustomRole.CheckBodyOrSchool(this)
	end
end;

OnItemMouseLeave=function()
	local szName = this:GetName()
	for i=1, 4, 1 do
		if szName == "Box_SkillIcon"..i then
			this:SetObjectMouseOver(0)
			HideTip()
			break;
		end
	end
	if LoginCustomRole.m_tCenterImage[szName] then
		HideTip()
		this:Lookup(1):Hide()
		local nCount = this:GetItemCount() - 1
		for i=0, nCount, 1 do
			local hImage = this:Lookup(i)
			hImage:SetSize(hImage.fInitW, hImage.fInitH )
			hImage:SetAbsPos(hImage.fInitX, hImage.fInitY)
		end
	end
end;

OnItemLButtonDown=function()
	if this:GetType() == "Box" then
		this:SetObjectStaring(false)
		this:SetObjectPressed(1)
	end
end;

OnItemLButtonUp=function()
	if this:GetType() == "Box" then
		this:SetObjectPressed(0)
	end
end;

OnItemLButtonClick=function()
	local szName = this:GetName()
	for i=1, 4, 1 do
		if szName == "Box_SkillIcon"..i and not this:IsEmpty() and not this:IsObjectCoolDown() then
			LoginCustomRole.PlaySkillAni(i)
			break;
		end
	end
	
	if LoginCustomRole.m_tCenterImage[szName] then
		LoginCustomRole.CheckBodyOrSchool(this)
	end
end;

OnItemLButtonDBClick=function()
	if Station.Lookup("Topmost/LoginCustomRole/WndNext/Btn_Next"):IsEnabled() then
		Login.StepNext()
	end
end;

ShowSchoolEquip = function(szSchoolName, nRoleType, bSheath)
	if not nRoleType then
		nRoleType = LoginCustomRole.m_aChar[LoginCustomRole.m_nChar]
	end
	
    local tSchoolEquip = LoginCustomRole.m_tSchoolEquip[szSchoolName]
    
    tSchoolEquip["RoleType"] = nRoleType
	tSchoolEquip["FaceStyle"] = g_tGlue.tFace[nRoleType][LoginCustomRole.m_nFace]
	if szSchoolName ~= "sl" then
	    tSchoolEquip["HairStyle"] = g_tGlue.tHair[nRoleType][LoginCustomRole.m_nHair][LoginCustomRole.m_nBang][LoginCustomRole.m_nPlait]
	end
    
	local nWeaponType = LoginCustomRole.m_tSchoolWeaponType[szSchoolName]
	LoginSingleRole.UpdateModel(tSchoolEquip, szSchoolName, bSheath, nWeaponType)
end;

GetRoleSex = function(nRoleType)
    if nRoleType == ROLE_TYPE.STANDARD_MALE or
         nRoleType == ROLE_TYPE.STRONG_MALE or
         nRoleType == LITTLE_BOY then
        return "male"
    else
        return "female"
    end
end;

PreloadAllRes = function(nRoleType)
	LoginCustomRole.PreloadRes(ROLE_TYPE.STANDARD_MALE)
	LoginCustomRole.PreloadRes(ROLE_TYPE.STANDARD_FEMALE)
	LoginCustomRole.PreloadRes(ROLE_TYPE.LITTLE_GIRL)
end;

PreloadRes = function(nRoleType)
	LoginCustomRole.UpdateSelection(nRoleType)
	for _, szSchoolType in pairs(LoginCustomRole.m_tSchoolCheckBox) do
		LoginCustomRole.ShowSchoolEquip(szSchoolType, nRoleType)
	end
end;
};
