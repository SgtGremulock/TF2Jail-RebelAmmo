#include <sourcemod>
#include <tf2_stocks>
#include <sdktools>
#include <tf2jail>
#undef REQUIRE_PLUGIN
#include <updater>

#define PLUGIN_NAME "[TF2Jail] Rebel Ammo Module"
#define PLUGIN_AUTHOR "Sgt. Gremulock"
#define PLUGIN_DESCRIPTION "Marks a prisoner as a rebel when they pick up ammo."
#define PLUGIN_VERSION "1.1"
#define PLUGIN_CONTACT "sourcemod.net"

#define UPDATE_URL "https://raw.githubusercontent.com/SgtGremulock/TF2Jail-RebelAmmo/master/updater.txt"

ConVar cv_Enabled;
bool bEnabled;

public Plugin myinfo = 
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = PLUGIN_CONTACT
}

public void OnPluginStart()
{
	CreateConVar("tf2jail_rebelammo_version", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_NOTIFY|FCVAR_REPLICATED);
	cv_Enabled = CreateConVar("tf2jail_rebelammo_enable", "1", "Enable/disable the plugin.", _, true, 0.0, true, 1.0);

	bEnabled = cv_Enabled.BoolValue;

	HookConVarChange(cv_Enabled, CvarUpdate);

	AutoExecConfig(true, "TF2Jail_RebelAmmo");

	AddUpdater();

	OnMapStart();
}

void AddUpdater()
{
	if (LibraryExists("updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
}

public void CvarUpdate(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	bEnabled = cv_Enabled.BoolValue;
}

public void OnConfigsExecuted()
{
	bEnabled = cv_Enabled.BoolValue;
}

public void OnMapStart()
{
	bEnabled = cv_Enabled.BoolValue;

	if (bEnabled)
	{
		HookEntityOutput("item_ammopack_full", "OnPlayerTouch", OnPlayerTouch);
		HookEntityOutput("item_ammopack_medium", "OnPlayerTouch", OnPlayerTouch);
		HookEntityOutput("item_ammopack_small", "OnPlayerTouch", OnPlayerTouch);
		HookEntityOutput("tf_dropped_weapon", "OnPlayerTouch", OnPlayerTouch);
		HookEntityOutput("tf_ammo_pack", "OnPlayerTouch", OnPlayerTouch);
	}
}

public Action OnPlayerTouch(const char[] output, int caller, int activator, float delay)
{
	if (IsValidClient(activator))
	{
		if (!TF2Jail_IsRebel(activator) && TF2_GetClientTeam(activator) == TFTeam_Red)
		{
			TF2Jail_MarkRebel(activator);

			if (TF2Jail_IsFreeday(activator))
			{
				TF2Jail_RemoveFreeday(activator);
			}
		}
	}
}

bool IsValidClient(int client)
{
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || IsFakeClient(client))
	{
		return false; 
	}
	
	return IsClientInGame(client); 
}