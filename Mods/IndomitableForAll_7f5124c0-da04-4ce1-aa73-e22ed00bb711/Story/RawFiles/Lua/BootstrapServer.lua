function StoreModVersion()
	local info = Ext.GetModInfo("7f5124c0-da04-4ce1-aa73-e22ed00bb711")
	Osi.DB_LLINDOMITABLE_LastVersion(info.Version)
end

function UpdateMod()
	local info = Ext.GetModInfo("7f5124c0-da04-4ce1-aa73-e22ed00bb711")
	Osi.LLINDOMITABLE_OnGetVersion(info.Version)
end

STATUSES = {
	---@type table<string,string>
	Resisted = {},
	--- No StatusData entries
	Engine = {
		["CHARMED"] = "CharmImmunity",
	},
	ImmunityFlags = {
		["StunImmunity"] = true,
		["FreezeImmunity"] = true,
		["KnockdownImmunity"] = true,
		["PetrifiedImmunity"] = true,
		["ChickenImmunity"] = true,
		["CrippledImmunity"] = true,
		["CharmImmunity"] = true,
		["FearImmunity"] = true,
		["MadnessImmunity"] = true,
	}
}

IGNORED = {
	Flags = {
		["LEADERLIB_IGNORE"] = true,
	},
	Tags = {
		["LeaderLib_Dummy"] = true,
		["LLMIME_Dummy"] = true,
		["LLMIME_Decoy"] = true,
	},
	Statuses = {
		["HIT"] = true,
		["INSURFACE"] = true,
		["LLINDOMITABLE_INDOMITABLE"] = true,
		["LLINDOMITABLE_INDOMITABLE_CD"] = true,
		["InstantKnockdown"] = true,
		["MATERIAL"] = true,
		["BOOST"] = true,
	}
}

local function SessionLoaded()
	Ext.Print("[IndomitableForAll] Building status list for Indomitable.")
	--Ext.Print("===================================================================")
	local total = 0
	for stat,flag in pairs(STATUSES.Engine) do
		total = total + 1
		--Ext.Print("[IndomitableForAll] Adding engine status ("..stat..").")
		STATUSES.Resisted[stat] = flag
	end
	for i,stat in pairs(Ext.GetStatEntries("StatusData")) do
		local flag = Ext.StatGetAttribute(stat, "ImmuneFlag")
		if STATUSES.ImmunityFlags[flag] == true then
			total = total + 1
			--Ext.Print("[IndomitableForAll] Adding status ("..stat..").")
			STATUSES.Resisted[stat] = flag
		end
	end
	Ext.Print("[IndomitableForAll] Listening for "..tostring(total).." statuses for Indomitable.")
	--Ext.Print("===================================================================")

	LoadSettings()
end

Ext.RegisterListener("SessionLoaded", SessionLoaded)

Helpers = {}

function Helpers.RegisterProtectedOsirisListener(event, arity, state, callback)
	Ext.RegisterOsirisListener(event, arity, state, function(...)
		if Ext.GetGameState() == "Running" then
			local b,err = xpcall(callback, debug.traceback, ...)
			if not b then
				Ext.PrintError(err)
			end
		end
	end)
end

Ext.Require("BootstrapShared.lua")
Ext.Require("Server/Indomitable.lua")
Ext.Require("Server/UserStatusSettings.lua")