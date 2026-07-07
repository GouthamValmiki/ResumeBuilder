import UIKit

final class ProjectEditViewController: UITableViewController {
    private enum Field: Int, CaseIterable {
        case name, role, link, startDate, endDate, description

        var title: String {
            switch self {
            case .name: return "Project Name"
            case .role: return "Your Role"
            case .link: return "Link / URL"
            case .startDate: return "Start Date"
            case .endDate: return "End Date"
            case .description: return "Description"
            }
        }

        var placeholder: String {
            switch self {
            case .name: return "Resume Builder App"
            case .role: return "Lead Developer"
            case .link: return "github.com/username/project"
            case .startDate: return "Jan 2024"
            case .endDate: return "Present"
            case .description: return "What you built and key achievements..."
            }
        }

        var keyboardType: UIKeyboardType {
            self == .link ? .URL : .default
        }
    }

    private var project: Project
    private let onUpdate: (Project) -> Void

    init(project: Project, onUpdate: @escaping (Project) -> Void) {
        self.project = project
        self.onUpdate = onUpdate
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Project"
        tableView.register(FormTextFieldCell.self, forCellReuseIdentifier: FormTextFieldCell.reuseIdentifier)
        tableView.register(FormTextViewCell.self, forCellReuseIdentifier: FormTextViewCell.reuseIdentifier)
        setupSaveButton()
    }

    private func setupSaveButton() {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 90))
        let button = UIButton(type: .system)
        button.setTitle("Save Project", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.05, green: 0.58, blue: 0.53, alpha: 1) // Modern teal color
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
        onUpdate(project)
        navigationController?.popViewController(animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Field.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let field = Field(rawValue: indexPath.row) else { return UITableViewCell() }

        if field == .description {
            let cell = tableView.dequeueReusableCell(withIdentifier: FormTextViewCell.reuseIdentifier, for: indexPath) as! FormTextViewCell
            cell.configure(title: field.title, text: project.description)
            cell.onTextChanged = { [weak self] text in self?.project.description = text }
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: FormTextFieldCell.reuseIdentifier, for: indexPath) as! FormTextFieldCell
        cell.configure(title: field.title, placeholder: field.placeholder, text: value(for: field), keyboardType: field.keyboardType)
        cell.onTextChanged = { [weak self] text in self?.setValue(text, for: field) }
        return cell
    }

    private func value(for field: Field) -> String {
        switch field {
        case .name: return project.name
        case .role: return project.role
        case .link: return project.link
        case .startDate: return project.startDate
        case .endDate: return project.endDate
        case .description: return project.description
        }
    }

    private func setValue(_ value: String, for field: Field) {
        switch field {
        case .name: project.name = value
        case .role: project.role = value
        case .link: project.link = value
        case .startDate: project.startDate = value
        case .endDate: project.endDate = value
        case .description: project.description = value
        }
    }
}
