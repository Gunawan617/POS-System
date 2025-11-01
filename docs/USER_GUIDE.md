# User Guide - POS Warkop

Panduan lengkap penggunaan aplikasi POS Warkop untuk kasir dan pemilik warung kopi.

## Daftar Isi
1. [Memulai](#memulai)
2. [Menu Kasir](#menu-kasir)
3. [Manajemen Produk](#manajemen-produk)
4. [Riwayat Transaksi](#riwayat-transaksi)
5. [Laporan](#laporan)
6. [Tips & Trik](#tips--trik)

---

## Memulai

### Pertama Kali Menggunakan

1. **Buka aplikasi** POS Warkop
2. Anda akan melihat layar Kasir (kosong karena belum ada produk)
3. **Tambahkan produk** terlebih dahulu:
   - Tap icon **Produk** di bottom navigation
   - Tap icon **download** (⬇️) untuk load data contoh
   - Atau tap icon **+** untuk menambah produk manual

### Navigasi Aplikasi

Aplikasi memiliki 4 menu utama di bottom navigation:

- 🧾 **Kasir** - Untuk melakukan transaksi penjualan
- 📦 **Produk** - Untuk mengelola produk
- 🧾 **Transaksi** - Untuk melihat riwayat transaksi
- 📊 **Laporan** - Untuk melihat laporan penjualan

---

## Menu Kasir

Menu kasir adalah tempat Anda melakukan transaksi penjualan sehari-hari.

### Melakukan Transaksi

#### 1. Pilih Produk
- **Cara 1**: Tap langsung pada card produk
- **Cara 2**: Gunakan search bar untuk mencari produk
- **Cara 3**: Filter berdasarkan kategori (Semua, Minuman, Makanan, Snack)

#### 2. Atur Quantity
Setelah produk masuk keranjang:
- Tap **-** untuk mengurangi quantity
- Tap **+** untuk menambah quantity
- Tap icon **🗑️** untuk menghapus item dari keranjang

#### 3. Proses Pembayaran
1. Pastikan semua item sudah benar di keranjang
2. Tap tombol **Bayar** (hijau di bawah)
3. Masukkan jumlah uang yang dibayarkan pelanggan
4. Tap **Proses**
5. Sistem akan menampilkan kembalian
6. Tap **OK** untuk menyelesaikan transaksi

#### 4. Batal Transaksi
- Tap tombol **Batal** untuk mengosongkan keranjang

### Tips Kasir
- Gunakan search untuk produk yang sering dibeli
- Gunakan filter kategori untuk mempercepat pencarian
- Periksa total sebelum proses pembayaran
- Pastikan jumlah bayar >= total

---

## Manajemen Produk

Menu untuk mengelola semua produk yang dijual.

### Menambah Produk Baru

1. Tap icon **+** di pojok kanan atas
2. Isi form:
   - **Nama Produk**: Nama produk (contoh: Kopi Hitam)
   - **Kode Produk**: Kode unik (contoh: KOPI001)
   - **Harga**: Harga jual (contoh: 7000)
   - **Stok**: Jumlah stok awal (contoh: 50)
   - **Kategori**: Pilih kategori (Minuman/Makanan/Snack)
   - **Deskripsi**: Deskripsi produk (opsional)
3. Tap **Simpan**

### Mengedit Produk

1. Tap icon **✏️** (edit) pada produk yang ingin diubah
2. Ubah data yang diperlukan
3. Tap **Simpan**

### Menghapus Produk

1. Tap icon **🗑️** (delete) pada produk yang ingin dihapus
2. Konfirmasi penghapusan
3. Tap **Hapus**

⚠️ **Perhatian**: Produk yang sudah dihapus tidak dapat dikembalikan!

### Load Sample Data

Untuk testing atau demo:
1. Tap icon **⬇️** (download) di pojok kanan atas
2. Konfirmasi
3. Sistem akan menambahkan 8 produk contoh

---

## Riwayat Transaksi

Menu untuk melihat semua transaksi yang telah dilakukan.

### Informasi yang Ditampilkan

Setiap transaksi menampilkan:
- **Nomor Transaksi** (#1, #2, dst)
- **Total Pembayaran**
- **Tanggal & Waktu** transaksi
- **Nama Pelanggan**
- **Metode Pembayaran**
- **Jumlah Bayar**
- **Kembalian**

### Melihat Detail Transaksi

Tap pada transaksi untuk melihat detail lengkap (fitur akan datang).

---

## Laporan

Menu untuk melihat analisis penjualan.

### Dashboard Statistik

Menampilkan 2 card utama:

#### 1. Penjualan Hari Ini
- Total penjualan hari ini
- Jumlah transaksi hari ini

#### 2. Penjualan Bulan Ini
- Total penjualan bulan berjalan
- Jumlah transaksi bulan berjalan

### Grafik Penjualan

**Grafik 7 Hari Terakhir**
- Menampilkan tren penjualan 7 hari terakhir
- Sumbu X: Tanggal
- Sumbu Y: Total penjualan (Rupiah)
- Hover pada titik untuk melihat detail

### Cara Membaca Grafik

- **Garis naik**: Penjualan meningkat
- **Garis turun**: Penjualan menurun
- **Garis datar**: Penjualan stabil

---

## Tips & Trik

### Untuk Kasir

1. **Gunakan Shortcut**
   - Search bar untuk produk favorit
   - Filter kategori untuk navigasi cepat

2. **Cek Sebelum Bayar**
   - Pastikan semua item benar
   - Cek total sebelum input pembayaran

3. **Kelola Keranjang**
   - Hapus item yang salah segera
   - Update quantity dengan tepat

### Untuk Pemilik

1. **Monitor Penjualan**
   - Cek laporan harian setiap hari
   - Analisis tren dari grafik

2. **Kelola Stok**
   - Update stok produk secara berkala
   - Nonaktifkan produk yang habis

3. **Analisis Data**
   - Lihat produk terlaris
   - Identifikasi hari dengan penjualan tinggi

### Maintenance

1. **Backup Data**
   - Export data secara berkala (fitur akan datang)
   - Simpan backup di tempat aman

2. **Update Harga**
   - Review harga produk secara berkala
   - Update sesuai kondisi pasar

3. **Bersihkan Data Lama**
   - Archive transaksi lama (fitur akan datang)
   - Hapus produk yang tidak aktif

---

## Troubleshooting

### Produk Tidak Muncul di Kasir
**Solusi**: 
- Pastikan produk sudah ditambahkan di menu Produk
- Cek status produk (harus aktif)

### Transaksi Tidak Tersimpan
**Solusi**:
- Pastikan proses pembayaran selesai
- Jangan tutup aplikasi saat proses transaksi

### Data Hilang
**Solusi**:
- Data tersimpan lokal di device
- Jangan clear data aplikasi
- Gunakan fitur backup (akan datang)

### Aplikasi Lambat
**Solusi**:
- Restart aplikasi
- Clear cache (jika tersedia)
- Update ke versi terbaru

---

## Keyboard Shortcuts

(Untuk versi desktop)

- `Ctrl + N` - Produk baru (akan datang)
- `Ctrl + F` - Focus search (akan datang)
- `Ctrl + P` - Print struk (akan datang)
- `Esc` - Batal transaksi (akan datang)

---

## Kontak Support

Jika mengalami masalah atau memiliki pertanyaan:
- Email: support@poswarkop.com (contoh)
- WhatsApp: +62xxx-xxxx-xxxx (contoh)
- Website: www.poswarkop.com (contoh)

---

## Update Log

Cek file `CHANGELOG.md` untuk melihat update terbaru.

---

**Selamat menggunakan POS Warkop! ☕**
