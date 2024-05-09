import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:PicBlockChain/config/config.dart';

class IpfsService {
  Future<String> uploadToIpfs(File file) async {
    final url = Uri.parse('https://api.pinata.cloud/pinning/pinFileToIPFS');
    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('file', file.path))
      ..headers['pinata_api_key'] = Config.pinataApiKey
      ..headers['pinata_secret_api_key'] = Config.pinataSecretApiKey;

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);
      return jsonResponse['IpfsHash'];
    } else {
      throw Exception('Failed to upload file to IPFS: ${response.statusCode}');
    }
  }
}
