-- trigger_removestatus
-- Strip weapons and stuff.
-- Key Values:
--  starton 0/1 - If it starts on or off. On by default.
--  status - Status to look for. Nothing by default.
--  statusfilter - But ignore any status named this. Nothing by default.
-- Inputs:
--  seton 0/1 - If the value is 1 then it turns on. Otherwise it turns off.
--  enable - Same as running seton 1
--  disable - Same as running seton 0

ENT.Type = "brush"

function ENT:Initialize()
	if self.On == nil then
		self.On = true
	end
end

function ENT:Think()
end

function ENT:Touch(ent)
	if self.On and self.Status and ent:GetClass() == "boxplayer" then
		ent:GetOwner():RemoveStatus(self.Status, true, true, self.StatusFilter)
	end
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
	if key == "status" then
		self.Status = value
	elseif key == "statusfilter" or key == "filterstatus" then
		if value == "nil" then
			self.StatusFilter = nil
		else
			self.StatusFilter = value
		end
	elseif key == "starton" then
		self.On = tonumber(value) == 1
	end
end
