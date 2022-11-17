//
//  RealmWithSwiftUIApp.swift
//  RealmWithSwiftUI
//
//  Created by paige shin on 2022/11/18.
//

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
