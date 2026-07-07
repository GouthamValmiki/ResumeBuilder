import UIKit

final class ProjectListViewController: UITableViewController {
    private var projects: [Project]
    private let onUpdate: ([Project]) -> Void

    init(projects: [Project], onUpdate: @escaping ([Project]) -> Void) {
        self.projects = projects
        self.onUpdate = onUpdate
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Projects"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addProject))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        projects.sort(by: { $0.sortDateValue < $1.sortDateValue })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            onUpdate(projects)
        }
    }

    private func sortProjectsAndReload() {
        projects.sort(by: { $0.sortDateValue < $1.sortDateValue })
        tableView.reloadData()
    }

    @objc private func addProject() {
        let newProject = Project()
        let vc = ProjectEditViewController(project: newProject) { [weak self] updated in
            self?.projects.append(updated)
            self?.sortProjectsAndReload()
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func openEditor(at index: Int) {
        let vc = ProjectEditViewController(project: projects[index]) { [weak self] updated in
            self?.projects[index] = updated
            self?.sortProjectsAndReload()
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        projects.isEmpty ? 1 : projects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if projects.isEmpty {
            var config = cell.defaultContentConfiguration()
            config.text = "No projects added yet"
            config.secondaryText = "Tap + to add your first project"
            config.secondaryTextProperties.color = .secondaryLabel
            cell.contentConfiguration = config
            cell.accessoryType = .none
            cell.selectionStyle = .none
            return cell
        }

        let project = projects[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = project.name.isEmpty ? "Untitled Project" : project.name
        config.secondaryText = project.role.isEmpty ? project.dateRange : "\(project.role) • \(project.dateRange)"
        config.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard !projects.isEmpty else { return }
        openEditor(at: indexPath.row)
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !projects.isEmpty else { return nil }
        return ListItemActions.swipeConfiguration(
            editHandler: { [weak self] in self?.openEditor(at: indexPath.row) },
            deleteHandler: { [weak self] in
                self?.projects.remove(at: indexPath.row)
                self?.tableView.reloadData()
            }
        )
    }
}
