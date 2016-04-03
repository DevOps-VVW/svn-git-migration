#!/bin/sh

## Filename : 03_git_sync.sh
## Author   : Robertus Lilik Haryanto <robert.djokdja@gmail.com>

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

# usage() method to show how to use this script
usage() {
    echo "SVN to Git synchronization tool"
    echo "-------------------------------"
    echo "Usage: ./03_git_sync.sh [master/release] [svn_project_path] [project_name] [release_branch_name_if_any]"
    echo "Example: "
	echo "   ./03_git_sync.sh master project_name/trunk project_name"
	echo "   ./03_git_sync.sh release project_name/trunk project_name v1.0"
    echo
}

# Arguments validation
if [ "$#" -eq 0 ] || [ "$#" -gt 4 ]; then
    usage
    exit 1
fi

echo ">> Initializing..."

# Internal configuration
BASE_PATH=$(pwd)
LIB_PATH="$BASE_PATH/libs"

# Read external configuration file
source $BASE_PATH/00_config.sh

# Catch all arguments
SVN_PROJECT_PATH=$2
PROJECT_NAME=$3
RELEASE_BRANCH_NAME=$4

# If master branch
if [ "$1" = "master" ]; then

    AUTHORS_FILE="authors_master.txt"
    DESTINATION_FOLDER="$BASE_PATH/repo/$PROJECT_NAME/$MASTER_BRANCH_FOLDER_NAME"
    
    cd $DESTINATION_FOLDER

    git checkout develop

    # Synchronizing with latest SVN checkins
    echo ">> Synchronizing with latest SVN checkins..."
    git svn fetch

    # Updating authors.txt
    echo ">> Updating authors.txt..."
    java -jar $LIB_PATH/svn-migration-scripts.jar authors $SVN_BASE_PATH/$SVN_PROJECT_PATH > $BASE_PATH/repo/$PROJECT_NAME/$AUTHORS_FILE

    # Rebasing
    echo "Rebasing..."
    git svn rebase
    git merge
    git commit -m "Synched up from latest SVN revision"

    # Pushing 'develop' branch to 'origin/develop'
    echo ">> Pushing 'develop' branch to 'origin/develop'..."
    git push

    # Merging 'develop' to 'master' 
    echo ">> Merging 'develop' to 'master'..."
    git checkout master
    git pull origin master
    git merge develop
    git push origin master

# If release branch
elif [ "$1" = "release" ]; then

    AUTHORS_FILE="authors-$RELEASE_BRANCH_NAME.txt"
    DESTINATION_FOLDER="$BASE_PATH/repo/$PROJECT_NAME/$RELEASE_BRANCH_FOLDER_PREFIX_$RELEASE_BRANCH_NAME"
    
    cd $DESTINATION_FOLDER

	# Checking out release branch
    git checkout release/$RELEASE_BRANCH_NAME

    # Synchronizing with latest SVN checkins
    echo ">> Synchronizing with latest SVN checkins..."
    git svn fetch

    # Updating authors.txt
    echo ">> Updating authors.txt..."
    java -jar $LIB_PATH/svn-migration-scripts.jar authors $SVN_BASE_PATH/$SVN_PROJECT_PATH > $BASE_PATH/repo/$PROJECT_NAME/$AUTHORS_FILE

    # Rebasing
    echo ">> Rebasing..."
    git svn rebase
    git merge
    git commit -m "Synched up from latest SVN revision of '$SVN_PROJECT_PATH'"

    # Pushing 'release/$RELEASE_BRANCH_NAME' branch to remote 'origin/release/$RELEASE_BRANCH_NAME'
    echo ">> Pushing 'release/$RELEASE_BRANCH_NAME' branch to 'origin release/$RELEASE_BRANCH_NAME'..."
    git push -u origin "release/$RELEASE_BRANCH_NAME"

fi

cd $BASE_PATH

# Done
echo ">> Done!"
