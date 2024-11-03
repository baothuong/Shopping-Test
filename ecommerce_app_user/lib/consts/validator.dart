//lớp này cung cấp các phương thức tĩnh để xác thực dữ liệu đầu vào của người dùng.
//Các phương thức này thường được sử dụng trong các trường biểu mẫu để đảm bảo dữ
// liệu đầu vào đáp ứng các tiêu chí nhất định trước khi được xử lý hoặc gửi đi.
class MyValidators {
  //Xác thực tên hiển thị: Đảm bảo tên hiển thị không để trống và nằm trong phạm vi độ dài đã chỉ định.
  static String? displayNamevalidator(String? displayName) {
    if (displayName == null || displayName.isEmpty) {
      return 'Display name cannot be empty';
    }
    if (displayName.length < 3 || displayName.length > 20) {
      return 'Display name must be between 3 and 20 characters';
    }

    return null; // Return null if display name is valid
  }

  //Xác thực email: Đảm bảo email không để trống và khớp với mẫu biểu thức chính quy cho các địa chỉ email hợp lệ.
  static String? emailValidator(String? value) {
    if (value!.isEmpty) {
      return 'Please enter an email';
    }
    if (!RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b')
        .hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  //Xác thực mật khẩu: Đảm bảo mật khẩu không để trống và đủ dài
  static String? passwordValidator(String? value) {
    if (value!.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  //Xác thực mật khẩu lặp lại: Đảm bảo mật khẩu lặp lại khớp với mật khẩu đã nhập
  static String? repeatPasswordValidator({String? value, String? password}) {
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  //xác thực giá trị đầu vào văn bản
  static String? uploadProdTexts({String? value, String? toBeReturnedString}) {
    if (value!.isEmpty) {
      return toBeReturnedString;
    }
    return null;
  }
}
