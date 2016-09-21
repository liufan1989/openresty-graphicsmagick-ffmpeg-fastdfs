
local tracker = require "resty.fastdfs.tracker"
local storage = require "resty.fastdfs.storage"

function download_file(ip,port,groupid)
	local tk = tracker:new()
	tk:set_timeout(3000)
	local ok,err = tk:connect({host=ip,port=port})
	if not ok then
		ngx.log(ngx.ERR,"fail to connect to fastdfs tracker:", err)
		ngx.exit(500)
	end
	local stginfo,err = tk:query_storage_fetch1(groupid)
	if not stginfo then
		ngx.log(ngx.ERR,"fail to query fastdfs storage:", err)
		ngx.exit(500)
	end
	local st = storage:new()
	st:set_timeout(3000)
	local ok, err = st:connect(stginfo)
	if not ok then
	    ngx.log(ngx.ERR,"connect storage error: ", err)
	    ngx.exit(500)
	end
	return st:download_file_to_buff1(groupid)
end

function is_file_exists(filepath)
	local fd = io.open(filepath,"r")
	if fd then
		fd:close()
		return true
	else
		return false
	end
end

----------------------MAIN------------------------------

local fdfs_ip   = ngx.var.fastdfs_tracker_ip
local fdfs_port = ngx.var.fastdfs_tracker_port

local cache_path = ngx.var.cache_path
local filepath = ngx.var.local_path
local filename = ngx.var.filename
local orgfilename = ngx.var.original_file
local orgfilepath = cache_path .. orgfilename

local groupid = ngx.var.group_id:sub(2,-1)

local media = ngx.var.media;
local image_size = ngx.var.image_size

--[[
ngx.log(ngx.ERR,"filename:",filename)
ngx.log(ngx.ERR,"filepath:",filepath)
ngx.log(ngx.ERR,"imagesize:",image_size)
ngx.log(ngx.ERR,"groupid:",groupid)
ngx.log(ngx.ERR,"originalfile:",orgfilename)
ngx.log(ngx.ERR,"originalfilepath:",orgfilepath)
--]]

if not is_file_exists(orgfilepath) then
	local buffer,err = download_file(fdfs_ip,fdfs_port,groupid)
	if not buffer then
	    ngx.log(ngx.ERR,"download from fastdfs storage error:", err)
	    ngx.exit(500)
	end
	local wfd = io.open(orgfilepath,"w")
	if not wfd then
	    ngx.log(ngx.ERR,"write file error:", orgfilepath)
	    ngx.exit(500)
	end
	wfd:write(buffer)
	wfd:close()
	--ngx.log(ngx.ERR,"write ok")
end

if media == '1' then
	if image_size ~= '' then
		local cmd = "gm convert " .. orgfilepath .. " -thumbnail " .. image_size .. " " .. filepath
		--ngx.log(ngx.ERR,"command : ",cmd)
		local ret = os.execute(cmd)
		if ret ~= 0 then
			ngx.log(ngx.ERR,"os execute fail : ",cmd)
		end
	end
elseif media == '2' then 
	local cmd = "ffmpeg -ss 1 -i " .. orgfilepath .. " -f image2 -y " .. filepath
	--ngx.log(ngx.ERR,"command : ",cmd)
	local ret = os.execute(cmd)
	if ret ~= 0 then
		ngx.log(ngx.ERR,"os execute fail : ", cmd)
	end
else
	ngx.log(ngx.ERR,'media type error!')
	ngx.exit(500)
end

