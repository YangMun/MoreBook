import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            HomePage()
                .tabItem {
                    Image(systemName: "house")
                    Text("홈")
                }
            
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("통계")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("프로필")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("설정")
                }
        }
        .accentColor(ColorFun.accent) // ColorFun 사용
        .onAppear {
            // 배경색 설정
            let bookBackgroundColor = UIColor(hex: "FFF0D7")
            
            // 탭 바 스타일 커스터마이징
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = bookBackgroundColor
            
            // 탭 바 경계선 설정 - 더 굵게 적용
            appearance.shadowColor = UIColor.black.withAlphaComponent(0.5)
            
            // 탭 바에 책 느낌을 주는 경계선 추가 - 더 굵게 적용
            UITabBar.appearance().layer.borderWidth = 2.0
            UITabBar.appearance().layer.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor
            
            // 상단 경계선 강화
            let topBorderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 2))
            topBorderView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            UITabBar.appearance().addSubview(topBorderView)
            
            // 적용
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

// 추가 뷰들 (나중에 각각 별도 파일로 분리 가능)
struct StatisticsView: View {
    var body: some View {
        ZStack {
            // 배경색 설정
            ColorFun.background
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                BookPageHeader(title: "통계")
                
                Spacer()
                
                Text("통계 페이지")
                    .font(.title)
                
                Spacer()
            }
            .padding()
        }
    }
}

struct ProfileView: View {
    var body: some View {
        ZStack {
            // 배경색 설정
            ColorFun.background
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                BookPageHeader(title: "프로필")
                
                Spacer()
                
                Text("프로필 페이지")
                    .font(.title)
                
                Spacer()
            }
            .padding()
        }
    }
}

struct SettingsView: View {
    var body: some View {
        ZStack {
            // 배경색 설정
            ColorFun.background
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                BookPageHeader(title: "설정")
                
                Spacer()
                
                Text("설정 페이지")
                    .font(.title)
                
                Spacer()
            }
            .padding()
        }
    }
}

// 책 느낌의 헤더 컴포넌트
struct BookPageHeader: View {
    var title: String
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 구분선
            Rectangle()
                .frame(height: 1.5)
                .foregroundColor(Color.black.opacity(0.4))
                .padding(.horizontal, 0)
            
            // 헤더 내용
            HStack {
                Spacer()
                
                Text(title)
                    .font(.custom("Times New Roman", size: 24))
                    .fontWeight(.bold)
                    .padding(.top, 10)
                
                Spacer()
            }
            .padding(.vertical, 10)
            
            // 하단 구분선
            Rectangle()
                .frame(height: 1.5)
                .foregroundColor(Color.black.opacity(0.4))
                .padding(.horizontal, 0)
        }
    }
}

#Preview {
    MainView()
}
