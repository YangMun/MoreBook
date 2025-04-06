import SwiftUI

// 책 표지 이미지 컴포넌트
struct BookCoverImage: View {
    let thumbnailUrl: String?
    @StateObject private var imageLoader = ImageLoader()
    
    var body: some View {
        Group {
            if let thumbnailUrl = thumbnailUrl {
                Group {
                    if let uiImage = imageLoader.image {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
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
                        .stroke(Color.black.opacity(0.4), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
                .onAppear {
                    imageLoader.loadImage(from: thumbnailUrl.replacingOccurrences(of: "http://", with: "https://"))
                }
            }
        }
    }
}

// 책 정보 컴포넌트
struct BookInfoView: View {
    let title: String
    let authors: [String]?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 제목
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .lineLimit(3)
            
            // By: 저자
            if let authors = authors {
                VStack(alignment: .leading, spacing: 4) {
                    Text("By: ")
                        .font(.system(size: 16))
                        .foregroundColor(.gray) +
                    Text(authors.joined(separator: ", "))
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .underline()
                }
            }
        }
    }
}

// 메인 상세 페이지
struct BookDetailPage: View {
    @Environment(\.presentationMode) var presentationMode
    var bookDetail: BookDetail?
    @State private var isRegisterPressed = false  // 버튼 눌림 상태 추가
    
    // 등록 버튼 컴포넌트
    private var registerButton: some View {
        Button(action: {
            // 등록 버튼 액션
        }) {
            Text("등록")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(ColorFun.buttonText)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .frame(width: 140)
                .background(ColorFun.buttonBackground)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black.opacity(0.3), lineWidth: 1.5)
                )
                .scaleEffect(isRegisterPressed ? 0.95 : 1.0)  // 눌림 효과
                .animation(.easeInOut(duration: 0.1), value: isRegisterPressed)  // 애니메이션
        }
        .simultaneousGesture(  // 터치 제스처 추가
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isRegisterPressed = true
                }
                .onEnded { _ in
                    isRegisterPressed = false
                }
        )
        .buttonStyle(PlainButtonStyle())
    }
    
    var body: some View {
        ZStack {
            // 배경색 설정
            ColorFun.background
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // 네비게이션 헤더
                AddHeader(title: "책 정보") {
                    presentationMode.wrappedValue.dismiss()
                }
                
                ScrollView {
                    VStack(spacing: 0) {
                        HStack {
                            Spacer(minLength: 0)
                            
                            // 컨텐츠 컨테이너
                            HStack(alignment: .top, spacing: 24) {
                                // 책 표지 이미지
                                BookCoverImage(thumbnailUrl: bookDetail?.thumbnailUrl)
                                
                                // 오른쪽 컨텐츠 영역
                                VStack(alignment: .leading) {
                                    // 책 정보
                                    BookInfoView(
                                        title: bookDetail?.title ?? "",
                                        authors: bookDetail?.authors
                                    )
                                    
                                    Spacer(minLength: 0)  // 유연한 공간 확보
                                    
                                    // 등록 버튼
                                    registerButton
                                }
                                .frame(height: 180)  // 이미지 높이와 동일하게 설정
                            }
                            .frame(maxWidth: 500)
                            .padding(.horizontal, 20)
                            
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 5)
                        
                        // 구분선
                        Rectangle()
                            .frame(height: 5)
                            .foregroundColor(Color.black.opacity(0.2))
                            .padding(.horizontal, 36)
                            .padding(.top, 10)
                        
                        // 책 설명
                        if let description = bookDetail?.description {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("요약: ")
                                    .font(.system(size: 18, weight: .bold))
                                    .padding(.bottom, 4)
                                
                                Text(description)
                                    .font(.system(size: 16))
                                    .lineSpacing(8)  // 줄 간격
                                    .fixedSize(horizontal: false, vertical: true)  // 자동 줄바꿈
                                    .multilineTextAlignment(.leading)  // 왼쪽 정렬
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 36)
                            .padding(.top, 20)
                            .padding(.bottom, 24)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
        .navigationBarHidden(true)
        .onAppear {
            // 페이지 방문 시 자동 저장
            if let bookDetail = bookDetail {
                CoreDataManager.shared.saveRecentBook(bookDetail)
            }
        }
    }
}

#Preview {
    BookDetailPage(bookDetail: nil)
}
