local UdwItemsInBag = {}
local UdwDestroyItems = {}
local updateDiff = 0
local dCount = 0
local lootClosed=false

local function eventHandler(self, event, message)
	if (dCount>0) then
		if (event=="LOOT_CLOSED") then
			lootClosed=true
		else
			Udw_AutoLoot();
		end
	end
end

local function onUpdate(self,elapsed)   
	if (dCount>0) then	
		Udw_AutoDestroy();
	end

	if (dCount==0 and lootClosed==true) then
		updateDiff = updateDiff + elapsed;         
		if (updateDiff>1) then
			UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
			lootClosed=false
			updateDiff = 0;
		end
	end
end

function Udw_SlashCommand(msg)
  if(msg) then
	local command = strlower(msg)
	if (command == "destroy") then
		Udw_DestroyStart()
	end
  end
end

function Udw_DestroyStart() 
	if (GetNumLootItems()>0) then
		UdwDestroyItems = {}
		freeSlots=Udw_TotalFreeSlots()
		if freeSlots==0 then
			UIErrorsFrame:AddMessage("Free at least one space in your bag to destroy loot!", 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
		else
			Udw_GetBagItems()
			Udw_GetLootItems()
			UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
			eventHandler(this,"UDW_DESTROY_START")
		end
	end
end

function Udw_AutoLoot()
	local numItems=GetNumLootItems()
	for i=1,numItems do
		local itemLink=GetLootSlotLink(i)
		if (itemLink) then
			LootSlot(i)
			ConfirmLootSlot(i)
		end
	end
end

function Udw_AutoDestroy()
	for i = 0, 4, 1 do
		local x = GetContainerNumSlots(i)
		for j = 0, x, 1 do
			local cItemId=GetContainerItemID(i, j)
			if cItemId then
				cItemId=tonumber(cItemId)
				if UdwItemsInBag[i][j] == false and dCount>0 and UdwDestroyItems[cItemId] == true then
					PickupContainerItem(i, j)
					if CursorHasItem() then
						--local sName, sLink, iRarity, iLevel, iMinLevel, sType, sSubType, iStackCount = GetItemInfo(cItemId);
						--DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Udw Destroying ".. sName)
						UdwDestroyItems[cItemId]=false
						dCount=dCount-1
						DeleteCursorItem()
					end
				end
			end
		end
	end
end

function Udw_GetBagItems() 
	UdwItemsInBag = {}
	
	for i = 0, 4, 1 do
		UdwItemsInBag[i]={}
		local x = GetContainerNumSlots(i)
		
		for j = 0, x, 1 do
			if GetContainerItemID(i, j) then
				UdwItemsInBag[i][j] = tonumber(GetContainerItemID(i, j))
			else
				UdwItemsInBag[i][j] = false
			end
		end
	end
end

function Udw_GetLootItems()
	local numItems=GetNumLootItems()
	if (numItems>0) then
		for i=1,numItems do
			local itemLink=GetLootSlotLink(i)
			if (itemLink) then
				local itemId = string.match (itemLink, "item:(%d+)")
				if (itemId) then
					itemId=tonumber(itemId)
					UdwDestroyItems[itemId] = true
					dCount=dCount+1
				end
			end
		end
		
	end
end

function Udw_TotalFreeSlots()
	local totalFreeNum=0
	for i = 0, 4, 1 do
		local freeSlots, bagType = GetContainerNumFreeSlots(i)
		if ( freeSlots>0 ) then
			totalFreeNum=totalFreeNum+freeSlots
		end
	end
	return totalFreeNum
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
--frame:RegisterEvent("LOOT_SLOT_CLEARED")
--frame:RegisterEvent("LOOT_SLOT_CHANGED")
--frame:RegisterEvent("LOOT_CLOSED")
--frame:RegisterEvent("CHAT_MSG_LOOT")
--frame:RegisterEvent("UI_ERROR_MESSAGE")