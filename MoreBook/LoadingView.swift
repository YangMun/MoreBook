import SwiftUI
import Lottie

struct LoadingView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var showMainView = false
    
    var body: some View {
        ZStack {
            // 배경색을 항상 회색으로 설정
            Color(UIColor.systemGray5)
                .edgesIgnoringSafeArea(.all)
            
            if showMainView {
                // 로딩 후 화면 - 메인 뷰로 이동
                MainView()
                    .transition(.opacity)
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
                    showMainView = true
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
