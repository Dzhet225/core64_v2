Core64.GitRunSH("lua/googlespeech/sh_google.lua")
if SERVER then
Core64.GitRunSH("lua/googlespeech/server/cl_google.lua")
else
Core64.GitRunSH("lua/googlespeech/client/sv_google.lua")
end