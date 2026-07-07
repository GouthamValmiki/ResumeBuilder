import UIKit

enum PDFGenerator {
    private static let pageWidth: CGFloat = 612
    private static let pageHeight: CGFloat = 792
    private static let margin: CGFloat = 48
    private static let contentWidth: CGFloat = pageWidth - (margin * 2)

    static func generatePDF(for resume: Resume) -> Data? {
        let template = resume.template
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))
        return renderer.pdfData { context in
            var y = margin
            context.beginPage()

            let headerHeight: CGFloat = 130
            if let gradientColors = template.headerGradientColors {
                drawGradientHeader(colors: gradientColors, rect: CGRect(x: 0, y: 0, width: pageWidth, height: headerHeight), in: context.cgContext)
                y = drawHeader(resume.personalInfo, template: template, at: 32, in: context.cgContext)
                y = max(y, headerHeight + 10)
            } else if let headerBg = template.headerBackgroundColor {
                context.cgContext.setFillColor(headerBg.cgColor)
                context.cgContext.fill(CGRect(x: 0, y: 0, width: pageWidth, height: headerHeight))
                y = drawHeader(resume.personalInfo, template: template, at: 32, in: context.cgContext)
                y = max(y, headerHeight + 10)
            } else {
                y = drawHeader(resume.personalInfo, template: template, at: y, in: context.cgContext)
            }

            y = drawSection(
                title: "Professional Summary",
                body: resume.personalInfo.summary,
                template: template,
                at: y,
                in: context.cgContext
            )

            for section in resume.sectionOrder {
                switch section {
                case .experience:
                    y = drawExperiences(resume.experiences, template: template, at: y, context: context)
                case .projects:
                    y = drawProjects(resume.projects, template: template, at: y, context: context)
                case .education:
                    y = drawEducations(resume.educations, template: template, at: y, context: context)
                case .skills:
                    y = drawSkills(resume.skills, template: template, at: y, context: context)
                }
            }
        }
    }

    private static func titleFont(template: ResumeTemplate, size: CGFloat, bold: Bool = true) -> UIFont {
        if template.usesSerifTitle {
            let fontName = bold ? "Georgia-Bold" : "Georgia"
            return UIFont(name: fontName, size: size) ?? .boldSystemFont(ofSize: size)
        }
        return bold ? .boldSystemFont(ofSize: size) : .systemFont(ofSize: size)
    }

    private static func bodyFont(template: ResumeTemplate, size: CGFloat) -> UIFont {
        if template.usesSerifTitle {
            return UIFont(name: "Georgia", size: size) ?? .systemFont(ofSize: size)
        }
        return .systemFont(ofSize: size)
    }

    private static func ensureSpace(_ needed: CGFloat, currentY: CGFloat, context: UIGraphicsPDFRendererContext) -> CGFloat {
        if currentY + needed > pageHeight - margin {
            context.beginPage()
            return margin
        }
        return currentY
    }

    private static func drawGradientHeader(colors: [UIColor], rect: CGRect, in cgContext: CGContext) {
        let cgColors = colors.map { $0.cgColor } as CFArray
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat] = [0.0, 1.0]
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: cgColors, locations: colorLocations) else { return }
        
        cgContext.saveGState()
        cgContext.clip(to: rect)
        cgContext.drawLinearGradient(
            gradient,
            start: CGPoint(x: rect.minX, y: rect.minY),
            end: CGPoint(x: rect.maxX, y: rect.maxY),
            options: []
        )
        cgContext.restoreGState()
    }

    private static func drawHeader(_ info: PersonalInfo, template: ResumeTemplate, at startY: CGFloat, in cgContext: CGContext) -> CGFloat {
        var y = startY
        let hasHeaderBg = template.headerBackgroundColor != nil || template.headerGradientColors != nil
        let nameColor = hasHeaderBg ? template.headerTextColor : UIColor.black
        
        let alignment: NSTextAlignment = template == .executive ? .center : .left
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        
        if !info.fullName.isEmpty {
            let attrs: [NSAttributedString.Key: Any] = [
                .font: titleFont(template: template, size: 24, bold: true),
                .foregroundColor: nameColor,
                .paragraphStyle: paragraphStyle
            ]
            y += drawText(info.fullName, rect: CGRect(x: margin, y: y, width: contentWidth, height: 40), attributes: attrs) + 6
        }

        var contactParts: [String] = []
        if !info.email.isEmpty { contactParts.append(info.email) }
        if !info.phone.isEmpty { contactParts.append(info.phone) }
        if !info.address.isEmpty { contactParts.append(info.address) }
        
        let contactColor = hasHeaderBg ? template.headerTextColor.withAlphaComponent(0.85) : UIColor.darkGray
        
        if !contactParts.isEmpty {
            let attrs: [NSAttributedString.Key: Any] = [
                .font: bodyFont(template: template, size: 9.5),
                .foregroundColor: contactColor,
                .paragraphStyle: paragraphStyle
            ]
            y += drawText(contactParts.joined(separator: "  •  "), rect: CGRect(x: margin, y: y, width: contentWidth, height: 30), attributes: attrs) + 4
        }
        
        var linkParts: [String] = []
        if !info.linkedIn.isEmpty { linkParts.append(info.linkedIn) }
        if !info.website.isEmpty { linkParts.append(info.website) }
        
        if !linkParts.isEmpty {
            let linkColor = hasHeaderBg ? template.headerTextColor : template.accentColor
            let attrs: [NSAttributedString.Key: Any] = [
                .font: bodyFont(template: template, size: 9.5),
                .foregroundColor: linkColor,
                .paragraphStyle: paragraphStyle
            ]
            y += drawText(linkParts.joined(separator: "  •  "), rect: CGRect(x: margin, y: y, width: contentWidth, height: 30), attributes: attrs) + 6
        }

        if !hasHeaderBg {
            y += 6
            drawLine(at: y, color: template.accentColor.withAlphaComponent(0.3), in: cgContext)
            y += 12
        }
        return y
    }

    private static func drawExperiences(_ experiences: [WorkExperience], template: ResumeTemplate, at startY: CGFloat, context: UIGraphicsPDFRendererContext) -> CGFloat {
        guard !experiences.isEmpty else { return startY }
        var y = ensureSpace(80, currentY: startY, context: context)
        y = drawSectionTitle("Work Experience", template: template, at: y, in: context.cgContext)
        for experience in experiences {
            y = ensureSpace(60, currentY: y, context: context)
            y = drawExperience(experience, template: template, at: y, in: context.cgContext)
        }
        return y
    }

    private static func drawProjects(_ projects: [Project], template: ResumeTemplate, at startY: CGFloat, context: UIGraphicsPDFRendererContext) -> CGFloat {
        guard !projects.isEmpty else { return startY }
        var y = ensureSpace(80, currentY: startY, context: context)
        y = drawSectionTitle("Projects", template: template, at: y, in: context.cgContext)
        for project in projects {
            y = ensureSpace(60, currentY: y, context: context)
            y = drawProject(project, template: template, at: y, in: context.cgContext)
        }
        return y
    }

    private static func drawEducations(_ educations: [Education], template: ResumeTemplate, at startY: CGFloat, context: UIGraphicsPDFRendererContext) -> CGFloat {
        guard !educations.isEmpty else { return startY }
        var y = ensureSpace(80, currentY: startY, context: context)
        y = drawSectionTitle("Education", template: template, at: y, in: context.cgContext)
        for education in educations {
            y = ensureSpace(60, currentY: y, context: context)
            y = drawEducation(education, template: template, at: y, in: context.cgContext)
        }
        return y
    }

    private static func drawSkills(_ skills: [Skill], template: ResumeTemplate, at startY: CGFloat, context: UIGraphicsPDFRendererContext) -> CGFloat {
        guard !skills.isEmpty else { return startY }
        var y = ensureSpace(80, currentY: startY, context: context)
        y = drawSectionTitle("Skills", template: template, at: y, in: context.cgContext)
        
        let grouped = Dictionary(grouping: skills, by: { $0.category })
        for (category, items) in grouped.sorted(by: { $0.key < $1.key }) {
            y = ensureSpace(24, currentY: y, context: context)
            
            // Draw category label in bold
            let catAttrs: [NSAttributedString.Key: Any] = [
                .font: titleFont(template: template, size: 10, bold: true),
                .foregroundColor: template.accentColor
            ]
            let catString = "\(category): "
            let catWidth = catString.boundingRect(
                with: CGSize(width: contentWidth, height: 20),
                options: [],
                attributes: catAttrs,
                context: nil
            ).width
            
            drawText(catString, rect: CGRect(x: margin, y: y, width: catWidth + 5, height: 20), attributes: catAttrs)
            
            // Draw skills list
            let skillAttrs: [NSAttributedString.Key: Any] = [
                .font: bodyFont(template: template, size: 10),
                .foregroundColor: UIColor.label
            ]
            let skillsText = items.map(\.name).joined(separator: ", ")
            
            let textHeight = drawText(
                skillsText,
                rect: CGRect(x: margin + catWidth + 5, y: y, width: contentWidth - (catWidth + 5), height: 30),
                attributes: skillAttrs
            )
            y += textHeight + 4
        }
        return y
    }

    private static func drawSection(title: String, body: String, template: ResumeTemplate, at startY: CGFloat, in cgContext: CGContext) -> CGFloat {
        guard !body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return startY }
        var y = drawSectionTitle(title, template: template, at: startY, in: cgContext)
        y = drawBody(body, template: template, at: y, in: cgContext)
        return y + 8
    }

    private static func drawSectionTitle(_ title: String, template: ResumeTemplate, at y: CGFloat, in cgContext: CGContext) -> CGFloat {
        switch template {
        case .classic:
            let attrs: [NSAttributedString.Key: Any] = [
                .font: titleFont(template: template, size: 12, bold: true),
                .foregroundColor: template.accentColor
            ]
            let height = drawText(title.uppercased(), rect: CGRect(x: margin, y: y, width: contentWidth, height: 24), attributes: attrs)
            drawLine(at: y + height + 2, color: template.accentColor.withAlphaComponent(0.4), in: cgContext)
            return y + height + 10
            
        case .modern:
            let attrs: [NSAttributedString.Key: Any] = [
                .font: titleFont(template: template, size: 12, bold: true),
                .foregroundColor: template.accentColor
            ]
            
            cgContext.setFillColor(template.accentColor.cgColor)
            cgContext.fill(CGRect(x: margin, y: y + 2, width: 4, height: 14))
            
            let height = drawText(title.uppercased(), rect: CGRect(x: margin + 10, y: y + 2, width: contentWidth - 10, height: 24), attributes: attrs)
            return y + height + 10
            
        case .minimal:
            let attrs: [NSAttributedString.Key: Any] = [
                .font: titleFont(template: template, size: 11, bold: true),
                .foregroundColor: template.accentColor
            ]
            let height = drawText(title.uppercased(), rect: CGRect(x: margin, y: y, width: contentWidth, height: 24), attributes: attrs)
            drawLine(at: y + height + 2, color: UIColor.lightGray.withAlphaComponent(0.5), in: cgContext)
            return y + height + 10
            
        case .executive:
            let attrs: [NSAttributedString.Key: Any] = [
                .font: titleFont(template: template, size: 12, bold: true),
                .foregroundColor: template.accentColor
            ]
            let textWidth = title.uppercased().boundingRect(
                with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                options: [],
                attributes: attrs,
                context: nil
            ).width
            
            let textX = margin + (contentWidth - textWidth) / 2
            let height = drawText(title.uppercased(), rect: CGRect(x: textX, y: y, width: textWidth, height: 24), attributes: attrs)
            
            cgContext.setStrokeColor(template.accentColor.withAlphaComponent(0.3).cgColor)
            cgContext.setLineWidth(0.5)
            
            cgContext.move(to: CGPoint(x: margin, y: y + height / 2))
            cgContext.addLine(to: CGPoint(x: textX - 10, y: y + height / 2))
            cgContext.strokePath()
            
            cgContext.move(to: CGPoint(x: textX + textWidth + 10, y: y + height / 2))
            cgContext.addLine(to: CGPoint(x: pageWidth - margin, y: y + height / 2))
            cgContext.strokePath()
            
            return y + height + 12
            
        case .creative:
            let attrs: [NSAttributedString.Key: Any] = [
                .font: titleFont(template: template, size: 9.5, bold: true),
                .foregroundColor: template.accentColor
            ]
            let textWidth = title.uppercased().boundingRect(
                with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                options: [],
                attributes: attrs,
                context: nil
            ).width
            
            let badgeWidth = textWidth + 20
            let badgeHeight: CGFloat = 20
            
            let path = UIBezierPath(roundedRect: CGRect(x: margin, y: y, width: badgeWidth, height: badgeHeight), cornerRadius: 6)
            cgContext.setFillColor(template.accentColor.withAlphaComponent(0.12).cgColor)
            cgContext.addPath(path.cgPath)
            cgContext.fillPath()
            
            drawText(title.uppercased(), rect: CGRect(x: margin + 10, y: y + 4, width: textWidth, height: badgeHeight), attributes: attrs)
            return y + badgeHeight + 10
        }
    }

    private static func drawExperience(_ exp: WorkExperience, template: ResumeTemplate, at startY: CGFloat, in cgContext: CGContext) -> CGFloat {
        var y = startY
        
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: titleFont(template: template, size: 12, bold: true),
            .foregroundColor: UIColor.black
        ]
        let dateAttrs: [NSAttributedString.Key: Any] = [
            .font: bodyFont(template: template, size: 10),
            .foregroundColor: UIColor.secondaryLabel
        ]
        let subAttrs: [NSAttributedString.Key: Any] = [
            .font: bodyFont(template: template, size: 11),
            .foregroundColor: template.accentColor
        ]

        let hasTitle = !exp.jobTitle.isEmpty
        let hasDate = !exp.dateRange.isEmpty
        
        if hasTitle {
            let titleWidth = hasDate ? contentWidth - 100 : contentWidth
            let titleHeight = drawText(exp.jobTitle, rect: CGRect(x: margin, y: y, width: titleWidth, height: 20), attributes: titleAttrs)
            
            if hasDate {
                drawText(exp.dateRange, rect: CGRect(x: pageWidth - margin - 120, y: y + 1.5, width: 120, height: 18), attributes: [
                    .font: bodyFont(template: template, size: 9.5),
                    .foregroundColor: UIColor.darkGray,
                    .paragraphStyle: {
                        let p = NSMutableParagraphStyle()
                        p.alignment = .right
                        return p
                    }()
                ])
            }
            y += titleHeight + 2
        } else if hasDate {
            y += drawText(exp.dateRange, rect: CGRect(x: margin, y: y, width: contentWidth, height: 18), attributes: dateAttrs) + 2
        }
        
        var subtitle = exp.company
        if !exp.location.isEmpty { subtitle += " — \(exp.location)" }
        if !subtitle.isEmpty {
            y += drawText(subtitle, rect: CGRect(x: margin, y: y, width: contentWidth, height: 18), attributes: subAttrs) + 2
        }
        
        if !exp.description.isEmpty {
            y += 2
            y = drawBody(exp.description, template: template, at: y, in: cgContext, bulletPoints: true)
        }
        return y + 6
    }

    private static func drawProject(_ project: Project, template: ResumeTemplate, at startY: CGFloat, in cgContext: CGContext) -> CGFloat {
        var y = startY
        
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: titleFont(template: template, size: 12, bold: true),
            .foregroundColor: UIColor.black
        ]
        let dateAttrs: [NSAttributedString.Key: Any] = [
            .font: bodyFont(template: template, size: 10),
            .foregroundColor: UIColor.secondaryLabel
        ]
        let subAttrs: [NSAttributedString.Key: Any] = [
            .font: bodyFont(template: template, size: 11),
            .foregroundColor: template.accentColor
        ]

        let hasTitle = !project.name.isEmpty
        let hasDate = !project.dateRange.isEmpty
        
        if hasTitle {
            let titleWidth = hasDate ? contentWidth - 100 : contentWidth
            let titleHeight = drawText(project.name, rect: CGRect(x: margin, y: y, width: titleWidth, height: 20), attributes: titleAttrs)
            
            if hasDate {
                drawText(project.dateRange, rect: CGRect(x: pageWidth - margin - 120, y: y + 1.5, width: 120, height: 18), attributes: [
                    .font: bodyFont(template: template, size: 9.5),
                    .foregroundColor: UIColor.darkGray,
                    .paragraphStyle: {
                        let p = NSMutableParagraphStyle()
                        p.alignment = .right
                        return p
                    }()
                ])
            }
            y += titleHeight + 2
        } else if hasDate {
            y += drawText(project.dateRange, rect: CGRect(x: margin, y: y, width: contentWidth, height: 18), attributes: dateAttrs) + 2
        }
        
        var subtitle = project.role
        if !project.link.isEmpty { subtitle += " — \(project.link)" }
        if !subtitle.isEmpty {
            y += drawText(subtitle, rect: CGRect(x: margin, y: y, width: contentWidth, height: 18), attributes: subAttrs) + 2
        }
        
        if !project.description.isEmpty {
            y += 2
            y = drawBody(project.description, template: template, at: y, in: cgContext, bulletPoints: true)
        }
        return y + 6
    }

    private static func drawEducation(_ edu: Education, template: ResumeTemplate, at startY: CGFloat, in cgContext: CGContext) -> CGFloat {
        var y = startY
        
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: titleFont(template: template, size: 12, bold: true),
            .foregroundColor: UIColor.black
        ]
        let dateAttrs: [NSAttributedString.Key: Any] = [
            .font: bodyFont(template: template, size: 10),
            .foregroundColor: UIColor.secondaryLabel
        ]
        let subAttrs: [NSAttributedString.Key: Any] = [
            .font: bodyFont(template: template, size: 11),
            .foregroundColor: template.accentColor
        ]

        let hasTitle = !edu.degree.isEmpty
        let hasDate = !edu.dateRange.isEmpty
        
        if hasTitle {
            let titleWidth = hasDate ? contentWidth - 100 : contentWidth
            let titleHeight = drawText(edu.degree, rect: CGRect(x: margin, y: y, width: titleWidth, height: 20), attributes: titleAttrs)
            
            if hasDate {
                drawText(edu.dateRange, rect: CGRect(x: pageWidth - margin - 120, y: y + 1.5, width: 120, height: 18), attributes: [
                    .font: bodyFont(template: template, size: 9.5),
                    .foregroundColor: UIColor.darkGray,
                    .paragraphStyle: {
                        let p = NSMutableParagraphStyle()
                        p.alignment = .right
                        return p
                    }()
                ])
            }
            y += titleHeight + 2
        } else if hasDate {
            y += drawText(edu.dateRange, rect: CGRect(x: margin, y: y, width: contentWidth, height: 18), attributes: dateAttrs) + 2
        }
        
        var subtitle = edu.institution
        if !edu.location.isEmpty { subtitle += " — \(edu.location)" }
        if !subtitle.isEmpty {
            y += drawText(subtitle, rect: CGRect(x: margin, y: y, width: contentWidth, height: 18), attributes: subAttrs) + 2
        }
        
        if !edu.details.isEmpty {
            y += 2
            y = drawBody(edu.details, template: template, at: y, in: cgContext, bulletPoints: false)
        }
        return y + 6
    }

    private static func drawBody(_ text: String, template: ResumeTemplate, at startY: CGFloat, in cgContext: CGContext, bulletPoints: Bool = false) -> CGFloat {
        let lines = text.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        var y = startY
        let attrs: [NSAttributedString.Key: Any] = [
            .font: bodyFont(template: template, size: 10),
            .foregroundColor: UIColor.black
        ]

        for line in lines {
            if bulletPoints && (template == .creative || template == .modern) {
                cgContext.setFillColor(template.accentColor.cgColor)
                cgContext.fill(CGRect(x: margin + 3, y: y + 5, width: 3, height: 3))
                
                let textHeight = drawText(
                    line.trimmingCharacters(in: .whitespaces),
                    rect: CGRect(x: margin + 12, y: y, width: contentWidth - 12, height: 200),
                    attributes: attrs
                )
                y += textHeight + 4
            } else {
                let display = bulletPoints ? "• \(line.trimmingCharacters(in: .whitespaces))" : line
                let textHeight = drawText(
                    display,
                    rect: CGRect(x: margin + (bulletPoints ? 8 : 0), y: y, width: contentWidth - (bulletPoints ? 8 : 0), height: 200),
                    attributes: attrs
                )
                y += textHeight + 4
            }
        }
        return y
    }

    @discardableResult
    private static func drawText(_ text: String, rect: CGRect, attributes: [NSAttributedString.Key: Any]) -> CGFloat {
        let attributed = NSAttributedString(string: text, attributes: attributes)
        let bounding = attributed.boundingRect(
            with: CGSize(width: rect.width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        attributed.draw(
            with: CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.width, height: ceil(bounding.height)),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        return ceil(bounding.height)
    }

    private static func drawLine(at y: CGFloat, color: UIColor, in cgContext: CGContext) {
        cgContext.setStrokeColor(color.cgColor)
        cgContext.setLineWidth(0.5)
        cgContext.move(to: CGPoint(x: margin, y: y))
        cgContext.addLine(to: CGPoint(x: pageWidth - margin, y: y))
        cgContext.strokePath()
    }
}
