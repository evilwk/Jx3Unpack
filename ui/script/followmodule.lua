local l_tFollowerInfo = {}

local function SplitPath(szPath)
    local nPos = 1
    while 1 do
        local nNext = string.find(szPath, "/", nPos)
        if not nNext then
            break
        end
        nPos = nNext + 1
    end
    return string.sub(szPath, nPos)
end


local function UpdateFollowerPosition(hFrame, tAnchor)
    local nW, nH = hFrame:GetSize()
    hFrame:SetPoint(tAnchor.s, 0, 0, tAnchor.MasterWindow, tAnchor.r, tAnchor.x - nW, tAnchor.y)
	hFrame:CorrectPos()
end

local function UpdateFollowersPos(szMasterFrame)
    local hMasterFrame = nil
    local bMasterVisible = false
    for k, v in pairs(l_tFollowerInfo[szMasterFrame]) do
        local hFrame = Station.Lookup(v.szFollowerPath)
        
        if not hMasterFrame then
            hFrameMaster = Station.Lookup(v.szMasterPath)
            if hFrameMaster and  hFrameMaster:IsVisible() then
                bMasterVisible = true
            end
        end
        
        if bMasterVisible and hFrame and hFrame:IsVisible() then
            UpdateFollowerPosition(hFrame, v.tAnchor)
        end
    end
end

local function RestoreFunction(tGlobal, tLocal, szFunctionName)
    if tGlobal and tLocal and 
       tGlobal[szFunctionName] == tLocal[szFunctionName.."New"] then
       
       tGlobal[szFunctionName] = tLocal[szFunctionName]
    end
end

local function UpdateMasterSize(szMasterPath, szFollowerPath, bClose)
    local hFrameFollower = Station.Lookup(szFollowerPath)
    local hFrameMaster = Station.Lookup(szMasterPath)

    if not hFrameFollower or not hFrameMaster then
        --Trace("Lua[Error] UpdateMasterSize hFrameFollower or hFrameMaster is nil  bClose is"..tostring(bClose))
        return 
    end
    
    if not hFrameMaster:IsVisible() then
        return
    end
    
    local nW = hFrameFollower:GetSize()
    local nMW, nMH = hFrameMaster:GetSize()
    if bClose then
        hFrameMaster:SetSize(nMW - nW, nMH)
    else
        hFrameMaster:SetSize(nMW + nW, nMH)
    end
    CorrectAutoPosFrameAfterClientResize()
end

local function ProcessOpenMaster(szMasterFrame, szFollowerFrame)
    local szMasterOpen = "Open" .. szMasterFrame
    local tInfo = l_tFollowerInfo[szMasterFrame][szFollowerFrame]
    tInfo[szMasterOpen] = _G[szMasterOpen]
    
    _G[szMasterOpen] = function(nParam1, nParam2, nParam3, nParam4, nParam5)
        local hFrame = Station.Lookup(tInfo.szFollowerPath)
        local hMasterFrame = Station.Lookup(tInfo.szMasterPath)
        if (not hMasterFrame or  not hMasterFrame:IsVisible()) and  hFrame and hFrame:IsVisible() then
            tInfo[szMasterOpen](nParam1, nParam2, nParam3, nParam4, nParam5)            
            UpdateMasterSize(tInfo.szMasterPath, tInfo.szFollowerPath, false)
            UpdateFollowersPos(szMasterFrame)
        else
        	tInfo[szMasterOpen](nParam1, nParam2, nParam3, nParam4, nParam5)
        end
    end
    tInfo[szMasterOpen.."New"] = _G[szMasterOpen]
end

local function ProcessCloseMaster(szMasterFrame, szFollowerFrame)
    local szMasterClose = "Close" .. szMasterFrame
    local szFollowerClose = "Close" .. szFollowerFrame
    local tInfo = l_tFollowerInfo[szMasterFrame][szFollowerFrame]
    tInfo[szMasterClose] = _G[szMasterClose]
    
    _G[szMasterClose] = function(nParam1, nParam2, nParam3, nParam4, nParam5)
        local hFrame = Station.Lookup(tInfo.szFollowerPath)
        if hFrame and hFrame:IsVisible() and _G[szFollowerClose] then
            _G[szFollowerClose]();
        end
        
        if tInfo[szMasterClose] then
            tInfo[szMasterClose](nParam1, nParam2, nParam3, nParam4, nParam5)
        end
    end
    tInfo[szMasterClose.."New"] = _G[szMasterClose]
end

local function ProcessCloseFollower(szMasterFrame, szFollowerFrame)
    local szFollowerClose = "Close" .. szFollowerFrame
    local tInfo = l_tFollowerInfo[szMasterFrame][szFollowerFrame]
    tInfo[szFollowerClose] = _G[szFollowerClose]
    
    _G[szFollowerClose] = function(nParam1, nParam2, nParam3, nParam4, nParam5)
        local hFrame = Station.Lookup(tInfo.szFollowerPath)
        if hFrame and hFrame:IsVisible() then
            UpdateMasterSize(tInfo.szMasterPath, tInfo.szFollowerPath, true)
        end
        
        if tInfo[szFollowerClose] then
            tInfo[szFollowerClose](nParam1, nParam2, nParam3, nParam4, nParam5)
        end
        UpdateFollowersPos(szMasterFrame)
    end
    tInfo[szFollowerClose.."New"] = _G[szFollowerClose]
end

local function ProcessOpenFollower(szMasterFrame, szFollowerFrame)
    local szOpenFollower = "Open"..szFollowerFrame
    local tInfo = l_tFollowerInfo[szMasterFrame][szFollowerFrame]
    tInfo[szOpenFollower] = _G[szOpenFollower]
    _G[szOpenFollower] = function(nParam1, nParam2, nParam3, nParam4, nParam5)
        local bClose = true
        local hFrame = Station.Lookup(tInfo.szFollowerPath)
        if hFrame and hFrame:IsVisible() then
            bClose = false
        end
        
        if tInfo[szOpenFollower] then
            tInfo[szOpenFollower](nParam1, nParam2, nParam3, nParam4, nParam5)
        end
        
        if bClose then
            UpdateMasterSize(tInfo.szMasterPath, tInfo.szFollowerPath, false)
        end
        
        UpdateFollowersPos(szMasterFrame)
    end
    tInfo[szOpenFollower.."New"] = _G[szOpenFollower]
end

local function ProcessSetFocusMaster(szMasterFrame, szFollowerFrame)
    local tInfo = l_tFollowerInfo[szMasterFrame][szFollowerFrame]
    tInfo.OnSetFocus = _G[szMasterFrame].OnSetFocus
    _G[szMasterFrame].OnSetFocus = function()
        if tInfo.OnSetFocus then
            tInfo.OnSetFocus()
        end
        
        local hFrame = Station.Lookup(tInfo.szFollowerPath)
        if hFrame and hFrame:IsVisible() then
            hFrame:BringToTop()
        end
    end
    tInfo.OnSetFocusNew = _G[szMasterFrame].OnSetFocus
end

local function ProcessOnFrameDragSetPosEnd(szMasterFrame, szFollowerFrame)
    local tInfo = l_tFollowerInfo[szMasterFrame][szFollowerFrame]
    tInfo.OnFrameDragSetPosEnd = _G[szMasterFrame].OnFrameDragSetPosEnd
    
    _G[szMasterFrame].OnFrameDragSetPosEnd = function()
        local hFrame = Station.Lookup(tInfo.szFollowerPath)
        if hFrame and hFrame:IsVisible() then
            UpdateFollowerPosition(hFrame, tInfo.tAnchor)
        end
        
        if tInfo.OnFrameDragSetPosEnd then
            tInfo.OnFrameDragSetPosEnd()
        end
    end
    tInfo.OnFrameDragSetPosEndNew = _G[szMasterFrame].OnFrameDragSetPosEnd
end

function UnRegisterFollowPanel(szMasterFrame, szFollowerFrame)
    if not l_tFollowerInfo[szMasterFrame] or not l_tFollowerInfo[szMasterFrame][szFollowerFrame] then
        return
    end
    
    tInfo = l_tFollowerInfo[szMasterFrame][szFollowerFrame]
    RestoreFunction(_G[szMasterFrame],  tInfo, "OnFrameDragSetPosEnd")
    RestoreFunction(_G,  tInfo, "Open"..szMasterFrame)
    RestoreFunction(_G,  tInfo, "Close"..szMasterFrame)
    RestoreFunction(_G,  tInfo, "Close"..szFollowerFrame)
    RestoreFunction(_G[szMasterFrame],  tInfo, "OnSetFocus")
    RestoreFunction(_G,  tInfo, "Open"..szFollowerFrame)
    tInfo = nil
end

function RegisterFollowPanel(szMasterPath, szFollowerPath, tAnchor)
    local szMasterFrame = SplitPath(szMasterPath)
    local szFollowerFrame = SplitPath(szFollowerPath)
    
    UnRegisterFollowPanel(szMasterFrame, szFollowerFrame)
    
    if not l_tFollowerInfo[szMasterFrame] then
        l_tFollowerInfo[szMasterFrame] = {}
    end
    
    l_tFollowerInfo[szMasterFrame][szFollowerFrame] = {}
    local tInfo = l_tFollowerInfo[szMasterFrame][szFollowerFrame]
    
    tInfo.szMasterPath = szMasterPath
    tInfo.szFollowerPath = szFollowerPath
    tInfo.szMasterFrame = szMasterFrame
    tInfo.szFollowerFrame = szFollowerFrame
    
    tAnchor.MasterWindow = szMasterPath
    tInfo.tAnchor = clone(tAnchor)

    ProcessOpenMaster(szMasterFrame, szFollowerFrame)
    ProcessCloseMaster(szMasterFrame, szFollowerFrame)
    ProcessCloseFollower(szMasterFrame, szFollowerFrame)
    ProcessOpenFollower(szMasterFrame, szFollowerFrame)
    ProcessSetFocusMaster(szMasterFrame, szFollowerFrame)
    ProcessOnFrameDragSetPosEnd(szMasterFrame, szFollowerFrame)
end

local function OnUIScaled()
    for szMasterFrame, tMaster in pairs(l_tFollowerInfo) do
        UpdateFollowersPos(szMasterFrame);
        
    end
end

local function OnCorrectAutoPos()
    for szMasterFrame, tMaster in pairs(l_tFollowerInfo) do
        UpdateFollowersPos(szMasterFrame);
    end
end

RegisterEvent("UI_SCALED", OnUIScaled);
RegisterEvent("CORRECT_AUTO_POS", OnCorrectAutoPos)

