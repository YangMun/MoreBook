import CoreData
import Foundation

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    // CoreData 컨테이너
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BookModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("CoreData 스토어 로딩 실패: \(error)")
            }
        }
        return container
    }()
    
    // Context 가져오기
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    // 변경사항 저장
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("CoreData 저장 실패: \(error)")
            }
        }
    }
    
    // 최근 본 도서 저장
    func saveRecentBook(_ bookDetail: BookDetail) {
        let fetchRequest: NSFetchRequest<RecentBook> = RecentBook.fetchRequest()
        
        do {
            // 1. 이미 존재하는 도서인지 확인
            fetchRequest.predicate = NSPredicate(format: "id == %@", bookDetail.id)
            let existing = try context.fetch(fetchRequest)
            
            if let existingBook = existing.first {
                // 2. 존재하면 viewedAt만 업데이트
                existingBook.viewedAt = Date()
            } else {
                // 3. 전체 개수 확인
                let countRequest = RecentBook.fetchRequest()
                let count = try context.count(for: countRequest)
                
                // 4. 10개 이상이면 가장 오래된 것 삭제
                if count >= 10 {
                    let oldestFetch = RecentBook.fetchRequest()
                    oldestFetch.sortDescriptors = [NSSortDescriptor(key: "viewedAt", ascending: true)]
                    oldestFetch.fetchLimit = 1
                    
                    if let oldestBook = try context.fetch(oldestFetch).first {
                        context.delete(oldestBook)
                    }
                }
                
                // 5. 새 도서 추가
                let newBook = RecentBook(context: context)
                newBook.id = bookDetail.id
                newBook.title = bookDetail.title
                newBook.authors = bookDetail.authors?.joined(separator: ", ")  // 저자들을 쉼표와 공백으로 구분
                newBook.bookDescription = bookDetail.description
                newBook.thumbnailUrl = bookDetail.thumbnailUrl
                newBook.viewedAt = Date()
                newBook.publishedDate = bookDetail.publishedDate
                newBook.pageCount = Int32(bookDetail.pageCount ?? 0)
                newBook.language = bookDetail.language
            }
            
            // 6. 저장
            saveContext()
            print("저장 성공")
            
        } catch {
            print("최근 본 도서 저장 실패: \(error)")
        }
    }
    
    // 최근 본 도서 목록 가져오기
    func fetchRecentBooks() -> [RecentBook] {
        let fetchRequest: NSFetchRequest<RecentBook> = RecentBook.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "viewedAt", ascending: false)]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("최근 본 도서 조회 실패: \(error)")
            return []
        }
    }
}
