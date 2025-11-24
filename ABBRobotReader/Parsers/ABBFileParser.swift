import Foundation

class ABBFileParser {
    static func parse(fileURL: URL) throws -> ABBFile {
        let data = try Data(contentsOf: fileURL)
        guard let decodedContent = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) else {
            throw NSError(domain: "ABBFileParser", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unsupported file encoding"])
        }

        let content = decodedContent.replacingOccurrences(of: "\r\n", with: "\n")
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

        for line in lines {
            lineNumber += 1
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            let normalizedLine = trimmedLine.uppercased()

            // Module detection
            if normalizedLine.hasPrefix("MODULE") || normalizedLine.hasPrefix("SYSMODULE") || normalizedLine.hasPrefix("USERMODULE") {
                // Save previous module if exists
                if var module = currentModule {
                    if var routine = currentRoutine {
                        routine.content = routineContent
                        routines.append(routine)
                    }
                    module.routines = routines
                    module.declarations = declarations
                    module.content = moduleContent
                    modules.append(module)
                }

                // Parse module name
                let moduleType: ABBModule.ModuleType
                if normalizedLine.hasPrefix("SYSMODULE") {
                    moduleType = .system
                } else if normalizedLine.hasPrefix("USERMODULE") {
                    moduleType = .user
                } else {
                    moduleType = .program
                }

                let moduleName = extractName(from: trimmedLine, after: moduleType.rawValue)
                currentModule = ABBModule(name: moduleName, type: moduleType, routines: [], declarations: [], content: "")
                moduleContent = line + "\n"
                routines = []
                declarations = []
                currentRoutine = nil
                routineContent = ""
            }
            // Routine detection
            else if normalizedLine.hasPrefix("PROC ") || normalizedLine.hasPrefix("FUNC ") || normalizedLine.hasPrefix("TRAP ") {
                // Save previous routine if exists
                if var routine = currentRoutine {
                    routine.content = routineContent
                    routines.append(routine)
                }

                let routineType: ABBRoutine.RoutineType
                let keyword: String
                if normalizedLine.hasPrefix("PROC ") {
                    routineType = .proc
                    keyword = "PROC"
                } else if normalizedLine.hasPrefix("FUNC ") {
                    routineType = .function
                    keyword = "FUNC"
                } else {
                    routineType = .trap
                    keyword = "TRAP"
                }

                let routineName = extractName(from: trimmedLine, after: keyword)
                let params = extractParameters(from: trimmedLine)
                currentRoutine = ABBRoutine(name: routineName, type: routineType, parameters: params, content: "", lineNumber: lineNumber)
                routineContent = line + "\n"
                moduleContent += line + "\n"
            }
            // End of routine
            else if (normalizedLine.hasPrefix("ENDPROC") || normalizedLine.hasPrefix("ENDFUNC") || normalizedLine.hasPrefix("ENDTRAP")) && currentRoutine != nil {
                routineContent += line + "\n"
                moduleContent += line + "\n"
                if var routine = currentRoutine {
                    routine.content = routineContent
                    routines.append(routine)
                }
                currentRoutine = nil
                routineContent = ""
            }
            // End of module
            else if normalizedLine.hasPrefix("ENDMODULE") {
                moduleContent += line + "\n"
                if var module = currentModule {
                    if var routine = currentRoutine {
                        routine.content = routineContent
                        routines.append(routine)
                    }
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
            }
            // Variable declarations
            else if currentModule != nil && currentRoutine == nil {
                if !trimmedLine.isEmpty && !trimmedLine.hasPrefix("!") {
                    // Check for variable declarations
                    if normalizedLine.contains("VAR") || normalizedLine.contains("PERS") || normalizedLine.contains("CONST") {
                        declarations.append(trimmedLine)
                    }
                }
                moduleContent += line + "\n"
            }
            // Inside routine
            else if currentRoutine != nil {
                routineContent += line + "\n"
                moduleContent += line + "\n"
            }
            // Outside module (standalone code)
            else {
                moduleContent += line + "\n"
            }
        }

        // Capture any dangling routine/module at EOF
        if var routine = currentRoutine {
            routine.content = routineContent
            routines.append(routine)
        }

        if var module = currentModule {
            module.routines = routines
            module.declarations = declarations
            module.content = moduleContent
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
        guard let range = line.range(of: keyword, options: .caseInsensitive) else { return "Unknown" }
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
