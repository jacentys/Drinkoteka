import Foundation
import SwiftUI

#if os(iOS)
extension UIApplication {
	func koniecEdycjiExt() {
		sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
	}
}
#endif
