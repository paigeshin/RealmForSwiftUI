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
