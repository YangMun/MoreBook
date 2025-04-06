import SwiftUI

struct MyBook: View {
    var body: some View {
        ZStack {
            // 배경색 설정
            ColorFun.background
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                BookPageHeader(title: "My Book")
                
                Spacer()
                
                Text("프로필 페이지")
                    .font(.title)
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    MyBook()
}
