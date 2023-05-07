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
class ListView: UITableViewController {

	private var objects: [People] = []
	private var observerId: String?

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Star Wars"

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)

		loadPeople()
		createObserver()
	}

	// MARK: - Database methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadPeople() {

		objects = People.fetchAll(gqldb)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func createObserver() {

		let types: [GQLObserverType] = [.insert, .update]

		observerId = People.createObserver(gqldb, types) { [self] (method, objectId) in
			if (method == "INSERT") { refreshInsert(objectId) }
			if (method == "UPDATE") { refreshUpdate(objectId) }
		}
	}

	// MARK: - Database methods (refresh)
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func refreshInsert(_ objectId: Any) {

		if let object = People.fetchOne(gqldb, key: objectId) {
			DispatchQueue.main.async { [self] in
				objects.append(object)
				tableView.reloadData()
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func refreshUpdate(_ objectId: Any) {

		if let object = People.fetchOne(gqldb, key: objectId) {
			let index = indexOf(objectId)
			DispatchQueue.main.async { [self] in
				if let index = index {
					objects[index] = object
					tableView.reloadData()
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func indexOf(_ objectId: Any) -> Int? {

		for (index, object) in objects.enumerated() {
			if (object.id == objectId as! String) {
				return index
			}
		}
		return nil
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ListView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func numberOfSections(in tableView: UITableView) -> Int {

		return 1
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return objects.count
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
		if (cell == nil) { cell = UITableViewCell(style: .default, reuseIdentifier: "cell") }

		let people = objects[indexPath.row]
		cell?.textLabel?.text = people.name
		cell?.accessoryType = .disclosureIndicator

		return cell!
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ListView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

		return 50
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		let people = objects[indexPath.row]
		let peopleView = PeopleView(people)
		navigationController?.pushViewController(peopleView, animated: true)
	}
}
