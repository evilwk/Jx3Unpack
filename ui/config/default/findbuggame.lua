FindBugGame = {nMoveSpeed = 1, nRandNum = 60, nLevel = 1}

function FindBugGame.OnFrameCreate()
	FindBugGame.InitBugPos(this:Lookup("", ""))
	local handle = this:Lookup("", "")
	handle:Lookup("Text_Num"):SetText(g_tStrings.BUGGAME_BUGNUMBER..FindBugGame.nBugNum)
	handle:Lookup("Text_Num1"):SetText(g_tStrings.BUGGAME_LEVEL..FindBugGame.nLevel)
end

----------------自动调整窗口位置------------
function FindBugGame.AutoClose(frame)
	CloseFindBugGame(true)
end

function FindBugGame.OnFrameShow()
	CorrectAutoPosFrameWhenShow(this)
end

function FindBugGame.OnFrameHide()
	CorrectAutoPosFrameWhenHide(this)
end
--------------------------------------------

function FindBugGame.InitBugPos(handle)
	local nSpeedbase = 1
	local nSleepMax = 60
	if FindBugGame.nLevel == 1 then
		nSpeedbase = 1
		nSleepMax = 60
	elseif FindBugGame.nLevel == 2 then
		nSpeedbase = 2
		nSleepMax = 80
	else
		nSpeedbase = 3
		nSleepMax = 100
	end
	local aPos = {
					{334, 312, Random(280, 300), 334, Random(nSpeedbase , 5), 330}, 
					{274, 215, Random(220, 240), 274, Random(nSpeedbase , 6), 270}, 
					{194, 395, Random(140, 160), 194, Random(nSpeedbase + 2, 7), 190}, 
					{414, 255, Random(360, 380), 414, Random(nSpeedbase + 2, 7), 410}, 
					{174, 250, Random(120, 140), 174, Random(nSpeedbase + 3, 7), 170}
					}
	FindBugGame.nBugNum = 0
	for index, vPos in pairs(aPos) do
		local img = handle:Lookup("Image_Bug"..index)
		img:SetRelPos(vPos[1], vPos[2])
		img:Show()
		img.nX, img.nY = vPos[1], vPos[2]
		img.nXMin, img.nXMax = vPos[3], vPos[4]
		img.nSpeed = vPos[5]
		img.nXHide = vPos[6]
		img.nMaxSleepRandom = nSleepMax
		img.bDie = false
		
		img.OnActive = function(this)
			if this.bDie then
				return
			end
			if this.bSleep then
				this.nSleepCount = this.nSleepCount + 1
				if this.nSleepCount < this.nMaxSleepCount then
					return
				end
				this.bSleep = false
			end
			local x, y = this:GetRelPos()
			
			if this.bAdd  then
				x = x + this.nSpeed
			else
				x = x - this.nSpeed
			end
			
			if x < this.nXMin then
				x = this.nXMin
				this.bAdd = true
			end
			if x > this.nXMax then
				x = this.nXMax
				this.bAdd = false
				this.bSleep = true
				this.nSleepCount = 0
				this.nMaxSleepCount = Random(1, this.nMaxSleepRandom)
			end
			local w, h = this:GetSize()			
			this:SetPercentage((this.nXHide - x) / w)
			this:SetRelPos(x, y)
		end
		img.OnItemLButtonDown = function()
			this.bDie = true
			this:Hide()
			FindBugGame.nBugNum = FindBugGame.nBugNum + 1
			local text = this:GetParent():Lookup("Text_Num")
			text:SetText(g_tStrings.BUGGAME_BUGNUMBER..FindBugGame.nBugNum)
--			OutPutMessage("MSG_ANNOUNCE_RED", "你抓到了一条虫子!\n".."剩余虫子的数量是"..(5 - FindBugGame.nBugNum))
		end
		img:OnActive()
	end
	handle:Lookup("Text_Num"):SetText(g_tStrings.BUGGAME_BUGNUMBER..FindBugGame.nBugNum)
	handle:Lookup("Text_Num1"):SetText(g_tStrings.BUGGAME_LEVEL..FindBugGame.nLevel)
	handle:FormatAllItemPos()
end

function FindBugGame.OnFrameBreathe()
	local handle = this:Lookup("", "")
	for i = 1, 5, 1 do
		handle:Lookup("Image_Bug"..i):OnActive()
	end
	if FindBugGame.nBugNum == 5 and FindBugGame.nLevel <= 2 then
		FindBugGame.nLevel = FindBugGame.nLevel + 1
		FindBugGame.InitBugPos(this:GetRoot():Lookup("", ""))
	end
	handle:FormatAllItemPos()
end

function FindBugGame.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Reset" then
		FindBugGame.InitBugPos(this:GetRoot():Lookup("", ""))
	elseif szName == "Btn_Stop" then
		FindBugGame.nLevel = FindBugGame.nLevel + 1
		if FindBugGame.nLevel > 3 then
			FindBugGame.nLevel = 3
		end
		FindBugGame.InitBugPos(this:GetRoot():Lookup("", ""))
	elseif szName == "Btn_Close" then
		CloseFindBugGame()
	end
end

function OpenFindBugGame(bDisableSound)
	if IsFindBugGameOpened() then
		return
	end
	Wnd.OpenWindow("FindBugGame")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end	
end

function CloseFindBugGame(bDisableSound)
	if not IsFindBugGameOpened() then
		return
	end
	Wnd.CloseWindow("FindBugGame")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end		
end

function IsFindBugGameOpened()
	local frame = Station.Lookup("Normal/FindBugGame")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end
	
