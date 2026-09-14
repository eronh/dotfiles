# ls list files only
ls -lAh | grep -v '^d'

# ls directories only
ls -lAh | grep '^d'

# Download Best MP4 (Video+Audio) for MacOS / WhatsApp
/opt/homebrew/bin/yt-dlp -f "bestvideo[vcodec^=avc1]+bestaudio[acodec^=mp4a]/best[ext=mp4]" \
	--merge-output-format mp4 \
	-o "%(title).50s.%(ext)s" \
	"VIDEO_URL"

# Download Audio Only
/opt/homebrew/bin/yt-dlp -f "bestaudio" -x --audio-format mp3 \
	-o "%(title).50s.%(ext)s" \
	"VIDEO_URL"

# Download Video Only (no audio)
yt-dlp -f "bestvideo[vcodec^=avc1]" \
	-o "%(title).50s.%(ext)s" \
	"VIDEO_URL"

	# If that fails, fallback to:
	yt-dlp -f bestvideo --merge-output-format mp4 -o "%(title).50s.%(ext)s" "VIDEO_URL"

# Remove Audio from a Video (with ffmpeg)
ffmpeg -i "input.mp4" -an -c:v copy "no-audio.mp4"

# Convert Video to WhatsApp-Compatible MP4
ffmpeg -i "input.mp4" \
	-c:v libx264 -profile:v baseline -level 3.0 -pix_fmt yuv420p \
	-c:a aac -b:a 128k -movflags +faststart \
	"whatsapp_ready.mp4"

# Shrink Video for WhatsApp (mobile-friendly)
ffmpeg -i "input.mp4" \
	-vf "scale=iw*min(640/iw\,480/ih):ih*min(640/iw\,480/ih)" \
	-c:v libx264 -profile:v baseline -level 3.0 -pix_fmt yuv420p \
	-c:a aac -b:a 96k -crf 28 -movflags +faststart \
	"whatsapp_small.mp4"

# Check File Codec (video & audio)
ffprobe -v error -show_entries stream=index,codec_type,codec_name \
	-of default=noprint_wrappers=1 \
	"yourfile.mp4"
# list node_modules directories (recursively)
find . -name 'node_modules' -type d -prune

# remove node_modules directories (recursively)
find . -name 'node_modules' -type d -prune -exec trash '{}' +

# Find device IP in the local network
ipconfig getifaddr en0  # mac os  # en0 = wifi; if on cable: en1 or en2
ip a                    # linux

# recursively list all files with common compression extensions
find . -type f \( \
  -iname "*.zip" -o \
  -iname "*.tar" -o \
  -iname "*.tar.gz" -o \
  -iname "*.tgz" -o \
  -iname "*.tar.bz2" -o \
  -iname "*.tbz2" -o \
  -iname "*.tar.xz" -o \
  -iname "*.txz" -o \
  -iname "*.7z" -o \
  -iname "*.rar" \
\)

# specify dirs to ignore that are direct children of CWD
find . \( \
  -path "./node_modules" -o \
  -path "./.git" -o \
  -path "./dist" \
\) -prune -o -type f \( \
  -iname "*.zip" -o \
  -iname "*.tar" -o \
  -iname "*.tar.gz" -o \
  -iname "*.tgz" -o \
  -iname "*.gz" -o \
  -iname "*.bz2" -o \
  -iname "*.xz" -o \
  -iname "*.7z" -o \
  -iname "*.rar" -o \
  -iname "*.zst" -o \
  -iname "*.lz" -o \
  -iname "*.lzma" \
\) -print

# run from ~: copy a file preserving its path
rsync -RL $HOME/.local/bin/code /Volumes/ExternalDrive/backup/

# run from ~: alternative: preserve symlink instead of the target
rsync -R $HOME/.local/bin/code /Volumes/ExternalDrive/backup/

# compress-mov-videos
ffmpeg -i "input.mov" -c:v libx264 -crf 28 -preset fast -c:a aac -b:a 128k "output.mov"

# Recursively delete specific directories
find . -type d \( -name "node_modules" -o -name "_generated" -o -name "dist" \) -prune

# flush macos dns cache
sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder



# tmux: manually trigger window renaming
tmux list-windows -a -F '#{window_id}' | xargs -I{} tmux set -w -u -t {} automatic-rename
