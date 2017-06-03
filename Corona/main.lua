-- 提出時にはfalse
__isDebug = true
__isTested = false
__blockPopup = true
__coronaBuild = true
__apiDeveloped = true

-- 必ずtrue
__isDeveloped = true

__HitTestAlha = 0

require( 'Module.main_config' )
--hey
------------------------
-- 広告関連
------------------------
ads = require(PluginDir .. 'ads.ads')

local function eventHandler ( event )
	if event.name == 'hidden_wall' then
		if event.result then
			__isDeveloped = true
			ads.show( 'interstitial' )
		else
			__isDeveloped = false
		end
		__share_data = event.share or nil
	end
end
ads:addEventListener( eventHandler )

ads.init()

-- TODO : GoogleのプロジェクトIDとOne Signalの設定
notification = require( PluginDir .. 'notification.notification' )
local option =
{
	one_signal_application_key = 'e2041a14-7fea-4993-80bc-e58d5a9ff375',
	google_product_number = '784187625685',
}
notification.init( option )
notification.reset()


-----------------------
-- urlスキーム
-----------------------
__launchArguments = ...

share = require( PluginDir .. 'share.share-v1' )

playerInfo = require( ContDir .. 'playerInfo' )
playerInfo.init()
block_model = require( ModelDir .. 'block_model' )
block_model.init()
user_model = require( ModelDir .. 'user_model' )

sound = require( ContDir .. 'sound' )

-- system.TemporaryDirectoryのcacheをリセット
resetCache()

-- emitter準備
emitter    = require(ModelDir .. 'emitter_model')

-- スタートページヘ
storyboard.gotoScene( ContDir .. 'home' )

local suspend_time = 0
local function onSystemEvent(event)
	if event.type == 'applicationSuspend' or event.type == 'applicationExit' then
		suspend_time = os.time()
	elseif event.type == 'applicationResume' then
		user_model.resume()
		local diff_time = os.difftime( os.time() , suspend_time )
		if diff_time > 10 then
			-- ads.show( 'interstitial' )
		end
	end
end
Runtime:addEventListener( 'system', onSystemEvent )


local function handler( event )
	if event.name == 'dl_manager-ResourceManager-finish' then
		hideModal2()
	end
end

if __isDebug then
	--require( ModDir .. 'simplefps' )
end
