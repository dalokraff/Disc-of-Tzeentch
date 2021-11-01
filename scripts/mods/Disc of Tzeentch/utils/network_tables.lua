local mod = get_mod("Disc of Tzeentch")

--network lookup table setup
local unit_path = "units/disc_tzeentch/disc"
local num_inv = #NetworkLookup.inventory_packages
local num_husk = #NetworkLookup.husks
local item_num = #NetworkLookup.item_names
local pickup_num = #NetworkLookup.pickup_names
local num_buffs = #NetworkLookup.buff_templates
local num_interacts = #NetworkLookup.interactions
local num_spawnTemp = #NetworkLookup.spawn_unit_templates

NetworkLookup.inventory_packages[num_inv] = unit_path
NetworkLookup.inventory_packages[unit_path] = num_inv
NetworkLookup.husks[num_husk] = unit_path
NetworkLookup.husks[unit_path] = num_husk
NetworkLookup.pickup_names[pickup_num+1] = "disc_tzeentch"
NetworkLookup.pickup_names["disc_tzeentch"] = pickup_num + 1
NetworkLookup.item_names[item_num + 1] = "disc_tzeentch"
NetworkLookup.item_names["disc_tzeentch"] = item_num + 1
NetworkLookup.buff_templates["disc_buff"] = num_buffs + 1
NetworkLookup.buff_templates[num_buffs + 1] = "disc_buff"
NetworkLookup.interactions["mount_interaction"] = num_interacts+1
NetworkLookup.interactions[num_interacts + 1] = "mount_interaction"
NetworkLookup.spawn_unit_templates["disc_unit"] = num_spawnTemp + 1 
NetworkLookup.spawn_unit_templates[num_spawnTemp + 1] = "disc_unit"