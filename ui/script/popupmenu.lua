--[[

menu = 
{
	nMiniWidth, --最小宽
	id, --标识
	x, y --位置,如果不设置取鼠标位置
	fnMouseEnter=function() end,
	fnAction = function(UserData, bCkeck)  end,	--默认处理函数。可以没有
	fnChangeColor = function(UserData, r, g, b) end, --默认色盘表更改处理函数
	fnCancelAction = function() end, --取消时调用的函数
	fnAutoClose = function() end, --函数返回true，自动关闭
	bVisibleWhenHideUI = true, --在隐藏UI的模式下仍然显示。
	{szOption = "组队", UserData = 1, nFont = 160, r = 255, g = 255, b = 210, bDisable = true, fnAction = function() player.Zhudui() end}, --一项,UserData--可以没有

	{bDevide = true}, --分割线
	{szOption = "监视信息", 
	
		{
			szOption = "战斗提示", 
			bCheck = true, bChecked = true, 
			bColorTable = true, bNotChangeSelfColor = true, 
			rgb = {255, 0, 0}, --颜色
            bNoHead = false, 不计算头
			szIcon = "ui\Image\button\FrendNPartyButton.UITex",	-- 要显示的图标的路径（可选）
			nFrame = 60, -- 图标的帧数（如果填写了szIcon，必须填写nFrame）
			szLayer = "ICON_LEFT", -- 可以是"ICON_LEFT", "ICON_RIGHT", "ICON_CENTER", nil, 分别表示图标在文字左边，右边，图标居中重叠，缺省重叠（图标和文字都在左边并重叠）（可选）
			fnDisable = function() end,	-- 动态的判断是否为Disable状态
			fnChangeColor = function(UserData, r, g, b) end
		}	--bCheck，前面有没有勾，bChecked--初始状态, --bColorTable 色盘, --bNotChangeSelfColor 不改选项颜色， fnChangeColor --改颜色处理函数
		{szOption = "任务提示", bCheck = true, fnAction = function(UserData, bCkeck) ... end}
		
		{szOption = "任务提示", bMCheck = true, fnAction = function(UserData, bCkeck) ... end} --bMCheck ，多个中选择一个,以分割符为界
	},	--有子项的项

}


]]

POPUPMENU_DISABLE_FONT = 161
POPUPMENU_ENABLE_FONT = 162

local POPUPMENU_HORIZONTAL_SPACE = 10
local POPUPMENU_VERTICAL_SPACE = 10
local POPUPMENU_MINIMUM_WIDTH = 20
local POPUPMENU_INI_FILE_PATH = "UI/Config/default/PopupMenuPanel.ini"

function IsPopupMenuOpened()
	if Station.Lookup("Topmost1/PopupMenuPanel") then
		return true
	end
	return false
end

function GetPopupMenu()
	return Station.Lookup("Topmost1/PopupMenuPanel")
end

function PopupMenu(menu)
	if IsPopupMenuOpened() then
		Wnd.CloseWindow("PopupMenuPanel")
	end
	local hMenuFrame = Wnd.OpenWindow("PopupMenuPanel")
	local hTotal = hMenuFrame:Lookup("", "")
	hTotal:Clear()
	Station.SetFocusWindow(hMenuFrame)
	
	if menu.bVisibleWhenHideUI then
		hMenuFrame:ShowWhenUIHide()
	end
	
	hMenuFrame.fnAction = menu.fnAction
	hMenuFrame.fnMouseEnter = menu.fnMouseEnter
	hMenuFrame.fnChangeColor = menu.fnChangeColor
	hMenuFrame.fnCancelAction = menu.fnCancelAction
	hMenuFrame.fnAutoClose = menu.fnAutoClose
	hMenuFrame.id = menu.id
	hTotal.nMiniWidth = menu.nMiniWidth
	
	hMenuFrame.AppendChildMenu = function(hTotal, szName, menu)
		local hSubMenu = hTotal:AppendItemFromIni(POPUPMENU_INI_FILE_PATH, "Handle_Menu", szName)
		hSubMenu.szType = "menu"
		local hItemGroup = hSubMenu:Lookup("Handle_Item_Group")
		hItemGroup:SetRelPos(POPUPMENU_HORIZONTAL_SPACE, POPUPMENU_VERTICAL_SPACE)
		
		local nItemHeadWidth = 0
		local nItemBodyWidth = POPUPMENU_MINIMUM_WIDTH
		local nItemFootWidth = 0
		local hItemPosX = 0
		local hItemPosY = 0
		for key, value in ipairs(menu) do
			if value.bDevide then
				hItemGroup:AppendItemFromIni(POPUPMENU_INI_FILE_PATH, "Image_Devide")
				local hImage = hItemGroup:Lookup("Image_Devide")
				hImage:SetName("")
				hImage:SetRelPos(hItemPosX, hItemPosY)
				local _, nDevideHeight = hImage:GetSize()
				hItemPosY = hItemPosY + nDevideHeight
			else
				hItemGroup:AppendItemFromIni(POPUPMENU_INI_FILE_PATH, "Handle_Item")
				local hItem = hItemGroup:Lookup("Handle_Item")
				hItem.fnMouseEnter = value.fnMouseEnter
				hItem:SetName(szName.."_"..key)
				hItem:SetRelPos(hItemPosX, hItemPosY)
				local _, nItemHeight = hItem:GetSize()
				hItemPosY = hItemPosY + nItemHeight
				hItem.tData = value
				
				if not value.szOption then
					value.szOption = ""
				end
				local hTextContent = hItem:Lookup("Text_Content")
				hTextContent:SetText(value.szOption)
				if value.nFont then
					hTextContent:SetFontScheme(value.nFont)
				end
				if value.r and value.g and value.b then
					hTextContent:SetFontColor(value.r, value.g, value.b)
				end
				if value.rgb then
					hTextContent:SetFontColor(value.rgb[1], value.rgb[2], value.rgb[3])
				end
				if value.bDisable then
					hTextContent:SetFontScheme(POPUPMENU_DISABLE_FONT) --disable的字体
				end
				hTextContent:AutoSize()
				hTextContent:Show()
				local nTextWidth = hTextContent:GetSize()
				
				local nIconWidth = 0
				if value.szIcon then
					local hImageContent = hItem:Lookup("Image_Content")
					hImageContent:FromUITex(value.szIcon, value.nFrame)
					hImageContent:Show()
					nIconWidth, _ = hImageContent:GetSize()
				end
				
				if nTextWidth + nIconWidth > nItemBodyWidth then
					nItemBodyWidth = nTextWidth + nIconWidth
				end
				
				local hImageHead
				if value.bMCheck then
					hImageHead = hItem:Lookup("Image_MCheck")
				elseif value.bCheck then
					hImageHead = hItem:Lookup("Image_Check")						
				end
				if hImageHead then
					if value.bChecked then
						hImageHead:Show()
					end
					local nWidth, _ = hImageHead:GetSize()
					if nWidth > nItemHeadWidth then
						nItemHeadWidth = nWidth
					end
				end
				
				local hImageFoot
				if value[1] then	--有子项
					hImageFoot = hItem:Lookup("Image_Child")
				elseif value.bColorTable then --附加色盘
					hImageFoot = hItem:Lookup("Image_Color")
				end
				if hImageFoot then
					hImageFoot:Show()
					local nWidth, _ = hImageFoot:GetSize()
					if nWidth > nItemFootWidth then
						nItemFootWidth = nWidth
					end
				end
			end
		end
		
		local nItemWidth = nItemHeadWidth + nItemBodyWidth + nItemFootWidth
		if hTotal.nMiniWidth and hTotal.nMiniWidth - 2 * POPUPMENU_HORIZONTAL_SPACE > nItemWidth then
			nItemWidth = hTotal.nMiniWidth - 2 * POPUPMENU_HORIZONTAL_SPACE
		end
				
		-- typeset
		local nCount = hItemGroup:GetItemCount()
		for i = 0, nCount - 1 do
			local hItem = hItemGroup:Lookup(i)
			local _, nItemHeight = hItem:GetSize()
			hItem:SetSize(nItemWidth, nItemHeight)
			if hItem.tData then
				hItem:Lookup("Image_Over"):SetSize(nItemWidth, nItemHeight)
				
				local hImageHead
				if hItem.tData.bMCheck then
					hImageHead = hItem:Lookup("Image_MCheck")
				elseif hItem.tData.bCheck then
					hImageHead = hItem:Lookup("Image_Check")
				end
				if hImageHead then
					local _, nHeight = hImageHead:GetSize()
					hImageHead:SetRelPos(0, (nItemHeight - nHeight) / 2)	
				end
				
				local hImageFoot
				if hItem.tData[1] then
					hImageFoot = hItem:Lookup("Image_Child")
				elseif hItem.tData.bColorTable then
					hImageFoot = hItem:Lookup("Image_Color")
				end
				if hImageFoot then
					local nWidth, nHeight = hImageFoot:GetSize()
					hImageFoot:SetRelPos(nItemWidth - nWidth, (nItemHeight - nHeight) / 2)	
				end
				
				local hTextContent = hItem:Lookup("Text_Content")
				local nTextWidth, nTextHeight = hTextContent:GetSize()
				
				local hImageContent = hItem:Lookup("Image_Content")
				local nImageWidth, nImageHeight = hImageContent:GetSize()
				
				local szLayer = hItem.tData.szLayer
				if not szLayer then
                    if hItem.tData.bNotHead then
                        hTextContent:SetRelPos(0, (nItemHeight - nTextHeight) / 2)
                        hImageContent:SetRelPos(0, (nItemHeight - nImageHeight) / 2)
                    else
                        hTextContent:SetRelPos(nItemHeadWidth, (nItemHeight - nTextHeight) / 2)
                        hImageContent:SetRelPos(nItemHeadWidth, (nItemHeight - nImageHeight) / 2)
                    end
				elseif szLayer == "ICON_CENTER" then
					hTextContent:SetRelPos(nItemHeadWidth, (nItemHeight - nTextHeight) / 2)
					hImageContent:SetRelPos(nItemHeadWidth + (nItemBodyWidth - nImageWidth) / 2, (nItemHeight - nImageHeight) / 2)
				elseif szLayer == "ICON_LEFT" then
					hTextContent:SetRelPos(nItemHeadWidth + nItemBodyWidth - nTextWidth, (nItemHeight - nTextHeight) / 2)
					hImageContent:SetRelPos(nItemHeadWidth, (nItemHeight - nImageHeight) / 2)
				elseif szLayer == "ICON_RIGHT" then
					hTextContent:SetRelPos(nItemHeadWidth, (nItemHeight - nTextHeight) / 2)
					hImageContent:SetRelPos(nItemHeadWidth + nItemBodyWidth - nImageWidth, (nItemHeight - nImageHeight) / 2)
				else
					error("PopupMenu: szLayer error!");
				end
				
				hItem:FormatAllItemPos()
			end
		end
		
		local nMenuWidth = nItemWidth + POPUPMENU_HORIZONTAL_SPACE * 2
		local nMenuHeight = hItemPosY + POPUPMENU_VERTICAL_SPACE * 2
		local hImageBg = hSubMenu:Lookup("Image_Bg")
		hImageBg:SetSize(nMenuWidth, nMenuHeight)
				
		hItemGroup:FormatAllItemPos()
		hItemGroup:SetSizeByAllItemSize()
		hSubMenu:FormatAllItemPos()
		hSubMenu:SetSizeByAllItemSize()
	end
	
	hMenuFrame.AppendChildMenu(hTotal, "", menu)

	local hMainMenu = hTotal:Lookup(0)
	local nMenuWidth, nMenuHeight = hMainMenu:GetSize()
	hTotal:SetSize(nMenuWidth, nMenuHeight)
	hMenuFrame:SetSize(nMenuWidth, nMenuHeight)
	
	local nX, nY = menu.x, menu.y
	if not nX or not nY then
		nX, nY = Cursor.GetPos()
	end
	local nClientWidth, nClientHeight = Station.GetClientSize()
	if nY + nMenuHeight > nClientHeight then
		if nY - nMenuHeight < 0 then
			nY = nClientHeight - nMenuHeight
		else
			nY = nY - nMenuHeight
		end
	end
	if nX + nMenuWidth > nClientWidth then
		if nX - nMenuWidth < 0 then
			nX = nClientWidth - nMenuWidth
		else
			nX = nX - nMenuWidth
		end
	end

	hMenuFrame:SetRelPos(nX, nY)
	hMainMenu:SetAbsPos(nX, nY)
	hMainMenu:Show()
		
	PlaySound(SOUND.UI_SOUND,g_sound.OpenFrame)				
end


function PopupMenuEx(hBtn, tData, fnCloseCondition, text)
	if hBtn.bIgnor then
		hBtn.bIgnor = nil
		return
	end
	
	if not text then
		text = hBtn:Lookup("", ""):Lookup(0)
	end
    
	local szName = text:GetName()
	local xT, yT = text:GetAbsPos()
	local wT, hT = text:GetSize()
	local menu =
	{
		nMiniWidth = wT,
		x = xT, y = yT + hT,
		fnCancelAction = function()
			if hBtn:IsValid() then
				local x, y = Cursor.GetPos()
				local xA, yA = hBtn:GetAbsPos()
				local w, h = hBtn:GetSize()
				if x >= xA and x < xA + w and y >= yA and y <= yA + h then
                    hBtn.bIgnor = true
				end
			end
		end,
		fnAction = function(UserData)
			if text:IsValid() then
                text:SetText(UserData.name)
				if UserData.value and type(UserData.value) == "table" then
					text.MenuValue = text.MenuValue or {}
					for k, v in pairs(UserData.value) do
						text.MenuValue[k] = v;
					end
				else
					text.MenuValue = UserData.value
				end
				
				if UserData.fnAction then
					UserData.fnAction(UserData.value)
				end
			end
		end,
		fnAutoClose = function() return not fnCloseCondition() end,
	}
	for k, v in ipairs(tData) do
        table.insert(menu, {szOption = v.name, UserData= v, r = v.r, g = v.g, b = v.b})
	end
	PopupMenu(menu)
end