
--[[
@
@ Project  : Cosmo
@
@ Filename : MIDI-v2.lua
@
@ Author   : Tomohiro Matsuo
@
@ Date     :
@
@ Comment  :
@
@ Package  : MIDIの拡張
@
]]--

-- 継承元
local MIDI = require( ModDir .. 'MIDI.MIDI' )

local this = object.new()

local checkDownload = checkDownload2

function this.getBaseBPMFromOpus(myOpus)
	local baseBPM = 120
	--search every event in every track for set_tempo in the song.[ch][1] position, then take song.[ch][3]
	for trackParser = 2,  #myOpus do
		for eventParser = 1 , #myOpus[trackParser] do
			if myOpus[trackParser][eventParser][1] == "set_tempo" then
				local rawBPM  = myOpus[trackParser][eventParser][3]
				baseBPM =  ( 6000000 / (rawBPM * .1) )
				do return baseBPM end
			end
		end
	end
	return baseBPM
end

function this.readMidiFile(path, dir)
	local contents
	local dir = dir or system.ResourceDirectory
	local path = system.pathForFile( path , dir )  --excellent
	local fh, reason = io.open( path, "r" )
	if fh then
		contents = fh:read( "*a" )
	else
		print( "Reason open failed: " .. reason )  -- display failure message in terminal
		return nil
	end
	io.close( fh )
	local opusFormattedMIDI = MIDI.midi2opus(contents)
	local baseBPM = this.getBaseBPMFromOpus(opusFormattedMIDI)
	print(baseBPM)
	opusFormattedMIDI = nil

	local scoreFormattedMIDI = MIDI.midi2ms_score(contents)
	scoreFormattedMIDI[1] = baseBPM
	return scoreFormattedMIDI
end

-- read MIDI from url
function this.readMidiFromUrl( ... )
	local arg = { ... }

	local path     = arg[1]
	local dir      = arg[2]
	local sub_dir  = arg[3] or ''
	local listener = arg[4] or function() end

	if dir == nil then
		dir = system.ResourceDirectory
	end

	if system.getInfo( 'platformName' ) == 'iPhone OS' and dir == system.DocumentsDirectory then
		dir = system.CachesDirectory
	end

	if sub_dir and sub_dir ~= '' then
		sub_dir = sub_dir .. '/'

		local is_exsit = existsDirectory( sub_dir )
		if not is_exsit then
			createDirectory( sub_dir, dir )
		end	
	end

	-- サーバからのMIDI取得
	if startsWith( path, 'http://' ) then 
		if dir == nil then
			dir = system.TemporaryDirectory
		end
		local open_path = system.pathForFile( sub_dir ..  basename( path ), dir )
		local file = io.open( open_path, 'r' )
		if not file then
			local function cdHandler()
				local tmp_path = system.pathForFile( sub_dir ..  basename( path ), dir )
				local len = io.file_size( tmp_path )
				if len < 100 then
					deleteDocument( sub_dir .. basename( path ) )
					return this.readMidiFromUrl( arg[1], arg[2], arg[3], arg[4] )
				end
				local load_midi = this.readMidiFile( sub_dir ..  basename( path ), dir )
				timer.performWithDelay( 1, listener )
				return load_midi
			end
			checkDownload( path, cdHandler, sub_dir, dir )
		else
			io.close( file )
			local load_midi = this.readMidiFile( sub_dir ..  basename( path ), dir )
			timer.performWithDelay( 1, listener )
			return load_midi
		end
	else
		if startsWith( path, 'local://' ) then 
			-- 生成
			path = string.gsub( path, 'local://', '' )
		end
		local load_midi = this.readMidiFile( sub_dir ..  path , dir )
		timer.performWithDelay( 1, listener )
		return load_midi
	end
end

return this
