import SwiftUI
import Combine

class DeleteTaskSheetManager: ObservableObject {
    @Published var isPresented = false
    @Published var taskId: String = ""
    @Published var taskTitle: String = ""
    @Published var isPending: Bool = false

    func show(taskId: String, title: String, isPending: Bool = false) {
        self.taskId = taskId
        self.taskTitle = title
        self.isPending = isPending
        withAnimation(.spring(response: 0.5, dampingFraction: 1.0)) { isPresented = true }
    }

    func hide() {
        withAnimation(.spring(response: 0.5, dampingFraction: 1.0)) { isPresented = false }
    }
}
