-- anim
--
-- local obj = display.newRect(0, 0, 100, 100)
-- obj:setAnim()
-- 
--
--
--
-------------------------------------------------------
local this = {}
local anims = {}

this.timers = {}

--------------------
-- アニメーション
--------------------
-- ぷにぷに
function anims:punipuni(option)
	local anim1, anim2
	local count = 0

	if not option then
		option = {}
	end
	local xScale = option.xScale or 1.06
	local yScale = option.yScale or 0.96
	local _delay = option.delay or 1000
	local _time  = option.time or 300 	
	local _count  = option.count or 2


	function anim1()
		if not self then return end
		local delay = 0
		if count%_count == 1 then
			delay = _delay
		end
		count = count + 1
		local tran = transition.to(self, {time=_time, xScale=xScale, yScale=yScale, onComplete=anim2, delay=delay, transition=easing.outSine})
		table.insert(self.trans, tran)
	end
	function anim2()
		if not self then return end
		local tran = transition.to(self, {time=_time, xScale=1, yScale=1, onComplete=anim1, transition=easing.outSine})
		table.insert(self.trans, tran)
	end
	anim1()
end

-- 上下左右
function anims:updown(option)
	local anim1, anim2
	local count = 1

	if not option then
		option = {}
	end

	local y0 = self.y
	local _y = option.y or 16
	local x0 = self.x
	local _x = option.x or 0
	local _count  = option.count or 2
	local _delay = option.delay or 1000

	function anim1()
		if not self then return end
		local delay = 0
		if count%_count == 1 then
			delay = _delay
		end		
		count = count + 1
		local tran = transition.to(self, {time=300, x=x0+_x, y=y0+_y, delay=delay, onComplete=anim2})
		table.insert(self.trans, tran)
	end
	function anim2()
		if not self then return end
		local tran = transition.to(self, {time=300, x=x0, y=y0, onComplete=anim1})
		table.insert(self.trans, tran)
	end
	anim1()
end


-- 揺らす
function anims:shake(option)
	if not option then
		option = {}
	end

	local anim1, anim2
	local limit  = option.limit or nil
	local x0     = self.x
	local y0     = self.y
	local x1     = option.x or 10
	local y1     = option.y or 10
	local time   = option.time or 30
	local tag    = option.tag or nil
	local count  = 0
	local rotation = option.rotation or 0
	local easing   = option.easing or easing.linear

	function anim1()
		if not self then return end
		count = count + 1
		if limit and limit == count then 

			return 
		else
			local r = rotation - math.random(0, rotation)*2
			local tran = transition.to(self, {time=time, tag=tag, x=x0+math.random(0, x1), y=y0+math.random(0, y1), rotation=r , transition=easing, onComplete=anim2})
			table.insert(self.trans, tran)
		end
	end
	function anim2()
		if not self then return end
		local r = rotation - math.random(0, rotation)*2
		local tran = transition.to(self, {time=time, tag=tag, x=x0, y=y0, rotation=r, transition=easing, onComplete=anim1})
		table.insert(self.trans, tran)
	end
	anim1()
end

-- イカっぽいなにか
function anims:ika( option )
	if not option then option = {} end

	local anim1, anim2
	local r
	local count  = 0
	local limit  = option.limit or nil
	local tag    = option.tag or nil
	local easing   = option.easing or easing.linear
	local rotation = option.rotation or 15
	local u_time   = option.time or 300

	function anim1()
		if not self then return end
		count = count + 1
		if limit and limit == count then 
			return 
		else
			r = rotation - math.random(0, rotation) * 2
			local d_time = 100 * math.random(3,5)
			local l = math.random(90, 100)
			local tran = transition.to(self, {time=d_time*10, tag=tag, x=self.x, y=self.y+l, rotation=r, transition=easing, onComplete=anim2})
			table.insert(self.trans, tran)
		end
	end
	
	function anim2()
		if not self then return end
		local l  = math.random(90, 110)
		local x1 = math.cos((90 + self.rotation) / 180 * math.pi ) * l
		local y1 = math.sin((90 + self.rotation) / 180 * math.pi ) * l
		local tran = transition.to(self, {time=u_time, tag=tag, x=self.x - x1, y=self.y-y1, transition=easing, onComplete=anim1})
		table.insert(self.trans, tran)
	end

	anim1()
end


-- 停止
function anims:stopAnim()
	for k, v in pairs(self.trans) do
		if v then 
			transition.cancel(v)
		end
		k, v = nil, nil
	end
	self.trans = {}
end


---------------------------------------
-- オブジェクトにアニメーションを付加する
---------------------------------------
function  this.new(self)
	for k, v in pairs(anims) do
		self[k] = v
	end
	self.trans = {}
end

return this