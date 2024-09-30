local DifficultyModel = require("sphere.models.DifficultyModel")
local base_new = DifficultyModel.new

function DifficultyModel:new()
	base_new(self)
	self.registry:add(require("minacalc.MsdDiffcalc")())
end

if not arg then
	return
end

local path_util = require("path_util")

local function ensureLibIsInBin(pkg_path)
	local source ---@type string
	local dest ---@type string
	local os_name = love.system.getOS()

	if os_name == "Linux" then
		source = "minacalc/bin/linux64/libminacalc.so"
		dest = "bin/linux64/libminacalc.so"
	elseif os_name == "Windows" then
		source = "minacalc/bin/win64/libminacalc.dll"
		dest = "bin/win64/libminacalc.dll"
	else
		print("Build minacalc for your OS yourself. https://github.com/Thetan-ILW/MinaCalc-soundsphere")
		return
	end

	if love.filesystem.getInfo(dest) then
		return
	end

	print("copying libminacalc to bin directory")
	local file = love.filesystem.newFileData(path_util.join(pkg_path, source))
	love.filesystem.write(dest, file)

	for i = 1, 30, 1 do
		print("RESTART THE GAME!!!")
	end
	love.event.quit("restart")
end

local UserInterfaceModel = require("sphere.models.UserInterfaceModel")
local base_load = UserInterfaceModel.load

function UserInterfaceModel:load()
	base_load(self)
	ensureLibIsInBin(self.game.packageManager:getPackageDir("msd_calculator"))
end

