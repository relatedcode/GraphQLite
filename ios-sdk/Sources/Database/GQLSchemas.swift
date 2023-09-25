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
class GQLSchemas: NSObject {

	private var schemas: [String: GQLSchema] = [:]

	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: GQLSchemas = {
		let instance = GQLSchemas()
		return instance
	} ()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class subscript(_ table: String) -> GQLSchema {

		if let schema = shared.schemas[table] {
			return schema
		}

		fatalError("Trying to fetch a non-existing Schema. \(table)")
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class subscript(_ otype: GQLObject.Type) -> GQLSchema {

		let table = otype.table()

		if let schema = shared.schemas[table] {
			return schema
		}

		let schema = GQLSchema(otype)
		shared.schemas[table] = schema
		return schema
	}
}
