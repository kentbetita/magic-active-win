import AppKit

func getActiveBrowserTabURLAppleScriptCommand(_ appId: String) -> String? {
	switch appId {
	case "com.google.Chrome", "com.google.Chrome.beta", "com.google.Chrome.dev", "com.google.Chrome.canary", "com.brave.Browser", "com.brave.Browser.beta", "com.brave.Browser.nightly", "com.microsoft.edgemac", "com.microsoft.edgemac.Beta", "com.microsoft.edgemac.Dev", "com.microsoft.edgemac.Canary", "com.mighty.app", "com.ghostbrowser.gb1", "com.bookry.wavebox", "com.pushplaylabs.sidekick", "com.operasoftware.Opera",  "com.operasoftware.OperaNext", "com.operasoftware.OperaDeveloper", "com.vivaldi.Vivaldi", "company.thebrowser.Browser":
		return "tell app id \"\(appId)\" to get the URL of active tab of front window"
	case "com.apple.Safari", "com.apple.SafariTechnologyPreview":
		return "tell app id \"\(appId)\" to get URL of front document"
	default:
		return nil
	}
}

func exitWithoutResult() -> Never {
	print("null")
	exit(0)
}

func printOutput(_ output: Any) -> Never {
	guard let string = try? toJson(output) else {
		exitWithoutResult()
	}

	print(string)
	exit(0)
}

func getWindowInformation(window: [String: Any], windowOwnerPID: pid_t) -> [String: Any]? {
	// Skip transparent windows, like with Chrome.
	if (window[kCGWindowAlpha as String] as! Double) == 0 { // Documented to always exist.
		return nil
	}

	let bounds = CGRect(dictionaryRepresentation: window[kCGWindowBounds as String] as! CFDictionary)! // Documented to always exist.

	// Skip tiny windows, like the Chrome link hover statusbar.
	let minWinSize: CGFloat = 50
	if bounds.width < minWinSize || bounds.height < minWinSize {
		return nil
	}

	// This should not fail as we're only dealing with apps, but we guard it just to be safe.
	guard let app = NSRunningApplication(processIdentifier: windowOwnerPID) else {
		return nil
	}

	let appName = window[kCGWindowOwnerName as String] as? String ?? app.bundleIdentifier ?? "<Unknown>"

	let windowTitle = disableScreenRecordingPermission ? "" : window[kCGWindowName as String] as? String ?? ""

	if app.bundleIdentifier == "com.apple.dock" {
		return nil
	}

	var output: [String: Any] = [
		"platform": "macos",
		"title": windowTitle,
		"id": window[kCGWindowNumber as String] as! Int, // Documented to always exist.
		"bounds": [
			"x": bounds.origin.x,
			"y": bounds.origin.y,
			"width": bounds.width,
			"height": bounds.height
		],
		"owner": [
			"name": appName,
			"processId": windowOwnerPID,
			"bundleId": app.bundleIdentifier ?? "", // I don't think this could happen, but we also don't want to crash.
			"path": app.bundleURL?.path ?? "" // I don't think this could happen, but we also don't want to crash.
		],
		"memoryUsage": window[kCGWindowMemoryUsage as String] as? Int ?? 0
	]

	// * Commented the script below as we don't need the `url` property and to prevent retrieving it and running the apple script.

	// Run the AppleScript to get the URL if the active window is a compatible browser and accessibility permissions are enabled.
	// if
	// 	!disableAccessibilityPermission,
	// 	let bundleIdentifier = app.bundleIdentifier,
	// 	let script = getActiveBrowserTabURLAppleScriptCommand(bundleIdentifier),
	// 	let url = runAppleScript(source: script)
	// {
	// 	output["url"] = url
	// }

	return output
}

let disableAccessibilityPermission = CommandLine.arguments.contains("--no-accessibility-permission")
let disableScreenRecordingPermission = CommandLine.arguments.contains("--no-screen-recording-permission")
let enableOpenWindowsList = CommandLine.arguments.contains("--open-windows-list")

// * Commented the guard below so that we don't get the accessibility permission prompt.

// Show accessibility permission prompt if needed. Required to get the URL of the active tab in browsers.
// if !disableAccessibilityPermission {
// 	if !AXIsProcessTrustedWithOptions(["AXTrustedCheckOptionPrompt": true] as CFDictionary) {
// 		print("active-win requires the accessibility permission in “System Settings › Privacy & Security › Accessibility”.")
// 		exit(1)
// 	}
// }

// Show screen recording permission prompt if needed. Required to get the complete window title.
if
	!disableScreenRecordingPermission,
	!hasScreenRecordingPermission()
{
	print("active-win requires the screen recording permission in “System Settings › Privacy & Security › Screen Recording”.")
	exit(1)
}

guard
	let frontmostAppPID = NSWorkspace.shared.frontmostApplication?.processIdentifier,
	let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]]
else {
	exitWithoutResult()
}

var openWindows = [[String: Any]]();

for window in windows {
	let windowOwnerPID = window[kCGWindowOwnerPID as String] as! pid_t // Documented to always exist.
	if !enableOpenWindowsList && windowOwnerPID != frontmostAppPID {
		continue
	}

	guard let windowInformation = getWindowInformation(window: window, windowOwnerPID: windowOwnerPID) else {
		continue
	}

	if !enableOpenWindowsList {
		printOutput(windowInformation)
	} else {
		openWindows.append(windowInformation)
	}
}

if !openWindows.isEmpty {
	printOutput(openWindows)
}

exitWithoutResult()
