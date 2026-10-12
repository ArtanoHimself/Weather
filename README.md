# Weather

An iOS weather app: current conditions, a 5-day forecast in 3-hour steps, and a list of saved cities. Data comes from the [OpenWeather](https://openweathermap.org/api) API.

## Screenshots

<p align="center">
  <img src="AppScreenshots/main-clouds.jpg" width="200" alt="Main screen, scattered clouds">
  <img src="AppScreenshots/main-snow.jpg" width="200" alt="Main screen, light snow">
  <img src="AppScreenshots/cities.jpg" width="200" alt="City management">
  <img src="AppScreenshots/search.jpg" width="200" alt="City search">
</p>

## Features

- Current weather: date, city, temperature, description, pressure, humidity, "feels like" and wind.
- Forecast with a 3-hour step (40 data points).
- Background changes with the weather (thunder, rain, snow, sunny, cloudy).
- City search with suggestions (up to 5 results, with country and region), debounced by 0.5 s.
- Saved cities: add, delete, and move the selected city to the top. The first city in the list is the current one.
- Error handling for network problems (no connection, timeout, bad status code, decoding) and storage problems.

## Tech Stack

- Swift, UIKit
- MVVM
- Swift Concurrency (`async/await`) for networking
- Combine (`@Published`, `debounce`) for ViewModel-to-View binding and search
- `URLSession` + `Codable` (DTO layer separated from domain models)
- `UserDefaults` for persisting saved cities

## Getting Started

1. Clone the repository and open `Weather.xcodeproj`.
2. Get a free API key at [openweathermap.org](https://openweathermap.org/api) (sign up, then open the **API keys** tab). A new key may take some time to start working.
3. In `Weather/Networking`, copy `APIKey.swift.example` to `APIKey.swift` (keep the original):

   ```bash
   cp Weather/Networking/APIKey.swift.example Weather/Networking/APIKey.swift
   ```

4. Open `APIKey.swift` and replace `Your_API_KEY` with your key.
5. Select a simulator and press Run.

`APIKey.swift` is listed in `.gitignore`, so your key will not be committed. If Xcode shows `APIKey.swift` in red, the file has not been created at that path yet. Without a valid key, requests will fail with a bad status code (401).


