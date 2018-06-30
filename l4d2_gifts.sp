#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <colors>
#pragma newdecls required
#include <sdkhooks>

#define PLUGIN_VERSION "2.1"
#define PLUGIN_NAME "l4d2_gift"
#define PLUGIN_AUTHOR "Emilio3"
#define OLD_SPAWN true 
#define MDL_GIFT "models/items/l4d_gift.mdl"
#define MDL_GIFT_DOLL "models/props_unique/doll01.mdl"
#define MDL_GIFT_TEDDY "models/props_interiors/teddy_bear.mdl"
#define MDL_GIFT_BOOK "models/props_downtown/phone_book.mdl"
#define MDL_GIFT_ELEPHANT "models/props_fairgrounds/elephant.mdl"
#define MDL_GIFT_COCODRILE "models/props_fairgrounds/alligator.mdl"
#define MDL_GIFT_GIRAFA "models/props_fairgrounds/giraffe.mdl"
#define MDL_GIFT_SERPIENTE "models/props_fairgrounds/snake.mdl"
#define SND_REWARD "ui/pickup_guitarriff10.wav"
#define SND_GIFT_DROP "ui/gift_drop.wav"
#define TANK_SOUND "player/tank/voice/growl/tank_fail_02.wav"
#define SPITTER_SOUND "player/spitter/voice/idle/spitter_lurk_03.wav"
#define BOOMER_SOUND "player/boomer/vomit/attack/bv1.wav"
#define SMOKER_SOUND "player/smoker/voice/idle/smoker_spotprey_13.wav"
#define JOCKEY_SOUND "player/jockey/voice/idle/jockey_recognize20.wav"
#define CHARGER_SOUND "player/charger/voice/attack/charger_charge_02.wav"
#define HUNTER_SOUND "player/hunter/voice/attack/hunter_attackmix_01.wav"
#define WITCH_SOUND "npc/witch/voice/attack/female_distantscream2.wav"
#define BRIDE_SOUND "npc/witch/voice/attack/female_distantscream1.wav"
#define LASER_SOUND "player/laser_on.wav"
#define HEAL_SOUND "items/suitchargeok1.wav"
#define BLOOD_SOUND "ui/survival_medal.wav"
#define COPA_GIFT "achieved"
#define BREAK_GIFT "impact_paper"
#define FIREWORK_GIFT "mini_fireworks"
#define MODEL_GOLFCLUB_W "models/weapons/melee/w_golfclub.mdl"
#define MODEL_GOLFCLUB_V "models/weapons/melee/v_golfclub.mdl"
#define MODEL_KATANA_W "models/weapons/melee/w_katana.mdl"
#define MODEL_KATANA_V "models/weapons/melee/v_katana.mdl"
#define MODEL_KNIFE_W "models/w_models/weapons/w_knife_t.mdl"
#define MODEL_KNIFE_V "models/v_models/v_knife_t.mdl"
#define MODEL_MACHETE_W "models/weapons/melee/w_machete.mdl"
#define MODEL_MACHETE_V "models/weapons/melee/v_machete.mdl"
#define MODEL_RIOTSHIELD_W "models/weapons/melee/w_riotshield.mdl"
#define MODEL_RIOTSHIELD_V "models/weapons/melee/v_riotshield.mdl"
#define SPRITE_BEAM "materials/sprites/laserbeam.vmt"
#define SPRITE_HALO "materials/sprites/halo01.vmt"
#define BRIDE "models/infected/witch_bride.mdl"
#define WITCH "models/infected/witch.mdl"
#define COLOR_GREEN "0 255 0 255"
#define COLOR_RED "255 0 0 255"
#define COLOR_BLUE "0 0 255 255"
#define COLOR_CYAN "0 255 255 255"
#define COLOR_YELLOW "255 255 0 255"
#define COLOR_PINK "255 105 180 255"
#define COLOR_PURPLE "128 0 128 255"
#define COLOR_ORANGE "255 69 0 255"
#define COLOR_BLACK "0 0 0 255"
#define GIFT_TIME 0
#define GIFTS 1
#define GIFT_NORMAL 2
#define GIFT_SPECIAL 3
#define GIFT_POINTS 4
#define GIFT_STATS "l4dstats"
#define GIFT_CREATE_TABLE "\
CREATE TABLE IF NOT EXISTS `l4d2_gifts` (\
 `Steamid` varchar(32) NOT NULL DEFAULT '',\
 `Name` tinyblob NOT NULL,\
 `Time1` int(11) NOT NULL DEFAULT '0',\
 `Time2` int(11) NOT NULL DEFAULT '0',\
 `Gifts` int(11) NOT NULL DEFAULT '0',\
 `Gift_normal` int(11) NOT NULL DEFAULT '0',\
 `Gift_special` int(11) NOT NULL DEFAULT '0',\
 `Gift_points` int(11) NOT NULL DEFAULT '0',\
 PRIMARY KEY (`Steamid`)\
) ENGINE=MyISAM DEFAULT CHARSET=utf8;\
"

ConVar g_hGiftEnable, g_hGiftLife, g_hChance;

Handle sdkRevive = null, g_hGameConf = null;

int g_enable, g_giftchance, x, HP, g_iMeleeClassCount = 0, g_BeamSprite, g_HaloSprite, 
greenColor[4] = {192, 238, 39, 255}, redColor[4] = {255, 15, 15, 255}, orangeColor[4] = {255, 165, 0, 255},
ig_temp[MAXPLAYERS+1][16], ig_real[MAXPLAYERS+1][16];

float g_gifmaxlife, g_GifLife[2000], l4d2_healgift_radius = 50.0;

bool g_RoundEnd;

char g_sMeleeClass[16][32], sg_query1[640], sg_query2[640], sg_query3[640], sg_buf2[128];

Database gift_db;

static char name_weapon[][] = 
{
	"awp",
	"scout",
	"ak47",
	"m60",
	"spas",
	"grenade launcher",
	"rifle military",
	"smg",
	"smg silenced",
	"pumpshotgun",
	"shotgun chrome",
	"autoshotgun",
	"rifle hunting",
	"katana",
	"rifle desert",
	"knife",
	"golfclub",
	"machete",
	"riotshield",
	"mp5"
};

static char guns[][] = 
{
	{"sniper_awp"},
	{"sniper_scout"},
	{"rifle_ak47"},
	{"rifle_m60"},
	{"shotgun_spas"},
	{"grenade_launcher"},
	{"sniper_military"},
	{"smg"},
	{"smg_silenced"},
	{"pumpshotgun"},
	{"shotgun_chrome"},
	{"autoshotgun"},
	{"hunting_rifle"},
	{"katana"},
	{"rifle_desert"},
	{"knife"},
	{"golfclub"},
	{"machete"},
	{"riotshield"},
	{"smg_mp5"}
};

static char name_infected[][] = 
{
	{"bride", BRIDE},
	{"tank"},
	{"witch", WITCH},
	{"boomer"},
	{"jockey"},
	{"spitter"},
	{"smoker"},
	{"charger"}
};

enum L4D2GlowType
{
    L4D2Glow_None = 0,
    L4D2Glow_OnUse,
    L4D2Glow_OnLookAt,
    L4D2Glow_Constant
}

static const int aColor[][] =
{
    {41, 36, 33},
    {0, 255, 0},
    {255, 0, 0},
    {0, 0, 255},
    {255, 215, 0},
    {255, 255, 255},
    {0, 255, 255},
    {72, 209, 204},
    {0, 191, 255},
    {30, 144, 255},
    {255, 255, 0},
    {255, 105, 180},
    {128, 0, 128},
    {255, 69, 0}
};

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = "Gift with points, heal & weapons",
	version = PLUGIN_VERSION,
	url = "n/a"
}

public void OnPluginStart()
{
	CreateConVar("l4d2_gift__version", PLUGIN_VERSION, "Plugin version");
	g_hGiftEnable = CreateConVar("l4d2_gift_enabled", "1", "0:Off, 1:On, Toggle plugin on/of");
	g_hGiftLife = CreateConVar("l4d2_giftlife", "60.0", "How long the gift stay on ground (seconds)");
	g_hChance = CreateConVar("l4d2_gift_chance", "6", "Chance (%) of infected drop gift.");
	AutoExecConfig(true, PLUGIN_NAME);
	RegAdminCmd("sm_gift", CMD_Gift, ADMFLAG_CHEATS, "Create Gift");
	RegConsoleCmd("sm_gifts", ShowGifts);
	RegConsoleCmd("sm_gpoints", ShowPoints);
	RegAdminCmd("sm_gtables", CMD_CreateTables, ADMFLAG_CHEATS, "");
	HookEvent("round_start", Event_RoundStart);
	HookEvent("map_transition", Event_Save, EventHookMode_Post);
	HookEvent("finale_win", Event_Save, EventHookMode_Post);
	HookEvent("mission_lost", Event_Save, EventHookMode_Post);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
	HookEvent("lunge_pounce", Event_InfectedGrab, EventHookMode_Pre);
	HookEvent("choke_start", Event_InfectedGrab, EventHookMode_Pre);
	HookEvent("jockey_ride", Event_InfectedGrab, EventHookMode_Pre);
	HookEvent("charger_pummel_start", Event_InfectedGrab, EventHookMode_Pre);
	HookEvent("witch_spawn", Event_WitchSpawn, EventHookMode_Pre);
	LoadTranslations("l4d2_gift.phrases");	
	HookConVarChange(g_hGiftEnable, CVAR_Changed);
	UpdateCvar();
	g_hGameConf = LoadGameConfigFile("l4d2_gift");
	if (g_hGameConf == null) SetFailState("Couldn't find the offsets and signatures file. Please, check that it is installed correctly.");
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CTerrorPlayer_OnRevived");
	sdkRevive = EndPrepSDKCall();
	if(sdkRevive == null) SetFailState("Unable to find the \"CTerrorPlayer::OnRevived(void)\" signature, check the file version!");
	CreateTimer(60.0, GiftTimerPI, _, TIMER_REPEAT);
	gift_db = null;
}

native int TYSTATS_GetPoints(int client);

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	MarkNativeAsOptional("TYSTATS_GetPoints");
	return APLRes_Success;
}

public void OnConfigsExecuted()
{
	if (!gift_db)
	{
		if (SQL_CheckConfig(GIFT_STATS))
		{
			gift_db = SQL_Connect(GIFT_STATS, true, sg_buf2, sizeof(sg_buf2)-1);
			if (!gift_db)
			{
				LogError("%s", sg_buf2);
			}
		}
	}
}

public void GiftClean(int &client)
{
	ig_temp[client][GIFT_TIME] = 0;
	ig_temp[client][GIFTS] = 0;
	ig_temp[client][GIFT_NORMAL] = 0;
	ig_temp[client][GIFT_SPECIAL] = 0;
	ig_temp[client][GIFT_POINTS] = 0;	
	ig_real[client][GIFT_TIME] = 0;
	ig_real[client][GIFTS] = 0;
	ig_real[client][GIFT_NORMAL] = 0;
	ig_real[client][GIFT_SPECIAL] = 0;
	ig_real[client][GIFT_POINTS] = 0;	
}

public void GiftDBregisterUser(int &client)
{
	char sTeamID[24];
	if (gift_db)
	{
		sg_query1[0] = '\0';
		GetClientAuthId(client, AuthId_Steam2, sTeamID, sizeof(sTeamID)-1);
		Format(sg_query1, sizeof(sg_query1)-1
		 , "SELECT \
			Steamid, \
			Time1, \
			Gifts, \
			Gift_normal, \
			Gift_special, \
			Gift_points \			
			FROM `l4d2_gifts` WHERE `Steamid` = '%s'", sTeamID);
		DBResultSet hQuery = SQL_Query(gift_db, sg_query1);
		if (hQuery)
		{
			if (!SQL_FetchRow(hQuery))
			{
				sg_query1[0] = '\0';
				Format(sg_query1, sizeof(sg_query1)-1, "INSERT IGNORE INTO `l4d2_gifts` SET `Steamid` = '%s'", sTeamID);
				DBResultSet hQuery2 = SQL_Query(gift_db, sg_query1);
				if (hQuery2)
				{
					delete hQuery2;
				}
			}
			else
			{
				ig_real[client][GIFT_TIME] = SQL_FetchInt(hQuery, 1);
				ig_real[client][GIFTS] = SQL_FetchInt(hQuery, 2);
				ig_real[client][GIFT_NORMAL] = SQL_FetchInt(hQuery, 3);
				ig_real[client][GIFT_SPECIAL] = SQL_FetchInt(hQuery, 4);
				ig_real[client][GIFT_POINTS] = SQL_FetchInt(hQuery, 5);
				CreateTimer(6.0, TimerKnowGifts, client, TIMER_FLAG_NO_MAPCHANGE);				
			}
			delete hQuery;
		}
	}
}

public Action GiftDBTimerUserPost(Handle timer, any client)
{
	if (IsClientInGame(client))
	{
		GiftDBregisterUser(client);
	}

	return Plugin_Stop;
}

public void OnClientPostAdminCheck(int client)
{
	if (!IsFakeClient(client))
	{
		GiftClean(client);
		CreateTimer(0.5, GiftDBTimerUserPost, client, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action TimerKnowGifts(Handle timer, any client)
{
	if (!client || !IsClientInGame(client)) 
	{
		return Plugin_Stop;
	}
	if (IsFakeClient(client)) 
	{
		return Plugin_Stop;
	}
	CPrintToChat(client, "%t", "[UKS_Gift] %N Your Points Gifts: %d. Your Gifts: %d.", client, ig_real[client][GIFT_POINTS], ig_real[client][GIFTS]);
	CPrintToChat(client, "%t", "[UKS] Type !rank to see your stats");
	PrintHintText(client, "%t", "UKS_Coop.25");
	return Plugin_Stop;
}

public void OnClientDisconnect(int client)
{
	if (!IsFakeClient(client))
	{
		if (ig_temp[client][GIFTS])
		{
			if (gift_db)
			{
				char sTeamID[24];
				sg_query2[0] = '\0';
				GetClientAuthId(client, AuthId_Steam2, sTeamID, sizeof(sTeamID)-1);
				Format(sg_query2, sizeof(sg_query2)-1
				 , "UPDATE `l4d2_gifts` SET \
					Time1 = Time1 + %d, \
					Time2 = %d, \
					Gifts = Gifts + %d, \
					Gift_normal = Gift_normal + %d, \
					Gift_special = Gift_special + %d, \
					Gift_points = Gift_points + %d \					
					WHERE `Steamid` = '%s'"
				, ig_temp[client][GIFT_TIME]
				, GetTime()
				, ig_temp[client][GIFTS]
				, ig_temp[client][GIFT_NORMAL]
				, ig_temp[client][GIFT_SPECIAL]
				, ig_temp[client][GIFT_POINTS]				
				, sTeamID);
				DBResultSet hQuery = SQL_Query(gift_db, sg_query2);
				if (hQuery)
				{
					delete hQuery;
				}
			}
		}
		GiftClean(client);
	}
}

public void OnMapStart()
{	
	PrecacheSound(SND_REWARD, true);
	PrecacheSound(SND_GIFT_DROP, true);
	PrecacheSound(HEAL_SOUND, true);
	PrecacheSound(BLOOD_SOUND, true);
	PrecacheSound(TANK_SOUND, true);
	PrecacheSound(SPITTER_SOUND, true);
	PrecacheSound(BOOMER_SOUND, true);
	PrecacheSound(SMOKER_SOUND, true);
	PrecacheSound(JOCKEY_SOUND, true);	
	PrecacheSound(CHARGER_SOUND, true);
	PrecacheSound(HUNTER_SOUND, true);
	PrecacheSound(WITCH_SOUND, true);
	PrecacheSound(BRIDE_SOUND, true);
	PrecacheSound(LASER_SOUND, true);	
	PrecacheParticle(BREAK_GIFT);
	PrecacheParticle(FIREWORK_GIFT);
	PrecacheParticle(COPA_GIFT);
	PrecacheModel(MDL_GIFT);
	PrecacheModel(MDL_GIFT_TEDDY);
	PrecacheModel(MDL_GIFT_DOLL);
	PrecacheModel(MDL_GIFT_BOOK);	
	PrecacheModel(MDL_GIFT_ELEPHANT);	
	PrecacheModel(MDL_GIFT_COCODRILE);
	PrecacheModel(MDL_GIFT_GIRAFA);
	PrecacheModel(MDL_GIFT_SERPIENTE);	
	PrecacheModel(MODEL_GOLFCLUB_W, true);
	PrecacheModel(MODEL_GOLFCLUB_V, true);
	PrecacheModel(MODEL_KATANA_W, true);
	PrecacheModel(MODEL_KATANA_V, true);
	PrecacheModel(MODEL_KNIFE_W, true);
	PrecacheModel(MODEL_KNIFE_V, true);
	PrecacheModel(MODEL_MACHETE_W, true);
	PrecacheModel(MODEL_MACHETE_V, true);
	PrecacheModel(MODEL_RIOTSHIELD_W, true);
	PrecacheModel(MODEL_RIOTSHIELD_V, true);
	PrecacheModel(BRIDE, true);		
	g_BeamSprite = PrecacheModel(SPRITE_BEAM);
	g_HaloSprite = PrecacheModel(SPRITE_HALO);
	Precached_weapons();
}

public void CVAR_Changed(ConVar convar, const char[] oldValue, const char[] newValue)
{
	UpdateCvar();
}

int UpdateCvar()
{
	g_enable = g_hGiftEnable.IntValue;
	g_giftchance = g_hChance.IntValue;
	g_gifmaxlife = g_hGiftLife.FloatValue;
}

int Precached_weapons()
{
	if (!IsModelPrecached("models/v_models/v_snip_awp.mdl"))
		PrecacheModel("models/v_models/v_snip_awp.mdl");
	if (!IsModelPrecached("models/v_models/v_snip_scout.mdl"))
		PrecacheModel("models/v_models/v_snip_scout.mdl");
	if (!IsModelPrecached("models/w_models/weapons/w_sniper_scout.mdl"))
		PrecacheModel("models/w_models/weapons/w_sniper_scout.mdl");
	if (!IsModelPrecached("models/w_models/weapons/w_sniper_awp.mdl"))
		PrecacheModel("models/w_models/weapons/w_sniper_awp.mdl");
	if (!IsModelPrecached("models/w_models/weapons/w_m60.mdl"))
		PrecacheModel("models/w_models/weapons/w_m60.mdl");
	if (!IsModelPrecached("models/w_models/weapons/w_smg_mp5.mdl"))
		PrecacheModel("models/w_models/weapons/w_smg_mp5.mdl");
	if (!IsModelPrecached("models/w_models/weapons/w_rifle_sg552.mdl"))
		PrecacheModel("models/w_models/weapons/w_rifle_sg552.mdl");	
}
 
int PrecacheParticle(char[] particlename)
{
	int ent = CreateEntityByName("info_particle_system");
	if (IsValidEntity(ent))
	{
		DispatchKeyValue(ent, "effect_name", particlename);
		DispatchSpawn(ent);
		ActivateEntity(ent);
		AcceptEntityInput(ent, "start");
		CreateTimer(0.01, Timer_DeleteEntity, EntIndexToEntRef(ent), TIMER_FLAG_NO_MAPCHANGE);
	} 
}

public Action Timer_DeleteEntity(Handle timer, any data)
{
	int ent = EntRefToEntIndex(data);
	if (IsValidEntity(ent))
	{
		char classname[32];
		GetEdictClassname(ent, classname, sizeof(classname));
		if (StrEqual(classname, "info_particle_system", false) || StrEqual(classname, "info_particle_target", false))
		{
			AcceptEntityInput(ent, "stop");
			AcceptEntityInput(ent, "kill");
			RemoveEdict(ent);
		}
		else
		{
			AcceptEntityInput(ent, "kill");
		}
	}
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_enable) return;
	g_RoundEnd = false;
}

public Action Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_enable) return;
	g_RoundEnd = true;
}

public Action Event_InfectedGrab(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_enable) return;	
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_enable) return;
	int victim = GetClientOfUserId(event.GetInt("userid"));
	if (IsValidClient(victim) && GetClientTeam(victim) == 3)
	{
		if (GetRandomInt(1, 100) < g_giftchance)
		{
			DropGift(victim);     
		}
	}
}

public Action Event_WitchSpawn(Event event, const char[] sName, bool dontBroadcast)
{
	switch(GetRandomInt(1, 2))
	{
		case 1:
		{
			int iWitch = event.GetInt("witchid");
			SetEntityModel(iWitch, BRIDE), SetEntityRenderMode(iWitch, RENDER_TRANSCOLOR), SetEntityRenderColor(iWitch, 255, 0, 0, 255), L4D2_SetEntGlow(iWitch, L4D2Glow_Constant, aColor[2]);
		}
	}
}

public void Event_Save(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_enable) return;
	int client = GetClientOfUserId(event.GetInt("userid"));
	{
		if (IsValidClient(client) && GetClientTeam(client) == 2)
		{
		    SaveGifts(client);	
		}
	}
}

public void SaveGifts(int client)
{
	char sName[32], sTeamID[24];
	if (IsClientInGame(client))
	{
		if (!IsFakeClient(client))
		{
			if (gift_db)
			{
				sName[0] = '\0';
				sg_query3[0] = '\0';
				GetClientName(client, sName, sizeof(sName)-8);
				GetClientAuthId(client, AuthId_Steam2, sTeamID, sizeof(sTeamID)-1);
				GiftProtect(sName);
				Format(sg_query3, sizeof(sg_query3)-1
				 , "UPDATE `l4d2_gifts` SET \
					Name = '%s', \
					Time1 = Time1 + %d, \
					Time2 = %d, \
					Gift = Gift + %d, \
					Gift_normal = Gift_normal + %d, \
					Gift_special = Gift_special + %d \
					Gift_points = Gift_points + %d \						
					WHERE `Steamid` = '%s'"
				, sName
				, ig_temp[client][GIFT_TIME]
				, GetTime()
				, ig_temp[client][GIFTS]
				, ig_temp[client][GIFT_NORMAL]
				, ig_temp[client][GIFT_SPECIAL]
				, ig_temp[client][GIFT_POINTS]						
				, sTeamID);
				DBResultSet hQuery = SQL_Query(gift_db, sg_query3);
				if (hQuery)
				{
				    delete hQuery;
				}
			}
		}
	}
	if (gift_db)
	{
		delete gift_db;
	}
}

public Action Timer_GiftLife(Handle timer, any index)
{	
	int gift = EntRefToEntIndex(index);
	char sTeamID[24];
	if (IsValidEntity(gift))
	{
		g_GifLife[gift] += 0.1;
		if(g_RoundEnd || g_GifLife[gift] > g_gifmaxlife)
		{
			g_GifLife[gift] = 0.0;
			AcceptEntityInput(gift, "kill");
			for(int i = 1; i<=MaxClients; i++)
			StopSound(i, SNDCHAN_VOICE, SND_GIFT_DROP);
			return Plugin_Stop;
		}
		RotateAdvance(gift, 15.0, 1);
		float myPos[3], gfPos[3];
		GetEntPropVector(gift, Prop_Send, "m_vecOrigin", gfPos);
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && IsPlayerAlive(i) && !IsFakeClient(i) && GetClientTeam(i) == 2 && IsClientInGame(i) && GetClientButtons(i) & IN_USE)
			{	
				int i_Buttons = GetClientButtons(i);
				if(i_Buttons & IN_USE)
				{				
					GetEntPropVector(i, Prop_Send, "m_vecOrigin", myPos);
					if (GetVectorDistance(myPos, gfPos) < 70.0)
					{ 
						if(points(i)) (health(i)) (weapons(i));
						{
					        i_Buttons = IN_USE;
					        AcceptEntityInput(gift, "kill");						
					        StopSound(i, SNDCHAN_VOICE, SND_GIFT_DROP);
					        CreateParticle(gift, BREAK_GIFT, 0.01);
					        CreateParticle(gift, FIREWORK_GIFT, 0.02);
					        CreateParticle(gift, COPA_GIFT, 0.02);
					        AcceptEntityInput(gift, "kill");
					        GetClientAuthId(i, AuthId_Steam2, sTeamID, sizeof(sTeamID)-1);
					        ig_temp[i][GIFTS] += 1;
					        ig_temp[i][GIFT_SPECIAL] += 1;
					        ig_temp[i][GIFT_POINTS] += x;													
					        break;						
						}								
					}						
				}
			}
		}
		return Plugin_Continue;
	}
	return Plugin_Stop;
} 

public Action Timer_GiftLife1(Handle timer, any index)
{	
	int gift = EntRefToEntIndex(index);
	char sTeamID[24];
	if (IsValidEntity(gift))
	{
		g_GifLife[gift] += 0.1;
		if(g_RoundEnd || g_GifLife[gift] > g_gifmaxlife)
		{
			g_GifLife[gift] = 0.0;
			AcceptEntityInput(gift, "kill");
			for(int i = 1; i<=MaxClients; i++)
			StopSound(i, SNDCHAN_VOICE, SND_GIFT_DROP);
			return Plugin_Stop;
		}
		float myPos[3], gfPos[3];
		GetEntPropVector(gift, Prop_Send, "m_vecOrigin", gfPos);
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && IsPlayerAlive(i) && !IsFakeClient(i) && GetClientTeam(i) == 2 && IsClientInGame(i) && GetClientButtons(i) & IN_USE)
			{	
				int i_Buttons = GetClientButtons(i);
				if(i_Buttons & IN_USE)
				{				
					GetEntPropVector(i, Prop_Send, "m_vecOrigin", myPos);
					if (GetVectorDistance(myPos, gfPos) < 70.0)
					{ 
						if(points(i)) (health(i)) (weapons(i));
						{
					        i_Buttons = IN_USE;
					        AcceptEntityInput(gift, "kill");							
					        StopSound(i, SNDCHAN_VOICE, SND_GIFT_DROP);
					        CreateParticle(gift, BREAK_GIFT, 0.01);
					        CreateParticle(gift, FIREWORK_GIFT, 0.02);
					        CreateParticle(gift, COPA_GIFT, 0.02);
					        AcceptEntityInput(gift, "kill");
					        GetClientAuthId(i, AuthId_Steam2, sTeamID, sizeof(sTeamID)-1);
					        ig_temp[i][GIFTS] += 1;
					        ig_temp[i][GIFT_NORMAL] += 1;
					        ig_temp[i][GIFT_POINTS] += x;									
					        break;
						}								
					}						
				}
			}
		}
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

public int GiftProtect(char[] sBuf)
{
	int i = 0;
	while (sBuf[i] != '\0')
	{
		if (sBuf[i] > 32)
		{
			if (sBuf[i] < 48)
			{
				sBuf[i] = ' ';
			}
		}
		if (sBuf[i] > 57)
		{
			if (sBuf[i] < 65)
			{
				sBuf[i] = ' ';
			}
		}
		if (sBuf[i] > 90)
		{
			if (sBuf[i] < 97)
			{
				sBuf[i] = ' ';
			}
		}
		i += 1;
	}
	return i;
} 

public Action Timer_SetRenderGlow(Handle timer, any index) 
{
	int gift = EntRefToEntIndex(index);
	if (IsValidEntity(gift))  	
	{ 
		SetEntityRenderMode(gift, RENDER_TRANSTEXTURE); 
		SetEntityRenderFx(gift, RENDERFX_PULSE_FAST_WIDER);
		switch (GetRandomInt(1, 13))
		{ 
			case 1: L4D2_SetEntGlow(gift, L4D2Glow_Constant, aColor[1]);
			case 2: L4D2_SetEntGlow(gift, L4D2Glow_Constant, aColor[2]);
			case 3: L4D2_SetEntGlow(gift, L4D2Glow_Constant, aColor[3]);
			case 4: L4D2_SetEntGlow(gift, L4D2Glow_Constant, aColor[4]);
			case 5: L4D2_SetEntGlow(gift, L4D2Glow_Constant, aColor[5]);
			case 6: L4D2_SetEntGlow(gift, L4D2Glow_Constant, aColor[6]);
			case 7: L4D2_SetEntGlow(gift, L4D2Glow_Constant, aColor[7]);
			case 8: L4D2_SetEntGlow(gift, L4D2Glow_Constant, aColor[8]);
			case 9: L4D2_SetEntGlow(gift, L4D2Glow_Constant, aColor[9]);
			case 10: L4D2_SetEntGlow(gift, L4D2Glow_Constant, aColor[10]);
			case 11: L4D2_SetEntGlow(gift, L4D2Glow_Constant, aColor[11]);
			case 12: L4D2_SetEntGlow(gift, L4D2Glow_Constant, aColor[12]);
			case 13: L4D2_SetEntGlow(gift, L4D2Glow_Constant, aColor[13]);
		}
		for (int i = 1; i <= MaxClients; i++)
		EmitSoundToAll(SND_GIFT_DROP, i, SNDCHAN_VOICE); 
     } 
} 

int DropGift(int client)
{
	float gifPos[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", gifPos);
	gifPos[2] += 10.0;
	int gift;
	switch (GetRandomInt(1, 2))
	{
	    case 1: 
		{
			gift = CreateEntityByName("prop_physics_override");
			if(gift != -1)
			{
		        DispatchKeyValue(gift, "model", MDL_GIFT);
		        switch (GetRandomInt(1, 9))
		        { 
			        case 1: DispatchKeyValue(gift, "rendercolor", COLOR_CYAN);
			        case 2: DispatchKeyValue(gift, "rendercolor", COLOR_GREEN);				
			        case 3: DispatchKeyValue(gift, "rendercolor", COLOR_PURPLE);					
			        case 4: DispatchKeyValue(gift, "rendercolor", COLOR_PINK);					
			        case 5: DispatchKeyValue(gift, "rendercolor", COLOR_RED);					
			        case 6: DispatchKeyValue(gift, "rendercolor", COLOR_ORANGE);				
			        case 7: DispatchKeyValue(gift, "rendercolor", COLOR_YELLOW);
			        case 8: DispatchKeyValue(gift, "rendercolor", COLOR_BLUE);
					case 9: DispatchKeyValue(gift, "rendercolor", COLOR_BLACK);
		        }
			}
			DispatchKeyValueVector(gift, "origin", gifPos);
			SetEntPropFloat(gift, Prop_Send,"m_flModelScale", 1.0);
			DispatchSpawn(gift);
			g_GifLife[gift] = 0.0;
			CreateTimer(0.1, Timer_GiftLife1, EntIndexToEntRef(gift), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(1.0, Timer_SetRenderGlow, EntIndexToEntRef(gift), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);		
	    }
	    case 2:
		{
			gift = CreateEntityByName("prop_dynamic_override");
			if(gift != -1)
			{
		        switch (GetRandomInt(1, 7))
		        { 
			        case 1: 
			        {
			            if(DispatchKeyValue(gift, "model", MDL_GIFT_ELEPHANT))
			            {
			                switch (GetRandomInt(1, 9))
			                {
			                    case 1: DispatchKeyValue(gift, "rendercolor", COLOR_CYAN);
			                    case 2: DispatchKeyValue(gift, "rendercolor", COLOR_GREEN);				
			                    case 3: DispatchKeyValue(gift, "rendercolor", COLOR_PURPLE);					
			                    case 4: DispatchKeyValue(gift, "rendercolor", COLOR_PINK);					
			                    case 5: DispatchKeyValue(gift, "rendercolor", COLOR_RED);					
			                    case 6: DispatchKeyValue(gift, "rendercolor", COLOR_ORANGE);				
			                    case 7: DispatchKeyValue(gift, "rendercolor", COLOR_YELLOW);
			                    case 8: DispatchKeyValue(gift, "rendercolor", COLOR_BLUE);
								case 9: DispatchKeyValue(gift, "rendercolor", COLOR_BLACK);
			                }
			            }
			        }							
			        case 2: 
			        {
			            if(DispatchKeyValue(gift, "model", MDL_GIFT_COCODRILE))
			            {
			                switch (GetRandomInt(1, 9))
			                {
			                    case 1: DispatchKeyValue(gift, "rendercolor", COLOR_CYAN);
			                    case 2: DispatchKeyValue(gift, "rendercolor", COLOR_GREEN);				
			                    case 3: DispatchKeyValue(gift, "rendercolor", COLOR_PURPLE);					
			                    case 4: DispatchKeyValue(gift, "rendercolor", COLOR_PINK);					
			                    case 5: DispatchKeyValue(gift, "rendercolor", COLOR_RED);					
			                    case 6: DispatchKeyValue(gift, "rendercolor", COLOR_ORANGE);				
			                    case 7: DispatchKeyValue(gift, "rendercolor", COLOR_YELLOW);
			                    case 8: DispatchKeyValue(gift, "rendercolor", COLOR_BLUE);
								case 9: DispatchKeyValue(gift, "rendercolor", COLOR_BLACK);
			                }
			            }
			        }		
			        case 3: 
			        {
			            if(DispatchKeyValue(gift, "model", MDL_GIFT_GIRAFA))
			            {
			                switch (GetRandomInt(1, 9))
			                {
			                    case 1: DispatchKeyValue(gift, "rendercolor", COLOR_CYAN);
			                    case 2: DispatchKeyValue(gift, "rendercolor", COLOR_GREEN);				
			                    case 3: DispatchKeyValue(gift, "rendercolor", COLOR_PURPLE);					
			                    case 4: DispatchKeyValue(gift, "rendercolor", COLOR_PINK);					
			                    case 5: DispatchKeyValue(gift, "rendercolor", COLOR_RED);					
			                    case 6: DispatchKeyValue(gift, "rendercolor", COLOR_ORANGE);				
			                    case 7: DispatchKeyValue(gift, "rendercolor", COLOR_YELLOW);
			                    case 8: DispatchKeyValue(gift, "rendercolor", COLOR_BLUE);
								case 9: DispatchKeyValue(gift, "rendercolor", COLOR_BLACK);
			                }
			            }
			        }	
			        case 4: 
			        {
			            if(DispatchKeyValue(gift, "model", MDL_GIFT_SERPIENTE))
			            {
			                switch (GetRandomInt(1, 9))
			                {
			                    case 1: DispatchKeyValue(gift, "rendercolor", COLOR_CYAN);
			                    case 2: DispatchKeyValue(gift, "rendercolor", COLOR_GREEN);				
			                    case 3: DispatchKeyValue(gift, "rendercolor", COLOR_PURPLE);					
			                    case 4: DispatchKeyValue(gift, "rendercolor", COLOR_PINK);					
			                    case 5: DispatchKeyValue(gift, "rendercolor", COLOR_RED);					
			                    case 6: DispatchKeyValue(gift, "rendercolor", COLOR_ORANGE);				
			                    case 7: DispatchKeyValue(gift, "rendercolor", COLOR_YELLOW);
			                    case 8: DispatchKeyValue(gift, "rendercolor", COLOR_BLUE);
								case 9: DispatchKeyValue(gift, "rendercolor", COLOR_BLACK);
			                }
			            }							
			        }	
			        case 5: 
			        {
			            if(DispatchKeyValue(gift, "model", MDL_GIFT_TEDDY))
			            {
			                switch (GetRandomInt(1, 9))
			                {
			                    case 1: DispatchKeyValue(gift, "rendercolor", COLOR_CYAN);
			                    case 2: DispatchKeyValue(gift, "rendercolor", COLOR_GREEN);				
			                    case 3: DispatchKeyValue(gift, "rendercolor", COLOR_PURPLE);					
			                    case 4: DispatchKeyValue(gift, "rendercolor", COLOR_PINK);					
			                    case 5: DispatchKeyValue(gift, "rendercolor", COLOR_RED);					
			                    case 6: DispatchKeyValue(gift, "rendercolor", COLOR_ORANGE);				
			                    case 7: DispatchKeyValue(gift, "rendercolor", COLOR_YELLOW);
			                    case 8: DispatchKeyValue(gift, "rendercolor", COLOR_BLUE);
								case 9: DispatchKeyValue(gift, "rendercolor", COLOR_BLACK);
			                }
			            }							
			        }	
			        case 6: 
			        {
			            if(DispatchKeyValue(gift, "model", MDL_GIFT_BOOK))
			            {
			                switch (GetRandomInt(1, 9))
			                {
			                    case 1: DispatchKeyValue(gift, "rendercolor", COLOR_CYAN);
			                    case 2: DispatchKeyValue(gift, "rendercolor", COLOR_GREEN);				
			                    case 3: DispatchKeyValue(gift, "rendercolor", COLOR_PURPLE);					
			                    case 4: DispatchKeyValue(gift, "rendercolor", COLOR_PINK);					
			                    case 5: DispatchKeyValue(gift, "rendercolor", COLOR_RED);					
			                    case 6: DispatchKeyValue(gift, "rendercolor", COLOR_ORANGE);				
			                    case 7: DispatchKeyValue(gift, "rendercolor", COLOR_YELLOW);
			                    case 8: DispatchKeyValue(gift, "rendercolor", COLOR_BLUE);
								case 9: DispatchKeyValue(gift, "rendercolor", COLOR_BLACK);
			                }
			            }							
			        }	
			        case 7: 
			        {
			            if(DispatchKeyValue(gift, "model", MDL_GIFT_DOLL))
			            {
			                switch (GetRandomInt(1, 9))
			                {
			                    case 1: DispatchKeyValue(gift, "rendercolor", COLOR_CYAN);
			                    case 2: DispatchKeyValue(gift, "rendercolor", COLOR_GREEN);				
			                    case 3: DispatchKeyValue(gift, "rendercolor", COLOR_PURPLE);					
			                    case 4: DispatchKeyValue(gift, "rendercolor", COLOR_PINK);					
			                    case 5: DispatchKeyValue(gift, "rendercolor", COLOR_RED);					
			                    case 6: DispatchKeyValue(gift, "rendercolor", COLOR_ORANGE);				
			                    case 7: DispatchKeyValue(gift, "rendercolor", COLOR_YELLOW);
			                    case 8: DispatchKeyValue(gift, "rendercolor", COLOR_BLUE);
								case 9: DispatchKeyValue(gift, "rendercolor", COLOR_BLACK);
			                }
			            }							
			        }
			    }
			}
			DispatchKeyValueVector(gift, "origin", gifPos);
			SetEntPropFloat(gift, Prop_Send,"m_flModelScale", 1.0);
			DispatchSpawn(gift);
			g_GifLife[gift] = 0.0;
			CreateTimer(0.1, Timer_GiftLife, EntIndexToEntRef(gift), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(1.0, Timer_SetRenderGlow, EntIndexToEntRef(gift), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);		
		}
	}		
}

bool points(int client)
{
	int special;
	switch (GetRandomInt(1, 150))
	{
        case 1: x = 5; case 2: x = 15; case 3: x = 20; case 4: x = 25; 
		case 5: x = 30; case 6: x = 35; case 7: x = 40; case 8: x = 45; 
		case 9: x = 50; case 10: x = 55; case 11: x = 60; case 12: x = 65; 
		case 13: x = 70; case 14: x = 75; case 15: x = 80; case 16: x = 85; 
		case 17: x = 90; case 18: x = 95; case 19: x = 100; case 20: x = 105; 
		case 21: x = 110; case 22: x = 150;
        case 23: x = 150, zombie(client, "witch_bride"), special = 0, EmitSoundToAll(BRIDE_SOUND); 
		case 24: x = 150, zombie(client, "tank"), special = 1, EmitSoundToAll(TANK_SOUND);
		case 25: x = 150, zombie(client, "witch"), special = 2, EmitSoundToAll(WITCH_SOUND); 
		case 26: x = 150, zombie(client, "boomer"), special = 3, EmitSoundToAll(BOOMER_SOUND);
		case 27: x = 150, zombie(client, "jockey"), special = 4, EmitSoundToAll(JOCKEY_SOUND);
		case 28: x = 150, zombie(client, "spitter"), special = 5, EmitSoundToAll(SPITTER_SOUND);
		case 29: x = 150, zombie(client, "smoker"), special = 6, EmitSoundToAll(SMOKER_SOUND);
		case 30: x = 150, zombie(client, "charger"), special = 7, EmitSoundToAll(CHARGER_SOUND);
        case 31: x = 110, zombie(client, "witch_bride"), special = 0, EmitSoundToAll(BRIDE_SOUND); 
		case 32: x = 110, zombie(client, "tank"), special = 1, EmitSoundToAll(TANK_SOUND);
		case 33: x = 110, zombie(client, "witch"), special = 2, EmitSoundToAll(WITCH_SOUND);
		case 34: x = 110, zombie(client, "boomer"), special = 3, EmitSoundToAll(BOOMER_SOUND);
		case 35: x = 110, zombie(client, "jockey"), special = 4, EmitSoundToAll(JOCKEY_SOUND);
		case 36: x = 110, zombie(client, "spitter"), special = 5, EmitSoundToAll(SPITTER_SOUND);
		case 37: x = 110, zombie(client, "smoker"), special = 6, EmitSoundToAll(SMOKER_SOUND);
		case 38: x = 110, zombie(client, "charger"), special = 7, EmitSoundToAll(CHARGER_SOUND);
        case 39: x = 105, zombie(client, "witch_bride"), special = 0, EmitSoundToAll(BRIDE_SOUND);
		case 40: x = 105, zombie(client, "tank"), special = 1, EmitSoundToAll(TANK_SOUND);
		case 41: x = 105, zombie(client, "witch"), special = 2, EmitSoundToAll(WITCH_SOUND);
		case 42: x = 105, zombie(client, "boomer"), special = 3, EmitSoundToAll(BOOMER_SOUND);
		case 43: x = 105, zombie(client, "jockey"), special = 4, EmitSoundToAll(JOCKEY_SOUND);
		case 44: x = 105, zombie(client, "spitter"), special = 5, EmitSoundToAll(SPITTER_SOUND);
		case 45: x = 105, zombie(client, "smoker"), special = 6, EmitSoundToAll(SMOKER_SOUND);
		case 46: x = 105, zombie(client, "charger"), special = 7, EmitSoundToAll(CHARGER_SOUND);
        case 47: x = 100, zombie(client, "witch_bride"), special = 0, EmitSoundToAll(BRIDE_SOUND);
		case 48: x = 100, zombie(client, "tank"), special = 1, EmitSoundToAll(TANK_SOUND);
		case 49: x = 100, zombie(client, "witch"), special = 2, EmitSoundToAll(WITCH_SOUND);
		case 50: x = 100, zombie(client, "boomer"), special = 3, EmitSoundToAll(BOOMER_SOUND);
		case 51: x = 100, zombie(client, "jockey"), special = 4, EmitSoundToAll(JOCKEY_SOUND);
		case 52: x = 100, zombie(client, "spitter"), special = 5, EmitSoundToAll(SPITTER_SOUND);
		case 53: x = 100, zombie(client, "smoker"), special = 6, EmitSoundToAll(SMOKER_SOUND);
		case 54: x = 100, zombie(client, "charger"), special = 7, EmitSoundToAll(CHARGER_SOUND);
        case 55: x = 95, zombie(client, "witch_bride"), special = 0, EmitSoundToAll(BRIDE_SOUND);
		case 56: x = 95, zombie(client, "tank"), special = 1, EmitSoundToAll(TANK_SOUND);
		case 57: x = 95, zombie(client, "witch"), special = 2, EmitSoundToAll(WITCH_SOUND);
		case 58: x = 95, zombie(client, "boomer"), special = 3, EmitSoundToAll(BOOMER_SOUND);
		case 59: x = 95, zombie(client, "jockey"), special = 4, EmitSoundToAll(JOCKEY_SOUND);
		case 60: x = 95, zombie(client, "spitter"), special = 5, EmitSoundToAll(SPITTER_SOUND);
		case 61: x = 95, zombie(client, "smoker"), special = 6, EmitSoundToAll(SMOKER_SOUND);
		case 62: x = 95, zombie(client, "charger"), special = 7, EmitSoundToAll(CHARGER_SOUND);
        case 63: x = 90, zombie(client, "witch_bride"), special = 0, EmitSoundToAll(BRIDE_SOUND);
		case 64: x = 90, zombie(client, "tank"), special = 1, EmitSoundToAll(TANK_SOUND);
		case 65: x = 90, zombie(client, "witch"), special = 2, EmitSoundToAll(WITCH_SOUND);
		case 66: x = 90, zombie(client, "boomer"), special = 3, EmitSoundToAll(BOOMER_SOUND);
		case 67: x = 90, zombie(client, "jockey"), special = 4, EmitSoundToAll(JOCKEY_SOUND);
		case 68: x = 90, zombie(client, "spitter"), special = 5, EmitSoundToAll(SPITTER_SOUND);
		case 69: x = 90, zombie(client, "smoker"), special = 6, EmitSoundToAll(SMOKER_SOUND);
		case 70: x = 90, zombie(client, "charger"), special = 7, EmitSoundToAll(CHARGER_SOUND);
        case 71: x = 85, zombie(client, "witch_bride"), special = 0, EmitSoundToAll(BRIDE_SOUND);
		case 72: x = 85, zombie(client, "tank"), special = 1, EmitSoundToAll(TANK_SOUND);
		case 73: x = 85, zombie(client, "witch"), special = 2, EmitSoundToAll(WITCH_SOUND);
		case 74: x = 85, zombie(client, "boomer"), special = 3, EmitSoundToAll(BOOMER_SOUND);
		case 75: x = 85, zombie(client, "jockey"), special = 4, EmitSoundToAll(JOCKEY_SOUND);
		case 76: x = 85, zombie(client, "spitter"), special = 5, EmitSoundToAll(SPITTER_SOUND);
		case 77: x = 85, zombie(client, "smoker"), special = 6, EmitSoundToAll(SMOKER_SOUND);
		case 78: x = 85, zombie(client, "charger"), special = 7, EmitSoundToAll(CHARGER_SOUND);
        case 79: x = 80, zombie(client, "witch_bride"), special = 0, EmitSoundToAll(BRIDE_SOUND);
		case 80: x = 80, zombie(client, "tank"), special = 1, EmitSoundToAll(TANK_SOUND);
		case 81: x = 80, zombie(client, "witch"), special = 2, EmitSoundToAll(WITCH_SOUND);
		case 82: x = 80, zombie(client, "boomer"), special = 3, EmitSoundToAll(BOOMER_SOUND);
		case 83: x = 80, zombie(client, "jockey"), special = 4, EmitSoundToAll(JOCKEY_SOUND);
		case 84: x = 80, zombie(client, "spitter"), special = 5, EmitSoundToAll(SPITTER_SOUND);
		case 85: x = 80, zombie(client, "smoker"), special = 6, EmitSoundToAll(SMOKER_SOUND);
		case 86: x = 80, zombie(client, "charger"), special = 7, EmitSoundToAll(CHARGER_SOUND);
        case 87: x = 75, zombie(client, "witch_bride"), special = 0, EmitSoundToAll(BRIDE_SOUND);
		case 88: x = 75, zombie(client, "tank"), special = 1, EmitSoundToAll(TANK_SOUND);
		case 89: x = 75, zombie(client, "witch"), special = 2, EmitSoundToAll(WITCH_SOUND);
		case 90: x = 75, zombie(client, "boomer"), special = 3, EmitSoundToAll(BOOMER_SOUND);
		case 91: x = 75, zombie(client, "jockey"), special = 4, EmitSoundToAll(JOCKEY_SOUND);
		case 92: x = 75, zombie(client, "spitter"), special = 5, EmitSoundToAll(SPITTER_SOUND);
		case 93: x = 75, zombie(client, "smoker"), special = 6, EmitSoundToAll(SMOKER_SOUND);
		case 94: x = 75, zombie(client, "charger"), special = 7, EmitSoundToAll(CHARGER_SOUND);
        case 95: x = 70, zombie(client, "witch_bride"), special = 0, EmitSoundToAll(BRIDE_SOUND);
		case 96: x = 70, zombie(client, "tank"), special = 1, EmitSoundToAll(TANK_SOUND);
		case 97: x = 70, zombie(client, "witch"), special = 2, EmitSoundToAll(WITCH_SOUND);
		case 98: x = 70, zombie(client, "boomer"), special = 3, EmitSoundToAll(BOOMER_SOUND);
		case 99: x = 70, zombie(client, "jockey"), special = 4, EmitSoundToAll(JOCKEY_SOUND);
		case 100: x = 70, zombie(client, "spitter"), special = 5, EmitSoundToAll(SPITTER_SOUND);
		case 101: x = 70, zombie(client, "smoker"), special = 6, EmitSoundToAll(SMOKER_SOUND);
		case 102: x = 70, zombie(client, "charger"), special = 7, EmitSoundToAll(CHARGER_SOUND);
        case 103: x = 5; case 104: x = 15; case 105: x = 20; case 106: x = 25; 
		case 107: x = 30; case 108: x = 35; case 109: x = 40; case 110: x = 45; 
		case 111: x = 50; case 112: x = 55; case 113: x = 60; case 114: x = 65;
        case 115: x = 5; case 116: x = 15; case 117: x = 20; case 118: x = 25; 
		case 119: x = 30; case 120: x = 35; case 121: x = 40; case 122: x = 45; 
		case 123: x = 50; case 124: x = 55; case 125: x = 60; case 126: x = 65;
        case 127: x = 5; case 128: x = 15; case 129: x = 20; case 130: x = 25; 
		case 131: x = 30; case 132: x = 35; case 133: x = 40; case 134: x = 45; 
		case 135: x = 50; case 136: x = 55; case 137: x = 60; case 138: x = 65;
        case 139: x = 5; case 140: x = 15; case 141: x = 20; case 142: x = 25; 
		case 143: x = 30; case 144: x = 35; case 145: x = 40; case 146: x = 45; 
		case 147: x = 50; case 148: x = 55; case 149: x = 60; case 150: x = 65;    			
	}
	ServerCommand("sm_givepoints #%d %d", GetClientUserId(client), x);
	EmitSoundToAll(SND_REWARD, client);
	if(special)
	{
		CPrintToChatAll("%t", "[UKS_Gift] %N got %d points + gift[%s]", client, x, name_infected[special]);
	}		
	else 
	{	
		CPrintToChatAll("%t", "[UKS_Gift] %N got %d points", client, x);
	}			
	return true;	
}

bool health(int client)
{
	if (!client || !IsClientConnected(client)) return;
	if (!IsClientInGame(client)) return; 
	if (GetClientTeam(client) != 2)
	if (!IsPlayerAlive(client)) return;
	switch (GetRandomInt(1, 20))
	{
        case 1: HP = 40;
        case 2: HP = 20;
        case 3: HP = 80;
        case 4: HP = 60;
        case 5: HP = 100;
        case 6: HP = 30;
        case 7: HP = 70;
        case 8: HP = 50;
        case 9: HP = 90;
		case 10: HP = 10;
		case 12: HP = 35;
		case 13: HP = 95;
		case 14: HP = 65;
		case 15: HP = 15;
		case 16: HP = 25;
		case 17: HP = 85;
		case 18: HP = 75;
		case 19: HP = 45;
		case 20: HP = 5;
	}
	int flags = GetCommandFlags("give");
	SetCommandFlags("give", flags & ~FCVAR_CHEAT);
	if (client)
	{
        FakeClientCommand(client, "give health");
        SetEntityHealth(client, HP);
        SetEntProp(client, Prop_Send, "m_isGoingToDie", 0);
        SetEntProp(client, Prop_Send, "m_currentReviveCount", 0);
        SetEntPropFloat(client, Prop_Send, "m_healthBuffer", 0.0); 
        SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", 0.0);
        SetTempHealth(client, 0);
        float position[3];
        GetEntPropVector(client, Prop_Send, "m_vecOrigin", position);
        position[2] += 10;
        GetClientEyePosition(client, position);
        if(HP == 5)
        {
			HP = 99;		
			TE_SetupBeamRingPoint(position, 10.0, l4d2_healgift_radius, g_BeamSprite, g_HaloSprite, 0, 10, 0.3, 10.0, 0.5, redColor, 400, 0);
			TE_SendToAll();		
			EmitAmbientSound(BLOOD_SOUND, position, client, SNDLEVEL_RAIDSIREN);
			ScreenFade(client, 255, 15, 15, 100, RoundToZero(0.8 * 1000.0), 1);
			if (IsValidEntity(client) && IsValidEdict(client))
			{
			    if (GetClientTeam(client) == 2 && IsPlayerAlive(client) && !IsGoingToDie(client))
			    {
						BlackAndWhite(client);
			    }
			}
			CPrintToChat(client, "%t", "[UKS_Gift] %N Health %d + BlackAndWhite", client, HP);
        }		
        else if(HP == 10)
        {
			HP = 99;		
			TE_SetupBeamRingPoint(position, 10.0, l4d2_healgift_radius, g_BeamSprite, g_HaloSprite, 0, 10, 0.3, 10.0, 0.5, redColor, 400, 0);
			TE_SendToAll();		
			EmitAmbientSound(BLOOD_SOUND, position, client, SNDLEVEL_RAIDSIREN);
			ScreenFade(client, 255, 15, 15, 100, RoundToZero(0.8 * 1000.0), 1);
			if (IsValidEntity(client) && IsValidEdict(client))
			{
			    if (GetClientTeam(client) == 2 && IsPlayerAlive(client) && !IsGoingToDie(client))
			    {
						BlackAndWhite(client);
			    }
			}
			CPrintToChat(client, "%t", "[UKS_Gift] %N Health %d + BlackAndWhite", client, HP);
        }
        else if(HP == 15)
        {
			HP = 15;
			TE_SetupBeamRingPoint(position, 10.0, l4d2_healgift_radius, g_BeamSprite, g_HaloSprite, 0, 10, 0.3, 10.0, 0.5, redColor, 400, 0);
			TE_SendToAll();		
			EmitAmbientSound(BLOOD_SOUND, position, client, SNDLEVEL_RAIDSIREN);
			ScreenFade(client, 255, 15, 15, 100, RoundToZero(0.8 * 1000.0), 1);
			CPrintToChatAll("%t", "[UKS_Gift] %N Health %d", client, HP);
			CleanAura(client);
        }
        else if(HP == 20)
        {
			HP = 20;
			TE_SetupBeamRingPoint(position, 10.0, l4d2_healgift_radius, g_BeamSprite, g_HaloSprite, 0, 10, 0.3, 10.0, 0.5, redColor, 400, 0);
			TE_SendToAll();		
			EmitAmbientSound(BLOOD_SOUND, position, client, SNDLEVEL_RAIDSIREN);
			ScreenFade(client, 255, 15, 15, 100, RoundToZero(0.8 * 1000.0), 1);
			CPrintToChatAll("%t", "[UKS_Gift] %N Health %d", client, HP);
			CleanAura(client);
        }
        else if(HP == 25)
        {
			HP = 25;
			TE_SetupBeamRingPoint(position, 10.0, l4d2_healgift_radius, g_BeamSprite, g_HaloSprite, 0, 10, 0.3, 10.0, 0.5, orangeColor, 400, 0);
			TE_SendToAll();		
			EmitAmbientSound(BLOOD_SOUND, position, client, SNDLEVEL_RAIDSIREN);
			ScreenFade(client, 255, 165, 0, 140, RoundToZero(0.8 * 1000.0), 1);
			CPrintToChatAll("%t", "[UKS_Gift] %N Health %d", client, HP);
			CleanAura(client);
        }
        else if(HP == 30)
        {
			HP = 30;		
			TE_SetupBeamRingPoint(position, 10.0, l4d2_healgift_radius, g_BeamSprite, g_HaloSprite, 0, 10, 0.3, 10.0, 0.5, orangeColor, 400, 0);
			TE_SendToAll();		
			EmitAmbientSound(BLOOD_SOUND, position, client, SNDLEVEL_RAIDSIREN);
			ScreenFade(client, 255, 165, 0, 140, RoundToZero(0.8 * 1000.0), 1);
			CPrintToChatAll("%t", "[UKS_Gift] %N Health %d", client, HP);
			CleanAura(client);
        }
        else if(HP == 35)
        {
			HP = 35;		
			TE_SetupBeamRingPoint(position, 10.0, l4d2_healgift_radius, g_BeamSprite, g_HaloSprite, 0, 10, 0.3, 10.0, 0.5, orangeColor, 400, 0);
			TE_SendToAll();		
			EmitAmbientSound(BLOOD_SOUND, position, client, SNDLEVEL_RAIDSIREN);
			ScreenFade(client, 255, 165, 0, 140, RoundToZero(0.8 * 1000.0), 1);
			CPrintToChatAll("%t", "[UKS_Gift] %N Health %d", client, HP);
			CleanAura(client);
        }
        else 
        {	
			TE_SetupBeamRingPoint(position, 10.0, l4d2_healgift_radius, g_BeamSprite, g_HaloSprite, 0, 10, 0.3, 10.0, 0.5, greenColor, 400, 0);
			TE_SendToAll();
			EmitAmbientSound(HEAL_SOUND, position, client, SNDLEVEL_RAIDSIREN);
			ScreenFade(client, 192, 238, 39, 140, RoundToZero(0.6 * 1000.0), 1);
			CPrintToChatAll("%t", "[UKS_Gift] %N Health %d", client, HP);
			CleanAura(client);	
        }
	}
	SetCommandFlags("give", flags);	
}

void BlackAndWhite(int client, int hp=99)
{
	if(client > 0 && IsValidEntity(client) && IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 2)
	{
		SetEntProp(client, Prop_Send, "m_currentReviveCount", FindConVar("survivor_max_incapacitated_count").IntValue-1);
		SetEntProp(client, Prop_Send, "m_isIncapacitated", 1);
		SDKCall(sdkRevive, client);
		SetEntityHealth(client, 1);
		SetTempHealth(client, hp);
	}
}

public void CleanAura(int client)
{
	if (client < 1)
		return;
	if (!IsValidEntity(client))
		return;
	if (!IsClientInGame(client))
		return;
	if (GetClientTeam(client) != 2)
		return;

	SetEntProp(client, Prop_Send, "m_iGlowType", 0);
	SetEntProp(client, Prop_Send, "m_glowColorOverride", 0);
}

bool IsGoingToDie(int client)
{
	if (GetEntProp(client, Prop_Send, "m_currentReviveCount") == FindConVar("survivor_max_incapacitated_count").IntValue)
		return true;
	return false;
}

public int SetTempHealth(int client, int hp)
{
	SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
	float newOverheal = hp * 1.0; 
	SetEntPropFloat(client, Prop_Send, "m_healthBuffer", newOverheal);
}

public void ScreenFade(int target, int red, int green, int blue, int alpha, int duration, int type)
{
	Handle msg = StartMessageOne("Fade", target);
	BfWriteShort(msg, 500);
	BfWriteShort(msg, duration);
	if (type == 0) BfWriteShort(msg, (0x0002 | 0x0008));
	else BfWriteShort(msg, (0x0001 | 0x0010));
	BfWriteByte(msg, red);
	BfWriteByte(msg, green);
	BfWriteByte(msg, blue);
	BfWriteByte(msg, alpha);
	EndMessage();
}

bool weapons(int client)
{		
	EmitSoundToAll(SND_REWARD, client);
	if (!client || !IsClientConnected(client))
	if (!IsClientInGame(client)) 
	if (GetClientTeam(client) != 2)
	if (!IsPlayerAlive(client)) 
	if (GetPlayerWeaponSlot(client, 0) > -1) 
	{
        RemovePlayerItem(client, GetPlayerWeaponSlot(client, 0));
	}
	char ScriptName[32];
	int name = 0, laseron = 0, explosive = 0, incendiary = 0;
	int random = GetRandomInt(1, 65);
	switch (random)
	{
		case 1: name = 0, create_weapons(client, guns[0]);		
		case 2: name = 1, create_weapons(client, guns[1]);
		case 3: name = 2, create_weapons(client, guns[2]);
		case 4: name = 3, create_weapons(client, guns[3]);
		case 5: name = 4, create_weapons(client, guns[4]);
		case 6: name = 5, create_weapons(client, guns[5]), Gren(client);
		case 7: name = 6, create_weapons(client, guns[6]);
		case 8: name = 7, create_weapons(client, guns[7]);
		case 9: name = 8, create_weapons(client, guns[8]);
		case 10: name = 9, create_weapons(client, guns[9]);
		case 11: name = 10, create_weapons(client, guns[10]);
		case 12: name = 11, create_weapons(client, guns[11]);
		case 13: name = 12, create_weapons(client, guns[12]);
		case 14: name = 13, create_weapons(client, guns[13]);
		case 15: name = 14, create_weapons(client, guns[14]);
		case 16: name = 15, create_weapons(client, guns[15]);
		case 17: name = 16, create_weapons(client, guns[16]); 
		case 18: name = 17, create_weapons(client, guns[17]);
		case 19: name = 18, create_weapons(client, guns[18]), GetScriptName(guns[18], ScriptName);
		case 20: name = 19, create_weapons(client, guns[19]);
		case 21: name = 0, create_weapons(client, guns[0]), ammo(client, "laser_sight"), laseron = 1;		
		case 22: name = 1, create_weapons(client, guns[1]), ammo(client, "laser_sight"), laseron = 1;
		case 23: name = 2, create_weapons(client, guns[2]), ammo(client, "laser_sight"), laseron = 1;
		case 24: name = 3, create_weapons(client, guns[3]), ammo(client, "laser_sight"), laseron = 1;
		case 25: name = 4, create_weapons(client, guns[4]), ammo(client, "laser_sight"), laseron = 1;
		case 26: name = 5, create_weapons(client, guns[5]), ammo(client, "laser_sight"), laseron = 1, Gren(client);
		case 27: name = 6, create_weapons(client, guns[6]), ammo(client, "laser_sight"), laseron = 1;
		case 28: name = 7, create_weapons(client, guns[7]), ammo(client, "laser_sight"), laseron = 1;
		case 29: name = 8, create_weapons(client, guns[8]), ammo(client, "laser_sight"), laseron = 1;
		case 30: name = 9, create_weapons(client, guns[9]), ammo(client, "laser_sight"), laseron = 1;
		case 31: name = 10, create_weapons(client, guns[10]), ammo(client, "laser_sight"), laseron = 1;
		case 32: name = 11, create_weapons(client, guns[11]), ammo(client, "laser_sight"), laseron = 1;
		case 33: name = 12, create_weapons(client, guns[12]), ammo(client, "laser_sight"), laseron = 1;
		case 34: name = 14, create_weapons(client, guns[14]), ammo(client, "laser_sight"), laseron = 1;
		case 35: name = 19, create_weapons(client, guns[19]), ammo(client, "laser_sight"), laseron = 1;
		case 36: name = 0, create_weapons(client, guns[0]), ammo(client, "explosive_ammo"), explosive = 1;		
		case 37: name = 1, create_weapons(client, guns[1]), ammo(client, "explosive_ammo"), explosive = 1;
		case 38: name = 2, create_weapons(client, guns[2]), ammo(client, "explosive_ammo"), explosive = 1;
		case 39: name = 3, create_weapons(client, guns[3]), ammo(client, "explosive_ammo"), explosive = 1;
		case 40: name = 4, create_weapons(client, guns[4]), ammo(client, "explosive_ammo"), explosive = 1;
		case 41: name = 5, create_weapons(client, guns[5]), ammo(client, "explosive_ammo"), explosive = 1, Gren(client);
		case 42: name = 6, create_weapons(client, guns[6]), ammo(client, "explosive_ammo"), explosive = 1;
		case 43: name = 7, create_weapons(client, guns[7]), ammo(client, "explosive_ammo"), explosive = 1;
		case 44: name = 8, create_weapons(client, guns[8]), ammo(client, "explosive_ammo"), explosive = 1;
		case 45: name = 9, create_weapons(client, guns[9]), ammo(client, "explosive_ammo"), explosive = 1;
		case 46: name = 10, create_weapons(client, guns[10]), ammo(client, "explosive_ammo"), explosive = 1;
		case 47: name = 11, create_weapons(client, guns[11]), ammo(client, "explosive_ammo"), explosive = 1;
		case 48: name = 12, create_weapons(client, guns[12]), ammo(client, "explosive_ammo"), explosive = 1;
		case 49: name = 14, create_weapons(client, guns[14]), ammo(client, "explosive_ammo"), explosive = 1;
		case 50: name = 19, create_weapons(client, guns[19]), ammo(client, "explosive_ammo"), explosive = 1;
		case 51: name = 0, create_weapons(client, guns[0]), ammo(client, "incendiary_ammo"), incendiary = 1;		
		case 52: name = 1, create_weapons(client, guns[1]), ammo(client, "incendiary_ammo"), incendiary = 1;
		case 53: name = 2, create_weapons(client, guns[2]), ammo(client, "incendiary_ammo"), incendiary = 1;
		case 54: name = 3, create_weapons(client, guns[3]), ammo(client, "incendiary_ammo"), incendiary = 1;
		case 55: name = 4, create_weapons(client, guns[4]), ammo(client, "incendiary_ammo"), incendiary = 1;
		case 56: name = 5, create_weapons(client, guns[5]), ammo(client, "incendiary_ammo"), incendiary = 1, Gren(client);
		case 57: name = 6, create_weapons(client, guns[6]), ammo(client, "incendiary_ammo"), incendiary = 1;
		case 58: name = 7, create_weapons(client, guns[7]), ammo(client, "incendiary_ammo"), incendiary = 1;
		case 59: name = 8, create_weapons(client, guns[8]), ammo(client, "incendiary_ammo"), incendiary = 1;
		case 60: name = 9, create_weapons(client, guns[9]), ammo(client, "incendiary_ammo"), incendiary = 1;
		case 61: name = 10, create_weapons(client, guns[10]), ammo(client, "incendiary_ammo"), incendiary = 1;
		case 62: name = 11, create_weapons(client, guns[11]), ammo(client, "incendiary_ammo"), incendiary = 1;
		case 63: name = 12, create_weapons(client, guns[12]), ammo(client, "incendiary_ammo"), incendiary = 1;
		case 64: name = 14, create_weapons(client, guns[14]), ammo(client, "incendiary_ammo"), incendiary = 1;
		case 65: name = 19, create_weapons(client, guns[19]), ammo(client, "incendiary_ammo"), incendiary = 1;		
	}
	if(laseron > 0)
	{	
		CPrintToChatAll("%t", "[UKS_Gift] %N got %s + Laser.", client, name_weapon[name], laseron);
		EmitSoundToAll(LASER_SOUND, client, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN);
	}
	else if(explosive > 0)
	{	
		CPrintToChatAll("%t", "[UKS_Gift] %N got %s + Explosives.", client, name_weapon[name], explosive);
	}
	else if(incendiary > 0)
	{	
		CPrintToChatAll("%t", "[UKS_Gift] %N got %s + Incendiarys.", client, name_weapon[name], incendiary);
	}
	else
	{	
		CPrintToChatAll("%t", "[UKS_Gift] %N got %s.", client, name_weapon[name]);
	}	
}

void Gren(int client)
{
	SetEntProp(GetPlayerWeaponSlot(client, 0), Prop_Send, "m_iExtraPrimaryAmmo", 0, 4, 0);
	SetEntProp(GetPlayerWeaponSlot(client, 0), Prop_Send, "m_iClip1", 100, 4, 0);
	SetEntProp(GetPlayerWeaponSlot(client, 0), Prop_Send, "m_upgradeBitVec", 1, 4, 0);
	SetEntProp(GetPlayerWeaponSlot(client, 0), Prop_Send, "m_nUpgradedPrimaryAmmoLoaded", 100, 4, 0);
}

stock void create_weapons(int client, const char[] weapon)
{
	if (client) 
	{
        int flagscreate = GetCommandFlags("give");
        SetCommandFlags("give", flagscreate & ~FCVAR_CHEAT);
        FakeClientCommand(client, "give %s", weapon);
        SetCommandFlags("give", flagscreate);
	 }
}

stock void ammo(int client, const char[] arg)
{
	if (client) 
	{
        int flagsammo = GetCommandFlags("upgrade_add");
        SetCommandFlags("upgrade_add", flagsammo & ~FCVAR_CHEAT);
        FakeClientCommand(client, "upgrade_add %s", arg);
        SetCommandFlags("upgrade_add", flagsammo);
	 }
}

stock void zombie(int client, const char[] arg)
{
	if (client && OLD_SPAWN) 
	{
        int flagszombie = GetCommandFlags("z_spawn_old");
        SetCommandFlags("z_spawn_old", flagszombie & ~FCVAR_CHEAT);
        FakeClientCommand(client, "z_spawn_old %s", arg);
        SetCommandFlags("z_spawn_old", flagszombie);
	 }
	 else
	 {
        int flagszombie = GetCommandFlags("z_spawn");
        SetCommandFlags("z_spawn", flagszombie & ~FCVAR_CHEAT);
        FakeClientCommand(client, "z_spawn %s", arg);
        SetCommandFlags("z_spawn", flagszombie);
	 }
}

public void CreateParticle(int ent, char[] particleType, float time)
{
    
	int particle = CreateEntityByName("info_particle_system");
	char name[64];
	if (IsValidEdict(particle)) 
	{
        float position[3];
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", position);
        TeleportEntity(particle, position, NULL_VECTOR, NULL_VECTOR);
        GetEntPropString(ent, Prop_Data, "m_iName", name, sizeof(name));
        DispatchKeyValue(particle, "targetname", "l4d2particle");
        DispatchKeyValue(particle, "parentname", name);
        DispatchKeyValue(particle, "effect_name", particleType);
        DispatchSpawn(particle);
        SetVariantString(name);
        AcceptEntityInput(particle, "SetParent", particle, particle, 0);
        ActivateEntity(particle);
        AcceptEntityInput(particle, "start");	
        CreateTimer(time, DeleteParticle, particle);
	}   
}

public Action DeleteParticle(Handle timer, any particle)
{
    if (IsValidEntity(particle))
    {
        char classname[256];
        GetEdictClassname(particle, classname, sizeof(classname));
        if (!strcmp(classname, "info_particle_system"))
        RemoveEdict(particle);
    }
}

stock int GetScriptName(const char[] Class, char[] ScriptName)
{
	for(int i = 0; i < g_iMeleeClassCount; i++)
	{
		if(StrContains(g_sMeleeClass[i], Class, false) == 0)
		{
			Format(ScriptName, 32, "%s", g_sMeleeClass[i]);
			return;
		}
	}
	Format(ScriptName, 32, "%s", g_sMeleeClass[0]);	
}
			
stock int RotateAdvance(int index, float value, int axis)
{
	if (IsValidEntity(index))
	{
		float rotate_[3];
		GetEntPropVector(index, Prop_Data, "m_angRotation", rotate_);
		rotate_[axis] += value;
		TeleportEntity(index, NULL_VECTOR, rotate_, NULL_VECTOR);
	}
}

bool IsValidClient(int client)
{
	if (!(1 <= client <=  MaxClients)) return false;
	if (!IsClientConnected(client)) return false;
	if (!IsClientInGame(client)) return false;
	return true;
}

public Action CMD_Gift(int client, int args)
{
	if (client)
	{
		DropGiftP(client);
	}
	return Plugin_Handled;
} 

int DropGiftP(int client)
{
	float vAngles[3], vOrigin[3], gifPos[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", gifPos);
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);
	int gift;
	switch (GetRandomInt(1, 2))
	{
	    case 1: 
		{
			gift = CreateEntityByName("prop_physics_override");
			Handle distance = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
			if (TR_DidHit(distance))
			{
			    {
			        TR_GetEndPosition(gifPos, distance);
			        gifPos[2] += 10.0;
			        TeleportEntity(gift, gifPos, NULL_VECTOR, NULL_VECTOR);
			    }			
			    delete distance;
			}
			if(gift != -1)
			{
		        DispatchKeyValue(gift, "model", MDL_GIFT);
		        switch (GetRandomInt(1, 9))
		        { 
			        case 1: DispatchKeyValue(gift, "rendercolor", COLOR_CYAN);
			        case 2: DispatchKeyValue(gift, "rendercolor", COLOR_GREEN);				
			        case 3: DispatchKeyValue(gift, "rendercolor", COLOR_PURPLE);					
			        case 4: DispatchKeyValue(gift, "rendercolor", COLOR_PINK);					
			        case 5: DispatchKeyValue(gift, "rendercolor", COLOR_RED);					
			        case 6: DispatchKeyValue(gift, "rendercolor", COLOR_ORANGE);				
			        case 7: DispatchKeyValue(gift, "rendercolor", COLOR_YELLOW);
			        case 8: DispatchKeyValue(gift, "rendercolor", COLOR_BLUE);
					case 9: DispatchKeyValue(gift, "rendercolor", COLOR_BLACK);
		        }
			}
			DispatchKeyValueVector(gift, "origin", gifPos);
			SetEntPropFloat(gift, Prop_Send,"m_flModelScale", 1.0);
			DispatchSpawn(gift);
			g_GifLife[gift] = 0.0;
			CreateTimer(0.1, Timer_GiftLife1, EntIndexToEntRef(gift), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(1.0, Timer_SetRenderGlow, EntIndexToEntRef(gift), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);		
	    }
	    case 2:
		{
			gift = CreateEntityByName("prop_dynamic_override");
			Handle distance = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
			if (TR_DidHit(distance))
			{
			    {
			        TR_GetEndPosition(gifPos, distance);
			        gifPos[2] += 10.0;
			        TeleportEntity(gift, gifPos, NULL_VECTOR, NULL_VECTOR);
			    }			
			    delete distance;
			}
			if(gift != -1)
			{
		        switch (GetRandomInt(1, 7))
		        { 
			        case 1: 
			        {
			            if(DispatchKeyValue(gift, "model", MDL_GIFT_ELEPHANT))
			            {
			                switch (GetRandomInt(1, 9))
			                {
			                    case 1: DispatchKeyValue(gift, "rendercolor", COLOR_CYAN);
			                    case 2: DispatchKeyValue(gift, "rendercolor", COLOR_GREEN);				
			                    case 3: DispatchKeyValue(gift, "rendercolor", COLOR_PURPLE);					
			                    case 4: DispatchKeyValue(gift, "rendercolor", COLOR_PINK);					
			                    case 5: DispatchKeyValue(gift, "rendercolor", COLOR_RED);					
			                    case 6: DispatchKeyValue(gift, "rendercolor", COLOR_ORANGE);				
			                    case 7: DispatchKeyValue(gift, "rendercolor", COLOR_YELLOW);
			                    case 8: DispatchKeyValue(gift, "rendercolor", COLOR_BLUE);
								case 9: DispatchKeyValue(gift, "rendercolor", COLOR_BLACK);
			                }
			            }
			        }							
			        case 2: 
			        {
			            if(DispatchKeyValue(gift, "model", MDL_GIFT_COCODRILE))
			            {
			                switch (GetRandomInt(1, 9))
			                {
			                    case 1: DispatchKeyValue(gift, "rendercolor", COLOR_CYAN);
			                    case 2: DispatchKeyValue(gift, "rendercolor", COLOR_GREEN);				
			                    case 3: DispatchKeyValue(gift, "rendercolor", COLOR_PURPLE);					
			                    case 4: DispatchKeyValue(gift, "rendercolor", COLOR_PINK);					
			                    case 5: DispatchKeyValue(gift, "rendercolor", COLOR_RED);					
			                    case 6: DispatchKeyValue(gift, "rendercolor", COLOR_ORANGE);				
			                    case 7: DispatchKeyValue(gift, "rendercolor", COLOR_YELLOW);
			                    case 8: DispatchKeyValue(gift, "rendercolor", COLOR_BLUE);
								case 9: DispatchKeyValue(gift, "rendercolor", COLOR_BLACK);
			                }
			            }
			        }		
			        case 3: 
			        {
			            if(DispatchKeyValue(gift, "model", MDL_GIFT_GIRAFA))
			            {
			                switch (GetRandomInt(1, 9))
			                {
			                    case 1: DispatchKeyValue(gift, "rendercolor", COLOR_CYAN);
			                    case 2: DispatchKeyValue(gift, "rendercolor", COLOR_GREEN);				
			                    case 3: DispatchKeyValue(gift, "rendercolor", COLOR_PURPLE);					
			                    case 4: DispatchKeyValue(gift, "rendercolor", COLOR_PINK);					
			                    case 5: DispatchKeyValue(gift, "rendercolor", COLOR_RED);					
			                    case 6: DispatchKeyValue(gift, "rendercolor", COLOR_ORANGE);				
			                    case 7: DispatchKeyValue(gift, "rendercolor", COLOR_YELLOW);
			                    case 8: DispatchKeyValue(gift, "rendercolor", COLOR_BLUE);
								case 9: DispatchKeyValue(gift, "rendercolor", COLOR_BLACK);
			                }
			            }
			        }	
			        case 4: 
			        {
			            if(DispatchKeyValue(gift, "model", MDL_GIFT_SERPIENTE))
			            {
			                switch (GetRandomInt(1, 9))
			                {
			                    case 1: DispatchKeyValue(gift, "rendercolor", COLOR_CYAN);
			                    case 2: DispatchKeyValue(gift, "rendercolor", COLOR_GREEN);				
			                    case 3: DispatchKeyValue(gift, "rendercolor", COLOR_PURPLE);					
			                    case 4: DispatchKeyValue(gift, "rendercolor", COLOR_PINK);					
			                    case 5: DispatchKeyValue(gift, "rendercolor", COLOR_RED);					
			                    case 6: DispatchKeyValue(gift, "rendercolor", COLOR_ORANGE);				
			                    case 7: DispatchKeyValue(gift, "rendercolor", COLOR_YELLOW);
			                    case 8: DispatchKeyValue(gift, "rendercolor", COLOR_BLUE);
								case 9: DispatchKeyValue(gift, "rendercolor", COLOR_BLACK);
			                }
			            }							
			        }	
			        case 5: 
			        {
			            if(DispatchKeyValue(gift, "model", MDL_GIFT_TEDDY))
			            {
			                switch (GetRandomInt(1, 9))
			                {
			                    case 1: DispatchKeyValue(gift, "rendercolor", COLOR_CYAN);
			                    case 2: DispatchKeyValue(gift, "rendercolor", COLOR_GREEN);				
			                    case 3: DispatchKeyValue(gift, "rendercolor", COLOR_PURPLE);					
			                    case 4: DispatchKeyValue(gift, "rendercolor", COLOR_PINK);					
			                    case 5: DispatchKeyValue(gift, "rendercolor", COLOR_RED);					
			                    case 6: DispatchKeyValue(gift, "rendercolor", COLOR_ORANGE);				
			                    case 7: DispatchKeyValue(gift, "rendercolor", COLOR_YELLOW);
			                    case 8: DispatchKeyValue(gift, "rendercolor", COLOR_BLUE);
								case 9: DispatchKeyValue(gift, "rendercolor", COLOR_BLACK);
			                }
			            }							
			        }	
			        case 6: 
			        {
			            if(DispatchKeyValue(gift, "model", MDL_GIFT_BOOK))
			            {
			                switch (GetRandomInt(1, 9))
			                {
			                    case 1: DispatchKeyValue(gift, "rendercolor", COLOR_CYAN);
			                    case 2: DispatchKeyValue(gift, "rendercolor", COLOR_GREEN);				
			                    case 3: DispatchKeyValue(gift, "rendercolor", COLOR_PURPLE);					
			                    case 4: DispatchKeyValue(gift, "rendercolor", COLOR_PINK);					
			                    case 5: DispatchKeyValue(gift, "rendercolor", COLOR_RED);					
			                    case 6: DispatchKeyValue(gift, "rendercolor", COLOR_ORANGE);				
			                    case 7: DispatchKeyValue(gift, "rendercolor", COLOR_YELLOW);
			                    case 8: DispatchKeyValue(gift, "rendercolor", COLOR_BLUE);
								case 9: DispatchKeyValue(gift, "rendercolor", COLOR_BLACK);
			                }
			            }							
			        }	
			        case 7: 
			        {
			            if(DispatchKeyValue(gift, "model", MDL_GIFT_DOLL))
			            {
			                switch (GetRandomInt(1, 9))
			                {
			                    case 1: DispatchKeyValue(gift, "rendercolor", COLOR_CYAN);
			                    case 2: DispatchKeyValue(gift, "rendercolor", COLOR_GREEN);				
			                    case 3: DispatchKeyValue(gift, "rendercolor", COLOR_PURPLE);					
			                    case 4: DispatchKeyValue(gift, "rendercolor", COLOR_PINK);					
			                    case 5: DispatchKeyValue(gift, "rendercolor", COLOR_RED);					
			                    case 6: DispatchKeyValue(gift, "rendercolor", COLOR_ORANGE);				
			                    case 7: DispatchKeyValue(gift, "rendercolor", COLOR_YELLOW);
			                    case 8: DispatchKeyValue(gift, "rendercolor", COLOR_BLUE);
								case 9: DispatchKeyValue(gift, "rendercolor", COLOR_BLACK);
			                }
			            }							
			        }
			    }
			}
			DispatchKeyValueVector(gift, "origin", gifPos);
			SetEntPropFloat(gift, Prop_Send,"m_flModelScale", 1.0);
			DispatchSpawn(gift);
			g_GifLife[gift] = 0.0;
			CreateTimer(0.1, Timer_GiftLife, EntIndexToEntRef(gift), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(1.0, Timer_SetRenderGlow, EntIndexToEntRef(gift), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);						
	    }
	}		
}

public bool TraceEntityFilterPlayer(int entity, int contentsMask)
{
	{
		return entity > GetMaxClients() || !entity;
	} 
}

public Action ShowGifts(int client, int args)
{
	Print_Gifts(client);
	return Plugin_Handled;
}

public Action Print_Gifts(int client)
{
	if (client)
	{
		if (IsClientInGame(client))
		{
		    CPrintToChat(client, "%t", "[UKS_Gift] %N Total All Gifts: %d + [%d]", client, ig_real[client][GIFTS], ig_temp[client][GIFTS]);	
		    CPrintToChat(client, "%t", "[UKS_Gift] %N Total Normal Gifts: %d + [%d]", client, ig_real[client][GIFT_NORMAL], ig_temp[client][GIFT_NORMAL]);
		    CPrintToChat(client, "%t", "[UKS_Gift] %N Total Teddies Gifts: %d + [%d]", client, ig_real[client][GIFT_SPECIAL], ig_temp[client][GIFT_SPECIAL]);
		    CPrintToChat(client, "%t", "[UKS_Gift] %N Total Points Gifts: %d + [%d]", client, ig_real[client][GIFT_POINTS], ig_temp[client][GIFT_POINTS]);			
		}		
	}
	return Plugin_Handled;
}

public Action ShowPoints(int client, int args)
{
	Print_Points(client);
	return Plugin_Handled;
}

public Action Print_Points(int client)
{
	if (client)
	{
		if (IsClientInGame(client))
		{
		    CPrintToChat(client, "%t", "[UKS_Gift] %N Total Points Gifts: %d + [%d]", client, ig_real[client][GIFT_POINTS], ig_temp[client][GIFT_POINTS]);			
		}		
	}
	return Plugin_Handled;
}

public Action GiftTimerPI(Handle timer)
{
	int i = 1;
	while (i <= MaxClients)
	{
		if (IsClientInGame(i))
		{
			ig_temp[i][GIFT_TIME] += 1;
		}
		else
		{
			ig_temp[i][GIFT_TIME] = 0;
		}
		i += 1;
	}
}

stock bool L4D2_SetEntGlow(int entity, L4D2GlowType type, int colorOverride[3], int range=0, int minRange=0, bool flashing=false)
{
    char netclass[128];
    GetEntityNetClass(entity, netclass, 128);
    if(FindSendPropInfo(netclass, "m_iGlowType") < 1) return false;
    SetEntProp(entity, Prop_Send, "m_iGlowType", type);
    SetEntProp(entity, Prop_Send, "m_glowColorOverride", colorOverride[0] + (colorOverride[1] * 256) + (colorOverride[2] * 65536));
    SetEntProp(entity, Prop_Send, "m_nGlowRange", range);
    SetEntProp(entity, Prop_Send, "m_nGlowRangeMin", minRange);
    SetEntProp(entity, Prop_Send, "m_bFlashing", view_as<int>(flashing));
    return true;
}

public Action CMD_CreateTables(int client, int args)
{
	if (client)
	{
		if (gift_db)
		{
			DBResultSet hQuery = SQL_Query(gift_db, GIFT_CREATE_TABLE);
			if (hQuery)
			{
				delete hQuery;
			}
		}
	}
	return Plugin_Handled;
}