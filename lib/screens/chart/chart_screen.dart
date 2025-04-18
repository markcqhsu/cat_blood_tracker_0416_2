import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/entry_provider.dart';
// import '../../providers/settings_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../providers/cat_provider.dart';
import '../../providers/chart_settings_provider.dart';

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
  String? _selectedCatId;

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
      initialDateRange:
          _startDate != null && _endDate != null
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
    // final settings = context.watch<SettingsProvider>();
    final cats = context.watch<CatProvider>().cats;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    if (cats.isNotEmpty && _selectedCatId == null) {
      _selectedCatId = cats.first.id;
    }

    final sortedEntries =
        entries.toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final filteredEntries =
        sortedEntries.where((e) {
          return _inRange(e.dateTime) &&
              (_selectedCatId == null || e.catID == _selectedCatId);
        }).toList();

    if (filteredEntries.isEmpty) {
      return const Center(child: Text('No data to display.'));
    }

    final spots =
        filteredEntries.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          return FlSpot(index.toDouble(), data.bloodGlucose.toDouble());
        }).toList();

    final chartLimits =
        _selectedCatId == null
            ? []
            : context
                .watch<ChartSettingsProvider>()
                .limitRecords
                .where((e) => e.catId == _selectedCatId)
                .toList();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: screenHeight * 0.08,
            bottom: 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: DropdownButtonFormField<String>(
                        value: _selectedCatId,
                        decoration: InputDecoration(
                          isDense: false,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          prefixIcon: const Icon(Icons.pets),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        hint: Text(
                          AppLocalizations.of(context)?.filterByPet ?? 'Pet',
                        ),
                        items:
                            cats.map((cat) {
                              return DropdownMenuItem(
                                value: cat.id,
                                child: Text(cat.name),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCatId = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: DropdownButtonFormField<String>(
                        value: _selectedRange,
                        decoration: InputDecoration(
                          isDense: false,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        hint: Text(
                          AppLocalizations.of(context)?.filterByDate ?? 'Date',
                        ),
                        items:
                            ranges.map((r) {
                              return DropdownMenuItem(value: r, child: Text(r));
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
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                    top: 8,
                  ), // 讓左邊的文字有空間 and move chart down slightly
                  child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: (spots.length - 1).toDouble(),
                      minY: spots
                          .map((s) => s.y)
                          .reduce((a, b) => a < b ? a : b),
                      maxY: (spots
                                  .map((s) => s.y)
                                  .reduce((a, b) => a > b ? a : b) +
                              20)
                          .clamp(0, 600),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 ||
                                  index >= filteredEntries.length) {
                                return const SizedBox();
                              }
                              final date = filteredEntries[index].dateTime;
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  DateFormat('MM/dd').format(date),
                                  style: TextStyle(
                                    fontSize: isTablet ? 12 : 10,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40, // 原本預設 32，調大一點避免擁擠
                            getTitlesWidget:
                                (value, meta) => Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
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
                          for (var limit in chartLimits) ...[
                            HorizontalLine(
                              y: limit.lower,
                              color: limit.lowerColor,
                              strokeWidth: 2,
                              dashArray: [8, 4],
                              label: HorizontalLineLabel(
                                show: true,
                                alignment: Alignment.bottomLeft,
                                labelResolver: (_) => 'Lower ${limit.lower}',
                                style: TextStyle(
                                  color: limit.lowerColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            HorizontalLine(
                              y: limit.upper,
                              color: limit.upperColor,
                              strokeWidth: 2,
                              dashArray: [8, 4],
                              label: HorizontalLineLabel(
                                show: true,
                                alignment: Alignment.topLeft,
                                labelResolver: (_) => 'Upper ${limit.upper}',
                                style: TextStyle(
                                  color: limit.upperColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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
