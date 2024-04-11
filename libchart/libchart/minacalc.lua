local ffi = require("ffi")

if MinaCalc then
	return MinaCalc
end

MinaCalc = {}

local lib

if jit.os == "Windows" then
	lib = ffi.load("moddedgame/MinaCalc/bin/win64/libminacalc.dll")
else
	lib = ffi.load("moddedgame/MinaCalc/bin/linux64/libminacalc.so")
end

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

	Ssr calc_ssr(CalcHandle *calc, NoteInfo *rows, size_t num_rows, float music_rate, float score_goal);
]])

local calcHandle = lib.create_calc()

function MinaCalc.noteInfo(size)
	if not size then
		return ffi.new("NoteInfo")
	end

	return ffi.new(("NoteInfo[%i]"):format(size))
end

function MinaCalc.getSsr(rows, numRows, timeRate)
	local ssr = lib.calc_ssr(calcHandle, rows, numRows, timeRate, 0.93)

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

return MinaCalc
