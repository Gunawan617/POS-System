# Changelog

All notable changes to this project will be documented in this file.

## [1.2.0] - 2025-01-11

### Added
- **Upload Gambar Produk**: Upload foto produk dari kamera atau galeri
- **Login System**: Authentication dengan username & password
- **User Management**: Admin bisa kelola user (tambah, edit, hapus)
- **Role-Based Access**: 3 role (Admin, Kasir, Barista) dengan permission berbeda
- **Barista Screen**: Fitur khusus barista untuk ambil produk konsumsi internal
- **Internal Transaction**: Transaksi internal untuk barista (harga Rp 0, stok berkurang)
- **Image Preview**: Tampilan gambar produk di kasir dan barista screen

### Changed
- Updated Product model dengan field image
- Updated Transaction model dengan type (sale/internal) dan userId
- Improved UI dengan role indicator di AppBar
- Enhanced navigation berdasarkan user role

### Technical
- Added `image_picker` untuk upload gambar
- Added User model dengan role & permissions
- Added AuthService untuk authentication
- Added ImageService untuk handle gambar produk
- Image disimpan di application documents directory

## [1.1.0] - 2025-01-11

### Added
- **Print Invoice**: Print struk thermal (80mm) setelah transaksi
- **Print Invoice A4**: Print ulang invoice dari riwayat transaksi
- **Export Excel**: Export laporan transaksi ke Excel
- **Export Products**: Export daftar produk ke Excel
- **Export Sales Report**: Export laporan penjualan dengan ringkasan
- **Share Files**: Share file Excel via WhatsApp, Email, dll

### Changed
- Updated dependencies untuk support print & export
- Removed incompatible printer packages
- Improved transaction flow dengan opsi print

### Technical
- Added PDF generation with `pdf` package
- Added Excel export with `excel` package
- Added file sharing with `share_plus` package
- Added file system access with `path_provider`

## [1.0.0] - 2025-01-11

### Added
- Initial release of POS Warkop
- Cashier screen with product selection and cart management
- Product management (CRUD operations)
- Transaction history tracking
- Sales reports and analytics
- 7-day sales chart visualization
- Sample data loader for testing
- Category filtering (Minuman, Makanan, Snack)
- Search functionality for products
- Payment processing with change calculation
- Local data storage using Flutter Secure Storage
- Material Design 3 UI with Google Fonts
- Bottom navigation for easy screen switching

### Features
- **Kasir**: Point of sale interface with real-time cart updates
- **Produk**: Complete product management system
- **Transaksi**: Transaction history with detailed information
- **Laporan**: Daily and monthly sales reports with charts

### Technical
- State management using Riverpod
- Secure local storage implementation
- Responsive UI design
- Indonesian locale support for currency and dates
