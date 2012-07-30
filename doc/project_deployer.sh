#!/bin/bash
#
# This script does the following tasks
#   1. Updates the local instance of MyOrganization/my_app git repo clone
#   2. Preps it for production (builds assets, bundle package, bundle install etc.)
#   3. Rsyncs it to the target servers
#
# Syntax:
# ./this-command --servers SERVER1,SERVER2,SERVER3 --branch BRANCH --environment ENV --db-conf=/path/to/database.yml
#   Optional Flags: --skip-assets, --db-migrate
#   Servers: Can be a public IP address, dns/host name, or name alias known to ~/.ssh/config, or username@server
###

# ------ Edit these for your project: -----#
MY_APP_PATH="/home/tupac/deployables/program_creator" # No trailing slash
DEFAULT_BRANCH="MASTER"
RELEASE_PATH="/var/www/my_organization/my_app"
USE_CAPISTRANO_STYLE_SYMLINKS=true # Releases are in $RELEASE_PATH/releases/[git-rev], symlinked to $RELEASE_PATH/current
STATIC_FILES="/home/tupac/deployables/static/" # These are for static files that don't change between revisions. Only use when necessary!
DEPLOY_EXCLUDE="/home/tupac/deployables/static/pc_excludes"
#------------------------------------------#

# Do not edit these defaults:
PROCOMPILE_ASSETS=true
DB_MIGRATE=false


# Requires Bash 4.0+
if ((BASH_VERSINFO[0] < 4)); then
    echo "Sorry, you need at least bash-4.0 to run this script." >&2
    exit 1
fi

function print_help_text {
    echo "$(cat <<EOF
# This script does the following tasks
#   1. Updates the local instance of MyOrganization/My_App
#   2. Preps it for production (builds assets, bundle package, bundle install etc.)
#   3. Rsyncs it to the target servers
#
# Syntax:
# ./this-command --servers SERVER1,SERVER2,SERVER3 --branch BRANCH --environment ENV --db-conf=/path/to/database.yml
#   Optional Flags: --skip-assets, --db-migrate
#   Servers: Can be a public IP address, dns/host name, or name alias known to ~/.ssh/config
EOF
)"
}

function exit_if_failure() {
    if [ $? -ne 0 ]; then
        echo "$1"
        exit 1
    fi
}

while test $# -gt 0; do
    case "$1" in
      -h|-?|--help)
          print_help_text;
          exit 0
          ;;
      --servers|-s)
          shift
          if test $# -gt 0; then
              SERVERS_LIST=$1
              SERVERS=$(echo $SERVERS_LIST | tr "," "\n")
              echo "These are the servers: ${SERVERS}"
          else
             echo "no servers specified"
             exit 1
          fi
          shift
          ;;
      --branch|-b)
          shift
          if test $# -gt 0; then
              BRANCH=$1
              echo "Deploying Branch ${BRANCH}"
          else
             echo "No branch was specified"
             exit 1
          fi
          shift
          ;;
      --environment|-E)
          shift
          if test $# -gt 0; then
              ENV=$1
              echo "Running in environment: ${ENV}"
          else
             echo "no environment specified"
             exit 1
          fi
          shift
          ;;
      --skip-assets|--skip-assets-precompile|-s)
          shift
          unset PROCOMPILE_ASSETS
          echo "Skipping Assets Precompile"
          shift
          ;;
      --db-migrate)
          shift
          RUN_MIGRATE=true
          echo "Requesting DB migrations, post deploy"
          shift
          ;;
      --db-conf|-d)
          shift
          if test $# -gt 0; then
              DB_CONF_FILE=$1
              if [[ ! -f $DB_CONF_FILE ]]; then
                echo "DB config file was not found."
                exit 1
              fi
          else
              echo "Please provide a filename with --db-conf"
              exit 1
          fi
          shift
          ;;
      -*) # unknown option - ignore
          echo "WARN: Unknown option (ignored): $1" >&2
          shift
          ;;
      *)
          break
          ;;
     esac
done

# TODO: Check for required arguments

# Test each server to ensure network access


cd $MY_APP_PATH
export RAILS_ENV=production

# Run git-reset
echo "+++ Running Git Reset +++"
git reset --hard HEAD
exit_if_failure "Could not reset branch. Aborting deployment."

# Run git-pull
echo "+++ Running Git Pull from origin/${BRANCH} +++"
git pull origin $BRANCH
exit_if_failure "Could not pull origin/${BRANCH}. Aborting deployment."

# Run bundle install --deployment
echo "+++ Running Bundle Install +++"
bundle install --deployment --without development test
exit_if_failure "Could not bundle application dependencies. Aborting deployment."

# Get static resources (like the db-conf file)
if [ ! -z "$DB_CONFIG_FILE" ]; then
    cp -a $DB_CONF_FILE config/database.yml
    exit_if_failure "Could not copy static resources file ${DB_CONF_FILE}. Aborting deployment."
fi

# Compile assets
# Unless directed not to...
if [ ! -z "$PROCOMPILE_ASSETS" ]; then
    echo "+++ Running Assets Precompile +++"
    rake assets:precompile:all
    exit_if_failure "Could not compile assets. Aborting deployment."
fi

# Set a deployment indicator file (.RELEASE)
GIT_REV=$(git rev-parse HEAD)
echo -e "Revision: $GIT_REV \nDate: $(date)" > .RELEASE

# Rsync this mofo!
shopt -s dotglob # Copy dot files too
declare -A deployments # Associative Array of statuses
if [ $USE_CAPISTRANO_STYLE_SYMLINKS ]; then
    DEPLOY_PATH="${RELEASE_PATH}/releases/$GIT_REV"
else
    DEPLOY_PATH=$RELEASE_PATH
fi

for server in $SERVERS; do
    echo "+++ Deploying to ${server}! +++"
    RSYNC_CMD="rsync --verbose --recursive --delete-delay --timeout=30 --compress --exclude-from=$DEPLOY_EXCLUDE $MY_APP_PATH/ $server:$DEPLOY_PATH"
    echo "Running command: ${RSYNC_CMD}"
    $RSYNC_CMD
    if [ $? -eq 0 ] && [ $USE_CAPISTRANO_STYLE_SYMLINKS ]; then
        echo "Updating current symlink..."
        ssh $server "ln -snf $DEPLOY_PATH $RELEASE_PATH/current"
    fi
    deployments[$server]=$?
    # TODO: set permissions on destination
    echo "++++ Result was: exitstatus: ${deployments[$server]}"
done


