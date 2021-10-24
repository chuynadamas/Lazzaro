---
date: 2021-09-25 3:13
description: Explanation about the opaque return types in swift 🐦
tags: Article, Swift
---

# Opaque return types in swift 🤪

<a class="disclaimer" href="https://www.donnywals.com/understanding-opaque-return-types-in-swift-5-1/">
    This is a rewrite of the post from Donny Wals, if you are reading this pleae see the original content at Donny Wals I'm not making any money of this blog is only my personal studies purposes.
</a>

## Some background

If you have spent some time with SwiftUI, you may have noticed that views in SwiftUI have a property called `body` of type `some View`. If want to go deeper please see the following [SE-0244](https://github.com/apple/swift-evolution/blob/master/proposals/0244-opaque-result-types.md)

## `Some` keyboard

In Swift, we can use protocols to define interfaces or contracts for our objects. When something conforms to a protocol, we know that it can do certain things, or has certain properties. This means that you can writr code like this:

```swfit
protocol ListItemDisplayable {
  var name: String { get }
}

struct Shoe: ListItemDisplayable {
  let name: String
}

var listItem: ListItemDisplayable = Shoe(name: "a shoe")
```
<br/>
When using this `listItem` property, only the properties exposed by `ListItemDisplayable` are exposed to us. This is especially useful when you want to have an array of items that are `ListItemDisplayable` where concrete types can be more than just `Shoe`
<br/>

```swfit
struct Shoe: ListItemDisplayable {
  let name: String
}

struct Shorts: ListItemDisplayable {
  let name: String
}

var mixedList: [ListItemDisplayable] = [Shoe(name: "a shoe"),
                                        Shorts(name: "a pair of shorts")]
```
<br/>
The compiler treats our `Shoe` and `Shorts` objects as `ListItemDisplayable`, so users of this list won't know whether they're dealing with shoes, shorts, jeans or anything else. All they know is that whatever is in the array can be displayed in a list because ir conforms to `ListDisplayable`.
<br/>
## Opaque result types for protocols with associated types

The flexible shown in the previous section is really cool, but we can push our code further:
<br/>
```swift
protocol ListDataSource {
  associatedtype ListItem: ListItemDisplayable

  var items: [ListItem] { get }
  var numberOfItems: Int { get }
  func itemAt(_ index: Int) -> ListItem
}
```
<br/>
The above defines a `ListDataSource` that holds some list of an item that conforms to `ListItemDisplayable`. We can use objects that conform to this protocol as data source objects for table views, or collection views which is preatty neat.
<br/>
We can define a view model generator object that will, depending on what kind of items we pass it, generate a `ListDataSource:`
<br/>
```swift
struct ShoesDataSource: ListDataSource {
  let items: [Shoe]
  var numberOfItems: Int { items.count }

  func itemAt(_ index: Int) -> Shoe {
    return items[index]
  }
}

struct ViewModelGenerator {
  func listProvider(for items: [Shoe]) -> ListDataSource {
    return ShoesDataSource(items: items)
  }
}
```
<br/>
However, this code doesn't compile because `ListDataSource` is a protocol with associated type constraints. We could fix this by specifiying `ShoesDataSource` as the return type instead of `ListDataSource`, but this would expose an implementation detail that we wanto to hide from users of the `ViewModelGenerator`. 
<br/>
Callers of `listProvider(for:)` only really need to know is that we're going to return a `ListDataSource` from this method. We can rewrite the generators as follos make our code compile:
<br/>
```swift
struct ViewModelGenerator {
  func listProvider(for items: [Shoe]) -> some ListDataSource {
    return ShoesDataSource(items: items)
  }
}
```
<br/>
By using the `some` keyword, the compiler can enforce a couple of things while hiding them from the caller of `listProvides(for:)`:
<br/>
<ul class="ul-normal">
    <li class="li-normal">We return something that conforms to<code>ListDataSource</code></li>
    <li class="li-normal">The returned object's associated type matches any requirements that are set by<code>ListDataSource</code></li>
    <li class="li-normal">We always return the same type from<code>listProvider(for:)</code></li>
</ul>

<br/>
<br/>

Especially this last point is interesting. In Swift, we rely on the compiler to do a lot of compile-time type checks to help us write safe and consistent code. And in turn, the compiler uses all of this information about types to optimize our code to ensure it runs as fast as possible. Protocols are often a problem for the compiler because they imply a certain dynamism that makes it hard for the compiler to make certain optimizations at compile time which means that we’ll take a *(very small)* performance hit at runtime because the runtime will need to do some type checking to make sure that what’s happening is valid.
<br/>

Because the Swift compiler can enforce the things listed above, it can make the same optimizations that it can when we would use concrete types, yet we have the power of hiding the concrete type from the caller of a function or property that returns an opaque type.
<br/>

## Opaque result types and Self requirements

Because the compiler can enforce type constraints compile time, we can do other interesting things. For example, we can compare items that are returned as opaque types while we cannot do the same with protocols. Let’s look at a simple example:
<br/>

```swift
protocol ListItemDisplayable: Equatable {
  var name: String { get }
}

func createAnItem() -> ListItemDisplayable {
  return Shoe(name: "a comparable shoe: \(UUID().uuidString)")
}
```

<br/>
The above doesn’t compile because `Equatable` has a `Self` requirement. It wants to compare two instances of `Self` where both instances are of the same type. This means that we can’t use `ListItemDisplayable` as a regular return type, because a protocol on its own has no type information. We need the `some` keyword here so the compiler will figure out and enforce a type for `ListItemDisplayable` when we call `createAnItem():`
<br/>
```swift
func createAnItem() -> some ListItemDisplayable {
  return Shoe(name: "a comparable shoe: \(UUID().uuidString)")
}
```
<br/>
The compiler can now determine that we’ll always return `Shoe` from this function, which means that it knows what `Self` for the item that’s returned by `createAnItem()`, which means that the item can be considered `Equatable`. This means that the following code can now be used to create two items and compare them:
<br/>

```swift
let left = createAnItem()
let right = createAnItem()

print(left == right)
```

<br/>
What’s really cool here is that both `left` and `right` hide all of their type information. If you call `createAnItem()`, all you know is that you get a `list` item back. And that you can compare that list item to other list items returned by the same function.
<br/>
## Opaque return types as reverse generics

The Swift documentation on opaque result types sometimes refers to them as reverse generics which is a pretty good description. Before opaque result types, the only way to use protocols with associated types as a return type would have been to place the protocol on a generic constraint for that method. The downside here is that the caller of the method gets to decide the type that’s returned by a function rather than letting the function itself decide:
<br/>
```swift
protocol ListDataSource {
  associatedtype ListItem: ListItemDisplayable

  var items: [ListItem] { get }ƒ
  var numberOfItems: Int { get }
  func itemAt(_ index: Int) -> ListItem

  init(items: [ListItem])
}

func createViewModel<T: ListDataSource>(for list: [T.ListItem]) -> T {
  return T.init(items: list)
}

func createOpaqueViewModel<T: ListItemDisplayable>(for list: [T]) -> some ListDataSource {
  return GenericViewModel<T>(items: list)
}

let shoes: GenericViewModel<Shoe> = createViewModel(for: shoeList)
let opaqueShoes = createOpaqueViewModel(for: shoeList)
```
<br/>
Both methods in the preceding code return the exact same `GenericViewModel` in this example. The main difference here is that in the first case, the caller decides that it wants to have a `GenericViewModel<Shoe>` for its list of shoes, and it will get a concrete type back of type `GenericViewModel<Shoe>`. In the opaque example, the caller only decides that it wants some `ListDataSource` that holds its list of `ListItemDisplayable` items. This means that the implementation of `createOpaqueViewModel` can now decide what it wants to do. In this case, we chose to return a generic view model. We could also have chosen to return a different kind of view model instead, all that matters is that we always return the same type and that it conforms to `ListDataSource`.

## Using opaque return types in your projects

While I was studying opaque return types and trying to come up with examples for this post, I noticed that it’s not really easy to come up with reasons to use opaque return types in common projects. In SwiftUI they serve a key role, which might make you believe that opaque return types are going to be commonplace in a lot of projects at some point.
<br/>
Personally, I don’t think this will be the case. Opaque return types are a solution to a very specific problem in a domain that most of us don’t work on. If you’re building frameworks or highly reusable code that should work across many projects and codebases, opaque result types will interest you. You’ll likely want to write flexible code based on protocols with associated types where you, as the builder of the framework, have full control of the concrete types that are returned without exposing any generics to your callers.
<br/>
Another consideration for opaque return types might be their runtime performance. As discussed earlier, protocols sometimes force the compiler to defer certain checks and lookups until runtime which comes with a performance penalty. Opaque return types can help the compiler make compile-time optimizations which is really cool, but I’m confident that it won’t matter much for most applications. Unless you’re writing code that really has to be optimized to its core, I don’t think the runtime performance penalty is significant enough to throw opaque result types at your codebase. Unless, of course, it makes a lot of sense to you. Or if you’re certain that in your case the performance benefits are worth it.
<br/>
What I’m really trying to say here is that protocols as return types aren’t suddenly horrible for performance. In fact, they sometimes are the only way to achieve the level of flexibility you need. For example, if you need to return more than one concrete type from your function, depending on certain parameters. You can’t do that with opaque return types.
<br/>
This brings me to quite possibly the least interesting yet easiest way to start using opaque return types in your code. If you have places in your code where you’ve specified a protocol as return type, but you know that you’re only returning one kind of concrete type from that function, it might make sense to use an opaque return type instead.
## In summary
You learned that opaque return types can act as a return type if you want to return an object that conforms to a protocol with associated type constraints. This works because the compiler performs several checks at compile time to figure out what the real types of a protocol’s associated types are. You also saw that opaque return types help resolve so-called Self requirements for similar reasons. Next, you saw how opaque result types act as reverse generics in certain cases, which allows the implementer of a method to determine a return type that conforms to a protocol rather than letting the caller of the method decide.
<br/>
> With great power comes great responsibility -- Uncle Ben 🕸


