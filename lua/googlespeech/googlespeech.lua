Core64.GitRunSH("lua/googlespeech/autorun/sh_google.lua")
if SERVER then
Core64.GitRunSH("lua/googlespeech/autorun/server/sv_google.lua")
else
Core64.GitRunSH("lua/googlespeech/autorun/client/cl_google.lua")
end