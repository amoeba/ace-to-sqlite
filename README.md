# ace-to-sqlite

Automation to export the latest releases of [ACEmulator](https://github.com/ACEmulator) data as SQLite databases served via [Datasette](https://datasette.io).

See it live at https://acedb.treestats.net.
If you want to use the output in your own application, see the latest releases. You can use the `latest` tag to float or you can follow versioned tags. Versioned tags match the tags on ACE-World-16PY-Patches so you know which version of the database you're using.

## Databases

The following data sources are included:

- `ace_world_base`: https://github.com/ACEmulator/ACE-World-16PY
- `ace_world_patches`: https://github.com/ACEmulator/ACE-World-16PY-Patches
- `ace_pcap_exports`: https://github.com/ACEmulator/ACE-PCAP-Exports
- `ace`: https://github.com/ACEmulator/ACE (via [dogsheep](https://dogsheep.github.io/))

## Rationale

People sometimes want to know if certain items are in the game or build things on top of ACE data.
The best way to do this is to query the ACE database.
This makes that (and more) easier.

## Methodology

I didn't find a good tool that can directly convert MySQL DDL (What ACE stores its data as) to SQLite DDL (what we need for loading into [Datasette](https://datasette.io)).
After trying to some things, I settled on the following set of steps:

- Spin up a MySQL instance
- Load MySQL DDL files in
- Run a custom version of [db-to-sqlite](https://datasette.io/tools/db-to-sqlite)
- Publish with [Datasette](https://datasette.io) to a VPS running [Dokku](https://dokku.com).

## Updates

The databases are updated automatically. A GitHub Actions workflow runs daily, checks each upstream ACEmulator repo for new releases, and — if anything changed — exports fresh SQLite databases, publishes them to the [latest release](https://github.com/amoeba/ace-to-sqlite/releases/tag/latest), and redeploys https://acedb.treestats.net. 

## Using the Databases

The SQLite databases are published as assets on each [GitHub Release](https://github.com/amoeba/ace-to-sqlite/releases). The `latest` release always contains the most recent versions.

**Download via browser:** Go to the [latest release](https://github.com/amoeba/ace-to-sqlite/releases/tag/latest) and download whichever `.db` files you need.

**Download via `gh` CLI:**

```sh
gh release download latest --repo amoeba/ace-to-sqlite --pattern "*.db"
```

Or download a specific database:

```sh
gh release download latest --repo amoeba/ace-to-sqlite --pattern "ace_world_patches.db"
```

Once downloaded, query with any SQLite tool:

```sh
sqlite3 ace_world_patches.db "SELECT * FROM weenie LIMIT 10;"
```

Or explore interactively with [Datasette](https://datasette.io):

```sh
pip install "datasette>=1.0a43"
datasette ace_world_patches.db
```

### Arrow exports

The Datasette instance at https://acedb.treestats.net also serves [Apache Arrow IPC streams](https://arrow.apache.org/docs/format/Columnar.html#ipc-streaming-format) via [datasette-arrows](https://github.com/datasette/datasette-arrows). Add `.arrows` to any table, view, row, or SQL query URL:

```
https://acedb.treestats.net/ace_world_patches/weenie.arrows?_stream=1
https://acedb.treestats.net/ace_world_patches/-/query.arrows?sql=select+*+from+weenie+limit+10
```

`?_stream=1` exports every row; without it only a single page is returned. Filters, sorting, and `?_col=` work the same way as on HTML pages. This instance sets Datasette's `max_stream_mb` to 200 MB, so larger exports will be cut off.

Read a stream in Python:

```sh
pip install pyarrow
python - <<'PY'
import urllib.request
import pyarrow as pa

url = "https://acedb.treestats.net/ace_world_patches/weenie.arrows?_stream=1"
with urllib.request.urlopen(url) as response:
    table = pa.ipc.open_stream(response).read_all()
print(table.num_rows)
PY
```

The plugin and its streaming support currently require prerelease versions: `datasette-arrows>=0.1a0` and `datasette>=1.0a43`, as specified in `requirements.txt`.

Datasette 1.0 also changed the JSON API: table query results use column and row objects instead of parallel arrays, and a single-row URL returns `{"row": ...}` instead of `{"rows": [...]}`. See the [Datasette upgrade guide](https://docs.datasette.io/en/latest/upgrade_guide.html) if you consume those endpoints.

## Running This Yourself

This automation is a GitHub Action so please look at https://github.com/amoeba/ace-to-sqlite/blob/main/.github/workflows/export.yml for the steps.

The Datasette app runs in configuration-directory mode (`datasette .`). `plugins/propagate_metadata.py` copies the license and source fields in `metadata.json` down to each table, because Datasette 1.0 removed metadata fallback.

If you're interested in running the automation yourself and in another environment, look at https://github.com/amoeba/ace-to-sqlite/blob/main/scripts/generate_world_database.sh which will download and convert the latest ACE World release to SQLite. Its requirements are:

- A local MySQL server instance with the root password off
- bash
- curl
- jq
- unzip
- Python
- db-to-sqlite (Installed from [my fork](https://github.com/amoeba/db-to-sqlite))

## Contributing

Please file an [Issue](https://github.com/amoeba/ace-to-sqlite/issues) if you have any questions or commands. An example of a good type of issue to file would be if you want a datasource included here that isn't or if you find either a data or documentation issue.
