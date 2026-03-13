# 入力画像ファイルと音声ファイル
$ImageFile = "daisy-prof.webp"
$AudioFile = "daisy-hello.mp3"

# 出力ファイル
$VideoFile = "daisy-hello.mp4"

# 画像ファイルがなければエラー
if (!(Test-Path $ImageFile)) {
  Write-Host "ERROR: Not found $ImageFile"
  exit 1
}

# 音声ファイルがなければ gtts-mp3.py で作成する
if (!(Test-Path $AudioFile)) {
  python gtts-mp3.py "$AudioFile"
  if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Python failed"
    exit 1
  }
}

# 動画サイズ
$Width  = 512
$Height = 288

# 画像を拡大縮小し画面にフィットさせるffmpegコマンド
$SCALE = "scale=${Width}:${Height}:force_original_aspect_ratio=decrease"

# 画像の周囲にパディングを入れるffmpegコマンド
$BackColor = "navy"
$PAD = "pad=${Width}:${Height}:(ow-iw)/2:(oh-ih)/2:${BackColor}"

# フォントのフルパス（ffmpegの引数内で ":" はエスケープが必要）
$Font = "C\:/Windows/Fonts/BIZ-UDGothicB.ttc"

# 文字表示スタイル
$Style = @(
  "fontfile='${Font}'", # フォント
  "fontsize=18",        # 文字サイズ
  "fontcolor=white",    # 文字色
  "bordercolor=navy",   # 縁取り色
  "borderw=2",          # 縁取りの太さ
  "x=(w-text_w)/2",     # 横方向センタリング
  "y=h-27"              # 画面の下端から上に27
) -join ":"

# 字幕表示のffmpegコマンド1（0.0秒～1.7秒）
$T1 = @(
  "drawtext=${Style}",
  "text='こんにちは デイジーです。'",
  "enable='between(t,0.0,1.7)'"
) -join ":"

# 字幕表示のffmpegコマンド2（1.8秒～3.9秒）
$T2 = @(
  "drawtext=${Style}",
  "text='よろしくお願いします。'",
  "enable='between(t,1.8,3.9)'"
) -join ":"

# 字幕表示のffmpegコマンド3（4.0秒～8.0秒）
$T3 = @(
  "drawtext=${Style}",
  "text='PythonのgTTSで話しています。'",
  "enable='between(t,4.0,8.0)'"
) -join ":"

# ffmpegのコマンドライン引数
$Args = @(
  "-loglevel", "error"    # 警告レベル"error"以上を出力、"trace"で詳細出力
  "-loop", "1"            # ループフラグをTrueにする（静止画表示の場合はこれを指定）
  "-t", "8"               # 8秒で止める（loopありの場合これがないと無限ループ）
  "-r", "10"              # 毎秒10フレーム
  "-i", $ImageFile        # 入力画像ファイル
  "-i", $AudioFile        # 入力音声ファイル
  "-filter_complex", "${SCALE},${PAD},${T1},${T2},${T3}"
  "-tune", "stillimage"   # 静止画の場合はこれをつけるとよいらしい
  "-c:v", "libx264"       # ビデオ形式 H264
  "-c:a", "aac"           # 音声形式 aac
  "-pix_fmt", "yuv420p"   # ピクセル形式 yuv420p
  "-y", $VideoFile        # 既存のファイルがあれば上書き
)

# ffmpegを実行（呼び出し演算子 "&" を利用）
& ffmpeg $Args

# 成功したらメッセージを表示する
if ($LASTEXITCODE -eq 0) {
  Write-Host "CREATED: $VideoFile"
}
