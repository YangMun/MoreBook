import SwiftUI

// 이미지 로딩을 위한 ObservableObject
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    private var cancellable: URLSessionDataTask?
    
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        isLoading = true
        cancellable?.cancel() // 이전 요청 취소
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let data = data, let image = UIImage(data: data) {
                    self?.image = image
                }
            }
        }
        cancellable = task
        task.resume()
    }
    
    func cancel() {
        cancellable?.cancel()
        cancellable = nil
    }
}

struct AddViewPage: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @StateObject private var viewModel = BookSearchViewModel()
    @FocusState private var isSearchFocused: Bool
    
    // 2열 그리드 레이아웃 정의
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            // 배경색 설정
            ColorFun.background
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isSearchFocused = false // 키보드 닫기
                }
            
            VStack(spacing: 0) {
                // 네비게이션 헤더
                AddHeader(title: "책 등록") {
                    presentationMode.wrappedValue.dismiss()
                }
                
                // 검색 영역
                VStack(spacing: 15) {
                    // 검색창 컨테이너
                    ZStack {
                        // 배경 레이어
                        Rectangle()
                            .fill(Color(red: 0.95, green: 0.93, blue: 0.88)) // 오래된 종이 색상
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(red: 0.6, green: 0.5, blue: 0.3), lineWidth: 1.5)
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                        
                        // 상단 장식선
                        Rectangle()
                            .fill(Color(red: 0.6, green: 0.5, blue: 0.3))
                            .frame(height: 1)
                            .offset(y: -20)
                        
                        // 하단 장식선
                        Rectangle()
                            .fill(Color(red: 0.6, green: 0.5, blue: 0.3))
                            .frame(height: 1)
                            .offset(y: 20)
                        
                        // 검색 컨텐츠
                        HStack(spacing: 12) {
                            // 검색 아이콘
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 18))
                                .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.2))
                            
                            // 검색 입력창
                            TextField("책 제목, 저자, ISBN을 입력하세요", text: $searchText)
                                .font(.custom("Times New Roman", size: 16))
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                                .submitLabel(.search)
                                .focused($isSearchFocused)
                                .onSubmit {
                                    if !searchText.isEmpty {
                                        viewModel.searchBooks(query: searchText)
                                        isSearchFocused = false // 검색 시 키보드 닫기
                                    }
                                }
                            
                            // 검색창 클리어 버튼
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.2))
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                    }
                    .frame(height: 50)
                }
                .padding(.horizontal)
                .padding(.top, 15)
                
                // 검색 결과 영역
                ScrollView {
                    if viewModel.isLoading && viewModel.bookPreviews.isEmpty {
                        ProgressView()
                            .padding()
                    } else if !searchText.isEmpty && viewModel.error != nil {
                        Text("검색 중 오류가 발생했습니다: \(viewModel.error!.localizedDescription)")
                            .foregroundColor(.red)
                            .padding()
                    } else if !viewModel.bookPreviews.isEmpty {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(viewModel.bookPreviews) { preview in
                                SearchBookCard(preview: preview)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        // 추가 로딩 인디케이터
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        }
                        
                        // 스크롤 감지를 위한 지오메트리 리더
                        GeometryReader { geometry in
                            Color.clear.preference(key: ScrollOffsetPreferenceKey.self,
                                value: geometry.frame(in: .named("scroll")).maxY)
                        }
                        .frame(height: 20)
                    } else if searchText.isEmpty {
                        // 초기 상태 메시지
                        VStack(spacing: 10) {
                            Image(systemName: "book.circle")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("원하시는 책을 검색해보세요")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 100)
                    }
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { maxY in
                    // 스크롤이 하단에 가까워지면 추가 로드
                    let threshold = UIScreen.main.bounds.height * 0.5
                    if maxY < threshold {
                        viewModel.loadMoreResults()
                    }
                }
                .onTapGesture {
                    isSearchFocused = false
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
        .navigationBarHidden(true)
    }
}

// 검색 결과 책 카드 컴포넌트
struct SearchBookCard: View {
    let preview: BookPreview
    @StateObject private var imageLoader = ImageLoader()
    @State private var isPressed = false // 버튼 눌림 상태
    @State private var navigateToDetail = false
    @State private var bookDetail: BookDetail?
    
    var body: some View {
        Button(action: {
            Task {
                do {
                    print("=== 도서 상세 정보 요청 시작 ===")
                    print("도서 ID: \(preview.id)")
                    
                    let detail = try await GoogleBooksAPI.shared.fetchBookDetail(bookId: preview.id)
                    
                    print("=== 도서 상세 정보 ===")
                    print("제목: \(detail.title)")
                    print("저자: \(detail.authors?.joined(separator: ", ") ?? "정보 없음")")
                    print("출판일: \(detail.publishedDate ?? "정보 없음")")
                    print("페이지 수: \(detail.pageCount ?? 0)")
                    print("언어: \(detail.language ?? "정보 없음")")
                    print("설명: \(detail.description ?? "정보 없음")")
                    print("썸네일 URL: \(detail.thumbnailUrl ?? "정보 없음")")
                    print("=========================")
                    
                    // UI 업데이트는 메인 스레드에서
                    await MainActor.run {
                        self.bookDetail = detail
                        navigateToDetail = true
                    }
                } catch {
                    print("도서 상세 정보 조회 중 오류 발생: \(error.localizedDescription)")
                }
            }
        }) {
            VStack(alignment: .leading, spacing: 5) {
                // 책 커버 이미지
                if let imageUrl = preview.imageUrl {
                    Group {
                        if let uiImage = imageLoader.image {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .overlay(
                                    Group {
                                        if imageLoader.isLoading {
                                            ProgressView()
                                        } else {
                                            Image(systemName: "book.closed")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 30)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                )
                        }
                    }
                    .frame(width: 120, height: 180)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black.opacity(0.4), lineWidth: 1.5)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 3, x: 2, y: 2)
                    .onAppear {
                        imageLoader.loadImage(from: imageUrl)
                    }
                    .onDisappear {
                        imageLoader.cancel()
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 120, height: 180)
                        .overlay(
                            Image(systemName: "book.closed")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30)
                                .foregroundColor(.gray)
                        )
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black.opacity(0.4), lineWidth: 1.5)
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 3, x: 2, y: 2)
                }
                
                Text(preview.title)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)
                    .foregroundColor(.black)
                
                if let authors = preview.authors {
                    Text(authors.joined(separator: ", "))
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            .frame(width: 120)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: { })
        .background(
            NavigationLink(
                destination: BookDetailPage(bookDetail: bookDetail),
                isActive: $navigateToDetail
            ) {
                EmptyView()
            }
        )
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

// 스크롤 오프셋을 추적하기 위한 PreferenceKey
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    AddViewPage()
} 
