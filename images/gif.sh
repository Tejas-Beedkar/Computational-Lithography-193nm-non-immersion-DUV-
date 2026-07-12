#!/bin/bash
IN=in.mp4; OUT=out.gif
MAX=25690112   # 24.5 MiB in bytes

for C in 256 192 128 96 64 48 32 24 16 8; do
  ffmpeg -y -loglevel error -i "$IN" \
    -vf "fps=12,split[a][b];[a]palettegen=max_colors=$C:stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=3" \
    -loop 0 "$OUT"
  SZ=$(stat -c%s "$OUT")
  printf "colors=%-4s → %5.1f MB\n" "$C" "$(echo "$SZ/1048576" | bc -l)"
  if [ "$SZ" -le "$MAX" ]; then
    echo "✓ fits at max_colors=$C (resolution untouched)"
    exit 0
  fi
done

echo "✗ still over at 8 colors — resolution alone can't be preserved."
echo "  Next levers: lower fps (12 → 10 → 8), or trim with -t / -ss."
