SceneMini={
	
g_aHightlightObj = nil;

OnFrameCreate=function(szSelfName)
	this:RegisterEvent("PLAYER_ENTER_SCENE")
	this:RegisterEvent("PLAYER_LEAVE_SCENE")
	this:RegisterEvent("UI_SCALED")
	SceneMini.OnEvent("UI_SCALED")
end;

OnFrameShow=function()
	SceneMini.UpdateSceneID()
end;

UpdateSceneID=function()
	local wndSelf = Station.Lookup("Normal/SceneMini")
	if not wndSelf then
		Trace("[UI SceneMini] Error get Scene when OnEvent2!")
		return
	end
	
	local wndMain = wndSelf:Lookup("Scene_Main")
	if not wndMain then
		Trace("[UI SceneMini] Error get Scene_Main when OnEvent!")
		return
	end
	
	local player = GetClientPlayer()
	if not player then
		Trace("[UI SceneMini] Error get player when OnEvent!")
		return
	end	
	
	local scene = player.GetScene()
	if not scene then
		Trace("[UI SceneMini] Error get scene when OnEvent3!")
        return
	end
	
	local p3DScene = KG3DEngine.GetScene(scene.dwID)
	wndMain:SetScene(p3DScene)
end;

ResetSceneID=function()
--	Trace("ResetSceneID()\n")
	local wndSelf = Station.Lookup("Normal/SceneMini")
	if not wndSelf then
		Trace("[UI Sence] Error get Scene when OnEvent1!")
		return
	end
	
	local wndMain = wndSelf:Lookup("Scene_Main")
	if not wndMain then
		Trace("[UI Sence] Error get Scene_Main when OnEvent!")
		return
	end
	
	wndMain:SetScene(nil)
end;

OnLButtonUp = function()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		Wnd.ToggleWindow("SceneMini")
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	end
end;

OnEvent=function(event)
	if event == "PLAYER_ENTER_SCENE" then
		if arg0 == GetClientPlayer().dwID then
			SceneMini.UpdateSceneID()
		end
	elseif event == "PLAYER_LEAVE_SCENE" then
		if arg0 == GetClientPlayer().dwID then
			SceneMini.ResetSceneID()
		end
	end
end;
}

