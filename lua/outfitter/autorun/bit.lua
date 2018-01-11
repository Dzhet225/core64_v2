-- Copyright (C) 2016-2017 Meta Construct ( http://metastruct.net )
-- All rights reserved. Except where Meta Construct has specifically granted written permission to do so.
-- Licensed under https://creativecommons.org/licenses/by-nc-nd/4.0/
AddCSLuaFile()

ubit=ubit or {}

local bit=bit
local ubit=ubit

function gen(name)
	local f=bit[name]
	if not f then error"?!?" end
	local function func(...)
		local ret = f(...)
		return ret>=0 and ret or 0x100000000+ret
	end
	ubit[name] = func
	bit['u'..name] = func
end

gen'rol'
gen'rshift'
gen'ror'
gen'bswap'
gen'bxor'
gen'bor'
gen'arshift'
gen'bnot'
gen'tobit'
gen'lshift'
gen'band'
ubit.tohex=bit.tohex
