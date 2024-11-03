import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ecommerce_app_user/models/cart_model.dart';
import 'package:ecommerce_app_user/providers/products_provider.dart';
import 'package:ecommerce_app_user/services/my_app_functions.dart';
import 'package:uuid/uuid.dart';

//lớp này Quản lý trạng thái của giỏ hàng bằng provider
class CartProvider with ChangeNotifier {
  final Map<String, CartModel> _cartItems = {};
  Map<String, CartModel> get getCartitems {
    return _cartItems;
  }

  final userstDb = FirebaseFirestore.instance.collection("users");
  final _auth = FirebaseAuth.instance;

//Phương thức addToCartFirebase để Đảm bảo rằng người dùng đã được xác thực chưa, trước khi tiến hành thao tác giỏ hàng
//và Cập nhật dữ liệu giỏ hàng của người dùng trong Firestore.
  Future<void> addToCartFirebase({
    required String productId,
    required int qty,
    required BuildContext context,
  }) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      MyAppFunctions.showErrorOrWarningDialog(
        context: context,
        subtitle: "Please login first",
        fct: () {},
      );
      return;
    }
    final uid = user.uid;
    final cartId = const Uuid().v4();
    try {
      await userstDb.doc(uid).update({
        'userCart': FieldValue.arrayUnion([
          {
            'cartId': cartId,
            'productId': productId,
            'quantity': qty,
          }
        ])
      });
      await fetchCart();
      Fluttertoast.showToast(msg: "Item has been added");
    } catch (e) {
      rethrow;
    }
  }

  //phương thức fetchCart để lấy dữ liệu giỏ hàng của người dùng từ Firestore và cập nhật trạng thái của giỏ hàng
  //để đảm bảo đồng bộ hóa với dữ liệu lưu trữ trong Firestore
  Future<void> fetchCart() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      _cartItems.clear();
      return;
    }
    try {
      final userDoc = await userstDb.doc(user.uid).get();
      final data = userDoc.data();
      if (data == null || !data.containsKey('userCart')) {
        return;
      }
      final leng = userDoc.get("userCart").length;
      for (int index = 0; index < leng; index++) {
        _cartItems.putIfAbsent(
          userDoc.get("userCart")[index]['productId'],
          () => CartModel(
              cartId: userDoc.get("userCart")[index]['cartId'],
              productId: userDoc.get("userCart")[index]['productId'],
              quantity: userDoc.get("userCart")[index]['quantity']),
        );
      }
    } catch (e) {
      rethrow;
    }
    notifyListeners();
  }

  //phương thức này chịu trách nhiệm xóa một mục khỏi giỏ hàng của người dùng trong Firestore sau đó cập nhật trạng thái cục bộ bằng cách xóa mục khỏi `_cartItems` map
  Future<void> removeCartItemFromFirestore({
    required String cartId,
    required String productId,
    required int qty,
  }) async {
    final User? user = _auth.currentUser;
    try {
      await userstDb.doc(user!.uid).update({
        'userCart': FieldValue.arrayRemove([
          {
            'cartId': cartId,
            'productId': productId,
            'quantity': qty,
          }
        ])
      });
      // await fetchCart();
      _cartItems.remove(productId);
      Fluttertoast.showToast(msg: "Item has been removed");
    } catch (e) {
      rethrow;
    }
  }

//phương thức clearCartFromFirebase, chịu trách nhiệm xóa tất cả các mục khỏi giỏ hàng của người dùng trong Firestore
  Future<void> clearCartFromFirebase() async {
    final User? user = _auth.currentUser;
    try {
      await userstDb.doc(user!.uid).update({
        'userCart': [],
      });
      // await fetchCart();
      _cartItems.clear();
      Fluttertoast.showToast(msg: "Cart has been cleared");
    } catch (e) {
      rethrow;
    }
  }

// Local
  //phương thức addProductToCart để thêm một mục vào giỏ hàng cục bộ
  void addProductToCart({required String productId}) {
    _cartItems.putIfAbsent(
      productId,
      () => CartModel(
          cartId: const Uuid().v4(), productId: productId, quantity: 1),
    );
    notifyListeners();
  }

  //phương thức updateQty để cập nhật số lượng của một mục trong giỏ hàng cục bộ
  void updateQty({required String productId, required int qty}) {
    _cartItems.update(
      productId,
      (cartItem) => CartModel(
        cartId: cartItem.cartId,
        productId: productId,
        quantity: qty,
      ),
    );
    notifyListeners();
  }

  //phương thức isProdinCart để kiểm tra xem một mục đã được thêm vào giỏ hàng cục bộ chưa
  bool isProdinCart({required String productId}) {
    return _cartItems.containsKey(productId);
  }

  //phương thức getTotal để tính tổng giá trị của tất cả các mục trong giỏ hàng cục bộ
  double getTotal({required ProductsProvider productsProvider}) {
    double total = 0.0;

    _cartItems.forEach((key, value) {
      final getCurrProduct = productsProvider.findByProdId(value.productId);
      if (getCurrProduct == null) {
        total += 0;
      } else {
        total += double.parse(getCurrProduct.productPrice) * value.quantity;
      }
    });
    return total;
  }

  //phương thức getQty để lấy tổng số lượng của tất cả các mục trong giỏ hàng cục bộ
  int getQty() {
    int total = 0;
    _cartItems.forEach((key, value) {
      total += value.quantity;
    });
    return total;
  }

  //phương thức clearLocalCart để xóa tất cả các mục khỏi giỏ hàng cục bộ
  void clearLocalCart() {
    _cartItems.clear();
    notifyListeners();
  }

  //phương thức removeOneItem để xóa một mục khỏi giỏ hàng cục b
  void removeOneItem({required String productId}) {
    _cartItems.remove(productId);
    notifyListeners();
  }
}
