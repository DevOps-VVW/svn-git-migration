#!/bin/sh

## Filename : 01_svn_clone.sh
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
    echo "SVN to Git clone tool for trunk project"
    echo "---------------------------------------"
    echo "Usage: ./01_svn_clone [master/release] [svn_project_path_after_prefix] [local_destination_folder] [release_branch_name_if_any] [authors_file_if_any]"
    echo "Example: "
	echo "   ./01_svn_clone.sh master project_name/trunk project_name"
	echo "   ./01_svn_clone.sh master project_name/trunk project_name \"\" authors.txt"
	echo "   ./01_svn_clone.sh release project_name/trunk project_name v1.0"
	echo "   ./01_svn_clone.sh release project_name/trunk project_name v1.0 authors.txt"
    echo
}

# Arguments validation
if [ "$#" -eq 0 ] || [ "$#" -gt 5 ]; then
    usage
    exit 1
fi

echo ">> Initializing..."

# Internal configuration
BASE_PATH=$(pwd)
LIB_PATH="$BASE_PATH/libs"

DEFAULT_AUTHOR_EMAIL_SUFFIX="mycompany.com"

# Read external configuration file
source $BASE_PATH/00_config.sh

# Catch all arguments
SVN_PROJECT_PATH=$2
PROJECT_NAME=$3
RELEASE_BRANCH_NAME=$4
AUTHORS_FILE_PARAM=$5

# If master branch
if [ "$1" = "master" ]; then
    AUTHORS_FILE="authors_master.txt"
    DESTINATION_FOLDER="$BASE_PATH/repo/$PROJECT_NAME/$MASTER_BRANCH_FOLDER_NAME"
	
# If develop branch
elif [ "$1" = "develop" ]; then
    AUTHORS_FILE="authors_develop.txt"
    DESTINATION_FOLDER="$BASE_PATH/repo/$PROJECT_NAME/$DEVELOP_BRANCH_FOLDER_NAME"

# If release branch
elif [ "$1" = "release" ]; then
    AUTHORS_FILE="authors_$RELEASE_BRANCH_NAME.txt"
    DESTINATION_FOLDER="$BASE_PATH/repo/$PROJECT_NAME/$RELEASE_BRANCH_FOLDER_PREFIX-$RELEASE_BRANCH_NAME"
fi

# Cleaning up the workspace...
echo ">> Cleaning up the workspace..."
if [ -d $BASE_PATH/repo/$PROJECT_NAME ]; then
    if [ "$1" = "master" ]; then
        rm -fR $BASE_PATH/repo/$PROJECT_NAME
    elif [ "$1" = "release" ]; then
        rm -fR $BASE_PATH/repo/$PROJECT_NAME/$RELEASE_BRANCH_FOLDER_PREFIX-$RELEASE_BRANCH_NAME
    fi
fi
mkdir -p $DESTINATION_FOLDER

# Extracting all authors of $PROJECT_NAME if $AUTHORS_FILE_PARAM is not specified...
if [ -z "$AUTHORS_FILE_PARAM" ]; then
    echo "Extracting all authors of $PROJECT_NAME..."
    java -jar $LIB_PATH/svn-migration-scripts.jar authors $SVN_BASE_PATH/$SVN_PROJECT_PATH > $BASE_PATH/repo/$PROJECT_NAME/$AUTHORS_FILE
    AUTHORS_FILE_PARAM=$BASE_PATH/repo/$PROJECT_NAME/$AUTHORS_FILE
fi
echo "(no author) = no author <no_author@$SVN_AUTHOR_EMAIL_SUFFIX>" >> $BASE_PATH/repo/$PROJECT_NAME/$AUTHORS_FILE
sed -i -e "s/$DEFAULT_AUTHOR_EMAIL_SUFFIX/$SVN_AUTHOR_EMAIL_SUFFIX/g" $BASE_PATH/repo/$PROJECT_NAME/$AUTHORS_FILE

# Migrating $SVN_BASE_PATH/$SVN_PROJECT_PATH into local repository...
echo ">> Migrating $SVN_BASE_PATH/$SVN_PROJECT_PATH into local repository..."
git svn clone $SVN_BASE_PATH/$SVN_PROJECT_PATH --username $SVN_USER -A $BASE_PATH/repo/$PROJECT_NAME/$AUTHORS_FILE $DESTINATION_FOLDER

# Done
echo ">> Done!"