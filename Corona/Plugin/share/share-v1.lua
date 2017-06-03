
-- ProjectName : 
--
-- Filename : ads.lua
--
-- Creater : Ryo Takahashi
--
-- Date : 2015-06-18
--
-- Comment : 
-- adsから継承して作成。Talkspaceにシェア出来る
----------------------------------------------------------------------------------

-- 継承元
local share = require(PluginDir .. 'share.share')
-- local talkspace = require(PluginDir .. 'talkspace.talkspace')
local this = object.new()
line = object.new()

-- 継承元のメソッドを残す
share._post = share.post

local share_option

local prev_line_share_time
this.line_share_tap = false
this.line_shared = 1

-- Plugin
local ads = require(PluginDir .. 'ads.ads')
local ads_keep = {}

-- シュミレーターの時には擬似的にシェアを成功させるか
local is_simulator = true

local function post_simulator()
	if 'simulator' == system.getInfo( 'environment' ) and is_simulator then
		if share_option.listener then
			share_option.listener()
		end
	end
end

-- サーバ側から情報の変更
local function replaceData( data )
	if data then
		print( data )
		if __share_data and data['type'] and __share_data[data['type']] then
			if __share_data[data['type']]['comment'] and type( __share_data[data['type']]['comment'] ) == 'string' then
				data['message'] = __share_data[data['type']]['comment']
			else
				if __share_data[data['type']]['comment'] and type( __share_data[data['type']]['comment'] ) == 'table' then
					if data['stage'] then
						data['message'] = __share_data[data['type']]['comment'][data['stage']]
					end

					if __share_data[share_option['type']]['random'] then
						local share_comment_num = #__share_data[data['type']]['comment']
						local nonce = math.random( 1, share_comment_num )
						data['message'] = __share_data[data['type']]['comment'][nonce]
					end
				end
			end
			if __share_data[data['type']]['url'] then
				data['url'] = __share_data[data['type']]['url']
			end
		end
		data['message'] = string.gsub(data['message'], '@name', data['name'] or '')
		data['message'] = string.gsub(data['message'], '@rarity', data['rarity'] or '')
		data['message'] = string.gsub(data['message'], '@action', data['action'] or '')
		data['message'] = string.gsub(data['message'], '@code', data['code'] or '')
	end
	return data
end


local function onSystemEvent( event )

    local eventType = event.type

    if eventType == "applicationStart" then
    elseif eventType == "applicationExit" then
    	timer.performWithDelay( 2000 , function() Runtime:removeEventListener( 'system' , onSystemEvent ) end )
    elseif eventType == "applicationSuspend" then

    	if this.line_share_tap == true then
			prev_line_share_time = os.time()
		end
    elseif eventType == "applicationResume" then
        -- 再起動
        if prev_line_share_time and os.difftime( os.time() , prev_line_share_time ) > 10 then
            this.line_shared = 0
            local event = 
            {
            	name = 'line-post-finish'
        	}
        	line:dispatchEvent( event )
            -- this.reload()
            -- this.review_option.action()
            this.line_share_tap = false
        end
		timer.performWithDelay( 2000 , function() Runtime:removeEventListener( 'system' , onSystemEvent ) end )

    elseif eventType == "applicationOpen" then
    end
end

local function talkspaceHundler(event)
	if event.name == 'talkspace-post-finish' then

		if share_option and share_option.listener then
			local t_event = {
				name = 'popup',
				type = 'social',
				action = 'sent',
				limitReached = 'nil'
			}
			share_option.listener(t_event)
		end
	end
end
-- talkspace:addEventListener( talkspaceHundler )

local function lineHandler( event )

	if event.name == 'line-post-finish' then

		if share_option and share_option.listener then

			local line_event = {
				name = 'popup',
				type = 'social',
				action = 'sent',
				limitReached = 'nil'
			}
			share_option.listener( line_event )
		end
	end
end
line:addEventListener( lineHandler )


function share.twitter( ... )
	share_option = ...
	share_option = replaceData( share_option )

	local uniq_id = string.random( 3, '%l%d' )
	share_option.url = share_option.url .. '?s=' .. uniq_id

	print( share_option )

	if system.getInfo('platformName') ~= 'Android' then
		share_option['service'] = 'twitter'
	end
	if share_option['image'] and share_option['type'] and __share_data[share_option['type']] and  __share_data[share_option['type']]['image'] then
		share_option['image'] = nil
	end
	share._post( share_option )

	analytics.logEvent( 'share', { type = 'twitter', page = share_option.type } )
	Runtime:addEventListener( 'system' , onSystemEvent )
	post_simulator()
end

function share.line( ... )
	share_option = ...
	share_option = replaceData( share_option )

	print( share_option )

	local message = share_option.message .. '　' .. share_option.url
	local url="line://msg/text/".. url_encode( message )
	event_type = 'line'
	if system.getInfo('platformName') == 'iPhone OS' then
		-- ATS 対策
		local ios = system.getInfo( 'platformVersion' )
		local ios_version = string.sub( ios , 1 , 1 )
		if tonumber( ios_version ) >= 9 then
			message = share_option.message .. share_option.url
			url = urlBase .. 'line.php?line_message='.. url_encode( message )
		end
	end
	analytics.logEvent( 'share', { type = 'line', page = share_option.type } )
	system.openURL( url )

	this.line_share_tap = true
	Runtime:addEventListener( 'system' , onSystemEvent )
	post_simulator()
end

----------------------------------
-- トクスペ機能を盛り込んだシェア
----------------------------------
local function shareEventHandler( event )
	if event.action == "clicked" then
		local i = event.index
		local event_type
		if i == 1 then
			-- Do nothing; dialog will simply dismiss
			event_type = 'twitter'
			if system.getInfo('platformName') ~= 'Android' then
				share_option['service'] = 'twitter'
			end
			if share_option['image'] and share_option['type'] and __share_data[share_option['type']] and __share_data[share_option['type']]['image'] then
				share_option['image'] = nil
			end
			local uniq_id = string.random( 3, '%l%d' )
			share_option.url = share_option.url .. '?s=' .. uniq_id
			analytics.logEvent( 'share', { type = 'twitter', page = share_option.type } )
			share._post( share_option )
			post_simulator()

		elseif i == 2 then
			-- line urlscheme
			this.line_share_tap = true
			local message = share_option.message .. '　' .. share_option.url
	    	local url="line://msg/text/".. url_encode( message )
	    	event_type = 'line'
	    	if system.getInfo('platformName') == 'iPhone OS' then
	    		-- ATS 対策
	    		local ios = system.getInfo( 'platformVersion' )
				local ios_version = string.sub( ios , 1 , 1 )
				if tonumber( ios_version ) >= 9 then
		    		message = share_option.message .. share_option.url
					url = urlBase .. 'line.php?line_message='.. url_encode( message )
				end
	    	end
	    	analytics.logEvent( 'share', { type = 'line', page = share_option.type } )
	    	system.openURL( url )
	    	post_simulator()
		end
	end
end

-------------------
-- 投稿機能
-------------------
function share.post(...)
	share_option = ...
	share_option = replaceData( share_option )
	
	print( share_option )

	local snsStr = 'Twitter'
	if system.getInfo('platformName') == 'Android' then
		snsStr = 'その他SNS'
	end
	local event_type
	if share_option.fever then
		event_type = 'fever'
		local alert = native.showAlert( '☆フィーバータイム☆', 'シェアしてフィーバータイム突入', { snsStr, "LINE", '戻る' }, shareEventHandler ) 	
	elseif share_option.recover then
		event_type = 'recover'
		local alert = native.showAlert( '☆フィーバー回復☆', 'シェアしてフィーバータイム回復', { snsStr, "LINE", '戻る' }, shareEventHandler ) 
	elseif share_option.geted then	
		event_type = 'geted'
		local alert = native.showAlert( '☆新' .. __charge_icon_name .. 'GET☆', 'SNSにシェアすると無料で' .. __charge_potion_name .. 'をGETできます!!', { snsStr, "LINE", '戻る' }, shareEventHandler ) 
	elseif share_option.growth then
		event_type = 'growth'
		local alert = native.showAlert( '☆進化時限定☆', 'SNSにシェアすると無料で' .. __charge_potion_name .. 'をGETできます!!', { snsStr, "LINE", '戻る' }, shareEventHandler ) 	
	else
		event_type = 'share'
		local alert = native.showAlert( "SNSシェア", "シェアするSNSを選んで下さい", { snsStr, "LINE", '戻る' }, shareEventHandler )
	end

	-- analytics.logEvent( 'share', { kind = event_type } )
	Runtime:addEventListener( 'system' , onSystemEvent )
end

-------------------
-- ads用のhundler
-------------------
local function adsHandler(event)
	if event.name == 'talkspace-post-finish' or (event.name == 'talkspace-btn-tap' and event.value == 'cancel') then
		for k, v in pairs(ads_keep) do
			ads.show(k, v)
		end
		share_option = nil
	end
end
-- talkspace:addEventListener( adsHandler )

function share.save()
	local boarder_date = os.date( '%Y%m%d', os.time() )
	playerInfo.set( 'share_date', boarder_date )
	playerInfo.set( 'is_share', 0 )
end

function share.check()
	local current_date = tonumber( os.date( '%Y%m%d', os.time() ) )
	if current_date > tonumber( playerInfoData['share_date'] ) then
		playerInfo.set( 'is_share', 1 )
		return 0
	end
	return -1
end


return share