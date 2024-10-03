local ffi = require("ffi")
local path_util = require("path_util")

local minacalc_lib = {}

ffi.cdef([[
	typedef struct NoteInfo
	{
		unsigned int notes;
		float rowTime;
	} NoteInfo;

	typedef struct CalcHandle {} CalcHandle;

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

	typedef struct MsdForAllRates {
		// one for each full-rate from 0.7 to 2.0 inclusive
		Ssr msds[14];
	} MsdForAllRates;

	int calc_version();

	CalcHandle *create_calc();

	void destroy_calc(CalcHandle *calc);

	MsdForAllRates calc_msd(CalcHandle *calc, const NoteInfo *rows, size_t num_rows, const unsigned int keycount);
	Ssr calc_ssr(CalcHandle *calc, NoteInfo *rows, size_t num_rows, float music_rate, float score_goal, const unsigned int keycount);
]])

local lib_path = jit.os == "Windows" and "bin/win64/libminacalc.dll" or "bin/linux64/libminacalc.so"

if not love.filesystem.getInfo(lib_path) then
	return -- Other plugin loaded before minacalc, this plugin will copy library to bin and restart the game later.
end

local lib = ffi.load(lib_path)
local calc_handle = lib.create_calc()
print(("minacalc %i handle created"):format(lib.calc_version()))

---@param size number
---@return ffi.cdata*
function minacalc_lib.noteInfo(size)
	if not size then
		return ffi.new("NoteInfo")
	end

	return ffi.new("NoteInfo[?]", size)
end

---@param rows ffi.cdata*
---@param row_count number
---@param key_count number
---@return table
function minacalc_lib.getMsds(rows, row_count, key_count)
	local result = lib.calc_msd(calc_handle, rows, row_count, key_count)

	local t = {}

	for i = 0, 13, 1 do
		local v = result.msds[i]

		t[i + 7] = {
			overall = v.overall,
			stream = v.stream,
			jumpstream = v.jumpstream,
			handstream = v.handstream,
			stamina = v.stamina,
			jackspeed = v.jackspeed,
			chordjack = v.chordjack,
			technical = v.technical,
		}
	end

	return t
end

---@param rows ffi.cdata*
---@param row_count number
---@param time_rate number
---@param target_accuracy number
---@param keycount number
---@return table
function minacalc_lib.getSsr(rows, row_count, time_rate, target_accuracy, keycount)
	local ssr = lib.calc_ssr(calc_handle, rows, row_count, time_rate, target_accuracy, keycount)

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
	local row_count = 1000
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

	local rows = minacalc_lib.noteInfo(row_count)

	for i = 0, 1000 - 1, 1 do
		rows[i].notes = bytes[(i % 10) + 1]
		rows[i].rowTime = i * 0.05
	end

	local ssr = minacalc_lib.getSsr(rows, row_count, 1.0, 0.93, 4)
	local overall = ssr.overall
	assert(overall > 30, "RESTART THE GAME!!! MinaCalc is not feeling good for some reason." .. overall)
	print("minacalc ok")
end

local function test7k()
	print(" ----- 7K ----- ")
	local row_count = 1000
	local bytes = {
		0b0101010,
		0b1010101,
		0b0001000,
		0b0100010,
		0b1010100,
		0b0100001,
		0b0001010,
	}

	local rows = minacalc_lib.noteInfo(row_count)

	for i = 0, 1000 - 1, 1 do
		rows[i].notes = bytes[(i % #bytes) + 1]
		rows[i].rowTime = i * 0.125
	end

	local ssr = minacalc_lib.getSsr(rows, row_count, 1.0, 0.93, 8)

	print("streams:", ssr.stream)
	print("brackets:", ssr.handstream)
	print("chordstream:", ssr.jumpstream)
	print("chordjack:", ssr.chordjack)
end

test()
test7k()

return minacalc_lib
