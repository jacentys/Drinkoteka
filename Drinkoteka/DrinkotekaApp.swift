//
//  DrinkotekaApp.swift
//  Drinkoteka
//
//  Created by Jacek Skrobisz on 2025.04.17.
//

import SwiftUI
import SwiftData

@main
struct DrinkotekaApp: App {
    var body: some Scene {
		 
        WindowGroup {
			  drinki()
        }
		  .modelContainer(
			for: [Dr_M.self, Skl_M.self],
			inMemory: false,
			isUndoEnabled: false)
    }
}
