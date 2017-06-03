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
