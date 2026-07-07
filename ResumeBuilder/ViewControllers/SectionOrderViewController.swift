import UIKit

final class SectionOrderViewController: UITableViewController {
    private var sectionOrder: [ResumeSectionType]
    private let onUpdate: ([ResumeSectionType]) -> Void

    init(sectionOrder: [ResumeSectionType], onUpdate: @escaping ([ResumeSectionType]) -> Void) {
        self.sectionOrder = sectionOrder
        self.onUpdate = onUpdate
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Reorder Sections"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        navigationItem.rightBarButtonItem = editButtonItem
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            onUpdate(sectionOrder)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sectionOrder.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let sectionType = sectionOrder[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = sectionType.title
        config.image = UIImage(systemName: sectionType.iconName)
        config.imageProperties.tintColor = .systemBlue
        cell.contentConfiguration = config
        cell.showsReorderControl = true
        return cell
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = sectionOrder.remove(at: sourceIndexPath.row)
        sectionOrder.insert(item, at: destinationIndexPath.row)
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }

    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        false
    }
}
