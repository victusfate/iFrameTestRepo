# if you have os x, worth comparing
mediafilesegmenter -t 10 -i video_index.m3u8 --generate-variant-plist -B videoOnly -A -z iframe_index.m3u8 mainWithAudio.mp4
mv mainWithAudio.plist videoOnly.plist
# mediafilesegmenter -t 10 -i audio_index.m3u8 --generate-variant-plist -B audioOnly -a mainWithAudio.mp4
# mv mainWithAudio.plist audioOnly.plist
# variantplaylistcreator -o junk.m3u8 video_index.m3u8  videoOnly.plist -i iframe_index.m3u8 audio_index.m3u8 audioOnly.plist
mediafilesegmenter -s -a -t 10 -i audio_single_index.m3u8 --generate-variant-plist -B audioSingleOnly mainWithAudio.mp4
mv mainWithAudio.plist audioSingleOnly.plist
variantplaylistcreator -o junk.m3u8 video_index.m3u8  videoOnly.plist -i iframe_index.m3u8 audio_single_index.m3u8 audioSingleOnly.plist
