# Arcana Ebook Reader

A modern, open-source Flutter ebook reader supporting EPUB (with metadata extraction), PDF, MOBI, TXT, and more. Now using the latest dependencies and a robust, maintainable architecture.

## Features

- 📖 **EPUB Reading** (with [vocsy_epub_viewer](https://pub.dev/packages/vocsy_epub_viewer))
- 📚 Import books from device storage
- 🏷️ Extracts and displays real title, author, and cover from EPUBs
- ⭐ Favorites, recently read, and search
- 🖼️ Custom cover support (with fallback)
- 🦾 Modern codebase, optimized for performance
- 🛠️ Makefile for all dev/build tasks
- 🗄️ **Robust local database using Drift (SQLite)**

## Getting Started

### Prerequisites

- [Flutter 3.22+](https://flutter.dev/docs/get-started/install)
- Dart 3.0+

### Install dependencies

```sh
flutter pub get
```

### Run the app

```sh
flutter run
```

### Build APK (Android)

```sh
flutter build apk --release
```

### Build iOS

```sh
flutter build ios --release
```

## Development

- Use the `Makefile` for common tasks (formatting, analyze, build, etc.)
- All scripts from the old `package.json` are now in the Makefile.
- **Code generation:**
  - Run `make update-stores` to generate code for Drift (database) and MobX (stores).

## EPUB Metadata Extraction

- Uses a pure Dart parser to extract title, author, and cover from EPUB files on import.
- If metadata is missing, falls back to filename and default cover.

## Database Architecture

- Uses [Drift](https://drift.simonbinder.eu/) (SQLite) for all local storage and queries.
- All data is managed in a robust, queryable SQL database.
- Code generation for database tables and DAOs is handled by Drift and build_runner.

## Dependencies

- `drift` (SQLite database)
- `sqlite3_flutter_libs` (native SQLite for Flutter)
- `vocsy_epub_viewer` (EPUB viewing)
- `archive` (EPUB metadata extraction)
- `file_picker`, `permission_handler`, `uuid`, `image`, etc.

## Contributing

Pull requests are welcome! Please open an issue first to discuss major changes.

## License

MIT
