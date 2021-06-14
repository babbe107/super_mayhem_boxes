-- This entity allows you to make interactive things.

ENT.Type = "brush"

function ENT:Initialize()
	self.Key = self.Key or IN_FORWARD
	if self.On == nil then
		self.On = true
	end
	if self.Continuous == nil then
		self.Continuous = true
	end
end

function ENT:Think()
end

function ENT:StartTouch(ent)
end

function ENT:Touch(ent)
	if ent:GetClass() == "boxplayer" and (ent:GetOwner():KeyPressed(self.Key) or self.Continuous and ent:GetOwner():KeyDown(self.Key)) then
		ent["TouchingEater"..self:EntIndex()] = true

		self:FireOutput("OnKeyEat", ent, ent:GetOwner())
	end
end

function ENT:EndTouch(ent)
	if ent:GetClass() == "boxplayer" and ent["TouchingEater"..self:EntIndex()] then
		ent["TouchingEater"..self:EntIndex()] = nil

		self:FireOutput("OnAtenLeave", ent, ent:GetOwner())
	end
end

function ENT:AcceptInput(name, caller, activator, arg)
	name = string.lower(name)
	if name == "seton" then
		self.On = tonumber(arg) == 1
		return true
	elseif name == "setcontinuous" then
		self.Continuous = tonumber(arg) == 1
		return true
	elseif name == "enablecontinuous" then
		self.Continuous = true
		return true
	elseif name == "disablecontinuous" then
		self.Continuous = false
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
	if key == "key" then
		local id = tonumber(value)
		if id then
			self.Key = id
		elseif _G[value] then
			self.Key = tonumber(_G[id]) or self.Key or IN_USE
		end
	elseif key == "onkeyeat" then
		self:AddOnOutput("OnKeyEat", value)
	elseif key == "onatenleave" or key == "oneatenleave" then
		self:AddOnOutput("OnAtenLeave", value)
	elseif key == "starton" then
		self.On = tonumber(value) == 1
	elseif key == "continuous" then
		self.Continuous = tonumber(value) == 1
	end
end
