ffmpeg -i 408fcf5b6c689f71a9b064f69c7aba197957e957 audio.wav
# force output audio to be sync'd to 24 fps, http://lzone.de/fix+async+video+with+ffmpeg
ffmpeg -async 24 -i audio.wav -acodec libfaac -f adts -b:a 128000 -r 24 audio.aac
