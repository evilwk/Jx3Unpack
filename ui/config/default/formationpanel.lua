FormationPanel = 
{

}

local aFormationPanelSkill = {}
local function SetFormationPanelSkill(box)
	local dwType, nData1, nData2, nData3, nData4, nData5, nData6 = box:GetObject()
	aFormationPanelSkill[box] = {dwType, nData1, nData2, nData3, nData4, nData5, nData6}	
end

function FormationPanel.OnFrameCreate()
	
end

function FormationPanel.OnFrameKeyDown()
	local szKey = GetKeyName(Station.GetMessageKey())
	if szKey == "Esc" then
		CloseFormationPanel()
		return 1
	end
end

function FormationPanel.OnFrameBreathe() 
	if this ~= Station.GetActiveFrame() then
		CloseFormationPanel()
	else
		local player = GetClientPlayer()
		if player then
			local handle = this:Lookup("", "Handle_Box")
			local nCount = handle:GetItemCount() - 1
			for i = 0, nCount, 1 do
				UpdataSkillCDProgress(player, handle:Lookup(i))
			end
		end
	end
end

function FormationPanel.OnItemLButtonDown()
	this:SetObjectPressed(1)
end

function FormationPanel.OnItemLButtonUp()
	this:SetObjectPressed(0)
end

function FormationPanel.OnItemLButtonClick()
	local t = aFormationPanelSkill[this]
	if t then
		OnUseSkill(t[2], t[3])
	end
	PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	CloseFormationPanel()
end

function FormationPanel.OnItemLButtonDBClick()
	FormationPanel.OnItemLButtonClick()
end


function FormationPanel.OnItemRButtonDown()
	FormationPanel.OnItemLButtonDown()
end

function FormationPanel.OnItemRButtonUp()
	FormationPanel.OnItemLButtonUp()
end

function FormationPanel.OnItemRButtonClick()
	FormationPanel.OnItemLButtonClick()
end

function FormationPanel.OnItemRButtonDBClick()
	FormationPanel.OnItemLButtonDBClick()
end

function FormationPanel.OnItemMouseEnter()
	this:SetObjectMouseOver(1)
	local x, y = this:GetAbsPos()
	local w, h = this:GetSize()
	local dwSkilID, dwSkillLevel = this:GetObjectData()
	OutputSkillTip(dwSkilID, dwSkillLevel, {x, y, w, h})	
end

function FormationPanel.OnItemMouseLeave()
	this:SetObjectMouseOver(0)
	HideTip()
end

function FormationPanel.Update(frame, rect)
	local handle = frame:Lookup("", "")
	local img = handle:Lookup("Image_Bg")
	local hList = handle:Lookup("Handle_Box")
	
	aFormationPanelSkill = {}
	hList:Clear()
	
	local aSkill = GetClientPlayer().GetAllSkillList()
	local a = {}
	for k, v in pairs(aSkill) do
		local skill = GetSkill(k, v)
		if skill.dwBelongKungfu ~= 0 and Table_IsSkillFormationCaster(k, v) then
			table.insert(a, {k, v})
		end
	end
	if #a == 0 then
		CloseFormationPanel(false)
		return
	end
	table.insert(a, {738, 1})
	
	local nIndex = 0
	for k, v in pairs(a) do
		hList:AppendItemFromString("<box>w=48 h=48 eventid=525311 </box>")
		local box = hList:Lookup(nIndex)
		box.dwID, box.dwLevel = v[1], v[2]
		box:SetObject(UI_OBJECT_SKILL, box.dwID, box.dwLevel)
		SetFormationPanelSkill(box)
		box:SetObjectIcon(Table_GetSkillIconID(box.dwID, box.dwLevel))
		box:SetRelPos(nIndex * 48, 0)
		nIndex = nIndex + 1
	end
		
	hList:FormatAllItemPos()
	hList:SetSizeByAllItemSize()
	local w, h = hList:GetSize()
	w, h = w + 4, h + 4
	img:SetSize(w, h)
	handle:SetSize(w, h)
	frame:SetSize(w, h)
	local wA, hA = Station.GetClientSize()
	if rect[1] + rect[3] + w > wA then
		frame:SetAbsPos(rect[1] - w, rect[2])
	else
		frame:SetAbsPos(rect[1] + rect[3], rect[2])
	end
end

function OpenFormationPanel(rect, bDisbleSound)
	if IsFormationPanelOpened() then
		return
	end
	local frame = Wnd.OpenWindow("FormationPanel")
	if frame then
		FormationPanel.Update(frame, rect)
		Station.SetActiveFrame(frame)
		if not bDisbleSound then
			PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
		end
	end	
end

function IsFormationPanelOpened()
	local frame = Station.Lookup("Topmost/FormationPanel")
	if frame and frame:IsVisible() then
		return true
	end
end

function CloseFormationPanel(bDisbleSound)
	if not IsFormationPanelOpened() then
		return
	end
	
	Wnd.CloseWindow("FormationPanel")
	if not bDisbleSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end	
end
