hook.Add("PlayerSay", "VotemapPlayerSay", function(pl, text, all)
	if pl:IsPlayer() and pl:IsConnected() and text == "/votemap" then
		pl:SendLua("OpenVoteMenu()")
		return ""
	end
end)

GM.VotedAlready = {}
GM.VotedVotes = {}

local TopVoted = 0
local VotedMaps = {}

local DisabledMaps = {}

util.AddNetworkString("recmapnumvotes")
util.AddNetworkString("recgtnumvotes")

concommand.Add("votemap", function(sender, command, arguments)

	if not sender:IsValid() or CurTime() < (sender.NextVoteMap or 0) then return end
	sender.NextVoteMap = CurTime() -- + 2.5 -- allow for instant new votes

	if VOTEMAPLOCKED or VOTEMAPSTART and CurTime() < VOTEMAPSTART then
		sender:PrintMessage(HUD_PRINTTALK, "Map voting has not started yet!")
		return
	end

	if VOTEMAPOVER and VOTEMAPOVER <= CurTime() then
		sender:PrintMessage(HUD_PRINTTALK, "Map voting time has ended!")
		return
	end

	local uid = sender:UniqueID()

	arguments = tonumber(arguments[1])
	if not arguments then return end

	local id = arguments
	local maptab = GAMEMODE.MapList[id]
	if not maptab then
		sender:PrintMessage(HUD_PRINTTALK, "Map doesn't exist.")
		return
	end

	local mapname = maptab[1]
	local mapdesc = maptab[2]
	if not mapname then
		sender:PrintMessage(HUD_PRINTTALK, "Error, map not properly added to server. Tell an admin.")
		return
	end

	local lowermapname = string.lower(mapname)

	if string.lower(game.GetMap()) == lowermapname then
		sender:PrintMessage(HUD_PRINTTALK, "You can't vote for the same map that's being played.")
		return
	end

	if DisabledMaps[lowermapname] then
		sender:PrintMessage(HUD_PRINTTALK, "That map has been marked for removal: "..tostring(DisabledMaps[lowermapname]))
		return
	end

	if maptab[5] and #player.GetAll() < maptab[5] then
		sender:PrintMessage(HUD_PRINTTALK, "That map requires at least "..maptab[5].." players in the game!")
		return
	end

	local votes = math.max(1, sender:Frags())


	local votedalready = GAMEMODE.VotedAlready[uid]
	if votedalready == mapname then return end
	
	if votedalready then
		VotedMaps[votedalready] = VotedMaps[votedalready] - GAMEMODE.VotedVotes[uid]
		GAMEMODE.VotedAlready[uid] = nil
		GAMEMODE.VotedVotes[uid] = nil

		-- umsg.Start("recmapnumvotes")
		-- 	umsg.String(votedalready)
		-- 	umsg.Short(VotedMaps[votedalready])
		-- umsg.End()
		print("[Voting] votedalready")
		print(votedalready)
		print(VotedMaps[votedalready])
		net.Start("recmapnumvotes")
		net.WriteString(votedalready)
		net.WriteInt(VotedMaps[votedalready], 16)
		net.Broadcast()
		print("Sent recmapnumvotes for votedalready")
	end

	GAMEMODE.VotedAlready[uid] = mapname
	GAMEMODE.VotedVotes[uid] = votes

	VotedMaps[mapname] = (VotedMaps[mapname] or 0) + votes

	if votes == 1 then
		PrintMessage(HUD_PRINTTALK, sender:Name().." placed 1 vote for "..mapdesc.." ("..mapname..").")
	else
		PrintMessage(HUD_PRINTTALK, sender:Name().." placed "..votes.." votes for "..mapdesc.." ("..mapname..").")
	end

	-- umsg.Start("recmapnumvotes")
	-- 	umsg.String(mapname)
	-- 	umsg.Short(VotedMaps[mapname])
	-- umsg.End()
	print("[Voting] mapname")
	print(mapname)
	print(VotedMaps[mapname])
	net.Start("recmapnumvotes")
	net.WriteString(mapname)
	net.WriteInt(VotedMaps[mapname], 16)
	print("Send recmapnumvotes")
	--print(mapname)
	--print(VotedMaps[mapname])
	net.Broadcast()

	local most = 0
	for mapname, numvotes in pairs(VotedMaps) do
		if numvotes > most then
			most = numvotes
			-- print("most votes:"..mapname)
			-- print("numvotes:"..numvotes)
			GAMEMODE.NEXT_MAP = mapname
		end
	end

	if GAMEMODE.MapVoted then
		GAMEMODE:MapVoted(sender, maptab, mapname, id, votes, VotedMaps[mapname])
	end
end)

hook.Add("Initialize", "GameTypeVotingInitialize", function()
	hook.Remove("Initialize", "GameTypeVotingInitialize")

	if not GAMEMODE.GameTypes then return end

	GAMEMODE.GameTypeVoted = {}
	GAMEMODE.GameTypeVotedVotes = {}
	GAMEMODE.GameTypeVotes = {}
	for _, gt in pairs(GAMEMODE.GameTypes) do
		GAMEMODE.GameTypeVotes[gt] = 0
	end
	GAMEMODE.TopGameTypeVotes = 0
	print("Voting for gamemodes")
	concommand.Add("votegt", function(sender, command, arguments)
		if not sender:IsValid() or CurTime() < (sender.NextVoteGameType or 0) then return end
		sender.NextVoteGameType = CurTime() -- + 2.5 -- allow for instant new votes

		if not ENDGAME then
			sender:PrintMessage(HUD_PRINTTALK, "Can only vote for a gametype after the current game has ended!")
			return
		end

		if not VOTEMAPOVER or CurTime() < VOTEMAPOVER then
			sender:PrintMessage(HUD_PRINTTALK, "Can only vote for a gametype after the map voting stage!")
			return
		end

		arguments = arguments[1]
		if not arguments then return end

		local gonethrough = false
		for _, gt in pairs(GAMEMODE.GameTypes) do
			if arguments == gt then
				gonethrough = true
				break
			end
		end

		if not gonethrough then
			sender:PrintMessage(HUD_PRINTTALK, "Error. Gametype doesn't exist?")
			return
		end

		if GAMEMODE.NoGameTypeTwiceInRow and 1 < #GAMEMODE.GameTypes and arguments == GAMEMODE.GameType then sender:PrintMessage(HUD_PRINTTALK, "The same game type can't be played twice in a row.") return end

		local votes = 1

		local uid = sender:UniqueID()


		local votedalready = GAMEMODE.GameTypeVoted[uid]
		if votedalready == arguments then return end
		if votedalready then
			GAMEMODE.GameTypeVotes[votedalready] = GAMEMODE.GameTypeVotes[votedalready] - GAMEMODE.GameTypeVotedVotes[uid]
			GAMEMODE.GameTypeVotedVotes[uid] = nil
			GAMEMODE.GameTypeVoted[uid] = nil

			-- umsg.Start("recgtnumvotes")
			-- 	umsg.String(votedalready)
			-- 	umsg.Short(GAMEMODE.GameTypeVotes[votedalready])
			-- umsg.End()
			net.Start("recgtnumvotes")
			net.WriteString(votedalready)
			net.WriteInt(GAMEMODE.GameTypeVotes[votedalready], 16)
			net.Broadcast()
			print("Sent recgtnumvotes votedalready")
		end
		
		GAMEMODE.GameTypeVoted[uid] = arguments
		GAMEMODE.GameTypeVotedVotes[uid] = votes
		GAMEMODE.GameTypeVotes[arguments] = GAMEMODE.GameTypeVotes[arguments] + votes

		local most = 0
		for _, gt in pairs(GAMEMODE.GameTypes) do
			if GAMEMODE.GameTypeVotes[gt] > most then
				most = GAMEMODE.GameTypeVotes[gt]
				print("Most: "..GAMEMODE.GameTypeVotes[gt])
				file.Write(GAMEMODE_NAME.."_gametype.txt", gt)
			end
		end

		if votes == 1 then
			PrintMessage(HUD_PRINTTALK, sender:Name().." placed 1 vote for "..arguments..".")
		else
			PrintMessage(HUD_PRINTTALK, sender:Name().." placed "..votes.." votes for "..arguments..".")
		end

		-- umsg.Start("recgtnumvotes")
		-- 	umsg.String(arguments)
		-- 	umsg.Short(GAMEMODE.GameTypeVotes[arguments])
		-- umsg.End()
		net.Start("recgtnumvotes")
		net.WriteString(arguments)
		net.WriteInt(GAMEMODE.GameTypeVotes[arguments], 16)
		net.Broadcast()
		print("Sent recgtnumvotes")
		print(arguments)
		print(GAMEMODE.GameTypeVotes[arguments])
	end)
end)
