local mod = get_mod("Disc of Tzeentch")

--this funciton is for calculating the disc tilt, the quaternions for left rigth tilt aren't in the player's reference frame currently
local function calculate_rotation(look_delta)
    local iR,jR,kR = Quaternion.to_euler_angles_xyz(look_delta:unbox())
    local original_rotation = Quaternion.from_euler_angles_xyz(iR,jR,kR)
  
    local target_rot1 = Quaternion.from_euler_angles_xyz(0,0,0)
    if mod.forward then 
        target_rot1 = Quaternion.from_euler_angles_xyz(20,0,0)
    end
    if mod.backward then 
        target_rot1 = Quaternion.from_euler_angles_xyz(-20,0,0)
    end

    local target_rot2 = Quaternion.from_euler_angles_xyz(0,0,0)
    if mod.richt then 
        target_rot2 = Quaternion.from_euler_angles_xyz(0,20,0)
    end
    if mod.left then 
        target_rot2 = Quaternion.from_euler_angles_xyz(0,-20,0)
    end

    local new_rotation1 = Quaternion.multiply(Quaternion.conjugate(original_rotation), target_rot1)
    local new_rotation2 = Quaternion.multiply(Quaternion.conjugate(original_rotation), target_rot2)

    return Quaternion.conjugate(Quaternion.multiply(new_rotation1, new_rotation2))
end

--this is the a modified drag function from UnitExplorer and sets the position and rotation of the disc relatvie to the player 
function mod.drag_unit(world)    
    
    local calvary = mod.mounted_players
    
    -- for k,v in pairs(mod.mounted_players) do 
    --     mod:echo(k)
    --     for i,j in pairs(v) do
    --         mod:echo(i)
    --         mod:echo(j)
    --     end
    -- end

    for k,v in pairs(calvary) do 
        --local list_of_mounts_in_world = World.unit_by_name(world, v.mount)
        local list_of_mounts_in_world = World.units_by_resource(world, "units/disc_tzeentch/disc")
        for _,mounts in pairs(list_of_mounts_in_world) do 
            if Unit.get_data(mounts, "current_rider") == v.rider then
                local unit = mounts

                if not Managers.player._players_by_peer[v.rider] then 
                    Unit.set_data(unit, "current_rider", "no_one")
                    mod:network_send("rpc_remove_rider","all", v.rider, v.mount)
                    break
                end

                local player_unit = Managers.player._players_by_peer[v.rider][1].player_unit

                if Unit.alive(unit) then 
                    local player_pos = Unit.local_position(player_unit, 0)
                    
                    --this is *the true* local player
                    local new_position = player_pos
                    local player = Managers.player:local_player()
                    local client_player_unit = player.player_unit

                    --performs a check to see if the rider is is *the true* local player
                    if (player_unit == client_player_unit) then
                        if mod.down then 
                            local zilch = Vector3.zero()
                            --Vector3.set_z(zilch, 0.3) for old size
                            Vector3.set_z(zilch, 0.075)
                            new_position = player_pos - zilch
                        end 
                        if mod.up then
                            local zilch = Vector3.zero()
                            --Vector3.set_z(zilch, 0.1)
                            Vector3.set_z(zilch, 0.2)
                            new_position = player_pos + zilch 
                        elseif not mod.down then
                            local zilch = Vector3.zero()
                            --Vector3.set_z(zilch, 0.0265)
                            Vector3.set_z(zilch, 0.119)
                            new_position = player_pos + zilch
                        end
                    end

                    local player_rot = QuaternionBox(Unit.local_rotation(player_unit, 0))

                    if Unit.alive(unit) and new_position then 
                        Unit.set_local_position(unit, 0, new_position)
                    
                        Unit.set_local_rotation(unit, 0, Quaternion.normalize(calculate_rotation(player_rot)))

                        -- Force the physics to update
                        Unit.disable_physics(unit)
                        Unit.enable_physics(unit)
                    end
                end
            end
        end
    end
end
