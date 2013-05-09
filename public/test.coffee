exec    = require('child_process').exec
async   = require('async')
log     = console.log

args = process.argv.splice(2);
duration = 11
version = 4

probeFrames = (file, cb) ->
    exec 'ffprobe -show_frames -print_format json '+file, { maxBuffer: 10000*1024 }, (oError, oStdOut, oStdError) ->
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
                keyPackets = { 
                    times : []
                    pos : []
                    psize : []
                    tStart      : frames[0].pkt_pts_time
                    tEnd        : frames[frames.length-1].pkt_pts_time
                    totalSize   : parseInt(frames[frames.length-1].pkt_pos, 10) + parseInt(frames[frames.length-1].pkt_size, 10)
                    file        : file
                }
                
                for frame in frames when frame.media_type is 'video' and parseInt(frame.key_frame,10) == 1 
                    keyPackets.times.push parseFloat frame.pkt_pts_time
                    keyPackets.pos.push parseInt frame.pkt_pos, 10
                    keyPackets.psize.push parseInt frame.pkt_size, 10
                cb(null, keyPackets)


log "#EXTM3U"
log "#EXT-X-TARGETDURATION:"+duration
log "#EXT-X-VERSION:"+version
log "#EXT-X-MEDIA-SEQUENCE:0"
log "#EXT-X-PLAYLIST-TYPE:VOD"
log "#EXT-X-I-FRAMES-ONLY"



printIframeInfo = (keyPacketList) ->
    times   = []
    pos     = []
    psize   = []
    files   = []

    prevTime = 0
    tEnd = 0

    for packet in keyPacketList
        i = 0
        for k,v of packet.times
            dT = v
            dT += prevTime if k == 0
            times.push v
            pos.push packet.pos[k]
            psize.push packet.psize[k]
            files.push packet.file
            prevTime = v
        tEnd = packet.tEnd

    for k,v of times
        k = parseInt k,10
        if k < times.length - 1
            nextTime = times[k+1]
            log "#EXTINF:#{(nextTime - v).toFixed(4)},"
            log "#EXT-X-BYTERANGE:#{psize[k]}@#{pos[k]}"
            log files[k]
        else 
            nextTime = tEnd
            log "#EXTINF:#{(nextTime - v).toFixed(4)},"
            log "#EXT-X-BYTERANGE:#{psize[k]}@#{pos[k]}"
            log files[k]

    log "#EXT-X-ENDLIST"



async.map args,
    (file, cb) ->
        createIframeFile file, cb
    (err, keyPacketList) ->
        printIframeInfo keyPacketList


