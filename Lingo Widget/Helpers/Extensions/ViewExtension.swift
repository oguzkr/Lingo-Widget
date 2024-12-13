//
//  ViewExtensions.swift
//  Wod Timer
//
//  Created by Oguz Doruk on 10.08.2023.
//

import SwiftUI

extension View {
    func widthAsPercentage(_ percentage: CGFloat) -> some View {
        self.frame(width: UIScreen.main.bounds.width * percentage / 100)
    }
    
    func heightAsPercentage(_ percentage: CGFloat) -> some View {
        self.frame(height: UIScreen.main.bounds.height * percentage / 100)
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func hapticFeedback() {
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackgenerator.impactOccurred()
    }
    
    func heightForBottomAndTopFrame() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        return (screenHeight - screenWidth) / 2
    }
}
