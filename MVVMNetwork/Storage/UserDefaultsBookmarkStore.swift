import MVVMDomain
import Foundation

public final class UserDefaultsBookmarkStore: BookmarkStoreProtocol {
    private let defaults: UserDefaults
    private let storageKey: String

    public init(defaults: UserDefaults = .standard, storageKey: String = "weather.bookmarked.ids") {
        self.defaults = defaults
        self.storageKey = storageKey
    }

    public func bookmarkedIds() -> Set<String> {
        Set(defaults.stringArray(forKey: storageKey) ?? [])
    }

    public func isBookmarked(id: String) -> Bool {
        bookmarkedIds().contains(id)
    }

    public func setBookmarked(id: String, bookmarked: Bool) {
        var ids = bookmarkedIds()
        if bookmarked {
            ids.insert(id)
        } else {
            ids.remove(id)
        }
        defaults.set(Array(ids).sorted(by: >), forKey: storageKey)
    }
}
