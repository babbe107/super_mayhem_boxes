function GM:CTFInitialize()
	self.Name = self.Name.." ("..self.GameTranslates["CTF"]..")"
	self.GameType = "CTF"
	self.FlagEntity = "2dflag"
	self.StartScore = 0
	gmod.BroadcastLua("GAMEMODE:CTFInitialize()")
	hook.Add("PlayerReady", "GMSend2", function(pl)
		pl:SendLua("GAMEMODE:CTFInitialize()")
	end)

	hook.Add("OnBoxRemoved", "CTF_OnBoxRemoved", function(box)
		for _, flag in pairs(ents.FindByClass("2dflag")) do
			if flag.Carrier == box then
				flag:Drop(box)
			end
		end
	end)

	function self:GameTypeThink()
	end

	function self:PlayerShouldGetALossForLeaving(pl)
		local teamid = pl:Team()

		if teamid == TEAM_RED then
			return self.CapturesToWin:GetInt() - 1 <= team.GetScore(TEAM_GREEN)
		elseif teamid == TEAM_GREEN then
			return self.CapturesToWin:GetInt() - 1 <= team.GetScore(TEAM_RED)
		end

		return false
	end

	function self:FlagDropped(myteam, byplayer)
		-- umsg.Start("FDro")
		-- 	umsg.Short(myteam)
		-- 	umsg.String(byplayer)
		-- umsg.End()
		util.AddNetworkString("FDro")
		net.Start("FDro")
			net.WriteInt(myteam, 16)
			net.WriteString(byplayer, 16)
		net.Broadcast()
	end

	function self:FlagReturned(pl, box, myteam, far, dist)
		local msg = ""
		if far then
			if pl and pl:IsValid() then
				pl:AddFrags(3)
				msg = pl:Name().." returned the "..team.GetName(myteam).." flag. A "..math.ceil(dist / 16).." foot return!"
			else
				msg = "The "..team.GetName(myteam).." flag was auto-returned."
			end
		else
			if pl and pl:IsValid() then
				msg = pl:Name().." gently put the "..team.GetName(myteam).." flag back on the stand."
			else
				msg = "The "..team.GetName(myteam).." flag was auto-returned."
			end
		end

		-- umsg.Start("FRet")
		-- 	umsg.String(msg)
		-- umsg.End()
		util.AddNetworkString("FRet")
		net.Start("FRet")
			net.WriteString(msg)
		net.Broadcast()
	end

	function self:FlagCaptured(pl, box, myteam, otherteam)
		--PrintMessageAll(HUD_PRINTTALK, pl:Name().." of "..team.GetName(myteam).." captured the "..team.GetName(otherteam).." flag!")
		team.AddScore(myteam, 1)
		local shouldend = self.CTF_CapturesToWin:GetInt() <= team.GetScore(myteam)
		pl:AddFrags(10)

		for _, ent in pairs(ents.FindByClass("logic_flagscored")) do
			if ent.Enabled == 1 and (ent.Team == 0 or ent.Team == myteam) then
				ent:FireOutput("OnScored", pl, box)
			end
		end

		-- umsg.Start("FCap")
		-- 	umsg.String(pl:Name())
		-- 	umsg.Short(myteam)
		-- 	umsg.Short(otherteam)
		-- 	umsg.Bool(shouldend)
		-- umsg.End()
		util.AddNetworkString("FCap")
		net.Start("FCap")
			net.WriteString(pl:Name())
			net.WriteInt(myteam, 16)
			net.WriteInt(otherteam, 16)
			net.WriteBool(shouldend)
		net.Broadcast()
		if shouldend then
			gamemode.Call("EndGame", myteam)
		end
	end

	function self:FlagPickedUp(pl, box, myteam)
		-- umsg.Start("FTak")
		-- 	umsg.String(pl:Name())
		-- 	umsg.Short(myteam)
		-- umsg.End()
		util.AddNetworkString("FTak")
		net.Start("FTak")
			net.WriteString(pl:Name())
			net.WriteInt(myteam, 16)
		net.Broadcast()

	end
end
