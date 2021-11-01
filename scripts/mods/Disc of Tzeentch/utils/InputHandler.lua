local mod = get_mod("Disc of Tzeentch")

function mod.handle_inputs()
    --these are used to help determine disc tilt when moving
    if Keyboard.pressed(Keyboard.button_index("d")) then mod.richt = true end
    if Keyboard.released(Keyboard.button_index("d")) then mod.richt = false end
    if Keyboard.pressed(Keyboard.button_index("a")) then mod.left = true end
    if Keyboard.released(Keyboard.button_index("a")) then mod.left = false end
    if Keyboard.pressed(Keyboard.button_index("w")) then mod.forward = true end
    if Keyboard.released(Keyboard.button_index("w")) then mod.forward = false end
    if Keyboard.pressed(Keyboard.button_index("s")) then mod.backward = true end
    if Keyboard.released(Keyboard.button_index("s")) then mod.backward = false end

    --these keys control the ascend and descend
    if Keyboard.pressed(Keyboard.button_index("left shift")) then mod.down = true end
    if Keyboard.released(Keyboard.button_index("left shift")) then mod.down = false end
    if Keyboard.pressed(Keyboard.button_index("space")) then mod.up = true end
    if Keyboard.released(Keyboard.button_index("space")) then mod.up = false end
end
