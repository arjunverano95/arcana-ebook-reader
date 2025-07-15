########################### Development ###########################
dev:
	flutter run


########################### Dependency Management ###########################
get-dependencies:
	flutter pub get

upgrade-dependencies:
	flutter pub upgrade --major-versions

########################### Code Quality ###########################
format:
	dart run import_sorter:main && dart format .

analyze:
	flutter analyze

fix:
	dart fix --apply

########################### Build APKs ###########################
build-android:
	flutter clean && flutter build apk && open build/app/outputs/flutter-apk/

########################### Build Signed App Bundles ###########################
signed-android:
	flutter clean && flutter build appbundle && open build/app/outputs/bundle/release/

signed-ios:
	flutter clean && flutter build ipa && open build/ios/ipa/

########################### Launcher Icons and Splash Screen ###########################
update-launcher-icons:
	dart pub run flutter_launcher_icons

update-splash-screen:
	dart pub run flutter_native_splash:create

########################### Code Generation ###########################
# Generates code for Drift (database) and MobX (stores)
update-stores:
	flutter packages pub run build_runner build --delete-conflicting-outputs

########################### Versioning ###########################
version-major:
	dart pub global run cider bump major --bump-build

version-minor:
	dart pub global run cider bump minor --bump-build

version-patch:
	dart pub global run cider bump patch --bump-build
