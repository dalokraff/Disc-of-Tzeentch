--mod:dofile("scripts/mods/Disc of Tzeentch/utils/disc_buff")
local mod = get_mod("Disc of Tzeentch")
mod:dofile("scripts/mods/Disc of Tzeentch/utils/unit")
mod:dofile("scripts/mods/Disc of Tzeentch/utils/strManip")
mod:dofile("scripts/mods/Disc of Tzeentch/utils/InputHandler")
mod:dofile("scripts/mods/Disc of Tzeentch/utils/mod_rpcs")
mod:dofile("scripts/mods/Disc of Tzeentch/utils/network_tables")

-- Your mod code goes here.
-- https://vmf-docs.verminti.de

--directional states when on disc
mod.down = false
mod.up = true
mod.left = false
mod.richt = false
mod.forward = false
mod.backward = false

--table for keepign track of disc-rider pairs
mod.mounted_players = {}

mod.ascend = function()
    mod.up = not mod.up
end

mod.descend = function()
    mod.down = not mod.down
end

mod.player_hot_join = false

Managers.package:load("resource_packages/levels/dlcs/morris/tzeentch_common", "global")

math.randomseed(1)

function mod.update()
        if mod.mounted_players[1] ~= nil then
            local world = Managers.world:world("level_world")
            if  mod.player_hot_join and Managers.player:local_player().is_server then
                
                local list_of_mounts_in_world = World.units_by_resource(world, "units/disc_tzeentch/disc")
                local unit_pos_list = {}
                for _,v in pairs(list_of_mounts_in_world) do
                    for _,j in pairs(mod.mounted_players) do
                        if Unit.get_data(v, "current_rider") == j.rider then
                            local unitPos = Unit.local_position(v, 0)
                            local unitRot = Unit.local_rotation(v, 0)
                            local Xx,Yy,Zz,Ww = Quaternion.to_elements(unitRot)
                            local unit_marker = Unit.get_data(v, "unit_marker")
                            unit_pos_list[j.rider] = {
                                x = unitPos.x,
                                y = unitPos.y,
                                z = unitPos.z,
                                x1 = Xx,
                                y1 = Yy,
                                z1 = Zz,
                                w1 = Ww,
                                unit_marker = Unit.get_data(v, "unit_marker")
                            }
                        end
                    end
                end
                
                mod:network_send("rpc_snyc_mounts","others", mod.mounted_players, unit_pos_list)
                mod.player_hot_join = false
            end
            mod.handle_inputs()
            mod.drag_unit(world)
        end    
end

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

mod:hook(LevelTransitionHandler, "load_current_level", function(func, self)
    for k,v in pairs(mod.mounted_players) do 
        table.remove(mod.mounted_players, k)
    end
    return func(self)
end)


mod:hook(GameModeManager, "rpc_to_client_spawn_player", function (func, self, channel_id, local_player_id, profile_index, career_index, position, rotation, is_initial_spawn)
    mod:network_send("rpc_request_mount_snyc", "others")
    return func(self, channel_id, local_player_id, profile_index, career_index, position, rotation, is_initial_spawn)
end)

--defines the custom buff that is applied while riding the disc
local test_buff_templates = {
	disc_buff = {
		buffs = {
			{
				max_stacks = 1,
                remove_buff_func = "remove_movement_buff",
				apply_buff_func = "apply_movement_buff",
				icon = "victor_zealot_passive_move_speed",
                refresh_durations = true,
				multiplier = 2,
                path_to_movement_setting_to_modify = {
                    "move_speed"
                }
			}
		}
	}
}
BuffTemplates["disc_buff"] = test_buff_templates.disc_buff
BuffUtils.copy_talent_buff_names(test_buff_templates)

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
            mod:echo(interactor_unit)
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



function mod.spawn_network_package()
    local player = Managers.player:local_player()
    local player_unit = player.player_unit
    local position = Unit.local_position(player_unit, 0) + Vector3(0, 0, 1)
    local rotation = Unit.local_rotation(player_unit, 0)
    local posList = { position.x, position.y, position.z }
    local x,y,z,w = Quaternion.to_elements(rotation)
    local rotList = { x,y,z,w }
    local unit_marker = math.random(10000)

    mod:network_send("rpc_spawn_mount","all", posList, rotList, unit_marker)
    
    mod:echo('++++')
    for k,v in pairs(Managers.player._players_by_peer) do
        mod:echo(k)
        mod:echo(v)
    end
    mod:echo('++++')
    mod:echo(player:network_id())
end

mod:command("disc_net", "", function() 
    mod.spawn_network_package()
    mod:echo('spawned')
end)

SpawnUnitTemplates = SpawnUnitTemplates or {}
SpawnUnitTemplates.disc_unit = {
    spawn_func = function (source_unit, position, rotation)
        local package_name = "units/disc_tzeentch/disc"
        local unit_template_name = "interaction_unit"
        local extension_init_data = {}
        local material = "units/props/tzeentch/tzeentch_faction_01"
        local unit_spawner = Managers.state.unit_spawner

        local unit, go_id = unit_spawner:spawn_network_unit(package_name, unit_template_name, extension_init_data, position, rotation)
        Unit.set_material(unit, "disc", material)
        mod:echo(Managers.state.unit_storage:go_id(unit))
        mod:echo('test')
        mod:echo(go_id)
        
    end
}

--this defines the custom interaction that is called when interacting with the disc
InteractionHelper = InteractionHelper or {}
InteractionHelper.interactions.mount_interaction = {}
for _, config_table in pairs(InteractionHelper.interactions) do
	config_table.request_rpc = config_table.request_rpc or "rpc_generic_interaction_request"
end

InteractionDefinitions["mount_interaction"] = InteractionDefinitions.mount_interaction or table.clone(InteractionDefinitions.smartobject)
InteractionDefinitions.mount_interaction.config.swap_to_3p = false
InteractionDefinitions.mount_interaction.config.request_rpc = "rpc_generic_interaction_request" --"rpc_request_spawn_network_unit"

InteractionDefinitions.mount_interaction.server.stop = function (world, interactor_unit, interactable_unit, data, config, t, result)
    if result == InteractionResult.SUCCESS then
        local interactable_system = ScriptUnit.extension(interactable_unit, "interactable_system")
        interactable_system.num_times_successfully_completed = interactable_system.num_times_successfully_completed + 1

    end
end

InteractionDefinitions.mount_interaction.client.can_interact = function (interactor_unit, interactable_unit, data, config)
	return true
end

InteractionDefinitions.mount_interaction.client.stop = function (world, interactor_unit, interactable_unit, data, config, t, result)
	data.start_time = nil

	if result == InteractionResult.SUCCESS and not data.is_husk then
	    if interactable_unit then

            local player = Managers.player:local_player()
            local currentRider = player:network_id()
            local currentMount = Unit.get_data(interactable_unit, "unit_marker")

            if Unit.get_data(interactable_unit, "current_rider") == currentRider then 
                local buff_to_remove = Unit.get_data(interactable_unit, "interaction_data", "apply_buff")
                local buff_extension = ScriptUnit.extension(interactor_unit, "buff_system")
                local active_buff = buff_extension:get_non_stacking_buff(buff_to_remove)
                buff_extension:remove_buff(active_buff.id)                
            end

            local disc_pos = Unit.local_position(interactable_unit, 0)
            local zilch = Vector3.zero()
            Vector3.set_z(zilch, 0.3)
            disc_pos = disc_pos + zilch
            Unit.set_local_position(interactor_unit, 0, disc_pos)
            
            mod:echo(Unit.get_data(interactable_unit, "current_rider"))
            if Unit.get_data(interactable_unit, "current_rider") == "no_one" then
                --Unit.set_data(interactable_unit, "current_rider", currentRider)
                mod:network_send("rpc_add_rider","all", currentRider, currentMount)
                
            else
                --Unit.set_data(interactable_unit, "current_rider", "no_one")
                mod:network_send("rpc_remove_rider","all", currentRider, currentMount)
            end
            mod:echo(Unit.get_data(interactable_unit, "current_rider"))


        end

	end
end

InteractionDefinitions.mount_interaction.client.hud_description = function (interactable_unit, data, config, fail_reason, interactor_unit)
	return Unit.get_data(interactable_unit, "interaction_data", "hud_description"), "Mount"
end

