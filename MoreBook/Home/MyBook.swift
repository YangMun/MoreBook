import SwiftUI

struct MyBook: View {
    var body: some View {
        ZStack {
            // 배경색 설정
            ColorFun.background
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // 책 스타일 헤더
                BookHeader(title: "나의 도서")
                
                Spacer()
                
                Text("프로필 페이지")
                    .font(.title)
                
                Spacer()
            }
            .padding(.vertical)
        }
    }
}

#Preview {
    MyBook()
}
