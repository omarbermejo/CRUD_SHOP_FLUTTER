import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnveriomentConfig {

  static Future<void> initEnv() async{
    try {
      await dotenv.load(fileName: ".env");
    } on FileSystemException catch (e) {
      // Archivo no encontrado o error de acceso
      if (e.osError?.errorCode == 2 || e.message.contains('No such file')) {
        throw Exception(
          'El archivo .env no existe.\n\n'
          'Solución:\n'
          '1. Crea un archivo .env en la raíz del proyecto\n'
          '2. Agrega la siguiente línea según tu caso:\n\n'
          '   Para Android Emulator:\n'
          '   API_URL=http://10.0.2.2:3000/api\n\n'
          '   Para dispositivo físico:\n'
          '   API_URL=http://TU_IP_LOCAL:3000/api\n'
          '   (Ejemplo: http://192.168.1.100:3000/api)\n\n'
          '   Para obtener tu IP local en Windows, ejecuta:\n'
          '   ipconfig y busca "IPv4"'
        );
      }
      throw Exception(
        'Error al acceder al archivo .env: ${e.message}\n'
        'Verifica los permisos del archivo.'
      );
    } catch (e) {
      throw Exception(
        'Error al cargar el archivo .env: $e\n\n'
        'Asegúrate de que:\n'
        '1. El archivo .env existe en la raíz del proyecto\n'
        '2. El archivo está incluido en pubspec.yaml (assets: - .env)\n'
        '3. El archivo contiene: API_URL=http://localhost:3000/api'
      );
    }
  }

  static String get apiUrl {
    // Verificar si dotenv está cargado
    if (dotenv.env.isEmpty) {
      throw Exception(
        'Las variables de entorno no están cargadas.\n'
        'Asegúrate de llamar EnveriomentConfig.initEnv() antes de usar apiUrl.'
      );
    }

    final url = dotenv.env['API_URL'];
    
    // Caso 1: Variable no existe o está vacía
    if (url == null || url.trim().isEmpty) {
      throw Exception(
        'La variable API_URL no está configurada en el archivo .env\n\n'
        'Solución:\n'
        'Agrega la siguiente línea a tu archivo .env según tu caso:\n\n'
        'Para Android Emulator:\n'
        'API_URL=http://10.0.2.2:3000/api\n\n'
        'Para dispositivo físico (tu caso):\n'
        'API_URL=http://TU_IP_LOCAL:3000/api\n'
        '(Ejemplo: http://192.168.1.100:3000/api)\n\n'
        'Para obtener tu IP local en Windows:\n'
        '1. Abre PowerShell o CMD\n'
        '2. Ejecuta: ipconfig\n'
        '3. Busca "Adaptador de LAN inalámbrica" o "Adaptador de Ethernet"\n'
        '4. Copia la dirección "IPv4" (ej: 192.168.1.100)\n'
        '5. Úsala en tu .env: API_URL=http://192.168.1.100:3000/api'
      );
    }

    final trimmedUrl = url.trim();

    // Caso 2: Validar formato básico (debe comenzar con http:// o https://)
    if (!trimmedUrl.startsWith('http://') && !trimmedUrl.startsWith('https://')) {
      throw Exception(
        'Formato de URL incorrecto\n\n'
        'La URL debe comenzar con http:// o https://\n'
        'Valor actual: "$trimmedUrl"\n\n'
        'Ejemplos correctos:\n'
        '   http://10.0.2.2:3000/api (Android Emulator)\n'
        '   http://192.168.1.100:3000/api (Dispositivo físico)\n'
        '   https://api.ejemplo.com'
      );
    }

    // Caso 3: Validar que tenga al menos un punto o localhost
    if (!trimmedUrl.contains('://') || 
        (trimmedUrl.split('://').length < 2 || trimmedUrl.split('://')[1].isEmpty)) {
      throw Exception(
        'URL mal formada\n\n'
        'La URL debe tener el formato: protocolo://host:puerto/ruta\n'
        'Valor actual: "$trimmedUrl"\n\n'
        'Ejemplos correctos:\n'
        '   http://10.0.2.2:3000/api (Android Emulator)\n'
        '   http://192.168.1.100:3000/api (Dispositivo físico)'
      );
    }

    // Validación adicional: verificar que no termine con /
    final cleanUrl = trimmedUrl.endsWith('/') 
        ? trimmedUrl.substring(0, trimmedUrl.length - 1) 
        : trimmedUrl;

    return cleanUrl;
  }
  
  }