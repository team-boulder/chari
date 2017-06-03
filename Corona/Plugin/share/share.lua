-- ProjectName : 
--
-- Filename : gamecenter.lua
--
-- Creater : Ryo Takahashi
--
-- Date : 2015-06-30
--
-- Comment : 
--
----------------------------------------------------------------------------------
-- local talkspace = require(PluginDir .. 'talkspace.talkspace')
-- talkspace.init()

local this = object.new()
this.default_message = ""
this.default_service = 'twitter'

if system.getInfo( 'platformName' ) == 'Android' then
	this.default_service = 'share'
end

---------------------------------------------------------------------------------
-- シェアする
--
-- @params table option : シェアする対象や文章、画像
-- message  : シェアする文章
-- url      : url
-- image    : 画像url
-- listener : レスポンスを返す
-- tags     : Talkspaceのタイムラインにタグを付ける
-- service  : サービス名 (share, twitter, facebook, sinaWeibo, tencentWeibo)
---------------------------------------------------------------------------------
function this.post(option)
	local share_option = {}

	-- シェアする文章
	share_option.message = option.message or this.default_message

	-- シェアするurl
	if option.url then
		share_option.url = {option.url}
	end

	-- シェアする画像
	if option.image then
		share_option.image = {
			{filename = option.image.filename, baseDir = option.image.dir or system.ResourceDirectory}
		}
	end

	-- シェアする先
	share_option.service = option.service or this.default_service

	local listener = {}
    function listener:popup( event )
        print( "name: " .. event.name )
        print( "type: " .. event.type )
        print( "action: " .. tostring( event.action ) )
        print( "limitReached: " .. tostring( event.limitReached ) )

        option.listener(event)
    end

	share_option.listener = listener

	-- Talkspaceに付加するタグ
    share_option.tags = option.tags or 'Talkspace'

    if share_option.service == 'talkspace' then
		-- talkspace.post( share_option )
	else
		native.showPopup('social', share_option)
	end
	if analytics and share_option.service then
		-- analytics.logEvent( 'share' )
		-- analytics.logEvent( 'share', { type = share_option.service } )
	end
end


return this