ENT.Type = "point"

function ENT:AcceptInput(name, args, activator, caller, arg)
	name = string.lower(name)
	if name == "seton" then
		self.Enabled = tonumber(args) == 1
		return true
	elseif name == "enable" then
		self.Enabled = true
		return true
	elseif name == "disable" then
		self.Enabled = false
		return true
	end
end

function ENT:Initialize()
	if self.Enabled == nil then
		self.Enabled = true
	end
	self.Team = self.Team or 0
end

function ENT:OnRemove()
end

function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "startdisabled" then
		self.Enabled = tonumber(value) == 0
	elseif key == "starton" then
		self.Enabled = tonumber(value) == 1
	elseif name == "onscored" then
		self:AddOnOutput("OnScored", value)
	elseif key == "team" then
		if value == "red" then
			self.Team = TEAM_RED
		elseif value == "green" then
			self.Team = TEAM_GREEN
		else
			self.Team = 0
		end
	end
end
