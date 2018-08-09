-- Copyright (C) 2018  The Dota IMBA Development Team
-- Copyright (C) 2015  rxi
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- Editors:
--     suthernfriend, 03.02.2018
--


local json = { _version = "0.1.0" }

local char
do
	local ok, utf8 = pcall(require, 'utf8')
	if ok then
		local ch = utf8.char(0xD6)

		if ch == 'Ö' or ch == string.char(0xC3, 0x96) then
			char = utf8.char
		end
	end
end

-------------------------------------------------------------------------------
-- Null Representation
-------------------------------------------------------------------------------

local null = setmetatable({}, {
	__tostring = function ()
		return "null"
	end
})

json.null = null

-------------------------------------------------------------------------------
-- Encode
-------------------------------------------------------------------------------

local encode

local escape_char_map = {
	[ "\\" ] = "\\\\",
	[ "\"" ] = "\\\"",
	[ "\b" ] = "\\b",
	[ "\f" ] = "\\f",
	[ "\n" ] = "\\n",
	[ "\r" ] = "\\r",
	[ "\t" ] = "\\t",
}

local escape_char_map_inv = { [ "\\/" ] = "/" }
for k, v in pairs(escape_char_map) do
	escape_char_map_inv[v] = k
end

local function escape_char(c)
	return escape_char_map[c] or string.format("\\u%04x", c:byte())
end

local function encode_nil()
	return "null"
end

local function encode_table(val, stack)
	if val == null then
		return "null"
	end

	local res = {}
	stack = stack or {}

	-- Circular reference?
	if stack[val] then error("Invalid table: circular reference") end

	stack[val] = true

	if val[1] ~= nil or next(val) == nil then
		-- Treat as array -- check keys are valid and it is not sparse
		local n = 0
		for k in pairs(val) do
			if type(k) ~= "number" then
				error("Invalid table: mixed or invalid key types")
			end
			n = n + 1
		end

		if n ~= #val then
			error("Invalid table: sparse array")
		end
		-- Encode
		for _, v in ipairs(val) do
			table.insert(res, encode(v, stack))
		end

		stack[val] = nil

		return "[" .. table.concat(res, ",") .. "]"
	else
		-- Treat as an object
		for k, v in pairs(val) do
			if type(k) ~= "string" then
				error("Invalid table: mixed or invalid key types")
			end

			table.insert(res, encode(k, stack) .. ":" .. encode(v, stack))
		end

		stack[val] = nil

		return "{" .. table.concat(res, ",") .. "}"
	end
end

local function encode_string(val)
	return '"' .. val:gsub('[%z\1-\31\\"]', escape_char) .. '"'
end

local function encode_number(val)
	-- Check for NaN, -inf and inf
	if val ~= val or val <= -math.huge or val >= math.huge then
		error("Unexpected number value '" .. tostring(val) .. "'")
	end

	return string.format("%.14g", val)
end

local type_func_map = {
	[ "nil"     ] = encode_nil,
	[ "table"   ] = encode_table,
	[ "string"  ] = encode_string,
	[ "number"  ] = encode_number,
	[ "boolean" ] = tostring,
}

encode = function(val, stack)
	local t = type(val)
	local f = type_func_map[t]

	if f then
		return f(val, stack)
	end

	error("Unexpected type '" .. t .. "'")
end

function json.encode(val)
	return (encode(val))
end

-------------------------------------------------------------------------------
-- Decode
-------------------------------------------------------------------------------

local parse

local function create_set(...)
	local res = {}

	for i = 1, select("#", ...) do
		res[ select(i, ...) ] = true
	end

	return res
end

local space_chars   = create_set(" ", "\t", "\r", "\n")
local delim_chars   = create_set(" ", "\t", "\r", "\n", "]", "}", ",")
local escape_chars  = create_set("\\", "/", '"', "b", "f", "n", "r", "t", "u")
local literals      = create_set("true", "false", "null")

local literal_map = {
	[ "true"  ] = true,
	[ "false" ] = false,
	[ "null"  ] = null,
}

local function next_char(str, idx, set, negate)
	for i = idx, #str do
		if set[str:sub(i, i)] ~= negate then
			return i
		end
	end

	return #str + 1
end

local function decode_error(str, idx, msg)
	local line_count = 1
	local col_count = 1

	for i = 1, idx - 1 do
		col_count = col_count + 1
		if str:sub(i, i) == "\n" then
			line_count = line_count + 1
			col_count = 1
		end
	end

	error(string.format("%s at line %d col %d", msg, line_count, col_count))
end

local codepoint_to_utf8 = char or function (n)
	-- http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=iws-appendixa
	local f = math.floor

	if n <= 0x7F then
		return string.char(n)
	elseif n <= 0x7FF then
		return string.char(f(n / 0x40) + 0xC0, n % 0x40 + 0x80)
	elseif n <= 0xFFFF then
		return string.char(f(n / 0x1000) + 0xE0, f(n % 0x1000 / 0x40) + 0x80, n % 0x40 + 0x80)
	elseif n <= 0x10FFFF then
		local a, b = f(n / 0x40000) + 0xF0, f(n % 0x40000 / 0x1000) + 0x80
		local c, d = f(n % 0x1000 / 0x40) + 0x80, n % 0x40 + 0x80
		return string.char(a, b, c, d)
	end

	error(string.format("Invalid unicode codepoint '%x'", n))
end

local function parse_unicode_escape(s)
	local n1 = tonumber(s:sub(3, 6),  16)
	local n2 = tonumber(s:sub(9, 12), 16)
	-- Surrogate pair?
	if n2 then
		return codepoint_to_utf8((n1 - 0xD800) * 0x400 + (n2 - 0xDC00) + 0x10000)
	else
		return codepoint_to_utf8(n1)
	end
end

local function parse_string(str, i)
	local has_unicode_escape = false
	local has_surrogate_escape = false
	local has_escape = false
	local last

	for j = i + 1, #str do
		local x = str:byte(j)

		if x < 32 then
			decode_error(str, j, "Control character in string")
		end

		if last == 92 then -- "\\" (escape char)
			if x == 117 then -- "u" (unicode escape sequence)
				local hex = str:sub(j + 1, j + 5)

				if not hex:find("%x%x%x%x") then
					decode_error(str, j, "Invalid unicode escape in string")
				end
				if hex:find("^[dD][89aAbB]") then
					has_surrogate_escape = true
				else
					has_unicode_escape = true
				end
		else
			local c = string.char(x)

			if not escape_chars[c] then
				decode_error(str, j, "Invalid escape char '" .. c .. "' in string")
			end

			has_escape = true
		end

		last = nil
		elseif x == 34 then -- '"' (end of string)
			local s = str:sub(i + 1, j - 1)

			if has_surrogate_escape then
				s = s:gsub("\\u[dD][89aAbB]..\\u....", parse_unicode_escape)
			end
			if has_unicode_escape then
				s = s:gsub("\\u....", parse_unicode_escape)
			end
			if has_escape then
				s = s:gsub("\\.", escape_char_map_inv)
			end

			return s, j + 1
		else
			last = x
		end
	end

	decode_error(str, i, "Expected closing quote for string")
end

local function parse_number(str, i)
	local x = next_char(str, i, delim_chars)
	local s = str:sub(i, x - 1)
	local n = tonumber(s)

	if not n then
		decode_error(str, i, "Invalid number '" .. s .. "'")
	end

	return n, x
end

local function parse_literal(str, i)
	local x = next_char(str, i, delim_chars)
	local word = str:sub(i, x - 1)

	if not literals[word] then
		decode_error(str, i, "Invalid literal '" .. word .. "'")
	end

	return literal_map[word], x
end

local function parse_array(str, i)
	local res = {}
	local n = 1
	i = i + 1

	while 1 do
		local x
		i = next_char(str, i, space_chars, true)
		-- Empty / end of array?
		if str:sub(i, i) == "]" then
			i = i + 1
			break
		end
		-- Read token
		x, i = parse(str, i)
		res[n] = x
		n = n + 1
		-- Next token
		i = next_char(str, i, space_chars, true)
		local chr = str:sub(i, i)
		i = i + 1

		if chr == "]" then break end
		if chr ~= "," then decode_error(str, i, "Expected ']' or ','") end
	end

	return res, i
end


local function parse_object(str, i)
	local res = {}
	i = i + 1

	while 1 do
		local key, val
		i = next_char(str, i, space_chars, true)
		-- Empty / end of object?
		if str:sub(i, i) == "}" then
			i = i + 1
			break
		end
		-- Read key
		if str:sub(i, i) ~= '"' then
			decode_error(str, i, "Expected string for key")
		end
		key, i = parse(str, i)
		-- Read ':' delimiter
		i = next_char(str, i, space_chars, true)
		if str:sub(i, i) ~= ":" then
			decode_error(str, i, "Expected ':' after key")
		end
		i = next_char(str, i + 1, space_chars, true)
		-- Read value
		val, i = parse(str, i)
		-- Set
		res[key] = val
		-- Next token
		i = next_char(str, i, space_chars, true)
		local chr = str:sub(i, i)
		i = i + 1

		if chr == "}" then break end
		if chr ~= "," then decode_error(str, i, "Expected '}' or ','") end
	end

	return res, i
end

local char_func_map = {
	[ '"' ] = parse_string,
	[ "0" ] = parse_number,
	[ "1" ] = parse_number,
	[ "2" ] = parse_number,
	[ "3" ] = parse_number,
	[ "4" ] = parse_number,
	[ "5" ] = parse_number,
	[ "6" ] = parse_number,
	[ "7" ] = parse_number,
	[ "8" ] = parse_number,
	[ "9" ] = parse_number,
	[ "-" ] = parse_number,
	[ "t" ] = parse_literal,
	[ "f" ] = parse_literal,
	[ "n" ] = parse_literal,
	[ "[" ] = parse_array,
	[ "{" ] = parse_object,
}

parse = function(str, idx)
	local chr = str:sub(idx, idx)
	local f = char_func_map[chr]

	if f then
		return f(str, idx)
	end

	decode_error(str, idx, "Unexpected character '" .. chr .. "'")
end

function json.decode(str)
	if type(str) ~= "string" then
		error("Expected argument of type string, got " .. type(str))
	end

	return (parse(str, next_char(str, 1, space_chars, true)))
end

return json
