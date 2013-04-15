--[[
	fVelocity      速度
	fAcceleration  加速度
	bFadeIn        过程中进行淡入
	fInitScale     初始的 缩放大小
	
	fElasticity       反弹系数
	szElasticityType  反弹类型， >x或<x： 以y轴 为反弹面  >y或<y： 以x轴 为反弹面
	
	bCenterX, bCenterY  以为初始位置的中心点 为 轨迹的运动的中心点
	fOffsetCenter 		中心点位置的偏移
	tStartPos =    动画开始位置 获取参数
	{
		x, y 	   坐标
		bEqualEndX，bEqualEndY， 起始位置的X或y坐标等于 结束位置
		bAddClientW，bAddClientH 坐标加上 屏幕的 长宽
		bEqualInit 起始位置 等于 当前的 位置
		fOffsetX, fOffsetY  位置的偏移
		
	},
	
	tEndPos = 
	{
		x, y       坐标
		bEqualInit 最后显示的位置，由程序获取
		bAddClientW，bAddClientH 坐标加上 屏幕的 长宽
		fOffsetX, fOffsetY  位置的偏移
		fClientX, fClientY  屏幕的 长宽 的比例位置
	},
]]

local g_fGravity = 8
local g_tConfig =
{
	["Line"] = 
	{
		["Role_BodyIn1"] = {fVelocity = 3, fAcceleration =9, nInitAlpha=50, tStartPos = {x=0, bEqualEndY = true}, tEndPos = {bEqualInit = true}, bCenterY = true, fInitScale=5.0,},
		["Role_BodyIn2"] = {fVelocity = 3, fAcceleration =7, nInitAlpha=50, tStartPos = {x=-100, bEqualEndY = true}, tEndPos = {bEqualInit = true}, bCenterY = true, fInitScale=5.0,},
		["Role_BodyIn3"] = {fVelocity = 2, fAcceleration =7, nInitAlpha=50, tStartPos = {x=-100, bEqualEndY = true}, tEndPos = {bEqualInit = true}, bCenterY = true, fInitScale=5.0,},
		-- 从上面掉下来 有反弹效果
		["Role_Body"] = {fVelocity = 1, fAcceleration = 4.5, nInitAlpha=0, tStartPos = {x=-310, bEqualEndY = true}, tEndPos = {bEqualInit = true}, fElasticity = 0.2, szElasticityType = ">x",},
	
		["Role_Body1"] = {fVelocity = 0.2, fAcceleration = 3.5, tStartPos = {x=-100, bEqualEndY = true}, tEndPos = {bEqualInit = true}, fInitScale = 3.5, bCenterY = true,},	
		["Role_Body2"] = {fVelocity = 0.2, fAcceleration = 3.5, tStartPos = {x=0, bEqualEndY = true}, tEndPos = {bEqualInit = true}, fInitScale = 3.5, bCenterY = true,},	
		["Role_Body3"] = {fVelocity = 0.2, fAcceleration = 3.5, tStartPos = {x=100, bEqualEndY = true}, tEndPos = {bEqualInit = true}, fInitScale = 3.5, bCenterY = true,},	
	
		-- 从左边加速进入 
		["Role_BodyTile"] = {fVelocity = 0.2, fAcceleration = 5.0, tStartPos = {x=-310, bEqualEndY = true,}, tEndPos = {fOffsetX=-15, bEqualInit = true},},
		-- 从左边加速进入后 刹车的一段
		["Role_BodyStop"] = {fVelocity = 0.05, fAcceleration = -0.06, tStartPos = {bEqualInit = true}, tEndPos = {fOffsetX=15, bEqualInit = true},},
		
		-- 从右边加速进入 
		["Role_Info"] = {fVelocity = 0.2, fAcceleration = 5.0, tStartPos = {x=400, bEqualEndY = true, bAddClientW=true}, tEndPos = {fOffsetX=15, bEqualInit = true},},
		-- 从右边加速进入后 刹车的一段
		["Role_InfoStop"] = {fVelocity = 0.05, fAcceleration = -0.06, tStartPos = {bEqualInit = true}, tEndPos = {fOffsetX=-15, bEqualInit = true},},
		
		-- 从左边加速进入 并进行 缩放
		["Role_SchoolUp1"] = {fVelocity = 0.2, fAcceleration = 3.5, tStartPos = {x=-100, bEqualEndY = true},	tEndPos = { bEqualInit = true}, fInitScale = 3.0, bCenterY = true,},
		["Role_SchoolUp2"] = {fVelocity = 0.2, fAcceleration = 3.5, tStartPos = {x=-60, bEqualEndY = true},	tEndPos = {bEqualInit = true}, fInitScale = 3.0, bCenterY = true,},
		["Role_SchoolUp3"] = {fVelocity = 0.2, fAcceleration = 3.5, tStartPos = {x=-20, bEqualEndY = true},	tEndPos = {bEqualInit = true}, fInitScale = 3.0, bCenterY = true,},
		["Role_SchoolUp4"] = {fVelocity = 0.2, fAcceleration = 3.5, tStartPos = {x=20, bEqualEndY = true},	tEndPos = {bEqualInit = true}, fInitScale = 3.0, bCenterY = true,},
		
		-- 从左边加速进入 并进行 缩放
		["Role_SchoolDown1"] = {fVelocity=0.2, fAcceleration=3.5, tStartPos={x=-100,  bEqualEndY=true}, tEndPos={bEqualInit=true}, fInitScale=3.0, bCenterY=true, },
		["Role_SchoolDown2"] = {fVelocity=0.2, fAcceleration=3.5, tStartPos={x=-60,  bEqualEndY=true}, tEndPos={bEqualInit=true}, fInitScale=3.0, bCenterY=true, },
		["Role_SchoolDown3"] = {fVelocity=0.2, fAcceleration=3.5, tStartPos={x=-20,  bEqualEndY=true}, tEndPos={bEqualInit=true}, fInitScale=3.0, bCenterY=true, },
		["Role_SchoolDown4"] = {fVelocity=0.2, fAcceleration=3.5, tStartPos={x=20,  bEqualEndY=true}, tEndPos={bEqualInit=true}, fInitScale=3.0, bCenterY=true,},
		
		--fOffsetY=-197,
		
		--从左边缓慢进入
		["Role_Slow"] = {fVelocity = 0.2, fAcceleration = -0.06, nInitAlpha=0, tStartPos = {x=-250, bEqualEndY = true},	tEndPos = {bEqualInit = true},},
		
		--===================================
		["Role_Center1"] = {fVelocity = 0.3, fAcceleration = 3, tStartPos = {bEqualInit=true}, tEndPos = {x=0, y=80}},
		["Role_Center2"] = {fVelocity = 0.3, fAcceleration = 3, tStartPos = {bEqualInit=true}, tEndPos = {x=14, y=111}, fInitScale = 1.6,  bUseInitSize=true},	--bCenterY = true, bCenterX = true,
		["Role_Center3"] = {fVelocity = 0.3, fAcceleration = 3, tStartPos = {bEqualInit=true}, tEndPos = {x=98, y=111}, fInitScale = 1.6, bUseInitSize=true},
		["Role_Center4"] = {fVelocity = 0.3, fAcceleration = 3, tStartPos = {bEqualInit=true}, tEndPos = {x=182, y=111}, fInitScale = 1.6, bUseInitSize=true},	
		
		["Role_Scale"] = {fVelocity = 1, fAcceleration = 5, tStartPos = {bEqualInit=true}, tEndPos = {bEqualInit=true, fOffsetX=0, fOffsetY=-300, fOffsetScale=-7.5}, fInitScale = 1.0, nInitAlpha=255, nEndAlpha=50, fEndScale=20, bUseInitSize=true},
		
		["Role_Scale1"] = {tStartPos = {bEqualInit=true}, tEndPos = {bEqualInit=true}, fTotalTime=400, fInitScale = 1.0,  fEndScale=15, nInitAlpha=255, nEndAlpha=50, fOffsetCenterX=242, bCenterX=true, bCenterY= true},
		["Role_Scale2"] = {tStartPos = {bEqualInit=true}, tEndPos = {bEqualInit=true}, fTotalTime=400, fInitScale = 1.0,  fEndScale=15, nInitAlpha=255, nEndAlpha=50, bCenterX=true, bCenterY= true},
		["Role_Scale3"] = {tStartPos = {bEqualInit=true}, tEndPos = {bEqualInit=true}, fTotalTime=400, fInitScale = 1.0,  fEndScale=15, nInitAlpha=255, nEndAlpha=50, fOffsetCenterX=-242, bCenterX=true, bCenterY= true},
	
		["Role_FadeOut"] = {tStartPos = {bEqualInit=true}, tEndPos = {bEqualInit=true}, fTotalTime=200, nInitAlpha=255, nEndAlpha=0},	

		["Role_ScaleBig"] = {tStartPos = {bEqualInit=true}, tEndPos = {bEqualInit=true,},  fTotalTime=140, fInitScale = 1.0, fEndScale=1.3, bCenterX=true, bCenterY= true, },
		["Role_ScaleSmall"] = {tStartPos = {bEqualInit=true}, tEndPos = {bEqualInit=true,},fTotalTime=100, fInitScale = 1.2, fEndScale=1.0, bCenterX=true, bCenterY= true,},
		
		--章节提示
		["ChaptersUp_Begin"] = {fVelocity = 0.1, fAcceleration = 0.08, tStartPos = {x=0, y=-150}, tEndPos = {bEqualInit=true}},
		["ChaptersDown_Begin"] = {fVelocity = 0.1, fAcceleration = 0.08, tStartPos = {x=0, bAddClientH=true}, tEndPos = {bEqualInit=true}},
		
		["ChaptersUp_End"] = {fVelocity = 0.1, fAcceleration = 0.08, tStartPos = {bEqualInit=true}, tEndPos = {x=0, y=-150}},
		["ChaptersDown_End"] = {fVelocity = 0.1, fAcceleration = 0.08, tStartPos = {bEqualInit=true}, tEndPos = {x=0,y=150, bAddClientH=true}},
	}
}

local tAnimationQueue = {}
local g_aDelayCall = {}

local AddDelayCall=function(nTime, fn, hObject)
	table.insert(g_aDelayCall, {nTime = GetTickCount() + nTime, fnAction=fn, hObject= hObject})
end

local function Vec2Normalize(aSpeed)
	local nLen = math.sqrt(aSpeed.x * aSpeed.x + aSpeed.y * aSpeed.y)
	aSpeed.x = aSpeed.x / nLen 
	aSpeed.y = aSpeed.y / nLen
	
	return aSpeed
end

local function Vec2_SubVec2(a, b)
	local c =  {x=a.x - b.x, y=a.y - b.y}
	return c
end

local function Vec2_AddVec2(a, b, c)
	if not c then
		c = {}
	end
	
	c.x = a.x + b.x 
	c.y = a.y + b.y
	
	return c
end

local function Vec2_MultValue(a, fValue)
	local c  = {x=a.x * fValue, y=a.y * fValue}
	return c
end

local function DoRebound(tAni, fLastTime, fCurrentTime)
	if tAni.bDelete then
		return
	end
	
	local fInterval = fCurrentTime - fLastTime
	if fInterval < 0.00001 then
		return
	end
	
	local fInitVelocity = tAni.fVelocity
	local aSpeed = tAni.aSpeed
	
	--local aAcc = {x =0, y=1}
	local fAcceleration = g_fGravity / 1000
	
	local fVelocity = fInitVelocity - fAcceleration * fInterval
	--UILog(tAni.aPos, aSpeed, fInterval, fVelocity, "old")
	
	tAni.aPos = Vec2_AddVec2(tAni.aPos, Vec2_MultValue(aSpeed, (fInitVelocity + fVelocity) * 0.5 * fInterval), tAni.aPos)
	
	--UILog(tAni.aPos)
	
	tAni.fVelocity = fVelocity
	tAni.fLastTime = fCurrentTime
	
	local bFloor = false;
	if (tAni.szElasticityType == ">x" and tAni.aPos.x >= tAni.aEndPos.x) or
	   (tAni.szElasticityType == "<x" and tAni.aPos.x <= tAni.aEndPos.x) then
		tAni.aPos.x = tAni.aEndPos.x
		tAni.fVelocity = tAni.fVelocity * tAni.fElasticity
		bFloor = true
	elseif (tAni.szElasticityType == ">y" and tAni.aPos.y >= tAni.aEndPos.y) or
		(tAni.szElasticityType == "<y" and tAni.aPos.y <= tAni.aEndPos.y) then
		tAni.aPos.y = tAni.aEndPos.y
		tAni.fVelocity = tAni.fVelocity * tAni.fElasticity
		bFloor = true
	end
	
	if bFloor and tAni.fVelocity < 0.001 then
		tAni.bDelete = true
	end
	
	tAni.hObject:SetAbsPos(tAni.aPos.x, tAni.aPos.y)
end


local function AppendRebound(tAni)
	local tRebound = {}
	local tAction = g_tConfig["Line"][tAni.nID]
	local tRTParam = tAni.tRTParam
	
	local fInitVelocity = tRTParam.fVelocity * tAction.fElasticity
	local aSpeed = Vec2_SubVec2(tAni.aEndPos, tAni.aStartPos)
	if tAction.szElasticityType == ">x" or tAction.szElasticityType == "<x" then
		aSpeed.x =  -aSpeed.x
	elseif tAction.szElasticityType == ">y" or tAction.szElasticityType == "<y" then	
		aSpeed.y =  -aSpeed.y
	else
		return
	end
	
	aSpeed = Vec2Normalize(aSpeed)
	tRebound.fVelocity = fInitVelocity
	tRebound.aSpeed = aSpeed
	
	tRebound.aEndPos = clone(tAni.aEndPos)
	tRebound.aPos = clone(tAni.aEndPos)
	
	tRebound.fLastTime = GetTickCount()
	tRebound.szType = "rebound"
	tRebound.hObject = tAni.hObject
	
	tRebound.fElasticity = tAction.fElasticity
	tRebound.szElasticityType = tAction.szElasticityType
	table.insert(tAnimationQueue, tRebound)
end

local function DoLineAction(tAni, fLastTime, fCurrentTime)
	local tAction =  g_tConfig["Line"][tAni.nID]
	
	if tAni.bDelete then
		return
	end
	
	local fInterval = fCurrentTime - fLastTime
	if fInterval < 0.00001 then
		return
	end
	
	local tRTParam = tAni.tRTParam
	local aSpeed = Vec2_SubVec2(tAni.aEndPos, tAni.aStartPos)
	aSpeed = Vec2Normalize(aSpeed)	
	
	if tRTParam.fVelocity then
		local fAcceleration = tAction.fAcceleration / 1000
		local fVelocity = tRTParam.fVelocity + fAcceleration * fInterval
		
		tRTParam.aPos = Vec2_AddVec2(tRTParam.aPos, Vec2_MultValue(aSpeed, (tRTParam.fVelocity + fVelocity) * 0.5 * fInterval), tRTParam.aPos)
		tRTParam.fVelocity = fVelocity
	end
	
	tRTParam.fPastTime = tRTParam.fPastTime + fInterval
	tAni.fLastTime = fCurrentTime

	if tAni.nAlpha then
		local nAlpha = tAni.hObject:GetAlpha()
		if tAni.nAlpha > 0 then
			nAlpha =  math.min(nAlpha + tAni.nAlpha * fInterval, tAni.nEndAlpha)
		else
			nAlpha =  math.max(nAlpha + tAni.nAlpha * fInterval, tAni.nEndAlpha)
		end
		tAni.hObject:SetAlpha(nAlpha)
	end
	
	local nCurrentWidth, nCurrentHeight = tAni.hObject:GetSize()
	if tAni.fScale then
		local nDstWidth = tAni.fInitW * tAni.fScale
		local fScale = nDstWidth / nCurrentWidth
		--UILog("fScale", fScale, tAni.fScale, tAni.nInitWidth, nCurrentWidth, nDstWidth)
		tAni.hObject:Scale(fScale, fScale)
		if tAni.fScaleDelta > 0 then
			tAni.fScale =  math.min(tAni.fScale + tAni.fScaleDelta * fInterval, tAni.fEndScale)
		else
			tAni.fScale =  math.max(tAni.fScale + tAni.fScaleDelta * fInterval, tAni.fEndScale)
		end
	end
	if tAni.nCenterY and tAni.nCenterX then
		tAni.hObject:SetAbsPos(tAni.nCenterX - nCurrentWidth / 2, tAni.nCenterY - nCurrentHeight / 2)
	elseif tAni.nCenterY then
		tAni.hObject:SetAbsPos(tRTParam.aPos.x , tAni.nCenterY - nCurrentHeight / 2)
	elseif tAni.nCenterX then
		tAni.hObject:SetAbsPos(tAni.nCenterX - nCurrentWidth/2, tRTParam.aPos.y)
	else
		tAni.hObject:SetAbsPos(tRTParam.aPos.x, tRTParam.aPos.y)
	end
	
	if tRTParam.fPastTime > tAni.fTotalTime then
		tAni.hObject:SetAbsPos(tAni.aEndPos.x, tAni.aEndPos.y)
		if tAni.nAlpha and tAni.nAlpha > 0 then
			tAni.hObject:SetAlpha(tAni.nEndAlpha)
		end
		tAni.bDelete = true
		
		if tAction.fElasticity then
			AppendRebound(tAni)
		end
		if tAni.fScale then
			tAni.fScale = tAni.fEndScale
			tAni.hObject:SetSize(tAni.nInitWidth, tAni.nInitHeight)
		end
		
		if tAni.fnEndAction then
			tAni.fnEndAction()
		end
	end
	
	return tRTParam.aPos
end


local function GetLineStartAndEnd(hObject, tAction)
	local aStartPos = {x=0, y=0}
	local aEndPos = {x=0, y=0}
	local tStartParam = tAction.tStartPos
	local tEndParam = tAction.tEndPos
	local nCW, nCH = Station.GetClientSize()

	--===end=========================================
	aEndPos.x = tEndParam.x or aEndPos.x 
	aEndPos.y = tEndParam.y or aEndPos.y
	
	if tEndParam.bEqualInit then
		aEndPos.x, aEndPos.y = hObject:GetAbsPos()
	end
	
	if tEndParam.fClientY then
		aEndPos.y = nCH * tEndParam.fClientY
	end

	if tEndParam.fClientX then
		aEndPos.x = nCW * tEndParam.fClientX
	end

	if tEndParam.fOffsetX then
		aEndPos.x = aEndPos.x + tEndParam.fOffsetX
	end
	
	if tEndParam.fOffsetY then
		aEndPos.y = aEndPos.y + tEndParam.fOffsetY
	end
	
	if tEndParam.bAddClientH then
		aEndPos.y = aEndPos.y + nCH
	end
	
	if tEndParam.fOffsetScale then
		local nW, nH = hObject:GetSize()
		aEndPos.x = aEndPos.x + tEndParam.fOffsetScale * nW + nW / 2
		aEndPos.y = aEndPos.y + tEndParam.fOffsetScale * nH + nH / 2
	end
	
	--================start==========================
	aStartPos.x = tStartParam.x or aStartPos.x
	aStartPos.y = tStartParam.y or aStartPos.y
	
	if tStartParam.bEqualInit then
		aStartPos.x, aStartPos.y = hObject:GetAbsPos()
	end
	
	if tStartParam.fClientX then
		aStartPos.x = nCW * tStartParam.fClientX
	end
	
	if tStartParam.fClientY then
		aStartPos.y = nCH * tStartParam.fClientY
	end
	
	if tStartParam.bEqualEndX then
		aStartPos.x = aEndPos.x
	end
	
	if tStartParam.bEqualEndY then
		aStartPos.y = aEndPos.y
	end
	
	
	if tStartParam.bAddClientW then
		aStartPos.x = aStartPos.x + nCW
	end
	
	if tStartParam.bAddClientH then
		aStartPos.y = aStartPos.y + nCH
	end
	
	if tStartParam.fOffsetX then
		aStartPos.x = aStartPos.x + tStartParam.fOffsetX
	end
	
	if tStartParam.fOffsetY then
		aStartPos.y = aStartPos.y + tStartParam.fOffsetY
	end
	
	return aStartPos, aEndPos
end


local function GetRunTime(nLen, fVelocity, fAcceleration, szParamName)
	local nTime = 0
	if nLen == 0 or fVelocity == 0 then
		return 0
	end
	
	if fAcceleration == 0 then
		nTime = nLen / fVelocity
		return math.max(nTime, 0)
	end
	
	local A = 0.5 * fAcceleration
	local B = fVelocity
	local C = -nLen
	local nJduge = B * B - 4 * A * C
	if nJduge < 0 then
		Trace("GetRunTime no answer ! szParamName:"..tostring(szParamName))
		return 0
	end
	
	nTime = (-B + math.sqrt(nJduge)) * 0.5 / A
	return math.max(nTime, 0)
end

function Animation_StopAni(hObject, bNotDelay)
	local nLen = #tAnimationQueue
	if nLen > 0 then
		local tAction = {}
		for i=nLen, 1, -1 do
			local tAni = tAnimationQueue[i]
			if tAni.hObject == hObject then
				if not tAni.bDelete then
					tAni.hObject:SetSize(hObject.fInitW, hObject.fInitH)
					if not hObject.fInitX then
						UILog("Animation_StopAni", hObject.fInitX, hObject.fInitY)
					end
					hObject:SetAbsPos(hObject.fInitX, hObject.fInitY)
					if tAni.nEndAlpha then
						hObject:SetAlpha(tAni.nEndAlpha)
					end
					if bNotDelay and tAni.fnEndAction then
						table.insert(tAction, tAni.fnEndAction)
					end
				end
				table.remove(tAnimationQueue, i)
			end
		end
		if bNotDelay then
			for k, v in pairs(tAction) do
				v();
			end
		end
	end
	
	if not bNotDelay then
		nLen = #g_aDelayCall
		if nLen > 0 then
			for i = nLen, 1, -1 do
				local v = g_aDelayCall[i]
				if v.hObject == hObject then
					hObject:Show()
					--UILog("Remove", hObject:GetName())
					table.remove(g_aDelayCall, i)
				end
			end
		end
	end
end

function Animation_AppendLineAni(hObject, nID, fDelayTime, fnEndAction, fnBeginAction)
	local tAction = g_tConfig["Line"][nID]
	if not tAction then
		return
	end
	--UILog("dddddd", #tAnimationQueue, #g_aDelayCall)
	hObject:Hide()
	local fn=function()
		Animation_StopAni(hObject, true);
		
		local aStartPos, aEndPos = GetLineStartAndEnd(hObject, tAction)
		
		local tAni = {}
		local fVelocity = tAction.fVelocity
		
		tAni.aStartPos, tAni.aEndPos = aStartPos, aEndPos
		tAni.nID = nID
		tAni.szType = "Line"
		tAni.fLastTime = GetTickCount()
		tAni.tRTParam = 
		{
			fVelocity = fVelocity,
			aPos = clone(tAni.aStartPos),
			fPastTime = 0.0,
		}
		tAni.hObject = hObject
		tAni.fnEndAction = fnEndAction
		tAni.fTotalTime = tAction.fTotalTime
		
		if tAction.bUseInitSize then
			tAni.nInitWidth, tAni.nInitHeight = hObject.fInitW, hObject.fInitH
		else
			tAni.nInitWidth, tAni.nInitHeight = hObject:GetSize()
		end
		
		if tAction.bScaleInitSize then
			tAni.fInitW, tAni.fInitH= hObject.fInitW, hObject.fInitH
		else
			tAni.fInitW, tAni.fInitH= tAni.nInitWidth, tAni.nInitHeight
		end
		
		local aVec = Vec2_SubVec2(tAni.aEndPos, tAni.aStartPos)
		local nLen = math.sqrt(aVec.x * aVec.x + aVec.y * aVec.y)
		
		if tAction.fVelocity then
			local fAcceleration = tAction.fAcceleration / 1000
			tAni.fTotalTime = GetRunTime(nLen, fVelocity, fAcceleration, nID)
		end
		
		if tAction.fInitScale and tAni.fTotalTime > 0 then
			tAni.fScale = tAction.fInitScale
			tAni.fEndScale = tAction.fEndScale or 1.0
			tAni.fScaleDelta = (tAni.fEndScale - tAction.fInitScale) / tAni.fTotalTime
			--UILog("tAni.fScale", tAni.fScale)
		end
		
		local nCenterX, nCenterY = hObject:GetAbsPos()
		if tAction.bCenterX then
			tAni.nCenterX = nCenterX + tAni.nInitWidth / 2 + (tAction.fOffsetCenterX or 0)
		end
		
		if tAction.bCenterY then 
			tAni.nCenterY = nCenterY + tAni.nInitHeight / 2 + (tAction.fOffsetCenterY or 0)
		end
		
		if tAction.nInitAlpha and tAni.fTotalTime > 0 then
			tAni.nEndAlpha = tAction.nEndAlpha or 255
			
			tAni.nAlpha = (tAni.nEndAlpha - tAction.nInitAlpha) / tAni.fTotalTime
			tAni.hObject:SetAlpha(tAction.nInitAlpha)
		end		
		
		tAni.hObject:Show()
		tAni.hObject:SetAbsPos(tAni.aStartPos.x, tAni.aStartPos.y)
		table.insert(tAnimationQueue, tAni)
		
		if fnBeginAction then
			fnBeginAction()
		end
		--DoLineAction(tAni, tAni.fLastTime, tAni.fLastTime+0.001)
	end
	
	if fDelayTime and fDelayTime > 0 then
		AddDelayCall(fDelayTime, fn, hObject)
	else
		fn()
	end
end


g_OutputInLog = false
local function OnFrameRender()
	if #tAnimationQueue > 0 then		
		local nLen = #tAnimationQueue
		for i=nLen, 1, -1 do
			local tAni = tAnimationQueue[i]
			if tAni.bDelete then
				table.remove(tAnimationQueue, i)
			end
		end
		
		local nCurrentTime = GetTickCount()
		for _, tAni in pairs(tAnimationQueue) do
			if not tAni.bDelete then
				if tAni.szType == "Line" then
					DoLineAction(tAni, tAni.fLastTime, nCurrentTime)
				elseif tAni.szType == "rebound" then
					DoRebound(tAni, tAni.fLastTime, nCurrentTime)
				end
			end
		end
	end
	
	local nLen = #g_aDelayCall
	if nLen > 0 then
		if g_OutputInLog then
			UILog(" Delay in")
		end

		local nTime = GetTickCount()
		for i = nLen, 1, -1 do
			local v = g_aDelayCall[i]
			if nTime >= v.nTime then
				local fnAction = v.fnAction()
				table.remove(g_aDelayCall, i)
			end
		end
	end
end

RegisterEvent("RENDER_FRAME_UPDATE", function() OnFrameRender() end )