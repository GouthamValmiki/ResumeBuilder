import UIKit

final class CareerToolkitViewController: UITableViewController {
    private enum Tool: CaseIterable {
        case jobMatch
        case translator
        case achievements
        case applications
        case interview

        var title: String {
            switch self {
            case .jobMatch: return "Job Match Studio"
            case .translator: return "Experience Translator"
            case .achievements: return "Achievement Vault"
            case .applications: return "Application Tracker"
            case .interview: return "Interview Story Builder"
            }
        }

        var subtitle: String {
            switch self {
            case .jobMatch: return "Compare a resume with a job description"
            case .translator: return "Turn college, project, and work activities into bullets"
            case .achievements: return "Save wins, metrics, feedback, and career evidence"
            case .applications: return "Track roles, status, follow-ups, and notes"
            case .interview: return "Turn achievements into clear STAR answers"
            }
        }

        var iconName: String {
            switch self {
            case .jobMatch: return "scope"
            case .translator: return "text.badge.star"
            case .achievements: return "trophy.fill"
            case .applications: return "tray.full.fill"
            case .interview: return "person.wave.2.fill"
            }
        }

        var tintColor: UIColor {
            switch self {
            case .jobMatch: return .systemTeal
            case .translator: return .systemIndigo
            case .achievements: return .systemOrange
            case .applications: return .systemBlue
            case .interview: return .systemPink
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Career Toolkit"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ToolCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 82
        setupFooter()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Tool.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tool = Tool.allCases[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToolCell", for: indexPath)
        var config = UIListContentConfiguration.subtitleCell()
        config.text = tool.title
        config.textProperties.font = .systemFont(ofSize: 17, weight: .bold)
        config.secondaryText = tool.subtitle
        config.secondaryTextProperties.color = .secondaryLabel
        config.secondaryTextProperties.numberOfLines = 0
        config.image = UIImage(systemName: tool.iconName)
        config.imageProperties.tintColor = tool.tintColor
        config.imageProperties.maximumSize = CGSize(width: 30, height: 30)
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch Tool.allCases[indexPath.row] {
        case .jobMatch:
            chooseResumeForJobMatch()
        case .translator:
            navigationController?.pushViewController(ExperienceTranslatorViewController(), animated: true)
        case .achievements:
            navigationController?.pushViewController(AchievementVaultViewController(), animated: true)
        case .applications:
            navigationController?.pushViewController(ApplicationTrackerViewController(), animated: true)
        case .interview:
            navigationController?.pushViewController(InterviewStoryBuilderViewController(), animated: true)
        }
    }

    private func chooseResumeForJobMatch() {
        let resumes = ResumeStorage.shared.loadAll()
        guard !resumes.isEmpty else {
            showAlert(title: "Create a Resume First", message: "Job Match Studio compares a saved resume with a job description.")
            return
        }

        if resumes.count == 1, let resume = resumes.first {
            openJobMatch(resume)
            return
        }

        let alert = UIAlertController(title: "Choose Resume", message: "Select the resume to compare.", preferredStyle: .actionSheet)
        resumes.forEach { resume in
            alert.addAction(UIAlertAction(title: resume.title, style: .default) { [weak self] _ in
                self?.openJobMatch(resume)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        }
        present(alert, animated: true)
    }

    private func openJobMatch(_ resume: Resume) {
        navigationController?.pushViewController(JobMatchViewController(resume: resume), animated: true)
    }

    private func setupFooter() {
        let label = UILabel()
        label.text = "These tools provide practical guidance. Keep only suggestions that truthfully reflect your experience."
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 78)
        tableView.tableFooterView = label
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

private final class JobMatchViewController: UITableViewController {
    private let resume: Resume
    private var jobDescription = ""
    private var report: JobMatchReport?

    init(resume: Resume) {
        self.resume = resume
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Job Match"
        tableView.register(FormTextViewCell.self, forCellReuseIdentifier: FormTextViewCell.reuseIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ResultCell")
        setupAnalyzeButton()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        report == nil ? 1 : 5
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Job Description for \(resume.title)"
        case 1: return "Match Score"
        case 2: return "Matched Keywords"
        case 3: return "Missing Keywords"
        default: return "Recommended Changes"
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let report else { return 1 }
        switch section {
        case 0, 1: return 1
        case 2: return max(report.matchedKeywords.count, 1)
        case 3: return max(report.missingKeywords.count, 1)
        default: return report.suggestions.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: FormTextViewCell.reuseIdentifier, for: indexPath) as! FormTextViewCell
            cell.configure(title: "Paste the full job post", text: jobDescription)
            cell.onTextChanged = { [weak self] text in self?.jobDescription = text }
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath)
        var config = UIListContentConfiguration.subtitleCell()
        config.textProperties.numberOfLines = 0
        config.secondaryTextProperties.numberOfLines = 0
        cell.selectionStyle = .none

        guard let report else { return cell }
        switch indexPath.section {
        case 1:
            config.text = "\(report.score)% match"
            config.textProperties.font = .systemFont(ofSize: 26, weight: .black)
            config.textProperties.color = scoreColor(report.score)
            config.secondaryText = "Keyword match is a guide. Review responsibilities and role fit too."
            config.image = UIImage(systemName: "scope")
            config.imageProperties.tintColor = scoreColor(report.score)
        case 2:
            config.text = report.matchedKeywords.isEmpty ? "No clear keyword matches yet" : report.matchedKeywords[indexPath.row]
            config.image = UIImage(systemName: "checkmark.circle.fill")
            config.imageProperties.tintColor = .systemGreen
        case 3:
            config.text = report.missingKeywords.isEmpty ? "No major missing keywords" : report.missingKeywords[indexPath.row]
            config.image = UIImage(systemName: "plus.circle.fill")
            config.imageProperties.tintColor = .systemOrange
        default:
            config.text = report.suggestions[indexPath.row]
            config.image = UIImage(systemName: "lightbulb.fill")
            config.imageProperties.tintColor = .systemYellow
        }
        cell.contentConfiguration = config
        return cell
    }

    private func setupAnalyzeButton() {
        tableView.tableFooterView = CareerToolkitUI.buttonFooter(
            title: "Analyze Match",
            color: .systemTeal,
            target: self,
            action: #selector(analyze)
        )
    }

    @objc private func analyze() {
        view.endEditing(true)
        guard jobDescription.trimmingCharacters(in: .whitespacesAndNewlines).count >= 40 else {
            CareerToolkitUI.showAlert(on: self, title: "Add More Job Details", message: "Paste the full job description so the match can identify meaningful keywords.")
            return
        }
        report = CareerToolkitService.match(resume: resume, jobDescription: jobDescription)
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: true)
    }

    private func scoreColor(_ score: Int) -> UIColor {
        if score >= 75 { return .systemGreen }
        if score >= 50 { return .systemOrange }
        return .systemRed
    }
}

private final class ExperienceTranslatorViewController: UITableViewController {
    private var experienceTitle = ""
    private var sourceText = ""
    private var suggestions: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Experience Translator"
        tableView.register(FormTextFieldCell.self, forCellReuseIdentifier: FormTextFieldCell.reuseIdentifier)
        tableView.register(FormTextViewCell.self, forCellReuseIdentifier: FormTextViewCell.reuseIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BulletCell")
        setupButton()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        suggestions.isEmpty ? 1 : 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Your Experience" : "Resume Bullets - Tap to Copy"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 2 : suggestions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: FormTextFieldCell.reuseIdentifier, for: indexPath) as! FormTextFieldCell
            cell.configure(title: "Experience Type", placeholder: "Course project, club role, internship...", text: experienceTitle)
            cell.onTextChanged = { [weak self] text in self?.experienceTitle = text }
            return cell
        }
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: FormTextViewCell.reuseIdentifier, for: indexPath) as! FormTextViewCell
            cell.configure(title: "Describe what you did in normal words", text: sourceText)
            cell.onTextChanged = { [weak self] text in self?.sourceText = text }
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "BulletCell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = suggestions[indexPath.row]
        config.textProperties.numberOfLines = 0
        config.image = UIImage(systemName: "doc.on.doc")
        config.imageProperties.tintColor = .systemIndigo
        cell.contentConfiguration = config
        cell.accessoryType = .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section == 1 else { return }
        UIPasteboard.general.string = suggestions[indexPath.row]
        CareerToolkitUI.showAlert(on: self, title: "Copied", message: "The bullet is ready to paste into a resume. Replace any placeholder outcome with a truthful result.")
    }

    private func setupButton() {
        tableView.tableFooterView = CareerToolkitUI.buttonFooter(
            title: "Create Resume Bullets",
            color: .systemIndigo,
            target: self,
            action: #selector(translate)
        )
    }

    @objc private func translate() {
        view.endEditing(true)
        suggestions = CareerToolkitService.translateExperience(title: experienceTitle, source: sourceText)
        guard !suggestions.isEmpty else {
            CareerToolkitUI.showAlert(on: self, title: "Describe an Experience", message: "Add a few details about what you did, solved, created, or learned.")
            return
        }
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: true)
    }
}

private final class AchievementVaultViewController: UITableViewController {
    private let storage = CareerStorage.shared
    private var achievements: [CareerAchievement] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Achievement Vault"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAchievement))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AchievementCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        max(achievements.count, 1)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AchievementCell", for: indexPath)
        var config = UIListContentConfiguration.subtitleCell()
        if achievements.isEmpty {
            config.text = "Save your first achievement"
            config.secondaryText = "Capture wins, positive feedback, metrics, awards, and completed projects."
            config.image = UIImage(systemName: "trophy")
            config.imageProperties.tintColor = .systemOrange
            cell.accessoryType = .none
            cell.selectionStyle = .none
        } else {
            let achievement = achievements[indexPath.row]
            config.text = achievement.title.isEmpty ? "Untitled Achievement" : achievement.title
            config.secondaryText = [achievement.result, achievement.skills].filter { !$0.isEmpty }.joined(separator: " • ")
            config.secondaryTextProperties.numberOfLines = 2
            config.image = UIImage(systemName: "trophy.fill")
            config.imageProperties.tintColor = .systemOrange
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
        }
        cell.contentConfiguration = config
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard !achievements.isEmpty else { return }
        openEditor(achievements[indexPath.row])
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !achievements.isEmpty else { return nil }
        return ListItemActions.swipeConfiguration(
            editHandler: { [weak self] in
                guard let self else { return }
                self.openEditor(self.achievements[indexPath.row])
            },
            deleteHandler: { [weak self] in
                guard let self else { return }
                self.storage.deleteAchievement(id: self.achievements[indexPath.row].id)
                self.reloadData()
            }
        )
    }

    @objc private func addAchievement() {
        openEditor(CareerAchievement())
    }

    private func openEditor(_ achievement: CareerAchievement) {
        navigationController?.pushViewController(AchievementEditViewController(achievement: achievement), animated: true)
    }

    private func reloadData() {
        achievements = storage.loadAchievements()
        tableView.reloadData()
    }
}

private final class AchievementEditViewController: UITableViewController {
    private enum Field: Int, CaseIterable {
        case title, context, action, result, skills

        var title: String {
            switch self {
            case .title: return "Achievement Title"
            case .context: return "Situation / Context"
            case .action: return "What You Did"
            case .result: return "Result / Impact"
            case .skills: return "Skills Used"
            }
        }
    }

    private var achievement: CareerAchievement

    init(achievement: CareerAchievement) {
        self.achievement = achievement
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Achievement"
        tableView.register(FormTextFieldCell.self, forCellReuseIdentifier: FormTextFieldCell.reuseIdentifier)
        tableView.register(FormTextViewCell.self, forCellReuseIdentifier: FormTextViewCell.reuseIdentifier)
        tableView.tableFooterView = CareerToolkitUI.buttonFooter(title: "Save Achievement", color: .systemOrange, target: self, action: #selector(save))
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Field.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = Field.allCases[indexPath.row]
        if field == .title || field == .skills {
            let cell = tableView.dequeueReusableCell(withIdentifier: FormTextFieldCell.reuseIdentifier, for: indexPath) as! FormTextFieldCell
            cell.configure(title: field.title, placeholder: placeholder(field), text: value(field))
            cell.onTextChanged = { [weak self] text in self?.setValue(text, field) }
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: FormTextViewCell.reuseIdentifier, for: indexPath) as! FormTextViewCell
        cell.configure(title: field.title, text: value(field))
        cell.onTextChanged = { [weak self] text in self?.setValue(text, field) }
        return cell
    }

    @objc private func save() {
        view.endEditing(true)
        guard !achievement.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            CareerToolkitUI.showAlert(on: self, title: "Add a Title", message: "Give this achievement a short name so you can find it later.")
            return
        }
        CareerStorage.shared.saveAchievement(achievement)
        navigationController?.popViewController(animated: true)
    }

    private func value(_ field: Field) -> String {
        switch field {
        case .title: return achievement.title
        case .context: return achievement.context
        case .action: return achievement.action
        case .result: return achievement.result
        case .skills: return achievement.skills
        }
    }

    private func setValue(_ value: String, _ field: Field) {
        switch field {
        case .title: achievement.title = value
        case .context: achievement.context = value
        case .action: achievement.action = value
        case .result: achievement.result = value
        case .skills: achievement.skills = value
        }
    }

    private func placeholder(_ field: Field) -> String {
        field == .title ? "Improved event registrations" : "Communication, Excel, Swift..."
    }
}

private final class ApplicationTrackerViewController: UITableViewController {
    private let storage = CareerStorage.shared
    private var applications: [JobApplication] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Application Tracker"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addApplication))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ApplicationCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        max(applications.count, 1)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ApplicationCell", for: indexPath)
        var config = UIListContentConfiguration.subtitleCell()
        if applications.isEmpty {
            config.text = "Track your first opportunity"
            config.secondaryText = "Save roles and follow-up steps so promising applications do not get lost."
            config.image = UIImage(systemName: "tray.full")
            config.imageProperties.tintColor = .systemBlue
            cell.accessoryType = .none
            cell.selectionStyle = .none
        } else {
            let application = applications[indexPath.row]
            config.text = application.role.isEmpty ? "Untitled Role" : application.role
            config.secondaryText = [application.company, application.status.displayName, application.nextStep].filter { !$0.isEmpty }.joined(separator: " • ")
            config.secondaryTextProperties.numberOfLines = 2
            config.image = UIImage(systemName: application.status.iconName)
            config.imageProperties.tintColor = statusColor(application.status)
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
        }
        cell.contentConfiguration = config
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard !applications.isEmpty else { return }
        openEditor(applications[indexPath.row])
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !applications.isEmpty else { return nil }
        return ListItemActions.swipeConfiguration(
            editHandler: { [weak self] in
                guard let self else { return }
                self.openEditor(self.applications[indexPath.row])
            },
            deleteHandler: { [weak self] in
                guard let self else { return }
                self.storage.deleteApplication(id: self.applications[indexPath.row].id)
                self.reloadData()
            }
        )
    }

    @objc private func addApplication() {
        openEditor(JobApplication())
    }

    private func openEditor(_ application: JobApplication) {
        navigationController?.pushViewController(ApplicationEditViewController(application: application), animated: true)
    }

    private func reloadData() {
        applications = storage.loadApplications()
        tableView.reloadData()
    }

    private func statusColor(_ status: JobApplicationStatus) -> UIColor {
        switch status {
        case .saved: return .systemGray
        case .applied: return .systemBlue
        case .interview: return .systemOrange
        case .offer: return .systemGreen
        case .rejected: return .systemRed
        }
    }
}

private final class ApplicationEditViewController: UITableViewController {
    private enum Section: Int, CaseIterable {
        case details
        case status
        case notes
    }

    private enum DetailField: Int, CaseIterable {
        case role, company, appliedDate, nextStep

        var title: String {
            switch self {
            case .role: return "Role"
            case .company: return "Company"
            case .appliedDate: return "Applied Date"
            case .nextStep: return "Next Step / Follow-up"
            }
        }
    }

    private var application: JobApplication

    init(application: JobApplication) {
        self.application = application
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Application"
        tableView.register(FormTextFieldCell.self, forCellReuseIdentifier: FormTextFieldCell.reuseIdentifier)
        tableView.register(FormTextViewCell.self, forCellReuseIdentifier: FormTextViewCell.reuseIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StatusCell")
        tableView.tableFooterView = CareerToolkitUI.buttonFooter(title: "Save Application", color: .systemBlue, target: self, action: #selector(save))
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section) {
        case .details: return "Opportunity"
        case .status: return "Status"
        case .notes: return "Notes"
        case .none: return nil
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Section(rawValue: section) == .details ? DetailField.allCases.count : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .details:
            let field = DetailField.allCases[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: FormTextFieldCell.reuseIdentifier, for: indexPath) as! FormTextFieldCell
            cell.configure(title: field.title, placeholder: placeholder(field), text: detailValue(field))
            cell.onTextChanged = { [weak self] text in self?.setDetailValue(text, field) }
            return cell
        case .status:
            let cell = tableView.dequeueReusableCell(withIdentifier: "StatusCell", for: indexPath)
            var config = cell.defaultContentConfiguration()
            config.text = application.status.displayName
            config.image = UIImage(systemName: application.status.iconName)
            config.imageProperties.tintColor = .systemBlue
            cell.contentConfiguration = config
            cell.accessoryType = .disclosureIndicator
            return cell
        case .notes:
            let cell = tableView.dequeueReusableCell(withIdentifier: FormTextViewCell.reuseIdentifier, for: indexPath) as! FormTextViewCell
            cell.configure(title: "Contacts, interview details, salary, links...", text: application.notes)
            cell.onTextChanged = { [weak self] text in self?.application.notes = text }
            return cell
        case .none:
            return UITableViewCell()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard Section(rawValue: indexPath.section) == .status else { return }
        chooseStatus()
    }

    @objc private func save() {
        view.endEditing(true)
        guard !application.role.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            CareerToolkitUI.showAlert(on: self, title: "Add the Role", message: "Enter the job title before saving this application.")
            return
        }
        CareerStorage.shared.saveApplication(application)
        navigationController?.popViewController(animated: true)
    }

    private func chooseStatus() {
        let alert = UIAlertController(title: "Application Status", message: nil, preferredStyle: .actionSheet)
        JobApplicationStatus.allCases.forEach { status in
            alert.addAction(UIAlertAction(title: status.displayName, style: .default) { [weak self] _ in
                self?.application.status = status
                self?.tableView.reloadSections(IndexSet(integer: Section.status.rawValue), with: .automatic)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = tableView
            popover.sourceRect = tableView.rectForRow(at: IndexPath(row: 0, section: Section.status.rawValue))
        }
        present(alert, animated: true)
    }

    private func detailValue(_ field: DetailField) -> String {
        switch field {
        case .role: return application.role
        case .company: return application.company
        case .appliedDate: return application.appliedDate
        case .nextStep: return application.nextStep
        }
    }

    private func setDetailValue(_ value: String, _ field: DetailField) {
        switch field {
        case .role: application.role = value
        case .company: application.company = value
        case .appliedDate: application.appliedDate = value
        case .nextStep: application.nextStep = value
        }
    }

    private func placeholder(_ field: DetailField) -> String {
        switch field {
        case .role: return "iOS Developer"
        case .company: return "Company name"
        case .appliedDate: return "Jun 12, 2026"
        case .nextStep: return "Follow up next Friday"
        }
    }
}

private final class InterviewStoryBuilderViewController: UITableViewController {
    private var sourceText = ""
    private var selectedAchievement: CareerAchievement?
    private var story: STARStory?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Interview Story"
        tableView.register(FormTextViewCell.self, forCellReuseIdentifier: FormTextViewCell.reuseIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StoryCell")
        tableView.tableFooterView = CareerToolkitUI.buttonFooter(title: "Build STAR Story", color: .systemPink, target: self, action: #selector(buildStory))
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        story == nil ? 1 : 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Choose a Story Source" : "STAR Answer Draft"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 2 : 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StoryCell", for: indexPath)
            var config = cell.defaultContentConfiguration()
            config.text = selectedAchievement?.title ?? "Choose from Achievement Vault"
            config.secondaryText = selectedAchievement == nil ? "Optional" : "Selected achievement"
            config.image = UIImage(systemName: "trophy")
            config.imageProperties.tintColor = .systemOrange
            cell.contentConfiguration = config
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: FormTextViewCell.reuseIdentifier, for: indexPath) as! FormTextViewCell
            cell.configure(title: "Or describe an achievement / challenge", text: sourceText)
            cell.onTextChanged = { [weak self] text in self?.sourceText = text }
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "StoryCell", for: indexPath)
        let item = storyItem(indexPath.row)
        var config = UIListContentConfiguration.subtitleCell()
        config.text = item.0
        config.textProperties.font = .systemFont(ofSize: 15, weight: .black)
        config.secondaryText = item.1
        config.secondaryTextProperties.numberOfLines = 0
        config.image = UIImage(systemName: item.2)
        config.imageProperties.tintColor = .systemPink
        cell.contentConfiguration = config
        cell.selectionStyle = .none
        cell.accessoryType = .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section == 0 && indexPath.row == 0 else { return }
        chooseAchievement()
    }

    @objc private func buildStory() {
        view.endEditing(true)
        if let selectedAchievement {
            story = CareerToolkitService.buildSTAR(from: selectedAchievement)
        } else if !sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            story = CareerToolkitService.buildSTAR(from: sourceText)
        } else {
            CareerToolkitUI.showAlert(on: self, title: "Choose a Story", message: "Select an achievement or describe a challenge you handled.")
            return
        }
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: true)
    }

    private func chooseAchievement() {
        let achievements = CareerStorage.shared.loadAchievements()
        guard !achievements.isEmpty else {
            CareerToolkitUI.showAlert(on: self, title: "Vault Is Empty", message: "Save an achievement first, or describe a story in the text box.")
            return
        }

        let alert = UIAlertController(title: "Choose Achievement", message: nil, preferredStyle: .actionSheet)
        achievements.forEach { achievement in
            alert.addAction(UIAlertAction(title: achievement.title, style: .default) { [weak self] _ in
                self?.selectedAchievement = achievement
                self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = tableView
            popover.sourceRect = tableView.rectForRow(at: IndexPath(row: 0, section: 0))
        }
        present(alert, animated: true)
    }

    private func storyItem(_ row: Int) -> (String, String, String) {
        guard let story else { return ("", "", "") }
        switch row {
        case 0: return ("Situation", story.situation, "location.fill")
        case 1: return ("Task", story.task, "target")
        case 2: return ("Action", story.action, "figure.run")
        default: return ("Result", story.result, "chart.line.uptrend.xyaxis")
        }
    }
}

private enum CareerToolkitUI {
    static func buttonFooter(title: String, color: UIColor, target: Any, action: Selector) -> UIView {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 92))
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.backgroundColor = color
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(target, action: action, for: .touchUpInside)
        footer.addSubview(button)

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: footer.topAnchor, constant: 20),
            button.leadingAnchor.constraint(equalTo: footer.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
        return footer
    }

    static func showAlert(on viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController.present(alert, animated: true)
    }
}
