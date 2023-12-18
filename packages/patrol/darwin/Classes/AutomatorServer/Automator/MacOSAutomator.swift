#if PATROL_ENABLED && os(macOS)
  import XCTest

  class MacOSAutomator: Automator {
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

    func openApp(_ bundleId: String) throws {
      try runAction("opening app with id \(bundleId)") {
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

    func pressHome() throws {
      try runAction("pressHome") {
        throw PatrolError.methodNotImplemented("pressHome")
      }
    }

    func openAppSwitcher() throws {
      try runAction("openAppSwitcher") {
        throw PatrolError.methodNotImplemented("openAppSwitcher")
      }
    }

    func openControlCenter() throws {
      try runAction("openControlCenter") {
        throw PatrolError.methodNotImplemented("openControlCenter")
      }
    }

    func tap(onText text: String, inApp bundleId: String, atIndex index: Int) throws {
      let view = "view with text \(format: text) at index \(index) in app \(bundleId)"

      try runAction("tapping on \(view)") {
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

    func doubleTap(onText text: String, inApp bundleId: String) throws {
      try runAction("double tapping on text \(format: text) in app \(bundleId)") {
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

    func typeText(
      _ data: String,
      modifierKeys: [Int],
      inApp bundleId: String
    ) throws {
      try runAction("entering text \(format: data) by index \(index) in app \(bundleId)") {
        let app = try self.getApp(withBundleId: bundleId)
        let decodeModifierKeys = self.decodeModifierKeys(modifierKeys)
        app.typeKey(data, modifierFlags: XCUIElement.KeyModifierFlags(decodeModifierKeys))
      }
    }   

    func enterText(
      _ data: String, byText text: String, atIndex index: Int, inApp bundleId: String,
      dismissKeyboard: Bool
    ) throws {
      try runAction("enterText") {
        throw PatrolError.methodNotImplemented("enterText")
      }
    }

    func enterText(
      _ data: String, byIndex index: Int, inApp bundleId: String, dismissKeyboard: Bool
    ) throws {
      try runAction("enterText") {
        throw PatrolError.methodNotImplemented("enterText")
      }
    }

    func swipe(from start: CGVector, to end: CGVector, inApp bundleId: String) throws {
      try runAction("swipe") {
        throw PatrolError.methodNotImplemented("swipe")
      }
    }

    func waitUntilVisible(onText text: String, inApp bundleId: String) throws {
      try runAction(
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

    func enableDarkMode(_ bundleId: String) throws {
      try runAction("enableDarkMode") {
        throw PatrolError.methodNotImplemented("enableDarkMode")
      }
    }

    func disableDarkMode(_ bundleId: String) throws {
      try runAction("disableDarkMode") {
        throw PatrolError.methodNotImplemented("disableDarkMode")
      }
    }

    func enableAirplaneMode() throws {
      try runAction("enableAirplaneMode") {
        throw PatrolError.methodNotImplemented("enableAirplaneMode")
      }
    }

    func disableAirplaneMode() throws {
      try runAction("disableAirplaneMode") {
        throw PatrolError.methodNotImplemented("disableAirplaneMode")
      }
    }

    func enableCellular() throws {
      try runAction("enableCellular") {
        throw PatrolError.methodNotImplemented("enableCellular")
      }
    }

    func disableCellular() throws {
      try runAction("disableCellular") {
        throw PatrolError.methodNotImplemented("disableCellular")
      }
    }

    func enableWiFi() throws {
      try runAction("enableWiFi") {
        throw PatrolError.methodNotImplemented("enableWiFi")
      }
    }

    func disableWiFi() throws {
      try runAction("disableWiFi") {
        throw PatrolError.methodNotImplemented("disableWiFi")
      }
    }

    func enableBluetooth() throws {
      try runAction("enableBluetooth") {
        throw PatrolError.methodNotImplemented("enableBluetooth")
      }
    }

    func disableBluetooth() throws {
      try runAction("disableBluetooth") {
        throw PatrolError.methodNotImplemented("disableBluetooth")
      }
    }

    func getNativeViews(byText text: String, inApp bundleId: String) throws -> [NativeView] {
      try runAction("getNativeViews") {
        throw PatrolError.methodNotImplemented("getNativeViews")
      }
    }

    func getUITreeRoots(installedApps: [String]) throws -> [NativeView] {
      try runAction("getUITreeRoots") {
        throw PatrolError.methodNotImplemented("getUITreeRoots")
      }
    }

    func openNotifications() throws {
      try runAction("opening notifications") {
        let clockItem = self.controlCenter.statusItems["com.apple.menuextra.clock"]
        var exists = clockItem.waitForExistence(timeout: self.timeout)
        guard exists else {
          throw PatrolError.viewNotExists("com.apple.menuextra.clock")
        }

        clockItem.tap()
      }
    }

    func closeNotifications() throws {
      try runAction("closeNotifications") {
        throw PatrolError.methodNotImplemented("closeNotifications")
      }
    }

    func closeHeadsUpNotification() throws {
      try runAction("closeHeadsUpNotification") {
        throw PatrolError.methodNotImplemented("closeHeadsUpNotification")
      }
    }

    func getNotifications() throws -> [Notification] {
      try runAction("getNotifications") {
        throw PatrolError.methodNotImplemented("getNotifications")
      }
    }

    func tapOnNotification(byIndex index: Int) throws {
      try runAction("tapOnNotification") {
        throw PatrolError.methodNotImplemented("tapOnNotification")
      }
    }

    func tapOnNotification(bySubstring substring: String) throws {
      try runAction("tapOnNotification") {
        throw PatrolError.methodNotImplemented("tapOnNotification")
      }
    }

    func isPermissionDialogVisible(timeout: TimeInterval) throws -> Bool {
      try runAction("isPermissionDialogVisible") {
        throw PatrolError.methodNotImplemented("isPermissionDialogVisible")
      }
    }

    func allowPermissionWhileUsingApp() throws {
      try runAction("allowPermissionWhileUsingApp") {
        throw PatrolError.methodNotImplemented("allowPermissionWhileUsingApp")
      }
    }

    func allowPermissionOnce() throws {
      try runAction("allowPermissionOnce") {
        throw PatrolError.methodNotImplemented("allowPermissionOnce")
      }
    }

    func denyPermission() throws {
      try runAction("denyPermission") {
        throw PatrolError.methodNotImplemented("denyPermission")
      }
    }

    func selectFineLocation() throws {
      try runAction("selectFineLocation") {
        throw PatrolError.methodNotImplemented("selectFineLocation")
      }
    }

    func selectCoarseLocation() throws {
      try runAction("selectCoarseLocation") {
        throw PatrolError.methodNotImplemented("selectCoarseLocation")
      }
    }

    func debug() throws {
      try runAction("debug") {
        throw PatrolError.methodNotImplemented("debug")
      }
    }

    private func decodeModifierKeys(_ input: [Int]) -> [XCUIElement.KeyModifierFlags] {
        var response: [XCUIElement.KeyModifierFlags] = []
        for element in input {
          switch(element) {
            case 0x002000001f6:
              response.append(XCUIElement.KeyModifierFlags.command)
            case 0x002000001f0:
              response.append( XCUIElement.KeyModifierFlags.control)
            case 0x002000001f4:
              response.append( XCUIElement.KeyModifierFlags.option)
            case 0x002000001f2:
              response.append( XCUIElement.KeyModifierFlags.shift)
            case 0x00100000104:
              response.append( XCUIElement.KeyModifierFlags.capsLock)
            case 0x00100000106:
              response.append( XCUIElement.KeyModifierFlags.function)
            default:
              print("No modifer key for \(element)")
          }
        }
        return response
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

    private func runAction<T>(_ log: String, block: @escaping () throws -> T) rethrows -> T {
      return try DispatchQueue.main.sync {
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
    static func fromXCUIElement(_ xcuielement: XCUIElement, _ bundleId: String) -> NativeView {
      return NativeView(
        className: String(xcuielement.elementType.rawValue),  // TODO: Provide mapping for names
        text: xcuielement.label,
        contentDescription: "",  // TODO:
        focused: false,  // TODO:
        enabled: xcuielement.isEnabled,
        resourceName: xcuielement.identifier,
        applicationPackage: bundleId,
        children: xcuielement.children(matching: .any).allElementsBoundByIndex.map { child in
          return NativeView.fromXCUIElement(child, bundleId)
        })
    }
  }

#endif
