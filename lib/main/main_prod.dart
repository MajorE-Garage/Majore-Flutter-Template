import 'application.dart';
import 'firebase_options_prod.dart' as prod;

void main() => mainApp(prod.DefaultFirebaseOptions.currentPlatform);
