#!/usr/bin/env bash
# Helper Functions

save-config() {
	echo "ITEMS_DIR='${ITEMS_DIR}'" > ../appdata/taskboard/taskswap.config

	for app in "${apps[@]}"
	do
		if [ ${enabledApps[$(hash "$app")]} ]
		then
			echo "enabledApps[$(hash "$app")]=true" >> ../appdata/taskboard/taskswap.config
		fi
	done
}

load_items() {
	local directory="$1"
	local name
	local symbol

	if [ "$(ls "$directory")" ]
	then
		while read dir
		do
			name=
			symbol=
			source "${dir}.taskboard" 2>/dev/null

			echo "${symbol}$(basename "$dir")   ${name}"
		done <<< "$(ls -d "$directory"*/)"
	fi
}

timelog-message() {
	local jiranum="$1"
	local repo="$2"
	local name="$3"

	echo "${jiranum} ${name}" | sed 's/ *$//'
}

activate-task() {
	local jiranum="$1"
	local repo="$2"
	local name="$3"

	activate "$jiranum" "$repo" "$name"
	../timelog/timelog.sh "$(timelog-message "$jiranum" "$repo" "$name")" start

	active_jira="$jiranum"
	active_repo="$repo"
	active_name="$name"
}

deactivate-task() {
	local jiranum="$1"
	local repo="$2"
	local name="$3"

	deactivate "$jiranum" "$repo" "$name"
	../timelog/timelog.sh "$(timelog-message "$jiranum" "$repo" "$name")" end

	active_jira=
	active_repo=
	active_name=
}


# Main Menu Functions

select-task() {
	case "${menu_value:0:1}" in
		' ' )
			[ "$active_jira" ] && deactivate-task "$active_jira" "$active_repo" "$active_name"
			activate-task "$jiranum" "$repo" "$name"
		;;
		'*' )
			deactivate-task "$jiranum" "$repo" "$name"
		;;
	esac
}

quit() {
	[ "$active_jira" ] && deactivate-task "$active_jira" "$active_repo" "$active_name"

	# Remove custom title
	#osascript -e 'tell app "Terminal" to set custom title of 1st window whose name contains "TaskBoard" to "Terminal"' 2>/dev/null &

	clear-menu

	exit
}

new-task() {
	local jiraurl
	local jiranum
	local name
	local gitUrl
	local repo

	clear
	tput cnorm
	stty echo

	read -p "JIRA URL or Number: " jiraurl
	if [[ "$jiraurl" =~ .*\.atlassian\.net\/browse\/([^/#?]+).* ]]
	then
		jiranum="${BASH_REMATCH[1]}"
	else
		if [[ "$jiraurl" =~ ^[A-Za-z]+-[0-9]+$ ]]
		then
			jiranum="$jiraurl"
		else
			tput civis
			stty -echo
			printf "Invalid URL or JIRA Number:\n${jiraurl}\n\n> Return to TaskBoard"
			read -sp ''
			return
		fi
	fi

	IFS= read -p "Message: " name
	name="${name//\"/\\\"}"
	name="${name//\$/\\\"}"

	read -p "GitHub URL or Repo Name (blank for none): " gitUrl
	repo="$gitUrl"
	if [[ "$gitUrl" =~ .*github\.com\/[^/]+\/([^/]+).* ]]
	then
		repo="${BASH_REMATCH[1]}"
	fi

	# Start new task
	clear-menu
	new "$name" "$jiranum" "$repo"


	# Switch active task to new task
	[ "$active_jira" ] && deactivate-task "$active_jira" "$active_repo" "$active_name"
	active_jira="$jiranum"
	active_repo="$repo"
	active_name="$name"

	# Start timelog
	../timelog/timelog.sh "$(timelog-message "$jiranum" "$repo" "$name")" start
}

close-task() {
	if [ "$jiranum" ]
	then
		close "$(echo "$jiranum" | cut -d ' ' -f 1)"
		../timelog/timelog.sh "$(timelog-message "$jiranum" "$repo" "$name")" end

		if [ "$jiranum" = "$active_jira" ]
		then
			active_jira=
			active_repo=
			active_name=
		fi
	fi
}

open_jira_task() {
    if [[ "$jiranum" ]]
	then
	    open "https://yexttest.atlassian.net/browse/$jiranum"
	fi
}

more_options() {
	menu "\
E: Enable/Disable TaskSwap
I: Change Items Directory
S: Set Current Window Positions as Default
T: TimeReport" ' Return to TaskBoard' 0 'E' 'I' 'S' 'T'

	case "$menu_key" in
		'E' )
			menu_selected=0
			while :
			do
				menu '[Enter]: Enable/Disable App | Q: Save Preferences' "$(
					for app in "${apps[@]}"
					do
						local symbol=' '
						[ ${enabledApps[$(hash "$app")]} ] && symbol='*'
						echo "${symbol}${app}"
					done
				)" $menu_selected 'Q'

				[ "$menu_key" = 'Q' ] && break

				enabledApps[$(hash "${menu_value:1}")]=$([ ${enabledApps[$(hash "${menu_value:1}")]} ] || echo true)
			done

			save-config

		;;

		# Change Items Directory
		'I' )
			clear
			tput cnorm
			stty echo

			echo "Default is ${HOME}/items/"
			echo 'Type the full name of the directory or leave blank to use default:'

			read ITEMS_DIR
			[ "$ITEMS_DIR" ] || ITEMS_DIR="${HOME}/items/"

			save-config
		;;

		# Set Current Window Positions as Default
		'S' )
			if [ "$active_jira" ]
			then
				save-window-bounds "$active_jira" "$active_repo"
				clear
				printf "The current window positions and sizes have been set as default.\n\n> Return to TaskBoard"
				read -p ''
			else
				clear
				printf "You must have an active task to save window positions.\n\n> Return to TaskBoard"
				read -p ''
			fi
		;;

		# TimeReport
		'T' )
			clear
			tput cnorm
			stty echo

			read -p 'Start Date (format yyyy-mm-dd; leave blank for today): ' date
			read -p 'End Date (format yyyy-mm-dd; leave blank for same as start): ' endDate

			[ "$active_jira" ] && ../timelog/timelog.sh "$(timelog-message "$jiranum" "$repo" "$name")" end

			../timelog/timereport.sh "$date" "$endDate"

			[ "$active_jira" ] && ../timelog/timelog.sh "$(timelog-message "$jiranum" "$repo" "$name")" start

			tput civis
			stty -echo

			printf "\n\n> Return to TaskBoard"
			read -p ''
		;;
	esac
}


# PROGRAM START

# Set window title
#osascript -e 'tell app "Terminal" to set custom title of front window to "TaskBoard"' &

# Set up directory and files
cd "$(dirname "${BASH_SOURCE[0]}")"
source taskswap.sh
source ../common/menu.sh
mkdir -p ../appdata/taskboard

# Read TaskSwap settings from config file
[ -f ../appdata/taskboard/taskswap.config ] && source ../appdata/taskboard/taskswap.config

if [ ! "$ITEMS_DIR" ]
then
	clear
	echo 'Welcome to TaskBoard! Please choose a directory for item folders.'
	echo "Default is ${HOME}/items/"
	echo 'Type the full name of the directory or leave blank to use default:'

	read ITEMS_DIR
	[ "$ITEMS_DIR" ] || ITEMS_DIR="${HOME}/items/"

	save-config
fi
mkdir -p "$ITEMS_DIR"

selected=0

while :
do
	menu "\
Q: Quit TaskBoard | N: New Task       | X: Close Selected
[Enter]: Activate/Deactivate Selected | M: More Options
O: Open Associated Task in JIRA       | " "$(load_items "$ITEMS_DIR")" $selected 'Q' 'N' 'X' 'M' 'O'

	selected=$menu_selected
	jiranum="$(echo "${menu_value:1}" | cut -d ' ' -f 1)"
	repo=
	name="$(echo "${menu_value:1} " | cut -d ' ' -f 4-)"

	case "$menu_key" in
		'' ) select-task;;
		'Q' ) quit;;
		'N' ) new-task;;
		'X' ) close-task;;
		'M' ) more_options;;
		'O' ) open_jira_task;;
	esac
done
