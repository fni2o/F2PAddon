--misc functions that don't fit neatly in any other category.

function F2PMisc_NamePlusRealm(name) --append the player's realm name to the end of a character name.
	local chatFormRealm, _ = GetRealmName():gsub("%s","")  --get the realm and strip out the spaces
	if not string.match(name,"-") then  --make sure were not adding the realm name if it's already there
		name = name.."-"..chatFormRealm
	end
	return name
end

function F2PMisc_NameMinusRealm(name) --strip realm name from a character name
	return string.gsub(name,"-.+","")
end


function F2PMisc_BuildMapIDNameTable()
	F2PAddonGlobalVars.MapIDNameTable = {}
	local i = 0
	local id
	local continentIDs = {}
	for k,v in pairs({GetMapContinents()}) do
	i=i+1
		if (i % 2 == 0) then  --for even values of i
			continentIDs[id] = v
			F2PAddonGlobalVars.MapIDNameTable[id] = v
		else --store the odd values
			id = v
		end
	end

	i = 0
	local zoneIDs = {}
	for k,v in pairs(continentIDs) do
		for k,v in pairs({GetMapSubzones(k)}) do
			i=i+1
			if (i % 2 == 0) then  --for even values of i
				zoneIDs[id] = v
				F2PAddonGlobalVars.MapIDNameTable[id] = v
			else --store the odd values
				id = v
			end
		end
	end

	i = 0
	local subzoneIDs = {}
	for k,v in pairs(zoneIDs) do
		for k,v in pairs({GetMapSubzones(k)}) do
			i=i+1
			if (i % 2 == 0) then  --for even values of i
				subzoneIDs[id] = v
				F2PAddonGlobalVars.MapIDNameTable[id] = v
			else --store the odd values
				id = v
			end
		end
	end
end