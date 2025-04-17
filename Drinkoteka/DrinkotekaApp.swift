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
			//			for: [Skladnik.self, Drink.self, DrinkSkladnik.self, DrinkPrzepis.self, SklZamiennik.self],
			for: [SklZamiennik.self, Drink.self],
			inMemory: false,
			isUndoEnabled: false)
    }
}
