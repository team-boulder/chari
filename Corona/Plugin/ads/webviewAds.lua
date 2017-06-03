-- ProjectName : 
--
-- Filename : webviewAds.lua
--
-- Creater : Ryo Takahashi
--
-- Date : 2015-07-08
--
-- Comment : 
--
----------------------------------------------------------------------------------


-- local ads = require( "ads" )
local this = object.new()

this.header        = nil
this.footer        = nil
this.icon          = nil
this.wall          = nil
this.interstitial  = nil

this.option   = {}

this.header_isVisible        = false
this.footer_isVisible        = false
this.icon_isVisible          = false  
this.wall_isVisible          = false 
this.interstitial_isVisible  = false

---------------------------------
-- ads
--
-- ads[ads_type] = {}
-- ads[ads_type]['option']
-- ads[ads_type]['view']
-- ads[ads_type]['phase']
-- ads[ads_type]['isVisible']
---------------------------------
local ads = {}

-- 表示位置のサンプル
local position = {}
position['icon']         = {x=0, y=_H/2+10, width=_W, height=120}
position['header']       = {x=0, y=0,      width=_W, height=100}
position['footer']       = {x=0, y=_H-100, width=_W, height=100}
position['wall']         = {x=0, y=0,      width=_W, height=_H}
position['interstitial'] = {x=0, y=0,      width=_W, height=_H}

-----------------------------------
-- イニシャライズ
--
-- @params table option : 
-----------------------------------
function this.init(option)
	ads = {}
	for k, v in pairs(option) do
		ads[k] = {}
		ads[k]['url'] = v
	end
end


----------------
-- 表示判定
----------------
local function visible(ads_type, set)
	if not ads[ads_type] then
		ads[ads_type] = {}
	end	

	if set == true or set == false then
		ads[ads_type]['isVisible'] = set
	end
	return ads[ads_type]['isVisible']
end

-- 広告リスナー
local isVisible = false
local function urlListener(event)

	local shouldLoad = true

	if event.errorCode then
		shouldLoad = false
		isVisible = false
	end

	-----------------------
	-- applipromotionの場合
	-----------------------
	if event.url:find("ad.applipromotion.com") then
		print(event.target.type)
		print(event.url, event.type)
		print(shouldLoad, isVisible)
		if event.url:find("wall") and event.type == "link" and system.getInfo( "platformName" ) == 'Android' then
			if isVisible then
				shouldLoad = false
				isVisible = false
			else
				isVisible = true
			end
		elseif event.url:find("wall") and system.getInfo( "platformName" ) == 'iPhone OS' then
			if isVisible then
				shouldLoad = false
				isVisible = false
			else
				isVisible = true
			end
		elseif event.url:find("open") then
			shouldLoad = false
			isVisible = false
			-- this.reload()
			system.openURL(event.url)			
		end
		if shouldLoad == false then
			if ads['wall'] then
				ads['wall']['view']:removeSelf()
			end
			if ads['wall']['view'] then
				ads['interstitial']['view']:removeSelf()
			end
			isVisible = false
		end
	elseif(event.type == "link") and not event.url:find("html#") then
		analytics.logEvent( 'ads-action', { type = event.target.ads_type, url = basename( event.url ) } )
		system.openURL(event.url)
		local cached_adsType = event.target.ads_type
		event.target:removeSelf()
		this.show(cached_adsType, this.option[cached_adsType])
		isVisible = false
	end

	return shouldLoad
end

---------------------------------
-- 表示している広告をリロードする
---------------------------------
function this.reload()
	if this.header then
		this.header:removeSelf( )
		this.get('header')
	end
	if this.footer then	
		this.footer:removeSelf( )
		this.get('footer')
	end
	if this.icon then
		this.icon:removeSelf( )
		this.get('icon')
	end
	if this.interstitial then
		this.interstitial:removeSelf()
		this.get('interstitial')
	end
end

--------------------------------------------------------
-- 表示する広告の取得
--
-- @params string ads_type : 広告の種類(php側と一致させる)
-- @params table  option   : 
--------------------------------------------------------
function this.prepare_prev(ads_type, option)
	local function listener(event)

		local data = json.decode(event.response)
		if data then
			local ad_option = {
				 url = data.url
			}

			ads[ads_type]['url'] = data.url
			ads[ads_type]['prepared'] = true

			-- prepare終了
			local dispatchEvent = {
				name = 'webviewAds',
				response = 'prepared',
				phase = 'prepared',
				ads_type = ads_type
			}
			this:dispatchEvent(dispatchEvent)			
		end
	end

	assert(ads_type, 'ERROR : ads_typeを指定してください')

	if not ads[ads_type] then
		ads[ads_type] = {}
	end
	ads[ads_type]['prepared'] = false

	--付加するパラメータ
	local params = {}
	params['type'] = ads_type
	params['platform'] = system.getInfo( "platformName" )
	fnetwork.request(urlBase .. "ads/get.php", "POST",listener, params)		

	local target = visible(type, true)
end


function this.prepare(ads_type, option)

	assert(ads_type, 'ERROR : ads_typeを指定してください')
	local target = visible(type, true)
	local dispatchEvent

	if ads[ads_type]['url'] then
		-- prepare終了
		dispatchEvent = {
			name = 'webviewAds',
			response = 'prepared',
			phase = 'prepared',
			ads_type = ads_type
		}
	else
		dispatchEvent = {
			name = 'webviewAds',
			response = 'fail',
			phase = 'fail',
			ads_type = ads_type
		}
	end
	this:dispatchEvent(dispatchEvent)
end


-----------------------------------------------
-- 広告の表示
--
-- @params str type : 広告のタイプ
-- @params table  option : 表示位置などの設定
-----------------------------------------------
function this.show(ads_type, option)
	local x, y, w, h, group = nil, nil, nil, nil, nil

	if position[ads_type] then
		local p = position[ads_type]
		x, y = p.x, p.y
		w, h = p.width, p.height
	end

	if option then
		x = option.x or x
		y = option.y or y
		w = option.width or w
		h = option.height or h
		group = option.group
		this.option[ads_type] = option
	end
	assert(ads_type, 'ERROR : ads_typeを指定して下さい')

	visible(ads_type, true)

	local function showAds()
		-- 表示していいか判定
		local view = visible(ads_type)

		local url = ads[ads_type]['url']

		-- リワード動画の場合
		if ads_type == 'rewardedVideo' then
			this.showRewardedVideo(url)
			return
		else
			assert(x and y and w and h, 'ERROR : 座標、サイズが指定されていません')
		end


		-- applipromotion用
		if url:find("ad.applipromotion.com") then
			if isVisible == false then
				view = false
			end
		end

		if view == true then
			ads[ads_type]['view'] = native.newWebView(0, 0, w, h)
			ads[ads_type]['view'].x, ads[ads_type]['view'].y = x + w/2 , y + h/2
			ads[ads_type]['view'].hasBackground = false
			if 'simulator' == system.getInfo( 'environment' ) then
				ads[ads_type]['view'].hasBackground = true
			end
			ads[ads_type]['view']['ads_type'] = ads_type
			ads[ads_type]['view']:addEventListener("urlRequest", urlListener)
			ads[ads_type]['view']:request(url, system.ResourceDirectory)
			analytics.logEvent( 'ads-show', { type = ads_type, url = basename( url ) } )

			local dispatchEvent = {
				name = 'webviewAds',
				phase = 'showed',
				ads_type = ads_type
			}
			this:dispatchEvent(dispatchEvent)

			if group then
				group:insert(ads[ads_type]['view'])
			end
		end

		if option.table then
			table.insert(option.table, ads[ads_type]['view'])
		end
	end

	-- prepare前かどうか
	if not ads[ads_type]['url'] then
		local function showListener(event)
			if event and event.response == 'prepared' then
				showAds()
				this:removeEventListener( showListener )
			end
		end
		this:addEventListener( showListener )
		this.prepare(ads_type)
	else
		showAds()
	end	
	
	return ads[ads_type]['view']
end

-- 広告を隠す
function this.unreveal( ads_type )
	assert(ads_type, 'ERROR : ads_typeを指定して下さい')
	if ads[ads_type] and ads[ads_type]['view'] then
		local target = ads[ads_type]['view'] 
		if target then
			if target.cached_x == target.x or target.cached_y == target.y then return -1 end
			if target.x == _W*2 or target.y == _H*2 then return -1 end
			target.cached_x, target.cached_y = target.x, target.y
			target.x, target.y = _W*2, _H*2
		end
	end
end

function this.reveal( ads_type )
	assert(ads_type, 'ERROR : ads_typeを指定して下さい')
	if ads[ads_type] and ads[ads_type]['view'] then
		local target = ads[ads_type]['view'] 
		if target then
			target.x, target.y = target.cached_x, target.cached_y
			target.cached_x, target.cached_y = nil
		end
	end
end

function this.remove(ads_type)
	assert(ads_type, 'ERROR : ads_typeを指定して下さい')
	if ads[ads_type] and ads[ads_type]['view'] then
		local target = ads[ads_type]['view'] 
		if target then
			local flag, ret = pcall(target.removeSelf, target)
			if not flag then
				print("error", ret)
			end
		end
		target = nil

		local index = table.indexOf( this.option, this.option[ads_type] )
		if index and type( index ) == 'number' then
			table.remove( this.option, index )
		end

		visible(ads_type, false)
	end
end


-------------------------------
-- rewardedVideo
--
-- リワードビデオを見る
-------------------------------
local _key = 'W6cDh5mg'
function this.showRewardedVideo(url)

	if system.getInfo('platformName') == 'iPhone OS' or system.getInfo('platformName') == 'Android' then
		-- sessionID 生成
		local sessionID = string.random(7, "%l%d")

		-- テキストファイルに保存する
		writeText('session_id.txt', sessionID)

		-- 画面遷移
		system.openURL(url..'?session='..sessionID)
	end
end

-- 動画を見終わった後に呼び出す
function this.endedRewardedVideo(url)

	if url then
		local solt = url:match('solt=(%w+)')
		local hash = url:match('hash=(%w+)')
		local sessionID = url:match('session=(%w+)')

		local lua_sessionID = readText("session_id.txt", system.DocumentsDirectory)
		local crypto = require( "crypto" )
		local lua_hash = crypto.digest( crypto.sha256,lua_sessionID..solt )

		local event = {}
		event.type = 'webviewAds'
		if lua_hash == hash then
			-- 成功
			event.name = 'reward'

			-- テキストファイルの削除
			local result, reason = os.remove( system.pathForFile( "session_id.txt", system.DocumentsDirectory) )
		else
			-- 不正なID
			event.name = 'failed'
		end
		this:dispatchEvent(event)
	end
end


local function onSystemEvent(event)
	if event.type == "applicationOpen" then
		local url  = event.url
		local solt = url:match('solt=(%w+)')
		local hash = url:match('hash=(%w+)')
		if solt and hash then
			this.endedRewardedVideo(url)
		end
	end
end
Runtime:addEventListener("system", onSystemEvent)

return this