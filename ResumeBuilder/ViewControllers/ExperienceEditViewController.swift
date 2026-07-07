import UIKit

final class ExperienceEditViewController: UITableViewController {
    private enum Field: Int, CaseIterable {
        case jobTitle, company, location, startDate, endDate, description

        var title: String {
            switch self {
            case .jobTitle: return "Job Title"
            case .company: return "Company"
            case .location: return "Location"
            case .startDate: return "Start Date"
            case .endDate: return "End Date"
            case .description: return "Description"
            }
        }

        var placeholder: String {
            switch self {
            case .jobTitle: return "Software Engineer"
            case .company: return "Company Name"
            case .location: return "City, State"
            case .startDate: return "Jan 2020"
            case .endDate: return "Present"
            case .description: return "Key responsibilities and achievements..."
            }
        }
    }

    private var experience: WorkExperience
    private let onUpdate: (WorkExperience) -> Void

    init(experience: WorkExperience, onUpdate: @escaping (WorkExperience) -> Void) {
        self.experience = experience
        self.onUpdate = onUpdate
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Experience"
        tableView.register(FormTextFieldCell.self, forCellReuseIdentifier: FormTextFieldCell.reuseIdentifier)
        tableView.register(FormTextViewCell.self, forCellReuseIdentifier: FormTextViewCell.reuseIdentifier)
        setupSaveButton()
    }

    private func setupSaveButton() {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 90))
        let button = UIButton(type: .system)
        button.setTitle("Save Experience", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.15, green: 0.45, blue: 0.85, alpha: 1) // Classic blue color
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
        onUpdate(experience)
        navigationController?.popViewController(animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Field.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let field = Field(rawValue: indexPath.row) else {
            return UITableViewCell()
        }

        if field == .description {
            let cell = tableView.dequeueReusableCell(withIdentifier: FormTextViewCell.reuseIdentifier, for: indexPath) as! FormTextViewCell
            cell.configure(title: field.title, text: experience.description)
            cell.onTextChanged = { [weak self] text in
                self?.experience.description = text
            }
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: FormTextFieldCell.reuseIdentifier, for: indexPath) as! FormTextFieldCell
        cell.configure(title: field.title, placeholder: field.placeholder, text: value(for: field))
        cell.onTextChanged = { [weak self] text in
            self?.setValue(text, for: field)
        }
        return cell
    }

    private func value(for field: Field) -> String {
        switch field {
        case .jobTitle: return experience.jobTitle
        case .company: return experience.company
        case .location: return experience.location
        case .startDate: return experience.startDate
        case .endDate: return experience.endDate
        case .description: return experience.description
        }
    }

    private func setValue(_ value: String, for field: Field) {
        switch field {
        case .jobTitle: experience.jobTitle = value
        case .company: experience.company = value
        case .location: experience.location = value
        case .startDate: experience.startDate = value
        case .endDate: experience.endDate = value
        case .description: experience.description = value
        }
    }
}
