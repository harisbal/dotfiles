#!/usr/bin/env bash
# Claude Code status line: project / ctx % / 5h % (resets in) / 7d % (resets in)
input=$(cat)

dir=$(echo "$input" | jq -r '.workspace.project_dir // .workspace.current_dir // .cwd // empty')
name=$(basename "${dir:-.}")

fmt_remaining() {
  local s=$(( $1 - $(date +%s) ))
  [ "$s" -lt 0 ] && s=0
  local d=$(( s / 86400 )) h=$(( s % 86400 / 3600 )) m=$(( s % 3600 / 60 ))
  if [ "$d" -gt 0 ]; then echo "${d}d${h}h"
  else echo "${h}h${m}m"; fi
}

# color a percentage: green <50, yellow 50-79, red >=80
cpct() {
  local n; n=$(printf '%.0f' "$1")
  local c=32
  [ "$n" -ge 50 ] && c=33
  [ "$n" -ge 80 ] && c=31
  printf '\033[%sm%s%%\033[0m' "$c" "$n"
}

out="$name"

branch=$(git -C "${dir:-.}" symbolic-ref --short -q HEAD 2>/dev/null || git -C "${dir:-.}" rev-parse --short HEAD 2>/dev/null)
[ -n "$branch" ] && out="$out ($branch)"

model=$(echo "$input" | jq -r '.model.display_name // empty')
effort=$(echo "$input" | jq -r '.effort.level // empty')
if [ -n "$model" ] && [ -n "$effort" ]; then out="$out | $model ($effort)"
elif [ -n "$model" ]; then out="$out | $model"
fi

ctx=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
[ -n "$ctx" ] && out="$out | ctx $(cpct "$ctx")"

for w in five_hour:5h seven_day:7d; do
  key=${w%%:*}; label=${w##*:}
  pct=$(echo "$input" | jq -r ".rate_limits.$key.used_percentage // empty")
  rst=$(echo "$input" | jq -r ".rate_limits.$key.resets_at // empty")
  [ -z "$pct" ] && continue
  seg="$label $(cpct "$pct")"
  [ -n "$rst" ] && seg="$seg ($(fmt_remaining "${rst%.*}"))"
  out="$out | $seg"
done

echo "$out"
