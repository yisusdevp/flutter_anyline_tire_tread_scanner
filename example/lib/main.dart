import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_anyline_tire_tread_scanner/flutter_anyline_tire_tread_scanner.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Material App',
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
  }

  @override
  Widget build(BuildContext context) {
    AnylineTireTreadScanner.onScanningEvent.listen((event) {
      if (event is ScanningAborted) {
        debugPrint(event.uuid);
      } else if (event is UploadAbortedEvent) {
        debugPrint(event.uuid);
      } else if (event is UploadCompletedEvent) {
        debugPrint(event.uuid);
      } else if (event is UploadFailedEvent) {
        debugPrint(event.error);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Material App Bar'),
      ),
      body: Center(
        child: Column(
          children: [
            MaterialButton(
              onPressed: () {
                AnylineTireTreadScanner.setup(
                  licenseKey: "{YOUR_LICENSE_KEY}",
                );
              },
              child: const Text("Setup"),
            ),
            const SizedBox(
              height: 20,
            ),
            MaterialButton(
              onPressed: () {
                AnylineTireTreadScanner.open();
              },
              child: const Text("Open"),
            ),
          ],
        ),
      ),
    );
  }
}
