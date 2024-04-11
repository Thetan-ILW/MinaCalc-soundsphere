local class = require("class")
local enps = require("libchart.enps")
local osu_starrate = require("libchart.osu_starrate")
local simplify_notechart = require("libchart.simplify_notechart")
local etterna_ssr = require("libchart.etterna_ssr")

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

	local ssr = etterna_ssr.getSsr(notes, timeRate)

	if not ssr then
		return
	end

	chartdiff.msd_diff = ssr.overall
	chartdiff.msd_diff_data = etterna_ssr:encodePatterns(ssr)
end

return DifficultyModel
