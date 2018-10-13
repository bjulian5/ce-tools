jira-auth() {
	username="$1"
	if [ ! "$username" ]
	then
		username="$(security find-generic-password -s "TimeLog" -l "JIRA API token" | grep '"acct"' | cut -d = -f 2 | tr -d \")"

		while [ ! "$username" ]
		do
			read -p "JIRA Username: " username
		done
	fi

	apiToken="$(security find-generic-password -s "TimeLog" -a "$username" -w)"

	if [ ! "$apiToken" ]
	then
		echo "Enter your JIRA API token for ${username}"
		echo "If you haven't created a token yet, create one here:"
		echo "https://id.atlassian.com/manage/api-tokens"

		while [ ! "$apiToken" ]
		do
			read -sp "API Token: " apiToken
			echo ""
		done

		if [[ "$(read -p "Save your token in Keychain? (y/N) ")" =~ ^[Yy]([Ee][Ss])?$ ]]
		then
			security add-generic-password -s "TimeLog" -a "$username" -l "JIRA API token" -p "$apiToken" -U
		fi
	else
		if [ "$2" ] && [ ! "$2" = "$apiToken" ]
		then
			echo "The given API token does not match the saved token for '${username}'."
			if [[ "$(read -p "Update saved token? (y/N) ")" =~ ^[Yy]([Ee][Ss])?$ ]]
			then
				security add-generic-password -s "TimeLog" -a "$username" -l "JIRA API token" -p "$apiToken" -U
			fi

			apiToken="$2"
		fi
	fi
}