#!/bin/sh

if [[ "$1" == "install" ]]; then
    /usr/local/bin/mysql_install_db > /dev/null 2>&1
fi

/usr/local/bin/mysqld_start

case $1 in

  (install):
    echo -n "  creating databases"
    unset VERSION

    cd /var/mailserv/admin && /usr/local/bin/rake db:setup RAILS_ENV=production > /dev/null 2>&1
    cd /var/mailserv/admin && /usr/local/bin/rake db:migrate RAILS_ENV=production > /dev/null 2>&1
    /usr/local/bin/mysql mail < /var/mailserv/install/templates/sql/mail.sql
    /usr/local/bin/mysql < /var/mailserv/install/templates/sql/spamcontrol.sql
    /usr/local/bin/ruby /var/mailserv/scripts/rrdmon_create.rb
    echo "."
    ;;

  (upgrade):
    echo -n "  Updating database schema"
    # Update the database
    cd /var/mailserv/admin && /usr/local/bin/rake RAILS_ENV=production db:migrate
    # Delete the cached javascript and stylesheet caches
    rm -f /var/sfta/app/public/javascripts/all.js /var/sfta/app/public/stylesheets/all.css 2>/dev/null
    echo "."
    ;;

esac
/usr/local/bin/mysqladmin shutdown
