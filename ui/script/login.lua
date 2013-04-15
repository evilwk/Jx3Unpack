g_tLoginData = 
{
	szRegion = "",
	szServer = "",
	szAccount = "",
	bRememberAccount = false,
	bAcceptEULA = false,
	bShowLogo = true,
}

RegisterCustomData("LoginGlobal/g_tLoginData")

Login={
	m_tPreloadModels = {
		"Data\\source\\player\\M2\\部件\\Mdl\\M2_player.mdl",
		"Data\\source\\player\\M2\\部件\\M2_1002_body.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1002_hand.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1002_leg.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1001_head.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1001_plait.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1002_belt.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1001_face.mesh",
		"data\\source\\NPC_source\\A030\\模型\\A030.mdl",
		"Data\\source\\player\\M2\\部件\\M2_1002_head.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1003_head.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1004_body.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1003_body.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1004_hand.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1002_face.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1003_face.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1004_face.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1005_face.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1002_plait.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1003_plait.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1004_plait.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1005_plait.mesh",
		"data\\source\\item\\weapon\\sword\\RH_sword_017.Mesh",
		"data\\source\\item\\weapon\\spear\\RH_spear_001.Mesh",
		"data\\source\\item\\weapon\\wand\\RH_wand_002.Mesh",
		"Data\\source\\player\\M2\\部件\\M2_1004_leg.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1001_leg.mesh",
		"Data\\source\\player\\M2\\部件\\M2_2704_body.mesh",
		"Data\\source\\player\\M2\\部件\\M2_2704_hand.mesh",
		"Data\\source\\player\\M2\\部件\\M2_2704_leg.mesh",
		"Data\\source\\player\\M2\\部件\\M2_2704_belt.mesh",
		"data\\source\\item\\prop\\D010079.Mesh",
		"Data\\source\\player\\M2\\部件\\M2_2704_hat.mesh",
		"Data\\source\\player\\M2\\部件\\M2_2603_body.mesh",
		"Data\\source\\player\\M2\\部件\\M2_2603_hand.mesh",
		"Data\\source\\player\\M2\\部件\\M2_2603_leg.mesh",
		"Data\\source\\player\\M2\\部件\\M2_2603_belt.mesh",
		"data\\source\\item\\weapon\\sword\\RH_Sword_013.Mesh",
		"Data\\source\\player\\M2\\部件\\M2_2603_hat.mesh",
		"Data\\source\\player\\M2\\部件\\M2_2203_body.mesh",
		"Data\\source\\player\\M2\\部件\\M2_2203_hand.mesh",
		"Data\\source\\player\\M2\\部件\\M2_2203_leg.mesh",
		"Data\\source\\player\\M2\\部件\\M2_0000_head.mesh",
		"Data\\source\\player\\M2\\部件\\M2_2203_belt.mesh",
		"data\\source\\item\\weapon\\brush\\RH_brush_023.Mesh",
		"Data\\source\\player\\M2\\部件\\M2_2203_hat.mesh",
		"Data\\source\\player\\M2\\部件\\M2_2103_body.mesh",
		"Data\\source\\player\\M2\\部件\\M2_2103_hand.mesh",
		"Data\\source\\player\\M2\\部件\\M2_2103_leg.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1000_head.mesh",
		"Data\\source\\player\\M2\\部件\\M2_2103_belt.mesh",
		"data\\source\\item\\weapon\\wand\\RH_wand_034.Mesh",
		"Data\\source\\player\\M2\\部件\\M2_2002_body.mesh",
		"Data\\source\\player\\M2\\部件\\M2_2002_hand.mesh",
		"Data\\source\\player\\M2\\部件\\M2_2002_leg.mesh",
		"Data\\source\\player\\M2\\部件\\M2_2002_belt.mesh",
		"data\\source\\item\\prop\\D007181.Mesh",
		"data\\source\\item\\weapon\\sword\\RH_Sword_085d.Mesh",
		"Data\\source\\player\\M2\\部件\\M2_2003_hat.mesh",
		"Data\\source\\player\\M2\\部件\\M2_2301_body.mesh",
		"Data\\source\\player\\M2\\部件\\M2_2301_hand.mesh",
		"Data\\source\\player\\M2\\部件\\M2_2301_leg.mesh",
		"Data\\source\\player\\M2\\部件\\M2_2301_belt.mesh",
		"data\\source\\item\\prop\\D011011.Mesh",
		"Data\\source\\player\\M2\\部件\\M2_2301_hat.mesh",
		"Data\\source\\player\\F2\\部件\\Mdl\\F2_player.mdl",
		"Data\\source\\player\\F2\\部件\\F2_3007_body.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1001_hand.mesh",
		"Data\\source\\player\\F2\\部件\\F2_3003_leg.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1003_head.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1001_belt.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1001_face.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2301_body.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2301_hand.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2301_leg.mesh",
		"Data\\source\\player\\F2\\部件\\F2_0000_head.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2301_hat.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2002_body.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2002_hand.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2002_leg.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1001_head.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2002_belt.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2003_hat.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2503_body.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2503_hand.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2503_leg.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2503_belt.mesh",
		"data\\source\\item\\weapon\\sword\\RH_Sword_045.Mesh",
		"Data\\source\\player\\F2\\部件\\F2_2503_hat.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2704_body.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2704_hand.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2704_leg.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2704_belt.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2704_hat.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2603_body.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2603_hand.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2603_leg.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2603_belt.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2603_hat.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2203_body.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2203_hand.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2203_leg.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2203_belt.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2203_hat.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1004_head.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1006_head.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1006_plait.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1004_belt.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1001_bang.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1002_bang.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1003_bang.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1004_bang.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1006_face.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1007_face.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1008_face.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1009_face.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1010_face.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1011_face.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1012_face.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1013_face.mesh",
		"Data\\source\\player\\M2\\部件\\M2_1003_belt.mesh",
		"data\\source\\item\\weapon\\brush\\RH_brush_002.Mesh",
		"data\\source\\item\\prop\\D011001.Mesh",
		"Data\\source\\player\\F2\\部件\\F2_1003_bang.mesh",
		"Data\\source\\player\\F2\\部件\\F2_3006_hand.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1001_leg.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1001_plait.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1011_face.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1002_head.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1004_head.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1005_head.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1006_head.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1001_bang.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1002_bang.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1004_bang.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1005_bang.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1006_bang.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1007_bang.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1008_bang.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1002_plait.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1003_plait.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1004_plait.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1005_plait.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1006_plait.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1003_face.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1007_face.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1002_face.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1012_face.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1009_face.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1004_face.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1010_face.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1005_face.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1008_face.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1006_face.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1013_face.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1002_body.mesh",
		"Data\\source\\player\\F2\\部件\\F2_3003_body.mesh",
		"Data\\source\\player\\F2\\部件\\F2_3003_hand.mesh",
		"Data\\source\\player\\F2\\部件\\F2_3003_belt.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1003_belt.mesh",
		"Data\\source\\player\\F2\\部件\\F2_3006_leg.mesh",
		"data\\source\\item\\weapon\\sword\\RH_sword_003.Mesh",
		"Data\\source\\player\\F1\\部件\\Mdl\\F1.mdl",
		"Data\\source\\player\\F1\\部件\\F1_1001b_body.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1001_hand.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1001_leg.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1003_head.mesh",
		"Data\\source\\player\\F1\\部件\\F1_3003_belt.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1012_face.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1004_head.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1001_bang.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1002_bang.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1003_bang.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1004_bang.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1005_bang.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1006_bang.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1007_bang.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1001_head.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1001_plait.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1002_head.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1002_plait.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1003_plait.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1004_plait.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1005_plait.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1006_plait.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1001_face.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1002_face.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1003_face.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1004_face.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1005_face.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1006_face.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1007_face.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1008_face.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1009_face.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1010_face.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1011_face.mesh",
		"Data\\source\\player\\F1\\部件\\F1_3003_body.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1001_body.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1002_hand.mesh",
		"Data\\source\\player\\F1\\部件\\F1_3003_hand.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1001_belt.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1002_belt.mesh",
		"Data\\source\\player\\F1\\部件\\F1_3003_leg.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1000_leg.mesh",
		"data\\source\\player\\F1\\部件\\F1_2503_body.mesh",
		"data\\source\\player\\F1\\部件\\F1_2503_hand.mesh",
		"data\\source\\player\\F1\\部件\\F1_2503_leg.mesh",
		"Data\\source\\player\\F1\\部件\\F1_2503_belt.mesh",
		"Data\\source\\player\\F1\\部件\\F1_2503_hat.mesh",
		"data\\source\\player\\F1\\部件\\F1_2704_body.mesh",
		"data\\source\\player\\F1\\部件\\F1_2704_hand.mesh",
		"data\\source\\player\\F1\\部件\\F1_2704_leg.mesh",
		"Data\\source\\player\\F1\\部件\\F1_2704_belt.mesh",
		"Data\\source\\player\\F1\\部件\\F1_2704_hat.mesh",
		"data\\source\\player\\F1\\部件\\F1_2603_body.mesh",
		"data\\source\\player\\F1\\部件\\F1_2603_hand.mesh",
		"data\\source\\player\\F1\\部件\\F1_2603_leg.mesh",
		"Data\\source\\player\\F1\\部件\\F1_0000_head.mesh",
		"Data\\source\\player\\F1\\部件\\F1_2603_belt.mesh",
		"Data\\source\\player\\F1\\部件\\F1_2603_hat.mesh",
		"data\\source\\player\\F1\\部件\\F1_2203_body.mesh",
		"data\\source\\player\\F1\\部件\\F1_2203_hand.mesh",
		"data\\source\\player\\F1\\部件\\F1_2203_leg.mesh",
		"Data\\source\\player\\F1\\部件\\F1_2203_belt.mesh",
		"Data\\source\\player\\F1\\部件\\F1_2203_hat.mesh",
		"data\\source\\player\\F1\\部件\\F1_2002_body.mesh",
		"data\\source\\player\\F1\\部件\\F1_2002_hand.mesh",
		"data\\source\\player\\F1\\部件\\F1_2002_leg.mesh",
		"Data\\source\\player\\F1\\部件\\F1_2002_belt.mesh",
		"Data\\source\\player\\F1\\部件\\F1_2003_hat.mesh",
		"data\\source\\player\\F1\\部件\\F1_2301_body.mesh",
		"data\\source\\player\\F1\\部件\\F1_2301_hand.mesh",
		"data\\source\\player\\F1\\部件\\F1_2301_leg.mesh",
		"data\\source\\player\\F1\\部件\\F1_2301_hat.mesh",
		"Data\\source\\player\\M2\\部件\\M2_2402_body.mesh",
		"Data\\source\\player\\M2\\部件\\M2_2402_hand.mesh",
		"Data\\source\\player\\M2\\部件\\M2_2402_leg.mesh",
		"Data\\source\\player\\M2\\部件\\M2_2402_belt.mesh",
		"data\\source\\item\\weapon\\bow\\RH_bow_017.mdl",
		"Data\\source\\player\\M2\\部件\\M2_2402_hat.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1002_body.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1001_hand.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1001_leg.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1001_head.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1001_plait.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1001_belt.mesh",
		"Data\\source\\player\\F2\\部件\\F2_1011_face.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2402_body.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2402_hand.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2402_leg.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2402_belt.mesh",
		"Data\\source\\player\\F2\\部件\\F2_2402_hat.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1001_body.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1001_hand.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1000_leg.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1001_head.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1001_plait.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1001_belt.mesh",
		"Data\\source\\player\\F1\\部件\\F1_1001_face.mesh",
		"data\\source\\player\\F1\\部件\\F1_2402_body.mesh",
		"data\\source\\player\\F1\\部件\\F1_2402_hand.mesh",
		"data\\source\\player\\F1\\部件\\F1_2402_leg.mesh",
		"Data\\source\\player\\F1\\部件\\F1_2402_belt.mesh",
		"Data\\source\\player\\F1\\部件\\F1_2402_hat.mesh",
		"data\\source\\item\\weapon\\bow\\RH_bow_005.mdl",
		"data\\source\\item\\prop\\D011001.Mesh",
	};

	m_StateLeaveFunction = nil;
	m_szAccount = nil;
	m_szPassword = nil;
	m_szServerIP = nil;
	m_nServerPort = nil;
	m_szRoleFullName = nil;
	m_bUserdataExist = false;
	m_bPauseCameraMovement = false;
	m_bRelogin = false;
	m_bSelectServer = false;
	m_bBindCard = false;
	m_bSndaBindCard = false;

	m_aRoleEquip = {
		RoleType = 1,
		FaceStyle = 1,
		HairStyle = 1,
		ChestStyle = 1,
		BootsStyle = 1,
		BangleStyle = 1,
		WaistStyle = 1,
		WeaponStyle = 0
	};
	m_aRoleAnimation = { Idle = 100, Brief = 59 };

	SCENE_LOGO = 1;
	SCENE_CREATE_ROLE = 2;
	SCENE_SINGLE_ROLE = 3;
	SCENE_ROLE_BRIEF = 4;

EnterLogo=function()
	Login.SwitchState(Login.LeaveLogo)

	Login.ShowSdoaWindows(false)
	Wnd.OpenWindow("LoginLogo"):Show()
end;

LeaveLogo=function()
	Station.Lookup("Topmost/LoginLogo"):Hide()
end;

EnterPassword=function()
	Login.SwitchState(Login.LeavePassword)

	Login.Logout()

	Login.m_szPassword=nil
	LoginPassword.ClearPassword()

	LoginRoleList.m_nSelectIndex = 0

	LoginSingleRole.UnloadModel()

	Wnd.OpenWindow("LoginSingleRole"):Show()
	Station.Lookup("Topmost/LoginSwordLogo"):Show()
	Station.Lookup("Normal/LoginPassword"):Show()

	LoginSingleRole.m_camera:SetPerspective(0.96, nil, nil, nil)

	local _,_,_,szVersionEx = GetVersion()
	if szVersionEx == "snda" then
		if Wnd.IsUsingIme() then
			Wnd.AssociateImmContext(true)
		end

		if not Login.m_bSelectServer and SdoaIsRememberAccount() and g_tLoginData.bAcceptEULA then
			Login.ShowServerList()
			LoginServerList.AcceptSelection()
		end

		if Login.m_bSelectServer then
			LoginPassword.ShowSdoaLoginDialog()
		else
			Login.ShowServerList()	
		end
	end

	if not g_tLoginData.bAcceptEULA then
		Wnd.OpenWindow("EULAPanel")
	end
    
    local szBgMusic = Table_GetPath("LOGIN_BGM")
	PlayBgMusic(szBgMusic)
end;

LeavePassword=function()
	Wnd.OpenWindow("LoginSingleRole"):Hide()
	Station.Lookup("Topmost/LoginSwordLogo"):Hide()
	Station.Lookup("Normal/LoginPassword"):Hide()
end;

ShowServerList=function()
	Login.ShowSdoaWindows(false)
	Station.Lookup("Topmost/LoginServerList"):Show()
end;

HideServerList=function()
	Station.Lookup("Topmost/LoginServerList"):Hide()
end;

ShowSecurityCard=function()
	Station.Lookup("Topmost/SecurityCard"):Show()
end;

HideSecurityCard=function()
	Station.Lookup("Topmost/SecurityCard"):Hide()
end;

ShowLoginTokenPanel=function()
	Station.Lookup("Topmost/LoginTokenPanel"):Show()
end;

ShowLoginPhonePanel=function()
	Station.Lookup("Topmost/LoginTokenPanel"):Show()
end;

HideLoginTokenPanel=function()
	Station.Lookup("Topmost/LoginTokenPanel"):Hide()
end;

EnterCustomRole=function()
	Login.SwitchState(Login.LeaveCustomRole)
	
	LoginSingleRole.UnloadModel()
	LoginCustomRole.bEnterCustomRole = true
	LoginCustomRole.bCorrentSide = nil
	Wnd.OpenWindow("LoginSingleRole"):Show()
	Station.Lookup("Topmost/LoginCustomRole"):Show()

	if not Login.m_bPauseCameraMovement then
		Login.m_bPauseCameraMovement = true
		LoginSingleRole.PauseCameraAnimation()
	end

	LoginSingleRole.m_camera:SetPerspective(0.505, nil, nil, nil)
	SetListenerPostion(LoginSingleRole.m_nX, LoginSingleRole.m_nY, LoginSingleRole.m_nZ, LoginSingleRole.m_nYaw)
	
	Login_QueryHometownList()
end;

LeaveCustomRole=function()
	LoginCustomRole.bEnterCustomRole = false
	Wnd.OpenWindow("LoginSingleRole"):Hide()
	Station.Lookup("Topmost/LoginCustomRole"):Hide()
	Station.Lookup("Topmost/LoginCustomRoleNext"):Hide()

	if Login.m_bPauseCameraMovement then
		Login.m_bPauseCameraMovement = false
		LoginSingleRole.PauseCameraAnimation()
	end
end;

EnterCG= function()
    Login.SwitchState(Login.LeaveCG)
    LoginLogo.ShowCG(nil, false)
    Wnd.OpenWindow("LoginLogo"):Show()
end;

LeaveCG = function()
    Station.Lookup("Topmost/LoginLogo"):Hide()
end;

EnterRoleList=function()
	Login.SwitchState(Login.LeaveRoleList)

	Wnd.OpenWindow("LoginSingleRole"):Show()
	Station.Lookup("Topmost/LoginRoleList"):Show()

	if not Login.m_bPauseCameraMovement then
		Login.m_bPauseCameraMovement = true
		LoginSingleRole.PauseCameraAnimation()
	end
	
	SetListenerPostion(LoginSingleRole.m_nX, LoginSingleRole.m_nY, LoginSingleRole.m_nZ, LoginSingleRole.m_nYaw)
	LoginSingleRole.m_camera:SetPerspective(0.505, nil, nil, nil)
end;

LeaveRoleList=function()
	Wnd.OpenWindow("LoginSingleRole"):Hide()
	Station.Lookup("Topmost/LoginRoleList"):Hide()

	Wnd.CloseWindow("LoginDeleteRole")

	if Login.m_bPauseCameraMovement then
		Login.m_bPauseCameraMovement = false
		LoginSingleRole.PauseCameraAnimation()
	end
end;

EnterLoading=function()
	Login.SwitchState(Login.LeaveLoading)

	Login.BeginWait(g_tGlue.tLoginString["LOADING"])

	Wnd.OpenWindow("LoginSingleRole"):Show()

	Login.m_szAccount=nil
	Login.m_szPassword=nil

	LoginPassword.ClearAccount()
	LoginPassword.ClearPassword()

	if not Login.m_bPauseCameraMovement then
		Login.m_bPauseCameraMovement = true
		LoginSingleRole.PauseCameraAnimation()
	end

	LoginSingleRole.m_camera:SetPerspective(0.96, nil, nil, nil)

	Wnd.CloseWindow("LoginSingleRole")

	Login.UpdateSdoaTaskBarPosition("GAME")
end;

LeaveLoading=function()
	Login.EndWait()
end;

EnterGame=function()
	local _,_,_,szVersionType = GetVersion()
	if szVersionType == "snda" then
		Wnd.AssociateImmContext(false)
	end

	Login.SwitchState(Login.LeaveGame)
	
	--LoginSingleRole.m_modelMgr:Postload()
end;

LeaveGame=function()
	--LoginSingleRole.m_modelMgr:Postload()
end;

IsFirstLogin=function()
	return GetUserRoleName() == ""
end;

IsRememberAccount=function()
	local bRememberAccount = false
	local _,_,_,szVersionEx = GetVersion()
	if szVersionEx == "snda" then
		bRememberAccount = SdoaIsRememberAccount()
	else
		bRememberAccount = g_tLoginData.bRememberAccount
	end
	return bRememberAccount
end;

Logout=function()
	Login_CancelLogin()

	local _,_,_,szVersionType = GetVersion()
	if szVersionType == "snda" then
		SdoaLogout()
	end
end;

HandleResult=function(nEvent, arg)
	if nEvent == LOGIN.VERIFY_SUCCESS then
		SetUserAccount(Login.m_szAccount)
		
		local szRegionName, szServerName = LoginServerList.GetSelectedServer()
		SetUserServer(szRegionName, szServerName)
		if Login.IsRememberAccount() then
			g_tLoginData.szRegion = szRegionName
			g_tLoginData.szServer = szServerName
			g_tLoginData.szAccount = Login.m_szAccount
		else
			g_tLoginData.szRegion = ""
			g_tLoginData.szServer = ""
			g_tLoginData.szAccount = ""
		end
		FireEvent("ACCOUNT_LOGIN")
		LoginRoleList.UpdateLoginInfo()
		Login.HideServerList()
		Login.HideSecurityCard()
		Login.HideLoginTokenPanel()
	
		local nMonthEndTime, nPointLeftTime, nDayLeftTime = Login_GetTimeOfFee()
		local nCurrentTime = Login_GetLoginTime()
		local nMonthLeftTime = nMonthEndTime - nCurrentTime

		if nMonthLeftTime >= 60 and nMonthLeftTime <= 172800 and nDayLeftTime == 0 and nPointLeftTime == 0 then
			Login.ShowRechargeMessage(nMonthLeftTime, "Month")
		elseif nDayLeftTime >= 60 and nDayLeftTime <= 172800 and nMonthLeftTime <= 0 and nPointLeftTime == 0 then
			Login.ShowRechargeMessage(nDayLeftTime, "Day")
		elseif nPointLeftTime >= 60 and nPointLeftTime <= 18000 and nMonthLeftTime <= 0 and nDayLeftTime == 0 then
			Login.ShowRechargeMessage(nPointLeftTime, "Point")
		end
		
	elseif nEvent == LOGIN.HANDSHAKE_SUCCESS then
		local _,_,_,szVersionType = GetVersion()
		if szVersionType == "snda" then
			Login_SndaTokenVerify()
		else
			Login_AccountVerify();
		end
	elseif nEvent == LOGIN.NEED_MATRIX_PASSWORD then
		Login.EndWait()
		Login.ShowSecurityCard()
		SecurityCard.SetSecurityCardPosion(arg)
	elseif nEvent == LOGIN.NEED_TOKEN_PASSWORD then
		Login.EndWait()
		Login.ShowLoginTokenPanel()
	elseif nEvent == LOGIN.NEED_PHONE_PASSWORD then
		Login.EndWait()
		Login.ShowLoginPhonePanel()
	elseif nEvent == LOGIN.TOKEN_USED or
			nEvent == LOGIN.TOKEN_FAILED or 
			nEvent == LOGIN.TOKEN_EXPIRED or
			nEvent == LOGIN.TOKEN_NOTFOUND or
			nEvent == LOGIN.TOKEN_DISABLE then
		LoginTokenPanel.ShowErrorCode(g_tGlue.tTokenErrorCode[nEvent])
	elseif nEvent == LOGIN.MATRIX_FAILED then
		SecurityCard.ErrorRetry(g_tGlue.tSecuritycardError[LOGIN.MATRIX_FAILED], arg)
	elseif nEvent == LOGIN.MIBAO_SYSTEM_ERROR or nEvent == LOGIN.MATRIX_CARDINVALID or nEvent == LOGIN.MATRIX_NOTFOUND then
		SecurityCard.ErrorClose(g_tGlue.tSecuritycardError[nEvent])
	elseif nEvent == LOGIN.GET_ROLE_LIST_SUCCESS then
		Login.EndWait()

		local _,_,_,szVersionType = GetVersion()
		if szVersionType == "snda" then
			--local nZoneID = Login_GetZoneID()
			--SdoaSetAreaInfo(nZoneID, 1)
			SgdpSetUserID(Login.m_szAccount)
		end

		if Login.m_StateLeaveFunction == Login.LeavePassword
		or Login.m_StateLeaveFunction == Login.LeaveRoleList
		or Login.m_StateLeaveFunction == Login.LeaveCustomRole
		then
			if Login_GetRoleCount() == 0 then
				Login.EnterCustomRole()
			else
				Login.EnterRoleList()
			end
		end
	elseif nEvent == LOGIN.GET_ALL_ROLE_LIST_SUCCESS then
	    LoginServerList.CheckRoleCount()
    	if Login_GetRoleCount() > 0 then
	        LoginRoleList.SelectLastLoginRole()
	    end
	elseif nEvent == LOGIN.UPDATE_HOMETOWN_LIST then
		local aHomeplaceList = Login_GetHometownList()
		LoginCustomRoleNext.UpdateHomeplaceList(aHomeplaceList)
    elseif nEvent == LOGIN.CREATE_ROLE_SUCCESS then
    	Login.EndWait()
        Login.EnterCG()
        Login.m_szRoleFullName = arg3
    	LoginServerList.CheckRoleCount()
    elseif nEvent == LOGIN.REQUEST_LOGIN_GAME_SUCCESS then
		local szRoleName = Login.m_szRoleFullName
		local szAccount = Login_GetAccount()

		SetUserRoleName(szRoleName)
		SaveUserData(szAccount)
		LoginRoleList.m_szLastLoginRole = Login.m_szRoleFullName

		-- role level
		local _, _, _, nRoleLevel = Login_GetRoleInfo(nRoleIndex)
		local szRegionName, szServerName = LoginServerList.GetSelectedServer()
		Login_PostRoleLogin(szAccount, szRoleName, szRegionName, szServerName, nRoleLevel, tUrl.GamePlugReportUrl, tUrl.GamePlugReportWebPage, tUrl.NoKppReportUrl, tUrl.NoKppReportWebPage)

		local _,_,_,szVersionType = GetVersion()
		if szVersionType == "snda" then
			local re = LoginRoleList.m_aRoleEquip[LoginRoleList.m_nSelectIndex + 1]
			SdoaSetRoleInfo(szRoleName, re["RoleType"])
		end

		Login.EndWait()
		Login.EnterLoading()
		
    	Login.SendGameResolution()
    elseif nEvent == LOGIN.DELETE_ROLE_SUCCESS or nEvent == LOGIN.DELETE_ROLE_DELAY then
    	Login.EndWait()

		if Login_GetRoleCount() == 0 then
			Login.EnterCustomRole()
		else
			LoginRoleList.UpdateRoleList()
		end
		
		LoginServerList.CheckRoleCount()
	elseif nEvent == LOGIN.RENAME_NAME_ALREADY_EXIST or
		nEvent == LOGIN.RENAME_NAME_TOO_LONG or
		nEvent == LOGIN.RENAME_NAME_TOO_SHORT or
		nEvent == LOGIN.RENAME_NEW_NAME_ERROR or
		nEvent == LOGIN.RENAME_ERROR then
		LoginMessage.ShowEventMessage(nEvent)
	elseif nEvent == LOGIN.RENAME_SUCCESS then
		CloseLoginRename()
		LoginRoleList.UpdateRoleList()
	elseif nEvent == LOGIN.VERIFY_IN_GAME then
		Login.EndWait()
		Login.EnterPassword()
		LoginMessage.ShowEventMessage(nEvent)
	elseif nEvent == LOGIN.UNABLE_TO_CONNECT_SERVER or nEvent == LOGIN.SYSTEM_MAINTENANCE or nEvent == LOGIN.MISS_CONNECTION then
		--角色库相关网络异常
    	Login.EndWait()
		Login.ShowServerList()
		LoginMessage.ShowEventMessage(nEvent)
	elseif nEvent == LOGIN.REQUEST_LOGIN_GAME_OVERLOAD or nEvent == LOGIN.REQUEST_LOGIN_GAME_MAINTENANCE or nEvent == LOGIN.REQUEST_LOGIN_GAME_UNKNOWN_ERROR then
		--游戏世界相关网络异常
    	Login.EndWait()
		Login.ShowServerList()
		LoginMessage.ShowEventMessage(nEvent)
	elseif nEvent == LOGIN.GIVEUP_QUEUE_SUCCESS then
		local frameQueue = Station.Lookup("Topmost/Queue")
		frameQueue:Hide()
		Login.EnterRoleList()
	elseif nEvent == LOGIN.GIVEUP_QUEUE_ERROR then
		local frameQueue = Station.Lookup("Topmost/Queue")
		frameQueue:Hide()
		Login.EnterRoleList()
		LoginMessage.ShowEventMessage(nEvent)
	elseif nEvent == LOGIN.VERIFY_ACC_FREEZED then
		Login.EndWait()
		Login.EnterPassword()
		LoginMessage.ShowEventMessage(nEvent)
	elseif nEvent == LOGIN.VERIFY_ACC_SMS_LOCK then
		Login.EndWait()
		Login.EnterPassword()
		LoginMessage.ShowEventMessage(nEvent)
	elseif nEvent == LOGIN.VERIFY_LIMIT_ACCOUNT then
		Login.EndWait()
		Login.Logout()
		
		local _,_,_,szVersionType = GetVersion()
		if szVersionType == "snda" then
			Login.ShowLimitAccountMessage()
		else
			if arg2 == 10 or arg2 == 11 or arg2 == 12 then
				Login.BindCard()
			else
				Login.ShowLimitAccountMessage()
			end
		end
	elseif nEvent == LOGIN.VERIFY_NO_MONEY then
		Login.EndWait()
		Login.Logout()
		Login.ShowNoTimeMessage()
	else
		if nEvent == LOGIN.VERIFY_ACC_PSW_ERROR then
			LoginPassword.ClearPassword()
		end

		Login.EndWait()

		local _,_,_,szVersionType = GetVersion()
		if szVersionType == "snda" then
			Login.EnterPassword()
			Login.ShowSdoaWindows(false)
		end

		LoginMessage.ShowEventMessage(nEvent)
	end
end;

ShowLimitAccountMessage = function()
	local nWidth, nHeight = Station.GetClientSize()
	local tMsg =
	{
		x = nWidth / 2, y = nHeight / 2,
		szMessage = g_tGlue.tLoginString.VERIFY_LIMIT_ACCOUNT,
		szName = "LimitAccount",
		{
			szOption = g_tGlue.STR_BIND_INFO,
			fnAction = function() 
				local _,_,_,szVersionType = GetVersion()
				if szVersionType == "snda" then
					Login.EnterPassword()
				end

				OpenInternetExplorer(tUrl.Register, true)
			end
		},
		{
			szOption = g_tStrings.STR_HOTKEY_CANCEL,
			fnAction = function()
				local _,_,_,szVersionType = GetVersion()
				if szVersionType == "snda" then
					Login.EnterPassword()
				end
			end
		},
	}
	MessageBox(tMsg)
end;

ShowNoTimeMessage = function()
	local nWidth, nHeight = Station.GetClientSize()
	local tMsg =
	{
		x = nWidth / 2, y = nHeight / 2,
		szMessage = FormatString(g_tGlue.STR_NO_TIME_TIP, tUrl.Recharge),
		szName = "NoTimeTip",
		{
		    szOption = g_tGlue.STR_CLICK_RECHARGE,
			fnAction = function() 
				local _,_,_,szVersionType = GetVersion()
				if szVersionType == "snda" then
					Login.EnterPassword()
				end

				OpenInternetExplorer(tUrl.Recharge, true)
			end
		},
	}
	MessageBox(tMsg)
end;

ShowRechargeMessage = function(nLeftTime, szCard)
	local szTipTime = ""
	local nDay = math.floor(nLeftTime / 86400)
	local nHour = math.floor((nLeftTime % 86400) / 3600)
	local nMinute = math.floor((nLeftTime % 3600) / 60)
	
	if nDay > 0 then
		szTipTime = szTipTime..tostring(nDay)..g_tGlue.STR_TIME_DAY
	end
	if nHour > 0 then
		szTipTime = szTipTime..tostring(nHour)..g_tGlue.STR_TIME_HOUR
	end
	if nMinute > 0 then
		szTipTime = szTipTime..tostring(nMinute)..g_tGlue.STR_TIME_MINUTE
	end
		
	if szCard == "Month" then
		szTipTime = FormatString(g_tGlue.tLoginString.RECHARGE_TIP, g_tGlue.STR_MONTH_CARD, szTipTime)
	elseif szCard == "Day" then
		szTipTime = FormatString(g_tGlue.tLoginString.RECHARGE_TIP, g_tGlue.STR_DAY_CARD, szTipTime)
	elseif szCard == "Point" then
		szTipTime = FormatString(g_tGlue.tLoginString.RECHARGE_TIP, g_tGlue.STR_POINT_CARD, szTipTime)
	end
	
	local nWidth, nHeight = Station.GetClientSize()
	local tMsg =
	{
		x = nWidth / 2, y = nHeight / 2,
		szMessage = szTipTime,
		szName = "RechargeTip",
		fnAutoClose = function() return IsInLoading() end,
		{
		    szOption = g_tGlue.STR_RECHARGE,
		     fnAction = function() 
		        OpenInternetExplorer(tUrl.Recharge, true)
		     end
		},
		{szOption = g_tStrings.STR_HOTKEY_CANCEL},
	}
	MessageBox(tMsg)
end;

ShowLoginDeletedRoleMessage = function()
	local nWidth, nHeight = Station.GetClientSize()
	local tMsg =
	{
		x = nWidth / 2, y = nHeight / 2,
		szMessage = g_tGlue.STR_LOGIN_DELETED_ROLE_TIP,
		szName = "LoginDeletedRole",
		fnAutoClose = function() return Login.m_StateLeaveFunction ~= Login.LeaveRoleList end,
		{
		    szOption = g_tStrings.STR_HOTKEY_SURE,
		     fnAction = function()
				Login.BeginWait(g_tGlue.tLoginString["LOGINING"])
				Login_RoleLogin(Login.m_szRoleFullName)
		     end
		},
		{szOption = g_tStrings.STR_HOTKEY_CANCEL},
	}
	MessageBox(tMsg)
end;

BindCard = function()
	OpenInternetExplorerForBindCard(tUrl.BindCard, Login.m_szAccount, Login.m_szPassword, "2", tUrl.OfficialWebClean)
	
	local szRegionName, szServerName = LoginServerList.GetSelectedServer()
	SetUserServer(szRegionName, szServerName)
	
	Login.m_bBindCard = true
end;

SndaBindCard = function(szUrl)
	Login.EndWait()
		
	OpenInternetExplorer(szUrl, true)
	
	Login.m_bSndaBindCard = true
end;

BeginWait=function(szMessage)
	local frame=Station.Lookup("Topmost/LoginWaiting")
	frame:Lookup("Wnd_All", "Text_Message"):SetText(szMessage)
	if not frame:IsVisible() then
		frame:Show()
	end
end;

ShowSdoaWindows=function(bVisible)
	if bVisible then
		LoginPassword.ShowSdoaLoginDialog()
	else
		local _,_,_,szVersionType = GetVersion()
		if szVersionType == "snda" then
			if SdoaWinExists("igwUserLoginDialog") then
				SdoaSetWinVisible("igwUserLoginDialog", false)
			end
		end
	end
end;

EndWait=function()
	local frame = Station.Lookup("Topmost/LoginWaiting")
	if frame then
		frame:Hide()
	end
	
	Login.ShowSdoaWindows(false)
end;

Relogin=function()
	Login.m_bRelogin = true

	Login.BeginWait(g_tGlue.tLoginString["CONNECTING"])

	LoginRoleList.m_nSelectIndex = 0

	Login.SelectServer(GetUserServer())

	Login_CancelLogin()
	Login_SetGatewayAddress(Login.m_szServerIP, Login.m_nServerPort)
	Login_ConnectGateway()
end;

RequestRelogin = function()
	if g_bRequestRemoteServerListSuccess then
		Login.Relogin()
	else
		Login.bRequestRelogin = true
		LoginServerList.RequestRemoteServerList()
	end
end;

RequestLogin=function(szMsg, bShowError)
	Login.m_bRelogin = false

	if Login.m_szAccount == "" then
		Login.m_szAccount = nil
	end
	if Login.m_szPassword == "" then
		Login.m_szPassword = nil
	end
	
	if not Login.m_szPasswordLen or Login.m_szPasswordLen == 0 then
		Login.m_szPassword = nil
	end

	local _,_,_,szVersionEx = GetVersion()
	if szVersionEx == "snda" then
		Login.m_szPassword = ""
	end

	if Login.m_szAccount and Login.m_szPassword then
		if not Login.m_szServerIP or not Login.m_nServerPort then
			LoadUserData(Login.m_szAccount)
		end

		if not g_bRequestRemoteServerListSuccess then
			Log("RequestLogin")
		end
		local szRegionName, szServerName = LoginServerList.GetSelectedServer()
		Login.SelectServer(szRegionName, szServerName)

		Login.BeginWait(szMsg)

		Login_CancelLogin()
		Login_SetGatewayAddress(Login.m_szServerIP, Login.m_nServerPort)
		Login_SetAccountPassword(Login.m_szAccount, Login.m_szPassword, szVersionEx ~= "snda")
		Login_ConnectGateway()
	elseif bShowError and szVersionEx ~= "snda" then
		if not Login.m_szAccount and not Login.m_szPassword then
			LoginMessage.ShowMessage(g_tGlue.tLoginString["ACCOUNT_PASSWORD_CANNOT_EMPTY"])
		elseif not Login.m_szAccount then
			LoginMessage.ShowMessage(g_tGlue.tLoginString["ACCOUNT_CANNOT_EMPTY"])
		elseif not Login.m_szPassword then
			LoginMessage.ShowMessage(g_tGlue.tLoginString["PASSWORD_CANNOT_EMPTY"])
		end
	end
end;

StepPrev=function()
	--PlaySound(SOUND.UI_SOUND, g_sound.Button)
	if Login.m_StateLeaveFunction == Login.LeaveLogo then
		ExitGame()
	elseif Login.m_StateLeaveFunction == Login.LeavePassword then
		ExitGame()
	elseif Login.m_StateLeaveFunction == Login.LeaveCustomRole then
		if Login_GetRoleCount() == 0 then
			Login.EnterPassword()
		else
			Login.EnterRoleList()
		end
	elseif Login.m_StateLeaveFunction == Login.LeaveRoleList then
		FireEvent("ACCOUNT_LOGOUT")
		Login.EnterPassword()
	elseif Login.m_StateLeaveFunction == Login.LeaveLoading then
		--NOTE: 不能进入上一步
	elseif Login.m_StateLeaveFunction == Login.LeaveGame then
		--NOTE: 不能进入上一步
	end
end;

StepNext=function()
	if Login.m_StateLeaveFunction == Login.LeaveLogo then
		Login.EnterPassword()
	elseif Login.m_StateLeaveFunction == Login.LeavePassword then
		LoginPassword.SaveAccountAndPassword()

		if Login.IsRememberAccount() and IsUserDataExist(Login.m_szAccount) or Login.m_bSelectServer then
		    Login.RequestLogin(g_tGlue.tLoginString["CONNECTING"], true)
		else
			Login.ShowServerList()
		end
	elseif Login.m_StateLeaveFunction == Login.LeaveCustomRole then
		local szRoleName, nRoleName = LoginCustomRoleNext.GetRoleName()

		if Login.CheckRoleName(nRoleName, szRoleName) then
			Login.BeginWait(g_tGlue.tLoginString["CRATING_ROLE"])

			local szRoleName = Station.Lookup("Topmost/LoginCustomRoleNext/WndRoleName/Edit_Name"):GetText()

			if szRoleName then
				Login.m_szRoleFullName = szRoleName
				g_FirstLogin = true
			    local nRoleType = LoginCustomRole.m_aChar[LoginCustomRoleNext.m_nChar]
				local aRoleEquip = LoginCustomRoleNext.GetRoleEquip()
				local dwMapID, nMapCopyIndex = LoginCustomRoleNext.GetSelectedHomeplaceInfo()
				local nKungfuID = LoginCustomRoleNext.m_nKungfuID
				Login_CreateRole(
                    Login.m_szRoleFullName, nRoleType, dwMapID, nMapCopyIndex,
                    aRoleEquip["FaceStyle"],        aRoleEquip["HairStyle"],
                    aRoleEquip["HelmStyle"],        aRoleEquip["HelmColor"],        aRoleEquip["HelmEnchant"],
                    aRoleEquip["ChestStyle"],       aRoleEquip["ChestColor"],       aRoleEquip["ChestEnchant"],
                    aRoleEquip["WaistStyle"],       aRoleEquip["WaistColor"],       aRoleEquip["WaistEnchant"],
                    aRoleEquip["BangleStyle"],	    aRoleEquip["BangleColor"],	    aRoleEquip["BangleEnchant"],
                    aRoleEquip["BootsStyle"],       aRoleEquip["BootsColor"],
                    aRoleEquip["WeaponStyle"],	    aRoleEquip["WeaponColor"], aRoleEquip["WeaponEnchant1"],   aRoleEquip["WeaponEnchant2"],
                    aRoleEquip["BigSwordStyle"],	    aRoleEquip["BigSwordColor"], aRoleEquip["BigSwordEnchant1"],   aRoleEquip["BigSwordEnchant2"],
                    aRoleEquip["BackExtend"],	    aRoleEquip["WaistExtend"], nKungfuID,
                    aRoleEquip["HorseStyle"],       aRoleEquip["HorseAdornment1"],	aRoleEquip["HorseAdornment2"],
                    aRoleEquip["HorseAdornment3"],  aRoleEquip["HorseAdornment4"],  aRoleEquip["Reserved"]
                )
			end
		end
    elseif Login.m_StateLeaveFunction == Login.LeaveCG then
        if Login.m_szRoleFullName and Login.m_szRoleFullName ~= "" then
            Login.BeginWait(g_tGlue.tLoginString["LOGINING"])
            Login_RoleLogin(Login.m_szRoleFullName)
        end
	elseif Login.m_StateLeaveFunction == Login.LeaveRoleList then
		local re = LoginRoleList.m_aRoleEquip[LoginRoleList.m_nSelectIndex + 1]
		if re then
			Login.m_szRoleFullName = re["RoleName"]
			if Login.m_szRoleFullName and Login.m_szRoleFullName ~= "" then
				if re["DeleteTime"] ~= 0 then
					Login.ShowLoginDeletedRoleMessage()
				else
					Login.BeginWait(g_tGlue.tLoginString["LOGINING"])			
					Login_RoleLogin(Login.m_szRoleFullName)
				end
			end
		else
			Login.EnterCustomRole()
		end
	elseif Login.m_StateLeaveFunction == Login.LeaveLoading then
		Login.BeginWait(g_tGlue.tLoginString["ENTERING_GAME"])
	elseif Login.m_StateLeaveFunction == Login.LeaveGame then
		--NOTE: 没有下一步
	end
end;

CheckRoleName = function(nRoleName, szRoleName)
	local _,_,szVersionLineName,_ = GetVersion()

	if nRoleName < 2 then
		LoginMessage.ShowMessage(g_tGlue.tLoginString["FULL_NAME_LENGHT_INVALID"])
		return false
	elseif not szRoleName then
		LoginMessage.ShowMessage(g_tGlue.tLoginString["FULL_NAME_CANNOT_EMPTY"])
		return false
	elseif szVersionLineName == "zhcn" and not IsSimpleChineseString(szRoleName) then
		LoginMessage.ShowMessage(g_tGlue.tLoginString["FULL_NAME_CHARACTER_INVALID"])
		return false
	end
	
	return true
end;

SendGameResolution = function()
    local szUserName = GetUserAccount()
    local tUserEnv = GetUserEnv()
    if szUserName and szUserName ~= "" and tUserEnv and tUserEnv.UUID and tUserEnv.UUID ~= "" and tUserEnv.Width and tUserEnv.Height then
        local szVga = tostring(tUserEnv.Width).."x"..tostring(tUserEnv.Height)
        szUrl = "/Client.php?"
        szUrl = szUrl.."uuid="..tUserEnv.UUID.."&username="..szUserName.."&vga="..szVga.."&type=3"
        Interaction_Send("GameResolution", tUrl.Report, szUrl, "", 80)
    end
end;

UpdateSdoaTaskBarPosition=function(szType)
	local _,_,_,szVersionEx = GetVersion()
	if szVersionEx == "snda" then
		local w, h = Station.GetClientSize(false)

		if szType == "LOGIN" then
			SdoaSetTaskBarPosition(w * 0.75, h * 0.9)
		elseif szType == "GAME" then
			SdoaSetTaskBarPosition(w - 140, h - 4)
		end
	end
end;

--------------------------------------------------------Private--------------------------------------------------------
SwitchState=function(func)
	if Login.m_StateLeaveFunction then
		Login.m_StateLeaveFunction()
	end

	Login.m_StateLeaveFunction=func
end;

SelectServer=function(szRegionName, szServerName)
	LoginServerList.SetSelectedServer(szRegionName, szServerName)

	if not g_bRequestRemoteServerListSuccess then
		Log("SelectServer")
	end
	local _, _, szIP, nPort, nAreaID, nGroupID = LoginServerList.GetSelectedServer()
	Login.m_szServerIP, Login.m_nServerPort = szIP, nPort

	if nAreaID and nGroupID then
		local _,_,_,szVersionType = GetVersion()
		if szVersionType == "snda" then
			SdoaSetAreaInfo(nAreaID, nGroupID)
		end
	end
end;

};

function Login.OnCustomDataLoaded()
	if arg0 == "LoginGlobal" then
		Login.m_szAccount = g_tLoginData.szAccount	
	end
end
RegisterEvent("CUSTOM_DATA_LOADED", Login.OnCustomDataLoaded)


