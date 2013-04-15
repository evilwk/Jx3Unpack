TrafficSurepanel = {}

function TrafficSurepanel.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	TrafficSurepanel.OnEvent("UI_SCALED")
end

function TrafficSurepanel.OnFrameBreathe()
	if TrafficSurepanel.bMiddleTraffic then
		if not IsMiddleMapOpened() then
			Wnd.CloseWindow("TrafficSurepanel")
		end
	else
		if not IsWorldMapOpend() then
			Wnd.CloseWindow("TrafficSurepanel")
		end
	end
end

function TrafficSurepanel.OnEvent(event)
	if event == "UI_SCALED" then
		this:SetPoint("CENTER", 0, 0, "CENTER", 0, 0)
	end
end

function TrafficSurepanel.OnLButtonClick()
	if this:GetName() == "Btn_Ok" then
		CloseTrafficSurepanel(true)
		if TrafficSurepanel.bMiddleTraffic then
            RoadTrackStartOut(TrafficSurepanel.dwPoint, TrafficSurepanel.dwCity, TrafficSurepanel.dwCost)
			CloseMiddleMap(true)
        elseif TrafficSurepanel.tTrafficSkill then
            CastSkillXYZ(3691,1, TrafficSurepanel.tTrafficSkill[1],0,0) --传送技能
			CloseWorldMap(true)
        elseif TrafficSurepanel.tTrafficByItem then
            RemoteCallToServer("OnItemTransferToCityRequest", TrafficSurepanel.tTrafficByItem[1], TrafficSurepanel.tTrafficByItem[2])
			CloseWorldMap(true)
        else
            RoadTrackStartOut(TrafficSurepanel.dwPoint, TrafficSurepanel.dwCity, TrafficSurepanel.dwCost)
			CloseWorldMap()
		end
	elseif this:GetName() == "Btn_Cancel" then
		CloseTrafficSurepanel()
	end
end

function OpenTrafficSurepanel(dwPoint, dwCity, szCity, bMiddleTraffic, tTrafficSkill, tTrafficByItem, bDisableSound)
	local bOk
	local dwCost = 0
	if not bMiddleTraffic and not tTrafficSkill and not tTrafficByItem then
		bOk, dwCost = CalculateTrackCost(dwPoint, dwCity)
		if not bOk then --去不了
			OutputMessage("MSG_ANNOUNCE_RED",g_tStrings.TRAFFIC_CANNOT_ARRIVE)
			return
		end
		
		if dwCost > GetClientPlayer().GetMoney() then --钱不够
			OutputMessage("MSG_ANNOUNCE_RED",FormatString(g_tStrings.TRAFFIC_NOT_ENOUGH_MONEY, GetMoneyPureText(dwCost - GetClientPlayer().GetMoney())))
			return
		end
	end
	
	TrafficSurepanel.dwPoint = dwPoint
	TrafficSurepanel.dwCity = dwCity
	TrafficSurepanel.dwCost = dwCost
	
	local frame = Wnd.OpenWindow("TrafficSurepanel")
	local handle = frame:Lookup("Wnd_All", "Handle_Message")
	handle:Clear()
	local szInfo = ""
    TrafficSurepanel.bMiddleTraffic = bMiddleTraffic
    TrafficSurepanel.tTrafficSkill = tTrafficSkill
    TrafficSurepanel.tTrafficByItem = tTrafficByItem
	if bMiddleTraffic then
		local szText = FormatString(g_tStrings.TRAFFIC_MIDDLE_SURE, szCity)
		szInfo = GetFormatText(szText, 18)
    elseif tTrafficSkill then
        szInfo = GetFormatText(g_tStrings.TRAFFIC_TO_FIGHT_MAP_SURE, 18)
    elseif tTrafficByItem then
        szInfo = GetFormatText(g_tStrings.TRAFFIC_TO_FIGHT_MAP_SURE, 18)
	else
		szInfo = GetFormatText(FormatString(g_tStrings.TRAFFIC_SURE_GO,szCity), 18) .. GetMoneyText(dwCost, "font=27")
	end
	
	
	handle:AppendItemFromString(szInfo)
	handle:FormatAllItemPos()
end

function IsTrafficSurepanelOpened()
	if Station.Lookup("Topmost2/TrafficSurepanel") then
		return true
	end
	return false
end

function CloseTrafficSurepanel(bDisableSound)
	Wnd.CloseWindow("TrafficSurepanel")
	if not bDisableSound then
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
end