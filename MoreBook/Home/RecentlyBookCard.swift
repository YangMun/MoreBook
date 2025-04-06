import SwiftUI

// 책 카드 컴포넌트
struct RecentlyBookCard: View {
    let title: String
    let authors: String
    let thumbnailUrl: String?
    let bookId: String
    @StateObject private var imageLoader = ImageLoader()
    @StateObject private var viewModel = BookDetailViewModel()
    @State private var isPressed = false  // 버튼 눌림 상태 추가
    
    var body: some View {
        NavigationLink(destination: 
            BookDetailPage(bookDetail: viewModel.bookDetail)
                .onAppear {
                    if viewModel.bookDetail == nil {
                        viewModel.fetchBookDetail(bookId: bookId)
                    }
                }
        ) {
            VStack(alignment: .leading, spacing: 5) {
                // 책 커버 이미지
                Group {
                    if let thumbnailUrl = thumbnailUrl {
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
                                                    .frame(width: 50)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    )
                            }
                        }
                        .onAppear {
                            imageLoader.loadImage(from: thumbnailUrl.replacingOccurrences(of: "http://", with: "https://"))
                        }
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                Image(systemName: "book.closed")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50)
                                    .foregroundColor(.gray)
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
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)
                    .foregroundColor(.black)
                
                Text(authors)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            .frame(width: 120)
            .scaleEffect(isPressed ? 0.95 : 1.0)  // 눌림 효과
            .animation(.easeInOut(duration: 0.1), value: isPressed)  // 애니메이션
        }
        .simultaneousGesture(  // 터치 제스처 추가
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            viewModel.fetchBookDetail(bookId: bookId)
        }
    }
}

// 도서 상세 정보를 관리하는 ViewModel
class BookDetailViewModel: ObservableObject {
    @Published var bookDetail: BookDetail?
    private var isLoading = false
    
    func fetchBookDetail(bookId: String) {
        guard !isLoading && bookDetail == nil else { return }
        
        isLoading = true
        
        Task {
            do {
                let detail = try await GoogleBooksAPI.shared.fetchBookDetail(bookId: bookId)
                DispatchQueue.main.async {
                    self.bookDetail = detail
                    self.isLoading = false
                }
            } catch {
                print("도서 상세 정보 가져오기 실패: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
}
