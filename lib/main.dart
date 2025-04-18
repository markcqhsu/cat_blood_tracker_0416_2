import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'mock/mock_data_seeder.dart';
import 'app.dart';
import 'providers/entry_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/cat_provider.dart';
import 'providers/chart_settings_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // Optional: log to console
    debugPrint('Flutter Error: ${details.exceptionAsString()}');
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CatProvider()),
        ChangeNotifierProvider(create: (_) => EntryProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ChartSettingsProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Cat Blood Tracker',
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        locale: const Locale('en'),
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const CatBgTrackerApp(),
      ),
    ),
  );

  // Inject test data after providers are initialized
  if (kDebugMode) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentContext!;
      final catProvider = Provider.of<CatProvider>(context, listen: false);
      final entryProvider = Provider.of<EntryProvider>(context, listen: false);
      debugPrint('Seeding mock data...');
      MockDataSeeder.seed(catProvider, entryProvider);
    });
  }
}

// Note: New file l10n.yaml should be created in the root directory with the following content:
/*
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
synthetic-package: false
*/

@override
Widget build(BuildContext context) {
  final catProvider = context.watch<CatProvider>();
  final chartSettingsProvider = context.watch<ChartSettingsProvider>();
  final selectedCatId = catProvider.selectedCatId;
  final selectedCat = catProvider.getCatById(selectedCatId ?? '');
  final limits =
      chartSettingsProvider.limitRecords
          .where((e) => e.catId == selectedCatId)
          .toList();

  return Scaffold(
    appBar: AppBar(
      title: Text(
        AppLocalizations.of(context)?.insulinChartTitle ??
            'Insulin Chart Range Settings',
      ),
    ),
    body:
        selectedCat == null
            ? Center(
              child: Text(
                AppLocalizations.of(context)?.pleaseAddPet ??
                    'Please add a pet before configuring chart ranges.',
              ),
            )
            : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 1. 寵物選擇
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedCatId,
                        items:
                            catProvider.cats.map((cat) {
                              return DropdownMenuItem<String>(
                                value: cat.id,
                                child: Text(cat.name),
                              );
                            }).toList(),
                        onChanged: (id) {
                          catProvider.setSelectedCat(id);
                        },
                      ),
                    ),
                  ),

                  // 2. 範圍設定：下限 -> 上限
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)?.lowerLimit ??
                                'Lower Limit Warning',
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  onChanged:
                                      chartSettingsProvider.setLowerLimit,
                                  decoration: InputDecoration(
                                    labelText:
                                        AppLocalizations.of(context)?.value ??
                                        'Value',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green,
                                  border: Border.all(color: Colors.black12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)?.upperLimit ??
                                'Upper Limit Warning',
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  onChanged:
                                      chartSettingsProvider.setUpperLimit,
                                  decoration: InputDecoration(
                                    labelText:
                                        AppLocalizations.of(context)?.value ??
                                        'Value',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                  border: Border.all(color: Colors.black12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. 儲存按鈕
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                        ),
                        onPressed: () {
                          chartSettingsProvider.saveLimits(selectedCatId);
                        },
                        child: Text(
                          AppLocalizations.of(context)?.saveSettings ??
                              'Save Settings',
                        ),
                      ),
                    ),
                  ),

                  // 4. 已設定的紀錄
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: limits.length,
                    itemBuilder: (ctx, index) {
                      final r = limits[index];
                      final catName =
                          catProvider.getCatById(r.catId)?.name ?? 'Unknown';
                      return Dismissible(
                        key: ValueKey(r),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          chartSettingsProvider.delete(r);
                        },
                        background: Container(color: Colors.red),
                        child: Card(
                          child: ListTile(
                            title: Text('$catName'),
                            subtitle: Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 12,
                                  color: r.upperColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${AppLocalizations.of(context)?.upper ?? 'Upper'}: ${r.upper}',
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.circle,
                                  size: 12,
                                  color: r.lowerColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${AppLocalizations.of(context)?.lower ?? 'Lower'}: ${r.lower}',
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    chartSettingsProvider.setLowerLimit(
                                      r.lower.toString(),
                                    );
                                    chartSettingsProvider.setUpperLimit(
                                      r.upper.toString(),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    chartSettingsProvider.delete(r);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
  );
}
