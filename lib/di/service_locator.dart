import 'package:get_it/get_it.dart';

import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/firebase_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  if (!getIt.isRegistered<DatabaseService>()) {
    final databaseService = DatabaseService();
    await databaseService.init();
    getIt.registerSingleton<DatabaseService>(databaseService);
  }

  if (!getIt.isRegistered<AuthService>()) {
    getIt.registerLazySingleton<AuthService>(() => AuthService());
  }

  if (!getIt.isRegistered<FirebaseService>()) {
    getIt.registerLazySingleton<FirebaseService>(
      () => FirebaseService(getIt<DatabaseService>()),
    );
  }
}

