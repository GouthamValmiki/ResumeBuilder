import UIKit

final class SkillsViewController: UITableViewController {
    private var skills: [Skill]
    private let onUpdate: ([Skill]) -> Void

    init(skills: [Skill], onUpdate: @escaping ([Skill]) -> Void) {
        self.skills = skills
        self.onUpdate = onUpdate
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Skills"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addSkill))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            onUpdate(skills)
        }
    }

    @objc private func addSkill() {
        let newSkill = Skill()
        let vc = SkillEditViewController(skill: newSkill) { [weak self] updated in
            self?.skills.append(updated)
            self?.tableView.reloadData()
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func openEditor(at index: Int) {
        let vc = SkillEditViewController(skill: skills[index]) { [weak self] updated in
            self?.skills[index] = updated
            self?.tableView.reloadData()
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        skills.isEmpty ? 1 : skills.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if skills.isEmpty {
            var config = cell.defaultContentConfiguration()
            config.text = "No skills added yet"
            config.secondaryText = "Tap + to add skills"
            config.secondaryTextProperties.color = .secondaryLabel
            cell.contentConfiguration = config
            cell.accessoryType = .none
            cell.selectionStyle = .none
            return cell
        }

        let skill = skills[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = skill.name.isEmpty ? "Untitled Skill" : skill.name
        config.secondaryText = skill.category
        config.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard !skills.isEmpty else { return }
        openEditor(at: indexPath.row)
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !skills.isEmpty else { return nil }
        return ListItemActions.swipeConfiguration(
            editHandler: { [weak self] in self?.openEditor(at: indexPath.row) },
            deleteHandler: { [weak self] in
                self?.skills.remove(at: indexPath.row)
                self?.tableView.reloadData()
            }
        )
    }
}
