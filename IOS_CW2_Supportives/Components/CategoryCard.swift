import SwiftUI

struct CategoryCard: View {
    let icon: String
    let title: String
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.gray.opacity(0.1))
                .frame(width: 65, height: 65)
                .overlay(
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.blue)
                )
            
            Text(title)
                .font(.caption)
        }
    }
}

