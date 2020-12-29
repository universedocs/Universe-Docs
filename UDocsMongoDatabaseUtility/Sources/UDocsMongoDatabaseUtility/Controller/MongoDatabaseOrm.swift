//
//  File.swift
//  
//
//  Created by Kumar Muthaiah on 06/06/20.
//

import Foundation
import MongoSwiftSync
import UDocsUtility
import UDocsDatabaseModel
import UDocsDatabaseUtility

public class MongoDatabaseOrm : DatabaseOrm {
    var client: MongoClient?
    var database: MongoDatabase?
    var objectName: String = "MongoDatabaseOrm"
    //    let udbcDatabaseOrm: UDBCDatabaseOrm?
    var clientSession: ClientSession?
    
    public init() {
    }
    
    static public func getName() -> String {
        return "MongoDatabaseOrm"
    }
    
    public func generateId() -> String {
        return BSONObjectID().hex
    }
    
    public func connect(userName: String, password: String, host: String, port: Int, databaseName: String) -> DatabaseOrmResult<String> {
        //        udbcDatabaseOrm.ormObject = self
        //        udbcDatabaseOrm.type = UDBCDatabaseType.MongoDatabase.description()
        var databaseOrmResult: DatabaseOrmResult = DatabaseOrmResult<String>()
        do {
            // initialize global state
            if userName.isEmpty {
                client = try MongoClient("mongodb://\(host):\(port)/\(databaseName)")
            } else {
                client = try MongoClient("mongodb://\(userName):\(password)@\(host):\(port)/\(databaseName)")
            }
            database = client!.db(databaseName)
            databaseOrmResult = startTransaction(options: [["readConcern": "majority", "writeConcern": "majority", "readPreference": "primary", "maxCommitTimeMS": 30], [ "readConcern": "majority", "writeConcern": "majority", "readPreference": "primary", "maxCommitTimeMS": 30]])
        } catch {
            let databaseOrmError = DatabaseOrmError()
            databaseOrmError.name = DatabaseOrmError.ConnectionFailure.name
            databaseOrmError.description = "\(DatabaseOrmError.ConnectionFailure.description): \(error.localizedDescription)"
            databaseOrmResult.databaseOrmError.append(databaseOrmError)
        }
        
        return databaseOrmResult
    }
    
    private func getReadConcern(concern: String) -> ReadConcern? {
        switch concern {
        case "snapshot":
            return .snapshot
        case "majority":
            return .majority
        default:
            return nil
        }
    }
    
    private func getWriteConcern(concern: String) throws -> WriteConcern? {
        switch concern {
        case "majority":
            return .majority
        default:
            return nil
        }
    }
    
    private func getReadPreference(preference: String) -> ReadPreference? {
        switch preference {
        case "primary":
            return .primary
        default:
            return nil
        }
    }
    
    public func startTransaction(options: [[String: Any]]) -> DatabaseOrmResult<String> {
        let databaseOrmResult = DatabaseOrmResult<String>()
        do {
            let transactionOptionsStartSession = TransactionOptions(
                maxCommitTimeMS: (options[0]["maxCommitTimeMS"] as! Int),
                readConcern: getReadConcern(concern: options[0]["readConcern"] as! String),
                readPreference: getReadPreference(preference: options[0]["readPreference"] as! String),
                writeConcern: try getWriteConcern(concern: options[0]["writeConcern"] as! String)
            )
            clientSession = client?.startSession(options: ClientSessionOptions(defaultTransactionOptions: transactionOptionsStartSession))

            let transactionOptions = TransactionOptions(
                maxCommitTimeMS: (options[1]["maxCommitTimeMS"] as! Int),
                readConcern: getReadConcern(concern: options[1]["readConcern"] as! String),
                readPreference: getReadPreference(preference: options[1]["readPreference"] as! String),
                writeConcern: try getWriteConcern(concern: options[1]["writeConcern"] as! String)
            )
            
            try clientSession!.startTransaction(options: transactionOptions)
        } catch {
            let databaseOrmError = DatabaseOrmError()
            databaseOrmError.name = "DatabaseOrmError.StartTransactionFailure"
            databaseOrmError.description = "Start transaction failure: \(error.localizedDescription)"
            databaseOrmResult.databaseOrmError.append(databaseOrmError)
        }
        
        return databaseOrmResult
    }
    
    public func commitTransaction() -> DatabaseOrmResult<String> {
        let databaseOrmResult = DatabaseOrmResult<String>()
        do {
            try clientSession!.commitTransaction()
        } catch {
            let databaseOrmError = DatabaseOrmError()
            databaseOrmError.name = "DatabaseOrmError.StartTransactionFailure"
            databaseOrmError.description = "Start transaction failure: \(error.localizedDescription)"
            databaseOrmResult.databaseOrmError.append(databaseOrmError)
        }
        
        return databaseOrmResult
    }
    
    public func abortTransaction() -> DatabaseOrmResult<String> {
        let databaseOrmResult = DatabaseOrmResult<String>()
        do {
            try clientSession!.abortTransaction()
        } catch {
            let databaseOrmError = DatabaseOrmError()
            databaseOrmError.name = "DatabaseOrmError.StartTransactionFailure"
            databaseOrmError.description = "Start transaction failure: \(error.localizedDescription)"
            databaseOrmResult.databaseOrmError.append(databaseOrmError)
        }
        
        return databaseOrmResult
    }
    
    public func disconnect() -> DatabaseOrmResult<String> {
        let databaseOrmResult = DatabaseOrmResult<String>()
        
        // Close connection
        //        do {
        //            /*let result =*/ try client!
        //            result.whenSuccess { success in
        // Free all resources
        cleanupMongoSwift()
        //                try? self.eventLoopGroup!.syncShutdownGracefully()
        //            }
        //
        //            result.whenFailure { error in
        //                let databaseOrmError = DatabaseOrmError()
        //                databaseOrmError.name = DatabaseOrmError.DisconnectionFailure.name
        //                databaseOrmError.description = "\(DatabaseOrmError.DisconnectionFailure.description): \(error)"
        //                databaseOrmResult.databaseOrmError.append(databaseOrmError)
        //            }
        //        } catch {
        //            let databaseOrmError = DatabaseOrmError()
        //            databaseOrmError.name = DatabaseOrmError.DisconnectionFailure.name
        //            databaseOrmError.description = "\(DatabaseOrmError.DisconnectionFailure.description): \(error)"
        //            databaseOrmResult.databaseOrmError.append(databaseOrmError)
        //        }
        
        return databaseOrmResult
    }
    
    public func getCollectionsNames() -> DatabaseOrmResult<String> {
        let databaseOrmResult: DatabaseOrmResult = DatabaseOrmResult<String>()
               
        do {
            
            
            let result = try database?.listCollections()
            var doc = result!.next()
            while doc != nil {
                databaseOrmResult.object.append(try doc!.get().name)
                doc = result!.next()
            }
            
            if databaseOrmResult.object.count == 0 {
                let databaseOrmError = DatabaseOrmError()
                databaseOrmError.name = DatabaseOrmError.NoRecords.name
                databaseOrmError.description = "\(DatabaseOrmError.NoRecords.description)"
                databaseOrmResult.databaseOrmError.append(databaseOrmError)
                return databaseOrmResult
            }
        } catch {
            
            let databaseOrmError = DatabaseOrmError()
            databaseOrmError.name = DatabaseOrmError.FailedToFindRecords.name
            databaseOrmError.description = "\(DatabaseOrmError.FailedToFindRecords.description): \(error.localizedDescription)"
            databaseOrmResult.databaseOrmError.append(databaseOrmError)
        }
        
        return databaseOrmResult
    }
    
    public func dropCollection(collectionName: String) -> DatabaseOrmResult<Bool> {
        let databaseOrmResult: DatabaseOrmResult = DatabaseOrmResult<Bool>()
        databaseOrmResult.object.append(false)
        
        do {
            let collectionObject = try database?.collection(collectionName)
            try collectionObject!.drop()
            databaseOrmResult.object[0] = true
        } catch {
            let databaseOrmError = DatabaseOrmError()
            databaseOrmError.name = DatabaseOrmError.FailedToFindRecords.name
            databaseOrmError.description = "\(DatabaseOrmError.FailedToFindRecords.description): \(error.localizedDescription)"
            databaseOrmResult.databaseOrmError.append(databaseOrmError)
        }
        
        return databaseOrmResult
    }
    
    
    public func save<T : Codable>(collectionName: String, object: T) -> DatabaseOrmResult<T> {
        let databaseOrmResult: DatabaseOrmResult = DatabaseOrmResult<T>()
        
        let collectionObject = database?.collection(collectionName, withType: T.self)
        
        do {
            let inserteOneResult = try collectionObject!.insertOne(object, session: clientSession!)
            
            databaseOrmResult.id = inserteOneResult!.insertedID.stringValue!
        } catch {
            abortTransaction()
            let databaseOrmError = DatabaseOrmError()
            databaseOrmError.name = DatabaseOrmError.FailedToFindRecords.name
            databaseOrmError.description = "\(DatabaseOrmError.FailedToFindRecords.description): \(collectionName): \(error.localizedDescription)"
            databaseOrmResult.databaseOrmError.append(databaseOrmError)
        }
        
        return databaseOrmResult
    }
    
    public func getDocument(dictionary: [String: Any]) -> BSONDocument {
        var document = BSONDocument()
        for dict in dictionary {
            if dict.value is Int {
                document[dict.key] = BSON.init(dict.value as! Int)
            } else if dict.value is String {
                document[dict.key] = BSON.string(dict.value as! String)
            } else if dict.value is [String] {
                let arr = dict.value as! [String]
                var bsonArray = [BSON]()
                for a in arr {
                    bsonArray.append(BSON.string(a))
                }
                document[dict.key] = BSON.array(bsonArray)
            } else if dict.value is Date {
                document[dict.key] = BSON.datetime(dict.value as! Date)
            } else if dict.value is NSRegularExpression {
                document[dict.key] = BSON.regex(BSONRegularExpression(from: dict.value as! NSRegularExpression))
            } else if dict.value is Bool {
                document[dict.key] = BSON.bool(dict.value as! Bool)
            } else if dict.value is [String: Any] {
                document[dict.key] = BSON.document(getDocument(dictionary: dict.value as! [String: Any]))
            } else if dict.value is [[String: Any]] {
                let dictionaries = dict.value as! [[String: Any]]
                var documentArray = [BSON]()
                for d in dictionaries {
                    documentArray.append(BSON.document(getDocument(dictionary: d)))
                }
                document[dict.key] = BSON.array(documentArray)
            }
        }
        
        print("Document desc: \(document.description))")
        return document
    }
    
    public func isCollectionFound(collectionName: String) -> DatabaseOrmResult<Bool> {
        let databaseOrmResult: DatabaseOrmResult = DatabaseOrmResult<Bool>()
        databaseOrmResult.object.append(false)
        do {
            let result = database!.collection(collectionName)
            databaseOrmResult.rowsAffected = try result.countDocuments()
            databaseOrmResult.object[0] = true
        } catch {
           let databaseOrmError = DatabaseOrmError()
            databaseOrmError.name = DatabaseOrmError.FailedToCreateCollection.name
            databaseOrmError.description = "\(DatabaseOrmError.FailedToCreateCollection.description): \(collectionName): \(error.localizedDescription)"
            databaseOrmResult.databaseOrmError.append(databaseOrmError)
        }
        
        return databaseOrmResult
    }
    
    public func createCollection(collectionName: String) -> DatabaseOrmResult<Bool> {
        let databaseOrmResult: DatabaseOrmResult = DatabaseOrmResult<Bool>()
        databaseOrmResult.object.append(false)
        
        do {
            let result = try database!.createCollection(collectionName)
            databaseOrmResult.rowsAffected = try result.countDocuments()
            databaseOrmResult.object[0] = true
        } catch {
           let databaseOrmError = DatabaseOrmError()
            databaseOrmError.name = DatabaseOrmError.FailedToCreateCollection.name
            databaseOrmError.description = "\(DatabaseOrmError.FailedToCreateCollection.description): \(collectionName): \(error.localizedDescription)"
            databaseOrmResult.databaseOrmError.append(databaseOrmError)
        }
        
        return databaseOrmResult
    }
    
    public func find<T: Codable>(collectionName: String, dictionary: [String: Any], limitedTo: Int?, sortOrder: String)  -> DatabaseOrmResult<T> {
        let databaseOrmResult: DatabaseOrmResult = DatabaseOrmResult<T>()
        
        let collectionObject = database?.collection(collectionName, withType: T.self)
        var findOptions: FindOptions?
        if limitedTo! > 0 {
            findOptions = FindOptions(limit: Int(limitedTo!))
        }
        var so: Int = 1
        if sortOrder == UDBCSortOrder.Descending.name {
            so = -1
        }
        findOptions = FindOptions(limit: Int(limitedTo!), sort: ["_id": BSON.init(so)] as BSONDocument)
        
        do {
            let result = try collectionObject!.find(getDocument(dictionary: dictionary), options: findOptions, session: clientSession!)
            
            var doc = result.next()
            while doc != nil {
                databaseOrmResult.object.append(try doc!.get())
                doc = result.next()
            }
            
            if databaseOrmResult.object.count == 0 {
                let databaseOrmError = DatabaseOrmError()
                databaseOrmError.name = DatabaseOrmError.NoRecords.name
                databaseOrmError.description = "\(DatabaseOrmError.NoRecords.description): \(collectionName)"
                databaseOrmResult.databaseOrmError.append(databaseOrmError)
                return databaseOrmResult
            }
            commitTransaction()
        } catch {
            abortTransaction()
            let databaseOrmError = DatabaseOrmError()
            databaseOrmError.name = DatabaseOrmError.FailedToFindRecords.name
            databaseOrmError.description = "\(DatabaseOrmError.FailedToFindRecords.description): \(collectionName): \(error.localizedDescription)"
            databaseOrmResult.databaseOrmError.append(databaseOrmError)
        }
        
        return databaseOrmResult
    }
    
    public func find<T: Codable>(collectionName: String, dictionary: [String: Any], limitedTo: Int?, sortOrder: String, sortedBy: String) -> DatabaseOrmResult<T> {
        let databaseOrmResult: DatabaseOrmResult = DatabaseOrmResult<T>()
        
        let collectionObject = database?.collection(collectionName, withType: T.self)
        var findOptions: FindOptions?
        if limitedTo! > 0 {
            findOptions = FindOptions(limit: Int(limitedTo!))
        }
        var so = 1
        if sortOrder == UDBCSortOrder.Descending.name {
            so = -1
        }
        
        if limitedTo! > 0 {
            findOptions = FindOptions(limit: Int(limitedTo!), sort: [sortedBy: BSON.init(so)])
        } else {
            findOptions = FindOptions(sort: [sortedBy: BSON.init(so)])
        }
        
        do {
            let result = try collectionObject!.find(getDocument(dictionary: dictionary), options: findOptions, session: clientSession!)
            
            var doc = result.next()
            while doc != nil {
                databaseOrmResult.object.append(try doc!.get())
                doc = result.next()
            }
            
            if databaseOrmResult.object.count == 0 {
                let databaseOrmError = DatabaseOrmError()
                databaseOrmError.name = DatabaseOrmError.NoRecords.name
                databaseOrmError.description = "\(DatabaseOrmError.NoRecords.description): \(collectionName)"
                databaseOrmResult.databaseOrmError.append(databaseOrmError)
                return databaseOrmResult
            }
            commitTransaction()
        } catch {
            abortTransaction()
            let databaseOrmError = DatabaseOrmError()
            databaseOrmError.name = DatabaseOrmError.FailedToFindRecords.name
            databaseOrmError.description = "\(DatabaseOrmError.FailedToFindRecords.description): \(collectionName): \(error.localizedDescription)"
            databaseOrmResult.databaseOrmError.append(databaseOrmError)
        }
        
        return databaseOrmResult
    }
    
    public func find<T: Codable>(collectionName: String, dictionary: [String: Any], projection: [String]?, limitedTo: Int?, sortOrder: String, sortedBy: String) -> DatabaseOrmResult<T> {
        let databaseOrmResult: DatabaseOrmResult = DatabaseOrmResult<T>()
        
        let collectionObject = database?.collection(collectionName, withType: T.self)
        var findOptions: FindOptions?
        if limitedTo! > 0 {
            findOptions = FindOptions(limit: Int(limitedTo!))
        }
        var so = 1
        if sortOrder == UDBCSortOrder.Descending.name {
            so = -1
        }
        var proj = BSONDocument()
        for item in projection! {
            proj[item] = 1
        }
        if limitedTo! > 0 {
            if projection != nil {
                findOptions = FindOptions(limit: Int(limitedTo!), projection: proj, sort: [sortedBy: BSON.init(so)])
            } else {
                findOptions = FindOptions(limit: Int(limitedTo!), sort: [sortedBy: BSON.init(so)])
            }
        } else {
            if projection != nil {
                findOptions = FindOptions(projection: proj, sort: [sortedBy: BSON.init(so)])
            } else {
                findOptions = FindOptions(sort: [sortedBy: BSON.init(so)])
            }
        }
        
        do {
            let result = try collectionObject!.find(getDocument(dictionary: dictionary), options: findOptions, session: clientSession!)
            
            var doc = result.next()
            while doc != nil {
                databaseOrmResult.object.append(try doc!.get())
                doc = result.next()
            }
            
            if databaseOrmResult.object.count == 0 {
                let databaseOrmError = DatabaseOrmError()
                databaseOrmError.name = DatabaseOrmError.NoRecords.name
                databaseOrmError.description = "\(DatabaseOrmError.NoRecords.description): \(collectionName)"
                databaseOrmResult.databaseOrmError.append(databaseOrmError)
                return databaseOrmResult
            }
            commitTransaction()
        } catch {
            abortTransaction()
            let databaseOrmError = DatabaseOrmError()
            databaseOrmError.name = DatabaseOrmError.FailedToFindRecords.name
            databaseOrmError.description = "\(DatabaseOrmError.FailedToFindRecords.description): \(collectionName): \(error.localizedDescription)"
            databaseOrmResult.databaseOrmError.append(databaseOrmError)
        }
        
        
        return databaseOrmResult
    }
    
    private func getRegularExpression(pattern: String, options: NSRegularExpression.Options) throws -> AnyObject {
        let nsRegularExpression = try NSRegularExpression(pattern: pattern, options: options)
        return BSONRegularExpression(from: nsRegularExpression) as AnyObject
    }
    
    public func find<T: Codable>(collectionName: String, dictionary: [String: Any], limitedTo: Int?) -> DatabaseOrmResult<T> {
        let databaseOrmResult: DatabaseOrmResult = DatabaseOrmResult<T>()
        
        let collectionObject = database?.collection(collectionName, withType: T.self)
        var findOptions: FindOptions?
        
        do {
            if limitedTo! > 0 {
                findOptions = FindOptions(limit: Int(limitedTo!))
                let result = try collectionObject!.find(getDocument(dictionary: dictionary), options: findOptions, session: clientSession!)
                
                var doc = result.next()
                while doc != nil {
                    databaseOrmResult.object.append(try doc!.get())
                    doc = result.next()
                }
                
                if databaseOrmResult.object.count == 0 {
                    let databaseOrmError = DatabaseOrmError()
                    databaseOrmError.name = DatabaseOrmError.NoRecords.name
                    databaseOrmError.description = "\(DatabaseOrmError.NoRecords.description): \(collectionName)"
                    databaseOrmResult.databaseOrmError.append(databaseOrmError)
                    return databaseOrmResult
                }
            } else {
                let result = try collectionObject!.find(getDocument(dictionary: dictionary))
                
                var doc = result.next()
                while doc != nil {
                    databaseOrmResult.object.append(try doc!.get())
                    doc = result.next()
                }
                
                if databaseOrmResult.object.count == 0 {
                    let databaseOrmError = DatabaseOrmError()
                    databaseOrmError.name = DatabaseOrmError.NoRecords.name
                    databaseOrmError.description = "\(DatabaseOrmError.NoRecords.description): \(collectionName)"
                    databaseOrmResult.databaseOrmError.append(databaseOrmError)
                    return databaseOrmResult
                }
            }
            commitTransaction()
        } catch {
            abortTransaction()
            print(error.localizedDescription)
            let databaseOrmError = DatabaseOrmError()
            databaseOrmError.name = DatabaseOrmError.FailedToFindRecords.name
            databaseOrmError.description = "\(DatabaseOrmError.FailedToFindRecords.description): \(collectionName): \(error.localizedDescription)"
            databaseOrmResult.databaseOrmError.append(databaseOrmError)
        }
        
        return databaseOrmResult
    }
    
    public func getAll<T: Codable>(collectionName: String) -> DatabaseOrmResult<T> {
        let databaseOrmResult: DatabaseOrmResult = DatabaseOrmResult<T>()
        
        let collectionObject = database?.collection(collectionName, withType: T.self)
        
        do {
            let result = try collectionObject!.find(session: clientSession!)
            
            var doc = result.next()
            while doc != nil {
                databaseOrmResult.object.append(try doc!.get())
                doc = result.next()
            }
            
            if databaseOrmResult.object.count == 0 {
                let databaseOrmError = DatabaseOrmError()
                databaseOrmError.name = DatabaseOrmError.NoRecords.name
                databaseOrmError.description = "\(DatabaseOrmError.NoRecords.description): \(collectionName)"
                databaseOrmResult.databaseOrmError.append(databaseOrmError)
                return databaseOrmResult
            }
            commitTransaction()
        } catch {
            abortTransaction()
            let databaseOrmError = DatabaseOrmError()
            databaseOrmError.name = DatabaseOrmError.FailedToFindRecords.name
            databaseOrmError.description = "\(DatabaseOrmError.FailedToFindRecords.description): \(collectionName): \(error.localizedDescription)"
            databaseOrmResult.databaseOrmError.append(databaseOrmError)
        }
        
        return databaseOrmResult
    }
    
    public func update<T: Codable>(collectionName: String, whereDictionary: [String: Any], setDictionary: [String: Any]) -> DatabaseOrmResult<T> {
        
        let databaseOrmResult: DatabaseOrmResult = DatabaseOrmResult<T>()
        let collectionObject = database?.collection(collectionName, withType: T.self)
        
        do {
            let result = try collectionObject!.updateOne(filter: getDocument(dictionary: whereDictionary), update: ["$set": BSON.document(getDocument(dictionary: setDictionary))], session: clientSession!)
            
            databaseOrmResult.rowsAffected = result!.modifiedCount
            commitTransaction()
        }
        catch {
            abortTransaction()
            let databaseOrmError = DatabaseOrmError()
            databaseOrmError.name = DatabaseOrmError.FailedToUpdateRecords.name
            databaseOrmError.description = "\(DatabaseOrmError.FailedToUpdateRecords.description): \(collectionName): \(error.localizedDescription)"
            databaseOrmResult.databaseOrmError.append(databaseOrmError)
        }
        
        return databaseOrmResult
    }
    
    public func updatePush<T: Codable>(collectionName: String, whereDictionary: [String: Any], setDictionary: [String: Any]) -> DatabaseOrmResult<T> {
        let databaseOrmResult: DatabaseOrmResult = DatabaseOrmResult<T>()
        
        let collectionObject = database?.collection(collectionName, withType: T.self)
        
        do {
            let result = try collectionObject!.updateOne(filter: getDocument(dictionary: whereDictionary), update: ["$push": BSON.document(getDocument(dictionary: setDictionary))], session: clientSession!)
            
            databaseOrmResult.rowsAffected = result!.modifiedCount
            commitTransaction()
        }
        catch {
            abortTransaction()
            let databaseOrmError = DatabaseOrmError()
            databaseOrmError.name = DatabaseOrmError.FailedToUpdateRecords.name
            databaseOrmError.description = "\(DatabaseOrmError.FailedToUpdateRecords.description): \(collectionName): \(error.localizedDescription)"
            databaseOrmResult.databaseOrmError.append(databaseOrmError)
        }
        
        return databaseOrmResult
    }
    
    private func getBSONArray(_ values: [String]) -> [BSON] {
        var bsonValues = [BSON]()
        for v in values {
            bsonValues.append(BSON.string(v))
        }
        
        return bsonValues
    }
    
    public func updatePush<T: Codable>(collectionName: String, whereDictionary: [String: Any], key: String, values: [String], position: Int) -> DatabaseOrmResult<T> {
        let databaseOrmResult: DatabaseOrmResult = DatabaseOrmResult<T>()
        
        let collectionObject = database?.collection(collectionName, withType: T.self)
        
        do {
            let result = try collectionObject!.updateOne(filter: getDocument(dictionary: whereDictionary), update: ["$push": [key: ["$each": BSON.array(getBSONArray(values)), "$position": BSON.init(position)]]], session: clientSession!)
            
            databaseOrmResult.rowsAffected = result!.modifiedCount
            commitTransaction()
        }
        catch {
            abortTransaction()
            let databaseOrmError = DatabaseOrmError()
            databaseOrmError.name = DatabaseOrmError.FailedToUpdateRecords.name
            databaseOrmError.description = "\(DatabaseOrmError.FailedToUpdateRecords.description): \(collectionName): \(error.localizedDescription)"
            databaseOrmResult.databaseOrmError.append(databaseOrmError)
        }
        
        return databaseOrmResult
    }
    
    public func updatePull<T: Codable>(collectionName: String, whereDictionary: [String: Any], setDictionary: [String: Any]) -> DatabaseOrmResult<T> {
        let databaseOrmResult: DatabaseOrmResult = DatabaseOrmResult<T>()
        
        let collectionObject = database?.collection(collectionName, withType: T.self)
        
        do {
            let result = try collectionObject!.updateOne(filter: getDocument(dictionary: whereDictionary), update: ["$pull": BSON.document(getDocument(dictionary: setDictionary))], session: clientSession!)
            
            databaseOrmResult.rowsAffected = result!.modifiedCount
            commitTransaction()
        }
        catch {
            abortTransaction()
            let databaseOrmError = DatabaseOrmError()
            databaseOrmError.name = DatabaseOrmError.FailedToUpdateRecords.name
            databaseOrmError.description = "\(DatabaseOrmError.FailedToUpdateRecords.description): \(collectionName): \(error.localizedDescription)"
            databaseOrmResult.databaseOrmError.append(databaseOrmError)
        }
        
        return databaseOrmResult
    }
    
    public func update<T : Codable>(collectionName: String, id: String, object: T) -> DatabaseOrmResult<T> {
        let databaseOrmResult: DatabaseOrmResult = DatabaseOrmResult<T>()
        do {
            let collectionObject = database?.collection(collectionName, withType: T.self)
            let encoder = BSONEncoder()
            let doc = try encoder.encode(object)
            
            let result = try collectionObject!.updateOne(filter: ["_id": BSON.string(id)], update: ["$set": BSON.document(doc)], session: clientSession!)
            
            databaseOrmResult.rowsAffected = result!.modifiedCount
            commitTransaction()
        }
        catch {
            abortTransaction()
            let databaseOrmError = DatabaseOrmError()
            databaseOrmError.name = DatabaseOrmError.FailedToUpdateRecords.name
            databaseOrmError.description = "\(DatabaseOrmError.FailedToUpdateRecords.description): \(collectionName): \(error.localizedDescription)"
            databaseOrmResult.databaseOrmError.append(databaseOrmError)
        }
        
        return databaseOrmResult
    }
    
    
    public func update<T : Codable>(collectionName: String, whereDictionary: [String: Any], object: T) -> DatabaseOrmResult<T> {
        let databaseOrmResult: DatabaseOrmResult = DatabaseOrmResult<T>()
        do {
            let collectionObject = database?.collection(collectionName, withType: T.self)
            let encoder = BSONEncoder()
            let doc = try encoder.encode(object)
            
            let result = try collectionObject!.updateOne(filter: getDocument(dictionary: whereDictionary), update: ["$set": BSON.document(doc)], session: clientSession!)
            
            databaseOrmResult.rowsAffected = result!.modifiedCount
            commitTransaction()
        }
        catch {
            abortTransaction()
            let databaseOrmError = DatabaseOrmError()
            databaseOrmError.name = DatabaseOrmError.FailedToUpdateRecords.name
            databaseOrmError.description = "\(DatabaseOrmError.FailedToUpdateRecords.description): \(collectionName): \(error.localizedDescription)"
            databaseOrmResult.databaseOrmError.append(databaseOrmError)
        }
        
        return databaseOrmResult
    }
    
    public func remove<T: Codable>(collectionName: String, id: String) -> DatabaseOrmResult<T> {
        let databaseOrmResult: DatabaseOrmResult = DatabaseOrmResult<T>()
        let collectionObject = database?.collection(collectionName, withType: T.self)
        do {
            let result = try collectionObject!.deleteOne(["_id": BSON.string(id)], session: clientSession!)
            
            databaseOrmResult.rowsAffected = result!.deletedCount
            commitTransaction()
        }
        catch {
            abortTransaction()
            let databaseOrmError = DatabaseOrmError()
            databaseOrmError.name = DatabaseOrmError.FailedToDeleteRecords.name
            databaseOrmError.description = "\(DatabaseOrmError.FailedToDeleteRecords.description): \(collectionName): \(error.localizedDescription)"
            databaseOrmResult.databaseOrmError.append(databaseOrmError)
        }
        
        return databaseOrmResult
    }
    
    public func remove<T: Codable>(collectionName: String, dictionary: [String: Any]) -> DatabaseOrmResult<T> {
        let databaseOrmResult: DatabaseOrmResult = DatabaseOrmResult<T>()
        
        let collectionObject = database?.collection(collectionName, withType: T.self)
        do {
            let result = try collectionObject!.deleteMany(getDocument(dictionary: dictionary), session: clientSession!)
            
            databaseOrmResult.rowsAffected = result!.deletedCount
            commitTransaction()
        }
        catch {
            abortTransaction()
            let databaseOrmError = DatabaseOrmError()
            databaseOrmError.name = DatabaseOrmError.FailedToDeleteRecords.name
            databaseOrmError.description = "\(DatabaseOrmError.FailedToDeleteRecords.description): \(collectionName): \(error.localizedDescription)"
            databaseOrmResult.databaseOrmError.append(databaseOrmError)
        }
        
        return databaseOrmResult
    }
    
    
    //    public func find(collectionName: String, unwind: [String], aggregateDictionary: [Dictionary<String, String>]) throws -> Cursor<Document> {
    //        var cursor: Cursor<Document>?
    //        do {
    //            let collectionObject = (database?[collectionName])!
    //            var pipeline: AggregationPipeline = AggregationPipeline()
    //            for aggregateDict in aggregateDictionary {
    //                let lookup = AggregationPipeline.Stage.lookup(from: aggregateDict["collectionName"]!, localField: aggregateDict["localField"]!, foreignField: aggregateDict["foreignField"]!, as: aggregateDict["as"]!)
    //                pipeline.append(lookup)
    //            }
    //            for uw in unwind {
    //                let unwind = AggregationPipeline.Stage.unwind("$\(uw)")
    //                pipeline.append(unwind)
    //            }
    //
    //            cursor = try collectionObject.aggregate(pipeline)
    //        } catch {
    //            throw DatabaseOrmError.error("Failed to get records: \(collectionName): \(error)")
    //        }
    //
    //        return cursor!
    //    }
    
    
    
}
