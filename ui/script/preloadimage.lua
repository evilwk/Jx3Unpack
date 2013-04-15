local lc_bPreLoadImage = false
local lc_tLoadFailImage = {}
local lc_dwCurrentMapID

local szIconPath = "\\ui\\scheme\\case\\image_preload.txt"
local szIconImage = "\\ui\\image\\icon\\" 
local lc_tLoadMapImage = {}
local lc_tLoadFailMapImage = {}

local Title = 
{
	{f = "p", t = "szFile"},
	{f = "i", t = "bIcon"},
	{f = "s", t = "szDesc"},
}
RegisterUITable("Image_PreLoad", szIconPath, Title);

local function Table_GetMapImagesPath(dwMapID)
	local tMap = g_tTable.MapList:Search(dwMapID)
	if tMap then
		return tMap.szImagesPath
	end
end

local function UnloadMapImages(dwMapID)
	if not UnloadUIImage then
		return
	end
	
	if not lc_tLoadMapImage[dwMapID] then
		Trace("UnloadMapImages: already unload or haven't ever loaded")
		return
	end
	
	assert(lc_dwCurrentMapID == dwMapID)
	
	local szPath = ""
	local szKey = lc_tLoadMapImage[dwMapID]
	local nRow = g_tTable[szKey]:GetRowCount()
	for i = 2, nRow do
		local tLine = g_tTable[szKey]:GetRow(i)
		if tLine.szFile and tLine.szFile ~= "" then
			local szFile = string.lower(tLine.szFile)
			if tLine.bIcon == 1 then
				szPath = szIconImage..szFile
			else
				szPath = szFile
			end
			
			if not lc_tLoadFailMapImage[dwMapID][szPath] then
				UnloadUIImage(szPath)
				--Trace("unload image file:"..szFile.. " mapid:"..dwMapID)
			end
		end
	end
	
	lc_tLoadMapImage[dwMapID] = nil
	lc_tLoadFailMapImage[dwMapID] = nil
	lc_dwCurrentMapID = nil
	
	Trace("UnloadMapImages finish! mapID:"..dwMapID)
end

local function LoadMapImages(dwMapID)
	if not LoadUIImage then
		return
	end
	
	local szPath = Table_GetMapImagesPath(dwMapID)
	if not szPath or szPath == "" then
		return
	end
	
	local szKey = "image_preload_mapid_"..dwMapID
	if not IsUITableRegister(szKey) then
		RegisterUITable(szKey, szPath, Title);
	end
	
	if lc_tLoadMapImage[dwMapID] ~= nil then
		Trace("images already load! mapid:"..dwMapID)
		return
	end
	
	lc_tLoadFailMapImage[dwMapID] = {}
	
	local szPath  = ""
	local bResult = false
	local nRow = g_tTable[szKey]:GetRowCount()
    for i = 2, nRow do
        local tLine = g_tTable[szKey]:GetRow(i)
		if tLine.szFile and tLine.szFile ~= "" then
			local szFile = string.lower(tLine.szFile)
			if tLine.bIcon == 1 then
				szPath = szIconImage..szFile
			else
				szPath = szFile
			end
			
			bResult = LoadUIImage(szPath, false)
			if bResult == false then
				lc_tLoadFailMapImage[dwMapID][szPath] = true
			end
			--Trace("load image file:" .. szFile .. " mapid:"..dwMapID)
		end
    end
	lc_tLoadMapImage[dwMapID] = szKey
	lc_dwCurrentMapID = dwMapID
	
	Trace("LoadMapImage finish! mapid:"..dwMapID)
end

function UI_PreLoadImage()
	if not LoadUIImage then
		return
	end
	
	if lc_bPreLoadImage then
		Trace("UI_PreLoadImage: already load")
		return
	end
	
	local szPath  = ""
	local bResult = false
    local nRow = g_tTable.Image_PreLoad:GetRowCount()
    for i = 2, nRow do
        local tLine = g_tTable.Image_PreLoad:GetRow(i)
		if tLine.szFile and tLine.szFile ~= "" then
			local szFile = string.lower(tLine.szFile)
			if tLine.bIcon == 1 then
				szPath = szIconImage..szFile
			else
				szPath = szFile
			end
			
			bResult = LoadUIImage(szPath, false)
			if bResult == false then
				lc_tLoadFailImage[szPath] = true
			end
			--Trace("load image "..szFile.." result:"..tostring(bResult))
		end
    end
	lc_bPreLoadImage = true
	
	Trace("UI_PreLoadImage load image finish \n")
end

local function OnLuaReset()
	if not UnloadUIImage then
		return
	end
	
	if lc_dwCurrentMapID and lc_tLoadMapImage[lc_dwCurrentMapID] then 
		UnloadMapImages(lc_dwCurrentMapID)
	end
	
	if not lc_bPreLoadImage then
		Trace("OnLuaReset: already unload")
		return
	end
	
	local szPath = ""
	local nRow = g_tTable.Image_PreLoad:GetRowCount()
	for i = 2, nRow do
		local tLine = g_tTable.Image_PreLoad:GetRow(i)
		if tLine.szFile and tLine.szFile ~= "" then
			local szFile = string.lower(tLine.szFile)
			if tLine.bIcon == 1 then
				szPath = szIconImage..szFile
			else
				szPath = szFile
			end
			
			if not lc_tLoadFailImage[szPath] then
				UnloadUIImage(szPath)
				--Trace("unload image "..szFile)
			end
		end
	end
	
	lc_tLoadFailImage = {}
	lc_bPreLoadImage = false;
	
	Trace("ui unload image finish!\n")
end

local function OnPlayerEnterScene()
	local player = GetClientPlayer()
	if arg0 ~= player.dwID then
		return
	end
	
	local scene = GetClientScene();
	if not scene then
		return
	end
	
	local dwMapID = scene.dwMapID
	LoadMapImages(dwMapID)
end

local function OnPlayerLeaveScene()
	local player = GetClientPlayer()
	if not player or arg0 ~= player.dwID then
		return
	end
	
	local scene = GetClientScene();
	if not scene then
		return
	end
	
	local dwMapID = scene.dwMapID
	UnloadMapImages(dwMapID)
end

RegisterEvent("PLAYER_ENTER_SCENE", OnPlayerEnterScene)
RegisterEvent("PLAYER_LEAVE_SCENE", OnPlayerLeaveScene)

RegisterEvent("UI_LUA_RESET", OnLuaReset)