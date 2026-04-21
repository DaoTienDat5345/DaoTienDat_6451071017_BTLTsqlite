# bai1 - SQLite Notes CRUD

A simple Flutter notes app using SQLite with basic CRUD:
- List all notes
- Add a note
- Edit a note
- Delete a note
- Auto-refresh UI after every change

## Data schema
Table: `notes`
- `id` INTEGER PRIMARY KEY AUTOINCREMENT
- `title` TEXT NOT NULL
- `content` TEXT NOT NULL

`DatabaseService` also includes a migration path from legacy `noteDetail` data into `notes`.

## Run
```bash
flutter pub get
flutter run
```

## Test
```bash
flutter test
```
