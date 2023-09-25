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

//-----------------------------------------------------------------------------------------------------------------------------------------------
public class GQLDate: NSObject {

	private var formatterCustom: DateFormatter?

	private var formatterDefault = ISO8601DateFormatter()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: GQLDate = {
		let instance = GQLDate()
		return instance
	} ()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override init() {

		super.init()

		formatterDefault.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class func custom(_ formatter: DateFormatter) {

		shared.formatterCustom = formatter
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLDate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class subscript(_ string: String) -> Date {

		if let date = convert(string) { return date }
		fatalError("Date conversion error. \(string)")
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class subscript(_ date: Date) -> String {

		return convert(date)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class subscript(_ timestamp: TimeInterval) -> String {

		let date = Date(timeIntervalSince1970: timestamp)

		return convert(date)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLDate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func convert(_ string: String) -> Date? {

		if let formatter = shared.formatterCustom {
			return formatter.date(from: string)
		}
		return shared.formatterDefault.date(from: string)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func convert(_ date: Date) -> String {

		if let formatter = shared.formatterCustom {
			return formatter.string(from: date)
		}
		return shared.formatterDefault.string(from: date)
	}
}
