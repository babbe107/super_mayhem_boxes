function GM:TDMInitialize()
	self.Name = self.Name.." ("..self.GameTranslates["TDM"]..")"
	self.GameType = "TDM"
	self.FlagEntity = nil
	self.StartScore = 0

	gmod.BroadcastLua("GAMEMODE:TDMInitialize()")
	hook.Add("PlayerReady", "GMSend2", function(pl)
		pl:SendLua("GAMEMODE:TDMInitialize()")
	end)

	function self:PlayerShouldGetALossForLeaving(pl)
		local teamid = pl:Team()

		if teamid == TEAM_RED then
			return self.TDM_KillsToWin:GetInt() * 0.5 <= team.GetScore(TEAM_GREEN)
		elseif teamid == TEAM_GREEN then
			return self.TDM_KillsToWin:GetInt() * 0.5 <= team.GetScore(TEAM_RED)
		end

		return false
	end

	hook.Add("PlayerKilledByPlayer", "TDM_PlayerKilledByPlayer", function(victim, attacker, inflictor)
		local teamid = attacker:Team()
		team.AddScore(teamid, 1)
		if self.TDM_KillsToWin:GetInt() <= team.GetScore(teamid) then
			gamemode.Call("EndGame", teamid)
		end
	end)
end
