# Speedy

##### Welcome to Speedy! A concise reactive Swift property observation framework.

###### Quick Start

* To get started with Speedy you can use [Carthage](https://github.com/Carthage/Carthage), [Cocoapods](https://cocoapods.org), or simply download the source and build for the desired OS.

> Carthage

* Ensure you have carthage installed: `brew install carthage`
* Create a `Cartfile` in your chosen directory with the following contents:

```
github "RedHandTech/Speedy"
```

* Run `carthage update`

> Cocoapods

* Add `pod 'Speedy', '~> 0.1'` to your Podfile and run `pod install`

###### Documentation

> Inspectable

* ***EVERYTHING*** in Speedy is an instance of type `Inspectable`.
* `Inspectable` allows you to filter, map and, of course, inspect values (see below for detailed examples).

> Value

* The `Value` class is the start point for making values inspectable, simply wrap your value in an instance of `Value`.
* ***ANYTHING*** can be wrapped up in `Value` (see below for detailed examples). 

##### Examples

**NOTE:** The following examples assume an MVVM environment. Speedy is particulary useful when adopting MVVM.

###### Creating Values

```swift
class MyViewModel {
	
	let myViewControllerTitle = Value("Hello, World!")
}
```

Simple as that! `myViewControllerTitle` will be of type `Value<String>`.

###### Inspecting Values

To read the value of a `Value` it's as easy as accessing the `value` property:

```swift
class MyViewController: UIViewController {
	
	let viewModel: MyViewModel ....

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		title = viewModel.myViewControllerTitle.value
	}
}
```

To setup reactive inspection:

```swift
class MyViewController: UIViewController {
	
	let viewModel: MyViewModel ....

	override func viewDidLoad() {
		super.viewDidLoad()

		// setup inspections
		weak var weakSelf = self // IMPORTANT
		viewModel.myViewControllerTitle.inspect { weakSelf?.title = $0 }
	}
}
```

This will setup a callback on the `myViewControllerTitle` value in the `viewModel` that is called every time the value is changed.
This means that the view model only has to call `myViewControllerTitle.value = "Goodbye, World!"` and the callback will be invoked.
**NOTE** the importance of creating a weak instance of self for use in the closures. This is because in this situation the view controller owns the view model which in turn owns the the value which owns the closure. 

###### Filtering Value Inspections

What if you have the following view model:

```swift
class MyViewModel {
	
	let rows = Value(0)
}
```

And in your view controller you want to use this value to provide data to a `UITableView`.
You want to realod the table every time the value changes right? So...

```swift 
class MyViewController: UIViewController {
	
	let viewModel: MyViewModel ...

	override func viewDidLoad() {
		super.viewDidLoad()

		weak var weakSelf = self
		viewModel.rows.inspect { _ in weakSelf?.tableView?.reloadData() }
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.rows.value
	}
}
```

Great! But what if `rows.value` is a negative number? We dont really want to be calling reaload data then. Speedy allows you to filter out negative numbers like so:

```swift
class MyViewController: UIViewController {
	
	let viewModel: MyViewModel ...

	override func viewDidLoad() {
		super.viewDidLoad()

		weak var weakSelf = self
		viewModel.rows.when { $0 >= 0 }
					  .inspect { _ in weakSelf?.tableView?.reloadData() }
	}
}	
``` 

***Only*** when the condition in the `when` closure evaluates to `true` will the sequence of events continue.

###### Transforming Value Inspections

Lets say we have a basic value set up like so:

```swift
class MyViewModel {
	
	let favoriteNumber = Value(7)
}
```

In our view controller we want to do something trivial like display a label with text `"My favorite nunber is 7"` but we want the label to be dynamic, i.e when the `favoriteNumber`  value changes the label needs to update.
Speedy allows you to transform the value which can be something as simple as:

```swift
class MyViewController: UIViewController {
	
	let viewModel: MyViewModel ....

	override func viewDidLoad() {
		super.viewDidLoad()

		weak var weakSelf = self
		viewModel.favoriteNumber.map { String(format: "My favorite number is: %i", $0) }
								.inspect { weakSelf?.label?.text = $0 }
	}
}
```

Now lets say that *if the `favouriteNumber.value` is 9* you want to change it to 8 (dont ask why...):

```swift
class MyViewController: UIViewController {
	
	let viewModel: MyViewModel ....

	override func viewDidLoad() {
		super.viewDidLoad()

		weak var weakSelf = self
		viewModel.favoriteNumber.map { $0 == 9 ? 8 : $0 }
								.map { String(format: "My favorite number is: %i", $0) }
								.inspect { weakSelf?.label?.text = $0 }
	}
}
```

Now what if the `favoriteNumber.value` is an optional and you only want to update the label if it's not nil:

 ```swift
class MyViewController: UIViewController {
	
	let viewModel: MyViewModel ....

	override func viewDidLoad() {
		super.viewDidLoad()

		weak var weakSelf = self
		viewModel.favoriteNumber.when { $0 != nil }
								.map { $0! } 
								.map { String(format: "My favorite number is: %i", $0) }
								.inspect { weakSelf?.label?.text = $0 }
	}
}
```

Or if you want to always update the label but if the value is nil transform it to `0`:

 ```swift
class MyViewController: UIViewController {
	
	let viewModel: MyViewModel ....

	override func viewDidLoad() {
		super.viewDidLoad()

		weak var weakSelf = self
		viewModel.favoriteNumber.map { $0 ?? 0 } 
								.map { String(format: "My favorite number is: %i", $0) }
								.inspect { weakSelf?.label?.text = $0 }
	}
}
```

The possibilities are endless!

###### Sequences

As you may have noticed, Speedy supports sequences of `Inspectables` every call to `where`, `map` and `watch` returns another instance of `Inspectable` so you can continue to manipulate values.

This allows you to do something as simle as:

```swift
class MyViewController: UIViewController {
	
	let viewModel: MyViewModel ....

	override func viewDidLoad() {
		super.viewDidLoad()

		weak var weakSelf = self
		viewModel.coolValue.inspect { weakSelf?.doSomethingCool($0) }
	}
}
```

To something as complex as:

```swift
class MyViewModel {
	
	let repeatable: Value<(String?, Int)> = Value(("Hello, World!", 10))
}
```

```swift
class MyViewController: UIViewController {
	
	let viewModel: MyViewModel ....

	var tableData: [String] = []

	override func viewDidLoad() {
		super.viewDidLoad()

		weak var weakSelf = self
		viewModel.repeatable.when { $0.0 != nil }
							.map { ($0.0!, $0.1) }
							.watch { weakSelf?.doCoolThingWithString($0.0) }
							.when { $0.0 != "Goodbye, World!" }
							.when { $0.1 >= 0 }
							.map { (t: (String, Int)) -> [String] 
								var array: [String] = []
								for _ in 1...t.1 {
									arr.append(t.0)
								}
								return array
							}.inspect { array in
								weakSelf?.tableData = array
								weakSelf?.tableView?.reloadData()
							}

	}
}
```

###### Old Values

You can access the old value of a given value by accessing the `oldValue` property (funnily enough...).

```swift
let myVal = Value(10)

print(myVal.oldValue) // output nil

myVal.value = 1

print(myVal.oldValue) // output 10
```

There are also a few functions built around the old value:

- ***Compare*** allows you to quickly compare the old value with the new value and decide whether to continue the chain:

```swift
let myVal = Value(0)
        
myVal.compare { $0 == ($1 ?? 0) + 1 }
    .inspect { print("Incremented \($0 - 1) by 1 is now \($0)") }

myVal.value += 1 // outputs: "Incremented 0 by 1 is now 1."
myVal.value += 1 // outputs: "Incremented 1 by 1 is now 2"
myVal.value += 2 // no output
```

- ***Distinct*** provides a quick and easy interface to ensure that the new value is not the same as the old value:

```swift
let val = Value("Hello")

val.distinct()
   .inspect { print("New distinct value: \($0)") }
val.value = "Hello" // no output
val.value = "Hello, World!" // output: "New distinct value: Hello, World!"
```

Cool huh?










