import Foundation
import SwiftUI

// 도서 미리보기 정보를 담을 모델
struct BookPreview: Identifiable, Equatable {
    let id: String
    let title: String
    let authors: [String]?
    let imageUrl: String?
    
    // Book 모델에서 미리보기 모델로 변환
    init(from book: Book) {
        self.id = book.id
        self.title = book.title
        self.authors = book.authors
        // HTTP URL을 HTTPS로 변환
        if let imageUrl = book.imageUrl {
            self.imageUrl = imageUrl.replacingOccurrences(of: "http://", with: "https://")
        } else {
            self.imageUrl = nil
        }
    }
}

// 도서 정보를 담을 모델
struct Book: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let authors: [String]?
    let description: String?
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case volumeInfo
        case title
        case authors
        case description
        case imageLinks
        case smallThumbnail
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        
        let volumeInfo = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .volumeInfo)
        title = try volumeInfo.decode(String.self, forKey: .title)
        authors = try? volumeInfo.decode([String].self, forKey: .authors)
        description = try? volumeInfo.decode(String.self, forKey: .description)
        
        if let imageLinks = try? volumeInfo.nestedContainer(keyedBy: CodingKeys.self, forKey: .imageLinks) {
            imageUrl = try? imageLinks.decode(String.self, forKey: .smallThumbnail)
        } else {
            imageUrl = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        
        var volumeInfo = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .volumeInfo)
        try volumeInfo.encode(title, forKey: .title)
        try volumeInfo.encodeIfPresent(authors, forKey: .authors)
        try volumeInfo.encodeIfPresent(description, forKey: .description)
        
        if let imageUrl = imageUrl {
            var imageLinks = volumeInfo.nestedContainer(keyedBy: CodingKeys.self, forKey: .imageLinks)
            try imageLinks.encode(imageUrl, forKey: .smallThumbnail)
        }
    }
    
    // Equatable 프로토콜 구현
    static func == (lhs: Book, rhs: Book) -> Bool {
        return lhs.id == rhs.id &&
               lhs.title == rhs.title &&
               lhs.authors == rhs.authors &&
               lhs.description == rhs.description &&
               lhs.imageUrl == rhs.imageUrl
    }
    
    // 미리보기 변환 함수
    func toPreview() -> BookPreview {
        return BookPreview(from: self)
    }
}

// API 응답을 담을 모델
struct BookResponse: Codable {
    let items: [Book]?
    let totalItems: Int
}

// 도서 상세 정보를 담을 모델
struct BookDetail: Codable, Equatable {
    let id: String
    let title: String
    private let _authors: [String]?
    let publishedDate: String?
    let description: String?
    let pageCount: Int?
    let thumbnailUrl: String?
    let language: String?
    
    // 저자 이름에서 괄호와 그 안의 내용을 제거하는 계산 프로퍼티
    var authors: [String]? {
        _authors?.map { author in
            if let range = author.range(of: "\\(.*\\)", options: .regularExpression) {
                return String(author[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
            }
            return author
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case volumeInfo
        case title
        case _authors = "authors"
        case publishedDate
        case description
        case pageCount
        case imageLinks
        case thumbnail
        case language
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        
        let volumeInfo = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .volumeInfo)
        title = try volumeInfo.decode(String.self, forKey: .title)
        _authors = try? volumeInfo.decode([String].self, forKey: ._authors)
        publishedDate = try? volumeInfo.decode(String.self, forKey: .publishedDate)
        description = try? volumeInfo.decode(String.self, forKey: .description)
        pageCount = try? volumeInfo.decode(Int.self, forKey: .pageCount)
        language = try? volumeInfo.decode(String.self, forKey: .language)
        
        if let imageLinks = try? volumeInfo.nestedContainer(keyedBy: CodingKeys.self, forKey: .imageLinks) {
            thumbnailUrl = try? imageLinks.decode(String.self, forKey: .thumbnail)
        } else {
            thumbnailUrl = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        
        var volumeInfo = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .volumeInfo)
        try volumeInfo.encode(title, forKey: .title)
        try volumeInfo.encodeIfPresent(_authors, forKey: ._authors)
        try volumeInfo.encodeIfPresent(publishedDate, forKey: .publishedDate)
        try volumeInfo.encodeIfPresent(description, forKey: .description)
        try volumeInfo.encodeIfPresent(pageCount, forKey: .pageCount)
        try volumeInfo.encodeIfPresent(language, forKey: .language)
        
        if let thumbnailUrl = thumbnailUrl {
            var imageLinks = volumeInfo.nestedContainer(keyedBy: CodingKeys.self, forKey: .imageLinks)
            try imageLinks.encode(thumbnailUrl, forKey: .thumbnail)
        }
    }
}

// Google Books API 관리 클래스
class GoogleBooksAPI {
    static let shared = GoogleBooksAPI()
    private let baseURL = "https://www.googleapis.com/books/v1/volumes"
    private let apiKey: String
    
    private init() {
        // Info.plist에서 API 키 가져오기
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GoogleBooksAPI") as? String {
            self.apiKey = apiKey
        } else {
            fatalError("GoogleBooksAPI key not found in Info.plist")
        }
    }
    
    // 도서 검색 함수
    func searchBooks(query: String, startIndex: Int = 0, maxResults: Int = 10) async throws -> BookResponse {
        // URL 인코딩
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw URLError(.badURL)
        }
        
        // URL 구성
        let urlString = "\(baseURL)?q=\(encodedQuery)&startIndex=\(startIndex)&maxResults=\(maxResults)&key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        // API 호출
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // JSON 디코딩
        let bookResponse = try JSONDecoder().decode(BookResponse.self, from: data)
        return bookResponse
    }
    
    // 도서 상세 정보 조회 함수
    func fetchBookDetail(bookId: String) async throws -> BookDetail {
        // URL 구성
        let urlString = "\(baseURL)/\(bookId)?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        // API 호출
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // JSON 디코딩
        let bookDetail = try JSONDecoder().decode(BookDetail.self, from: data)
        return bookDetail
    }
}

// 도서 검색 결과를 표시하기 위한 ViewModel
class BookSearchViewModel: ObservableObject {
    @Published var bookPreviews: [BookPreview] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var hasMoreResults = true
    
    private var currentQuery = ""
    private var currentPage = 0
    private let resultsPerPage = 10
    
    func searchBooks(query: String) {
        // 빈 검색어인 경우 검색하지 않음
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        // 새로운 검색어인 경우 이전 결과 초기화
        if query != currentQuery {
            bookPreviews = []
            currentPage = 0
            hasMoreResults = true
        }
        
        currentQuery = query
        loadMoreResults()
    }
    
    func loadMoreResults() {
        // 빈 검색어이거나 이미 로딩 중이거나 더 이상 결과가 없는 경우 중단
        guard !currentQuery.isEmpty && !isLoading && hasMoreResults else { return }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                let startIndex = currentPage * resultsPerPage
                let response = try await GoogleBooksAPI.shared.searchBooks(
                    query: currentQuery,
                    startIndex: startIndex,
                    maxResults: resultsPerPage
                )
                
                DispatchQueue.main.async {
                    if let newItems = response.items {
                        self.bookPreviews.append(contentsOf: newItems.map { $0.toPreview() })
                        self.currentPage += 1
                        // 더 이상 결과가 없거나 totalItems에 도달한 경우
                        self.hasMoreResults = newItems.count == self.resultsPerPage &&
                                           self.bookPreviews.count < response.totalItems
                    } else {
                        self.hasMoreResults = false
                    }
                    self.isLoading = false
                }
                
                // 검색 결과 로깅
                print("=== 검색 결과 ===")
                print("총 \(response.totalItems)개 중 \(self.bookPreviews.count)개 로드됨")
                print("------------------------")
                
            } catch {
                print("검색 오류 발생: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    // 실제 검색 시도 중에만 오류를 설정
                    if !self.currentQuery.isEmpty {
                        self.error = error
                    }
                    self.isLoading = false
                }
            }
        }
    }
}
