local mod = get_mod("Disc of Tzeentch")

function mod.handle_inputs()
    --these keys control the ascend and descend
    if Keyboard.pressed(Keyboard.button_index("left shift")) then mod.down = true end
    if Keyboard.released(Keyboard.button_index("left shift")) then mod.down = false end
    if Keyboard.pressed(Keyboard.button_index("space")) then mod.up = true end
    if Keyboard.released(Keyboard.button_index("space")) then mod.up = false end
end
