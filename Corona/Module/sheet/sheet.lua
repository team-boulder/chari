-- File : sheet.lua
--
-- Creater : RYO TAKAHASHI
-- 
-- Date : 2016-09-29
--
-- Comment 
--
-- 使い方
-- local sprite = require(ModDir .. 'sheet.sheet')
-- local sheet = sprite.new(ImgDir .. 'Sheet.cosmo_play_image_sheet', ImgDir .. 'play/cosmo_play_image_sheet.png')
-- local obj = sheet.newImage([group], filename, [x, y])
-------------------------------------------------------------------------------------------------------------------------

local sheet = object.new()

local function listener(sheet_path, image_path)
	local self = {}

	local sheetInfo = require(sheet_path)
	local imageSheet = graphics.newImageSheet( image_path, sheetInfo:getSheet() )

	function self.newImage(...)
		option = {...}

		local group = nil
		local image_name = nil
		local x = 0
		local y = 0
		local dir = system.ResourceDirectory
		local isFullResolution = true
		local onComplete = nil

		-- 生成するオブジェクト
		local obj = nil

		----------------------------------------------
		-- 引数の確認の設定
		-- group, path, dir, x, y, isFullResolution
		----------------------------------------------
		local section = 1
		
		if type(option[section]) == "table" and #option == 1 then
			-- 引数を配列で渡した場合
			local data  = option[section]
			image_name       = data.image
			group            = data.group or nil
			x                = data.x or 0
			y                = data.y or 0
			isFullResolution = data.isFullResolution or true
			dir              = data.dir
			onComplete       = data.onComplete
		else
			-- 引数を各々渡した場合

			-- group
			if type(option[section]) == "table" and type(option[section].numChildren) == 'number' then
				group = option[section]
				section = section + 1
			else
				-- イメージが複数枚
				image_name = option[section]
				section = section + 1
			end

			if image_name == nil then
				-- path
				image_name = option[section]
				section = section + 1;
			end
			
			-- dir
			if type(option[section]) == "userdata" then
				dir = option[section] 
				section = section + 1;
			end

			-- x, y
			if type(option[section]) == "number" or type(option[section]) == "string" then
				x = option[section]
				section = section + 1;

				y = option[section]
				section = section + 1;
			end

			-- isFullResolution
			if option[section]  == "boolean" then
				isFullResolution = option[section]
			end
		end

		-- 画像のリソース判定
		local path = {}
		if type(image_name) == "userdata" then
			-- スプライトシート対応
			obj = display.newImage(...)

		-- elseif startsWith(image_name,"http://") then 
			
			-- local path = system.pathForFile(basename(image_name), system.TemporaryDirectory)
			-- local file = io.open(path, "r")
			-- if not file then
			-- 	-- リンクからDL
			-- 	obj = display.newGroup()
			-- 	obj.x = x; obj.y = y;

			-- 	if group then
			-- 		group:insert(obj)
			-- 	end
			-- 	checkDownload(image_name, 
			-- 		function()
			-- 			if obj then
			-- 				obj:setReferencePoint(display.TopLeftReferencePoint)
			-- 				local image = display.newImage(obj, basename(image_name), system.TemporaryDirectory)
			-- 				image:setReferencePoint(display.TopLeftReferencePoint)
			-- 				if obj.x ~= x then
			-- 					image.x = -image.width/2
			-- 				end
			-- 				if obj.y ~= y then
			-- 					image.y = -image.height/2
			-- 				end
							
			-- 				-- 完了後に実行する関数
			-- 				if onComplete then
			-- 					timer.performWithDelay( 1, onComplete)
			-- 				end					
			-- 			end
			-- 		end
			-- 	)
			-- else
			-- 	io.close(file)
			-- 	-- 画像の生成
			-- 	if group then
			-- 		obj = display.newImage(group, basename(image_name), system.TemporaryDirectory, x, y, isFullResolution)
			-- 	else
			-- 		obj = display.newImage(basename(image_name), system.TemporaryDirectory, x, y,  isFullResolution)
			-- 	end		
			-- 	-- 完了後に実行する関数
			-- 	if onComplete then
			-- 		timer.performWithDelay( 1, onComplete)
			-- 	end
			-- end
		else
			if type(image_name) == 'table' then
				for k, v  in pairs(image_name) do
					v = string.gsub(v, '.png', '')
					v = string.gsub(v, '.jpg', '')
					table.insert(path, sheetInfo:getFrameIndex(v))
				end
			else

				image_name = string.gsub(image_name, '.png', '')
				image_name = string.gsub(image_name, '.jpg', '')
				table.insert(path, sheetInfo:getFrameIndex(image_name))
			end

			-- 画像の生成
			if group then
				obj = display.newSprite( imageSheet , {frames=path} )
				obj:setReferencePoint(display.TopLeftReferencePoint)
				obj.x, obj.y = x, y
				group:insert(obj)
				obj:setReferencePoint(display.CenterReferencePoint)
			else
				obj = display.newSprite( imageSheet , {frames=path} )
				obj:setReferencePoint(display.TopLeftReferencePoint)
				obj.x, obj.y = x, y
				obj:setReferencePoint(display.CenterReferencePoint)				
			end
			-- 完了後に実行する関数
			if onComplete then
				timer.performWithDelay( 1, onComplete)
			end
		end

		function obj.play(self, options)
			obj:play()
		end


		function obj.stop(self, options)
			obj:stop()
		end

		return obj
	end
	return self
end



function sheet.new(sheet_path, image_path)
	return listener(sheet_path, image_path)
end

return sheet