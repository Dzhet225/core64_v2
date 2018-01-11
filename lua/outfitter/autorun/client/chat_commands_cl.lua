
local LocalPlayer=LocalPlayer
local cmds={["!"]=true,["\\"]=true,["/"]=true,["."]=true}
local disable_legacy
local function Parse(pl,msg)
	if not cmds[msg:sub(1,1)] then return end
	local pos=string.find(msg," ",1,true)

	local com,paramstr
	if pos then
		com,paramstr=msg:sub(2,pos-1),msg:sub(pos+1,-1)
	else
		com=msg:sub(2,-1)
		paramstr=""
	end

	local ret = hook.Run("ChatCommand",com,paramstr,msg)
	if ret==true then return ret end
end
hook.Add("OnPlayerChat","ChatCommand",function(pl,msg)
	if pl~=LocalPlayer() then return end
	return Parse(pl,msg)
end)

hook.Add("PlayerSay","ChatCommand",function(pl,msg)
	if pl~=LocalPlayer() then return end
	if not disable_legacy then
		hook.Remove("OnPlayerChat","ChatCommand")
		disable_legacy =  true
	end

	return Parse(pl,msg)
end)
