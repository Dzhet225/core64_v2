



do
	return 
end

local fp = "models/"
local flist = file.Find(fp .. '*.mdl', 'GAME')
flist = { 'props_borealis/bluebarrel001.mdl', 'player/soldier.mdl' }
for _, fn in next, flist do
	print("\n\n==== " .. fn .. " ====")
	local fpath = fp .. fn
	local f = file.Open(fpath, 'rb', 'GAME')
	local mdl, err = mdlinspect.Open(f)
	if not mdl then
		print("Parser init fail", err)
		return 
	end

	local ok, err = mdl:ParseHeader()
	if not ok then
		print("header parse failed", err)
		return 
	end

	print("SURFNAME", mdl:SurfaceName())
	print("VERSION", mdl.version, "", "", "VALIDATE:", mdl:Validate(), mdl.initial_offset)
	print("NAME", ("%q"):format(mdl.name))
	print("BodyPartCount", mdl.bodypart_count)
	for k, data in next, mdl:BodyParts() do
		print("", data.name)
		print("", data.nummodels)
	end

end


