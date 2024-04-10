local class = require("class")
local enps = require("libchart.enps")
local osu_starrate = require("libchart.osu_starrate")
local simplify_notechart = require("libchart.simplify_notechart")
local minacalc = require("libchart.minacalc")

---@class sphere.DifficultyModel
---@operator call: sphere.DifficultyModel
local DifficultyModel = class()

---@param chartdiff table
---@param noteChart ncdk.NoteChart
---@param timeRate number
function DifficultyModel:compute(chartdiff, noteChart, timeRate)
	local notes = simplify_notechart(noteChart)

	local long_notes_count = 0
	for _, note in ipairs(notes) do
		if note.end_time then
			long_notes_count = long_notes_count + 1
		end
	end

	local bm = osu_starrate.Beatmap(notes, noteChart.inputMode:getColumns(), timeRate)

	chartdiff.notes_count = #notes
	chartdiff.long_notes_count = long_notes_count
	chartdiff.enps_diff = enps.getEnps(notes) * timeRate
	chartdiff.osu_diff = bm:calculateStarRate()

	if chartdiff.inputmode ~= "4key" then
		return
	end

	local msd = minacalc.getSsr(notes, timeRate)
	chartdiff.msd_diff = msd.overall

	msd.overall = nil

	local max_diff = 0

	for _, value in pairs(msd) do
		max_diff = math.max(value, max_diff)
	end

	local diffs = {}
	local count = 0

	for key, value in pairs(msd) do
		if count >= 2 then
			break
		end

		if value > max_diff * 0.93 then
			table.insert(diffs, { key, value })
			count = count + 1
		end
	end

	table.sort(diffs, function(a, b)
		return a[2] > b[2]
	end)

	local patterns = ""

	for i, diff in ipairs(diffs) do
		patterns = string.format("%s%s", patterns, diff[1])

		if i ~= #diffs then
			patterns = patterns .. "\n"
		end
	end

	chartdiff.msd_diff_data = patterns
end

return DifficultyModel
