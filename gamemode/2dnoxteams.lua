team = {}
team.TeamInfo = {}
team.DefaultColor = Color(255, 255, 100, 255)

team.TeamInfo[TEAM_CONNECTING] = { Name = "Joining/Connecting", Color = DefaultColor, Score = 0}
team.TeamInfo[TEAM_UNASSIGNED] = { Name = "Unassigned", Color = DefaultColor, Score = 0}
team.TeamInfo[TEAM_SPECTATOR] = { Name = "Spectator", Color = DefaultColor, Score = 0}

function team.SetUp(id, name, color)
	team.TeamInfo[id] = {Name = name, Color = color, Score = 0, Props = 0}
end

function team.TotalWeight(index)
	local weight = 0
	for id, pl in pairs(player.GetAll()) do
		if pl:Team() == index then
			weight = weight + pl:TeamWeight()
		end
	end
	return weight
end

function team.TotalDeaths(index)
	local score = 0
	for id, pl in pairs(player.GetAll()) do
		if pl:Team() == index then
			score = score + pl:Deaths()
		end
	end
	return score
end

function team.TotalFrags(index)
	local score = 0
	for id, pl in pairs(player.GetAll()) do
		if pl:Team() == index then
			score = score + pl:Frags()
		end
	end
	return score
end

function team.NumPlayers(index)
	return #team.GetPlayers(index)
end

function team.GetPlayers(index)
	local TeamPlayers = {}

	for id,pl in pairs(player.GetAll()) do
		if pl:Team() == index then
			table.insert(TeamPlayers, pl)
		end
	end

	return TeamPlayers
end

function team.GetScore(index)
	return GetGlobalInt(index.."Sc", 0)
end

function team.GetProps(index)
	return GetGlobalInt(index.."Pro", 0)
end

function team.SetProps(index, props)
	SetGlobalInt(index.."Pro", props)
end

function team.AddProps(index, props)
	team.SetProps(index, team.GetProps(index) + props)
end

function team.GetName(index)
	if not team.TeamInfo[index] then return "" end
	return team.TeamInfo[index].Name
end

function team.GetColor(index)
	if not team.TeamInfo[index] then return team.DefaultColor end
	return team.TeamInfo[index].Color or team.DefaultColor
end

function team.SetScore(index, score)
	SetGlobalInt(index.."Sc", score)
end

function team.AddScore(index, score)
	team.SetScore(index, team.GetScore(index) + score)
end
