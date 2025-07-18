# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter web application called "서구 골목" (Seogu Alley) that displays an interactive map dashboard for tracking merchant statistics in Seogu District. The app shows 119 designated merchant areas with 11,426 stores across 18 administrative districts (dong).

## Development Commands

### Core Flutter Commands
- `flutter run -d chrome` - Run the app in Chrome (web platform)
- `flutter build web` - Build for web deployment
- `flutter test` - Run all tests
- `flutter analyze` - Run static analysis using rules from analysis_options.yaml

### Development Tools
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies
- `flutter clean` - Clean build artifacts
- `flutter doctor` - Check Flutter installation and dependencies

## Architecture

### File Structure
```
lib/
├── app.dart                    # Main app widget with MaterialApp setup
├── main.dart                   # Entry point
└── page/
    ├── home_page.dart          # Main page with dashboard and map layout
    ├── data/
    │   ├── dong_list.dart      # Static data for districts and merchants
    │   └── map_assets.dart     # Map asset configurations
    └── widget/
        ├── chart_widget.dart        # Dashboard charts
        ├── dashboard_widget.dart    # Left panel with statistics
        ├── floating_action_buttons.dart  # Map controls
        ├── map_widget.dart         # Interactive map component
        └── merchant_list_dialog.dart  # Merchant selection dialog
```

### Key Components

1. **HomePage (lib/page/home_page.dart:9)**: Main layout with responsive design showing dashboard and map side-by-side with toggle functionality

2. **MapWidget (lib/page/widget/map_widget.dart:9)**: Interactive map using InteractiveViewer with:
   - Layered PNG images for base map, terrain, and labels
   - Merchant location markers with tooltips
   - Coordinate copying functionality on tap
   - Legend controls for layer visibility

3. **DashboardWidget (lib/page/widget/dashboard_widget.dart:4)**: Statistics panel showing merchant area completion status

4. **DongList (lib/page/data/dong_list.dart:28)**: Static data structure containing 18 districts with:
   - 119 total merchant areas
   - Color-coded regions
   - Merchant coordinates and names
   - Area boundaries and assets

### Data Model
- **Dong**: Represents administrative district with color, merchant list, area boundaries, and asset paths
- **Merchant**: Individual merchant with ID, name, and map coordinates (x, y)

## Key Dependencies

- `flutter_svg: ^2.0.10+1` - SVG rendering
- `fl_chart: ^1.0.0` - Chart widgets
- `fluttertoast: ^8.2.6` - Toast notifications
- `hawk_fab_menu: ^1.2.0` - Floating action button menu

## Asset Management

The app uses extensive image assets organized in:
- `assets/map/` - Base map images, district overlays, and tags
- `assets/svg/` - SVG region files (region1.svg to region18.svg)
- `assets/images/` - General images
- `assets/temp/` - Temporary files

All assets are declared in pubspec.yaml and loaded via AssetImage.

## Code Style

- Uses standard Flutter/Dart conventions
- Follows flutter_lints rules from analysis_options.yaml
- Korean language strings for UI text
- Responsive design with LayoutBuilder for tablet/desktop layouts

## Testing

- Single widget test file: `test/widget_test.dart`
- Run tests with `flutter test`
- Use `flutter analyze` for static analysis