--[[
@
@ ProjectName : 
@
@ Filename	  : inAppBilling.lua
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


local base64 = require( ModDir .. 'base64.base64' )

local this = object.new()
local google_iap_v3 = false
local store = {}

if system.getInfo( 'platformName' ) == 'Android' then
	store = require( 'plugin.google.iap.v3' )
	google_iap_v3 = true
elseif system.getInfo( 'platformName' ) == 'iPhone OS' then
	store = require( 'store' )
else
	store.availableStores = {}
	-- native.showAlert( '', 'In-app Billing are not supported in the Corona Simulator.', { 'OK' } )
end

-- レシートをiOS用に整形する
local function formatReceiptOfApple( receiptData  )
	assert( receiptData, 'ERROR : not found receiptData' )

	--remove unwanted characters
	local receipt = receiptData:sub(2,-2)
	receipt = receipt:gsub(' ','')
	
	--Convert to ascii
	local ascii = ''
	local l = receipt:len()
	for i=1,l,2 do 
		local hex = receipt:sub(i,i+1)
		local dec = tonumber(hex, 16)
		if dec then 
			local char = string.char(dec)
			ascii = ascii..char
		end
	end
	
	
	--Encode to base 64
	local b64encode = base64.encode(ascii)
	
	if serverValidation then  
		--dont send password in case of server validation
		return b64encode
	end 
	
	--Convert to json 
	local jsn = json.encode 
	{
		receipt_data = b64encode,
	}
	jsn = jsn:gsub('receipt_data','receipt-data')
	
	return jsn 
end

local function formatReceiptOfGoogle( receiptData, identifier, signature )
	assert( receiptData, 'ERROR : not found receiptData' )
	assert( identifier, 'ERROR : not found identifier' )
	assert( signature, 'ERROR : not found signature' )

	local data = {}
	data['receipt'] = receiptData
	data['identifier'] = identifier
	data['signature'] = signature

	receiptData = json.encode( data )

	return receiptData
end

-- レシートの保存
function this.saveReceipt( receiptData )
	print( receiptData ) 
	local is_exsist = existsDirectory( 'receipt' )
	if not is_exsist then
		createDirectory( 'receipt' )
	end
	local saveFilename = os.time( os.date( '*t' ) );
	writeText( 'receipt/' .. saveFilename .. '.txt', receiptData )
	
	print(saveFilename)
	return saveFilename
end

-- レシートの削除
function this.deleteReceipt( receiptName )
	print('delete receipt ', receiptName)
	deleteDocument( 'receipt/' .. receiptName )
end

-- レシートを整形
function this.formatReceipt( receiptData, identifier, signature )
	if system.getInfo( 'platformName' ) == 'iPhone OS' then
		receiptData = formatReceiptOfApple( receiptData )
	
	elseif system.getInfo( 'platformName' ) == 'Android' then

		receiptData = formatReceiptOfGoogle( receiptData, identifier, signature )
	end
	return receiptData
end


-- 購入したアイテムの確認
function this.pushUserProduct( receiptPath )
	assert( receiptPath, 'ERROR : not found receiptPath' )

	local receiptData = readText( 'receipt/' .. receiptPath )
	
	print(receiptData)
	if receiptData and receiptData ~= '' then

		local function purchaseNetworkEventListener( e )
			if not e.isError then
				-- print( e.response )
				local data = json.decode( e.response )
				this.deleteReceipt( receiptPath )
				local event = 
				{
					name = 'inAppBilling-purchase-finish',
					phase = 'finished',
					data = data,
				}
				this:dispatchEvent( event )
			end
		end

		local params = {}
		params['token'] = userInfoData.token
		params['uid'] = userInfoData.id
		params['receipt'] = receiptData
		params['platform'] = system.getInfo( 'platformName' )
		params['publicKey'] = __publicKey 

		fnetwork.request( urlBase .. 'store/purchase.php', 'POST', purchaseNetworkEventListener, params )
	else
		this.deleteReceipt( receiptPath )
	end

end

-- 課金済のアイテムを再取得
function this.fetchUserProduct()
	if userInfoData and userInfoData.id then
		local is_exsist = existsDirectory( 'receipt' )
		if is_exsist then
			local doc_path = system.pathForFile( 'receipt', system.DocumentsDirectory )
		
			for file in lfs.dir( doc_path ) do
				 --file is the current file or directory name
				
				if file and file ~= '' and file ~= '.' and file ~= '..' then
					print( 'Found file: ', file )
					this.pushUserProduct( file )
				else
					print( 'Found not file!!' )
				end
		
			end
		else
			createDirectory( 'receipt' )
		end
	end
end


local function listener()

	local self = object.new()

	-- シミュレータでは動かない旨のポップアップ 
	if system.getInfo( 'platformName' ) ~= 'Android' and system.getInfo( 'platformName' ) ~= 'iPhone OS' then
		-- native.showAlert( 'Notice', 'In-app Billing are not supported in the Corona Simulator.', { 'OK' } )
	end

	-- 課金APIからのレスポンスを受け取るリスナー	
	local function transactionCallback( e )
		local transaction = e.transaction

		if transaction.state == 'purchased' then
			print('Transaction succuessful!')
			print('productIdentifier', transaction.productIdentifier)
			print('receipt', transaction.receipt)
			print('signature', transaction.signature)
			print('transactionIdentifier', transaction.identifier)
			print('date', transaction.date)

			self.consumePurchase( { transaction.productIdentifier } )

			local event = 
			{
				name = 'inAppBilling-purchase-transaction-finish',
				phase = 'purchased',
				transaction = transaction,
			}
			this:dispatchEvent( event )

		elseif	transaction.state == 'restored' then
			print('Transaction restored (from previous session)')
			print('productIdentifier', transaction.productIdentifier)
			print('receipt', transaction.receipt)
			print('transactionIdentifier', transaction.identifier)
			print('date', transaction.date)
			print('originalReceipt', transaction.originalReceipt)
			print('originalTransactionIdentifier', transaction.originalIdentifier)
			print('originalDate', transaction.originalDate)

			local event = 
			{
				name = 'inAppBilling-purchase-transaction-finish',
				phase = 'restored',
				transaction = transaction,
			}
			this:dispatchEvent( event )

		elseif transaction.state == 'cancelled' then
			print('User cancelled transaction')

			local event = 
			{
				name = 'inAppBilling-purchase-transaction-finish',
				phase = 'cancelled',
				transaction = transaction,
			}
			this:dispatchEvent( event )

		elseif transaction.state == 'failed' then
			print('Transaction failed, type:', transaction.errorType, transaction.errorString)
			
			local event = 
			{
				name = 'inAppBilling-purchase-transaction-finish',
				phase = 'failed',
				transaction = transaction,
			}
			this:dispatchEvent( event )

		else
			print('unknown event')

			local event = 
			{
				name = 'inAppBilling-purchase-transaction-finish',
				phase = 'unknown-event',
			}
			this:dispatchEvent( event )
		end

		store.finishTransaction( transaction )
	end

	-- ストア情報をイニシャライズする
	function self.init()
		-- OSによってストアのイニシャライズを変える
		if google_iap_v3 or store.availableStores.google then
			timer.performWithDelay( 1000, 
				function()
					store.init( transactionCallback )
				end
			)
		elseif store.availableStores.apple then
			store.init( 'apple', transactionCallback )
		else
			native.showAlert( 'Notice', 'In-app Billing are not supported in the Corona Simulator.', { 'OK' } )
		end
	end

	-- 購入処理を行う
	function self.purchase( productIdentifier )
		-- シミュレータでは動かない旨のポップアップ 
		if system.getInfo( 'platformName' ) ~= 'Android' and system.getInfo( 'platformName' ) ~= 'iPhone OS' then
			native.showAlert( 'Notice', 'In-app Billing are not supported in the Corona Simulator.', { 'OK' } )
		else
			if system.getInfo( 'platformName' ) == 'Android' then
				-- {"state":"failed","errorString":"Unable to buy item (response: 7:Item Already Owned)","isError":true,"errorType":7} のError
				-- store.consumePurchase( { productIdentifier } )
				store.purchase( productIdentifier )
			else
				store.purchase( { productIdentifier } )
			end
		end
	end

	-- ConsumeProductを消費したことを明示する
	function self.consumePurchase( productList )
		print(productList)
		if system.getInfo( 'platformName' ) == 'Android' then
			store.consumePurchase( productList, transactionCallback )
		end
	end
	
	-- リストアを行う
	function self.restore()
		-- シミュレータでは動かない旨のポップアップ 
		if system.getInfo( 'platformName' ) ~= 'Android' and system.getInfo( 'platformName' ) ~= 'iPhone OS' then
			native.showAlert( 'Notice', 'In-app Billing are not supported in the Corona Simulator.', { 'OK' } )
		else
			store.restore()
		end
	end

	-- 商品を読み込む
	function self.loadProducts( arrayOfProductIdentifiers )

		local function productCallback( e )
			if e.isError then
				print( e.errorType )
				print( e.errorString )
				return
			else
				local event = 
				{
					name = 'inAppBilling-loadProducts-finish',
					phase = 'finished',
					validProducts = e.products,
					invalidProducts = e.invalidProducts
				}
				self:dispatchEvent( event )
			end
		end

		if store.canLoadProducts then
			store.loadProducts( arrayOfProductIdentifiers, productCallback )
		end
	end

	-- ストア情報をイニシャライズする
	function self.init()
		-- OSによってストアのイニシャライズを変える
		if google_iap_v3 or store.availableStores.google then
			timer.performWithDelay( 1000, 
				function()
					store.init( transactionCallback )
				end
			)
		elseif store.availableStores.apple then
			store.init( 'apple', transactionCallback )
		else
			-- native.showAlert( 'Notice', 'In-app Billing are not supported in the Corona Simulator.', { 'OK' } )
			print( 'In-app Billing are not supported in the Corona Simulator.' )
		end
	end

	return self
end

function this.new()
	return listener()
end

return this

