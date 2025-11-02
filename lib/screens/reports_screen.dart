import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/product_provider.dart';
import '../services/export_service.dart';
import '../services/storage_service.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          transactionsAsync.when(
            data: (transactions) => PopupMenuButton(
              icon: const Icon(Icons.download),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'transactions',
                  child: Row(
                    children: [
                      Icon(Icons.receipt_long),
                      SizedBox(width: 8),
                      Text('Export Transaksi'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'products',
                  child: Row(
                    children: [
                      Icon(Icons.inventory),
                      SizedBox(width: 8),
                      Text('Export Produk'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'sales',
                  child: Row(
                    children: [
                      Icon(Icons.analytics),
                      SizedBox(width: 8),
                      Text('Export Laporan Penjualan'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) => _handleExport(context, ref, value as String, transactions),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          final today = DateTime.now();
          final todayTransactions = transactions.where((t) =>
              t.date.year == today.year &&
              t.date.month == today.month &&
              t.date.day == today.day).toList();

          final todayTotal = todayTransactions.fold<double>(
              0, (sum, t) => sum + t.total);
          final todayCount = todayTransactions.length;

          final monthTransactions = transactions.where((t) =>
              t.date.year == today.year &&
              t.date.month == today.month).toList();

          final monthTotal = monthTransactions.fold<double>(
              0, (sum, t) => sum + t.total);
          final monthCount = monthTransactions.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Hari Ini',
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(todayTotal),
                        '$todayCount transaksi',
                        Icons.today,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Bulan Ini',
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(monthTotal),
                        '$monthCount transaksi',
                        Icons.calendar_month,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Grafik Penjualan 7 Hari Terakhir',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: _buildChart(transactions),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List transactions) {
    final now = DateTime.now();
    final last7Days = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return DateTime(date.year, date.month, date.day);
    });

    final data = last7Days.map((date) {
      final dayTransactions = transactions.where((t) =>
          t.date.year == date.year &&
          t.date.month == date.month &&
          t.date.day == date.day).toList();
      final total = dayTransactions.fold<double>(0, (sum, t) => sum + t.total);
      return total;
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Text(
                  NumberFormat.compact(locale: 'id_ID').format(value),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < last7Days.length) {
                  return Text(
                    DateFormat('dd/MM').format(last7Days[value.toInt()]),
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value);
            }).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExport(
    BuildContext context,
    WidgetRef ref,
    String type,
    List<Transaction> transactions,
  ) async {
    try {
      switch (type) {
        case 'transactions':
          final storage = ref.read(storageServiceProvider);
          final allItems = <List<TransactionItem>>[];
          for (var transaction in transactions) {
            final items = await storage.getTransactionItems(transaction.id!);
            allItems.add(items);
          }
          await ExportService.exportTransactionsToExcel(transactions, allItems);
          break;
          
        case 'products':
          final productsAsync = ref.read(productsProvider);
          productsAsync.whenData((products) async {
            await ExportService.exportProductsToExcel(products);
          });
          break;
          
        case 'sales':
          final now = DateTime.now();
          final startOfMonth = DateTime(now.year, now.month, 1);
          await ExportService.exportSalesReportToExcel(
            transactions,
            startOfMonth,
            now,
          );
          break;
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export berhasil! File akan dibagikan.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal export: $e')),
        );
      }
    }
  }
}
