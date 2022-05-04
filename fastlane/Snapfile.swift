// Uncomment the lines below you want to change by removing the // in the beginning

class Snapshotfile: SnapshotfileProtocol {
    // A list of devices you want to take the screenshots from
    var devices: [String] { return [
        "iPhone 8 Plus",
        "iPhone 13 Pro Max",
        "iPad Pro (12.9-inch) (2nd generation)",
        "iPad Pro (12.9-inch) (3th generation)"
        ]
    }

    // locales not supported in Swift yet
    var languages: [String] { return [
        "en-US"
        ]
    }

    // The name of the scheme which contains the UI Tests
     var scheme: String? { return "Word300UITests" }
    
     var reinstallApp: Bool = true
     var clean: Bool = true
    // Where should the resulting screenshots be stored?
    // var outputDirectory: String { return "./screenshots" }

    // Clear all previously generated screenshots before creating new ones
    // var clearPreviousScreenshots: Bool { return true }

    // Choose which project/workspace to use
    // var project: String? { return "./Project.xcodeproj" }
     var workspace: String? { return "./Word300iOS.xcworkspace" }

    // Arguments to pass to the app on launch. See https://docs.fastlane.tools/actions/snapshot/#launch-arguments
    // var launchArguments: [String] { return ["-favColor red"] }

    // For more information about all available options run
    // fastlane snapshot --help
}

