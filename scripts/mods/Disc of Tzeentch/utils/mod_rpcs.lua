local mod = get_mod("Disc of Tzeentch")

--rpcs used by the mod
mod:network_register("rpc_request_mount_snyc", function(sender)
    mod.player_hot_join = true
end)

--syncs the currently spawned in disc units with the host when a client hot joins
mod:network_register("rpc_snyc_mounts", function(sender, list_mount, unitPos)
        local package_name = "units/disc_tzeentch/disc"
        local world = Managers.world:world("level_world")
        local material = "units/props/tzeentch/tzeentch_faction_01"
        local extension_init_data = {}
        local unit_spawner = Managers.state.unit_spawner
        local unit_template_name = "interaction_unit"
        if list_mount["empty"] then
            if list_mount["empty"]["empty"] == "empty" then
                list_mount = {}
            end
        end
        for _,j in pairs(unitPos) do
            local unit_marker = j.unit_marker
            local unit_pos = Vector3(j.x, j.y, j.z)
            local unit_rot = Quaternion.from_elements(j.x1, j.y1, j.z1, j.w1)

            local unit, go_id = unit_spawner:spawn_network_unit(package_name, unit_template_name, extension_init_data, unit_pos, unit_rot, material)
            Unit.set_material(unit, "disc", material)
            Unit.set_data(unit, "unit_marker", unit_marker)
            for _,v in pairs(list_mount) do 
                if unitPos[v.rider].unit_marker == unit_marker then
                    Unit.set_data(unit, "current_rider", v.rider)
                    table.insert(mod.mounted_players, v)
                end
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
end)

--adds or removes a rider(player) when then mount or dismount (interact with) from the disc
mod:network_register("rpc_add_rider", function(sender, new_rider, mount_marker)
    local mount_table = {
        rider = new_rider
    }
    table.insert(mod.mounted_players, mount_table)
    local world = Managers.world:world("level_world")
    local list_of_mounts_in_world = World.units_by_resource(world, "units/disc_tzeentch/disc")
    for _,mount in pairs(list_of_mounts_in_world) do
        if Unit.get_data(mount, "unit_marker") == mount_marker then
            Unit.set_data(mount, "current_rider", new_rider)
        end
    end
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