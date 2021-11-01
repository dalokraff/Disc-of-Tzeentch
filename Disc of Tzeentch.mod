return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Disc of Tzeentch` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("Disc of Tzeentch", {
			mod_script       = "scripts/mods/Disc of Tzeentch/Disc of Tzeentch",
			mod_data         = "scripts/mods/Disc of Tzeentch/Disc of Tzeentch_data",
			mod_localization = "scripts/mods/Disc of Tzeentch/Disc of Tzeentch_localization",
		})
	end,
	packages = {
		"resource_packages/Disc of Tzeentch/Disc of Tzeentch",
	},
}
