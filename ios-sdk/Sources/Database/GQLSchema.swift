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
class GQLSchema: NSObject {

	var otype: GQLObject.Type

	var table = ""

	var key = ""

	var columns: [GQLColumn] = []

	var columnz: [String: GQLColumn] = [:]

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(_ otype: GQLObject.Type) {

		self.otype = otype

		super.init()

		self.initialize()
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
class GQLColumn: NSObject {

	var name = ""
	var type = ""
	var sqlite = ""
	var encrypt = false

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(_ name: String) {

		super.init()

		self.name = name
	}
}

// MARK: - Init methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLSchema {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func initialize() {

		table = otype.table()

		key = otype.primaryKey()

		addColumns()

		checkIntegrity()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func addColumns() {

		let mirror = Mirror(reflecting: otype.object())

		for property in mirror.children {
			if let name = property.label {
				if (name == key) {
					addColumn(name, property.value)
				}
			}
		}

		for property in mirror.children {
			if let name = property.label {
				if (name != key) {
					addColumn(name, property.value)
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func addColumn(_ name: String, _ value: Any) {

		let column = GQLColumn(name)
		let typex = type(of: value)
		let typez = String(describing: typex)

		if (typex == Bool.self)							{ column.sqlite = "INTEGER";	column.type = "Bool"	}
		if (typex == Int8.self)							{ column.sqlite = "INTEGER";	column.type = "Int8"	}
		if (typex == Int16.self)						{ column.sqlite = "INTEGER";	column.type = "Int16"	}
		if (typex == Int32.self)						{ column.sqlite = "INTEGER";	column.type = "Int32"	}
		if (typex == Int64.self)						{ column.sqlite = "INTEGER";	column.type = "Int64"	}
		if (typex == Int.self)							{ column.sqlite = "INTEGER";	column.type = "Int"		}
		if (typex == Float.self)						{ column.sqlite = "REAL";		column.type = "Float"	}
		if (typex == Double.self)						{ column.sqlite = "REAL";		column.type = "Double"	}
		if (typex == String.self)						{ column.sqlite = "TEXT";		column.type = "String"	}
		if (typez.starts(with: "Array"))				{ column.sqlite = "TEXT";		column.type = "Array"	}
		if (typez.starts(with: "Dictionary<String"))	{ column.sqlite = "TEXT";		column.type = "Dict"	}
		if (typex == Date.self)							{ column.sqlite = "TEXT";		column.type = "Date"	}
		if (typex == Data.self)							{ column.sqlite = "BLOB";		column.type = "Data"	}

		if let encryptedColumns = otype.encryptedColumns?() {
			column.encrypt = encryptedColumns.contains(name)
		}

		if (column.type.isEmpty == false) {
			columns.append(column)
			columnz[name] = column
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func checkIntegrity() {

		if (columnz[key] == nil) {
			fatalError(String(format: "%@ primaryKey value (%@) seems to be invalid.", table, key))
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func typeKey() -> String {

		guard let column = columnz[key] else {
			fatalError(String(format: "%@ primaryKey value (%@) seems to be invalid.", table, key))
		}
		return column.type
	}
}

// MARK: - Table Create, Drop methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLSchema {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func createTable() -> String {

		var temp = ""

		for column in columns {
			let comma = temp.isEmpty ? "" : ", "
			let textKey = (column.name == key) ? " PRIMARY KEY NOT NULL" : ""
			temp += comma + column.name + " " + column.sqlite + textKey
		}

		return String(format: "CREATE TABLE IF NOT EXISTS %@ (%@);", table, temp)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func dropTable() -> String {

		return String(format: "DROP TABLE IF EXISTS %@;", table)
	}
}

// MARK: - Insert methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLSchema {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func insert() -> String {

		var temp1 = ""
		var temp2 = ""

		for column in columns {
			let comma = temp1.isEmpty ? "" : ", "
			temp1 += comma + column.name
			temp2 += comma + "?"
		}

		return String(format: "INSERT OR IGNORE INTO %@ (%@) VALUES (%@);", table, temp1, temp2)
	}
}

// MARK: - Update methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLSchema {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func update(_ values: [String: Any]) -> String {

		var temp = ""

		for column in columns {
			if (column.name != key) {
				if (values[column.name] != nil) {
					let comma = temp.isEmpty ? "" : ", "
					temp += comma + column.name + " = ?"
				}
			}
		}

		return String(format: "UPDATE %@ SET %@ WHERE %@ = ?;", table, temp, key)
	}
}

// MARK: - Update methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLSchema {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateOne(_ values: [String: Any]) -> String {

		var temp = ""

		for column in columns {
			if (column.name != key) {
				if (values[column.name] != nil) {
					let comma = temp.isEmpty ? "" : ", "
					temp += comma + column.name + " = ?"
				}
			}
		}

		return String(format: "UPDATE %@ SET %@ WHERE %@ = ?;", table, temp, key)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateAll(_ values: [String: Any], _ condition: String, _ order: String, _ limit: Int = 0, _ offset: Int = 0) -> String {

		var temp = ""

		for column in columns {
			if (column.name != key) {
				if (values[column.name] != nil) {
					let comma = temp.isEmpty ? "" : ", "
					temp += comma + column.name + " = ?"
				}
			}
		}

		let valid_offset = (limit != 0) && (offset != 0)

		let wherex = (condition != "")	? String(format: " WHERE %@", condition) : ""
		let orderx = (order != "")		? String(format: " ORDER BY %@", order)	 : ""
		let limitx = (limit != 0)		? String(format: " LIMIT %d", limit)	 : ""
		let offsetx	= (valid_offset)	? String(format: " OFFSET %d", offset)	 : ""

		return String(format: "UPDATE %@ SET %@ %@%@%@%@;", table, temp, wherex, orderx, limitx, offsetx)
	}
}

// MARK: - Delete methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLSchema {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func deleteOne() -> String {

		let wherex = String(format: " WHERE %@ = ?", key)

		return String(format: "DELETE FROM %@%@;", table, wherex)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func deleteAll(_ condition: String, _ order: String, _ limit: Int = 0, _ offset: Int = 0) -> String {

		let valid_offset = (limit != 0) && (offset != 0)

		let wherex	= (condition != "")	? String(format: " WHERE %@", condition) : ""
		let orderx	= (order != "")		? String(format: " ORDER BY %@", order)	 : ""
		let limitx	= (limit != 0)		? String(format: " LIMIT %d", limit)	 : ""
		let offsetx	= (valid_offset)	? String(format: " OFFSET %d", offset)	 : ""

		return String(format: "DELETE FROM %@%@%@%@%@;", table, wherex, orderx, limitx, offsetx)
	}
}

// MARK: - Fetch methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLSchema {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func fetchOne() -> String {

		let wherex = String(format: " WHERE %@ = ?", key)

		return String(format: "SELECT * FROM %@%@;", table, wherex)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func fetchOne(_ condition: String, _ order: String) -> String {

		let wherex = (condition != "")	? String(format: " WHERE %@", condition) : ""
		let orderx = (order != "")		? String(format: " ORDER BY %@", order)	 : ""

		return String(format: "SELECT * FROM %@%@%@ LIMIT 1;", table, wherex, orderx)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func fetchAll(_ condition: String, _ order: String, _ limit: Int = 0, _ offset: Int = 0) -> String {

		let valid_offset = (limit != 0) && (offset != 0)

		let wherex = (condition != "")	? String(format: " WHERE %@", condition) : ""
		let orderx = (order != "")		? String(format: " ORDER BY %@", order)	 : ""
		let limitx = (limit != 0)		? String(format: " LIMIT %d", limit)	 : ""
		let offsetx = (valid_offset)	? String(format: " OFFSET %d", offset)	 : ""

		return String(format: "SELECT * FROM %@%@%@%@%@;", table, wherex, orderx, limitx, offsetx)
	}
}

// MARK: - Check methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLSchema {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func check() -> String {

		let wherex = String(format: " WHERE %@ = ?", key)

		return String(format: "SELECT %@ FROM %@%@;", key, table, wherex)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func check(_ condition: String) -> String {

		let wherex = (condition != "") ? String(format: " WHERE %@", condition) : ""

		return String(format: "SELECT %@ FROM %@%@ LIMIT 1;", key, table, wherex)
	}
}

// MARK: - Count methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLSchema {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func count(_ condition: String) -> String {

		let wherex = (condition != "") ? String(format: " WHERE %@", condition) : ""

		return String(format: "SELECT COUNT(*) FROM %@%@;", table, wherex)
	}
}

// MARK: - Trigger methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLSchema {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func createTrigger(_ observerId: String, _ method: String, _ prefix: String, _ condition: String) -> String {

		let name = String(format: "trigger_%@_%@_%@", method, prefix, observerId)

		var when = ""
		if (condition.count != 0) {
			guard condition.contains("OBJ.") else {
				fatalError("Trigger condition must contain OBJ.")
			}
			let condition_new = condition.replacingOccurrences(of: "OBJ.", with: "NEW.")
			let condition_old = condition.replacingOccurrences(of: "OBJ.", with: "OLD.")
			if (prefix == "NEW") { when = String(format: "WHEN (%@)", condition_new) }
			if (prefix == "OLD") { when = String(format: "WHEN (%@)", condition_old) }
		}

		let action = String(format: "SELECT Observer('%@','%@',%@.%@,'%@');", observerId, method, prefix, key, typeKey())

		return String(format: "CREATE TRIGGER %@ AFTER %@ ON %@ %@ BEGIN %@ END;", name, method, table, when, action)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func dropTrigger(_ observerId: String, _ method: String, _ prefix: String) -> String {

		let name = String(format: "trigger_%@_%@_%@", method, prefix, observerId)

		return String(format: "DROP TRIGGER IF EXISTS %@;", name)
	}
}
