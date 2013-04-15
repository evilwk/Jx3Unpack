function OutputAutoTipInfo()
	local szText, nShowTipType, bRichText, x, y, w, h = GetAutoTipInfo()
	if not szText or szText == "" then
		return
	end
	OutputAutoTipInfoByText(szText, nShowTipType, bRichText, x, y, w, h)
end

function OutputAutoTipInfoByText(szText, nShowTipType, bRichText, x, y, w, h)
	local fnGetHotkey = function(s)
		local nKey, bShift, bCtrl, bAlt = Hotkey.Get(s)
		local szkey = GetKeyShow(nKey, bShift, bCtrl, bAlt)
		if not szkey or szkey == "" then
			nKey, bShift, bCtrl, bAlt = Hotkey.Get(s, 2)
			szkey = GetKeyShow(nKey, bShift, bCtrl, bAlt)		
		end
		if not szkey then
			szkey = s
		end
		return szkey
	end
	szText = string.gsub(szText, "<KEY (.-)>", fnGetHotkey)
	
	if not bRichText then
		szText = "<text>text="..EncodeComponentsString(szText).." font=106 </text>"
	end
	if nShowTipType == 0 then
		--显示在旁边
		OutputTip(szText, 350, {x, y, w, h})
	elseif nShowTipType == 1 then
		--显示在鼠标旁边并且跟随鼠标移动
		local x, y = Cursor.GetPos()	
		w, h = 40, 40
		OutputTip(szText, 350, {x, y, w, h})
	elseif nShowTipType == 2 then
		--显示在固定位置
		OutputTip(szText, 350, {x, y, w, h, 1})
	end
end

function TipOnMouseMove()
	local x, y = Cursor.GetPos()
	local frame = GetTipFrame()
	Wnd.SetTipPosByRect(frame, x, y, x + 40, y + 40, ALW.RIGHT_LEFT_AND_BOTTOM_TOP)
end