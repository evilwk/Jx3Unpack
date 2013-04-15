g_tAuctionString =
{
	tAuctionTime =
	{
		"12小时",
		"24小时",
		"48小时",
	},
	STR_ITEM_NAME     = "物品名称",
	STR_ITEM_SORT     = "所有种类",
	STR_ITEM_SUB_SORT = "所有子类",
	STR_ITEM_YESORNO  = "是否可用",
	STR_ITEM_QUALITY  = "任何品质",
	STR_ITEM_STATUS   = "所有状态",
	STR_SELLER_NAME   = "出售者名称",

	STR_DEFAULT_TIME = "24小时",
	STR_ERROR_CANNOT_DRAG_ITEM_IN_AUCTION = "该物品不能寄卖",
	STR_ERROR_CANNOT_SELL_BAD_ITEM = "不能寄卖已损坏物品",
	STR_ERROR_CANNOT_DRAG_BIND_IN_AUCTION = "不能寄卖已绑定物品",
	STR_ERROR_CANNOT_DRAG_TIME_LIMIT_ITEM_IN_AUCTION = "不能寄卖限时物品",
	STR_AUCTION_ONLY_SOLD_GLOUP = "请把拆开的物品放进背包后再寄卖\n",
	STR_AUCTION_CANNOT_SELL_BOOK = "不能寄卖书籍",
	STR_AUCTION_SELL_SUCCESS = "物品已寄卖\n",
	STR_AUCTION_BID_SUCCESS = "出价成功\n",
	STR_AUCTION_CANCEL_SUCCESS = "取消成功\n",
	STR_AUCTION_NEAR_DUE = "即将到期",
	STR_AUCTION_NO_ONE_BID  = "无人出价",
	STR_AUCTION_CURRENT_BID = "当前出价",
	STR_AUCTION_MY_BID = "我的出价",
	STR_AUCTION_MY_UNIT_BID = "我的单价",
	STR_AUCTION_UNIT_PRICE = "单价",
	STR_AUCTION_CURRENT_UNIT_BID = "当前单价",

	STR_BID_AFFIRM = "<text>text=\"您确定要以\" font=105 </text><D0><text>text=\"价格竞标[<D1>]\" font=105 </text>",
	STR_BUY_AFFIRM = "<text>text=\"您确定要以\" font=105 </text><D0><text>text=\"价格购买[<D1>]\" font=105 </text>",
	STR_CANCEL_AFFIRM = "要取消[<D0>]的寄卖吗？",
	STR_CAN_NOT_CANCEL = "该物品已有玩家出价，不能取消寄卖。",
	STR_BID_BIGGER_THAN_TEN = "你的加价额度不能低于10铜。",
	STR_DATA_APPLY_SYSTEM_BUSY = "服务器忙，请稍后重试。",
	STR_NOTICE_SURE = "确定",
	STR_NOTICE_CANCEL = "取消",
	STR_AUCTION_ITEM_INFO_CHANGE = "寄卖失败！您要寄卖的物品信息有误。",

	tSearchSort =
	{
		["兵刃"] =
		{
		 	nSortID = 1,
		 	tSubSort =
		 	{
		 		["棍类"]   = 1,
				["长兵"]   = 2,
				["短兵类"] = 3,
				--["拳套"] = 4,
				["双兵类"] = 5,
				["笔类"]   = 6,
				["重兵类"] = 7,
				["虫笛类"] = 8,
				["千机匣"] = 9,
		 	},
		},
		["暗器"] =
		{
			nSortID = 2,
			tSubSort =
			{
				["投掷"] = 1,
				["弓弦"] = 2,
				--["机射"] = 3,
				["弹药"] = 4,
			},
		},
		["服饰"] =
		{
			nSortID = 3,
			tSubSort =
			{
				["上衣"] = 1,
				["帽子"] = 2,
				["腰带"] = 3,
				["下装"] = 4,
				["鞋子"] = 5,
				["护腕"] = 6,
			},
		},
		["饰物"] =
		{
			nSortID = 4,
			tSubSort =
			{
				["项链"] = 1,
				["戒指"] = 2,
				["腰坠"] = 3,
				["腰部挂件"] = 4,
				["背部挂件"] = 5,
			},
		},
		["坐骑"] =
		{
			nSortID = 5,
			tSubSort =
			{
				["坐骑"]     = 1,
				["坐骑头饰"] = 2,
				["坐骑胸饰"] = 3,
				["坐骑足饰"] = 4,
				["坐骑鞍具"] = 5,
			},
		},
		["包裹"] = {nSortID = 6, tSubSort = {}, },
		["秘笈"] =
		{
			nSortID = 7,
			tSubSort =
			{
				["纯阳秘笈"] = 1,
				["天策秘笈"] = 2,
				["少林秘笈"] = 3,
				["七秀秘笈"] = 4,
				["万花秘笈"] = 5,
				["江湖秘笈"] = 6,
				["藏剑秘笈"] = 7,
				["五毒秘笈"] = 8,
				["唐门秘笈"] = 9,
			},
		},
		["配方"] =
		{
			nSortID = 8,
			tSubSort =
			{
				["缝纫配方"] = 1,
				["烹饪配方"] = 2,
				["医术配方"] = 3,
				["铸造配方"] = 4,
			},
		},
		["消耗品"] =
		{
			nSortID = 9,
			tSubSort =
			{
				["食物"]     = 1,
				["药品"]     = 2,
				--["物品强化"] = 3,
				["礼品"]     = 4,
			},
		},
		["物品强化"] =
		{
			nSortID = 13,
			tSubSort =
			{
				["帽子"] = 1,
				["上衣"] = 2,
				["下装"] = 3,
				["腰带"] = 4,
				["鞋子"] = 5,
				["护腕"] = 6,
				["武器"] = 7,
				["饰品"] = 8,
			},
		},
		["材料"] =
		{
			nSortID = 10,
			tSubSort =
			{
				["金属与矿物"] = 1,
				["药草"] = 2,
				["酒"]   = 3,
				["布料"] = 4,
				["皮料"] = 5,
				["肉类"] = 6,
				["纸墨"] = 7,
				["特殊材料"] = 8,
			},
		},
		["书籍"] =
		{
			nSortID = 12,
			tSubSort =
			{
				["杂集"] = 1,
				["道学"] = 2,
				["佛学"] = 3,
			},
		},
		["宝石"] =
		{
			nSortID = 15,
			tSubSort =
			{
				["金系五行石"] = 1,
				["木系五行石"] = 2,
				["水系五行石"] = 3,
				["火系五行石"] = 4,
				["土系五行石"] = 5,
				["五彩石"] = 6,
			},
		},
		["宝箱"] =
		{
			nSortID = 16,
			tSubSort =
			{
				["宝箱"] = 1,
				["钥匙"] = 2,
			},
		},
		["帮会产物"] =
		{
			nSortID = 14,
			tSubSort =
			{
				["瑰石"] = 1,
				["其他"] = 2,
			},
		},
		["其他"] =
		{
			nSortID = 20,
			tSubSort =
			{
				["垃圾"] = 1,
				["其他"] = 2,
			},
		},
	},
	tSearchQuality =
	{
		["破败"] = 0,
		["普通"] = 1,
		["精巧"] = 2,
		["卓越"] = 3,
		["珍奇"] = 4,
		["稀世"] = 5,
	},

	tSearchStatus =
	{
		["已出价"] = AUCTION_SALE_STATE.SOMEONE_BID,
		["无出价"] = AUCTION_SALE_STATE.NO_ONE_BID,
	},

	tAuctionRespond =
	{
		[AUCTION_RESPOND_CODE.ITEM_NOT_EXIST] = "物品不存在\n",
		[AUCTION_RESPOND_CODE.PRICE_TOO_LOW] = "价格太低\n",
		[AUCTION_RESPOND_CODE.CANNOT_CANCEL] = "有人出价不能取消\n",
		[AUCTION_RESPOND_CODE.SERVER_BUSY] = "服务器忙，请稍后重试\n",
		[AUCTION_RESPOND_CODE.MAILBOX_FULL] = "交易行邮件过多\n",
		[AUCTION_RESPOND_CODE.UNKNOWN_ERROR] = "未知错误\n",
	},

	tAuctionNotify =
	{
		[AUCTION_MESSAGE_CODE.ACQUIRE_ITEM] = "<text>text=\"你以\" font=<D2></text><D0><text>text=\"价格成功购买[<D1>]。请到信使处收取物品。\\\n\" font=<D2></text>",
		[AUCTION_MESSAGE_CODE.BID_LOST] 	= "<text>text=\"你对[<D0>]的出价已被超过。\\\n\" font=<D1></text>",
		[AUCTION_MESSAGE_CODE.SOMEONE_BID]  = "<text>text=\"你寄卖的[<D1>]已出价到\" font=<D2></text><D0><text>text=\"。\\\n\" font=<D2></text>",
		[AUCTION_MESSAGE_CODE.ITEM_SOLD]    = "<text>text=\"你寄卖的[<D1>]以\" font=<D2></text><D0><text>text=\"价格成功卖出。请到信使处收取金钱。\\\n\" font=<D2></text>",
		[AUCTION_MESSAGE_CODE.TIME_OVER]    = "<text>text=\"你寄卖的[<D0>]已到期。请到信使处取回物品。\\\n\" font=<D1></text>",
	},
}
