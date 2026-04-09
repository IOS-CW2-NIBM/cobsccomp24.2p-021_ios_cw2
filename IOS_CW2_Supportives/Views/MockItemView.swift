import SwiftUI

struct MockItemView: View {
    var item: MockItem
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(item.title)
                .font(.headline)
            Text(item.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    MockItemView(item: MockItem(id: UUID(), title: "Mock Title", description: "Mock Description"))
}
