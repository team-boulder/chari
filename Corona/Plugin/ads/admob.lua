-- ProjectName : ads
--
-- Filename : chartboost.lua
--
-- Creater : Ryo Takahashi
--
-- Date : 2015-07-08
--
-- Comment :
---------------------------------------------------------
local admob = require("ads")

local this = object.new()
local is_display = false

this.initialized = false
this.data = {}
this.ads_type = nil
this.option = {}

------------------------------
-- イベントのリスナー
------------------------------
local function adListener(event)
	print("admob : adListener")
	if event.name == 'adsRequest' then
		if not event.isError then
			if event.phase == "loaded" then
			    -- an ad was preloaded
			    if is_display then
			    	is_display = false
				    this.show(this.ads_type, this.option)
				end
			elseif event.phase == "shown" then
			    -- the ad was viewed and closed
			    is_display = false
			    this.prepare(this.ads_type, this.option)
			end
		end
		this:dispatchEvent( event )
	end
end

-------------------------
-- initialize
-------------------------
function this.init(appId, option)
	this.data = option
	admob.init('admob', appId, adListener)
	this.initialized = true

	if this.data[ads_type] then
		this.prepare(ads_type)
	end
end

-------------------------
-- prepare
-------------------------
function this.prepare(ads_type, option)
	assert(this.initialized == true, 'ERROR : ads.init() をして下さい')
	assert(ads_type, 'ERROR : ads_typeが指定されていません')

	-- prepare
	admob.load( ads_type, {appId = this.data[ads_type]['appId'], testMode=this.data[ads_type]['testMode']})
end


-------------------------
-- show
-------------------------
function this.show(ads_type, option)
	-- print(option)
	local ads_type_prev = ads_type
	if ads_type == 'header' or ads_type == 'footer' then
		ads_type = 'banner'
	end
	assert(this.initialized == true, 'ERROR : ads.init() をして下さい')
	assert(ads_type, 'ERROR : ads_typeが指定されていません')
	assert(ads_type == 'interstitial' or ads_type == 'banner', 'ERROR : 存在しないads_typeです')
	this.ads_type = ads_type_prev
	this.option = option

	-- prepare
	local _x = 0
	local _y = 0
	if option and option.x and type(option.x) == 'number' then
		_x = option.x
	end
	if option and option.y and type(option.y) == 'number' then
		_y = option.y
	end
	-- admob.show('interstitial', {x=0, y=0, appId='ca-app-pub-9384125113983211/5793244486', testMode=true})
	if true or admob.isLoaded( ads_type ) then
		admob.show( ads_type, {x = _x or 0, y = _y or 0, appId = this.data[ads_type_prev]['appId'], testMode=this.data[ads_type_prev]['testMode']})
	else
		is_display = true
		this.prepare(this.ads_type)
	end
end


--------------------------
-- remove
--------------------------
function this.remove()
	admob.hide()
end

return this