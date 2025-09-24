import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingSignUp = false
    @State private var showingSignIn = false
    @State private var showingInviteCode = false
    @State private var logoOffset: CGFloat = -100
    @State private var logoOpacity: Double = 0
    @State private var coconutEmojis: [String] = []
    @State private var coconutTimer: Timer?
    @State private var hasShownCoconuts = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: geometry.size.width > 768 ? 40 : 30) {
                        Spacer(minLength: geometry.size.width > 768 ? 60 : 40)
                            .padding(.top, 10)
                        
                        // App Logo/Title
                        VStack(spacing: geometry.size.width > 768 ? 16 : 10) {
                            Image(systemName: "airplane.departure")
                                .font(.system(size: geometry.size.width > 768 ? 120 : 90))
                                .foregroundColor(.blue)
                                .offset(x: logoOffset)
                                .opacity(logoOpacity)
                            
                            Text("Mochaa")
                                .font(geometry.size.width > 768 ? .system(size: 48, weight: .bold) : .largeTitle)
                                .fontWeight(.bold)
                                .offset(x: logoOffset)
                                .opacity(logoOpacity)
                            
                            Text("Plan your trips together")
                                .font(geometry.size.width > 768 ? .title3 : .subheadline)
                                .foregroundColor(.secondary)
                                .offset(x: logoOffset)
                                .opacity(logoOpacity)
                    
                    // Coconut Emoji Row Below Subtitle - Reserved Space
//                    HStack(spacing: 12) {
//                        ForEach(Array(coconutEmojis.enumerated()), id: \.offset) { index, emoji in
//                            Text(emoji)
//                                .font(.system(size: 40))
//                                .transition(.scale.combined(with: .opacity))
//                        }
//                    }
//                    .frame(height: 50) // Reserve space for coconuts
//                    .padding(.top, 10)
                }
                
                Spacer()
                    .frame(height: 30)
                    .padding(.top, 5)
                
                    // Authentication Options
                    VStack(spacing: geometry.size.width > 768 ? 16 : 12) {
                        Button(action: {
                            print("🍎 Apple Sign-In button tapped!")
                            authManager.signInWithApple()
                        }) {
                            HStack {
                                Image(systemName: "applelogo")
                                    .font(.system(size: geometry.size.width > 768 ? 20 : 16))
                                    .foregroundColor(.blue)
                                Text("Sign In with Apple")
                                    .font(geometry.size.width > 768 ? .title3 : .body)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(geometry.size.width > 768 ? 20 : 16)
                            .background(
                                RoundedRectangle(cornerRadius: geometry.size.width > 768 ? 16 : 12)
                                    .fill(Color.blue.opacity(0.1))
                                    .shadow(color: .blue.opacity(0.2), radius: 4, x: 0, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: geometry.size.width > 768 ? 16 : 12)
                                    .stroke(.blue, lineWidth: 1)
                            )
                            .foregroundColor(.blue)
                        }
                    
                        Button(action: {
                            authManager.signInWithGoogle()
                        }) {
                            HStack {
                                Image(systemName: "globe")
                                    .font(.system(size: geometry.size.width > 768 ? 20 : 16))
                                    .foregroundColor(.red)
                                Text("Sign In with Google")
                                    .font(geometry.size.width > 768 ? .title3 : .body)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(geometry.size.width > 768 ? 20 : 16)
                            .background(
                                RoundedRectangle(cornerRadius: geometry.size.width > 768 ? 16 : 12)
                                    .fill(Color.red.opacity(0.12))
                                    .shadow(color: .red.opacity(0.2), radius: 4, x: 0, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: geometry.size.width > 768 ? 16 : 12)
                                    .stroke(.red, lineWidth: 1)
                            )
                            .foregroundColor(.red)
                        }
                    
                        Button(action: {
                            showingInviteCode = true
                        }) {
                            HStack {
                                Image(systemName: "key")
                                    .font(.system(size: geometry.size.width > 768 ? 20 : 16))
                                    .foregroundColor(.green)
                                Text("Join with Invite Code")
                                    .font(geometry.size.width > 768 ? .title3 : .body)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(geometry.size.width > 768 ? 20 : 16)
                            .background(
                                RoundedRectangle(cornerRadius: geometry.size.width > 768 ? 16 : 12)
                                    .fill(Color.green.opacity(0.12))
                                    .shadow(color: .green.opacity(0.2), radius: 4, x: 0, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: geometry.size.width > 768 ? 16 : 12)
                                    .stroke(.green, lineWidth: 1)
                            )
                            .foregroundColor(.green)
                        }
                    }
                    .padding(.horizontal, geometry.size.width > 768 ? 40 : 20)
                
                Spacer()
                
                    // Sign In button at the bottom
                    Button(action: {
                        showingSignIn = true
                    }) {
                        Text("Sign In")
                            .font(geometry.size.width > 768 ? .title3 : .body)
                            .fontWeight(.semibold)
                            .padding(.horizontal, geometry.size.width > 768 ? 48 : 36)
                            .padding(.vertical, geometry.size.width > 768 ? 16 : 12)
                            .background(
                                RoundedRectangle(cornerRadius: geometry.size.width > 768 ? 24 : 20)
                                    .fill(Color.blue.opacity(0.1))
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: geometry.size.width > 768 ? 24 : 20)
                                    .stroke(.blue, lineWidth: 1)
                            )
                            .foregroundColor(.blue)
                    }
                        .padding(.bottom, geometry.size.width > 768 ? 60 : 40)
                    }
                    .frame(minHeight: geometry.size.height)
                }
                .scrollIndicators(.visible)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    logoOffset = 0
                    logoOpacity = 1
                }
                
                // Only show coconuts once on startup
                if !hasShownCoconuts {
                    hasShownCoconuts = true
                    startCoconutAnimation()
                }
            }
            .onDisappear {
                coconutTimer?.invalidate()
            }
        }
        .sheet(isPresented: $showingSignUp) {
            SignUpView()
        }
        .sheet(isPresented: $showingSignIn) {
            SignInView()
        }
        .sheet(isPresented: $showingInviteCode) {
            InviteCodeView()
        }
    }
}

// MARK: - Coconut Animation Functions
extension AuthenticationView {
    private func startCoconutAnimation() {
        // Clear any existing timer
        coconutTimer?.invalidate()
        
        // Show coconuts only once after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            addCoconutEmoji()
        }
    }
    
    private func addCoconutEmoji() {
        // Determine number of coconuts based on probability
        let random = Double.random(in: 0...1)
        let coconutCount: Int
        
        if random < 0.1 {
            coconutCount = 4  // 10% chance
        } else if random < 0.9 {
            coconutCount = 3  // 80% chance
        } else {
            coconutCount = 2  // 10% chance
        }
        
        // Clear existing coconuts
        withAnimation(.easeOut(duration: 0.3)) {
            coconutEmojis.removeAll()
        }
        
//        // Add new coconuts one by one
//        for i in 0..<coconutCount {
//            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3) {
//                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
//                    coconutEmojis.append("🥥")
//                }
//            }
//        }
    }
    

}
