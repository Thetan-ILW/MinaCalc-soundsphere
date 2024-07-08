local ffi = require("ffi")

if MinaCalc then
	return MinaCalc
end

MinaCalc = {}

local file = jit.os == "Windows" and "win64/libminacalc.dll" or "linux64/libminacalc.so"
local lib_path = "bin/" .. file

if love.filesystem.getInfo("moddedgame/MinaCalc/bin/" .. file) then
	lib_path = "moddedgame/MinaCalc/bin/" .. file
end

local lib = ffi.load(lib_path)

ffi.cdef([[
	typedef struct CalcHandle {} CalcHandle;
	CalcHandle *create_calc();

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

	typedef struct MsdForAllRates {
		Ssr msds[14];
	} MsdForAllRates;

	Ssr calc_ssr(CalcHandle *calc, NoteInfo *rows, size_t num_rows, float music_rate, float score_goal);
	MsdForAllRates calc_msd(CalcHandle *calc, const NoteInfo *rows, size_t num_rows);
]])

local calcHandle = lib.create_calc()

---@param size number
---@return ffi.cdata*
function MinaCalc.noteInfo(size)
	if not size then
		return ffi.new("NoteInfo")
	end

	return ffi.new(("NoteInfo[%i]"):format(size))
end

---@param rows ffi.cdata*
---@param row_count number
---@return table
function MinaCalc.getMsds(rows, row_count)
	local result = lib.calc_msd(calcHandle, rows, row_count)

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
---@return table
function MinaCalc.getSsr(rows, row_count, time_rate, target_accuracy)
	local ssr = lib.calc_ssr(calcHandle, rows, row_count, time_rate, target_accuracy)

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

	local rows = MinaCalc.noteInfo(row_count)

	for i = 0, 1000 - 1, 1 do
		rows[i].notes = bytes[(i % 10) + 1]
		rows[i].rowTime = i * 0.05
	end

	local ssr = MinaCalc.getSsr(rows, row_count, 1.0, 0.93)
	local overall = ssr.overall
	assert(overall > 30, "RESTART THE GAME!!! MinaCalc is not feeling good for some reason." .. overall)
end

test()

return MinaCalc
