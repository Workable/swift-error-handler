# ErrorHandler

[![Travis](https://travis-ci.org/Workable/swift-error-handler.svg?branch=master)](https://travis-ci.org/Workable/swift-error-handler)

> Elegant and flexible error handling for Swift

ErrorHandler enables expressing complex error handling logic with a few lines of code using a memorable fluent API.


## Installation

### CocoaPods

To integrate `ErrorHandler` into your Xcode project using CocoaPods, use the following entry in your `Podfile`:

```ruby
target '<Your Target Name>' do
    pod 'ErrorHandler'
end
```

or if you are using Alamofire and want to take advantage of the `ErrorHandler`s convenience extensions for handling `Alamofire` errors with  invalid http statuses


```ruby
target '<Your Target Name>' do
    pod 'ErrorHandler'
    pod 'ErrorHandler/Alamofire'
end
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

To integrate `ErrorHandler` into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "Workable/swift-error-handler"
```

Run `carthage update` to build the framework and drag the built `ErrorHandler.framework` into your Xcode project.

### Swift Package Manager

To integrate using Apple's Swift package manager, add the following as a dependency to your Package.swift:

```swift
import PackageDescription

let package = Package(
    name: "MyApp",
    dependencies: [
        .Package(url: "https://github.com/Workable/swift-error-handler.git", majorVersion: 0)
    ]
)
```


## Usage

Let's say we're building a messaging iOS app that uses both the network and a local database.

We need to:

### Setup a default ErrorHandler once

The default ErrorHandler will contain the error handling logic that is common across your application and you don't want to duplicate. You can create a factory that creates it so that you can get new instance with the common handling logic from anywhere in your app.

```swift
extension ErrorHandler {
    class var defaultHandler: ErrorHandler {

        return ErrorHandler()

            // Τhe error matches and the action is called if the matches closure returns true
            .on(matches: { (error) -> Bool in
                guard let error = error as? InvalidInputsError else { return false }
                // we will ignore errors with code == 5
                return error.code != 5
            }, do: { (error) in
                showErrorAlert("Invalid Inputs")
                return .continueMatching
            })

            // Variant using ErrorMatcher which is convenient if you want to
            // share the same matching logic elsewhere
            .on(InvalidStateMatcher(), do: { (_) in
                showErrorAlert("An error has occurred. Please restart the app.")
                return .continueMatching
            })

            // Handle all errors of the same type the same way
            .onError(ofType: ParsingError.self, do: { (error) in
                doSomething(with: error)
                return .continueMatching
            })

            // Handle a specific instance of an Equatable error type
            .on(DBError.migrationNeeded, do: { (_) in
                // Db.migrate()
                return .continueMatching
            })

            // You can tag matchers or matches functions in order to reuse them with a more memorable alias.
            // You can use the same tag for many matchers. This way you can group them and handle their errors together.
            .tag(NSErrorMatcher(domain: NSURLErrorDomain, code: NSURLErrorNetworkConnectionLost),
                with: "ConnectionError"
            )
            .tag(NSErrorMatcher(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet),
                with: "ConnectionError"
            )
            .on(tag: "ConnectionError") { (_) in
                showErrorAlert("You are not connected to the Internet. Please check your connection and retry.")
                return .continueMatching
            }

            // You can use the Alamofire extensions to easily handle responses with invalid http status
            .onAFError(withStatus: 401, do: { (_) in
                showLoginScreen()
                return .continueMatching
            })
            .onAFError(withStatus: 404, do: { (_) in
                showErrorAlert("Resource not found!")
                return .continueMatching
            })

            // Handle unknown errors.
            .onNoMatch(do: { (_)  in
                showErrorAlert("An error occurred! Please try again. ")
                return .continueMatching
            })

            // Add actions - like logging - that you want to perform each time - whether the error was matched or not
            .always(do: { (error) in
                Logger.log(error)
                return .continueMatching
            })
    }
}
```
### Use the default handler to handle common cases

Often the cases the default handler knows about will be good enough.

```swift
do {
    try saveStatus()
} catch {
    ErrorHandler.defaultHandler.handle(error)
}
```

or use the `tryWith` free function:

```swift
tryWith(ErrorHandler.defaultHandler) {
    try saveStatus()
}
```
### Customize the error handler when needed.

In cases where extra context is available you can add more cases or override the ones provided already.

For example in a SendMessageViewController

```swift
sendMessage(message) { (response, error) in

            if let error = error {
                ErrorHandler.defaultHandler
                    .on(ValidationError.invalidEmail, do: { (_) in
                        updateEmailTextFieldForValidationError()
                        return .continueMatching
                    })
                    .onAFError(withStatus: 404, do: { (_) in
                        doSomethingSpecificFor404()
                        return .stopMatching
                    })
                    .onNoMatch(do: { (_) in
                        // In the context of the current screen we can provide a better message.
                        showErrorAlert("An error occurred! The message has not been sent.")
                        // We want to override the default onNoMatch handling so we stop searching for other matches.
                        return .stopMatching
                    })
                    .handle(error)
            }
        }
```


## Why?

When designing for errors, we usually need to:

1. have a **default** handler for **expected** errors
   // i.e. network, db errors etc.
2. handle **specific** errors **in a custom manner** given **the context**  of where and when they occur
   // i.e. network error while uploading a file, invalid login
3. have a **catch-all** handler for **unknown** errors
   // i.e. errors we don't have custom handling for
4. perform some **actions** for **all errors** both known and unknown like logging
5. keep our code **DRY**

Swift's has a very well thought error handling model keeping balance between convenience ([automatic propagation](https://github.com/apple/swift/blob/master/docs/ErrorHandlingRationale.rst#automatic-propagation)) and clarity-safety ([Typed propagation](https://github.com/apple/swift/blob/master/docs/ErrorHandlingRationale.rst#id3), [Marked propagation](https://github.com/apple/swift/blob/master/docs/ErrorHandlingRationale.rst#id4)). As a result, the compiler serves as a reminder of errors that need to be handled and at the same type it is relatively easy to propagate errors and handle them higher up the stack.

However, even with this help from the language, achieving the goals listed above in an **ad-hoc** manner in an application of a reasonable size can lead to a lot of **boilerplate** which is **tedious** to write and reason about. Because of this friction developers quite often choose to swallow errors or handle them all in the same generic way.

This library addresses these issues by providing an abstraction over defining flexible error handling rules with an opinionated fluent API.
