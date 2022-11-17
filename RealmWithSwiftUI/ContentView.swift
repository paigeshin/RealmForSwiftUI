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
