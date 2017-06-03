--[[
@
@ Project  :
@
@ Filename : start_view.lua
@
@ Author   : Task Nagashige
@
@ Date     : 2015-10-10
@
@ Comment  : アプリ起動時に色々な情報を取ってきて起動の準備をするページ。
@            実態はスプラッシュ・ローディングが表示されているのみ
@
]]--

local self = object.new()

local obj = {}

local is_completed = false

function self.effect( listener )
	local trans1, trans2, trans3
	local count = 0
	function trans1()
		if count < 3 then
			transition.to( obj.btn, { time = 100, alpha = 0, onComplete = trans2 } )
		else
			listener()
		end
	end

	function trans2()
		transition.to( obj.btn, { time = 100, alpha = 1, onComplete = trans1 } )
		count = count + 1
	end

	trans1()
end

function self.create()
	if obj.group == nil then
		obj.group = display.newGroup()

		obj.bg = display.newImage( ImgDir .. 'start/bg.png' )

		obj.btn = display.newImage( ImgDir .. 'start/btn.png' )
		obj.btn.x, obj.btn.y = _W*0.5, 570
		obj.btn.value = 'btn'

		obj.btn:addEventListener( 'tap', self.tap )

		obj.group:insert( obj.bg )
		obj.group:insert( obj.btn )

		return obj.group
	end
end

function self.destroy()
	if obj.group then
		local function remove()
			display.remove( obj.group )
			obj.group = nil
		end
		transition.to( obj.group, { time = 200, alpha = 0, onComplete = remove } )
	end
	is_completed = false
end

function self.tap( e )
	if e.target.value == 'btn' then
		if is_completed then return true end
		sound.play( sound.op_tap )
		is_completed = true
		self.effect( function() self:dispatchEvent( { name = 'start_view-tap' } ) end )
	end
	return true
end

return self
