local IDiffcalc = require("sphere.models.DifficultyModel.IDiffcalc")
local etterna_msd = require("minacalc.etterna_msd")

---@class sphere.MsdDiffcalc: sphere.IDiffcalc
---@operator call: sphere.MsdDiffcalc
local MsdDiffcalc = IDiffcalc + {}

MsdDiffcalc.name = "MSD"
MsdDiffcalc.chartdiff_field = "msd_diff"

---@param ctx sphere.DiffcalcContext
function MsdDiffcalc:compute(ctx)
	local notes = ctx:getSimplifiedNotes()

	local status, msds = pcall(etterna_msd.getMsds, notes, ctx.chartdiff.inputmode)

	if not status then
		print(msds)
		return
	end

	if not msds then
		ctx.chartdiff.msd_diff = 0
		ctx.chartdiff.msd_diff_data = ""
		return
	end

	ctx.chartdiff.msd_diff = msds[10].overall
	ctx.chartdiff.msd_diff_data = etterna_msd.encode(msds)
end

return MsdDiffcalc
