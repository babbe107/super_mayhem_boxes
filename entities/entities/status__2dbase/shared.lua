ENT.Type = "anim"

function ENT:PhysicsCollide()
end
ENT.StartTouch = ENT.PhysicsCollide
ENT.Touch = ENT.PhysicsCollide
ENT.EndTouch = ENT.PhysicsCollide
ENT.AcceptInput = ENT.PhysicsCollide
ENT.KeyPress = ENT.PhysicsCollide
ENT.KeyRelease = ENT.PhysicsCollide

ENT.GetPlayer = ENT.GetParent
