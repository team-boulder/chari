module(..., package.seeall)

--FPSの定義、コンテンツに合わせる
local content_fps = 60

--カウンタ表示用

displayObject = display.newGroup()

-- local rectFront = display.newRect( 0, 0, display.contentWidth, 60 )
-- rectFront:setFillColor( 0, 180 )
-- displayObject:insert( rectFront )

local textFront  = display.newText("",   display.contentWidth/2,   5, native.systemFont, 20 )
textFront:setFillColor ( 255 )
displayObject:insert( textFront )

local urlFront  = display.newText("",   display.contentWidth/2,   _H-50, native.systemFont, 24 )
urlFront:setFillColor ( 255 )
displayObject:insert( urlFront )

--

local frame_count = 0
local count_num = 0
local total_frame = 0

local cpu_count = 0
local cpu_per = 0
local cpu_ms = 0

--

local function cpuChecker()
    cpu_count = cpu_count + 1
    local d = cpu_count % content_fps
    if d == 1 then
        cpu_ms = os.clock()
    elseif d == 0 then
        cpu_ms = os.clock()-cpu_ms
        cpu_per = math.floor(cpu_ms*100)
    end
end

local function enterframeCheck( event )
    frame_count = frame_count+1
    cpuChecker()
end


local function oneSecondCheck( event )
    count_num = count_num + 1
    total_frame = total_frame + frame_count

    local ave = math.floor( 10*total_frame/count_num )/10
    local mem = math.floor( collectgarbage( "count" )/1024*100)/100
    local tex = math.floor( system.getInfo( "textureMemoryUsed" )/1024/1024*100)/100

    local disp = "FPS:"..frame_count .. "  AVE:".. ave .."  MEM:"..mem.."MB".."  TEX:"..tex.."MB  ".."CPU:"..cpu_per.."%"
    textFront.text , urlFront.text = disp, urlBase

    -- print( disp )

    frame_count = 0
end

Runtime:addEventListener( "enterFrame", enterframeCheck )
timer.performWithDelay( 1000, oneSecondCheck , 0 )