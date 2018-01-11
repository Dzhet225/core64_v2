local goospeech = goospeech
local string_gsub, string_format, string_len, Color = string.gsub, string.format, string.len, Color
local sound_PlayURL, chat_AddText, IsValid, ipairs = sound.PlayURL, chat.AddText, IsValid, ipairs
local ScrW, ScrH, LocalPlayer, hook_Add, string_byte = ScrW, ScrH, LocalPlayer, hook.Add, string.byte
local vgui_Create = vgui.Create
local net_Start, net_WriteString, net_SendToServer = net.Start, net.WriteString, net.SendToServer
local RunConsoleCommand, net_Receive = RunConsoleCommand, net.Receive

local GoogleBool = CreateClientConVar("cl_google_enabled", "1", true)
local GoogleInWorld = CreateClientConVar("cl_google_enabled_3d", "0", true)
local GoogleVoice = CreateClientConVar("cl_google_voice", "oksana", true)

local function httpUrlEncode(text) -- спасибо разрабам wiremod
	local ndata = string_gsub(text, "[^%w _~%.%-]", function(str)
		local nstr = string_format("%X", string_byte(str))
		return "%"..((string_len(nstr) == 1) and "0" or "")..nstr
	end)
	return string_gsub(ndata, " ", "+")
end

local colorRed = Color(0, 255, 0)
hook_Add("OnPlayerChat", "OnPlayerChat_Google", function(ply, text, teamchat, dead)
	if !IsValid(ply) or !GoogleBool:GetBool() then return end
	
	if goospeech:HasValue(ply) then
		local encode = string_format("http://tts.voicetech.yandex.net/tts?speaker=%s&text=%s", goospeech:GetVoice(ply), httpUrlEncode(text))
		local flag = "mono"
		if GoogleInWorld:GetBool() then
			flag = "3D"
		end
		sound_PlayURL(encode, flag, function(station)
			if IsValid(station) then
				if GoogleInWorld:GetBool() then
					station:SetPos(ply:GetPos())
				end
				station:Play()
			else
				chat_AddText(colorRed, "Invalid URL!")
			end
		end)
	end
end)

local voices = voices or {}
voices[1] = { ru_name = "Zahar", en_name = "zahar" }
voices[2] = { ru_name = "Ermil", en_name = "ermil" }
voices[3] = { ru_name = "Oksana", en_name = "oksana" }
voices[4] = { ru_name = "Alyss", en_name = "alyss" }
voices[5] = { ru_name = "Omazh", en_name = "omazh" }
voices[6] = { ru_name = "Jane", en_name = "jane" }

local function GetVoices(ply)
	for _, v in ipairs(voices) do
		if goospeech:GetVoice(ply) == v.en_name then
			return v.ru_name
		end
	end
end


local menu
net_Receive("goospeech.start", function(len)
	if IsValid(menu) then menu:Remove() end
	
	local w, h = ScrW(), ScrH()
	
	menu = vgui_Create("DFrame")
	menu:SetSize(w / 5, h / 5 + 25)
	menu:Center()
	menu:SetDraggable(true)
	menu:ShowCloseButton(true)
	menu:SetTitle("Google speech")
	menu:MakePopup()
	
	local ply = LocalPlayer()
	
	local voice = vgui_Create("DComboBox", menu)
	voice:SetSize(w/7, h/20 - 15)
	voice:SetPos(w/7-115, h/20)
	voice:SetTooltip("Voice speech")
	voice:SetValue("Voice: "..GetVoices(ply))
	for _, add in ipairs(voices) do
		voice:AddChoice(add.ru_name)
	end
	voice.OnSelect = function(idx, val, data)
		for _, add in ipairs(voices) do
			if data == add.ru_name then
				local name = add.en_name
				net_Start("goospeech.end")
				net_WriteString(name)
				net_SendToServer()
				RunConsoleCommand("cl_google_voice", name)
			end
		end
	end
	local sgs = vgui_Create("DForm", menu)
	sgs:SetSize(w/7 + 40, h/20 + 20)
	sgs:SetPos(w/7-135, h/20 + 35)
	sgs:SetName("Settings")
	sgs:CheckBox("Enable google speech?", "cl_google_enabled")
	sgs:CheckBox("Enable 3D google speech?", "cl_google_enabled_3d")
end)

net_Receive("goospeech.SyncVars_server", function(len)
	net_Start("goospeech.SyncVars_client")
	net_WriteString(GoogleVoice:GetString())
	net_SendToServer()
end)