import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/entry_provider.dart';
import '../../providers/settings_provider.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  String _selectedRange = 'All';
  List<String> ranges = ['All', '7 days', '30 days', 'Custom'];
  DateTime? _startDate;
  DateTime? _endDate;

  bool _inRange(DateTime time) {
    if (_selectedRange == '7 days') {
      return time.isAfter(DateTime.now().subtract(const Duration(days: 7)));
    } else if (_selectedRange == '30 days') {
      return time.isAfter(DateTime.now().subtract(const Duration(days: 30)));
    } else if (_selectedRange == 'Custom') {
      if (_startDate != null && _endDate != null) {
        return time.isAfter(_startDate!.subtract(const Duration(seconds: 1))) &&
               time.isBefore(_endDate!.add(const Duration(days: 1)));
      }
      return false;
    }
    return true;
  }

  Future<void> _selectCustomDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<EntryProvider>().entries;
    final settings = context.watch<SettingsProvider>();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    final sortedEntries = entries.toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final filteredEntries = sortedEntries.where((e) => _inRange(e.dateTime)).toList();

    if (filteredEntries.isEmpty) {
      return const Center(child: Text('No data to display.'));
    }

    final spots = filteredEntries.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return FlSpot(index.toDouble(), data.bloodGlucose.toDouble());
    }).toList();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: screenHeight * 0.12,
            bottom: 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    value: _selectedRange,
                    items: ranges.map((r) {
                      return DropdownMenuItem(
                        value: r,
                        child: Text(r),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      if (value != null) {
                        if (value == 'Custom') {
                          await _selectCustomDateRange();
                        }
                        setState(() => _selectedRange = value);
                      }
                    },
                  ),
                  if (_selectedRange == 'Custom' && _startDate != null && _endDate != null)
                    Text('${DateFormat('MM/dd').format(_startDate!)} - ${DateFormat('MM/dd').format(_endDate!)}')
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12), // 讓左邊的文字有空間
                  child: LineChart(
                    LineChartData(
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= filteredEntries.length) return const SizedBox();
                              final date = filteredEntries[index].dateTime;
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  DateFormat('MM/dd').format(date),
                                  style: TextStyle(fontSize: isTablet ? 12 : 10),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40, // 原本預設 32，調大一點避免擁擠
                            getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 12)),
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          barWidth: 3,
                          color: Colors.teal,
                          belowBarData: BarAreaData(show: false),
                          dotData: FlDotData(show: true),
                        ),
                      ],
                      extraLinesData: ExtraLinesData(
                        horizontalLines: [
                          for (var range in settings.limitRanges) ...[
                            HorizontalLine(
                              y: range['lower'],
                              color: range['lowerColor'],
                              strokeWidth: 2,
                              dashArray: [8, 4],
                              label: HorizontalLineLabel(
                                show: true,
                                alignment: Alignment.bottomLeft,
                                labelResolver: (_) => 'Lower ${range['lower']}',
                                style: TextStyle(color: range['lowerColor'], fontWeight: FontWeight.bold),
                              ),
                            ),
                            HorizontalLine(
                              y: range['upper'],
                              color: range['upperColor'],
                              strokeWidth: 2,
                              dashArray: [8, 4],
                              label: HorizontalLineLabel(
                                show: true,
                                alignment: Alignment.topLeft,
                                labelResolver: (_) => 'Upper ${range['upper']}',
                                style: TextStyle(color: range['upperColor'], fontWeight: FontWeight.bold),
                              ),
                            ),
                          ]
                        ],
                      ),
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: true),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}