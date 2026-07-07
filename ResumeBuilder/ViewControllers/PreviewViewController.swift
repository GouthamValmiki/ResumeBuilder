import UIKit

final class PreviewViewController: UIViewController {
    private let resume: Resume
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    init(resume: Resume) {
        self.resume = resume
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Preview"
        view.backgroundColor = .systemGroupedBackground
        setupScrollView()
        buildPreview()
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func buildPreview() {
        let template = resume.template
        
        let card = UIView()
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.08
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 12
        card.clipsToBounds = true
        card.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)

        // Header view container (could be solid color, gradient, or clear)
        let headerView: UIView
        if let gradientColors = template.headerGradientColors {
            headerView = GradientView(colors: gradientColors)
        } else {
            headerView = UIView()
            headerView.backgroundColor = template.headerBackgroundColor ?? .clear
        }
        headerView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(headerView)

        // Header content stack (for name, email, phone, links)
        let headerStack = UIStackView()
        headerStack.axis = .vertical
        headerStack.spacing = 8
        headerStack.alignment = template == .executive ? .center : .leading
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(headerStack)

        // Main content stack below header
        let bodyStack = UIStackView()
        bodyStack.axis = .vertical
        bodyStack.spacing = 20
        bodyStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(bodyStack)

        // Layout constraints
        var constraints = [
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

            headerView.topAnchor.constraint(equalTo: card.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: card.trailingAnchor),

            headerStack.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 24),
            headerStack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            headerStack.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            headerStack.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -24),

            bodyStack.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            bodyStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            bodyStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            bodyStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24)
        ]
        NSLayoutConstraint.activate(constraints)

        let info = resume.personalInfo
        let hasHeaderBg = template.headerBackgroundColor != nil || template.headerGradientColors != nil
        let headerColor: UIColor = hasHeaderBg ? template.headerTextColor : .label

        // Name
        if !info.fullName.isEmpty {
            let nameLabel = makeLabel(info.fullName, font: titleFont(size: 26), color: headerColor)
            if template == .executive {
                nameLabel.textAlignment = .center
            }
            headerStack.addArrangedSubview(nameLabel)
        }

        // Contact details
        var contact: [String] = []
        if !info.email.isEmpty { contact.append(info.email) }
        if !info.phone.isEmpty { contact.append(info.phone) }
        if !info.address.isEmpty { contact.append(info.address) }
        if !contact.isEmpty {
            let color: UIColor = hasHeaderBg ? headerColor.withAlphaComponent(0.85) : .secondaryLabel
            let label = makeLabel(contact.joined(separator: "  •  "), font: .systemFont(ofSize: 13), color: color)
            if template == .executive {
                label.textAlignment = .center
            }
            headerStack.addArrangedSubview(label)
        }

        // Links
        var links: [String] = []
        if !info.linkedIn.isEmpty { links.append(info.linkedIn) }
        if !info.website.isEmpty { links.append(info.website) }
        if !links.isEmpty {
            let color: UIColor = hasHeaderBg ? headerColor : template.accentColor
            let label = makeLabel(links.joined(separator: "  •  "), font: .systemFont(ofSize: 13, weight: .medium), color: color)
            if template == .executive {
                label.textAlignment = .center
            }
            headerStack.addArrangedSubview(label)
        }

        // Bottom border for transparent headers (Classic / Executive / Minimal)
        if !hasHeaderBg {
            let divider = makeDivider(color: template.accentColor.withAlphaComponent(0.3))
            bodyStack.addArrangedSubview(divider)
        }

        // Professional Summary
        if !info.summary.isEmpty {
            bodyStack.addArrangedSubview(makeSectionHeader("Professional Summary", template: template))
            bodyStack.addArrangedSubview(makeLabel(info.summary, font: bodyFont(size: 14)))
        }

        // Add sections in user-defined order
        for section in resume.sectionOrder {
            switch section {
            case .experience:
                addExperiences(to: bodyStack, template: template)
            case .projects:
                addProjects(to: bodyStack, template: template)
            case .education:
                addEducations(to: bodyStack, template: template)
            case .skills:
                addSkills(to: bodyStack, template: template)
            }
        }
    }

    private func titleFont(size: CGFloat) -> UIFont {
        resume.template.usesSerifTitle
            ? (UIFont(name: "Georgia-Bold", size: size) ?? .boldSystemFont(ofSize: size))
            : .boldSystemFont(ofSize: size)
    }

    private func bodyFont(size: CGFloat) -> UIFont {
        resume.template.usesSerifTitle
            ? (UIFont(name: "Georgia", size: size) ?? .systemFont(ofSize: size))
            : .systemFont(ofSize: size)
    }

    private func addExperiences(to stack: UIStackView, template: ResumeTemplate) {
        guard !resume.experiences.isEmpty else { return }
        stack.addArrangedSubview(makeSectionHeader("Work Experience", template: template))
        for exp in resume.experiences {
            stack.addArrangedSubview(makeExperienceView(exp, template: template))
        }
    }

    private func addProjects(to stack: UIStackView, template: ResumeTemplate) {
        guard !resume.projects.isEmpty else { return }
        stack.addArrangedSubview(makeSectionHeader("Projects", template: template))
        for project in resume.projects {
            stack.addArrangedSubview(makeProjectView(project, template: template))
        }
    }

    private func addEducations(to stack: UIStackView, template: ResumeTemplate) {
        guard !resume.educations.isEmpty else { return }
        stack.addArrangedSubview(makeSectionHeader("Education", template: template))
        for edu in resume.educations {
            stack.addArrangedSubview(makeEducationView(edu, template: template))
        }
    }

    private func addSkills(to stack: UIStackView, template: ResumeTemplate) {
        guard !resume.skills.isEmpty else { return }
        stack.addArrangedSubview(makeSectionHeader("Skills", template: template))
        
        let grouped = Dictionary(grouping: resume.skills, by: { $0.category })
        let skillStack = UIStackView()
        skillStack.axis = .vertical
        skillStack.spacing = 8
        
        for (category, items) in grouped.sorted(by: { $0.key < $1.key }) {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 8
            
            let catLabel = makeLabel("\(category):", font: .systemFont(ofSize: 13, weight: .bold), color: template.accentColor)
            let itemsLabel = makeLabel(items.map(\.name).joined(separator: ", "), font: bodyFont(size: 13))
            
            row.addArrangedSubview(catLabel)
            row.addArrangedSubview(itemsLabel)
            catLabel.setContentHuggingPriority(.required, for: .horizontal)
            
            skillStack.addArrangedSubview(row)
        }
        stack.addArrangedSubview(skillStack)
    }

    private func makeLabel(_ text: String, font: UIFont, color: UIColor = .label) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        label.numberOfLines = 0
        return label
    }

    private func makeDivider(color: UIColor) -> UIView {
        let line = UIView()
        line.backgroundColor = color
        line.translatesAutoresizingMaskIntoConstraints = false
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return line
    }

    private func makeSectionHeader(_ title: String, template: ResumeTemplate) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 4
        
        let label = UILabel()
        label.text = title.uppercased()
        label.textColor = template.accentColor
        
        switch template {
        case .classic:
            label.font = titleFont(size: 14)
            container.addArrangedSubview(label)
            container.addArrangedSubview(makeDivider(color: template.accentColor.withAlphaComponent(0.4)))
            
        case .modern:
            label.font = .systemFont(ofSize: 13, weight: .black)
            
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 8
            row.alignment = .center
            
            let accentBar = UIView()
            accentBar.backgroundColor = template.accentColor
            accentBar.translatesAutoresizingMaskIntoConstraints = false
            accentBar.widthAnchor.constraint(equalToConstant: 4).isActive = true
            accentBar.heightAnchor.constraint(equalToConstant: 18).isActive = true
            accentBar.layer.cornerRadius = 2
            
            row.addArrangedSubview(accentBar)
            row.addArrangedSubview(label)
            container.addArrangedSubview(row)
            
        case .minimal:
            label.font = .systemFont(ofSize: 12, weight: .bold)
            container.addArrangedSubview(label)
            container.addArrangedSubview(makeDivider(color: .separator))
            
        case .executive:
            label.font = titleFont(size: 13)
            label.textAlignment = .center
            
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 10
            row.alignment = .center
            
            let leftLine = makeDivider(color: template.accentColor.withAlphaComponent(0.3))
            let rightLine = makeDivider(color: template.accentColor.withAlphaComponent(0.3))
            
            row.addArrangedSubview(leftLine)
            row.addArrangedSubview(label)
            row.addArrangedSubview(rightLine)
            
            container.addArrangedSubview(row)
            
        case .creative:
            label.font = .systemFont(ofSize: 11, weight: .bold)
            label.textColor = template.accentColor
            
            let badge = UIView()
            badge.backgroundColor = template.accentColor.withAlphaComponent(0.12)
            badge.layer.cornerRadius = 6
            badge.translatesAutoresizingMaskIntoConstraints = false
            badge.addSubview(label)
            
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: badge.topAnchor, constant: 5),
                label.bottomAnchor.constraint(equalTo: badge.bottomAnchor, constant: -5),
                label.leadingAnchor.constraint(equalTo: badge.leadingAnchor, constant: 10),
                label.trailingAnchor.constraint(equalTo: badge.trailingAnchor, constant: -10)
            ])
            
            let row = UIStackView()
            row.axis = .horizontal
            row.addArrangedSubview(badge)
            row.addArrangedSubview(UIView())
            container.addArrangedSubview(row)
        }
        
        return container
    }

    private func makeExperienceView(_ exp: WorkExperience, template: ResumeTemplate) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 4
        
        let titleRow = UIStackView()
        titleRow.axis = .horizontal
        titleRow.alignment = .firstBaseline
        
        if !exp.jobTitle.isEmpty {
            titleRow.addArrangedSubview(makeLabel(exp.jobTitle, font: titleFont(size: 15), color: .label))
        }
        if !exp.dateRange.isEmpty {
            titleRow.addArrangedSubview(makeLabel(exp.dateRange, font: .systemFont(ofSize: 12), color: .secondaryLabel))
        }
        container.addArrangedSubview(titleRow)
        
        var subtitle = exp.company
        if !exp.location.isEmpty { subtitle += " — \(exp.location)" }
        if !subtitle.isEmpty {
            container.addArrangedSubview(makeLabel(subtitle, font: .italicSystemFont(ofSize: 13), color: template.accentColor))
        }
        
        if !exp.description.isEmpty {
            let bullets = exp.description.components(separatedBy: .newlines)
                .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            
            if template == .creative || template == .modern {
                let listStack = UIStackView()
                listStack.axis = .vertical
                listStack.spacing = 4
                
                for bullet in bullets {
                    let row = UIStackView()
                    row.axis = .horizontal
                    row.spacing = 8
                    row.alignment = .top
                    
                    let dot = UIView()
                    dot.backgroundColor = template.accentColor
                    dot.translatesAutoresizingMaskIntoConstraints = false
                    dot.widthAnchor.constraint(equalToConstant: 4).isActive = true
                    dot.heightAnchor.constraint(equalToConstant: 4).isActive = true
                    dot.layer.cornerRadius = 2
                    
                    let dotContainer = UIView()
                    dotContainer.addSubview(dot)
                    dotContainer.translatesAutoresizingMaskIntoConstraints = false
                    dotContainer.widthAnchor.constraint(equalToConstant: 6).isActive = true
                    dotContainer.heightAnchor.constraint(equalToConstant: 16).isActive = true
                    dot.centerYAnchor.constraint(equalTo: dotContainer.centerYAnchor).isActive = true
                    dot.centerXAnchor.constraint(equalTo: dotContainer.centerXAnchor).isActive = true
                    
                    let content = makeLabel(bullet.trimmingCharacters(in: .whitespaces), font: bodyFont(size: 13), color: .label)
                    
                    row.addArrangedSubview(dotContainer)
                    row.addArrangedSubview(content)
                    listStack.addArrangedSubview(row)
                }
                container.addArrangedSubview(listStack)
            } else {
                let bulletText = bullets.map { "• \($0.trimmingCharacters(in: .whitespaces))" }.joined(separator: "\n")
                container.addArrangedSubview(makeLabel(bulletText, font: bodyFont(size: 13), color: .label))
            }
        }
        return container
    }

    private func makeProjectView(_ project: Project, template: ResumeTemplate) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 4
        
        let titleRow = UIStackView()
        titleRow.axis = .horizontal
        titleRow.alignment = .firstBaseline
        
        if !project.name.isEmpty {
            titleRow.addArrangedSubview(makeLabel(project.name, font: titleFont(size: 15), color: .label))
        }
        if !project.dateRange.isEmpty {
            titleRow.addArrangedSubview(makeLabel(project.dateRange, font: .systemFont(ofSize: 12), color: .secondaryLabel))
        }
        container.addArrangedSubview(titleRow)
        
        var subtitle = project.role
        if !project.link.isEmpty { subtitle += " — \(project.link)" }
        if !subtitle.isEmpty {
            container.addArrangedSubview(makeLabel(subtitle, font: .italicSystemFont(ofSize: 13), color: template.accentColor))
        }
        
        if !project.description.isEmpty {
            let bullets = project.description.components(separatedBy: .newlines)
                .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            
            if template == .creative || template == .modern {
                let listStack = UIStackView()
                listStack.axis = .vertical
                listStack.spacing = 4
                
                for bullet in bullets {
                    let row = UIStackView()
                    row.axis = .horizontal
                    row.spacing = 8
                    row.alignment = .top
                    
                    let dot = UIView()
                    dot.backgroundColor = template.accentColor
                    dot.translatesAutoresizingMaskIntoConstraints = false
                    dot.widthAnchor.constraint(equalToConstant: 4).isActive = true
                    dot.heightAnchor.constraint(equalToConstant: 4).isActive = true
                    dot.layer.cornerRadius = 2
                    
                    let dotContainer = UIView()
                    dotContainer.addSubview(dot)
                    dotContainer.translatesAutoresizingMaskIntoConstraints = false
                    dotContainer.widthAnchor.constraint(equalToConstant: 6).isActive = true
                    dotContainer.heightAnchor.constraint(equalToConstant: 16).isActive = true
                    dot.centerYAnchor.constraint(equalTo: dotContainer.centerYAnchor).isActive = true
                    dot.centerXAnchor.constraint(equalTo: dotContainer.centerXAnchor).isActive = true
                    
                    let content = makeLabel(bullet.trimmingCharacters(in: .whitespaces), font: bodyFont(size: 13), color: .label)
                    
                    row.addArrangedSubview(dotContainer)
                    row.addArrangedSubview(content)
                    listStack.addArrangedSubview(row)
                }
                container.addArrangedSubview(listStack)
            } else {
                let bulletText = bullets.map { "• \($0.trimmingCharacters(in: .whitespaces))" }.joined(separator: "\n")
                container.addArrangedSubview(makeLabel(bulletText, font: bodyFont(size: 13), color: .label))
            }
        }
        return container
    }

    private func makeEducationView(_ edu: Education, template: ResumeTemplate) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 4
        
        let titleRow = UIStackView()
        titleRow.axis = .horizontal
        titleRow.alignment = .firstBaseline
        
        if !edu.degree.isEmpty {
            titleRow.addArrangedSubview(makeLabel(edu.degree, font: titleFont(size: 15), color: .label))
        }
        if !edu.dateRange.isEmpty {
            titleRow.addArrangedSubview(makeLabel(edu.dateRange, font: .systemFont(ofSize: 12), color: .secondaryLabel))
        }
        container.addArrangedSubview(titleRow)
        
        var subtitle = edu.institution
        if !edu.location.isEmpty { subtitle += " — \(edu.location)" }
        if !subtitle.isEmpty {
            container.addArrangedSubview(makeLabel(subtitle, font: .italicSystemFont(ofSize: 13), color: template.accentColor))
        }
        
        if !edu.details.isEmpty {
            container.addArrangedSubview(makeLabel(edu.details, font: bodyFont(size: 13), color: .label))
        }
        return container
    }
}

// MARK: - Gradient Helper View
final class GradientView: UIView {
    private let gradientLayer = CAGradientLayer()

    init(colors: [UIColor]) {
        super.init(frame: .zero)
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.addSublayer(gradientLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
