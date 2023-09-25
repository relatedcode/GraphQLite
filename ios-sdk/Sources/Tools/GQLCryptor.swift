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
import CryptoKit

//-----------------------------------------------------------------------------------------------------------------------------------------------
public class GQLCryptor: NSObject {

	private var password = "1234567890abcdxyz"

	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: GQLCryptor = {
		let instance = GQLCryptor()
		return instance
	} ()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class func password(_ value: String) {

		shared.password = value
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLCryptor {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func encrypt(_ text: String) -> String? {

		if let dataDecrypted = text.data(using: .utf8) {
			if let dataEncrypted = encrypt(dataDecrypted) {
				return dataEncrypted.base64EncodedString()
			}
		}
		return nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func decrypt(_ text: String) -> String? {

		if let dataEncrypted = Data(base64Encoded: text) {
			if let dataDecrypted = decrypt(dataEncrypted) {
				return String(data: dataDecrypted, encoding: .utf8)
			}
		}
		return nil
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLCryptor {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func encrypt(_ data: Data) -> Data? {

		return try? encrypt(data, shared.password)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func decrypt(_ data: Data) -> Data? {

		return try? decrypt(data, shared.password)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLCryptor {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func encrypt(_ data: Data, _ key: String) throws -> Data {

		let cryptedBox = try ChaChaPoly.seal(data, using: symmetricKey(key))
		let sealedBox = try ChaChaPoly.SealedBox(combined: cryptedBox.combined)

		return sealedBox.combined
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func decrypt(_ data: Data, _ key: String) throws -> Data {

		let sealedBox = try ChaChaPoly.SealedBox(combined: data)
		let decryptedData = try ChaChaPoly.open(sealedBox, using: symmetricKey(key))

		return decryptedData
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func symmetricKey(_ key: String) -> SymmetricKey {

		let dataKey = Data(key.utf8)
		let hash256 = SHA256.hash(data: dataKey)
		return SymmetricKey(data: hash256)
	}
}
