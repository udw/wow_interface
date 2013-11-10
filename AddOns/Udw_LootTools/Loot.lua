local panelName
local UdwDestroyItem = {}
local autoDestroyRun=false
local updateDiff = 0

local function eventHandler(self, event, ...)
  if(autoDestroyRun==true) then
	  if(event == "BAG_UPDATE") then
			Udw_AutoDestroy()
	  elseif (event=="CHAT_MSG_LOOT") then
		local message, sender, language, channelString, target, flags, _, channelNumber, channelName, _, _ = ...
		Udw_HandleIncomingLoot(message)
	  elseif (event=="LOOT_SLOT_CLEARED") then
		--autoDestroyRun=false;
	  end
  end
end

local function onUpdate(self,elapsed) 
	if (autoDestroyRun==true) then
		updateDiff = updateDiff + elapsed; 	
		if (updateDiff>1) then
			autoDestroyRun=false;
			updateDiff = 0;
		end
	end
end

function Udw_SlashCommand(msg)
  if(msg) then
	local command = strlower(msg)
	if (command == "destroy") then
		Udw_HandleLoot();
	end
  end
end

function Udw_HandleLoot()
		autoDestroyRun=true;
		Udw_AutoLoot();
end

function Udw_AutoLoot()
	local numItems = GetNumLootItems()
	--DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Udw number of items:" .. numItems)
	for i=1,numItems do
			LootSlot(i)
	end
end

function Udw_HandleIncomingLoot(message)	
		local _,_,_,itemId = string.find(message, "^You receive loot: |?c?f?f?(.*)|Hitem:(%d+):.*:.*:.*:.*:.*:.*:.*:.*|.*$")
		if(itemId) then
			local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(itemId)
				--DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Udw Destroy grey: "..itemId..", quality:"..quality)
				UdwDestroyItem[#(UdwDestroyItem) + 1] = tonumber(itemId)
		end
end

function Udw_AutoDestroy()
	for i = 0, 4, 1 do
		x = GetContainerNumSlots(i)
		for j = 0, x, 1 do
			if GetContainerItemID(i, j) then
				local tableIndex = Udw_InTable(UdwDestroyItem, tonumber(GetContainerItemID(i, j)))
				if tableIndex then
					PickupContainerItem(i, j)
					if CursorHasItem() then
						--DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Udw Destroying "..tableIndex)
						DeleteCursorItem()
						tremove(UdwDestroyItem, tableIndex)
					end
				end
			end
		end
	end
end

function Udw_InTable2(t, val)
	for i=1, #(t), 1 do
		local localValue
		if(type(t[i]) == "table") then
			localValue = t[i].name
		else
			localValue = t[i]
		end
  		if localValue == val then
		    return i
  		end
	end
	return false
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
local version = GetAddOnMetadata("Udw", "Version")

frame:SetScript("OnEvent", eventHandler)
frame:SetScript("OnUpdate", onUpdate);

SlashCmdList["UDW"] = function(msg)
	Udw_SlashCommand(msg)
end
SLASH_Udw1 = "/udw"

if( DEFAULT_CHAT_FRAME ) then
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Udw v"..version.." loaded")
end
UIErrorsFrame:AddMessage("Udw v"..version.." AddOn loaded", 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
frame:RegisterEvent("CHAT_MSG_LOOT")
frame:RegisterEvent("BAG_UPDATE")
frame:RegisterEvent("LOOT_SLOT_CLEARED")
	