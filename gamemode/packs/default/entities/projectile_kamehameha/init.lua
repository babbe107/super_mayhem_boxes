AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	phys:EnableGravity(false)
	phys:EnableDrag(false)
	phys:SetMass(100)
	phys:Wake()

	self.DeathTime = CurTime() + 10

	self:EmitSound("mayhem/kamehameha_fire.wav")
end

function ENT:OnRemove()
	local box = self.Box
	if box and box:IsValid() then
		local phys = box:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableMotion(true)
		end
	end
end

function ENT:Think()
	if self.DeathTime < CurTime() then
		self:Remove()
	end
end

function ENT:PhysicsCollide(data, phys)
	local hitentity = data.HitEntity
	hitentityvalid = hitentity:IsValid()
	if not self.Exploded and not (hitentityvalid and hitentity:GetClass() == "projectile_grapplinghook") then
		--[[if hitentityvalid and hitentity:GetClass() == "projectile_kamehameha" and hitentity.Team ~= self.Team and not self.PowerStruggle and not hitentity.PowerStruggle then
			self.PowerStruggle = hitentity
			self.DeathTime = 9999999999
		elseif not hitentityvalid and self.Owner:IsValid() and self.Owner:KeyDown(IN_JUMP) then
			self.PowerThrust = true
			self.DeathTime = 9999999999
		else]]
			self.Exploded = true
			self.DeathTime = 0

			phys:EnableMotion(false)
			local box = self.Box
			if box and box:IsValid() then
				local phys = box:GetPhysicsObject()
				if phys:IsValid() then
					phys:EnableMotion(true)
				end
			end

			util.BlastDamage(self, self.Owner, data.HitPos, 1800, 800)

			local effectdata = EffectData()
				effectdata:SetOrigin(data.HitPos)
				effectdata:SetNormal(data.HitNormal)
			util.Effect("kameexp", effectdata)
		--end
	end
end
