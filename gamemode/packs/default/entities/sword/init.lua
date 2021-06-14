AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/peanut/conansword.mdl")
	self:DrawShadow(false)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end

	self:SetTrigger(true)
	self:SetNotSolid(true)
end

function ENT:Think()
end

function ENT:Touch(ent)
end

function ENT:StartTouch(ent)
	local mybox = self:GetOwner()
	if ent:GetClass() == "boxplayer" and ent:Team() ~= mybox:Team() then
		--[[local status = ent:GetOwner():GetStatus("weapon_sword")
		if status then
			local swordent = status.Sword
			local nearest = swordent:NearestPoint(ent)
			if nearest:Distance(ent:NearestPoint(nearest)) <= 4 then
				local enemybox = ent:GetOwner()

				local enemyboxpos = enemybox:GetPos()
				local myboxpos = mybox:GetPos()

				local mid = (enemyboxpos + myboxpos) / 2

				enemybox:GetPhysicsObject():ApplyForceCenter((enemyboxpos - mid):Normalize() * 70000)
				mybox:GetPhysicsObject():ApplyForceCenter((myboxpos - mid):Normalize() * 70000)

				local effectdata = EffectData()
					effectdata:SetOrigin(mid)
				util.Effect("swordcollide", effectdata)
				return
			end
		end]]

		ent:TakeDamage(20, mybox:GetOwner(), self)
		self:EmitSound("ambient/machines/slicer"..math.random(1, 4)..".wav")
	end
end

function ENT:EndTouch(ent)
	if ent:GetClass() == "boxplayer" and ent:Team() ~= self:GetOwner():Team() then
		ent:TakeDamage(20, self:GetOwner():GetOwner(), self)
		self:EmitSound("ambient/machines/slicer"..math.random(1, 4)..".wav")
	end
end

function ENT:PhysicsCollide(data, phys)
end
