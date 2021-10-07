--Reducing the cooldown status' duration when resisted statuses are applied
Helpers.RegisterProtectedOsirisListener("CharacterStatusApplied", 3, "after", function(target, status, source)
	if HasActiveStatus(target, "LLINDOMITABLE_INDOMITABLE_CD") == 1 and IsResistedStatus(target, status) then
		local character = Ext.GetCharacter(target)
		local cooldownStatus = character:GetStatus("LLINDOMITABLE_INDOMITABLE_CD")
		if cooldownStatus and cooldownStatus.CurrentLifeTime > 0 then
			cooldownStatus.CurrentLifeTime = math.max(0.0, cooldownStatus.CurrentLifeTime - 6.0)
			cooldownStatus.RequestClientSync = true
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