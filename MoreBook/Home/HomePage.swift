import SwiftUI

struct HomePage: View {
    @State private var selectedCategory = "베스트셀러"
    @State private var showAddView = false
    @State private var recentBooks: [RecentBook] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                // 배경색 설정
                ColorFun.background
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    // 책 스타일 헤더
                    BookHeader(title: "MoreBook")
                    
                    // 카테고리 선택 영역
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            BookCategoryButton(
                                title: "베스트셀러",
                                isSelected: selectedCategory == "베스트셀러",
                                action: { selectedCategory = "베스트셀러" }
                            )
                            
                            BookCategoryButton(
                                title: "신간도서",
                                isSelected: selectedCategory == "신간도서",
                                action: { selectedCategory = "신간도서" }
                            )
                            
                            BookCategoryButton(
                                title: "추천도서",
                                isSelected: selectedCategory == "추천도서",
                                action: { selectedCategory = "추천도서" }
                            )
                        }
                        .padding(.horizontal)
                    }
                    // 배너 영역
                    ZStack {
                        Rectangle()
                            .fill(ColorFun.bannerBackground)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black.opacity(0.4), lineWidth: 1.5)
                            )
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("어디서나 마음껏 읽으세요")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("다양한 종류의 책을 발견하고 읽어보세요")
                                .font(.subheadline)
                            
                            NavigationLink(destination: AddViewPage(), isActive: $showAddView) {
                                Button(action: {
                                    showAddView = true
                                }) {
                                    Text("지금 시작하기")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(ColorFun.buttonText)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 20)
                                        .background(ColorFun.buttonBackground)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.black.opacity(0.3), lineWidth: 1.5)
                                        )
                                }
                            }
                            .padding(.top, 5)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 180)
                    .padding(.horizontal)
                    
                    // 인기 도서 섹션
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("\(selectedCategory) 목록")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button(action: {
                                // 더보기 버튼 액션
                            }) {
                                Text("더보기")
                                    .font(.subheadline)
                                    .foregroundColor(ColorFun.accent)
                            }
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(recentBooks, id: \.id) { book in
                                    RecentlyBookCard(
                                        title: book.title ?? "",
                                        authors: book.authors ?? "",
                                        thumbnailUrl: book.thumbnailUrl,
                                        bookId: book.id ?? ""
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
                .onAppear {
                    // 최근 본 도서 목록 가져오기
                    recentBooks = CoreDataManager.shared.fetchRecentBooks()
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// 책 모양의 카테고리 버튼 컴포넌트
struct BookCategoryButton: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Text(title)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                    .foregroundColor(isSelected ? .white : .black)
                    .frame(height: 40)
                    .background(
                        isSelected ? ColorFun.categoryButtonBackground : Color.clear
                    )
                    // 상단 선
                    .overlay(
                        Rectangle()
                            .frame(height: 1.5)
                            .foregroundColor(Color.black.opacity(0.4))
                            .offset(y: -20), // 텍스트 위에 배치
                        alignment: .top
                    )
                    // 하단 선
                    .overlay(
                        Rectangle()
                            .frame(height: 1.5)
                            .foregroundColor(Color.black.opacity(0.4))
                            .offset(y: 20), // 텍스트 아래에 배치
                        alignment: .bottom
                    )
            }
            // 책 느낌을 위한 그림자 효과
            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        // 버튼 누를 때 애니메이션
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// 원래 카테고리 버튼 (사용하지 않음)
struct CategoryButton: View {
    var title: String
    var isSelected: Bool
    
    var body: some View {
        Text(title)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(isSelected ? ColorFun.selectedCategory : Color.white)
            .foregroundColor(isSelected ? .white : .black)
            .font(.subheadline)
            .fontWeight(isSelected ? .bold : .regular)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.black.opacity(0.2), lineWidth: 0.5)
            )
    }
}

// 책 스타일 헤더 컴포넌트
struct BookHeader: View {
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
                Button(action: {
                    // 메뉴 버튼 액션
                }) {
                    Image(systemName: "line.horizontal.3")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Text(title)
                    .font(.custom("Times New Roman", size: 28))
                    .fontWeight(.bold)
                    .kerning(2)
                
                Spacer()
                
                Button(action: {
                    // 알림 버튼 액션
                }) {
                    Image(systemName: "bell")
                        .font(.title2)
                        .foregroundColor(.black)
                }
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
    HomePage()
}
