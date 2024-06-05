import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api_service.dart';
import '../../database/kazfintracker_database.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/budgets_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/statistics_provider.dart';
import '../../providers/transactions_provider.dart';

class LinkCardPage extends ConsumerStatefulWidget {
  const LinkCardPage({super.key});

  @override
  ConsumerState<LinkCardPage> createState() => _LinkCardPageState();
}

class _LinkCardPageState extends ConsumerState<LinkCardPage> {
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expirationDateController =
  TextEditingController();
  final TextEditingController securityCodeController = TextEditingController();
  final TextEditingController billingAddressController =
  TextEditingController();

  String cardType = '';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: ref.read(authenticationServiceProvider).isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == true) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text("Link a Card"),
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Image.asset('assets/card_icon.png', height: 100),
                      // Placeholder for card icon
                      const SizedBox(height: 30),
                      TextField(
                        controller: cardNumberController,
                        decoration: InputDecoration(
                          labelText: 'Debit or credit card number',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: cardType.isEmpty ? null : cardType,
                        decoration: InputDecoration(
                          labelText: 'Card type',
                          border: OutlineInputBorder(),
                        ),
                        items: <String>[
                          'Visa',
                          'MasterCard',
                          'American Express'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            cardType = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: expirationDateController,
                        decoration: const InputDecoration(
                          labelText: 'Expiration date',
                          hintText: 'MM/YY',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.datetime,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: securityCodeController,
                        decoration: const InputDecoration(
                          labelText: 'Security code',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: billingAddressController,
                        decoration: const InputDecoration(
                          labelText: 'Billing address',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          ApiService().linkCard({
                            'cardNumber': cardNumberController.text,
                            'cardType': cardType,
                            'expirationDate': expirationDateController.text,
                            'securityCode': securityCodeController.text,
                            'billingAddress': billingAddressController.text,
                          }).then((result) async {
                            await KazFinTrackerDatabase.instance.fillDemoData().then((value) {
                              // Assuming ref is accessible here as WidgetRef or from a Consumer widget
                              ref.refresh(accountsProvider);
                              ref.refresh(categoriesProvider);
                              ref.refresh(transactionsProvider);
                              ref.refresh(budgetsProvider);
                              ref.refresh(dashboardProvider);
                              ref.refresh(lastTransactionsProvider);
                              ref.refresh(statisticsProvider);
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text('Success'),
                                  content: Text(result),
                                  // 'Card linked successfully'
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(ctx)
                                            .pop(); // Close the dialog
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                ),
                              );                            });
                          }).catchError((error) {
                            // Handle errors, show user-friendly messages
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('Error'),
                                content: Text(error.toString()),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          });
                        },
                        child: Text('Link Card'),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Scaffold(
                appBar: AppBar(
                  title: const Text("Link a Card"),
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text("You must be registered to link your account."),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () =>
                                Navigator.of(context).pushNamed('/register'),
                            child: const Text('Register'),
                          ),
                          const SizedBox(width: 20),
                          TextButton(
                            onPressed: () =>
                                Navigator.of(context).pushNamed('/login'),
                            child: const Text('Login'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        });
  }
}
