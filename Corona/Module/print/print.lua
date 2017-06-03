_print = print
local _isDebug = __isDebug

local function tsstring(o)
    return '"' .. tostring(o) .. '"'
end
 
local function recurse(o, indent)
	if indent == nil then indent = '' end
	local indent2 = indent .. '  '
	if type(o) == 'table' then
		local s = indent .. '{' .. '\n'
		local first = true
		for k,v in pairs(o) do
			if first == false then s = s .. ', \n' end
			if type(k) ~= 'number' then k = tsstring(k) end
			s = s .. indent2 .. '[' .. k .. '] = ' .. recurse(v, indent2)
			first = false
		end
		return s .. '\n' .. indent .. '}'
	else
		return tsstring(o)
	end
end
 
local function printTable(table, prefix)
	if not prefix then
		prefix = "### "
	end
	if _isDebug == true then 
		if type(table) == "table" then
			for key, value in pairs(table) do
				if type(value) == "table" then
					_print(prefix .. tostring(key))
					_print(prefix .. "{")
					printTable(value, prefix .. "   ")
					_print(prefix .. "}")
				else
					_print(prefix .. tostring(key) .. ": " .. tostring(value))
				end
			end
		end
	end
end

local function tsprint( str1, str2, str3, str4, str5, str6, str7, str8, str9, str10)
	if _isDebug == true then
		if type(str1) == "table" then
			printTable(str1)
		else
			if str2 == nil then str2 = "" end 
			if str3 == nil then str3 = "" end 
			if str4 == nil then str4 = "" end 
			if str5 == nil then str5 = "" end 
			if str6 == nil then str6 = "" end 
			if str7 == nil then str7 = "" end 
			if str8 == nil then str8 = "" end 
			if str9 == nil then str9 = "" end 
			if str10 == nil then str10 = "" end 
			_print( tostring(str1), tostring(str2), tostring(str3), tostring(str4), tostring(str5), tostring(str6), tostring(str7), tostring(str8), tostring(str9), tostring(str10))
		end
	end
end

function print( str1, str2, str3, str4, str5, str6, str7, str8, str9, str10)
	local debugInfo = debug.getinfo(2)
	local fileName = debugInfo.source:match("[^/]*$")
	local currentLine = debugInfo.currentline

	if type(str1) == "table" then
		tsprint(fileName..":"..currentLine..":")
		tsprint( str1, str2, str3, str4, str5, str6, str7, str8, str9, str10)
	else
		tsprint( fileName..":"..currentLine..":",str1, str2, str3, str4, str5, str6, str7, str8, str9, str10)
	end
end
