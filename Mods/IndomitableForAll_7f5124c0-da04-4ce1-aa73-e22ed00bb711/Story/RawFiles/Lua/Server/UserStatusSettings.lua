local function SaveSettingsFile(data)
	Ext.SaveFile("IndomitableForAll_StatusSettings.json", Ext.JsonStringify(data or {
		Ignored = {},
		Resisted = {}
	}))
end

Ext.RegisterOsirisListener("GameStarted", 2, "after", function()
	local userFile = Ext.LoadFile("IndomitableForAll_StatusSettings.json")
	if userFile then
		local settings = Ext.JsonParse(userFile)
		if settings then
			if settings.Ignored then
				for _,v in pairs(settings.Ignored) do
					if type(v) == "string" then
						IGNORED.Statuses[v] = true
					end
				end
			end
			if settings.Resisted then
				for _,v in pairs(settings.Resisted) do
					if type(v) == "string" then
						IGNORED.Statuses[v] = nil
						local stat = Ext.GetStat(v)
						if stat then
							STATUSES.Resisted[v] = stat.ImmuneFlag or ""
						end
					end
				end
			end
		else
			SaveSettingsFile()
		end
	else
		SaveSettingsFile()
	end
end)