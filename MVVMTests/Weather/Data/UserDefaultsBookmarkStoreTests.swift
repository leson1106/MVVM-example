import MVVMDomain
import XCTest
@testable import MVVMNetwork

final class UserDefaultsBookmarkStoreTests: XCTestCase {
    private var defaults: UserDefaults!
    private var store: UserDefaultsBookmarkStore!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "UserDefaultsBookmarkStoreTests")!
        defaults.removePersistentDomain(forName: "UserDefaultsBookmarkStoreTests")
        store = UserDefaultsBookmarkStore(defaults: defaults, storageKey: "test.bookmarks")
    }

    func test_setBookmarked_persistsAndReadsBack() {
        // when
        store.setBookmarked(id: "2024-03-18", bookmarked: true)

        // then
        XCTAssertTrue(store.isBookmarked(id: "2024-03-18"))
        XCTAssertEqual(store.bookmarkedIds(), ["2024-03-18"])
    }

    func test_setBookmarked_false_removesId() {
        // given
        store.setBookmarked(id: "2024-03-18", bookmarked: true)

        // when
        store.setBookmarked(id: "2024-03-18", bookmarked: false)

        // then
        XCTAssertFalse(store.isBookmarked(id: "2024-03-18"))
        XCTAssertTrue(store.bookmarkedIds().isEmpty)
    }
}
