import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisab/core/db/hive/person_model/person.dart';
import 'package:hisab/core/db/hive/transaction_model/transaction.dart';
import 'package:hisab/core/db/hive/user_model/user_model.dart';
import 'package:hisab/l10n/app_localizations.dart';
import 'package:hive/hive.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/preferences/preference_config.dart';
import 'presentations/app.dart';
import 'package:hive_flutter/hive_flutter.dart';

// GlobalKey<NavigatorState> navigatorKey = GlobalKey();
// BuildContext get appContext => navigatorKey.currentContext!;
ThemeData appTheme(BuildContext context) => Theme.of(context);
AppLocalizations appLanguage(BuildContext context) => AppLocalizations.of(context)!;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await ScreenUtil.ensureScreenSize();
  await initPreferences();
    await Hive.initFlutter();
  Hive.registerAdapter(PersonAdapter());
  Hive.registerAdapter(TransactionAdapter());
      Hive.registerAdapter(UserAdapter());
  await Hive.openBox<Person>('persons');
  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox<User>('users');

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
