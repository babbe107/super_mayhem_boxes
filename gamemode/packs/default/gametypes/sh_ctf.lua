GM.CTF_CapturesToWin = CreateConVar("smb_ctf_capturestowin", 3, FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED)

table.insert(GM.GameTypes, "CTF")
GM.GameTypeDescriptions["CTF"] = "The classic capture the flag game. Take the enemy flag and bring it back to your own!"
GM.GameTranslates["CTF"] = "Capture the Flag"
