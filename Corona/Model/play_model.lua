local self = {}

self.dist = 0
self.maxScore = 0

local function listener(event)
    self.dist = self.dist + 1
    print(self.dist)
end

--距離測定
function self.distance()
    self.time = timer.performWithDelay(10,listener, -1)
    --[[local event =
    {
        name = "play_model-distance",
        dist = self.dist
    } 
    self:dispatchEvent( event )]]--
end

--タイマーストップ
function self.stopTimer()
    self.dist = 0
    timer.cancel(self.time)
end

--スコアセーブ
function self.scoreSave()
    self.maxScore = playerInfoData['max_score']
    if self.maxScore < self.dist then
        playerInfoData['max_score'] = self.dist
        playerInfo.save()
    end
end


return self
