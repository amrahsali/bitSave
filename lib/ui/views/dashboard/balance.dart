import 'package:flutter/material.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';

class Balance extends StatelessWidget {
  final Stream<GetInfoResponse> getInfoStream;

  const Balance({super.key, required this.getInfoStream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GetInfoResponse>(
      stream: getInfoStream,
      builder: (context, getInfoSnapshot) {
        if (getInfoSnapshot.hasError) {
          return Center(child: Text('Error: ${getInfoSnapshot.error}'));
        }

        if (!getInfoSnapshot.hasData) {
          return const Center(child: Text('Loading...'));
        }

        final getInfo = getInfoSnapshot.data!;
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "${getInfo.walletInfo.balanceSat} sats",
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.blue),
              ),
            ],
          ),
        );
      },
    );
  }
}