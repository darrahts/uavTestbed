#!/bin/bash

################################################################################
################################################################################
#
#            This script will promt the user to 
#                1. install PostgreSQL
#                    copy and pasted code from https://www.postgresql.org/download/linux/ubuntu/
#                2. setup the database and user
#                    creates uav_db and the current user
#                3. setup the table schema
#                    executes table_schema.sql
#                4. setup defaults
#                    executes setup_defaults.sql
#
#            Tim Darrah
#            NASA Fellow
#            PhD Student
#            Vanderbilt University
#            timothy.s.darrah@vanderbilt.edu
#
################################################################################
################################################################################

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

# create the database and user
read -p "setup database? (y/n): " ans
if [[ $ans = y ]]
then
    read -p "enter your password: " passwd
    sudo -u postgres psql -f sql/setup_db_user.sql -v user="$USER" -v passwd="'$passwd'"
fi
unset ans

# create the tables
read -p "setup table schema? (y/n): " ans
if [[ $ans = y ]]
then
    psql -d uav_db -f sql/setup_table_schema.sql
fi
unset ans

# create a uav and degradation processes with default parameters
read -p "setup defaults? (y/n): " ans

if [[ $ans = y ]]
then
    psql -d uav_db -f sql/setup_defaults.sql
fi