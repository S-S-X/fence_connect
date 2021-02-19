dofile("spec/mineunit/init.lua")
mineunit("core")

describe("Nothing", function()
	it("Never Fails", function()
		assert.equals(true, true)
	end)
end)
