SVN to Git migration Shell script
==========================

This migration script is a Shell script for migrating source code from Subversion (SVN) to Git without losing its history. It can be running in Linux/Unix environment. It provides 3 scripts:

- `01_git_clone.sh`
  
  Script for pulling all code from Subversion server into local Git repository.

- `02_git_push.sh`

  Script for pushing all code from local Git repository into remote Git server.

- `03_git_sync.sh`

  Script for synchronizing all code changes in Subversion server into local Git repository and push it into remote Git server.

  
> This script has been well-tested with [CollabNet SubversionEdge][subversionedge] as Subversion (SVN) server and [GitLab][gitlab] as a Git server.


## Version

1.0.0

## Author

[Robertus Lilik Haryanto][my-email]

## Installation

Clone this project into your local, and configure 00_config.sh. Just simply execute `01_git_clone.sh`, `02_git_push.sh`, and `03_git_sync.sh` sequentially with a proper arguments.


> Feel free to fork this project for your specific purpose.

   [my-email]: <mailto:robert.djokdja@gmail.com>
   [subversionedge]: <http://www.collab.net/products/subversion>
   [gitlab]: <https://about.gitlab.com/>
