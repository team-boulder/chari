--[[
@
@ ProjectName : 
@
@ Filename	  : store_model.lua
@
@ Author	  : Task Nagashige
@
@ Created	  : 2015-10-09
@
@ Comment	  : Coronaのstoreライブラリを使って課金機能を呼び出す
@				ネイティブ箇所を呼び出して決済処理を行う部分は毎回インスタンスを生成しないとアクセスできず、
@				それ以外の箇所はアクセス制限はない。
@
]]--

local inAppBilling = require( PluginDir .. 'inAppBilling.inAppBilling' )

local this = object.new()
local data = {}
local products = {}

this.status = nil

-- 正常に購入されたの時のListener
local function purchaseEventListener( transaction )

	if transaction and transaction.receipt and transaction.receipt ~= '' then

		local receiptPath = nil

		local function purchaseNetworkEventListener( e )
			if not e.isError then
				-- print( e )
				print( json.encode( e.response ) )
				local data = json.decode( e.response )
				-- print(receiptPath)
				inAppBilling.deleteReceipt( receiptPath .. '.txt' )
				local event = 
				{
					name = 'store_model-purchaseEventListener',
					phase = 'finished',
					data = data,
				}
				this:dispatchEvent( event )
			end
		end

		local receiptData = inAppBilling.formatReceipt( transaction.receipt, transaction.identifier, transaction.signature )
		receiptPath = inAppBilling.saveReceipt( receiptData )

		local params = {}
		params['token'] = userInfoData.token
		params['uid'] = userInfoData.id
		params['receipt'] = receiptData
		params['platform'] = system.getInfo( 'platformName' ) or ''
		params['publicKey'] = __publicKey
        if this.status then 
			params['status'] = this.status
		end
		print( params )

		fnetwork.request( urlBase .. 'store/purchase.php', 'POST', purchaseNetworkEventListener, params )
	end

end

-- リストアされた時のListener
local function restoreEventListener( transaction )
	local event = 
	{
		name = 'store_model-restoreEventListener',
		phase = 'finish',
		transaction = transaction
	}
	this:dispach( event )
end

-- 購入がキャンセルされた時のListener
local function cancelledEventListener( transaction )
	local event = 
	{
		name = 'store_model-cancelledEventListener',
		phase = 'finish',
		transaction = transaction
	}
	this:dispatchEvent( event )
end

-- 購入に失敗したの時のListener
local function failedEventListener( transaction )
	local event = 
	{
		name = 'store_model-failedEventListener',
		phase = 'finish',
		transaction = transaction
	}
	this:dispatchEvent( event )
end

-- 不明なイベントの時のListener
local function unknownEventListener( transaction )
	local event = 
	{
		name = 'store_model-unknownEventListener',
		phase = 'finish',
		transaction = transaction
	}
	this:dispatchEvent( event )
end

-- 捕捉できないエラーの時のListener
local function errorEventListener()
	local event = 
	{
		name = 'store_model-errorEventListener',
		phase = 'finish'
	}
	this:dispatchEvent( event )
end


-- 課金APIのレスポンスをHandleするListener
function this.inAppBillingTransactionListener( event )

	local transaction = event.transaction
	if event.name == 'inAppBilling-purchase-transaction-finish' then
		if event.phase == 'purchased' then
			print( 'catched purchased event' )
			purchaseEventListener( transaction )

		elseif event.phase == 'restore' then
			print( 'catched restore event' )
			restoreEventListener( transaction )

		elseif event.phase == 'cancelled' then
			print( 'catched cancelled event' )
			cancelledEventListener( transaction )

		elseif event.phase == 'failed' then
			print( 'catched failed event' )
			failedEventListener( transaction )

		elseif event.phase == 'unknown-event' then
			print( 'catched unknown event' )
			unknownEventListener( transaction )

		else
			print( 'Fatal error Not catch event' )
			errorEventListener()

		end
		inAppBilling:removeEventListener( this.inAppBillingTransactionListener )
	end

end


local function listener()
	local self = object.new()
	

	-- プロパティの宣言

	-- ストア情報取得
	function self.getList()
		local function networkListener(event)
			print(event.response)
			local res = json.decode(event.response)
			local data = res['purchases']
			local product = res['product_data']
			this.store.consumePurchase( product )
			local dispathEvent = {
				name = 'store_model-getList',
				phase = 'finished',
				data = data,
				product = product,
				res = res,
			}
			this:dispatchEvent( dispathEvent )
		end

		-- 付加するパラメータ
		local params = {}
		params['uid'] = userInfoData.id
		params['token'] = userInfoData.token
		params['platform'] = system.getInfo( 'platformName' )

		fnetwork.request(urlBase..'store/list.php', 'POST', networkListener, params)
	end

	-- 課金APIを継承
	function self.init()
		this.store = inAppBilling.new()
		this.store.init()
		-- 未処理のレシートがあったら処理
		inAppBilling.fetchUserProduct()
	end

	self.init()
	
	return self
end


function this.new()
	return listener()
end

return this
