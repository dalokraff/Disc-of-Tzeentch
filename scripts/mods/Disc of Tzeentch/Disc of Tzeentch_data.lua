local mod = get_mod("Disc of Tzeentch")

local loli = {
	setting_id      = "setting_id43",
	type            = "keybind",
	keybind_trigger = "held",
	keybind_type    = "function_call",
    function_name   = "ascend",
	text = "t",
	tooltip ="t"
}




local test = {
	setting_id    = "setting_id",
	type          = "checkbox",
	default_value = true,
	sub_widgets   = { --[[...]] } -- optional
  }

local test2 = {
	setting_id    = "setting_id2",
	type          = "checkbox",
	default_value = true,
	sub_widgets   = { --[[...]] } -- optional
}

local lolicon = {
	setting_id  = "setting_id32",
	type        = "group",
	sub_widgets = { test }
}

local menu = {
	name = "Disc of Tzeentch",
	description = mod:localize("Ride the Winds of Magic in style, with a Daemon of Tzeentch."),
	is_togglable = true,
	options = {
		widgets = {
			test2,
			lolicon
		}
	}
}

-- menu.options_widgets = {
-- 	{
-- 		["setting_name"] = "Ascend",
-- 		["widget_type"] = "keybind",
-- 		["text"] = "Ascend",
-- 		["tooltip"] = "Ascend",
-- 		["default_value"] = {"space"},
-- 		["keybind_trigger"] = "held",
-- 		["action"] = "ascend"
-- 	},
-- 	{
-- 		["setting_name"] = "Descend",
-- 		["widget_type"] = "keybind",
-- 		["text"] = "Descend",
-- 		["tooltip"] = "Descend",
-- 		["default_value"] = {"c"},
-- 		["keybind_trigger"] = "held",
-- 		["action"] = "descend"
-- 	}
-- }
-- menu.options_widgets = {
-- 	{
-- 		["setting_name"] = "Ascend",
-- 		["widget_type"] = "keybind",
-- 		["text"] ="Ascend",
-- 		["tooltip"] = "Ascend",
-- 		["default_value"] = {"v"},
-- 		["action"] = "ascend"
-- 	},
-- 	{
-- 		["setting_name"] = "Descend",
-- 		["widget_type"] = "keybind",
-- 		["text"] ="Descend",
-- 		["tooltip"] = "Descend",
-- 		["default_value"] = {"c"},
-- 		["action"] = "descend"
-- 	},
-- }


return menu