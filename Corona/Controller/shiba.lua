local scene = storyboard.newScene()

-- require view
local shiba_view = require( ViewDir .. 'shiba_view' )
local home_view = require( ViewDir .. 'home_view' )
local shiba2_view = require( ViewDir .. 'shiba2_view' )
local playerInfo = require( ContDir .. 'playerInfo')

local function viewHandler( event )
	if event.name == 'shiba_view-tap' then

		if event.value == 'back' then
			storyboard.gotoScene(ContDir..'home')
			print("ThinThin")
		end

		if event.value == 'next' then
			storyboard.gotoScene(ContDir..'shiba2')
			print("ThinThin_next")
			playerInfoData['thinthin_size'] = playerInfoData['thinthin_size'] + 1 
			playerInfo.save()

		end

	end
end

function scene:createScene( event )
	local group = self.view
end

function scene:willEnterScene( event )
	local group = self.view

	--user_model:addEventListener( modelHandler )
	shiba_view:addEventListener( viewHandler )

	local view_obj = shiba_view.create()
	group:insert( view_obj )

end

function scene:enterScene( event )
	local group = self.view
end

function scene:exitScene( event )
	local group = self.view

	--user_model:removeEventListener( modelHandler )
	shiba_view:removeEventListener( viewHandler )

	shiba_view.destroy()

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
