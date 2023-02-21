# ace-to-sqlite

Automation to export the latest release of the [ACEmulator](https://github.com/ACEmulator) data as SQLite databases served via [Datasette](https://datasette.io).

See it live at https://acedb.treestats.net.

## Databases

The following data sources are included:

- `ace_world_base`: https://github.com/ACEmulator/ACE-World-16PY
- `ace_world_patches`: https://github.com/ACEmulator/ACE-World-16PY-Patches
- `ace_pcap_exports`: https://github.com/ACEmulator/ACE-PCAP-Exports

## Rationale

People sometimes want to know if certain items are in the game or build things on top of ACE data.
The best way to do this is to query the ACE database.
This makes that (and more) easier.

## Methodology

I didn't find a good tool that can directly convert MySQL DDL (What ACE stores its data as) to SQLite DDL (what we need for loading into [Datasette](https://datasette.io) so I though the best approach would be to let MySQL help with the conversion process.

The approach used here is roughly:

- Spin up a MySQL instance
- Load DDL files in
- Export all databases as .tsv files
- Run [`csvs-to-sqlite`](https://datasette.io/tools/csvs-to-sqlite) on those .tsv files to convert everything to SQLite databases
- Host them online with [Datasette](https://datasette.io).

## Running This Yourself

This automation is a GitHub Action so please look at https://github.com/amoeba/ace-to-sqlite/blob/main/.github/workflows/export.yml for the steps.

If you're interested in running the automation yourself and in another environment, look at https://github.com/amoeba/ace-to-sqlite/blob/main/scripts/generate_world_database.sh which will download and convert the latest ACE World release to SQLite. Its requirements are:

- A local MySQL server instance with the root password off
- bash
- curl
- jq
- unzip
- Python
- csvs-to-sqlite (python -m pip install csvs-to-sqlite)
  
## Contributing

Please file an [Issue](https://github.com/amoeba/ace-to-sqlite/issues) if you have any questions or commands. An example of a good type of issue to file would be if you want a datasource included here that isn't or if you find either a data or documentation issue.
