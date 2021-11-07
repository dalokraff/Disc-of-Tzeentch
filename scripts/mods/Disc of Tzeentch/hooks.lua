local mod = get_mod("Disc of Tzeentch")

mod:hook(PackageManager, "load",
         function(func, self, package_name, reference_name, callback,
                  asynchronous, prioritize)
    if package_name ~= "units/disc_tzeentch/disc" then
        func(self, package_name, reference_name, callback, asynchronous,
             prioritize)
    end
	
end)
mod:hook(PackageManager, "unload",
         function(func, self, package_name, reference_name)
    if  package_name ~= "units/disc_tzeentch/disc" then
        func(self, package_name, reference_name)
    end
	
end)
mod:hook(PackageManager, "has_loaded",
         function(func, self, package, reference_name)
    if package == "units/disc_tzeentch/disc" then
        return true
    end
	
    return func(self, package, reference_name)
end)

--bypasses the local error function, removing the "<>" for this mod's localized text
mod:hook(LocalizationManager, "_base_lookup", function (func, self, text_id)
    if not string.find(mod:localize(text_id), "<") then
        return mod:localize(text_id)
    end

	return func(self, text_id)
end)

--resets the list of mounted discs when a new level is loaded
mod:hook(LevelTransitionHandler, "load_current_level", function(func, self)
    for k,v in pairs(mod.mounted_players) do 
        table.remove(mod.mounted_players, k)
    end
    return func(self)
end)

--tells the host that a player is hot joining and to send their list of mounts and riders
mod:hook(GameModeManager, "rpc_to_client_spawn_player", function (func, self, channel_id, local_player_id, profile_index, career_index, position, rotation, is_initial_spawn)
    mod:network_send("rpc_request_mount_snyc", "others")
    return func(self, channel_id, local_player_id, profile_index, career_index, position, rotation, is_initial_spawn)
end)

--prevents the walking animations from playing when a player is on the disc
mod:hook(GameNetworkManager, "anim_event", function (func, self, unit, event)
    local calvary = mod.mounted_players

    for _,v in pairs(calvary) do
        local player_unit = Managers.player._players_by_peer[v.rider][1].player_unit
        if unit == player_unit then
            event = "idle"
        end
    end
    return func(self, unit, event)

end)


--makes sure that the disc's extension data is applied to the unit; prevents crashing when of other clients/host when interacting with the disc
mod:hook(ScriptUnit, "extension", function(func, unit_1, system_name)
    local Entities = rawget(_G, "G_Entities")

    local unit_extensions = Entities[unit_1]
	local extension = unit_extensions and unit_extensions[system_name]

    if extension == nil then 
        extension = {
            _is_level_object = false,
            unit = unit_1,
            num_times_successfully_completed = 0,
            interactable_type = "mount_interaction",
            interaction_result = "2",
            _enabled = true
        }
        extension.destroy = function (self)
            return
        end
        extension.interaction_type = function (self)
            return self.interactable_type
        end
        extension.set_is_being_interacted_with = function (self, interactor_unit, interaction_result)
            local unit = self.unit
            local interaction_type = self.interactable_type
            self.interactor_unit = interactor_unit
            self.interaction_result = interaction_result
        end
        extension.is_being_interacted_with = function (self)
            return self.interactor_unit
        end
        extension.is_enabled = function (self)
            return self._enabled
        end
        extension.set_enabled = function (self, enabled)
            self._enabled = enabled
        end        
    end
	return extension
end)


--adding the new interaction to the list of unit extensions
local unit_templates_to_add = {
    mount_interaction = {
        go_type = "",
        self_owned_extensions = {
            "UnitSynchronizationExtension",
            "PingTargetExtension",
            "GenericUnitInteractableExtension",
            "ElevatorOutlineExtension"
        },
        husk_extensions = {
            "UnitSynchronizationExtension",
            "PingTargetExtension",
            "GenericUnitInteractableExtension",
            "ElevatorOutlineExtension"
        }

    }
}

local unit_templates = require("scripts/network/unit_extension_templates")
table.merge(unit_templates, unit_templates_to_add)

--makes sure the disc's extensions gets added to the "unit_templates" table used by the unit_templates class
mod:hook(unit_templates, "get_extensions", function (func, unit_template_name, is_husk, is_server)
    local extensions, num_extensions = nil
	local template = unit_templates[unit_template_name]

	if is_husk then
		if is_server and template.husk_extensions_server then
			num_extensions = template.num_husk_extensions_server
			extensions = template.husk_extensions_server
		else
			num_extensions = template.num_husk_extensions
			extensions = template.husk_extensions
		end
	elseif is_server and template.self_owned_extensions_server then
		num_extensions = template.num_self_owned_extensions_server
		extensions = template.self_owned_extensions_server
	else
		num_extensions = template.num_self_owned_extensions
		extensions = template.self_owned_extensions
	end

	return extensions, num_extensions
end)

mod:hook(unit_templates, "extensions_to_remove_on_death", function (func, unit_template_name, is_husk, is_server)
    local extensions, num_extensions = nil
	local remove_when_killed = unit_templates[unit_template_name].remove_when_killed

	if remove_when_killed == nil then
		return nil
	end

	if is_husk then
		if is_server and remove_when_killed.husk_extensions_server then
			num_extensions = remove_when_killed.num_husk_extensions_server
			extensions = remove_when_killed.husk_extensions_server
		else
			num_extensions = remove_when_killed.num_husk_extensions
			extensions = remove_when_killed.husk_extensions
		end
	elseif is_server and remove_when_killed.self_owned_extensions_server then
		num_extensions = remove_when_killed.num_self_owned_extensions_server
		extensions = remove_when_killed.self_owned_extensions_server
	else
		num_extensions = remove_when_killed.num_self_owned_extensions
		extensions = remove_when_killed.self_owned_extensions
	end

	return extensions, num_extensions
end)

