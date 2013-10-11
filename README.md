# Tupac - A web-based wrapper for sysadmin tasks

_Version_: 0.02 - July 30, 2012

_Author_: Arthur Ketcham at [Gloo.us / Tango Group](http://gloo.us/)


**Status**: Currently in development, usable but does not yet have a turn-key setup.


Tupac is a web-based tool for system administration in a multiple administrator, server, and environment setting.
This tool is designed to be an easy to use UI to run shell commands on remote servers. Simply put, it manages and wraps 
remote SSH commands specified in the [sudoers config](https://help.ubuntu.com/community/Sudoers).

This makes it easy to build a list of commands, such as deployments tasks, associate them with target servers
and environments, and allow users to run them. Everything that happens is recorded in a searchable log. 
It also ensures security by using sudoers to store allowed commands and arguments.

This is a great web tool for running tasks with Chef, Knife, Capistrano, Rake, and literally anything else you can do via SSH.

### Requirements

* Ruby 1.9
* Postgresql, MySQL, SQLite, or any database supported by ActiveRecord
* Network SSH access between this server and the target servers (servers upon which commands will be run)
* Root access on this server, for configuring accounts and runnable command lists
* Root or appropriate access rights via SSH on the target servers

## Architecture

Tupac is written with Ruby on Rails, and requires the following Gems:
  * (TODO: Gemlist)

It requires any database supported by active record (tested with Postgresql and SQLite)

It uses Google OAuth to authenticate users from a given domain, and checks them against a list of groups supplied by the admin user.
Users are usually assigned a group, and each group has specific permissions to do certain actions in the system.

Users may run tasks, add notes, and view history entries.

## Installation

  1. Install Ruby, RVM, etc. I'll assume you have this installed already
  2. Install this application. If you're using git do:
     `git clone git@github.com:excalq/tupac.git`
     otherwise:
     `wget https://github.com/excalq/tupac/zipball/master`
  3. Create a "tupac" system user on the Tupac server
  4. Install your database, and configure the file `config/database.yml` with your db, username, and password.
  5. Install/Configure the webserver stack (e.g. Unicorn, Passenger, Nginx, Apache) to allow this rails app to be web accessible. 
     * **Do not run rails or the webserver as the "tupac" system user!**
  6. Run `bundle install`
  7. Log in to Tupac using the username: "_admin_", and password: "_this password will self destruct_" (expires on first login!)
  8. In the app, create groups and add associate users to them
  9. Users will login via OAuth, and have the permissions set by admins.
  10. Admins will create sets of commands, servers, and environments which can be run.


## Usage

### User Access

On the first login, you will use the admin account, however typically, users will use OAuth (in our install, we restrict users to a Google Apps domain).

New users will be given a group, either "no_group" or a group specified by admin.

Groups will have rights to specific tasks, commands, and views. Here are details of access control list behavior:

**Predefined Groups:**
  * *admin*: Users in this group can do anything, including modifiying other users' rights.
  * *no_group*: Users that are not memebers of any other group. This group typically has no or few permissions.

**Access Objects**
  * *commands*: SSH commands that can be run on servers
  * *servers*: individual target servers
  * *environments*: collections of servers
  * *posts_create*: adding and editing post entries
  * *posts_moderate*: editing or deleting other people's posts
  * *routes*: Application's controllers and actions, for allowing/denying access to specific pages/functionality


### Adding Commands

  Use the "Add New Command" tool to add a new command to the system.
  It will output a "sudoers" configuration block of text, which you will then add to the sudoers configuration. (See [Configuring Sudo](#config-sudo))


## Other Features

### Configuring Environments
  * Create environments like "Production", "Staging", etc.
  * Each environment will have a different UI background color. This is to make it really fscking obvious and [avoid accidents](https://github.com/blog/744-today-s-outage).


### Configuring Servers
  * SSH Keys
    * Generate local server server keys, as user _tupac_
    * Copy public keys into target servers' .ssh/authorized_keys file
    * Add certain commands which require root access to target severs' sudo configuration

### Logging
  * Tupac logs everything that is done. Failures are easy to identify and diagnose, and users and times are noted as well.
  * The log is searchable and filterable

### Freeform Posts
  * Post notes which are associated with servers, environments, deployments, or commands.
  * These notes can be useful for flagging temporary issues, keep todo items noted, or notices to other admins


## Appendix

### <a name="config-sudo"></a>Configuring Sudo
  **Warning:** Be extremely careful monkeying with /etc/sudoers!!! It's easy to lock yourself out of your system.

  For saftey, always use [visudo](http://www.gratisoft.us/sudo/visudo.man.html) to edit /etc/sudoers. It detects errors when you update the file.


  **Debian/Ubuntu 10.04+ users:** Add all sudo configuration content to /etc/sudoers.d/tupac instead of /etc/sudoers
  If you've upgraded from an older version of your OS, you may need to add `#includedir /etc/sudoers.d` to /etc/sudoers.


  Allow sudo to run Tupac commands by inserting the following into the sudoer's config (using `visudo` or editing /etc/sudoers.d/tupac)


```bash
Defaults:tupac        !requiretty

# Include the user you run rake for spec tests.
User_Alias            TUPAC = tupac, arthur

###
# Commands
# The first command is used to test the initial configuration
# Each new command added in Tupac gives a line item to insert here
##
Cmnd_Alias     TCOMMANDS = /bin/echo --- test [[\:alpha\:]]* sudo ---

###
# Sudo Access for Tupac
##
TUPAC          ALL=(tupac) NOPASSWD: TCOMMANDS

```

Test new commands locally in the shell using sudo.

`sudo su tupac -c 'echo "--- test tupac sudo ---"'`


## License
Tupac was developed by Arthur Ketcham at [Gloo.us / Tango Group](http://gloo.us/). It is released under the MIT license:

www.opensource.org/licenses/MIT
