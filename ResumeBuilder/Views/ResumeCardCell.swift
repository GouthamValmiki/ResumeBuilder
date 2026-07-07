import UIKit

final class ResumeCardCell: UITableViewCell {
    static let reuseIdentifier = "ResumeCardCell"

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.separator.withAlphaComponent(0.4).cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.03
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Template badge pill (e.g. "✓ Modern")
    private let templatePill: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let templateDot: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let templateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Horizontal stack for detail badges (Exp, Edu, Projects, Skills)
    private let badgesStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // Date stack with clock icon
    private let dateStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let clockIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "clock"))
        iv.tintColor = .tertiaryLabel
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.widthAnchor.constraint(equalToConstant: 12).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 12).isActive = true
        return iv
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        label.textColor = .tertiaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let editButton: UIButton = {
        var config = UIButton.Configuration.gray()
        config.image = UIImage(systemName: "pencil")
        config.cornerStyle = .capsule
        config.baseForegroundColor = .secondaryLabel
        config.buttonSize = .mini
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let deleteButton: UIButton = {
        var config = UIButton.Configuration.gray()
        config.image = UIImage(systemName: "trash")
        config.cornerStyle = .capsule
        config.baseForegroundColor = .systemRed
        config.buttonSize = .mini
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        templatePill.addSubview(templateDot)
        templatePill.addSubview(templateLabel)

        cardView.addSubview(titleLabel)
        cardView.addSubview(templatePill)
        cardView.addSubview(nameLabel)
        cardView.addSubview(badgesStackView)

        dateStackView.addArrangedSubview(clockIcon)
        dateStackView.addArrangedSubview(dateLabel)
        cardView.addSubview(dateStackView)

        cardView.addSubview(editButton)
        cardView.addSubview(deleteButton)
        contentView.addSubview(cardView)

        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            // Title
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: templatePill.leadingAnchor, constant: -8),

            // Template Pill
            templatePill.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            templatePill.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            templatePill.heightAnchor.constraint(equalToConstant: 20),

            templateDot.leadingAnchor.constraint(equalTo: templatePill.leadingAnchor, constant: 6),
            templateDot.centerYAnchor.constraint(equalTo: templatePill.centerYAnchor),
            templateDot.widthAnchor.constraint(equalToConstant: 6),
            templateDot.heightAnchor.constraint(equalToConstant: 6),

            templateLabel.leadingAnchor.constraint(equalTo: templateDot.trailingAnchor, constant: 4),
            templateLabel.trailingAnchor.constraint(equalTo: templatePill.trailingAnchor, constant: -6),
            templateLabel.centerYAnchor.constraint(equalTo: templatePill.centerYAnchor),

            // Name
            nameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: editButton.leadingAnchor, constant: -8),

            // Badges
            badgesStackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            badgesStackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            badgesStackView.heightAnchor.constraint(equalToConstant: 18),

            // Date stack (below badges)
            dateStackView.topAnchor.constraint(equalTo: badgesStackView.bottomAnchor, constant: 10),
            dateStackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14),

            // Buttons
            editButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            editButton.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -8),
            editButton.widthAnchor.constraint(equalToConstant: 30),
            editButton.heightAnchor.constraint(equalToConstant: 30),

            deleteButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            deleteButton.widthAnchor.constraint(equalToConstant: 30),
            deleteButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with resume: Resume) {
        titleLabel.text = resume.title
        nameLabel.text = resume.personalInfo.fullName.isEmpty ? "No name added" : resume.personalInfo.fullName

        // Setup Template Pill
        let template = resume.template
        templateDot.backgroundColor = template.accentColor
        templateLabel.text = template.displayName.uppercased()
        templateLabel.textColor = template.accentColor
        templatePill.backgroundColor = template.accentColor.withAlphaComponent(0.08)

        // Setup Relative Date
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        dateLabel.text = "Updated \(formatter.localizedString(for: resume.updatedAt, relativeTo: Date()))"

        // Setup detail summary badges
        setupBadges(for: resume)
    }

    private func setupBadges(for resume: Resume) {
        // Clear old badges
        badgesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Experience badge
        if !resume.experiences.isEmpty {
            let badge = makeBadge(
                iconName: "briefcase.fill",
                text: "\(resume.experiences.count) Exp",
                color: UIColor(red: 0.15, green: 0.45, blue: 0.85, alpha: 1)
            )
            badgesStackView.addArrangedSubview(badge)
        }

        // Projects badge
        if !resume.projects.isEmpty {
            let badge = makeBadge(
                iconName: "folder.fill",
                text: "\(resume.projects.count) Proj",
                color: UIColor(red: 0.05, green: 0.58, blue: 0.53, alpha: 1)
            )
            badgesStackView.addArrangedSubview(badge)
        }

        // Education badge
        if !resume.educations.isEmpty {
            let badge = makeBadge(
                iconName: "graduationcap.fill",
                text: "\(resume.educations.count) Edu",
                color: UIColor(red: 0.82, green: 0.45, blue: 0.15, alpha: 1)
            )
            badgesStackView.addArrangedSubview(badge)
        }

        // Skills badge
        if !resume.skills.isEmpty {
            let badge = makeBadge(
                iconName: "checklist",
                text: "\(resume.skills.count) Skills",
                color: UIColor(red: 0.49, green: 0.18, blue: 0.9, alpha: 1)
            )
            badgesStackView.addArrangedSubview(badge)
        }

        // If no details at all, add a placeholder/helper badge
        if badgesStackView.arrangedSubviews.isEmpty {
            let placeholderBadge = makeBadge(
                iconName: "sparkles",
                text: "Empty Resume",
                color: .systemGray
            )
            badgesStackView.addArrangedSubview(placeholderBadge)
        }
    }

    private func makeBadge(iconName: String, text: String, color: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = color.withAlphaComponent(0.06)
        container.layer.cornerRadius = 5
        container.layer.borderWidth = 0.5
        container.layer.borderColor = color.withAlphaComponent(0.2).cgColor
        container.translatesAutoresizingMaskIntoConstraints = false

        let iv = UIImageView(image: UIImage(systemName: iconName))
        iv.tintColor = color
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false

        let lbl = UILabel()
        lbl.text = text
        lbl.font = .systemFont(ofSize: 9, weight: .bold)
        lbl.textColor = color
        lbl.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(iv)
        container.addSubview(lbl)

        NSLayoutConstraint.activate([
            iv.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 5),
            iv.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iv.widthAnchor.constraint(equalToConstant: 10),
            iv.heightAnchor.constraint(equalToConstant: 10),

            lbl.leadingAnchor.constraint(equalTo: iv.trailingAnchor, constant: 3),
            lbl.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -5),
            lbl.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            container.heightAnchor.constraint(equalToConstant: 16)
        ])

        return container
    }

    @objc private func editTapped() { onEdit?() }
    @objc private func deleteTapped() { onDelete?() }
}
