exec    = require('child_process').exec
async   = require('async')
log     = console.log

args = process.argv.splice(2);
file = args[0]
duration = parseInt args[1],10
version = 4

probeFrames = (file, cb) ->
    exec 'ffprobe -show_frames -print_format json '+file, { maxBuffer: 10000*1024 }, (oError, oStdOut, oStdError) ->
        if (oError) 
            cb oError
        else 
            frames =  JSON.parse(oStdOut).frames
            cb null, frames

createm3u8File = (file, cb) ->
    probeFrames file, (err, frames) ->
        if (err) 
            log err
            cb(err)
        else 
            if (frames.length)
                keyPackets = { 
                    times : []
                    pos : []
                }
                
                for frame in frames when parseInt(frame.key_frame,10) == 1 
                    keyPackets.times.push parseFloat frame.pkt_pts_time
                    keyPackets.pos.push parseInt frame.pkt_pos, 10
                    log frame
                cb(null, keyPackets)

dispDuration = duration + 1

log "#EXTM3U"
log "#EXT-X-TARGETDURATION:" + dispDuration
log "#EXT-X-VERSION:"+version
log "#EXT-X-MEDIA-SEQUENCE:0"
log "#EXT-X-PLAYLIST-TYPE:VOD"


printIframeInfo = (keyPackets) ->
    prevTime = 0
    prevPos = 0
    targetTime = duration
    times = keyPackets.times
    pos = keyPackets.pos

    for k,t of times
        k = parseInt k,10
        t = parseFloat t
        if k < times.length - 1
            nextTime = times[k+1]
            if t > targetTime and targetTime < nextTime
                log "#EXTINF:#{t - prevTime},"
                log "#EXT-X-BYTERANGE:#{pos[k]}@#{prevPos}"
                log file
                prevTime = t
                targetTime += duration
                prevPos = pos[k]

    log "#EXT-X-ENDLIST"



createm3u8File file, (err,keyPackets) ->
    printIframeInfo keyPackets


