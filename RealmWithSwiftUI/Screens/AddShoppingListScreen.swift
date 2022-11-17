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
