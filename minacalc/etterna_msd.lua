local json = require("json")
local minacalc = require("minacalc.lib")
local math_util = require("math_util")

local EtternaMsd = {}

EtternaMsd.orderedSsr = {
	"overall",
	"stream",
	"jumpstream",
	"handstream",
	"stamina",
	"jackspeed",
	"chordjack",
	"technical",
}

---@param notes table
---@return table
---@return number
function EtternaMsd.getRows(notes)
	local row_count = 0
	local row_notes = 0
	local row_time = notes[1].time

	local bytes = { 1, 2, 4, 8 }
	local rows = {}

	for _, note in ipairs(notes) do
		if note.time ~= row_time then
			table.insert(rows, {
				notes = row_notes,
				time = row_time,
			})

			row_time = note.time
			row_notes = 0
			row_count = row_count + 1
		end

		row_notes = row_notes + bytes[note.column]
	end

	local c_rows = minacalc.noteInfo(row_count)

	for i = 0, row_count - 1, 1 do
		c_rows[i].notes = rows[i + 1].notes
		c_rows[i].rowTime = rows[i + 1].time
	end

	return c_rows, row_count
end

---@param notes table
---@return table?
function EtternaMsd.getMsds(notes)
	if not notes[1] then
		return nil
	end
	local rows, row_count = EtternaMsd.getRows(notes)
	return minacalc.getMsds(rows, row_count)
end

---@param notes table
---@param rate number
---@param accuracy number
---@return table
function EtternaMsd.getSsr(notes, rate, accuracy)
	if not notes[1] then
		return {}
	end
	local rows, row_count = EtternaMsd.getRows(notes)
	return minacalc.getSsr(rows, row_count, rate, accuracy)
end

local minRate = 7
local maxRate = 20

---@param msds table
---@param time_rate number
---@return table
function EtternaMsd.getApproximate(msds, time_rate)
	local floor = math_util.clamp(math.floor(time_rate * 10), minRate, maxRate)
	local ceil = math_util.clamp(math.ceil(time_rate * 10), minRate, maxRate)

	if floor == ceil then
		return msds[floor]
	end

	local a = msds[floor]
	local b = msds[ceil]

	local t = {}

	for k, _ in pairs(a) do
		t[k] = (a[k] + b[k]) / 2
	end

	return t
end

---@param notes table
---@param time_rate number
---@return table?
function EtternaMsd.getMsdForRate(notes, time_rate)
	if not notes[1] then
		return nil
	end

	local rows, row_count = EtternaMsd.getRows(notes)

	local msds = minacalc.getMsds(rows, row_count)
	return EtternaMsd.getApproximate(msds, time_rate)
end


---@param msds table
---@return string
function EtternaMsd.encode(msds)
	local t = {}

	for rate = minRate, maxRate do
		local patterns = {}

		for _, pattern in ipairs(EtternaMsd.orderedSsr) do
			table.insert(patterns, ("%0.02f"):format(msds[rate][pattern]))
		end

		table.insert(t, patterns)
	end

	return json.encode(t)
end

---@param str string
---@return table?
function EtternaMsd.decode(str)
	if not str or str == "" then
		return nil
	end

	local t = {}

	local patterns = json.decode(str)

	for rate = minRate, maxRate do
		t[rate] = {}
		for i, k in ipairs(EtternaMsd.orderedSsr) do
			t[rate][k] = tonumber(patterns[rate - 6][i])
		end
	end

	return t
end

---@param msd table<string, number>
function EtternaMsd.getMaxAndSecondFromMsd(msd)
	local max_value = 0
	local second_value = 0
	local max_key = nil
	local second_key = nil

	for key, value in pairs(msd) do
		value = tonumber(value)
		if value > max_value and key ~= "overall" then
			max_value = value
			max_key = key
		end
	end

	local threshold = max_value * 0.93
	for key, value in pairs(msd) do
		value = tonumber(value)
		if value < max_value and value >= threshold and value > second_value and key ~= "overall" then
			second_value = tonumber(value)
			second_key = key
		end
	end

	local output = max_key
	if second_key then
		output = output .. "\n" .. second_key
	end

	return output
end

---@param msd table<string, number>
---@return string
function EtternaMsd.getFirstFromMsd(msd)
	local max_key = "none"
	local max_value = 0

	for key, value in pairs(msd) do
		value = tonumber(value)
		if value > max_value and key ~= "overall" then
			max_value = value
			max_key = key
		end
	end

	return max_key
end

---@param pattern  string
---@return string
function EtternaMsd.simplifySsr(pattern)
	if pattern == "stream" then
		return "STR"
	elseif pattern == "jumpstream" then
		return "JS"
	elseif pattern == "handstream" then
		return "HS"
	elseif pattern == "stamina" then
		return "STMN"
	elseif pattern == "jackspeed" then
		return "JACK"
	elseif pattern == "chordjack" then
		return "CJ"
	elseif pattern == "technical" then
		return "TECH"
	end

	return "NONE"
end

---@param msd_data string
---@return table<string, number>?
function EtternaMsd.getMsdPatterns(msd_data)
	---@type table?
	local ssr = EtternaMsd.decode(msd_data)
	return ssr
end

---@return string[]
function EtternaMsd.getSsrPatternNames()
	return EtternaMsd.orderedSsr
end

---@param msd_data string
---@param time_rate number
---@return table<string, number>?
function EtternaMsd.getMsdFromData(msd_data, time_rate)
	---@type table?
	local msds = EtternaMsd.decode(msd_data)

	if msds then
		return EtternaMsd.getApproximate(msds, time_rate)
	end
end

return EtternaMsd
