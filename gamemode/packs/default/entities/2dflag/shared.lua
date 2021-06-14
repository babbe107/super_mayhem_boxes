ENT.Type = "anim"

function ENT:GrappleHookable(proj)
	return self:GetPhysicsObject():IsMoveable()
end
