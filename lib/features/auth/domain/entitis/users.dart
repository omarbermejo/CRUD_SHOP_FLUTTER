

class Users {
  final String id;
  final String email;
  final String fullName;
  final List<String> roles;
  final String token;
  Users({
    required this.id,
    required this.email,
    required this.fullName,
    required this.roles,
    required this.token,
  });

  // Al momento de crear el Usuario verificamos si es admin
   bool get isAdmin => roles.contains('admin');
  
  /* Aqui una vez con acceso a la API, mapeamos los datos recibidos a la entidad Users. Para la recoleccion y el retornos de estos parametros. 
    *  ID
    *  EMAIL
    *  FULL NAME
    *  ROLES
    *  TOKEN
  // */
  factory Users.fromMap(Map<String, dynamic> map) {
    return Users(
      id: map['id'].toString(),
      fullName: map['fullName']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      roles: List<String>.from(map['roles'] ?? []),
      token: map['token']?.toString() ?? '',    
    );
  }
}
