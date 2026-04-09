import Foundation

class MockDataService {
    static let shared = MockDataService()
    
    private init() {}
    
    func fetchMockString() -> String {
        return "This is data from the Mock Service"
    }
}
