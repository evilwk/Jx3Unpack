EmotionManagePanel =
{ 
  szNotice = nil,
  hSelItem = nil,
  MAX_JIANGHU_COUNTS = 300,
  bModified = false,
  Rect = {200, 200, 25, 25},
}

function EmotionManagePanel.OnFrameCreate()
  EmotionManagePanel.UpdateJHInfo(this)
end

function EmotionManagePanel.UpdateInfoState(hItem)
  local imgOver = hItem:Lookup("Image_Over")
  if hItem.bSel then
    imgOver:Show()
  elseif hItem.bOver then
    imgOver:Show()
  else    
    imgOver:Hide()
  end
end

function EmotionManagePanel.UpdateJHInfo(frame)
  local hList = frame:Lookup("", "Handle_List")
  hList:Clear()

  local tJiangHu = g_tJiangHuClient
  if #tJiangHu == 0 then
    frame:Lookup("Btn_Delete"):Enable(0)
  else
  	frame:Lookup("Btn_Delete"):Enable(1)
  end

  for i, v in ipairs(tJiangHu) do
  	hList:AppendItemFromIni("UI/Config/Default/EmotionManagePanel.ini", "Handle_Item", "")
	local hItem = hList:Lookup(i - 1)  
	
	hItem.szCmd = v[1]
	hItem.szNoTarget = v[2]
	hItem.szTarget = v[3]
	hItem.bJiangHu = true
	hItem:Lookup("Text_Name"):SetText(hItem.szCmd)   
	EmotionManagePanel.UpdateInfoState(hItem)
  end
  EmotionManagePanel.UpdateListScrollInfo(hList)
  
  frame:Lookup("Edit_Command"):SetText("")
  frame:Lookup("Edit_Target"):SetText("")
  frame:Lookup("Edit_NoTarget"):SetText("")
  frame:Lookup("", "Text_CmdTitle"):SetText("")
  
  EmotionManagePanel.Select(hList:Lookup(0))  
  EmotionManagePanel.ShowContent(frame)
end

function EmotionManagePanel.UpdateListScrollInfo(hList)
	local frame = hList:GetRoot()
	local scroll = frame:Lookup("Scroll_Command")
	hList:FormatAllItemPos()
	
	local wAll, hAll = hList:GetAllItemSize()
  	local w, h = hList:GetSize()
  	local nCountStep = math.ceil((hAll - h) / 20)
  	scroll:SetStepCount(nCountStep)
  	if nCountStep > 0 then
    	scroll:Show()
    	frame:Lookup("Btn_Prev"):Show()
    	frame:Lookup("Btn_Next"):Show()
  	else
    	scroll:Hide()
    	frame:Lookup("Btn_Prev"):Hide()
    	frame:Lookup("Btn_Next"):Hide()
  	end
end

function EmotionManagePanel.UpdateTableData(frame)
  local hList = frame:Lookup("", "Handle_List")
  
  local tJiangHu = g_tJiangHuClient
  local  nCount = hList:GetItemCount() - 1
  local nSize = table.maxn(tJiangHu)
  
  while nSize > nCount do
    table.remove(tJiangHu)
    nSize = nSize - 1
  end

  for i = 0, nCount, 1 do
    local hItem = hList:Lookup(i)
    if hItem then
      if tJiangHu[i + 1] then 
        if hItem.szCmd and hItem.szNoTarget and hItem.szTarget and 
            hItem.szCmd ~= "" and hItem.szNoTarget ~= "" and hItem.szNoTarget ~= "" then
          tJiangHu[i + 1][1] = hItem.szCmd
          tJiangHu[i + 1][2] = hItem.szNoTarget
          tJiangHu[i + 1][3] = hItem.szTarget
        end
      else
        if hItem.szCmd and hItem.szNoTarget and hItem.szTarget and 
            hItem.szCmd ~= "" and hItem.szNoTarget ~= "" and hItem.szNoTarget ~= "" then
          table.insert(tJiangHu, {hItem.szCmd, hItem.szNoTarget, hItem.szTarget})
        end
      end
    end
  end
end

function EmotionManagePanel.Select(hItem)
	if EmotionManagePanel.hSelItem then
		EmotionManagePanel.hSelItem.bSel = false
		EmotionManagePanel.UpdateInfoState(EmotionManagePanel.hSelItem)
		EmotionManagePanel.hSelItem = nil
	end
  
	if hItem then
		hItem.bSel = true
		EmotionManagePanel.UpdateInfoState(hItem)
		EmotionManagePanel.hSelItem = hItem
	end
end

function EmotionManagePanel.OnScrollBarPosChanged()
	local nCurrentValue = this:GetScrollPos()
	local frame = this:GetRoot()
	local szName = this:GetName()
	if nCurrentValue == 0 then
		frame:Lookup("Btn_Prev"):Enable(false)
	else
		frame:Lookup("Btn_Prev"):Enable(true)
	end
	
	if nCurrentValue == this:GetStepCount() then
		frame:Lookup("Btn_Next"):Enable(false)
	else
		frame:Lookup("Btn_Next"):Enable(true)
	end
	frame:Lookup("", "Handle_List"):SetItemStartRelPos(0, - nCurrentValue * 20)
end

function EmotionManagePanel.NewCommand(frame)
	local hList = frame:Lookup("", "Handle_List")
	local nCount = hList:GetItemCount() - 1
	
	if nCount + 1 >= EmotionManagePanel.MAX_JIANGHU_COUNTS then
		return g_tExpression.MSG_EMOTION_MAX_COMMAND_NOTICE 
	end
	
	local szCmd = g_tExpression.STR_NEW_EMOTION.."0"
	for i = 0, nCount + 1, 1 do
		szCmd =g_tExpression.STR_NEW_EMOTION..i
		for j = 0, nCount, 1 do
			if szCmd == hList:Lookup(j).szCmd then
		    	szCmd = nil
		    	break
		  	end
		end
		
		if szCmd then
		  break
		end
	end
	
	if szCmd == g_tExpression.STR_NEW_EMOTION.."100" then
		return g_tExpression.MSG_EMOTION_MAX_NEW_NOTICE
	end
	
	hList:AppendItemFromIni("UI/Config/Default/EmotionManagePanel.ini", "Handle_Item", "")
	nCount = hList:GetItemCount() - 1
	
	local hItem = hList:Lookup(nCount)
	if hItem then
		hItem.bJiangHu = true
		hItem.szCmd = szCmd
		hItem.szNoTarget = "$N£º"..string.sub(szCmd, 2)
		hItem.szTarget = "$N£º"..string.sub(szCmd, 2)
		hItem:Lookup("Text_Name"):SetText(hItem.szCmd)
		frame:Lookup("Edit_Command"):SetText(szCmd)
		
		EmotionManagePanel.UpdateListScrollInfo(hList)
		
		EmotionManagePanel.Select(hItem)
		EmotionManagePanel.ShowContent(frame)    
		frame:Lookup("Scroll_Command"):ScrollEnd()
		EmotionManagePanel.bModified = true
		    
		if nCount == 0 then
			frame:Lookup("Btn_Delete"):Enable(1)
		end
	end
	return nil
end

function EmotionManagePanel.DeleteCommand(frame)  
  local hList = frame:Lookup("", "Handle_List")
  local nDel = nil
  local nCount = hList:GetItemCount() - 1
  for i = 0, nCount, 1 do
    local hItem = hList:Lookup(i)
    if hItem.bSel then
      hList:RemoveItem(i)      
      nDel = i
      EmotionManagePanel.hSelItem = nil
      
      if nCount == 0 then
        frame:Lookup("Btn_Delete"):Enable(0)
      end
      break
    end
  end
  EmotionManagePanel.UpdateListScrollInfo(hList)
  
  local hItem = hList:Lookup(nDel)
  if not hItem then
  	hItem = hList:Lookup(nDel - 1)
  end
  
  if hItem then
  	EmotionManagePanel.Select(hItem)
    EmotionManagePanel.ShowContent(frame)
  else
    EmotionManagePanel.Select(nil)
  end
  
  EmotionManagePanel.bModified = true
end

function EmotionManagePanel.IsJiangHuCmd(frame, szCmd)
	local hList = frame:Lookup("", "Handle_List")
	local nCount = hList:GetItemCount() - 1
  
	for i = 0, nCount, 1 do
		local hItem = hList:Lookup(i)
		if hItem and not hItem.bSel and hItem.szCmd == szCmd then
	  		return true
		end
	end
	
	return false
end

function EmotionManagePanel.IsBlankString(szContent)
	if not szContent or szContent == "" then
		return true
	end
	local nSize = string.len(szContent)
	local szWord = ""
	for i = 1, nSize , 1 do
		szWord = szWord.." "
	end
	if szWord == szContent then
		return true
	end
	return false
end

function EmotionManagePanel.MendCommand(frame)
	local szCmd = frame:Lookup("Edit_Command"):GetText()
	local szNoTarget = frame:Lookup("Edit_NoTarget"):GetText()
	local szTarget = frame:Lookup("Edit_Target"):GetText()

	szNoTarget = string.gsub(szNoTarget, "\r\n", "")
	szNoTarget = string.gsub(szNoTarget, "\n", "")
	szTarget = string.gsub(szTarget, "\r\n", "")
	szTarget = string.gsub(szTarget, "\n", "")

	if EmotionManagePanel.IsBlankString(szCmd) or 
	   EmotionManagePanel.IsBlankString(szNoTarget) or 
	   EmotionManagePanel.IsBlankString(szTarget) then
		return g_tExpression.MSG_EMOTION_NONE_NOTICE
	end
	
	if not string.find(szNoTarget, "$N") then
		szNoTarget = "$N£º"..szNoTarget
	end

	if not string.find(szTarget, "$N") then
		szTarget = "$N£º"..szTarget
	end
	
	szCmd = "/"..szCmd
	local hItem = EmotionManagePanel.hSelItem
	if hItem and szCmd == hItem.szCmd and szNoTarget == hItem.szNoTarget and szTarget == hItem.szTarget then
		EmotionManagePanel.ShowContent(frame)
		return nil
	end
	
	if EmotionManagePanel.IsJiangHuCmd(frame, szCmd) or IsEmotion(szCmd) or IsChannelHeader(szCmd.." ")then
		return  g_tExpression.MSG_EMOTION_EXIST_NOTICE
	end
	
	if hItem then
		hItem.szCmd = szCmd
		hItem.szNoTarget = szNoTarget
		hItem.szTarget = szTarget
		EmotionManagePanel.ShowContent(frame)
	end
	EmotionManagePanel.bModified = true
	return g_tExpression.MSG_EMOTION_SUCCESS_NOTICE
end

function EmotionManagePanel.OnLButtonDown()
  local szName = this:GetName()
  if szName == "Btn_Prev" then 
    EmotionManagePanel.OnLButtonHold()
  elseif szName == "Btn_Next" then
    EmotionManagePanel.OnLButtonHold()
  end
end

function EmotionManagePanel.OnLButtonHold()
  local szName = this:GetName()
  if szName == "Btn_Prev" then 
    this:GetParent():Lookup("Scroll_Command"):ScrollPrev()
  elseif szName == "Btn_Next" then
    this:GetParent():Lookup("Scroll_Command"):ScrollNext()
  end
end

function EmotionManagePanel.ShowNotice(szNotice, bSure, fun, bCancel)
	if szNotice then
		local msg = nil
		msg = 
		{
		  	bRichText = true,
			szMessage = "<text>text="..EncodeComponentsString(szNotice).." font=105 </text>", 
			szName = "EmotionNotice", 
			fnAutoClose = function() if not IsOpenEmotionManagePanel() then return true end end,
		}
		if bSure then
			table.insert(msg, { szOption = g_tExpression.STR_EMOTION_SURE, fnAction = fun})
		end
		if bCancel then
			table.insert(msg, { szOption = g_tExpression.STR_EMOTION_CANCEL})
		end
		MessageBox(msg)
	end
end

function EmotionManagePanel.RestoreDefaults(frame)
	local nSize = #g_tJiangHuClient
	local nDefSize = #g_tExpression.tJiangHu
	while nSize > nDefSize do
		table.remove(g_tJiangHuClient)
    	nSize = nSize - 1
	end
	
	local i = 1
	while nDefSize >= i do
		if g_tJiangHuClient[i] then
			g_tJiangHuClient[i][1] = g_tExpression.tJiangHu[i][1]
			g_tJiangHuClient[i][2] = g_tExpression.tJiangHu[i][2]
			g_tJiangHuClient[i][3] = g_tExpression.tJiangHu[i][3]
		else
			table.insert(g_tJiangHuClient, g_tExpression.tJiangHu[i])
		end
		i = i + 1
	end
	
	EmotionManagePanel.Select(nil)
	EmotionManagePanel.UpdateJHInfo(frame)
	EmotionManagePanel.bModified = true
end

function EmotionManagePanel.OnLButtonClick()
  local szName = this:GetName()
	if szName == "Btn_New" then
    	local szNotice = EmotionManagePanel.NewCommand(this:GetRoot())
    	EmotionManagePanel.ShowNotice(szNotice, true)
	elseif szName == "Btn_Delete" then
		local szCmd = EmotionManagePanel.hSelItem.szCmd

		local szNotice = FormatString(g_tExpression.MSG_EMOTION_DELETE_YES_OR_NO, szCmd)
		local fnAction  = function() 
		    local frame = Station.Lookup("Normal/EmotionManagePanel")
		    EmotionManagePanel.DeleteCommand(frame)
		end
		EmotionManagePanel.ShowNotice(szNotice, true, fnAction, true)
	elseif szName == "Btn_Enter" then
		local szNotice = EmotionManagePanel.MendCommand(this:GetRoot())
		EmotionManagePanel.ShowNotice(szNotice, true)
	elseif szName == "Btn_Cancel" then
		CloseEmotionManagePanel()
	elseif szName == "Btn_Up" then
		EmotionManagePanel.SwapPosition(this:GetRoot(), -1)
	elseif szName == "Btn_Down" then
		EmotionManagePanel.SwapPosition(this:GetRoot(), 1)
	elseif szName == "Btn_Close" then
		CloseEmotionManagePanel()
	elseif szName == "Btn_Default" then
		local szNotice = g_tExpression.MSG_EMOTION_SURE_SET_DEFAULT
		local fnAction  = function() 
		    local frame = Station.Lookup("Normal/EmotionManagePanel")
		    EmotionManagePanel.RestoreDefaults(frame)
		end
		EmotionManagePanel.ShowNotice(szNotice, true, fnAction, true)
	end
end

function EmotionManagePanel.SwapPosition(frame, nDelta)
  local hList = frame:Lookup("", "Handle_List")
  local nCounts = hList:GetItemCount() - 1
  local nCurPos = nil
   
  for i = 0, nCounts, 1 do
    local hItem = hList:Lookup(i)
    if hItem.bSel then
      nCurPos = i
      break
    end
  end
  
  if nCurPos + nDelta < 0 or nCurPos + nDelta > nCounts then
    return
  end
  
  hList:ExchangeItemIndex(nCurPos, nCurPos + nDelta)
  hList:FormatAllItemPos()
  EmotionManagePanel.bModified = true
end

function EmotionManagePanel.OnItemMouseEnter()
  local szPName = this:GetParent():GetName()
  if szPName == "Handle_List" then
    this.bOver = true
    EmotionManagePanel.UpdateInfoState(this)
  end
end

function EmotionManagePanel.OnItemMouseLeave()
  local szPName = this:GetParent():GetName()
  if szPName == "Handle_List" then
    this.bOver = false
    EmotionManagePanel.UpdateInfoState(this)
  end
end

function EmotionManagePanel.OnItemLButtonDBClick()
	EmotionManagePanel.OnItemLButtonClick() 
end


function EmotionManagePanel.OnItemLButtonClick()
	if this.bJiangHu then
		EmotionManagePanel.Select(this)
    	EmotionManagePanel.ShowContent(this:GetRoot())	
	end
end

function EmotionManagePanel.OnItemMouseWheel()
  local nDistance = Station.GetMessageWheelDelta()
  
  local szName = this:GetName()
  if szName == "Handle_Emotion" then
    this:GetParent():Lookup("Scroll_Command"):ScrollNext(nDistance)
  end
  return 1
end

function EmotionManagePanel.ShowContent(frame)
  local CmdEdit = frame:Lookup("Edit_Command")
  local TargetEdit = frame:Lookup("Edit_Target")
  local NoTargetEdit = frame:Lookup("Edit_NoTarget")
  local CmdTitle = frame:Lookup("", "Text_CmdTitle")
  
  local hItem = EmotionManagePanel.hSelItem
  if hItem then
    local szCmd = hItem.szCmd

    hItem:Lookup("Text_Name"):SetText(szCmd)
    CmdTitle:SetText(szCmd)
    CmdEdit:SetText(string.sub(szCmd, 2))
    
    NoTargetEdit:SetText(hItem.szNoTarget)
    TargetEdit:SetText(hItem.szTarget)
  end
end

function OpenEmotionManagePanel(bDisableSound, rect)
	if IsOpenEmotionManagePanel() then
		return
	end

	local frame = Station.Lookup("Normal/EmotionManagePanel")
	if frame then
		frame:Show()
	else
		frame = Wnd.OpenWindow("EmotionManagePanel")
	end    
	local w, h = frame:GetSize()
	EmotionManagePanel.Rect = rect
	frame:SetAbsPos(rect[1], rect[2] + rect[4] - h)
	frame:CorrectPos()
  	EmotionManagePanel.bModified = false
end

function CloseEmotionManagePanel(bDisableSound)
  if not IsOpenEmotionManagePanel() then
    return
  end
  
  local frame = Station.Lookup("Normal/EmotionManagePanel")
  if frame then
    if EmotionManagePanel.bModified then
      EmotionManagePanel.UpdateTableData(frame)
      FireEvent("JIANGHU_TABLE_UPDATE")
      EmotionManagePanel.bModified = false
    end
    frame:Hide()
    
    OpenEmotionPanel(false, EmotionManagePanel.Rect)
  end
end

function IsOpenEmotionManagePanel()
  local frame = Station.Lookup("Normal/EmotionManagePanel")
  if frame and frame:IsVisible() then
    return true
  end
  return false
end
