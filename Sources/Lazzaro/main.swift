import Foundation
import Publish
import Plot
import AppKit
import SplashPublishPlugin

// This type acts as the configuration for your website.
struct Lazzaro: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case posts
        //case apps
        //case about
        //case resume
    }

    struct ItemMetadata: WebsiteItemMetadata {
        // Add any site-specific metadata that you want to use here.
    }

    // Update these properties to configure your website:
    var url = URL(string: "https://chuynadamas.github.io/chuynadamas/")!
    var name = "ChuyNadaMas's Personal Blog"
    var description = "Some note for my personal purposes"
    var language: Language { .english }
    var imagePath: Path? { nil }
    var favicon: Favicon? { .init(path: Path("images/asteroid.ico"), type: "image/x-icon") }
}

// This will generate your website using the built-in Foundation theme:
try Lazzaro().publish(using: [
    .copyResources(),
    .installPlugin(.splash(withClassPrefix: "")),
    .addMarkdownFiles(),
    .sortItems(by: \.date, order: .descending),
    .generateHTML(withTheme: .lazzaro),
    .unwrap(RSSFeedConfiguration.default) { config in
        .generateRSSFeed(
            including: [.posts],
            config: config
        )
    },
    .generateSiteMap(),
    .deploy(using: .gitHub("chuynadamas/blog", useSSH: true))
])


