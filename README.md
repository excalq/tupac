# Tupac - A web-based _wrapper_ for Chef build and deployment tools

## Version

Version 0.01 - July 1, 2012


## Concept

Tupac is a web-based tool for system administration in a multi-admin, multi-server environment of servers.
This tool is designed to be an easy to use UI to run shell commands (which should be preset in the server's sudoers file).

### Requirements

* Ruby 1.9
* Postgresql, MySQL, SQLite, or any database supported by ActiveRecord
* Network SSH access between this server and the target servers (servers which deployment and commands will be run on).
* Root access on the Tupac server to configure sudo and create a "tupac" user which will store SSH keys and issue remote commands.
* Root or appropriate access rights via SSH on the target servers.


## Architecture

Tupac is written with Ruby on Rails, and requires the following Gems:
  * (TODO: Gemlist)

It requires any database supported by active record (tested with Postgresql and SQLite)

It uses Google oAuth to authenticate users from a given domain, and checks them against a list of groups supplied by the admin user.
Users are usually assigned a group, and each group has specific permissions to do certain actions in the system.

Users may run tasks, add notes, and view history entries.

## Installation

  1. Install Ruby, RVM, etc. I'll assume you have this installed already
  2. Install this application. If you're using git do:
     `[GIT CLONE COMAND]`
     otherwise:
     `[WGET COMMAND]`
  3. Create a "tupac" system user on the Tupac server
  4. Install your database, and configure the file `config/database.yml` with your db, username, and password.
  5. Install/Configure the webserver stack (e.g. Unicorn, Passenger, Nginx, Apache) to allow this rails app to be web accessible. DO NOT RUN RAILS OR THE WEBSERVER AS THE "tupac" SYSTEM USER!
  6. Run `bundle install`
  7. Login using the username: "admin", and password: "this-password-will-self-destruct" (which will expire on first login)
  8. Create lists of groups and add users to them
  9. Create commands and server lists



## Usage

### User Access

On the first login, you will use the admin account, however for typical usage you should use oAuth.

New users will be given a group, either "No Group" or a group specified by admin.

Groups will have rights to specific tasks, commands, and views. Here are details of access control list behavior:
  
  *Predefined Groups:*
  * admin: Users in this group can do anything, including modifiying other users' rights.
  * no-group: Users that are not memebers of any other group. This group typically has no or few permissions.
  
  *Access Objects*
  * commands: SSH commands that can be run on servers
  * servers: individual target servers
  * environments: collections of servers
  * posts-create: adding and editing post entries
  * posts-moderate: editing or deleting other people's posts
  * routes: Application's controllers and actions, for allowing/denying access to specific pages/functionality


### Adding commands to the application

  Use the "Add New Command" tool to add a new command to the system.
  It will output a "sudoers" configuration block of text, which you will then add to the sudoers configuration. (See [Configuring Sudo](#config-sudo))
  
  


## Appendix

### <a id="config-sudo"></a>Configuring Sudo
  *Warnging:* Be extremely careful monkeying with /etc/sudoers, by the way. It's easy to lock yourself out of your system.

  Always use [visudo](http://www.gratisoft.us/sudo/visudo.man.html) to edit /etc/sudoers. It detects errors when you update the file.


  *Debian/Ubuntu 10.04+ users:* Add also sudo configuration content to /etc/sudoers.d/tupac

  If you've upgraded from an older version of your OS, you may need to add `#includedir /etc/sudoers.d` to /etc/sudoers.


  Allow sudo to run Tupac commands by inserting the following into /etc/sudoers using visudo.
  `visudo`


```
Defaults:tupac   !requiretty
User_Alias	TUPAC = tupac

###
# Commands
#
Cmnd_Alias	TCOMMANDS = /bin/echo "** test tupac sudo **"

###
# Sudo Access for Tupac
#
TUPAC	ALL=(tupac) TCOMMANDS
  
```

  Test the command locally in the shell using sudo.

## 
