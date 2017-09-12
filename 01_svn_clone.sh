#!/bin/sh

## Filename : 01_svn_clone.sh
## Author   : Robertus Lilik Haryanto <robert.djokdja@gmail.com>
##
## This script is a SVN to Git migration clone tool

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
echo "SVN to Git clone script"
echo "-----------------------"
echo

# usage() method to show how to use this script
usage() {
   echo "Usage: ./01_svn_clone [master/develop/release/hotfix/feature] [svn_remote_url] [svn_username] [project_name] [subfolder_name_or_branch_name_if_any] [authors_file_if_any]"
   echo "Example: "
   echo "   ./01_svn_clone.sh master http://my_svn_repo/project_name/trunk svnuser project_name"
   echo "   ./01_svn_clone.sh master http://my_svn_repo/project_name/trunk svnuser project_name \"\" authors.txt"
   echo "   ./01_svn_clone.sh release http://my_svn_repo/project_name/release_v1.0 svnuser project_name v1.0"
   echo "   ./01_svn_clone.sh release http://my_svn_repo/project_name/release_v1.0 svnuser project_name v1.0 authors.txt"
   echo
}

# Arguments validation
if [ "$#" -eq 0 ] || [ "$#" -gt 5 ]; then
   usage
   exit 1
fi

# Catch all arguments
BRANCH=$1
SVN_REMOTE_URL=$2
SVN_USERNAME=$3
PROJECT_NAME=$4
SUBFOLDER_NAME=$5
AUTHORS_FILE_PARAM=$6

echo "Your parameters"
echo "---------------"
echo "# Branch Name       : $BRANCH"
echo "# SVN Remote URL    : $SVN_REMOTE_URL"
echo "# SVN Username      : $SVN_USERNAME"
echo "# Project Name      : $PROJECT_NAME"
echo "# Subfolder Name    : $SUBFOLDER_NAME"
echo "# Authors File Name : $AUTHORS_FILE_PARAM"
echo

read -n 1 -s -r -p "Press any key to continue"
echo

echo ">> Initializing..."

# Internal configuration
BASE_PATH=$(pwd)
LIB_PATH="$BASE_PATH/libs"

DEFAULT_AUTHOR_EMAIL_SUFFIX="mycompany.com"

# Read external configuration file
. "$BASE_PATH/00_config.sh"

# If master/develop branch
if [ "$BRANCH" = "master" ] || [ "$BRANCH" = "develop" ]; then
   AUTHORS_FILE="authors_$BRANCH.txt"

   if [ "$SUBFOLDER_NAME" = "" ]; then
      DESTINATION_FOLDER="$BASE_PATH/repo/$PROJECT_NAME/$BRANCH"
   else
      DESTINATION_FOLDER="$BASE_PATH/repo/$PROJECT_NAME/$SUBFOLDER_NAME"
   fi

# If release/hotfix/feature branch
elif [ "$BRANCH" = "release" ] || [ "$BRANCH" = "hotfix" ] || [ "$BRANCH" = "feature" ]; then
   AUTHORS_FILE="authors_$BRANCH.txt"
   DESTINATION_FOLDER="$BASE_PATH/repo/$PROJECT_NAME/$BRANCH-$SUBFOLDER_NAME"
fi

# Cleaning up the workspace...
echo ">> Cleaning up the workspace..."
if [ -d "$BASE_PATH/repo/$PROJECT_NAME" ]; then
   rm -fR "$DESTINATION_FOLDER"
fi
mkdir -p "$DESTINATION_FOLDER"

# Extracting all authors of $PROJECT_NAME if $AUTHORS_FILE_PARAM is not specified...
if [ -z "$AUTHORS_FILE_PARAM" ]; then
   echo ">> Extracting all authors of $PROJECT_NAME..."
   java -jar $LIB_PATH/svn-migration-scripts.jar authors $SVN_REMOTE_URL > $BASE_PATH/repo/$PROJECT_NAME/$AUTHORS_FILE
   AUTHORS_FILE_PARAM=$BASE_PATH/repo/$PROJECT_NAME/$AUTHORS_FILE
   echo "(no author) = no author <no_author@$SVN_AUTHOR_EMAIL_SUFFIX>" >> $BASE_PATH/repo/$PROJECT_NAME/$AUTHORS_FILE
   sed -i -e "s/$DEFAULT_AUTHOR_EMAIL_SUFFIX/$SVN_AUTHOR_EMAIL_SUFFIX/g" $BASE_PATH/repo/$PROJECT_NAME/$AUTHORS_FILE
fi

# Migrating $SVN_REMOTE_URL into local repository...
echo ">> Cloning $SVN_REMOTE_URL into local repository..."
git svn clone "$SVN_REMOTE_URL" --username $SVN_USERNAME -A $BASE_PATH/repo/$PROJECT_NAME/$AUTHORS_FILE $DESTINATION_FOLDER

# Done
echo ">> Done!"
