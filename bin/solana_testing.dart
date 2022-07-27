import 'dart:convert';

import 'package:jupiter_aggregator/jupiter_aggregator.dart';
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';

void main(List<String> arguments) async {
  const seedPhrase = 'Enter you seed phrase';

  final client = JupiterAggregatorClient();

  final _solanaClient = SolanaClient(
    rpcUrl: Uri.parse('https://api.mainnet-beta.solana.com'),
    websocketUrl: Uri.parse('ws://api.mainnet-beta.solana.com'),
  );

  /// Convert WSOL to USDC
  final result = await client.getQuote(
    inputMint: 'So11111111111111111111111111111111111111112',
    outputMint: 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
    amount: 10000000,
  );

  final swap = await client.getSwapTransactions(
    userPublicKey: 'G4AogvmdJzhdhpASLEADtTAd2F3WHBnreorD9sD1pyKA',
    route: result.first,
  );

  final decoded = base64Decode(swap.swapTransaction);
  final byteArray = ByteArray(decoded);
  final compiled = CompiledMessage.fromSignedTransaction(byteArray);

  /// Below code to be executed if we have multiple transactions to sign to complete swap

  // final message = Message.decompile(compiled);
  // final recent = await _solanaClient.rpcClient.getRecentBlockhash();
  // final recompiled = message.compile(recentBlockhash: recent.blockhash);

  final wallet = await Ed25519HDKeyPair.fromMnemonic(seedPhrase, account: 0);

  final signedTx = SignedTx(
    messageBytes: compiled.data,
    signatures: [await wallet.sign(compiled.data)],
  );

  final transaction = signedTx.encode();

  final txHash = await _solanaClient.rpcClient.sendTransaction(
    transaction,
    preflightCommitment: Commitment.confirmed,
  );

  print(txHash);

  /// 5kCGUqLtisWiTLZqxdQNdpYAhXvaaGxa6eu4D29aRib9BK65iMSdgo6goY27SRpLRsAy98CywgumocLH8RbMWvze
}
