local mod = get_mod("Disc of Tzeentch")

--rpcs used by the mod
mod:network_register("rpc_request_mount_snyc", function(sender)
    mod.player_hot_join = true
end)

mod:network_register("rpc_snyc_mounts", function(sender, list_mount, unitPos)
    if mod.mounted_players ~= list_mount then 
        local package_name = "units/disc_tzeentch/disc"
        local world = Managers.world:world("level_world")
        local material = "units/props/tzeentch/tzeentch_faction_01"
        local extension_init_data = {}
        local unit_spawner = Managers.state.unit_spawner
        local unit_template_name = "interaction_unit"
        for _,v in pairs(list_mount) do 
            local currentRider = v.rider --rider id
            local unit_marker = unitPos[currentRider].unit_marker --unit marker
            local unit_pos = Vector3(unitPos[currentRider].x, unitPos[currentRider].y, unitPos[currentRider].z)
            local unit_rot = Quaternion.from_elements(unitPos[currentRider].x1, unitPos[currentRider].y1, unitPos[currentRider].z1, unitPos[currentRider].w1)

            local unit, go_id = unit_spawner:spawn_network_unit(package_name, unit_template_name, extension_init_data, unit_pos, unit_rot, material)
            Unit.set_material(unit, "disc", material)
            Unit.set_data(unit, "current_rider", currentRider)
            Unit.set_data(unit, "unit_marker", unit_marker)

            table.insert(mod.mounted_players, v)
        end
    end

end)

mod:network_register("rpc_spawn_mount", function(sender, posList, rotList, unit_mark)
    local package_name = "units/disc_tzeentch/disc"
    local world = Managers.world:world("level_world")
    local material = "units/props/tzeentch/tzeentch_faction_01"
    local extension_init_data = {}
    local unit_spawner = Managers.state.unit_spawner
    local unit_template_name = "interaction_unit"

    local unit_pos = Vector3(posList[1], posList[2], posList[3])
    local unit_rot = Quaternion.from_elements(rotList[1], rotList[2], rotList[3], rotList[4])
    
    local unit, go_id = unit_spawner:spawn_network_unit(package_name, unit_template_name, extension_init_data, unit_pos, unit_rot, material)
    Unit.set_material(unit, "disc", material)
    Unit.set_data(unit, "unit_marker", unit_mark)
    
    mod:echo(Unit.get_data(unit, "unit_marker"))
    mod:echo(go_id)
    mod:echo(sender)
end)

mod:network_register("rpc_add_rider", function(sender, new_rider, mount_marker)
    local mount_table = {
        rider = new_rider
    }
    mod:echo(new_rider)
    mod:echo('------')
    table.insert(mod.mounted_players, mount_table)
    local world = Managers.world:world("level_world")
    local list_of_mounts_in_world = World.units_by_resource(world, "units/disc_tzeentch/disc")
    for _,mount in pairs(list_of_mounts_in_world) do
        if Unit.get_data(mount, "unit_marker") == mount_marker then
            Unit.set_data(mount, "current_rider", new_rider)
        end
    end
    
    mod:echo('------')
end)

mod:network_register("rpc_remove_rider", function(sender, removed_rider, mount_marker)
    for k,v in pairs(mod.mounted_players) do 
        if v.rider == removed_rider then 
            table.remove(mod.mounted_players, k)
        end
    end
    local world = Managers.world:world("level_world")
    local list_of_mounts_in_world = World.units_by_resource(world, "units/disc_tzeentch/disc")
    for _,mount in pairs(list_of_mounts_in_world) do
        if Unit.get_data(mount, "unit_marker") == mount_marker then
            Unit.set_data(mount, "current_rider", "no_one")
        end
    end

end)

return