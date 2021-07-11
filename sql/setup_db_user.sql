------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
/*
            This script will create a database named uav_db and a user with the currently logged in user,
            grant permissions to the database and make the user a superuser.

            Tim Darrah
            NASA Fellow
            PhD Student
            Vanderbilt University
            timothy.s.darrah@vanderbilt.edu
*/
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------

-- create the database
create database uav_db;

-- create a database user (you)
create user :user with encrypted password :passwd;

-- grant permissions to you
grant all privileges on database uav_db to :user;

-- give yourself admin access
alter user :user with superuser;

-- create a read-only guest account 
create user guest with encrypted password 'P@$$word1';
grant connect on database uav_db to guest;
grant usage on schema public to guest;
grant select on all tables in schema public to guest;
alter user guest with connection limit 10;