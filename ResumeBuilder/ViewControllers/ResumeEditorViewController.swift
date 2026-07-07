import UIKit

final class ResumeEditorViewController: UITableViewController {
    private enum EditorSection: Int, CaseIterable {
        case template
        case personalInfo
        case content
        case sectionOrder
        case actions

        var title: String? {
            switch self {
            case .template: return "Template"
            case .personalInfo: return "Personal Information"
            case .content: return "Resume Sections"
            case .sectionOrder: return "Layout"
            case .actions: return "Actions"
            }
        }
    }

    private var resume: Resume
    private let storage = ResumeStorage.shared
    private var isCheckingATS = false

    init(resume: Resume) {
        self.resume = resume
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = resume.title
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadFromStorage()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            persistResume()
        }
    }

    private func reloadFromStorage() {
        if let fresh = storage.load(id: resume.id) {
            resume = fresh
            title = resume.title
            tableView.reloadData()
        }
    }

    private func persistResume() {
        resume = storage.save(resume)
        title = resume.title
    }

    private func updateResume(_ block: (inout Resume) -> Void) {
        block(&resume)
        persistResume()
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        EditorSection.allCases.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        EditorSection(rawValue: section)?.title
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let editorSection = EditorSection(rawValue: section) else { return 0 }
        switch editorSection {
        case .template, .personalInfo, .sectionOrder:
            return 1
        case .content:
            return resume.sectionOrder.count
        case .actions:
            return 3
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        cell.accessoryType = .disclosureIndicator
        cell.imageView?.image = nil
        print(Thread.isMainThread)

        guard let editorSection = EditorSection(rawValue: indexPath.section) else { return cell }

        switch editorSection {
        case .template:
            config.text = "Resume Template"
            config.secondaryText = resume.template.displayName
            config.image = UIImage(systemName: resume.template.iconName)
            config.imageProperties.tintColor = resume.template.accentColor

        case .personalInfo:
            config.text = "Edit Personal Info"
            config.secondaryText = resume.personalInfo.fullName.isEmpty ? "Required" : "Done"
            config.image = UIImage(systemName: "person.crop.circle")

        case .content:
            let sectionType = resume.sectionOrder[indexPath.row]
            config.text = sectionType.editorTitle
            config.secondaryText = "\(resume.entryCount(for: sectionType)) entries"
            config.image = UIImage(systemName: sectionType.iconName)
            config.imageProperties.tintColor = .systemBlue

        case .sectionOrder:
            config.text = "Reorder Sections"
            config.secondaryText = resume.sectionOrder.map(\.title).joined(separator: " → ")
            config.image = UIImage(systemName: "arrow.up.arrow.down")

        case .actions:
            if indexPath.row == 0 {
                config.text = "Check ATS Score"
                config.secondaryText = "Find missing basics, keywords, and recruiter signals"
                config.image = UIImage(systemName: "checklist.checked")
                config.imageProperties.tintColor = .systemGreen
            } else if indexPath.row == 1 {
                config.text = "Preview Resume"
                config.image = UIImage(systemName: "doc.text.magnifyingglass")
            } else {
                config.text = "Export as PDF"
                config.image = UIImage(systemName: "square.and.arrow.up")
                cell.accessoryType = .none
            }
        }

        cell.contentConfiguration = config
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let editorSection = EditorSection(rawValue: indexPath.section) else { return }

        switch editorSection {
        case .template:
            showTemplatePicker()

        case .personalInfo:
            let vc = PersonalInfoViewController(personalInfo: resume.personalInfo) { [weak self] updated in
                self?.updateResume { $0.personalInfo = updated }
            }
            navigationController?.pushViewController(vc, animated: true)

        case .content:
            openContentSection(resume.sectionOrder[indexPath.row])

        case .sectionOrder:
            let vc = SectionOrderViewController(sectionOrder: resume.sectionOrder) { [weak self] updated in
                self?.updateResume { $0.sectionOrder = updated }
            }
            navigationController?.pushViewController(vc, animated: true)

        case .actions:
            if indexPath.row == 0 {
                runATSCheck()
            } else if indexPath.row == 1 {
                let vc = PreviewViewController(resume: resume)
                navigationController?.pushViewController(vc, animated: true)
            } else {
                exportPDF()
            }
        }
    }

    private func runATSCheck() {
        guard !isCheckingATS else { return }
        isCheckingATS = true

        let resumeSnapshot = resume
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let report = ATSCheckerService.analyze(resumeSnapshot)

            DispatchQueue.main.async {
                guard let self else { return }
                self.isCheckingATS = false
                self.navigationItem.rightBarButtonItem = nil

                let checker = ATSCheckerViewController(report: report)
                self.navigationController?.pushViewController(checker, animated: true)
            }
        }
    }

    private func showTemplatePicker() {
        let alert = UIAlertController(title: "Choose Template", message: nil, preferredStyle: .actionSheet)
        for template in ResumeTemplate.allCases {
            let title = template == resume.template ? "✓ \(template.displayName)" : template.displayName
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.updateResume { $0.template = template }
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = tableView
            popover.sourceRect = tableView.rectForRow(at: IndexPath(row: 0, section: EditorSection.template.rawValue))
        }
        present(alert, animated: true)
    }

    private func openContentSection(_ sectionType: ResumeSectionType) {
        switch sectionType {
        case .experience:
            let vc = ExperienceListViewController(experiences: resume.experiences) { [weak self] updated in
                self?.updateResume { $0.experiences = updated }
            }
            navigationController?.pushViewController(vc, animated: true)

        case .projects:
            let vc = ProjectListViewController(projects: resume.projects) { [weak self] updated in
                self?.updateResume { $0.projects = updated }
            }
            navigationController?.pushViewController(vc, animated: true)

        case .education:
            let vc = EducationListViewController(educations: resume.educations) { [weak self] updated in
                self?.updateResume { $0.educations = updated }
            }
            navigationController?.pushViewController(vc, animated: true)

        case .skills:
            let vc = SkillsViewController(skills: resume.skills) { [weak self] updated in
                self?.updateResume { $0.skills = updated }
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    private func exportPDF() {
        guard let data = PDFGenerator.generatePDF(for: resume) else {
            showAlert(title: "Error", message: "Could not generate PDF.")
            return
        }

        let fileName = "\(resume.title.replacingOccurrences(of: " ", with: "_")).pdf"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: tempURL)
            let activity = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            if let popover = activity.popoverPresentationController {
                popover.sourceView = view
                popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            }
            present(activity, animated: true)
        } catch {
            showAlert(title: "Error", message: "Could not save PDF file.")
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
