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

-- create a database user 
create user :user with encrypted password :passwd;

-- grant permissions
grant all privileges on database uav_db to :user;

alter user :user with superuser;
