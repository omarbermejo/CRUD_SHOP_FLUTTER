


import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnveriomentConfig {

  static initEnv() async{
    await dotenv.load(fileName: ".env");
  }

  static String apiUrl = dotenv.env['API_URL'] ?? 'No esta especificada en las variables de entorno';
  
  }