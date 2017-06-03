local self = object.new()

local obj = {}

function self.create()
		obj.group = display.newGroup()

		-- tytle
		obj.bg = display.newRect(0,0,_W,_H)
		obj.bg:setFillColor(100,200,200)
		obj.cloud = display.newEmitter( emitter.params[3] )
		obj.cloud.x = _W*1.5
		obj.cloud.y = 100
		obj.group:insert( obj.bg )
		rand = math.random(1, 4)
		if rand == 1 then
		    obj.bg:setFillColor(144,144,144)
			obj.snow = display.newEmitter( emitter.params[4] )
			obj.snow.x = _W/2
			obj.snow.y = 0
			obj.group:insert( obj.snow ) 
		elseif rand == 2 then
			obj.bg:setFillColor(234,145,152)
			obj.sakura = display.newEmitter( emitter.params[5] )
			obj.sakura.x = _W/2
			obj.sakura.y = 100
			obj.group:insert( obj.sakura )
		elseif rand == 3 then
		    obj.bg:setFillColor(197,84,49)
			obj.momiji = display.newEmitter( emitter.params[6] )
			obj.momiji.x = _W/2
			obj.momiji.y = 100
			obj.group:insert( obj.momiji )
		end

		obj.group:insert( obj.cloud )

		return obj.group
end


function self.destroy()
	if obj.group then
		local function remove()
			display.remove( obj.group )
			obj.group = nil
		end
		remove()
	end
end


return self
