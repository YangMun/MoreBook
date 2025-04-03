import SwiftUI

struct AddViewPage: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // 배경색 설정
            ColorFun.background
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // 네비게이션 헤더
                AddHeader(title: "책 등록") {
                    presentationMode.wrappedValue.dismiss()
                }
                
                // 여기에 실제 콘텐츠가 들어갈 공간
                ScrollView {
                    VStack {
                        // 콘텐츠를 위한 공간
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
        .navigationBarHidden(true)
    }
}

// 책 스타일 헤더 컴포넌트
struct AddHeader: View {
    var title: String
    var backAction: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 구분선
            Rectangle()
                .frame(height: 1.5)
                .foregroundColor(Color.black.opacity(0.4))
                .padding(.horizontal, 0)
            
            // 헤더 내용
            HStack {
                Button(action: backAction) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                        Text("뒤로")
                            .font(.system(size: 16))
                    }
                    .foregroundColor(.black)
                }
                
                Spacer()
                
                Text(title)
                    .font(.custom("Times New Roman", size: 28))
                    .fontWeight(.bold)
                    .kerning(2)
                
                Spacer()
                
                // 오른쪽 여백을 위한 투명 버튼 (왼쪽 버튼과 동일한 크기)
                HStack(spacing: 5) {
                    Text("뒤로")
                        .font(.system(size: 16))
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                .opacity(0)
            }
            .padding(.horizontal)
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
    AddViewPage()
} 
