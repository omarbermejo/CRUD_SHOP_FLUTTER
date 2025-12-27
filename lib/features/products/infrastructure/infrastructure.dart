/// Infrastructure Layer - Clean Architecture
/// Esta capa contiene:
/// - DataSources: Implementaciones concretas para obtener datos (API, DB, etc.)
/// - Repositories: Implementaciones de los repositorios del Domain
/// - Mappers: Transformaciones entre modelos de datos y entidades
library;

export 'datasources/products_remote_datasource.dart';
export 'repositories/repositories.dart';
