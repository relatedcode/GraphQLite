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
@objc public protocol GQLObject {

	static func primaryKey() -> String

	@objc optional static func encryptedColumns() -> [String]
}

// MARK: - Helper methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func table() -> String {

		return String(describing: self)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func table() -> String {

		return String(describing: type(of: self))
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func object() -> NSObject {

		if let otype = self as? NSObject.Type { return otype.init() }

		fatalError("Object must be a subclass of NSObject.")
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func object() -> NSObject {

		if let object = self as? NSObject { return object }

		fatalError("Object must be a subclass of NSObject.")
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private static func schema() -> GQLSchema {

		return GQLSchemas[table()]
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func schema() -> GQLSchema {

		return GQLSchemas[table()]
	}
}

// MARK: - Create methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func create(_ values: [String: Any]) -> Self {

		let object = self.object()

		for column in schema().columns {
			let name = column.name
			switch column.type {

			case "Bool":	if let value = values[name] as? Bool		{ object.setValue(value,			forKey: name)	}
			case "Int8":	if let value = values[name] as? Int8		{ object.setValue(value,			forKey: name)	}
			case "Int16":	if let value = values[name] as? Int16		{ object.setValue(value,			forKey: name)	}
			case "Int32":	if let value = values[name] as? Int32		{ object.setValue(value,			forKey: name)	}
			case "Int64":	if let value = values[name] as? Int64		{ object.setValue(value,			forKey: name)	}
			case "Int":		if let value = values[name] as? Int			{ object.setValue(value,			forKey: name)	}
			case "Float":	if let value = values[name] as? Float		{ object.setValue(value,			forKey: name)	}
			case "Double":	if let value = values[name] as? Double		{ object.setValue(value,			forKey: name)	}
			case "String":	if let value = values[name] as? String		{ object.setValue(value,			forKey: name)	}

			case "Array":	if let value = values[name] as? [Any]		{ object.setValue(value,			forKey: name)	}
							if let value = values[name] as? String		{ object.setValue(convert(value),	forKey: name)	}

			case "Dict":	if let value = values[name] as? AnyDict		{ object.setValue(value,			forKey: name)	}
							if let value = values[name] as? String		{ object.setValue(convert(value),	forKey: name)	}

			case "Date":	if let value = values[name] as? Date		{ object.setValue(value,			forKey: name)	}
							if let value = values[name] as? String		{ object.setValue(GQLDate[value],	forKey: name)	}

			case "Data":	if let value = values[name] as? Data		{ object.setValue(value,			forKey: name)	}

			default: break
			}
		}

		return object as! Self
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private static func convert(_ text: String) -> Any? {

		if let data = text.data(using: .utf8) {
			if let object = try? JSONSerialization.jsonObject(with: data) {
				return object
			}
		}
		return nil
	}
}

// MARK: - Values methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func values(for names: [String]) -> [String: Any] {

		var columns: [GQLColumn] = []

		for column in schema().columns {
			if (names.contains(column.name)) {
				columns.append(column)
			}
		}

		return values(columns)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func values(except names: [String]) -> [String: Any] {

		var columns: [GQLColumn] = []

		for column in schema().columns {
			if (!names.contains(column.name)) {
				columns.append(column)
			}
		}

		return values(columns)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func values() -> [String: Any] {

		let columns = schema().columns

		return values(columns)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func values(_ columns: [GQLColumn]) -> [String: Any] {

		let object = self.object()

		var values: [String: Any] = [:]

		for column in columns {
			let name = column.name
			switch column.type {

			case "Bool":	if let value = object.value(forKey: name) as? Bool		{ values[name] = value			}
			case "Int8":	if let value = object.value(forKey: name) as? Int8		{ values[name] = value			}
			case "Int16":	if let value = object.value(forKey: name) as? Int16		{ values[name] = value			}
			case "Int32":	if let value = object.value(forKey: name) as? Int32		{ values[name] = value			}
			case "Int64":	if let value = object.value(forKey: name) as? Int64		{ values[name] = value			}
			case "Int":		if let value = object.value(forKey: name) as? Int		{ values[name] = value			}
			case "Float":	if let value = object.value(forKey: name) as? Float		{ values[name] = value			}
			case "Double":	if let value = object.value(forKey: name) as? Double	{ values[name] = value			}
			case "String":	if let value = object.value(forKey: name) as? String	{ values[name] = value			}
			case "Array":	if let value = object.value(forKey: name) as? [Any]		{ values[name] = convert(value)	}
			case "Dict":	if let value = object.value(forKey: name) as? AnyDict	{ values[name] = convert(value)	}
			case "Date":	if let value = object.value(forKey: name) as? Date		{ values[name] = GQLDate[value]	}
			case "Data":	if let value = object.value(forKey: name) as? Data		{ values[name] = value			}

			default: break
			}
		}

		return values
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

// MARK: - Export methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func export(for names: [String]) -> [String: Any] {

		var values: [String: Any] = [:]

		let mirror = Mirror(reflecting: self)

		for property in mirror.children {
			if let name = property.label {
				if (names.contains(name)) {
					values[name] = property.value
				}
			}
		}

		return values
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func export(except names: [String]) -> [String: Any] {

		var values: [String: Any] = [:]

		let mirror = Mirror(reflecting: self)

		for property in mirror.children {
			if let name = property.label {
				if (!names.contains(name)) {
					values[name] = property.value
				}
			}
		}

		return values
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func export() -> [String: Any] {

		var values: [String: Any] = [:]

		let mirror = Mirror(reflecting: self)

		for property in mirror.children {
			if let name = property.label {
				values[name] = property.value
			}
		}

		return values
	}
}

// MARK: - Insert methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func insert(_ db: GQLDatabase) {

		db.insert(table(), values())
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func insertUpdate(_ db: GQLDatabase) {

		db.insertUpdate(table(), values())
	}
}

// MARK: - Update methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func update(_ db: GQLDatabase) {

		db.update(table(), values())
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func updateInsert(_ db: GQLDatabase) {

		db.updateInsert(table(), values())
	}
}

// MARK: - Update methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func updateOne(_ db: GQLDatabase, _ values: [String: Any], key: Any) {

		db.updateOne(table(), values, key: key)
	}

	// MARK: - arguments: none
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func updateAll(_ db: GQLDatabase, _ values: [String: Any], _ condition: String = "", order: String = "") {

		db.updateAll(table(), values, condition, order: order)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func updateAll(_ db: GQLDatabase, _ values: [String: Any], _ condition: String = "", order: String = "", limit: Int) {

		db.updateAll(table(), values, condition, order: order, limit: limit)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func updateAll(_ db: GQLDatabase, _ values: [String: Any], _ condition: String = "", order: String = "", limit: Int, offset: Int) {

		db.updateAll(table(), values, condition, order: order, limit: limit, offset: offset)
	}

	// MARK: - arguments: [Any]
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func updateAll(_ db: GQLDatabase, _ values: [String: Any], _ condition: String, _ arguments: [Any], order: String = "") {

		db.updateAll(table(), values, condition, arguments, order: order)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func updateAll(_ db: GQLDatabase, _ values: [String: Any], _ condition: String, _ arguments: [Any], order: String = "", limit: Int) {

		db.updateAll(table(), values, condition, arguments, order: order, limit: limit)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func updateAll(_ db: GQLDatabase, _ values: [String: Any], _ condition: String, _ arguments: [Any], order: String = "", limit: Int, offset: Int) {

		db.updateAll(table(), values, condition, arguments, order: order, limit: limit, offset: offset)
	}

	// MARK: - arguments: [String: Any]
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func updateAll(_ db: GQLDatabase, _ values: [String: Any], _ condition: String, _ arguments: [String: Any], order: String = "") {

		db.updateAll(table(), values, condition, arguments, order: order)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func updateAll(_ db: GQLDatabase, _ values: [String: Any], _ condition: String, _ arguments: [String: Any], order: String = "", limit: Int) {

		db.updateAll(table(), values, condition, arguments, order: order, limit: limit)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func updateAll(_ db: GQLDatabase, _ values: [String: Any], _ condition: String, _ arguments: [String: Any], order: String = "", limit: Int, offset: Int) {

		db.updateAll(table(), values, condition, arguments, order: order, limit: limit, offset: offset)
	}
}

// MARK: - Delete methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func delete(_ db: GQLDatabase) {

		let object = self.object()
		let schema = self.schema()

		if let key = object.value(forKey: schema.key) {
			db.deleteOne(table(), key: key)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func deleteOne(_ db: GQLDatabase, key: Any) {

		db.deleteOne(table(), key: key)
	}

	// MARK: - arguments: none
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func deleteAll(_ db: GQLDatabase, _ condition: String = "", order: String = "") {

		db.deleteAll(table(), condition, order: order)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func deleteAll(_ db: GQLDatabase, _ condition: String = "", order: String = "", limit: Int) {

		db.deleteAll(table(), condition, order: order, limit: limit)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func deleteAll(_ db: GQLDatabase, _ condition: String = "", order: String = "", limit: Int, offset: Int) {

		db.deleteAll(table(), condition, order: order, limit: limit, offset: offset)
	}

	// MARK: - arguments: [Any]
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func deleteAll(_ db: GQLDatabase, _ condition: String, _ arguments: [Any], order: String = "") {

		db.deleteAll(table(), condition, arguments, order: order)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func deleteAll(_ db: GQLDatabase, _ condition: String, _ arguments: [Any], order: String = "", limit: Int) {

		db.deleteAll(table(), condition, arguments, order: order, limit: limit)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func deleteAll(_ db: GQLDatabase, _ condition: String, _ arguments: [Any], order: String = "", limit: Int, offset: Int) {

		db.deleteAll(table(), condition, arguments, order: order, limit: limit, offset: offset)
	}

	// MARK: - arguments: [String: Any]
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func deleteAll(_ db: GQLDatabase, _ condition: String, _ arguments: [String: Any], order: String = "") {

		db.deleteAll(table(), condition, arguments, order: order)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func deleteAll(_ db: GQLDatabase, _ condition: String, _ arguments: [String: Any], order: String = "", limit: Int) {

		db.deleteAll(table(), condition, arguments, order: order, limit: limit)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func deleteAll(_ db: GQLDatabase, _ condition: String, _ arguments: [String: Any], order: String = "", limit: Int, offset: Int) {

		db.deleteAll(table(), condition, arguments, order: order, limit: limit, offset: offset)
	}
}

// MARK: - Fetch methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func fetchOne(_ db: GQLDatabase, key: Any) -> Self? {

		if let values = db.fetchOne(table(), key: key) {
			return create(values)
		}
		return nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func fetchOne(_ db: GQLDatabase, _ condition: String = "", order: String = "") -> Self? {

		if let values = db.fetchOne(table(), condition, order: order) {
			return create(values)
		}
		return nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func fetchOne(_ db: GQLDatabase, _ condition: String, _ arguments: [Any], order: String = "") -> Self? {

		if let values = db.fetchOne(table(), condition, arguments, order: order) {
			return create(values)
		}
		return nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func fetchOne(_ db: GQLDatabase, _ condition: String, _ arguments: [String: Any], order: String = "") -> Self? {

		if let values = db.fetchOne(table(), condition, arguments, order: order) {
			return create(values)
		}
		return nil
	}

	// MARK: - arguments: none
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func fetchAll(_ db: GQLDatabase, _ condition: String = "", order: String = "") -> [Self] {

		var array: [Self] = []
		for values in db.fetchAll(table(), condition, order: order) {
			array.append(create(values))
		}
		return array
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func fetchAll(_ db: GQLDatabase, _ condition: String = "", order: String = "", limit: Int) -> [Self] {

		var array: [Self] = []
		for values in db.fetchAll(table(), condition, order: order, limit: limit) {
			array.append(create(values))
		}
		return array
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func fetchAll(_ db: GQLDatabase, _ condition: String = "", order: String = "", limit: Int, offset: Int) -> [Self] {

		var array: [Self] = []
		for values in db.fetchAll(table(), condition, order: order, limit: limit, offset: offset) {
			array.append(create(values))
		}
		return array
	}

	// MARK: - arguments: [Any]
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func fetchAll(_ db: GQLDatabase, _ condition: String, _ arguments: [Any], order: String = "") -> [Self] {

		var array: [Self] = []
		for values in db.fetchAll(table(), condition, arguments, order: order) {
			array.append(create(values))
		}
		return array
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func fetchAll(_ db: GQLDatabase, _ condition: String, _ arguments: [Any], order: String = "", limit: Int) -> [Self] {

		var array: [Self] = []
		for values in db.fetchAll(table(), condition, arguments, order: order, limit: limit) {
			array.append(create(values))
		}
		return array
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func fetchAll(_ db: GQLDatabase, _ condition: String, _ arguments: [Any], order: String = "", limit: Int, offset: Int) -> [Self] {

		var array: [Self] = []
		for values in db.fetchAll(table(), condition, arguments, order: order, limit: limit, offset: offset) {
			array.append(create(values))
		}
		return array
	}

	// MARK: - arguments: [String: Any]
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func fetchAll(_ db: GQLDatabase, _ condition: String, _ arguments: [String: Any], order: String = "") -> [Self] {

		var array: [Self] = []
		for values in db.fetchAll(table(), condition, arguments, order: order) {
			array.append(create(values))
		}
		return array
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func fetchAll(_ db: GQLDatabase, _ condition: String, _ arguments: [String: Any], order: String = "", limit: Int) -> [Self] {

		var array: [Self] = []
		for values in db.fetchAll(table(), condition, arguments, order: order, limit: limit) {
			array.append(create(values))
		}
		return array
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func fetchAll(_ db: GQLDatabase, _ condition: String, _ arguments: [String: Any], order: String = "", limit: Int, offset: Int) -> [Self] {

		var array: [Self] = []
		for values in db.fetchAll(table(), condition, arguments, order: order, limit: limit, offset: offset) {
			array.append(create(values))
		}
		return array
	}
}

// MARK: - Check methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func check(_ db: GQLDatabase, key: Any) -> Bool {

		return db.check(table(), key: key)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func check(_ db: GQLDatabase, _ condition: String = "") -> Bool {

		return db.check(table(), condition)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func check(_ db: GQLDatabase, _ condition: String, _ arguments: [Any]) -> Bool {

		return db.check(table(), condition, arguments)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func check(_ db: GQLDatabase, _ condition: String, _ arguments: [String: Any]) -> Bool {

		return db.check(table(), condition, arguments)
	}
}

// MARK: - Count methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func count(_ db: GQLDatabase, _ condition: String = "") -> Int {

		return db.count(table(), condition)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func count(_ db: GQLDatabase, _ condition: String, _ arguments: [Any]) -> Int {

		return db.count(table(), condition, arguments)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func count(_ db: GQLDatabase, _ condition: String, _ arguments: [String: Any]) -> Int {

		return db.count(table(), condition, arguments)
	}
}

// MARK: - Observer methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@discardableResult public static func createObserver(_ db: GQLDatabase, _ type: GQLObserverType, _ condition: String = "", callback: @escaping GQLObserverCallback) -> String {

		return db.createObserver(table(), type, condition, callback)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@discardableResult public static func createObserver(_ db: GQLDatabase, _ types: [GQLObserverType], _ condition: String = "", callback: @escaping GQLObserverCallback) -> String {

		return db.createObserver(table(), types, condition, callback)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func removeObserver(_ db: GQLDatabase, _ observerId: String?) {

		if let observerId = observerId {
			db.removeObserver(observerId)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public static func removeObserver(_ db: GQLDatabase, _ observerId: String) {

		db.removeObserver(observerId)
	}
}
