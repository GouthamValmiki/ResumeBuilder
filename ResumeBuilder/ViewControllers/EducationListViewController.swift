import UIKit

final class EducationListViewController: UITableViewController {
    private var educations: [Education]
    private let onUpdate: ([Education]) -> Void

    init(educations: [Education], onUpdate: @escaping ([Education]) -> Void) {
        self.educations = educations
        self.onUpdate = onUpdate
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Education"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addEducation))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            onUpdate(educations)
        }
    }

    @objc private func addEducation() {
        let newEducation = Education()
        let vc = EducationEditViewController(education: newEducation) { [weak self] updated in
            self?.educations.append(updated)
            self?.tableView.reloadData()
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func openEditor(at index: Int) {
        let vc = EducationEditViewController(education: educations[index]) { [weak self] updated in
            self?.educations[index] = updated
            self?.tableView.reloadData()
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        educations.isEmpty ? 1 : educations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if educations.isEmpty {
            var config = cell.defaultContentConfiguration()
            config.text = "No education added yet"
            config.secondaryText = "Tap + to add your first degree"
            config.secondaryTextProperties.color = .secondaryLabel
            cell.contentConfiguration = config
            cell.accessoryType = .none
            cell.selectionStyle = .none
            return cell
        }

        let education = educations[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = education.degree.isEmpty ? "Untitled Degree" : education.degree
        config.secondaryText = education.institution.isEmpty ? education.dateRange : "\(education.institution) • \(education.dateRange)"
        config.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard !educations.isEmpty else { return }
        openEditor(at: indexPath.row)
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !educations.isEmpty else { return nil }
        return ListItemActions.swipeConfiguration(
            editHandler: { [weak self] in self?.openEditor(at: indexPath.row) },
            deleteHandler: { [weak self] in
                self?.educations.remove(at: indexPath.row)
                self?.tableView.reloadData()
            }
        )
    }
}
