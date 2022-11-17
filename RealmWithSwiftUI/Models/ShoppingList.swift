//
//  ShoppingList.swift
//  RealmWithSwiftUI
//
//  Created by paige shin on 2022/11/18.
//

import Foundation
import RealmSwift

final class ShoppingList: Object, Identifiable {
    
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String
    @Persisted var address: String
    /// Create Relationship
    @Persisted var items: List<ShoppingItem> = List<ShoppingItem>()
//    override class func primaryKey() -> String? {
//        "id"
//    }
    
}
