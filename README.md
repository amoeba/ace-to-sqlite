# ace-to-sqlite

Work in progress automation to export the latest release of the [ACE](https://github.com/acemulator/ace) database to SQLite.

## Rationale

People sometimes want to know if certain items are in the game.
The best way to do this is to query the ACE database.
This makes that easy.

## Methodology

- Spin up a working ACE instance using Docker
- Run some SQL queries and `mysqldump` commands to dump the database as one CSV per table
- Run `csvs-to-sqlite` on those CSV files to make three SQLite databases
- Publish them with `datasette`

## Pre-requisites

- Docker
  - Docker Compose
- Python and pip

## Setup

- Install datasette and csvs-to-sqlite
  `python -m pip install -r requirements.txt`
- Install vercel plugin
  - `datasette install datasette-publish-vercel`

## Running

Note: Wait until ACE DB has fully come up.

- Export to CSV
  - `docker exec -it ace-db /bin/sh /scripts/dump_ace.sh`
  - This produces files in `./export`
- Convert to SQLite
  - `csvs-to-sqlite ./export/*.csv`
- Publish to Vercel
  - `datasette publish...` <--- TODO
