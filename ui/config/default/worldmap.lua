local MIDDLE_MAP_MIN_ALPHA = 128
WorldMap = {
	bTraffic = false, 
	nAlpha = 255,
	fScale = 1.0,
}

RegisterCustomData("WorldMap.nAlpha")

local tTransMap = {}

WorldMap.aMapInfo = 
{
	w = 1778, h = 1304,
	{file = "ui/Image/WorldMap/worldmap10.tga", w = 512, h = 512, x = 0, y = 0},
	{file = "ui/Image/WorldMap/worldmap11.tga", w = 512, h = 512, x = 512, y = 0},
	{file = "ui/Image/WorldMap/worldmap12.tga", w = 512, h = 512, x = 1024, y = 0},
	{file = "ui/Image/WorldMap/worldmap13.tga", w = 242, h = 512, x = 1536, y = 0},
	{file = "ui/Image/WorldMap/worldmap20.tga", w = 512, h = 512, x = 0, y = 512},
	{file = "ui/Image/WorldMap/worldmap21.tga", w = 512, h = 512, x = 512, y = 512},
	{file = "ui/Image/WorldMap/worldmap22.tga", w = 512, h = 512, x = 1024, y = 512},
	{file = "ui/Image/WorldMap/worldmap23.tga", w = 242, h = 512, x = 1536, y = 512},
	{file = "ui/Image/WorldMap/worldmap30.tga", w = 512, h = 280, x = 0, y = 1024},
	{file = "ui/Image/WorldMap/worldmap31.tga", w = 512, h = 280, x = 512, y = 1024},
	{file = "ui/Image/WorldMap/worldmap32.tga", w = 512, h = 280, x = 1024, y = 1024},
	{file = "ui/Image/WorldMap/worldmap33.tga", w = 242, h = 280, x = 1536, y = 1024},

}

WorldMap.aCityButton = 
{
	{file = "ui/Image/MiddleMap/MapWindow.UITex", normal = 42, disable = 45, over = 43, down = 44, highlight = 100},
	{file = "ui/Image/MiddleMap/MapWindow.UITex", normal = 46, disable = 49, over = 47, down = 48, highlight = 101},
	{file = "ui/Image/MiddleMap/MapWindow.UITex", normal = 38, disable = 41, over = 39, down = 40, highlight = 98},
	{file = "ui/Image/MiddleMap/MapWindow.UITex", normal = 50, disable = 53, over = 51, down = 52, highlight = 99},
	{file = "ui/Image/Minimap/Minimap.UITex", normal = 76, disable = 71, over = 69, down = 70},
	{file = "ui/Image/Minimap/Minimap.UITex", normal = 76, disable = 71, over = 69, down = 70},
	{file = "ui/Image/Minimap/Minimap.UITex", normal = 76, disable = 71, over = 69, down = 70},
}

WorldMap.tCityFrame = {normal = 1, over = 2, down = 3, disable = 4, highlight = 5}

function WorldMap.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("UPDATE_ROAD_TRACK_FORCE")
	this:RegisterEvent("UPDATE_ROUTE_NODE_OPEN_LIST")
	this:RegisterEvent("ON_MAP_VISIT_FLAG_CHANGED")
	this:RegisterEvent("SYNC_ROLE_DATA_END")
	this:RegisterEvent("SELECT_CITY_COPY")
	
	local player = GetClientPlayer()
	local hTotal = this:Lookup("Wnd_All", "")
	local hMap = hTotal:Lookup("Handle_Map")
	for k, v in ipairs(WorldMap.aMapInfo) do
		hMap:AppendItemFromString("<image></image>")
		local img = hMap:Lookup(k - 1)
		img:FromTextureFile(v.file)
		img.x = v.x
		img.y = v.y
		img.w = v.w
		img.h = v.h
	end

	local hPoint = hTotal:Lookup("Handle_Point")
	local nIndex = 0
	for k, v in ipairs(g_aTrafficLine) do
		local bShow, bOk = CheckRoadTrack(v.from, v.to)
		hPoint:AppendItemFromString("<image></image>")
		local img = hPoint:Lookup(nIndex)
		nIndex = nIndex + 1
		if bShow then
			if bOk or not v.disablefile then
				img:FromTextureFile(v.file)
				img:SetUserData(1)
			else
				img:FromTextureFile(v.disablefile)
				img:SetUserData(0)
			end
		else
			if v.disablefile then
				img:FromTextureFile(v.disablefile)
				img:SetUserData(0)
			else
				img:FromTextureFile(v.file)
				img:SetUserData(1)
			end
		end
		img.x = v.x
		img.y = v.y
		img.w = v.w
		img.h = v.h			
	end
	hPoint:Sort()
	hPoint:Show()
	
	local hCityBtn = hTotal:Lookup("Handle_CityBtn")
	local hFightCity = hTotal:Lookup("Handle_FightCity")
	local hCampFightCity = hTotal:Lookup("Handle_CampFightCity")
	for k, v in ipairs(g_aCityPoint) do
		local bOpen = RoadTrackIsCityOpen(v.id)
		if not WorldMap.bTraffic and v.mapid == 1 then
			bOpen = true
		end
		
		if v.tothermapid then
			for _, nOtherShowMapid in ipairs(v.tothermapid) do
				tTransMap[nOtherShowMapid] = v.mapid
			end
		end
		
		if WorldMap.bTraffic and WorldMap.bTrafficByItem then
			if WorldMap.tCanTrafficMapList[v.mapid] then
				bOpen = true
			else
				bOpen = false
			end
		end
		
		local bInFight = WorldMap.IsCityInFight(v.id)
		local szFile = v.button
		
		if bOpen then
			szFile = szFile.. WorldMap.tCityFrame.normal .. ".tga"
		else
			szFile = szFile.. WorldMap.tCityFrame.disable .. ".tga"
		end
		
		hFightCity:AppendItemFromString("<image></image>")
		local img = hFightCity:Lookup(hFightCity:GetItemCount() - 1)
		img:FromTextureFile("ui/Image/WorldMap/neutral_fight.tga")
		img:Show(bInFight)
		img.x = v.x
		img.y = v.y
		img.w = 158
		img.h = 86
		img.bInFight = bInFight
			
		hCityBtn:AppendItemFromString("<image>eventid=341</image>")
		local img = hCityBtn:Lookup(k - 1)
		img:FromTextureFile(szFile)
		img.bEnable = bOpen
		img.bInFight = bInFight
		img.x = v.x
		img.y = v.y
		img.id = v.id
		img.mapid = v.mapid
		img.middlemapindex = v.middlemapindex
		
		local szName = Table_GetMapName(v.mapid)
		img.name = szName
		img.city = szName
		--img.tip = Table_GetMapTip(v.mapid)
		img.button = v.button
		img.w = v.w
		img.h = v.h
		img.bCity = true
		
		if v.id == 25 or v.id == 27 then
			local bInCampFight = GetInCampFightCity() == v.id
			hCampFightCity:AppendItemFromString("<image></image>")
			local img = hCampFightCity:Lookup(hCampFightCity:GetItemCount() - 1)
			img:FromUITex("ui/Image/MiddleMap/MapWindow.UITex", 104)
			img:Show(bInCampFight)
			img.id = v.id
			img.x = v.x
			img.y = v.y
			img.w = 55
			img.h = 52
		end
	end
	
	local hCityName = hTotal:Lookup("Handle_CityName")
	for k, v in ipairs(g_aCityPoint) do
		local szName = Table_GetMapName(v.mapid)
		hCityName:AppendItemFromString("<text>text="..EncodeComponentsString(szName).."halign=1 valign=1 font=9</text>")
		local text = hCityName:Lookup(k - 1)
		text.x = v.xN
		text.y = v.yN
	end

	local hCopyBtn = hTotal:Lookup("Handle_CopyBtn")
	for k, v in ipairs(g_aCopyPoint) do
		local bOpen = player.GetMapVisitFlag(v.mapid)
		local szFile, nFrame = WorldMap.aCityButton[v.button].file, WorldMap.aCityButton[v.button].disable
		
		if v.tothermapid then
			for _, nOtherShowMapid in ipairs(v.tothermapid) do
				tTransMap[nOtherShowMapid] = v.mapid
			end
		end
		
		if WorldMap.bTraffic and WorldMap.bTrafficByItem then
			if WorldMap.tCanTrafficMapList[v.mapid] then
				bOpen = true
			else
				bOpen = false
			end
		end
		
		if bOpen then
			nFrame = WorldMap.aCityButton[v.button].normal
		end
		hCopyBtn:AppendItemFromString("<image>path="..EncodeComponentsString(szFile).." frame="..nFrame.." eventid=341</image>")
		local img = hCopyBtn:Lookup(k - 1)
		
		img.bEnable = bOpen
		img.x = v.x
		img.y = v.y
		img.w = 48
		img.h = 48
		img.id = v.id
		img.mapid = v.mapid
		img.middlemapindex = v.middlemapindex
		local szName = Table_GetMapName(v.mapid)
		img.name = szName
		img.city = szName
		--img.tip = Table_GetMapTip(v.mapid)
		img.button = v.button
		img.copy = true
	end
	hCopyBtn:Show()

	WorldMap.UpdatePlayerPos(hTotal:Lookup("Handle_Player"))
	
	local fScaleMin, fScaleMax = WorldMap.GetScaleRange(hTotal)
	WorldMap.fScale = fScaleMin
	
	WorldMap.OnEvent("UI_SCALED")
end

function WorldMap.IsCityInFight(dwID)
	local a = GetRoadNodeInfoByCity(dwID) or {}
	for k, v in pairs(a) do
		if not v.bEnable then
			return true
		end
	end
	return false
end

function WorldMap.OnFrameBreathe()
	if this.bDrag then
		local x, y = Cursor.GetPos()
		this:Lookup("Wnd_All/Scroll_H"):ScrollNext(this.fDragX - x)
		this:Lookup("Wnd_All/Scroll_V"):ScrollNext(this.fDragY - y)
		this.fDragX, this.fDragY = x, y
	end
	local handle = this:Lookup("Wnd_All", "")
	local hPlayer = handle:Lookup("Handle_Player")
	WorldMap.UpdatePlayerPos(hPlayer)
	WorldMap.UpdatePointPos(hPlayer, WorldMap.GetMapScale(hPlayer:GetParent()))
	if WorldMap.bInFight then
		local img = handle:Lookup("Image_OnAttack")
		img:Show()
		if img.bAdd then
			local nAlpha = img:GetAlpha()
			nAlpha = nAlpha + 30
			img:SetAlpha(nAlpha)
			if nAlpha >= 255 then
				img.bAdd = false
			end
		else
			local nAlpha = img:GetAlpha()
			nAlpha = nAlpha - 30
			img:SetAlpha(nAlpha)
			if nAlpha <= 0 then
				img.bAdd = true
			end
		end
	else
		handle:Lookup("Image_OnAttack"):Hide()
	end
end

function WorldMap.ScrollPlayerToVisiblePos(frame)
	local hPlayer = frame:Lookup("Wnd_All", "Handle_Player")
	local img = hPlayer:Lookup(0)
	local x, y = img:GetRelPos()
	local w, h = hPlayer:GetSize()
	frame:Lookup("Wnd_All/Scroll_H"):SetScrollPos(x - w / 2)
	frame:Lookup("Wnd_All/Scroll_V"):SetScrollPos(y - h / 2)
end

function WorldMap.GetMaxPos(dwMapID)
	local pos = g_aMapIDtoWorldMapPoint[dwMapID]
	local x, y
	if pos then
		x, y = pos.x, pos.y
	end
	x, y = x or -10000, y or -10000
	return x, y
end

function WorldMap.UpdatePlayerPos(handle)
	local player = GetClientPlayer()
	if not player then
		return
	end
	
	local dwMapID = player.GetScene().dwMapID
	local nCount = handle:GetItemCount()
	if nCount == 0 then
		handle:AppendItemFromString("<image>path="..EncodeComponentsString("ui/Image/Minimap/Minimap.UITex").."frame=0 imagetype=6 </image>")
		handle:AppendItemFromString("<animate>path="..EncodeComponentsString("ui/Image/Minimap/Minimap.UITex").."group=69 eventid=256 </animate>")
		nCount = 2
	end
	nCount = nCount - 1
	local img = handle:Lookup(0)
	img:SetRotate((255 - player.nFaceDirection) * 6.2832 / 255)
	img.x, img.y = WorldMap.GetMaxPos(dwMapID)
	img.bPlayer = true
	local ani = handle:Lookup(1)
	ani.x, ani.y = img.x, img.y
	ani.bPlayerAni = true
	
	local t = {}
	if player.IsInParty() then
		local hTeam = GetClientTeam()
		local nGroupNum = hTeam.nGroupNum
		for i = 0, nGroupNum - 1 do
			local tGroupInfo = hTeam.GetGroupInfo(i)
			if tGroupInfo and tGroupInfo.MemberList then
				for _, dwID in pairs(tGroupInfo.MemberList) do
					local tMemberInfo = hTeam.GetMemberInfo(dwID)
					if dwID ~= player.dwID and tMemberInfo.bIsOnLine then
						if not t[tMemberInfo.dwMapID] then
							t[tMemberInfo.dwMapID] = {}
						end
						table.insert(t[tMemberInfo.dwMapID], dwID)					
					end
				end
			end
		end
	end
			
	for i = nCount, 2, -1 do
		local img = handle:Lookup(i)
		if t[img.dwMapID] then
			img.aTeammate = t[img.dwMapID]
			t[img.dwMapID] = nil
		else
			handle:RemoveItem(i)
		end
	end
	for k, v in pairs(t) do
		handle:AppendItemFromString("<image>path="..EncodeComponentsString("ui/Image/Minimap/Minimap.UITex").."frame=10 eventid=256 </image>")
		local img = handle:Lookup(handle:GetItemCount() - 1)
		img.dwMapID = k
		img.aTeammate = v
		img.x, img.y = WorldMap.GetMaxPos(k)
	end
end

function WorldMap.GetMapScale(hTotal)
	local hMap = hTotal:Lookup("Handle_Map")
	local fScale = Station.GetUIScale()
	fScale = fScale / WorldMap.fScale
	local wFact, hFact = Station.OriginalToAdjustPos(hMap:GetSize())
	local wAll, hAll = WorldMap.aMapInfo.w, WorldMap.aMapInfo.h
	wAll = wAll * WorldMap.fScale
	hAll = hAll * WorldMap.fScale
	if wFact > wAll or hFact > hAll then
		local fScaleLarge = wFact / wAll
		if fScaleLarge * hAll < hFact then
			fScaleLarge = hFact / hAll
		end
		fScale = fScale / fScaleLarge
	end
	return fScale
end

function WorldMap.GetScaleRange(hTotal)
	local hMap = hTotal:Lookup("Handle_Map")
	local wFact, hFact = Station.OriginalToAdjustPos(hMap:GetSize())
	local wAll, hAll = WorldMap.aMapInfo.w, WorldMap.aMapInfo.h
	
	local fScale = wFact / wAll
	if hAll * fScale > hFact then
		fScale = hFact / hAll
	end
	
	if fScale > 1.0 then
		fScale = 1.0
	end
	
	return fScale, 1.0
end

function WorldMap.UpdateScale(hTotal)
	local fScale = WorldMap.GetMapScale(hTotal)
	
	local hMap = hTotal:Lookup("Handle_Map")	
	WorldMap.UpdatePicPos(hMap, fScale)
	
	WorldMap.UpdatePicPos(hTotal:Lookup("Handle_Point"), fScale)
	
	WorldMap.UpdatePointPos(hTotal:Lookup("Handle_CityBtn"), fScale)
	WorldMap.UpdatePointPos(hTotal:Lookup("Handle_FightCity"), fScale)
	WorldMap.UpdatePointPos(hTotal:Lookup("Handle_CampFightCity"), fScale)
	WorldMap.UpdatePointPos(hTotal:Lookup("Handle_CityName"), fScale)
	WorldMap.UpdatePointPos(hTotal:Lookup("Handle_CopyBtn"), fScale)
	WorldMap.UpdatePointPos(hTotal:Lookup("Handle_Player"), fScale)
	
	WorldMap.UpdateScrollInfo(hMap)
end

function WorldMap.OnEvent(event)
	if event == "UI_SCALED" then
		local wC, hC = Station.GetClientSize(false)
		local w, h = this:GetSize()
		local wFact, hFact = Station.OriginalToAdjustPos(w, h)
		
		local fScale = wC / wFact
		if hFact * fScale > hC then
			fScale = hC / hFact
		end
		if wFact * fScale > 1280 then
			fScale = 1280 / wFact
		end
		if fScale ~= 1 then
			this:Scale(fScale, fScale)
		end
		
		local hTotal = this:Lookup("Wnd_All", "")		
		WorldMap.UpdateScale(hTotal)
		
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	elseif event == "UPDATE_ROAD_TRACK_FORCE" or event == "UPDATE_ROUTE_NODE_OPEN_LIST" or event == "ON_MAP_VISIT_FLAG_CHANGED" or event == "SYNC_ROLE_DATA_END" then
		WorldMap.Refresh(this)
	elseif event == "SELECT_CITY_COPY" then
		WorldMap.SelectCityOrCopy(this, arg0)
	end
end

function WorldMap.UpdateImageState(hImage)
	if hImage.bCity then
		if hImage.bSelect then
			hImage:FromTextureFile(hImage.button..WorldMap.tCityFrame.highlight ..".tga")
		elseif hImage.bEnable then
			if hImage.bDown then
				hImage:FromTextureFile(hImage.button.. WorldMap.tCityFrame.down .. ".tga")
			elseif hImage.bIn then
				hImage:FromTextureFile(hImage.button.. WorldMap.tCityFrame.over .. ".tga")
			else
				hImage:FromTextureFile(hImage.button.. WorldMap.tCityFrame.normal .. ".tga")
			end
		else
			hImage:FromTextureFile(hImage.button.. WorldMap.tCityFrame.disable ..  ".tga")
		end
	elseif hImage.copy then
		if hImage.bSelect then
			hImage:SetFrame(WorldMap.aCityButton[hImage.button].highlight)
		elseif hImage.bEnable then
			if hImage.bDown then
				hImage:SetFrame(WorldMap.aCityButton[hImage.button].down)
			elseif hImage.bIn then
				hImage:SetFrame(WorldMap.aCityButton[hImage.button].over)
			else
				hImage:SetFrame(WorldMap.aCityButton[hImage.button].normal)
			end
		else
			hImage:SetFrame(WorldMap.aCityButton[hImage.button].disable)
		end
	end
end

function WorldMap.UpdatePicPos(handle, fScale)
	local nCount = handle:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local img = handle:Lookup(i)
		img:SetRelPos(img.x / fScale, img.y / fScale)
		img:SetSize(img.w / fScale, img.h / fScale)
	end
	handle:FormatAllItemPos()
end

function WorldMap.UpdatePointPos(handle, fScale)
	nCount = handle:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local item = handle:Lookup(i)
		if item.w and item.h then
			item:SetSize(item.w / fScale, item.h / fScale)
		end
		local w, h = item:GetSize()
		item:SetRelPos(item.x / fScale - w / 2, item.y / fScale - h / 2)
	end
	handle:FormatAllItemPos()
end

function WorldMap.Refresh(frame)
	local player = GetClientPlayer()
	if not player then
		return
	end
	local hTotal = frame:Lookup("Wnd_All", "")

	local hPoint = hTotal:Lookup("Handle_Point")
	local nCount = hPoint:GetItemCount() - 1
	local nIndex = 0
	for k, v in ipairs(g_aTrafficLine) do
		local bShow, bOk = CheckRoadTrack(v.from, v.to)
		if nIndex > nCount then
			hPoint:AppendItemFromString("<image></image>")
		end
		local img = hPoint:Lookup(nIndex)
		nIndex = nIndex + 1
		if bShow then
			if bOk or not v.disablefile then
				img:FromTextureFile(v.file)
				img:SetUserData(1)
			else
				img:FromTextureFile(v.disablefile)
				img:SetUserData(0)
			end
		else
			if v.disablefile then
				img:FromTextureFile(v.disablefile)
				img:SetUserData(0)
			else
				img:FromTextureFile(v.file)
				img:SetUserData(1)
			end
		end
		img.x = v.x
		img.y = v.y
		img.w = v.w
		img.h = v.h			
	end	
	for i = nCount, nIndex, -1 do
		hPoint:RemoveItem(i)
	end
	hPoint:Sort()	
	WorldMap.UpdatePicPos(hPoint, WorldMap.GetMapScale(hTotal))
	
	local hCityBtn = hTotal:Lookup("Handle_CityBtn")
	local hFightCity = hTotal:Lookup("Handle_FightCity")
	local nCount = hCityBtn:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local img = hCityBtn:Lookup(i)
		local bInFight = WorldMap.IsCityInFight(img.id)
		img.bEnable = RoadTrackIsCityOpen(img.id)
		img.bInFight = bInFight
		if not WorldMap.bTraffic and img.mapid == 1 then
			img.bEnable = true
		end	
		
		if WorldMap.bTraffic and WorldMap.bTrafficByItem then
			if WorldMap.tCanTrafficMapList[img.mapid] then
				img.bEnable = true
			else
				img.bEnable = false
			end
		end
		
		WorldMap.UpdateImageState(img)
		
		local img = hFightCity:Lookup(i)
		img.bInFight = bInFight
		img:Show(bInFight)
	end
	
	local hCampFightCity = hTotal:Lookup("Handle_CampFightCity")
	local nCount = hCampFightCity:GetItemCount()- 1
	for i = 0, nCount, 1 do
		local img = hCampFightCity:Lookup(i)
		local bInCampFight = GetInCampFightCity() == img.id
		img:Show(bInCampFight)
	end
	
	local hCopyBtn = hTotal:Lookup("Handle_CopyBtn")
	local nCount = hCopyBtn:GetItemCount() - 1
	for i = 0, nCount, 1 do
		local img = hCopyBtn:Lookup(i)
		img.bEnable = player.GetMapVisitFlag(img.mapid)
		
		if WorldMap.bTraffic and WorldMap.bTrafficByItem then
			if WorldMap.tCanTrafficMapList[img.mapid] then
				img.bEnable = true
			else
				img.bEnable = false
			end
		end
		
		WorldMap.UpdateImageState(img)
	end
end

function WorldMap.UpdateScrollInfo(hMap)
	local w, h = hMap:GetSize()
	local wAll, hAll = hMap:GetAllItemSize()
	
	local wndParent = hMap:GetParent():GetParent()
	
	wndParent:Lookup("Scroll_H"):SetStepCount(wAll - w)
	if wAll > w + 1 then
		wndParent:Lookup("Scroll_H"):Show()
		wndParent:Lookup("Btn_UpH"):Show()
		wndParent:Lookup("Btn_DownH"):Show()
	else
		wndParent:Lookup("Scroll_H"):Hide()
		wndParent:Lookup("Btn_UpH"):Hide()
		wndParent:Lookup("Btn_DownH"):Hide()
	end
	
	wndParent:Lookup("Scroll_V"):SetStepCount(hAll - h)
	if hAll > h + 1 then
		wndParent:Lookup("Scroll_V"):Show()
		wndParent:Lookup("Btn_UpV"):Show()
		wndParent:Lookup("Btn_DownV"):Show()
	else
		wndParent:Lookup("Scroll_V"):Hide()
		wndParent:Lookup("Btn_UpV"):Hide()
		wndParent:Lookup("Btn_DownV"):Hide()
	end
	
	if wAll <= w and hAll <= h then
		wndParent:Lookup("Btn_Left"):Hide()
		wndParent:Lookup("Btn_Right"):Hide()
		wndParent:Lookup("Btn_Up"):Hide()
		wndParent:Lookup("Btn_Down"):Hide()
	else
		wndParent:Lookup("Btn_Left"):Show()
		wndParent:Lookup("Btn_Right"):Show()
		wndParent:Lookup("Btn_Up"):Show()
		wndParent:Lookup("Btn_Down"):Show()	
	end
end

function WorldMap.OnScrollBarPosChanged()
	local nCurrentValue = this:GetScrollPos()
	local handle = this:GetParent():Lookup("", "")
	local hMap = handle:Lookup("Handle_Map")
	local x, y = hMap:GetItemStartRelPos()
	local szName = this:GetName()
	if szName == "Scroll_Alpha" then
		local nAlpha = MIDDLE_MAP_MIN_ALPHA + (255 - MIDDLE_MAP_MIN_ALPHA) * nCurrentValue / this:GetStepCount()
		if nAlpha ~= WorldMap.nAlpha then
			WorldMap.nAlpha = nAlpha
		end
		local handle = this:GetParent():Lookup("", "")
		handle:Lookup("Handle_Map"):SetAlpha(WorldMap.nAlpha)
		handle:Lookup("Handle_Point"):SetAlpha(WorldMap.nAlpha)
		handle:Lookup("Handle_CityBtn"):SetAlpha(WorldMap.nAlpha)
		handle:Lookup("Handle_FightCity"):SetAlpha(WorldMap.nAlpha)
		handle:Lookup("Handle_CampFightCity"):SetAlpha(WorldMap.nAlpha)
		handle:Lookup("Handle_CityName"):SetAlpha(WorldMap.nAlpha)
		handle:Lookup("Handle_CopyBtn"):SetAlpha(WorldMap.nAlpha)
		handle:Lookup("Handle_Player"):SetAlpha(WorldMap.nAlpha)
		handle:Lookup("Text_AlphaPer"):SetText(math.floor(100 * WorldMap.nAlpha / 255).."%")
		return
	elseif szName == "Scroll_H" then
		if nCurrentValue == 0 then
			this:GetParent():Lookup("Btn_UpH"):Enable(0)
			this:GetParent():Lookup("Btn_Left"):Enable(0)
		else
			this:GetParent():Lookup("Btn_UpH"):Enable(1)
			this:GetParent():Lookup("Btn_Left"):Enable(1)
		end	
		
		if nCurrentValue == this:GetStepCount() then
			this:GetParent():Lookup("Btn_DownH"):Enable(0)
			this:GetParent():Lookup("Btn_Right"):Enable(0)
		else
			this:GetParent():Lookup("Btn_DownH"):Enable(1)
			this:GetParent():Lookup("Btn_Right"):Enable(1)
		end
		x = -nCurrentValue
	elseif szName == "Scroll_V"  then
		if nCurrentValue == 0 then
			this:GetParent():Lookup("Btn_UpV"):Enable(0)
			this:GetParent():Lookup("Btn_Up"):Enable(0)
		else
			this:GetParent():Lookup("Btn_UpV"):Enable(1)
			this:GetParent():Lookup("Btn_Up"):Enable(1)
		end	
		
		if nCurrentValue == this:GetStepCount() then
			this:GetParent():Lookup("Btn_DownV"):Enable(0)
			this:GetParent():Lookup("Btn_Down"):Enable(0)
		else
			this:GetParent():Lookup("Btn_DownV"):Enable(1)
			this:GetParent():Lookup("Btn_Down"):Enable(1)
		end
		y = -nCurrentValue
	end
	hMap:SetItemStartRelPos(x, y)
	handle:Lookup("Handle_Point"):SetItemStartRelPos(x, y)
	handle:Lookup("Handle_CityBtn"):SetItemStartRelPos(x, y)
	handle:Lookup("Handle_FightCity"):SetItemStartRelPos(x, y)
	handle:Lookup("Handle_CampFightCity"):SetItemStartRelPos(x, y)
	handle:Lookup("Handle_CityName"):SetItemStartRelPos(x, y)
	handle:Lookup("Handle_CopyBtn"):SetItemStartRelPos(x, y)
	handle:Lookup("Handle_Player"):SetItemStartRelPos(x, y)
end

function WorldMap.OnItemMouseWheel()
	local fScaleMin, fScaleMax = WorldMap.GetScaleRange(this:GetParent())
	local nDistance = Station.GetMessageWheelDelta()
	local fScale = WorldMap.fScale
	if fScale < fScaleMin then
		fScale = fScaleMin
	end
	if fScale > fScaleMax then
		fScale = fScaleMax
	end
	if nDistance < 0 then
		local i = 0
		while i < -nDistance do
			fScale = fScale * 1.1
			i = i + 1
		end
		if fScale > fScaleMax then
			fScale = fScaleMax
		end		
	elseif nDistance > 0 then
		local i = 0
		while i < nDistance do
			fScale = fScale * 0.9
			i = i + 1
		end
		if fScale < fScaleMin then
			fScale = fScaleMin
		end
	end
	WorldMap.fScale = fScale
	
	local hTotal = this:GetParent()
	WorldMap.UpdateScaleBtnState(hTotal)
	WorldMap.UpdateScale(hTotal)
	
	--this:GetParent():GetParent():Lookup("Scroll_V"):ScrollNext(nDistance * 4)
	return true
end

function WorldMap.OnItemLButtonDown()
	if this.button and this.bEnable then
		this.bDown = true
		WorldMap.UpdateImageState(this)
	elseif this:GetName() == "Handle_Map" then
		local frame = this:GetRoot()
		frame.bDrag = true
		frame.fDragX, frame.fDragY = Station.GetMessagePos()
	end
end

function WorldMap.OnItemMouseEnter()
	if this.button then
		this.bIn = true
		local szTip = Table_GetMapTip(this.mapid)
		WorldMap.UpdateImageState(this)
		
		--local szTip = GetFormatText(this.tip .. "\n", 162)
		local _, _, _, _, nCampType = GetMapParams(this.mapid)
		if nCampType then
			szTip = szTip .. GetFormatText("\n"..g_tStrings.STR_MAP_CAMP_TYPE[nCampType], 163)
		end
		local nX, nY = Cursor.GetPos()
		if szTip then
			OutputTip(szTip, 400, {nX, nY, 10, 10})
		end
	elseif this.bPlayerAni then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		w = w + 20
		h = h + 20
		OutputTip("<text>text="..EncodeComponentsString(g_tStrings.MAP_POSITION_SELF).."</text>", 200, {x, y, w, h})	
	elseif this.aTeammate then
		local x, y = this:GetAbsPos()
		local w, h = this:GetSize()
		w = w + 20
		h = h + 20
		local szNameList = ""
		for k, v in pairs(this.aTeammate) do
			local szName = GetTeammateName(v)
			if szName then
				szNameList = szNameList..szName.."\n"
			end
		end
		if szNameList ~= "" then
			local r, g, b = GetPartyMemberFontColor()
			local szTip = "<text>text="..EncodeComponentsString(g_tStrings.MAP_PARTY).."</text><text>text="..EncodeComponentsString(szNameList).."font=80 r="..r.." g="..g.." b="..b.."</text>"
			OutputTip(szTip, 200, {x, y, w, h})
		end
	end
end

function WorldMap.OnItemMouseLeave()
	HideTip()
	if this.button then
		this.bIn = false
		WorldMap.UpdateImageState(this)
		this:GetParent():GetParent():Lookup("Text_Tip"):SetText("")
	elseif this.bPlayerAni then
		HideTip()
	elseif this.aTeammate then
		HideTip()
	end
end

function WorldMap.OnItemLButtonUp()
	if this.button and this.bEnable then
		this.bDown = false
		WorldMap.UpdateImageState(this)
	end
	local frame = this:GetRoot()
	frame.bDrag = false	
end

function WorldMap.IsSafeToMap(dwMapID)
    local hPlayer = GetClientPlayer()
    if not hPlayer then
        return false
    end
    
    if hPlayer.nCamp == CAMP.NEUTRAL then
        return true
    end
    
    local _, _, _, _, nCampType = GetMapParams(this.mapid)
    if nCampType == MAP_CAMP_TYPE.ALL_PROTECT then
        return true
    end
    
    return false
end

function WorldMap.OnItemLButtonClick()
	if this.button then
		if WorldMap.bTraffic then
			if this.bEnable then
				if WorldMap.bTrafficSkill then
					if this.mapid == GetClientPlayer().GetScene().dwMapID then
						OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.TRAFFIC_ALEADY_IN_THIS_MAP)
					else
						if this.mapid == 1 then
							OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.TRAFFIC_CAN_NOT_GO)
						else
                            if WorldMap.IsSafeToMap(this.mapid) then
                                CastSkillXYZ(3691, 1,this.mapid,0,0) --´«ËÍ¼¼ÄÜ
                                CloseWorldMap(true)
                             else
                                OpenTrafficSurepanel(nil, nil, nil, nil, {this.mapid})
                             end
						end
					end
				elseif WorldMap.bTrafficByItem then
					if this.mapid == GetClientPlayer().GetScene().dwMapID then
						OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.TRAFFIC_ALEADY_IN_THIS_MAP)
					else
						if this.mapid == 1 then
							OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.TRAFFIC_CAN_NOT_GO)
						else
                            if WorldMap.IsSafeToMap(this.mapid) then
                                RemoteCallToServer("OnItemTransferToCityRequest", WorldMap.nItemID, this.mapid)
                                CloseWorldMap(true)
                            else
                                OpenTrafficSurepanel(nil, nil, nil, nil, nil, {WorldMap.nItemID, this.mapid})
                            end
						end
				    end
				else
					if this.copy then
						OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.TRAFFIC_CAN_NOT_TO_COPY)
					elseif this.mapid == GetClientPlayer().GetScene().dwMapID then
						OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.TRAFFIC_ALEADY_IN_THIS_MAP)
					else
						OpenTrafficSurepanel(WorldMap.dwTrafficPointID, this.id, this.city)
					end
				end
			end
		else
			OpenMiddleMap(this.mapid, this.middlemapindex)
			CloseWorldMap(true)
		end
		PlaySound(SOUND.UI_SOUND, g_sound.Button)
	end
end

function WorldMap.OnItemLButtonDBClick()
	WorldMap.OnItemLButtonClick()
end

function WorldMap.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		CloseWorldMap()
    end
end

function WorldMap.OnLButtonDBClick()
	WorldMap.OnLButtonHold()
end

function WorldMap.OnLButtonDown()
	WorldMap.OnLButtonHold()
end

function WorldMap.OnLButtonHold()
	local szName = this:GetName()
	if szName == "Btn_UpH" then
		this:GetParent():Lookup("Scroll_H"):ScrollPrev(4)
	elseif szName == "Btn_Left" then
		this:GetParent():Lookup("Scroll_H"):ScrollPrev(40)
	elseif szName == "Btn_DownH" then
		this:GetParent():Lookup("Scroll_H"):ScrollNext(4)	
	elseif szName == "Btn_Right" then
		this:GetParent():Lookup("Scroll_H"):ScrollNext(40)
	elseif szName == "Btn_UpV" then
		this:GetParent():Lookup("Scroll_V"):ScrollPrev(4)
	elseif szName == "Btn_Up" then 
		this:GetParent():Lookup("Scroll_V"):ScrollPrev(40)
	elseif szName == "Btn_DownV" then
		this:GetParent():Lookup("Scroll_V"):ScrollNext(4)
	elseif szName == "Btn_Down" then
		this:GetParent():Lookup("Scroll_V"):ScrollNext(40)
	elseif szName == "Btn_Big" then
		local hTotal = this:GetParent():Lookup("", "")
		local fScaleMin, fScaleMax = WorldMap.GetScaleRange(hTotal)
		local fScale = WorldMap.fScale
		if fScale < fScaleMin then
			fScale = fScaleMin
		end
		fScale = fScale * 1.1
		if fScale > fScaleMax then
			fScale = fScaleMax
		end		
		WorldMap.fScale = fScale
		WorldMap.UpdateScaleBtnState(hTotal)
		WorldMap.UpdateScale(hTotal)
	elseif szName == "Btn_Small" then
		local hTotal = this:GetParent():Lookup("", "")
		local fScaleMin, fScaleMax = WorldMap.GetScaleRange(hTotal)
		local fScale = WorldMap.fScale
		if fScale > fScaleMax then
			fScale = fScaleMax
		end
		fScale = fScale * 0.9
		if fScale < fScaleMin then
			fScale = fScaleMin
		end
		WorldMap.fScale = fScale	
		WorldMap.UpdateScaleBtnState(hTotal)
		WorldMap.UpdateScale(hTotal)
    end
end

function WorldMap.UpdateScaleBtnState(hTotal)
	local fScaleMin, fScaleMax = WorldMap.GetScaleRange(hTotal)
	local wnd = hTotal:GetParent()
	if WorldMap.fScale >= fScaleMax then
		wnd:Lookup("Btn_Big"):Enable(false)
	else
		wnd:Lookup("Btn_Big"):Enable(true)
	end

	if WorldMap.fScale <= fScaleMin then
		wnd:Lookup("Btn_Small"):Enable(false)
	else
		wnd:Lookup("Btn_Small"):Enable(true)
	end
end

function WorldMap.Init(frame)
	local thisSave = this
	this = frame
	WorldMap.OnFrameBreathe()
	this = thisSave
	WorldMap.ScrollPlayerToVisiblePos(frame)
	
	RoadTrackForceRequest()
	
	frame:Lookup("Wnd_All/Scroll_Alpha"):SetScrollPos(WorldMap.nAlpha)
	frame:Lookup("Wnd_All", "Text_AlphaPer"):SetText(math.floor(100 * WorldMap.nAlpha / 255).."%")
end

function WorldMap.SelectCityOrCopy(hFrame, dwMapID)
	hCityList = hFrame:Lookup("Wnd_All", "Handle_CityBtn")
	hCopyList = hFrame:Lookup("Wnd_All", "Handle_CopyBtn")
	
	local nCount = hCityList:GetItemCount()
	local hSelect = nil
	local hChild = nil
	local nSelectCopy = false
	for i = 0, nCount - 1 do
		hChild = hCityList:Lookup(i)
		local nTransMap = tTransMap[dwMapID]
		if (hChild.mapid and hChild.mapid == dwMapID) or (nTransMap and nTransMap == hChild.mapid) then
			hChild.bSelect = true
			WorldMap.UpdateImageState(hChild)
			hSelect = hChild
		elseif hChild.bSelect then
			hChild.bSelect = false
			WorldMap.UpdateImageState(hChild)
		end
	end
	
	nCount = hCopyList:GetItemCount()
	for i = 0, nCount - 1 do
		hChild = hCopyList:Lookup(i)
		local nTransMap = tTransMap[dwMapID]
		if (hChild.mapid and hChild.mapid == dwMapID) or (nTransMap and nTransMap == hChild.mapid) then
			hChild.bSelect = true
			WorldMap.UpdateImageState(hChild)
			hSelect = hChild
			nSelectCopy = true
		elseif hChild.bSelect then
			hChild.bSelect = false
			WorldMap.UpdateImageState(hChild)
		end
	end
	
	if hSelect then		
		local hMap = hFrame:Lookup("Wnd_All", "Handle_Map")
		local nPosX, nPosY = hSelect:GetRelPos()
		local nWidth, nHeight = hCityList:GetSize()
		local hScrollWidth = hFrame:Lookup("Wnd_All/Scroll_H")
		local hScrollHeight = hFrame:Lookup("Wnd_All/Scroll_V")
		
		hScrollWidth:SetScrollPos(nPosX - nWidth / 2)
		hScrollHeight:SetScrollPos(nPosY - nHeight / 2)
	else
		if not nSelectCopy then
			local nWidth, nHeight = Station.GetClientSize()
			local tMsg =
			{
				x = nWidth / 2, y = nHeight / 2,
				szMessage = g_tStrings.SUGGEST_COPY_PARTY_RECRUIT_TIP,
				szName = "SelectCopy",
				{szOption = g_tStrings.STR_HOTKEY_SURE, fnAction = function() end}
			}
			MessageBox(tMsg)
			CloseWorldMap()
		end
	end
end

function OpenWorldMap(bTraffic, dwTrafficPointID, bTrafficSkill, bDisableSound)
	if not WorldMap.bOpenItem then
		WorldMap.tCanTrafficMapList = nil
		WorldMap.bTrafficByItem = nil
		WorldMap.nItemID = nil
	end

	WorldMap.bTraffic = bTraffic
	WorldMap.dwTrafficPointID = dwTrafficPointID
	WorldMap.bTrafficSkill = bTrafficSkill
	local frame = Station.Lookup("Topmost1/WorldMap")
	if frame then
		frame:Show()
	else
		frame = Wnd.OpenWindow("WorldMap")
	end
	
	WorldMap.Init(frame)
	if bTraffic then
		FireHelpEvent("OnOpenpanel", "TRAFFIC")
	end
	
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)
	end
	
	if not bTraffic and not GetClientPlayer().IsAchievementAcquired(1005) then
		RemoteCallToServer("OnClientAddAchievement", "Open_World_Map")
	end
	
	WorldMap.nLastAlpha = WorldMap.nAlpha
end

function OpenWorldMapByItem(bTraffic, nItemID, tCanTrafficMapList, bDisableSound)
	WorldMap.tCanTrafficMapList = tCanTrafficMapList
	WorldMap.bTrafficByItem = true
	WorldMap.nItemID = nItemID
	
	WorldMap.bOpenItem = true;
	OpenWorldMap(bTraffic)
	WorldMap.bOpenItem = false;
	
	FireEvent("ON_MAP_VISIT_FLAG_CHANGED")
end

function IsWorldMapOpend()
	local frame = Station.Lookup("Topmost1/WorldMap")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function CloseWorldMap(bDisableSound)
	local frame = Station.Lookup("Topmost1/WorldMap")
	if frame then
		frame:Hide()
	end
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND,g_sound.CloseFrame)
	end
	
	if WorldMap.nLastAlpha and WorldMap.nLastAlpha ~= WorldMap.nAlpha then
		FireDataAnalysisEvent("ADJUST_WORLD_MAP_DIAPHANEITY", {WorldMap.nAlpha})
		WorldMap.nLastAlpha = nil
	end
end

function GetInCampFightCity()
	local szCampFightLeftTime, _, nWeekday = CampActiveTime.GetTime()
	if CampActiveTime.tNextCampBattleDay[nWeekday] > 0 then
		return
	end
	
	if szCampFightLeftTime == g_tStrings.CAMPACTIVE_END_LEFT_TIME then
		if nWeekday == 4 or nWeekday == 0 then
			return 27
		elseif nWeekday == 3 or nWeekday == 6 then
			return 25
		end
	end
end