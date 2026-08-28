-- Database and schema creation for AEROSPACE_SUPPLY_CHAIN_AI
-- Co-authored with CoCo

/*
  Script: 01_create_database_schemas.sql
  Creates the database and all schemas for the Aerospace Supply Chain AI project.
  Run this FIRST before all other scripts.
*/

CREATE DATABASE IF NOT EXISTS AEROSPACE_SUPPLY_CHAIN_AI;

USE DATABASE AEROSPACE_SUPPLY_CHAIN_AI;

CREATE SCHEMA IF NOT EXISTS RAW;
CREATE SCHEMA IF NOT EXISTS ANALYTICS;
CREATE SCHEMA IF NOT EXISTS SEMANTIC;
