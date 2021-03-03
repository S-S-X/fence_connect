require("mineunit")

mineunit("core")

fixture("fences")

minetest.register_node(":technic:test_chest", {
	description = "Technic chest",
	groups = {
		snappy = 2, choppy = 2, oddly_breakable_by_hand = 2,
		tubedevice = 1, tubedevice_receiver = 1, technic_chest = 1,
	},
})

describe("Mod initialization", function()

	it("Wont crash", function()
		sourcefile("init")
	end)

end)
