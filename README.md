# ace-to-sqlite

Automation to publish the [ACE](https://github.com/ACEmulator/ACE) database to the web using [Datasette](https://datasette.io/). See https://acemu-db.fly.dev/.

## Rationale

People sometimes want to know if certain items are in the game.
The best way to do this is to query the ACE database.
This makes that (and more) easier.

## Methodology

- Spin up a working ACE instance using Docker
- Run some SQL queries and `mysqldump` commands to dump the database as one TSV per table
- Run `csvs-to-sqlite` on those TSV files to make three SQLite databases
- Publish them with `datasette`

## Pre-requisites

- Docker
  - Docker Compose
- Python and pip

## Setup

- Install datasette and csvs-to-sqlite
  `python -m pip install -r requirements.txt`
- Install fly plugin
  - `datasette install datasette-publish-fly`

## Running

Note: Wait until ACE DB has fully come up.

- Export to CSV
  - `docker exec -it ace-db /bin/sh /scripts/dump_ace.sh`
  - This produces files in `./export`
- Convert to SQLite
  - `csvs-to-sqlite ./export/*.tsv`
- Publish to Fly
  - `datasette publish fly *.db --app=acemu-db`
