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

local function ModuleSetup_StatOverrides()
	-- So Madness can be blocked
	Ext.StatSetAttribute("MADNESS", "ImmuneFlag", "MadnessImmunity")
end

Ext.RegisterListener("ModuleLoading", ModuleSetup_StatOverrides)
--Ext.RegisterListener("ModuleResume", ModuleSetup_StatOverrides)