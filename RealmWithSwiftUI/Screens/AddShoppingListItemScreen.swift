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
