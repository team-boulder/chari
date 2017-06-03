local self = {}

-- blockの管理を開始

function self.genPet(blockGroup,listener)
		local block = {}
		local baseX,baseY = 30,250
		local pixelSize = 50

		for i,row in ipairs(playerInfoData['petdata']) do
			local array = {}
			for j,v in ipairs(row) do
				array[j] = display.newRect(blockGroup,baseX+j*pixelSize,baseY+i*pixelSize,pixelSize,pixelSize)
				array[j]:setFillColor(0)
				if v==1 then
					array[j]:setFillColor(255)
				elseif v==-1 then
					array[j]:setFillColor(0,0,0,0)
				end
				array[j].value = {i,j}
				array[j]:addEventListener('tap',listener)
			end
			table.insert(block,array)
		end

    return block
end

return self
