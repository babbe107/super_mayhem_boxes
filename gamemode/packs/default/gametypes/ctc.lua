function GM:CTCInitialize()
	self.Name = self.Name.." ("..self.GameTranslates["CTC"]..")"
	self.GameType = "CTC"
	self.FlagEntity = "coinbank"
	self.StartScore = 50
	gmod.BroadcastLua("GAMEMODE:CTCInitialize()")
	hook.Add("PlayerReady", "GMSend2", function(pl)
		pl:SendLua("GAMEMODE:CTCInitialize()")
	end)

	function self:GameTypeThink()
		if 100 <= team.GetScore(TEAM_GREEN) then
			gamemode.Call("EndGame", TEAM_GREEN)
		elseif 100 <= team.GetScore(TEAM_RED) then
			gamemode.Call("EndGame", TEAM_RED)
		end
	end

	function self:PlayerShouldGetALossForLeaving(pl)
		local teamid = pl:Team()

		if teamid == TEAM_RED then
			return team.GetScore(TEAM_RED) <= 20
		elseif teamid == TEAM_GREEN then
			return team.GetScore(TEAM_GREEN) <= 20
		end

		return false
	end

	function self:PlayerReturnedCoins(pl, box, coins)
		local myteam = pl:Team()
		if 100 <= team.GetScore(myteam) then
			gamemode.Call("EndGame", myteam)
		else
			-- umsg.Start("coinret")
			-- 	umsg.String(pl:Name())
			-- 	umsg.Short(myteam)
			-- 	umsg.Short(coins)
			-- umsg.End()
			util.AddNetworkString("coinret")
			net.Start("coinret")
				net.WriteString(pl:Name())
				net.WriteInt(myteam, 16)
				net.WriteInt(coins, 16)
			net.Broadcast()
			pl:AddFrags(coins)
		end
	end

	function self:PlayerTookCoins(pl, box, coins, otherteam)
		team.SetScore(otherteam, team.GetScore(otherteam) - coins)
		box:SetCoins(box:GetCoins() + coins)
		if otherteam == TEAM_RED then
			box.RedCoins = box.RedCoins + coins
		elseif otherteam == TEAM_GREEN then
			box.GreenCoins = box.GreenCoins + coins
		end
		box:EmitSound("vo/ravenholm/madlaugh0"..math.random(1,4)..".wav", 95, math.Rand(190, 210))
		-- umsg.Start("cointak")
		-- 	umsg.String(pl:Name())
		-- 	umsg.Short(otherteam)
		-- 	umsg.Short(coins)
		-- umsg.End()
		util.AddNetworkString("cointak")
		net.Start("cointak")
			net.WriteString(pl:Name())
			net.WriteInt(otherteam, 16)
			net.WriteInt(coins, 16)
		net.Broadcast()
	end

	hook.Add("OnBoxRemoved", "CTC_OnBoxRemoved", function(box)
		local pos = box:GetPos()
		local vel = box:GetVelocity()
		local droppedred = 0
		local droppedgreen = 0
		for i=1, box:GetCoins() do
			local ent = ents.Create("coin")
			ent:SetPos(pos)
			if 0 < box.RedCoins then
				ent:SetColor(255, 100, 100, 255)
				ent.Team = TEAM_RED
				box.RedCoins = box.RedCoins - 1
				droppedred = droppedred + 1
			elseif 0 < box.GreenCoins then
				ent:SetColor(100, 255, 100, 255)
				ent.Team = TEAM_GREEN
				box.GreenCoins = box.GreenCoins - 1
				droppedgreen = droppedgreen + 1
			end
			ent:Spawn()
			local dir = VectorRand()
			dir.x = 0
			ent:GetPhysicsObject():SetVelocityInstantaneous(vel + dir:GetNormalized() * 400)
		end

		if 0 < droppedred or 0 < droppedgreen then
			local owner = box:GetOwner()
			if owner:IsValid() then
				-- umsg.Start("coindrp")
				-- 	umsg.String(owner:Name())
				-- 	umsg.Short(droppedred)
				-- 	umsg.Short(droppedgreen)
				-- umsg.End()
				util.AddNetworkString("coindrp")
				net.Start("coindrp")
					net.WriteString(owner:Name())
					net.WriteInt(droppedred, 16)
					net.WriteInt(droppedgreen, 16)
				net.Broadcast()
			else
				-- umsg.Start("coindrp")
				-- 	umsg.String("Someone")
				-- 	umsg.Short(droppedred)
				-- 	umsg.Short(droppedgreen)
				-- umsg.End()
				util.AddNetworkString("coindrp")
				net.Start("coindrp")
					net.WriteString("Someone")
					net.WriteInt(droppedred, 16)
					net.WriteInt(droppedgreen, 16)
				net.Broadcast()

			end
		end
	end)
end
