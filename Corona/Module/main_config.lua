-- ProjectName :
--
-- Filename : main_config.lua
--
-- Creater :
--
-- Date :
--
-- Comment :
--
--
------------------------------------------------------------------------------------

-- アプリのプロジェクト名
__project_name = 'cosmo'

-- アプリのバージョン
__app_ver = 0.50

__userInfoDataFile = 'userInfo.txt'
__default_message = 'このアプリ面白い！'

--ステータスバーの設定
-- display.setStatusBar( display.TranslucentStatusBar )
display.setStatusBar( display.HiddenStatusBar )

--画面幅を_W、画面高さを_H、ステータスバー高さを_SHとする
_W  = display.contentWidth
_H  = display.actualContentHeight

if system.getInfo( 'platformName' ) == 'Android' then
	_SH = 45
else
	_SH = (display.actualContentHeight - display.contentHeight)*0.5
end

-- iOSはsystem.DocumentsDirectoryに保存するとリジェクトされるのでそれ用にわける
__cache_dir = system.DocumentsDirectory
if system.getInfo( 'platformName' ) == 'iPhone OS' then
	__cache_dir = system.CachesDirectory
end

if system.getInfo( 'platformName' ) == 'iPhone OS' then
	__device_id = system.getInfo( 'iosIdentifierForVendor' )
else
	__device_id = system.getInfo( 'deviceID' )
end

-- urlのベース部分
-- TODO : APIのディレクトリを最適なものに変更する

urlBase = "http://app.talkspace-web.com/cgn/"
if __apiDeveloped then
	urlBase = "http://apptest.talkspace-web.com/ntask/cosmo/"
	urlBase = "http://app.talkspace-web.com/cosmo-api/"
end


--呼び出すディレクトリ
ImgDir     = 'Images/'
ViewDir    = "View."
ModelDir   = "Model."
ContDir    = "Controller."
ModDir     = "Module."
PluginDir  = "Plugin."
AudioDir   = "Audio/"
JsonDir    = "Json/"
VideoDir	 = "Video/"

-- ファイル呼び出し

require(ModDir .. 'print.print')
require(ModDir .. "tsutil.tsutil")
require(ModDir .. "library.library")
require(ModDir .. "audio.audio")
require(ModDir .. "display.display-v2")
require(ModDir .. "game_config")
require(ModDir .. 'table.table')
require(ModDir .. "transition.transition")
require(ModDir .. 'native.native')
require(ModDir .. 'timer.timer')

-----------------
-- 解析 (Flurry)
-----------------
analytics  = require( PluginDir..'analytics.analytics-v2' )
fnetwork   = require(ModDir.."network.network")
object     = require(ModDir.."object.object")
btn        = require(ModDir.."btn.btn")
json       = require("json")
number     = require(ModDir.."number.number")
storyboard = require(ModDir.."storyboard.storyboard-v2")
MIDI       = require(ModDir.."MIDI.MIDI-v2")
sheet      = require(ModDir.."sheet.sheet")
mime 	   = require("mime")
http 	   = require("socket.http")
ltn12	   = require("ltn12")
widget     = require 'widget'
widget_v1  = require(ModDir.."widget.widget-v1")
widget.setTheme( 'widget_theme_android_holo_dark' )
applovin   = require( "plugin.applovin" )
anim       = require(PluginDir .. 'anim.anim')

--- Googleのパブリックキーを特殊な処理で暗号化
-- TODO : 暗号化したGoogleパブリックキーを設定する。
__publicKey = 'TUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUFtSTdMUll6anc5OURrNnJyQ21GWUh2SzY0OHlBb1NobnFWUVZGMlRZS3FlZTBBNzQ3SWZsenlVS2ttNk5aempZelZNakwrNGEzTVc5WHptOWh3WVluUHB0WkxEQUc5RFNaaXdaSE5ma0RJVnpFcGNvVllsQnA1YytXWm1WcWJLVkJtTXRnV3BjUjc2RDRRaVRodXkxNXhwa2tibTRYWW9tM01raEV1OFR2MjUra3VKMThuc25MaUE4cXMvSXZYTHF3cUJqMFNFUi80a1JFL05SL1BsSVBBbi9LaHlRUkJBK2MwcGZmTTVGU3BpczducTB4UFU2N0xhd1hHUXdNZEcvK05GSmRNd0pGWkRKVld2R0Fyb2dXM2FqRFR4NVY0cFMwZTQ1YmhPcUMwdHhHcXdSTWZ4S3JsR3pVTGpXTnkwdG85TWd3ZnRyUjVCM0tBbS9nODRZUFFJREFRQUI='

_mcolor = {70, 78, 102}
