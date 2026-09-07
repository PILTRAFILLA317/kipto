import 'dart:io';

import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class BillingUnavailable implements Exception {
  const BillingUnavailable();
}

/// RevenueCat owns receipts and store UI. Only the backend grants paid usage.
class BillingRepository {
  BillingRepository({required this.owner});
  final String? Function() owner;
  Future<void> _tail = Future.value();
  String? _bound;
  String get _key => Platform.isIOS
      ? const String.fromEnvironment('REVENUECAT_IOS_PUBLIC_KEY')
      : Platform.isAndroid
      ? const String.fromEnvironment('REVENUECAT_ANDROID_PUBLIC_KEY')
      : '';
  bool get configured => _key.isNotEmpty;
  Future<T> _serial<T>(Future<T> Function() work) {
    final future = _tail.then((_) => work());
    _tail = future.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return future;
  }

  Future<String> _bind() async {
    final user = owner();
    if (!configured || user == null) throw const BillingUnavailable();
    if (!await Purchases.isConfigured) {
      await Purchases.setLogLevel(LogLevel.error);
      await Purchases.configure(PurchasesConfiguration(_key)..appUserID = user);
    } else if (_bound != user) {
      await Purchases.logIn(user);
    }
    if (owner() != user) throw const BillingUnavailable();
    _bound = user;
    return user;
  }

  Future<List<Package>> offerings() => _serial(() async {
    final user = await _bind();
    final offers = await Purchases.getOfferings();
    if (owner() != user) throw const BillingUnavailable();
    return offers.current?.availablePackages
            .where(
              (p) =>
                  p.packageType == PackageType.monthly ||
                  p.packageType == PackageType.annual,
            )
            .toList() ??
        [];
  });
  Future<String> purchase(Package package) => _serial(() async {
    final user = await _bind();
    try {
      await Purchases.purchase(PurchaseParams.package(package));
      if (owner() != user) throw const BillingUnavailable();
      return 'verificationPending';
    } on PlatformException catch (error) {
      final code = PurchasesErrorHelper.getErrorCode(error);
      if (code == PurchasesErrorCode.purchaseCancelledError) return 'cancelled';
      if (code == PurchasesErrorCode.paymentPendingError) {
        return 'paymentPending';
      }
      rethrow;
    }
  });
  Future<void> restore() => _serial(() async {
    final user = await _bind();
    await Purchases.restorePurchases();
    if (owner() != user) throw const BillingUnavailable();
  });
  Future<String?> managementUrl() => _serial(() async {
    final user = await _bind();
    final info = await Purchases.getCustomerInfo();
    if (owner() != user) throw const BillingUnavailable();
    return info.managementURL;
  });
  Future<void> detach() => _serial(() async {
    if (configured && await Purchases.isConfigured && _bound != null) {
      await Purchases.logOut();
    }
    _bound = null;
  });
}
