import Foundation
import Publish
import Plot
import AppKit

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
    var name = "ChuyNadaMas's Personal Blog"
    var description = "This is the lazaro project, the blog who return from dead"
    var language: Language { .english }
    var imagePath: Path? { nil }
    
}

// This will generate your website using the built-in Foundation theme:
try Lazzaro().publish(using: [
    .copyResources(),
    .addMarkdownFiles(),
    .sortItems(by: \.date, order: .descending),
    .generateHTML(withTheme: .lazzaro),
    .generateSiteMap(),
    .deploy(using: .gitHub("chuynadamas/blog", useSSH: true))
])

//try Lazzaro().publish(
//    withTheme: .lazzaro,
//    deployedUsing: .gitHub("chuynadamas/mediocrates", useSSH: true)
//)


