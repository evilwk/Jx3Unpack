local tSubToBoxIndex = 
{
    [EQUIPMENT_SUB.HELM] = 1, -- 头部
    [EQUIPMENT_SUB.CHEST] = 2, -- 上衣
    [EQUIPMENT_SUB.BANGLE] = 3, -- 护手
    [EQUIPMENT_SUB.WAIST] = 4, -- 腰带
    [EQUIPMENT_SUB.BOOTS] = 5 -- 鞋子
}

local tExteriorSubToBoxIndex = 
{
    [EXTERIOR_INDEX_TYPE.HELM] = 1, -- 头部
    [EXTERIOR_INDEX_TYPE.CHEST] = 2, -- 上衣
    [EXTERIOR_INDEX_TYPE.BANGLE] = 3, -- 护手
    [EXTERIOR_INDEX_TYPE.WAIST] = 4, -- 腰带
    [EXTERIOR_INDEX_TYPE.BOOTS] = 5 -- 鞋子
}

local tRepresentSubToBoxIndex = 
{
    [EQUIPMENT_REPRESENT.HELM_STYLE] = 1, -- 头部 2
    [EQUIPMENT_REPRESENT.CHEST_STYLE] = 2, -- 上衣 5
    [EQUIPMENT_REPRESENT.BANGLE_STYLE] = 3, -- 护手 11
    [EQUIPMENT_REPRESENT.WAIST_STYLE] = 4, -- 腰带 8
    [EQUIPMENT_REPRESENT.BOOTS_STYLE] = 5 -- 鞋子 14
}

local tBoxIndexToRepresentSub = 
{
    EQUIPMENT_REPRESENT.HELM_STYLE,  -- 头部
    EQUIPMENT_REPRESENT.CHEST_STYLE, -- 上衣
    EQUIPMENT_REPRESENT.BANGLE_STYLE,  -- 护手
    EQUIPMENT_REPRESENT.WAIST_STYLE, -- 腰带
    EQUIPMENT_REPRESENT.BOOTS_STYLE-- 鞋子
}

local tBoxIndexToExteriorSub = 
{
    EXTERIOR_INDEX_TYPE.HELM,  -- 头部
    EXTERIOR_INDEX_TYPE.CHEST, -- 上衣
    EXTERIOR_INDEX_TYPE.BANGLE,  -- 护手
    EXTERIOR_INDEX_TYPE.WAIST, -- 腰带
    EXTERIOR_INDEX_TYPE.BOOTS, -- 鞋子
}

local tBoxIndexToSub = 
{
    EQUIPMENT_SUB.HELM,  -- 头部
    EQUIPMENT_SUB.CHEST, -- 上衣
    EQUIPMENT_SUB.BANGLE,  -- 护手
    EQUIPMENT_SUB.WAIST, -- 腰带
    EQUIPMENT_SUB.BOOTS, -- 鞋子
}

local tSubToRepresentSub = 
{
    [EQUIPMENT_SUB.HELM]  = EQUIPMENT_REPRESENT.HELM_STYLE,
    [EQUIPMENT_SUB.CHEST] = EQUIPMENT_REPRESENT.CHEST_STYLE,
    [EQUIPMENT_SUB.BANGLE] = EQUIPMENT_REPRESENT.BANGLE_STYLE,
    [EQUIPMENT_SUB.WAIST] = EQUIPMENT_REPRESENT.WAIST_STYLE,
    [EQUIPMENT_SUB.BOOTS] = EQUIPMENT_REPRESENT.BOOTS_STYLE,
}

local tRepresentSubToExteriorSub = 
{
    [EQUIPMENT_REPRESENT.HELM_STYLE]  = EXTERIOR_INDEX_TYPE.HELM,
    [EQUIPMENT_REPRESENT.CHEST_STYLE] = EXTERIOR_INDEX_TYPE.CHEST,
    [EQUIPMENT_REPRESENT.BANGLE_STYLE] = EXTERIOR_INDEX_TYPE.BANGLE,
    [EQUIPMENT_REPRESENT.WAIST_STYLE] = EXTERIOR_INDEX_TYPE.WAIST,
    [EQUIPMENT_REPRESENT.BOOTS_STYLE] = EXTERIOR_INDEX_TYPE.BOOTS,
}

local tRepresentSubToColor = 
{
    [EQUIPMENT_REPRESENT.HELM_STYLE]  = EQUIPMENT_REPRESENT.HELM_COLOR,
    [EQUIPMENT_REPRESENT.CHEST_STYLE] = EQUIPMENT_REPRESENT.CHEST_COLOR,
    [EQUIPMENT_REPRESENT.BANGLE_STYLE] = EQUIPMENT_REPRESENT.BANGLE_COLOR,
    [EQUIPMENT_REPRESENT.WAIST_STYLE] = EQUIPMENT_REPRESENT.WAIST_COLOR,
    [EQUIPMENT_REPRESENT.BOOTS_STYLE] = EQUIPMENT_REPRESENT.BOOTS_COLOR,
}

local tRepresentSubToEquipSub = 
{
    [EQUIPMENT_REPRESENT.HELM_STYLE]  = EQUIPMENT_INVENTORY.HELM,
    [EQUIPMENT_REPRESENT.CHEST_STYLE] = EQUIPMENT_INVENTORY.CHEST,
    [EQUIPMENT_REPRESENT.BANGLE_STYLE] = EQUIPMENT_INVENTORY.BANGLE,
    [EQUIPMENT_REPRESENT.WAIST_STYLE] = EQUIPMENT_INVENTORY.WAIST,
    [EQUIPMENT_REPRESENT.BOOTS_STYLE] = EQUIPMENT_INVENTORY.BOOTS,
}

function Exterior_SubToBoxIndex(nSub)
    return tSubToBoxIndex[nSub]
end

function Exterior_ExteriorSubToBoxIndex(nSub)
    return tExteriorSubToBoxIndex[nSub]
end

function Exterior_RepresentToBoxIndex(nSub)
    return tRepresentSubToBoxIndex[nSub]
end

function Exterior_BoxIndexToRepresentSub(nIndex)
    return tBoxIndexToRepresentSub[nIndex]
end

function Exterior_BoxIndexToExteriorSub(nIndex)
    return tBoxIndexToExteriorSub[nIndex]
end

function Exterior_BoxIndexToSub(nIndex)
    return tBoxIndexToSub[nIndex]
end

function Exterior_SubToRepresentSub(nSub)
    return tSubToRepresentSub[nSub]
end

function Exterior_RepresentSubToExteriorSub(nSub)
    return tRepresentSubToExteriorSub[nSub]
end

function Exterior_RepresentSubToColor(nSub)
    return tRepresentSubToColor[nSub]
end

function Exterior_RepresentSubToEquipSub(nSub)
    return tRepresentSubToEquipSub[nSub]
end

g_tExteriorPayTypeFrame = 
{
    [EXTERIOR_PAY_TYPE.COIN] =  {"ui/Image/Common/Money.UITex", 15}, -- [TypeEnum] = {szPath, nImageFrame}
    [EXTERIOR_PAY_TYPE.MONEY] = {"ui/Image/Common/Money.UITex", 0},
    [EXTERIOR_PAY_TYPE.FREE] = {"ui/Image/UICommon/ExteriorBox.UITex", 32},
}

g_tExteriorTimeType = {EXTERIOR_TIME_TYPE.LIMIT, EXTERIOR_TIME_TYPE.PERMANENT, EXTERIOR_TIME_TYPE.END}
g_tExteriorPayType = {EXTERIOR_PAY_TYPE.COIN, EXTERIOR_PAY_TYPE.MONEY, EXTERIOR_PAY_TYPE.FREE}

ExteriorCharacter = {}

ExteriorCharacter.tResisterFrame = {}

ExteriorCharacter.tCameraInfo = 
{
	[0] = { -30, 160, -25, 0, 150, 0 }, --rtInvalid = 0,
    [1] = { 0, 70, -240, 0, 120, 150 }, --rtStandardMale,     // 标准男
    [2] = { 0, 78, -235, 0, 120, 150 }, --rtStandardFemale,   // 标准女
    [3] = { -30, 160, -25, 0, 150, 0 }, --rtStrongMale,       // 魁梧男
    [4] = { -30, 160, -25, 0, 150, 0 }, --rtSexyFemale,       // 性感女
    [5] = { -30, 160, -25, 0, 80, 150 }, --rtLittleBoy,        // 小男孩
    [6] = { 0, 70, -215, 0, 100, 150 }  --rtLittleGirl,       // 小孩女
}

ExteriorCharacter.tCameraMaxMinY = 
{
	[0] = {150, 150}, --rtInvalid = 0,
    [1] = {120, 170},--rtStandardMale,     // 标准男
    [2] = {120, 170},  --rtStandardFemale,   // 标准女
    [3] = {150, 180},--rtStrongMale,       // 魁梧男
    [4] = {150, 180},--rtSexyFemale,       // 性感女
    [5] = {80, 120}, --rtLittleBoy,        // 小男孩
    [6] = {100, 120}, --rtLittleGirl,       // 小孩女
}


function ExteriorCharacter.CreateOnLButtonDown(szFrame)
    ExteriorCharacter.tResisterFrame[szFrame].fnOldOnLButtonDown = _G[szFrame].OnLButtonDown
    _G[szFrame].OnLButtonDown = function()
        local hFrame = this:GetRoot()
        local szFrameName = hFrame:GetName()
        local tFrame = ExteriorCharacter.tResisterFrame[szFrameName]
        local szName = this:GetName()
        local hScene = hFrame:Lookup(tFrame.szScene)
        if szName == tFrame.szTurnLeft then
            hScene.bTurnLeft = true
        elseif szName == tFrame.szTurnRight then
            hScene.bTurnRight = true
        end
        
        if tFrame.fnOldOnLButtonDown then
            return tFrame.fnOldOnLButtonDown()
        end
    end
    ExteriorCharacter.tResisterFrame[szFrame].fnNewOnLButtonDown = _G[szFrame].OnLButtonDown
end

function ExteriorCharacter.CreateOnLButtonUp(szFrame)
     ExteriorCharacter.tResisterFrame[szFrame].fnOldOnLButtonUp = _G[szFrame].OnLButtonUp
     _G[szFrame].OnLButtonUp = function()
        local hFrame = this:GetRoot()
        local szFrameName = hFrame:GetName()
        local tFrame = ExteriorCharacter.tResisterFrame[szFrameName]
        local szName = this:GetName()
        local hScene = hFrame:Lookup(tFrame.szScene)
        if szName == tFrame.szTurnLeft then
            hScene.bTurnLeft = false
        elseif szName == tFrame.szTurnRight then
            hScene.bTurnRight = false
        end
        
        if tFrame.fnOldOnLButtonUp then
            return tFrame.fnOldOnLButtonUp()
        end
    end
    
    ExteriorCharacter.tResisterFrame[szFrame].fnNewOnLButtonUp = _G[szFrame].OnLButtonUp
end

function ExteriorCharacter.CreateOnFrameBreathe(szFrame)
     ExteriorCharacter.tResisterFrame[szFrame].fnOldOnFrameBreathe = _G[szFrame].OnFrameBreathe
     _G[szFrame].OnFrameBreathe = function()
        local szFrameName = this:GetName()
        local tFrame = ExteriorCharacter.tResisterFrame[szFrameName]
        if tFrame then
            local hScene = this:Lookup(tFrame.szScene)
            if hScene.bTurnRight then
                hScene.fRoleYaw = hScene.fRoleYaw - CHARACTER_ROLE_TURN_YAW
                hScene.hModelView.m_modelRole["MDL"]:SetYaw(hScene.fRoleYaw)
            elseif hScene.bTurnLeft then
                hScene.fRoleYaw = hScene.fRoleYaw + CHARACTER_ROLE_TURN_YAW
                hScene.hModelView.m_modelRole["MDL"]:SetYaw(hScene.fRoleYaw)
            end
            
            if tFrame.fnOldOnFrameBreathe then
                return tFrame.fnOldOnFrameBreathe()
            end
          end
    end
    
    ExteriorCharacter.tResisterFrame[szFrame].fnNewOnFrameBreathe = _G[szFrame].OnFrameBreathe
end

function ExteriorCharacter.CreateOnFrameDestroy(szFrame)
     ExteriorCharacter.tResisterFrame[szFrame].fnOldOnFrameDestroy = _G[szFrame].OnFrameDestroy
     _G[szFrame].OnFrameDestroy = function()
        local szFrameName = this:GetName()
        local tFrame = ExteriorCharacter.tResisterFrame[szFrameName]
        local hModelView = tFrame.hModelView
        if hModelView then
            hModelView:UnloadModel()
            hModelView:release()
            tFrame.hModelView = nil
        end
        
        if tFrame.fnOldOnFrameDestroy then
            return tFrame.fnOldOnFrameDestroy()
        end
    end
    ExteriorCharacter.tResisterFrame[szFrame].fnNewOnFrameDestroy = _G[szFrame].OnFrameDestroy
end

function ExteriorCharacter.CreateOnFrameCreate(szFrame)
     ExteriorCharacter.tResisterFrame[szFrame].fnOldOnFrameCreate = _G[szFrame].OnFrameCreate
     _G[szFrame].OnFrameCreate = function()
        this:RegisterEvent("RENDER_FRAME_UPDATE")
        if tFrame.fnOldOnFrameCreate then
            return tFrame.fnOldOnFrameCreate()
        end
    end
    ExteriorCharacter.tResisterFrame[szFrame].fnNewOnFrameCreate = _G[szFrame].OnFrameCreate
end

function ExteriorCharacter.CreateOnEvent(szFrame)
     ExteriorCharacter.tResisterFrame[szFrame].fnOldOnEvent = _G[szFrame].OnEvent
     _G[szFrame].OnEvent = function(szEvent)
        local szFrameName = this:GetName()
        local tFrame = ExteriorCharacter.tResisterFrame[szFrameName]
        if szEvent == "RENDER_FRAME_UPDATE" then
            local hScene = this:Lookup(tFrame.szScene)
            local nCameraRadiusDelta = hScene.nCameraRadiusExpect - hScene.nCameraRadius
            local nLookAtYDelta = hScene.nLookAtYExpect - hScene.nLookAtY
            if nCameraRadiusDelta ~= 0 or nLookAtYDelta ~= 0 then
                if nCameraRadiusDelta > 0 then
                    hScene.nCameraRadius = hScene.nCameraRadius + nCameraRadiusDelta / 5
                    if hScene.nCameraRadius > hScene.nCameraRadiusExpect then
                        hScene.nCameraRadius = hScene.nCameraRadiusExpect
                    end
                else
                    hScene.nCameraRadius = hScene.nCameraRadius + nCameraRadiusDelta / 5
                    if hScene.nCameraRadius < hScene.nCameraRadiusExpect then
                        hScene.nCameraRadius = hScene.nCameraRadiusExpect
                    end
                end
                
                if nLookAtYDelta > 0 then
                    hScene.nLookAtY = hScene.nLookAtY + nLookAtYDelta / 5
                    if hScene.nLookAtY > hScene.nLookAtYExpect then
                        hScene.nLookAtY = hScene.nLookAtYExpect
                    end
                else
                    hScene.nLookAtY = hScene.nLookAtY + nLookAtYDelta / 5
                    if hScene.nLookAtY < hScene.nLookAtYExpect then
                        hScene.nLookAtY = hScene.nLookAtYExpect
                    end
                end
                ExteriorCharacter.UpdateCameraPosition(this)
            end
        end
        
        if tFrame.fnOldOnEvent then
            return tFrame.fnOldOnEvent(szEvent)
        end
    end
    ExteriorCharacter.tResisterFrame[szFrame].fnNewOnEvent = _G[szFrame].OnEvent
end

function ExteriorCharacter.Init(szFrame)
    local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
    local tFrame = ExteriorCharacter.tResisterFrame[szFrame]
    hFrame = Station.Lookup(tFrame.szFrame)
    assert(hFrame)
    local hScene = hFrame:Lookup(tFrame.szScene)
    local nWidth, nHeight = hScene:GetSize()
    local tCameraInfo
    if tFrame.tCameraInfo then
        tCameraInfo = tFrame.tCameraInfo
    else
        tCameraInfo = ExteriorCharacter.tCameraInfo
    end
    
	local tCamera = tCameraInfo[hPlayer.nRoleType]
	hScene.hModelView = PlayerModelView.new()
	hScene.hModelView:init()
    tFrame.hModelView = hModelView
	--hScene.hModelView:SetCamera({tCamera[1], tCamera[2], tCamera[3], tCamera[4], tCamera[5], tCamera[6], math.pi / 4, nWidth / nHeight, nil, nil, true })
    hScene:SetScene(hScene.hModelView.m_scene)
    hScene.fRoleYaw = 0
	hScene.bTurnLeft = false
	hScene.bTurnRight = false
    hScene.nLookAtX = tCamera[4]
	hScene.nLookAtY = tCamera[5]
	hScene.nLookAtZ = tCamera[6]
    hScene.nLookAtYExpect = tCamera[5]
	hScene.nCameraRadius = 430 --430 --392
    hScene.nCameraRadiusExpect = hScene.nCameraRadius
    hScene.nCameraMaxRadius = hScene.nCameraRadius
    hScene.nCameraMinRadius = 250
	hScene.m_nCameraYaw = -1.57
	hScene.nCameraPitch = -0.0766055 -- math.asin((tCamera[2] - tCamera[5]) / hScene.nCameraRadius)
    ExteriorCharacter.UpdateCameraPosition(hFrame)
    ExteriorCharacter.CreateOnLButtonDown(szFrame)
    ExteriorCharacter.CreateOnLButtonUp(szFrame)
    ExteriorCharacter.CreateOnFrameBreathe(szFrame)
    ExteriorCharacter.CreateOnFrameDestroy(szFrame)
    if tFrame.bCamera then
        ExteriorCharacter.CreateOnEvent(szFrame)
    end
end

function ExteriorCharacter.UpdateCameraPosition(hFrame)
    local szFrameName = hFrame:GetName()
    local tFrame = ExteriorCharacter.tResisterFrame[szFrameName]
    if not tFrame then
        return
    end
    local hScene = hFrame:Lookup(tFrame.szScene)
    local hModelView = hScene.hModelView
	local ycos = hScene.nCameraRadius * math.cos(hScene.nCameraPitch)
	local ysin = hScene.nCameraRadius * math.sin(hScene.nCameraPitch)
	local x = hScene.nLookAtX + ycos * math.cos(hScene.m_nCameraYaw)
	local y = hScene.nLookAtY + ysin
	local z = hScene.nLookAtZ + ycos * math.sin(hScene.m_nCameraYaw)
	local xLookAt = hScene.nLookAtX
	local yLookAt = hScene.nLookAtY
	local zLookAt = hScene.nLookAtZ
    local nWidth, nHeight = hScene:GetSize()
    hModelView:SetCamera({x, y, z, xLookAt, yLookAt, zLookAt, math.pi / 4, nWidth / nHeight, nil, nil, true })
	
    --[[
    hCamera:SetLookAtPosition(xLookAt, yLookAt, zLookAt)
	hCamera:SetPosition(x, y, z)
    --]]
	--hScene:SetFocus(xLookAt, yLookAt, zLookAt)
end

function ExteriorCharacter.SetCameraRadius(szName, szRadius)
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return 
    end
    local tFrame = ExteriorCharacter.tResisterFrame[szName]
    local hFrame = Station.Lookup(tFrame.szFrame)
    local hScene = hFrame:Lookup(tFrame.szScene)
    
    local tCameraMaxMinY
    if tFrame.tCameraMaxMinY then
        tCameraMaxMinY = tFrame.tCameraMaxMinY
    else
        tCameraMaxMinY = ExteriorCharacter.tCameraMaxMinY
    end
    
	local tCameraY = tCameraMaxMinY[hPlayer.nRoleType]
    
    local nRadius
    local nLookAtY
    if szRadius == "Max" then
       nRadius = hScene.nCameraMaxRadius
       nLookAtY = tCameraY[1]
    elseif szRadius == "Min" then
       nRadius = hScene.nCameraMinRadius
       nLookAtY = tCameraY[2]
    end
   
	hScene.nCameraRadiusExpect = nRadius
    hScene.nLookAtYExpect = nLookAtY
end

function ExteriorCharacter.ShowPlayer(szName, tRepresentID)
    local hPlayer = GetClientPlayer()
	if not hPlayer then
		return
	end
    local tFrame = ExteriorCharacter.tResisterFrame[szName]
    local hFrame = Station.Lookup(tFrame.szFrame)
    local hScene = hFrame:Lookup(tFrame.szScene)
    local hModelView = hScene.hModelView
    
    hModelView:UnloadModel()
	hModelView:LoadRes(hPlayer.dwID, tRepresentID)
	hModelView:LoadModel()
	hModelView:PlayAnimation("Standard", "loop")
	if hModelView.m_modelRole then
		hModelView.m_modelRole["MDL"]:SetYaw(hScene.fRoleYaw)
	end
end

local function RestoreMsgFunction(szFrame, szFunctionName)
    if _G[szFrame] and ExteriorCharacter.tResisterFrame[szFrame] and 
       _G[szFrame][szFunctionName] == ExteriorCharacter.tResisterFrame[szFrame]["fnNew" .. szFunctionName] then
       
       _G[szFrame][szFunctionName] = ExteriorCharacter.tResisterFrame[szFrame]["fnOld" .. szFunctionName]
    end
end

function RegisterExteriorCharacter(szName, szFrame, szScene, szTurnLeft, szTurnRight, bCamera)
    if ExteriorCharacter.tResisterFrame[szName] then
        local tFrame = ExteriorCharacter.tResisterFrame[szName]
        RestoreMsgFunction(szName, "OnLButtonDown")
        RestoreMsgFunction(szName, "OnLButtonUp")
        RestoreMsgFunction(szName, "OnFrameBreathe")
        RestoreMsgFunction(szName , "OnFrameDestroy")
        RestoreMsgFunction(szName , "OnFrameCreate")
        RestoreMsgFunction(szName , "OnEvent")
        ExteriorCharacter.tResisterFrame[szName] = nil
    end
    ExteriorCharacter.tResisterFrame[szName] = {["szFrame"] = szFrame, ["szScene"] = szScene, ["szTurnLeft"] = szTurnLeft, ["szTurnRight"] = szTurnRight, ["bCamera"] = bCamera}
    ExteriorCharacter.Init(szName)
end


local function OnExteriorCharacterEvent(szEvent)
    if szEvent == "EXTERIOR_CHARACTER_UPDATE" then
        ExteriorCharacter.ShowPlayer(arg0, arg1)
    end
end

local function OnExteriorSetCameraRadius(szEvent)
    if szEvent == "EXTERIOR_CHARACTER_SET_CAME_RARADIUS" then
        ExteriorCharacter.SetCameraRadius(arg0, arg1)
    end
end

RegisterEvent("EXTERIOR_CHARACTER_UPDATE", function(szEvent) OnExteriorCharacterEvent(szEvent) end)
RegisterEvent("EXTERIOR_CHARACTER_SET_CAME_RARADIUS", function(szEvent) OnExteriorSetCameraRadius(szEvent) end)
