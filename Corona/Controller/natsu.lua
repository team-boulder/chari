--gitの練習だお

local scene = storyboard.newScene()

-- require view
local natsu_view = require( ViewDir .. 'natsu_view' )
local home_view = require( ViewDir .. 'home_view' )

local function viewHandler( event )
	if event.name == 'natsu_view-tap' then

		if event.value == 'back' then
			storyboard.gotoScene(ContDir..'home')
		end

		if event.value == 'next' then
			storyboard.gotoScene(ContDir..'natsu1')
		end

	end
end

function scene:createScene( event )
	local group = self.view
end

function scene:willEnterScene( event )
	local group = self.view

	--user_model:addEventListener( modelHandler )
	natsu_view:addEventListener( viewHandler )

	local view_obj = natsu_view.create()
	group:insert( view_obj )

end

function scene:enterScene( event )
	local group = self.view
end

function scene:exitScene( event )
	local group = self.view

	--user_model:removeEventListener( modelHandler )
	natsu_view:removeEventListener( viewHandler )

	natsu_view.destroy()

end

function scene:didExitScene( event )
	local group = self.view

end

function scene:destroyScene( event )
	local group = self.view
end


-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "willEnterScene" event is dispatched before scene transition begins
scene:addEventListener( "willEnterScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

scene:addEventListener( "didExitScene", scene )
-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeAll() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene
