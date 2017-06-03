-- ProjectName : 
--
-- Filename : ads.lua
--
-- Creater : Ryo Takahashi
--
-- Date : 2015-06-18
--
-- Comment : freepのウォール、アフィリエイト（affiliate）、インタースティシャル、ネイティブアド
--------------------------------------------------------

local this = object.new()
local ads = {}

-- もやしびと型広告の背景はここで設定	
local moyashi_bg = ImgDir .. 'ads/ads.png'

-----------------------------------
-- イニシャライズ
--
-- @params table option : 
-----------------------------------
function this.init(option)
	ads = {}
	for k, v in pairs(option) do
		print(k)
		print(v)
		ads[k] = {}
		ads[k]['url'] = v

		if k == 'interstitial' then
			this.prepareInterstitial()			
		end
	end
end


----------------------------------
-- トクスペおすすめ用webView
----------------------------------
local webview
local wall_option = {}

this.is_shown_interstitial = false

local function urlListenerWall(event)
	if event.type == "link" and event.url:find("store") then
		system.openURL(event.url)
		webview:removeSelf()
		local event = {
			type = 'freepAds',
			phase = 'closed',
			name = 'wall'
		}
		this:dispatchEvent( event )
	elseif event.type == "link" and event.url:find("close") then
		transition.to(webview, {time=200, x=wall_option._x0, y=wall_option._y0, transition=easing.inQuad, onComplete=
			function()
				webview:removeSelf()
				local event = {
					type = 'freepAds',
					phase = 'closed',
					name = 'wall'
				}
				this:dispatchEvent( event )
			end
		})
	end
end

-------------------------
-- 自社ウォール広告
-------------------------
function this.showTsWall(ads_option)
	-- 現れる方向
	wall_option.direction = 'right'
	
	if ads_option and ads_option.direction then
		wall_option.direction = ads_option.direction
	end

	if wall_option.direction == 'right' then
		wall_option._x0 = _W*3/2
		wall_option._y0 = _H/2

	elseif wall_option.direction == 'left' then
		wall_option._x0 = -_W/2
		wall_option._y0 = _H/2

	elseif wall_option.direction == 'top' then
		wall_option._x0 = _W/2
		wall_option._y0 = -_H/2

	elseif wall_option.direction == 'bottom' then
		wall_option._x0 = _W*3/2
		wall_option._y0 = _H*3/2
	end


	webview = native.newWebView(0, 0, _W, _H)
	webview.x, webview.y = wall_option._x0, wall_option._y0 
	webview.hasBackground = true
	webview:addEventListener("urlRequest", urlListenerWall)
	webview:request(ads['wall']['url'], system.ResourceDirectory)

	transition.to(webview, {time=200, x=_W/2, y=_H/2, transition=easing.inQuad})

	local event = {
		type = 'freepAds',
		phase = 'showed',
		name = 'wall'
	}
	this:dispatchEvent( event )
end

----------------------------
-- アフィリエイト広告
----------------------------

-- アフィリエイト用webView
local affi = {}

local function urlListenerAfii(event)
	if event.type == "link" and event.url:find("product") then
		system.openURL(event.url)
		this.removeAffiliate()
	elseif event.type == "link" and event.url:find("close") then
		this.removeAffiliate()
	end
end


-- 広告表示
function this.showAffiliate(ads_option)

	-- パラメータ
	local _x = _W/2
	local _y = _H/2 + 50
	local _w = _W-100
	local _h = _H-200

	if ads_option then
		_x = ads_option.x or _x
		_y = ads_option.y or _y
		_w = ads_option.width or _w
		_h = ads_option.height or _h
	end

	affi.group = display.newGroup()

	-- 背景
	affi.bg = display.newRect(affi.group, 0, 0, _W, _H)
	affi.bg:setFillColor( 0, 220 )
	affi.bg.alpha=0

	-- 閉じるボタン
	local close = btn.newPushImage({image='Plugin/ads/Images/closeIcon.png', group=affi.group})
	close.x = _W-90; close.y = 60;
	close:addEventListener( 'tap', this.removeAffiliate )

	-- webview部分
	affi.webview = native.newWebView(0, 0, _w, _h)
	affi.webview.x, affi.webview.y = _x, _y
	affi.group:insert(affi.webview)
	affi.webview.hasBackground = false
	affi.webview:addEventListener("urlRequest", urlListenerAfii)
	affi.webview:request(ads['affiliate']['url'], system.ResourceDirectory)	

	-- 表示挙動
	affi.webview:scale(0.1, 0.1)
	transition.to(affi.webview, {time=230, xScale=1, yScale=1, transition=easing.outBack})
	transition.to(affi.bg, {time=230, alpha=1})

	local event = {
		type = 'freepAds',
		phase = 'showed',
		name = 'affiliate'
	}
	this:dispatchEvent( event )

end

-- アフィリエイト削除
function this.removeAffiliate()
	if affi then
		-- 表示挙動
		affi.webview:scale(0.1, 0.1)
		transition.to(affi.webview, {time=230, xScale=0.1, yScale=0.1, transition=easing.inBack, onComplete=
			function()
				display.remove(affi.group)
				affi.group = nil
			end
		})
		transition.to(bg, {time=230, alpha=0})

		local event = {
			type = 'freepAds',
			phase = 'closed',
			name = 'affiliate'
		}
		this:dispatchEvent( event )
	end
end


----------------------------
-- インタースティシャル広告
----------------------------

-- インタースティシャル用webView
local interstitial = {}
interstitial.group = nil

local function urlListenerInterstitial(event)
	if event.type == "link" and not event.url:find("html#") then
		system.openURL( event.url )
		this.removeInterstitial()
	elseif event.type == "link" and event.url:find("close") then
		this.removeInterstitial()
	end
end

interstitial.x = _W*0.5
interstitial.y = _H*0.5 + 56
interstitial.width = 600
interstitial.height = 500

-- 事前にインターステイシャルを準備
function this.prepareInterstitial()
	if interstitial == nil then return end
	display.remove(interstitial.effect_group)
	interstitial.effect_group = nil 
	interstitial.effect_group = display.newGroup()
	interstitial.prepared = true
	interstitial.webview = native.newWebView(0, -1000, interstitial.width, interstitial.height)
	interstitial.webview.x, interstitial.webview.y = _W*2, interstitial.y
	interstitial.webview.hasBackground = false
	if 'simulator' == system.getInfo( 'environment' ) then
		interstitial.webview.hasBackground = true
	end
	interstitial.webview:addEventListener("urlRequest", urlListenerInterstitial)
	interstitial.webview:request(ads['interstitial']['url'], system.ResourceDirectory)
end

-- 広告表示
function this.showInterstitial(ads_option)
	if not this.is_shown_interstitial then
		-- パラメータ
		this.is_shown_interstitial = true

		if ads_option then
			interstitial.x = ads_option.x or interstitial.x
			interstitial.y = ads_option.y or interstitial.y
			interstitial.width = ads_option.width or interstitial.width
			interstitial.height = ads_option.height or interstitial.height
		end

		if interstitial.group then
			display.remove( interstitial.group )
			interstitial.group = nil
		end
		interstitial.group = display.newGroup()

		-- 背景
		interstitial.bg = display.newRect(interstitial.group, 0, 0, _W, _H)
		interstitial.bg:setFillColor( 0, 200 )
		interstitial.bg.alpha = 0
		interstitial.bg.isHitTestable = true
		interstitial.bg:addEventListener( 'tap', returnTrue )
		interstitial.bg:addEventListener( 'touch', returnTrue )

		local image_src = ImgDir .. 'ads/popup.jpg'
		interstitial.popup = display.newImage(interstitial.effect_group, image_src)
		interstitial.popup.x, interstitial.popup.y = _W*0.5, _H*0.5

		-- 閉じるボタン
		local close = display.newRect( 0, 0, 600, 80 )
		close.x, close.y = _W*0.5, interstitial.popup.y+interstitial.popup.height*0.5-close.height*0.5
		close:setFillColor( 255, 0, 0 )
		close.alpha = __HitTestAlha
		close.isHitTestable = true
		close:addEventListener( 'tap', this.removeInterstitial )
		interstitial.effect_group:insert( close )

		-- webview部分
		if interstitial.prepared == false then
			this.prepareInterstitial()
		end
		interstitial.group:insert(interstitial.webview)
		interstitial.webview:setReferencePoint( display.CenterReferencePoint )
		interstitial.webview.x, interstitial.webview.y = interstitial.x, interstitial.y
		if system.getInfo('platformName') == 'Android' then
			interstitial.webview.y = interstitial.y+10
		end

		interstitial.group:insert( interstitial.effect_group )

		local function onComplete( e )
			local event = 
			{
				type = 'freepAds',
				phase = 'showed',
				name = 'interstitial'
			}
			this:dispatchEvent( event )
		end

		-- 表示挙動
		interstitial.effect_group:scale( 0.1, 0.1 )
		interstitial.effect_group:setReferencePoint( display.CenterReferencePoint )
		transition.to( interstitial.effect_group, { time = 100, xScale = 1, yScale = 1, transition = easing.outBack, onComplete = onComplete } )
		transition.to( interstitial.bg, { time=100, alpha = 1 } )

	end
end

-- インタースティシャル削除
function this.removeInterstitial()
	if interstitial then
		if sound and sound.play then
			sound.play( sound.push )
		end
		
		local function remove()
			display.remove( interstitial.group )
			interstitial.group = nil
			interstitial.prepared = false
			this.prepareInterstitial()
		end
		transition.to( interstitial.group, { time = 230, alpha = 0, transition=easing.inBack, onComplete = remove } )
		this.is_shown_interstitial = false

		local event = {
			type = 'freepAds',
			phase = 'closed',
			name = 'interstitial'
		}
		this:dispatchEvent( event )
	end
	return true
end

----------------------------
-- ネイティブアド広告
----------------------------

-- ネイティブアド用webView
local moyashi = {}
moyashi.group = nil

local function urlListenerMoyashi(event)
	if event.type == "link" and not event.url:find("html#") then
		system.openURL( event.url )
	end
end

moyashi.x = 100
moyashi.y = 190
moyashi.bg_x = 145
moyashi.bg_y = 190
moyashi.width = 180
moyashi.height = 150

-- 広告表示
function this.showMoyashi( ads_option )
	if not this.is_shown_moyashi then
		-- パラメータ
		this.is_shown_moyashi = true

		if ads_option then
			moyashi.x = ads_option.x or moyashi.x
			moyashi.y = ads_option.y or moyashi.y
			moyashi.bg_x = ads_option.bg_x or moyashi.x+35
			moyashi.bg_y = ads_option.bg_y or moyashi.y
			moyashi.width = ads_option.width or moyashi.width
			moyashi.height = ads_option.height or moyashi.height
		end

		if moyashi.group then
			display.remove( moyashi.group )
			moyashi.group = nil
		end
		moyashi.group = display.newGroup()

		moyashi.popup = display.newImage( moyashi.group, moyashi_bg )
		moyashi.popup.x, moyashi.popup.y = moyashi.bg_x, moyashi.bg_y

		-- webview部分
		moyashi.webview = native.newWebView( 0, 0, moyashi.width, moyashi.height )
		moyashi.webview.x, moyashi.webview.y = moyashi.x, moyashi.y
		moyashi.group:insert( moyashi.webview )
		moyashi.webview.hasBackground = false
		if 'simulator' == system.getInfo( 'environment' ) then
			moyashi.webview.hasBackground = true
		end
		moyashi.webview:addEventListener("urlRequest", urlListenerMoyashi)
		moyashi.webview:request(ads['moyashi']['url'], system.ResourceDirectory)

		local event = {
			type = 'freepAds',
			phase = 'showed',
			name = 'moyashi'
		}
		this:dispatchEvent( event )
	end
end

-- ネイティブアド削除
function this.removeMoyashi()
	if moyashi then
		display.remove( moyashi.group )
		moyashi.group = nil
		this.is_shown_moyashi = false

		local event = {
			type = 'freepAds',
			phase = 'closed',
			name = 'moyashi'
		}
		this:dispatchEvent( event )
	end
	return true
end

function this.unrevealMoyashi()
	if moyashi then
		moyashi.webview.x, moyashi.webview.y = _W*2, _H*2
	end
end

function this.revealMoyashi()
	if moyashi then
		moyashi.webview.x, moyashi.webview.y = moyashi.x, moyashi.y
	end
end

-- コンテンツ型広告の読み込み
function this.prepare( ads_type, ads_option )
	assert(ads_type, 'ads_typeを指定して下さい')
	assert(ads_type == 'wall' or ads_type == 'affiliate' or ads_type == 'interstitial' or ads_type == 'moyashi', 'ads_typeが対応していません')

	if ads_type == 'wall' then
	elseif ads_type == 'affiliate' then
	elseif ads_type == 'interstitial' then
		this.prepareInterstitial()
	elseif ads_type == 'moyashi' then
	end
end

---------------------------
-- 広告表示
---------------------------
function this.show(ads_type, ads_option)
	assert(ads_type, 'ads_typeを指定して下さい')
	assert(ads_type == 'wall' or ads_type == 'affiliate' or ads_type == 'interstitial' or ads_type == 'moyashi', 'ads_typeが対応していません')

	if ads_type == 'wall' then
		this.showTsWall(ads_option)
	elseif ads_type == 'affiliate' then
		this.showAffiliate(ads_option)
	elseif ads_type == 'interstitial' then
		this.showInterstitial( ads_option )
	elseif ads_type == 'moyashi' then
		this.showMoyashi( ads_option )
	end
end

function this.remove( ads_type, ads_option )
	assert(ads_type, 'ads_typeを指定して下さい')
	assert(ads_type == 'wall' or ads_type == 'affiliate' or ads_type == 'interstitial' or ads_type == 'moyashi', 'ads_typeが対応していません')
	
	if ads_type == 'interstitial' then
		this.removeInterstitial()
	elseif ads_type == 'moyashi' then
		this.removeMoyashi()
	end
end

function this.reveal( ads_type )
	assert(ads_type, 'ads_typeを指定して下さい')
	assert(ads_type == 'wall' or ads_type == 'affiliate' or ads_type == 'interstitial' or ads_type == 'moyashi', 'ads_typeが対応していません')
	
	if ads_type == 'moyashi' then
		this.revealMoyashi()
	end
end

function this.unreveal( ads_type )
	assert(ads_type, 'ads_typeを指定して下さい')
	assert(ads_type == 'wall' or ads_type == 'affiliate' or ads_type == 'interstitial' or ads_type == 'moyashi', 'ads_typeが対応していません')
	
	if ads_type == 'moyashi' then
		this.unrevealMoyashi()
	end
end

return this