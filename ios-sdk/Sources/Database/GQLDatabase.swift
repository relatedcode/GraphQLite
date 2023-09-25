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
public enum GQLObserverType {

	case insert
	case update
	case delete
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
public typealias GQLObserverCallback = (String, Any) -> Void

//-----------------------------------------------------------------------------------------------------------------------------------------------
typealias GQLCFunction = @convention(c) (OpaquePointer?, Int32, UnsafeMutablePointer<OpaquePointer?>?) -> Void
typealias GQLFunction = @convention(block) (OpaquePointer?, Int32, UnsafeMutablePointer<OpaquePointer?>?) -> Void

//-----------------------------------------------------------------------------------------------------------------------------------------------
public class GQLDatabase: NSObject {

	private var handle: OpaquePointer?

	private var observers: [String: GQLObserverCallback] = [:]

	private var functions: [String: GQLFunction] = [:]

	private let queue = DispatchQueue(label: "com.graphqlite." + UUID().uuidString)

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public override init() {

		super.init()
		open()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public init(file: String) {

		super.init()
		open(file: file)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public init(path: String) {

		super.init()
		open(path: path)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	deinit {

		close()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func queueAsync(_ block: @escaping () -> Void) {

		queue.async {
			autoreleasepool {
				block()
			}
		}
	}
}

// MARK: - Open, Close methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLDatabase {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func open() {

		open(file: "database.sqlite")
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func open(file: String) {

		let domain = FileManager.SearchPathDomainMask.userDomainMask
		let dir = FileManager.SearchPathDirectory.applicationSupportDirectory

		if let url = try? FileManager.default.url(for: dir, in: domain, appropriateFor: nil, create: true) {
			open(path: url.appendingPathComponent(file).path)
		} else {
			GQLDebug.error("Database url error.")
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func open(path: String) {

		let flags = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX

		if (sqlite3_open_v2(path, &handle, flags, nil) != SQLITE_OK) {
			GQLDebug.error("Database open error.")
			close()
		} else {
			createTables()
			createFunction()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func close() {

		if let handle = handle {
			if (sqlite3_close(handle) != SQLITE_OK) {
				GQLDebug.error("Database close error.")
			}
			self.handle = nil
		}
	}
}

// MARK: - Table Create, Drop methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLDatabase {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func cleanupDatabase() {

		queueAsync {
			self.dropTables()
			self.createTables()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func createTables() {

		for result in GQLRuntime.classes(conformToProtocol: GQLObject.self) {
			if let otype = result as? GQLObject.Type {
				let schema = GQLSchemas[otype]
				let sql = schema.createTable()
				GQLExecute(handle, sql)?.execute()
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func dropTables() {

		for result in GQLRuntime.classes(conformToProtocol: GQLObject.self) {
			if let otype = result as? GQLObject.Type {
				let schema = GQLSchemas[otype]
				let sql = schema.dropTable()
				GQLExecute(handle, sql)?.execute()
			}
		}
	}

	// MARK: -
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func createTable(_ table: String) {

		queueAsync {
			let schema = GQLSchemas[table]
			let sql = schema.createTable()
			GQLExecute(self.handle, sql)?.execute()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func dropTable(_ table: String) {

		queueAsync {
			let schema = GQLSchemas[table]
			let sql = schema.dropTable()
			GQLExecute(self.handle, sql)?.execute()
		}
	}
}

// MARK: - Execute methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLDatabase {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func execute(_ sql: String) {

		queueAsync {
			GQLExecute(self.handle, sql)?.execute()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func execute(_ sql: String, _ arguments: [Any]) {

		queueAsync {
			GQLExecute(self.handle, sql)?.execute(arguments)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func execute(_ sql: String, _ arguments: [String: Any]) {

		queueAsync {
			GQLExecute(self.handle, sql)?.execute(arguments)
		}
	}
}

// MARK: - Transaction methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLDatabase {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func beginTransaction() {

		GQLExecute(handle, "BEGIN;")?.execute()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func commitTransaction() {

		GQLExecute(handle, "COMMIT;")?.execute()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func rollbackTransaction() {

		GQLExecute(handle, "ROLLBACK;")?.execute()
	}
}

// MARK: - Export methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLDatabase {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func export(_ table: String, _ values: [String: Any]) -> [String: Any] {

		let schema = GQLSchemas[table]

		let object = schema.otype.create(values)

		return object.export()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func export(_ schema: GQLSchema, _ values: [String: Any]) -> [String: Any] {

		let object = schema.otype.create(values)

		return object.export()
	}
}

// MARK: - Insert methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLDatabase {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func insert(_ table: String, _ values: [String: Any], _ populate: Bool = false) {

		queueAsync {
			let schema = GQLSchemas[table]
			self.insert(schema, values, populate)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func insert(_ table: String, _ array: [[String: Any]], _ populate: Bool = false, _ completion: @escaping () -> Void = {}) {

		queueAsync {
			let schema = GQLSchemas[table]

			self.beginTransaction()
			for values in array {
				self.insert(schema, values, populate)
			}
			self.commitTransaction()

			completion()
		}
	}
}

// MARK: - Update methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLDatabase {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func update(_ table: String, _ values: [String: Any]) {

		queueAsync {
			let schema = GQLSchemas[table]
			self.update(schema, values)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func update(_ table: String, _ array: [[String: Any]], _ completion: @escaping () -> Void = {}) {

		queueAsync {
			let schema = GQLSchemas[table]

			self.beginTransaction()
			for values in array {
				self.update(schema, values)
			}
			self.commitTransaction()

			completion()
		}
	}
}

// MARK: - InsertUpdate methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLDatabase {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func insertUpdate(_ table: String, _ values: [String: Any], _ populate: Bool = false) {

		queueAsync {
			let schema = GQLSchemas[table]
			self.insert(schema, values, populate)
			if (sqlite3_changes(self.handle) == 0) {
				self.update(schema, values)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func insertUpdate(_ table: String, _ array: [[String: Any]], _ populate: Bool = false, _ completion: @escaping () -> Void = {}) {

		queueAsync {
			let schema = GQLSchemas[table]

			self.beginTransaction()
			for values in array {
				self.insert(schema, values, populate)
				if (sqlite3_changes(self.handle) == 0) {
					self.update(schema, values)
				}
			}
			self.commitTransaction()

			completion()
		}
	}
}

// MARK: - UpdateInsert methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLDatabase {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func updateInsert(_ table: String, _ values: [String: Any], _ populate: Bool = false) {

		queueAsync {
			let schema = GQLSchemas[table]
			self.update(schema, values)
			if (sqlite3_changes(self.handle) == 0) {
				self.insert(schema, values, populate)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func updateInsert(_ table: String, _ array: [[String: Any]], _ populate: Bool = false, _ completion: @escaping () -> Void = {}) {

		queueAsync {
			let schema = GQLSchemas[table]

			self.beginTransaction()
			for values in array {
				self.update(schema, values)
				if (sqlite3_changes(self.handle) == 0) {
					self.insert(schema, values, populate)
				}
			}
			self.commitTransaction()

			completion()
		}
	}
}

// MARK: - Insert, Update execute methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLDatabase {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func insert(_ schema: GQLSchema, _ values: [String: Any], _ populate: Bool) {

		if (populate) {
			let sql = schema.insert()
			let export = export(schema, values)
			GQLExecute(handle, sql, schema)?.insert(export)
		} else {
			let sql = schema.insert()
			GQLExecute(handle, sql, schema)?.insert(values)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func update(_ schema: GQLSchema, _ values: [String: Any]) {

		let sql = schema.update(values)
		GQLExecute(handle, sql, schema)?.update(values)
	}
}

// MARK: - Update methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLDatabase {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func updateOne(_ table: String, _ values: [String: Any], key: Any) {

		queueAsync {
			let schema = GQLSchemas[table]
			let sql = schema.updateOne(values)
			GQLExecute(self.handle, sql, schema)?.updateOne(values, key)
		}
	}

	// MARK: - arguments: none
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func updateAll(_ table: String, _ values: [String: Any], _ condition: String = "", order: String = "") {

		queueAsync {
			let schema = GQLSchemas[table]
			let sql = schema.updateAll(values, condition, order)
			GQLExecute(self.handle, sql, schema)?.updateAll(values)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func updateAll(_ table: String, _ values: [String: Any], _ condition: String = "", order: String = "", limit: Int) {

		queueAsync {
			let schema = GQLSchemas[table]
			let sql = schema.updateAll(values, condition, order, limit)
			GQLExecute(self.handle, sql, schema)?.updateAll(values)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func updateAll(_ table: String, _ values: [String: Any], _ condition: String = "", order: String = "", limit: Int, offset: Int) {

		queueAsync {
			let schema = GQLSchemas[table]
			let sql = schema.updateAll(values, condition, order, limit, offset)
			GQLExecute(self.handle, sql, schema)?.updateAll(values)
		}
	}

	// MARK: - arguments: [Any]
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func updateAll(_ table: String, _ values: [String: Any], _ condition: String, _ arguments: [Any], order: String = "") {

		queueAsync {
			let condition = self.refactor(condition, arguments)
			let arguments = self.refactor(arguments)

			let schema = GQLSchemas[table]
			let sql = schema.updateAll(values, condition, order)
			GQLExecute(self.handle, sql, schema)?.updateAll(values, arguments)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func updateAll(_ table: String, _ values: [String: Any], _ condition: String, _ arguments: [Any], order: String = "", limit: Int) {

		queueAsync {
			let condition = self.refactor(condition, arguments)
			let arguments = self.refactor(arguments)

			let schema = GQLSchemas[table]
			let sql = schema.updateAll(values, condition, order, limit)
			GQLExecute(self.handle, sql, schema)?.updateAll(values, arguments)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func updateAll(_ table: String, _ values: [String: Any], _ condition: String, _ arguments: [Any], order: String = "", limit: Int, offset: Int) {

		queueAsync {
			let condition = self.refactor(condition, arguments)
			let arguments = self.refactor(arguments)

			let schema = GQLSchemas[table]
			let sql = schema.updateAll(values, condition, order, limit, offset)
			GQLExecute(self.handle, sql, schema)?.updateAll(values, arguments)
		}
	}

	// MARK: - arguments: [String: Any]
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func updateAll(_ table: String, _ values: [String: Any], _ condition: String, _ arguments: [String: Any], order: String = "") {

		queueAsync {
			let condition = self.refactor(condition, arguments)
			let arguments = self.refactor(arguments)

			let schema = GQLSchemas[table]
			let sql = schema.updateAll(values, condition, order)
			GQLExecute(self.handle, sql, schema)?.updateAll(values, arguments)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func updateAll(_ table: String, _ values: [String: Any], _ condition: String, _ arguments: [String: Any], order: String = "", limit: Int) {

		queueAsync {
			let condition = self.refactor(condition, arguments)
			let arguments = self.refactor(arguments)

			let schema = GQLSchemas[table]
			let sql = schema.updateAll(values, condition, order, limit)
			GQLExecute(self.handle, sql, schema)?.updateAll(values, arguments)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func updateAll(_ table: String, _ values: [String: Any], _ condition: String, _ arguments: [String: Any], order: String = "", limit: Int, offset: Int) {

		queueAsync {
			let condition = self.refactor(condition, arguments)
			let arguments = self.refactor(arguments)

			let schema = GQLSchemas[table]
			let sql = schema.updateAll(values, condition, order, limit, offset)
			GQLExecute(self.handle, sql, schema)?.updateAll(values, arguments)
		}
	}
}

// MARK: - Delete methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLDatabase {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func deleteOne(_ table: String, key: Any) {

		queueAsync {
			let schema = GQLSchemas[table]
			let sql = schema.deleteOne()
			GQLExecute(self.handle, sql, schema)?.deleteOne(key)
		}
	}

	// MARK: - arguments: none
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func deleteAll(_ table: String, _ condition: String = "", order: String = "") {

		queueAsync {
			let schema = GQLSchemas[table]
			let sql = schema.deleteAll(condition, order)
			GQLExecute(self.handle, sql, schema)?.deleteAll()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func deleteAll(_ table: String, _ condition: String = "", order: String = "", limit: Int) {

		queueAsync {
			let schema = GQLSchemas[table]
			let sql = schema.deleteAll(condition, order, limit)
			GQLExecute(self.handle, sql, schema)?.deleteAll()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func deleteAll(_ table: String, _ condition: String = "", order: String = "", limit: Int, offset: Int) {

		queueAsync {
			let schema = GQLSchemas[table]
			let sql = schema.deleteAll(condition, order, limit, offset)
			GQLExecute(self.handle, sql, schema)?.deleteAll()
		}
	}

	// MARK: - arguments: [Any]
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func deleteAll(_ table: String, _ condition: String, _ arguments: [Any], order: String = "") {

		queueAsync {
			let condition = self.refactor(condition, arguments)
			let arguments = self.refactor(arguments)

			let schema = GQLSchemas[table]
			let sql = schema.deleteAll(condition, order)
			GQLExecute(self.handle, sql, schema)?.deleteAll(arguments)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func deleteAll(_ table: String, _ condition: String, _ arguments: [Any], order: String = "", limit: Int) {

		queueAsync {
			let condition = self.refactor(condition, arguments)
			let arguments = self.refactor(arguments)

			let schema = GQLSchemas[table]
			let sql = schema.deleteAll(condition, order, limit)
			GQLExecute(self.handle, sql, schema)?.deleteAll(arguments)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func deleteAll(_ table: String, _ condition: String, _ arguments: [Any], order: String = "", limit: Int, offset: Int) {

		queueAsync {
			let condition = self.refactor(condition, arguments)
			let arguments = self.refactor(arguments)

			let schema = GQLSchemas[table]
			let sql = schema.deleteAll(condition, order, limit, offset)
			GQLExecute(self.handle, sql, schema)?.deleteAll(arguments)
		}
	}

	// MARK: - arguments: [String: Any]
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func deleteAll(_ table: String, _ condition: String, _ arguments: [String: Any], order: String = "") {

		queueAsync {
			let condition = self.refactor(condition, arguments)
			let arguments = self.refactor(arguments)

			let schema = GQLSchemas[table]
			let sql = schema.deleteAll(condition, order)
			GQLExecute(self.handle, sql, schema)?.deleteAll(arguments)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func deleteAll(_ table: String, _ condition: String, _ arguments: [String: Any], order: String = "", limit: Int) {

		queueAsync {
			let condition = self.refactor(condition, arguments)
			let arguments = self.refactor(arguments)

			let schema = GQLSchemas[table]
			let sql = schema.deleteAll(condition, order, limit)
			GQLExecute(self.handle, sql, schema)?.deleteAll(arguments)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func deleteAll(_ table: String, _ condition: String, _ arguments: [String: Any], order: String = "", limit: Int, offset: Int) {

		queueAsync {
			let condition = self.refactor(condition, arguments)
			let arguments = self.refactor(arguments)

			let schema = GQLSchemas[table]
			let sql = schema.deleteAll(condition, order, limit, offset)
			GQLExecute(self.handle, sql, schema)?.deleteAll(arguments)
		}
	}
}

// MARK: - Fetch methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLDatabase {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func fetchOne(_ table: String, key: Any) -> [String: Any]? {

		let schema = GQLSchemas[table]
		let sql = schema.fetchOne()
		return GQLExecute(handle, sql, schema)?.fetchOne(key)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func fetchOne(_ table: String, _ condition: String = "", order: String = "") -> [String: Any]? {

		let schema = GQLSchemas[table]
		let sql = schema.fetchOne(condition, order)
		return GQLExecute(handle, sql, schema)?.fetchOne()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func fetchOne(_ table: String, _ condition: String, _ arguments: [Any], order: String = "") -> [String: Any]? {

		let condition = refactor(condition, arguments)
		let arguments = refactor(arguments)

		let schema = GQLSchemas[table]
		let sql = schema.fetchOne(condition, order)
		return GQLExecute(handle, sql, schema)?.fetchOne(arguments)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func fetchOne(_ table: String, _ condition: String, _ arguments: [String: Any], order: String = "") -> [String: Any]? {

		let condition = refactor(condition, arguments)
		let arguments = refactor(arguments)

		let schema = GQLSchemas[table]
		let sql = schema.fetchOne(condition, order)
		return GQLExecute(handle, sql, schema)?.fetchOne(arguments)
	}

	// MARK: - arguments: none
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func fetchAll(_ table: String, _ condition: String = "", order: String = "") -> [[String: Any]] {

		let schema = GQLSchemas[table]
		let sql = schema.fetchAll(condition, order)
		return GQLExecute(handle, sql, schema)?.fetchAll() ?? []
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func fetchAll(_ table: String, _ condition: String = "", order: String = "", limit: Int) -> [[String: Any]] {

		let schema = GQLSchemas[table]
		let sql = schema.fetchAll(condition, order, limit)
		return GQLExecute(handle, sql, schema)?.fetchAll() ?? []
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func fetchAll(_ table: String, _ condition: String = "", order: String = "", limit: Int, offset: Int) -> [[String: Any]] {

		let schema = GQLSchemas[table]
		let sql = schema.fetchAll(condition, order, limit, offset)
		return GQLExecute(handle, sql, schema)?.fetchAll() ?? []
	}

	// MARK: - arguments: [Any]
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func fetchAll(_ table: String, _ condition: String, _ arguments: [Any], order: String = "") -> [[String: Any]] {

		let condition = refactor(condition, arguments)
		let arguments = refactor(arguments)

		let schema = GQLSchemas[table]
		let sql = schema.fetchAll(condition, order)
		return GQLExecute(handle, sql, schema)?.fetchAll(arguments) ?? []
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func fetchAll(_ table: String, _ condition: String, _ arguments: [Any], order: String = "", limit: Int) -> [[String: Any]] {

		let condition = refactor(condition, arguments)
		let arguments = refactor(arguments)

		let schema = GQLSchemas[table]
		let sql = schema.fetchAll(condition, order, limit)
		return GQLExecute(handle, sql, schema)?.fetchAll(arguments) ?? []
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func fetchAll(_ table: String, _ condition: String, _ arguments: [Any], order: String = "", limit: Int, offset: Int) -> [[String: Any]] {

		let condition = refactor(condition, arguments)
		let arguments = refactor(arguments)

		let schema = GQLSchemas[table]
		let sql = schema.fetchAll(condition, order, limit, offset)
		return GQLExecute(handle, sql, schema)?.fetchAll(arguments) ?? []
	}

	// MARK: - arguments: [String: Any]
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func fetchAll(_ table: String, _ condition: String, _ arguments: [String: Any], order: String = "") -> [[String: Any]] {

		let condition = refactor(condition, arguments)
		let arguments = refactor(arguments)

		let schema = GQLSchemas[table]
		let sql = schema.fetchAll(condition, order)
		return GQLExecute(handle, sql, schema)?.fetchAll(arguments) ?? []
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func fetchAll(_ table: String, _ condition: String, _ arguments: [String: Any], order: String = "", limit: Int) -> [[String: Any]] {

		let condition = refactor(condition, arguments)
		let arguments = refactor(arguments)

		let schema = GQLSchemas[table]
		let sql = schema.fetchAll(condition, order, limit)
		return GQLExecute(handle, sql, schema)?.fetchAll(arguments) ?? []
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func fetchAll(_ table: String, _ condition: String, _ arguments: [String: Any], order: String = "", limit: Int, offset: Int) -> [[String: Any]] {

		let condition = refactor(condition, arguments)
		let arguments = refactor(arguments)

		let schema = GQLSchemas[table]
		let sql = schema.fetchAll(condition, order, limit, offset)
		return GQLExecute(handle, sql, schema)?.fetchAll(arguments) ?? []
	}
}

// MARK: - Check methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLDatabase {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func check(_ table: String, key: Any) -> Bool {

		let schema = GQLSchemas[table]
		let sql = schema.check()
		return GQLExecute(handle, sql, schema)?.check(key) ?? false
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func check(_ table: String, _ condition: String = "") -> Bool {

		let schema = GQLSchemas[table]
		let sql = schema.check(condition)
		return GQLExecute(handle, sql, schema)?.check() ?? false
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func check(_ table: String, _ condition: String, _ arguments: [Any]) -> Bool {

		let condition = refactor(condition, arguments)
		let arguments = refactor(arguments)

		let schema = GQLSchemas[table]
		let sql = schema.check(condition)
		return GQLExecute(handle, sql, schema)?.check(arguments) ?? false
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func check(_ table: String, _ condition: String, _ arguments: [String: Any]) -> Bool {

		let condition = refactor(condition, arguments)
		let arguments = refactor(arguments)

		let schema = GQLSchemas[table]
		let sql = schema.check(condition)
		return GQLExecute(handle, sql, schema)?.check(arguments) ?? false
	}
}

// MARK: - Count methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLDatabase {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func count(_ table: String, _ condition: String = "") -> Int {

		let schema = GQLSchemas[table]
		let sql = schema.count(condition)
		return GQLExecute(handle, sql, schema)?.count() ?? 0
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func count(_ table: String, _ condition: String, _ arguments: [Any]) -> Int {

		let condition = refactor(condition, arguments)
		let arguments = refactor(arguments)

		let schema = GQLSchemas[table]
		let sql = schema.count(condition)
		return GQLExecute(handle, sql, schema)?.count(arguments) ?? 0
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func count(_ table: String, _ condition: String, _ arguments: [String: Any]) -> Int {

		let condition = refactor(condition, arguments)
		let arguments = refactor(arguments)

		let schema = GQLSchemas[table]
		let sql = schema.count(condition)
		return GQLExecute(handle, sql, schema)?.count(arguments) ?? 0
	}
}

// MARK: - Condition refactoring: [Any]
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLDatabase {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func refactor(_ arguments: [Any]) -> [Any] {

		var result: [Any] = []

		for argument in arguments {
			if let array = argument as? [Any] {
				for arg in array {
					result.append(arg)
				}
			} else {
				result.append(argument)
			}
		}
		return result
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func refactor(_ condition: String, _ arguments: [Any]) -> String {

		var params: [Int: String] = [:]

		for (index, argument) in arguments.enumerated() {
			if let array = argument as? [Any] {
				params[index] = createParam(array.count)
			}
		}

		if (params.isEmpty) { return condition }

		var result = ""

		for (index, component) in condition.components(separatedBy: "?").enumerated() {
			if (!component.isEmpty) {
				result += component
				if let param = params[index] {
					result += param
				} else {
					result += "?"
				}
			}
		}

		return result
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func createParam(_ count: Int) -> String {

		var temp = ""
		var comma = ""

		for _ in 0..<count {
			temp += comma + "?"
			comma = ", "
		}

		return String(format: "(%@)", temp)
	}
}

// MARK: - Condition refactoring: [String: Any]
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLDatabase {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func refactor(_ arguments: [String: Any]) -> [String: Any] {

		var arguments = arguments
		for (name, argument) in arguments {
			if let array = argument as? [Any] {
				for (index, arg) in array.enumerated() {
					let temp = createName(name, index)
					arguments[temp] = arg
				}
			}
		}
		return arguments
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func refactor(_ condition: String, _ arguments: [String: Any]) -> String {

		var skip = true
		for (_, argument) in arguments {
			if (argument as? [Any] != nil) {
				skip = false
			}
		}
		if (skip) { return condition }

		var condition = condition + " "
		for (name, argument) in arguments {
			if let array = argument as? [Any] {
				let old = String(format: " %@ ", name)
				let new = createParam(name, array.count)
				condition = condition.replacingOccurrences(of: old, with: new)
			}
		}
		return String(condition.dropLast())
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func createParam(_ name: String, _ count: Int) -> String {

		var temp = ""
		var comma = ""

		for index in 0..<count {
			temp += comma + createName(name, index)
			comma = ", "
		}

		return String(format: " (%@) ", temp)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func createName(_ name: String, _ index: Int) -> String {

		return String(format: "%@_%03ld", name, index)
	}
}

// MARK: - Observer methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLDatabase {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func createObserver(_ table: String, _ type: GQLObserverType, _ condition: String, _ callback: @escaping GQLObserverCallback) -> String {

		return createObserver(table, [type], condition, callback)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func createObserver(_ table: String, _ types: [GQLObserverType], _ condition: String, _ callback: @escaping GQLObserverCallback) -> String {

		let observerId = UUID().uuidString.replacingOccurrences(of: "-", with: "")

		observers[observerId] = callback

		queueAsync {
			let schema = GQLSchemas[table]
			self.createTriggers(schema, observerId, types, condition)
		}

		return observerId
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func removeObserver(_ observerId: String) {

		observers.removeValue(forKey: observerId)

		queueAsync {
			self.dropTriggers(observerId)
		}
	}

	// MARK: -
	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func createTriggers(_ schema: GQLSchema, _ observerId: String, _ types: [GQLObserverType], _ condition: String) {

		if (types.contains(.insert))	{ createTrigger(schema, observerId, "INSERT", "NEW", condition) }
		if (types.contains(.update))	{ createTrigger(schema, observerId, "UPDATE", "NEW", condition) }
		if (types.contains(.delete))	{ createTrigger(schema, observerId, "DELETE", "OLD", condition) }
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func createTrigger(_ schema: GQLSchema, _ observerId: String, _ method: String, _ prefix: String, _ condition: String) {

		let sql = schema.createTrigger(observerId, method, prefix, condition)
		GQLExecute(handle, sql)?.execute()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func dropTriggers(_ observerId: String) {

		dropTrigger(observerId, "INSERT", "NEW")
		dropTrigger(observerId, "UPDATE", "NEW")
		dropTrigger(observerId, "DELETE", "OLD")
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func dropTrigger(_ observerId: String, _ method: String, _ prefix: String) {

		let sql = GQLSchema.dropTrigger(observerId, method, prefix)
		GQLExecute(handle, sql)?.execute()
	}
}

// MARK: - Function methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLDatabase {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func createFunction() {

		if (functions["Observer"] == nil) {
			createFunction("Observer") { observerId, method, key in
				if let callback = self.observers[observerId] {
					callback(method, key)
				} else {
					self.removeObserver(observerId)
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func createFunction(_ name: String, _ block: @escaping (String, String, Any) -> Void) {

		guard let handle = handle else { return }

		let flags = SQLITE_UTF8 | SQLITE_DETERMINISTIC

		let function: GQLFunction = { context, argc, argv in
			if let argv = argv, (argc == 4) {
				let observerId	= String(cString: sqlite3_value_text(argv[0]))
				let method		= String(cString: sqlite3_value_text(argv[1]))
				let key			= String(cString: sqlite3_value_text(argv[2]))
				let type		= String(cString: sqlite3_value_text(argv[3]))
				block(observerId, method, self.convert(key, type))
			}
		}
		let pointer = unsafeBitCast(function, to: UnsafeMutableRawPointer.self)

		let cfunction: GQLCFunction = { context, argc, argv in
			let pointer = sqlite3_user_data(context)
			let function = unsafeBitCast(pointer, to: GQLFunction.self)
			function(context, argc, argv)
		}

		if (sqlite3_create_function_v2(handle, name, -1, flags, pointer, cfunction, nil, nil, nil) == SQLITE_OK) {
			functions[name] = function
		} else {
			GQLDebug.error(handle)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func convert(_ value: String, _ type: String) -> Any {

		switch type {
		case "Bool":	return Bool(value)!
		case "Int8":	return Int8(value)!
		case "Int16":	return Int16(value)!
		case "Int32":	return Int32(value)!
		case "Int64":	return Int64(value)!
		case "Int":		return Int(value)!
		case "Float":	return Float(value)!
		case "Double":	return Double(value)!
		default:		return value
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func deleteFunction(_ name: String) {

		guard let handle = handle else { return }

		let flags = SQLITE_UTF8

		if (sqlite3_create_function_v2(handle, name, -1, flags, nil, nil, nil, nil, nil) == SQLITE_OK) {
			functions.removeValue(forKey: name)
		} else {
			GQLDebug.error(handle)
		}
	}
}
