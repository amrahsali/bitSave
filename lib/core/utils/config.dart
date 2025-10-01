import 'package:flutter/material.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:path_provider/path_provider.dart';

Future<Config> getConfig({
  LiquidNetwork network = LiquidNetwork.mainnet,
  String? breezApiKey,
}) async {
  debugPrint("Getting default SDK config for network: $network");
  final defaultConf = defaultConfig(network: network, breezApiKey: breezApiKey);
  debugPrint("Getting SDK config");
  final workingDir = await getApplicationDocumentsDirectory();
  return defaultConf.copyWith(
    workingDir: workingDir.path,
  );
}

extension ConfigCopyWith on Config {
  Config copyWith({
    BlockchainExplorer? liquidExplorer,
    BlockchainExplorer? bitcoinExplorer,
    String? workingDir,
    LiquidNetwork? network,
    BigInt? paymentTimeoutSec,
    int? zeroConfMinFeeRateMsat,
    BigInt? zeroConfMaxAmountSat,
    String? breezApiKey,
    List<ExternalInputParser>? externalInputParsers,
    String? syncServiceUrl,
    List<AssetMetadata>? assetMetadata,
    String? sideswapApiKey,
  }) {
    return Config(
      liquidExplorer: liquidExplorer ?? this.liquidExplorer,
      bitcoinExplorer: bitcoinExplorer ?? this.bitcoinExplorer,
      workingDir: workingDir ?? this.workingDir,
      network: network ?? this.network,
      paymentTimeoutSec: paymentTimeoutSec ?? this.paymentTimeoutSec,
      zeroConfMaxAmountSat: zeroConfMaxAmountSat ?? this.zeroConfMaxAmountSat,
      breezApiKey: breezApiKey ?? this.breezApiKey,
      externalInputParsers: externalInputParsers ?? this.externalInputParsers,
      syncServiceUrl: syncServiceUrl ?? this.syncServiceUrl,
      useDefaultExternalInputParsers: true,
      assetMetadata: assetMetadata ?? this.assetMetadata,
      sideswapApiKey: sideswapApiKey ?? this.sideswapApiKey,
    );
  }
}

/// Utility class for currency conversions between Naira, Bitcoin, and Satoshis
class CurrencyConverter {
  /// Convert Naira to Satoshis
  static double nairaToSats(double nairaAmount, double nairaPerBtcRate) {
    // 1 BTC = 100,000,000 sats
    const satsPerBtc = 100000000.0;
    final btcAmount = nairaAmount / nairaPerBtcRate;
    return btcAmount * satsPerBtc;
  }

  /// Convert Bitcoin to Satoshis
  static double bitcoinToSats(double btcAmount) {
    return btcAmount * 100000000.0;
  }

  /// Convert Satoshis to Bitcoin
  static double satsToBitcoin(double satsAmount) {
    return satsAmount / 100000000.0;
  }

  /// Convert Satoshis to Naira
  static double satsToNaira(double satsAmount, double nairaPerBtcRate) {
    final btcAmount = satsToBitcoin(satsAmount);
    return btcAmount * nairaPerBtcRate;
  }
}