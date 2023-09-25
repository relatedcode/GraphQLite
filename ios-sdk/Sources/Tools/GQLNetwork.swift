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
import Network

//-----------------------------------------------------------------------------------------------------------------------------------------------
public class GQLNetwork: NSObject {

	private let monitor = NWPathMonitor()

	private var initialized = false
	private var notReachable = false
	private var isReachable = false
	private var isCellular = false
	private var isWiFi = false

	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: GQLNetwork = {
		let instance = GQLNetwork()
		return instance
	} ()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class func setup() {

		_ = shared
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override init() {

		super.init()

		monitor.pathUpdateHandler = { path in
			self.isReachable	= (path.status == .satisfied)
			self.notReachable	= (path.status == .unsatisfied)
			self.isWiFi			= path.usesInterfaceType(.wifi)
			self.isCellular		= path.usesInterfaceType(.cellular)
			self.notification()
		}

		monitor.start(queue: DispatchQueue.global(qos: .background))
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func notification() {

		if (initialized) {
			GQLNotification.post("GQLNetworkChanged")
		}
		initialized = true
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class func notReachable() -> Bool	{ return shared.notReachable	}
	public class func isReachable() -> Bool		{ return shared.isReachable		}
	public class func isCellular() -> Bool		{ return shared.isCellular		}
	public class func isWiFi() -> Bool			{ return shared.isWiFi			}
	//-------------------------------------------------------------------------------------------------------------------------------------------
}
