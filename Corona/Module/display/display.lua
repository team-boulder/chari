-- display.lua
-- Comment : dislay.lua
-- Date : 2015-5-30
-- Creater : Ryo Takahashi
-----------------------------------------------

--------------------------------------------------
-- display.newImage
--
-- @param : group, path, x, y, isFullResolution
--------------------------------------------------

_displayNewImage = display.newImage
function display.newImage(...)
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
		if type(option[section]) == "table" or type(option[section]) == "object" then
			group = option[section]
			section = section + 1;
		end

		-- path
		image_name = option[section]
		section = section + 1;
		
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
	local path = nil
	if type(image_name) == "userdata" then
		-- スプライトシート対応
		obj = _displayNewImage(...)

	elseif startsWith(image_name,"http://") then 
		
		local path = system.pathForFile(basename(image_name), system.TemporaryDirectory)
		local file = io.open(path, "r")
		if not file then
			-- リンクからDL
			obj = display.newGroup()
			obj.x = x; obj.y = y;

			if group then
				group:insert(obj)
			end
			checkDownload(image_name, 
				function()
					if obj then
						obj:setReferencePoint(display.TopLeftReferencePoint)
						local image = _displayNewImage(obj, basename(image_name), system.TemporaryDirectory)
						image:setReferencePoint(display.TopLeftReferencePoint)
						if obj.x ~= x then
							image.x = -image.width/2
						end
						if obj.y ~= y then
							image.y = -image.height/2
						end
						
						-- 完了後に実行する関数
						if onComplete then
							timer.performWithDelay( 1, onComplete)
						end					
					end
				end
			)
		else
			io.close(file)
			-- 画像の生成
			if group then
				obj = _displayNewImage(group, basename(image_name), system.TemporaryDirectory, x, y, isFullResolution)
			else
				obj = _displayNewImage(basename(image_name), system.TemporaryDirectory, x, y,  isFullResolution)
			end		
			-- 完了後に実行する関数
			if onComplete then
				timer.performWithDelay( 1, onComplete)
			end
		end
	else
		if startsWith(image_name,"local://") then 
			-- 生成
			path = string.gsub(image_name, "local://", "")
		else
			path = image_name
		end
		
		-- 画像の生成
		if group then
			obj = _displayNewImage(group, path, dir, x, y, isFullResolution)
		else
			obj = _displayNewImage(path, dir, x, y, isFullResolution)
		end
		-- 完了後に実行する関数
		if onComplete then
			timer.performWithDelay( 1, onComplete)
		end
	end

	return obj
end

-- group内のオブジェクトを全てremoveする
local cached_displayRemove = display.remove
function display.remove( obj )
	local obj = obj
	if type( obj ) == 'table' then
		transition.cancel( obj )
		local group_num = obj.numChildren
		if group_num and group_num > 1 then
			local i
			for i = 1, group_num do
				display.remove( obj[i] )
				obj[i] = nil
			end
			i = nil
			group_num = nil
		end
	end
	cached_displayRemove( obj )
end