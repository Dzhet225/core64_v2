local goospeech = goospeech
local ipairs = ipairs
local string_sub, string_len, hook_Add = string.sub, string.len, hook.Add
local timer_Simple = timer.Simple
local net_Start, net_Send, net_ReadString, net_Receive = net.Start, net.Send, net.ReadString, net.Receive

util.AddNetworkString("goospeech.start")
util.AddNetworkString("goospeech.SyncVars_server")
util.AddNetworkString("goospeech.SyncVars_client")
util.AddNetworkString("goospeech.end")

hook_Add("PlayerSay", "PlayerSay_Google", function(ply, text)
	for _, cmd in ipairs(goospeech.ChatCommand) do
		if string_len(cmd) > 0 and string_sub(text, 0, string_len(cmd)) == cmd then
			if !goospeech:HasValue(ply) then return end
			net_Start("goospeech.start")
			net_Send(ply)
			return false
		end
	end
end)

net_Receive("goospeech.end", function(len, ply)
	goospeech:SetVoice(ply, net_ReadString())
end)

hook_Add("PlayerInitialSpawn", "goospeech.initialSpawn", function(ply)
	if !IsValid(ply) then return end
	
	timer_Simple(3, function()
		net_Start("goospeech.SyncVars_server")
		net_Send(ply)
	end)
end)

net_Receive("goospeech.SyncVars_client", function(len, ply)
	if !IsValid(ply) then return end
	goospeech:SetVoice(ply, net_ReadString())
end)