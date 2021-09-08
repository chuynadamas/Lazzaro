---
date: 2021-09-06 21:39
description: Subsctipt a dictionary? - No problem ☄️
tags: Article, Swift
---

# Subscript a Dictonary in swift

## The power of subscription in swift

The dictionary are a super helpful tool given by foundation in swift, but we can make it even powerful with the powe of subscript, 
let see the example with the current user here in the site.
<br/>
I'll crete a new dictionary with to handle the color of my labels, something like this:
```swift
private struct Utils {
    static let tagVariants = [
        "Article" : "variant-a",
        "Assembly" : "variant-b"
        "Swift": "variant-c"
    ]
}
```
<br/>
This is a pretty simple dictionary but every time we wan't to use any variant for the color in the css we have to call something like the 
following `Utils.tagVariants[safeKey: tag.string]` this is `O(1)` but the result will be an optinal string `String?` becuase could be the scenario 
with the dictionary fails triying to find our value. 
<br/>
In that se have to unwrap every time we use in our code, to be sure the key already has a value
```swift
if let actualValue = Utils.tagVariants["Article"] {
//Do the rest...
}
```
<br/>
This is a good practice but if you are a little bit lazy like me we can make a safe access for the subscription, something like this
<br/> 
```swift
import Foundation

extension Dictionary where Key == String, Value == String {
    subscript(safeKey key: Key) -> Value {
        get {
            return self[key] ?? ""
        }
    }
}
``` 
<br/>
With that every time we use our new function `[safeKey]` we are ensure that the result will be a value, and if the tag doesn't have any style we 
need to be sure that we have an associated type in our current dictionary. 
<br/>
As an example now we can use the following way to acces our variants!
```swift
Utils.tagVariants[safeKey: tag.string]
```
<br/>
Just directly without using any `guard` of `if let` logic. This is faster, but also cames with a great responsability because you have to be sure \
that all the values that you'll use have to be in your ditionary in other case you won't have a crash... Yes, sometimes crash are good, they can 
help us to find some holes in our code. 
<br/>
With great power comes great responsibility -- Uncle Ben 🕸


