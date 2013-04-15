local STEP_SIZE = 10

Cyclopaedia_Log = {}

function Cyclopaedia_Log.Update(hWnd)
	Interaction_Request("JX3Patch", tUrl.JX3Patch, "", "", 80)
end

function Cyclopaedia_Log.OnEvent(hFrame, szEvent)
	if szEvent ~= "INTERACTION_REQUEST_RESULT" then
		return
	end
	
	if arg0 ~= "JX3Patch" or not arg1 then
			return
	end
	
	local hCheckLog = hFrame:Lookup("PageSet_Total/CheckBox_Log")
	
	if not hCheckLog:IsCheckBoxChecked() then
		return 
	end
	
	local hWndLog = hFrame:Lookup("PageSet_Total/Page_Log/Wnd_Log")
	Cyclopaedia_Log.UpdateLog(hWndLog, arg2)
end

function Cyclopaedia_Log.UpdateLog(hWnd, szLog)
	local hHandleLog = hWnd:Lookup("", "")
	
	hHandleLog:Clear()
    local nCodePage = GetCodePage()
    szLog = string.sub(szLog, 4)
	local szText = MultiByteToMultiByte(szLog, 65001, nCodePage)
	szText = GetFormatText(szText, 157)
	hHandleLog:AppendItemFromString(szText)
	hHandleLog:FormatAllItemPos()
	
	Cyclopaedia_Log.UpdateInfoScroll(hHandleLog, true)
end

function Cyclopaedia_Log.UpdateInfoScroll(hList, bHome)
	local hWndInfo = hList:GetParent()
	local hScroll = hWndInfo:Lookup("Scroll_LogInfo")
	local fWidthAll, fHeightAll = hList:GetAllItemSize()
	local fWidth, fHeight = hList:GetSize()
	local nStepCount = math.ceil((fHeightAll - fHeight) / STEP_SIZE)
	hScroll:SetStepCount(nStepCount)
	
	if bHome then
		hScroll:ScrollHome()
	end
	if nStepCount > 0 then
		hScroll:Show()
		hWndInfo:Lookup("Btn_LogInfoUp"):Show()
		hWndInfo:Lookup("Btn_LogInfoDown"):Show()
	else
		hScroll:Hide()
		hWndInfo:Lookup("Btn_LogInfoUp"):Hide()
		hWndInfo:Lookup("Btn_LogInfoDown"):Hide()
	end	
end

function Cyclopaedia_Log.OnLButtonDown(hButton)
	local szName = hButton:GetName()
	local hWnd = hButton:GetParent()
    if szName == "Btn_LogInfoUp" then
		hWnd:Lookup("Scroll_LogInfo"):ScrollPrev()
	elseif szName == "Btn_LogInfoDown" then
		hWnd:Lookup("Scroll_LogInfo"):ScrollNext()
	end
end

function Cyclopaedia_Log.OnScrollBarPosChanged(hScroll)
	local szName = hScroll:GetName()
	local nCurrentValue = hScroll:GetScrollPos()
	if szName == "Scroll_LogInfo" then
		local hWndInfo = hScroll:GetParent()
		if nCurrentValue == 0 then
			hWndInfo:Lookup("Btn_LogInfoUp"):Enable(false)
		else
			hWndInfo:Lookup("Btn_LogInfoUp"):Enable(true)
		end
		
		if nCurrentValue == hScroll:GetStepCount() then
			hWndInfo:Lookup("Btn_LogInfoDown"):Enable(false)
		else
			hWndInfo:Lookup("Btn_LogInfoDown"):Enable(true)
		end
		hWndInfo:Lookup("", ""):SetItemStartRelPos(0, - nCurrentValue * STEP_SIZE)
	end
end

function Cyclopaedia_Log.OnItemMouseWheel(hItem)
	local nDistance = Station.GetMessageWheelDelta()
	local szName = hItem:GetName()
	
	if szName == "Handle_LogInfo" then
		local hWnd = hItem:GetParent():GetParent()
		hWnd:Lookup("Scroll_LogInfo"):ScrollNext(nDistance)
	end
end