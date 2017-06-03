--[[
@
@ Project  :
@
@ Filename : playerInfo.lua
@
@ Author   : Task Nagashige
@
@ Date     : 2015-06-24
@
@ Comment  :
@
]]--ß

local this = object.new()
playerInfoData = {}

local tonumber = tonumber

-- サーバからのデータを保存
function this.setDataFromServer( data )
	assert( data, 'Fatal error : not found data' )
	assert( type( data ) == 'table', 'Fatal error : invalid data' )

	for key, value in pairs ( playerInfoData ) do
		for k, v in pairs ( data ) do
			if k == key and v then
				-- TODO : サーバの時間がずれてるのでとりあえず手動で修正
				if k == 'stamina_time' and __isDebug then
					v = v + 150
				end
				this.set( k, v )
			end
		end
	end
end

function this.set( key, value )
	assert( key, 'Fatal error : not found key' )
	assert( value, 'Fatal error : not found value' )

	local res = tonumber( value )
	if res and res ~= '' and type( res ) == 'number' then
		value = res
	end

	playerInfoData[key] = value

	this.reload()
end

function this.setAll( data )
	assert( data, 'Fatal error : not found data' )

	playerInfoData['name']          	= data['name'] or 'PLAYER' .. string.format( '%05d', math.random( 10000 ) )
	playerInfoData['hoge']    			= tonumber( data['hoge'] ) or 10
	playerInfoData['buy_items']     	= data['buy_items'] or {1,1,1,1}
	playerInfoData['block']         	= tonumber( data['block'] ) or 0
	playerInfoData['thinthin_size']     = tonumber( data['thinthin_size'] ) or 0
	playerInfoData['theme_color']       = data['theme_color'] or {120,230,240}
	playerInfoData['size']          	= tonumber( data['size'] ) or 0.2
	playerInfoData['tutorial']          = tonumber( data['tutorial'] ) or 1
    playerInfoData['age']				= tonumber( data['age'] ) or 1
	playerInfoData['test'] = tonumber(data['test']) or 0

	this.reload()
end

function this.reload()
	this.save()
	Runtime:dispatchEvent( { name = 'playerInfo-reload', data = playerInfoData } )
end

function this.save()
	if playerInfoData then
		local res = json.encode( playerInfoData )
		if res and res ~= '[]' then
			writeText( 'playerInfo.txt', res )
			this:dispatchEvent( { name = 'playerInfo-save', data = playerInfoData } )
			return 0
		else
			this.setAll( {} )
		end
	else
		return -1
	end
end

function this.load()
	local res = readText( 'playerInfo.txt' )
	if res then
		local decode_res = json.decode( res )
		if decode_res then
			this.setAll( decode_res )
			return 0
		end
		return -1
	else
		return -1
	end
end

function this.init()
	print('loading player info')
	local res = this.load()
	if res == -1 then
		this.save()
	end
end

function this.reset()
	playerInfoData = nil
	playerInfoData = {}
	deleteDocument( 'playerInfo.txt' )
end

return this
