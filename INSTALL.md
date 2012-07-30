## Install Notes

_This document is still a draft it needs clean up, edits, and review.

### 1. Add user "tupac"
  * Could script, but probably wont due to root req. and distro diffs.


`export TUPAC_USER=tupac TUPAC_HOME=/var/tupac`
`sudo adduser --system --home $TUPAC_HOME --shell /bin/bash --disabled-password $TUPAC_USER`

### 2. Create SSH Keys on local and remote server

This is for running rake tests, SSHing from localhost to localhost.
```bash
sudo mkdir $TUPAC_HOME/.ssh
sudo ssh-keygen -t rsa -f $TUPAC_HOME/.ssh/id_rsa
# For testing locally, using rake, simulating ssh commands
sudo cp -a $TUPAC_HOME/.ssh/id_rsa.pub $TUPAC_HOME/.ssh/authorized_keys
sudo chown -R $TUPAC_USER $TUPAC_HOME/.ssh/
```
Now copy the contents of $TUPAC_HOME/.ssh/id_rsa.pub into the remote target server's ~/.ssh/authorized_keys file


### 3. Test the connection

`sudo -u tupac ssh "$TARGET_USER@$TARGET_SERVER"`


### 4. Setup tupac database

```bash
cd $TUPAC_HOME
sudo -u postgres createuser --no-createrole --no-superuser --createdb tupac
sudo -u postgres createdb -O tupac tupac
echo -e "production:\n  adapter: postgresql\n  encoding: unicode\n  database: tupac\n  pool: 5\n  username: tupac\n  password:" > config/database.yml
export RAILS_ENV=production 
rake db:migrate
rake db:create
rake db:seed
```

### 5. Compile assets


### 6. Integrate the app into Nginx/Apache and Unicorn/Passenger/other.
* This is a standard Rails App, and requires no special settings.
* The current Gloo Unicorn/Nginx configuration was set in July 2012.
* http://brandontilley.com/2011/01/29/serving-rails-apps-with-rvm-nginx-unicorn-and-upstart.html is a good resource for this.

---------------------------
# Draft
