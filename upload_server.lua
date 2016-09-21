------Import Module--------
local cjson = require "cjson"
local upload = require "resty.upload"
local md5 = require "resty.md5"
local tracker = require "resty.fastdfs.tracker"
local storage = require "resty.fastdfs.storage"
local magick = require "magick"
local videometa = require "libvideometa"

---------Function----------
function get_filename(res) 
	local filename = ngx.re.match(res,'(.+)filename="(.+)"(.*)') 
	if filename then  
		return filename[2] 
	else
		return nil
	end 
end 

function get_extension(str)
	return str:match(".+%.(%w+)$")
end

function connect_fastdfs(fdfs_ip,fdfs_port)
	local tk = tracker:new()
	tk:set_timeout(3000)
	local ok,err = tk:connect({host=fdfs_ip,port=fdfs_port})
	if not ok then
		ngx.log(ngx.ERR,"fail to connect to fastdfs tracker:",err)
		return nil
	end
	local stginfo,err = tk:query_storage_store()
	if not stginfo then
		ngx.log(ngx.ERR,"fail to query fastdfs storage:",err)
		return nil
	end
	local stg = storage:new()
	stg:set_timeout(3000)
	local ok,err = stg:connect(stginfo)		
	if not ok then
		ngx.log(ngx.ERR,"fail to connect fastdfs storage:",err)
		return nil
	end
	return stg
end


------------------MAIN---------------------------------

local chunk_size = 52428800 --50M
local form,err = upload:new(chunk_size)
if not form then
	ngx.log(ngx.ERR,"fail to new upload: ",err)
	ngx.exit(500)
end
form:set_timeout(3000) -- 3s

--local firstflag = 1
local md5c = md5:new()
local fdfs_ip = nil
local fdfs_port = nil
local result = {}
local filesize = 0
local filename = nil 
local postfix = nil
local filetype = nil
local buffer = ''

while true do
	local stream, res, err = form:read()
	if not stream then
		ngx.log(ngx.ERR,"fail to read socket stream",err)
		ngx.exit(500)
	end
	if stream == "header" then
		if res[1] ~= "Content-Type" then
			filename =  get_filename(res[2])
			postfix = get_extension(filename)
		end
		if res[1] == "Content-Type" then
			filetype = res[2]:sub(1,5)
		end

	elseif stream == "body" then
		md5c:update(res)
                filesize = filesize + #res
		buffer = buffer .. res
		--[[
		if firstflag then
			local rs,err = stg:upload_appender_by_buff(res,postfix)
		        result[filename] = rs.group_name .. "/" .. rs.file_name
			firstflag = nil
			ngx.log(ngx.ERR,'frist read....')
		else
			ngx.log(ngx.ERR,'next read....')
			local rs,err = stg:append_by_buff1(result[filename],res)
		end
		]]--


	elseif stream == "part_end" then
		local md5_num = md5c:final()
		local filemeta = nil

		--------Meta Info---------
		if filetype == "image" then
			fdfs_ip = ngx.var.fastdfs_image_tracker_ip
			fdfs_port = ngx.var.fastdfs_image_tracker_port

			local img = magick.load_image_from_blob(buffer)
			if not img then
				ngx.log(ngx.ERR,'load image from buffer error')
				ngx.exit(500)
			end
			filemeta = cjson.encode({size=filesize,ext=postfix,md5=md5_num,width=img:get_width(),height=img:get_height()})

                elseif filetype == "video" then
			fdfs_ip = ngx.var.fastdfs_video_tracker_ip
			fdfs_port = ngx.var.fastdfs_video_tracker_port

			local vm = videometa.get_video_info(buffer,filesize)
			if not vm then
				ngx.log(ngx.ERR,'get video info eror')
				ngx.exit(500)
 			end
			filemeta = cjson.encode({size=filesize,ext=postfix,md5=md5_num,width=vm.width,height=vm.height,duration=vm.duration})
                else

			ngx.log(ngx.ERR,'upload file type is error!')
			ngx.exit(500)
                end

		-------Upload File---------
		local stg = connect_fastdfs(fdfs_ip,fdfs_port)
		if not stg then
			ngx.log(ngx.ERR,'connect to fastdfs server error!')
			ngx.exit(500)
		end

		local rs,err = stg:upload_appender_by_buff(buffer,postfix)
		if not rs then
			ngx.log(ngx.ERR,"fail to upload master file to fastdfs storage:",err)
			ngx.exit(500)
		end

		result[filename] = rs.group_name .. "/" .. rs.file_name

		local rs,err = stg:upload_slave_by_buff1(result[filename],"-meta",filemeta,"json")
		if not rs then
			ngx.log(ngx.ERR,"fail to upload slave file to fastdfs storage:",err)
			ngx.exit(500)
		end
	
		------- Reset Variable ------
		--firstflag = 1
		md5c:reset()
		filesize = 0
		filename = ''
		postfix = ''
		filetype = nil
		buffer = ''

	elseif stream == "eof" then
		break		
	else
		ngx.exit(500)
	end

end
ngx.print(cjson.encode(result))



