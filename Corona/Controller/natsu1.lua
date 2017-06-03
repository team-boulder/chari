--gitの練習だお

local scene = storyboard.newScene()

-- require view
local natsu_view1 = require( ViewDir .. 'natsu_view1' )
local natsu_view = require( ViewDir .. 'natsu_view' )

local tapCount = 0

local function viewHandler( event )
	if event.name == 'natsu_view-tap1' then
		if event.value == 'back' then
			--tapCount = 0
			storyboard.gotoScene(ContDir..'home')
		end

		if event.value == 'image' then
			if tapCount < 10 then
				tapCount = tapCount + 1
				natsu_view1.refresh(tapCount)
				playerInfoData['test'] = tapCount
			else
				tapCount = 0
			end	
			playerInfoData['test'] = tapCount
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
	natsu_view1:addEventListener( viewHandler )

	local view_obj = natsu_view1.create()
	group:insert( view_obj )

end

function scene:enterScene( event )
	local group = self.view
end

function scene:exitScene( event )
	local group = self.view

	--user_model:removeEventListener( modelHandler )
	natsu_view1:removeEventListener( viewHandler )

	natsu_view1.destroy()

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
