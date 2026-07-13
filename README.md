# MVVM-example

A minimal MVVM example flow with unit tests.

## Setup

1. Run `pod install`
2. Open `MVVM.xcworkspace`
2. Build and run the **MVVM** scheme.

WeatherAPI.com key is hardcoded in `MVVMNetwork/WeatherAPIConfiguration.swift` for local development.

## Architecture

- **MVVMDomain** — entities, UI models, UseCases, repository protocols
- **MVVMNetwork** — DTOs, URLSession client, repository implementation, bookmark storage
- **MVVM** — ViewControllers / ViewModels / Navigators

## Screens

- **WeatherList** — Hanoi historical weather in a `UITableView`, filterable by 7 days / 30 days / bookmarked
- **WeatherDetail** — full day detail with bookmark toggle

## Tests

- Test coverage is almost 80% (unit tests only)

```bash
xcodebuild test -workspace MVVM.xcworkspace -scheme MVVM \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:MVVMTests \
  -enableCodeCoverage YES
```
