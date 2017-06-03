local self = object.new()

local tonumber = tonumber

userInfoData = {}

function self.check()
	local function networkListener( e )
		-- print( e )
		if not e.isError then
			local data = json.decode( e.response )
			print(data)
			if data.result == 'success' then
				self:dispatchEvent( { name = 'user_model-recoverStamina', result = 'success', stamina = data.stamina } )
				if listener then
					listener()
				end
			else
				self:dispatchEvent( { name = 'user_model-recoverStamina', result = 'failure', reason = data.reason } )
			end
		end
	end

	local tmp_id = string.random( 10, '%l%d' )

	--付加するパラメータ
	local params = {}
	params['token']          = userInfoData.token
	params['user_id']        = userInfoData.id
	params['transaction_id'] = transaction_id or tmp_id

	fnetwork.request( 'https://me2x1q3388.execute-api.ap-northeast-1.amazonaws.com/prod/boulder', 'GET', networkListener, params )
end

return self