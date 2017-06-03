local scene = storyboard.newScene()

-- require view
local temp_view = require( ViewDir .. 'temp_view' )

local function viewHandler( event )
	if event.name == 'temp_view-tap' then

		if event.value == 'bg' then
			storyboard.hideOverlay( "slideRight" )
		end
	end
end


function scene:createScene( event )
	local group = self.view
end

function scene:willEnterScene( event )
	local group = self.view

	temp_view:addEventListener( viewHandler )

	local view_obj = temp_view.create(event.params)
	group:insert( view_obj )

end

function scene:enterScene( event )
	local group = self.view
end

function scene:exitScene( event )
	local group = self.view

	temp_view:removeEventListener( viewHandler )

end

function scene:didExitScene( event )
	local group = self.view

end

function scene:destroyScene( event )
	local group = self.view
	temp_view.destroy()
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
