import 'package:flutter/material.dart';

import '../../../core/presentation/app_view_builder.dart';
import '../../../core/service_locator/service_locator.dart';
import '../domain/login_vm.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppViewBuilder<LoginVm>(
        model: ServiceLocator.get(),
        builder: (vm, _) => Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: vm.emailField,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: vm.passwordField,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 16),
            TextButton(onPressed: vm.login, child: Text('Login')),

            if (vm.hasEncounteredError) Text('Login failed - ${vm.lastFailure?.message ?? ''}'),
          ],
        ),
      ),
    );
  }
}
