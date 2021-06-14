AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Items/item_item_crate.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetTrigger(true)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(5)
		phys:EnableMotion(false)
		phys:Wake()
	end

	local col = team.TeamInfo[self.Team].Color
	self:SetColor(col.r, col.g, col.b, 255)

	self:SetName(self.Team)
end

function ENT:EndTouch()
end

function ENT:Touch()
end

function ENT:StartTouch(hitent)
	if ENDGAME then return end

	if hitent:GetClass() == "boxplayer" then
		local pl = hitent:GetOwner()
		local plteam = pl:Team()
		local myteam = self.Team
		local hitcoins = hitent:GetCoins()
		if plteam == myteam then
			if 0 < hitcoins then
				team.SetScore(myteam, team.GetScore(myteam) + hitcoins)
				hitent:SetCoins(0)
				hitent.RedCoins = 0
				hitent.GreenCoins = 0

				gamemode.Call("PlayerReturnedCoins", pl, hitent, hitcoins)
			end
		elseif hitcoins < 20 and 0 < team.GetScore(myteam) then
			if 2 <= #player.GetAll() then
				gamemode.Call("PlayerTookCoins", pl, hitent, math.min(20 - hitcoins, team.GetScore(myteam)), myteam)
			else
				pl:PrintMessage(HUD_PRINTCENTER, "You can't take the coins of an unrepresented team!")
			end
		end
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

util.PrecacheSound("npc/turret_floor/click1.wav")
function ENT:PhysicsCollide(data, phys)
	if 50 < data.Speed and 0.3 < data.DeltaTime then
		self:EmitSound("npc/turret_floor/click1.wav")
	end
end
