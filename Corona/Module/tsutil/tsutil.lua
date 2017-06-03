--[[
  便利関数群
]]

-- pathからファイル名を取り出す
function basename(path)
    name = string.gsub(path, '.*/', '')
    name = string.gsub(name, "%.dds$", "")
    return name
end

function getPath(path,sep)
    sep=sep or'/'
    return path:match("(.*"..sep..")")
end

--- for string.random
local Chars = {}
for Loop = 0, 255 do
   Chars[Loop+1] = string.char(Loop)
end
local String = table.concat(Chars)

local Built = {['.'] = Chars}

local AddLookup = function(CharSet)
   local Substitute = string.gsub(String, '[^'..CharSet..']', '')
   local Lookup = {}
   for Loop = 1, string.len(Substitute) do
       Lookup[Loop] = string.sub(Substitute, Loop, Loop)
   end
   Built[CharSet] = Lookup

   return Lookup
end

-- ランダムな文字列を返す
function string.random(Length, CharSet)
   -- Length (number)
   -- CharSet (string, optional); e.g. %l%d for lower case letters and digits

   local CharSet = CharSet or '.'

   if CharSet == '' then
      return ''
   else
      local Result = {}
      local Lookup = Built[CharSet] or AddLookup(CharSet)
      local Range = table.getn(Lookup)

      for Loop = 1,Length do
         Result[Loop] = Lookup[math.random(1, Range)]
      end

      return table.concat(Result)
   end
end

-- Extend tostring to work better on tables
-- make it output in {a,b,c...;x1=y1,x2=y2...} format; use nexti
-- only output the LH part if there is a table.n and members 1..n
--   x: object to convert to string
-- returns
--   s: string representation
function my_tostring(x)
  local s
  if type(x) == "table" then
    s = "{"
    local i, v = next(x)
    while i do
      s = s .. tostring(i) .. "=" .. tostring(v)
      i, v = next(x, i)
      if i then s = s .. "," end
    end
    return s .. "}"
  else return tostring(x)
  end
end

function startsWith(self, piece)
  return string.sub(self, 1, string.len(piece)) == piece
end

-- テーブルの中身を検索
function table.search(word, t)
  local res = false
  for k, v in pairs(t) do
    if word == v then
      res = k
    end
  end
  return res
end

local _math_random = math.random
function math.random(min, max)
  if max == nil then
    max = min
    min = 1
  end
  if tonumber(min) < 0 then
    return _math_random(0, max-min) + min

  else
     return _math_random(min, max)

  end
end