local ffi = require("ffi")
local lib

if jit.os == "Windows" then
	lib = ffi.load("moddedgame/MinaCalc/bin/win64/libminacalc.dll")
else
	lib = ffi.load("moddedgame/MinaCalc/bin/linux64/libminacalc.so")
end

ffi.cdef([[
	typedef struct CalcHandle {} CalcHandle;
	CalcHandle *create_calc();
	void destroy_calc(CalcHandle *calc);

	typedef struct Ssr {
		float overall;
		float stream;
		float jumpstream;
		float handstream;
		float stamina;
		float jackspeed;
		float chordjack;
		float technical;
	} Ssr;

	typedef struct NoteInfo {
		unsigned int notes;
		float rowTime;
	} NoteInfo;

	int calc_version();
	Ssr calc_ssr(CalcHandle *calc, NoteInfo *rows, size_t num_rows, float music_rate, float score_goal);
]])

local calcHandle = lib.create_calc()

local MinaCalc = {}

function MinaCalc.getSsr(notes, timeRate)
	local row_count = 0
	local row_notes = 0

	if not notes[1] then
		return nil
	end

	local row_time = notes[1].time

	local bytes = { 1, 2, 4, 8 }
	local luaRows = {}

	for _, note in ipairs(notes) do
		if note.time ~= row_time then
			table.insert(luaRows, {
				notes = row_notes,
				time = row_time,
			})

			row_time = note.time
			row_notes = 0
			row_count = row_count + 1
		end

		row_notes = row_notes + bytes[note.column]
	end

	local rows = ffi.new(("NoteInfo[%i]"):format(row_count))

	for i = 0, row_count - 1, 1 do
		rows[i].notes = luaRows[i + 1].notes
		rows[i].rowTime = luaRows[i + 1].time
	end

	local ssr = lib.calc_ssr(calcHandle, rows, row_count, timeRate, 0.93)

	return {
		overall = ssr.overall,
		stream = ssr.stream,
		jumpstream = ssr.jumpstream,
		handstream = ssr.handstream,
		stamina = ssr.stamina,
		jackspeed = ssr.jackspeed,
		chordjack = ssr.chordjack,
		technical = ssr.technical,
	}
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

	local rows = ffi.new(("NoteInfo[%i]"):format(rowCount))

	for i = 0, 1000, 1 do
		rows[i].notes = bytes[(i % 10) + 1]
		rows[i].rowTime = i * 0.05
	end

	local ssr = lib.calc_ssr(calcHandle, rows, rowCount, 1.0, 0.93)
	local overall = ssr.overall
	assert(overall > 38 and overall < 39, "Mina calculator is broken, IT'S OVER. " .. overall)
end

test()

return MinaCalc
