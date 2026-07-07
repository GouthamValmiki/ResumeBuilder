import UIKit

final class EducationEditViewController: UITableViewController {
    private enum Field: Int, CaseIterable {
        case degree, institution, location, startDate, endDate, details

        var title: String {
            switch self {
            case .degree: return "Degree"
            case .institution: return "Institution"
            case .location: return "Location"
            case .startDate: return "Start Date"
            case .endDate: return "End Date"
            case .details: return "Details"
            }
        }

        var placeholder: String {
            switch self {
            case .degree: return "B.S. Computer Science"
            case .institution: return "University Name"
            case .location: return "City, State"
            case .startDate: return "2018"
            case .endDate: return "2022"
            case .details: return "GPA, honors, coursework..."
            }
        }
    }

    private var education: Education
    private let onUpdate: (Education) -> Void

    init(education: Education, onUpdate: @escaping (Education) -> Void) {
        self.education = education
        self.onUpdate = onUpdate
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Education"
        tableView.register(FormTextFieldCell.self, forCellReuseIdentifier: FormTextFieldCell.reuseIdentifier)
        tableView.register(FormTextViewCell.self, forCellReuseIdentifier: FormTextViewCell.reuseIdentifier)
        setupSaveButton()
    }

    private func setupSaveButton() {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 90))
        let button = UIButton(type: .system)
        button.setTitle("Save Education", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.82, green: 0.45, blue: 0.15, alpha: 1) // Warm bronze/orange color
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
        onUpdate(education)
        navigationController?.popViewController(animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Field.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let field = Field(rawValue: indexPath.row) else {
            return UITableViewCell()
        }

        if field == .details {
            let cell = tableView.dequeueReusableCell(withIdentifier: FormTextViewCell.reuseIdentifier, for: indexPath) as! FormTextViewCell
            cell.configure(title: field.title, text: education.details)
            cell.onTextChanged = { [weak self] text in
                self?.education.details = text
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
        case .degree: return education.degree
        case .institution: return education.institution
        case .location: return education.location
        case .startDate: return education.startDate
        case .endDate: return education.endDate
        case .details: return education.details
        }
    }

    private func setValue(_ value: String, for field: Field) {
        switch field {
        case .degree: education.degree = value
        case .institution: education.institution = value
        case .location: education.location = value
        case .startDate: education.startDate = value
        case .endDate: education.endDate = value
        case .details: education.details = value
        }
    }
}
