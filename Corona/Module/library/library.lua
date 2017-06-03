
function returnTrue()
	return true
end

local function removeTableContents( array )
	if array and #array > 0 then
		for key = 1, #array do
			local value = array[key]
			key = nil
			value = nil
		end
		array = nil
		array = {}
	end
end

function io.file_size(filename)
    local fh = io.open(filename, "rb")
    local len = fh:seek("end")
    fh:close()
    return len
end

-- ネットワークへのConnectionを確保する
local timerTable = {}
local checkNetworkTable = {}
local checkRetryTime = 100
local checkCountNum = 0
local function checkNetworkStatus( func )

	local function checkNetworkStatusListener( event )
		print( 'event.status', event.status )

		if event.isError then
			print("network error!!")
		end
		if event.status < 0 then

			--規定回数以上失敗したら
			if #timerTable >= 60 then
				_is_network_connect = true
			else
				--再度時間をおいて接続
				timer.performWithDelay( 50,
					function()
						func()
					end
				)
			end
		elseif event.status ~= 200 then

			--規定回数以上失敗したら
			if #timerTable >= 10 then
				_is_network_connect = true
			else
				--再度時間をおいて接続
				timer.performWithDelay( 500,
					function()
						func()
					end
				)
			end
		else
			--リクエスト成功
			_is_network_connect = true
			func()
		end
	end


	if _is_network_connect == false then
		local function timerEventListener( event )
		    
		    if _is_network_connect == false then
			    print( '_is_network_connect', _is_network_connect, checkRetryTime )

			    print( "checkNetworkStatus called ", checkCountNum )
			    checkCountNum = checkCountNum + 1
			    
			    if checkNetworkTable[ #checkNetworkTable ] then
				    network.cancel( checkNetworkTable[ #checkNetworkTable ] )
				end
			    if _is_network_connect or checkCountNum > 20 then
			    	timer.cancel( event.source )
			    	 print( '_is_network_connect', _is_network_connect, checkCountNum )
			    	checkCountNum = 0
			        for k = 1, #checkNetworkTable do
			        	local v = checkNetworkTable[k]
			        	network.cancel( v )
			        end
			        checkRetryTime = checkRetryTime+100
			    	if checkRetryTime > 500 then
			    		-- checkRetryTime = 500
			    		_is_network_connect = true
			    	end
			    	func()
			        removeTableContents( timerTable )
			        removeTableContents( checkNetworkTable )
			    end
			end
		end

		local timerHandler = timer.performWithDelay( checkRetryTime, timerEventListener, 0 )
		timerTable[ #timerTable + 1 ] = timerHandler

		local checkRequest = network.request( 'https://encrypted.google.com/', 'GET', checkNetworkStatusListener )
		checkNetworkTable[ #checkNetworkTable + 1 ] = checkRequest
	end
end


-- ダウンロードする関数
-- 既に持っているか、http:// or local://　かをチェックして画像を準備する
local counter = 1
function checkDownload(url, action, dir, root)

	checkRetryTime = 100
	checkCountNum = 0

	local directory = dir or system.TemporaryDirectory
	local filePath = root or ""
	if startsWith(url,"http://") then
		local path = system.pathForFile(basename(url), directory)
		local file = io.open(path, "r")
		if file then
			io.close(file)
			if action then
				action()
			end
		else

			_is_network_connect = true
			local function request()
				if _is_network_connect then

					-- print("checkDownload count = "..counter)
					-- counter = counter + 1

					local function listener(event)
						if event.isError then
						else
							if event.status ~= 200 then
								os.remove(system.pathForFile( basename(url), directory))
							end          
							if action then
								action()
							end
						end
					end
					
					local headers = {}
					headers["User-Agent"] = userAgent
					local params = {}
					params.headers = headers

					network.download(url, "GET", listener, filePath..basename(url), directory)
				else
					checkNetworkStatus( request )
				end
			end
			request()
		end
	else
		if action then
			action()
		end   
	end
end

-- 重複したURLをDLしないようにする
local tableOfCheckDownload = {}

local function addUrlEventTable( url )
	assert( url, 'ERROR : not found url!' )

	local allow = true
	for k, v in pairs( tableOfCheckDownload ) do
		if url == v then
			allow = false
		end
	end

	if allow == true then
		-- URLを追加
		table.insert( tableOfCheckDownload, url )
		return true
	else
		-- 既に追加済み
		return false
	end
end

-- URLを除去
local function removeUrlEventTable( url )
	for k, v in pairs( tableOfCheckDownload ) do
		if url == v then
			table.remove( tableOfCheckDownload, k )
		end
	end
end

-- サブディレクトリを使用する際の関数
-- checkDownloadと使い方は同じ。
-- ただし、サブディレクトリを指定する際は、"subDir"と指定すること。
function checkDownload2(url, action, subDir, dir, root)
	local directory = dir or system.DocumentsDirectory
	local filePath = root or ""
	local subDirectory = subDir or ""
	local isUrl = addUrlEventTable( url )
	local listener
	if startsWith(url, "http://") then
		local path = system.pathForFile(subDirectory .. '/' .. basename(url), directory)
		local file = io.open(path, "r")
		if file then
			io.close(file)
			if action then
				action()
			end
		elseif isUrl then
			function listener(event)
				-- print( url )
				if event.isError then
			    elseif event.phase == "began" then
        			print( "Progress Phase: began" )
			    elseif event.phase == "progress" then
        			print( json.encode( event ) )
    			elseif event.phase == "ended" then
    				print( "Progress Phase: ended" )
					removeUrlEventTable( url )
			    	if event.status ~= 200 then
			    		os.remove( system.pathForFile( subDirectory .. '/' .. basename(url), directory) )
			    	end          
			    	if action then
			    		action()
					end
				end
			end
			
			local headers = {}
			headers["User-Agent"] = userAgent
			local params = {}
			params.headers = headers
			params.progress = true
			network.download( url, "GET", listener, params, filePath..subDirectory.."/"..basename(url), directory )
		elseif not isUrl then
			timer.performWithDelay( 500, function() checkDownload2( url, action, subDir, dir, root ) end )
		end
	else
		if action then
			action()
		end   
	end
end

function getFileWithURL(url)

	local returnPath = ""
	if startsWith(url, "local://") then
		-- returnPath = abs path to

	end

	if startsWith(url,"http://") then
		-- download file
		-- save file to temp dir
		--returnPath = abs path to the saved file
		local http = require("socket.http")
		local ltn12 = require("ltn12")
		-- Create local file for saving data
		local path = system.pathForFile(basename(url), system.TemporaryDirectory )
		myFile = io.open( path, "w+b" ) 

		-- Request remote file and save data to local file
		http.request{
			url = url, 
			sink = ltn12.sink.file(myFile),
		}
		returnPath = basename(url)
		--[[
		function listener(event)
			if event.isError then
				print("download error")
			else
				print("download compleate")
			end
		end
		network.download(url, "GET", listener,basename(url), system.TemporaryDirectory)
		returnPath = basename(url)
		print("--"..returnPath)
		]]
	end

	return returnPath
end

--create button
function createButton(image_name, image_url, pushed_name, pushed_url, x, y, group, action)
	local image_name = display.newImage(image_url, x, y)
	if group then
		group:insert(image_name)
	end
	image_name:addEventListener("touch",
		function(event)
			if event.phase == "began" then
				display.remove(pushed_name)
				pushed_name = display.newImage(pushed_url, x, y)
				if group then
					group:insert(pushed_name)
				end
				timer.performWithDelay(300, function() display.remove(pushed_name) pushed_name = nil end)
			else
				display.remove(pushed_name)
				pushed_name = nil
			end
			--return true
		end
	)
	image_name:addEventListener("tap", action)
end


--create button
function createObject(image_url,image_dir, pushed_url,pushed_dir, x, y, group, pushedAction, releaseAction)
	--[[
	collectgarbage()
	print( "MemUsage: " .. collectgarbage("count") )
	local textMem = system.getInfo( "textureMemoryUsed" ) / 1000000
	print( "TexMem:   " .. textMem )
	collectgarbage('stop')
	--]]
	if image_dir == nil then
		image_dir = system.ResourceDirectory
	end

	if pushed_dir == nil then
		pushded_dir = system.ResourceDirectory
	end

	local object = display.newImage(image_url,image_dir, x, y, true)
	--print("object height = "..object.height.." width = "..object.width)



	if pcall(function() group:insert(object) end) then
	else
		display.remove(object)
		object = nil
	end

	if group then
		if group.parent then
			group:insert(object)
		else
			display.remove( object )
			object = nil

		end
	end
	local pushed_name  
	function listener(event)
		if pushed_url then
			if event.phase == "began" then
				if pushed_url then
					display.remove(pushed_name)
					pushed_name = display.newImage(pushed_url,pushed_dir,x, y)
					pushed_name.x = object.x
					pushed_name.y = object.y
					timer.performWithDelay(300, function() display.remove(pushed_name) pushed_name = nil end)
				end
				if group then
					group:insert(pushed_name)
				end        
	
				--if pushedAction then
				--  pushedAction()
				--end
			else
				if pushed_url then
					display.remove(pushed_name)
					pushed_name = nil
				end
			end
			--return true
		end
	end

	if object then
		if pushedAction then
			object:addEventListener("touch",pushedAction)
		else
			object:addEventListener("touch", listener)
		end
		
		if releaseAction then
			object:addEventListener("tap",
				function()
					if pushed_url then
						display.remove(pushed_name)
						pushed_name = nil
					end
					releaseAction()
				end
			)
		end
	end
	return object
end

--create button
function createObject2(image_url,image_dir, pushed_url,pushed_dir, x, y, width, height, group, pushedAction, releaseAction)
	--[[
	collectgarbage()
	print( "MemUsage: " .. collectgarbage("count") )
	local textMem = system.getInfo( "textureMemoryUsed" ) / 1000000
	print( "TexMem:   " .. textMem )
	collectgarbage('stop')
	--]]

	local objGroup = display.newGroup()
	if image_dir == nil then
		image_dir = system.ResourceDirectory
	end

	if pushed_dir == nil then
		pushded_dir = system.ResourceDirectory
	end

	local object = display.newImage(objGroup, image_url,image_dir, x, y, true)
	
	local pushed_name  
	function listener(event)
		if pushed_url then
			if event.phase == "began" then
				if pushed_url then
					display.remove(pushed_name)
					pushed_name = display.newImage(objGroup, pushed_url,pushed_dir,x, y)
					pushed_name.x = object.x
					pushed_name.y = object.y
					timer.performWithDelay(300, function() display.remove(pushed_name) pushed_name = nil end)
				end
			else
				if pushed_url then
					display.remove(pushed_name)
					pushed_name = nil
				end
			end
		end
	end

	local objectBg = display.newRect( objGroup, 0, 0, width, height )
	objectBg.x = object.x; objectBg.y = object.y
	objectBg:setFillColor(0)
	objectBg.isVisible = false
	objectBg.isHitTestable = true

	if pushedAction then
		objectBg:addEventListener("touch", pushedAction)
	else
		objectBg:addEventListener("touch", listener)
	end
	
	if releaseAction then
		objectBg:addEventListener("tap",
			function()
				if pushed_url then
					display.remove(pushed_name)
					pushed_name = nil
				end
				releaseAction()
			end
		)
	end

	if group then
		group:insert(objGroup)
	end
	objGroup:setReferencePoint(display.CenterReferencePoint)
	return objGroup
end


---------------------------------------------------------------------------------------------------------
function prePrepareResource(name,normalImg , pushedImg, x, y,group, pushedAcion, releaseAction)
	local pushedImgFileName
	local pushedImgDir
	local function setNormalImage ()
		if startsWith(normalImg, "local://") then
			-- returnPath = abs path to
			local normalImgFileName = string.gsub(normalImg, "local://", "")
			local normalImgDir = system.ResourceDirectory
			return createObject(normalImgFileName,normalImgDir, pushedImgFileName ,pushedImgDir, x, y, group, pushedAction, releaseAction)
			--return name
		end

		if startsWith(normalImg,"http://") then
			local normalImgFileName = basename(normalImg)
			local normalImgDir = system.TemporaryDirectory

			local path = system.pathForFile( normalImgFileName, normalImgDir )
			local file = io.open( path, "r" ) 
			if file then -- nil if no file found
				setNormalImage()
				io.close( file )
			else
				local function normalImgListener(event)
					if event.isError then
						print("error")
					else
						return createObject(normalImgFileName,normalImgDir, pushedImgFileName ,pushedImgDir, x, y, group, pushedAction, releaseAction)
						--return name
					end
				end
				local headers = {}
				headers["User-Agent"] = userAgent
				local params = {}
				params.headers = headers
				network.download(normalImg, "GET", normalImgListener,normalImgFileName, normalImgDir,params)
			end
		end
	end

	if pushedImg then
		if startsWith(pushedImg, "local://") then
			-- returnPath = abs path to
			pushedImgFileName = string.gsub(pushedImg, "local://", "")
			pushedImgDir = system.ResourceDirectory
			setNormalImage()
		end

		if startsWith(pushedImg,"http://") then 
			pushedImgFileName = basename(pushedImg)
			pushedImgDir = system.TemporaryDirectory

			local path = system.pathForFile( pushedImgFileName, pushedImgDir )
			local file = io.open( path, "r" ) 
			if file then -- nil if no file found
				setNormalImage()
				io.close( file )
			else
				local function listener(event)
					if event.isError then

					else
						print("pushed download compleate!!!")
						setNormalImage()
					end
				end
				local headers = {}
				headers["User-Agent"] = userAgent
				local params = {}
				params.headers = headers

				network.download(pushedImg, "GET", listener,pushedImgFileName, pushedImgDir,params)
			end
		end
	else
		pushedImgFileName = nil
		pushedImgDir = nil
		setNormalImage()
	end
end  


function createButton2(image_url, pushed_url, x, y, group, action)
	local fileURL = getFileWithURL(image_url)
	local fileURL2 = getFileWithURL(pushed_url)
	print(fileURL)
	print(fileURL2)
	local image
	local pushed
	if startsWith(image_url,"http://") then
		image = display.newImage(group,fileURL,system.TemporaryDirectory, x, y)
	else
		image = display.newImage(fileURL, x, y)
	end  
	--group:insert(image)
	image:addEventListener("touch",
		function(event)
			if event.phase == "began" then
				if startsWith(image_url,"http://") then
					pushed = display.newImage(group, fileURL2,system.TemporaryDirectory, x, y)
				else
					pushed = display.newImage(group, pushed_url, x, y)
				end
				timer.performWithDelay(300, function() display.remove(pushed) pushed = nil end)
			else
				display.remove(pushed)
				pushed = nil
			end
			--return true
		end
	)
	image:addEventListener("tap", action)
end


function prePrepareResource2(name,normalImg , pushedImg, x, y,group, pushedAcion, releaseAction)
	local pushedImgFileName
	local pushedImgDir
	local function setNormalImage ()
		if startsWith(normalImg, "local://") then
			-- returnPath = abs path to
			local normalImgFileName = string.gsub(normalImg, "local://", "")
			local normalImgDir = system.ResourceDirectory
			return createObject(normalImgFileName,normalImgDir, pushedImgFileName ,pushedImgDir, x, y, group, pushedAction, releaseAction)
			--return name
		end

		if startsWith(normalImg,"http://") then
			local normalImgFileName = basename(normalImg)
			local normalImgDir = system.TemporaryDirectory

			local path = system.pathForFile( normalImgFileName, normalImgDir )
			local file = io.open( path, "r" ) 
			if file then -- nil if no file found
				setNormalImage()
				io.close( file )
			else
				local function normalImgListener(event)
					if event.isError then
						print("library error")
					else
						return createObject(normalImgFileName,normalImgDir, pushedImgFileName ,pushedImgDir, x, y, group, pushedAction, releaseAction)
						--return name
					end
				end
				local headers = {}
				headers["User-Agent"] = userAgent
				local params = {}
				params.headers = headers

				network.download(normalImg, "GET", normalImgListener,normalImgFileName, normalImgDir,params)
			end
		end
	end

	if pushedImg then
		if startsWith(pushedImg, "local://") then
			-- returnPath = abs path to
			pushedImgFileName = string.gsub(pushedImg, "local://", "")
			pushedImgDir = system.ResourceDirectory
			setNormalImage()
		end

		if startsWith(pushedImg,"http://") then 
			pushedImgFileName = basename(pushedImg)
			pushedImgDir = system.TemporaryDirectory

			local path = system.pathForFile( pushedImgFileName, pushedImgDir )
			local file = io.open( path, "r" ) 
			if file then -- nil if no file found
				setNormalImage()
				io.close( file )
			else
				local function listener(event)
					if event.isError then

					else
						print("pushed download compleate!!!")
						setNormalImage()
					end
				end
				local headers = {}
				headers["User-Agent"] = userAgent
				local params = {}
				params.headers = headers

				network.download(pushedImg, "GET", listener,pushedImgFileName, pushedImgDir)
			end
		end
	else
		pushedImgFileName = nil
		pushedImgDir = nil
		setNormalImage()
	end
end  


function prePrepareResource3(name,normalImg , pushedImg, x, y,group, pushedAcion, releaseAction)

	local pushedImgFileName
	local pushedImgDir
	local function setNormalImage ()
		if startsWith(normalImg, "local://") then
			-- returnPath = abs path to
			local normalImgFileName = string.gsub(normalImg, "local://", "")
			local normalImgDir = system.ResourceDirectory
			return createObject(normalImgFileName,normalImgDir, pushedImgFileName ,pushedImgDir, x, y, group, pushedAction, releaseAction)
			--return name
		end

		if startsWith(normalImg,"http://") then
			local normalImgFileName = basename(normalImg)
			local normalImgDir = system.TemporaryDirectory
			return createObject(normalImgFileName,normalImgDir, pushedImgFileName ,pushedImgDir, x, y, group, pushedAction, releaseAction)
		end
	end

	if pushedImg then
		if startsWith(pushedImg, "local://") then
			-- returnPath = abs path to
			pushedImgFileName = string.gsub(pushedImg, "local://", "")
			pushedImgDir = system.ResourceDirectory
			setNormalImage()
		end

		if startsWith(pushedImg,"http://") then 
			pushedImgFileName = basename(pushedImg)
			pushedImgDir = system.TemporaryDirectory
			setNormalImage()
		end
	else
		pushedImgFileName = nil
		pushedImgDir = nil
		setNormalImage()
	end

end


function createButton3(imageFileName, imageDir, pushedFileName,pushedDir, x, y, group, action)  
	local image
	local pushed
	image = display.newImage(imageFileName,imageDir, x, y)
	group:insert(image)
	if pushed_url then
		image:addEventListener("touch",
			function(event)
				if event.phase == "began" then
					pushed = display.newImage(group, pushedFileName ,pushedDir, x, y)
					group:insert(pushed)
					timer.performWithDelay(500, function() display.remove(pushed) pushed = nil end)
				end
			end
		)
	end
	image:addEventListener("tap", action)
end


function downloadImage(image_url, pushed_url, x, y, group, action)  
	local function setImage()
		local image
		local pushed
		image = display.newImage(group, basename(image_url), system.TemporaryDirectory, x, y)
		if pushed_url then
			image:addEventListener("touch",
				function(event)
					if event.phase == "began" then
						pushed = display.newImage(group, basename(pushed_url), system.TemporaryDirectory , x, y)
						timer.performWithDelay(500, function() display.remove(pushed) pushed = nil end)
					end
				end
			)
		end
		image:addEventListener("tap", action)
	end

	local function listener(event)
		if event.isError then

		else
			setImage()
		end
	end
	local function listenerPushed(event)
		if event.isError then

		else
		 
		end
	end
	local headers = {}
	headers["User-Agent"] = userAgent
	local params = {}
	params.headers = headers

	network.download(image_url, "GET", listener,params,basename(image_url), system.TemporaryDirectory)
	network.download(pushed_url, "GET", listenerPushed,params,basename(pushed_url), system.TemporaryDirectory)
end

function imageDownload(imageUrl, table )
	local function listener(event)
		if event.isError then
			--downlaod error
		else

		end
	end
	local headers = {}
	headers["User-Agent"] = userAgent
	local params = {}
	params.headers = headers

	network.download(image_url, "GET", listener,params,basename(image_url), system.TemporaryDirectory)
end


--write text
function writeText(name, data, dir)
	-- print("library.lua  - - - - -  writeText - - - - - ")
	local directory = dir or system.DocumentsDirectory
	local path = system.pathForFile(name, directory)

	local file = io.open(path, "w")
	if file then
		file:write(data)
		io.close(file)
	else -- ファイルがない場合は,ファイルを作成してテキストを書き込む
		local directoryName = ""
		for k, v in string.gmatch(name, "(%w+)/") do
			directoryName = directoryName..k.."/"
			createDirectory(directoryName,directory)
		end
		--writeTextライブラリが何重にもの呼び出される恐れがあるため一回のみ行う
		file = io.open(path, "w")
		if file then
			file:write(data)
			io.close(file)
		end
	end
end

--write text
function readText(name, dir)
	local directory = dir or system.DocumentsDirectory
	local path = system.pathForFile(name, directory)
	local file = io.open(path, "r")
	if file then
		local contents = file:read("*a")
		return contents
	else
		return nil
	end
end


--黒い触れない背景みたいなやつ
--引数：x,y,width,height
function createBlackFilter(x,y,width,height,group,color)
	local object = display.newRect(x,y,width, height)
	if group then
		group:insert(object)
	end
	if color then
		object:setFillColor(color[1],color[2],color[3],color[4] or 255) --(0,240)
	else
		object:setFillColor(0,0,0,220) --(0,240)
	end
	object:addEventListener("touch", function() return true end)
	object:addEventListener("tap", function() return true end)
	return object
end

--DocumentDirectoryにあるか確認して振り分ける
function isDownlaodFile(image)
	local path = system.pathForFile(image, system.DocumentsDirectory )
	local fhd = io.open( path )
 -- io.close(fhd)

	if fhd then
		return true
	else
		return false
	end
end

-- on,offのスイッチを作る
--on:1  off:0
function createSwitch(table, x, y, switch, onAction, offAction)
	local frame = {table[1],table[2],table[3],table[4]}
	btn = movieclip.newAnim(frame)
	local width = btn.width
	local height = btn.height
	btn.x = x+width*0.5
	btn.y = y+height*0.5 
	--onの時は1
	if switch == 1 then
		btn:stopAtFrame(1)
	else
		btn:stopAtFrame(3)
	end
	btn:addEventListener("touch",
		function(event)
			if event.phase == "began" then
				if btn:currentFrame() == 3 then
					btn:stopAtFrame(4)
					timer.performWithDelay(500, function() if btn:currentFrame() == 4 then btn:stopAtFrame(3) end end)
				elseif btn:currentFrame() == 1 then
					btn:stopAtFrame(2)
					timer.performWithDelay(500, function() if btn:currentFrame() == 2 then btn:stopAtFrame(1) end end)
				end
			end       
		end
	)
	btn:addEventListener("tap",
		function()
			if btn:currentFrame() == 4 then
				if onAction then
					onAction()
				end
				btn:stopAtFrame(1)
			elseif btn:currentFrame() == 2 then
				if offAction then
					offAction()
				end
				btn:stopAtFrame(3)
			end
		end
	)
	return btn
end
-----------------------------------------


----------------------------------------------------------
-- ResouceManeger関連
----------------------------------------------------------

---------------------------------------------------
-- StopAllPlayer
-- 
-- playerTableに入っているplayerの再生を全て停止する
---------------------------------------------------
local playerTable = {}
local function stopAllPlayer()
	if playerTable then
		for k, v in pairs(playerTable) do
			v.stop()
		end
	end
	playerTable = nil
	playerTable = {}
end



--表示を始めた時間
local popupShowTime = nil

-- setAction
-- actionをつける
local function setAction(action, group, parameter)
	--背景を押せなくするアクション
	if action == "returnTrue" then
		return returnTrue
	end

	--webページを閉じる
	if action == "closeWeb" then
		local function func() 
			native.cancelWebPopup()
		end
		return func 
	end

	--すべて閉じる
	if action == "closeAll" then
		display.remove(group)
		group = nil
		native.cancelWebPopup()

		-- アプリ内通知を一時停止
		-- local notification_model = require(modelDir .. "notification_model")
		-- notification_model.stop = false
	end

	if action == "closeGroup" then
		display.remove(group)
		group = nil

		-- アプリ内通知を一時停止
		-- local notification_model = require(modelDir .. "notification_model")
		-- notification_model.stop = false		
	end

	-- クリスタル取得時
	if action == 'crystal' then
		if parameter.crystal and tonumber( parameter.crystal ) and userInfoData then
			userInfoData['item'] = tonumber( parameter.crystal )
			Runtime:dispatchEvent( { name = 'user_model-time_is_money', point = userInfoData['item'] } )
		end
	end

	-- 経験値玉（キャラのレベルを上げるのに必要）取得時
	if action == 'growth_point' then
		if parameter.growth_point and tonumber( parameter.growth_point ) and userInfoData then
			Runtime:dispatchEvent( { name = 'user_model-set_growth_point' } )
		end
	end

	-- 経験値（キャラのランクを上げるのに必要）取得時
	if action == 'exp' then
		if parameter.exp and tonumber( parameter.exp ) and userInfoData then
			Runtime:dispatchEvent( { name = 'user_model-set_exp' } )
		end
	end

	if action == "page" then
		local function func()
			display.remove(group)
			group=nil

			return true   
		end
		return func
	end

	--外部サイトに飛ばす為必要
	if action == "openScheme" then 
		system.openURL(parameter["url"])
	end  


	-- レスポンスのネイティブアラート
	if action == 'alert' then
		local function listener()
			if parameter.close then
				display.remove(group)
				group=nil  
			end
		end

		local title   = parameter.title or ''
		local message = parameter.message or ''
		local alert = native.showAlert( title, message, { 'OK' }, listener  )
	end

	----------------------------------------------------------------------------
	-- 任意のurlを叩くことが出来る
	-- 
	-- action : request
	-- parameter : {"url":"http://...", "param":["key1":"value1", "key2":"value2"], "resPopup":"num", "resUrl":"", "close":true or false}
	----------------------------------------------------------------------------

	if action == "request" then
		print(parameter)
		local function listener(event)
			print(event.response)
			hideModal()

			if parameter.close then
				display.remove(group)
				group=nil  
			end

			if parameter.endAction then
				setAction(parameter.endAction.action, group, parameter.parameter)
			end
		end

		local MultipartFormData = require(ModDir .. "network.class_MultipartFormData") 
		local multipart = MultipartFormData.new()
		
		if userInfoData.token then
			multipart:addField("token", userInfoData.token)    
		end
		if userInfoData.id then
			multipart:addField("uid", userInfoData.id)
		end
		for k, v in pairs(parameter.param) do
			multipart:addField(k,v)
		end
		local params = {}
		params.body = multipart:getBody() -- Must call getBody() first!
		local contentLength = string.len(params.body)
		local headers = multipart:getHeaders() 
		headers["Content-Length"] = contentLength
		headers["User-Agent"] = userAgent
		params.headers = headers -- Headers not valid until getBody() is called.  

		networkRequest2( parameter.url , "POST", listener,params, "L01") 
		showModal()
	end

	if action == nil then
		return nil
	end

end

---------------------------------------------------------------------------------------------------------
-- ResourceManeger
-- 
-- jsonで受け取り、それをテーブルに入れる。
-- ダウンロードが必要ならダウンロードし、表示する
-- 表示する順序は守る
--
-- 表示しうる種類は、ボタン（画像）、テキスト、　webPopup、　rect
--
-- ResorceTable[key]["resolved"]   : 準備できているか
-- ResorceTable[key]["displayed"]  : 表示しているか
local showedPopup = false
local popupID = nil

function showRemoteAds(ads_type)
	local ads = require( PluginDir .. 'ads.ads' )
	ads.show( ads_type )
end


function ResourceManeger(data, endAction)

	local ads = require(PluginDir .. 'ads.ads')

	print("ResorceManeger")
	local json = require("json")
	local group = display.newGroup()
	-- _G["stampPopup"] = group
	group.alpha = 0
	local data = json.decode(data)
	local function removeAll() 
		display.remove(group)
		group = nil
		native.cancelWebPopup()

		ads.display()
	end


	if #data > 0 then
		local ResorceTable = {} -- データを入れるテーブル
		for key, value in pairs(data) do

			-- 一つ一つの要素のテーブルを作る
			ResorceTable[key] = {}

			ResorceTable[key]["resolved"]="NO"
			ResorceTable[key]["displayed"]="NO"

			--リソースの準備
			if value.type == "image" then
				local count = 0
				local function action()
					count = count + 1
					if value.pushedImage then
						if count == 2 then
							ResorceTable[key]["resolved"] = "YES"
						end
					else
						ResorceTable[key]["resolved"] = "YES"
					end            
				end 
			
				checkDownload(value.normalImage, function() 
						local path = system.pathForFile(basename(value.normalImage), system.TemporaryDirectory)
						local file = io.open(path, "r")
						if file then
							io.close(file)
							action()
						end
				end)
				

				if value.pushedImage then
					checkDownload(value.pushedImage, function()
						local path = system.pathForFile(basename(value.pushedImage), system.TemporaryDirectory)
						local file = io.open(path, "r")
						if file then
							io.close(file)
							action()
						end
					end)
				end
				ResorceTable[key]["name"] = value.name
				ResorceTable[key]["type"] = value.type
				ResorceTable[key]["normalImage"] = value.normalImage or nil
				ResorceTable[key]["pushedImage"] = value.pushedImage or nil
				ResorceTable[key]["x"] = value.x or 0
				ResorceTable[key]["y"] = value.y or 0
				ResorceTable[key]["releaseAction"] = value.releaseAction or nil
				ResorceTable[key]["actionParameter"] = value.actionParameter or nil

			--文字の場合  
			elseif value.type == "text" then
				ResorceTable[key]["name"] = value.name
				ResorceTable[key]["type"] = value.type
				ResorceTable[key]["str"] = value.str or ""
				ResorceTable[key]["x"] = value.x or 0
				ResorceTable[key]["y"] = value.y or 0
				ResorceTable[key]["family"] = value.family or nil
				ResorceTable[key]["size"] = value.size or 24
				ResorceTable[key]["r"] = value.r or 0
				ResorceTable[key]["g"] = value.g or 0
				ResorceTable[key]["b"] = value.b or 0

				ResorceTable[key]["resolved"] = "YES"

			--ウェブポップアップの場合
			elseif value.type == "web" then
				ResorceTable[key]["name"] = value.name
				ResorceTable[key]["type"] = value.type
				ResorceTable[key]["x"] = value.x or 0
				ResorceTable[key]["y"] = value.y or 0
				ResorceTable[key]["width"] = value.width or display.contentWidth
				ResorceTable[key]["height"] = value.height or display.contenHeight
				ResorceTable[key]["url"] = value.url

				ResorceTable[key]["resolved"] = "YES"
			
			
			--ウェブポップアップの場合
			elseif value.type == "url" then
				ResorceTable[key]["type"] = value.type
				ResorceTable[key]["url"] = value.url 
				ResorceTable[key]["method"] = value.method -- POST or GET
				ResorceTable[key]["params"] = value.params -- {[key, value], [key, value], [key, value]}
				ResorceTable[key]["startAction"] = value.startAction -- table {action, action, action}
				ResorceTable[key]["endAction"] = value.endAction -- table {action, action, action}

				ResorceTable[key]["resolved"] = "YES"


			elseif value.type == "action" then
				ResorceTable[key]["type"] = value.type
				ResorceTable[key]["action"] = value.action
				ResorceTable[key]["params"] = value.params -- {[key, value], [key, value], [key, value]}

				ResorceTable[key]["resolved"] = "YES"

			--四角形の場合
			elseif value.type == "rect" then
				ResorceTable[key]["name"] = value.name
				ResorceTable[key]["type"] = value.type
				ResorceTable[key]["x"] = value.x or 0
				ResorceTable[key]["y"] = value.y or 0
				ResorceTable[key]["width"] = value.width or 100
				ResorceTable[key]["height"] = value.height or 100
				ResorceTable[key]["r"] = value.r or 255
				ResorceTable[key]["g"] = value.g or 255
				ResorceTable[key]["b"] = value.b or 255
				ResorceTable[key]["releaseAction"] = value.releaseAction or nil
				ResorceTable[key]["pushedAction"] = value.pushedAction or nil
				ResorceTable[key]["alpha"] = value.alpha or 255

				ResorceTable[key]["resolved"] = "YES"
			
			--四角形の場合
			elseif value.type == "userimage" then
				ResorceTable[key]["name"] = value.name
				ResorceTable[key]["type"] = value.type
				ResorceTable[key]["x"] = value.x or 0
				ResorceTable[key]["y"] = value.y or 0
				ResorceTable[key]["scale"] = value.scale or 1
				ResorceTable[key]["notBackground"] = value.notBackground or nil
				ResorceTable[key]["url"] =value.url

				ResorceTable[key]["resolved"] = "YES"			

			
			elseif value.type == "player" then
				-- plyerの設置
				-- 音声を再生する為のオブジェクト
				ResorceTable[key]["resolved"] = "NO"
				-- 画像の準備
				local count = 0
				local function action()
					count = count + 1
					if count == 2 then
						ResorceTable[key]["resolved"] = "YES"
					end    
				end 
			
				-- print(value.playImage)
				-- print(value.stopImage)
				checkDownload(value.playImage, function() 
						local path = system.pathForFile(basename(value.playImage), system.TemporaryDirectory)
						local file = io.open(path, "r")
						if file then
							io.close(file)
							action()
						end
				end)

				checkDownload(value.stopImage, function() 
						local path = system.pathForFile(basename(value.stopImage), system.TemporaryDirectory)
						local file = io.open(path, "r")
						if file then
							io.close(file)
							action()
						end
				end)

				ResorceTable[key]["name"] = value.name
				ResorceTable[key]["type"] = value.type
				ResorceTable[key]["playImage"] = value.playImage or nil
				ResorceTable[key]["stopImage"] = value.stopImage or nil
				ResorceTable[key]["x"] = value.x or 0
				ResorceTable[key]["y"] = value.y or 0
				ResorceTable[key]["duration"] = value.duration or 3
				ResorceTable[key]["durationColor"] = value.durationColor or {255,255,255}
				ResorceTable[key]["durationFont"] = value.durationFont or nil
				ResorceTable[key]["durationFontSize"] = value.durationFontSize or 24
				ResorceTable[key]["durationX"] = value.durationX or 0
				ResorceTable[key]["durationY"] = value.durationY or 0
				ResorceTable[key]["audioUrl"] = value.audioUrl or nil

			elseif value.type == "avatar" then
				
				ResorceTable[key]["resolved"] = "YES"
				cleanDirectory( 'avatar' )

			
			--[[
			@	ポップアップからアバターを表示
			@	php側での設定方法	
			@	$avatar1 = array(
			@		"name"=>"useravatar",
			@		"type"=>"useravatar",
			@		"x"=>240,
			@		"y"=>$image_y+520,
			@		"uid"=>5755,
			@		"scale"=>0.15,
			@	);
			]]--
			elseif value.type == "useravatar" then
				ResorceTable[key]["name"] = value.name
				ResorceTable[key]["type"] = value.type
				ResorceTable[key]["x"] = value.x or 0
				ResorceTable[key]["y"] = value.y or 0
				ResorceTable[key]["scale"] = value.scale or 0.5
				ResorceTable[key]["uid"] = value.uid or nil
				ResorceTable[key]["url"] = value.url or nil

				ResorceTable[key]["resolved"] = "YES"

				print(ResorceTable[key])	

			elseif value.type == "ads" then
				ResorceTable[key]["name"] = value.name
				ResorceTable[key]["type"] = value.type
				ResorceTable[key]["x"] = value.x or 0
				ResorceTable[key]["y"] = value.y or 0
				ResorceTable[key]["width"] = value.width or _W
				ResorceTable[key]["height"] = value.height or 100
				ResorceTable[key]["url"] = value.url

				ResorceTable[key]["resolved"] = "YES"

			elseif value.type == "id" then
				popupID = value.id
				ResorceTable[key]["resolved"] = "YES"
				
			end
		end

		-- 描画する
		-- 一つ目から順番に行い、全部終わったら終了

		local num = 1 
		local function enterFrame()
			if #data >= num then
				-- print(ResorceTable[num]["type"], ResorceTable[num]["resolved"])
				--表示していなければ、表示する
				if ResorceTable[num]["displayed"] == "NO" and ResorceTable[num]["resolved"] == "YES" then

					if ResorceTable[num]["type"] == "id" then

					--画像の場合
					elseif ResorceTable[num]["type"] == "image" then
						--print(ResorceTable[num]["normalImage"]..ResorceTable[num]["pushedImage"]..ResorceTable[num]["x"]..ResorceTable[num]["y"])
						local image
						if ResorceTable[num]["releaseAction"] == "close" then
							image = prePrepareResource3("image",ResorceTable[num]["normalImage"], ResorceTable[num]["pushedImage"], ResorceTable[num]["x"], ResorceTable[num]["y"], group,ResorceTable[num]["pushedAcion"], removeAll)
						else
							local releaseAction =  ResorceTable[num]["releaseAction"]  

							image = prePrepareResource3("image",ResorceTable[num]["normalImage"], ResorceTable[num]["pushedImage"], ResorceTable[num]["x"], ResorceTable[num]["y"], group,ResorceTable[num]["pushedAcion"],
								function()
									if releaseAction then
										for k, v in pairs(releaseAction) do
											print(v.action, v.parameter)
											setAction(v.action, group, v.parameter)
										end           
									end
									--setAction(ResorceTable[num]["releaseAction"],group,  ResorceTable[num]["actionParameter"])
								end
							)
						end            
						
					--playerの場合
					elseif ResorceTable[num]["type"] == "player" then
						---- 再生アイコン 
						local playIcon = btn.newPushImage({image=basename(ResorceTable[num]["playImage"]), dir=system.TemporaryDirectory})
						local stopIcon = btn.newPushImage({image=basename(ResorceTable[num]["stopImage"]), dir=system.TemporaryDirectory})
						playIcon.x, playIcon.y = ResorceTable[num]["x"], ResorceTable[num]["y"]
						stopIcon.x, stopIcon.y = playIcon.x, playIcon.y
						
						group:insert(playIcon)
						group:insert(stopIcon)

						stopIcon.isVisible = false

						-- 再生秒数
						local countdownTimer,stopCountDown, countDown
						local duration = ResorceTable[num]["duration"]
						local orgDuration = ResorceTable[num]["duration"]
						
						local sec = display.newText(group, duration, ResorceTable[num]["durationX"], ResorceTable[num]["durationY"], ResorceTable[num]["durationFont"], ResorceTable[num]["durationFontSize"])
						sec:setFillColor( ResorceTable[num]["durationColor"][1] , ResorceTable[num]["durationColor"][2], ResorceTable[num]["durationColor"][3])
						sec.text = duration

						local function stopEvent()
							playIcon.isVisible = true
							stopIcon.isVisible = false
							stopCountDown()
						end

						local function startEvent()
							playIcon.isVisible = false
							stopIcon.isVisible = true
							countDown()
						end

						function stopCountDown()
							if countdownTimer then
								timer.cancel( countdownTimer )
							end
							sec.text = orgDuration
							duration = orgDuration
						end		

						function countDown()
							if duration >= 0 then
								countdownTimer = timer.performWithDelay( 1000, 
									function()
										duration = duration - 1
										sec.text = duration
									end
								, 0)
							else
								stopCountDown()
							end
						end
				

						-- 音声再生機能
						local player = {}
						player.downloaded = false 

						tsaudio.checkAudioDownloadStatus = true

						tsaudio.preparePlayerWithURL(ResorceTable[num]["audioUrl"], function (event)
							if event.phase == "downloaded" then			
								-- プレイヤーをイベントから取り出し、再生
								player.play = event.player.play
								player.stop = event.player.stop
								player.downloaded = true
							end							
							if event.phase == "finished" then
								stopEvent()
							end				
							if event.phase == "started" then
								tslisten.isset({pattern='popup'})
								table.insert(playerTable, player)
								startEvent()
							end

							if event.phase == "erroroccurred" then
								stopEvent()
							end
						end)						

						playIcon:addEventListener( "tap", 
							function() 
								if player.play then 
									stopAllPlayer()
									player.play() 
								end 
							end
						)
						stopIcon:addEventListener( "tap", 
							function() 
								if player.stop then 
									stopAllPlayer()
									player.stop() 
								end 
							end
						)


					--テキストの場合
					elseif ResorceTable[num]["type"] == "text" then
						print("create text"..ResorceTable[num]["str"]..ResorceTable[num]["x"]..ResorceTable[num]["y"]..ResorceTable[num]["size"])
						local text = display.newText(group, ResorceTable[num]["str"],ResorceTable[num]["x"], ResorceTable[num]["y"],ResorceTable[num]["family"],ResorceTable[num]["size"])
						text:setFillColor(ResorceTable[num]["r"], ResorceTable[num]["g"], ResorceTable[num]["b"])

					--rectの場合  
					elseif ResorceTable[num]["type"] == "rect" then
						
						local rect = display.newRect(ResorceTable[num]["x"],ResorceTable[num]["y"],ResorceTable[num]["width"], ResorceTable[num]["height"])
						rect:addEventListener("touch",function() return true end)
						rect:addEventListener("tap",function() return true end)
					
						if group and group.parent then
							group:insert(rect)
						else
							display.remove( rect )
						end

						if ResorceTable[num]["releaseAction"] == "close" then
							local rect = display.newRect(ResorceTable[num]["x"],ResorceTable[num]["y"],ResorceTable[num]["width"], ResorceTable[num]["height"])
							rect:addEventListener("tap", removeAll)
							group:insert(rect)
						elseif  ResorceTable[num]["releaseAction"] ~= nil then
							
							local releaseAction =  ResorceTable[num]["releaseAction"]
							rect:addEventListener("tap", 
								function()
									if releaseAction then
										for k, v in pairs(releaseAction) do
											setAction(v.action, group, v.parameter)
										end           
									end
								end
							)
						end
						rect:setFillColor(ResorceTable[num]["r"], ResorceTable[num]["g"], ResorceTable[num]["b"],ResorceTable[num]["alpha"])


					--ユーザー画像の場合
					elseif ResorceTable[num]["type"] == "userimage" then
						local userimage = require(libDir.."userimage")
						local uimage = userimage.newCircle({image_url = ResorceTable[num]["url"], notBackground=ResorceTable[num]["notBackground"]})
						uimage.x = ResorceTable[num]["x"]; uimage.y = ResorceTable[num]["y"];
						if ResorceTable[num]["scale"] then
							uimage:scale(ResorceTable[num]["scale"], ResorceTable[num]["scale"])
						end
						if group and group.parent then
							group:insert(uimage)
						else
							display.remove( uimage )
						end

					elseif ResorceTable[num]["type"] == "useravatar" then
						local avatar = require( contDir .. 'avatar' )
						local avatarClass = avatar.new()

						avatarClass.scale = ResorceTable[num]["scale"]
						avatarClass.x, avatarClass.y = ResorceTable[num]["x"], ResorceTable[num]["y"]
						avatarClass.create( { uid = ResorceTable[num]["uid"], url = ResorceTable[num]["url"] } )

						local createdAvatar
						local function avatarEventHandler( event )
						    if event.name == 'avatar_view-create-finish' and group and group.parent then
						        local flag, ret = pcall( createdAvatar, event )
						        if not flag then
						            print( 'profile_view.lua : Error avatarEventHandler' )
						            -- エラー処理
						            display.remove( event.group )
						            event.group = nil
						        end
						    else
						        avatarClass.view.destory( event.group )
						        event.group = nil
						    end
						end
						avatarClass:addEventListener( avatarEventHandler )

						function createdAvatar( event )
						    group:insert( event.group )
						    avatarClass:removeEventListener( avatarEventHandler )
						end


					--webの場合  
					elseif ResorceTable[num]["type"] == "web" then
						native.showWebPopup(ResorceTable[num]["x"], ResorceTable[num]["y"], ResorceTable[num]["width"],ResorceTable[num]["height"],ResorceTable[num]["url"])

					--actionの場合  
					elseif ResorceTable[num]["type"] == "action" then
						
						local action = setAction(ResorceTable[num]["action"], group, ResorceTable[num]["parameter"])
						action()

					-- urlを叩かせる場合
					elseif ResorceTable[num]["type"] == "url" then
						
						local endAction = ResorceTable[num]["endAction"] or nil
						local startAction = ResorceTable[num]["startAction"] or nil

						local function listener(event)
							print("ResourceManeger: type:url event.response = ".. event.response)
							if endAction then
								if endAction == "close" then
									removeAll()
								else
									endAction()
								end
							end
						end

						local multipart = MultipartFormData.new()
						
						-- postするパラメータ
						for k, v in pairs (ResorceTable[num]["params"]) do 
							multipart:addField(v.key,v.value)
						end
						if userInfoData.token then
							multipart:addField("token",userInfoData.token)
						end
						if userInfoData.id then
							multipart:addField("uid",userInfoData.id)
						end
						multipart:addField("language",_isLanguage)
						local params = {}
						params.body = multipart:getBody() -- Must call getBody() first!
						local contentLength = string.len(params.body)
						local headers = multipart:getHeaders() 
						headers["Content-Length"] = contentLength
						headers["User-Agent"] = userAgent
						params.headers = headers -- Headers not valid until getBody() is called.  

						networkRequest2(ResorceTable[num]["url"], ResorceTable[num]["method"], listener, params)
						if startAction then
							startAction()
						end
					end 

					ResorceTable[num]["displayed"] = "YES"
					num = num + 1
				end
			else
				group.isVisible = true
				Runtime:removeEventListener("enterFrame", enterFrame)
				
				-- 解析
				popupShowTime = os.time()
				-- tsanalysis.event({name="E001", status1=_deviceID})
				
				ads.hide()

				transition.to(group, {time=100, alpha = 1})
				group.x = 0
				group:setReferencePoint( display.CenterReferencePoint )
				group:scale( 0.2,0.2 )
				transition.to( group, { time = 300, xScale = 1, yScale = 1, transition=easing.outBack } )
				if endAction then
					endAction()
				end
			end
			--
		end
		group.isVisible = false
		Runtime:addEventListener("enterFrame", enterFrame)
	end
	return group
end
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

---　読み込み中の画像
local loadingGroup
local loadingAction
local loadingTimer
function loadingModal(x, y, group, x1,y1, width, height, filter,touchFoucs)
	display.remove(loadingGroup)

	-- print("読み込み中.....................................................")

	loadingGroup = display.newGroup()

	--触れられないようにするため
	--読み込み中背景
	loadingBackground = display.newRect(loadingGroup, x1-x+150,y1-y+50,width,height)
	loadingBackground:setFillColor(0,1)
	if touchFoucs ~= 1 then
			loadingBackground:addEventListener("touch" , function() return true  end)
			loadingBackground:addEventListener("tap" , function() return true  end)
	end

	if filter == true then
		loadingBackground:setFillColor( 0,180 )
	end
	

	local scale = 100
	local popup = display.newRoundedRect(loadingGroup, 0, 0, 352*scale, 253*scale, 4*scale)
	popup:scale(1/scale, 1/scale)
	popup.x, popup.y = loadingBackground.x, loadingBackground.y
	popup.alpha = 0.93
	loadingGroup:insert(popup)

	scale = nil

	local text = display.newText(loadingGroup, translations.get("Loading"), 0, 0, nil, 31)
	text:setFillColor(55)
	text.x, text.y = loadingBackground.x, loadingBackground.y + 70

	local loading = display.newImage( loadingGroup ,imageDir.."accountEdit/loadingIcon.png")
	loading:scale( 0.76, 0.76)
	loading.x, loading.y = popup.x, popup.y - 32

	transition.to(loading, {time=1000*100, rotation=180*100})


	loadingGroup.x = x-150
	loadingGroup.y = y-50
	
	if group then
		group:insert(loadingGroup)
	end  
	return loadingGroup
end


-- 臨機応変に対応
function loadingModal1(option)

	local x = option.x
	local y = option.y
	local width  = option.width
	local height = option.height

	display.remove(loadingGroup)
	loadingGroup = display.newGroup()

	--触れられないようにするため
	--読み込み中背景
	loadingBackground = display.newRect(loadingGroup, 0, 0, width, height)
	loadingBackground:setFillColor(0,1)
	if option.touchFoucs ~= 1 then
			loadingBackground:addEventListener("touch" , function() return true  end)
			loadingBackground:addEventListener("tap" , function() return true  end)
	end

	if option.filter == true then
		loadingBackground:setFillColor( 0,180 )
	end
	

	local scale = 100
	local popup = display.newRoundedRect(loadingGroup, 0, 0, 352*scale, 253*scale, 4*scale)
	popup:scale(1/scale, 1/scale)
	popup.x, popup.y = x or loadingBackground.x, y or loadingBackground.y
	popup.alpha = 0.93
	loadingGroup:insert(popup)

	scale = nil

	local text = display.newText(loadingGroup, translations.get("Loading"), 0, 0, nil, 31)
	text:setFillColor(55)
	text.x, text.y = popup.x, popup.y + 70

	local loading = display.newImage( loadingGroup ,imageDir.."accountEdit/loadingIcon.png")
	loading:scale( 0.76, 0.76)
	loading.x, loading.y = popup.x, popup.y - 32

	transition.to(loading, {time=1000*100, rotation=180*100})
	
	if option.group then
		option.group:insert(loadingGroup)
	end  

 --return group
end



function loadingModal2(option)
	-------------------------
	-- option.x
	-- option.y
	-- option.width
	-- option.height
	-- option.group
	-------------------------
	display.remove(loadingGroup)

	loadingGroup = display.newGroup()

	local X = option.x or _W*0.5
	local Y = option.y or _H*0.5


	--触れられないようにするため
	--読み込み中背景
	if option.width and option.height then
			loadingBackground = display.newRect(loadingGroup, 0, 0,option.width, option.height)
			loadingBackground:setFillColor(0,1)
			loadingBackground:addEventListener("touch" , function() return true  end)
			loadingBackground:addEventListener("tap" , function() return true  end)
			loadingBackground.x, loadingBackground.y = X, Y
	end

	backImage = display.newImage(loadingGroup, imageDir.."image/loadingBg.png", 0,0)
	backImage.x, backImage.y = X, Y

	local dot1 = display.newImage(loadingGroup, imageDir.."image/loadingDot.png", 0, 0)
	local dot2 = display.newImage(loadingGroup, imageDir.."image/loadingDot.png", 0, 0)
	local dot3 = display.newImage(loadingGroup, imageDir.."image/loadingDot2.png", 0, 0)

	dot1.x = backImage.x-34; dot1.y = backImage.y+5
	dot2.x = backImage.x; dot2.y = backImage.y+5
	dot3.x = backImage.x+46; dot3.y = backImage.y - 12

	local function set(num)
		if num == 1 then
			dot1.alpha = 0
			dot2.alpha = 0
			dot3.alpha = 0
		end
		if num == 2 then
			dot2.alpha = 0
			dot3.alpha = 0
			transition.to(dot1, {time=100, alpha =1})
		end
		if num == 3 then
			transition.to(dot2, {time=100, alpha =1})
		end
		if num == 4 then
			transition.to(dot3, {time=100, alpha =1})
		end
	end
	set(1)

	local timer1, timer2, timer3, timer4  
	function timer1()
		local timerA = timer.performWithDelay(500, function() set(2) timer2() end)
	end
	function timer2()
		local timerB = timer.performWithDelay(500, function() set(3) timer3() end)
	end
	function timer3()
		local timerC = timer.performWithDelay(500, function() set(4) timer1() end)
	end

	timer1()
	if option.group then
		option.group:insert(loadingGroup)
	end
end




--読み込み中画像を消す
function removeLoadingModal()
	if loadingGroup then
		if loadingGroup.parent then
			if pcall(
				function ()
					display.remove(loadingGroup)
					loadingGroup = nil
				end)
			then
				
			end
		end
	end
	if loadingAction then
		transition.cancel(loadingAction)
		loadingAction = nil
	end
	
end
------------------------------------------

-- ====================文字列の長さ　日本語対応===============================
function utf8charbytes (s, i)
	 -- argument defaults
	 i = i or 1
	 local c = string.byte(s, i)
	 
	 -- determine bytes needed for character, based on RFC 3629
	 if c > 0 and c <= 127 then
			-- UTF8-1
			return 1
	 elseif c >= 194 and c <= 223 then
			-- UTF8-2
			local c2 = string.byte(s, i + 1)
			return 2
	 elseif c >= 224 and c <= 239 then
			-- UTF8-3
			local c2 = s:byte(i + 1)
			local c3 = s:byte(i + 2)
			return 3
	 elseif c >= 240 and c <= 244 then
			-- UTF8-4
			local c2 = s:byte(i + 1)
			local c3 = s:byte(i + 2)
			local c4 = s:byte(i + 3)
			return 4
	 end
end
 
-- returns the number of characters in a UTF-8 string
function utf8len (s)
	 local pos = 1
	 local bytes = string.len(s)
	 local len = 0
	 
	 while pos <= bytes and len ~= chars do
			local c = string.byte(s,pos)
			len = len + 1
			
			pos = pos + utf8charbytes(s, pos)
	 end
	 
	 if chars ~= nil then
			return pos - 1
	 end
	 
	 return len
end


--時間の表示を〇〇分前等にかえる
function diffTime(dateTime)
	dateTime = string.gsub(dateTime, " ", "-")
	dateTime = string.gsub(dateTime, ":", "-")
	function split(str, d)
		local s = str
		local t = {}
		local p = "%s*(.-)%s*"..d.."%s*"
		local f = function(v)
			table.insert(t, v)
		end
		if s ~= nil then
			string.gsub(s, p, f)
			f(string.gsub(s, p, ""))
		end
		return t
	end
	
	dateTime = split(dateTime, "-")
	local returnTime = nil
	local Year, Month, Day, Hour, Minute, Second= dateTime[1],dateTime[2],dateTime[3],dateTime[4],dateTime[5],dateTime[6]
	local t1 = os.time({year=Year, month=Month, day=Day, hour=Hour, min=Minute, sec=Second})
	local date = os.date( '*t' )
	local t2 = os.time({year=date.year, month=date.month, day=date.day, hour=date.hour, min=date.min, sec=date.sec})
	local now=os.difftime( t2, t1 )
	local niti = math.floor(now/86400)
	local jikan = math.floor(now/3600)
	local hun = math.floor(now/60)
	local byou = math.floor(now)

	if byou<60 then
		returnTime = "数秒前"
	elseif hun<60 then
		returnTime = hun.."分前"
	elseif jikan<24 then
		returnTime = jikan.."時間前"
	elseif 10<niti then
		returnTime = Month.."."..Day
	elseif niti>=1 then 
		returnTime =  niti.."日前"
	end
	return returnTime
end

--時間の表示を〇〇分前等にかえる
function diffTime2(dateTime)
	dateTime = string.gsub(dateTime, " ", "-")
	dateTime = string.gsub(dateTime, ":", "-")
	function split(str, d)
		local s = str
		local t = {}
		local p = "%s*(.-)%s*"..d.."%s*"
		local f = function(v)
			table.insert(t, v)
		end
		if s ~= nil then
			string.gsub(s, p, f)
			f(string.gsub(s, p, ""))
		end
		return t
	end
	
	dateTime = split(dateTime, "-")
	local returnTime = nil
	local Year, Month, Day, Hour, Minute, Second= dateTime[1],dateTime[2],dateTime[3],dateTime[4],dateTime[5],dateTime[6]
	local t1 = os.time({year=Year, month=Month, day=Day, hour=Hour, min=Minute, sec=Second})
	local date = os.date( '*t' )
	local t2 = os.time({year=date.year, month=date.month, day=date.day, hour=date.hour, min=date.min, sec=date.sec})
	local now=os.difftime( t2, t1 )
	local niti = math.floor(now/86400)
	local jikan = math.floor(now/3600)
	local hun = math.floor(now/60)
	local byou = math.floor(now)

	if byou<60 then
		returnTime = Hour ..":".. Minute
	elseif hun<60 then
		returnTime = Hour ..":".. Minute
	elseif jikan<24 then
		returnTime = Hour ..":".. Minute
	elseif 10<niti then
		returnTime = Hour ..":".. Minute
	elseif niti>=1 then 
		returnTime =  Hour ..":".. Minute
	end
	return returnTime
end

--時間の表示を〇〇分前等にかえる
function diffTime3(dateTime)
	dateTime = string.gsub(dateTime, " ", "-")
	dateTime = string.gsub(dateTime, ":", "-")
	function split(str, d)
		local s = str
		local t = {}
		local p = "%s*(.-)%s*"..d.."%s*"
		local f = function(v)
			table.insert(t, v)
		end
		if s ~= nil then
			string.gsub(s, p, f)
			f(string.gsub(s, p, ""))
		end
		return t
	end	
	dateTime = split(dateTime, "-")

	local Year, Month, Day, Hour, Minute, Second= dateTime[1],dateTime[2],dateTime[3],dateTime[4],dateTime[5],dateTime[6]
	local returnTime = Month .. "/" .. Day
	return returnTime
end

--曜日を返す
function dayOfWeek()
	local wday = os.date("*t").wday
	local wdayText
	if wday == 1 then
		wdayText = "日"
	elseif wday == 2 then
		wdayText = "月"
	elseif wday == 3 then
		wdayText = "火"
	elseif wday == 4 then
		wdayText = "水"
	elseif wday == 5 then
		wdayText = "木"
	elseif wday == 6 then
		wdayText = "金"
	elseif wday == 7 then
		wdayText = "土"
	end

	return wdayText
end

function getDayOfWeek(dateTime) 
	dateTime = string.gsub(dateTime, " ", "-")
	dateTime = string.gsub(dateTime, ":", "-")
	function split(str, d)
		local s = str
		local t = {}
		local p = "%s*(.-)%s*"..d.."%s*"
		local f = function(v)
			table.insert(t, v)
		end
		if s ~= nil then
			string.gsub(s, p, f)
			f(string.gsub(s, p, ""))
		end
		return t
	end	
	dateTime = split(dateTime, "-")

	local yy, mm, dd = dateTime[1],dateTime[2],dateTime[3]

	dw=os.date('*t',os.time{year=yy,month=mm,day=dd})['wday']
	return ({ "日", "月", "火", "水", "木", "金", "土" })[dw]

end


-- yy-mm-dd h:i:s → os.time
function getOsTime(dateTime)
	dateTime = string.gsub(dateTime, " ", "-")
	dateTime = string.gsub(dateTime, ":", "-")
	function split(str, d)
		local s = str
		local t = {}
		local p = "%s*(.-)%s*"..d.."%s*"
		local f = function(v)
			table.insert(t, v)
		end
		if s ~= nil then
			string.gsub(s, p, f)
			f(string.gsub(s, p, ""))
		end
		return t
	end
	
	dateTime = split(dateTime, "-")
	local returnTime = nil
	local Year, Month, Day, Hour, Minute, Second= dateTime[1],dateTime[2],dateTime[3],dateTime[4],dateTime[5],dateTime[6]
	local t1 = os.time({year=Year, month=Month, day=Day, hour=Hour, min=Minute, sec=Second})

	return t1
end


-- 秒数を◯◯：○○形式に変換
function changeSeconds( duration )
	local duration = duration
	local minutes = math.floor((duration / 60) % 60)
	local seconds = math.floor( duration % 60 )
	if seconds*0.1 < 1 then
		seconds = '0' .. seconds
	end
	local hms = minutes .. ':' .. seconds
	return hms
end


------------------------------------
-- 特定の文字がいくつ含まれるかを返す関数
------------------------------------
function countSpecificCharacterInString(str, chara)
	assert(str, "Not Found str!")
	assert(chara, "Not Found chara!")

	local num = 0
	local nextNum = 1
	local count = 0 
	while nextNum ~= nil and count < 100 do
		count = count + 1 
		local ms, me = str:find(chara, nextNum)
		if ms ~= nil then
			num = num + 1
			nextNum = me + 1
		else
			nextNum = nil
		end
	end
	
	return num 
end




--文字列の改行したときに必要な高さを返す
function getTextHeight(W, text,family, size)
	print(text, family, size)
	local obj = display.newText(text, 0,0, family, size)
	obj.y = _H/2
	local width = obj.width
	local height = obj.height
	local line 

	if width%W == 0 then
		line = math.floor(width/W)
	else
		line = math.floor(width/W)+1
	end
	print("row", countSpecificCharacterInString(text, "\n"))
	line = line + countSpecificCharacterInString(text, "\n")

	display.remove(obj)
	return (height+size*0.2)*line
end

-------------------------------------------
-- textTruncate
--　
-- 文字、置き換える文字、文章の幅、サイズ、書体を書くと幅に合わした文字列を返してくれる
-- local text = display.newText(textTruncate(str, "...", 470, 38, native.systemFont), 100,100, native.systemFont, 38)
-- 文字（１行）が指定の幅を超えたら特定の文字に置き換える
function textTruncate(str, replaceText, width, size, family)
	str = string.gsub(str,"\n","") 
	local text = display.newText(str,0,0,family,size)
	local length = text.width
	display.remove(text)
	text = nil

	if width <= length then
		--仮に１００で
		local str2, returnStr, strNum
		local count = 1

		for i=1, 600 do
			local wordByte = string.byte(str,count)
			--[[if 0 <= wordByte and wordByte <= 127 then
				strNum = 1
			elseif 128 <= wordByte and wordByte <= 159 then
				strNum = 3
			else
				strNum = 1
			end]]
			if wordByte > 223 then
				count = count + 2
			end
			str2 = string.sub(str,1,count)
			str2 = str2 .. replaceText
			local text3 = display.newText(str2, 0,0,family, size)
			if text3.width <= width then
				display.remove(text3)
				text3=nil
				returnStr = str2
			else
				display.remove(text3)
				text3=nil
				return returnStr
			end
			count = count+1
		end
	else
		--print("textTrimcate:length = "..length.." width="..width)
		return str
	end
end


--------------------------------------------
-- 遠隔操作用のpopup

function showRemotePopup(url)

	local function networkListener(event)
		ResourceManeger(event.response)
	end

	local MultipartFormData = require(ModDir .. "network.class_MultipartFormData") 
	local multipart = MultipartFormData.new()

	-- postするパラメータ
	-- postするパラメータ
	multipart:addField("token",userInfoData.token)
	multipart:addField("uid",userInfoData.id)
	-- multipart:addField("language",)
	multipart:addField("width",_W)
	multipart:addField("height",_H)
	multipart:addField("platform",system.getInfo("platformName"))

	local params = {}
	params.body = multipart:getBody() -- Must call getBody() first!
	local contentLength = string.len(params.body)
	local headers = multipart:getHeaders() 
	headers["Content-Length"] = contentLength
	headers["User-Agent"] = userAgent
	params.headers = headers -- Headers not valid until getBody() is called.  

	networkRequest2( url, "POST", networkListener, params)

end





--------------------------------------------
-- ネットワークエラーがあります！！
local timerTable = {}
local function allTimerCanceler()
		local k, v
		for k,v in pairs(timerTable) do
				timer.cancel( v )
				v = nil; k = nil
		end
		timerTable = nil
		timerTable = {}
end

--ネットワーク接続
_is_network_connect = false
local connectErrorNum = 0
local networkTable = {}
local timeTable = {6000, 6000, 6000, 6000, 6000, 6000, 6000, 6000, 6000, 6000}
function networkRequest2(url, method, listener, params, errorCode)
	assert(listener, "Error: Not found Listener ")

	checkRetryTime = 100
	checkCountNum = 0
	
	--前方宣言
	local subListener, request, timeoutFunction

	networkTable[url] = {}


	-- ポップアップを閉じる
	local function closePopup()
		transition.to(popup, {time=200, alpha=0, onComplete=
			function()
				display.remove(popup)
				popup = nil
			end
		})
	end


	-- ネットワークエラーのポップアップ
	local function networkErrorPopup()
		--print("error:"..url)
		--ユーザー用のpopupタイマーを止める
		if networkTable[url]["retry"] then
			timer.cancel(networkTable[url]["retry"])
		end
		display.remove(popup)
		popup = nil
		--エラー発生時
		popup = display.newGroup()
		--黒い背景
		local filter = createBlackFilter(0,0,_W, _H, popup)
		--背景画像
		local background = display.newRoundedRect(popup, 0, 0, _W-80, 600, 8)--display.newImage(popup,"connectError/Back.png", 0,0)
		background.x , background.y = _W*0.5, _H*0.5

		local popupTitle = display.newText(popup, translations.get("ConnectionError"), 0, 0, nil, 54)
		popupTitle:setFillColor(rgbSet.rgbFunction(1)[1],rgbSet.rgbFunction(1)[2],rgbSet.rgbFunction(1)[3])
		popupTitle.x,  popupTitle.y = _W*0.5, background.y - 230


		local popupText2 = display.newText(popup, translations.get("PleaseRefreshInBetterReception"), 0, 0, _W-160, 200, nil, 36)
		popupText2:setFillColor(110)
		local xTextPos 
		if _isLanguage == "ja" or _isLanguage == nil then
			xTextPos = 0
		else
			xTextPos = 35
		end
		popupText2.x,  popupText2.y = _W*0.5+xTextPos, background.y + 180


		--エラー画像
		local errorImage = display.newImage(popup, "background/networkError.png", 0, 0)
		errorImage.x, errorImage.y = background.x,  background.y - 70
		--再接続ボタン
		local reConnectBtn = btn.newPushImage({group=popup, image="Btn/retryConnectBtn.png", action=
			function()    
				closePopup()
				if networkTable[url]["errorTimer"] then
					timer.cancel(networkTable[url]["errorTimer"])
				end
				if networkTable[url]["retryTimer"] then
					timer.cancel(networkTable[url]["retryTimer"])
				end
			end
		})
		reConnectBtn.x, reConnectBtn.y = _W*0.5 - 497*0.5, background.y + 200

		--ボタン上の文字
		local textOnBtn = display.newText(popup, translations.get("Refresh"), 0, 0, nil, 40)
		textOnBtn.x, textOnBtn.y = reConnectBtn.x + reConnectBtn.width*0.5, reConnectBtn.y + reConnectBtn.height*0.5 - 10

	end

	-- Responseが返ってくる場合
	function subListener(event)
		if event.isError then
			print("network error!!")
		end
		if event.status < 0 then

			--失敗した回数
			networkTable[url]["count1"] = networkTable[url]["count1"] + 1
			--規定回数以上失敗したら
			if networkTable[url]["count1"] >= 100 then
				_is_network_connect = false
				networkErrorPopup()
				print(event)
			else
				--再度時間をおいて接続
				timer.performWithDelay(50,
					function()
						request()
					end
				)
			end
		elseif event.status ~= 200 then
			--失敗した回数
			networkTable[url]["count2"] = networkTable[url]["count2"] + 1
			--規定回数以上失敗したら
			if networkTable[url]["count2"] >= #timeTable then
				_is_network_connect = false
				networkErrorPopup()
				print(event)
			else
				--再度時間をおいて接続
				timer.performWithDelay(timeTable[networkTable[url]["count2"]],
					function()
						request()
					end
				)
			end
		else

			--リクエスト成功
			listener(event)

			-- json中身判定
			local data = json.decode(event.response)
			if data then
				--強制ログアウト	
				if data.forced_logout == true then
					local account = require('account')
					account.logout()
				else
					-- ポップアップがないかを確認
					if data.remote_popup and __blockPopup == false then
						showRemotePopup(data.remote_popup)
					end

					-- トークンが不正の時

					if data.reason == "invalid token" then
						print("library.lua : invalid token url is '"..url.."'")

						local account = require('account')
						account.invalidToken()
					end
				end
			end


			--ユーザー用のpopupタイマーを止める
			timer.cancel(networkTable[url]["errorTimer"])
			--timer.cancel(networkTable[url]["retryTimer"])    
		end
	end

	-- 30秒以上Responseがなかったら
	function timeoutFunction()
		network.cancel(networkTable[url]["request"])
	end

	--ネットワークリクエスト
	networkTable[url]["count1"]   = 0
	networkTable[url]["count2"]   = 0

	function request()
		-- TODO : 様子見
		-- if _is_network_connect then
		if true then
			networkTable[url]["request"] = network.request(url, method, subListener, params)
			networkTable[url]["errorTimer"] = timer.performWithDelay(30000, timeoutFunction)
		else
			checkNetworkStatus( request )
		end
	end
	request()
	--print("networkRequest2", url)
end

-- オープニング用ネットワーク再接続2
function networkDownload(url, method, listener, params,imageName,Directory)
	local function removeTimeout()
			--既にある場合
			if networkErrorGroup then
					transition.to(networkErrorGroup, {time=170, alpha = 0})
					timer.performWithDelay(170,
							function()
									display.remove(networkErrorGroup)
									networkErrorGroup = nil
							end
					)
					--network.cancel(net)
			end
	end

	local function popupWindow()
		display.remove(networkErrorGroup)
		networkErrorGroup = nil
		--エラー発生時
		networkErrorGroup = display.newGroup()
		--黒い背景
		local filter = createBlackFilter(0,0,_W, _H, networkErrorGroup)
		--背景画像
		local background = display.newImage(networkErrorGroup,"connectError/Back.png", 0,0)
		background.x , background.y = _W*0.5, _H*0.5
		--再接続ボタン
		local reConnectBtn = createObject("connectError/ReloadBtn.png", nil, "connectError/ReloadBtnPushed.png", nil,200, 570,networkErrorGroup, nil, 
				function()
						removeTimeout()
						networkRequest(url, method, listener, params,imageName,Directory)
				end
		)
	end

	local function subListener(event)
		if event.status ~= 200 then
			popupWindow()
			timer.cancel(reportTimer)
		else
			listener(event)
		end
	end
	network.download(url, method, subListener, params, imageName,Directory)
end

function url_encode(str)
	if (str) then
		str = string.gsub (str, "\n", "\r\n")
		str = string.gsub (str, "([^%w ])",
				function (c) return string.format ("%%%02X", string.byte(c)) end)
		str = string.gsub (str, " ", "+")
	end
	return str  
end

function url_decode(str)
	str = string.gsub (str, "+", " ")
	str = string.gsub (str, "%%(%x%x)",
			function(h) return string.char(tonumber(h,16)) end)
	str = string.gsub (str, "\r\n", "\n")
	return str
end

-- 日付のXXXX-XX-XX表記をXXXX/XX/XX表記に変換する
function date_cast( date )
	local date = string.sub( date, 1, 4 ) .. "/" .. string.sub( date, 6, 7 ) .. "/" .. string.sub( date, 9, 10 )
	return date
end


---------------------------------------------------
-- サブディレクトリを作成する関数
-- dirName：サブディレクトリの名前
-- dirSrc：サブディレクトリを作成する場所（デフォルトではDocumentsDirectory） 
-- 使い方：createDirectory( "folder1", system.DocumentsDirectory )
-- 注意：require"lfs"をしておくこと！
local lfs = require "lfs";
function createDirectory( dirName, dirSrc )
	assert( dirName, "Error!: dirName is nil value" )
	local dirName = tostring(dirName)
	local directory = dirSrc or system.DocumentsDirectory
	local dir_path = system.pathForFile( "", directory )

	local success = lfs.chdir( dir_path )
	local new_folder_path

	if success then
		lfs.mkdir(dirName)
		print( " lfs.currentdir() " .. lfs.currentdir()  )
		new_folder_path = lfs.currentdir() .. "/"..dirName
	end
end

-- print all files you select directory
function checkDirectory( dirName, dirSrc )
	assert( dirName, "Error!: dirName is nil value" )
	local dirName = tostring(dirName)
	local directory = dirSrc or system.DocumentsDirectory
	local doc_path = system.pathForFile( dirName, directory )

	local lfs = require( 'lfs' )
	for file in lfs.dir( doc_path ) do
		 --file is the current file or directory name
		
		if file and file ~= '' and file ~= '.' and file ~= '..' then
			print( "Found file: " .. file )
		else
			print( "Found not file!!" )
		end

	end
end

function existsDirectory( dirName, dirSrc )
	assert( dirName, "Error!: dirName is nil value" )

	local dirName = tostring(dirName)
	local directory = dirSrc or system.DocumentsDirectory
	local doc_path = system.pathForFile( dirName, directory )

	local is_exists = lfs.chdir( doc_path )
	if is_exists then
		return true
	else
		return false
	end
end

function renameDocument( oldName, newName, docSrc )
	local destDir = docSrc or system.DocumentsDirectory  -- where the file is stored
	local results, reason = os.rename( system.pathForFile( oldName, destDir  ),
	        system.pathForFile( newName, destDir  ) )
	
	if results then
	   print( "file renamed" )
	else
	   print( "file not renamed", reason )
	end
	--> file not renamed    orange.txt: No such file or directory
end

 -- delete file you select
function deleteDocument( docName, docSrc )
	assert( docName, "Error!: docName is nil value" )
	local doc = nil

	if docSrc ~= nil then
		doc = docSrc .. "/" .. docName
	else
		doc = docName
	end

	local results = os.remove( system.pathForFile( doc, system.DocumentsDirectory  ) )

	if results then
		 print( "deleteDocument: file removed" )
	else
		 print( "deleteDocument: file does not exist" )
	end
end

-- delete all files you select directory
function cleanDirectory( dirName, dirSrc )
	assert( dirName, "Error!: dirName is nil value" )
	local dirName = tostring(dirName)
	local directory = dirSrc or system.DocumentsDirectory
	local doc_path = system.pathForFile( dirName, directory )

	print("library.lua  createDirectory",doc_path)

	if doc_path ~= nil then
		for file in lfs.dir( doc_path ) do
			 --file is the current file or directory name
			if file ~= nil then
				print( "Found file: " .. file )
				deleteDocument( file, dirName )
			else
				print( "Found not file!!" )
			end
		end
	else
		print("doc_path does not exist")
	end
end

-- you can check document whether or not it exsits
function checkDocument( docName, dirSrc )

	if docName ~= nil then
		local directory = dirSrc or system.DocumentsDirectory
		local doc_path = system.pathForFile( docName, directory )

		if doc_path then
			doc_path = io.open( doc_path, "r" )
		end

		if  doc_path then
			print( "File found -> " .. docName )
			doc_path:close()
					
			return true
		else
			print( "File does not exist -> " .. docName )
			return false
		end
	else
		print( "docName is nil value!!" )
		return nil
	end

end

function resetCache()
	local doc_path = system.pathForFile( '', system.TemporaryDirectory )
	for file in lfs.dir( doc_path ) do
	    -- File is the current file or directory name
		local results = os.remove( system.pathForFile( file, system.TemporaryDirectory  ) )
	    print( 'Found file: ' .. file )
		if results then
			 print( 'resetCache: file removed' )
		else
			 print( 'resetCache: file does not exist' )
		end
	end
end

-- 乱数を返す
function _tsCreateInvalidValue()
	local invalidTable = {}

	for i = 1, 10 do
		local invalidValue = math.random()

		invalidTable[ #invalidTable + 1 ] = invalidValue
	end
	local invalidJson = json.encode( invalidTable )

	return invalidJson
end


-- ネットワーク遅延を試す関数
function _tsCheckisBugFixed( func, time )
	local _time = time or 3000

	print( "--------------------------------------------------" )
	print( _time, func )
	print( "--------------------------------------------------" )

	timer.performWithDelay( _time, function() func() end )

end

-- 文字列の分解
function split(str, delim)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end

    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local lastPos
    for part, pos in string.gfind(str, pat) do
        table.insert(result, part)
        lastPos = pos
    end
    table.insert(result, string.sub(str, lastPos))
    return result
end

function stringFromHex(str)
    return (str:gsub('..', function (cc)
        return string.char(tonumber(cc, 16))
    end))
end


-- scaleの調整
function tsscale(width, height, obj)
	assert(width, "ERROR : NOT FOUND width")
	assert(height, "ERROR : NOT FOUND height")
	assert(obj, "ERROR : NOT FOUND obj")
	
	if obj.width/obj.height > width/height then
		obj:scale(height/obj.height, height/obj.height)
	else
		obj:scale(width/obj.width,width/obj.width)
	end
end



-- create a table listener object for the bkgd image
local ZOOMMAX = 5
local ZOOMMIN =1
local function calculateDelta( previousTouches, event )
    local id,touch = next( previousTouches )
    if event.id == id then
        id,touch = next( previousTouches, id )
        assert( id ~= event.id )
    end

    local dx = touch.x - event.x
    local dy = touch.y - event.y
    return dx, dy
end

function pinchAndMove( event )
	system.activate( "multitouch" )
    local result = true

    local phase = event.phase
    local self = event.target
    local previousTouches = self.previousTouches
    local t = event.target
    local numTotalTouches = 1
    if ( previousTouches ) then
        -- add in total from previousTouches, subtract one if event is already in the array
        numTotalTouches = numTotalTouches + self.numPreviousTouches
        if previousTouches[event.id] then
            numTotalTouches = numTotalTouches - 1
        end
    end

    if "began" == phase then
        -- Very first "began" event
        if ( not self.isFocus ) then
            -- Subsequent touch events will target button even if they are outside the stageBounds of button
            display.getCurrentStage():setFocus( self )
            self.isFocus = true
			t.x0 = event.x - t.x
			t.y0 = event.y - t.y

            previousTouches = {}
            self.previousTouches = previousTouches
            self.numPreviousTouches = 0
        elseif ( not self.distance ) then
            local dx,dy

            if previousTouches and ( numTotalTouches ) >= 2 then
                    dx,dy = calculateDelta( previousTouches, event )
            end

            -- initialize to distance between two touches
            if ( dx and dy ) then
                local d = math.sqrt( dx*dx + dy*dy )
                if ( d > 0 ) then
                    self.distance = d
                    self.xScaleOriginal = self.xScale
                    self.yScaleOriginal = self.yScale

                    print( "distance = " .. self.distance )
                end
            end
        end

        if not previousTouches[event.id] then
            self.numPreviousTouches = self.numPreviousTouches + 1
        end
        previousTouches[event.id] = event

    elseif self.isFocus then
        if "moved" == phase then
            if ( self.distance ) then
                local dx,dy
                if previousTouches and ( numTotalTouches ) >= 2 then
                    dx,dy = calculateDelta( previousTouches, event )
                end

                if ( dx and dy ) then
                    local newDistance = math.sqrt( dx*dx + dy*dy )
                    local scale = newDistance / self.distance
                    if ( scale > 0 ) then
                        self.xScale = self.xScaleOriginal * scale
                        self.yScale = self.yScaleOriginal * scale
                    end
                end
            end
			if numTotalTouches == 1 then
				
				t.x = event.x - t.x0
				t.y = event.y - t.y0
				--xの上限
				if t.x < 0 then
					t.x = 0
				elseif t.x > _W then
					t.x = _W
				end
				--yの上限
				if t.y < 0 then
					t.y = 0
				elseif t.y > _H then
					t.y = _H
				end

			end
            if not previousTouches[event.id] then
                self.numPreviousTouches = self.numPreviousTouches + 1
            end
            previousTouches[event.id] = event

        elseif "ended" == phase or "cancelled" == phase then
        	system.deactivate( "multitouch" )
            if previousTouches[event.id] then
                self.numPreviousTouches = self.numPreviousTouches - 1
                previousTouches[event.id] = nil
            end

            if ( #previousTouches > 0 ) then
                -- must be at least 2 touches remaining to pinch/zoom
                self.distance = nil
            else
                -- previousTouches is empty so no more fingers are touching the screen
                -- Allow touch events to be sent normally to the objects they "hit"
                display.getCurrentStage():setFocus( nil )

                self.isFocus = false
                self.distance = nil

                self.xScaleOriginal = nil
                self.yScaleOriginal = nil

                -- reset array
                self.previousTouches = nil
                self.numPreviousTouches = nil
            end
        end
    end

    return result
end



function hideModal()
	if __loadingModalGroup then
		local function remove()
			if __spinner and __spinner.parent then
				local flag, ret = pcall( __spinner.stop, __spinner )
				if not flag then
					print("error", ret)
				end

				local flag, ret = pcall( __spinner.removeSelf, __spinner )
				if not flag then
					print("error", ret)
				end
				__spinner = nil
			end

			display.remove( __loadingModalGroup )
			__loadingModalGroup = nil
		end
		__loadingModalGroup:setReferencePoint( display.CenterReferencePoint )
		transition.to( __loadingModalGroup, { time = 200, alpha = 0, transition = easing.inBack, onComplete = remove } )
	end
end

__loadingModalGroup = nil
__spinner = nil
function showModal()
	if __loadingModalGroup == nil then
		
		__loadingModalGroup = display.newGroup()

		local bg = display.newRect( 0, 0, _W, _H )
		bg.isVisible = false
		bg.isHitestable = true

		local popup = display.newRoundedRect( 0, 0, 350*100, 250*100, 5*100 )
		popup:scale( 0.01, 0.01 )
		popup:setReferencePoint( display.CenterReferencePoint )
		popup:setFillColor( 0, 200 )
		popup.x, popup.y = _W*0.5, _H*0.5


		local text = display.newText( '読み込み中...', 0, 0, native.systemFontBold, 30 )
		text.x, text.y = _W*0.5, popup.y+80

		__spinner = widget.newSpinner 
		{
			width = 100,
			height = 100,
		}
		__spinner.x, __spinner.y = _W*0.5, _H*0.5-20

		bg:addEventListener( 'tap', returnTrue )
		bg:addEventListener( 'touch', returnTrue )
		
		__loadingModalGroup:insert( bg )
		__loadingModalGroup:insert( popup )
		__loadingModalGroup:insert( text )
		__loadingModalGroup:insert( __spinner )
		
		if __spinner and __spinner.parent then
			local flag, ret = pcall( __spinner.start, __spinner )
			if not flag then
				print("error", ret)
			end
		end

		__loadingModalGroup.x = 0
		__loadingModalGroup:setReferencePoint( display.CenterReferencePoint )
		__loadingModalGroup:scale( 0.2, 0.2 )
		transition.to( __loadingModalGroup, { time = 300, xScale = 1, yScale = 1, transition=easing.outBack } )
	end
end


function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- json decodeした配列の中身が文字列になっているものを数値に直す
function convertStrToNumFromTable( data )
	local res = {}
	if type( data ) == 'table' then
		for key, value in pairs ( data ) do
			local ret = tonumber( value )
			if ret and ret ~= '' and type( ret ) == 'number' then
				value = ret
			end
			value = convertStrToNumFromTable( value )
			local cached_key = tonumber( key )
			if cached_key and cached_key ~= '' and type( cached_key ) == 'number' then
				key = cached_key
			end
			res[key] = value
		end
	else
		res = data
	end
	return res
end

-- ソートするpairs
function order_pairs(tab)
    local sorted = {}
    for key in pairs(tab) do
        table.insert(sorted,key)
    end

    local function compare( a, b )
		return a < b
	end
    
    table.sort(sorted, compare)
    local i=0
    return function()
        i = i + 1
        if i > #sorted then
            return nil,nil
        else
            local key=sorted[i]
            return key,tab[key]
        end
    end
end
