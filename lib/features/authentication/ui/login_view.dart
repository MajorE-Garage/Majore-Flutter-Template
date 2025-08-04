import 'package:flutter/material.dart';

import '../../../core/presentation/presentation.dart';
import '../../../core/service_locator/service_locator.dart';
import '../domain/login_vm.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppView<LoginVm>(
        model: ServiceLocator.get(),
        builder: (vm, _) => Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: vm.emailField,
              label: context.translations.email,
              keyboardType: TextInputType.emailAddress,
              capitalization: TextCapitalization.none,
            ),
            SizedBox(height: 16),
            AppTextField(controller: vm.passwordField, label: context.translations.password),
            SizedBox(height: 16),
            AppViewSelector<LoginVm, bool>(
              selector: (vm) => vm.isBusy,
              builder: (isBusy, child) => AppButton.primary(
                onPressed: vm.login,
                busy: isBusy,
                label: context.translations.login,
              ),
            ),
            AppViewSelector<LoginVm, bool>(
              selector: (vm) => vm.hasEncounteredError,
              builder: (hasEncounteredError, child) => hasEncounteredError
                  ? Text('Login failed - ${vm.lastFailure?.message ?? ''}')
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
