#!/usr/bin/env bash
selector_GoogleChrome() {
	local jiranum="$1"
	local repo="$2"

	echo "window where the title of the 1st tab contains \"[${jiranum}]\""
}

save-window-bounds_GoogleChrome() {
	local jiranum="$1"
	local repo="$2"

	echo "bounds_GoogleChrome='$(osascript -e "tell app \"Google Chrome\" to get the bounds of the 1st $(selector_GoogleChrome "$jiranum" "$repo")")'"
}

new_GoogleChrome() {
	local jiranum="$1"
	local repo="$2"
	local monitors="$3"

	local bounds='279, 23, 1610, 1050'
	[[ $monitors -gt 1 ]] && bounds='232, 23, 1919, 1118'
	[[ "$bounds_GoogleChrome" ]] && bounds="$bounds_GoogleChrome"

	if [ "$repo" ]
	then
		local repoCmds="
			make new tab in new_window
			set the URL of the active tab of new_window to \"https://github.com/yext-pages/${repo}\"
			make new tab in new_window
			set the URL of the active tab of new_window to \"https://www.yext.com/pagesadmin/?query=$(echo "${repo//[Mm]aster[^A-Za-z0-9]}" | tr A-Z a-z)\""
	fi

	printf "
		tell app \"Google Chrome\"
			set new_window to (make new window)
			set the bounds of new_window to {${bounds}}
			set the URL of the 1st tab of new_window to \"https://yexttest.atlassian.net/browse/${jiranum}\"
			${repoCmds}
			set the active tab index of new_window to 1
		end tell
	" | osascript &
}

apps[${#apps[@]}]='Google Chrome'
