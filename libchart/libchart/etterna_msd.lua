local json = require("json")
local minacalc = require("libchart.libchart.minacalc")
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
local function getRows(notes)
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

	local rows, row_count = getRows(notes)

	return minacalc.getMsds(rows, row_count)
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

	local rows, row_count = getRows(notes)

	local msds = minacalc.getMsds(rows, row_count)
	return EtternaMsd.getApproximate(msds, time_rate)
end

---@param msds table
---@return string
function EtternaMsd:encode(msds)
	local t = {}

	for rate = minRate, maxRate do
		local patterns = {}

		for _, pattern in ipairs(self.orderedSsr) do
			table.insert(patterns, ("%0.02f"):format(msds[rate][pattern]))
		end

		table.insert(t, patterns)
	end

	return json.encode(t)
end

---@param str string
---@return table?
function EtternaMsd:decode(str)
	if not str then
		return nil
	end

	local t = {}

	local patterns = json.decode(str)

	for rate = minRate, maxRate do
		t[rate] = {}
		for i, k in ipairs(self.orderedSsr) do
			t[rate][k] = tonumber(patterns[rate - 6][i])
		end
	end

	return t
end

function EtternaMsd.getVersion()
	return "0.1.2"
end

return EtternaMsd
