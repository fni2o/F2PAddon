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