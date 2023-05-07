//
// Copyright (c) 2021 Related Code - https://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import GraphQLite

//-----------------------------------------------------------------------------------------------------------------------------------------------
class TodoView: UIViewController {

	@IBOutlet var tableView: UITableView!

	private var todos: [Todo] = []

	private var observerId: String?

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Todo"

		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(actionCreate))

		tableView.tableFooterView = UIView()

		loadTodos()
		observeTodos()
	}

	// MARK: - Database methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadTodos() {

		todos.removeAll()

		todos = Todo.fetchAll(gqldb, "deleted = ?", [false], order: "createdAt DESC")

		tableView.reloadData()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func observeTodos() {

		let types: [GQLObserverType] = [.insert, .update]

		observerId = Todo.createObserver(gqldb, types) { method, objectId in
			DispatchQueue.main.async {
				self.loadTodos()
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func createTodo(_ title: String) {

		let todo = Todo()
		todo.title = title
		todo.insert(gqldb)

		ServerData.createTodo(todo)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func completeTodo(_ todo: Todo) {

		todo.completed = true
		todo.updatedAt = Date()
		todo.update(gqldb)

		ServerData.updateTodo(todo)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func deleteTodo(_ todo: Todo) {

		todo.deleted = true
		todo.updatedAt = Date()
		todo.update(gqldb)

		ServerData.updateTodo(todo)
	}

	// MARK: - User actions
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionCreate() {

		let alert = UIAlertController(title: "Create Todo", message: "Enter a new todo item to create", preferredStyle: .alert)

		alert.addTextField(configurationHandler: { textField in
			textField.placeholder = "Todo item"
			textField.autocapitalizationType = .words
		})

		alert.addAction(UIAlertAction(title: "Create", style: .default) { action in
			if let textField = alert.textFields?[0] {
				if let text = textField.text {
					if (!text.isEmpty) {
						self.createTodo(text)
					}
				}
			}
		})

		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

		present(alert, animated: true)
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension TodoView: UITableViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 1
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return todos.count
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell")
		if (cell == nil) { cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell") }

		let todo = todos[indexPath.row]

		cell.textLabel?.text = todo.title
		cell.accessoryType = todo.completed ? .checkmark : .none

		return cell
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		
		let action = UIContextualAction(style: .normal, title: nil) { [self] (action, sourceView, completionHandler) in
			let todo = todos[indexPath.row]
			DispatchQueue.main.async(after: 0.35) {
				completeTodo(todo)
			}
			completionHandler(true)
		}

		action.image = UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .heavy))
		action.backgroundColor = .systemGreen

		return UISwipeActionsConfiguration(actions: [action])
	}
	
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

		let action = UIContextualAction(style: .destructive, title: nil) { [self] (action, sourceView, completionHandler) in
			let todo = todos[indexPath.row]
			DispatchQueue.main.async(after: 0.35) {
				deleteTodo(todo)
			}
			completionHandler(true)
		}

		action.image = UIImage(systemName: "trash", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .heavy))
		action.backgroundColor = .systemRed

		return UISwipeActionsConfiguration(actions: [action])
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension TodoView: UITableViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)
	}
}
