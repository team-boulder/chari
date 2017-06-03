-- number.lua
-- Comment : number.lua
-- Date : 2015-07-18
-- Creater : Ryo Takahashi
-----------------------------------------------
-- -- Sample 
-- local number = require(ModDir .. 'number.number')
-- local obj = number.newImage(group, 100, ImgDir..'number/', 10, 10)
-- obj:text(20)
-----------------------------------------------


module(..., package.seeall)

------------------
-- 数字の生成
------------------
function newImage(...)

	local self = display.newGroup()
	local option = {...}

	local s = 1
	local num = 0
	self._extension = 'png'

	-- group, image
	if option[s] and type(option[s]) == 'table' then
		option[s]:insert(self)
		num = ( option[s+1] )
		s = s+2
	else
		num = (option[s])
		s = s+1
	end

	-- ディレクトリ
	if option[s] and type(option[s]) == 'string' then
		self.dir = option[s]
		s = s + 1
	end

	-- 座標
	if option[s] and type(option[s]) == 'number' then
		self.x = option[s]
		self.y = option[s+1]
		s = s + 2
	end

	-- 座標
	self._width = 0
	if option[s] and type(option[s]) == 'number' then
		self._width = option[s] or 0
		s = s + 1
	end
	
	if  option[s] and type(option[s]) == 'string' then
		self._extension = option[s]
	end

	function self:text(num)
		display.remove(self.inner)
		self.inner = nil

		self.inner = display.newGroup()
		self:insert(self.inner)

		local numChar = tostring(num)
		local prev = nil
		local l = string.len(numChar)
		local str = {}

		for i = 1 , l do
			str[i] = string.sub(numChar , i , i )
			if str[i] == ':' then
				str[i] = 'coron'
			end
			local width = 0
			
			if prev then
				width = prev.x + prev.width/2 + 0 + self._width
			end
			
			local numobj = display.newImage(self.inner, self.dir.."/"..str[i].."." ..self._extension, width, 0)
			if prev then
				numobj.y = prev.y
			end
			prev = numobj
		end

		self.inner:setReferencePoint(display.CenterReferencePoint)
		self.inner.x = 0
		self.inner.y = 0

		prev = nil

	end
	self:text(num)
	self:setReferencePoint(display.CenterReferencePoint)

	function self:setFillColor( ... )
		local group_num = self.inner.numChildren
		for i = 1, group_num do
			if self.inner[i].setFillColor then
				self.inner[i]:setFillColor( ... )
			end
		end
	end

	return self
end