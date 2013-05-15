./messWithAudioStream.sh
# ffmpeg -i main.ts -i audio.aac -qscale 0 -vcodec copy -acodec copy -absf aac_adtstoasc -threads 0 -y mainWithAudio.mp4
ffmpeg -i main.ts -i audio.wav -qscale 0 -vcodec copy -acodec libfaac -ab 128k -ar 48000 -threads 0 -y mainWithAudio.mp4
ffmpeg -i mainWithAudio.mp4 -vcodec copy -acodec copy -vbsf h264_mp4toannexb mainWithAudio.ts
