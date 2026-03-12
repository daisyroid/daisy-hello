# pip install gTTS 
# https://gtts.readthedocs.io/en/latest/

import sys
from gtts import gTTS

message = "こんにちはデイジーです。よろしくお願いします。PythonのgTTSで話しています。"
out_file = "daisy-hello.mp3"

out_file = sys.argv[1]
tts = gTTS(text=message, lang='ja')
tts.save(out_file)
print(f"CREATED: {out_file}")  
