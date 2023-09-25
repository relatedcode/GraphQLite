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
public class GQLStorage: NSObject {

	private var amazonS3: GQLAmazonS3?

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public init(AmazonS3 regionName: String, _ secretKey: String, _ accessKey: String) {

		super.init()

		amazonS3 = GQLAmazonS3(regionName, secretKey, accessKey)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func upload(_ bucket: String, _ key: String, _ data: Data, completion: @escaping (Error?) -> Void) {

		amazonS3?.upload(bucket, key, data, completion)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func download(_ bucket: String, _ key: String, completion: @escaping (Data?, Error?) -> Void) {

		amazonS3?.download(bucket, key, completion)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func delete(_ bucket: String, _ key: String, completion: @escaping (Error?) -> Void) {

		amazonS3?.delete(bucket, key, completion)
	}
}
