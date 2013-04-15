Debug={
	
g_nCount = 0;

OnFrameBreathe=function()
	Debug.g_nCount = Debug.g_nCount + 1
	if Debug.g_nCount < 1 then
		return
	end
	Debug.g_nCount = 0
	
	local text = this:Lookup("", "Text_Output")
	if not text then
		return
	end
	
	local player = GetClientPlayer()
	if not player then
		return
	end

	local szText = ""
	local target = nil
	
	local objtype, objid = player.GetTarget()
	if objtype == TARGET.PLAYER then
		target = GetPlayer(objid)
	elseif objtype == TARGET.NPC then
		target = GetNpc(objid)
	elseif objtype == TARGET.DOODAD then
		target = GetDoodad(objid)
	else
		return
	end
	
    local nX = target.nX
    local nY = target.nY
    local nZ = target.nZ
    local nFaceDirection = target.nFaceDirection
    
    szText = szText..objid.." <"..nX..","..nY..","..nZ.."> "..nFaceDirection.."\n"

	local player = GetClientPlayer()
    nX = player.nX
    nY = player.nY
    nZ = player.nZ
    nFaceDirection = player.nFaceDirection

    szText = szText..player.dwID.." <"..nX..","..nY..","..nZ.."> "..nFaceDirection.."\n"
    
	text:SetText(szText)
end;

}
