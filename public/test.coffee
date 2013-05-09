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
                keyPackets = { 
                    times : []
                    pos : []
                    tStart      : frames[0].pkt_pts_time
                    tEnd        : frames[frames.length-1].pkt_pts_time
                    totalSize   : frames[frames.length-1].pkt_pos 
                }
                
                for frame in frames when parseInt(frame.key_frame,10) == 1 
                    keyPackets.times.push parseFloat frame.pkt_pts_time
                    keyPackets.pos.push parseInt frame.pkt_pos, 10
                cb(null, keyPackets)


log "#EXTM3U"
log "#EXT-X-TARGETDURATION:"+duration
log "#EXT-X-VERSION:"+version
log "#EXT-X-MEDIA-SEQUENCE:0"
log "#EXT-X-PLAYLIST-TYPE:VOD"
log "#EXT-X-I-FRAMES-ONLY"

async.map args,
    (file, cb) ->
        createIframeFile file, cb
    (err, keyPacketList) ->
        for i in keyPacketList
            log i


# log "#EXTINF:#{dt},"
# log "#EXT-X-BYTERANGE:#{packetPosition-pposmin1}@#{pposmin1}"
# log file

# log "#EXT-X-ENDLIST"

