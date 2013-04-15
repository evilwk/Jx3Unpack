COMBAT_TEXT_FADE_IN_FRAME = 4	     --���õ��������
COMBAT_TEXT_HOLD_FRAME = 20			 --���ó���������
COMBAT_TEXT_FADE_OUT_FRAME = 8		 --���õ���������

COMBAT_TEXT_IMMUNE_SCALE = 1		 --������������ű���
COMBAT_TEXT_BLOCK_SCALE = 1		 --����������ű���
COMBAT_TEXT_ABSORB_SCALE = 1		 --������������ű���
COMBAT_TEXT_SHIELD_SCALE = 1		 --������������ű���
COMBAT_TEXT_PARRY_SCALE = 1		 --�м���������ű���
COMBAT_TEXT_INSIGHT_SCALE = 1		 --ʶ����������ű���

CombatTextWnd={

--�Ҷ�Ŀ����ɵ�Ч��
g_bMerge = true;
MeToOther = 
{
	bShangHai = true, --�˺�
	bZhiLiao = true, --����
	bQiTa = true, -- ����
	bChaiZhao = true, --����
	bDuoShan = true, --����
	bPianLi = true, --ƫ��
	bShiPo = true, --ʶ��
	bHuaJie = true, --����
	bMianYi = true, --����
	bDiXiao = true, --����
	bZengYi = false, --����
	bJianYi = false, --����
	bSkillName = true,
},
--Ŀ�������ɵ�Ч��
OtherToMe =
{
	bShangHai = true, --�˺�
	bZhiLiao = true, --����
	bQiTa = true, -- ����
	bChaiZhao = true, --����
	bDuoShan = true, --����
	bPianLi = true, --ƫ��
	bShiPo = true, --ʶ��
	bHuaJie = true, --����
	bMianYi = true, --����
	bDiXiao = true, --����
	bZengYi = true, --����
	bJianYi = true, --����
	bSkillName = true,
},

--�ᶶ���ļ���
g_ShockSkill = { 
	[415]=true,--����
	[426]=true,--�Ƽ���
	[561]=true,--��������
	[564]=true,--�������
	[383]=true,--�����޽�
	[386]=true,--�����޽�
	[387]=true,--�����޽�
	[388]=true,--�����޽�
	[389]=true,--�����޽�
	[390]=true,--�����޽�
	[391]=true,--�����޽�
	[392]=true,--�����޽�
	[393]=true,--�����޽�
	[394]=true,--�����޽�
	[588]=true,--�˽���һ
	[317]=true,--���ǻ���
	[318]=true,--���ǻ���
	[319]=true,--���ǻ���
	[320]=true,--���ǻ���
	[321]=true,--���ǻ���
	[456]=true,--���ǻ���
	[457]=true,--���ǻ���
	[458]=true,--���ǻ���
	[459]=true,--���ǻ���
	[460]=true,--���ǻ���
	[305]=true,--��ת��һ
	[201]=true,--Τ������
	[202]=true,--Τ������
	[203]=true,--Τ������
	[265]=true,--����ʽ
	[266]=true,--����ʽ
	[267]=true,--����ʽ
	[179]=true,--����ָ
	[182]=true,--��ʯ���
	[7165]=true,--ս���Ա�����
};
				
g_bShock = false;

--�����ܵ��˺�(��������)1 
g_OtherCommonDamage = {{ X = {}, Y = {} }, { X = {}, Y = {} }, { X = {}, Y = {} }, { X = {}, Y = {} }, { X = {}, Y = {} }};
--�����ܵ��˺�������
g_OtherCommonDamageScale = {};
--��������
g_CriticalScale = { 1, 2, 3, 5, 5, 3, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1, 2.1 };
--�����ܵ��˺�(��������)1
g_SelfCommonDamage = { X = {}, Y = {} };
--���Ǳ�����2
g_SelfCriticalStrikeDamage = { X = {}, Y = {} };
--���˱�����3
g_OtherCriticalStrikeDamage =
{
	X = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	Y = {-2, -4, -6, -8, -10, -12, -14, -16, -18, -20, -22, -24, -26, -28, -30, -32, -33, -34, -35, -36, -37, -38, -39, -40, -41, -42, -43, -44, -45, -46, -47, -48, -49, -50, -51, -52, -53, -54, -55, -56, -57, -58, -59, -60, -61, -62, -63, -64, -65, -66, -67, -68, -69, -70, -71, -72, -73, -74, -75, -76, -77, -78, -79, -80}
};

--�����ܵ�����
g_Therapy ={ X = {}, Y = {} };

--�������ܵ�����
g_OtherTherapy={ X = {}, Y = {} };

--��������,
g_SelfDodge ={ X = {}, Y = {} };

--���Ǹ�
g_SelfBlock =
{
	X = {-1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, -13, -14, -15, -16, -17, -18, -19, -20, -21, -22, -23, -24, -25, -26, -27, -28, -29, -30, -31, -32, -33, -34, -35, -36, -37, -38, -39, -40, -41, -42, -43, -44, -45, -46, -47, -48, -49, -50, -51, -52, -53, -54, -55, -56, -57, -58, -59, -60, -61, -62, -63, -64},
	Y = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64}
};

--��������
g_SelfAbsorb =
{
	X = {-1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, -13, -14, -15, -16, -17, -18, -19, -20, -21, -22, -23, -24, -25, -26, -27, -28, -29, -30, -31, -32, -33, -34, -35, -36, -37, -38, -39, -40, -41, -42, -43, -44, -45, -46, -47, -48, -49, -50, -51, -52, -53, -54, -55, -56, -57, -58, -59, -60, -61, -62, -63, -64},
	Y = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64}
};

--�������������˺�
g_SelfShield =
{
	X = {-1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, -13, -14, -15, -16, -17, -18, -19, -20, -21, -22, -23, -24, -25, -26, -27, -28, -29, -30, -31, -32, -33, -34, -35, -36, -37, -38, -39, -40, -41, -42, -43, -44, -45, -46, -47, -48, -49, -50, -51, -52, -53, -54, -55, -56, -57, -58, -59, -60, -61, -62, -63, -64},
	Y = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64}
};

--�����м�
g_SelfParry =
{
	X = {-1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, -13, -14, -15, -16, -17, -18, -19, -20, -21, -22, -23, -24, -25, -26, -27, -28, -29, -30, -31, -32, -33, -34, -35, -36, -37, -38, -39, -40, -41, -42, -43, -44, -45, -46, -47, -48, -49, -50, -51, -52, -53, -54, -55, -56, -57, -58, -59, -60, -61, -62, -63, -64},
	Y = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64}
};
--����ʶ��
g_SelfInsight =
{
	X = {-1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, -13, -14, -15, -16, -17, -18, -19, -20, -21, -22, -23, -24, -25, -26, -27, -28, -29, -30, -31, -32, -33, -34, -35, -36, -37, -38, -39, -40, -41, -42, -43, -44, -45, -46, -47, -48, -49, -50, -51, -52, -53, -54, -55, -56, -57, -58, -59, -60, -61, -62, -63, -64},
	Y = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64}
};

-- ����δ����
g_SelfMiss = { X = {}, Y = {} };
--����������
g_OtherDodge = 
{
	X = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64},
	Y = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64}
};

--�����˸�
g_OtherBlock =
{
	X = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64},
	Y = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64}
};

--����������
g_OtherAbsorb =
{
	X = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64},
	Y = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64}
};

--���������������˺�
g_OtherShield =
{
	X = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64},
	Y = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64}
};

--�������м�
g_OtherParry =
{
	X = {-1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, -13, -14, -15, -16, -17, -18, -19, -20, -21, -22, -23, -24, -25, -26, -27, -28, -29, -30, -31, -32, -33, -34, -35, -36, -37, -38, -39, -40, -41, -42, -43, -44, -45, -46, -47, -48, -49, -50, -51, -52, -53, -54, -55, -56, -57, -58, -59, -60, -61, -62, -63, -64},
	Y = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64}
};
--������ʶ��
g_OtherInsight =
{
	X = {-1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, -13, -14, -15, -16, -17, -18, -19, -20, -21, -22, -23, -24, -25, -26, -27, -28, -29, -30, -31, -32, -33, -34, -35, -36, -37, -38, -39, -40, -41, -42, -43, -44, -45, -46, -47, -48, -49, -50, -51, -52, -53, -54, -55, -56, -57, -58, -59, -60, -61, -62, -63, -64},
	Y = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64}
};


-- ������δ����
g_OtherMiss =
{
	X = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64},
	Y = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64}
};

--BuffЧ����ʾ
g_BuffPrompt ={ X = {}, Y = {} };

-- Buff������ʾ
g_BuffImmunity = 
{
	X = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64},
	Y = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
};

--����������ʾ
g_SkillCastName = 
{
	X = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64},
	Y = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
};

g_BowledTip = 
{
	X = {}, Y = {}
};

g_BowledScale = {};

--����ֵ�켣
g_ExpLog = { X = {}, Y = {} };
--����ֵ����
g_ExpLogScale = {};

--͸����
g_ExpAlpha = {};

--��������
g_Stylish = { X = {}, Y = {} };
--��������
g_StylishScale = { 1, 1, 2, 3, 3, 4, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1};
--�˺���ɫ
g_color = { r = {}, g = {} ,b = {} };

--��ǰռ�ù켣ID
g_MaxTraceNumber = 32;										--������Ϣ�������������ֵҪ���ڵ��롢�����������������͵�����֮��
g_CurrentIndex = 1;
g_CurrentNumber = 5;
g_CurrentFlagTable = {false, false, false, false, false};

OnFrameCreate=function()   
	this:RegisterEvent("FIGHT_HINT")
    this:RegisterEvent("COMMON_HEALTH_TEXT")
    this:RegisterEvent("SKILL_EFFECT_TEXT")
    this:RegisterEvent("SKILL_MISS")
    this:RegisterEvent("SKILL_DODGE")
    this:RegisterEvent("SKILL_BLOCK")
    this:RegisterEvent("SKILL_BUFF")
    this:RegisterEvent("BUFF_IMMUNITY")
    this:RegisterEvent("DO_SKILL_CAST")
    this:RegisterEvent("SYS_MSG")
    this:RegisterEvent("PLAYER_LEAVE_SCENE")

    local handle = this:Lookup("", "");
    if handle then
       handle:Clear();
    end
    handle.nUseCount = 0
    
    CombatTextWnd.handle = handle
    CombatTextWnd.hFrame = this
	
	for i = 1, CombatTextWnd.g_MaxTraceNumber, 1 do
	    --�����ܵ��˺�(��������)1
		--����켣1
        if i <= CombatTextWnd.g_MaxTraceNumber * 0.2 then		
			CombatTextWnd.g_OtherCommonDamage[1]["X"][i] = 0
			CombatTextWnd.g_OtherCommonDamage[1]["Y"][i] = -30-1*i-0.5*0.5*i*i
		elseif i <= CombatTextWnd.g_MaxTraceNumber * 0.8 then
			CombatTextWnd.g_OtherCommonDamage[1]["X"][i] = 0
			CombatTextWnd.g_OtherCommonDamage[1]["Y"][i] = -30-0.2*CombatTextWnd.g_MaxTraceNumber-0.01*CombatTextWnd.g_MaxTraceNumber*CombatTextWnd.g_MaxTraceNumber-1*(i-0.2*CombatTextWnd.g_MaxTraceNumber)
		else
			CombatTextWnd.g_OtherCommonDamage[1]["X"][i] = 0
			CombatTextWnd.g_OtherCommonDamage[1]["Y"][i] = -30-0.2*CombatTextWnd.g_MaxTraceNumber-0.01*CombatTextWnd.g_MaxTraceNumber*CombatTextWnd.g_MaxTraceNumber-1*0.6*CombatTextWnd.g_MaxTraceNumber- 4*(i - CombatTextWnd.g_MaxTraceNumber * 0.8)
		end
		--����켣2
		if i <= CombatTextWnd.g_MaxTraceNumber * 0.2 then		
			CombatTextWnd.g_OtherCommonDamage[2]["X"][i] = 0
			CombatTextWnd.g_OtherCommonDamage[2]["Y"][i] = -15 -1*i-0.5*0.5*i*i
		elseif i <= CombatTextWnd.g_MaxTraceNumber * 0.8 then
			CombatTextWnd.g_OtherCommonDamage[2]["X"][i] = 0
			CombatTextWnd.g_OtherCommonDamage[2]["Y"][i] = -15 -0.2*CombatTextWnd.g_MaxTraceNumber-0.01*CombatTextWnd.g_MaxTraceNumber*CombatTextWnd.g_MaxTraceNumber-1*(i-0.2*CombatTextWnd.g_MaxTraceNumber)
		else
			CombatTextWnd.g_OtherCommonDamage[2]["X"][i] = 0
			CombatTextWnd.g_OtherCommonDamage[2]["Y"][i] = -15 -0.2*CombatTextWnd.g_MaxTraceNumber-0.01*CombatTextWnd.g_MaxTraceNumber*CombatTextWnd.g_MaxTraceNumber-1*0.6*CombatTextWnd.g_MaxTraceNumber- 4*(i - CombatTextWnd.g_MaxTraceNumber * 0.8)
		end
		--����켣3
		if i <= CombatTextWnd.g_MaxTraceNumber * 0.2 then		
			CombatTextWnd.g_OtherCommonDamage[3]["X"][i] = 0
			CombatTextWnd.g_OtherCommonDamage[3]["Y"][i] = 0 -1*i-0.5*0.5*i*i
		elseif i <= CombatTextWnd.g_MaxTraceNumber * 0.8 then
			CombatTextWnd.g_OtherCommonDamage[3]["X"][i] = 0
			CombatTextWnd.g_OtherCommonDamage[3]["Y"][i] = 0 -0.2*CombatTextWnd.g_MaxTraceNumber-0.01*CombatTextWnd.g_MaxTraceNumber*CombatTextWnd.g_MaxTraceNumber-1*(i-0.2*CombatTextWnd.g_MaxTraceNumber)
		else
			CombatTextWnd.g_OtherCommonDamage[3]["X"][i] = 0
			CombatTextWnd.g_OtherCommonDamage[3]["Y"][i] = 0 -0.2*CombatTextWnd.g_MaxTraceNumber-0.01*CombatTextWnd.g_MaxTraceNumber*CombatTextWnd.g_MaxTraceNumber-1*0.6*CombatTextWnd.g_MaxTraceNumber- 4*(i - CombatTextWnd.g_MaxTraceNumber * 0.8)
		end
		--����켣4
		if i <= CombatTextWnd.g_MaxTraceNumber * 0.2 then		
			CombatTextWnd.g_OtherCommonDamage[4]["X"][i] = 25
			CombatTextWnd.g_OtherCommonDamage[4]["Y"][i] = -30 -1*i-0.5*0.5*i*i
		elseif i <= CombatTextWnd.g_MaxTraceNumber * 0.8 then
			CombatTextWnd.g_OtherCommonDamage[4]["X"][i] = 25
			CombatTextWnd.g_OtherCommonDamage[4]["Y"][i] = -30 -0.2*CombatTextWnd.g_MaxTraceNumber-0.01*CombatTextWnd.g_MaxTraceNumber*CombatTextWnd.g_MaxTraceNumber-1*(i-0.2*CombatTextWnd.g_MaxTraceNumber)
		else
			CombatTextWnd.g_OtherCommonDamage[4]["X"][i] = 25
			CombatTextWnd.g_OtherCommonDamage[4]["Y"][i] = -30 -0.2*CombatTextWnd.g_MaxTraceNumber-0.01*CombatTextWnd.g_MaxTraceNumber*CombatTextWnd.g_MaxTraceNumber-1*0.6*CombatTextWnd.g_MaxTraceNumber- 4*(i - CombatTextWnd.g_MaxTraceNumber * 0.8)
		end
		--����켣5
		if i <= CombatTextWnd.g_MaxTraceNumber * 0.2 then		
			CombatTextWnd.g_OtherCommonDamage[5]["X"][i] = -25
			CombatTextWnd.g_OtherCommonDamage[5]["Y"][i] = -30 -1*i-0.5*0.5*i*i
		elseif i <= CombatTextWnd.g_MaxTraceNumber * 0.8 then
			CombatTextWnd.g_OtherCommonDamage[5]["X"][i] = -25
			CombatTextWnd.g_OtherCommonDamage[5]["Y"][i] = -30 -0.2*CombatTextWnd.g_MaxTraceNumber-0.01*CombatTextWnd.g_MaxTraceNumber*CombatTextWnd.g_MaxTraceNumber-1*(i-0.2*CombatTextWnd.g_MaxTraceNumber)
		else
			CombatTextWnd.g_OtherCommonDamage[5]["X"][i] = -25
			CombatTextWnd.g_OtherCommonDamage[5]["Y"][i] = -30 -0.2*CombatTextWnd.g_MaxTraceNumber-0.01*CombatTextWnd.g_MaxTraceNumber*CombatTextWnd.g_MaxTraceNumber-1*0.6*CombatTextWnd.g_MaxTraceNumber- 4*(i - CombatTextWnd.g_MaxTraceNumber * 0.8)
		end
		--�����ܵ��˺�������
		if i <= CombatTextWnd.g_MaxTraceNumber * 0.2 then		
			CombatTextWnd.g_OtherCommonDamageScale[i] = 1.5
		elseif i <= CombatTextWnd.g_MaxTraceNumber * 0.8 then
			CombatTextWnd.g_OtherCommonDamageScale[i] = 1.5
		else
			CombatTextWnd.g_OtherCommonDamageScale[i] = (1 - i / CombatTextWnd.g_MaxTraceNumber) * 1.5 * CombatTextWnd.g_MaxTraceNumber / ( CombatTextWnd.g_MaxTraceNumber - i )
		end
		--�����ܵ��˺�(��������)1
		if i <= CombatTextWnd.g_MaxTraceNumber * 0.4 then
			CombatTextWnd.g_SelfCommonDamage["X"][i] = -2 * i * i * 0.15 - 32
			CombatTextWnd.g_SelfCommonDamage["Y"][i] = i * i * 0.15+ 32
		elseif i <= CombatTextWnd.g_MaxTraceNumber * 0.75 then
			CombatTextWnd.g_SelfCommonDamage["X"][i] = -2 * CombatTextWnd.g_MaxTraceNumber * 0.4 * CombatTextWnd.g_MaxTraceNumber * 0.4 * 0.15 - 32
			CombatTextWnd.g_SelfCommonDamage["Y"][i] = CombatTextWnd.g_MaxTraceNumber * 0.4 * CombatTextWnd.g_MaxTraceNumber * 0.4 * 0.15 + 32
		else
			CombatTextWnd.g_SelfCommonDamage["X"][i] = -0.2 * (i - CombatTextWnd.g_MaxTraceNumber * 0.75) -2 * CombatTextWnd.g_MaxTraceNumber * 0.4 * CombatTextWnd.g_MaxTraceNumber * 0.4 * 0.15 - 32
			CombatTextWnd.g_SelfCommonDamage["Y"][i] = 0.2 * (i - CombatTextWnd.g_MaxTraceNumber * 0.75) + CombatTextWnd.g_MaxTraceNumber * 0.4 * CombatTextWnd.g_MaxTraceNumber * 0.4 * 0.15 + 32
		end
		--���Ǳ�����2
		if i <= CombatTextWnd.g_MaxTraceNumber * 0.4 then
			CombatTextWnd.g_SelfCriticalStrikeDamage["X"][i] = -2 * i - 16
			CombatTextWnd.g_SelfCriticalStrikeDamage["Y"][i] = i + 16
		elseif i <= CombatTextWnd.g_MaxTraceNumber * 0.75 then
			CombatTextWnd.g_SelfCriticalStrikeDamage["X"][i] = -2 * CombatTextWnd.g_MaxTraceNumber * 0.4 - 16
			CombatTextWnd.g_SelfCriticalStrikeDamage["Y"][i] = CombatTextWnd.g_MaxTraceNumber * 0.4 + 16
		else
			CombatTextWnd.g_SelfCriticalStrikeDamage["X"][i] = -0.2 * (i - CombatTextWnd.g_MaxTraceNumber * 0.75) -2 * CombatTextWnd.g_MaxTraceNumber * 0.4 - 16
			CombatTextWnd.g_SelfCriticalStrikeDamage["Y"][i] = 0.2 * (i - CombatTextWnd.g_MaxTraceNumber * 0.75) + CombatTextWnd.g_MaxTraceNumber * 0.4 + 16
		end
		-- ����δ����
		CombatTextWnd.g_SelfMiss["X"][i] = i + 8
		CombatTextWnd.g_SelfMiss["Y"][i] = 0.05 * i * i +16
		--��������
		CombatTextWnd.g_Stylish["X"][i] = 0
		CombatTextWnd.g_Stylish["Y"][i] = 0
		--�˺���ɫ
		CombatTextWnd.g_color["r"][i] = i / 48 * 255
		CombatTextWnd.g_color["g"][i] = 255 * ( 1 - i / 48 )
		CombatTextWnd.g_color["b"][i] = 255
		--���Ǳ�����
		if i <= CombatTextWnd.g_MaxTraceNumber * 0.4 then
			CombatTextWnd.g_Therapy["X"][i] = 2 * i + 32
			CombatTextWnd.g_Therapy["Y"][i] = i + 32
		elseif i <= CombatTextWnd.g_MaxTraceNumber * 0.75 then
			CombatTextWnd.g_Therapy["X"][i] = 2 * CombatTextWnd.g_MaxTraceNumber * 0.4 + 32
			CombatTextWnd.g_Therapy["Y"][i] = CombatTextWnd.g_MaxTraceNumber * 0.4 + 32
		else
			CombatTextWnd.g_Therapy["X"][i] = 0.2 * (i - CombatTextWnd.g_MaxTraceNumber * 0.75) + 2 * CombatTextWnd.g_MaxTraceNumber * 0.4 + 32
			CombatTextWnd.g_Therapy["Y"][i] = 0.2 * (i - CombatTextWnd.g_MaxTraceNumber * 0.75) + CombatTextWnd.g_MaxTraceNumber * 0.4 + 32
		end
		
		--�����˱�����
		if i <= CombatTextWnd.g_MaxTraceNumber * 0.2 then		
			CombatTextWnd.g_OtherTherapy["X"][i] = 0
			CombatTextWnd.g_OtherTherapy["Y"][i] = -30-1*i-0.5*0.5*i*i
		elseif i <= CombatTextWnd.g_MaxTraceNumber * 0.8 then
			CombatTextWnd.g_OtherTherapy["X"][i] = 0
			CombatTextWnd.g_OtherTherapy["Y"][i] = -30-0.2*CombatTextWnd.g_MaxTraceNumber-0.01*CombatTextWnd.g_MaxTraceNumber*CombatTextWnd.g_MaxTraceNumber-1*(i-0.2*CombatTextWnd.g_MaxTraceNumber)
		else
			CombatTextWnd.g_OtherTherapy["X"][i] = 0
			CombatTextWnd.g_OtherTherapy["Y"][i] = -30-0.2*CombatTextWnd.g_MaxTraceNumber-0.01*CombatTextWnd.g_MaxTraceNumber*CombatTextWnd.g_MaxTraceNumber-1*0.6*CombatTextWnd.g_MaxTraceNumber- 4*(i - CombatTextWnd.g_MaxTraceNumber * 0.8)
		end
	end
	
	--����ֵ���ֵĹ켣
	for i = 1, 64, 1 do
		if i <= CombatTextWnd.g_MaxTraceNumber * 0.6 then		
			CombatTextWnd.g_ExpLog["X"][i] = 0
			CombatTextWnd.g_ExpLog["Y"][i] = 0
		elseif i <= CombatTextWnd.g_MaxTraceNumber * 0.75  then
			CombatTextWnd.g_ExpLog["X"][i] = 0
			CombatTextWnd.g_ExpLog["Y"][i] = 0
		else
			CombatTextWnd.g_ExpLog["X"][i] = 0
			CombatTextWnd.g_ExpLog["Y"][i] = 0
		end
	end
	--����ֵ���ֵ�����
	for i = 1, 64, 1 do
		if i <= CombatTextWnd.g_MaxTraceNumber * 3/CombatTextWnd.g_MaxTraceNumber then		
			CombatTextWnd.g_ExpLogScale[i] = i
		elseif i <= CombatTextWnd.g_MaxTraceNumber * 5/CombatTextWnd.g_MaxTraceNumber  then
			CombatTextWnd.g_ExpLogScale[i] = 4.5
		elseif i <= CombatTextWnd.g_MaxTraceNumber * 6/CombatTextWnd.g_MaxTraceNumber  then
			CombatTextWnd.g_ExpLogScale[i] = 2.8
		else 
			CombatTextWnd.g_ExpLogScale[i] = 1.5
		end
	end 
	--����������
	for i = 1, 64, 1 do
		if i <= CombatTextWnd.g_MaxTraceNumber * 0.4 then		
			CombatTextWnd.g_SelfDodge["X"][i] = -2 * i * i * 0.15 - 32
			CombatTextWnd.g_SelfDodge["Y"][i] = 0
		elseif i <= CombatTextWnd.g_MaxTraceNumber * 0.75  then
			CombatTextWnd.g_SelfDodge["X"][i] = -2 * CombatTextWnd.g_MaxTraceNumber * 0.4 * CombatTextWnd.g_MaxTraceNumber * 0.4 * 0.15 - 32
			CombatTextWnd.g_SelfDodge["Y"][i] = 0
		else
			CombatTextWnd.g_SelfDodge["X"][i] = -0.2 * (i - CombatTextWnd.g_MaxTraceNumber * 0.75) -2 * CombatTextWnd.g_MaxTraceNumber * 0.4 * CombatTextWnd.g_MaxTraceNumber * 0.4 * 0.15 - 32
			CombatTextWnd.g_SelfDodge["Y"][i] = 0
		end
	end
	
	--����BUFF
	for i = 1, 64, 1 do
		if i <= CombatTextWnd.g_MaxTraceNumber * 0.4 then		
			CombatTextWnd.g_BuffPrompt["X"][i] = 2 * i * i * 0.15 + 32
			CombatTextWnd.g_BuffPrompt["Y"][i] = 0
		elseif i <= CombatTextWnd.g_MaxTraceNumber * 0.75  then
			CombatTextWnd.g_BuffPrompt["X"][i] = 2 * CombatTextWnd.g_MaxTraceNumber * 0.4 * CombatTextWnd.g_MaxTraceNumber * 0.4 * 0.15 + 32
			CombatTextWnd.g_BuffPrompt["Y"][i] = 0
		else
			CombatTextWnd.g_BuffPrompt["X"][i] = 0.2 * (i - CombatTextWnd.g_MaxTraceNumber * 0.75) + 2 * CombatTextWnd.g_MaxTraceNumber * 0.4 * CombatTextWnd.g_MaxTraceNumber * 0.4 * 0.15 + 32
			CombatTextWnd.g_BuffPrompt["Y"][i] = 0
		end
	end
	--����ֵ���ֵ�͸����
	for i = 1, 48, 1 do
		if i <= 8 then
			CombatTextWnd.g_ExpAlpha[i] = i / 8 * 255
		elseif i <= 40 then
			CombatTextWnd.g_ExpAlpha[i] = 255
		else
			CombatTextWnd.g_ExpAlpha[i] = ( 1- ( i - 40) / 8 ) * 255	
		end
	end
    
	for i = 1, 64, 1 do
		if i <= CombatTextWnd.g_MaxTraceNumber * 0.6 then		
			CombatTextWnd.g_BowledTip["X"][i] = 0
			CombatTextWnd.g_BowledTip["Y"][i] = -70
		elseif i <= CombatTextWnd.g_MaxTraceNumber * 0.75  then
			CombatTextWnd.g_BowledTip["X"][i] = 0
			CombatTextWnd.g_BowledTip["Y"][i] = -70
		else
			CombatTextWnd.g_BowledTip["X"][i] = 0
			CombatTextWnd.g_BowledTip["Y"][i] = -70
		end
	end
    
	for i = 1, 64, 1 do
	        if i <= CombatTextWnd.g_MaxTraceNumber * 3/CombatTextWnd.g_MaxTraceNumber then
	            CombatTextWnd.g_BowledScale[i] = i
	        elseif i <= CombatTextWnd.g_MaxTraceNumber * 8/CombatTextWnd.g_MaxTraceNumber  then
	            CombatTextWnd.g_BowledScale[i] = 2.8
	        elseif i <= CombatTextWnd.g_MaxTraceNumber * 9/CombatTextWnd.g_MaxTraceNumber then
	            CombatTextWnd.g_BowledScale[i] = 2.6
	        else
	            CombatTextWnd.g_BowledScale[i] = 1.5
	        end
	end 
end;

OnFrameBreathe=function()     
    local handle = CombatTextWnd.handle
    local nCount = #CombatTextWnd.m_tTextQueue
    for nIndex=nCount, 1, -1 do
		local bRemove = false
        local text = CombatTextWnd.m_tTextQueue[nIndex]
        if text:IsValid() then
            local nFrameCount = text.nFrameCount
			local nX = text.Track.X[nFrameCount % CombatTextWnd.g_MaxTraceNumber + 1]
			local nY = text.Track.Y[nFrameCount % CombatTextWnd.g_MaxTraceNumber + 1]
			if nX and nY then
				local nDeltaPosX = nX * 3	--�ֲ�����ϵX�ı���ϵ��
				local nDeltaPosY = nY * 3	--�ֲ�����ϵY�ı���ϵ��
				local fScale = text.fScale
				local dwOwner = text.dwOwner;
				
				if text.aScale and text.aScale[nFrameCount] then
					fScale = text.aScale[nFrameCount]
				end
				
				text.nFrameCount = nFrameCount + 2 --������ٶ�
				nFrameCount = nFrameCount + 2 --������ٶ�
				if nFrameCount >= CombatTextWnd.g_MaxTraceNumber and text:GetName() == "SkillOtherCommondDamage" then
					CombatTextWnd.g_CurrentIndex = 1--�Ѿ����ڿ��еĹ켣
					if text.nFlag < 4 then--�����Ƿ��б��ù켣�ȴ�
						if CombatTextWnd.g_CurrentFlagTable[4] then
							CombatTextWnd.OnDisplace(4, text.nFlag)
						elseif CombatTextWnd.g_CurrentFlagTable[5] then
							CombatTextWnd.OnDisplace(5, text.nFlag)
						else
							CombatTextWnd.g_CurrentFlagTable[text.nFlag] = false
						end
					else
						CombatTextWnd.g_CurrentFlagTable[text.nFlag] = false
					end
				end
				
				if nDeltaPosX and nDeltaPosY then
					local nOrgX, nOrgY
					if dwOwner == GetClientPlayer().dwID then
						nOrgX, nOrgY = text.xScreen, text.yScreen
					else
					    nOrgX, nOrgY = Scene_ScenePointToScreenPoint(text.x, text.y, text.z)
					    if not nOrgX then
					       Trace("UI: Scene_ScenePointToScreenPoint() failed !\n");
						   return;
					    end
					    nOrgX, nOrgY = Station.AdjustToOriginalPos(nOrgX, nOrgY)			
					end
					
					if fScale ~= text.fScale then
						text.fScale = fScale
						
					    text:SetFontScale(fScale)
					    text:AutoSize()
					end

					--����ÿ��任
					local nFrameNum = nFrameCount % CombatTextWnd.g_MaxTraceNumber + 1
					if text.bChangeColor then
						local nR, nG, nB = text:GetFontColor()
						local r = CombatTextWnd.g_color["r"][nFrameNum]
						local g = CombatTextWnd.g_color["g"][nFrameNum]
						local b = CombatTextWnd.g_color["b"][nFrameNum]
						if r ~= nR or g ~= nG or b ~= nB then
							text:SetFontColor(r, g, b)
						end
					end
					
				    local cxText, cyText = text:GetSize();	
					
				    nOrgX = nOrgX - cxText / 2;
				    nOrgY = nOrgY - cyText / 2;

				    -- �������ֵ���,���� 				
					local nNextPosX =  nOrgX + nDeltaPosX;
					local nNextPosY =  nOrgY + nDeltaPosY;
					
					if text:GetName() ~= "TextShow" then--�����ַ���λ�ý������ڽ���̶�λ��
						text:SetAbsPos(nNextPosX, nNextPosY);
					end
					
					local nFadeInFrame = COMBAT_TEXT_FADE_IN_FRAME
					local nHoldFrame = COMBAT_TEXT_HOLD_FRAME
					local nFadeOutFrame = COMBAT_TEXT_FADE_OUT_FRAME
					
					if text.Alpha then
						local alpha = text.Alpha[nFrameCount]
						if alpha then
							text:SetAlpha(alpha)
						else
							bRemove = true
						end
					else
						if nFrameCount < nFadeInFrame then
							text:SetAlpha(255 * nFrameCount / nFadeInFrame)
						elseif nFrameCount < nFadeInFrame + nHoldFrame then
							text:SetAlpha(255)
						elseif nFrameCount < nFadeInFrame + nHoldFrame + nFadeOutFrame then
							text:SetAlpha(255 * (1 - (nFrameCount - nFadeInFrame - nHoldFrame) / nFadeOutFrame))
						else
							bRemove = true
						end
					end
				else
					bRemove = true
				end
			else
				bRemove = true
			end 	
        end
        
        if bRemove then
			text.bFree = true
			text:Hide()
			handle.nUseCount = handle.nUseCount - 1
			table.remove(CombatTextWnd.m_tTextQueue, nIndex)
        end
    end
end;

OnEvent=function(event)
	if event == "FIGHT_HINT" then
		CombatTextWnd.OnFightHint(event)
    elseif event == "COMMON_HEALTH_TEXT" then
    	CombatTextWnd.OnCommonHealth(event)
    elseif event == "SKILL_EFFECT_TEXT" then
       CombatTextWnd.OnSkillEffect(event)
    elseif event == "SKILL_MISS" then
       CombatTextWnd.OnSkillMiss(event)
    elseif event == "SKILL_DODGE" then
    	CombatTextWnd.OnSkillDodge(event)
    elseif event == "SKILL_BLOCK" then
    	CombatTextWnd.OnSkillBlock(event)
    elseif event == "SKILL_BUFF" then
    	CombatTextWnd.OnSkillBuff(event)
    elseif event == "BUFF_IMMUNITY" then
    	CombatTextWnd.OnBuffImmunity(event)
    --elseif event == "DO_SKILL_CAST" then
    	--CombatTextWnd.OnSkillCast(event)
    elseif event == "SYS_MSG" then
		if arg0 == "UI_OME_EXP_LOG" then
	    	CombatTextWnd.OnExpLog(arg1, arg2)
		end
	elseif event == "PLAYER_LEAVE_SCENE" then
		local player = GetClientPlayer()
		if not player or arg0 == player.dwID then
		    local handle = this:Lookup("", "");
		    if handle then
		       handle:Clear()
		    end
		end
    end
end;

OnSelectTrace=function()
	local bUser = false
	local nIndexFlag = 1
	for nID = 1, CombatTextWnd.g_CurrentNumber, 1 do--Ѱ�ҿ��еĹ켣,û����ȡ��һ���켣
		if not CombatTextWnd.g_CurrentFlagTable[nID] then
			bUser = true
			nIndexFlag = nID
			break
		end
	end
	
	if not bUser then--δ�ҵ����й켣���滻ѭ��Index�Ĺ켣
		nIndexFlag = CombatTextWnd.g_CurrentIndex
		if CombatTextWnd.g_CurrentIndex >= CombatTextWnd.g_CurrentNumber then
			CombatTextWnd.g_CurrentIndex = 1
		else
			CombatTextWnd.g_CurrentIndex = CombatTextWnd.g_CurrentIndex + 1
		end

--		local handle = Station.Lookup("Lowest/CombatTextWnd", "")
--		local nCount = handle:GetItemCount() - 1
--		for nId = 0, nCount, 1 do
--			local textTemp = handle:Lookup(nId)
--			if textTemp:GetName() == "SkillOtherCommondDamage" and textTemp.nFlag == nIndexFlag then
--				handle:RemoveItem(nId)
--				break
--			end
--		end	    		
	end
	return nIndexFlag
end;

OnDisplace=function(nInitiative, nPassiveness)--1,2,3�Ź켣��4,5�Ź켣�滻
	local handle = Station.Lookup("Lowest/CombatTextWnd", "")
	local nCount = handle:GetItemCount() - 1
	for nId = 0, nCount, 1 do
		local text = handle:Lookup(nId)
		if text:GetName() == "SkillOtherCommondDamage" and text.nFlag == nInitiative then
			text.nFlag = nPassiveness
			text.Track = CombatTextWnd.g_OtherCommonDamage[nPassiveness]
			CombatTextWnd.g_CurrentFlagTable[nInitiative] = false--�ճ��켣���
		end
	end
end;

OnFightHint=function(event)
	local bFight = arg0
	
	if bFight then
		WorldMap.bInFight = true
		MiddleMap.bInFight = true
		OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.STR_MSG_ENTER_FIGHT)
	else
		WorldMap.bInFight = false
		MiddleMap.bInFight = false
		OutputMessage("MSG_ANNOUNCE_YELLOW", g_tStrings.STR_MSG_LEAVE_FIGHT)
	end
end;

GetFreeText=function(handle)
	local nItemCount = handle:GetItemCount()
	local nIndex
	if handle.nUseCount < nItemCount then
		local nEnd = nItemCount - 1
		for i=0, nEnd, 1 do
			local hItem = handle:Lookup(i)
			if hItem.bFree then
				--Output("find index:"..i)
				hItem.bFree = false
				handle.nUseCount = handle.nUseCount + 1
				return hItem
			end
		end
	else
		handle:AppendItemFromString("<text> w=550 h=100 halign=1 valign=1 multiline=1 </text>"); 

		local hItem = handle:Lookup(handle.nUseCount)
		hItem.bFree = false
		handle.nUseCount = handle.nUseCount + 1
		return hItem
	end
end;

OutputFreeTextInfo=function()
	Output("use/total:"..CombatTextWnd.handle.nUseCount.."/"..CombatTextWnd.handle:GetItemCount())
end;

m_tTextQueue = {};
NewText=function(dwCharacterID, szText, fScale, bChangeColor, szName)
    local x, y, z = Scene_GetCharacterTop(dwCharacterID)
    local xScreen, yScreen = Scene_ScenePointToScreenPoint(x, y, z)
    xScreen, yScreen = Station.AdjustToOriginalPos(xScreen, yScreen)
    local handle = CombatTextWnd.handle
    
    local text = CombatTextWnd.GetFreeText(handle)
    table.insert(CombatTextWnd.m_tTextQueue, text)
    
    text:Show()
    text:SetText(szText)
    text:SetName(szName)
    text:SetFontScheme(19) -- ����35��3
    text:SetFontScale(1.0)
    text:SetFontScale(fScale)
    text:AutoSize()
	
	text.aScale = nil
	text.Track = nil
	text.Alpha = nil
	text.nFlag  = nil
	
	if szName == "TextShow" then
		xScreen, yScreen = Station.GetClientSize()
		text:SetAbsPos(xScreen * 3 / 4, yScreen / 4)--�����ַ���λ�ý������ڽ���̶�λ��
	else
	    local cxText, cyText = text:GetSize()
	    text:SetAbsPos(xScreen - cxText / 2, yScreen - cyText / 2)
    end

    text:SetAlpha(0)
    text:Show()
    
	text.dwOwner = dwCharacterID
	text.nFrameCount = 1
	text.x = x
	text.y = y
	text.z = z
	text.xScreen = xScreen
	text.yScreen = yScreen
	text.fScale = fScale
	text.bChangeColor = bChangeColor
	
	return text
end;

OnCommonHealth=function(event)
	local dwTargetID = arg0;
	local nDeltaLife = arg1;
    
    if nDeltaLife < 0 then
        CombatTextWnd.OnSkillDamage(0, dwTargetID, false,  SKILL_RESULT_TYPE.PHYSICS_DAMAGE, -nDeltaLife);
    elseif nDeltaLife > 0 then
        CombatTextWnd.OnSkillTherapy(0, dwTargetID, nDeltaLife);
    end
end;

OnSkillEffect=function(event)
	local dwCasterID		= arg0
	local dwTargetID		= arg1
	local bCriticalStrike	= arg2
	local nType				= arg3
	local nValue			= arg4
	local dwSkillID			= arg5
	local dwSkillLevel		= arg6
    
	if nType == SKILL_RESULT_TYPE.PHYSICS_DAMAGE 
	or nType == SKILL_RESULT_TYPE.SOLAR_MAGIC_DAMAGE 
	or nType == SKILL_RESULT_TYPE.NEUTRAL_MAGIC_DAMAGE 
	or nType == SKILL_RESULT_TYPE.LUNAR_MAGIC_DAMAGE
	or nType == SKILL_RESULT_TYPE.POISON_DAMAGE
	--or nType == SKILL_RESULT_TYPE.EFFECTIVE_DAMAGE 
	then 
		CombatTextWnd.OnSkillDamage(dwCasterID, dwTargetID, bCriticalStrike, nType, nValue,dwSkillID,dwSkillLevel);
	elseif nType == SKILL_RESULT_TYPE.REFLECTIED_DAMAGE	then
		CombatTextWnd.OnSkillDamage(dwTargetID, dwCasterID, bCriticalStrike, nType, nValue,dwSkillID,dwSkillLevel);
	elseif nType == SKILL_RESULT_TYPE.THERAPY then
	--or nType == SKILL_RESULT_TYPE.EFFECTIVE_THERAPY
		CombatTextWnd.OnSkillTherapy(dwCasterID, dwTargetID, nValue,dwSkillID,dwSkillLevel);
		
	elseif nType == SKILL_RESULT_TYPE.STEAL_LIFE then
		CombatTextWnd.OnSkillStealLife(dwCasterID, dwTargetID, nValue,dwSkillID,dwSkillLevel);
		
	elseif nType == SKILL_RESULT_TYPE.ABSORB_DAMAGE then
		CombatTextWnd.OnSkillDamageAbsorb(dwTargetID, nValue,dwSkillID,dwSkillLevel);
	elseif nType == SKILL_RESULT_TYPE.SHIELD_DAMAGE then
		CombatTextWnd.OnSkillDamageShield(dwTargetID, nValue,dwSkillID,dwSkillLevel);
    elseif nType == SKILL_RESULT_TYPE.PARRY_DAMAGE then
        CombatTextWnd.OnSkillDamageParry(dwTargetID, nValue,dwSkillID,dwSkillLevel);
	elseif nType == SKILL_RESULT_TYPE.INSIGHT_DAMAGE then
        CombatTextWnd.OnSkillDamageInsight(dwTargetID, nValue,dwSkillID,dwSkillLevel);
	end
end;

GetSkillKindColor=function(nDamageType)--�˺�����������ɫ
	if nDamageType == SKILL_RESULT_TYPE.PHYSICS_DAMAGE then
		return 255, 255, 255
	elseif nDamageType == SKILL_RESULT_TYPE.SOLAR_MAGIC_DAMAGE then
		return 255, 128, 128
	elseif nDamageType == SKILL_RESULT_TYPE.NEUTRAL_MAGIC_DAMAGE then
		return 255, 255, 0
	elseif nDamageType == SKILL_RESULT_TYPE.LUNAR_MAGIC_DAMAGE then
		return 12, 242, 239
	elseif nDamageType == SKILL_RESULT_TYPE.POISON_DAMAGE	then
		return 128, 255, 128
	elseif nDamageType == SKILL_RESULT_TYPE.REFLECTIED_DAMAGE then
		return 255, 128, 128
	else
		return 255, 255, 255
	end
end;

IsClientCaster = function(dwCasterID)
    local dwClientPlayerID = GetClientPlayer().dwID
    local bClientCaster = dwClientPlayerID == dwCasterID
    local bClientPetCaster = false
    if not IsPlayer(dwCasterID) then
        local Npc = GetNpc(dwCasterID)
        if Npc then
            bClientPetCaster = dwClientPlayerID == Npc.dwEmployer
        end
    end
    
    if bClientCaster or bClientPetCaster then
        return true
    end
    
    return false
end;

IsClientTarget = function(dwTargetID)
    local dwClientPlayerID = GetClientPlayer().dwID
    local bClientTarget = dwClientPlayerID == dwTargetID
    local bClientPetTarget = false
    if not IsPlayer(dwTargetID) then
        local Npc = GetNpc(dwTargetID)
        if Npc then
            bClientPetTarget = dwClientPlayerID == Npc.dwEmployer
        end
    end
    
    if bClientTarget or bClientPetTarget then
        return true
    end
    
    return false
end;

OnSkillDamage=function(dwCasterID, dwTargetID, bCriticalStrikeFlag, nDamageType, nDamageValue,dwSkillID,dwSkillLevel)
	OnDamageEvent(dwTargetID, nDamageValue, bCriticalStrikeFlag)
	
	local bClientCaster = CombatTextWnd.IsClientCaster(dwCasterID)
	local bClientTarget = CombatTextWnd.IsClientTarget(dwTargetID)
   
	local r, g, b
	local scale = 1
	local szText = nil
	
	if bClientTarget and CombatTextWnd.OtherToMe.bShangHai then
		r, g, b = 225, 0, 0 
		szText = "-"..nDamageValue
	else
		r, g, b = CombatTextWnd.GetSkillKindColor(nDamageType)
		szText = tostring(nDamageValue)
	end
    local function CatSkillInfo(szTxt)
		local szSkillName = Table_GetSkillName(dwSkillID, 1) or ""
		local szResult = szTxt
		if bCriticalStrikeFlag then
			szResult = g_tStrings.STR_CS_NAME .. " " .. szResult
		end
		
		if szSkillName ~= "" then
			szResult = szSkillName .. g_tStrings.STR_COLON .. szResult;
		end
		return szResult
	end

	
    if bCriticalStrikeFlag then
	    if bClientTarget and CombatTextWnd.OtherToMe.bShangHai then 
		--[[
			if IsShock() and CombatTextWnd.g_ShockSkill[dwSkillID] then
				ShowFullScreenSFX("CriticalStrike")
			end
			]]
			if CombatTextWnd.OtherToMe.bSkillName then
				szText = CatSkillInfo(szText)
			end
			
			local text = CombatTextWnd.NewText(dwTargetID, szText, 1, false, "SkillDamage")
			text:SetFontColor(r, g, b)
			text.aScale = CombatTextWnd.g_CriticalScale

			text.Track = CombatTextWnd.g_SelfCommonDamage
		else
			if bClientCaster and CombatTextWnd.MeToOther.bShangHai then		
			--[[
				if IsShock() and CombatTextWnd.g_ShockSkill[dwSkillID] then
					ShowFullScreenSFX("CriticalStrike")
				end
				]]
				if CombatTextWnd.MeToOther.bSkillName then
					szText = CatSkillInfo(szText)
				end
				
				local text = CombatTextWnd.NewText(dwTargetID, szText, 1, false, "SkillDamage")

				text:SetFontColor(r, g, b)
				text.aScale = CombatTextWnd.g_CriticalScale

				text:SetName("SkillOtherCommondDamage")--�����ַ��켣����
				local nIndexFlag = CombatTextWnd.OnSelectTrace()
				text.nFlag = nIndexFlag
				text.Track = CombatTextWnd.g_OtherCommonDamage[nIndexFlag]--ѡ������켣
				CombatTextWnd.g_CurrentFlagTable[nIndexFlag] = true
			end
		end
	else
		if bClientTarget and CombatTextWnd.OtherToMe.bShangHai then
		--[[
			if IsShock() and CombatTextWnd.g_ShockSkill[dwSkillID] then
				ShowFullScreenSFX("CriticalStrike")
			end
			]]
			if CombatTextWnd.OtherToMe.bSkillName then
				szText = CatSkillInfo(szText)
			end
			
			local text = CombatTextWnd.NewText(dwTargetID, szText, 1, false, "SkillDamage")
			text:SetFontColor(r, g, b)
			text.aScale = CombatTextWnd.g_OtherCommonDamageScale

			text.Track = CombatTextWnd.g_SelfCommonDamage
		else
			if bClientCaster and CombatTextWnd.MeToOther.bShangHai then
			--[[			
				if IsShock() and CombatTextWnd.g_ShockSkill[dwSkillID] then
					ShowFullScreenSFX("CriticalStrike")
				end
					]]
				if CombatTextWnd.MeToOther.bSkillName then
					szText = CatSkillInfo(szText)
				end
				
				local text = CombatTextWnd.NewText(dwTargetID, szText, 1, false, "SkillDamage")
				text:SetFontColor(r, g, b)
				text.aScale = CombatTextWnd.g_OtherCommonDamageScale
	
				text:SetName("SkillOtherCommondDamage")--�����ַ��켣����
				local nIndexFlag = CombatTextWnd.OnSelectTrace()
				text.nFlag = nIndexFlag
				text.Track = CombatTextWnd.g_OtherCommonDamage[nIndexFlag]--ѡ������켣
				CombatTextWnd.g_CurrentFlagTable[nIndexFlag] = true
			end
		end
	end
end;

OnSkillTherapy=function(dwCasterID, dwTargetID, nDeltaLife)
	local bClientCaster = CombatTextWnd.IsClientCaster(dwCasterID)
	local bClientTarget = CombatTextWnd.IsClientTarget(dwTargetID)
	
	local szText = "+"..nDeltaLife
	if bClientTarget and CombatTextWnd.OtherToMe.bZhiLiao then
    	local text = CombatTextWnd.NewText(dwTargetID, szText, 1, false, "SkillTherapy")
		text.aScale = CombatTextWnd.g_OtherCommonDamageScale
		text:SetFontColor(0, 255, 0)
		text.Track = CombatTextWnd.g_Therapy
	else
		if (bClientCaster or dwCasterID == 0) and CombatTextWnd.MeToOther.bZhiLiao then
			local text = CombatTextWnd.NewText(dwTargetID, szText, 1, false, "SkillTherapy")
			text:SetFontColor(0, 255, 0)
			text.aScale = CombatTextWnd.g_OtherCommonDamageScale
			text:SetName("SkillOtherCommondDamage")--�����ַ��켣����

			local nIndexFlag = CombatTextWnd.OnSelectTrace()
			text.nFlag = nIndexFlag
			text.Track = CombatTextWnd.g_OtherCommonDamage[nIndexFlag]--ѡ������켣
			CombatTextWnd.g_CurrentFlagTable[nIndexFlag] = true
		end
	end
end;

OnSkillStealLife=function(dwCasterID, dwTargetID, nDeltaLife)
	local bClientCaster = CombatTextWnd.IsClientCaster(dwCasterID)
	local bClientTarget = CombatTextWnd.IsClientTarget(dwTargetID)
	
	local szText = "+"..nDeltaLife
	if bClientCaster and CombatTextWnd.OtherToMe.bZhiLiao then
    	local text = CombatTextWnd.NewText(dwCasterID, szText, 1, false, "SkillStealLife")
		text.aScale = CombatTextWnd.g_OtherCommonDamageScale
		text:SetFontColor(0, 255, 0)
		text.Track = CombatTextWnd.g_Therapy
	else
		if (bClientTarget or dwTargetID == 0) and CombatTextWnd.MeToOther.bZhiLiao then
			local text = CombatTextWnd.NewText(dwCasterID, szText, 1, false, "SkillStealLife")
			text:SetFontColor(0, 255, 0)
			text.aScale = CombatTextWnd.g_OtherCommonDamageScale
			text:SetName("SkillOtherCommondDamage")--�����ַ��켣����

			local nIndexFlag = CombatTextWnd.OnSelectTrace()
			text.nFlag = nIndexFlag
			text.Track = CombatTextWnd.g_OtherCommonDamage[nIndexFlag]--ѡ������켣
			CombatTextWnd.g_CurrentFlagTable[nIndexFlag] = true
		end
	end
end;

OnSkillMiss=function(event, nDamageValue)
    local dwCasterID = arg0
    local dwTargetID = arg1
    
    local bIsClientCaster = CombatTextWnd.IsClientCaster(dwCasterID)
	local bIsClientTarget = CombatTextWnd.IsClientTarget(dwTargetID)
    
	if bIsClientTarget and CombatTextWnd.OtherToMe.bQiTa and CombatTextWnd.OtherToMe.bPianLi then
	    local text = CombatTextWnd.NewText(dwTargetID, g_tStrings.STR_MSG_MISS, 1, false, "SkillMiss")	
	    
		text.Track = CombatTextWnd.g_SelfDodge
		text:SetFontColor(230, 230, 230)
    else
    	if bIsClientCaster and CombatTextWnd.MeToOther.bQiTa and CombatTextWnd.MeToOther.bPianLi then
		    local text = CombatTextWnd.NewText(dwTargetID, g_tStrings.STR_MSG_MISS, 1, false, "SkillMiss")	
		    
			text:SetName("SkillOtherCommondDamage")--�����ַ��켣����
			local nIndexFlag = CombatTextWnd.OnSelectTrace()
			text.nFlag = nIndexFlag
			text:SetFontColor(255, 255, 255)
			text.Track = CombatTextWnd.g_OtherCommonDamage[nIndexFlag]--ѡ������켣
			CombatTextWnd.g_CurrentFlagTable[nIndexFlag] = true
		end
	end
end;

OnSkillDodge=function(event, nDamageType)
    local dwCasterID = arg0
    local dwTargetID = arg1
    
    local bIsClientCaster = CombatTextWnd.IsClientCaster(dwCasterID)
	local bIsClientTarget = CombatTextWnd.IsClientTarget(dwTargetID)
    
	if bIsClientTarget and CombatTextWnd.OtherToMe.bQiTa and CombatTextWnd.OtherToMe.bDuoShan then
	    local text = CombatTextWnd.NewText(dwTargetID, g_tStrings.STR_MSG_DODGE, 1, false, "SkillDodge")
	    
		text.Track = CombatTextWnd.g_SelfDodge
		text:SetFontColor(216, 54, 4)
    else
    	if bIsClientCaster and CombatTextWnd.MeToOther.bQiTa and CombatTextWnd.MeToOther.bDuoShan then
		    local text = CombatTextWnd.NewText(dwTargetID, g_tStrings.STR_MSG_DODGE, 1, false, "SkillDodge")
		    
			text:SetName("SkillOtherCommondDamage")--�����ַ��켣����
			local nIndexFlag = CombatTextWnd.OnSelectTrace()
			text.nFlag = nIndexFlag
			text:SetFontColor(255, 255, 255)
			text.Track = CombatTextWnd.g_OtherCommonDamage[nIndexFlag]--ѡ������켣
			CombatTextWnd.g_CurrentFlagTable[nIndexFlag] = true
		end
	end
end;

OnSkillDamageAbsorb=function(dwCharacterID, nValue) --����
    local dwCasterID = arg0
    local dwTargetID = arg1
    local bIsClientCaster = CombatTextWnd.IsClientCaster(dwCasterID)
	local bIsClientTarget = CombatTextWnd.IsClientTarget(dwTargetID)

  	if bIsClientTarget and CombatTextWnd.OtherToMe.bQiTa and CombatTextWnd.OtherToMe.bHuaJie then
	    local text = CombatTextWnd.NewText(dwCharacterID, g_tStrings.STR_MSG_ABSORB, COMBAT_TEXT_ABSORB_SCALE, false, "SkillDamageAbsorb")
	  	text:SetFontColor(255, 255, 255)
	  	text:SetFontScale(1)
	    text:AutoSize()  

		text.Track = CombatTextWnd.g_SelfDodge
    else 
    	if bIsClientCaster and CombatTextWnd.MeToOther.bQiTa and CombatTextWnd.MeToOther.bHuaJie then
		    local text = CombatTextWnd.NewText(dwCharacterID, g_tStrings.STR_MSG_ABSORB, COMBAT_TEXT_ABSORB_SCALE, false, "SkillOtherCommondDamage")
		  	text:SetFontColor(255, 255, 255)
		  	text:SetFontScale(1)
		    text:AutoSize()  

			local nIndexFlag = CombatTextWnd.OnSelectTrace()
			text.nFlag = nIndexFlag
			
			text.Track = CombatTextWnd.g_OtherCommonDamage[nIndexFlag]--ѡ������켣
			CombatTextWnd.g_CurrentFlagTable[nIndexFlag] = true
		end
	end
end;

OnSkillDamageShield=function(dwCharacterID, nValue)
    local dwCasterID = arg0
    local dwTargetID = dwCharacterID
    
    local bIsClientCaster = CombatTextWnd.IsClientCaster(dwCasterID)
	local bIsClientTarget = CombatTextWnd.IsClientTarget(dwTargetID)
    
    if bIsClientTarget and CombatTextWnd.OtherToMe.bQiTa and CombatTextWnd.OtherToMe.bDiXiao then
	    local text = CombatTextWnd.NewText(dwCharacterID, g_tStrings.STR_MSG_ABSORB, COMBAT_TEXT_ABSORB_SCALE, false, "SkillDamageShield")
	  	text:SetFontColor(255, 255, 255)  
	  	
		text.Track = CombatTextWnd.g_SelfDodge
    else
    	if bIsClientCaster and CombatTextWnd.MeToOther.bQiTa and CombatTextWnd.MeToOther.bDiXiao then
		    local text = CombatTextWnd.NewText(dwCharacterID, g_tStrings.STR_MSG_ABSORB, COMBAT_TEXT_ABSORB_SCALE, false, "SkillOtherCommondDamage")
		  	text:SetFontColor(255, 255, 255)  
		  	
			local nIndexFlag = CombatTextWnd.OnSelectTrace()
			text.nFlag = nIndexFlag
			
			text.Track = CombatTextWnd.g_OtherCommonDamage[nIndexFlag]--ѡ������켣
			CombatTextWnd.g_CurrentFlagTable[nIndexFlag] = true
		end
	end
end;

OnSkillDamageParry=function(dwCharacterID, nValue)
    local dwCasterID = arg0
    local dwTargetID = arg1
    
    local bIsClientCaster = CombatTextWnd.IsClientCaster(dwCasterID)
	local bIsClientTarget = CombatTextWnd.IsClientTarget(dwTargetID)
    
    if bIsClientTarget and CombatTextWnd.OtherToMe.bQiTa and CombatTextWnd.OtherToMe.bChaiZhao then
	    local text = CombatTextWnd.NewText(dwCharacterID, g_tStrings.STR_MSG_COUNTERACT, COMBAT_TEXT_PARRY_SCALE, false, "SkillDamageParry")
	  	text:SetFontColor(210, 200, 58)  
	  	
		text.Track = CombatTextWnd.g_SelfDodge
    else
    	if bIsClientCaster and CombatTextWnd.MeToOther.bQiTa and CombatTextWnd.MeToOther.bChaiZhao then
		    local text = CombatTextWnd.NewText(dwCharacterID, g_tStrings.STR_MSG_COUNTERACT, COMBAT_TEXT_PARRY_SCALE, false, "SkillOtherCommondDamage")
		  	text:SetFontColor(255, 255, 255)
		  	
			local nIndexFlag = CombatTextWnd.OnSelectTrace()
			text.nFlag = nIndexFlag
			
			text.Track = CombatTextWnd.g_OtherCommonDamage[nIndexFlag]--ѡ������켣
			CombatTextWnd.g_CurrentFlagTable[nIndexFlag] = true
		end
	end
end;

OnSkillDamageInsight=function(dwCharacterID, nValue)
    local dwCasterID = arg0
    local dwTargetID = dwCharacterID
    
    local bIsClientCaster = CombatTextWnd.IsClientCaster(dwCasterID)
	local bIsClientTarget = CombatTextWnd.IsClientTarget(dwTargetID)

    if bIsClientTarget and CombatTextWnd.OtherToMe.bQiTa and CombatTextWnd.OtherToMe.bShiPo then
	    local text = CombatTextWnd.NewText(dwCharacterID, g_tStrings.STR_MSG_INSIGHT, COMBAT_TEXT_INSIGHT_SCALE, false, "SkillDamageInsight")
	  	text:SetFontColor(255, 255, 255)  
  	
		text.Track = CombatTextWnd.g_SelfInsight
    else
    	if bIsClientCaster and CombatTextWnd.MeToOther.bQiTa and CombatTextWnd.MeToOther.bShiPo then
		    local text = CombatTextWnd.NewText(dwCharacterID, g_tStrings.STR_MSG_INSIGHT, COMBAT_TEXT_INSIGHT_SCALE, false, "SkillOtherCommondDamage")
		  	text:SetFontColor(255, 255, 255)
		  	
		  	local nIndexFlag = CombatTextWnd.OnSelectTrace()
			text.nFlag = nIndexFlag
			
			text.Track = CombatTextWnd.g_OtherCommonDamage[nIndexFlag]--ѡ������켣
			CombatTextWnd.g_CurrentFlagTable[nIndexFlag] = true
		end
	end
end;

OnSkillBlock=function(event) --�񵲣�����Ч����
		--local dwCasterID = arg0
    --local dwTargetID = arg1
    --local bIsClientCaster = GetClientPlayer().dwID == dwCasterID
    --local bIsClientTarget = GetClientPlayer().dwID == dwTargetID

    --local text = CombatTextWnd.NewText(dwTargetID, g_tStrings.STR_MSG_DEFENCE, COMBAT_TEXT_BLOCK_SCALE, false, "SkillBlock")
  	--text:SetFontColor(210, 200, 58)  

    --if bIsClientTarget then
		--text.Track = CombatTextWnd.g_SelfDodge
    --else
    	--if bIsClientCaster then
			--text.Track = CombatTextWnd.g_OtherBlock
		--end
	--end
end;

OnSkillBuff=function(event)
	local dwCharacterID = arg0;
	local bCanCancel = arg1;
	local dwID = arg2;
	local dwLevel = arg3;
	
	if not CombatTextWnd.OtherToMe.bQiTa then
		return
	end
	
	if bCanCancel then
		if not CombatTextWnd.OtherToMe.bZengYi then
	  		return
	  	end
    else
    	if not CombatTextWnd.OtherToMe.bJianYi then
	  		return
	  	end  
	end
	
	if not Table_BuffIsVisible(dwID, dwLevel) then
		return
	end
	
	local szBuffName = Table_GetBuffName(dwID, dwLevel);
	local text = CombatTextWnd.NewText(dwCharacterID, szBuffName, 1, false, "SkillBuff")
	
	if bCanCancel then
		text:SetFontColor(255, 255, 0)
	else
		text:SetFontColor(255, 0, 0)
	end
	
	text.Track = CombatTextWnd.g_BuffPrompt

    text:SetFontScale(1)
    text:AutoSize()
end;

OnBuffImmunity=function(event)
  	local dwCharacterID = arg0;

    local text = CombatTextWnd.NewText(dwCharacterID, g_tStrings.STR_MSG_IMMUNITY, COMBAT_TEXT_IMMUNE_SCALE, false, "BuffImmunity")
  	text:SetFontColor(255, 255, 255)  

	text.Track = CombatTextWnd.g_SelfDodge
end;

OnSkillCast=function(event, dwCharacterID)
	local dwCharacterID = arg0;
	local dwSkillID = arg1;
	local dwSkillLevel = arg2;
	local szText = "";
	local bIsPlayer = IsPlayer(dwCharacterID)
	local bIsClientPlayer = CombatTextWnd.IsClientTarget(dwCharacterID)

	if not bIsClientPlayer then
		if Table_IsSkillCombatShow(dwSkillID, dwSkillLevel) then
			szText = Table_GetSkillName(dwSkillID, dwSkillLevel)
			local text = CombatTextWnd.NewText(dwCharacterID, szText, COMBAT_TEXT_IMMUNE_SCALE, false, "SkillCast")
  			text:SetFontColor(0, 128, 255)  
			text:SetFontScale(1)
			text.Track = CombatTextWnd.g_SkillCastName
		end
	end
end;

OnExpLog=function(dwCharacterID, nExp)
    local text = CombatTextWnd.NewText(dwCharacterID, g_tStrings.STR_COMBATMSG_EXP..nExp, 1, false, "Exp")
  	text:SetFontColor(211, 10, 199)
  	text.aScale = CombatTextWnd.g_ExpLogScale
	
	text.Track = CombatTextWnd.g_ExpLog                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
	text.Alpha = CombatTextWnd.g_ExpAlpha
end;

}

function OnDamageEvent(dwID, nDamage, bCriticalStrike)
	local arg0bak = arg0
	local arg1bak = arg1
	local arg2bak = arg2
	arg0 = dwID
	arg1 = nDamage
	arg2 = bCriticalStrike
	FireEvent("UI_ON_DAMAGE_EVENT")
	arg0 = arg0bak
	arg1 = arg1bak
	arg2 = arg2bak
end


RegisterCustomData("CombatTextWnd.MeToOther")
RegisterCustomData("CombatTextWnd.OtherToMe")
RegisterCustomData("CombatTextWnd.g_bShock")
RegisterCustomData("CombatTextWnd.g_bMerge")

function GetCombatMeToTargetSetting()
	return CombatTextWnd.MeToOther
end

function SetCombatMeToTargetSetting(t)
	CombatTextWnd.MeToOther = t
end

function GetCombatTargetToMeSetting()
	return CombatTextWnd.OtherToMe
end

function SetCombatTargetToMeSetting(t)
	CombatTextWnd.OtherToMe = t
end

function IsShock()
	return CombatTextWnd.g_bShock
end

function SetShock(bShock)
	CombatTextWnd.g_bShock = bShock
end

function IsMergeDamage()
	return CombatTextWnd.g_bMerge
end

function SetMergeDamage(bMerge)
	CombatTextWnd.g_bMerge = bMerge
	
	if bMerge then
		rlcmd("EnableMergeDamage 1")
	else 
		rlcmd("EnableMergeDamage 0")
	end
end


function OnCharacterHeadLog(dwCharacterID, szTip, szParam)
    local text = CombatTextWnd.NewText(dwCharacterID, szTip, 1, false, "Scores")
  	text:SetFontColor(0, 128, 199)
  	text.aScale = CombatTextWnd.g_ExpLogScale
	
	text.Track = CombatTextWnd.g_ExpLog                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
	text.Alpha = CombatTextWnd.g_ExpAlpha
end

function OnBowledCharacterHeadLog(dwCharacterID, szTip, nFont, tColor, bMultiLine)
    local text = CombatTextWnd.NewText(dwCharacterID, szTip, 1, false, "Bowled")
    text:SetFontScheme(nFont);
    if tColor then
        text:SetFontColor(tColor[1], tColor[2], tColor[3])
    end
    bMultiLine = bMultiLine or false
    text:SetMultiLine(bMultiLine)
    
    text.Track = CombatTextWnd.g_BowledTip
    text.aScale = CombatTextWnd.g_BowledScale
    text.Alpha = CombatTextWnd.g_ExpAlpha
end

local function OnLoadCustomData()
	if arg0 == "Role" then
		SetMergeDamage(CombatTextWnd.g_bMerge)
	end
end
RegisterEvent("CUSTOM_DATA_LOADED", OnLoadCustomData)