------------------------消息中心------------------------------------
--普通消息就是一句话
--由多个部分组成的消息。比如对话应该使用richtext
--<text>text="[风清扬]:" name=\"namelink\" eventid=515 </text>..
--<text>text="清仓大甩卖，需要的密！" </text>..
--<text>text="[青龙偃月刀]" name="itemlink" eventid=515 userdata=1234 </text>..
--<text>text="[小七]" name="namelink" eventid=515 </text>..
--<animate>path="ui\image\face.uitex" group=0 </animate>..
--<text>text="\\\n"<text>

g_tDefaultChannel = 
{
	["MSG_ANNOUNCE_RED"] = {nFont = 33, r = 255, g = 0, b = 0},
	["MSG_ANNOUNCE_YELLOW"] = {nFont = 31, r = 255, g = 255, b = 0},
	["MSG_FIGHTLOG"] = {nFont = 10, r = 255, g = 255, b = 0},
	
	["MSG_NORMAL"] = {nFont = 10, r = 255, g = 255, b = 255},
	["MSG_MAP"] = {nFont = 10, r = 255, g = 126, b = 126},
	["MSG_BATTLE_FILED"] = {nFont = 10, r = 255, g = 126, b = 126},
	["MSG_PARTY"] = {nFont = 10, r = 140, g = 178, b = 253},
	["MSG_SCHOOL"] = {nFont = 10, r = 0, g = 255, b = 255},
	["MSG_GUILD"] = {nFont = 10, r = 0, g = 200, b = 72},
	["MSG_WHISPER"] = {nFont = 10, r = 202, g = 126, b = 255},
	["MSG_GROUP"] = {nFont = 10, r = 255, g = 255, b = 255},
	["MSG_OFFICIAL"] = {nFont = 10, r = 255, g = 255, b = 255},
	["MSG_FACE"] = {nFont = 10, r = 255, g = 255, b = 255},
	["MSG_WORLD"] = {nFont = 10, r = 252, g = 204, b = 204},
	["MSG_TEAM"] = {nFont = 10, r = 73, g = 188, b = 241},
	["MSG_CAMP"] = {nFont = 10, r = 155, g = 230, b = 58},
	["MSG_MENTOR"] = {nFont = 10, r = 178, g = 240, b = 164},
	["MSG_FRIEND"] = {nFont = 10, r = 241, g = 114, b = 183},
	
	["MSG_MONEY"] = {nFont = 10, r = 170, g = 150, b = 30},
	["MSG_EXP"] = {nFont = 10, r = 170, g = 150, b = 30},
	["MSG_ITEM"] = {nFont = 10, r = 170, g = 150, b = 30},
	["MSG_REPUTATION"] = {nFont = 10, r = 170, g = 150, b = 30},
	["MSG_CONTRIBUTE"] = {nFont = 10, r = 170, g = 150, b = 30},
	["MSG_PRESTIGE"] = {nFont = 10, r = 170, g = 150, b = 30},
	["MSG_ATTRACTION"] = {nFont = 10, r = 170, g = 150, b = 30},
	["MSG_TRAIN"] = {nFont = 10, r = 170, g = 150, b = 30},
	["MSG_DESGNATION"] = {nFont = 10, r = 170, g = 150, b = 30},
	["MSG_ACHIEVEMENT"] = {nFont = 10, r = 170, g = 150, b = 30},
	["MSG_MENTOR_VALUE"] = {nFont = 10, r = 170, g = 150, b = 30},
	["MSG_DEVELOPMENT_POINT"] = {nFont = 10, r = 170, g = 150, b = 30},
    ["MSG_THEW_STAMINA"] = {nFont = 10, r = 170, g = 150, b = 30},
	
	["MSG_SKILL_SELF_SKILL"] = {nFont = 10, r = 255, g = 255, b = 255},
	["MSG_SKILL_SELF_BUFF"] = {nFont = 10, r = 255, g = 255, b = 0},
    ["MSG_SKILL_SELF_DEBUFF"] = {nFont = 10, r = 255, g = 0, b = 0},
    ["MSG_SKILL_SELF_MISS"] = {nFont = 10, r = 255, g = 255, b = 255},
    ["MSG_SKILL_SELF_FAILED"] = {nFont = 10, r = 255, g = 255, b = 0},
	
	["MSG_SKILL_PARTY_SKILL"] = {nFont = 10, r = 255, g = 255, b = 255},		
	["MSG_SKILL_PARTY_BUFF"] = {nFont = 10, r = 255, g = 255, b = 255},
	["MSG_SKILL_PARTY_DEBUFF"] = {nFont = 10, r = 255, g = 255, b = 255},
    ["MSG_SKILL_PARTY_MISS"] = {nFont = 10, r = 255, g = 255, b = 255},
	
	["MSG_SKILL_OTHERS_SKILL"] = {nFont = 10, r = 255, g = 255, b = 255},
	["MSG_SKILL_OTHERS_MISS"] = {nFont = 10, r = 255, g = 255, b = 255},
	
	["MSG_SKILL_NPC_SKILL"] = {nFont = 10, r = 255, g = 255, b = 255},
	["MSG_SKILL_NPC_MISS"] = {nFont = 10, r = 255, g = 255, b = 255},

	["MSG_OTHER_DEATH"] = {nFont = 10, r = 255, g = 255, b = 255},
	["MSG_OTHER_ENCHANT"] = {nFont = 10, r = 255, g = 255, b = 255},
	["MSG_OTHER_SCENE"] = {nFont = 10, r = 255, g = 255, b = 255},
		
	["MSG_NPC_NEARBY"] = {nFont = 10, r = 255, g = 150, b = 0},
	["MSG_NPC_YELL"] = {nFont = 10, r = 255, g = 150, b = 0},
	["MSG_NPC_PARTY"] = {nFont = 10, r = 126, g = 126, b = 255},
	["MSG_NPC_WHISPER"] = {nFont = 10, r = 255, g = 150, b = 0},
	["MSG_NPC_FACE"] = {nFont = 10, r = 255, g = 150, b = 0},
	
	["MSG_SYS"] = {nFont = 10, r = 255, g = 255, b = 0},
	
	["MSG_NOTICE"] = {nFont = 10, r = 255, g = 255, b = 0},
	
	["MSG_SEEK_MENTOR"] = {nFont = 10, r = 255, g = 255, b = 255},
	["MSG_GM_ANNOUNCE"] = {nFont = 48, r = 255, g =150, b = 0},
}

IDENTITY = 
{
    JIANG_HU = 0,-- 侠
    SHAO_LIN = 1,-- 少林
    WAN_HUA = 2, -- 万花
    TIAN_CE = 3, -- 天策
    CHUN_YANG = 4,-- 纯阳,
    QI_XIU = 5,  -- 七秀
    CANG_JIAN = 8,-- 藏剑
    
    TUAN_ZHANG = 100, --团长
    BANG_ZHU = 101, -- 帮主
}

g_tIdentityColor = 
{
    [IDENTITY.JIANG_HU] = {r = 255, g = 255, b = 255},
    [IDENTITY.CHUN_YANG] = {r = 89, g = 224, b = 232},
    [IDENTITY.TIAN_CE] = {r = 255, g = 111, b = 83},
    [IDENTITY.QI_XIU]= {r = 255, g = 129, b = 176},
    [IDENTITY.SHAO_LIN] = {r = 255, g = 178, b = 95},
    [IDENTITY.WAN_HUA] = {r = 196, g = 152, b = 255},
    [IDENTITY.CANG_JIAN] = {r = 214, g = 249, b = 93},
    [IDENTITY.TUAN_ZHANG] = {r = 88, g = 238, b = 252},
    [IDENTITY.BANG_ZHU] = {r = 93, g = 255, b = 112},
}

_g_MsgVersion = 0
_g_MsgCenter = clone(g_tDefaultChannel)
g_tMsgCenterMonitor = {}

RegisterCustomData("_g_MsgCenter")
RegisterCustomData("_g_MsgVersion")

local tMsgCache = {}

function OutputMessage(szType, szMsg, bRich, nFont, tColor)
	if not IsChatPanelInit() and szType ~= "MSG_ANNOUNCE_RED" and szType ~= "MSG_ANNOUNCE_YELLOW" then
		local tMsg = {}
		tMsg.szType = szType
		tMsg.szMsg = szMsg
		tMsg.bRich = bRich
		table.insert(tMsgCache, tMsg)
		return
	end
	
	local v = _g_MsgCenter[szType]
    if not v then
        Log("KGUI Call function failed \ui\script\msg.lua")
        Log("szType = " .. szType)
    end
	local r, g, b = v.r, v.g, v.b
	if tColor then
		r = tColor[1]
		g = tColor[2]
		b = tColor[3]
	end
	if not nFont then
		nFont = v.nFont
	end
    
	local tMonitor = g_tMsgCenterMonitor[szType]
	if v and tMonitor then
		for kM, vM in pairs(tMonitor) do
			vM(szMsg, nFont, bRich, r, g, b, szType)
		end
	end
end

function Output(...)
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

--注册监听者。Monitor为接收消息函数，msg为接收消息列表
function RegisterMsgMonitor(Monitor, msg)
	for k, v in pairs(msg) do
		if not _g_MsgCenter[v] then
			_g_MsgCenter[v] = g_tDefaultChannel[v]
			if not _g_MsgCenter[v] then
				_g_MsgCenter[v] = {nFont = 1}
			end
		end
		if not g_tMsgCenterMonitor[v] then
			g_tMsgCenterMonitor[v] = {}
		end
		
		local bR = false
		for kM, vM in pairs(g_tMsgCenterMonitor[v]) do
			if vM == Monitor then
				bR = true
				break
			end
		end
		if not bR then
			table.insert(g_tMsgCenterMonitor[v], Monitor)
		end
	end
end

--注销监听者。如果msg为空注销所有Monitor监听的消息
function UnRegisterMsgMonitor(Monitor, msg)
	if not msg then
		for k, v in pairs(g_tMsgCenterMonitor) do
			for kM, vM in pairs(v) do
				if vM == Monitor then
					table.remove(v, kM)
					break
				end
			end
		end
		return
	end
	
	for k, v in pairs(msg) do
		local vT = g_tMsgCenterMonitor[v]
		if vT then
			for kM, vM in pairs(vT) do
				if vM == Monitor then
					table.remove(vT, kM)
					break
				end
			end
		end
	end
end

function GetMsgFontString(szType, tColor)
	local v = _g_MsgCenter[szType] or g_tDefaultChannel[szType]
	local szReturn
    
	if not v or not v.nFont then
		szReturn = " font=10".." r=255 g=255 b=255 "
	else
        local r, g, b = v.r, v.g, v.b
        if tColor then
            r = tColor.r
            g = tColor.g
            b = tColor.b
        end 
        
		if r and g and b then
			szReturn = " font="..v.nFont.." r="..r.." g="..g.." b="..b.." "
		else
			szReturn = " font="..v.nFont.." "
		end
	end
	return szReturn
end

function GetMsgFont(szType)
	local v = _g_MsgCenter[szType] or g_tDefaultChannel[szType]
	if not v or not v.nFont then
		return 10
	end
	return v.nFont
end

function GetMsgFontColor(szType, bA)
	local v = _g_MsgCenter[szType] or g_tDefaultChannel[szType]
	local r = 255
	local g = 255
	local b = 255
	if v then
		if v.r then
			r = v.r
		end
		if v.g then
			g = v.g
		end
		if v.b then
			b = v.b
		end
	end
	
	if bA then
		return {r, g, b}
	end
	return r, g, b
end

function SetMsgFontColor(szType, r, g, b)
	local v = _g_MsgCenter[szType]
	if v and r and g and b then
		FireDataAnalysisEvent("CHAT_MSG_COLOR", {{r=v.r, g=v.g, b=v.b},{r=r, g=g, b=b}, szType})
		
		v.r, v.g, v.b = r, g, b
	end
end

function SetDefaultMsgFontColor()
	_g_MsgCenter = clone(g_tDefaultChannel)
end

function OutputCacheMsg()
	for _, tMsg in ipairs(tMsgCache) do
		OutputMessage(tMsg.szType, tMsg.szMsg, tMsg.bRich)
	end
end

RegisterEvent("CHAT_PANEL_INIT", function() OutputCacheMsg() end)

---------------------------------------------------------------------------------
function MakeNameLink(szName, szFont)
	local szLink = "<text>text="..EncodeComponentsString(szName)..
	szFont.." name=\"namelink\" eventid=515</text>"
	return szLink
end

function MakeItemLink(szName, szFont, dwID)
	local szLink = "<text>text="..EncodeComponentsString(szName)..
		szFont.."name=\"itemlink\" eventid=513 userdata="..dwID.."</text>"
    return szLink
end

function MakeItemInfoLink(szName, szFont, nVersion, dwTabType, dwIndex)
	local szLink = "<text>text="..EncodeComponentsString(szName)..
		szFont.."name=\"iteminfolink\" eventid=513 script="..
			EncodeComponentsString("this.nVersion="..nVersion.."\nthis.dwTabType="..dwTabType.."\nthis.dwIndex="..dwIndex).."</text>"
    return szLink
end

function MakeQuestLink(szName, szFont, dwQuestID)
	local szLink = "<text>text="..EncodeComponentsString(szName)..
		szFont.."name=\"questlink\" eventid=513 userdata="..dwQuestID.."</text>"
    return szLink
end

function MakeRecipeLink(szName, szFont, dwCraftID, dwRecipeID)
	local szLink = "<text>text="..EncodeComponentsString(szName)..
		szFont.."name=\"recipelink\" eventid=513 script="..
		EncodeComponentsString("this.dwCraftID="..dwCraftID.."\nthis.dwRecipeID="..dwRecipeID).."</text>"
    return szLink
end

function MakeEnchantLink(szName, szFont, dwProID, dwCraftID, dwRecipeID)
	local szLink = "<text>text="..EncodeComponentsString(szName)..
		szFont.."name=\"enchantlink\" eventid=513 script="..
		EncodeComponentsString("this.dwProID="..dwProID.."\nthis.dwCraftID="..dwCraftID.."\nthis.dwRecipeID="..dwRecipeID).."</text>"
    return szLink
end

function MakeSkillLink(szName, szFont, skillKey)
	local szScript = "this.skillKey={"
	for k, v in pairs(skillKey) do
		szScript = szScript..k.."="..v..","
	end
	szScript = szScript.."}"
	
	local szLink = "<text>text="..EncodeComponentsString(szName)..
		szFont.."name=\"skilllink\" eventid=513 script="..
		EncodeComponentsString(szScript).."</text>"
    return szLink
end

function MakeSkillRecipeLink(szName, szFont, dwID, dwLevel)
	local szLink = "<text>text="..EncodeComponentsString(szName)..
		szFont.."name=\"skillrecipelink\" eventid=513 script="..
			EncodeComponentsString("this.dwID="..dwID.."\nthis.dwLevel="..dwLevel).."</text>"
    return szLink
end

function MakeBookLink(szName, szFont, nVersion, dwTabType, dwIndex, nBookRecipeID)
	local szLink = "<text>text="..EncodeComponentsString(szName)..
		szFont.."name=\"booklink\" eventid=513 script="..
			EncodeComponentsString("this.nVersion="..nVersion.."\nthis.dwTabType="..dwTabType.."\nthis.dwIndex="..dwIndex.."\nthis.nBookRecipeID="..nBookRecipeID).."</text>"
    return szLink
end

function MakeAchievementLink(szName, szFont, dwAchievementID)
	local szLink = "<text>text="..EncodeComponentsString(szName)..
		szFont.."name=\"achievementlink\" eventid=513 script="..
			EncodeComponentsString("this.dwID="..dwAchievementID).."</text>"
    return szLink
end

function MakeDesignationLink(szName, szFont, dwDesignationID, bPrefix)
	local szLink = "<text>text="..EncodeComponentsString(szName)..
		szFont.."name=\"designationlink\" eventid=513 script="..
			EncodeComponentsString("this.dwID="..dwDesignationID.."\nthis.bPrefix="..tostring(bPrefix)).."</text>"
    return szLink
end

function MakeEventLink(szText, szFont, szName, szLinkInfo)
	local szLink = "<text>text="..EncodeComponentsString(szText)..
		szFont.."name=\"eventlink\" eventid=513 script="..
			EncodeComponentsString("this.szName=\""..szName.."\"\nthis.szLinkInfo=\""..szLinkInfo.."\"").."</text>"
    return szLink
end

function MakeMsgLink(szMsgName, szFont)
	local szLink = "<text>text="..EncodeComponentsString(szMsgName)..
		szFont.."name=\"msglink\" eventid=513 script="..
			EncodeComponentsString("this.szName=\""..szMsgName.."\"").."</text>"
    return szLink
end

function FormatLinkString(szMsg, szFont, ...)
	szMsg = FormatString(szMsg, ...)
	local szResult = ""
	local nFirst, nLast, szAdd = string.find(szMsg, "<link (.-)>")
	while nFirst do
		local szPrev = string.sub(szMsg, 1, nFirst - 1)
		if szPrev and szPrev ~= "" then
			szResult = szResult.."<text>text="..EncodeComponentsString(szPrev)..szFont.." </text>"
		end
		if szAdd and szAdd ~= "" then
			local nIndex = tonumber(szAdd) + 1
			local szText = select(nIndex, ...) 
			if szText then
				szResult = szResult..szText
			else
				szResult = szResult.."<text>text="..EncodeComponentsString(szAdd)..szFont.." </text>"
			end
		end
		
		szMsg = string.sub(szMsg, nLast + 1, -1)
		nFirst, nLast, szAdd = string.find(szMsg, "<link (.-)>")
	end
	if szMsg and szMsg ~= "" then
		szResult = szResult.."<text>text="..EncodeComponentsString(szMsg)..szFont.." </text>"
	end
	return szResult
end

local function On_Msg_Version_Change()
	if arg0 == "Role" then
		if not _g_MsgVersion then
			_g_MsgVersion = 0
		end
		
		if _g_MsgVersion == 0 then
			if _g_MsgCenter then
				_g_MsgCenter["MSG_FACE"] = {nFont = 10, r = 255, g = 255, b = 255}
			end
			_g_MsgVersion = 1
		end	
		_g_MsgCenter["MSG_GM_ANNOUNCE"] = g_tDefaultChannel["MSG_GM_ANNOUNCE"]
	end
end

RegisterEvent("CUSTOM_DATA_LOADED", On_Msg_Version_Change)
