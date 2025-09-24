import SwiftUI

struct AppIconGenerator: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.cyan]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 8) {
                // Main icon: suitcase with people
                ZStack {
                    // Suitcase
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .frame(width: 60, height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white, lineWidth: 2)
                        )
                    
                    // Handle
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white)
                        .frame(width: 20, height: 4)
                        .offset(y: -22)
                }
                
                // People icons
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                }
                .offset(y: -5)
            }
        }
        .frame(width: 1024, height: 1024)
        .clipShape(RoundedRectangle(cornerRadius: 200))
    }
}

#Preview {
    AppIconGenerator()
        .frame(width: 200, height: 200)
}
