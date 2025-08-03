# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter web application called "서구 골목" (Seogu Alley) - an interactive dashboard for tracking merchant statistics in Seogu District. The app displays 119 designated merchant areas with 11,426 stores across 18 administrative districts (dong), featuring both public viewing and admin management capabilities.

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

### Multi-layer Application Structure

The application follows a layered architecture with clear separation of concerns:

1. **Presentation Layer**: UI widgets and pages
2. **Service Layer**: API communication and data management
3. **Data Layer**: Models and static data structures
4. **Core Layer**: Utilities, constants, and configurations

### Key Components

#### **HomePage (lib/page/home_page.dart:13)**
Main application layout with:
- Responsive dashboard/map toggle functionality
- Fixed 2560x1440 canvas wrapped in FittedBox for consistent scaling
- State management for map positioning and fullscreen modes
- Screenshot capture capabilities

#### **Admin System**
Complete JWT authentication system with:
- **AdminService (lib/page/data/admin_service.dart)**: Comprehensive API client with token management
- **AdminGuard**: Route protection for admin-only pages
- **NewAdminDashboardPage**: Modern admin dashboard with real-time data visualization
- Auto-logout on token expiration

#### **Interactive Map System (lib/page/widget/map/)**
Advanced map implementation featuring:
- Multi-layered rendering (base map, terrain, district overlays, labels)
- Coordinate-based merchant markers with tooltips
- District selection with dynamic highlighting
- Touch interaction with coordinate copying
- Legend controls for layer visibility

#### **Dashboard System (lib/page/widget/dashboard/)**
Dynamic data visualization with:
- Real-time metrics from REST API
- Chart widgets using fl_chart package
- Date-based data switching
- District-specific detailed views

### API Integration

**Dual Environment Setup:**
- Production: `https://seogu119-api.eyearth.net/api`
- Development: `http://localhost:8000` (debug mode)

**Service Architecture:**
- `lib/core/api_service.dart` - Main dashboard data fetching
- `lib/page/data/admin_service.dart` - Complete admin API operations
- JWT token management with automatic refresh
- Error handling with user-friendly feedback

## Key Dependencies

### Core Functionality
- `http: ^1.1.0` - HTTP client for API communication
- `shared_preferences: ^2.2.2` - Local storage for tokens/settings
- `jwt_decoder: ^2.0.1` - JWT token parsing and validation

### UI Components
- `flutter_svg: ^2.0.10+1` - SVG rendering for region overlays
- `fl_chart: ^1.0.0` - Interactive charts and graphs
- `glass_kit: ^4.0.1` - Glass morphism UI effects
- `cached_network_image: ^3.3.1` - Optimized image caching
- `speech_balloon: ^0.0.3` - Speech bubble tooltips

### Drawing & Screenshots
- `flutter_drawing_board: ^0.9.8` - Drawing functionality
- `screenshot: ^3.0.0` - Screenshot capture capabilities

## Data Models

### Core Data Structures
- **Dong**: Administrative district with merchant lists, boundaries, and assets
- **Merchant**: Individual merchant with ID, name, and precise map coordinates
- **DashboardData**: Dynamic metrics fetched from API
- **AdminUser**: Authentication and session management

### Static vs Dynamic Data
- **Static**: District boundaries, merchant locations, asset paths (dong_list.dart)
- **Dynamic**: Dashboard metrics, charts, statistics (API-driven)

## Asset Management

**Organized Asset Structure:**
- `assets/map/` - Base map layers and district-specific overlays
- `assets/images/` - UI icons and general imagery
- WebP images for optimal web performance
- SVG files for scalable region overlays

**Font Configuration:**
- Primary: NotoSans (Korean text support)
- Weights: Regular (400), Bold (700)
- Proper fallback font handling

## Routing & Authentication

**Route Structure:**
- `/` - Public homepage (FittedBox-wrapped for consistent scaling)
- `/admin` - Admin login page
- `/admin/dashboard` - Protected admin dashboard
- `/admin/dong/{dongName}` - District-specific admin views

**Authentication Flow:**
- JWT token storage in SharedPreferences
- Automatic token validation on protected routes
- Graceful fallback to login on auth failure

## Deployment

**AWS Integration:**
- Automated deployment via CodeBuild (buildspec.yml)
- S3 hosting with CloudFront CDN
- Cache invalidation for updated content
- Environment-specific API endpoint configuration

## Code Style & Standards

- Flutter/Dart conventions with flutter_lints
- Korean language strings for user-facing text
- Consistent error handling with try-catch blocks
- StatefulWidget pattern for component state management
- Responsive design using LayoutBuilder for different screen sizes

## Testing

- Widget test file: `test/widget_test.dart`
- Run with `flutter test`
- Static analysis: `flutter analyze`