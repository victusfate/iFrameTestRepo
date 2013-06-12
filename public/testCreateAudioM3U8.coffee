exec    = require('child_process').exec
async   = require('async')
log     = console.log

args = process.argv.splice(2);
file = args[0]
duration = parseInt args[1],10
version = 4

probeFrames = (file, cb) ->
    exec 'ffprobe -show_frames -print_format json '+file, { maxBuffer: 1000000*1024 }, (oError, oStdOut, oStdError) ->
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
                    psize : []
                    durations : []
                }
                
                for frame in frames when frame.media_type is 'audio' and parseInt(frame.key_frame,10) == 1 
                    keyPackets.times.push parseFloat frame.pkt_pts_time
                    keyPackets.pos.push parseInt frame.pkt_pos, 10
                    keyPackets.psize.push parseInt frame.pkt_size, 10
                    keyPackets.durations.push parseFloat frame.pkt_duration_time
                cb(null, keyPackets)

dispDuration = duration + 1

log "#EXTM3U"
log "#EXT-X-TARGETDURATION:" + dispDuration
log "#EXT-X-VERSION:"+version
log "#EXT-X-MEDIA-SEQUENCE:0"
log "#EXT-X-PLAYLIST-TYPE:VOD"


printIframeInfo = (keyPackets) ->
    prevTime = keyPackets.times[0]
    prevPos = 0
    targetTime = duration
    times = keyPackets.times
    pos = keyPackets.pos
    psize = keyPackets.psize
    durations = keyPackets.durations

    for k,t of times
        k = parseInt k,10
        t = parseFloat t
        if k < times.length - 1
            nextTime = times[k+1]
            # log 't, targetTime, nextTime', t, targetTime, nextTime
            # if targetTime < nextTime
            if t <= targetTime and targetTime < nextTime
            # if t >= targetTime
                if targetTime + duration < times[times.length-1]
                    log "#EXTINF:#{(nextTime - prevTime).toFixed(4)},"
                    log "#EXT-X-BYTERANGE:#{pos[k] + psize[k] - prevPos}@#{prevPos}"
                    log file
                else
                    timeToEnd = times[times.length-1] - nextTime + durations[k];
                    if timeToEnd > 0
                        bytesToStreamEnd = pos[pos.length-1] + psize[psize.length-1] - (pos[k] + psize[k])
                        log "#EXTINF:#{(timeToEnd).toFixed(4)},"
                        log "#EXT-X-BYTERANGE:#{pos[k] + psize[k] + bytesToStreamEnd - prevPos}@#{prevPos}"
                        log file
                prevTime = nextTime + durations[k]
                # targetTime += duration
                targetTime = nextTime + duration
                prevPos = pos[k] + psize[k]

    log "#EXT-X-ENDLIST"



createm3u8File file, (err,keyPackets) ->
    printIframeInfo keyPackets


