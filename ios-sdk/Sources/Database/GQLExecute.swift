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
typealias AnyDict = [String: Any]

//-----------------------------------------------------------------------------------------------------------------------------------------------
let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

//-----------------------------------------------------------------------------------------------------------------------------------------------
class GQLExecute: NSObject {

	private var handle: OpaquePointer!
	private var schema: GQLSchema!

	private var statement: OpaquePointer?

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init?(_ handle: OpaquePointer?, _ sql: String, _ schema: GQLSchema? = nil) {

		super.init()

		if (handle == nil) {
			fatalError("Database must be opened first.")
		}

		self.handle = handle
		self.schema = schema

		if (sqlite3_prepare_v2(handle, sql, -1, &statement, nil) != SQLITE_OK) {
			GQLDebug.error(handle)
			return nil
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	deinit {

		sqlite3_finalize(statement)
	}
}

// MARK: - Execute methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLExecute {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func execute() {

		if (sqlite3_step(statement) != SQLITE_DONE) {
			GQLDebug.error(handle)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func execute(_ arguments: [Any]) {

		bind(arguments)
		if (sqlite3_step(statement) != SQLITE_DONE) {
			GQLDebug.error(handle)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func execute(_ arguments: [String: Any]) {

		bind(arguments)
		if (sqlite3_step(statement) != SQLITE_DONE) {
			GQLDebug.error(handle)
		}
	}
}

// MARK: - Insert methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLExecute {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func insert(_ values: [String: Any]) {

		var index: Int32 = 1
		for column in schema.columns {
			if let value = values[column.name] {
				bind(value, column, index)
			}
			index += 1
		}

		if (sqlite3_step(statement) != SQLITE_DONE) {
			GQLDebug.error(handle)
		}
	}
}

// MARK: - Update methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLExecute {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func update(_ values: [String: Any]) {

		let index = prepareUpdate(values)

		if let value = values[schema.key] {
			bind(value, schema.key, index)
		}

		if (sqlite3_step(statement) != SQLITE_DONE) {
			GQLDebug.error(handle)
		}
	}
}

// MARK: - Update methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLExecute {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateOne(_ values: [String: Any], _ key: Any) {

		let index = prepareUpdate(values)

		bind(key, schema.key, index)
		if (sqlite3_step(statement) != SQLITE_DONE) {
			GQLDebug.error(handle)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateAll(_ values: [String: Any]) {

		prepareUpdate(values)

		if (sqlite3_step(statement) != SQLITE_DONE) {
			GQLDebug.error(handle)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateAll(_ values: [String: Any], _ arguments: [Any]) {

		let index = prepareUpdate(values)

		bind(arguments, index)
		if (sqlite3_step(statement) != SQLITE_DONE) {
			GQLDebug.error(handle)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateAll(_ values: [String: Any], _ arguments: [String: Any]) {

		let index = prepareUpdate(values)

		bind(arguments, index)
		if (sqlite3_step(statement) != SQLITE_DONE) {
			GQLDebug.error(handle)
		}
	}
}

// MARK: - Prepare Update methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLExecute {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@discardableResult private func prepareUpdate(_ values: [String: Any]) -> Int32 {

		var index: Int32 = 1
		for column in schema.columns {
			if (column.name != schema.key) {
				if let value = values[column.name] {
					bind(value, column, index)
					index += 1
				}
			}
		}
		return index
	}
}

// MARK: - Delete methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLExecute {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func deleteOne(_ key: Any) {

		bind(key, schema.key, 1)
		if (sqlite3_step(statement) != SQLITE_DONE) {
			GQLDebug.error(handle)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func deleteAll() {

		if (sqlite3_step(statement) != SQLITE_DONE) {
			GQLDebug.error(handle)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func deleteAll(_ arguments: [Any]) {

		bind(arguments)
		if (sqlite3_step(statement) != SQLITE_DONE) {
			GQLDebug.error(handle)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func deleteAll(_ arguments: [String: Any]) {

		bind(arguments)
		if (sqlite3_step(statement) != SQLITE_DONE) {
			GQLDebug.error(handle)
		}
	}
}

// MARK: - Fetch methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLExecute {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func fetchOne(_ key: Any) -> [String: Any]? {

		bind(key, schema.key, 1)
		if (sqlite3_step(statement) == SQLITE_ROW) {
			return values()
		}
		return nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func fetchOne() -> [String: Any]? {

		if (sqlite3_step(statement) == SQLITE_ROW) {
			return values()
		}
		return nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func fetchOne(_ arguments: [Any]) -> [String: Any]? {

		bind(arguments)
		if (sqlite3_step(statement) == SQLITE_ROW) {
			return values()
		}
		return nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func fetchOne(_ arguments: [String: Any]) -> [String: Any]? {

		bind(arguments)
		if (sqlite3_step(statement) == SQLITE_ROW) {
			return values()
		}
		return nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func fetchAll() -> [[String: Any]] {

		var results: [[String: Any]] = []

		while (sqlite3_step(statement) == SQLITE_ROW) {
			results.append(values())
		}

		return results
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func fetchAll(_ arguments: [Any]) -> [[String: Any]] {

		var results: [[String: Any]] = []

		bind(arguments)
		while (sqlite3_step(statement) == SQLITE_ROW) {
			results.append(values())
		}

		return results
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func fetchAll(_ arguments: [String: Any]) -> [[String: Any]] {

		var results: [[String: Any]] = []

		bind(arguments)
		while (sqlite3_step(statement) == SQLITE_ROW) {
			results.append(values())
		}

		return results
	}
}

// MARK: - Check methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLExecute {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func check(_ key: Any) -> Bool {

		bind(key, schema.key, 1)
		return (sqlite3_step(statement) == SQLITE_ROW)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func check() -> Bool {

		return (sqlite3_step(statement) == SQLITE_ROW)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func check(_ arguments: [Any]) -> Bool {

		bind(arguments)
		return (sqlite3_step(statement) == SQLITE_ROW)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func check(_ arguments: [String: Any]) -> Bool {

		bind(arguments)
		return (sqlite3_step(statement) == SQLITE_ROW)
	}
}

// MARK: - Count methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLExecute {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func count() -> Int {

		if (sqlite3_step(statement) == SQLITE_ROW) {
			return Int(sqlite3_column_int64(statement, 0))
		}
		return 0
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func count(_ arguments: [Any]) -> Int {

		bind(arguments)
		if (sqlite3_step(statement) == SQLITE_ROW) {
			return Int(sqlite3_column_int64(statement, 0))
		}
		return 0
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func count(_ arguments: [String: Any]) -> Int {

		bind(arguments)
		if (sqlite3_step(statement) == SQLITE_ROW) {
			return Int(sqlite3_column_int64(statement, 0))
		}
		return 0
	}
}

// MARK: - Binding values
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLExecute {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func bind(_ value: Any, _ name: String, _ index: Int32) {

		if let column = schema.columnz[name] {
			bind(value, column, index)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func bind(_ value: Any, _ column: GQLColumn, _ index: Int32) {

		switch column.type {

		case "Bool":	if let value = value as? Bool		{ xbind(value, index) }
		case "Int8":	if let value = value as? Int8		{ xbind(value, index) }
		case "Int16":	if let value = value as? Int16		{ xbind(value, index) }
		case "Int32":	if let value = value as? Int32		{ xbind(value, index) }
		case "Int64":	if let value = value as? Int64		{ xbind(value, index) }
		case "Int":		if let value = value as? Int		{ xbind(value, index) }
		case "Float":	if let value = value as? Float		{ xbind(value, index) }
		case "Double":	if let value = value as? Double		{ xbind(value, index) }

		case "String":	if let value = value as? String		{ xbind(value, index, column.encrypt) }

		case "Array":	if let value = value as? String		{ xbind(value, index, column.encrypt) }
						if let value = value as? [Any]		{ xbind(value, index, column.encrypt) }

		case "Dict":	if let value = value as? String		{ xbind(value, index, column.encrypt) }
						if let value = value as? AnyDict	{ xbind(value, index, column.encrypt) }

		case "Date":	if let value = value as? String		{ xbind(value, index, column.encrypt) }
						if let value = value as? Date		{ xbind(value, index, column.encrypt) }

		case "Data":	if let value = value as? Data		{ xbind(value, index, column.encrypt) }

		default: break
		}
	}
}

// MARK: - Binding arguments
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLExecute {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func bind(_ arguments: [Any], _ index: Int32 = 1) {

		var index = index

		for argument in arguments {
			bind(argument, index)
			index += 1
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func bind(_ arguments: [String: Any], _ index: Int32 = 1) {

		var index = index

		for i in 0..<sqlite3_bind_parameter_count(statement) {
			if let temp = sqlite3_bind_parameter_name(statement, i+1) {
				let name = String(cString: temp)
				if let argument = arguments[name] {
					bind(argument, index)
				}
				index += 1
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func bind(_ argument: Any, _ index: Int32) {

		if let value = argument as? Bool	{ xbind(value, index) }
		if let value = argument as? Int8	{ xbind(value, index) }
		if let value = argument as? Int16	{ xbind(value, index) }
		if let value = argument as? Int32	{ xbind(value, index) }
		if let value = argument as? Int64	{ xbind(value, index) }
		if let value = argument as? Int		{ xbind(value, index) }
		if let value = argument as? Float	{ xbind(value, index) }
		if let value = argument as? Double	{ xbind(value, index) }
		if let value = argument as? String	{ xbind(value, index, false) }
		if let value = argument as? Date	{ xbind(value, index, false) }
		if let value = argument as? Data	{ xbind(value, index, false) }
	}
}

// MARK: - Binding methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLExecute {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func xbind(_ value: Bool,	_ index: Int32)	{ sqlite3_bind_int(statement,	 index, Int32(value ? 1 : 0))	}
	private func xbind(_ value: Int8,	_ index: Int32)	{ sqlite3_bind_int(statement,	 index, Int32(value))			}
	private func xbind(_ value: Int16,	_ index: Int32)	{ sqlite3_bind_int(statement,	 index, Int32(value))			}
	private func xbind(_ value: Int32,	_ index: Int32)	{ sqlite3_bind_int(statement,	 index, Int32(value))			}
	private func xbind(_ value: Int64,	_ index: Int32)	{ sqlite3_bind_int64(statement,	 index, Int64(value))			}
	private func xbind(_ value: Int,	_ index: Int32)	{ sqlite3_bind_int64(statement,	 index, Int64(value))			}
	private func xbind(_ value: Float,	_ index: Int32)	{ sqlite3_bind_double(statement, index, Double(value))			}
	private func xbind(_ value: Double,	_ index: Int32)	{ sqlite3_bind_double(statement, index, Double(value))			}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func xbind(_ value: String,	 _ index: Int32, _ encrypt: Bool) { sqlitex_bind_text(statement, index, value,			encrypt) }
	private func xbind(_ value: [Any],	 _ index: Int32, _ encrypt: Bool) { sqlitex_bind_text(statement, index, convert(value),	encrypt) }
	private func xbind(_ value: AnyDict, _ index: Int32, _ encrypt: Bool) { sqlitex_bind_text(statement, index, convert(value),	encrypt) }
	private func xbind(_ value: Date,	 _ index: Int32, _ encrypt: Bool) { sqlitex_bind_text(statement, index, GQLDate[value],	encrypt) }
	private func xbind(_ value: Data,	 _ index: Int32, _ encrypt: Bool) { sqlitex_bind_blob(statement, index, value,			encrypt) }

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func sqlitex_bind_text(_ stmt: OpaquePointer!, _ index: Int32, _ text: String, _ encrypt: Bool) {

		if (encrypt) {
			if let crypted = GQLCryptor.encrypt(text) {
				sqlitex_bind_text(stmt, index, crypted)
			}
		} else {
			sqlitex_bind_text(stmt, index, text)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func sqlitex_bind_blob(_ stmt: OpaquePointer!, _ index: Int32, _ value: Data, _ encrypt: Bool) {

		if (encrypt) {
			if let crypted = GQLCryptor.encrypt(value) {
				sqlitex_bind_blob(stmt, index, crypted)
			}
		} else {
			sqlitex_bind_blob(stmt, index, value)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func sqlitex_bind_text(_ stmt: OpaquePointer!, _ index: Int32, _ text: String) {

		sqlite3_bind_text(stmt, index, NSString(string: text).utf8String, -1, SQLITE_TRANSIENT)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func sqlitex_bind_blob(_ stmt: OpaquePointer!, _ index: Int32, _ value: Data) {

		_ = value.withUnsafeBytes {
			sqlite3_bind_blob(stmt, index, $0.bindMemory(to: UInt8.self).baseAddress, Int32(value.count), SQLITE_TRANSIENT)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func convert(_ object: Any) -> String {

		if let data = try? JSONSerialization.data(withJSONObject: object, options: [.withoutEscapingSlashes]) {
			if let text = String(data: data, encoding: .utf8) {
				return text
			}
		}
		fatalError("JSONSerialization error. \(object)")
	}
}

// MARK: - Values methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLExecute {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func values() -> [String: Any] {

		var index: Int32 = 0
		var values: [String: Any] = [:]

		for column in schema.columns {
			let name = column.name
			switch column.type {

			case "Bool":	values[name] = Bool(sqlite3_column_int(statement, index) == 1)
			case "Int8":	values[name] = Int8(sqlite3_column_int(statement, index))
			case "Int16":	values[name] = Int16(sqlite3_column_int(statement, index))
			case "Int32":	values[name] = Int32(sqlite3_column_int(statement, index))
			case "Int64":	values[name] = Int64(sqlite3_column_int64(statement, index))
			case "Int":		values[name] = Int(sqlite3_column_int64(statement, index))
			case "Float":	values[name] = Float(sqlite3_column_double(statement, index))
			case "Double":	values[name] = Double(sqlite3_column_double(statement, index))

			case "String":	values[name] = sqlitex_column_text(statement, index, column.encrypt)
			case "Array":	values[name] = sqlitex_column_text(statement, index, column.encrypt)
			case "Dict":	values[name] = sqlitex_column_text(statement, index, column.encrypt)
			case "Date":	values[name] = sqlitex_column_text(statement, index, column.encrypt)
			case "Data":	values[name] = sqlitex_column_blob(statement, index, column.encrypt)

			default: break
			}
			index += 1
		}

		return values
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func sqlitex_column_text(_ stmt: OpaquePointer!, _ index: Int32, _ encrypt: Bool) -> String {

		guard let value = sqlite3_column_text(statement, index) else { return "" }

		let text = String(cString: value)

		if (encrypt) {
			return GQLCryptor.decrypt(text) ?? ""
		} else {
			return text
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func sqlitex_column_blob(_ stmt: OpaquePointer!, _ index: Int32, _ encrypt: Bool) -> Data {

		guard let bytes = sqlite3_column_blob(statement, index) else { return Data() }

		let count = Int(sqlite3_column_bytes(statement, index))

		let data = Data(bytes: bytes, count: count)

		if (encrypt) {
			return GQLCryptor.decrypt(data) ?? Data()
		} else {
			return data
		}
	}
}
