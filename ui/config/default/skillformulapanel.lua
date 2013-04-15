SkillFormulaPanel = {bHas = false, bCannot = true, bCan = true}

RegisterCustomData("SkillFormulaPanel.bHas")
RegisterCustomData("SkillFormulaPanel.bCannot")
RegisterCustomData("SkillFormulaPanel.bCan")

function SkillFormulaPanel.OnFrameCreate()
	this:RegisterEvent("MONEY_UPDATE")
	this:RegisterEvent("PLAYER_LEVEL_UPDATE")
	this:RegisterEvent("SKILL_UPDATE")
	this:RegisterEvent("RECIPE_UPDATE")
	
	SkillFormulaPanel.UpdateMoneyShow(this:Lookup("", ""), true, GetClientPlayer().GetMoney())
	
	local npc = GetNpc(SkillFormulaPanel.dwNpc)
	if npc then
		this:Lookup("", "Text_Title"):SetText(npc.szName)
	end
	
	if SkillFormulaPanel.bSkill then
		SkillFormulaPanel.UpdateSkillList(this)
	else
		SkillFormulaPanel.UpdateCraftList(this)
	end
	
	InitFrameAutoPosInfo(this, 1, "Dialog", nil, function() CloseSkillFormulaPanel(true) end)  
end

function SkillFormulaPanel.OnFrameBreathe()
	local player = GetClientPlayer()
	if not player or player.nMoveState == MOVE_STATE.ON_DEATH then
		CloseSkillFormulaPanel()
		return
	end
	
	if not SkillFormulaPanel.dwNpc then
		CloseSkillFormulaPanel()
	else
		local npc = GetNpc(SkillFormulaPanel.dwNpc)
		if not npc or not npc.CanDialog(player) then
			CloseSkillFormulaPanel()
		end
	end
end

function SkillFormulaPanel.UpdateCraftList(frame)
	local player = GetClientPlayer()
	local npc = GetNpc(SkillFormulaPanel.dwNpc)
	if not npc then
		CloseSkillFormulaPanel()
		return
	end
	local szIniFile = "UI/Config/Default/SkillFormulaPanel.ini"
	local handle = frame:Lookup("", "Handle_List")
	handle:Clear()
		
	local fnSel = function(hT)
		if hT.bSel then
			return
		end
		local hP = hT:GetParent()
		local nCount = hP:GetItemCount() - 1
		for i = 0, nCount, 1 do
			local hI = hP:Lookup(i)
			if hI.bSel then
				if hI.nFont then
					hI:Lookup(1):SetFontScheme(hI.nFont)
					hT:Lookup(0):SetFrame()
					hI.nFont = nil
				end
				hI:Lookup(0):Hide()
				hI.bSel = false
				break
			end
		end
		hP.dwCraftID = hT.dwCraftID
		hP.dwRecipeID = hT.dwRecipeID
		hT.bSel = true
		hT.nFont = hT:Lookup(1):GetFontScheme()
		hT:Lookup(1):SetFontScheme(0)
		hT:Lookup(0):Show()
		hT:Lookup(0):SetAlpha(255)
		SkillFormulaPanel.UpdateCraftInfo(hT:GetRoot(), hP.dwCraftID, hP.dwRecipeID, hT.bHas, hT.bCannot)	
	end
	
	local fnDown = function()
		this:GetParent():GetParent().bInfo = false
		if IsCtrlKeyDown() then
			EditBox_AppendLinkRecipe(this.dwCraftID, this.dwRecipeID)
		end
		this:Sel()
	end
	
	local fnEnter = function()
		if not this.bSel then
			this:Lookup(0):Show()
			this:Lookup(0):SetAlpha(128)
		end
	end
	
	local fnLeave = function()
		if not this.bSel then
			if this:Lookup(0) then
				this:Lookup(0):Hide()
			end
		end
	end
	
	local fnAppend = function(handle, v)
		handle:AppendItemFromIni(szIniFile, "TreeLeaf_Title", "")
		local hS = handle:Lookup(handle:GetItemCount() - 1)
		hS.dwCraftID = v.dwCraftID
		hS.dwRecipeID = v.dwRecipeID
		hS.bHas = v.bHas
		hS.bCannot = v.bCannot
		
		local nFont = 80
		local nFrame = 2
		if hS.bHas then
			nFont = 61
			nFrame = 3
		elseif hS.bCannot then
			nFont = 71
			nFrame = 1
		else
			hS.bCan = true
		end
		hS:Lookup(0):SetFrame(nFrame)
		hS:Lookup(1):SetFontScheme(nFont)
		
		local recipe = GetRecipe(v.dwCraftID, v.dwRecipeID)
		local szRecipeName = Table_GetRecipeName(v.dwCraftID, v.dwRecipeID)
		hS:Lookup(1):SetText(szRecipeName)
		hS:Lookup(2):SetText("")
		
		hS.Sel = fnSel
		hS.OnItemLButtonDown = fnDown
		hS.OnItemMouseEnter = fnEnter
		hS.OnItemMouseLeave = fnLeave
	end
	
	local aCraft = GetMasterRecipeList(SkillFormulaPanel.dwMasterID, SkillFormulaPanel.bCan, SkillFormulaPanel.bHas, SkillFormulaPanel.bCannot)
	if not aCraft then
		aCraft = {}
	end
	
	for k, v in pairs(aCraft) do
		local aLearnInfo = GetRecipeLearnInfo(SkillFormulaPanel.dwMasterID, v.dwCraftID, v.dwRecipeID)	
		v.nSortKey = aLearnInfo.nProfessionLevel
		v.nSortKeyTwo = k
	end
	
	local function fCmp(a, b)
		if a.nSortKey == b.nSortKey then 
			return a.nSortKeyTwo < b.nSortKeyTwo
		else
			return a.nSortKey < b.nSortKey
		end
	end
	table.sort(aCraft, fCmp)
	
	for k, v in ipairs(aCraft) do
		fnAppend(handle, v)
	end
	SkillFormulaPanel.UpdateListScroll(handle)
	
	local bFind = false
	local nCount = handle:GetItemCount() - 1
	local hOk = nil
	for i = 0, nCount, 1 do
		local hI = handle:Lookup(i)
		if hI.dwCraftID == handle.dwCraftID and hI.dwRecipeID == handle.dwRecipeID then
			if hI.bCan then
				hI:Sel()
				SkillFormulaPanel.LocateListScroll(handle, hI)
				bFind = true
				break
			else
				if not hOk or not hOk.bcan then
					hOk = hI
				end
			end
		else
			if hOk then
				if not hOk.bCan and hI.bCan then
					hOk = hI
				end
			else
				hOk = hI
			end
		end
	end
	
	if not bFind then
		if hOk then
			hOk:Sel()
			SkillFormulaPanel.LocateListScroll(handle, hOk)
		else
			handle.dwCraftID = nil
			handle.dwRecipeID = nil
			SkillFormulaPanel.ClearInfo(frame)
		end
	end	
end

function SkillFormulaPanel.UpdateCraftInfo(frame, dwCraftID, dwRecipeID, bHas, bCannot)
	local handle = frame:Lookup("", "Handle_Info")
	handle.dwCraftID = dwCraftID
	handle.dwRecipeID = dwRecipeID
	handle.bHas = bHas
	handle.bCannot = bCannot
	
	handle:Clear()
	
	local recipe = GetRecipe(dwCraftID, dwRecipeID)
	if not recipe then
		handle:Hide()
		return
	end
	
	local szIniFile = "UI/Config/Default/SkillFormulaPanel.ini"
	handle:AppendItemFromIni(szIniFile, "Handle_Title")
	
	local hI = handle:Lookup(handle:GetItemCount() - 1)
	local box = hI:Lookup("Box_SkillName")
	box:ClearObject()
	
	local text = hI:Lookup("Text_SkillTitle")
	--[[
	text:SetText(recipe.szName)
	local nFont = 31
	if bHas then
		nFont = 31
	elseif bCannot then
		nFont = 31
	end
	text:SetFontScheme(nFont)
	]]
	local itemInfo = SkillFormulaPanel.UpdateCraftInfoItem(text, box, recipe, dwCraftID, dwRecipeID)
	hI:Lookup("Text_SkillTitleL"):SetText("")
	
	if not bHas then
		local player = GetClientPlayer()
		local aLearnInfo = GetRecipeLearnInfo(SkillFormulaPanel.dwMasterID, dwCraftID, dwRecipeID)
		if aLearnInfo then
			if aLearnInfo.nPrice > 0 then
				local nFont = 162
				if player.GetMoney() < aLearnInfo.nPrice then
					nFont = 102
				end
				handle:AppendItemFromString("<text>text="..EncodeComponentsString(g_tStrings.STR_LEARN_NEED_MONEY).."font="..nFont.."</text>"..GetMoneyTipText(aLearnInfo.nPrice, nFont))
			end
			
			local szProName = Table_GetProfessionName(aLearnInfo.dwProfessionID)
			local prof = GetProfession(aLearnInfo.dwProfessionID)
			local szText = FormatString(g_tStrings.STR_LEARN_NEED_SKILL, szProName, FormatString(g_tStrings.STR_FRIEND_WTHAT_LEVEL1, aLearnInfo.nProfessionLevel))
			local nFont = 162
			local nProMaxLevel               = player.GetProfessionMaxLevel(aLearnInfo.dwProfessionID)
	        local nProLevel                  = player.GetProfessionLevel(aLearnInfo.dwProfessionID)
	        local nProAdjustLevel            = player.GetProfessionAdjustLevel(aLearnInfo.dwProfessionID) or 0
	        --local nProExp                    = player.GetProfessionProficiency(aLearnInfo.dwProfessionID)
	        
	        nProLevel = math.min((nProLevel + nProAdjustLevel), nProMaxLevel)
			if aLearnInfo.nProfessionLevel > nProLevel then
				nFont = 102
			end
			handle:AppendItemFromString("<text>text="..EncodeComponentsString(szText).."font="..nFont.."</text>")
			
			if aLearnInfo.dwBranchID ~= 0 then
				local szText = FormatString(g_tStrings.STR_LEARN_NEED_PART, Table_GetBranchName(aLearnInfo.dwProfessionID, aLearnInfo.dwBranchID))
				local nFont = 162
				if player.GetProfessionBranch(aLearnInfo.dwProfessionID) ~= aLearnInfo.dwBranchID then
					nFont = 102
				end
				handle:AppendItemFromString("<text>text="..EncodeComponentsString(szText).."font="..nFont.."</text>")
			end
			
			if aLearnInfo.dwReputationID ~= 0 then
				local szText = FormatString(g_tStrings.STR_LEARN_NEED_REPUT, g_tReputation.tReputationTable[aLearnInfo.dwReputationID].szName, g_tReputation.tReputationLevelTable[aLearnInfo.nReputationLevel].szLevel)
				local nFont = 162
				if player.GetReputeLevel(aLearnInfo.dwReputationID) < aLearnInfo.nReputationLevel then
					nFont = 102
				end
				handle:AppendItemFromString("<text>text="..EncodeComponentsString(szText).."font="..nFont.."</text>")
			end			
		end
	end
	
	if itemInfo then
		handle:AppendItemFromString("<text>text=\"\\\n\"</text>"..GetItemDesc(itemInfo.nUiId))
	end

	if bHas or bCannot then
		frame:Lookup("Btn_Study"):Enable(false)
	else
		frame:Lookup("Btn_Study"):Enable(true)
	end
	
	handle:Show()
	SkillFormulaPanel.UpdateInfoScroll(handle)
end

function SkillFormulaPanel.UpdateCraftInfoItem(textP, boxP, recipe, dwCraftID, dwRecipeID)
	if recipe.nCraftType == ALL_CRAFT_TYPE.ENCHANT then
		local szName = Table_GetEnchantName(recipe.dwProfessionID, dwCraftID, dwRecipeID)
		local nIconID = Table_GetEnchantIconID(recipe.dwProfessionID, dwCraftID, dwRecipeID)
		local nQuality = Table_GetEnchantQuality(recipe.dwProfessionID, dwCraftID, dwRecipeID)
		
		textP:SetText(szName)
		textP:SetFontColor(GetItemFontColorByQuality(nQuality, false))
		boxP:SetObject(UI_OBJECT_CRAFT, recipe.dwProfessionID, dwCraftID, dwRecipeID)
		boxP:SetObjectIcon(nIconID)
		
		boxP.OnItemLButtonClick=function()
			if IsCtrlKeyDown() then
				local nProID, nCraftID, nRecipeID = this:GetObjectData()
				EditBox_AppendLinkEnchant(nProID, nCraftID, nRecipeID)
			end
		end
		
		boxP.OnItemMouseEnter=function()
			local nProID, nCraftID, nRecipeID = this:GetObjectData()
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			OutputEnchantTip(nProID, nCraftID, nRecipeID, {x, y, w, h})
		end
		
		boxP.OnItemMouseLeave=function()
			HideTip()
		end
	else
		local nType = recipe.dwCreateItemType1
		local nID	= recipe.dwCreateItemIndex1
		local ItemP = GetItemInfo(nType, nID)
		
		local szRecipeName = Table_GetRecipeName(dwCraftID, dwRecipeID)
		textP:SetText(szRecipeName)
		textP:SetFontColor(GetItemFontColorByQuality(ItemP.nQuality, false))
		boxP:SetObject(UI_OBJECT_ITEM_INFO, ItemP.nUiId, GLOBAL.CURRENT_ITEM_VERSION, nType, nID)
		boxP:SetObjectIcon(Table_GetItemIconID(ItemP.nUiId))
		UpdateItemBoxExtend(boxP, ItemP)
		
		boxP.OnItemLButtonClick=function()
			if IsCtrlKeyDown() then
				local _, dwVer, nTabType, nIndex = this:GetObjectData()
				if IsGMPanelReceiveItem() then
					GMPanel_LinkItemInfo(dwVer, nTabType, nIndex)
				else		
					EditBox_AppendLinkItemInfo(dwVer, nTabType, nIndex)
				end
			end
		end
		
		boxP.OnItemMouseEnter=function()
			local _, dwVer, nTabType, nIndex = this:GetObjectData()
			local x, y = this:GetAbsPos()
			local w, h = this:GetSize()
			OutputItemTip(UI_OBJECT_ITEM_INFO, dwVer, nTabType, nIndex, {x, y, w, h})
		end
		
		boxP.OnItemMouseLeave=function()
			HideTip()
		end
		return ItemP
	end
end

function SkillFormulaPanel.UpdateSkillList(frame)
	local player = GetClientPlayer()
	local npc = GetNpc(SkillFormulaPanel.dwNpc)
	if not npc then
		CloseSkillFormulaPanel()
		return
	end
	local szIniFile = "UI/Config/Default/SkillFormulaPanel.ini"
	local handle = frame:Lookup("", "Handle_List")
	local aCollapse = {}
	local nCount = handle:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = handle:Lookup(i)
		if hI.bKungfu  and not hI:IsExpand() then
			table.insert(aCollapse, hI.dwID)
		end
	end
	
	handle:Clear()
	
	local fnSel = function(hT)
		if hT.bSel then
			return
		end
		local hP = hT:GetParent()
		local nCount = hP:GetItemCount() - 1
		for i = 0, nCount, 1 do
			local hI = hP:Lookup(i)
			if hI.bSel then
				if hI.nFont then
					hI:Lookup(1):SetFontScheme(hI.nFont)
					hI.nFont = nil
				end
				hI:Lookup(0):Hide()
				hI.bSel = false
				break
			end
		end
		hP.dwID = hT.dwID
		hT.bSel = true
		hT.nFont = hT:Lookup(1):GetFontScheme()
		hT:Lookup(1):SetFontScheme(0)
		if hT.bHas then
			hT:Lookup(0):SetFrame(3)
		elseif hT.bCannot then
			hT:Lookup(0):SetFrame(1)
		else
			hT:Lookup(0):SetFrame(2)
		end		
		hT:Lookup(0):Show()
		hT:Lookup(0):SetAlpha(255)
		SkillFormulaPanel.UpdateSkillInfo(hT:GetRoot(), hT.dwID, hT.dwLevel, hT.bHas, hT.bCannot)	
	end
	
	local fnDown = function()
		this:GetParent():GetParent().bInfo = false
		this:Sel()
		if this.bKungfu and this:PtInIcon(Cursor.GetPos()) then
			this:ExpandOrCollapse()
			PlaySound(SOUND.UI_SOUND,g_sound.Button)
			SkillFormulaPanel.UpdateListScroll(this:GetParent())
		end
	end
	
	local fnEnter = function()
		if not this.bSel then
			this:Lookup(0):Show()
			this:Lookup(0):SetAlpha(128)
		end		
	end
	
	local fnLeave = function()
		if not this.bSel then
			if this:Lookup(0) then
				this:Lookup(0):Hide()
			end
		end		
	end
	
	local fnAppend = function(handle, v, bKungfu)
		if bKungfu then
			handle:AppendItemFromIni(szIniFile, "TreeLeaf_Title", "")
		else
			handle:AppendItemFromIni(szIniFile, "TreeLeaf_Content", "")
		end
		local hS = handle:Lookup(handle:GetItemCount() - 1)
		hS.dwID = v.dwID
		hS.dwLevel = v.dwLevel
		if hS.dwLevel == 0 then
			hS.dwLevel = 1
		end				
		hS.bHas = v.bHas
		hS.bCannot = v.bCannot
		hS.bKungfu = bKungfu
		
		local nFont = 80
		local nFrame = 2
		if hS.bHas then
			nFont = 61
			nFrame = 3
		elseif hS.bCannot then
			nFont = 71
			nFrame = 1
		else
			hS.bCan = true
		end
		hS:Lookup(0):SetFrame(nFrame)
		hS:Lookup(1):SetFontScheme(nFont)
		hS:Lookup(1):SetText(Table_GetSkillName(hS.dwID, hS.dwLevel))
		hS:Lookup(2):SetText(FormatString(g_tStrings.STR_SKILL_H_THE_WHAT_LEVEL1, NumberToChinese(v.dwLevel)))
		
		hS.Sel = fnSel
		hS.OnItemLButtonDown = fnDown
		hS.OnItemMouseEnter = fnEnter
		hS.OnItemMouseLeave = fnLeave
	end
	
	local aKungfu = GetMasterSkillList(SkillFormulaPanel.dwMasterID, SkillFormulaPanel.bCan, SkillFormulaPanel.bHas, SkillFormulaPanel.bCannot)
	
	local function MySort(t)
		for i, v in ipairs (t) do 
			v.nSortIndex = i
		end
		local function MyCompare(a, b) 
			if a.nRLevel == b.nRLevel then 
				return a.nSortIndex < b.nSortIndex
			else
				return a.nRLevel < b.nRLevel
			end
		end
		table.sort(t, MyCompare)
	end
	
	MySort(aKungfu)
	for index, vKungfu in ipairs(aKungfu) do
		fnAppend(handle, vKungfu, true)
		local aSkill = vKungfu.aSkill
		
		MySort(aSkill)
		for k, vSkill in ipairs(aSkill) do
			fnAppend(handle, vSkill, false)
		end
	end
	
	local nCount = handle:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local hI = handle:Lookup(i)
		local bInC = false
		for k, v in pairs(aCollapse) do
			if hI.dwID == v then
				bInC = true
			end
		end
		if bInC then
			hI:Collapse()
		else
			hI:Expand()
		end
	end
	
	SkillFormulaPanel.UpdateListScroll(handle)
	
	local bFind = false
	local nCount = handle:GetItemCount() - 1
	local hOk = nil
	for i = 0, nCount, 1 do
		local hI = handle:Lookup(i)
		if hI.dwID == handle.dwID then
			if hI.bCan then
				hI:Sel()
				SkillFormulaPanel.LocateListScroll(handle, hI)
				bFind = true
				break
			else
				if not hOk or not hOk.bCan then
					hOk = hI
				end
			end
		else
			if hOk then
				if not hOk.bCan and hI.bCan then
					hOk = hI
				end
			else
				hOk = hI
			end			
		end
	end
	if not bFind then
		if hOk then
			hOk:Sel()
			SkillFormulaPanel.LocateListScroll(handle, hOk)
		else
			handle.dwID = nil
			SkillFormulaPanel.ClearInfo(frame)
		end
	end
end

function SkillFormulaPanel.UpdateListScroll(handle)
	handle:FormatAllItemPos()
	local w, h = handle:GetSize()
	local wAll, hAll = handle:GetAllItemSize()
	local scroll = handle:GetRoot():Lookup("Scroll_List")
	
	local nStep = math.ceil((hAll - h) / 10)	
	if nStep > 0 then
		scroll:Show()
		scroll:GetParent():Lookup("Btn_ListUp"):Show()
		scroll:GetParent():Lookup("Btn_ListDown"):Show()
	else
		scroll:Hide()
		scroll:GetParent():Lookup("Btn_ListUp"):Hide()
		scroll:GetParent():Lookup("Btn_ListDown"):Hide()			
	end	
	scroll:SetStepCount(nStep)
end

function SkillFormulaPanel.UpdateInfoScroll(handle)
	local scroll = handle:GetRoot():Lookup("Scroll_Info")
	if handle:IsVisible() then	
		handle:FormatAllItemPos()
		local w, h = handle:GetSize()
		local wAll, hAll = handle:GetAllItemSize()
		
		local nStep = math.ceil((hAll - h) / 10)	
		if nStep > 0 then
			scroll:Show()
			scroll:GetParent():Lookup("Btn_InfoUp"):Show()
			scroll:GetParent():Lookup("Btn_InfoDown"):Show()
		else
			scroll:Hide()
			scroll:GetParent():Lookup("Btn_InfoUp"):Hide()
			scroll:GetParent():Lookup("Btn_InfoDown"):Hide()			
		end	
		scroll:SetStepCount(nStep)
	else
		scroll:Hide()
		scroll:GetParent():Lookup("Btn_InfoUp"):Hide()
		scroll:GetParent():Lookup("Btn_InfoDown"):Hide()	
		scroll:SetStepCount(0)
	end
end

function SkillFormulaPanel.OnScrollBarPosChanged()
	local nCurrentValue = this:GetScrollPos()
	local frame = this:GetParent()
	local szName = this:GetName()
	if szName == "Scroll_List" then	
		if nCurrentValue == 0 then
			frame:Lookup("Btn_ListUp"):Enable(0)
		else
			frame:Lookup("Btn_ListUp"):Enable(1)
		end
		if nCurrentValue == this:GetStepCount() then
			frame:Lookup("Btn_ListDown"):Enable(0)
		else
			frame:Lookup("Btn_ListDown"):Enable(1)
		end
	    frame:Lookup("", "Handle_List"):SetItemStartRelPos(0, - nCurrentValue * 10)	
	elseif szName == "Scroll_Info" then
		if nCurrentValue == 0 then
			frame:Lookup("Btn_InfoUp"):Enable(0)
		else
			frame:Lookup("Btn_InfoUp"):Enable(1)
		end
		if nCurrentValue == this:GetStepCount() then
			frame:Lookup("Btn_InfoDown"):Enable(0)
		else
			frame:Lookup("Btn_InfoDown"):Enable(1)
		end
	    frame:Lookup("", "Handle_Info"):SetItemStartRelPos(0, - nCurrentValue * 10)		
	end
end

function SkillFormulaPanel.OnLButtonDown()
	local szName = this:GetName()
	if szName == "Btn_Filter" then
		if this.bIgnor then
			this.bIgnor = nil
			return
		end
		
		if not this:IsEnabled() then
			return
		end
		
		local fnA = function(u, b)
			if u == 1 then
				SkillFormulaPanel.bCan = b
			elseif u == 2 then
				SkillFormulaPanel.bCannot = b
			elseif u == 3 then
				SkillFormulaPanel.bHas = b
			end
			local frame = Station.Lookup("Normal/SkillFormulaPanel")
			if frame and frame:IsVisible() then
				if SkillFormulaPanel.bSkill then
					SkillFormulaPanel.UpdateSkillList(frame)
				else
					SkillFormulaPanel.UpdateCraftList(frame)
				end
			end
		end
		
		local text = this:Lookup("", "Text_Filter")
		local xA, yA = text:GetAbsPos()
		local w, h = text:GetSize()
		local menu = 
		{
			nMiniWidth = w,
			x = xA, y = yA + h,
			fnCancelAction = function() 
				local btn = Station.Lookup("Normal/SkillFormulaPanel/Btn_Filter") 
				if btn then
					local x, y = Cursor.GetPos()
					local xA, yA = btn:GetAbsPos()
					local w, h = btn:GetSize()
					if x >= xA and x < xA + w and y >= yA and y <= yA + h then
						btn.bIgnor = true
					end
				end
			end,
			fnAutoClose = function() return not IsSkillFormulaPanelOpened() end,
			{szOption = g_tStrings.FORMULA_AVAILABLE, bCheck = true, bChecked = SkillFormulaPanel.bCan, UserData = 1, fnAction = fnA },
			{szOption = g_tStrings.FORMULA_UNAVAILABLE, bCheck = true, bChecked = SkillFormulaPanel.bCannot, UserData = 2, fnAction = fnA },
			{szOption = g_tStrings.FORMULA_LEARNED, bCheck = true, bChecked = SkillFormulaPanel.bHas, UserData = 3, fnAction = fnA }
		}
		PopupMenu(menu)	
		return true		
	else
		SkillFormulaPanel.OnLButtonHold()
	end
end

function SkillFormulaPanel.OnLButtonHold()
	local szSelfName = this:GetName()
	if szSelfName == "Btn_ListUp" then
		this:GetParent():Lookup("Scroll_List"):ScrollPrev(1)
	elseif szSelfName == "Btn_ListDown" then
		this:GetParent():Lookup("Scroll_List"):ScrollNext(1)	
	elseif szSelfName == "Btn_InfoUp" then
		this:GetParent():Lookup("Scroll_Info"):ScrollPrev(1)	
	elseif szSelfName == "Btn_InfoDown" then
		this:GetParent():Lookup("Scroll_Info"):ScrollNext(1)			
    end
end

function SkillFormulaPanel.OnItemLButtonDown()
	local szName = this:GetName()
	if szName == "Handle_List" then
		this:GetParent().bInfo = false
	elseif szName == "Handle_Info" then
		this:GetParent().bInfo = true
	end
end

function SkillFormulaPanel.OnItemMouseWheel()
	local nDistance = Station.GetMessageWheelDelta()
	if this.bInfo then
		this:GetRoot():Lookup("Scroll_Info"):ScrollNext(nDistance)
	else
		this:GetRoot():Lookup("Scroll_List"):ScrollNext(nDistance)
	end
	return 1
end

function SkillFormulaPanel.ClearInfo(frame)
	local handle = frame:Lookup("", "Handle_Info")
	handle:Hide()
	
	handle.dwID = nil
	handle.dwLevel = nil
	handle.bHas = nil
	handle.bCannot = nil
	
	frame:Lookup("Btn_Study"):Enable(false)
	SkillFormulaPanel.UpdateInfoScroll(handle)
end

function SkillFormulaPanel.UpdateSkillInfo(frame, dwID, dwLevel, bHas, bCannot)
	local handle = frame:Lookup("", "Handle_Info")
	handle.dwID = dwID
	handle.dwLevel = dwLevel
	handle.bHas = bHas
	handle.bCannot = bCannot
	
	handle:Clear()
	
	local player = GetClientPlayer()
	local szIniFile = "UI/Config/Default/SkillFormulaPanel.ini"
	handle:AppendItemFromIni(szIniFile, "Handle_Title")
	
	local hI = handle:Lookup(handle:GetItemCount() - 1)
	local box = hI:Lookup("Box_SkillName")
	box:SetObject(UI_OBJECT_SKILL, dwID, dwLevel)
	box:SetObjectIcon(Table_GetSkillIconID(dwID, dwLevel))
	box.OnItemMouseEnter = function()
		this:SetObjectMouseOver(true)
		local dwSkillID, dwLevel = this:GetObjectData()
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		OutputSkillTip(dwSkillID, dwLevel, {x, y, w, h}, false)
	end
	box.OnItemMouseLeave = function()
		this:SetObjectMouseOver(false)
		HideTip()
	end
	
	local text = hI:Lookup("Text_SkillTitle")
	text:SetText(Table_GetSkillName(dwID, dwLevel))
	local nFont = 31
	if bHas then
		nFont = 31
	elseif bCannot then
		nFont = 31
	end
	text:SetFontScheme(nFont)
	hI:Lookup("Text_SkillTitleL"):SetText(FormatString(g_tStrings.STR_SKILL_H_THE_WHAT_LEVEL1, NumberToChinese(dwLevel)))
	
	if not bHas then
		local dwRExp, dwRLevel, dwRReputationID, dwRReputationLevel, dwRMoney = GetSkillLearningInfo(SkillFormulaPanel.dwMasterID, dwID, dwLevel)
		if dwRExp then
			if dwRMoney > 0 then
				local nFont = 162
				if player.GetMoney() < dwRMoney then
					nFont = 102
				end
				handle:AppendItemFromString("<text>text="..EncodeComponentsString(g_tStrings.STR_LEARN_NEED_MONEY).."font="..nFont.."</text>"..GetMoneyTipText(dwRMoney, nFont))			
			end
			
			local szText = FormatString(g_tStrings.STR_LEARN_NEED_LEVEL, dwRLevel)
			local nFont = 162
			if dwRLevel > player.nLevel then
				nFont = 102
			end
			handle:AppendItemFromString("<text>text="..EncodeComponentsString(szText).."font="..nFont.."</text>")
								
			local dwKunfu = GetSkill(dwID, dwLevel).dwBelongKungfu
			if dwKunfu ~= 0 then
				local szText = FormatString(g_tStrings.STR_LEARN_NEED_STUDY, Table_GetSkillName(dwKunfu, 1))
				local nFont = 162
				local dwKL = player.GetSkillLevel(dwKunfu)
				if not dwKL or dwKL < 1 then
					nFont = 102
				end
				handle:AppendItemFromString("<text>text="..EncodeComponentsString(szText).."font="..nFont.."</text>")			
			end
									
									
			if dwRReputationID ~= 0 then
if not g_tReputation.tReputationTable[dwRReputationID] then
	OutputMessage("MSG_SYS", FormatString(g_tStrings.ERROR_FORMULA_WITHOUT_REPUTATION,tostring(dwID),tostring(dwLevel),tostring(dwRReputationID)))
end
if not g_tReputation.tReputationLevelTable[dwRReputationLevel] then
	OutputMessage("MSG_SYS", FormatString(g_tStrings.ERROR_FORMULA_WITHOUT_REPUTATION_LEVEL,tostring(dwID),tostring(dwLevel),tostring(dwRReputationID),tostring(dwRReputationLevel)))
end
				local szText = FormatString(g_tStrings.STR_LEARN_NEED_REPUT, g_tReputation.tReputationTable[dwRReputationID].szName, g_tReputation.tReputationLevelTable[dwRReputationLevel].szLevel)
				local nFont = 162
				if player.GetReputeLevel(dwRReputationID) < dwRReputationLevel then
					nFont = 102
				end
				handle:AppendItemFromString("<text>text="..EncodeComponentsString(szText).."font="..nFont.."</text>")
			end
			
			if dwLevel > 1 and dwRExp > 0 then
				local szText = FormatString(g_tStrings.STR_LEARN_NEED_EXP, player.GetSkillExp(dwID), dwRExp)
				local nFont = 162
				if player.GetSkillExp(dwID) < dwRExp then
					nFont = 102
				end
				handle:AppendItemFromString("<text>text="..EncodeComponentsString(szText).."font="..nFont.."</text>")
			end
		else
			handle:AppendItemFromString("<text>text="..EncodeComponentsString(g_tStrings.ERROR_FORMULA_NOT_LEARNED_HERE).."font=102</text>")
		end
	end
	
	local szSpecial = Table_GetSkillSpecialDesc(dwID, dwLevel)
	if szSpecial ~= "" then
		handle:AppendItemFromString("<text>text="..EncodeComponentsString("\n"..szSpecial).."font=164</text>")
	end	
	local skillkey = player.GetSkillRecipeKey(dwID, dwLevel)
	local skillInfo = GetSkillInfo(skillkey)	
	local szDesc = GetSkillDesc(dwID, dwLevel, skillkey, skillInfo).."\n"
	handle:AppendItemFromString("<text>text="..EncodeComponentsString("\n"..szDesc).."font=100</text>")
	
	if bHas or bCannot then
		frame:Lookup("Btn_Study"):Enable(false)
	else
		frame:Lookup("Btn_Study"):Enable(true)
	end
	
	handle:Show()
	SkillFormulaPanel.UpdateInfoScroll(handle)
end

function SkillFormulaPanel.OnEvent(event)
	if event == "MONEY_UPDATE" then
		if SkillFormulaPanel.bSkill then
			SkillFormulaPanel.UpdateSkillList(this)
		else
			SkillFormulaPanel.UpdateCraftList(this)
		end
		SkillFormulaPanel.UpdateMoneyShow(this:Lookup("", ""), true, GetClientPlayer().GetMoney())
	elseif event == "PLAYER_LEVEL_UPDATE" then
		if GetClientPlayer().dwID == arg0 then
			if SkillFormulaPanel.bSkill then
				SkillFormulaPanel.UpdateSkillList(this)
			else
				SkillFormulaPanel.UpdateCraftList(this)
			end
		end
	elseif event == "SKILL_UPDATE" then
		if SkillFormulaPanel.bSkill then
			SkillFormulaPanel.UpdateSkillList(this)
		else
			SkillFormulaPanel.UpdateCraftList(this)
		end
	elseif event == "RECIPE_UPDATE" then
		if SkillFormulaPanel.bSkill then
			SkillFormulaPanel.UpdateSkillList(this)
		else
			SkillFormulaPanel.UpdateCraftList(this)
		end	
	end
end

function SkillFormulaPanel.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		CloseSkillFormulaPanel()
	elseif szName == "Btn_Study" then
		local handle = this:GetParent():Lookup("", "Handle_Info")
		if SkillFormulaPanel.bSkill then
			if handle.dwID then
				GetClientPlayer().LearnSkill(handle.dwID, SkillFormulaPanel.dwNpc)
			end
		else
			if handle.dwCraftID and handle.dwRecipeID then
				GetClientPlayer().LearnRecipe(handle.dwCraftID, handle.dwRecipeID, SkillFormulaPanel.dwNpc)
			end		
		end
		PlaySound(SOUND.UI_SOUND, g_sound.Practice)
	end
end

function SkillFormulaPanel.UpdateMoneyShow(handle, bSelf, nMoney)
	local nGold, nSilver, nCopper = MoneyToGoldSilverAndCopper(nMoney)
	local szAdd = ""
	if bSelf then
		szAdd = "S"
	end
    local textG = handle:Lookup("Text_Gold"..szAdd)
    local textS = handle:Lookup("Text_Silver"..szAdd)
    local textC = handle:Lookup("Text_Copper"..szAdd)
    local imageG = handle:Lookup("Image_Gold"..szAdd)
    local imageS = handle:Lookup("Image_Silver"..szAdd)
    local imageC = handle:Lookup("Image_Copper"..szAdd)
    textG:SetText(nGold)
    textS:SetText(nSilver)
    textC:SetText(nCopper)
    imageG:Show()
    imageS:Show()
    imageC:Show()
    if nGold == 0 then
    	textG:SetText("")
    	imageG:Hide()
    	if nSilver == 0 then
    		textS:SetText("")
    		imageS:Hide()
    	end
    end
end

function SkillFormulaPanel.LocateListScroll(hHandle, hSelect)
	local hScroll = hHandle:GetRoot():Lookup("Scroll_List")
  local nSelect = hSelect:GetIndex()
	for i = nSelect, 0, -1 do
		local hSkill = hHandle:Lookup(i)
		if hSkill.bKungfu then
			if not hSkill:IsExpand() then
				hSkill:Expand()
			end
			break
		end
	end
	hHandle:FormatAllItemPos()
	local nSelectX, nSelectY = hSelect:GetAbsPos()
	local nSelectW, nSelectH = hSelect:GetSize()
	local nScrollX, nScrollY = hScroll:GetAbsPos()
	local nScrollW, nScrollH = hScroll:GetSize()
	if nSelectY < nScrollY then
		hScroll:ScrollPrev(math.ceil((nScrollY - nSelectY) / 10))
	elseif nSelectY + nSelectH > nScrollY + nScrollH then
		hScroll:ScrollNext(math.ceil((nSelectY + nSelectH - nScrollY - nScrollH) / 10))
	end
end

function OpenSkillFormulaPanel(dwNpc, dwMasterID, bSkill, bDisableSound)
	if IsOptionOrOptionChildPanelOpened() then
		return
	end

	local player = GetClientPlayer()
	if not player or player.nMoveState == MOVE_STATE.ON_DEATH then
		return
	end

	SkillFormulaPanel.dwNpc = dwNpc
	SkillFormulaPanel.dwMasterID = dwMasterID
	SkillFormulaPanel.bSkill = bSkill
	local hFrame = Wnd.OpenWindow("SkillFormulaPanel")
	
	local hBtnStudy = hFrame:Lookup("Btn_Study")
	if bSkill and hBtnStudy:IsEnabled() then
		FireHelpEvent("OnOpenpanel", "SkillFormulaPanel", hBtnStudy)
	end
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
end

function IsSkillFormulaPanelOpened()
	local frame = Station.Lookup("Normal/SkillFormulaPanel")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseSkillFormulaPanel(bDisableSound)
	Wnd.CloseWindow("SkillFormulaPanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end
