//
//  ShoppingItemCel.swift
//  RealmWithSwiftUI
//
//  Created by paige shin on 2022/11/18.
//

import SwiftUI

struct ShoppingItemCell: View {
    
    let item: ShoppingItem
    var selected: Bool
    let isSelected: (Bool) -> Void
    
    var body: some View {
        HStack {
            Image(systemName: self.selected ? "checkmark.square" : "square") //: IMAGE
                .onTapGesture {
                    self.isSelected(!self.selected)
                }
            
            VStack(alignment: .leading) {
                Text(self.item.title) // TEXT
                Text(self.item.category) // CATEGORY
                    .opacity(0.4)
            } //: VSTACK
            
            Spacer()
            
            Text("\(item.quantity)")
            
        } //: HSTACK
        .opacity(self.selected ? 0.4 : 1.0)
    }
}

struct ShoppingItemCell_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingItemCell(item: ShoppingItem(),
                         selected: true,
                         isSelected: { _ in })
    }
}
