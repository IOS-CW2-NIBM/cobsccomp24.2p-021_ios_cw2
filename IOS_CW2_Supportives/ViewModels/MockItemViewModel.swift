import Foundation

class MockItemViewModel: ObservableObject {
    @Published var items: [MockItem] = []
    
    init() {
        loadMocks()
    }
    
    func loadMocks() {
        self.items = [
            MockItem(id: UUID(), title: "First Item", description: "This is the first mock item."),
            MockItem(id: UUID(), title: "Second Item", description: "This is the second mock item.")
        ]
    }
}
