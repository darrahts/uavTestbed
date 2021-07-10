
-- create the database
create database uav_db;

-- create a database user 
create user :user with encrypted password :passwd;

-- grant permissions
grant all privileges on database uav_db to :user;

