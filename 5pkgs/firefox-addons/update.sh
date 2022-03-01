#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl -p jq -p ripgrep

get_xpi_url() {
	curl -s "https://addons.mozilla.org/api/v5/addons/addon/${1}/?app=firefox" | jq -r ".current_version.file.url" | grep ".xpi"
}

replace_sha() {
	sed -i "s#sha256 = \"[^\"]*\"#sha256 = \"$2\"#" "$1"
}

replace_url() {
	sed -i "s#url = \".*\"#url = \"$2\"#" "$1"
}

extract_val() {
	grep "  $2 = \"" "$1" | cut -d '"' -f2
}

fetch_sha() {
	nix-prefetch-url "$1"
}

# Addons packaged from addons.mozilla.org
ADDONS_MOZILLA=$(rg "url = \"https://addons.mozilla.org/firefox/downloads/file/" --files-with-matches --type=nix)

for ADDON in $ADDONS_MOZILLA; do
	NAME=$(extract_val "$ADDON" "name")
	echo "[$NAME] updating $ADDON"

	EXISTING_XPI=$(extract_val "$ADDON" "url")
	XPI=$(get_xpi_url "$NAME")
	if [[ "$EXISTING_XPI" == "$XPI" ]]; then
		echo "[$NAME] XPI matches already"
		continue
	fi
	replace_url "$ADDON" "$XPI"

	SHA="$(fetch_sha "$XPI")"
	replace_sha "$ADDON" "$SHA"
	echo "[$NAME] updated $ADDON"
done
