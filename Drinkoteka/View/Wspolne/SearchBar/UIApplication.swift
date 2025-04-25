import Foundation
import SwiftUI

extension UIApplication {
	func koniecEdycjiExt() {
		sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
	}
}
