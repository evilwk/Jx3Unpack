_ShieldWeak = {}
setmetatable(_ShieldWeak, {__mode = "v"})

_g_CurrentExcuteMacro = nil
_g_ShildOnceKey = {}

_ShieldList = 
{
	["_G"] = true,
	["_ShieldWeak"] = true,
	["_ShieldList"] = true,
	["setfenv"] = true,
	["getfenv"] = true,
	["io"] = true,
	["os"] = true,
	["Ini"] = true,
	["dofile"] = true,
	["loadfile"] = true,
	["loadstring"] = true,
	["dostring"] = true,
	["load"] = true,
	["require"] = true,
	["package"] = true,
	["debug"] = true,
	["Camera_EnableControl"] = true,
	["MoveForwardStart"] = true,
	["MoveForwardStop"] = true,
	["MoveBackwardStart"] = true,
	["MoveBackwardStop"] = true,
	["TurnLeftStart"] = true,
	["TurnLeftStop"] = true,
	["TurnRightStart"] = true,
	["TurnRightStop"] = true,
	["StrafeLeftStart"] = true,
	["StrafeLeftStop"] = true,
	["StrafeRightStart"] = true,
	["StrafeRightStop"] = true,
	["MoveUpStart"] = true,
	["MoveUpStop"] = true,
	["MoveDownStart"] = true,
	["MoveDownStop"] = true,
	["ShieldValue"] = true,
	["ShieldTable"] = true,
	["ShieldFunction"] = true,
	["AutoMoveToTarget"] = true,
	["AutoMoveToPoint"] = true,
	["LoadScriptLib"] = true,
	["LoadLoginScriptLib"] = true,
	["LoadDefaultScriptLib"] = true,
	["RemoteCallToServer"] = true,
	["ActionBar_ButtonDown"] = true,
	["ActionBar_ButtonUp"] = true,
	["_g_CurrentExcuteMacro"] = true,
	["_g_ShildOnceKey"] = true,
	["GMMessage"] = true,
	["GMCheck"] = true,
	["FollowTarget"] = true,
	["StartFollow"] = true,
	["FollowTarget"] = true,
	["SetUserPreferences"] = true,
	["QueryShopPageDirectly"] = true,
	["SaveDataToFile"] = true,
	["LoadScriptFile"] = true,
	["SetGlobal"] = true,
	["GetGlobal"] = true,	
	["SelectTarget"] = true,
	["SelectTargetTarget"] = true,
	["SelectSelf"] = true,
	["SelectTeammate"] = true,
	["SearchAllies"] = true,
	["SearchEnemy"] = true,
	["ExcuteMacro"] = true,
	["ExcuteMacroByID"] = true,
	["Player_GetPlayerModelByID"] = true,
	["Character_PlayAnimation"] = true,
	["g_SkillNameToID"] = true,
	["g_ItemNameToID"] = true,
	["g_Macro"] = true,
	["g_MacroInfo"] = true,
	["AddMacro"] = true,
	["SetMacro"] = true,
	["RemoveMacro"] = true,
	["GetMacroContent"] = true,
	["OnUseSkill"] = true,
	["OnUseItem"] = true,
	["ActionButtonDown"] = true,
	["ActionButtonUp"] = true,
	["FarmPanel"] = true,
	["IrrigatePanel"] = true,
	["CastSkill"] = true,
	["CastSkillXYZ"] = true,
	["CastCommonSkill"] = true,
	["TurnTo"] = true,
	["AddFoe"] = true,
	["DelFoe"] = true,
	["SetTarget"] = true,
	["UseItem"] = true,
	["DestroyItem"] = true,
	["TradePanel"] = true,
	["TradingAddItem"] = true,
	["TradingDeleteItem"] = true,
	["TradingSetMoney"] = true,
	["TradingConfirm"] = true,
	["CardBuy"] = true,
	["OpenCardBuy"] = true,
	["CardSell"] = true,
	["OpenCardSell"] = true,
	["GetGameCardClient"] = true,
	["ApplySlay"] = true,
	["GetEmotion"] = true,
	["DoAction"] = true,
	["g_tExpression"] = true,
	["SendGmMessage"] = true,
	["GMPanel"] = true,
}

function ShieldValue(t, szKey)
	t[szKey] = true
end

function ShieldTable(t, szTable, tShield)
	t[szTable] = function(tOwner)
		local result = tOwner[szTable]
		if not result then
			return nil
		end
		
		if _ShieldWeak[result] then
			return _ShieldWeak[result]
		end
		
		local proxy = {}
		local mt = 
		{
			__index = function(t, k)
				if tShield[k] then
					if type(tShield[k]) == "function" then
						return tShield[k](result)
					end
					return nil
				end
				return result[k]
			end,
			__newindex = function(t, k, v)
				if tShield[k] then
					return
				end
				result[k] = v
			end,
			__metatable = function() end,
		}
		
		setmetatable(proxy, mt);
		
		_ShieldWeak[result] = proxy
		return proxy
	end
end

function ShieldFunction(t, szFunc, tResult, tParam, bInUserAction, szOnceKey)
	t[szFunc] = function(tOwner)
		return function(...)
			if _g_CurrentExcuteMacro then
				if szOnceKey then
					if _g_CurrentExcuteMacro.aOnce[szOnceKey] then
						return nil
					end
					_g_CurrentExcuteMacro.aOnce[szOnceKey] = true
				end
			else
				if bInUserAction and not Station.IsInUserAction() then
					return nil
				end
				if szOnceKey then
					if _g_ShildOnceKey[szOnceKey] then
						return nil
					end
					_g_ShildOnceKey[szOnceKey] = true
				end
			end
			
			if tParam then
				for k, v in pairs(tParam) do
					local a = select(k, ...)
					if v[a] then
						if type(v[a]) == "function" then
							return v[a](...)
						end
						return nil
					end
				end
			end
						
			if not tResult then
				return tOwner[szFunc](...)
			end
			
			local r = tOwner[szFunc](...)
			if not r then
				return nil
			end
			
			if _ShieldWeak[r] then
				return _ShieldWeak[r]
			end
			
			local proxy = {}
			local mt = 
			{
				__index = function(t, k)
					if tResult[k] then
						if type(tResult[k]) == "function" then
							return tResult[k](r)
						end
						return nil
					end
					return r[k]
				end,
				__newindex = function(t, k, v)
					if tResult[k] then
						return
					end
					r[k] = v
				end,
				__metatable = function() end,
			}
			setmetatable(proxy, mt)
			
			_ShieldWeak[r] = proxy
			
			return proxy
		end
	end
end

local _StationShild = 
{
	["IsInUserAction"] = true,
}
ShieldTable(_ShieldList, "Station", _StationShild)


ShieldFunction(_ShieldList, "BuyItem", nil, nil, true, "BuyItem")
ShieldFunction(_ShieldList, "SendMail", nil, nil, true, "SendMail")

local _ActionBarShield = 
{
	["OnUseActionBarObject"] = true,
	["OnItemLButtonDrag"] = true,
	["OnItemLButtonDragEnd"] = true,
	["OnItemLButtonClick"] = true,
	["OnItemLButtonDBClick"] = true,
	["OnItemRButtonClick"] = true,
	["OnItemRButtonDBClick"] = true,
	["OnChangeHandAndBoxItem"] = true,
	["EquipItemPosChanged"] = true,
	["UpdataSkillInActionBar"] = true,
	["OnRemoveMacro"] = true,
	["UpdataCraftInActionBar"] = true,
	["Save"] = true,
	["LoadSave"] = true,
	["New"] = true,
}

ShieldTable(_ShieldList, "ActionBar", _ActionBarShield)
ShieldTable(_ShieldList, "ActionBar1", _ActionBarShield)
ShieldTable(_ShieldList, "ActionBar2", _ActionBarShield)
ShieldTable(_ShieldList, "ActionBar3", _ActionBarShield)
ShieldTable(_ShieldList, "ActionBar4", _ActionBarShield)

local _ShopPanelShield = 
{
	["OnItemRButtonClick"] = true,
}

ShieldTable(_ShieldList, "ShopPanel", _ShopPanelShield)

local _MacroSettingShield = 
{
	["OnItemLButtonClick"] = true,
	["OnItemRButtonClick"] = true,
	["NewMacro"] = true,
	["NewMacroTitle"] = true,
}

ShieldTable(_ShieldList, "MacroSettingPanel", _MacroSettingShield)

local _EditBoxShield = 
{
	["OnEditSpecialKeyDown"] = true,
	["ProcessInput"] = true,
	["OnLButtonClick"] = true,
}
ShieldTable(_ShieldList, "EditBox", _EditBoxShield)

local _CompassPanelShield = 
{
	["OnEvent"] = true,
	["OnFrameBreathe"] = true,
	["OnLButtonClick"] = true,
	["ClampAngle"] = true,
	["GetTwoPointAngle"] = true,
	["OnHoroSysDataUpdate"] = true,
}

ShieldTable(_ShieldList, "CompassPanel", _CompassPanelShield)

local _SkillPanelShield = 
{
	["NewSkill"] = true,
	["UpdateSkill"] = true,
	["UpdateSkillInKungfu"] = true,
	["OnItemLButtonClick"] = true,
	["OnItemRButtonClick"] = true,
}

ShieldTable(_ShieldList, "SkillPanel", _SkillPanelShield)

local _FormationPanelShield = 
{
	["OnItemLButtonClick"] = true,
}

ShieldTable(_ShieldList, "FormationPanel", _FormationPanelShield)

