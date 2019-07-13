import 'dart:io';

var port = 3456;

main() async {
  print('HTTP_PROXY: ${Platform.environment['HTTP_PROXY']}');
  print('NO_PROXY: ${Platform.environment['NO_PROXY']}');
  print('');

  await test('ws://echo.websocket.org');
  await test('wss://echo.websocket.org');

  await Future.forEach(['localhost', '127.0.0.1'], (String address) async {
    final server = await startLocalServer(address, ++port);
    await test('ws://$address:$port');
    await server.close();
  });

  print('Completed!');
}

Future<HttpServer> startLocalServer(String address, int port) async {
  final server = await HttpServer.bind(address, port);
  print('Server listening at ${server.address.address}:$port');
  server.transform(WebSocketTransformer()).listen((WebSocket client) {
    client.listen((data) => client.add(data));
  });
  return server;
}

Future<void> test(String url) async {
  print('Connecting to $url');
  final ws = await WebSocket.connect(url);
  send(ws, 'TEST STRING');
  await receive(ws, 'TEST STRING');
  await ws.close();
  print('');
}

void send(WebSocket ws, String s) {
  print('SEND: $s');
  ws.add(s);
}

Future<void> receive(WebSocket ws, String s) async {
  final msg = await ws.first.timeout(const Duration(seconds: 1));
  print('RCV: $msg');
  if (msg != s) {
    throw 'Expected "$s" but got "$msg"';
  }
}
