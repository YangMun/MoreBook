import SwiftUI

struct LoginView: View {
    @StateObject private var loginAuth = LoginAuth.shared
    @State private var isApplePressed = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    private func handleLogin(_ action: @escaping () async throws -> Void) {
        Task {
            do {
                try await action()
            } catch {
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    // 애플 로그인 버튼 컴포넌트
    private func AppleLoginButton(title: String, imageName: String, action: @escaping () -> Void, isPressed: Bool) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: imageName)
                    .font(.system(size: 20))
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black.opacity(0.3), lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 1, y: 1)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isApplePressed = true
                }
                .onEnded { _ in
                    isApplePressed = false
                }
        )
    }
    
    var body: some View {
        Group {
            if loginAuth.isLoggedIn {
                MainView()
            } else {
                ZStack {
                    // 배경색 설정
                    ColorFun.background
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 0) {
                        Spacer()
                        
                        // 로고 및 환영 메시지
                        VStack(spacing: 24) {
                            Image(systemName: "books.vertical.fill")
                                .font(.system(size: 80))
                                .foregroundColor(ColorFun.accent)
                            
                            VStack(spacing: 8) {
                                Text("MoreBook에 오신 것을 환영합니다")
                                    .font(.system(size: 24, weight: .bold))
                                
                                Text("Apple 계정으로 간편하게 시작하세요")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                        
                        // 애플 로그인 버튼
                        AppleLoginButton(
                            title: "Apple로 계속하기",
                            imageName: "apple.logo",
                            action: {
                                handleLogin { try await LoginAuth.shared.signInWithApple() }
                            },
                            isPressed: isApplePressed
                        )
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .alert("로그인 오류", isPresented: $showError) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
}

#Preview {
    LoginView()
}
