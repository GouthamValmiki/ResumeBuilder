import UIKit

final class PersonalInfoViewController: UITableViewController {
    private enum Field: Int, CaseIterable {
        case fullName, email, phone, address, linkedIn, website, summary

        var title: String {
            switch self {
            case .fullName: return "Full Name"
            case .email: return "Email"
            case .phone: return "Phone"
            case .address: return "Address"
            case .linkedIn: return "LinkedIn"
            case .website: return "Website"
            case .summary: return "Professional Summary"
            }
        }

        var placeholder: String {
            switch self {
            case .fullName: return "John Doe"
            case .email: return "john@email.com"
            case .phone: return "+1 (555) 000-0000"
            case .address: return "City, State"
            case .linkedIn: return "linkedin.com/in/username"
            case .website: return "yourwebsite.com"
            case .summary: return "Brief professional summary..."
            }
        }

        var keyboardType: UIKeyboardType {
            switch self {
            case .email: return .emailAddress
            case .phone: return .phonePad
            case .website, .linkedIn: return .URL
            default: return .default
            }
        }
    }

    private var personalInfo: PersonalInfo
    private let onUpdate: (PersonalInfo) -> Void

    init(personalInfo: PersonalInfo, onUpdate: @escaping (PersonalInfo) -> Void) {
        self.personalInfo = personalInfo
        self.onUpdate = onUpdate
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Personal Info"
        tableView.register(FormTextFieldCell.self, forCellReuseIdentifier: FormTextFieldCell.reuseIdentifier)
        tableView.register(FormTextViewCell.self, forCellReuseIdentifier: FormTextViewCell.reuseIdentifier)
        setupSaveButton()
    }

    private func setupSaveButton() {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 90))
        let button = UIButton(type: .system)
        button.setTitle("Save Info", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.15, green: 0.20, blue: 0.45, alpha: 1)
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
        onUpdate(personalInfo)
        navigationController?.popViewController(animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Field.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let field = Field(rawValue: indexPath.row) else {
            return UITableViewCell()
        }

        if field == .summary {
            let cell = tableView.dequeueReusableCell(withIdentifier: FormTextViewCell.reuseIdentifier, for: indexPath) as! FormTextViewCell
            cell.configure(title: field.title, text: personalInfo.summary)
            cell.onTextChanged = { [weak self] text in
                self?.personalInfo.summary = text
            }
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: FormTextFieldCell.reuseIdentifier, for: indexPath) as! FormTextFieldCell
        cell.configure(
            title: field.title,
            placeholder: field.placeholder,
            text: value(for: field),
            keyboardType: field.keyboardType
        )
        cell.onTextChanged = { [weak self] text in
            self?.setValue(text, for: field)
        }
        return cell
    }

    private func value(for field: Field) -> String {
        switch field {
        case .fullName: return personalInfo.fullName
        case .email: return personalInfo.email
        case .phone: return personalInfo.phone
        case .address: return personalInfo.address
        case .linkedIn: return personalInfo.linkedIn
        case .website: return personalInfo.website
        case .summary: return personalInfo.summary
        }
    }

    private func setValue(_ value: String, for field: Field) {
        switch field {
        case .fullName: personalInfo.fullName = value
        case .email: personalInfo.email = value
        case .phone: personalInfo.phone = value
        case .address: personalInfo.address = value
        case .linkedIn: personalInfo.linkedIn = value
        case .website: personalInfo.website = value
        case .summary: personalInfo.summary = value
        }
    }
}
