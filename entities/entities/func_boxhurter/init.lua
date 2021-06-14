-- func_boxhurter
-- Boxes that enter here will get hurt obviously. This is trigger_hurt for Super Mayhem Boxes. You should basically never use trigger_hurt!!
-- Key Values
--  damage - Numeric value for damage. Default is 10.
--  damagerecycle - How long before the box can be damaged again by this trigger. Default is 0 (instantly).
--  starton 0/1 - Should the trigger start on or off. On by default.
-- Inputs
--  seton - 0 for off, 1 for on.
--  enable - Same as seton 1.
--  disable - Same as seton 0.

ENT.Type = "brush"

function ENT:Initialize()
	self.Damage = self.Damage or 10
	self.DamageRecycle = self.DamageRecycle or 0
	if self.On == nil then
		self.On = true
	end

	self.NextDamage = {}
end

function ENT:Think()
end

function ENT:StartTouch(ent)
end

function ENT:EndTouch(ent)
end

function ENT:AcceptInput(name, caller, activator, arg)
	name = string.lower(name)
	if name == "seton" then
		self.On = tonumber(arg) == 1
		return true
	elseif name == "enable" then
		self.On = true
		return true
	elseif name == "disable" then
		self.On = false
		return true
	end
end

function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "damage" then
		self.Damage = tonumber(value) or 0
	elseif key == "damagerecycle" then
		self.DamageRecycle = tonumber(value) or 0
	elseif key == "starton" then
		self.On = tonumber(value) == 1
	end
end

function ENT:Touch(ent)
	if self.On and ent.TouchBoxHurter and (self.NextDamage[ent] or 0) <= CurTime() then
		self.NextDamage[ent] = CurTime() + self.DamageRecycle

		ent:TouchBoxHurter(self)
	end
end
