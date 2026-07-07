import UIKit

final class SkillEditViewController: UITableViewController {
    private var skill: Skill
    private let onUpdate: (Skill) -> Void
    private let categories = ["Languages", "Frameworks", "Tools", "Methodologies", "General"]

    init(skill: Skill, onUpdate: @escaping (Skill) -> Void) {
        self.skill = skill
        self.onUpdate = onUpdate
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Skill"
        tableView.register(FormTextFieldCell.self, forCellReuseIdentifier: FormTextFieldCell.reuseIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        setupSaveButton()
    }

    private func setupSaveButton() {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 90))
        let button = UIButton(type: .system)
        button.setTitle("Save Skill", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.49, green: 0.18, blue: 0.9, alpha: 1) // Purple/violet color
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        
        footer.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: footer.topAnchor, constant: 20),
            button.leadingAnchor.constraint(equalTo: footer.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 50),
            button.bottomAnchor.constraint(equalTo: footer.bottomAnchor, constant: -20)
        ])
        
        button.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        tableView.tableFooterView = footer
    }

    @objc private func saveTapped() {
        view.endEditing(true)
        onUpdate(skill)
        navigationController?.popViewController(animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Skill Details" : "Category"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: FormTextFieldCell.reuseIdentifier, for: indexPath) as! FormTextFieldCell
            cell.configure(title: "Skill Name", placeholder: "e.g. Swift", text: skill.name)
            cell.onTextChanged = { [weak self] text in self?.skill.name = text }
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categories[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = category
        cell.contentConfiguration = config
        cell.accessoryType = skill.category == category ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section == 1 else { return }
        skill.category = categories[indexPath.row]
        tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
    }
}
