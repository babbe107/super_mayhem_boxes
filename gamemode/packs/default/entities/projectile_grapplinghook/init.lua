-- This entity is pretty hacky. All to make sure the physics don't crash.

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Items/CrossbowRounds.mdl")
	self:DrawShadow(false)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetBuoyancyRatio(0.01)
		phys:Wake()
	end

	self.Length = 200
	self.DeathTime = CurTime() + 10
end

util.PrecacheSound("npc/barnacle/barnacle_crunch2.wav")
function ENT:OnRemove()
	if self.Constraint then
		self:EmitSound("npc/barnacle/barnacle_crunch2.wav")
	end
end

function ENT:Think()
	if self.DeathTime and self.DeathTime < CurTime() or not self.Owner:IsValid() or self.StuckTo and not self.StuckTo:IsValid() then
		self:Remove()
	elseif self.Stuck then
		local player = self.Owner:GetOwner()
		if player:IsValid() and self.Constraint then
			local stuckto = self.StuckTo
			if stuckto and stuckto:IsValid() and stuckto:GetClass() == "boxplayer" then
				local enemy = stuckto:GetOwner()
				enemy.LastAttacker = player
				enemy.LastAttacked = CurTime()
			end
			if player:KeyDown(IN_FORWARD) then
				self.Length = math.Clamp(self.Length - FrameTime() * 400, 32, 1000)
				self.Constraint:Fire("SetSpringLength", self.Length, 0)
				self.Rope:Fire("SetLength", self.Length, 0)
				self:NextThink(CurTime())
				return true
			elseif player:KeyDown(IN_BACK) then
				self.Length = math.Clamp(self.Length + FrameTime() * 400, 32, 1000)
				self.Constraint:Fire("SetSpringLength", self.Length, 0)
				self.Rope:Fire("SetLength", self.Length, 0)
				self:NextThink(CurTime())
				return true
			end
		else
			self:Remove()
		end
	else
		if self.ThinkCollide then
			local phys = self:GetPhysicsObject()
			local data = self.ThinkCollide
			self.Stuck = true

			self.DeathTime = nil

			local dist = data.HitPos:Distance(self.Owner:GetPos())
			if 1100 < dist then return end

			self.Length = dist

			local ent = data.HitEntity
			if ent:IsValid() and (ent.GrappleHookable and ent:GrappleHookable(self) or string.find(ent:GetClass(), 1, 5) == "func_") then
				constraint.Weld(ent, self, 0, 0, 0, 1)
				self.StuckTo = ent
			else
				phys:EnableMotion(false)
			end

			self.Constraint, self.Rope = constraint.Elastic(self.Owner, self, 0, 0, Vector(0,0,0), Vector(0,0,0), 400, 40, 0, "cable/rope", 4.5, true)
			self:EmitSound("physics/metal/sawblade_stick"..math.random(1,3)..".wav")
			self.ThinkCollide = nil

			gamemode.Call("PlayerGrappledObject", self.Owner:GetOwner(), self.Owner, self, ent, data)
		end

		-- Think every frame.
		self:NextThink(CurTime())
		return true
	end
end

-- Doing just about anything with this function will crash the game or fuck the physics up. That's why we do it on the next think.
function ENT:PhysicsCollide(data, phys)
	if not self.Stuck and math.abs(data.HitNormal.x) ~= 1 and self.Owner:IsValid() then
		self.ThinkCollide = data
		self:NextThink(CurTime())
	end
end
