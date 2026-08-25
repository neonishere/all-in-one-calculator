# All-in-One Calculator

An open-source calculator app for desktop and Android. Opens straight into a
standard calculator; the grid icon in the top-left corner opens every other
tool, organized by category (Algebra, Geometry, Unit converters, Finance,
Health, Date & time, Other).

Built with Flutter so the same codebase targets Windows/macOS/Linux and
Android.

## Status

Early scaffold. The basic calculator, navigation, and a first batch of tools
work end to end. Everything else in the tool menu shows "Coming soon" until
it's built — see `lib/core/catalog/tool_catalog.dart` for the full list and
what's wired up.

## Getting started

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) and run `flutter doctor` until it's clean for the platforms you're targeting.
2. From this folder, generate the platform projects (only needs to run once):
   ```
   flutter create . --platforms=windows,android
   ```
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Run it:
   ```
   flutter run -d windows
   ```

### Live currency rates

The currency converter uses [exchangerate-api.com](https://www.exchangerate-api.com/)'s
free tier. Get a free API key, then run with:

```
flutter run -d windows --dart-define=EXCHANGE_RATE_API_KEY=your_key_here
```

Without a key the converter still works from the last cached rates, and shows
a banner explaining live rates are off.

## Project layout

```
lib/
  core/            theming, routing catalog, currency data layer
  features/        one folder per tool category, one file per tool
  shared/widgets/  reusable building blocks (number fields, result cards,
                    the generic linear unit converter)
```

## Contributing

Adding a new tool: add its screen under `lib/features/<category>/`, then wire
it into `lib/core/catalog/tool_catalog.dart` with a `builder`. Unit families
that are a simple linear scale (like length or weight) can usually reuse
`LinearUnitConverterScreen` instead of a new screen.

## License

MIT — see [LICENSE](LICENSE).
