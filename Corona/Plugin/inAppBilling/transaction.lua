-- transaction.lua
-- Comment : transaction.lua
-- Date : 2015-5-11
-- Creater : Ryo Takahashi
-----------------------------------------------

module( ... , package.seeall )

dir = "deal"

-- 新しいtransaction_id発行
function new(num)
	if userInfoData.id then
		local num = tonumber( num  )
		local uid = userInfoData.id
		local str = tostring( os.date("%s") .. string.format( "%09d", num) .. uid .. math.random(0, 1000000) )
		local transaction_id = crypto.digest( crypto.sha256, str )
		return transaction_id
	else
		return -1
	end
end


-- deal_tokenとtransaction_idの保存
function save(transaction_id, deal_token)
	assert(transaction_id , "ERROR : not found transaction_id!")
	assert(deal_token, "ERROR : not found deal_token!" )

	local e = nil
	
	-- ディレクトリチェック
	-- -- if checkDocument( dir ) then
	-- 	createDirectory( dir, system.DocumentsDirectory )
	-- -- end

	-- 同じdeal_token名のテキストがないかチェック
	local file_name = deal_token .. ".json"
	local path = system.pathForFile( dir.."/"..file_name, system.TemporaryDirectory )
	local fhd = io.open( path )
	if fhd then
		-- 同じのがある時
		return -1

	elseif not transaction_id or not deal_token then
		-- 引数が足りない時
		return -1

	else
		-- 成功
		local data = json.encode( {transaction_id=transaction_id, deal_token=deal_token} )
		writeText(dir.."/"..file_name, data)
		return 0
	end
	-- 成功

end

-- deal_tokenがないか確認する
function check()
	local is_exsist = existsDirectory( 'deal' )
	if is_exsist then
		local doc_path = system.pathForFile( 'deal', system.DocumentsDirectory )
	
		for file in lfs.dir( doc_path ) do
			 --file is the current file or directory name
			
			if file and file ~= '' and file ~= '.' and file ~= '..' and file ~= '.DS_Store' then
				print( 'Found file: ' .. file )
				local file_path = system.pathForFile( 'deal/'..file , system.DocumentsDirectory )
				local fh, reason = io.open( file_path, "r" )
				local contents = fh:read("*a")
				contents = json.decode(contents)

				local deal_token = contents.deal_token
				local transaction_id = contents.transaction_id
				restore(transaction_id ,deal_token)
			end
	
		end
	else
		createDirectory( 'deal' )
	end	
end

-- 未処理のdeal_tokenを処理する
function restore(transaction_id, deal_token)
	local function listener(event)

		local data = json.decode(event.response)
		print(event.response)
		-- deal_token ファイル削除
		if data.deletable == true then
			destroy(data.deal_token)
		end
	end

	--付加するパラメータ
	local params = {}
	params["token"] = userInfoData.token
	params["uid"] = userInfoData.id
	params["transaction_id"] = transaction_id
	params["deal_token"] = deal_token

	fnetwork.request(urlBase .. "deal/restore.php", "POST",listener, params)	
end

-- deal_tokenのtext削除する
function destroy(deal_token)
	local filename = deal_token..".json"
	deleteDocument(filename, dir)
end
