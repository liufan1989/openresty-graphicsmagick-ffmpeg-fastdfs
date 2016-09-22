

local videometa = require "libvideometa"

if not arg[1] then
	print('useage: luajit test.lua xxxxxxxx.mp4' )
	return
end

local fp = io.open(arg[1])
local data = fp:read("*a")

local vm = videometa.get_video_info(data,#data)
print(vm.duration,vm.height,vm.width)

