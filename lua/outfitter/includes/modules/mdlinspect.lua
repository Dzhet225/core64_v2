local Tag='mdlinspect'

module(Tag,package.seeall)

local function from_int(s,...)
	local size = 4
	local n = from_u_int(s,...)
	if n >= 2^(size*8-1) then
		return n - 2^(size*8)
	end
	return n
end


-- Format: https:--developer.valvesoftware.com/wiki/MDL#File_format
local vstruct
local needvstruct needvstruct = function()
	vstruct = vstruct or _G.vstruct
	if not vstruct then
		local ok,ret = pcall(require,'vstruct')
		if ok then vstruct=ret or _G.vstruct end
	end
	
	needvstruct=function() return vstruct end
	
	return vstruct
end

MAX_FORMAT = 49
local MDL = {}
local _M = {__index = MDL,__tostring=function(self) return "MDL Parser" end}
function Open(f)
	if isstring(f) then
		f = file.Open(f,'rb','GAME')
	end
	
	if not f then error"invalid file" end
	
	local initial_offset = f:Tell()
	
	local hdr = f:Read(4)
	if hdr~='IDST' then
		return nil,"notmdl"
	end
	
	local version = from_int(f:Read(4),true)
	
	if version>MAX_FORMAT then
		return nil,'newformat',version
	end
	
	local T = {
		file = f,
		version = version,
		initial_offset=initial_offset
	}
	
	return setmetatable(T,_M)
	
end

function MDL:IsValid()
	return self.file and true or false
end

function MDL:GetFile()
	return self.file
end

function MDL:Close()
	local f = self.file
	f:Close()
	self.file = false
end

function MDL:_ParseFail(reason)
	self.parsed_header = false
	self.parse_error = reason or "?"
	self.error = "Parsing failed: "..tostring(reason)
	return nil,reason
end

function MDL:GetError()
	return self.error
end

function MDL:HasFlag(f)
	local bit=ubit or bit
	return bit.band(self.flags,f)==f
end



local flaglist={
[0]="AUTOGENERATED_HITBOX",
"USES_ENV_CUBEMAP",
"FORCE_OPAQUE",
"TRANSLUCENT_TWOPASS",
"STATIC_PROP",
"USES_FB_TEXTURE",
"HASSHADOWLOD",
"USES_BUMPMAPPING",
"USE_SHADOWLOD_MATERIALS",
"OBSOLETE",
"UNUSED",
"NO_FORCED_FADE",
"FORCE_PHONEME_CROSSFADE",
"CONSTANT_DIRECTIONAL_LIGHT_DOT",
"FLEXES_CONVERTED",
"BUILT_IN_PREVIEW_MODE",
"AMBIENT_BOOST",
"DO_NOT_CAST_SHADOWS",
"CAST_TEXTURE_SHADOWS",
}

function MDL:ListFlags()
	local t = {}
	for i=0,#flaglist do
		if self:HasFlag(2^i) then
			t[flaglist[i]] = true
		end
	end
	return t
end

function MDL:Validate(filesize)
	local size = self.dataLength
	
	local f=self.file
	--TODO: can be wrong
	local fsize = filesize or (f:Size()-self.initial_offset)
	

	if fsize ~=size then
		return nil,"size"
	end
	
	--local checksum = from_int(self.checksum,true)
	--local crc = util.CRC(dat)
	--dat = nil
	--
	--if tostring(checksum)~=tostring(crc) then
	--	return nil,"checksum","("..tostring(crc)..','..tostring(checksum)..")"
	--end
	
	return true
end

function MDL:ParseHeader()
	if self.parsed_header~=nil then
		return self.parsed_header
	end
	self.parsed_header = false
	
	local f = self.file
	local res = self
	
	res.checksum = f:Read(4)
	
	local name = f:Read(64)
	name = name:match'^[^%z]*' or ""
	res.name = name
	
	local dataLength = from_int(f:Read(4),true)
	res.dataLength = dataLength
	
	-- TODO: skip Vectors, read elsewhere
	f:Seek( f:Tell()+4 * 3 *6 )
	
	res.flags=from_int(f:Read(4),true)
	
	-- mstudiobone_t
	res.bone_count = from_int(f:Read(4),true)	-- Number of data sections (of type mstudiobone_t)
	res.bone_offset = from_int(f:Read(4),true)	-- Offset of first data section
 
	-- mstudiobonecontroller_t
	res.bonecontroller_count = from_int(f:Read(4),true)
	res.bonecontroller_offset = from_int(f:Read(4),true)
 
	-- mstudiohitboxset_t
	res.hitbox_count = from_int(f:Read(4),true)
	res.hitbox_offset = from_int(f:Read(4),true)
 
	-- mstudioanimdesc_t
	res.localanim_count = from_int(f:Read(4),true)
	res.localanim_offset = from_int(f:Read(4),true)
 
	-- mstudioseqdesc_t
	res.localseq_count = from_int(f:Read(4),true)
	res.localseq_offset = from_int(f:Read(4),true)
 
	res.activitylistversion = from_int(f:Read(4),true) -- ??
	res.eventsindexed = from_int(f:Read(4),true)	-- ??
 
	-- VMT texture filenames
	-- mstudiotexture_t
	res.texture_count = from_int(f:Read(4),true)
	res.texture_offset = from_int(f:Read(4),true)
 
	-- This offset points to a series of ints.
		-- Each int value, in turn, is an offset relative to the start of this header/the-file,
		-- At which there is a null-terminated string.
	res.texturedir_count = from_int(f:Read(4),true)
	res.texturedir_offset = from_int(f:Read(4),true)
 
	-- Each skin-family assigns a texture-id to a skin location
	res.skinreference_count = from_int(f:Read(4),true)
	res.skinrfamily_count = from_int(f:Read(4),true)
	res.skinreference_index = from_int(f:Read(4),true)
 
	-- mstudiobodyparts_t
	res.bodypart_count = from_int(f:Read(4),true)
	res.bodypart_offset = from_int(f:Read(4),true)
 
	-- Local attachment points
	-- mstudioattachment_t
	res.attachment_count = from_int(f:Read(4),true)
	res.attachment_offset = from_int(f:Read(4),true)
 
	-- Node values appear to be single bytes, while their names are null-terminated strings.
	res.localnode_count = from_int(f:Read(4),true)
	res.localnode_index = from_int(f:Read(4),true)
	res.localnode_name_index = from_int(f:Read(4),true)
 
	-- mstudioflexdesc_t
	res.flexdesc_count = from_int(f:Read(4),true)
	res.flexdesc_index = from_int(f:Read(4),true)
 
	-- mstudioflexcontroller_t
	res.flexcontroller_count = from_int(f:Read(4),true)
	res.flexcontroller_index = from_int(f:Read(4),true)
 
	-- mstudioflexrule_t
	res.flexrules_count = from_int(f:Read(4),true)
	res.flexrules_index = from_int(f:Read(4),true)
 
	-- IK probably referse to inverse kinematics
	-- mstudioikchain_t
	res.ikchain_count = from_int(f:Read(4),true)
	res.ikchain_index = from_int(f:Read(4),true)
 
	-- Information about any "mouth" on the model for speech animation
	-- More than one sounds pretty creepy.
	-- mstudiomouth_t
	res.mouths_count = from_int(f:Read(4),true)
	res.mouths_index = from_int(f:Read(4),true)
 
	-- mstudioposeparamdesc_t
	res.localposeparam_count = from_int(f:Read(4),true)
	res.localposeparam_index = from_int(f:Read(4),true)
 
	--[[
	 * For anyone trying to follow along, as of this writing,
	 * the next "surfaceprop_index" value is at position 0x0134 (308)
	 * from the start of the file.
	 --]]
 
	-- Surface property value (single null-terminated string)
	res.surfaceprop_index = from_int(f:Read(4),true)
 
	-- Unusual: In this one index comes first, then count.
	-- Key-value data is a series of strings. If you can't find
	-- what you're interested in, check the associated PHY file as well.
	res.keyvalue_index = from_int(f:Read(4),true)
	res.keyvalue_count = from_int(f:Read(4),true)
 
	-- More inverse-kinematics
	-- mstudioiklock_t
	res.iklock_count = from_int(f:Read(4),true)
	res.iklock_index = from_int(f:Read(4),true)
 
 
	res.mass = f:ReadFloat() -- Mass of object (4-bytes)
	res.contents = from_int(f:Read(4),true)	-- ??
 
	-- Other models can be referenced for re-used sequences and animations
	-- (See also: The $includemodel QC option.)
	-- mstudiomodelgroup_t
	res.includemodel_count = from_int(f:Read(4),true)
	res.includemodel_index = from_int(f:Read(4),true)
 
	res.virtualModel = from_int(f:Read(4),true)	-- Placeholder for mutable-void*
 
	-- mstudioanimblock_t
	res.animblocks_name_index = from_int(f:Read(4),true)
	res.animblocks_count = from_int(f:Read(4),true)
	res.animblocks_index = from_int(f:Read(4),true)
 
	res.animblockModel = from_int(f:Read(4),true) -- Placeholder for mutable-void*
 
	-- Points to a series of bytes?
	res.bonetablename_index = from_int(f:Read(4),true)
 
	res.vertex_base = from_int(f:Read(4),true)	-- Placeholder for void*
	res.offset_base = from_int(f:Read(4),true)	-- Placeholder for void*
 
	-- Used with $constantdirectionallight from the QC
	-- Model should have flag #13 set if enabled
	res.directionaldotproduct = f:Read(1)
 
	res.rootLod = f:Read(1)	-- Preferred rather than clamped
 
	-- 0 means any allowed, N means Lod 0 -> (N-1)
	res.numAllowedRootLods = f:Read(1);
 
	f:Read(1)--		unused; -- ??
	res.unused = from_int(f:Read(4),true) -- ??
 
	-- mstudioflexcontrollerui_t
	res.flexcontrollerui_count = from_int(f:Read(4),true)
	res.flexcontrollerui_index = from_int(f:Read(4),true)
 
	--[[*
	 * Offset for additional header information.
	 * May be zero if not present, or also 408 if it immediately
	 * follows this studiohdr_t
	 --]]
	-- studiohdr2_t
	res.studiohdr2index = from_int(f:Read(4),true)
	
	return true
	
end

local offsetreaderinfo_1 = {}
local offsetreaderinfo_2 = {}
function MDL:IncludedModels()
	local f = self.file
	local t = self.included_models
	if t then return t end
	
	local ok = self:SeekTo(self.includemodel_index)
	assert(ok)
	
	t = {}
	
	for i=1,self.includemodel_count do
	
		local pos = self:Tell()
		
		local labelOffset = from_int(f:Read(4),true)
		local fileNameOffset = from_int(f:Read(4),true)
		offsetreaderinfo_1[i]=labelOffset 		+ pos
		offsetreaderinfo_2[i]=fileNameOffset	+ pos
	end
	for i=1,self.includemodel_count do
		
		
		local labelOffset = offsetreaderinfo_1[i]
		local fileNameOffset = offsetreaderinfo_2[i]
		
		--print(i,labelOffset,fileNameOffset)
		
		assert(self:SeekTo(labelOffset))
		local label = f:ReadString()

		assert(self:SeekTo(fileNameOffset))
		
		local fileName = f:ReadString()

		t[i] = {label,fileName}
		
	end
	
	self.included_models = t
	
	return t
end


local mstudioattachment_t_size =
	4 			-- int					sznameindex;
	+4 			-- unsigned int			flags;
	+4			-- int					localbone;
	+(3*4)*4	-- matrix3x4_t			local; // attachment point
	+4*8    	-- int					unused[8];

function MDL:offsetAttachment( i )
	assert(i>=0 and i<=self.attachment_count)
	return self.attachment_offset + mstudioattachment_t_size * i
end


function MDL:SurfaceName()
	local f = self.file
	local name = self.surfaceprop_name
	if name then return name end
	
	assert(self:SeekTo(self.surfaceprop_index))
	name = f:ReadString()
	assert(name)
	self.surfaceprop_name = name
	return name
end
	
function MDL:Attachments()
	local f = self.file
	local t = self.attachment_nameslist
	if t then return t end
	
	t = {}
	
	for i=0,self.attachment_count-1 do -- mstudioattachment_t --
		
			local thispos = self:offsetAttachment(i)
			assert(self:SeekTo(thispos))
			
			local sznameindex = from_int(f:Read(4),true)
			
			local flags = from_u_int(f:Read(4),true)
			
			assert(self:SeekTo(thispos + sznameindex))
			local name = f:ReadString()
			
			t[#t+1] = {name,flags}
			
	end

	self.attachment_nameslist = t
	
	return t
end

local mstudiobodyparts_t_size =
	4 -- int	sznameindex;
	+ 4 -- int	nummodels;
	+ 4 -- int	base;
	+ 4 -- int	modelindex; 
	
function MDL:offsetBodyPart( i )
	assert(i>=0 and i<=self.bodypart_count)
	return self.bodypart_offset + mstudiobodyparts_t_size * i
end

function MDL:BodyParts()
	local f = self.file
	local t = self.bodyparts
	if t then return t end
	
	t = {}
	
	self:ParseHeader()
	for i=0,self.bodypart_count-1 do -- mstudiobodyparts_t --
		
			local thispos = self:offsetBodyPart(i)
			assert(self:SeekTo(thispos))
			
			local sznameindex = from_int(f:Read(4),true)
			
			local nummodels = from_u_int(f:Read(4),true)
			local base = from_u_int(f:Read(4),true)
			
			assert(self:SeekTo(thispos + sznameindex))
			local name = f:ReadString()
			
			t[#t+1] = {name=name,base=base,nummodels=nummodels}
			
	end

	self.bodyparts = t
	
	return t
end

local bone_section_size =
	  4 -- int
	+ 4  -- int parent
	+ 4*6 --int					bonecontroller[6];	// bone controller index, -1 == none

	+ 4*3 --Vector				pos;
	+ 4*4 --Quaternion			quat;
	+ 4*3 --RadianEuler			rot;

	+ 4*3 --Vector				posscale;
	+ 4*3 --Vector				rotscale;
	+ 48 --matrix3x4_t			poseToBone;

	+ 4*4 --Quaternion			qAlignment;
	+ 4 --int					flags;
	+ 4 --int					proctype;
	+ 4 --int					procindex;		// procedural rule
	+ 4 --mutable int			physicsbone;	// index into physically simulated bone
	+ 4 --int					surfacepropidx;	// index into string tablefor property name
	+ 4 --int					contents;		// See BSPFlags.h for the contents flags
	+ 4 --int 					surfacepropLookup
	+ 4*7 --int					unused[7];		// remove as appropriate
	
function MDL:offsetBone( i )
	assert(i>=0 and i<=self.bone_count)
	return self.bone_offset + bone_section_size * i
end


function MDL:BoneNames()
	local f = self.file
	local t = self.bone_nameslist
	if t then return t end
	
	t = {}
	
	for i=0,self.bone_count-1 do -- mstudiobone_t --
	
		local thispos = self:offsetBone(i)
		assert(self:SeekTo(thispos))
		
		local nameoffset = from_int(f:Read(4),true)
		
		assert(self:SeekTo(thispos + nameoffset))
		local name = f:ReadString()
		
		t[#t+1] = name
		
		
	end

	self.bone_nameslist = t
	
	return t
end


function MDL:SeekTo(offset)
	
	local f = self.file
	local off = self.initial_offset + offset
	
	if off>f:Size() then
		--print("offset too big",off-f:Size())
		return false
	end
	
	f:Seek(off)
	return f:Tell()==off
	
end

function MDL:Tell()
	return self.file:Tell()-self.initial_offset
end

function BuildBodyGroupInfo(pbodypart,iValue,body)
	body = body or 0
	
	local iCurrent = (body / pbodypart.base) % pbodypart.nummodels
	
	body = (body - (iCurrent * pbodypart.base) + (iValue * pbodypart.base))
	
	return body
	
end


--[[ -- BodyPart test
local fp ="models/"
local flist = file.Find(fp..'*.mdl','GAME')
 flist = {'props_borealis/bluebarrel001.mdl','player/soldier.mdl','player/dukeplayermodel/dukeplayermodel.mdl'}

for _,fn in next,flist do
print("\n\n==== "..fn.." ====")
--local fn = 'matress.mdl'
local fpath = fp..fn
local f = file.Open(fpath,'rb','GAME')

local mdl,err = Open(f)
if not mdl then print("Parser init fail",err) return end

local ok ,err = mdl:ParseHeader()
if not ok then print("header parse failed",err) return end


print("SURFNAME",mdl:SurfaceName())

print("VERSION",mdl.version,"","","VALIDATE:",mdl:Validate(),mdl.initial_offset)
print("NAME",("%q"):format(mdl.name))
print("BodyPartCount",mdl.bodypart_count)

for k,data in next,mdl:BodyParts() do
	print("",data.name)
	print("",data.nummodels)
end

end

--]]

--[[ -- test
local fp ="models/player/"
local flist = file.Find(fp..'*.mdl','GAME')
-- flist = {'matress.mdl'}

for _,fn in next,flist do
print("\n\n==== "..fn.." ====")
--local fn = 'matress.mdl'

local fpath = fp..fn
local f = file.Open(fpath,'rb','GAME')

local mdl,err = Open(f)
if not mdl then print("Parser init fail",err) return end

local ok ,err = mdl:ParseHeader()
if not ok then print("header parse failed",err) return end

print("VERSION",mdl.version,"","","VALIDATE:",mdl:Validate(),mdl.initial_offset)
print("NAME",("%q"):format(mdl.name))
--print("bonec",mdl.bonecontroller_count,mdl.bonecontroller_offset)
--print("incmd",mdl.includemodel_count,mdl.includemodel_index)
--print("",mdl.includemodel_count)
--print("",mdl.includemodel_index)
if mdl.skinrfamily_count>1 then print("SKINCOUNT",mdl.skinrfamily_count) end

if mdl.flags~=0 then PrintTable("flags",mdl:ListFlags()) end

for k,v in next,mdl:IncludedModels() do
--	print("",('%q'):format(v[2]),file.Exists(v[2],'GAME'))
end

print("bones",mdl.bone_count,mdl.bone_offset,mdl:BoneNames() [1],mdl:BoneNames() [2])

end

--]]

return _M