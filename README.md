# WELCOME

This is a [Crono ETL](https://dev.crono.org/etl/project-structure/) project: a demo data warehouse built on the Northwind sample database. `jobs/load_datawarehouse.job` first imports the Northwind parquet files in `seeds/northwind_sample/` into the `staging` schema, then loads the `dwh` tables (dimensions and facts) defined in `models/`.

A Crono ETL project is just a folder of text files, so you can work on it with any of these:

- **Crono ETL for Windows**, the desktop IDE. Open `Crono.etlproj`.
- **Crono ETL CLI** (`crono-etl`), from the project folder. Run `crono-etl help` to list the commands.
- **Any text editor**. The models are Crono SQL (`.sql`), the jobs are `.job` files and the configuration is in `.crono/`.

To install Crono ETL CLI as a .NET global tool (you need the .NET SDK):

```
dotnet tool install crono-etl --source https://nuget.crono.org/v3/index.json --global
```

## For AI agents

Do not guess Crono SQL syntax or project conventions. Before making any change, read these two:

```
crono-etl reference overview          # What Crono is, Crono SQL and load patterns
crono-etl reference best-practices    # How to work on a Crono ETL project without breaking anything
```

The rest of the reference is in `crono-etl reference help`, and `crono-etl reference commands` lists all the CLI commands.

Any command followed by `help` shows its options and examples, for example `crono-etl docs check help`.
