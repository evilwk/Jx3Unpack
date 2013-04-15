SingleFStatistic = {}
local OBJECT = SingleFStatistic
local INI_FILE = "ui/config/default/SingleFStatistic.ini"

local FRAME_PTR
function SingleFStatistic.OnFrameCreate()
	FRAME_PTR = this
	OBJECT.UpdateContent(this)
end

function SingleFStatistic.UpdateContent(hFrame)
	local tData = SingleFStatistic.tData or {}
	local tPlayerInfo = tData.tPlayerInfo
	
	hFrame:Lookup("", "Text_Title"):SetText(tPlayerInfo.szPlayerName)
	hFrame:Lookup("", "Text_Lv"):SetText(g_tStrings.STR_GUILD_LEVEL..tPlayerInfo.nLevel.." "..g_tStrings.tForceTitle[tPlayerInfo.dwForceID])
	
	local hList = hFrame:Lookup("", "Handle_hurt/Handle_SkillList")
	hList:Clear()
	
	local nTotalValue = tData.nTotalValue or 0
	local tSkill = tData.tSkill or {}
	
	local function cmp(a, b)
		if a.nDamage ~= b.nDamage then	
			return a.nDamage > b.nDamage
		end
		return a.dwCount > b.dwCount
	end
	table.sort(tSkill, cmp)
	
	local nSelIndex = -1
	for k, v in pairs(tSkill) do
		local szSkillName = FStatistic_GetDamageSrcName(v.dwID, v.nSrcType)
		local hItem = hList:AppendItemFromIni(INI_FILE, "Handle_Skill")
		hItem.tInfo = v
		hItem.szSkillName = szSkillName
		
		if v.nType == 1 and v.nDamage ~= 0 then
			hItem:Lookup("Text_SKill"):SetText(szSkillName.."("..g_tStrings.STR_THERAPY ..")")
		else
			if v.dwReact == 0 then
				hItem:Lookup("Text_SKill"):SetText(szSkillName)
			else
				hItem:Lookup("Text_SKill"):SetText(g_tStrings.STR_DAMAGE_REACT)
			end
		end
		hItem:Lookup("Text_SkillDegree"):SetText(v.dwCount)
		hItem:Lookup("Text_SkillHurt"):SetText(v.nDamage)
		
		local szPercent = FightStat_FormatPercent(v.nDamage, nTotalValue)
		hItem:Lookup("Text_SkillProportion"):SetText(szPercent)
		
		if nSelIndex == -1 and (not hFrame.szSkillName or hFrame.szSkillName == szSkillName) then
			nSelIndex = hItem:GetIndex()
			if nSelIndex == -1 then
				nSelIndex = 0
			end
		end
	end
	FireUIEvent("SCROLL_UPDATE_LIST", "Handle_SkillList", "SingleFStatistic", true)
	
	if nSelIndex == -1 then
		nSelIndex = 0
	end
			
	local nCount = hList:GetItemCount()
	if nCount > 0 and nSelIndex ~= -1 then
		SingleFStatistic.SelItem(hList:Lookup(nSelIndex))
	else
		local hTot = hFrame:Lookup("", "Handle_Start")
		local hList = hTot:Lookup("Handle_StyleList")
		hList:Clear()
	end
end

function SingleFStatistic.UpdateSkillType(hFrame, tInfo)
	local hTot = hFrame:Lookup("", "Handle_Start")
	local hList = hTot:Lookup("Handle_StyleList")
	hList:Clear()
	
	for i=1, 8, 1 do
		hList:AppendItemFromIni(INI_FILE, "Handle_Style")
	end
	
	local function MathFloor(fValue)
		if not fValue then
			return ""
		end
		return math.floor(fValue)
	end
	
	local function SetItemValue(nIndex, szName, nMin, nAvg, nMax, nCount, fPercent)
		local hItem = hList:Lookup(nIndex)
		hItem:Lookup("Text_StyleHit"):SetText(szName);
		hItem:Lookup("Text_StyleLeast"):SetText(MathFloor(nMin));
		hItem:Lookup("Text_StyleAverage"):SetText(MathFloor(nAvg));
		hItem:Lookup("Text_StyleMost"):SetText(MathFloor(nMax));
		hItem:Lookup("Text_StyleDegreel"):SetText(nCount);
		hItem:Lookup("Text_StyleProportion"):SetText(fPercent or "");
	end

	--g_tStrings.STR_HIT_NAME..
	local nTotalValue = tInfo.nDamage
	local nCount = tInfo.dwHit - tInfo.dwCriticalStrike - tInfo.dwInsight - tInfo.dwDodge
	local nAvgValue = 0
	if nCount ~= 0 then
		nAvgValue= math.floor(tInfo.nTotalDamage / nCount + 0.0005)
	end
	local szPercent = FightStat_FormatPercent(tInfo.nTotalDamage, nTotalValue)
	SetItemValue(0, g_tStrings.STR_HIT_NOTCS_NAME, tInfo.nMinDamage, nAvgValue, tInfo.nMaxDamage, nCount, szPercent);

	nAvgValue = 0
	if tInfo.dwCriticalStrike ~= 0 then
		nAvgValue = math.floor(tInfo.nTotalCSDamage / tInfo.dwCriticalStrike + 0.0005)
	end
	szPercent = FightStat_FormatPercent(tInfo.nTotalCSDamage, nTotalValue)
	SetItemValue(1, g_tStrings.STR_CS_NAME, tInfo.nMinCSDamage, nAvgValue, tInfo.nMaxCSDamage, tInfo.dwCriticalStrike, szPercent);
	
	SetItemValue(2, g_tStrings.STR_INSIGHT_NAME, nil, nil, nil, tInfo.dwInsight);
	SetItemValue(3, g_tStrings.STR_MISS_NAME, nil, nil, nil, tInfo.dwCount - tInfo.dwHit- tInfo.dwShield);
	
	SetItemValue(4, g_tStrings.STR_DODGE_NAME, nil, nil, nil, tInfo.dwDodge);
	SetItemValue(5, g_tStrings.STR_PARRY_NAME, nil, nil, nil, tInfo.dwParry);
	SetItemValue(6, g_tStrings.STR_SHIELD_NAME, nil, nil, nil, tInfo.dwShield);
	SetItemValue(7, g_tStrings.STR_IMMUNITY_NAME, nil, nil, nil, tInfo.dwSkillImmunity);
	
	FireUIEvent("SCROLL_UPDATE_LIST", "Handle_StyleList", "SingleFStatistic", true)
end

function SingleFStatistic.UpdateItemBg(hItem)
	local img = hItem:Lookup("Image_Sel")
	if not img then
		return
	end
	if hItem.bSel then
		img:Show()
	elseif hItem.bOver then
		img:Show()
	else
		img:Hide()
	end
end

function SingleFStatistic.SelItem(hSelItem)
	local hList = hSelItem:GetParent()
	local nCount = hList:GetItemCount()
	for i = 0, nCount -1, 1 do
		local hItem = hList:Lookup(i)
		if hItem.bSel then
			hItem.bSel = false
			OBJECT.UpdateItemBg(hItem)
		end
	end
	hSelItem.bSel = true
	OBJECT.UpdateItemBg(hSelItem)
	local hFrame = hList:GetRoot()
	hFrame.szSkillName = hSelItem.szSkillName
	SingleFStatistic.UpdateSkillType(hFrame, hSelItem.tInfo)
end

function SingleFStatistic.OnItemLButtonDown()
	local szName = this:GetName()
	if szName == "Handle_Skill" then
		OBJECT.SelItem(this)
	end
end

function SingleFStatistic.OnItemMouseEnter()
	local szName = this:GetName()
	if szName == "Handle_Skill"then
		this.bOver = true;
		OBJECT.UpdateItemBg(this)
	end
end

function SingleFStatistic.OnItemMouseLeave()
	local szName = this:GetName()
	if szName == "Handle_Skill" then
		this.bOver = false;
		OBJECT.UpdateItemBg(this)
	end
end

function SingleFStatistic.OnLButtonClick()
	local szName = this:GetName()
	if szName == "Btn_Close" then
		CloseSingleFStatistic()
	end
end

function SingleFStatistic_GetData()
	if IsSingleFStatisticOpened() then
		return SingleFStatistic.tData
	end
	return nil
end

function SingleFStatistic_UpdateData(tData)
	if tData and IsSingleFStatisticOpened() and FRAME_PTR then
		SingleFStatistic.tData = tData
		SingleFStatistic.UpdateContent(FRAME_PTR)
	end
end

function IsSingleFStatisticOpened()
	local frame = Station.Lookup("Normal/SingleFStatistic")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function OpenSingleFStatistic(tData, bDisableSound)
    if IsSingleFStatisticOpened() then
		SingleFStatistic.tData = tData
		local frame = Station.Lookup("Normal/SingleFStatistic")
		SingleFStatistic.UpdateContent(frame)
        return
    end
    
	SingleFStatistic.tData = tData
	Wnd.OpenWindow("SingleFStatistic")
end

function CloseSingleFStatistic()
    if IsSingleFStatisticOpened() then
		Wnd.CloseWindow("SingleFStatistic")
	end
end

local function RegisterSingleFStatistic()
    RegisterScrollEvent("SingleFStatistic")
    
    UnRegisterScrollAllControl("SingleFStatistic")
        
    local szFramePath = "Normal/SingleFStatistic"
    local szWndPath = ""
    RegisterScrollControl(
        szFramePath, 
        "Btn_Up", "Btn_Down", 
        "Scroll_List", 
        {szWndPath, "Handle_hurt/Handle_SkillList"})
		
	RegisterScrollControl(
        szFramePath, 
        "Btn_UpT", "Btn_DownT", 
        "Scroll_ListT", 
        {szWndPath, "Handle_Start/Handle_StyleList"})
end
RegisterSingleFStatistic()