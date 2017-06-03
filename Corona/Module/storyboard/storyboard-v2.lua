--[[
@
@ Project  : 
@
@ Filename : storyboard-v2.lua
@ 
@ Author   : Task Nagashige
@
@ Date     : 
@
@ Comment  : 
@
@ Package  : storyboard関数の拡張
@
]]--

local self = require( ModDir .. 'storyboard.storyboard' )

local ads = require( PluginDir .. 'ads.ads' )
local ads_keep = {}

self.page_num = 0

local _time = 100
local _fade = 'crossFade'
local function remove()
	if self.left_cover then
		display.remove( self.left_cover )
		self.left_cover = nil
	end

	if self.right_cover then
		display.remove( self.right_cover )
		self.right_cover = nil
	end
end

local cached_self_purge_all = self.purgeAll
function self.purgeAll()
	for key, value in pairs( ads.showing_ads ) do
		ads.remove( key )
		key = nil
		value = nil
	end
	ads.destroy()
	cached_self_purge_all()
	remove()

	local count = playerInfoData['page_interval'] or 3
	local is_load = playerInfoData['load_ads'] or 0
	if (self.page_num+1)%count > 0 and is_load == 1 then
		ads.prepare( 'interstitial' )
	end
end

local cached_self_remove_all = self.removeAll
function self.removeAll()
	for key, value in pairs( ads.showing_ads ) do
		ads.remove( key )
		key = nil
		value = nil
	end
	ads.destroy()
	cached_self_remove_all()
	remove()
end

local cached_self_goto_scene = self.gotoScene
function self.gotoScene( ... )
	self.purgeAll()
	
	local arg = { ... }
	analytics.logEvent( arg[1] )
	if arg[2] == nil then
		arg[2] = { time = _time, effect = _fade }
	end

	if arg[2] and arg[2]['effect'] == nil then
		arg[2]['time']   = _time
		arg[2]['effect'] = _fade
	end
	cached_self_goto_scene( arg[1], arg[2] )

	local count = playerInfoData['page_interval'] or 3
	self.page_num = self.page_num + 1

	if self.page_num%count == 0 then
		ads.show( 'interstitial' )
	end

	self.left_cover = display.newRect( -_W*0.5, 0, _W*0.5, _H )
	self.left_cover:setFillColor( 0 )

	self.right_cover = display.newRect( _W, 0, _W*0.5, _H )
	self.right_cover:setFillColor( 0 )
end

local cached_self_show_overlay = self.showOverlay
function self.showOverlay( ... )
	local arg = { ... }
	analytics.logEvent( arg[1] )
	cached_self_show_overlay( ... )
	-- ads.hide( 'interstitial' )
end

local cached_self_hide_overlay = self.hideOverlay
function self.hideOverlay( ... )
	local arg = { ... }
	cached_self_hide_overlay( ... )
	-- ads.display( 'interstitial' )
end

local cached_self_new_scene = self.newScene
function self.newScene( ... )
	local s = cached_self_new_scene( ... )
	return s
end

local cached_self_reload_scene = self.reloadScene
function self.reloadScene()
	for key, value in pairs( ads.showing_ads ) do
		ads.remove( key )
	end
	ads.destroy()
	return cached_self_reload_scene()
end

return self