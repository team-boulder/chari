local self = {}

--各アイテムの値
self.speed_values   	= {5000,4000,4000,700,500}
self.food_values   	  = {20,40,60,80,100}
self.limit_values   	= {1000,10000,20000,50000,100000}

--各アイテム購入に必要なブロック数のリスト
self.speed_moneyList   	= {10,20,30,40,50}
self.food_moneyList   	= {10,20,30,40,50}
self.evol_moneyList   	= {10,20,30,40,50}
self.limit_moneyList   	= {1000,10000,20000,50000,100000}

function self.loadStatus()
  --現在の各ステータス
  self.current_speed 	= self.speed_values[playerInfoData['buy_items'][1]]
  self.current_food 	= self.food_values[playerInfoData['buy_items'][2]]
  self.current_limit 	= self.limit_values[playerInfoData['buy_items'][4]]

  --次の開放に必要なブロック数
  self.speedMoney = self.speed_moneyList[playerInfoData['buy_items'][1]]
  self.foodMoney  = self.food_moneyList[playerInfoData['buy_items'][2]]
  self.evolMoney  = self.evol_moneyList[playerInfoData['buy_items'][3]]
  self.limitMoney = self.limit_moneyList[playerInfoData['buy_items'][4]]
end

function self.init()
  self.second = timer.performWithDelay(3000,function()
    if self.current_limit <= playerInfoData['block'] then
      playerInfoData['block'] = self.current_limit
      playerInfo.save()
    else
      playerInfoData['block'] = playerInfoData['block'] + 1
      playerInfo.save()
    end
  end,-1)
end


function self.speedUp()
  playerInfoData['block'] = playerInfoData['block'] - self.speedMoney
  playerInfoData['buy_items'][1] = playerInfoData['buy_items'][1] + 1
  playerInfo.save()
  self.loadStatus()
end

function self.foodUp()
  playerInfoData['block'] = playerInfoData['block'] - self.foodMoney
  playerInfoData['buy_items'][2] = playerInfoData['buy_items'][2] + 1
  playerInfo.save()
  self.loadStatus()
end

function self.evol()
  playerInfoData['block'] = playerInfoData['block'] - self.evolMoney
  playerInfoData['buy_items'][3] = playerInfoData['buy_items'][3] + 1
  playerInfoData['pet_tap'] = playerInfoData['pet_tap'] + 1
  playerInfo.save()
  self.loadStatus()
end

function self.limitUp()
  playerInfoData['block'] = playerInfoData['block'] - self.limitMoney
  playerInfoData['buy_items'][4] = playerInfoData['buy_items'][4] + 1
  playerInfoData['size'] = (playerInfoData['block']+block_model.current_limit*0.1)/block_model.current_limit
  playerInfo.save()
  self.loadStatus()
end

self.loadStatus()
return self
