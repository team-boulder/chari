-- ProjectName : cosmo
--
-- Filename : emitter_model.lua
--
-- Creater : Ryo Takahashi
--
-- Date : 2016-09-21
--
-- Comment : emitter_list
--
--パーティクル読み込み
--1:背景降るブロック
---------------------------------------------------------
this = {}
this.params = {}

-- 事前読み込みしないリスト
local not_require = {}

-- initialize
local function init()
	for i=1,7 do
		if table.search(i, not_require) == false then
			local filePath = system.pathForFile( "Emitter/"..i..".json" )
			local f = io.open( filePath, "r" )
			local fileData = f:read( "*a" )
			f:close()
			this.params[i] = json.decode( fileData )
		else
		end
	end
end
init()

return this
