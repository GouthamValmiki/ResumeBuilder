import UIKit

final class ExperienceListViewController: UITableViewController {
    private var experiences: [WorkExperience]
    private let onUpdate: ([WorkExperience]) -> Void

    init(experiences: [WorkExperience], onUpdate: @escaping ([WorkExperience]) -> Void) {
        self.experiences = experiences
        self.onUpdate = onUpdate
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Work Experience"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addExperience))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            onUpdate(experiences)
        }
    }

    @objc private func addExperience() {
        let newExperience = WorkExperience()
        let vc = ExperienceEditViewController(experience: newExperience) { [weak self] updated in
            self?.experiences.append(updated)
            self?.tableView.reloadData()
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func openEditor(at index: Int) {
        let vc = ExperienceEditViewController(experience: experiences[index]) { [weak self] updated in
            self?.experiences[index] = updated
            self?.tableView.reloadData()
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        experiences.isEmpty ? 1 : experiences.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if experiences.isEmpty {
            var config = cell.defaultContentConfiguration()
            config.text = "No experience added yet"
            config.secondaryText = "Tap + to add your first job"
            config.secondaryTextProperties.color = .secondaryLabel
            cell.contentConfiguration = config
            cell.accessoryType = .none
            cell.selectionStyle = .none
            return cell
        }

        let experience = experiences[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = experience.jobTitle.isEmpty ? "Untitled Position" : experience.jobTitle
        config.secondaryText = experience.company.isEmpty ? experience.dateRange : "\(experience.company) • \(experience.dateRange)"
        config.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard !experiences.isEmpty else { return }
        openEditor(at: indexPath.row)
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !experiences.isEmpty else { return nil }
        return ListItemActions.swipeConfiguration(
            editHandler: { [weak self] in self?.openEditor(at: indexPath.row) },
            deleteHandler: { [weak self] in
                self?.experiences.remove(at: indexPath.row)
                self?.tableView.reloadData()
            }
        )
    }
}
