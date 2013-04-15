DebugNpcPortrait={ m_tune = 2 }

function DebugNpcPortrait.OnFrameCreate()
	this:Lookup("Btn_EyeXAdd"):Lookup("", ""):Lookup(0):SetText("EyeX+")
	this:Lookup("Btn_EyeXSub"):Lookup("", ""):Lookup(0):SetText("EyeX-")
	this:Lookup("Btn_EyeYAdd"):Lookup("", ""):Lookup(0):SetText("EyeY+")
	this:Lookup("Btn_EyeYSub"):Lookup("", ""):Lookup(0):SetText("EyeY-")
	this:Lookup("Btn_EyeZAdd"):Lookup("", ""):Lookup(0):SetText("EyeZ+")
	this:Lookup("Btn_EyeZSub"):Lookup("", ""):Lookup(0):SetText("EyeZ-")
	
	this:Lookup("Btn_LookXAdd"):Lookup("", ""):Lookup(0):SetText("LookAtX+")
	this:Lookup("Btn_LookXSub"):Lookup("", ""):Lookup(0):SetText("LookAtX-")
	this:Lookup("Btn_LookYAdd"):Lookup("", ""):Lookup(0):SetText("LookAtY+")
	this:Lookup("Btn_LookYSub"):Lookup("", ""):Lookup(0):SetText("LookAtY-")
	this:Lookup("Btn_LookZAdd"):Lookup("", ""):Lookup(0):SetText("LookAtZ+")
	this:Lookup("Btn_LookZSub"):Lookup("", ""):Lookup(0):SetText("LookAtZ-")

	this:Lookup("Btn_WidthAdd"):Lookup("", ""):Lookup(0):SetText("Width+")
	this:Lookup("Btn_WidthSub"):Lookup("", ""):Lookup(0):SetText("Width-")
	this:Lookup("Btn_HeightAdd"):Lookup("", ""):Lookup(0):SetText("Height+")
	this:Lookup("Btn_HeightSub"):Lookup("", ""):Lookup(0):SetText("Height-")

	this:Lookup("Btn_TuneAdd"):Lookup("", ""):Lookup(0):SetText("Step+")
	this:Lookup("Btn_TuneSub"):Lookup("", ""):Lookup(0):SetText("Step-")
	this:Lookup("Btn_Reset"):Lookup("", ""):Lookup(0):SetText("Reset")
	this:Lookup("Btn_Save"):Lookup("", ""):Lookup(0):SetText("Save")
	
	this:RegisterEvent("UI_SCALED")
	this:SetPoint("TOPRIGHT", 0, 0, "TOPRIGHT", -100, 40)
end

function DebugNpcPortrait.OnEvent(event)
	if event == "UI_SCALED" then
		this:SetPoint("TOPRIGHT", 0, 0, "TOPRIGHT", -100, 40)
	end
end

function DebugNpcPortrait.OnFrameShow()
	local dwType, dwID = GetClientPlayer().GetTarget()
	local aCameraInfo = nil
	if dwType == TARGET.NPC then
		local target = GetNpc(dwID)
		if target then
			if not NpcPortraitCameraInfo[target.dwModelID] then
				NpcPortraitCameraInfo[target.dwModelID] = { 21, 172, -26, 5, 170, 0, 30, 30 }
			end
			aCameraInfo = NpcPortraitCameraInfo[target.dwModelID]
		end
	elseif dwType == TARGET.PLAYER then
		if dwID == GetClientPlayer().dwID then
			local target = GetPlayer(dwID)
			if target then
				if not SelfPortraitCameraInfo[target.nRoleType] then
					SelfPortraitCameraInfo[target.nRoleType] = { 21, 172, -26, 5, 170, 0, 30, 30 }
				end
				aCameraInfo = SelfPortraitCameraInfo[target.nRoleType]
			end
		else
			local target = GetPlayer(dwID)
			if target then
				if not PlayerPortraitCameraInfo[target.nRoleType] then
					PlayerPortraitCameraInfo[target.nRoleType] = { 21, 172, -26, 5, 170, 0, 30, 30 }
				end
				aCameraInfo = PlayerPortraitCameraInfo[target.nRoleType]
			end
		end
	end

	if aCameraInfo then
		this:Lookup("Text_EyeX"):SetText(tostring(aCameraInfo[1]))
		this:Lookup("Text_EyeY"):SetText(tostring(aCameraInfo[2]))
		this:Lookup("Text_EyeZ"):SetText(tostring(aCameraInfo[3]))
		this:Lookup("Text_LookX"):SetText(tostring(aCameraInfo[4]))
		this:Lookup("Text_LookY"):SetText(tostring(aCameraInfo[5]))
		this:Lookup("Text_LookZ"):SetText(tostring(aCameraInfo[6]))
		this:Lookup("Text_Width"):SetText(tostring(aCameraInfo[7]))
		this:Lookup("Text_Height"):SetText(tostring(aCameraInfo[8]))
		this:Lookup("Text_Tune"):SetText(tostring(DebugNpcPortrait.m_tune))
		this:Lookup("Text_NpcID"):SetText(tostring(dwID))
	end
end


function DebugNpcPortrait.OnFrameHide()
	local dwType, dwID = GetClientPlayer().GetTarget()
end

function DebugNpcPortrait.OnLButtonClick()
	local szName = this:GetName()
	local dwType, dwID = GetClientPlayer().GetTarget()
	
	local aCameraInfo = nil
	
	if dwType == TARGET.NPC then
		local target = GetNpc(dwID)
		if target then
			if not NpcPortraitCameraInfo[target.dwModelID] then
				NpcPortraitCameraInfo[target.dwModelID] = { 21, 172, -26, 5, 170, 0, 30, 30 }
			end
			aCameraInfo = NpcPortraitCameraInfo[target.dwModelID]
		end
	elseif dwType == TARGET.PLAYER then
		if dwID == GetClientPlayer().dwID then
			local target = GetPlayer(dwID)
			if target then
				if not SelfPortraitCameraInfo[target.nRoleType] then
					SelfPortraitCameraInfo[target.nRoleType] = { 21, 172, -26, 5, 170, 0, 30, 30 }
				end
				aCameraInfo = SelfPortraitCameraInfo[target.nRoleType]
			end
		else
			if dwID == GetClientPlayer().dwID then
				local target = GetPlayer(dwID)
				if target then
					if not SelfPortraitCameraInfo[target.nRoleType] then
						SelfPortraitCameraInfo[target.nRoleType] = { 21, 172, -26, 5, 170, 0, 30, 30 }
					end
					aCameraInfo = SelfPortraitCameraInfo[target.nRoleType]
				end
			else
				local target = GetPlayer(dwID)
				if target then
					if not PlayerPortraitCameraInfo[target.nRoleType] then
						PlayerPortraitCameraInfo[target.nRoleType] = { 21, 172, -26, 5, 170, 0, 30, 30 }
					end
					aCameraInfo = PlayerPortraitCameraInfo[target.nRoleType]
				end
			end
		end
	end
	
	if aCameraInfo then
		if szName == "Btn_EyeXAdd" then
			aCameraInfo[1] = aCameraInfo[1] + DebugNpcPortrait.m_tune
			this:GetRoot():Lookup("Text_EyeX"):SetText(tostring(aCameraInfo[1]))
		elseif szName == "Btn_EyeXSub" then
			aCameraInfo[1] = aCameraInfo[1] - DebugNpcPortrait.m_tune
			this:GetRoot():Lookup("Text_EyeX"):SetText(tostring(aCameraInfo[1]))
		elseif szName == "Btn_EyeYAdd" then
			aCameraInfo[2] = aCameraInfo[2] + DebugNpcPortrait.m_tune
			this:GetRoot():Lookup("Text_EyeY"):SetText(tostring(aCameraInfo[2]))
		elseif szName == "Btn_EyeYSub" then
			aCameraInfo[2] = aCameraInfo[2] - DebugNpcPortrait.m_tune
			this:GetRoot():Lookup("Text_EyeY"):SetText(tostring(aCameraInfo[2]))
		elseif szName == "Btn_EyeZAdd" then
			aCameraInfo[3] = aCameraInfo[3] + DebugNpcPortrait.m_tune
			this:GetRoot():Lookup("Text_EyeZ"):SetText(tostring(aCameraInfo[3]))
		elseif szName == "Btn_EyeZSub" then
			aCameraInfo[3] = aCameraInfo[3] - DebugNpcPortrait.m_tune
			this:GetRoot():Lookup("Text_EyeZ"):SetText(tostring(aCameraInfo[3]))
		elseif szName == "Btn_LookXAdd" then
			aCameraInfo[4] = aCameraInfo[4] + DebugNpcPortrait.m_tune
			this:GetRoot():Lookup("Text_LookX"):SetText(tostring(aCameraInfo[4]))
		elseif szName == "Btn_LookXSub" then
			aCameraInfo[4] = aCameraInfo[4] - DebugNpcPortrait.m_tune
			this:GetRoot():Lookup("Text_LookX"):SetText(tostring(aCameraInfo[4]))
		elseif szName == "Btn_LookYAdd" then
			aCameraInfo[5] = aCameraInfo[5] + DebugNpcPortrait.m_tune
			this:GetRoot():Lookup("Text_LookY"):SetText(tostring(aCameraInfo[5]))
		elseif szName == "Btn_LookYSub" then
			aCameraInfo[5] = aCameraInfo[5] - DebugNpcPortrait.m_tune
			this:GetRoot():Lookup("Text_LookY"):SetText(tostring(aCameraInfo[5]))
		elseif szName == "Btn_LookZAdd" then
			aCameraInfo[6] = aCameraInfo[6] + DebugNpcPortrait.m_tune
			this:GetRoot():Lookup("Text_LookZ"):SetText(tostring(aCameraInfo[6]))
		elseif szName == "Btn_LookZSub" then
			aCameraInfo[6] = aCameraInfo[6] - DebugNpcPortrait.m_tune
			this:GetRoot():Lookup("Text_LookZ"):SetText(tostring(aCameraInfo[6]))
		elseif szName == "Btn_WidthAdd" then
			aCameraInfo[7] = aCameraInfo[7] + DebugNpcPortrait.m_tune
			this:GetRoot():Lookup("Text_Width"):SetText(tostring(aCameraInfo[7]))
		elseif szName == "Btn_WidthSub" then
			aCameraInfo[7] = aCameraInfo[7] - DebugNpcPortrait.m_tune
			this:GetRoot():Lookup("Text_Width"):SetText(tostring(aCameraInfo[7]))
		elseif szName == "Btn_HeightAdd" then
			aCameraInfo[8] = aCameraInfo[8] + DebugNpcPortrait.m_tune
			this:GetRoot():Lookup("Text_Height"):SetText(tostring(aCameraInfo[8]))
		elseif szName == "Btn_HeightSub" then
			aCameraInfo[8] = aCameraInfo[8] - DebugNpcPortrait.m_tune
			this:GetRoot():Lookup("Text_Height"):SetText(tostring(aCameraInfo[8]))
		elseif szName == "Btn_TuneAdd" then
			DebugNpcPortrait.m_tune = DebugNpcPortrait.m_tune + 1
			if DebugNpcPortrait.m_tune > 10 then
				DebugNpcPortrait.m_tune = 10
			end
			this:GetRoot():Lookup("Text_Tune"):SetText(tostring(DebugNpcPortrait.m_tune))
		elseif szName == "Btn_TuneSub" then
			DebugNpcPortrait.m_tune = DebugNpcPortrait.m_tune - 1
			if DebugNpcPortrait.m_tune < 1 then
				DebugNpcPortrait.m_tune = 1
			end
			this:GetRoot():Lookup("Text_Tune"):SetText(tostring(DebugNpcPortrait.m_tune))
		elseif szName == "Btn_Reset" then
			if dwType == TARGET.NPC then
				NpcPortraitCameraInfo[target.dwModelID] = { 0, 0, 0, 0, 0, 0, 30, 30 }
			elseif dwType == TARGET.PLAYER then
				if dwID == GetClientPlayer().dwID then
					SelfPortraitCameraInfo[target.nRoleType] = { 0, 0, 0, 0, 0, 0, 30, 30 }
				else
					PlayerPortraitCameraInfo[target.nRoleType] = { 0, 0, 0, 0, 0, 0, 30, 30 }
				end
			end
			
			DebugNpcPortrait.m_tune = 2
			
			this:GetRoot():Lookup("Text_EyeX"):SetText(tostring(aCameraInfo[1]))
			this:GetRoot():Lookup("Text_EyeY"):SetText(tostring(aCameraInfo[2]))
			this:GetRoot():Lookup("Text_EyeZ"):SetText(tostring(aCameraInfo[3]))
			this:GetRoot():Lookup("Text_LookX"):SetText(tostring(aCameraInfo[4]))
			this:GetRoot():Lookup("Text_LookY"):SetText(tostring(aCameraInfo[5]))
			this:GetRoot():Lookup("Text_LookZ"):SetText(tostring(aCameraInfo[6]))
			this:GetRoot():Lookup("Text_Width"):SetText(tostring(aCameraInfo[7]))
			this:GetRoot():Lookup("Text_Height"):SetText(tostring(aCameraInfo[8]))
			this:GetRoot():Lookup("Text_Tune"):SetText(tostring(DebugNpcPortrait.m_tune))
		elseif szName == "Btn_Save" then
			if dwType == TARGET.NPC then
				DebugNpcPortrait.SaveTable({{szTable = "NpcPortraitCameraInfo", aTable = NpcPortraitCameraInfo}}, 
					"/ui/script/npcportrait.lua")
			elseif dwType == TARGET.PLAYER then
				DebugNpcPortrait.SaveTable({{szTable = "PlayerPortraitCameraInfo", aTable = PlayerPortraitCameraInfo},
											{szTable = "SelfPortraitCameraInfo", aTable = SelfPortraitCameraInfo}}, 
					"/ui/script/playerportrait.lua")
			end
		end
		
		UpdatePlayerImage()
		UpdateTargetImage()
	end
end

function DebugNpcPortrait.SaveTable(aSave, szFile)
	local f = io.open(GetRootPath()..szFile, "w+")
	io.output(f)
	
	for index, aSaveInfo in pairs(aSave) do
		local t = {}
		for k, v in pairs(aSaveInfo.aTable) do
			table.insert(t, {id = k, data = v})
		end
		table.sort(t, function(t1, t2) return t1.id < t2.id end)
		io.write(aSaveInfo.szTable.." =\n{\n") 
		for k, v in pairs(t) do
			io.write("\t["..v.id.."] = {")
			for i, d in pairs(v.data) do
				if i ~= 1 then
					io.write(", ")
				end
				io.write(tostring(d))
			end
			io.write("},\n")
		end
		io.write("}\n")		
	end
	
	
	f:close()
	f = nil
end

function DebugNpcPortrait.OnEditSpecialKeyDown()
	local szKey = GetKeyName(Station.GetMessageKey())
	local nResult = 0
	local szName = this:GetName()
	local nValue = tonumber(this:GetText())
	
	local dwType, dwID = GetClientPlayer().GetTarget()
	local aCameraInfo = nil
	
	if dwType == TARGET.NPC then
		local target = GetNpc(dwID)
		if target then
			if not NpcPortraitCameraInfo[target.dwModelID] then
				NpcPortraitCameraInfo[target.dwModelID] = { 21, 172, -26, 5, 170, 0, 30, 30 }
			end
			aCameraInfo = NpcPortraitCameraInfo[target.dwModelID]
		end
	elseif dwType == TARGET.PLAYER then
		if dwID == GetClientPlayer().dwID then
			local target = GetPlayer(dwID)
			if target then
				if not SelfPortraitCameraInfo[target.nRoleType] then
					SelfPortraitCameraInfo[target.nRoleType] = { 21, 172, -26, 5, 170, 0, 30, 30 }
				end
				aCameraInfo = SelfPortraitCameraInfo[target.nRoleType]
			end
		else
			local target = GetPlayer(dwID)
			if target then
				if not PlayerPortraitCameraInfo[target.nRoleType] then
					PlayerPortraitCameraInfo[target.nRoleType] = { 21, 172, -26, 5, 170, 0, 30, 30 }
				end
				aCameraInfo = PlayerPortraitCameraInfo[target.nRoleType]
			end
		end
	end
	
	if aCameraInfo then
		if szKey == "Enter" then
			local bModify = false
			if szName == "Text_EyeX" then
				if aCameraInfo[1] ~= nValue then
					aCameraInfo[1] = nValue
					bModify = true
				end
			elseif szName == "Text_EyeY" then
				if aCameraInfo[2] ~= nValue then
					aCameraInfo[2] = nValue
					bModify = true
				end
			elseif szName == "Text_EyeZ" then
				if aCameraInfo[3] ~= nValue then
					aCameraInfo[3] = nValue
					bModify = true
				end
			elseif szName == "Text_LookX" then
				if aCameraInfo[4] ~= nValue then
					aCameraInfo[4] = nValue
					bModify = true
				end
			elseif szName == "Text_LookY" then
				if aCameraInfo[5] ~= nValue then
					aCameraInfo[5] = nValue
					bModify = true
				end
			elseif szName == "Text_LookZ" then
				if aCameraInfo[6] ~= nValue then
					aCameraInfo[6] = nValue
					bModify = true
				end
			elseif szName == "Text_Width" then
				if aCameraInfo[7] ~= nValue then
					aCameraInfo[7] = nValue
					bModify = true
				end
			elseif szName == "Text_Height" then
				if aCameraInfo[8] ~= nValue then
					aCameraInfo[8] = nValue
					bModify = true
				end
			elseif szName == "Text_TuneText" then
				DebugNpcPortrait.m_tune = nValue
			end
			if bModify then
				UpdateTargetImage()
			end
			nResult = 1
		elseif szKey == "Up" then
	--		nResult = 1
		elseif szKey == "Down" then
	--		nResult = 
		elseif szKey == "Left" then
		elseif szKey == "Right" then
		end
	end
	return nResult
end

