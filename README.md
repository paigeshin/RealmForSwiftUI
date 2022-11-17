# RealmForSwiftUI

## Utils 

### Migrator

```swift
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

```

## App 

### App

```swift
import SwiftUI

@main
struct RealmWithSwiftUIApp: App {
    
    private let migrator: Migrator = Migrator()
    
    var body: some Scene {
        WindowGroup {
            // Delete Constraints Error From Console
            let _ = UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
            let _ = print(String(describing: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path))
            
            ContentView()
        }
    }
}

```

## Models 

### ShppingList 

```swift
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

```

### ShoppingItem 

```swift
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

```

### Screens

### ContentView

```swift
//
//  ContentView.swift
//  RealmWithSwiftUI
//
//  Created by paige shin on 2022/11/18.
//

import RealmSwift
import SwiftUI

struct ContentView: View {
    
    @ObservedResults(ShoppingList.self) var shoppingLists
    @State private var isPresented: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                
                if self.shoppingLists.isEmpty {
                    Text("No shpping lists!")
                }
                
                List {
                    ForEach(self.shoppingLists, id: \.id) { shoppinglist in
                        NavigationLink {
                            ShoppingListItemsScreen(shoppingList: shoppinglist)
                        } label: {
                            VStack {
                                Text(shoppinglist.title) //: TEXT
                                Text(shoppinglist.address) //: TEXT
                                    .opacity(0.4)
                            } //: VSTACK
                        } //: NAVIGATION LINK
                        
                    } //: FOREACH
                    .onDelete(perform: self.$shoppingLists.remove(atOffsets:))
                } //: LIST
                .navigationTitle("Grocery App")
                
            } //: VSTACK
            .sheet(isPresented: self.$isPresented, content: {
                AddShoppingListScreen()
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self.isPresented = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        } //: NAVIGATION VIEW
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

```

### AddShoppingListScreen

```swift
//
//  AddShoppingListScreen.swift
//  RealmWithSwiftUI
//
//  Created by paige shin on 2022/11/18.
//

import SwiftUI
import RealmSwift

struct AddShoppingListScreen: View {
    
    @State private var title: String = ""
    @State private var address: String = ""
    
    @ObservedResults(ShoppingList.self) var shoppingLists: Results<ShoppingList>
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    var body: some View {
        NavigationView {
             
            Form {
                TextField("Enter Title", text: self.$title)
                TextField("Enter Address", text: self.$address)
            
                Button {
                    /// Create a shopping list record
                    let shoppingList = ShoppingList()
                    shoppingList.title = title
                    shoppingList.address = address
                    self.$shoppingLists.append(shoppingList)
                    
                    /// dismiss modal
                    self.dismiss()
                } label: {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                } //: BUTTON
                .buttonStyle(.bordered)
                
            } //: FORM
            .navigationTitle("New List")
            
        } //: NAVIGATION VIEW
    }

}

struct AddShoppingListScreen_Previews: PreviewProvider {
    static var previews: some View {
        AddShoppingListScreen()
    }
}

```

## ShoppingListItemsScreen

```swift
//
//  ShoppingListItemsScreen.swift
//  RealmWithSwiftUI
//
//  Created by paige shin on 2022/11/18.
//

import RealmSwift
import SwiftUI

struct ShoppingListItemsScreen: View {
    
    @ObservedRealmObject var shoppingList: ShoppingList
    @State private var isPresented: Bool = false
    @State private var selectedItemIds: [ObjectId] = []
    @State private var selectedCategory: String = "All"
    
    var items: [ShoppingItem] {
        if self.selectedCategory == "All" {
            return Array(self.shoppingList.items)
        } else {
            return self.shoppingList.items.sorted(byKeyPath: "title")
                .filter { $0.category == self.selectedCategory }
        }
    }
    
    var body: some View {
        VStack {
            
            CategoryFilterView(selectedCategory: self.$selectedCategory)
                .padding()
            
            if self.shoppingList.items.isEmpty {
                Text("No Items Found.")
            }
            
            List{
                ForEach(self.items) { item in
                    NavigationLink {
                        AddShoppingListItemScreen(shoppingList: self.shoppingList, itemToEdit: item)
                    } label: {
                        ShoppingItemCell(item: item,
                                         selected: self.selectedItemIds.contains(item.id)) { selected in
                            print("\(item.title) SELECTED: \(selected)")
                            self.selectedItemIds.append(item.id)
                            if let indexToDelete = self.shoppingList.items.firstIndex(where: { $0.id == item.id }) {
                                self.$shoppingList.items.remove(at: indexToDelete)
                            }
                        }
                    }
                } //: FOREACH
                .onDelete(perform: self.$shoppingList.items.remove(atOffsets:))
            } //: LIST
            .navigationTitle(self.shoppingList.title)
        } //: VSTACK
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    self.isPresented = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: self.$isPresented) {
            AddShoppingListItemScreen(shoppingList: self.shoppingList)
        }
    }
}

struct ShoppingListItemsScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ShoppingListItemsScreen(shoppingList: ShoppingList())
        }
    }
}

```

### AddShopppingListItemScreen

```swift
//
//  AddShoppingListItemScreen.swift
//  RealmWithSwiftUI
//
//  Created by paige shin on 2022/11/18.
//

import SwiftUI
import RealmSwift

struct AddShoppingListItemScreen: View {
    
    var itemToEdit: ShoppingItem?
    
    @State private var selectedCategory: String = ""
    @State private var title: String = ""
    @State private var quantity: String = ""
    @ObservedRealmObject var shoppingList: ShoppingList
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    private let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    private let data: [String] = [
        "Produce", "Fruit", "Meat", "Condiments", "Beverages", "Snacks", "Dairy"
    ]
    
    private var isEditing: Bool {
        self.itemToEdit == nil ? false : true
    }
    
    init(shoppingList: ShoppingList, itemToEdit: ShoppingItem? = nil) {
        self.shoppingList = shoppingList
        self.itemToEdit = itemToEdit
        if let itemToEdit: ShoppingItem = itemToEdit {
            _title = State(initialValue: itemToEdit.title)
            _quantity = State(initialValue: String(itemToEdit.quantity))
            _selectedCategory = State(initialValue: itemToEdit.category)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            if !self.isEditing {
                Text("Add Item")
                    .font(.largeTitle)
            }
            
            LazyVGrid(columns: self.columns) {
                ForEach(self.data, id: \.self) { item in
                    Text(item) //: TEXT
                        .padding()
                        .frame(width: 125)
                        .background(self.selectedCategory == item ? .orange : .green)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .foregroundColor(.white)
                        .onTapGesture {
                            self.selectedCategory = item
                        }
                } // FOREACH
            } //: LAZY V GRID
            Spacer()
                .frame(height: 60)
            
            TextField("Title", text: self.$title) //: TEXTFIELD
                .textFieldStyle(.roundedBorder)
            TextField("Quantity", text: self.$quantity) //: TEXTFIELD
                .textFieldStyle(.roundedBorder)
            
            Button {
                
                if let _ = self.itemToEdit {
                    /// Update the item
                    self.update()
                } else {
                    /// Save the item
                    self.save()
                }
                
                /// Dismiss
                self.dismiss()
            } label: {
                Text(self.isEditing ? "Update" : "Save")
                    .frame(maxWidth: .infinity, maxHeight: 40)
            } //: BUTTON
            .buttonStyle(.bordered)
            .padding(.top, 20)
            
            Spacer()
            
        } //: VSTACK
        .navigationTitle(self.isEditing ? "Update Item" : "Add Item")
        .padding()
    }
    
    private func save() {
        let shoppingItem: ShoppingItem = ShoppingItem()
        shoppingItem.title = title
        shoppingItem.quantity = Int(self.quantity) ?? 1
        shoppingItem.category = self.selectedCategory
        self.$shoppingList.items.append(shoppingItem)
    }
    
    private func update() {
        if let itemToEdit: ShoppingItem = itemToEdit {
            do {
                let realm: Realm = try Realm()
                guard let objectToUpdate = realm.object(ofType: ShoppingItem.self, forPrimaryKey: itemToEdit.id) else { return }
                try realm.write {
                    objectToUpdate.title = self.title
                    objectToUpdate.category = self.selectedCategory
                    objectToUpdate.quantity = Int(quantity) ?? 1
                }
            } catch {
                print(error)
            }
        }
    }
    
}

struct AddShoppingListItemScreen_Previews: PreviewProvider {
    static var previews: some View {
        AddShoppingListItemScreen(shoppingList: ShoppingList())
    }
}

```

### ShppingItemCell

```swift
//
//  AddShoppingListItemScreen.swift
//  RealmWithSwiftUI
//
//  Created by paige shin on 2022/11/18.
//

import SwiftUI
import RealmSwift

struct AddShoppingListItemScreen: View {
    
    var itemToEdit: ShoppingItem?
    
    @State private var selectedCategory: String = ""
    @State private var title: String = ""
    @State private var quantity: String = ""
    @ObservedRealmObject var shoppingList: ShoppingList
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    private let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    private let data: [String] = [
        "Produce", "Fruit", "Meat", "Condiments", "Beverages", "Snacks", "Dairy"
    ]
    
    private var isEditing: Bool {
        self.itemToEdit == nil ? false : true
    }
    
    init(shoppingList: ShoppingList, itemToEdit: ShoppingItem? = nil) {
        self.shoppingList = shoppingList
        self.itemToEdit = itemToEdit
        if let itemToEdit: ShoppingItem = itemToEdit {
            _title = State(initialValue: itemToEdit.title)
            _quantity = State(initialValue: String(itemToEdit.quantity))
            _selectedCategory = State(initialValue: itemToEdit.category)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            if !self.isEditing {
                Text("Add Item")
                    .font(.largeTitle)
            }
            
            LazyVGrid(columns: self.columns) {
                ForEach(self.data, id: \.self) { item in
                    Text(item) //: TEXT
                        .padding()
                        .frame(width: 125)
                        .background(self.selectedCategory == item ? .orange : .green)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .foregroundColor(.white)
                        .onTapGesture {
                            self.selectedCategory = item
                        }
                } // FOREACH
            } //: LAZY V GRID
            Spacer()
                .frame(height: 60)
            
            TextField("Title", text: self.$title) //: TEXTFIELD
                .textFieldStyle(.roundedBorder)
            TextField("Quantity", text: self.$quantity) //: TEXTFIELD
                .textFieldStyle(.roundedBorder)
            
            Button {
                
                if let _ = self.itemToEdit {
                    /// Update the item
                    self.update()
                } else {
                    /// Save the item
                    self.save()
                }
                
                /// Dismiss
                self.dismiss()
            } label: {
                Text(self.isEditing ? "Update" : "Save")
                    .frame(maxWidth: .infinity, maxHeight: 40)
            } //: BUTTON
            .buttonStyle(.bordered)
            .padding(.top, 20)
            
            Spacer()
            
        } //: VSTACK
        .navigationTitle(self.isEditing ? "Update Item" : "Add Item")
        .padding()
    }
    
    private func save() {
        let shoppingItem: ShoppingItem = ShoppingItem()
        shoppingItem.title = title
        shoppingItem.quantity = Int(self.quantity) ?? 1
        shoppingItem.category = self.selectedCategory
        self.$shoppingList.items.append(shoppingItem)
    }
    
    private func update() {
        if let itemToEdit: ShoppingItem = itemToEdit {
            do {
                let realm: Realm = try Realm()
                guard let objectToUpdate = realm.object(ofType: ShoppingItem.self, forPrimaryKey: itemToEdit.id) else { return }
                try realm.write {
                    objectToUpdate.title = self.title
                    objectToUpdate.category = self.selectedCategory
                    objectToUpdate.quantity = Int(quantity) ?? 1
                }
            } catch {
                print(error)
            }
        }
    }
    
}

struct AddShoppingListItemScreen_Previews: PreviewProvider {
    static var previews: some View {
        AddShoppingListItemScreen(shoppingList: ShoppingList())
    }
}

```

### CategoryFilterView

```swift
//
//  CategoryFilterView.swift
//  RealmWithSwiftUI
//
//  Created by paige shin on 2022/11/18.
//

import SwiftUI

struct CategoryFilterView: View {
    
    private let categories: [String] = [
        "All", "Produce", "Fruit", "Meat", "Condiments", "Beverages", "Snacks", "Dairy"
    ]
    @Binding var selectedCategory: String
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(self.categories, id: \.self) { category in
                    Text(category) //: TEXT
                        .frame(minWidth: 100)
                        .padding(6)
                        .foregroundColor(.white)
                        .background(self.selectedCategory == category ? Color.orange : Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
                        .onTapGesture {
                            self.selectedCategory = category
                        }
                }
            } //: HSTACK
        } //: SCROLL VIEW
    }
}

struct CategoryFilterView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryFilterView(selectedCategory: .constant("Meat"))
    }
}

```
