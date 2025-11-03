//
//  ImageCache.swift
//  BestFruits
//
//  Performance-optimized image caching system.
//

import Foundation
import UIKit
import Combine

/// Thread-safe image cache with LRU eviction
class ImageCache {
    static let shared = ImageCache()
    
    private var cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 50 // Max 50 images in memory
        cache.totalCostLimit = 25 * 1024 * 1024 // 25MB memory limit
        return cache
    }()
    
    private var diskCacheURL: URL {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent("ImageCache")
    }
    
    private let imageQueue = DispatchQueue(label: "image.cache", qos: .userInitiated)
    
    private init() {
        setupDiskCache()
    }
    
    /// Get image from cache (memory or disk)
    func image(forKey key: String) async -> UIImage? {
        // Check memory cache first
        if let image = cache.object(forKey: NSString(string: key)) {
            return image
        }
        
        // Check disk cache
        return await withCheckedContinuation { continuation in
            imageQueue.async {
                let url = self.diskCacheURL.appendingPathComponent(key.sha256())
                
                guard let data = try? Data(contentsOf: url),
                      let image = UIImage(data: data) else {
                    continuation.resume(returning: nil)
                    return
                }
                
                // Store in memory cache
                self.cache.setObject(image, forKey: NSString(string: key))
                continuation.resume(returning: image)
            }
        }
    }
    
    /// Store image in cache (memory and disk)
    func store(_ image: UIImage, forKey key: String) {
        // Store in memory cache
        cache.setObject(image, forKey: NSString(string: key))
        
        // Store in disk cache asynchronously
        imageQueue.async {
            let url = self.diskCacheURL.appendingPathComponent(key.sha256())
            guard let data = image.pngData() else { return }
            
            try? data.write(to: url)
        }
    }
    
    /// Clear all caches
    func clearCache() {
        cache.removeAllObjects()
        
        imageQueue.async {
            try? FileManager.default.removeItem(at: self.diskCacheURL)
            self.setupDiskCache()
        }
    }
    
    private func setupDiskCache() {
        try? FileManager.default.createDirectory(
            at: diskCacheURL,
            withIntermediateDirectories: true
        )
    }
}

/// Extension for AsyncImage with caching
struct CachedAsyncImage: View {
    let url: URL
    let placeholder: Image
    @State private var cachedImage: UIImage?
    
    var body: some View {
        Group {
            if let cachedImage = cachedImage {
                Image(uiImage: cachedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .onAppear {
                                cacheImage(image)
                            }
                    case .failure:
                        placeholder
                    default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(placeholder)
                    }
                }
            }
        }
        .clipped()
        .cornerRadius(12)
        .task {
            await loadCachedImage()
        }
    }
    
    private func cacheImage(_ image: Image) {
        if let uiImage = image.asUIImage() {
            ImageCache.shared.store(uiImage, forKey: url.absoluteString)
        }
    }
    
    private func loadCachedImage() async {
        cachedImage = await ImageCache.shared.image(forKey: url.absoluteString)
    }
}

// MARK: - Extensions

extension Image {
    func asUIImage() -> UIImage? {
        let controller = UIHostingController(rootView: self)
        controller.view.frame = CGRect(x: 0, y: 0, size: CGSize(width: 1, height: 1))
        
        if let view = controller.view {
            UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        
        return nil
    }
}

extension String {
    func sha256() -> String {
        guard let data = self.data(using: .utf8) else { return self }
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { bytes in
            _ = CC_SHA256(bytes.baseAddress, CC_LONG(bytes.count), &hash)
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

import CommonCrypto