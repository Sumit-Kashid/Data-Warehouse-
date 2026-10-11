-- KO_MED Hospital database
-- Author: Sumit Kashid
-- Creates the database. Run once before 01_schema_and_seed.sql.

IF DB_ID('KO_MED_Hospital') IS NULL
    CREATE DATABASE KO_MED_Hospital;
GO
