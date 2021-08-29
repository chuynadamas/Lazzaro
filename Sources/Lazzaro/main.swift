import Foundation
import Publish
import Plot

// This type acts as the configuration for your website.
struct Lazzaro: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case posts
        case apps
        case about
        case resume
    }

    struct ItemMetadata: WebsiteItemMetadata {
        // Add any site-specific metadata that you want to use here.
    }

    // Update these properties to configure your website:
    var url = URL(string: "https://chuynadamas.github.io/chuynadamas/")!
    var name = "ChuyNadaMas - Project Lazaro"
    var description = "This is the lazaro project, the blog who return from dead"
    var language: Language { .english }
    var imagePath: Path? { nil }
    
}

// This will generate your website using the built-in Foundation theme:
try Lazzaro().publish(
    withTheme: .lazzaro,
    deployedUsing: .gitHub("chuynadamas/chuynadamas", useSSH: true)
)


