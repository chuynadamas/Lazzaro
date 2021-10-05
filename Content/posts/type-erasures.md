---
date: 2021-10-03 21:39
description: Type Erasures in Swift ✏️
tags: Article, Swift, Combine
---

# Type erasures in Swift 🤔

## 

<a class="disclaimer" href="https://www.donnywals.com/understanding-type-erasure-in-swift/">
    This is a rewrite of the post from Donny Wals, if you are reading this pleae see the original content at Donny Wals I'm not making any money of this blog is only my personal studies purposes.
</a>

## Some background

With protocols and generics, you can express ideas that are complex and flexible. But sometimes you are coding along happily and the Swift compiler starts yelling at you. You've hit one of those scenarios where your code is so flexible and dynamic that Swift isn't having it. 
<br/>

If you want to write a function that returns an object that conforms to a protocol that has an associated type? Not going to happen unless you use an `opaque result type`!

<br/>

But what if you don't want to return the exact same concrete type from your function all time? Unfurtunately, `opaque results types` won't help you there.

When the Swift compiler keeps yelling at you and you have no idea how to make it stop. it might be time to apply some type erasure.

There are multiple scenarios where type erasure makes sense.
<br/>

## Using type erasure to hide implementation details

The most straightforward way to think of type erasure is to consider it a way to hide an objects "real" type. Some xamples that come to mind ommediately are Combine's `AnyCancellable` and `AnyPublisher`.
<br/>
`AnyPublisher` in Combine is generic over an `Output` and `Failure`. All you really need to know about `AnyPusbliser` is that conforms to the `Pusbliser` protocol and wraps another publisher. Combine comes with tons of built-in publishers like `Publisher.Map`, `Publisher.FlatMap`, `Future`, `Publisher.Filter`, and many more.
<br/>
Often when you're working with combine, you will write functions that set up a chain of publishers. You usually don't want to expose the publishers you used to callers of your function. In essence, all you want to expose is that you're creating a publisher that emits values of a certain type `Output` or fails with a specific error `Failirue`. So instead of writing this:

```swift
func fetchData() -> URLSession.DataTaskPublisher<(data: Data, response: URLResponse), URLError> {
  return URLSession.shared.dataTaskPublisher(for: someURL)
}
```
<br/>
You will usually want to write this:
<br/>

```swift
func fetchData() -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
  return URLSession.shared.dataTaskPublisher(for: someURL)
    .eraseToAnyPublisher()
}
```
<br/>
By appliying type erasure to the publisher created in `fetchData` we are now free to change its implementation as needed, and callers of `fetchData` don't need to care about the exact publisher that's used under the hood.
<br/>
When you thinkg about how you can refactor this code, you might be tempted to try and use a protocol instead of an `AnyPublisher`. And you'd be right to wonder why we wouldn't.
<br/>
Since `Publisher` has an `Output` and `Failure` that we want to be able to use, using `some Publisher` wouldn't work. We wouldn't be able to return `Publisher` due its associated type constraints, so returning `some Publisher` would allow the code to compile but it would be pretty useless:
<br/>
```swift
func fetchData() -> some Publisher {
  return URLSession.shared.dataTaskPublisher(for: someURL)
}

fetchData().sink(receiveCompletion: { completion in
  print(completion)
}, receiveValue: { output in
  print(output.data) // Value of type '(some Publisher).Output' has no member 'data'
})
```
<br/>
Because `some Publisher` hides the true type of the generic used by `Publisher`, there is no way to do anything useful with the `output` or `completion` in this example. An `AnyPublisher` hides the underlying type just like `some Publisher` does, exept you can still define what the `Output` and `Failure` types are for the publisher by writing `AnyPublisher<Output,Failure>`
<br/>
If you use `Combine`, you will encounter `AnyCancellable` when you subscribe to a publisher useing one of Combine's built-in subscription methods.
<br/>
Without going too much detail, Combine has a protocol called `Cancellable`. This protocol requires that conforming objects implement a `cancel` method that can be called to cancel a subscription to a publisher's output. Combine provides three objects that conform to `Cancellable:`
<br/>

- `AnyCancellable`
- `Suscribers.Assugn`
- `Subscribers.Sink`

<br/>

The `Assign` and `Sink` subscribrers match up with two of `Publishers`'s methods:

<br/>

- `assign(to:on:)`
- `sink(receiveCompletion:receiveValue)`

<br/>
These two methods both return `AnyCancellable` instances rather than `Subscribers.Assign` and `Subscribers.Sink`. Apple could have chosen to make both of these methods return `Cancellable` instead of `AnyCancellable`.
<br/>

But they didn't


<br/>

The reason Apple applies type erasure in this example is that thery don't want users of `assign(to:on:)` and `sink(receiveCompletion:receiveValue)` to know which type is returned exactly. It simply doen't matter. All you need to know is that it's an `AnyCancellable`. Not just that it's `Cancellable`, but that it coul be any `Cancellable`.
<br/>
Because `AnyCancellable` erases the type of the original `Cancellable` by wrapping it, you don't know if the `AnyCancellable` wraps a `Subscriber.Sink` or some other kind of internal, private `Cancellable` that we're not supposed to know about.
<br/>
If you have a need to hide implementation details in your code, or if you run into a case where you want to return an object that conforms to a protocol that has an associated type that you need to access without returning the actual type of object you wanted to return, type erasure just might be what you're looking for.
<br/>
## Applying type erasure in your codebase

Too apply type erasure to an object, you need to define a wrapper. Let's look at an example:

```swift
protocol DataStore {
  associatedtype StoredType

  func store(_ object: StoredType, forKey: String)
  func fetchObject(forKey key: String) -> StoredType?
}

class AnyDataStore<StoredType>: DataStore {
  private let storeObject: (StoredType, String) -> Void
  private let fetchObject: (String) -> StoredType?

  init<Store: DataStore>(wrappedStore: Store) where Store.StoredType == StoredType {
    self.storeObject = wrappedStore.store
    self.fetchObject = wrappedStore.fetchObject
  }

  func store(_ object: StoredType, forKey key: String) {
    storeObject(object, key)
  }

  func fetchObject(forKey key: String) -> StoredType? {
    return fetchObject(key)
  }
}
```
<br/>
This example defines a `DataStore` protocol and a type erasing wrapper called `AnyDataStore`. The purpose of the `AnyDataStore` is to provide an abstraction that hides the underlying data store entirely. Much like `Combine` `AnyPublisher`. The `AnyDataStore` object makes extensive use of generics, 
<br/>
The `AnyDataStore` itself is generic over `StoredType`. This is the type of object that the undelying `DataStore` stores. The initializer for `AnyDataStore` is generic over `Store` where `Store` conforms to `DataStore` and the objects that are stored in the `Store` must match the objects stored by the `AnyDataStore`. Due to the way this wrapper is set up that should always be the case but Swift requires us to be explicit.
<br/>
We want forward any calls on `AnyDataStore` to the wrapped store. but we can't hold in tothe wrapped store since that would require making `AnyDataStore` generic over the underlying datastore. Instead, we capture references to the method we need in the `storeObject` and `fetchObject` propeerties and forward any calls to `store(_:forKey:)` and `fetchObject(forKey:)` to their respective stores references.
<br/>
```swift
class InMemoryImageStore: DataStore {
  var images = [String: UIImage]()

  func store(_ object: UIImage, forKey key: String) {
    images[key] = object
  }

  func fetchObject(forKey key: String) -> UIImage? {
    return images[key]
  }
}

struct FileManagerImageStore: DataStore {
  typealias StoredType = UIImage

  func store(_ object: UIImage, forKey key: String) {
    // write image to file system
  }

  func fetchObject(forKey key: String) -> UIImage? {
    return nil // grab image from file system
  }
}

class StorageManager {
  func preferredImageStore() -> AnyDataStore<UIImage> {
    if Bool.random() {
      let fileManagerStore = FileManagerImageStore()
      return AnyDataStore(wrappedStore: fileManagerStore)
    } else {
      let memoryStore = InMemoryImageStore()
      return AnyDataStore(wrappedStore: memoryStore)
    }
  }
}
```





