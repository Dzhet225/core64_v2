Core64.GitRunSH("lua/googlespeech/sh_google.lua")
if SERVER then
Core64.GitRunSH("lua/googlespeech/server/sv_google.lua")
else
Core64.GitRunSH("lua/googlespeech/client/cl_google.lua")
end