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

createIframeFile = (file, cb) ->
    probeFrames file, (err, frames) =>
        if (err) 
            log err
            cb(err)
        else 
            if (frames.length)
                t0 = parseFloat frames[0].pkt_pts_time

                for frame in frames when parseInt(frame.key_frame,10) == 1 
                    t = parseFloat frame.pkt_pts_time
                    dt = t - t0
                    packetPosition = parseInt frame.pkt_pos, 10
                    packetSize = parseInt frame.pkt_size, 10
                    log "#EXTINF:#{dt},"
                    log "#EXT-X-BYTERANGE:#{packetSize}@#{packetPosition}"
                    log file
                cb(null)


log "#EXTM3U"
log "#EXT-X-TARGETDURATION:"+duration
log "#EXT-X-VERSION:"+version
log "#EXT-X-MEDIA-SEQUENCE:0"
log "#EXT-X-PLAYLIST-TYPE:VOD"
log "#EXT-X-I-FRAMES-ONLY"

async.each args, 
    (file, cb) ->
        createIframeFile file, cb
    () ->
        log "#EXT-X-ENDLIST"


