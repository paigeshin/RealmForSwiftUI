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
