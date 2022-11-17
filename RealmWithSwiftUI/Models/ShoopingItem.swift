//
//  ShoopingItem.swift
//  RealmWithSwiftUI
//
//  Created by paige shin on 2022/11/18.
//

import Foundation
import RealmSwift

class ShoppingItem: Object, Identifiable {
    
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String
    @Persisted var quantity: Int
    @Persisted var category: String
//    override class func primaryKey() -> String? {
//        return "id"
//    }

}
