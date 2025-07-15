########################### To create a new screen with arc ##########################
screen:
	cd lib/feature && mason make get_arc
	
########################### Development ###########################
dev:
	flutter run

start:
	flutter run

########################### Dependency Management ###########################
get-dependencies:
	flutter pub get

get:dependencies:
	flutter pub get

upgrade-dependencies:
	flutter pub upgrade --major-versions

upgrade:dependencies:
	flutter pub upgrade --major-versions

########################### Code Quality ###########################
format:
	dart run import_sorter:main && dart format .

analyze:
	flutter analyze

fix:
	dart fix --apply

########################### Build APKs ###########################
build-dev:
	flutter clean && flutter build apk --dart-define=APP_ENV=development && open build/app/outputs/flutter-apk/

build-stag:
	flutter clean && flutter build apk --dart-define=APP_ENV=staging && open build/app/outputs/flutter-apk/

build-prod:
	flutter clean && flutter build apk --dart-define=APP_ENV=production && open build/app/outputs/flutter-apk/

build:apk:
	flutter build apk

build:ios:
	flutter build ios

########################### Build Signed App Bundles ###########################
signed-dev:
	flutter clean && flutter build appbundle --dart-define=APP_ENV=development && open build/app/outputs/bundle/release/

signed-stag:
	flutter clean && flutter build appbundle --dart-define=APP_ENV=staging && open build/app/outputs/bundle/release/

signed-android:
	flutter clean && flutter build appbundle --dart-define=APP_ENV=production && open build/app/outputs/bundle/release/

signed-ios:
	flutter clean && flutter build ipa --dart-define=APP_ENV=production && open build/ios/ipa/

########################### Launcher Icons and Splash Screen ###########################
update-launcher-icons:
	dart pub run flutter_launcher_icons

update:launcher_icons:
	dart pub run flutter_launcher_icons

update-splash-screen:
	dart pub run flutter_native_splash:create

update:splash_screen:
	dart pub run flutter_native_splash:create

########################### Code Generation ###########################
update-stores:
	flutter packages pub run build_runner build --delete-conflicting-outputs

update:stores:
	flutter packages pub run build_runner build --delete-conflicting-outputs

########################### Versioning ###########################
version-major:
	dart pub global run cider bump major --bump-build

version:major:
	dart pub global run cider bump major --bump-build

version-minor:
	dart pub global run cider bump minor --bump-build

version:minor:
	dart pub global run cider bump minor --bump-build

version-patch:
	dart pub global run cider bump patch --bump-build

version:patch:
	dart pub global run cider bump patch --bump-build
