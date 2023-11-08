#if true
import XCTest

class Automator {
    private var timeout: TimeInterval = 10
    
    private lazy var controlCenter: XCUIApplication = {
        return XCUIApplication(bundleIdentifier: "com.apple.controlcenter")
    }()
    
    private lazy var notificationCenter: XCUIApplication = {
        return XCUIApplication(bundleIdentifier: "com.apple.notificationcenterui")
    }()
    
    private lazy var systemPreferences: XCUIApplication = {
        return XCUIApplication(bundleIdentifier: "com.apple.systempreferences")
    }()
    
    func configure(timeout: TimeInterval) {
        self.timeout = timeout
    }
    
    func openApp(_ bundleId: String) async throws {
        try await runAction("opening app with id \(bundleId)") {
            let app = try self.getApp(withBundleId: bundleId)
            app.activate()
        }
    }
    
    private func getApp(withBundleId bundleId: String) throws -> XCUIApplication {
        let app = XCUIApplication(bundleIdentifier: bundleId)
        // TODO: Doesn't work
        // See https://stackoverflow.com/questions/73976961/how-to-check-if-any-app-is-installed-during-xctest
        // guard app.exists else {
        //   throw PatrolError.appNotInstalled(bundleId)
        // }
        
        return app
    }

    // MARK: General UI interaction
    
     func tap(onText text: String, inApp bundleId: String, atIndex index: Int) async throws {
      let view = "view with text \(format: text) at index \(index) in app \(bundleId)"

      try await runAction("tapping on \(view)") {
        let app = try self.getApp(withBundleId: bundleId)

        // The below selector is an equivalent of `app.descendants(matching: .any)[text]`
        // TODO: We should consider more view properties. See #1554
        let format = """
          label == %@ OR \
          title == %@ OR \
          identifier == %@
          """
        let predicate = NSPredicate(format: format, text, text, text)
        let query = app.descendants(matching: .any).matching(predicate)

        Logger.shared.i("waiting for existence of \(view)")
        guard let element = self.waitFor(query: query, index: index, timeout: self.timeout) else {
          throw PatrolError.viewNotExists(view)
        }

        element.forceTap()
      }
    }

    func doubleTap(onText text: String, inApp bundleId: String) async throws {
      try await runAction("double tapping on text \(format: text) in app \(bundleId)") {
        let app = try self.getApp(withBundleId: bundleId)
        let element = app.descendants(matching: .any)[text]

        let exists = element.waitForExistence(timeout: self.timeout)
        guard exists else {
          throw PatrolError.viewNotExists(
            "view with text \(format: text) in app \(format: bundleId)")
        }

        element.firstMatch.forceTap()
      }
    }

    func enterText(
      _ data: String,
      byText text: String,
      atIndex index: Int,
      inApp bundleId: String
    ) async throws {
      let view = "text field with text \(format: text) at index \(index) in app \(bundleId)"
      let data = "\(data)\n"

      try await runAction("entering text \(format: data) into \(view)") {
        let app = try self.getApp(withBundleId: bundleId)

        // elementType must be specified as integer
        // See:
        // * https://developer.apple.com/documentation/xctest/xcuielementtype/xcuielementtypetextfield
        // * https://developer.apple.com/documentation/xctest/xcuielementtype/xcuielementtypesecuretextfield
        // The below selector is an equivalent of `app.descendants(matching: .any)[text]`
        // TODO: We should consider more view properties. See #1554
        let format = """
          label == %@ OR \
          title == %@ OR \
          identifier == %@ OR \
          value == %@ OR \
          placeholderValue == %@
          """
        let contentPredicate = NSPredicate(format: format, text, text, text, text, text)
        let textFieldPredicate = NSPredicate(format: "elementType == 49")
        let secureTextFieldPredicate = NSPredicate(format: "elementType == 50")

        let finalPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
          contentPredicate,
          NSCompoundPredicate(orPredicateWithSubpredicates: [
            textFieldPredicate, secureTextFieldPredicate,
          ]
          ),
        ])

        let query = app.descendants(matching: .any).matching(finalPredicate)
        guard
          let element = self.waitFor(
            query: query,
            index: index,
            timeout: self.timeout
          )
        else {
          throw PatrolError.viewNotExists(view)
        }

        element.forceTap()
        element.typeText(data)
      }
    }

    func enterText(
      _ data: String,
      byIndex index: Int,
      inApp bundleId: String
    ) async throws {
      var data = "\(data)\n"

      try await runAction("entering text \(format: data) by index \(index) in app \(bundleId)") {
        let app = try self.getApp(withBundleId: bundleId)

        // elementType must be specified as integer
        // See:
        // * https://developer.apple.com/documentation/xctest/xcuielementtype/xcuielementtypetextfield
        // * https://developer.apple.com/documentation/xctest/xcuielementtype/xcuielementtypesecuretextfield
        let textFieldPredicate = NSPredicate(format: "elementType == 49")
        let secureTextFieldPredicate = NSPredicate(format: "elementType == 50")
        let predicate = NSCompoundPredicate(
          orPredicateWithSubpredicates: [textFieldPredicate, secureTextFieldPredicate]
        )

        let textFieldsQuery = app.descendants(matching: .any).matching(predicate)
        guard
          let element = self.waitFor(
            query: textFieldsQuery,
            index: index,
            timeout: self.timeout
          )
        else {
          throw PatrolError.viewNotExists("text field at index \(index) in app \(bundleId)")
        }

        do {
          element.typeText(data)
        } 
        catch {
          throw PatrolError.internal("Could not typeText in text field at index \(index) in app \(bundleId)")
        }

      }
    }        

    func waitUntilVisible(onText text: String, inApp bundleId: String) async throws {
      try await runAction(
        "waiting until view with text \(format: text) in app \(bundleId) becomes visible"
      ) {
        let app = try self.getApp(withBundleId: bundleId)
        let element = app.descendants(matching: .any)[text]
        let exists = element.waitForExistence(timeout: self.timeout)
        guard exists else {
          throw PatrolError.viewNotExists(
            "view with text \(format: text) in app \(format: bundleId)")
        }
      }
    }

    // MARK: Services
    
    func enableBluetooth() async throws {
        try await runSystemPreferencesAction("enabling bluetooth") {
            let bluetoothMenuItem = self.systemPreferences.menuItems["Bluetooth"]
            var exists = bluetoothMenuItem.waitForExistence(timeout: self.timeout)
            guard exists else {
                throw PatrolError.viewNotExists("BluetoothMenuItem")
            }
            bluetoothMenuItem.tap()
            
            let bluetoothSwitch = self.systemPreferences.switches.firstMatch
            exists = bluetoothSwitch.waitForExistence(timeout: self.timeout)
            guard exists else {
                throw PatrolError.viewNotExists("BluetoothSwitch")
            }
            
            if bluetoothSwitch.value! as! NSNumber == 0 {
                bluetoothSwitch.tap()
            } else {
                Logger.shared.i("bluetooth is already enabled")
            }
        }
    }
    
    func disableBluetooth() async throws {
        try await runSystemPreferencesAction("disabling bluetooth") {
            let bluetoothMenuItem = self.systemPreferences.menuItems["Bluetooth"]
            var exists = bluetoothMenuItem.waitForExistence(timeout: self.timeout)
            guard exists else {
                throw PatrolError.viewNotExists("BluetoothMenuItem")
            }
            bluetoothMenuItem.tap()
            
            let bluetoothSwitch = self.systemPreferences.switches.firstMatch
            exists = bluetoothSwitch.waitForExistence(timeout: self.timeout)
            guard exists else {
                throw PatrolError.viewNotExists("BluetoothSwitch")
            }
            
            if bluetoothSwitch.value! as! NSNumber == 1 {
                bluetoothSwitch.tap()
            } else {
                Logger.shared.i("bluetooth is already disabled")
            }
        }
    }
    
    func getNativeViews(
        byText text: String,
        inApp bundleId: String
    ) async throws -> [NativeView] {
        try await runAction("getting native views matching \(text)") {
            let app = try self.getApp(withBundleId: bundleId)
            
            // The below selector is an equivalent of `app.descendants(matching: .any)[text]`
            // TODO: We should consider more view properties. See #1554
            let format = """
             label == %@ OR \
             title == %@ OR \
             identifier == %@
             """
            let predicate = NSPredicate(format: format, text, text, text)
            let query = app.descendants(matching: .any).matching(predicate)
            let elements = query.allElementsBoundByIndex
            
            let views = elements.map { xcuielement in
                return NativeView.fromXCUIElement(xcuielement, bundleId)
            }
            
            return views
        }
    }
    
    // MARK: Notifications
    
    func openNotifications() async throws {
        try await runAction("opening notifications") {
            let clockItem = self.controlCenter.statusItems["com.apple.menuextra.clock"]
            var exists = clockItem.waitForExistence(timeout: self.timeout)
            guard exists else {
                throw PatrolError.viewNotExists("com.apple.menuextra.clock")
            }
            
            clockItem.tap()
        }
    }
    
    func tapOnNotification(byIndex index: Int) async throws {
        try await runAction("tapping on notification at index \(index)") {
            throw PatrolError.methodNotImplemented("tapOnNotification(byIndex)")
        }
    }
    
    func tapOnNotification(bySubstring substring: String) async throws { 
        try await runAction("tapping on notification containing text \(format: substring)") {
            throw PatrolError.methodNotImplemented("tapOnNotification(bySubstring)")
        }
    }
    
    // MARK: Permissions
    
    func isPermissionDialogVisible(timeout: TimeInterval) async -> Bool {
        return false // TODO:
    }
    
    private func runSystemPreferencesAction(_ log: String, block: @escaping () throws -> Void)
    async throws
    {
        try await runAction(log) {
            self.systemPreferences.activate()
            
            try block()
            
            self.systemPreferences.terminate()
        }
    }

    @discardableResult
    func waitFor(query: XCUIElementQuery, index: Int, timeout: TimeInterval) -> XCUIElement? {
      var foundElement: XCUIElement?
      let startTime = Date()

      while Date().timeIntervalSince(startTime) < timeout {
        let elements = query.allElementsBoundByIndex
        if index < elements.count && elements[index].exists {
          foundElement = elements[index]
          break
        }
        sleep(1)
      }

      return foundElement
    }
    
    private func runAction<T>(_ log: String, block: @escaping () throws -> T) async rethrows -> T {
        return try await MainActor.run {
            Logger.shared.i("\(log)...")
            let result = try block()
            Logger.shared.i("done \(log)")
            Logger.shared.i("result: \(result)")
            return result
        }
    }
}

// MARK: Utilities

// Adapted from https://samwize.com/2016/02/28/everything-about-xcode-ui-testing-snapshot/
extension XCUIElement {
func forceTap() {
    if self.isHittable {
    self.tap()
    } else {
    let coordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.0))
    coordinate.tap()
    }
}
}

extension NativeView {
    static func fromXCUIElement(_ xcuielement: XCUIElement, _ bundleId: String) -> NativeView
    {
        return NativeView(
            className: String(xcuielement.elementType.rawValue),  // TODO: Provide mapping for names
            text: xcuielement.label,
            contentDescription: "",// TODO:
            focused: false,// TODO:
            enabled: xcuielement.isEnabled,
            resourceName: xcuielement.identifier,
            applicationPackage: bundleId,
            children: xcuielement.children(matching: .any).allElementsBoundByIndex.map { child in
                return NativeView.fromXCUIElement(child, bundleId)
            })
    }
}

#endif
