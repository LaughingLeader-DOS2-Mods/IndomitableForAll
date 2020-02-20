local player_stats = {
	--["_Base"] = true,
	["_Hero"] = true,
	["HumanFemaleHero"] = true,
	["HumanMaleHero"] = true,
	["DwarfFemaleHero"] = true,
	["DwarfMaleHero"] = true,
	["ElfFemaleHero"] = true,
	["ElfMaleHero"] = true,
	["LizardFemaleHero"] = true,
	["LizardMaleHero"] = true,
	["HumanUndeadFemaleHero"] = true,
	["HumanUndeadMaleHero"] = true,
	["DwarfUndeadFemaleHero"] = true,
	["DwarfUndeadMaleHero"] = true,
	["ElfUndeadFemaleHero"] = true,
	["ElfUndeadMaleHero"] = true,
	["LizardUndeadFemaleHero"] = true,
	["LizardUndeadMaleHero"] = true,
	["_Companions"] = true,
	["StoryPlayer"] = true,
	["CasualPlayer"] = true,
	["NormalPlayer"] = true,
	["HardcorePlayer"] = true,
	["Player_Ifan"] = true,
	["Player_Lohse"] = true,
	["Player_RedPrince"] = true,
	["Player_Sebille"] = true,
	["Player_Beast"] = true,
	["Player_Fane"] = true,
	--["Summon_Earth_Ooze_Player"] = true,
}

local function ModuleLoading_AddIndomatible()
	Ext.Print("===================================================================")
	Ext.Print("[IndomitableForAll:Bootstrap.lua] Adding Indomitable to all Character stats.")
	local totalOverrides = 0
	for i,stat in pairs(Ext.GetStatEntries("Character")) do
		if not player_stats[stat] then
			local talents = Ext.StatGetAttribute(stat, "Talents")
			if talents == nil or talents == "" then
				Ext.StatSetAttribute(stat, "Talents", "Indomitable")
				totalOverrides = totalOverrides + 1
			else
				if talents:find("Indomitable", 1, true) ~= nil then
					Ext.Print("[IndomitableForAll:Bootstrap.lua] Stat ("..stat..") already has Indomitable ("..talents.."). Skipping.")
				else
					Ext.StatSetAttribute(stat, "Talents", talents..";Indomitable")
					totalOverrides = totalOverrides + 1
				end
			end
		end
	end
	Ext.Print("[IndomitableForAll:Bootstrap.lua] Added the Indomitable talent to "..tostring(totalOverrides).." Character stats.")
	Ext.Print("===================================================================")
end

--Ext.RegisterListener("ModuleLoading", ModuleLoading_AddIndomatible)

function LLINDOMITABLE_Ext_AddTalent(character, talent)
	if CharacterHasTalent(character, talent) ~= 1 then
		if Ext.Version() >= 40 then
			Osi.NRD_CharacterSetPermanentBoostTalent(character, talent, 1)
			CharacterAddAttribute(character, "Dummy", 0)
		else
			Ext.Print("[IndomitableForAll:Bootstrap.lua] *WARNING* The extender is version ("..Ext.Version()..") but it requires >= 40 to add talents to NPCs!")
		end
	end
end

function LLINDOMITABLE_Ext_RemoveTalent(character, talent)
	if CharacterHasTalent(character, talent) == 1 then
		if Ext.Version() >= 40 then
			Osi.NRD_CharacterSetPermanentBoostTalent(character, talent, 0)
			CharacterAddAttribute(character, "Dummy", 0)
		else
			Ext.Print("[IndomitableForAll:Bootstrap.lua] *WARNING* The extender is version ("..Ext.Version()..") but it requires >= 40 to add talents to NPCs!")
		end
	end
end

function LLINDOMITABLE_Ext_UpdateMod()
	local info = Ext.GetModInfo("7f5124c0-da04-4ce1-aa73-e22ed00bb711")
	Osi.LLINDOMITABLE_OnGetVersion(info.Version)
end

--[[ ["InstantKnockdown"] = true,
["UNCONSCIOUS"] = true,
["SHOCKWAVE"] = true,
["PUZZLE_RAT"] = true,
["SHAPESHIFT_HUMAN"] = true,
["SHAPESHIFT_LIZARD"] = true,
["SHAPESHIFT_DWARF"] = true,
["SHAPESHIFT_ELF"] = true,
["UNDEAD_HUMAN"] = true,
["UNDEAD_LIZARD"] = true,
["UNDEAD_DWARF"] = true,
["UNDEAD_ELF"] = true,
["UNDEAD_IFAN"] = true,
["UNDEAD_LOHSE"] = true,
["UNDEAD_BEAST"] = true,
["UNDEAD_SEBILLE"] = true,
["UNDEAD_RED_PRINCE"] = true,
["UNDEAD_RED_PRINCE"] = true,
["FANE_ELF"] = true,
["DALLISDRAGON"] = true,
["DALLISDRAGON_COMBAT"] = true, ]]

local immunity_flags = {
	["StunImmunity"] = true,
	["FreezeImmunity"] = true,
	["KnockdownImmunity"] = true,
	["PetrifiedImmunity"] = true,
	["ChickenImmunity"] = true,
	["CrippledImmunity"] = true,
	["CharmImmunity"] = true,
}

--- No StatusData entries
local engine_statuses = {
	["CHARMED"] = "CharmImmunity",
}

local resisted_statuses = {}

local function SessionLoading()
	Ext.Print("[IndomitableForAll:Bootstrap.lua] Building status list for Indomitable.")
	Ext.Print("===================================================================")
	local total = 0
	for stat,b in pairs(engine_statuses) do
		total = total + 1
		Ext.Print("[IndomitableForAll:Bootstrap.lua] Adding engine status ("..stat..").")
		resisted_statuses[stat] = true
	end
	for i,stat in pairs(Ext.GetStatEntries("StatusData")) do
		local flag = Ext.StatGetAttribute(stat, "ImmuneFlag")
		if immunity_flags[flag] == true then
			total = total + 1
			Ext.Print("[IndomitableForAll:Bootstrap.lua] Adding status ("..stat..").")
			resisted_statuses[stat] = flag
		end
	end
	Ext.Print("[IndomitableForAll:Bootstrap.lua] Listening for "..tostring(total).." statuses for Indomitable.")
	Ext.Print("===================================================================")
end

Ext.RegisterListener("SessionLoading", SessionLoading)

local ignore_character_flags = {
	["LEADERLIB_IGNORE"] = true,
}

local ignore_character_tags = {
	["LeaderLib_Dummy"] = true,
	["LLMIME_Dummy"] = true,
	["LLMIME_Decoy"] = true,
}

local function is_immune(character, status)
	local flag = resisted_statuses[status]
	if flag ~= nil and NRD_CharacterGetStatInt(character, flag) > 0 then
		Ext.Print("[IndomitableForAll:Bootstrap.lua] ("..character..") is immune to ("..status..") via ("..flag..")")
		return true
	end
	return false
end

local function ignore_character(character)
	if HasActiveStatus(character, "LLINDOMITABLE_INDOMITABLE") == 1 or HasActiveStatus(character, "LLINDOMITABLE_INDOMITABLE_CD") == 1 then
		return true
	else
		--if Ext.IsModLoaded("7e737d2f-31d2-4751-963f-be6ccc59cd0c") then -- LeaderLib
		for flag,_ in pairs(ignore_character_flags) do
			if ObjectGetFlag(character, flag) == 1 then
				return true
			end
		end
		for tag,_ in pairs(ignore_character_tags) do
			if IsTagged(character, tag) == 1 then
				return true
			end
		end
	end
	return false
end

local ignored_statuses = {
	["HIT"] = true,
	["INSURFACE"] = true,
	["LLINDOMITABLE_INDOMITABLE"] = true,
	["LLINDOMITABLE_INDOMITABLE_CD"] = true,
	["InstantKnockdown"] = true,
}

local INDOMITABLE_CHANCE = 100.0

local function LLINDOMITABLE_CanApplyIndomitable(character, status)
	--if ignored_statuses[status] ~= true and resisted_statuses[status] == true then
	if (ignored_statuses[status] ~= true and ignore_character(character) == false and 
			resisted_statuses[status] ~= nil and is_immune(character, status) == false) then
		if INDOMITABLE_CHANCE >= 100.0 then
			return 1
		elseif INDOMITABLE_CHANCE <= 0.0 then
			return 0
		elseif Ext.Random(1,100) <= INDOMITABLE_CHANCE then
			return 1
		end
	end
	return 0
end

Ext.NewQuery(LLINDOMITABLE_CanApplyIndomitable, "LLINDOMITABLE_QRY_CanApplyIndomitable", "[in](CHARACTERGUID)_Character, [in](STRING)_Status, [out](INTEGER)_Bool")

function LLINDOMITABLE_Ext_SetIndomitableChance(chance)
	INDOMITABLE_CHANCE = tonumber(chance)
	Ext.Print("[IndomitableForAll:Bootstrap.lua] Set Indomitable Chance to ("..tostring(chance)..").")
end