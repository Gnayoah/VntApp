import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:vnt_app/vnt/vnt_manager.dart';
import 'package:vnt_app/network_config.dart';
import 'package:vnt_app/src/rust/frb_generated.dart'; // RustLib 初始化

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init(); // 初始化 flutter_rust_bridge
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: VntHomePage(),
    );
  }
}

class VntHomePage extends StatefulWidget {
  const VntHomePage({super.key});

  @override
  State<VntHomePage> createState() => _VntHomePageState();
}

class _VntHomePageState extends State<VntHomePage> {
  final TextEditingController _controller = TextEditingController();
  String? _virtualIp;
  bool _loading = false;

  void _startNetworking() async {
    setState(() {
      _loading = true;
      _virtualIp = null;
    });

    final networkCode = _controller.text.trim();
    final config = NetworkConfig(
      itemKey: networkCode,
      configName: '默认配置',
      token: 'test-token',
      deviceID: 'device-id',
      deviceName: 'device-name',
      virtualIPv4: '',
      serverAddress: 'example.com:3000',
      stunServers: [],
      inIps: [],
      outIps: [],
      portMappings: [],
      groupPassword: '',
      isServerEncrypted: false,
      protocol: 'udp',
      dataFingerprintVerification: false,
      encryptionAlgorithm: 'aes_gcm',
      virtualNetworkCardName: '',
      mtu: 1400,
      ports: [],
      firstLatency: false,
      noInIpProxy: false,
      dns: ['8.8.8.8'],
      simulatedPacketLossRate: 0.0,
      simulatedLatency: 0,
      punchModel: 'ipv4',
      useChannelType: 'p2p', // ✅ 修正：合法值 relay/p2p/all
      compressor: 'none',
    );

    final receivePort = ReceivePort();
    final box = await vntManager.create(config, receivePort.sendPort);
    final info = box.currentDevice();

    setState(() {
      _virtualIp = info['virtualIp'];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('组网 Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: '输入组网编号',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _startNetworking,
              child: _loading ? const CircularProgressIndicator() : const Text('开始组网'),
            ),
            const SizedBox(height: 32),
            if (_virtualIp != null)
              Text('虚拟IP: $_virtualIp', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
