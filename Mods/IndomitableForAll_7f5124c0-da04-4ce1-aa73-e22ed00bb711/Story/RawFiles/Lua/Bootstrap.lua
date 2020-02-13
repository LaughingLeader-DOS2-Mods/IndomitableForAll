local function ModuleLoad()
	Ext.Print("===================================================================")
	Ext.Print("[IndomitableForAll:Bootstrap.lua] Adding Indomitable to all Character stats.")
	local totalOverrides = 0
	for i,stat in pairs(Ext.GetStatEntries("Character")) do
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
	Ext.Print("[IndomitableForAll:Bootstrap.lua] Added the Indomitable talent to "..tostring(totalOverrides).." Character stats.")
	Ext.Print("===================================================================")
end

Ext.RegisterListener("ModuleLoading", ModuleLoad)

function LLINDOMITABLE_AddTalent(character, talent)
	if CharacterHasTalent(character, "Indomitable") ~= 1 then
		if Ext.Version() >= 40 then
			Osi.NRD_CharacterSetPermanentBoostTalent(character, talent, 1)
			CharacterAddAttribute(character, "Dummy", 0)
		else
			Ext.Print("[IndomitableForAll:Bootstrap.lua] *WARNING* The extender is version ("..Ext.Version()..") but it requires >= 40 to add talents to NPCs!")
		end
	end
end