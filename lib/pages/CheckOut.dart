import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
    debugShowCheckedModeBanner: false, home: OrderPlacedApp()));

class OrderPlacedApp extends StatefulWidget {
  const OrderPlacedApp({super.key});

  @override
  State<OrderPlacedApp> createState() => _OrderPlacedAppState();
}

class _OrderPlacedAppState extends State<OrderPlacedApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Order Placed Successfully',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const OrderPlacedScreen(),
    );
  }
}

class OrderPlacedScreen extends StatefulWidget {
  const OrderPlacedScreen({super.key});

  @override
  State<OrderPlacedScreen> createState() => _OrderPlacedScreenState();
}

class _OrderPlacedScreenState extends State<OrderPlacedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[100], // Cyan 100 background
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
              ),
            ],
            borderRadius: BorderRadius.circular(12),
            color: Colors.cyan[100], // White background for details box
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 55,
                            height: 55,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF17A948), // Green background
                            ),
                          ),
                          const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'Order placed successfully!',
                      style: TextStyle(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Commodo eu ut sunt qui minim fugiat elit nisi enim',
                      style: TextStyle(fontSize: 16, color: Color(0xFF888888)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const DetailsWidget(),
              const ExperienceWidget(),
              const BackToHomeWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailsWidget extends StatefulWidget {
  const DetailsWidget({super.key});

  @override
  State<DetailsWidget> createState() => _DetailsWidgetState();
}

class _DetailsWidgetState extends State<DetailsWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white, // White background for details box
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: const Column(
        children: [
          DetailsItem(title: 'Subtotal:', value: '\$2,800'),
          DetailsItem(title: 'Tax (10%):', value: '\$280'),
          DetailsItem(title: 'Fees:', value: '\$0'),
          DetailsItem(title: 'Total:', value: '\$3,080', success: true),
        ],
      ),
    );
  }
}

class DetailsItem extends StatefulWidget {
  final String title;
  final String value;
  final bool success;

  const DetailsItem(
      {super.key,
      required this.title,
      required this.value,
      this.success = false});

  @override
  State<DetailsItem> createState() => _DetailsItemState();
}

class _DetailsItemState extends State<DetailsItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          widget.value,
          style: TextStyle(color: widget.success ? Colors.green : null),
        ),
      ],
    );
  }
}

class ExperienceWidget extends StatefulWidget {
  const ExperienceWidget({super.key});

  @override
  State<ExperienceWidget> createState() => _ExperienceWidgetState();
}

class _ExperienceWidgetState extends State<ExperienceWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: const Column(
        children: [
          Text(
            'How was your experience?',
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.orange, size: 24),
              Icon(Icons.star, color: Colors.orange, size: 24),
              Icon(Icons.star, color: Colors.orange, size: 24),
              Icon(Icons.star, color: Colors.orange, size: 24),
              Icon(Icons.star, color: Colors.orange, size: 24),
            ],
          ),
        ],
      ),
    );
  }
}

class BackToHomeWidget extends StatefulWidget {
  const BackToHomeWidget({super.key});

  @override
  State<BackToHomeWidget> createState() => _BackToHomeWidgetState();
}

class _BackToHomeWidgetState extends State<BackToHomeWidget> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        // Handle button press action: navigate to home, etc.
        Navigator.pushNamed(
            context, 'PaymentUnsuccesful'); // Example navigation code
      },
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xFF3EBDE0), // Blue background
        padding: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home, color: Colors.white),
          SizedBox(width: 5),
          Text(
            'Back to Home',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
