import SwiftUI

// 책 카드 컴포넌트
struct RecentlyBookCard: View {
    let title: String
    let authors: String
    let thumbnailUrl: String?
    @StateObject private var imageLoader = ImageLoader()
    
    var body: some View {
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
            
            Text(authors)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .lineLimit(1)
        }
        .frame(width: 120)
    }
}
