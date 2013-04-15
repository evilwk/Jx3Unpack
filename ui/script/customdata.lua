local CUSTOM_DATA_VERION = 1.0

local function GetVariable(szVar)
	local tVariable = _G
	for szIndex in string.gmatch(szVar, "[^%.]+") do
		if tVariable and type(tVariable) == "table" then
			tVariable = tVariable[szIndex]
		else
			tVariable = nil
			break
		end
	end
	return tVariable
end

local function SetVariable(szVar, varData)
	local tEnv = _G
	local szLastIndex = nil
	for szIndex in string.gmatch(szVar, "[^%.]+") do
		if szLastIndex then
			if tEnv == _G and (_ShieldList[szLastIndex] and type(_ShieldList[szLastIndex]) ~= "function") then
				return
			end
			if not tEnv[szLastIndex] then
				tEnv[szLastIndex] = {}
			end
			tEnv = tEnv[szLastIndex]
		end
		szLastIndex = szIndex
	end	

	if tEnv == _G and (_ShieldList[szLastIndex] and type(_ShieldList[szLastIndex]) ~= "function") then
		return
	end
	tEnv[szLastIndex] = varData
end

local function IsAddonVariable(szVar)
	local tAddon = _G["_AddOn"]
	for szIndex in string.gmatch(szVar, "[^%.]+") do
		if tAddon and rawget(tAddon, szIndex) ~= nil then
			return true
		else
			return false
		end
	end
	return false
end
--------------------------------------------------------------------------------

local tCustomDataFile = 
{
	["LoginGlobal"] = function() return "config.dat" end,
	["LoginAccount"] = function() return GetUserAccount() .. "\\config.dat" end,
--	["Region"] = function() local szRegion, _ = GetUserServer(); return GetUserAccount() .. "\\" .. szRegion .. "\\config.dat" end,
--	["Server"] = function() local szRegion, szServer = GetUserServer(); return GetUserAccount() .. "\\" .. szRegion .. "\\" .. szServer .. ".dat" end,
	["EnaterGlobal"] = function() return "customEnter.dat" end,
    ["Global"] = function() return "custom.dat" end,
	["Account"] = function() return GetUserAccount() .. "\\custom.dat" end,
	["Role"] = function() local szRegion, szServer = GetUserServer(); return GetUserAccount() .. "\\" .. szRegion .. "\\" .. szServer .. "_" .. GetUserRoleName() .. ".dat" end,
}
local tCustomDataState = {}
local tVariableList = {}
local tLoadFunction = {}

function RegisterCustomData(szVarPath)
	assert(type(szVarPath) == "string")
	local _, _, szPath, szVar = string.find(szVarPath, "(%a+)[/\\](.+)")
	if not szPath or not szVar then
		szPath = "Role"	--default
		szVar = szVarPath
	end

	assert(tCustomDataFile[szPath])
	if not tVariableList[szPath] then
		tVariableList[szPath] = {}
		tVariableList[szPath]["addon"] = {}
		tVariableList[szPath]["inside"] = {}
	end
	
	if not GetLoadingAddOnIndex then
		GetLoadingAddOnIndex = function() return -1 end
	end
	
	local nIndex = GetLoadingAddOnIndex()
	if nIndex ~= -1 then
		local tInfo = GetAddOnInfo(nIndex)
		table.insert(tVariableList[szPath]["addon"], {szVar=szVar, szAddon=tInfo.szID})
		return
	elseif IsAddonVariable(szVar) then
		table.insert(tVariableList[szPath]["addon"], {szVar=szVar, szAddon=g_tStrings.tDataSave.UNKOWN_ADDON})
		return
	end
	
	table.insert(tVariableList[szPath]["inside"], szVar)
end

function RegisterLoadFunction(funcLoad)
	table.insert(tLoadFunction, funcLoad)
end

local function GetTableString(szVar)
	local szContent = "\n[\""..szVar.."\"] = "
	local t = GetVariable(szVar)
	return szContent .. var2str(t).. ","
end

local function SaveCustomData(szPath, bLuaReset)
	assert(tCustomDataFile[szPath])
	if not tVariableList[szPath] then
		tVariableList[szPath] = {}
	end
	local szFile = tCustomDataFile[szPath]()
	
	if bLuaReset then
		ProgressSaveData_Title(g_tStrings.tDataSave.START_SAVE..szFile)
	end
	
	local tCustomData = {}
	local byCustomData = LoadDataFromFile(szFile)
	if byCustomData then
		if IsEncodedData(byCustomData) then
			byCustomData = DecodeData(byCustomData)
		end
		
		if byCustomData then
			local funcData = loadstring(byCustomData)
			if funcData then
				local tFuncEnv = {}
				setfenv(funcData, tFuncEnv)
				funcData()
				tCustomData = tFuncEnv._custom_data_
			end
		end
	end
	
	local szCustomData = "_custom_data_ = {"
	local tInfo = tVariableList[szPath]["addon"] or {}
	
	if bLuaReset then
		ProgressSaveData_Begin(g_tStrings.tDataSave.START_SAVE_ADDON, #tInfo)
	end
	
	local szTip = ""
	for nIndex, tVar in ipairs(tInfo) do
		if bLuaReset then
			szTip = g_tStrings.tDataSave.START_SAVEING_ADDON..tVar.szAddon.."("..tVar.szVar..")"
			ProgressSaveData_LoadOne(szTip, nIndex)
		end
		
		szCustomData = szCustomData .. GetTableString(tVar.szVar)
		
		if bLuaReset then
			ProgressSaveData_FinishOne(szTip, nIndex)
		end
	end
	
	local tInfo = tVariableList[szPath]["inside"] or {}
	if bLuaReset then
		ProgressSaveData_Begin(g_tStrings.tDataSave.START_SAVE_IN, #tInfo)
	end
	
	for nIndex, szVar in ipairs(tInfo) do
		if bLuaReset then
			szTip = g_tStrings.tDataSave.START_SAVEING.."("..szVar..")"
			ProgressSaveData_LoadOne(szTip, nIndex)
		end
		
		szCustomData = szCustomData .. GetTableString(szVar)
		
		if bLuaReset then
			ProgressSaveData_FinishOne(szTip, nIndex)
		end
	end
	szCustomData = szCustomData .. "\n[\"_custom_data_version_\"] = " ..CUSTOM_DATA_VERION .. ",\n}"
	
	byCustomData = EncodeData(szCustomData, true, false)
	SaveDataToFile(byCustomData, szFile)
	tCustomDataState[szPath] = "saved"
	
	if bLuaReset then
		ProgressSaveData_End(g_tStrings.tDataSave.FINISH_SAVE..szFile)
	end
	
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function DataVersionTo1_0(szPath, tData)
end

local DATA_VERSION_CONVERT = 
{
	[1.0] = DataVersionTo1_0,
}

--------------------------------------------------------------------------------

local tVersionList = {}
for nVersion, _ in pairs(DATA_VERSION_CONVERT) do
	table.insert(tVersionList, nVersion)
end
table.sort(tVersionList)

local function ConvertDataVersion(szPath, tData, nFromVersion, nToVersion)
	for _, nVersion in ipairs(tVersionList) do
		if (not nFromVersion or nVersion > nFromVersion) and nVersion <= nToVersion then
			local fnConvertor = DATA_VERSION_CONVERT[nVersion]
			if fnConvertor then
				fnConvertor(szPath, tData)
			end
		end
	end
end


local function LoadCustomData(szPath)
	assert(tCustomDataFile[szPath])
	
	local byCustomData = LoadDataFromFile(tCustomDataFile[szPath]())
	if byCustomData then
		if IsEncodedData(byCustomData) then
			byCustomData = DecodeData(byCustomData)
		end
		
		if byCustomData then
			local tCustomData = {}
			local funcData = loadstring(byCustomData)
			if funcData then
				local tFuncEnv = {}
				setfenv(funcData, tFuncEnv)
				funcData()
				tCustomData = tFuncEnv._custom_data_
			end
			
			ConvertDataVersion(szPath, tCustomData, tCustomData._custom_data_version_, CUSTOM_DATA_VERION)
			for szVar, varData in pairs(tCustomData) do
				SetVariable(szVar, varData)
			end
		end
	else
		if szPath == "Role" then
			for _, funcLoad in pairs(tLoadFunction) do
				if funcLoad and type(funcLoad) == "function" then
					funcLoad()
				end
			end
		end
	end

	tCustomDataState[szPath] = "loaded"

	local arg0bak = arg0
	arg0 = szPath
	FireEvent("CUSTOM_DATA_LOADED")
	arg0 = arg0bak
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

RegisterEvent("GAME_START", function() LoadCustomData("LoginGlobal") end)
RegisterEvent("ACCOUNT_LOGIN", function() SaveCustomData("LoginGlobal") end)

RegisterEvent("GAME_START", function() LoadCustomData("Global") end)
RegisterEvent("UI_LUA_RESET", function() SaveCustomData("Global", g_bProgressSaveData_Loaded) end)

RegisterEvent("ACCOUNT_LOGIN", function() LoadCustomData("LoginAccount") end)
RegisterEvent("PLAYER_ENTER_GAME", function() SaveCustomData("LoginAccount") end)
RegisterEvent("ACCOUNT_LOGOUT", function() SaveCustomData("LoginAccount") end)

RegisterEvent("PLAYER_ENTER_GAME", function() LoadCustomData("EnaterGlobal") end)
RegisterEvent("UI_LUA_RESET", function() SaveCustomData("EnaterGlobal", g_bProgressSaveData_Loaded) end)

RegisterEvent("PLAYER_ENTER_GAME", function() LoadCustomData("Account") end)
RegisterEvent("UI_LUA_RESET", function() SaveCustomData("Account", g_bProgressSaveData_Loaded) end)

RegisterEvent("PLAYER_ENTER_GAME", function() LoadCustomData("Role") end)
RegisterEvent("UI_LUA_RESET", function() SaveCustomData("Role", g_bProgressSaveData_Loaded) end)


local function OnGameExit()
	for szPath, szState in pairs(tCustomDataState) do
		if szState == "loaded" then
			local bLuaReset = false
			if szPath == "Role" or szPath == "Account" or szPath == "Global" then
				bLuaReset = true
			end
			SaveCustomData(szPath, (bLuaReset and g_bProgressSaveData_Loaded) )
		end
	end
end
RegisterEvent("GAME_EXIT", OnGameExit)
