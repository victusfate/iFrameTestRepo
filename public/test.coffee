exec    = require('child_process').exec
async   = require('async')
log     = console.log

args = process.argv.splice(2);
file = args[0]
duration = 10
version = 4

probeFrames = (file, cb) ->
    exec 'ffprobe -show_frames -print_format json '+file, { maxBuffer: 10000*1024 }, (oError, oStdOut, oStdError) ->
        if (oError) 
            cb oError
        else 
            frames =  JSON.parse(oStdOut).frames
            cb null, frames

createIframeFile = (initialOffsetTime, file, cb) ->
    probeFrames file, (err, frames) =>
        if (err) 
            log err
            cb(err)
        else 
            if (frames.length)
                tprev = parseFloat frames[0].pkt_pts_time + initialOffsetTime
                pposmin1 = 0
                for frame in frames when parseInt(frame.key_frame,10) == 1 
                    t = parseFloat frame.pkt_pts_time
                    dt = t - tprev
                    packetPosition = parseInt frame.pkt_pos, 10
                    log "#EXTINF:#{dt},"
                    log "#EXT-X-BYTERANGE:#{packetPosition-pposmin1}@#{pposmin1}"
                    log file
                    pposmin1 = packetPosition
                    tprev = t
                nextOffsetTime = parseFloat frames[frames.length-1].pkt_pts_time - tprev                    
                cb(null, nextOffsetTime)


log "#EXTM3U"
log "#EXT-X-TARGETDURATION:"+duration
log "#EXT-X-VERSION:"+version
log "#EXT-X-MEDIA-SEQUENCE:0"
log "#EXT-X-PLAYLIST-TYPE:VOD"
log "#EXT-X-I-FRAMES-ONLY"

file0 = args[0]
waterfallArgs = []
func1 = "(cb) -> createIframeFile 0, '"+args[0]+"', cb"
waterfallArgs.push func1

oArgs = JSON.parse JSON.stringify args
log 'oArgs',oArgs
oArgs.splice(0,1)
log 'oArgs after splice',oArgs


async.each oArgs,
    (file, cb) ->
        func = "(initialOffsetTime,cb) -> createIframeFile initialOffsetTime, '" + file + "', cb"
        waterfallArgs.push func


for i in waterfallArgs
    log i.toString()


# async.waterfall waterfallArgs, 
#     () ->
#         log "#EXT-X-ENDLIST"


