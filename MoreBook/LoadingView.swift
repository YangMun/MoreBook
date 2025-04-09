import SwiftUI
import Lottie

struct LoadingView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var showLoginView = false
    @StateObject private var loginAuth = LoginAuth.shared
    
    var body: some View {
        ZStack {
            // 배경색을 항상 회색으로 설정
            Color(UIColor.systemGray5)
                .edgesIgnoringSafeArea(.all)
            
            if showLoginView {
                // 로그인 상태에 따라 MainView 또는 LoginView 표시
                if loginAuth.isLoggedIn {
                    MainView()
                        .transition(.opacity)
                } else {
                    LoginView()
                        .transition(.opacity)
                }
            } else {
                // 로딩 애니메이션 표시
                VStack(spacing: 20) {
                    LottieView(name: "LoadingAni")
                        .frame(width: 200, height: 200)
                }
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            // 로딩 애니메이션을 3초 동안 표시
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                    showLoginView = true
                }
            }
        }
    }
}

struct LottieView: UIViewRepresentable {
    var name: String
    
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        let animationView = LottieAnimationView()
        let animation = LottieAnimation.named(name)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
        // 업데이트 코드가 필요할 경우
    }
}

#Preview {
    LoadingView()
}
