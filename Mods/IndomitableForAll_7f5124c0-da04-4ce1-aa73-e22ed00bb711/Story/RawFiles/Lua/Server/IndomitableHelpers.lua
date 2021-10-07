INDOMITABLE_CHANCE = 100.0

local function IsImmuneToStatus(character, status)
	local flag = STATUSES.Resisted[status]
	if flag ~= nil and NRD_CharacterGetStatInt(character, flag) > 0 then
		--Ext.Print("[IndomitableForAll] ("..character..") is immune to ("..status..") via ("..flag..")")
		return true
	end
	return false
end

local function IgnoreCharacter(character)
	if HasActiveStatus(character, "LLINDOMITABLE_INDOMITABLE") == 1 
	or HasActiveStatus(character, "LLINDOMITABLE_INDOMITABLE_CD") == 1
	or CharacterIsDead(character) == 1
	or ObjectIsOnStage(character) == 0
	then
		return true
	else
		--if Ext.IsModLoaded("7e737d2f-31d2-4751-963f-be6ccc59cd0c") then -- LeaderLib
		for flag,_ in pairs(IGNORED.Flags) do
			if ObjectGetFlag(character, flag) == 1 then
				return true
			end
		end
		for tag,_ in pairs(IGNORED.Tags) do
			if IsTagged(character, tag) == 1 then
				return true
			end
		end
	end
	return false
end

function ApplyIndomitable(target, onRemoval)
	if onRemoval or GlobalGetFlag("LLINDOMITABLE_Settings_ApplyOnAttempt") == 0 then
		ApplyStatus(target, "LLINDOMITABLE_INDOMITABLE", Ext.ExtraData.LLINDOMITABLE_IndomitableDuration_OnRemoval or 6.0, 0, target)
	else
		ApplyStatus(target, "LLINDOMITABLE_INDOMITABLE", Ext.ExtraData.LLINDOMITABLE_IndomitableDuration_OnAttempt or 12.0, 0, target)
	end
end

function IsResistedStatus(character, status)
	if (IGNORED.Statuses[status] ~= true and IgnoreCharacter(character) == false and
			STATUSES.Resisted[status] ~= nil and IsImmuneToStatus(character, status) == false) then
		return true
	end
	return false
end

function CanApplyIndomitable(character, status)
	--if ignored_statuses[status] ~= true and resisted_statuses[status] == true then
	if IsResistedStatus(character, status) then
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