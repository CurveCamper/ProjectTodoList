import SwiftUI
import CocoaLumberjack

@main
struct ToDoListApp: App {
    init() {
        // Настройка CocoaLumberjack
        DDLog.add(DDOSLogger.sharedInstance)

        let fileLogger: DDFileLogger = DDFileLogger()
        fileLogger.rollingFrequency = TimeInterval(60 * 60 * 24)
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
