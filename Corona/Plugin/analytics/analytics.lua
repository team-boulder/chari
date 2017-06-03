-- Filename : analytics.lua
--
-- Creater : Ryo Takahashi
--
-- Date : 2015-06-28
--
-- Comment : 
--
---------------------------------------------------------------------
local analytics = require('analytics')

-------------------------------
-- FlurryサイトよりAPI Keyを取得
-------------------------------
-- TODO : iOSとAndroidのAPIキーを設定する
local app_key = nil
if system.getInfo( "platformName" ) == 'Android' then
	app_key = 'DYC9KKQ7RC8553GXCJQR'
elseif system.getInfo( "platformName" ) == 'iPhone OS' then
	app_key = '4QWZKQ5JB2GRKVSJJ6SR'
end
analytics.init(app_key)

return analytics
