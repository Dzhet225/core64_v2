goospeech = goospeech or {}
goospeech.steamids = {
	["STEAM_0:1:29606990"] = true,
	["superadmin"] = true,
}

goospeech.ChatCommand = {
	"/google",
	"!google",
}

function goospeech:HasValue(ply)
	local steamid = ply:SteamID()
	local groups = ply:GetUserGroup()
	return goospeech.steamids[steamid] or goospeech.steamids[groups]
end

function goospeech:SetVoice(ply, voice)
	if !tostring(voice) then return end
	ply:SetNWString("google_voice", voice)
end

function goospeech:GetVoice(ply)
	return ply:GetNWString("google_voice", "oksana")
end