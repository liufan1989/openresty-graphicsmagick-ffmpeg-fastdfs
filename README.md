# openresty-imagemagick-ffmpeg-fastdfs
Build the fastdfs file server via imagemagick and ffmpeg

The file server can upload videos and pictures as well as download video shots and any size of the picture

## install fastdfs 
* libfastcommon:  https://github.com/happyfish100/libfastcommon
* fastdfs:   https://github.com/happyfish100/fastdfs
* fastdht:   https://github.com/happyfish100/fastdht

## install lua-resty-fastdfs
* download from : https://github.com/azurewang/lua-resty-fastdfs 

## install imagemagick
* download from : http://www.imagemagick.org/script/index.php
* ./configure
* make & make install

## install imagemagick luajit ffi library
* download from : https://github.com/leafo/magick

## install ffmpeg
* download from : https://ffmpeg.org/download.html 
* make dynamic library:  ./configure --enable-shared 
* make & make install
* ln -s /usr/local/lib/libxxxx.so /usr/lib/libxxxx.so

## install you own library
* ./build.sh
* libvideometa.so : get video duration width and height by using the ffmpeg library
* libvideometa.lua : using luajit the extended library ffi

## install openresty
* Download the newest version:  http://openresty.org/cn/download.html
* ./configure
* make & make install
* learning more about the nginx.conf rule : http://openresty.org/download/agentzh-nginx-tutorials-zhcn.html

``` 
1. default openresty install path is /usr/local/openresty
2. replace the nginx.conf file
3. put download_server.lua upload_server.lua into /usr/local/openresty/site/
4. put libvideometa.so libvideometa.lua into /usr/local/openresty/luajit/share/lua/5.x/
5. put imagemagick luajit ffi library into /usr/local/openresty/luajit/share/lua/5.x/
6. put lua-resty-fastdfs/*.lua  into /usr/local/openresty/lualib/resty/fastdfs/
7. mkdir /srv/image_cache /srv/video_cache, by modified $cache_path in nginx.conf 
8. start running openresty: ./bin/openresty
```

## example
```
* upload file: http://127.0.0.1:7777/share/upload/  [http-form-data]
* download the original image: http://127.0.0.1:7777/image1/M00/00/00/wKgB8VfiL6KEJ3ZMAAAAAOerjWk419.jpg
* download the resize image: http://127.0.0.1:7777/image1/M00/00/00/wKgB8VfiL6KEJ3ZMAAAAAOerjWk419@200x200.jpg
* download the video: http://127.0.0.1:7777/video1/M00/00/00/wKgB8VfiNpCECq8AAAAAANek-BI696.mp4
* download the videosnapshot: http://127.0.0.1:7777/video1/M00/00/00/wKgB8VfiNpCECq8AAAAAANek-BI696.jpg
```

## Tips
* The upload file is http form-data submit, not suport http raw submit
* The $cache_path will generate a cache file, you need to clean up by the time stamp
* Upload multiple files at one time


