local json = require("json")
local minacalc = require("libchart.libchart.minacalc")

local EtternaSsr = {}

EtternaSsr.orderedPatterns = {
	"stream",
	"jumpstream",
	"handstream",
	"stamina",
	"jackspeed",
	"chordjack",
	"technical",
}

function EtternaSsr.getSsr(notes, timeRate)
	local rowCount = 0
	local rowNotes = 0

	if not notes[1] then
		return nil
	end

	local rowTime = notes[1].time

	local bytes = { 1, 2, 4, 8 }
	local luaRows = {}

	for _, note in ipairs(notes) do
		if note.time ~= rowTime then
			table.insert(luaRows, {
				notes = rowNotes,
				time = rowTime,
			})

			rowTime = note.time
			rowNotes = 0
			rowCount = rowCount + 1
		end

		rowNotes = rowNotes + bytes[note.column]
	end

	local rows = minacalc.noteInfo(rowCount)

	for i = 0, rowCount - 1, 1 do
		rows[i].notes = luaRows[i + 1].notes
		rows[i].rowTime = luaRows[i + 1].time
	end

	return minacalc.getSsr(rows, rowCount, timeRate)
end

function EtternaSsr:encodePatterns(ssr)
	ssr.overall = nil

	local t = {}

	for _, k in ipairs(self.orderedPatterns) do
		table.insert(t, ("%0.02f"):format(ssr[k]))
	end

	return json.encode(t)
end

function EtternaSsr:decodePatterns(str)
	local patterns = json.decode(str)

	local t = {}

	for i, k in ipairs(self.orderedPatterns) do
		t[k] = patterns[i]
	end

	return t
end

local function test()
	local rowCount = 1000
	local bytes = {
		0b0110,
		0b1111,
		0b1011,
		0b1111,
		0b1100,
		0b1111,
		0b0110,
		0b1111,
		0b1001,
		0b1111,
	}

	local rows = minacalc.noteInfo(rowCount)

	for i = 0, 1000 - 1, 1 do
		rows[i].notes = bytes[(i % 10) + 1]
		rows[i].rowTime = i * 0.05
	end

	local ssr = minacalc.getSsr(rows, rowCount, 1.0)
	local overall = ssr.overall
	assert(overall > 38 and overall < 39, "Mina calculator is broken, IT'S OVER. " .. overall)
end

test()

return EtternaSsr
