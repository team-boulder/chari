--[[
@
@ Project  : SubwayNinjaJump
@
@ Filename : sound.lua
@
@ Author   : Task Nagashige
@
@ Date     : 2015-06-23
@
@ Comment  :
@
]]--

local self = {}

-- シュミレーターで音を消す設定
local is_debug = true

self.op_tap   = audio.loadSound( AudioDir .. 'op_tap.mp3' )
self.push       = audio.loadSound( AudioDir .. 'push.mp3' )
--うるさいからけしとく
--self.home       = audio.loadSound( AudioDir .. 'home.mp3' )

--BGM再生開始時の遅延測定
function self.checkDelay()
  local current_time = system.getTimer()
  local function audioHandler(event)
    print(system.getTimer()-current_time)
    playerInfoData['bgm_delay'] = system.getTimer()-current_time-3000
    playerInfo.save()
    print(playerInfoData['bgm_delay'])
  end
  audio.play(self.test,{channel=2,onComplete=audioHandler})
  al.Source(self.test, al.PITCH, 2.0)
  --audio.seek(audio.getDuration(self.stage[1])-3000,{channel=2})
end
--self.checkDelay()

self.story   = {}
self.loopPlayer      = nil
self.randomPlayer    = nil

if 'simulator' == system.getInfo( 'environment' ) then
	--audio.setVolume( 0.01 )
end

function self.loopPlay( src )
	if self.loopPlayer == nil and src then
		-- if not is_debug or 'simulator' ~= system.getInfo( 'environment' ) then
			local availableChannel = audio.findFreeChannel(4)
			self.loopPlayer = audio.play( src, { loops = -1 , channel=availableChannel} )
		-- end
	end
end

function self.play_roulette()
	self.roulette_player = audio.play( self.roulette, { loops = -1 } )
end

function self.stop_roulette( time )
	if self.roulette_player then
		local function timer_event_handler( event )
			self.roulette_player = audio.fadeOut( { channel = self.roulette_player, time = time*0.6, volume = 0.5 } )
		end
		timer.performWithDelay( time*0.4, timer_event_handler )
	end
end

function self.play( audioHandle, option )
	local result = audio.freeChannels

	local o = option or {}
	local vol = o.volume or 1

	local availableChannel = audio.findFreeChannel(4)
	if vol and availableChannel then
		audio.setVolume( vol, { channel = availableChannel } )
	end
	local channel = audio.play( audioHandle, { onComplete = self.callbackListener, volume=vol , channel=availableChannel} )

	return channel
end

function self.playEventSound( audioHandle )
	local channel = media.playEventSound( audioHandle, self.callbackListener )
	return channel
end

function self.randomPlay( min, max )
	-- assert( min, 'Fatal error : not found min' )
	-- assert( max, 'Fatal error : not found max' )
	-- if self.randomPlayer then
	-- 	self.stop( self.randomPlayer )
	-- 	self.randomPlayer = nil
	-- end
	-- local randomNum = math.random( min, max )
	-- self.randomPlayer = audio.play( self.random[randomNum] )
	-- return self.randomPlayer
end

function self.play_random()
	local check_nonce = math.random( 10000 )
	if check_nonce%3 == 0 then
		local nonce = math.random( 1, 7 )
		self.avatar = audio.loadSound( AudioDir .. 'avatar/' .. nonce .. '.mp3' )
		audio.play( self.avatar )
	end
end

function self.explode( id )
	self.random  = audio.loadSound( AudioDir .. 'charge/' .. tostring( id ) .. '.mp3' )
	audio.play( self.random, { channel = 32 } )
end

function self.stop( channel )
	if channel then
		audio.stop( channel )
		channel = nil
	end
end

function self.callbackListener()

end

-- DLした音声ファイルの読み込み
function self.init()

end

return self
