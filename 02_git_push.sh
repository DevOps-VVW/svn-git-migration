#!/bin/sh

## Filename : 02_git_push.sh
## Author   : Robertus Lilik Haryanto <robert.djokdja@gmail.com>
##
## This script is a SVN to Git migration push tool

#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

echo
echo "SVN to Git push script"
echo "----------------------"
echo

# usage() method to show how to use this script
usage() {
	echo "Usage: ./02_git_push.sh [master/develop/release/hotfix/feature] [git_remote_url] [project_name] [subfolder_name_or_branch_name]"
	echo "Example: "
	echo "   ./02_git_push.sh release https://github.com/my_repo/project_name.git project_name v1.0"
	echo
}

# Arguments validation
if [ "$#" -eq 0 ] || [ "$#" -gt 4 ]; then
	usage
	exit 1
fi

# Catch all arguments
BRANCH=$1
GIT_REMOTE_URL=$2
PROJECT_NAME=$3
SUBFOLDER_NAME=$4

echo "Your parameters"
echo "---------------"
echo "# Branch Name       : $BRANCH"
echo "# Git Remote URL    : $GIT_REMOTE_URL"
echo "# Project Name      : $PROJECT_NAME"
echo "# Subfolder Name    : $SUBFOLDER_NAME"
echo

read -n 1 -s -r -p "Press any key to continue"
echo

echo ">> Initializing..."

# Internal configuration
BASE_PATH=$(pwd)

# Read external configuration file
. "$BASE_PATH/00_config.sh"

# If master/develop branch
if [ "$BRANCH" = "master" ] || [ "$BRANCH" = "develop" ]; then

	if [ "$SUBFOLDER_NAME" = "" ]; then
      DESTINATION_FOLDER="$BASE_PATH/repo/$PROJECT_NAME/$BRANCH"
   else
      DESTINATION_FOLDER="$BASE_PATH/repo/$PROJECT_NAME/$SUBFOLDER_NAME"
   fi

	cd "$DESTINATION_FOLDER" || exit

	# Commiting and pushing project to Git...
	echo ">> Commiting and pushing project..."
	git remote add origin "$GIT_REMOTE_URL"
	git add .
	git commit

	# Change branch
	git branch $BRANCH

	# Pushing changes to Git...
	echo ">> Pushing changes to '$BRANCH'..."
	git push -u origin "$BRANCH"

# If release/hotfix/feature branch
elif [ "$BRANCH" = "release" ] || [ "$BRANCH" = "hotfix" ] || [ "$BRANCH" = "feature" ]; then

	DESTINATION_FOLDER="$BASE_PATH/repo/$PROJECT_NAME/$BRANCH-$SUBFOLDER_NAME"

	cd "$DESTINATION_FOLDER" || exit

	# Commiting and pushing project to Git...
	echo ">> Commiting and pushing project..."
	git remote add origin "$GIT_REMOTE_URL"

	# Setting up Git flow...
	echo ">> Setting up Git flow..."
	git flow init -fd

	#Starting release $RELEASE_BRANCH_NAME...
	echo ">> Starting $BRANCH/$SUBFOLDER_NAME branch..."
	git flow $BRANCH start "$SUBFOLDER_NAME"

	# Copying all changes from branch to $BRANCH/$SUBFOLDER_NAME...
	echo ">> Copying all changes from branch to $BRANCH/$SUBFOLDER_NAME..."
	git add .
	git commit

	# Pushing all changes to $BRANCH/$SUBFOLDER_NAME...
	echo ">> Pushing all changes to '$BRANCH/$SUBFOLDER_NAME'..."
	git push -u origin "$BRANCH/$SUBFOLDER_NAME"

fi

cd "$BASE_PATH" || exit

# Done
echo ">> Done!"
