
function GetLocalTimeText()
	local nTime = GetCurrentTime()
	local t = TimeToDate(nTime)
	return FormatString(g_tStrings.STR_TIME, t.hour, t.minute, t.second, t.year, t.month, t.day)
end

function GetTimeText(nTime, bFrame, bShot, bInt, bCeil)
	if not nTime then
		Trace("/ui/script/base.lua GetTimeText nTime is nil")
		Trace(var2str(debug.traceback()))
		return ""
	end
	
	if bFrame then
		nTime = nTime / GLOBAL.GAME_FPS
	end
	
	local nD = math.floor(nTime / 3600 / 24)
	local nH = math.floor(nTime / 3600 % 24)
	local nM = math.floor((nTime % 3600) / 60)
	local nS = (nTime % 3600) % 60
	if bInt then
		if bCeil then
			nS = math.ceil(nS)
		else
			nS = math.floor(nS)
		end
	else
		nS = tonumber(FixFloat(nS, 2))
	end
	
	if bShot then
		if nD ~= 0 then
			if bCeil and (nH ~= 0 or nM ~= 0 or nS ~= 0) then
				nD = nD + 1
			end
			return nD..g_tStrings.STR_BUFF_H_TIME_D
		end
		if nH ~= 0 then
			if bCeil and (nM ~= 0 or nS ~= 0) then
				nH = nH + 1
			end
			return nH..g_tStrings.STR_BUFF_H_TIME_H
		end
		if nM > 0 then
			if bCeil and nS ~= 0 then
				nM = nM + 1
			end
			return nM..g_tStrings.STR_BUFF_H_TIME_M
		end
		return nS..g_tStrings.STR_BUFF_H_TIME_S
	end
	
	local szTimeText = ""
	if nD ~= 0 then
		szTimeText = szTimeText .. nD .. g_tStrings.STR_BUFF_H_TIME_D
	end
	if nH ~= 0 then
		szTimeText = szTimeText .. nH .. g_tStrings.STR_BUFF_H_TIME_H
	end
	if nM ~= 0 then
		szTimeText = szTimeText .. nM .. g_tStrings.STR_BUFF_H_TIME_M
	end
	if nS ~= 0 then
		szTimeText = szTimeText .. nS .. g_tStrings.STR_BUFF_H_TIME_S
	end
	return szTimeText
end

function clone(var)
	local szType = type(var)
	if szType == "nil"
	or szType == "boolean"
	or szType == "number" 
	or szType == "string" then
		return var
	elseif szType == "table" then
		local tTable = {}
		for key, val in pairs(var) do
			key = clone(key)
			val = clone(val)
			tTable[key] = val
		end
		return tTable
	elseif szType == "function" 
	or szType == "userdata" then
		return nil
	else
		return nil
	end	
end

function var2str(var, szIndent)
	local szType = type(var)
	if szType == "nil" then
		return "nil"
	elseif szType == "number" then
		return tostring(var)
	elseif szType == "string" then
		return string.format("%q", var)
	elseif szType == "function" then
		local szCode = string.dump(var)
		local arByte = { string.byte(szCode, i, #szCode) }
		szCode	= ""
		for i = 1, #arByte do
			szCode	= szCode..'\\'..arByte[i]
		end
		return 'loadstring("' .. szCode .. '")'
	elseif szType == "table" then
		if not szIndent then
			szIndent = ""
		end
		
		local szTbBlank	= szIndent .. "  "
		local szCode = ""
		
		for key, val in pairs(var) do
			local szPair = szTbBlank .. "[" .. var2str(key) .. "] = " .. var2str(val, szTbBlank) .. ",\n"
			szCode = szCode .. szPair
		end
		
		if (szCode == "") then
			return "{}"
		else
			return "\n"..szIndent.."{\n"..szCode..szIndent.."}"
		end
	elseif szType == "boolean" then
		return tostring(var)
	else	--if (szType == "userdata") then
		return '"' .. tostring(var) .. '"'
	end
end

function UILog(...)
  	local arg = {...}
	arg.n = nil -- param count
	
	local szMsg = var2str(arg)
	if Log then
		Log("[UI DEBUG]" .. szMsg)
	end
	
	if OutputMessage then
		OutputMessage("MSG_SYS", szMsg)
	end
end

function GetFormatText(szText, nFont, nR, nG, nB, nEvent, szScript, szName, dwUserData, szLinkInfo)
	local szFont = ""
	if nFont then
		szFont = " font=" .. nFont
	end
	
	local szColor = ""
	if nR and nG and nB then
		szColor = string.format(" r=%d g=%d b=%d", nR, nG, nB)
	end
	
	local szEventText = ""
	if nEvent then
		szEventText = " eventid=" .. nEvent
	end
	
	local szScriptText = ""
	if szScript then
		szScriptText = " script=" .. EncodeComponentsString(szScript)
	end
    
    local szNameText = ""
	if szName then
		szNameText = " name=" .. EncodeComponentsString(szName)
	end
	
	local szUserDataText = ""
	if dwUserData then
		szUserDataText = " userdata=" .. dwUserData
	end
    
    local szLink=""
    if szLinkInfo then
        szLink = " link="..EncodeComponentsString(szLinkInfo)
    end
    
	return "<text>text=" .. EncodeComponentsString(szText) .. szFont .. szColor .. szEventText .. szScriptText  .. szNameText .. szUserDataText .. szLink .."</text>"
end

function FormatHandle(szItem)
	return "<handle> handletype=3 " .. szItem .. "</handle>"
end

function GetFormatImage(szPath, nFrame, nWidth, nHeight, nEventID, szImageName)
	local szSize = ""
	if nWidth and nHeight then
		szSize = "w=" .. nWidth .. " h=" .. nHeight .. " "
	end
	local szEventID = ""
	if nEventID then
		szEventID = "eventid=" .. nEventID .. " "
	end
	local szName = ""
	if szImageName then
		szName = "name=\"" .. szImageName .. "\" "
	end
	return "<image>" .. szSize .. "path=\"" .. szPath .. "\" frame=" .. nFrame .. " " .. szEventID .. szName ..  "</image>"
end

function KeepOneByteFloat(f)
	return string.format("%g", string.format("%.1f", f))
end

function KeepTwoByteFloat(f)
	return string.format("%g", string.format("%.2f", f))
end

function FixFloat(fNum, nEPS)
	if not nEPS then
		nEPS = 0
	end
	assert(nEPS >= 0)
	return string.format("%g", string.format("%." .. nEPS .. "f", fNum))
end

function GetIntergerBit(nNumber)
	local fBit = math.log10(nNumber)
	local nLargest = math.floor(fBit)
	return nLargest + 1
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- 带加速度的进度条

local tProgressPath = {}
local PROGRESS_DEFUALT_IV = 0.1
local PROGRESS_DEFUALT_ACC = 1

function SetAcceleratProgress(hProgress, fPercent, fIV, fACC, bIgnoreAdjust, fnOnUpdateProgress)
	if not hProgress then
		return
	end
	
	if fPercent > 1 then
		fPercent = 1
	end
		
	local fCurPercent = hProgress:GetPercentage()
	if fCurPercent == fPercent then
		return
	end
	
	local fAdjustPercent = nil
	if fIV == 0 and fACC == 0 then
		fAdjustPercent = fPercent
	elseif not bIgnoreAdjust 
	and hProgress._progress_data 
	and hProgress._progress_data.fEndPercent then
		fAdjustPercent = hProgress._progress_data.fEndPercent
	end
	
	if fAdjustPercent then
		hProgress:SetPercentage(fAdjustPercent)
		if fnOnUpdateProgress then
			fnOnUpdateProgress(hProgress)
		end
	end
	
	if not hProgress._progress_data then
		hProgress._progress_data = {}
		table.insert(tProgressPath, {hProgress:GetTreePath()})
	end
	
	hProgress._progress_data.fBeginPercent = hProgress:GetPercentage()
	hProgress._progress_data.fEndPercent = fPercent
	hProgress._progress_data.nBeginTime = GetTickCount()
	hProgress._progress_data.OnUpdateProgress = fnOnUpdateProgress
			
	if fIV then
		hProgress._progress_data.fIV = fIV
	else
		hProgress._progress_data.fIV = PROGRESS_DEFUALT_IV
	end
	
	if fACC then
		hProgress._progress_data.fACC = fACC
	else
		hProgress._progress_data.fACC = PROGRESS_DEFUALT_ACC
	end
end

function OnAcceleratProgressActive()
	local nCurTime = GetTickCount()

	for i = #tProgressPath, 1, -1 do
		local hProgress = Station.Lookup(tProgressPath[i][1], tProgressPath[i][2])
		if hProgress 
		and hProgress:IsVisible() 
		and hProgress._progress_data 
		and hProgress._progress_data.fIV >= 0 
		and hProgress._progress_data.fACC >= 0 then
			local nDeltaTime = (nCurTime - hProgress._progress_data.nBeginTime) / 1000
			local fDelta = hProgress._progress_data.fIV * nDeltaTime + hProgress._progress_data.fACC * nDeltaTime * nDeltaTime / 2
			if math.abs(hProgress._progress_data.fEndPercent - hProgress._progress_data.fBeginPercent) > fDelta then
				if hProgress._progress_data.fBeginPercent > hProgress._progress_data.fEndPercent then
					hProgress:SetPercentage(hProgress._progress_data.fBeginPercent - fDelta)
				else
					hProgress:SetPercentage(hProgress._progress_data.fBeginPercent + fDelta)
				end
				if hProgress._progress_data.OnUpdateProgress then
					hProgress._progress_data.OnUpdateProgress(hProgress)
				end
			else
				hProgress:SetPercentage(hProgress._progress_data.fEndPercent)
				if hProgress._progress_data.OnUpdateProgress then
					hProgress._progress_data.OnUpdateProgress(hProgress)
				end
				hProgress._progress_data = nil
				table.remove(tProgressPath, i)
			end
		else
			if hProgress then
				hProgress._progress_data = nil
			end
			table.remove(tProgressPath, i)
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- 窗口振动效果

local tShakeFramePath = {}

local SHAKE_WINDOW_DEFAULT_TIME = 100
local SHAKE_WINDOW_DEFAULT_AMPLITUDE = 5

function ShakeWindow(hFrame, nTime, nAmplitude)
	if not hFrame then
		return
	end

	if not hFrame._shake_frame then
		hFrame._shake_frame = {}
		table.insert(tShakeFramePath, hFrame:GetTreePath())	
		hFrame._shake_frame.nOriPosX, hFrame._shake_frame.nOriPosY = hFrame:GetAbsPos()
	end
	
	if nTime then
		hFrame._shake_frame.nTime = nTime
	else
		hFrame._shake_frame.nTime = SHAKE_WINDOW_DEFAULT_TIME
	end
	 
	if nAmplitude then
		hFrame._shake_frame.nAmplitude = nAmplitude
	else
		hFrame._shake_frame.nAmplitude = SHAKE_WINDOW_DEFAULT_AMPLITUDE
	end
	
	hFrame._shake_frame.nBeginTime = GetTickCount()
	hFrame._shake_frame.nFrameCount = 0
	--hFrame._shake_frame.nOriPosX, hFrame._shake_frame.nOriPosY = hFrame:GetAbsPos()
end

function OnAcceleratShakeFrame()
	local nCurTime = GetTickCount()

	for i = #tShakeFramePath, 1, -1 do
		local hFrame = Station.Lookup(tShakeFramePath[i])
		if hFrame and hFrame:IsVisible() and hFrame._shake_frame
		and hFrame._shake_frame.nBeginTime + hFrame._shake_frame.nTime > nCurTime then
			local nPosX, nPosY = 0, 0
			if (hFrame._shake_frame.nFrameCount % 2) == 0 then
				nPosX = hFrame._shake_frame.nOriPosX + hFrame._shake_frame.nAmplitude
				nPosY = hFrame._shake_frame.nOriPosY + hFrame._shake_frame.nAmplitude
			else
				nPosX = hFrame._shake_frame.nOriPosX - hFrame._shake_frame.nAmplitude
				nPosY = hFrame._shake_frame.nOriPosY - hFrame._shake_frame.nAmplitude
			end
			hFrame:SetAbsPos(nPosX, nPosY)
			hFrame._shake_frame.nFrameCount = hFrame._shake_frame.nFrameCount + 1
		else
			if hFrame and hFrame._shake_frame then
				hFrame:SetAbsPos(hFrame._shake_frame.nOriPosX, hFrame._shake_frame.nOriPosY)
				hFrame._shake_frame = nil
			end
			table.remove(tShakeFramePath, i)
		end
	end
end

function FireUIEvent(szEvent, nParam0, nParam1, nParam2, nParam3, nParam4)
    local back0, back1, back2, back3, back4= arg0, arg1, arg2, arg3, arg4
    arg0 = nParam0
    arg1 = nParam1
    arg2 = nParam2
    arg3 = nParam3
    arg4 = nParam4
    FireEvent(szEvent)
    arg0 = back0
    arg1 = back1
    arg2 = back2
    arg3 = back3
    arg4 = back4
end

function Conversion2ChineseNumber(num, szSeparator, tDigTable)
	local szNum = tostring(num)
	if not szNum then
        return
    end
    
    local Conversion = function(nLen, szSeparator)
        local bZero = false
        local szValidLevel = ""
        szSeparator = szSeparator or ""
        if tDigTable then
            tCharNum = tDigTable.tCharNum
            tCharDiH = tDigTable.tCharDiH
            tCharDiL = tDigTable.tCharDiL
        else
            tCharNum = g_tStrings.DIGTABLE.tCharNum
            tCharDiH = g_tStrings.DIGTABLE.tCharDiH
            tCharDiL = g_tStrings.DIGTABLE.tCharDiL
        end

        if num == 0 then
            return tCharNum[0]
        end

        return function(matched)
            local nQuotient, nRemainder = math.modf(nLen / #tCharDiL) + 1, nLen % #tCharDiL
            local szCharNum = tCharNum[tonumber(matched)]
            if nRemainder == 0 then
                nRemainder = #tCharDiL
                nQuotient = nQuotient - 1
            end

            if szCharNum == tCharNum[0] then
                bZero = true
                szCharNum = ""
            else
                if bZero then
                    bZero = false
                    szCharNum = tCharNum[0] .. szCharNum
                end
                szCharNum = szCharNum .. tCharDiL[nRemainder]
                szValidLevel = tCharDiH[nQuotient]
            end

            if nRemainder == 1 then
                szCharNum = szCharNum .. szValidLevel .. szSeparator
                szValidLevel = ""
                bZero = false
            end
            
            nLen = nLen - 1
            return szCharNum
        end
    end
    return (szNum:gsub("%d", Conversion(#szNum, szSeparator)))
end


function InitTextGlyph()
	local szText="ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890+-abcdefghijklmnopqrstuvwxyz"
	for dwFontID=0, 7, 1 do
		FillTextGlyph(dwFontID, szText)
	end
end
InitTextGlyph()


function GetXoyoAskURL()
    local hPlayer = GetClientPlayer()
    if not hPlayer then
       return
    end
    local szUserRegion , szUserSever = GetUserServer()
    local szRoleName = hPlayer.szName
    local szAccount = GetUserAccount()
    local szVerify = "ask.client.jx3&&" .. szAccount .. "&&" .. szUserRegion .. szUserSever .. "&&" .. szRoleName
    szVerify = MD5(szVerify)
    szVerify = string.lower(szVerify)
    local szKey = UrlEncode(Base64_Encode("6||" .. szAccount .. "||".. szUserRegion .. szUserSever .. "||" .. szRoleName .. "||" .. szVerify))
    local szURL = "jx3.ask.xoyo.com/?key=" .. szKey
    return szURL
end

function IsTableEmpty(t)
	if not t then
		return true;
	end
	
	for k, v in pairs(t) do
		return false;
	end
	return true;
end

function Player_IsBuffExist(dwBuffID)
	local tBuffList = GetClientPlayer().GetBuffList()
	if not tBuffList or not dwBuffID then
		return
	end
	
	for _, tBuff in pairs(tBuffList) do
		if tBuff.dwID == dwBuffID then
			return true
		end
	end
	return
end

function GetMoneyTipText(nMoney, nFont, bTenThousand)
	local szText = "<handle>handletype=3"
	local bCheckZero = true
	local nGold, nSilver, nCopper = MoneyToGoldSilverAndCopper(nMoney)
	if nGold ~= 0 then
		if bTenThousand and nGold > 10000 then
			nTenThousand = nGold / 10000 - (nGold / 10000) % 1
			szText = szText .. GetFormatText(FormatString(g_tStrings.MPNEY_TENTHOUSAND, nTenThousand), nFont)
			nGold = nGold - nTenThousand * 10000
			if nGold > 0 then
				local szGold = ""
				local nNum = 1000
				for i = 1, 4 do
					if nGold >= nNum then
						break
					end
					szGold = szGold .. "0"
					nNum = nNum / 10
				end
				szText = szText ..GetFormatText(szGold .. nGold, nFont)
			end
			szText = szText ..GetFormatImage("UI/Image/Common/Money.UITex", 0)
		else
			szText = szText.."<text>text=\""..nGold.."\"font="..nFont.."</text><image>path=\"UI/Image/Common/Money.UITex\" frame=0</image>"
		end
		bCheckZero = false
	end
	
	if not bCheckZero or nSilver ~= 0 then
		szText = szText.."<text>text=\""..nSilver.."\"font="..nFont.."</text><image>path=\"UI/Image/Common/Money.UITex\" frame=2</image>"
	end

	szText = szText.."<text>text=\""..nCopper.."\"font="..nFont.."</text><image>path=\"UI/Image/Common/Money.UITex\" frame=1</image>"
	szText = szText.."</handle>"
	return szText
end

function GetGoldText(nGold, nFont)
	local szText = ""
	szText = szText.."<text>text=\""..nGold.."\"font="..nFont.."</text><image>path=\"UI/Image/Common/Money.UITex\" frame=0</image>"
	return szText
end

function GetMoneyText(nMoney, szFont)
	local szText = ""
	local bCheckZero = true
	local nGold, nSilver, nCopper = MoneyToGoldSilverAndCopper(nMoney)
	if nGold ~= 0 then
		szText = szText.."<text>text=\""..nGold.."\""..szFont.."</text><image>path=\"UI/Image/Common/Money.UITex\" frame=0</image>"
		bCheckZero = false
	end
	
	if not bCheckZero or nSilver ~= 0 then
		szText = szText.."<text>text=\""..nSilver.."\""..szFont.."</text><image>path=\"UI/Image/Common/Money.UITex\" frame=2</image>"
	end

	szText = szText.."<text>text=\""..nCopper.."\""..szFont.."</text><image>path=\"UI/Image/Common/Money.UITex\" frame=1</image>"
	return szText
end

function GetMoneyPureText(nMoney)
	local szText = ""
	local bCheckZero = true
	local nGold, nSilver, nCopper = MoneyToGoldSilverAndCopper(nMoney)
	if nGold ~= 0 then
		szText = szText..FormatString(g_tStrings.MPNEY_GOLD, nGold)
		bCheckZero = false
	end
	
	if not bCheckZero or nSilver ~= 0 then
		szText = szText..FormatString(g_tStrings.MPNEY_SILVER, nSilver)
	end

	szText = szText..FormatString(g_tStrings.MPNEY_COPPER, nCopper)
	return szText
end

function GetTimeToHourMinuteSecond(nTime, bFrame)
	if bFrame then
		nTime = nTime / GLOBAL.GAME_FPS
	end
	local nHour   = math.floor(nTime / 3600)
	nTime = nTime - nHour * 3600
	local nMinute = math.floor(nTime / 60)
	nTime = nTime - nMinute * 60
	local nSecond = math.floor(nTime)
	return nHour, nMinute, nSecond
end

--===player===========================
local Player_Cache = 
{
	tDispelInfo = {}
}

-- 注册人物更新消息

function UI_GetPlayerMountKungfuID()
	if Player_Cache.dwMountKungfuID then
		return Player_Cache.dwMountKungfuID
	end
	
	local kungfu = GetClientPlayer().GetKungfuMount()
	if kungfu then
		Player_Cache.dwMountKungfuID = kungfu.dwSkillID
	end
	return Player_Cache.dwMountKungfuID	
end

RegisterEvent("SKILL_MOUNT_KUNG_FU", function() Player_Cache.dwMountKungfuID=nil end)
-- 注册切内功消息

function UI_GetPlayerDispelInfo()
	local dwPlayerKungfuID = UI_GetPlayerMountKungfuID()
	
	if not dwPlayerKungfuID then 
		return
	end 
	
	if Player_Cache.tDispelInfo[dwPlayerKungfuID] then
		return Player_Cache.tDispelInfo[dwPlayerKungfuID]
	end
	
	local tDispelBuf = g_tTable.DispelBuff:Search(dwPlayerKungfuID)
	Player_Cache.tDispelInfo[dwPlayerKungfuID] = tDispelBuf
	
	return Player_Cache.tDispelInfo[dwPlayerKungfuID]
end

local Buff_Cache = {}
function UI_GetBuffType(dwBuffID, nLevel)
	if Buff_Cache[dwBuffID] then
		return Buff_Cache[dwBuffID]
	end
	
	local aInfo = {}
	local bufferInfo = GetBuffInfo(dwBuffID, nLevel, aInfo)
	local dwBuffType = bufferInfo.nDetachType
	Buff_Cache[dwBuffID] = dwBuffType
	
	return Buff_Cache[dwBuffID]
end

function IsBuffDispel(dwBuffID, nLevel)
	local dwBuffType = UI_GetBuffType(dwBuffID, nLevel)
	if dwBuffType == 0 then
		return false
	end
	
	local tDispelInfo = UI_GetPlayerDispelInfo()
	if tDispelInfo and tDispelInfo["szBuffTye"..dwBuffType] == 1 then 
		return true
	end
	
	return false
end

function SplitString(szText, szSeparators)
    local nStart = 1
    local nLen = #szText
    local tResult = {}   
    while nStart <= nLen do
        local nSt, nEnd = StringFindW(szText, szSeparators, nStart)
        if nSt and nEnd then
            local szResult = string.sub(szText, nStart, nSt - 1)
            table.insert(tResult, szResult)
            nStart = nEnd +1
        else
            if nStart <= nLen then
                local szResult = string.sub(szText, nStart, nLen)
                table.insert(tResult, szResult)
            end
            nStart = nLen + 1
        end
    end 
    return tResult
end