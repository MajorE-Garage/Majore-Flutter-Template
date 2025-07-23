import 'package:flutter/material.dart';

import '../../../core/domain/app_view_model.dart';
import '../data/authentication_repo.dart';

class LoginVm extends AppViewModel {
  final AuthenticationRepo _authRepo;

  LoginVm({required AuthenticationRepo authRepo}) : _authRepo = authRepo;

  final emailField = TextEditingController();
  final passwordField = TextEditingController();

  Future<void> login() async {
    // Validation

    // Send to Server
    final login = await _authRepo.login(email: emailField.text, password: passwordField.text);
    if (login.isSuccessful) {
      //
    } else {
      handleErrorAndSetVmState(login.error!);
    }
  }
}
