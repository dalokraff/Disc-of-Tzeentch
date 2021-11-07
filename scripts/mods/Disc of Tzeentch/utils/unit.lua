local mod = get_mod("Disc of Tzeentch")

--this funciton is for calculating the disc tilt
local function calculate_rotation(player_rot, new_pos, old_pos)
    --local pos_delta = new_pos - old_pos
    local root2 = math.sqrt(2)
    local target_rot1 = Quaternion.from_elements(0,0,0,1)
    local target_rot2 = Quaternion.from_elements(0,0,0,1)

    --Vector3.set_z(new_pos, 0)
    --Vector3.set_z(old_pos, 0)
    local pos_delta = Quaternion.rotate(player_rot:unbox(), new_pos) - Quaternion.rotate(player_rot:unbox(), old_pos)
    Vector3.set_z(pos_delta, 0)
    local pos_mag = Vector3.length(pos_delta)
    local w = 1
    -- if mod.forward then 
    --     w = -math.cos(math.pi/18)
    -- end
    -- if mod.richt then 
    --     w = -math.cos(math.pi/18)
    -- end
    -- if mod.left then 
    --     w = -math.cos(math.pi/18)
    -- end
    -- if mod.backward then 
    --     if w ~= 1 then
    --         w = -w
    --     else
    --         w = math.cos(math.pi/18)
    --     end
    -- end

    if pos_mag > 0.057 then 
        w = -math.cos(math.pi/18)
    elseif pos_mag > 0.01 then
        w = math.cos(math.pi/18)
    end


    z = math.sqrt(1-math.abs(w))
    Quaternion.set_xyzw(target_rot1 ,z,0,0,w)

    local new_rotation1 = Quaternion.multiply(player_rot:unbox(), target_rot1)
    local flip_rot = Quaternion.multiply(new_rotation1, Quaternion.from_elements(0,0,1,0))

    ----mod:echo(Vector3.length(pos_delta))

    return flip_rot
end

--this is the a modified drag function from UnitExplorer and sets the position and rotation of the disc relatvie to the player 
function mod.drag_unit(world)    
    
    local calvary = mod.mounted_players

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
                            Vector3.set_z(zilch, 0.1)
                            --Vector3.set_z(zilch, 0.2)
                            new_position = player_pos + zilch 
                        elseif not mod.down then
                            local zilch = Vector3.zero()
                            --Vector3.set_z(zilch, 0.0265)
                            --Vector3.set_z(zilch, 0.119)
                            Vector3.set_z(zilch, 0.0265)
                            new_position = player_pos + zilch
                        end
                    end

                    local player_rot = QuaternionBox(Unit.local_rotation(player_unit, 0))

                    if Unit.alive(unit) and new_position then 
                        local old_pos = Unit.local_position(unit, 0)
                        Unit.set_local_rotation(unit, 0, Quaternion.normalize(calculate_rotation(player_rot, new_position, old_pos)))
                        Unit.set_local_position(unit, 0, new_position)
                        --Unit.set_local_rotation(unit, 0, player_rot:unbox())

                        -- Force the physics to update
                        Unit.disable_physics(unit)
                        Unit.enable_physics(unit)

                        
                    end
                end
            end
        end
    end
end
