#!/bin/sh

## Filename : 00_config.sh
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

# SVN base path
# SVN_BASE_PATH="https://svn.domain.com"
SVN_BASE_PATH=""

# SVN username
# SVN_USER="your-username"
SVN_USER="<SVN_USERNAME>"

# SVN author's email suffix
# SVN_AUTHOR_EMAIL_SUFFIX="your-company.com"
SVN_AUTHOR_EMAIL_SUFFIX="<YOUR_DOMAIN>"

# Git base path (SSH or HTTP/s)
# GIT_BASE_PATH="https://git.domain.com"
GIT_BASE_PATH=""

# Folder name for storing trunk version code
MASTER_BRANCH_FOLDER_NAME="master"

# Folder name for storing trunk version code
DEVELOP_BRANCH_FOLDER_NAME="develop"

# Folder name for storing release branches code
RELEASE_BRANCH_FOLDER_PREFIX="release"
