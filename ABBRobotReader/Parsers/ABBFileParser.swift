import Foundation

class ABBFileParser {
    static func parse(fileURL: URL) throws -> ABBFile {
        let content: String
        do {
            content = try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            // ABB controller exports often use ISO-8859-1. Fallback to keep parsing resilient.
            content = try String(contentsOf: fileURL, encoding: .isoLatin1)
        }
        let fileName = fileURL.lastPathComponent
        
        var modules: [ABBModule] = []
        let lines = content.components(separatedBy: .newlines)
        
        var currentModule: ABBModule?
        var currentRoutine: ABBRoutine?
        var moduleContent = ""
        var routineContent = ""
        var declarations: [String] = []
        var routines: [ABBRoutine] = []
        var lineNumber = 0

        let moduleRegex = try NSRegularExpression(pattern: "^\\s*(sysmodule|usermodule|module)\\s+([\\w$]+)", options: [.caseInsensitive])
        let routineRegex = try NSRegularExpression(pattern: "^\\s*(local\\s+)?(proc|func|trap)\\s+([\\w$]+)(\\s*\\([^)]*\\))?", options: [.caseInsensitive])
        let routineEndRegex = try NSRegularExpression(pattern: "^\\s*end(proc|func|trap)", options: [.caseInsensitive])
        let declarationKeywords = ["var", "pers", "const", "record", "alias", "trapdata", "task", "struct"]

        for line in lines {
            lineNumber += 1
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)

            if let match = moduleRegex.firstMatch(in: trimmedLine, range: NSRange(location: 0, length: trimmedLine.utf16.count)) {
                if var module = currentModule {
                    module.routines = routines
                    module.declarations = declarations
                    module.content = moduleContent
                    modules.append(module)
                }

                let typeToken = (trimmedLine as NSString).substring(with: match.range(at: 1)).uppercased()
                let nameToken = (trimmedLine as NSString).substring(with: match.range(at: 2))
                let moduleType: ABBModule.ModuleType = {
                    switch typeToken {
                    case "SYSMODULE": return .system
                    case "USERMODULE": return .user
                    default: return .program
                    }
                }()

                currentModule = ABBModule(name: nameToken, type: moduleType, routines: [], declarations: [], content: "")
                moduleContent = line + "\n"
                routines = []
                declarations = []
                currentRoutine = nil
                routineContent = ""
                continue
            }

            if let match = routineRegex.firstMatch(in: trimmedLine, range: NSRange(location: 0, length: trimmedLine.utf16.count)) {
                if var routine = currentRoutine {
                    routine.content = routineContent
                    routines.append(routine)
                }

                let typeToken = (trimmedLine as NSString).substring(with: match.range(at: 2)).uppercased()
                let routineName = (trimmedLine as NSString).substring(with: match.range(at: 3))
                let params = extractParameters(from: trimmedLine)

                let routineType: ABBRoutine.RoutineType = {
                    switch typeToken {
                    case "FUNC": return .function
                    case "TRAP": return .trap
                    default: return .proc
                    }
                }()

                currentRoutine = ABBRoutine(name: routineName, type: routineType, parameters: params, content: "", lineNumber: lineNumber)
                routineContent = line + "\n"
                moduleContent += line + "\n"
                continue
            }

            if routineEndRegex.firstMatch(in: trimmedLine, range: NSRange(location: 0, length: trimmedLine.utf16.count)) != nil, currentRoutine != nil {
                routineContent += line + "\n"
                moduleContent += line + "\n"
                if var routine = currentRoutine {
                    routine.content = routineContent
                    routines.append(routine)
                }
                currentRoutine = nil
                routineContent = ""
                continue
            }

            if trimmedLine.lowercased().hasPrefix("endmodule") {
                moduleContent += line + "\n"
                if var module = currentModule {
                    module.routines = routines
                    module.declarations = declarations
                    module.content = moduleContent
                    modules.append(module)
                }
                currentModule = nil
                routines = []
                declarations = []
                moduleContent = ""
                currentRoutine = nil
                routineContent = ""
                continue
            }

            if currentModule != nil && currentRoutine == nil {
                if !trimmedLine.isEmpty && !trimmedLine.trimmingCharacters(in: .whitespaces).hasPrefix("!") {
                    let lower = trimmedLine.lowercased()
                    if declarationKeywords.contains(where: { lower.hasPrefix($0) || lower.contains(" \($0)") }) {
                        declarations.append(trimmedLine)
                    }
                }
                moduleContent += line + "\n"
                continue
            }

            if currentRoutine != nil {
                routineContent += line + "\n"
                moduleContent += line + "\n"
                continue
            }

            moduleContent += line + "\n"
        }
        
        // Append any unterminated routine/module so partially written files still render.
        if var routine = currentRoutine {
            routine.content = routineContent
            routines.append(routine)
        }
        if var module = currentModule {
            module.routines = routines
            module.declarations = declarations
            module.content = moduleContent.isEmpty ? content : moduleContent
            modules.append(module)
        }

        // Handle case where file doesn't have explicit MODULE declarations
        if modules.isEmpty && !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let implicitModule = ABBModule(
                name: fileName.replacingOccurrences(of: ".\(fileURL.pathExtension)", with: ""),
                type: .program,
                routines: routines,
                declarations: declarations,
                content: content
            )
            modules.append(implicitModule)
        }
        
        return ABBFile(name: fileName, url: fileURL, modules: modules, rawContent: content)
    }
    
    private static func extractName(from line: String, after keyword: String) -> String {
        guard let range = line.range(of: keyword) else { return "Unknown" }
        let afterKeyword = String(line[range.upperBound...])
        let components = afterKeyword.trimmingCharacters(in: .whitespaces).components(separatedBy: CharacterSet(charactersIn: "( \t"))
        return components.first?.trimmingCharacters(in: .whitespaces) ?? "Unknown"
    }
    
    private static func extractParameters(from line: String) -> [String] {
        guard let startIndex = line.firstIndex(of: "("),
              let endIndex = line.firstIndex(of: ")") else {
            return []
        }
        let paramString = String(line[line.index(after: startIndex)..<endIndex])
        return paramString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }
}
