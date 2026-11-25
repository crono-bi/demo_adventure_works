# docs

This folder holds the project documentation: what we write ourselves (design notes, decisions, data dictionaries, load diagrams) and the material the client provides (specifications, sample Excel files, reports). Crono ETL does not run anything in this folder, so you can put any file type here.

The documentation of each table and its columns does not belong here: it goes in the YAML header of the model file in `models/` (the `Description` and `Columns` keys), where `crono-etl docs` can read and check it.
