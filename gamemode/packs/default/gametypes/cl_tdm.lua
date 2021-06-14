function GM:TDMInitialize()
	self.Name = self.Name.." ("..self.GameTranslates["TDM"]..")"
	self.GameType = "TDM"
	self.FlagEntity = nil
	self.StartScore = 0
end

GM.HelpTopics["Team Deathmatch"] = {
"12|The rules of this game type are simple. Kill the enemy team more than they kill yours!"
}
