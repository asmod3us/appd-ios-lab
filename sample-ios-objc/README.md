## NSURLSession (Objective-C)

A simple iOS client (using Objective-C and NSURLSession for network calls) to test Mobile RUM beacon generation for the [ECommerce](https://github.com/Appdynamics/ECommerce-Docker) application.

### Configuration

To use the iOS client, add the AppDynamics iOS Agent (ADEUMINstrumentation.framework) to the Frameworks group and then edit ecommerce-ios-objc/ECommerce.plist to add your configuration information:

1. The URL for your ECommerce application
2. The URL for your EUM Collector
3. The EUM App Key for your ECommerce application
4. The username for your ECommerce application
5. The password for your ECommerce application

### Running the iOS client
From Xcode, select an appropriate device or simulator and click Run.  There is a also single UITest defined that will automate a simple sequence of actions: Login, Get All Items, Add to Cart and Checkout: click Test to run it.

The test automation can also be run from the commandline:
`xcodebuild -scheme "ecommerce-ios-swift" -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 6,OS=9.1' test`
