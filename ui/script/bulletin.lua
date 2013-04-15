function GetBulletinText()
	local szMsg =
[[
剑网3介绍

  《剑侠情缘网络版叁》是由金山软件旗下，拥有14年游戏自主开发历程的知名国产游戏工作室“西山居”历时五年、耗资数千万倾力打造的一款正统武侠MMORPG巨作，传承了《剑侠情缘》系列游戏的经典神髓，更开创了国内自主研发网游的精品先河！感谢广大玩家一直以来对游戏的关注和支持，您们的支持是我们不断努力、给广大玩家提供更高品质游戏和更好服务的强大动力。
]]
	return "<text>text="..EncodeComponentsString(szMsg).." font=18 </text>"
end;
