local l_tScroll = {}
local l_tWidgetIndex = {}
local l_tBackFunction = {}

local function GetNameFromPath(szPath)
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

local function GetWidgetData(szFrame, szWidget)
    if not l_tWidgetIndex[szFrame] then
        return
    end
    local szType = nil
    local Data = l_tWidgetIndex[szFrame][szWidget]
    local nIndex = Data
    if type(Data) == "table" then
        nIndex = Data.nIndex
        szType = Data.type
    end
    local tWidget = l_tScroll[szFrame][nIndex]
    return tWidget, szType
end

local function OnUpdateList(szList, szFrame, bHome)
    local tWidget = GetWidgetData(szFrame, szList)
    if not tWidget then
        return
    end
    local frame = Station.Lookup(l_tWidgetIndex[szFrame].szFramePath)
    local hList = frame:Lookup(tWidget.tList[1], tWidget.tList[2])
    if not hList then
        hList = frame:Lookup(tWidget.tList[1], "")
        if hList:GetName() ~= tWidget.tList[2] then
            Trace("lua[error] scroll.lua frame "..frame:GetName() .. " can not Lookup "..tWidget.tList[2])
            return
        end
    end
	hList:FormatAllItemPos()
	
	local hScroll = frame:Lookup(tWidget.szScroll)
    local hBtnUp = frame:Lookup(tWidget.szBtnUp)
    local hBtnDown = frame:Lookup(tWidget.szBtnDown)
	local w, h = hList:GetSize()
	local wAll, hAll = hList:GetAllItemSize()
	local nStepCount = math.ceil((hAll - h) / 10)

	hScroll:SetStepCount(nStepCount)
	if nStepCount > 0 then
		hScroll:Show()
		hBtnUp:Show()
		hBtnDown:Show()
	else
		hScroll:Hide()
		hBtnUp:Hide()
		hBtnDown:Hide()
	end
    
    if bHome then
        hScroll:SetScrollPos(0)
    end
end

local function CreateOnLButtonDown(szFrame)
    l_tBackFunction[szFrame].OnLButtonDown = _G[szFrame].OnLButtonDown
    
    _G[szFrame].OnLButtonDown = function()
        local frame = this:GetRoot()
        local szFrameName = frame:GetName()
        local szName = this:GetName()
        local tWidget, szType = GetWidgetData(szFrameName, szName)
        if tWidget then
            local hScroll = frame:Lookup(tWidget.szScroll)
            if szType == "up" then
                hScroll:ScrollPrev()
            elseif szType == "down" then
                hScroll:ScrollNext()
            end
            return
        end
        
        if l_tBackFunction[szFrame].OnLButtonDown then
            return l_tBackFunction[szFrame].OnLButtonDown()
        end    
    end
    l_tBackFunction[szFrame].OnLButtonDownNew = _G[szFrame].OnLButtonDown
end

local function CreateOnLButtonHold(szFrame)
    l_tBackFunction[szFrame].OnLButtonHold = _G[szFrame].OnLButtonHold
    
    _G[szFrame].OnLButtonHold = function()
        local frame = this:GetRoot()
        local szFrameName = frame:GetName()
        local szName = this:GetName()
        local tWidget, szType = GetWidgetData(szFrameName, szName)
        if tWidget then
            local hScroll = frame:Lookup(tWidget.szScroll)
            if szType == "up" then
                hScroll:ScrollPrev()
            elseif szType == "down" then
                hScroll:ScrollNext()
            end
            return
        end
        
        if l_tBackFunction[szFrame].OnLButtonHold then
            return l_tBackFunction[szFrame].OnLButtonHold()
        end
    end
    l_tBackFunction[szFrame].OnLButtonHoldNew = _G[szFrame].OnLButtonHold
end

local function CreateOnItemMouseWheel(szFrame)
    l_tBackFunction[szFrame].OnItemMouseWheel = _G[szFrame].OnItemMouseWheel
    
    _G[szFrame].OnItemMouseWheel = function()
        local frame = this:GetRoot()
        local szFrameName = frame:GetName()
        local nDistance = Station.GetMessageWheelDelta()
        local szName = this:GetName()

        local tWidget = GetWidgetData(szFrameName, szName)
        if tWidget then
            local hScroll = frame:Lookup(tWidget.szScroll)
            hScroll:ScrollNext(nDistance)
            return true
        end

        if l_tBackFunction[szFrame].OnItemMouseWheel then
            return l_tBackFunction[szFrame].OnItemMouseWheel()
        end  
    end
    l_tBackFunction[szFrame].OnItemMouseWheelNew = _G[szFrame].OnItemMouseWheel
end

local function CreateOnScrollBarPosChanged(szFrame)    
    l_tBackFunction[szFrame].OnScrollBarPosChanged = _G[szFrame].OnScrollBarPosChanged
   
    _G[szFrame].OnScrollBarPosChanged = function()
        local frame = this:GetRoot()
        local szFrameName = frame:GetName()
        local szName = this:GetName()
        local tWidget = GetWidgetData(szFrameName, szName)
        if tWidget then
            local hBtnUp = frame:Lookup(tWidget.szBtnUp)
            local hBtnDown = frame:Lookup(tWidget.szBtnDown)
            local hList = frame:Lookup(tWidget.tList[1], tWidget.tList[2])
            if not hList then
                hList = frame:Lookup(tWidget.tList[1], "")
                if hList:GetName() ~= tWidget.tList[2] then
                    Trace("lua[error] scroll.lua frame "..frame:GetName() .. " can not Lookup "..tWidget.tList[2])
                    return
                end
            end
    
            local nCurrentValue = this:GetScrollPos()
            if nCurrentValue == 0 then
                hBtnUp:Enable(false)
            else
                hBtnUp:Enable(true)
            end

            if nCurrentValue == this:GetStepCount() then
                hBtnDown:Enable(false)
            else
                hBtnDown:Enable(true)
            end
            
            local nValue = tWidget.tList[3] -- normal   10
            hList:SetItemStartRelPos(0, -nCurrentValue * nValue)
            return
        end

        if l_tBackFunction[szFrameName].OnScrollBarPosChanged then
            l_tBackFunction[szFrameName].OnScrollBarPosChanged()
        end
    end
     l_tBackFunction[szFrame].OnScrollBarPosChangedNew = _G[szFrame].OnScrollBarPosChanged
end

local function RestoreMsgFunction(szFrame, szFunctionName)
    if _G[szFrame] and l_tBackFunction[szFrame] and 
       _G[szFrame][szFunctionName] == l_tBackFunction[szFrame][szFunctionName.."New"] then
       
       _G[szFrame][szFunctionName] = l_tBackFunction[szFrame][szFunctionName]
    end
end

local function CreateIndex(szName, szFramePath, tData)
    if not l_tScroll[szName] then
        l_tScroll[szName] = {}
    end
    
    if not l_tWidgetIndex[szName] then
        l_tWidgetIndex[szName] = {}
    end
    
    table.insert(l_tScroll[szName], tData)  
    local nIndex = #l_tScroll[szName]
    
    local szWidgetName = GetNameFromPath(tData.szBtnUp)
    l_tWidgetIndex[szName][szWidgetName] = {nIndex = nIndex, type="up"}
    
    szWidgetName = GetNameFromPath(tData.szBtnDown)
    l_tWidgetIndex[szName][szWidgetName] = {nIndex = nIndex, type="down"}
    
    szWidgetName = GetNameFromPath(tData.szScroll)
    l_tWidgetIndex[szName][szWidgetName] = nIndex
    
	szWidgetName = GetNameFromPath(tData.tList[2])
    l_tWidgetIndex[szName][szWidgetName] = nIndex
    l_tWidgetIndex[szName].szFramePath = szFramePath
end

function RegisterScrollControl(szFrameName, szBtnUp, szBtnDown, szScroll, tList)
    local szName = GetNameFromPath(szFrameName)
    
    if not tList[3] then
        tList[3] = 10
    end
    local tData = {szBtnUp=szBtnUp, szBtnDown=szBtnDown, szScroll=szScroll,tList=tList}
    CreateIndex(szName, szFrameName, tData)
end

function UnRegisterScrollAllControl(szFrame)
    l_tScroll[szFrame] = nil
    l_tWidgetIndex[szFrame] = nil
end

function RegisterScrollEvent(szFrame)
    UnRegisterScrollEvent(szFrame)
    
    l_tBackFunction[szFrame] = {}
    
    CreateOnItemMouseWheel(szFrame)
    CreateOnLButtonDown(szFrame)
    CreateOnLButtonHold(szFrame)
    CreateOnScrollBarPosChanged(szFrame)
end

function UnRegisterScrollEvent(szFrame)
    if l_tBackFunction[szFrame] then
        RestoreMsgFunction(szFrame, "OnScrollBarPosChanged")
        RestoreMsgFunction(szFrame, "OnItemMouseWheel")
        RestoreMsgFunction(szFrame, "OnLButtonDown")
        RestoreMsgFunction(szFrame, "OnLButtonHold")
        l_tBackFunction[szFrame] = nil
    end
end

local function OnScrollEvent(szEvent)
    if szEvent == "SCROLL_UPDATE_LIST" then
        OnUpdateList(arg0, arg1, arg2)
    end
end
RegisterEvent("SCROLL_UPDATE_LIST", function(szEvent) OnScrollEvent(szEvent) end)
