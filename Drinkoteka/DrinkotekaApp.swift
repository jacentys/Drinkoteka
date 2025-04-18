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
			  zamienniki()
        }
		  .modelContainer(
			for: [Drink_M.self],
			//			for: [Skladnik.self, SklZamiennik.self],
			inMemory: false,
			isUndoEnabled: false)
    }
}
