function OutputBuffTip(dwCharacter, dwID, nLevel, nCount, bShowTime, nTime, Rect)
	local szTip = "<Text>text="..EncodeComponentsString(Table_GetBuffName(dwID, nLevel).."\t").." font=65 </text>"

	local aInfo = {}
	local bufferInfo = GetBuffInfo(dwID, nLevel, aInfo)
	
	local szDetachType = ""
	if g_tStrings.tBuffDetachType[bufferInfo.nDetachType] then
		szDetachType = g_tStrings.tBuffDetachType[bufferInfo.nDetachType]
	end
	szTip = szTip.."<Text>text="..EncodeComponentsString(szDetachType.."\n").." font=106 </text>"

	local szDesc = GetBuffDesc(dwID, nLevel, "desc")
	if szDesc then
		szDesc = szDesc..g_tStrings.STR_FULL_STOP
	end
	szTip = szTip.."<Text>text="..EncodeComponentsString(szDesc).." font=106 </text>"
	
	if bShowTime then
		local szTime = ""
		local szLeftH = ""
		local szLeftM = ""
		local szLeftS = ""
		local h = math.floor(nTime / 3600)
		if h > 0 then
			szLeftH = h..g_tStrings.STR_BUFF_H_TIME_H.." "
		end
		
		local m = math.floor((nTime - h * 3600) / 60)
		if h > 0 or m > 0 then
			szLeftM = m..g_tStrings.STR_BUFF_H_TIME_M_SHORT.." "
		end
		
		local s = math.floor((nTime - h * 3600 - m * 60))
		if h > 0 or m > 0 or s > 0 then
			szLeftS = s..g_tStrings.STR_BUFF_H_TIME_S
			szTime = FormatString(g_tStrings.STR_BUFF_H_LEFT_TIME_MSG, szLeftH, szLeftM, szLeftS)
		else
			szTime = g_tStrings.STR_BUFF_H_TIME_ZERO
		end
		
		szTip = szTip.."<Text>text="..EncodeComponentsString("\n"..szTime).." font=102 </text>"
	end
	
	-- 以下为测试代码
	if IsCtrlKeyDown() then
		szTip = szTip.."<Text>text="..EncodeComponentsString("\n".."调试用信息：".."\n".."ID:"..dwID.." Level:"..tostring(nLevel).."\n").." font=102 </text>"
	end
	-- 以上为测试代码
	
	OutputTip(szTip, 300, Rect)
end

function GetBuffDesc(dwID, nLevel, szKey)
	if szKey == "name" then
		local szBuffName = Table_GetBuffName(dwID, nLevel)
		if not szBuffName then
			szBuffName = Table_GetBuffName(dwID, 0)
		end
		return szBuffName
	elseif szKey == "time" then
		local nTime = GetBuffTime(dwID, nLevel)
		return GetTimeText(nTime, true)
	elseif szKey == "count" then
		local _, nCount = GetBuffTime(dwID, nLevel)
		return nCount
	elseif szKey == "interval" then
		local _, _, nInterval = GetBuffTime(dwID, nLevel)
		return GetTimeText(nInterval, true)
	elseif szKey == "desc" then
		local player = GetClientPlayer()
		local szDesc = Table_GetBuffDesc(dwID, nLevel)
		if not szDesc then
			szDesc = Table_GetBuffDesc(dwID, 0)
		end
		
		local szDescNew = ""
		szDesc = string.gsub(szDesc, "<Skill (%d+) (%d+) (.-)>", 
			function(dwSkillID, nLevel, szDesc1)
				dwSkillID = tonumber(dwSkillID)
				local nRequestLevel = tonumber(nLevel) or 1
				local nLevel = player.GetSkillLevel(dwSkillID)
				if nLevel == nRequestLevel then
					return szDesc1
				end
				return ""
			end
		)
		local function FormatBuffDesc(szText)
			local aInfo = {}
			string.gsub(szText, "<BUFF (.-)>", function(s) table.insert(aInfo, s) return s end)
			local bufferInfo = GetBuffInfo(dwID, nLevel, aInfo)
			if not bufferInfo then
				return szText
			end
			bufferInfo.time, bufferInfo.count, bufferInfo.interval = GetBuffTime(dwID, nLevel)
			local fd = function(s)
				local nValue = math.abs(bufferInfo[s])
				if s == "time" or s == "interval" then
					return GetTimeText(nValue, true)
				end
				return nValue
			end
			return string.gsub(szText, "<BUFF (.-)>", fd)	
		end
		
		local function FormatBuffDescEx(szText)
			local aInfo = {}
			string.gsub(szText, "<BUFF_EX (%d+) (.-)>", function(nBase, s) table.insert(aInfo, s) return s end)
			local bufferInfo = GetBuffInfo(dwID, nLevel, aInfo)
			if not bufferInfo then
				return szText
			end
			bufferInfo.time, bufferInfo.count, bufferInfo.interval = GetBuffTime(dwID, nLevel)
			local fd = function(nBase, s)
				local nValue = math.abs(bufferInfo[s])
				if s == "time" or s == "interval" then
					return GetTimeText(nValue, true)
				end
				if nBase and nBase ~= 0 then
					local fPercent = math.floor((nValue / nBase  + 0.005)*100)
					return fPercent
				else
					return "0"
				end
			end
			return string.gsub(szText, "<BUFF_EX (%d+) (.-)>", fd)	
		end
		szDesc = FormatBuffDesc(szDesc)
		szDesc = FormatBuffDescEx(szDesc)
		return szDesc
	end
end

function GetBindBuffDesc(nIndex, dwID, nLevel, szKey, skillKey)
	if szKey == "name" then
		return Table_GetBuffName(dwID, nLevel)
	elseif szKey == "time" then
		local nTime = GetBindBuffTime(nIndex, skillKey)
		return GetTimeText(nTime, true)
	elseif szKey == "count" then
		local _, nCount = GetBindBuffTime(nIndex, skillKey)
		return nCount
	elseif szKey == "interval" then
		local _, _, nInterval = GetBindBuffTime(nIndex, skillKey)
		return GetTimeText(nInterval, true)
	elseif szKey == "desc" then
		local szDesc = Table_GetBuffDesc(dwID, nLevel) or ""
		szDesc = GetPureText(szDesc)
		local aInfo = {}
		string.gsub(szDesc, "<BUFF (.-)>", function(s) table.insert(aInfo, s) return s end)
		local bufferInfo = GetBindBuffInfo(nIndex, skillKey, aInfo)
		bufferInfo.time, bufferInfo.count, bufferInfo.interval = GetBindBuffTime(nIndex, skillKey)
		local fd = function(s)
			local nValue = math.abs(bufferInfo[s])
			if s == "time" or s == "interval" then
				return GetTimeText(nValue, true)
			end
			return nValue
		end
		return string.gsub(szDesc, "<BUFF (.-)>", fd)	
	end
end