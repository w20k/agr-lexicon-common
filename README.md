# Lexicon::Common

This repository contains common classes related to download/load/enable the lexicon.

# Components
## Database
Wraps the database object of `pg` to provide syntactic sugar to facilitate transactions and automatic schema handling.

## Package
Contains models and services to create/load package archives.

## Production
Contain base services to load Lexicon Packages to a remote database server

## Remote
Contains base services to download/upload Lexicon Packages from a remote S3 server.

## Schema
Contains services to validate the schema of the lexicon manifest JSON file
