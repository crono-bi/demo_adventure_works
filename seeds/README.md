# seeds

This folder holds small input files that are maintained by hand rather than coming from the ERP: hierarchies, mapping tables, budgets and similar. CSV and Excel files are supported (for example `account_groups.csv` or `budget.xlsx`).

Crono ETL does not load them on its own: the models in `models/` read them (see [External data](https://dev.crono.org/etl/transformation/external-data/)). They are versioned with the rest of the project, so every change to a seed is tracked in Git.
