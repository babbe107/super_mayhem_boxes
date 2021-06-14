AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
end

function ENT:Think()
	local owner = self:GetOwner()
	if owner:IsValid() then
		local player = owner:GetOwner()
		if player:IsValid() then
			if player:KeyDown(IN_ATTACK) then
				-- print("AddAngleVelocity")
				-- print(Angle(FrameTime() * 610, 0, 0))
				-- print(type(Angle(FrameTime() * 610, 0, 0)))
				owner:GetPhysicsObject():AddAngleVelocity(Vector(FrameTime() * 610, 0, 0)) -- This crashes??
			elseif player:KeyDown(IN_ATTACK2) then
				owner:GetPhysicsObject():AddAngleVelocity(Vector(FrameTime() * -610, 0, 0))
			end
			self:NextThink(CurTime())
			return true
		end
	end
end

function ENT:KeyPress(pl, box, key)
end

function ENT:PlayerSet(pPlayer, eBox, bExists)
	pPlayer:RemoveStatus("weapon_*", true, true, "status_weapon_sword")
	eBox.Weapon = self
	if not bExists then
		--[[local ent = ents.Create("prop_dynamic_override")
		if ent:IsValid() then
			ent:SetModel("models/peanut/conansword.mdl")
			local up = self:GetUp()
			ent:SetPos(self:GetPos() + Vector(0,0,38))
			ent:SetAngles(Angle(0, 180, 180))
			ent:SetKeyValue("solid", "6")
			ent:Spawn()
			ent:SetParent(self)
			self.Sword = ent
		end]]
		local ent = ents.Create("sword")
		if ent:IsValid() then
			local up = self:GetUp()
			ent:SetPos(self:GetPos() + Vector(0,0,38))
			ent:SetAngles(Angle(0, 180, 180))
			ent:SetColor(eBox:GetColor())
			ent:Spawn()
			ent:SetParent(self)
			ent:SetOwner(eBox)
			self.Sword = ent
		end
		pPlayer:EmitSound("physics/metal/sawblade_stick"..math.random(1,3)..".wav")
		pPlayer:EmitSound("mayhem/powerup.wav")
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(eBox:GetPos())
		effectdata:SetEntity(eBox)
	util.Effect("boxpoweredup", effectdata)
end

function ENT:OnRemove()
	self.Sword:Remove()
end
