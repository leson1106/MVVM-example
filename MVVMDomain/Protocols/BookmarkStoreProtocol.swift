import Foundation

public protocol BookmarkStoreProtocol {
    func bookmarkedIds() -> Set<String>
    func isBookmarked(id: String) -> Bool
    func setBookmarked(id: String, bookmarked: Bool)
}
