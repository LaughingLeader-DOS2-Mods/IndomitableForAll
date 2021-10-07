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
			return true
		elseif INDOMITABLE_CHANCE <= 0.0 then
			return false
		elseif Ext.Random(1,100) <= INDOMITABLE_CHANCE then
			return true
		end
	end
	return false
end

--Reducing the cooldown status' duration when resisted statuses are applied
Helpers.RegisterProtectedOsirisListener("CharacterStatusApplied", 3, "after", function(target, status, source)
	if HasActiveStatus(target, "LLINDOMITABLE_INDOMITABLE_CD") == 1 and STATUSES.Resisted[status] then
		local character = Ext.GetCharacter(target)
		local cooldownStatus = character:GetStatus("LLINDOMITABLE_INDOMITABLE_CD")
		local cooldownBaseDuration = Ext.ExtraData.LLINDOMITABLE_IndomitableCooldownDuration or 18.0
		-- Let resisted statuses reduce cooldown duration when it's at 2 turns or less, so it's guaranteed for one turn
		if cooldownStatus and cooldownBaseDuration > 0 and cooldownStatus.CurrentLifeTime <= (cooldownBaseDuration - 6.0) then
			cooldownStatus.CurrentLifeTime = math.max(0.0, cooldownStatus.CurrentLifeTime - 6.0)
			cooldownStatus.RequestClientSync = true
			local exaustionText = Ext.GetTranslatedStringFromKey("LLINDOMITABLE_StatusText_CooldownReduced")
			if not exaustionText or exaustionText == "" then
				exaustionText = "<font color='#CCCC00'>Exhaustion Reduced</font>"
			end
			CharacterStatusText(target, exaustionText)
		end
	end
end)

Helpers.RegisterProtectedOsirisListener("CharacterStatusRemoved", 3, "after", function(target, status, nilSource)
	if status == "LLINDOMITABLE_INDOMITABLE" then
		ApplyStatus(target, "LLINDOMITABLE_INDOMITABLE_CD", Ext.ExtraData.LLINDOMITABLE_IndomitableCooldownDuration or 18.0, 0, target)
	else
		if GlobalGetFlag("LLINDOMITABLE_Settings_ApplyOnAttempt") == 0 then
			if CanApplyIndomitable(target, status) then
				ApplyIndomitable(target, true)
			end
		end
	end
end)

Helpers.RegisterProtectedOsirisListener("NRD_OnStatusAttempt", 4, "after", function(target, status, handle, source)
	if GlobalGetFlag("LLINDOMITABLE_Settings_ApplyOnAttempt") == 1 then
		local chance = NRD_StatusGetInt(target, handle, "CanEnterChance")
		if chance == 0 then
			return
		end
		if CanApplyIndomitable(target, status) then
			ApplyIndomitable(target, true)
		end
	end
end)