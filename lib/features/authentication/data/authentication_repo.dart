import '../../../core/data/data.dart';
import '../../../services/rest_network_service/rest_network_service.dart';
import '../domain/models/user_model.dart';

class AuthenticationRepo extends AppRepository {
  final RestNetworkService _networkService;

  AuthenticationRepo({required RestNetworkService networkService})
    : _networkService = networkService;

  Future<DataResponse<LoginInfo>> login({required String email, required String password}) =>
      runDataWithGuard(() async {
        final req = JsonRequest.post('/login', {'email': email, 'password': password});
        final response = await _networkService.sendJsonRequest(req);
        final user = UserModel(id: response['id'], email: response['email']);
        return DataResponse(data: (token: response['token'], user: user));
      });
}
