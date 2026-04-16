import SwiftUI
import Combine

class AddTaskSheetManager: ObservableObject {
    @Published var isPresented = false

    func show() {
        withAnimation(.spring(response: 0.5, dampingFraction: 1.0)) { isPresented = true }
    }

    func hide() {
        withAnimation(.spring(response: 0.5, dampingFraction: 1.0)) { isPresented = false }
    }
}
