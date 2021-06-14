function GM:CTCInitialize()
	self.Name = self.Name.." ("..self.GameTranslates["CTC"]..")"
	self.GameType = "CTC"
	self.FlagEntity = "coinbank"
	self.StartScore = 50

	function self:GameTypeHUDPaint()
		for _, pl in pairs(player.GetAll()) do
			local box = pl:GetBox()
			if box:IsValid() then
				local tpos = (box:GetPos() - Vector(0, 0, 32)):ToScreen()
				if tpos.visible then
					local coins = box:GetCoins()
					if 0 < coins then
						draw.DrawTextShadow(coins, "mayhem26", tpos.x, tpos.y - 100, COLOR_YELLOW, color_black, TEXT_ALIGN_CENTER)
					end
				end
			end
		end
	end

	usermessage.Hook("cointak", function(um)
		local playername = um:ReadString()
		local myteam = um:ReadShort()
		local amount = um:ReadShort()

		if amount == 1 then
			GAMEMODE:AddNotify(playername.." took 1 coin from the "..team.GetName(myteam).." coin bank!", team.GetColor(myteam), 5)
		else
			GAMEMODE:AddNotify(playername.." took "..amount.." coins from the "..team.GetName(myteam).." coin bank!", team.GetColor(myteam), 5)
		end

		if TEAM_GREEN == myteam then
			surface.PlaySound("mayhem/green_stolen.wav")
		else
			surface.PlaySound("mayhem/red_stolen.wav")
		end
	end)

	usermessage.Hook("coindrp", function(um)
		local playername = um:ReadString()
		local redcoins = um:ReadShort()
		local greencoins = um:ReadShort()

		if redcoins == 0 and 0 < greencoins then
			GAMEMODE:AddNotify(playername.." dropped "..greencoins.." of "..team.GetName(TEAM_GREEN).."'s coins!", team.GetColor(TEAM_GREEN), 5)
		elseif greencoins == 0 and 0 < redcoins then
			GAMEMODE:AddNotify(playername.." dropped "..redcoins.." of "..team.GetName(TEAM_RED).."'s coins!", team.GetColor(TEAM_RED), 5)
		else
			GAMEMODE:AddNotify(playername.." dropped "..redcoins.." of "..team.GetName(TEAM_RED).."'s and "..greencoins.." of "..team.GetName(TEAM_GREEN).."'s coins!", nil, 5)
		end

		surface.PlaySound("mayhem/coin.wav")
	end)

	usermessage.Hook("coinret", function(um)
		local playername = um:ReadString()
		local myteam = um:ReadShort()
		local amount = um:ReadShort()

		if amount == 1 then
			GAMEMODE:AddNotify(playername.." returned 1 coin for "..team.GetName(myteam).."!", team.GetColor(myteam), 5)
		else
			GAMEMODE:AddNotify(playername.." returned "..amount.." coins for "..team.GetName(myteam).."!", team.GetColor(myteam), 5)
		end

		if TEAM_GREEN == myteam then
			surface.PlaySound("mayhem/green_take.wav")
		else
			surface.PlaySound("mayhem/mayhem_take.wav")
		end
	end)

	local matFlag = surface.GetTextureID("noxctf/flagicon_home")
	self.HUDPaintBackground = function(me)
		if BOXENT:IsValid() then
			local boxpos = BOXENT:GetPos()
			for _, ent in pairs(ents.FindByClass(me.FlagEntity)) do
				local fpos = ent:GetPos() + Vector(0, 0, -24)
				local tpos = fpos:ToScreen()
				if tpos.x < 16 or w - 16 < tpos.x or tpos.y < 16 or h - 16 < tpos.y then
					tpos = (boxpos + (fpos - boxpos):GetNormalized() * fpos:Distance(boxpos)):ToScreen()
				end

				surface.SetTexture(matFlag)
				surface.SetDrawColor(ent:GetColor())
				surface.DrawTexturedRect(math.max(16, math.min(tpos.x, w - 16)) - 16, math.max(16, math.min(tpos.y, h - 16)) - 16, 32, 32)
			end
		end
	end
end

GM.HelpTopics["Coin Collectors"] = {
	"20|This is your team's coin collection.",
	"21|Steal the other team's coins by touching their collection ...|mayhem/green_stolen.wav",
	"22|... and touch your team's collection to store them for your side. The first team to get all 100 coins or the most after 20 minutes wins!|mayhem/roundwin.wav"
}
