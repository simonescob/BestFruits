//
//  ImageCache.swift
//  BestFruits
//
//  Performance-optimized image caching system.
//

import Foundation
import UIKit
import Combine
import CommonCrypto

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
                let url = self.diskCacheURL.appendingPathComponent(key)
                
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
            let url = self.diskCacheURL.appendingPathComponent(key)
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

// MARK: - Extensions

// File contains only UIKit-based image caching infrastructure