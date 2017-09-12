#!/bin/sh

## Filename : 03_git_sync.sh
## Author   : Robertus Lilik Haryanto <robert.djokdja@gmail.com>
##
## This script is a SVN to Git migration syncronization tool

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
echo "SVN to Git synchronization tool"
echo "-------------------------------"
echo

# usage() method to show how to use this script
usage() {
   echo "Usage: ./03_git_sync.sh [master/release] [svn_remote_url] [project_name] [subfolder_name_or_branch_name]"
   echo "Example: "
   echo "   ./03_git_sync.sh master http://my_svn_repo/project_name/trunkk project_name"
   echo "   ./03_git_sync.sh release http://my_svn_repo/project_name/trunk project_name v1.0"
   echo
}

# Arguments validation
if [ "$#" -eq 0 ] || [ "$#" -gt 4 ]; then
   usage
   exit 1
fi

# Catch all arguments
BRANCH=$1
SVN_REMOTE_URL=$2
PROJECT_NAME=$3
SUBFOLDER_NAME=$4

echo "Your parameters"
echo "---------------"
echo "# Branch Name       : $BRANCH"
echo "# SVN Remote URL    : $SVN_REMOTE_URL"
echo "# Project Name      : $PROJECT_NAME"
echo "# Subfolder Name    : $SUBFOLDER_NAME"
echo

read -n 1 -s -r -p "Press any key to continue"
echo

echo ">> Initializing..."

# Internal configuration
BASE_PATH=$(pwd)
LIB_PATH="$BASE_PATH/libs"

# Read external configuration file
. "$BASE_PATH/00_config.sh"

# If master/develop branch
if [ "$BRANCH" = "master" ] || [ "$BRANCH" = "develop" ]; then

   AUTHORS_FILE="authors_master.txt"

   if [ "$SUBFOLDER_NAME" = "" ]; then
      DESTINATION_FOLDER="$BASE_PATH/repo/$PROJECT_NAME/$BRANCH"
   else
      DESTINATION_FOLDER="$BASE_PATH/repo/$PROJECT_NAME/$SUBFOLDER_NAME"
   fi

   cd "$DESTINATION_FOLDER" || exit

   echo ">> Updating latest changes on Git..."
   git checkout $BRANCH

   # Synchronizing with latest SVN checkins
   echo ">> Synchronizing with latest SVN checkins..."
   git svn fetch

   # Updating authors.txt
   echo ">> Updating authors file..."
   java -jar $LIB_PATH/svn-migration-scripts.jar authors $SVN_REMOTE_URL > $BASE_PATH/repo/$PROJECT_NAME/$AUTHORS_FILE

   # Rebasing
   echo ">> Rebasing..."
   git svn rebase
   git merge
   git commit -m "Synched up from latest SVN revision"

   # Pushing changes to '$BRANCH'
   echo ">> Pushing changes to '$BRANCH'..."
   git push origin $BRANCH

# If release/hotfix/feature branch
elif [ "$BRANCH" = "release" ] || [ "$BRANCH" = "hotfix" ] || [ "$BRANCH" = "feature" ]; then

   AUTHORS_FILE="authors-$SUBFOLDER_NAME.txt"
   DESTINATION_FOLDER="$BASE_PATH/repo/$PROJECT_NAME/$BRANCH-$SUBFOLDER_NAME"

   cd "$DESTINATION_FOLDER" || exit

   echo ">> Updating latest changes on Git..."
   git checkout $BRANCH/$SUBFOLDER_NAME

   # Synchronizing with latest SVN checkins
   echo ">> Synchronizing with latest SVN checkins..."
   git svn fetch

   # Updating authors.txt
   echo ">> Updating authors file..."
   java -jar $LIB_PATH/svn-migration-scripts.jar authors $SVN_REMOTE_URL > $BASE_PATH/repo/$PROJECT_NAME/$AUTHORS_FILE

   # Rebasing
   echo ">> Rebasing..."
   git svn rebase
   git merge
   git commit -m "Synched up from latest SVN revision of '$SVN_REMOTE_URL'"

   # Pushing changes to '$BRANCH/$RELEASE_BRANCH_NAME'
   echo ">> Pushing changes to '$BRANCH/$SUBFOLDER_NAME'..."
   git push -u origin "$BRANCH/$SUBFOLDER_NAME"

fi

cd "$BASE_PATH" || exit

# Done
echo ">> Done!"
