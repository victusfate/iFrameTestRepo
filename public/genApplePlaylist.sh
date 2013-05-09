# if you have os x, worth comparing
mediafilesegmenter -t 10 --generate-variant-plist -z iframe_index.m3u8 mainWithAudio.mp4
variantplaylistcreator prog_index.m3u8  mainWithAudio.plist -i iframe_index.m3u8
