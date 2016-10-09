# openresty-graphicsmagick-ffmpeg-fastdfs
Build the fastdfs file server with graphicsmagick and ffmpeg tools, The file server can upload videos and pictures as well as download video shots and any size of the picture, At the same time can get the file meta information such as file size, md5 ,image width and height, duration of video, duration of audio etc. 

## Install fastdfs 
* libfastcommon:  https://github.com/happyfish100/libfastcommon
* fastdfs:   https://github.com/happyfish100/fastdfs
* fastdht:   https://github.com/happyfish100/fastdht

## Install lua-resty-fastdfs
* download from : https://github.com/azurewang/lua-resty-fastdfs 

## Install GraphicsMagick
* download from : http://www.graphicsmagick.org/index.html
* ./configure
* make & make install
* unbuntu: apt-get install graphicsmagick [either-or]

## Install magick lua ffi library [either-or]

#### Install ImageMagick luajit ffi library
* download from : https://github.com/leafo/magick
* Reference : http://www.imagemagick.org/script/index.php

#### Install GraphicsMagick luajit ffi library
* download from : https://github.com/clementfarabet/graphicsmagick
* Reference : http://www.graphicsmagick.org/index.html 

## Install ffmpeg library
* download from : https://ffmpeg.org/download.html 
* make dynamic library:  ./configure --enable-shared 
* make & make install
* echo "/usr/local/lib" >> /etc/ld.so.conf & ldconfig

## Install you own library
* ./build.sh
* libavmeta.so : get video and audio files information by using the ffmpeg library
* libavmeta.lua : using luajit ffi library

## Install openresty
* Download the newest version:  http://openresty.org/cn/download.html
* ./configure
* make & make install
* Learning more about the nginx.conf rules : http://openresty.org/download/agentzh-nginx-tutorials-zhcn.html

``` 
1. Default openresty install path is /usr/local/openresty
2. Replace the nginx.conf file
3. Put download_server.lua upload_server.lua into /usr/local/openresty/site/
4. Put libavmeta.so libavmeta.lua into /usr/local/openresty/lualib/
5. Put magick luajit ffi library into /usr/local/openresty/lualib/
6. Put lua-resty-fastdfs/*.lua  into /usr/local/openresty/lualib/resty/fastdfs/
7. mkdir /srv/image_cache /srv/video_cache, by modified $cache_path in nginx.conf 
8. Start running openresty: ./bin/openresty
```

## Example
```
* upload file: http://127.0.0.1:7777/share/upload/  [http-form-data]
* download the original image: http://127.0.0.1:7777/image1/M00/00/00/wKgB8VfiL6KEJ3ZMAAAAAOerjWk419.jpg
* download the resize image: http://127.0.0.1:7777/image1/M00/00/00/wKgB8VfiL6KEJ3ZMAAAAAOerjWk419@200x200.jpg
* download the video: http://127.0.0.1:7777/video1/M00/00/00/wKgB8VfiNpCECq8AAAAAANek-BI696.mp4
* download the videosnapshot: http://127.0.0.1:7777/video1/M00/00/00/wKgB8VfiNpCECq8AAAAAANek-BI696.mp4.jpg
```

## Tips
* Support only HTTP form data submission, not suport http raw submission
* The $cache_path will generate a cache file, you need to clean up by the time stamp
* Upload multiple files at one time
* Comment out "lua_code_cache off;" in nginx.conf
* Upload max file 50M ["client_max_body_size 50m" in nginx.conf, upload:new() in upload_server.lua]
* When uploading files  make sure the content-type of form correct

