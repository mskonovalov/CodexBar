import Foundation

public enum ClaudeOAuthKeychainReadStrategy: String, Sendable, Codable, CaseIterable {
    case securityFramework
    case securityCLIExperimental
}

public enum ClaudeOAuthKeychainReadStrategyPreference {
    private static let userDefaultsKey = "claudeOAuthKeychainReadStrategy"
    public static let securityCLIOptInUserDefaultsKey = "claudeOAuthSecurityCLIReaderOptIn"

    #if DEBUG
    @TaskLocal private static var taskOverride: ClaudeOAuthKeychainReadStrategy?
    #endif

    public static func current(userDefaults: UserDefaults = .standard) -> ClaudeOAuthKeychainReadStrategy {
        #if DEBUG
        if let taskOverride { return taskOverride }
        #endif
        if let raw = userDefaults.string(forKey: self.userDefaultsKey) {
            let strategy = ClaudeOAuthKeychainReadStrategy(rawValue: raw) ?? .securityFramework
            if strategy == .securityCLIExperimental,
               !userDefaults.bool(forKey: self.securityCLIOptInUserDefaultsKey)
            {
                return .securityFramework
            }
            return strategy
        }
        return .securityFramework
    }

    #if DEBUG
    public static func withTaskOverrideForTesting<T>(
        _ strategy: ClaudeOAuthKeychainReadStrategy?,
        operation: () throws -> T) rethrows -> T
    {
        try self.$taskOverride.withValue(strategy) {
            try operation()
        }
    }

    public static func withTaskOverrideForTesting<T>(
        _ strategy: ClaudeOAuthKeychainReadStrategy?,
        operation: () async throws -> T) async rethrows -> T
    {
        try await self.$taskOverride.withValue(strategy) {
            try await operation()
        }
    }

    public static var currentTaskOverrideForTesting: ClaudeOAuthKeychainReadStrategy? {
        self.taskOverride
    }
    #endif
}
