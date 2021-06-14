function GM:CTFInitialize()
	self.Name = self.Name.." ("..self.GameTranslates["CTF"]..")"
	self.GameType = "CTF"
	self.FlagEntity = "2dflag"
	self.StartScore = 0

	usermessage.Hook("FTak", function(um)
		local playername = um:ReadString()
		local myteam = um:ReadShort()

		GAMEMODE:AddNotify(playername.." took the "..team.GetName(myteam).." flag!", team.GetColor(myteam))
		surface.PlaySound("npc/roller/mine/rmine_tossed1.wav")
	end)

	usermessage.Hook("FDro", function(um)
		local selfteam = um:ReadShort()
		local playername = um:ReadString()
		if selfteam == MySelf:Team() then
			GAMEMODE:AddNotify(playername.." dropped your flag! Get it back!.", team.GetColor(selfteam))
		else
			GAMEMODE:AddNotify(playername.." dropped the "..team.GetName(selfteam).." flag.", team.GetColor(selfteam))
		end
		surface.PlaySound("mayhem/bump.wav")
	end)

	usermessage.Hook("FRet", function(um)
		GAMEMODE:AddNotify(um:ReadString())
		surface.PlaySound("mayhem/mayhemriff.wav")
	end)

	usermessage.Hook("FCap", function(um)
		local playername = um:ReadString()
		local myteam = um:ReadShort()
		local otherteam = um:ReadShort()
		local silent = um:ReadBool()

		GAMEMODE:AddNotify(playername.." of "..team.GetName(myteam).." captured the "..team.GetName(otherteam).." flag!", team.GetColor(myteam), 5)

		if not silent then
			if myteam == MySelf:Team() then
				surface.PlaySound("mayhem/roundwin.wav")
			else
				surface.PlaySound("mayhem/gameover.wav")
			end
		end
	end)

	local matHome = surface.GetTextureID("noxctf/flagicon_home")
	local matDropped = surface.GetTextureID("noxctf/flagicon_dropped")
	local matField = surface.GetTextureID("noxctf/flagicon_field")
	self.HUDPaintBackground = function(me)
		if BOXENT:IsValid() then
			local boxpos = BOXENT:GetPos()
			for _, ent in pairs(ents.FindByClass(me.FlagEntity)) do
				local fpos = ent:GetPos() + Vector(0, 0, -24)
				local tpos = fpos:ToScreen()

				if tpos.x < 16 or w - 16 < tpos.x or tpos.y < 16 or h - 16 < tpos.y and boxpos and fpos then
					tpos = (boxpos + (fpos - boxpos):GetNormalized() * fpos:Distance(boxpos)):ToScreen()
				end

				local x = math.max(16, math.min(tpos.x, w - 16))
				local y = math.max(16, math.min(tpos.y, h - 16))

				local skin = ent:GetDTInt(0)
				if skin == 0 then
					surface.SetTexture(matHome)
					surface.SetDrawColor(ent:GetColor())
				elseif skin == 1 then
					surface.SetTexture(matField)
					if 0 < math.sin(RealTime() * 23) then
						surface.SetDrawColor(255, 255, 255, 200)
					else
						surface.SetDrawColor(ent:GetColor())
					end
				else
					surface.SetTexture(matDropped)
					if 0 < math.cos(RealTime() * 23) then
						surface.SetDrawColor(255, 255, 255, 200)
					else
						surface.SetDrawColor(ent:GetColor())
					end
				end

				surface.DrawTexturedRect(x - 16, y - 16, 32, 32)
			end
		end
	end
end

GM.HelpTopics["Capture the Flag"] = {
"1|This is your team's flag. Make sure the enemy doesn't even get near it!",
"2|This is the enemy flag. Touch it to latch on to it ...|npc/roller/mine/rmine_tossed1.wav",
"3|... travel back to your base ...",
"4|... and touch your own flag while it's safely at home to score! First team to get 3 captures or the best score at the end of 20 minutes wins!|mayhem/roundwin.wav",
"5|But if someone drops a flag while carrying it ...|mayhem/bump.wav",
"6|... it will just sit there until someone picks it up or a member of the same team returns it by touching it.",
"7|It also goes back on its own after waiting around for too long!|mayhem/mayhemriff.wav"
}
