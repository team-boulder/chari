module( ..., package.seeall )

local function listener()
	local self = {}

	self.listnersTable = {}

	-- リスナーを追加
	function self:addEventListener(listener)
		assert(listener, "ERROR : not found listener!")
		local allow = true
		for k, v in pairs(self.listnersTable) do
			if listener == v then
				allow = false
			end
		end
		if allow == true then
			-- リスナーを追加
			table.insert(self.listnersTable, listener)

			return 1
		else
			-- 既に追加済み
			return -1
		end
	end

	-- リスナーを除去
	function self:removeEventListener(listener)
		for k, v in pairs(self.listnersTable) do
			if listener == v then
				table.remove(self.listnersTable, k)
			end
		end
	end

	-- リスナーにイベントを渡す
	function self:dispatchEvent(event)
		for k, v in pairs(self.listnersTable) do
			v(event)
		end
	end

	return self
end

function new()
	return listener()
end