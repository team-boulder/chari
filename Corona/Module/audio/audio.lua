--[[
@
@ Project  : 
@
@ Filename : audio.lua
@
@ Author   : Task Nagashige
@
@ Date     : 
@
@ Comment  : 
@
@ Package  : audio関数の拡張
@
]]--

local checkDownload = checkDownload2


--[[

音声データの事前読み込み
サブディレクトリを使わないばあいは基本的にそのままでよい

@param     string  path        : 音声データのパス(URLでも可)
@param   userdata  dir         : 音声データのあるディレクトリ（プロジェクト内の場合は空でも可）
@param     string  sub_dir     : サブディレクトリ（DocumentsDirectoryかCachesDirectoryの場合でサブディレクトリを使う場合のみ）
@param      table  listener    : 読み込み完了後に呼び出すListener
@return  userdata  audiodata   : 読み込み完了したオーディオデータ

Sample Code
local load_sound = audio.loadSound( 'http://app.talkspace-web.com/side/cosmo/assets/1.mp3', system.DocumentsDirectory, 'bgm' )

]]--
local cached_audioLoadSound = audio.loadSound
function audio.loadSound( ... )
	local arg = { ... }

	local path     = arg[1]
	local dir      = arg[2]
	local sub_dir  = arg[3] or ''
	local listener = arg[4] or function() end

	if dir == nil then
		dir = system.ResourceDirectory
	end

	if system.getInfo( 'platformName' ) == 'iPhone OS' and dir == system.DocumentsDirectory then
		dir = system.CachesDirectory
	end

	if sub_dir and sub_dir ~= '' then
		sub_dir = sub_dir .. '/'

		local is_exsit = existsDirectory( sub_dir )
		if not is_exsit then
			createDirectory( sub_dir, dir )
		end	
	end

	-- サーバからの音声取得
	if startsWith( path, 'http://' ) then 
		if dir == nil then
			dir = system.TemporaryDirectory
		end
		local open_path = system.pathForFile( sub_dir ..  basename( path ), dir )
		local file = io.open( open_path, 'r' )
		if not file then
			local function cdHandler()
				local tmp_path = system.pathForFile( sub_dir ..  basename( path ), dir )
				local len = io.file_size( tmp_path )
				if len < 100 then
					deleteDocument( sub_dir .. basename( path ) )
					return audio.loadSound( arg[1], arg[2], arg[3], arg[4] )
				end
				local load_sound = cached_audioLoadSound( sub_dir ..  basename( path ), dir )
				timer.performWithDelay( 1, listener )
				return load_sound
			end
			checkDownload( path, cdHandler, sub_dir, dir )
		else
			io.close( file )
			local load_sound = cached_audioLoadSound( sub_dir ..  basename( path ), dir )
			timer.performWithDelay( 1, listener )
			return load_sound
		end
	else
		if startsWith( path, 'local://' ) then 
			-- 生成
			path = string.gsub( path, 'local://', '' )
		end
		local load_sound = cached_audioLoadSound( path, dir )
		timer.performWithDelay( 1, listener )
		return load_sound
	end
end

-- 事前読み込み？
function audio.preload( ... )

end

local cached_audioDispose = audio.dispose
function audio.dispose( audioHandle )
	if audioHandle then
		pcall( function() cached_audioDispose( audioHandle ) end )
	end
end