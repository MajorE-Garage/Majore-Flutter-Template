import '../../core/service_locator/service_locator.dart';
import '../../services/analytics_service/analytics_service.dart';
import '../../services/error_logging_service/error_logging_service.dart';
import '../../services/local_storage_service/local_storage_service.dart';
import 'app_user.dart';
import 'app_view_model.dart';

typedef AuthModel = ({String token, AppUser user});

class SessionManager extends AppViewModel {
  final LocalStorageService localStorageService;
  final ErrorLogService errorLogService;
  final AnalyticsService analyticsService;

  late String _token;
  late AppUser _currentUser;

  bool _sessionIsOpen = false;

  final Map _sessionHeaders = <String, String>{};

  SessionManager({
    required this.localStorageService,
    required this.errorLogService,
    required this.analyticsService,
  });

  bool get isOpen => _sessionIsOpen;
  String? get accessToken => _sessionIsOpen ? _token : null;
  AppUser get currentUser => _currentUser;

  Map<String, String> sessionHeaders(bool withToken) {
    final Map<String, String> headers = Map.from(_sessionHeaders);
    if (!withToken) {
      return headers;
    } else {
      return headers..putIfAbsent('Authorization', () => 'Bearer $accessToken');
    }
  }

  void open({required AuthModel auth}) {
    _token = auth.token;
    _sessionIsOpen = true;

    _currentUser = auth.user;
    errorLogService.connectUser(_currentUser);
    analyticsService.logInUser(_currentUser);

    setState();
  }

  Future<void> close() async {
    if (_sessionIsOpen) {
      localStorageService.clearEntireStorage();
      errorLogService.disconnectUser();
      clearSessionHeaders();
      ServiceLocator.resetInstance<SessionManager>();
    }
  }

  bool updateUser(AppUser user) {
    if (_sessionIsOpen) {
      _currentUser = user;
      setState();
      errorLogService.connectUser(_currentUser);
      analyticsService.logInUser(_currentUser);
      return true;
    } else {
      return false;
    }
  }

  bool updateToken(String token) {
    if (_sessionIsOpen) {
      _token = token;
      return true;
    } else {
      return false;
    }
  }

  void setSessionHeaders(Map<String, String> x) {
    _sessionHeaders.addAll(x);
  }

  void clearSessionHeaders() {
    _sessionHeaders.clear();
  }
}
