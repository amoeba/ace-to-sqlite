from datasette import hookimpl

ATTRIBUTION_KEYS = ("license", "license_url", "source", "source_url")


@hookimpl
async def startup(datasette):
    """Copy database-level attribution to every table.

    Datasette 1.0 removed metadata fallback, so table pages need their own
    license and source entries to show them in the footer.
    """
    for database_name, database in datasette.databases.items():
        if database_name in ("_internal", "_memory"):
            continue
        database_metadata = await datasette.get_database_metadata(database_name)
        values = {
            key: database_metadata[key]
            for key in ATTRIBUTION_KEYS
            if key in database_metadata
        }
        if not values:
            continue
        for table in await database.table_names():
            for key, value in values.items():
                await datasette.set_resource_metadata(database_name, table, key, value)
