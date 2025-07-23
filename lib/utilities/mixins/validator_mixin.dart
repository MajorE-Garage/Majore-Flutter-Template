mixin ValidatorMixin {
  String? validateRequiredField(dynamic val) {
    if (val == null ||
        (val is num && val == 0) ||
        (val is String && val.trim().isEmpty)) {
      return 'This field cannot be empty';
    }
    return null;
  }

  String? validateEmail(String email) {
    if (email.trim().isEmpty) return 'Email address cannot be empty';
    final valid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
    if (!valid) return 'Enter a valid email address';
    return null;
  }

  String? validatePassword(String password) {
    password = password.trim();
    if (password.isEmpty) return 'Enter a password for your account';
    if (password.length < 6) return 'At least 6 characters';
    return null;
  }

  String? validateConfirmPassword(String confirmPassword, String password) {
    if (password.isEmpty) return null;
    if (confirmPassword.trim() != password.trim()) {
      return 'Passwords do not match';
    }
    return null;
  }

/*   String? validatePhone(String? phone, CountryModel? country) {
    if (country == null) {
      return "Select country's phone code";
    }
    if (phone == null || phone.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (phone.length < 7) {
      return 'Enter a valid phone number';
    }
    return null;
  } */
}
