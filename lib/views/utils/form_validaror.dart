class AppValidators {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name can\'t be empty';
    } else if (value.length <= 4) {
      return 'Full name must be more than 3 characters';
    } else if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
      return 'Full name can only contain letters';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number can\'t be empty';
    } else if (value.length < 11) {
      return 'Phone number must be more than 9 characters';
    } else if (!RegExp(r"^[0-9]+$").hasMatch(value)) {
      return 'Phone number can only contain numbers';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value!.isEmpty) {
      return 'Email can\'t be empty';
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Please enter a valid email';
    } else {
      return null;
    }
  }

  static String? validatePassword(String? value) {
    if (value!.isEmpty) {
      return 'Password can\'t be empty';
    } else if (value.length < 8) {
      return 'Password can\'t be less than 8 characters';
    } else if (!RegExp(r'^(?=.*[a-z])(?=.*[0-9]).{8,}$').hasMatch(value)) {
      return 'Password must be 8 - 16 characters long and contain alphabets and numbers';
    } else {
      return null;
    }
  }

  static String? validateOtp(String? value) {
    if (value!.isEmpty) {
      return 'OTP code can\'t be empty';
    } else if (value.length != 6) {
      return 'OTP code must consist of 6 digits';
    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'OTP code can only contain numbers';
    } else {
      return null;
    }
  }

  static String? validateDropdown(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select Value';
    }
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address can\'t be empty';
    } else if (value.length < 10) {
      return 'Address is incomplete, please enter more details';
    } else {
      return null;
    }
  }

  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Description can\'t be empty';
    } else if (value.length < 10) {
      return 'Description is incomplete, please enter more details';
    } else {
      return null;
    }
  }
}
