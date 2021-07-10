#!/bin/bash

# install PostgreSQL
read -p "install postgreSQL? (y/n): " ans

if [[ $ans = y ]]
then
    # Create the file repository configuration:
    sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

    # # Import the repository signing key:
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

    # # Update the package lists:
    sudo apt-get update

    # # Install the latest version of PostgreSQL.
    # # If you want a specific version, use 'postgresql-12' or similar instead of 'postgresql':
    sudo apt-get -y install postgresql
fi

unset ans
read -p "setup database? (y/n): " ans2
read -p "enter your password: " passwd

if [[ $ans2 = y ]]
then
    sudo -u postgres psql -f sql/setup.sql -v user="$USER" -v passwd="'$passwd'"
<<<<<<< HEAD
fi
=======
fi
>>>>>>> 3fb9224d7450892d3780e201025ee6d7a7acdfba
