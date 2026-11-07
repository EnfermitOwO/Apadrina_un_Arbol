// import 'package:mongo_dart/mongo_dart.dart';

// class MongoService {
//   static Db? _db;

//   // Tu URI de conexión configurada con ssl y replicaSet
// static const String _dbUri =
//       "mongodb://equipo_arbol:losmastroncos01@ac-gkug9uo-shard-00-00.kx2umeq.mongodb.net:27017,ac-gkug9uo-shard-00-01.kx2umeq.mongodb.net:27017,ac-gkug9uo-shard-00-02.kx2umeq.mongodb.net:27017/ArbolBD?ssl=true&replicaSet=atlas-1063je-shard-0&authSource=admin";

//   /// Abre la conexión global a MongoDB Atlas
//   static Future<void> connect() async {
//     if (_db != null && _db!.isConnected) return;

//     try {
//       _db = await Db.create(_dbUri);
//       await _db!.open();
//       print(">>> Conexión exitosa a MongoDB Atlas <<<");
//     } catch (e) {
//       print(">>> Error de conexión a MongoDB: $e <<<");
//       rethrow;
//     }
//   }

//   /// Retorna una colección de tu base de datos
//   static DbCollection getCollection(String collectionName) {
//     if (_db == null || !_db!.isConnected) {
//       throw Exception("La base de datos no está conectada. Ejecuta MongoService.connect() primero.");
//     }
//     return _db!.collection(collectionName);
//   }

//   /// Cierra la conexión si es necesario
//   static Future<void> close() async {
//     await _db?.close();
//   }
// } 


import 'package:mongo_dart/mongo_dart.dart';

class MongoService {
  static Db? _db;

  // URI de conexión a MongoDB Atlas
  static const String _dbUri = "mongodb://equipo_arbol:losmastroncos01@ac-gkug9uo-shard-00-00.kx2umeq.mongodb.net:27017,ac-gkug9uo-shard-00-01.kx2umeq.mongodb.net:27017,ac-gkug9uo-shard-00-02.kx2umeq.mongodb.net:27017/ArbolBD?ssl=true&replicaSet=atlas-1063je-shard-0&authSource=admin";


  /// Abre o recupera la conexión global a MongoDB Atlas
  static Future<void> connect() async {
    if (_db != null && _db!.isConnected) {
      return;
    }

    try {
      // Cierra una conexión anterior si existe
      if (_db != null) {
        try {
          await _db!.close();
        } catch (_) {}
      }

      // Crea una nueva conexión
      _db = await Db.create(_dbUri);
      await _db!.open();

      print(">>> Conexión exitosa a MongoDB Atlas <<<");
    } catch (e) {
      print(">>> Error de conexión a MongoDB: $e <<<");
      _db = null;
      rethrow;
    }
  }

  /// Retorna una colección de la base de datos
  static DbCollection getCollection(String collectionName) {
    if (_db == null || !_db!.isConnected) {
      throw Exception(
        "La base de datos no está conectada. "
        "Ejecuta MongoService.connect() primero.",
      );
    }

    return _db!.collection(collectionName);
  }

  /// Cierra la conexión si es necesario
  static Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
