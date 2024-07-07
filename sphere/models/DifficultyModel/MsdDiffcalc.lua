local IDiffcalc = require("sphere.models.DifficultyModel.IDiffcalc")
local etterna_msd = require("libchart.etterna_msd")

---@class sphere.MsdDiffcalc: sphere.IDiffcalc
---@operator call: sphere.MsdDiffcalc
local MsdDiffcalc = IDiffcalc + {}

MsdDiffcalc.name = "MSD"
MsdDiffcalc.chartdiff_field = "msd_diff"

---@param ctx sphere.DiffcalcContext
function MsdDiffcalc:compute(ctx)
	local notes = ctx:getSimplifiedNotes()

	if ctx.chartdiff.inputmode ~= "4key" then
		return
	end

	local status, msds = pcall(etterna_msd.getMsds, notes, ctx.rate)

	if not status then
		print(msds)
		return
	end

	if not msds then
		return
	end

	ctx.chartdiff.msd_diff = msds[10].overall
	ctx.chartdiff.msd_diff_data = etterna_msd:encode(msds)
end

return MsdDiffcalc
