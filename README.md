# CE Tools
*A repository for scripts and automation tools related to Consulting Engineering*

### INSTALL INSTRUCTIONS:
1. Clone this repo
2. Run install.sh (or `source` it to skip step 3)
3. Restart your terminal
4. Done! To use, run shortcuts in Terminal (e.g. run `tb.sh` for TaskBoard)

### How to Use TaskBoard:
1. After following the install instructions, run tb.sh to launch TaskBoard
2. In TaskBoard, press N to start a new task
3. Enter the JIRA number or the URL of the JIRA item's page
4. Enter the GitHub URL of the repo for the item or a custom message
5. Time is counted for the active task, denoted by *
6. Switch between tasks with arrows and Enter
7. See time worked per item and log to JIRA in More Options > TimeReport
8. Optionally enable automatic Chrome, Terminal, and/or Atom window switching in More Options > Enable/Disable TaskSwap

## Contents

### TaskBoard
*Shortcut: tb*
- Easily create and switch between tasks through a terminal GUI
- Automatically track time per item with option to submit to JIRA
- Assign tasks a JIRA number and GitHub repo or message
- Automatically clone repo and install node modules
- Open Atom to repo and Chrome to JIRA, GitHub, and Storm for the site
- Integration with TimeLog to track time spent on each task
- Integration with TimeReport to submit time to JIRA

### TimeLog
*Shortcut: tl*
- Keep track of time spent on a task
- Supports multiple tasks running concurrently
- Log time using commands "start" and "end" with matching messages
- Or log time using commands "from" and "to" to log a duration from a start time or to an end time

### TimeReport
*Shortcut: tr*
- Get a report of time spent on each task
- See time on a single day or in a range of days
- Submit time to JIRA, logged individually for each item on each day

### Scripts
*Shortcut: ce [SCRIPTNAME]*
- add-dns: step-through automation of adding a DNS entry (bridge domain)
- custom-field-audit: find all the custom fields used in a site
- deactivate-site: step through the process of deactivating a Pages site
- pager: run old pager (json pager)
- repo-fixes: fix yarn install errors, README location, and node version < 5
- reset-alpha: reset the local repo of alpha by re-cloning, re-installing, and re-making binaries
- s3-download: download site files from S3
- sites-pager-helper: start sites-pager for a site
- update: update alpha, generator-ysp, pages-builder, pages-tools, ce-tools, and homebrew
