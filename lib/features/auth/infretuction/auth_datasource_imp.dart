

import 'package:dio/dio.dart';
import 'package:teslo_shop/config/const/env.dart';
import 'package:teslo_shop/features/auth/domain/data_source/auth_datasource.dart';
import 'package:teslo_shop/features/auth/domain/entitis/users.dart';

class AuthDatasourceImp extends AuthDataSource {


  /* Esta libreria manda a llamar a las peticiones http con una mayor seguridad. 
   * Esta pre-configurada con la clase o libreria ENV. que creemos para manejar las variables de entorno.
  */

  final dio = Dio(
    BaseOptions(
      baseUrl: EnveriomentConfig.apiUrl
    ),
  );


  /*
    Estas son las clases que van a recibir las peticones HTTP desde la api previamente creada.
    Estas van a retornar un Future de tipo Users que es la entidad creada para manejar los datos del usuario.
    Se crearan los objetos / metodos necesarios para manejar las respuestas de la API.
  
   */
  @override
  Future<Users> login(String email, String password) async{
    try {
      /* Se pide la peticion POST a la API con los datos de email y password, con la URL "/auth/login". 
      Estan van a devolver los objetos "email y password".
      */
      final response = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      // Se mapea la respuesta de la API a la entidad Users creada previamente. 
      final userMap = response.data as Map<String, dynamic>;
      final user = Users.fromMap(userMap);

      return user;
    } catch (e) {
      throw Exception('Error en la recoleccion de datos, mapeo incorrecto: $e');
    }
  
  }

  @override
  Future<Users> register(String email, String password, String fullName) async{
    try {
      /* Se pide la peticion POST a la API con los datos de email, password y fullName, con la URL "/auth/register". 
      Estan van a devolver los objetos "email, password y fullName".
      */
      final response = await dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'fullName': fullName,
      });

      // Se mapea la respuesta de la API a la entidad Users creada previamente. 
      final userMap = response.data as Map<String, dynamic>;
      final user = Users.fromMap(userMap);

      return user;
    } catch (e) {
      throw Exception('Error en la recoleccion de datos, mapeo incorrecto: $e');
    }
  }

  @override
  Future<Users> checkAuthStatus(String token) async {
    try {
      /* Se pide la peticion GET a la API con el token de autenticacion, con la URL "/auth/check-status". 
      Estan van a devolver el objeto "token".
      */
      final response = await dio.get('/auth/check-status', options: Options(
        headers: {
          'Authorization': 'Bearer $token'
        }
      ));

      // Se mapea la respuesta de la API a la entidad Users creada previamente. 
      final userMap = response.data as Map<String, dynamic>;
      final user = Users.fromMap(userMap);

      return user;
    } catch (e) {
      throw Exception('Error en la recoleccion de datos, mapeo incorrecto: $e');
    }
  }

  @override
  Future<Users> logout() {
    // Implementación del método de logout
    throw UnimplementedError();
  }
}


