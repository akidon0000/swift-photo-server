import Vapor

// MARK: - MetadataStore

struct MetadataStoreKey: StorageKey {
    typealias Value = any MetadataStore
}

extension Application {
    var metadataStore: any MetadataStore {
        get {
            guard let store = storage[MetadataStoreKey.self] else {
                fatalError("MetadataStore not configured. Call configure() first.")
            }
            return store
        }
        set {
            storage[MetadataStoreKey.self] = newValue
        }
    }
}

// MARK: - PhotoStorageService

struct PhotoStorageServiceKey: StorageKey {
    typealias Value = any PhotoStorageService
}

extension Application {
    var photoStorageService: any PhotoStorageService {
        get {
            guard let service = storage[PhotoStorageServiceKey.self] else {
                fatalError("PhotoStorageService not configured. Call configure() first.")
            }
            return service
        }
        set {
            storage[PhotoStorageServiceKey.self] = newValue
        }
    }
}
