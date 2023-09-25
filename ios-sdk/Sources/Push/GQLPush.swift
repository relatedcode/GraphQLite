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
public class GQLPush: NSObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class func setup(_ appId: String, _ keyAPI: String) {

		GQLOneSignal.setup(appId, keyAPI)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class func token(_ deviceToken: Data) {

		GQLOneSignal.token(deviceToken)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class func register(_ userId: String) {

		GQLOneSignal.register(userId)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class func unregister() {

		GQLOneSignal.unregister()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class func send(_ chatId: String, _ userIds: [String], _ text: String) {

		GQLOneSignal.send(chatId, userIds, text)
	}
}
