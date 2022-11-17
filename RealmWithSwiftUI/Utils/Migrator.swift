//
//  Migrator.swift
//  RealmWithSwiftUI
//
//  Created by paige shin on 2022/11/18.
//

import Foundation
import RealmSwift

final class Migrator {
    
    init() {
        self.updateSchema()
    }
    
    func updateSchema() {
        let config: Realm.Configuration = Realm.Configuration(schemaVersion: 2) { migration, oldSchemaVersion in
            if oldSchemaVersion < 1 {
                /// add new fields to old schema
                migration.enumerateObjects(ofType: ShoppingList.className()) { _, newObject in
                    newObject!["items"] = List<ShoppingList>()
                }
            }
            
            if oldSchemaVersion < 2 {
                /// add new fields to old schema
                migration.enumerateObjects(ofType: ShoppingItem.className()) { _, newObject in
                    newObject!["category"] = ""
                }
            }
        }
        Realm.Configuration.defaultConfiguration = config
        let _ = try! Realm()
    }
    
}
