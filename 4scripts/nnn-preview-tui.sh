#!/usr/bin/env nix-shell
#!nix-shell -i sh -p libsixel -p imagemagickBig -p bat -p exa -p python3Packages.jupyter -p python3Packages.nbconvert
# based on https://github.com/jarun/nnn/blob/master/plugins/preview-tui

PAGER="${PAGER:-less -P?n -R}"
TMPDIR="${TMPDIR:-/tmp}"
BAT_STYLE="${BAT_STYLE:-numbers}"
BAT_THEME="${BAT_THEME:-ansi}"
# Consider setting NNN_PREVIEWDIR to $XDG_CACHE_HOME/nnn/previews if you want to keep previews on disk between reboots
NNN_PREVIEWDIR="${NNN_PREVIEWDIR:-$TMPDIR/nnn/previews}"
NNN_PREVIEWWIDTH="${NNN_PREVIEWWIDTH:-1920}"
NNN_PREVIEWHEIGHT="${NNN_PREVIEWHEIGHT:-1080}"
NNN_PARENT="${NNN_FIFO#*.}"
[ "$NNN_PARENT" -eq "$NNN_PARENT" ] 2>/dev/null || NNN_PARENT=""
FIFOPID="$TMPDIR/nnn-preview-tui-fifopid.$NNN_PARENT"
PREVIEWPID="$TMPDIR/nnn-preview-tui-pagerpid.$NNN_PARENT"
CURSEL="$TMPDIR/nnn-preview-tui-selection.$NNN_PARENT"

start_preview() {
	command="cd $PWD; \
		PATH=\"$PATH\" NNN_FIFO=\"$NNN_FIFO\" PREVIEW_MODE=1 PAGER=\"$PAGER\" \
		PREVIEWPID=\"$PREVIEWPID\" CURSEL=\"$CURSEL\" TMPDIR=\"$TMPDIR\" \
		NNN_PREVIEWHEIGHT=\"$NNN_PREVIEWHEIGHT\" \
		NNN_PREVIEWWIDTH=\"$NNN_PREVIEWWIDTH\" NNN_PREVIEWDIR=\"$NNN_PREVIEWDIR\" \
		BAT_STYLE=\"$BAT_STYLE\" TTY=\"$TTY\" \
		BAT_THEME=\"$BAT_THEME\" FIFOPID=\"$FIFOPID\" \"$0\" \"$1\""
	$TERMINAL -e sh -c "$command" &
} >/dev/null 2>&1

toggle_preview() {
	if kill "$(cat "$FIFOPID")"; then
		[ -p "$NNN_PPIPE" ] && printf "0" >"$NNN_PPIPE"
		kill "$(cat "$PREVIEWPID")"

	else
		[ -p "$NNN_PPIPE" ] && printf "1" >"$NNN_PPIPE"
		start_preview "$1" ""
	fi
} >/dev/null 2>&1

fifo_pager() {
	cmd="$1"
	shift

	# We use a FIFO to access $PAGER PID in jobs control
	tmpfifopath="$TMPDIR/nnn-preview-tui-fifo.$$"
	mkfifo "$tmpfifopath" || return

	$PAGER <"$tmpfifopath" &
	printf "%s" "$!" >"$PREVIEWPID"

	(
		exec >"$tmpfifopath"
		if [ "$cmd" = "pager" ]; then
			bat --terminal-width="$(tput cols <"$TTY")" --decorations=always --color=always \
				--paging=never --style="$BAT_STYLE" --theme="$BAT_THEME" "$@" &
		else
			"$cmd" "$@" &
		fi
	)

	rm "$tmpfifopath"
}

handle_mime() {
	case "$2" in
	image/png) image_preview "$cols" "$lines" "$1" ;;
	*) handle_ext "$1" "$3" "$4" ;;
	esac
}

handle_ext() {
	case "$2" in
	ipynb) fifo_pager jupyter nbconvert --to script --stdout "$1" ;;
	pdf) generate_preview "$cols" "$lines" "$1" "pdf" ;;
	*) if [ "$3" = "bin" ]; then
		echo "bin" "$1"
	else
		fifo_pager pager "$1"
	fi ;;
	esac
}

preview_file() {
	clear

	# Detecting the exact type of the file: the encoding, mime type, and extension in lowercase.
	encoding="$(file -bL --mime-encoding -- "$1")"
	mimetype="$(file -bL --mime-type -- "$1")"
	ext="${1##*.}"
	[ -n "$ext" ] && ext="$(printf "%s" "${ext}" | tr '[:upper:]' '[:lower:]')"
	lines=$(tput lines <"$TTY")
	cols=$(tput cols <"$TTY")

	if [ -d "$1" ]; then
		cd "$1" || return
		exa -G --group-directories-first --colour=always
	elif [ "${encoding#*)}" = "binary" ]; then
		handle_mime "$1" "$mimetype" "$ext" "bin"
	else
		handle_mime "$1" "$mimetype" "$ext"
	fi
} 2>/dev/null

generate_preview() {
	if [ ! -f "$NNN_PREVIEWDIR/$3.jpg" ] || [ -n "$(find -L "$3" -newer "$NNN_PREVIEWDIR/$3.jpg")" ]; then
		mkdir -p "$NNN_PREVIEWDIR/${3%/*}"
		case $4 in
		pdf) convert -resize "$NNN_PREVIEWWIDTH"x"$NNN_PREVIEWHEIGHT"\> "$3"[0] "$NNN_PREVIEWDIR/$3.jpg" ;;
		esac
	fi >/dev/null
	if [ -f "$NNN_PREVIEWDIR/$3.jpg" ]; then
		image_preview "$1" "$2" "$NNN_PREVIEWDIR/$3.jpg"
	fi
} 2>/dev/null

image_preview() {
	clear
	img2sixel "$3" &
} 2>/dev/null

winch_handler() {
	clear
	kill "$(cat "$PREVIEWPID")"
	preview_file "$(cat "$CURSEL")"
} 2>/dev/null

preview_fifo() {
	while read -r selection; do
		if [ -n "$selection" ]; then
			preview_file "$selection"
		fi
	done <"$NNN_FIFO"
} 2>/dev/null

if [ "$PREVIEW_MODE" ]; then
	preview_fifo &
	printf "%s" "$!" >"$FIFOPID"
	printf "%s" "$PWD/$1" >"$CURSEL"
	trap 'winch_handler; wait' WINCH
	trap 'rm "$PREVIEWPID" "$CURSEL" "$FIFOPID" 2>/dev/null' INT HUP EXIT
	wait "$!" 2>/dev/null
else
	if [ ! -r "$NNN_FIFO" ]; then
		clear
		printf "No FIFO available! (\$NNN_FIFO='%s')" "$NNN_FIFO"
		cfg=$(stty -g)
		stty raw -echo
		head -c 1
		stty "$cfg"
	else
		TTY="$(tty)"
		TTY="$TTY" toggle_preview "$1" &
	fi
fi
