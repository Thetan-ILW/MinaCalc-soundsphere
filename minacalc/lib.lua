local ffi = require("ffi")

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

local is_windows = jit.os == "Windows"
local lib_path = is_windows and "bin/win64/libminacalc.dll" or "bin/linux64/libminacalc.so"

if not love.filesystem.getInfo(lib_path) then
	minacalc_lib.error = "libminacalc not found in the bin/ directory"
	return minacalc_lib -- Other plugin loaded before minacalc, this plugin will copy library to bin and restart the game later.
end

if is_windows then
	local winapi = require("winapi")
	---@type boolean, string?
	local success, result = pcall(winapi.load_library, lib_path)

	if not success then
		if type(result) == "string" then
			minacalc_lib.error = result .. "\n" .. love.filesystem.getSource()
		end

		return minacalc_lib
	end
end

local success, result = pcall(ffi.load, lib_path)

if not success then
	minacalc_lib.error = result
	return minacalc_lib
end

local lib = result
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

return minacalc_lib
