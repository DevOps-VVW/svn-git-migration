#!/bin/sh

## Filename : 02_git_push.sh
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
    echo "SVN to Git push tool for trunk project"
    echo "--------------------------------------"
    echo "Usage: ./02_git_push.sh [master/release] [project_name] [username/team_name] [release_branch_name_if_any]"
    echo "Example: "
	echo "   ./02_git_push.sh master project_name lilik.haryanto"
	echo "   ./02_git_push.sh release project_name lilik.haryanto v1.0"
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
PROJECT_NAME=$2
USER_TEAM_NAME=$3
RELEASE_BRANCH_NAME=$4

# If master branch
if [ "$1" = "master" ]; then

    cd $BASE_PATH/repo/$PROJECT_NAME/$MASTER_BRANCH_FOLDER_NAME
    
	# Commiting and pushing project to Git...
    echo ">> Commiting and pushing project to Git..."
    git remote add origin $GIT_BASE_PATH:$USER_TEAM_NAME/$PROJECT_NAME.git
    git add .
    git commit
    git push -u origin master

	# Setting up Git flow...
    echo ">> Setting up Git flow..."
    git flow init -fd
    
	# Pushing changes to Git...
    echo ">> Pushing changes to Git..."
    git push -u origin develop
    
# If release branch
elif [ "$1" = "release" ]; then

    cd $BASE_PATH/repo/$PROJECT_NAME/$RELEASE_BRANCH_FOLDER_PREFIX-$RELEASE_BRANCH_NAME
    
	# Commiting and pushing project to Git...
    echo ">> Commiting and pushing project to Git..."
    git remote add origin $GIT_BASE_PATH:$USER_TEAM_NAME/$PROJECT_NAME.git
    
	# Setting up Git flow...
    echo ">> Setting up Git flow..."
    git flow init -fd

	#Starting release $RELEASE_BRANCH_NAME...
    echo ">> Starting release $RELEASE_BRANCH_NAME..."
    git flow release start "$RELEASE_BRANCH_NAME"

	# Copying all changes from branch to release/$RELEASE_BRANCH_NAME...
    echo ">> Copying all changes from branch to release/$RELEASE_BRANCH_NAME..."
    git add .
    git commit

	# Pushing all changes to release/$RELEASE_BRANCH_NAME...
    echo ">> Pushing all changes to release/$RELEASE_BRANCH_NAME..."
    git push -u origin "release/$RELEASE_BRANCH_NAME"
	
fi

cd $BASE_PATH

# Done
echo ">> Done!"
