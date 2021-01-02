local self = "turtle_3750"

local storage = "minecraft:ironchest_gold_458"

local storageinv = peripheral.wrap(storage)
local craftSlot = {1,2,3,5,6,7,9,10,11}
local crafts = {}
local storageinvSlots = {
  ["harvestcraft:potitem"] = 1,
  ["harvestcraft:bakewareitem"] = 2,
  ["harvestcraft:cuttingboarditem"] = 3,
  ["harvestcraft:mixingbowlitem"] = 4,
  ["harvestcraft:saucepanitem"] = 5,
  ["harvestcraft:mortarandpestleitem"] = 6,
  ["harvestcraft:juiceritem"] = 7,


  ["minecraft:bucket"] = 8,
  ["minecraft:water_bucket"] = 9,

  ["harvestcraft:saltitem"] = 19,
  ["minecraft:potato"] = 20,
  ["minecraft:baked_potato"] = 21,
  ["minecraft:milk_bucket"] = 22,
  ["harvestcraft:freshmilkitem"] = 23,
  ["harvestcraft:freshwateritem"] = 24,
  ["harvestcraft:heavycreamitem"] = 25,
  ["harvestcraft:butteritem"] = 26,
  ["harvestcraft:bubblywateritem"] = 27,

  ["harvestcraft:spiceleafitem"] = 28,
  ["minecraft:reeds"] = 29,
  ["minecraft:sugar"] = 30,
  ["harvestcraft:flouritem"] = 31,
  ["harvestcraft:batteritem"] = 32,
  ["minecraft:egg"] = 33,
  ["harvestcraft:spiceleafseeditem"] = 34,
  ["harvestcraft:oliveoilitem"] = 35,
  ["harvestcraft:peppercornitem"] = 36,
  ["harvestcraft:blackpepperitem"] = 37,
  ["harvestcraft:cornitem"] = 38,
  ["harvestcraft:cornmealitem"] = 39,
  
  ["harvestcraft:friesitem"] = 64,
  ["harvestcraft:mashedpotatoesitem"] = 65,
  ["harvestcraft:butteredpotatoitem"] = 66,
  ["harvestcraft:colasodaitem"] = 67,
  ["minecraft:chicken"] = 68,
  ["harvestcraft:friedchickenitem"] = 69,
  ["harvestcraft:friedfeastitem"] = 70,
  
}

crafts.salt = {
[1] = "harvestcraft:potitem", [2] = "minecraft:water_bucket", 

["output"] = "harvestcraft:saltitem"
}

crafts.fries = {
[1] = "harvestcraft:bakewareitem", [2] = "minecraft:potato", [3] = "harvestcraft:saltitem", 

["output"] = "harvestcraft:friesitem"
}

crafts.bakedpotato = {
	[1] = "minecraft:potato", [2] = "harvestcraft:bakewareitem",

	["output"] = "minecraft:baked_potato"
}

crafts.freshmilk = {
	[1] = "minecraft:milk_bucket",

	["output"] = "harvestcraft:freshmilkitem"
}

crafts.cream = {
	[1] = "harvestcraft:mixingbowlitem", [2] = "harvestcraft:freshmilkitem",

	["output"] = "harvestcraft:heavycreamitem"
}

crafts.butter = {
	[1] = "harvestcraft:saucepanitem", [2] = "harvestcraft:heavycreamitem", [3] = "harvestcraft:saltitem",

	["output"] = "harvestcraft:butteritem"
}

crafts.butterpotatoes = {
	[1] = "minecraft:baked_potato", [2] = "harvestcraft:butteritem",

	["output"] = "harvestcraft:butteredpotatoitem"
}

crafts.mashedpotato = {
	[1] = "harvestcraft:mixingbowlitem", [2] = "harvestcraft:butteredpotatoitem", [3] = "harvestcraft:saltitem",

	["output"] = "harvestcraft:mashedpotatoesitem"
}

crafts.freshwater = {
	[1] = "minecraft:water_bucket",

	["output"] = "harvestcraft:freshwateritem"
}

crafts.bubblywater = {
	[1] = "harvestcraft:potitem", [2] = "harvestcraft:freshwateritem", [3] = "harvestcraft:freshwateritem",

	["output"] = "harvestcraft:bubblywateritem"
}

crafts.sugar = {
	[1] = "minecraft:reeds",

	["output"] = "minecraft:sugar"
}

crafts.cola = {
	[1] = "harvestcraft:potitem", [2] = "harvestcraft:bubblywateritem", [3] = "minecraft:sugar", [4] = "harvestcraft:spiceleafitem",

	["output"] = "harvestcraft:colasodaitem"
}

crafts.flour = {
	[1] = "harvestcraft:mortarandpestleitem", [2] = "minecraft:potato",

	["output"] = "harvestcraft:flouritem" 
}

crafts.batter = {
	[1] = "harvestcraft:mixingbowlitem", [2] = "harvestcraft:flouritem", [3] = "minecraft:egg",

	["output"] = "harvestcraft:batteritem"
}

crafts.seeds = {
	[1] = "harvestcraft:spiceleafitem",

	["output"] = "harvestcraft:spiceleafseeditem"
}

crafts.oil = {
	[1] = "harvestcraft:juiceritem", [2] = "harvestcraft:spiceleafseeditem", [3] = "harvestcraft:spiceleafseeditem",

	["output"] = 'harvestcraft:oliveoilitem'
}

crafts.pepper = {
	[1] = "harvestcraft:mortarandpestleitem", [2] = "harvestcraft:peppercornitem",


	["output"] = "harvestcraft:blackpepperitem"
}

crafts.kfcbucket = {
	[1] = "harvestcraft:potitem", [2] = "minecraft:chicken", [3] = "harvestcraft:batteritem", 
	[4] = "harvestcraft:spiceleafitem", [5] = "harvestcraft:blackpepperitem", [6] = "harvestcraft:oliveoilitem",

	["output"] = "harvestcraft:friedchickenitem" 
}

crafts.feast = {
	[1] = "harvestcraft:cuttingboarditem", [2] = "harvestcraft:friedchickenitem", [3] = "harvestcraft:friesitem",
	[4] = "harvestcraft:mashedpotatoesitem", [5] = "harvestcraft:colasodaitem",

	["output"] = "harvestcraft:friedfeastitem"
}

crafts.cornmeal = {
	[1] = "harvestcraft:mortarandpestleitem", [2] = "harvestcraft:cornitem",


	["output"] = "harvestcraft:cornmealitem"
}

local function scanInventory()
	local inventory = {}
	for i = 1,16 do
		inventory[i] = turtle.getItemDetail(i)
	end
	return inventory
end

local function storeItems()
	local stored = scanInventory()
	for slot,item in pairs(stored) do
		if storageinvSlots[item.name] then
			storageinv.pullItems(self,slot,64,storageinvSlots[item.name])
		end
	end
	local stored = scanInventory()
	for _,_ in pairs(stored) do -- I hate this, but #stored doesn't work because lua's stupid
		print("Stocking overflowed items")
		for i = 1,16 do
			turtle.select(i)  
			turtle.dropUp()
		end
		break
	end
end

local function make(craft)
	local stored = storageinv.list()
	if not stored or not craft then return end
	if stored[ storageinvSlots[ craft["output"] ] ] and stored[ storageinvSlots[ craft["output"] ] ].count == 64 then
		print("We already have too much of this item, aborting")
		storeItems()
		return
	end

	local doubles = {}

	for i = 1,#craft-1 do
		if craft[i] == craft[i+1] then
			doubles[craft[i]] = (doubles[craft[i]] or 2)+1
		end
	end


	local needs = ""

	for slot, ingredient in ipairs(craft) do
		if slot ~= "output" then
			if not stored[storageinvSlots[ingredient]] or not stored[storageinvSlots[ingredient]].name == ingredient or (stored[storageinvSlots[ingredient]].count < (doubles[ingredient] or 1)) then
				print("Missing "..ingredient.." in slot "..storageinvSlots[ingredient])
				needs = ingredient
				break
			end
		end
	end 

	if needs ~= "" then
		print("Missing items to make "..craft["output"]..", trying to make them..")
		storeItems()
		possible = false
		for name,c in pairs(crafts) do
			if c["output"] == needs then
				possible = true
				make(crafts[name])
			end
		end
		if not possible then
			print("Failed")
			storeItems()
			return false
		end
		make(craft)
		storeItems()
		return
	end

	local pulled = 0
	print("Crafting "..craft["output"].."..")
	for slot, item in ipairs(craft) do
		pulled = storageinv.pushItems(self,storageinvSlots[item],1,craftSlot[slot])
		if pulled == 0 then
			print("Something wrong happened, aborting!")
			storeItems()
			return
		end
	end
	
	turtle.craft()

	storeItems()

	sleep(1)
end

local function sortChest()
	local count = 1
	while count ~= 0 do
		count = 0
		for slot, item in pairs(storageinv.list()) do
			for sortedItem,sortedSlot in pairs(storageinvSlots) do
				if item.name == sortedItem and slot ~= sortedSlot then
					count = 1
					storageinv.pushItems(self,slot,64,1)
					storageinv.pullItems(self,1,64,sortedSlot)
				end
			end
		end
	end
end

storeItems()
sortChest()

while true do
  for k,v in pairs(crafts) do
  	print("===============")
  	make(v)
  end
--  make(crafts.cola)
--  make(crafts.fries)
--  make(crafts.mashedpotato)

end