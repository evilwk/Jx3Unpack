DebuffList = 
{
	nMax = 16,
	nLine = 1,
	nSize = 40,
	bShowText = true,
	Sort = "left_to_right",
	DefaultAnchor = {s = "TOPLEFT", r = "TOPLEFT",  x = 25, y = 180},
	Anchor = {s = "TOPLEFT", r = "TOPLEFT", x = 25, y = 180},
	AnchorAdjust = {x = 0, y = 20},
}

RegisterCustomData("DebuffList.nSize")
RegisterCustomData("DebuffList.nLine")
RegisterCustomData("DebuffList.bShowText")
RegisterCustomData("DebuffList.Sort")
RegisterCustomData("DebuffList.Anchor")

function DebuffList.OnFrameCreate()
	this:RegisterEvent("BUFF_UPDATE")
	this:RegisterEvent("SYNC_ROLE_DATA_END")
	this:RegisterEvent("DEBUFF_SET_LINE")
	this:RegisterEvent("DEBUFF_SET_SORT")
	this:RegisterEvent("DEBUFF_SET_SHOW_TEXT")
	this:RegisterEvent("DEBUFF_SET_SIZE")
	
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("DEBUFFLIST_ANCHOR_CHANGED")
	this:RegisterEvent("CUSTOM_DATA_LOADED")
	
	DebuffList.Init(this)
	DebuffList.UpdateBuff(this)
	
	DebuffList.UpdateAnchor(this)
	UpdateCustomModeWindow(this, g_tStrings.DEBUFF)	
end

function DebuffList.OnFrameDrag()
end

function DebuffList.OnFrameDragSetPosEnd()
end

function DebuffList.OnFrameDragEnd()
	this:CorrectPos()
	DebuffList.Anchor = GetFrameAnchor(this)
end

function DebuffList.UpdateAnchor(frame)
	if DebuffList.Anchor.x ~= DebuffList.DefaultAnchor.x or DebuffList.Anchor.y ~= DebuffList.DefaultAnchor.y then
		DebuffList.AnchorAdjust.x = 0
		DebuffList.AnchorAdjust.y = 0
	end
	frame:SetPoint(DebuffList.Anchor.s, 0, 0, DebuffList.Anchor.r, DebuffList.Anchor.x + DebuffList.AnchorAdjust.x, DebuffList.Anchor.y + DebuffList.AnchorAdjust.y)
	frame:CorrectPos()
end


function DebuffList.OnEvent(event)
	if event == "BUFF_UPDATE" then
		if arg0 ~= GetClientPlayer().dwID then
			return
		end
		if arg7 then
			DebuffList.UpdateBuff(this)
			return
		end
		if arg3 then
			return
		end
		if IsBuffDispel(arg4, arg8) then 
			DebuffList.UpdateBuff(this)
			return 
		end
		if arg1 then
			DebuffList.RemoveBuff(this, arg2)
			return
		end
		DebuffList.UpdateSingleBuff(this, {nIndex = arg2, dwID = arg4, nStackNum = arg5, nEndFrame = arg6, nLevel = arg8})
	elseif event == "SYNC_ROLE_DATA_END" then
		DebuffList.UpdateBuff(this)
	elseif event == "DEBUFF_SET_LINE" then
		DebuffList.Init(this)
	elseif event == "DEBUFF_SET_SORT" then
		DebuffList.Init(this)
	elseif event == "DEBUFF_SET_SHOW_TEXT" then
		DebuffList.Init(this)
	elseif event == "DEBUFF_SET_SIZE" then
		DebuffList.Init(this)
	elseif event == "UI_SCALED" then
		DebuffList.UpdateAnchor(this)
	elseif event == "ON_ENTER_CUSTOM_UI_MODE" or event == "ON_LEAVE_CUSTOM_UI_MODE" then
		UpdateCustomModeWindow(this)
	elseif event == "DEBUFFLIST_ANCHOR_CHANGED" then
		DebuffList.UpdateAnchor(this)		
	elseif event == "CUSTOM_DATA_LOADED" then
		DebuffList.Init(this)
		DebuffList.UpdateAnchor(this)		
	end
end

function DebuffList.OnFrameBreathe()
	local handle = this:Lookup("", "")
	local hBox = handle:Lookup("Handle_Box")
	local hText = handle:Lookup("Handle_Text")
	local nCount = hBox:GetItemCount() - 1
	local nLogic = GetLogicFrameCount()
	for i = 0, nCount, 1 do
		local box = hBox:Lookup(i)
		if not box:IsVisible() then
			return
		end
		
		if box.Info.bSparking then
			local nLeft = box.Info.nEndFrame - nLogic
			if nLeft < 480 then --30s
				local alpha = box:GetAlpha()
				if box.bAdd then
					alpha = alpha + 20
					if alpha > 255 then
						box.bAdd = false
					end
				else
					alpha = alpha - 20
					if alpha < 0 then
						box.bAdd = true
					end				
				end
				box:SetAlpha(alpha)
			else
				box:SetAlpha(255)
			end						
		end
		local text = hText:Lookup(i)
		if text.Info.bShowTime then
			local nLeft = text.Info.nEndFrame - nLogic
			if nLeft < 0 then nLeft = 0 end
			local nH, nM, nS = GetTimeToHourMinuteSecond(nLeft, true)
			if nH >= 1 then
				if nM >= 1 or nS >= 1 then
					nH = nH + 1
				end			
				text:SetText(nH)
				text:SetFontScheme(162)
			elseif nM >= 1 then
				if nS >= 1 then
					nM = nM + 1
				end			
				text:SetText("  "..nM.."′")
				text:SetFontScheme(163)
			else
				text:SetText("  "..nS.."″")
				text:SetFontScheme(166)
			end
		else
			text:SetText("")
		end
	end
end

function DebuffList.Init(frame)
	local handle = frame:Lookup("", "")
	local hBox = handle:Lookup("Handle_Box")
	local hText = handle:Lookup("Handle_Text")
	handle:SetSize(10000, 10000)
	hBox:SetSize(10000, 10000)
	hText:SetSize(10000, 10000)	
	local nW = math.ceil(DebuffList.nMax / DebuffList.nLine)
	local nIndex = 0
	for i = 1, DebuffList.nLine, 1 do
		local y, yT
		if DebuffList.bShowText then
			y = (i - 1) * (DebuffList.nSize + 20)
			yT = y + DebuffList.nSize
		else
			y = (i - 1) * DebuffList.nSize
			yT = y + DebuffList.nSize
		end
		for j = 1, nW, 1 do
			if nIndex >= DebuffList.nMax then
				break
			end
			local box = hBox:Lookup(nIndex)
			if not box then
				hBox:AppendItemFromString("<box>w=40 h=40 eventid=954 lockshowhide=1 </box>")
				box = hBox:Lookup(nIndex)
			end
			local text = hText:Lookup(nIndex)
			if not text then			
				hText:AppendItemFromString("<text>w=40 h=20 halign=1 lockshowhide=1 </text>")
				text = hText:Lookup(nIndex)
			end
			
			box:SetSize(DebuffList.nSize, DebuffList.nSize)
			text:SetSize(DebuffList.nSize, 20)			
			
			if DebuffList.Sort == "left_to_right" then
				local x = (j - 1) * DebuffList.nSize
				box:SetRelPos(x, y)
				text:SetRelPos(x, yT)
			else
				local x = (nW - j) * DebuffList.nSize
				box:SetRelPos(x, y)
				text:SetRelPos(x, yT)
			end
			nIndex = nIndex + 1
		end
	end
	
	hBox:FormatAllItemPos()
	hBox:SetSizeByAllItemSize()
	if DebuffList.bShowText then
		hText:FormatAllItemPos()
		hText:SetSizeByAllItemSize()
		hText:Show()
	else
		hText:SetSize(0, 0)
		hText:Hide()
	end
	handle:FormatAllItemPos()
	handle:SetSizeByAllItemSize()
	local w, h = handle:GetSize()
	frame:SetSize(w, h)
	DebuffList.UpdateAnchor(frame)
end

function DebuffList.UpdateBuff(frame)
	local handle = frame:Lookup("", "")
	local hBox = handle:Lookup("Handle_Box")
	local hText = handle:Lookup("Handle_Text")
	local nCount = hBox:GetItemCount() - 1
	
	local player = GetClientPlayer()
	local t = nil
	if player then
		t =player.GetBuffList()
	end
	if not t then
		for i = 0, nCount, 1 do
			local box = hBox:Lookup(i)
			if box:IsVisible() then
				box:Hide()
				hText:Lookup(i):Hide()
			else
				break
			end
		end
		return
	end
	
	local nIndex = 0
	local tOtherBuff = {}
	for k, v in ipairs(t) do
		if not v.bCanCancel and Table_BuffIsVisible(v.dwID, v.nLevel) then
			if IsBuffDispel(v.dwID, v.nLevel) then 
				local box = hBox:Lookup(nIndex)
				local text = hText:Lookup(nIndex)
				DebuffList.UpdateSingleBuffInfo(box, text, v)
				nIndex = nIndex + 1
			else
				table.insert(tOtherBuff, k)
			end
		end
	end
	
	Image = handle:Lookup("Image_DebuffBG")
	local _, nHeight = Image:GetSize()
	Image:SetSize(nIndex * 40, nHeight)
	
	for _, v in pairs(tOtherBuff) do 
		local box = hBox:Lookup(nIndex)
		local text = hText:Lookup(nIndex)
		DebuffList.UpdateSingleBuffInfo(box, text, t[v])
		nIndex = nIndex + 1
	end
		
	for i = nIndex, nCount, 1 do
		local box = hBox:Lookup(i)
		if box:IsVisible() then
			box:Hide()
			hText:Lookup(i):Hide()
		else
			break
		end		
	end
end

function DebuffList.RemoveBuff(frame, nIndex)
	local handle = frame:Lookup("", "")
	local hBox = handle:Lookup("Handle_Box")
	local hText = handle:Lookup("Handle_Text")
	local nCount = hBox:GetItemCount() - 1
	local nBoxIndex = nil
	for i = 0, nCount, 1 do
		local box = hBox:Lookup(i)
		if not box:IsVisible() then
			return
		end
		
		if box.Info.nIndex == nIndex then
			nBoxIndex = i
			break
		end
	end
	
	if not nBoxIndex then
		return
	end
	
	for i = nBoxIndex + 1, nCount, 1 do
		local box = hBox:Lookup(i)
		if box:IsVisible() then
			local boxP = hBox:Lookup(i - 1)
			boxP.Info = box.Info
			boxP:SetObject(box:GetObject())
			boxP:SetObjectIcon(box:GetObjectIcon())
			boxP:SetObjectCoolDown(box:IsObjectCoolDown())
			boxP:SetCoolDownPercentage(box:GetCoolDownPercentage())
			boxP:SetOverText(0, box:GetOverText(0))
			boxP:SetAlpha(box:GetAlpha())
			local text = hText:Lookup(i)
			local textP = hText:Lookup(i - 1)
			textP.Info = text.Info
			textP:SetText(text:GetText())
			textP:SetFontScheme(text:GetFontScheme())
		else
			hBox:Lookup(i - 1):Hide()
			hText:Lookup(i - 1):Hide()
			return
		end
	end
	hBox:Lookup(nCount):Hide()
	hText:Lookup(nCount):Hide()
end

function DebuffList.UpdateSingleBuffInfo(box, text, v)
	local dwID, nLevel = v.dwID, v.nLevel
	box:Show()
	box:SetAlpha(255)
	box.Info = v
	box.Info.bSparking = Table_BuffNeedSparking(dwID, nLevel)
	box.Info.bShowTime = Table_BuffNeedShowTime(dwID, nLevel)
	box:SetObject(UI_OBJECT_NOT_NEED_KNOWN, dwID)
	box:SetObjectIcon(Table_GetBuffIconID(dwID, nLevel))
	if v.nStackNum > 1 then
		box:SetOverText(0, v.nStackNum)
	else
		box:SetOverText(0, "")
	end
	
	text:Show()
	text.Info = box.Info
	
	FireHelpEvent("OnAddBuff", dwID, nLevel, box)
end

function DebuffList.UpdateSingleBuff(frame, v)
	local dwID, nLevel = v.dwID, v.nLevel
	if not Table_BuffIsVisible(dwID, nLevel) then
		return
	end
	
	local handle = frame:Lookup("", "")
	local hBox = handle:Lookup("Handle_Box")
	local hText = handle:Lookup("Handle_Text")
	local nCount = hBox:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local box = hBox:Lookup(i)
		if box:IsVisible() then
			if box.Info.nIndex == v.nIndex then
				local text = hText:Lookup(i)
				DebuffList.UpdateSingleBuffInfo(box, text, v)
				return
			end
		else
			local text = hText:Lookup(i)
			DebuffList.UpdateSingleBuffInfo(box, text, v)
			return
		end
	end
end

function DebuffList.OnItemMouseEnter()
	if this:GetType() == "Box" then
		this:SetObjectMouseOver(1)
		local nTime = math.floor(this.Info.nEndFrame - GetLogicFrameCount()) / 16 + 1
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputBuffTip(GetClientPlayer().dwID, this.Info.dwID, this.Info.nLevel, this.Info.nStackNum, this.Info.bShowTime, nTime, {x, y, w, h})					
	end
end

function DebuffList.OnItemRefreshTip()
	return DebuffList.OnItemMouseEnter()
end

function DebuffList.OnItemMouseHover()
	DebuffList.OnItemMouseEnter()
end

function DebuffList.OnItemMouseLeave()
	if this:GetType() == "Box" then
		HideTip()
		this:SetObjectMouseOver(0)
	end		
end

-- 下面这个函数现在用来处理七夕宣传界面的弹出功能 397行
function DebuffList.OnItemLButtonClick()
	if not this.Info then
		return
	end
	local _,_,szVersionLineName,szVersionType = GetVersion()
--	if this.Info.dwID == 2081 then
--		if szVersionLineName == "zhcn" and szVersionType ~= "snda" then	--金山版本（包括体服）
	--		OpenCoures(219) --金山版血眼龙王活动宣传图
--		elseif szVersionLineName == "zhintl" then --马来版
	--		OpenCoures(212)	--春节活动
--		elseif szVersionLineName == "zhcn" and szVersionType == "snda" then --盛大版本			
		--	OpenCoures(211)	--春节活动
--		end		
--	end
	--if this.Info.dwID == 2524  or this.Info.dwID == 2209  then	--新玩家养成计划
--		if szVersionLineName == "zhcn" and szVersionType == "" then--金山版界面
--			OpenCoures(213)
--		end
--		if szVersionLineName == "zhcn" and szVersionType == "snda" then--盛大版界面
	--		OpenCoures(214)	
	--	end
--	end
	--if this.Info.dwID == 2641 then
	--	if szVersionLineName == "zhcn" and szVersionType ~= "snda" then	--金山版本（包括体服）
	--		OpenCoures(222) --资料片宣传
	--	elseif szVersionLineName == "zhintl" then --马来版
	--		OpenCoures(222)	--资料片宣传
	--	elseif szVersionLineName == "zhcn" and szVersionType == "snda" then --盛大版本			
	--		OpenCoures(222)	--资料片宣传
--		end
	--end
--	if this.Info.dwID == 2782 then--只有盛大版加这个buff
--		OpenCoures(220)	--盛大版血眼龙王活动宣传图
--	end
--	if this.Info.dwID == 2950 then
	--	OpenCoures(221)
--	end
--	if this.Info.dwID == 2996 then
--		OpenCoures(223)
--	end
--	if this.Info.dwID == 3050 then
--		OpenCoures(224)
--	end
--	if this.Info.dwID == 3128 then--七夕
--		OpenCoures(200)	--七夕
--	end
--	if this.Info.dwID == 3237 then -- 中秋
--		OpenCoures(203)	-- 中秋
--	end
--	if this.Info.dwID == 3272 then -- 9月15日
--		OpenCoures(231)	-- 9月15日
-- 	end
	if this.Info.dwID == 3478 then -- 11月17日
		OpenCoures(232)	-- 11月17日
	end
	if this.Info.dwID == 3492 then -- 11月17日
		OpenCoures(233)	-- 12月8日
	end
	if this.Info.dwID == 3606 then -- 2011年12月15日
		OpenCoures(234)	-- 2011年12月15日
	end
	if this.Info.dwID == 3687 then -- 2012年1月16日  春节活动
		OpenCoures(235)	-- -- 2012年1月16日
	end
	if this.Info.dwID == 3719 then -- 2012年2月13日  情人节活动
		OpenCoures(237)	-- -- 2012年2月13日
	end
	if this.Info.dwID == 3750 then -- 2012年2月20日  可人莫雨活动
	
		OpenCoures(238)	-- -- 2012年2月20日
	end
	if this.Info.dwID == 3847 then -- 2012年3月29日  清明节活动
			OpenCoures(239)	-- -- 2012年3月29日
	end
	if this.Info.dwID == 3910 then  --2012年4月19日  烛龙殿资料片开启
		OpenCoures(240)		--2012年4月19日  烛龙殿资料片开启
	end
end

function OpenDebuffList()
	local frame = Wnd.OpenWindow("DebuffList")
	DebuffList.Init(frame)
end

function SetDebuffListLine(nLine)
	if DebuffList.nLine == nLine then
		return
	end
	
	DebuffList.nLine = nLine
	FireEvent("DEBUFF_SET_LINE")
end

function GetDebuffListLine()
	return DebuffList.nLine
end

function SetDebuffListShowText(bShow)
	if DebuffList.bShowText == bShow then
		return
	end
	
	DebuffList.bShowText = bShow
	
	FireEvent("DEBUFF_SET_SHOW_TEXT")
end

function SetDebuffListSize(nSize)
	if nSize < 12 then
		nSize = 12
	end
	if nSize > 64 then
		nSize = 64
	end
	
	if DebuffList.nSize == nSize then
		return
	end
	
	DebuffList.nSize = nSize
	FireEvent("DEBUFF_SET_SIZE")
end

function GetDebuffListSize()
	return DebuffList.nSize
end

function IsDebuffListShowText()
	return DebuffList.bShowText
end

function SetDebuffListSortType(szType)
	if DebuffList.Sort == szType then
		return
	end
	
	DebuffList.Sort = szType
	
	FireEvent("DEBUFF_SET_SORT")
end

function GetDebuffListSortType()
	return DebuffList.Sort
end

function SetDebuffListAnchor(Anchor)
	DebuffList.Anchor = Anchor
	
	FireEvent("DEBUFFLIST_ANCHOR_CHANGED")
end

function GetDebuffListAnchor(Anchor)
	return DebuffList.Anchor
end

function DebuffList_SetAnchorDefault()
	DebuffList.Anchor.s = DebuffList.DefaultAnchor.s
	DebuffList.Anchor.r = DebuffList.DefaultAnchor.r
	DebuffList.Anchor.x = DebuffList.DefaultAnchor.x
	DebuffList.Anchor.y = DebuffList.DefaultAnchor.y
	FireEvent("DEBUFFLIST_ANCHOR_CHANGED")
end

RegisterEvent("CUSTOM_UI_MODE_SET_DEFAULT", DebuffList_SetAnchorDefault)
