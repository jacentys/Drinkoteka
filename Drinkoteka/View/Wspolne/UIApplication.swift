//
//  UIApplication.swift
//  Barman
//
//  Created by Jacek Skrobisz on 2025.04.02.
//

import SwiftUI

extension UIApplication {
	func koniecEdycjiExt() {
		sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
	}
}
