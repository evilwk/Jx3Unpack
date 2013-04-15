
function EditMiddleMapFlag(dwMapID, szName, nType, x, y, fnSave, fnDel, fnAutoClose, rect, bDisableSound, bNew)

	local frame = Wnd.OpenWindow("MiddleMapFlagEditor")
	frame.szName = szName
	frame.nSelectType = nType
	frame.nType = nType
	frame.x = x
	frame.y = y
	frame.fnSave = fnSave
	frame.fnDel = fnDel
	frame.fnAutoClose = fnAutoClose
	frame.dwMapID = dwMapID
	frame.bNew = bNew
	
	frame.OnFrameBreathe = function()
		if this.fnAutoClose and this.fnAutoClose() then
			CloseEditMiddleMapFlag()
		end
	end
	
	local wndC = frame:Lookup("Wnd_Center")
	
	local check = wndC:Lookup("CheckBox_"..nType)
	if check then
		check:Check(true)
	end
	
	local edit = wndC:Lookup("Edit_Name")
	edit:SetText(szName)
	edit:SelectAll()
	Station.SetFocusWindow(edit)
	
	for i = 1, 6, 1 do
		local check = wndC:Lookup("CheckBox_"..i)
		check.nType = i
		check.OnCheckBoxCheck = function()
			local wP = this:GetParent()
			for i = 1, 6, 1 do
				local cB = wP:Lookup("CheckBox_"..i)
				if cB ~= this then
					cB:Check(false)
				end
			end
			this:GetRoot().nSelectType = this.nType
			PlaySound(SOUND.UI_SOUND, g_sound.Button)
		end
	end
	
	wndC:Lookup("Btn_Send").OnLButtonClick = function()
		local frame = this:GetRoot()
		GetClientPlayer().SyncMidMapMark(frame.dwMapID, frame.x, frame.y, frame.nType, frame.szName)
		frame.bNew = false
		wndC:Lookup("Btn_Save").OnLButtonClick()
		CloseEditMiddleMapFlag()
	end
	
	wndC:Lookup("Btn_Save").OnLButtonClick = function()
		local frame = this:GetRoot()
		local szEditName = this:GetParent():Lookup("Edit_Name"):GetText()
		if frame.nSelectType ~= frame.nType or szEditName ~= frame.szName then
			frame.fnSave(frame.nSelectType, szEditName)
		end
		frame.bNew = false
		CloseEditMiddleMapFlag()
	end
	
	wndC:Lookup("Btn_Del").OnLButtonClick = function()
		local frame = this:GetRoot()
		frame.fnDel()
		frame.bNew = false
		CloseEditMiddleMapFlag()
	end
	
	wndC:Lookup("Btn_Close").OnLButtonClick = function()
		local frame = this:GetRoot()
		if frame.bNew then
			frame.fnDel()
		end
		frame.bNew = false
		CloseEditMiddleMapFlag()
	end
	local w, h = Station.GetClientSize()
	frame:SetSize(w, h)
	if rect then
		Wnd.SetTipPosByRect(wndC, rect[1], rect[2], rect[1] + rect[3], rect[2] + rect[4], ALW.CENTER)
	else
		local wW, hW = wndC:GetSize()
		wndC:SetRelPos((w - wW) / 2, (h - hW) / 2)
	end
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end		
end

function IsEditMiddleMapFlagOpened()
	local frame = Station.Lookup("Topmost1/MiddleMapFlagEditor")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseEditMiddleMapFlag(bDisableSound)
	local frame = Station.Lookup("Topmost1/MiddleMapFlagEditor")
	if frame and frame.bNew then
		frame.fnDel()
	end
	Wnd.CloseWindow("MiddleMapFlagEditor")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
end