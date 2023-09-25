//
// Copyright (c) 2023 Related Code - https://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import SQLite3

//-----------------------------------------------------------------------------------------------------------------------------------------------
public enum GQLDebugLevel {

	case none
	case error
	case all
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
public class GQLDebug: NSObject {

	private var debugLevel: GQLDebugLevel = .all

	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: GQLDebug = {
		let instance = GQLDebug()
		return instance
	} ()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class func level(_ debugLevel: GQLDebugLevel) {

		shared.debugLevel = debugLevel
	}
}

// MARK: - Debug methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLDebug {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func info(_ message: String) {

		print_info(message)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func error(_ message: String) {

		print_error(message)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func error(_ error: Error) {

		print_error(error.localizedDescription)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func error(_ error: Error?) {

		if let error = error {
			print_error(error.localizedDescription)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func error(_ handle: OpaquePointer?) {

		if let handle = handle {
			let desc = convert(sqlite3_errmsg(handle))
			let code = Int(sqlite3_errcode(handle))
			print_error("\(desc) - \(code)")
		} else {
			print_error("Database is not open.")
		}
	}
}

// MARK: - Print methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLDebug {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func print_info(_ message: String) {

		if (shared.debugLevel == .all) {
			print("GQL: " + message.trimmingCharacters(in: .newlines))
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func print_error(_ message: String) {

		if (shared.debugLevel != .none) {
			print("GQL Error: \(message)")
		}
	}
}

// MARK: - Convert methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLDebug {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func convert(_ value: UnsafePointer<Int8>?) -> String {

		if let value = value {
			return String(cString: value)
		}
		return ""
	}
}

// MARK: - Thread methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLDebug {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func thread() {

		let main = Thread.isMainThread ? "main" : "background"
		let temp = __dispatch_queue_get_label(nil)
		let name = String(cString: temp, encoding: .utf8) ?? "no name"
		print("Thread: \(main) - \(name)")
	}
}
