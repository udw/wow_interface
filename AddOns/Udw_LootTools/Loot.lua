local UdwItemsInBag = {}
local UdwDestroyItems = {}
local autoDestroyRun=false
local lootClosed=false
local updateDiff = 0

local function eventHandler(self, event, ...)
	if (autoDestroyRun==true) then
		if (event=="BAG_UPDATE" or event=="UDW_AUTOLOOT_START") then
			Udw_AutoLoot();
		end
		
		if (event=="LOOT_CLOSED") then
			lootClosed=true
		end
	end
end

local function onUpdate(self,elapsed) 
	if (autoDestroyRun==true) then
		Udw_AutoDestroy();
	end
   
	if (lootClosed==true) then
		updateDiff = updateDiff + elapsed;         
		if (updateDiff>1) then
				autoDestroyRun=false;
				lootClosed=false
				updateDiff = 0;
		end
	end
end

function Udw_SlashCommand(msg)
  if(msg) then
	local command = strlower(msg)
	if (command == "destroy") then
		UdwDestroyItems = {}
		if not Udw_GetBagItems() then
			UIErrorsFrame:AddMessage("Free at least one space in your bag to destroy loot!", 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
		else
			autoDestroyRun=true;
			eventHandler(this,"UDW_AUTOLOOT_START");
		end
	end
  end
end

function Udw_AutoLoot()
	local numItems = GetNumLootItems()
	--DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Udw number of items:" .. numItems)
	for i=1,numItems do
		local itemLink=GetLootSlotLink(i)
		if (itemLink) then
			LootSlot(i)
			ConfirmLootSlot(i)
			local itemId = string.match (itemLink, "item:(%d+)")
			UdwDestroyItems[#(UdwDestroyItems) + 1] = tonumber(itemId)
		end
	end
end

function Udw_GetBagItems() 
	UdwItemsInBag = {}
	local freeSpace=false
	for i = 0, 4, 1 do
		UdwItemsInBag[i]={}
		x = GetContainerNumSlots(i)
		
		local freeSlots, bagType = GetContainerNumFreeSlots(i)
		if ( freeSlots>0 ) then
			freeSpace=true
		end
		
		for j = 0, x, 1 do
			if GetContainerItemID(i, j) then
				UdwItemsInBag[i][j] = tonumber(GetContainerItemID(i, j))
			else
				UdwItemsInBag[i][j] = false
			end
		end
	end
	
	return freeSpace
end

function Udw_AutoDestroy()
	for i = 0, 4, 1 do
		x = GetContainerNumSlots(i)
		for j = 0, x, 1 do
			local cItemId=GetContainerItemID(i, j)
			if cItemId then
				if UdwItemsInBag[i][j] == false then
					PickupContainerItem(i, j)
					if CursorHasItem() and Udw_InTable(UdwDestroyItems,cItemId) then
						--DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Udw Destroying ".. cItemId)
						DeleteCursorItem()
					end
				end
			end
		end
	end
end

function Udw_InTable(t, val)
	for index, v in ipairs(t) do
		local localValue
		if(type(v) == "table") then
			localValue = v.name
		else
			localValue = v
		end
  		if localValue == val then
		    return index
  		end
	end
	return false
end

-- Addon Loading

frame = CreateFrame("Frame",nil,UIParent)
local version = GetAddOnMetadata("Udw_LootTools", "Version")

frame:SetScript("OnEvent", eventHandler)
frame:SetScript("OnUpdate", onUpdate);

SlashCmdList["UDW"] = function(msg)
	Udw_SlashCommand(msg)
end
SLASH_UDW1 = "/udw_loot"

if( DEFAULT_CHAT_FRAME ) then
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Udw_LootTools v"..version.." loaded")
end

frame:RegisterEvent("BAG_UPDATE")
frame:RegisterEvent("LOOT_SLOT_CLEARED")
frame:RegisterEvent("LOOT_SLOT_CHANGED")
frame:RegisterEvent("LOOT_CLOSED")
	