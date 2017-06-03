local self = object.new()

self.dist = 0
self.maxScore = 0

--ランダム
local function typeBool()
    local number  = math.random(0,100)
    if number < 5 then
        local event =
        {
            name = "play_model-bool",
        } 
        self:dispatchEvent( event )
    end
end

function self.typeRandom()
    local type = math.random(0,4)
    return type
end

--距離測定
local function distance()
    self.dist = self.dist + 1
    local event =
    {
        name = "play_model-distance",
        dist = self.dist
    } 
    self:dispatchEvent( event )
end

local function listener(event)
    -- 現在のキョリをカウントする関数
    distance()

    -- 障害物の発生を決めるよ
    typeBool()
end

-- 初期化()
function self.init()
    self.time = timer.performWithDelay(100,listener, -1)
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
