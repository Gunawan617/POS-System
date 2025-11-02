import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transaction.dart';
import '../models/product.dart';

class ExportService {
  static Future<void> exportTransactionsToExcel(
    List<Transaction> transactions,
    List<List<TransactionItem>> allItems,
  ) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Laporan Transaksi'];

      // Header
      sheet.appendRow([
        TextCellValue('No'),
        TextCellValue('Tanggal'),
        TextCellValue('No. Transaksi'),
        TextCellValue('Pelanggan'),
        TextCellValue('Total'),
        TextCellValue('Bayar'),
        TextCellValue('Kembali'),
        TextCellValue('Metode Pembayaran'),
      ]);

      // Style header
      for (var i = 0; i < 8; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.blue,
          fontColorHex: ExcelColor.white,
        );
      }

      // Data
      for (var i = 0; i < transactions.length; i++) {
        final transaction = transactions[i];
        sheet.appendRow([
          IntCellValue(i + 1),
          TextCellValue(DateFormat('dd/MM/yyyy HH:mm').format(transaction.date)),
          TextCellValue('#${transaction.id}'),
          TextCellValue(transaction.customer),
          DoubleCellValue(transaction.total),
          DoubleCellValue(transaction.paid),
          DoubleCellValue(transaction.change),
          TextCellValue(transaction.paymentMethod),
        ]);
      }

      // Auto-fit columns
      for (var i = 0; i < 8; i++) {
        sheet.setColumnWidth(i, 20);
      }

      // Save file
      final fileBytes = excel.save();
      if (fileBytes == null) {
        throw Exception('Failed to generate Excel file');
      }

      final uint8list = Uint8List.fromList(fileBytes);

      if (kIsWeb) {
        await Share.shareXFiles(
          [XFile.fromData(uint8list, name: 'Laporan_Transaksi_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx', mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
          subject: 'Laporan Transaksi POS Warkop',
        );
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'Laporan_Transaksi_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
        final filePath = '${directory.path}/$fileName';
        
        final file = File(filePath);
        await file.writeAsBytes(uint8list);

        await Share.shareXFiles(
          [XFile(filePath)],
          subject: 'Laporan Transaksi POS Warkop',
          text: 'Laporan transaksi periode ${DateFormat('dd MMMM yyyy').format(DateTime.now())}',
        );
      }
    } catch (e) {
      print('Error exporting transactions: $e');
      rethrow;
    }
  }

  static Future<void> exportProductsToExcel(List<Product> products) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Daftar Produk'];

      // Header
      sheet.appendRow([
        TextCellValue('No'),
        TextCellValue('Kode'),
        TextCellValue('Nama Produk'),
        TextCellValue('Kategori'),
        TextCellValue('Harga'),
        TextCellValue('Stok'),
        TextCellValue('Status'),
      ]);

      // Style header
      for (var i = 0; i < 7; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.green,
          fontColorHex: ExcelColor.white,
        );
      }

      // Data
      for (var i = 0; i < products.length; i++) {
        final product = products[i];
        sheet.appendRow([
          IntCellValue(i + 1),
          TextCellValue(product.code),
          TextCellValue(product.name),
          TextCellValue(product.category),
          DoubleCellValue(product.price),
          IntCellValue(product.stock),
          TextCellValue(product.isActive ? 'Aktif' : 'Nonaktif'),
        ]);
      }

      // Auto-fit columns
      for (var i = 0; i < 7; i++) {
        sheet.setColumnWidth(i, 20);
      }

      // Save file
      final fileBytes = excel.save();
      if (fileBytes == null) {
        throw Exception('Failed to generate Excel file');
      }

      final uint8list = Uint8List.fromList(fileBytes);

      if (kIsWeb) {
        await Share.shareXFiles(
          [XFile.fromData(uint8list, name: 'Daftar_Produk_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx', mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
          subject: 'Daftar Produk POS Warkop',
        );
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'Daftar_Produk_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
        final filePath = '${directory.path}/$fileName';
        
        final file = File(filePath);
        await file.writeAsBytes(uint8list);

        await Share.shareXFiles(
          [XFile(filePath)],
          subject: 'Daftar Produk POS Warkop',
          text: 'Daftar produk per ${DateFormat('dd MMMM yyyy').format(DateTime.now())}',
        );
      }
    } catch (e) {
      print('Error exporting products: $e');
      rethrow;
    }
  }

  static Future<void> exportSalesReportToExcel(
    List<Transaction> transactions,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final excel = Excel.createExcel();
      
      // Summary Sheet
      final summarySheet = excel['Ringkasan'];
      summarySheet.appendRow([TextCellValue('LAPORAN PENJUALAN')]);
      summarySheet.appendRow([
        TextCellValue('Periode: ${DateFormat('dd/MM/yyyy').format(startDate)} - ${DateFormat('dd/MM/yyyy').format(endDate)}'),
      ]);
      summarySheet.appendRow([TextCellValue('')]);
      
      final totalSales = transactions.fold<double>(0.0, (sum, t) => sum + t.total);
      final totalTransactions = transactions.length;
      final double averageSales = totalTransactions > 0 ? totalSales / totalTransactions : 0.0;
      
      summarySheet.appendRow([TextCellValue('Total Penjualan:'), DoubleCellValue(totalSales)]);
      summarySheet.appendRow([TextCellValue('Jumlah Transaksi:'), IntCellValue(totalTransactions)]);
      summarySheet.appendRow([TextCellValue('Rata-rata per Transaksi:'), DoubleCellValue(averageSales)]);

      // Detail Sheet
      final detailSheet = excel['Detail Transaksi'];
      detailSheet.appendRow([
        TextCellValue('No'),
        TextCellValue('Tanggal'),
        TextCellValue('No. Transaksi'),
        TextCellValue('Total'),
        TextCellValue('Metode Pembayaran'),
      ]);

      for (var i = 0; i < transactions.length; i++) {
        final transaction = transactions[i];
        detailSheet.appendRow([
          IntCellValue(i + 1),
          TextCellValue(DateFormat('dd/MM/yyyy HH:mm').format(transaction.date)),
          TextCellValue('#${transaction.id}'),
          DoubleCellValue(transaction.total),
          TextCellValue(transaction.paymentMethod),
        ]);
      }

      // Save file
      final fileBytes = excel.save();
      if (fileBytes == null) {
        throw Exception('Failed to generate Excel file');
      }

      final uint8list = Uint8List.fromList(fileBytes);

      if (kIsWeb) {
        await Share.shareXFiles(
          [XFile.fromData(uint8list, name: 'Laporan_Penjualan_${DateFormat('yyyyMMdd').format(startDate)}_${DateFormat('yyyyMMdd').format(endDate)}.xlsx', mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
          subject: 'Laporan Penjualan POS Warkop',
        );
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'Laporan_Penjualan_${DateFormat('yyyyMMdd').format(startDate)}_${DateFormat('yyyyMMdd').format(endDate)}.xlsx';
        final filePath = '${directory.path}/$fileName';
        
        final file = File(filePath);
        await file.writeAsBytes(uint8list);

        await Share.shareXFiles(
          [XFile(filePath)],
          subject: 'Laporan Penjualan POS Warkop',
          text: 'Laporan penjualan periode ${DateFormat('dd/MM/yyyy').format(startDate)} - ${DateFormat('dd/MM/yyyy').format(endDate)}',
        );
      }
    } catch (e) {
      print('Error exporting sales report: $e');
      rethrow;
    }
  }
}
