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
public enum GQLQueryFormat {

	case original
	case escaped
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
public class GQLQuery: NSObject {

	private var queries: [String: String] = [:]

	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: GQLQuery = {
		let instance = GQLQuery()
		return instance
	} ()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override init() {

		super.init()

		importQueries()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class subscript(_ name: String, _ format: GQLQueryFormat = .original) -> String {

		if var query = shared.queries[name] {
			if (format == .escaped) {
				query = query.replacingOccurrences(of: "\n", with: "\\n")
				query = query.replacingOccurrences(of: "\t", with: "\\t")
			}
			return query
		}

		fatalError("Trying to fetch a non-existing Query. \(name)")
	}
}

// MARK: - Import methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLQuery {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func importQueries() {

		guard let dir = Bundle.main.resourcePath else { return }

		guard let files = try? FileManager.default.contentsOfDirectory(atPath: dir) else { return }

		for file in files {
			let url = URL(fileURLWithPath: dir).appendingPathComponent(file)
			if (url.pathExtension == "graphql") {
				if let source = try? String(contentsOf: url) {
					importQueries(source)
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func importQueries(_ source: String) {

		var query = ""
		var inline = false

		for line in source.components(separatedBy: "\n") {
			if (line.hasPrefix("#") == false) {
				if (inline == false) && (line != "") {
					inline = true
					query = ""
				}
				if (inline == true) && (line.isEmpty) {
					let temp = name(query)
					queries[temp] = query
					inline = false
				}
				if (inline) {
					if (query != "") {
						query += "\n"
					}
					query += line
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func open(_ file: String) -> String? {

		if let url = Bundle.main.resourceURL {
			let path = url.appendingPathComponent(file)
			if let source = try? String(contentsOf: path) {
				return source
			}
		}
		return nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func name(_ query: String) -> String {

		if let type = query.components(separatedBy: " ").first {
			let temp = String(query.dropFirst(type.count))
			if let name1 = temp.components(separatedBy: "(").first {
				if let name2 = temp.components(separatedBy: "{").first {
					if (name1.count < name2.count) { return name1.trimmingCharacters(in: .whitespaces) }
					if (name1.count > name2.count) { return name2.trimmingCharacters(in: .whitespaces) }
				}
			}
		}
		fatalError("GQLQuery name error. \(query)")
	}
}
