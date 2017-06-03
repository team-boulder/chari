--[[
@
@ ProjectName : 
@
@ Filename	  : popup.lua
@
@ Author	  : Task Nagashige
@
@ Created	  : 2016-02-12
@
@ Comment	  : 
@
]]--

local self = {}

-- ポップアップ（remote_popup）を取得
function self.get( id )

	local function networkListener( event )
		if not event.isError then
			local data = json.decode( event.response )
			hideModal()
		end
	end

	local params = {}
	params['token'] = userInfoData.token
	params['uid'] = userInfoData.id
	params['id'] = id
	fnetwork.request( urlBase .. '/ads/get_popup.php', 'POST', networkListener, params )
end

return self