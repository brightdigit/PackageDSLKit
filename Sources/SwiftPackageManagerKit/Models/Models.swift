import Foundation

// Note: This file provides convenience extensions for SPM models
// All model types are available through their individual files

/// Convenience extensions for working with SPM models
extension PackageInfo {
    
    /// Find a target by name
    public func target(named name: String) -> Target? {
        return targets.first { $0.name == name }
    }
    
    /// Find a product by name
    public func product(named name: String) -> Product? {
        return products.first { $0.name == name }
    }
    
    /// Get all library products
    public var libraryProducts: [Product] {
        return products.filter {
            if case .library = $0.type {
                return true
            }
            return false
        }
    }
    
    /// Get all executable products
    public var executableProducts: [Product] {
        return products.filter {
            if case .executable = $0.type {
                return true
            }
            return false
        }
    }
}

extension Target {
    
    /// Get all product dependencies
    public var productDependencies: [String] {
        return dependencies.compactMap {
            if case .product(let productName, _, _) = $0 {
                return productName
            }
            return nil
        }
    }
    
    /// Get all by-name dependencies
    public var byNameDependencies: [String] {
        return dependencies.compactMap {
            if case .byName(let name, _) = $0 {
                return name
            }
            return nil
        }
    }
}

extension Dependency {
    
    /// Get the URL string for remote dependencies
    public var urlString: String? {
        switch self {
        case .sourceControl(let dep):
            if case .remote(let url) = dep.location {
                return url
            }
        case .fileSystem:
            return nil
        }
        return nil
    }
    
    /// Get the file path for local dependencies
    public var filePath: String? {
        switch self {
        case .sourceControl:
            return nil
        case .fileSystem(let dep):
            return dep.path
        }
    }
}