exec    = require('child_process').exec
async   = require('async')
log     = console.log

args = process.argv.splice(2);
duration = 11
version = 4

probeFrames = (file, cb) ->
    exec 'ffprobe -show_frames -print_format json '+ __dirname + '/' + file, { maxBuffer: 10000*1024 }, (oError, oStdOut, oStdError) ->
        if (oError) 
            cb oError
        else 
            frames =  JSON.parse(oStdOut).frames
            cb null, frames

createIframeFile = (file, cb) ->
    probeFrames file, (err, frames) ->
        if (err) 
            log err
            cb(err)
        else 
            if (frames.length)
                fileInfo = { 
                    iFrames       : []
                    nextFrames    : []
                }
                
                for k,frame of frames when frame.media_type is 'video' and parseInt(frame.key_frame,10) == 1 
                    fileInfo.iFrames.push frame
                    i = parseInt k, 10
                    if i < (frames.length-1) 
                        fileInfo.nextFrames.push frames[i+1]
                cb(null, fileInfo)


async.map args,
    (file, cb) ->
        createIframeFile file, cb
    (err, allFileInfo) ->
        for fileInfo in allFileInfo
            i = 0
            for k,v of fileInfo.iFrames
                log v
                log fileInfo.nextFrames[k]
        log 'DONE'


