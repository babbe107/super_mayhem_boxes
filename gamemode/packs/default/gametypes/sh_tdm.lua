GM.TDM_KillsToWin = CreateConVar("smb_tdm_killstowin", 50, FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED)

table.insert(GM.GameTypes, "TDM")
GM.GameTypeDescriptions["TDM"] = "The object of the game is to destroy the other team. First team to "..GM.TDM_KillsToWin:GetInt().." kills wins!"
GM.GameTranslates["TDM"] = "Team Deathmatch"
