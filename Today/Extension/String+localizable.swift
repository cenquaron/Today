import Foundation

extension String {
    
    var localizable: String {
        NSLocalizedString(
            self,
            comment: "\(self) could not be found in Localizable.strings")
    }
}
