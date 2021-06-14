AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetModel("models/props_trainstation/trainstation_clock001.mdl")
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

function ENT:StartTouch(ent)
	local owner = self:GetOwner()
	if ent:GetClass() == "boxplayer" and ent ~= owner and ent:Team() ~= owner:Team() then
		ent:TakeDamage(100, owner:GetOwner(), self)
	end
end

function ENT:OnRemove()
	local player = self:GetOwner():GetOwner()
	player:GodDisable()
	player:EmitSound("ambient/levels/citadel/portal_beam_shoot5.wav")
end

function ENT:PlayerSet(pPlayer, eBox, bExists)
	self.DieTime = CurTime() + 10
	pPlayer:EmitSound("ambient/levels/citadel/portal_beam_shoot6.wav")
	if not bExists then
		local effectdata = EffectData()
			effectdata:SetOrigin(eBox:GetPos())
			effectdata:SetEntity(eBox)
		util.Effect("boxpoweredup", effectdata)

		pPlayer:GodEnable()
		-- timer.Simple(0, util.SpriteTrail, self, 0, color_white, false, 64, 32, 0.75, 1 / 42, "trails/tube.vmt")
		timer.Simple(0, function() util.SpriteTrail(self, 0, color_white, false, 64, 32, 0.75, 1 / 42, "trails/tube.vmt") end) 
	end
end
