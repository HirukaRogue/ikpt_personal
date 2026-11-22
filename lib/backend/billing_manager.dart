import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/foundation.dart';
import 'hearts.dart';

class BillingManager {
  static final BillingManager _instance = BillingManager._internal();
  factory BillingManager() => _instance;
  BillingManager._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // ID do produto no Google Play Console
  static const String unlimitedHeartsId = 'unlimited_hearts_01';

  List<ProductDetails> _products = [];
  bool _available = false;
  bool _isUnlimitedPurchased = false;
  bool _isInitialized = false;

  bool get isUnlimitedPurchased => _isUnlimitedPurchased;

  // Inicializa a conexão com a loja
  void initialize() {
    if (_isInitialized) return;
    
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      debugPrint("Erro no stream de compras: $error");
    });

    _initStoreInfo();
    _isInitialized = true;
  }

  Future<void> _initStoreInfo() async {
    _available = await _iap.isAvailable();
    if (!_available) return;

    const Set<String> ids = {unlimitedHeartsId};
    final ProductDetailsResponse response = await _iap.queryProductDetails(ids);

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint("IDs não encontrados: ${response.notFoundIDs}");
    }
    _products = response.productDetails;

    // Tenta restaurar compras ao iniciar
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint("Erro ao restaurar compras: $e");
    }
  }

  Future<bool> checkUnlimitedStatus() async {
    if (_isUnlimitedPurchased) return true;
    // Em uma implementação real, poderíamos verificar se o status foi validado recentemente
    return _isUnlimitedPurchased;
  }

  Future<void> buyUnlimited() async {
    if (_products.isEmpty) {
      debugPrint("Produto não carregado da loja.");
      return;
    }

    final ProductDetails productDetails = _products.firstWhere((p) => p.id == unlimitedHeartsId);
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);

    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Aguardando
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint("Erro na compra: ${purchaseDetails.error}");
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          
          _isUnlimitedPurchased = true;
          _deliverProduct(purchaseDetails);
        }

        if (purchaseDetails.pendingCompletePurchase) {
          _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  void _deliverProduct(PurchaseDetails purchaseDetails) {
    if (purchaseDetails.productID == unlimitedHeartsId) {
      // ATIVA OS CORAÇÕES INFINITOS NO SINGLETON
      Hearts().setUnlimited(true);
      debugPrint("Corações Infinitos confirmados e ativados!");
    }
  }

  void dispose() {
    _subscription.cancel();
  }
}