AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_junk/garbage_metalcan001a.mdl")
	self:PhysicsInitSphere(12)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	--self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	local phys = self:GetPhysicsObject()
	--self:SetTrigger(true)
	if phys:IsValid() then
		phys:SetMass(5)
		phys:SetBuoyancyRatio(0.04)
		phys:EnableMotion(true)
		phys:Wake()
	end
	self:Fire("return", "", 30)
end

function ENT:AcceptInput(name, activator, caller, arg)
	if self.ToRemove then return true end
	if name == "return" then
		self.ToRemove = true

		if self.Team == TEAM_RED then
			team.SetScore(TEAM_RED, team.GetScore(TEAM_RED) + 1)
			if 100 <= team.GetScore(TEAM_RED) then
				GAMEMODE:EndGame(TEAM_RED)
			end
		elseif self.Team == TEAM_GREEN then
			team.SetScore(TEAM_GREEN, team.GetScore(TEAM_GREEN) + 1)
			if 100 <= team.GetScore(TEAM_GREEN) then
				GAMEMODE:EndGame(TEAM_GREEN)
			end
		end
		self:Remove()
		return true
	end
end

function ENT:Think()
	if self.ToRemove then self:Remove() end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_PVS
end

function ENT:TouchBoxHurter(ent)
	if 100 <= ent.Damage and not self.ToRemove then
		self:Fire("return", "", 0)
	end
end

util.PrecacheSound("npc/turret_floor/click1.wav")
function ENT:PhysicsCollide(data, phys)
	if self.ToRemove then return end

	if 50 < data.Speed and 0.3 < data.DeltaTime then
		self:EmitSound("npc/turret_floor/click1.wav")
	end

	local hitent = data.HitEntity
	if not ENDGAME and hitent and hitent:IsValid() and hitent:GetClass() == "boxplayer" and hitent:GetCoins() < 20 then
		hitent:SetCoins(hitent:GetCoins() + 1)
		if self.Team == TEAM_RED then
			hitent.RedCoins = hitent.RedCoins + 1
		elseif self.Team == TEAM_GREEN then
			hitent.GreenCoins = hitent.GreenCoins + 1
		end
		hitent:EmitSound("mayhem/coin.wav")
		self.ToRemove = true
		self:NextThink(CurTime())
	end
end
