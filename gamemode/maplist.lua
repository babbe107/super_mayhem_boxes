GM.MapList = {}
GM.EliminationIncrement = {}

if SERVER then
	function GM:AddMap(name, cleanname, garbage, garbage2, minplayers)
		table.insert(GM.MapList, {name, cleanname, nil, nil, minplayers})
	end
end

if CLIENT then
	function GM:AddMap(name, cleanname, description, author, minplayers)
		table.insert(GM.MapList, {name, cleanname, description, author, minplayers})
	end
end

function GM:GetMapTable(name)
	for i, tab in pairs(GM.MapList) do
		if tab[1] == name then return tab end
	end
end

-- Add your maps and descriptions here!!
GM:AddMap("nox2d_smb1", "SMB1")
GM:AddMap("nox2d_palace_v2", "Palace")
GM:AddMap("nox2d_dreamland_v7", "Dream Land", "This level is full of things just waiting to destroy you. Use the turrets and door switch to make sure no one can get your flag!", "JaSeN - jasen666@hotmail.com")

function GetNonExistantMaps()
	for i, maptab in pairs(GM.MapList) do
		if not file.Exists("../maps/"..maptab[1]..".bsp") then
			print(maptab[1])
		end
	end
end

collectgarbage("collect")
