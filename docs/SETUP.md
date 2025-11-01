# Setup Guide

## Prerequisites

Sebelum memulai, pastikan Anda sudah menginstall:

1. **Flutter SDK** (versi 3.9.0 atau lebih tinggi)
   - Download dari: https://flutter.dev/docs/get-started/install
   - Verifikasi instalasi: `flutter doctor`

2. **IDE/Editor**
   - Android Studio (recommended)
   - VS Code dengan Flutter extension
   - IntelliJ IDEA

3. **Git** (untuk version control)

## Installation Steps

### 1. Clone Repository

```bash
git clone <repository-url>
cd flutter_application_1
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Verify Setup

```bash
flutter doctor
```

Pastikan tidak ada error critical. Warning untuk platform yang tidak digunakan bisa diabaikan.

### 4. Run Application

#### Desktop (Windows/Mac/Linux)
```bash
flutter run -d windows  # Windows
flutter run -d macos    # macOS
flutter run -d linux    # Linux
```

#### Mobile
```bash
flutter run -d chrome   # Web browser
flutter run             # Connected device/emulator
```

#### Specific Device
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

## Configuration

### Flutter Secure Storage

Aplikasi menggunakan `flutter_secure_storage` untuk menyimpan data lokal secara aman.

**Windows Setup:**
Tidak perlu konfigurasi tambahan.

**Linux Setup:**
Install libsecret:
```bash
sudo apt-get install libsecret-1-dev
```

**macOS/iOS Setup:**
Tidak perlu konfigurasi tambahan.

**Android Setup:**
Minimum SDK version sudah dikonfigurasi di `android/app/build.gradle`.

## Development

### Hot Reload
Saat aplikasi berjalan, tekan:
- `r` untuk hot reload
- `R` untuk hot restart
- `q` untuk quit

### Debug Mode
```bash
flutter run --debug
```

### Release Mode
```bash
flutter run --release
```

## Building

### Android APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### Windows
```bash
flutter build windows --release
```
Output: `build/windows/runner/Release/`

### Web
```bash
flutter build web --release
```
Output: `build/web/`

## Troubleshooting

### Issue: Dependencies conflict
**Solution:**
```bash
flutter pub upgrade --major-versions
flutter pub get
```

### Issue: Build failed
**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: Hot reload not working
**Solution:**
- Restart aplikasi dengan `R`
- Atau restart IDE

### Issue: Storage not working
**Solution:**
- Pastikan permissions sudah diberikan
- Clear app data dan restart

## Testing

### Run Tests
```bash
flutter test
```

### Run with Coverage
```bash
flutter test --coverage
```

## Project Structure

```
flutter_application_1/
├── android/          # Android specific files
├── ios/             # iOS specific files
├── lib/             # Main application code
│   ├── models/      # Data models
│   ├── providers/   # State management
│   ├── screens/     # UI screens
│   ├── services/    # Business logic
│   ├── utils/       # Utilities
│   └── main.dart    # Entry point
├── test/            # Test files
├── web/             # Web specific files
├── windows/         # Windows specific files
├── pubspec.yaml     # Dependencies
└── README.md        # Documentation
```

## Next Steps

1. Load sample data dari menu Produk
2. Explore fitur-fitur aplikasi
3. Customize sesuai kebutuhan
4. Deploy ke production

## Support

Jika mengalami masalah:
1. Check dokumentasi Flutter: https://flutter.dev/docs
2. Check issue di repository
3. Buat issue baru dengan detail error

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [Material Design 3](https://m3.material.io)
