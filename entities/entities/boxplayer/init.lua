AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_junk/wood_crate001a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_BBOX)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:EnableMotion(true)
		phys:SetBuoyancyRatio(0.012)
	end

	self.NextJumpedOn = 0
	self.NextJump = 0
	self.NextHurt = 0
	self.JumpedOnCombo = 0
	self.RedCoins = 0
	self.GreenCoins = 0
	self.Weapon = NULL

	self.BR = self:BoundingRadius()
	self.BRP = Vector(300,0,-30)

	self.LastThink = CurTime()
end

function ENT:TouchBoxHurter(ent)
	if self.NextHurt <= CurTime() and 0 < ent.Damage then
		if 100 <= ent.Damage then
			self:GetOwner():GodDisable()
		end

		self:TakeDamage(ent.Damage, ent)
	end
end

function ENT:OnTakeDamage(dmginfo)
	local dmg = dmginfo:GetDamage()
	local attacker = dmginfo:GetAttacker()
	self:GetOwner():TakeDamage(dmg, attacker, dmginfo:GetInflictor())
	if dmginfo:IsExplosionDamage() and not (attacker:IsPlayer() and attacker:Team() == self:Team() and attacker ~= self:GetOwner()) then
		self:GetPhysicsObject():ApplyForceCenter(dmg * 850 * (self:GetPos() - dmginfo:GetDamagePosition()):GetNormalized())

		if 20 < dmg and self:WaterLevel() == 0 then
			self:GetOwner():GiveStatus("firedamage", dmg * 0.1).Attacker = attacker
		end
	end
end

function ENT:PhysicsCollide(data, phys)
	local ent = data.HitEntity
	if ent:IsValid() and ent:GetClass() == "boxplayer" and self:Team() ~= ent:Team() then
		local enemy = ent:GetOwner()
		enemy.LastAttacker = self:GetOwner()
		enemy.LastAttacked = CurTime()
		if ent.NextJumpedOn < CurTime() then
			local selfpos = self:GetPos()
			local entpos = ent:GetPos()
			if math.abs(selfpos.y - entpos.y) < self.BR * 0.9 and entpos.z < selfpos.z then
				ent:TakeDamage(50, self:GetOwner(), self)
				local vel = self:GetVelocity()
				vel.z = 1000
				phys:SetVelocityInstantaneous(vel)
				self:EmitSound("mayhem/stomp.wav", 80, math.min(255, 100 + self.JumpedOnCombo * 20))
				ent.NextJumpedOn = CurTime() + 0.1
				self.JumpedOnCombo = self.JumpedOnCombo + 1
			end
		end
	end
end

ENT.GetPredictedPos = debug.getregistry().Entity.GetPos

function ENT:Think()
	local owner = self:GetOwner()
	if self.Removing or not owner:IsValid() then
		self:Remove()
		return
	end

	if owner:IsValid() then
		local ct = CurTime()
		local deltatime = ct - self.LastThink
		self.LastThink = ct

		owner:SetPos(self:GetPos() + self.BRP)

		local phys = self:GetPhysicsObject()
		local vel = phys:GetVelocity()

		local onground, onobject = self:Grounded()
		if owner:KeyDown(IN_MOVELEFT) then
			if not owner:KeyDown(IN_MOVERIGHT) then
				if onground then
					vel = vel + Vector(0, -1400 * deltatime, 0)
				else
					vel = vel + Vector(0, -650 * deltatime, 0)
				end
			end
		elseif owner:KeyDown(IN_MOVERIGHT) then
			if not owner:KeyDown(IN_MOVELEFT) then
				if onground then
					vel = vel + Vector(0, 1400 * deltatime, 0)
				else
					vel = vel + Vector(0, 650 * deltatime, 0)
				end
			end
		end

		if onground and not onobject then self.JumpedOnCombo = 0 end

		phys:SetVelocityInstantaneous(vel)

		self:NextThink(ct)
		return true
	end
end

function ENT:KeyPress(pl, key)
	if key == IN_JUMP and self.NextJump < CurTime() then
		if self:PredictedGrounded() then
			self.NextJump = CurTime()
			pl:EmitSound("mayhem/jump.wav")
			local vel = self:GetVelocity()
			vel.z = math.max(vel.z + 800, 800)
			self:GetPhysicsObject():SetVelocityInstantaneous(vel)
		elseif 0 < self:WaterLevel() then
			self.NextJump = CurTime() + 0.1
			pl:EmitSound("mayhem/swim.wav")
			if pl:KeyDown(IN_BACK) then
				local vel = self:GetVelocity()
				vel.z = math.max(vel.z + 60, 60)
				self:GetPhysicsObject():SetVelocityInstantaneous(vel)
			elseif pl:KeyDown(IN_FORWARD) then
				self:GetPhysicsObject():ApplyForceCenter(Vector(0,0,9000))
			else
				self:GetPhysicsObject():ApplyForceCenter(Vector(0,0,5000))
			end
		end
	elseif key == IN_WALK then
		self:SetDTBool(3, true)
	end

	local wep = self.Weapon
	if wep:IsValid() then wep:KeyPress(pl, self, key) end
end

function ENT:KeyRelease(pl, key)
	if key == IN_WALK then
		self:SetDTBool(3, false)
	end

	local wep = self.Weapon
	if wep:IsValid() then wep:KeyRelease(pl, self, key) end
end

function ENT:OnRemove()
	gamemode.Call("OnBoxRemoved", self)

	local owner = self:GetOwner()
	if owner:IsValid() then
		owner:SetPos(self:GetPos())
	end
end

function ENT:Destroyed(dmginfo)
	gamemode.Call("OnBoxDestroyed", self, self:GetOwner(), dmginfo)
end
