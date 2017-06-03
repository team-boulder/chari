--[[
@
@ Project  : 
@
@ Filename : display-v2.lua
@
@ Author   : Task Nagashige
@
@ Date     : 
@
@ Comment  : 
@
@ Package  : display関数の拡張
@
]]--

-- 継承元
require( ModDir .. 'display.display' )

local cjson  = cjson
local assert = assert
local s_byte = string.byte
local s_sub  = string.sub
local s_find = string.find

-- mapping utf-8 leading-byte to byte offset
local byte_offsets = {
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1,
1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3,
3, 3, 3, 3, 3, 3, 3}

local function split_into_utf8_bytes(str)
	local codes = {}
	local i
	local offset = 0

	local mb_str, byte, offset_pos

	for i = 1, #str do
		offset_pos = i + offset
		if offset_pos > #str then
			break
		end

		byte = byte_offsets[s_byte(str, offset_pos, offset_pos)] or 0

		mb_str = s_sub(str, offset_pos, offset_pos + byte)

		codes[#codes + 1] = mb_str
		offset = offset + byte
	end
	return codes
end

--[[

スプライトシートからスプライトを切り出し、1枚の画像として表示させる

@param   integer options['width']          : スプライトの幅(required)
@param   integer options['height']         : スプライトの高さ(required)
@param   integer options['filePath']       : スプライトシートのファイルパス(required)
@param   integer options['contentWidth']   : スプライトシートの最大の幅(optional)
@param   integer options['contentHeight']  : スプライトシートの最大の高さ(optional)
@param   string  options['directory']      : スプライトシートのあるディレクトリ(optional)
@param   object  options['group']          : 画像オブジェクトが入るグループ(optional)
@return  object  imageObject               : スプライトシートから生成した画像オブジェクト

Sample Code

local options =
{
	-- 必須
    width = 70,
    height = 41,
    filePath = 'spriteSheet.png',
    frameIndex = 1,

    -- 任意（スプライトシートが2048✕2048の場合）
    contentWidth = 70,
    contentHeight = 82,
    -- group = privateGroup,
}

local face = display.newAvatar( options )

]]--
function display.newAvatar( options )
	assert( options, 'Error: options not found!' )
	assert( type( options ) == 'table', 'Error: options not table!' )
	assert( options['filePath'], 'Error: options[\'filePath\'] not found!' )

	local contentWidth = options['contentWidth'] or 2048
	local contentHeight = options['contentHeight'] or 2048

	local imageOptions =
	{
	    width = contentWidth,
	    height = contentHeight,
	    numFrames = 1,
	    sheetContentWidth = contentWidth,
	    sheetContentHeight = contentHeight,
	}

	local directory = nil
	if options['directory'] then
		directory = options['directory']
	elseif tonumber(options['filePath']) ~= 0 then
		directory = system.DocumentsDirectory
		options['filePath'] = 'avatar/' .. options['filePath']
	end

	local imageSheet
	if directory then
		imageSheet= graphics.newImageSheet( options['filePath'], directory, imageOptions )
	end

	local imageObject
	if imageSheet then
		imageObject = display.newImage( imageSheet, 1, true )
	end

	if imageObject and options['scale'] then
		imageObject:scale( options['scale'], options['scale'] )
	end

	if imageObject and options['x'] then
		imageObject:setReferencePoint( display.TopLeftReferencePoint )
		imageObject.x = options['x']
	end

	if imageObject and options['y'] then
		imageObject:setReferencePoint( display.TopLeftReferencePoint )
		imageObject.y = options['y']
	end

	if imageObject and options['group'] and options['group'].parent then
		options['group']:insert( imageObject )
	end

	return imageObject
end

-- 文字の長さを取って1文字ずつ文章として表示する。文字にポイントをつける機能も追加
function display.newSentence( ... )	
	local options = ...

	assert( options.text, 'Error: options.text not found!' )

	local self = display.newGroup()

	-- cached params
	local _parentGroup   = options.group
	local _text          = options.text
	local _x             = options.x
	local _y             = options.y
	local _width         = options.width or _W-100
	local _height        = options.height
	local _font          = options.font or nil
	local _fontSize      = options.fontSize or 24
	local _marker        = options.marker or {}
	local _marker_color  = options.marker_color or { 255, 0, 0 }
	local _time          = options.time or 50
	local _contentWidth  = options.contentWidth
	local _contentHeight = options.contentHeight
	local _listener      = options.listener or function() end
	local _audioPath     = options.audioPath or nil

	if _parentGroup then
		_parentGroup:insert( self )
	end

	self.x = _x
	self.y = _y

	local str_table = split_into_utf8_bytes( _text )

	local pos = 1

	local text_table    = {}
	local text_listener = {}
	local audio_player  = {}
	local audio_channel = {}

	local cached_width  = 0
	local cached_height = 0

	for key = 1, #str_table do
		local value = str_table[key]

		if text_table[key-1] then
			cached_width = text_table[key-1].x + text_table[key-1].width*0.5
			if cached_width > _width then
				cached_width  = 0
				cached_height = text_table[key-1].y + text_table[key-1].height*0.5 + 5
			end

			if value == '\n' then
				cached_width  = 0
				cached_height = text_table[key-1].y + text_table[key-1].height*0.25 + 5
				if system.getInfo( 'platformName' ) == 'Android' then
					print( 'Android space' )
					cached_height = text_table[key-1].y + text_table[key-1].height*0.1 + 5
				end
			end
		end

		text_table[key] = display.newText( self, value, cached_width, cached_height, _font, _fontSize )
		text_table[key].alpha = 0

		-- TODO : なんとかして音声のloadを消す仕組みを作らないとアプリがすごく重くなる
		if _audioPath then
			audio_player[key] = audio.loadSound( _audioPath )
		end

		text_listener[key] = function()
			self.play( key )
			transition.to( text_table[key], { time = _time, alpha = 1, onComplete = text_listener[key+1] } )
		end
	end

	text_listener[#str_table+1] = function()
		_listener()
	end

	function self.play( num )
		if audio_player[num] then
			audio_channel[num] = audio.play( audio_player[num] )
		end
	end

	function self.stop( num )
		if audio_channel[num] then
			audio.stop( audio_channel[num] )
		end
	end

	function self.show()
		for key = 1, #text_table do
			local value = text_table[key]
			value.alpha = 1
			transition.cancel( value )
			self.stop( key )
		end
		text_listener[#text_table+1]()
	end
	text_listener[1]()

	function self:setFillColor( ... )
		for key = 1, #text_table do
			local value = text_table[key]
			if not value.is_colored then
				value:setFillColor( ... )
			end
		end
	end


	local function checkWordsColor( key, marker )
		local marker_table = split_into_utf8_bytes( marker )

		if #marker_table == 1 then
			if str_table[key] == marker then
				text_table[key].is_colored = true
				text_table[key]:setFillColor( _marker_color[1], _marker_color[2], _marker_color[3] )
			end
		else
			local check_str = ''
			for i = 1, #marker_table do
				if #str_table >= key+1-i and key+1-i > 0 then
					check_str = str_table[key+1-i] .. check_str
				end
			end
			if check_str ~= '' and check_str == marker then
				for j = key, key-#marker_table+1, -1 do
					text_table[j].is_colored = true
					text_table[j]:setFillColor( _marker_color[1], _marker_color[2], _marker_color[3] )
				end
			end
		end
	end


	function self:marker()
		for key = 1, #str_table do
			if #_marker == 1 then
				checkWordsColor( key, _marker[1] )
			elseif #_marker > 1 then
				for k = 1, #_marker do
					checkWordsColor( key, _marker[k] )
				end
			end 
		end
	end

	self:setReferencePoint( display.TopLeftReferencePoint )

	return self
end

-- 文字にポイントをつける
function display.newMarkerText( ... )
	local options = ...

	assert( options.text, 'Error: options.text not found!' )

	local self = display.newGroup()

	-- cached params
	local _parent_group  = options.group
	local _text          = options.text
	local _x             = options.x
	local _y             = options.y
	local _width         = options.width or _W-100
	local _height        = options.height
	local _font          = options.font or nil
	local _fontSize      = options.fontSize or 24
	local _marker        = options.marker or {}
	local _marker_color  = options.marker_color or { 255, 0, 0 }
	local _contentWidth  = options.contentWidth
	local _contentHeight = options.contentHeight
	local _listener      = options.listener or function() end
	local _audioPath     = options.audioPath or nil
	local _align         = options.align or nil

	if _parent_group then
		_parent_group:insert( self )
	end

	self.x = _x
	self.y = _y

	local str_table = split_into_utf8_bytes( _text )

	local pos = 1

	local text_table    = {}
	local text_listener = {}
	local audio_player  = {}
	local audio_channel = {}

	local cached_width  = 0
	local cached_height = 0

	for key = 1, #str_table do
		local value = str_table[key]

		if text_table[key-1] then
			cached_width = text_table[key-1].x + text_table[key-1].width*0.5
			if cached_width > _width then
				cached_width  = 0
				cached_height = text_table[key-1].y + text_table[key-1].height*0.5 + 5
			end

			if value == '\n' then
				cached_width  = 0
				cached_height = text_table[key-1].y + text_table[key-1].height*0.25 + 5
				if system.getInfo( 'platformName' ) == 'Android' then
					print( 'Android space' )
					cached_height = text_table[key-1].y + text_table[key-1].height*0.25 + 5
				end
			end
		end
		text_table[key] = display.newText( self, value, cached_width, cached_height, _font, _fontSize )
	end

	function self:setFillColor( ... )
		for key = 1, #text_table do
			local value = text_table[key]
			if not value.is_colored then
				value:setFillColor( ... )
			end
		end
	end


	local function checkWordsColor( key, marker )
		local marker_table = split_into_utf8_bytes( marker )

		if #marker_table == 1 then
			if str_table[key] == marker then
				text_table[key].is_colored = true
				text_table[key]:setFillColor( _marker_color[1], _marker_color[2], _marker_color[3] )
			end
		else
			local check_str = ''
			for i = 1, #marker_table do
				if #str_table >= key+1-i and key+1-i > 0 then
					check_str = str_table[key+1-i] .. check_str
				end
			end
			if check_str ~= '' and check_str == marker then
				for j = key, key-#marker_table+1, -1 do
					text_table[j].is_colored = true
					text_table[j]:setFillColor( _marker_color[1], _marker_color[2], _marker_color[3] )
				end
			end
		end
	end


	function self:marker()
		for key = 1, #str_table do
			if #_marker == 1 then
				checkWordsColor( key, _marker[1] )
			elseif #_marker > 1 then
				for k = 1, #_marker do
					checkWordsColor( key, _marker[k] )
				end
			end 
		end
	end

	self:setReferencePoint( display.TopLeftReferencePoint )

	return self
end

function display.checkObj( obj )
	local obj = obj
	if obj == nil then
		return false
	end

	if obj.parent == nil then
		return false
	end
	return true
end