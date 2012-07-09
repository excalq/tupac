Install Notes

# Scratchpad (todo: clean up)

1. Add user "tupac"
  * Could script, but probably wont due to root req. and distro diffs.

`export TARGET_USER=tupac TARGET_SERVER=localhost`
`sudo adduser --system --home /var/tupac --shell /bin/bash --disabled-password tupac`

2. Create SSH Keys on local and remote server

```bash
sudo mkdir /var/tupac/.ssh
sudo ssh-keygen -t rsa -f /var/tupac/.ssh/id_rsa
sudo cp -a /var/tupac/.ssh/id_rsa.pub /var/tupac/authorized_keys
sudo chown -R tupac /var/tupac/.ssh/
```

3. Test the connection
`sudo -u tupac ssh "$TARGET_USER@$TARGET_SERVER"`

If Scripted:
```bash
export TARGET_USER=arthur TARGET_SERVER=localhost
sudo adduser --system --home /var/tupac --shell /bin/bash --disabled-password tupac
sudo mkdir /var/tupac/.ssh
sudo ssh-keygen -t rsa -f /var/tupac/.ssh/id_rsa
sudo chown -R tupac /var/tupac/.ssh/
sudo -u tupac ssh "$TARGET_USER@$TARGET_SERVER"
```

4. Setup tupac database
sudo -u postgres createuser --no-createrole --no-superuser --createdb tupac
rake db:create
rake db:seed

---------------------------
# Draft
