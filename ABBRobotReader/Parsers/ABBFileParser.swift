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
        
        for line in lines {
            lineNumber += 1
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // Module detection
            if trimmedLine.hasPrefix("MODULE") || trimmedLine.hasPrefix("SYSMODULE") || trimmedLine.hasPrefix("USERMODULE") {
                // Save previous module if exists
                if var module = currentModule {
                    module.routines = routines
                    module.declarations = declarations
                    module.content = moduleContent
                    modules.append(module)
                }
                
                // Parse module name
                let moduleType: ABBModule.ModuleType
                if trimmedLine.hasPrefix("SYSMODULE") {
                    moduleType = .system
                } else if trimmedLine.hasPrefix("USERMODULE") {
                    moduleType = .user
                } else {
                    moduleType = .program
                }
                
                let moduleName = extractName(from: trimmedLine, after: moduleType.rawValue)
                currentModule = ABBModule(name: moduleName, type: moduleType, routines: [], declarations: [], content: "")
                moduleContent = line + "\n"
                routines = []
                declarations = []
            }
            // Routine detection
            else if trimmedLine.hasPrefix("PROC ") || trimmedLine.hasPrefix("FUNC ") || trimmedLine.hasPrefix("TRAP ") {
                // Save previous routine if exists
                if var routine = currentRoutine {
                    routine.content = routineContent
                    routines.append(routine)
                }
                
                let routineType: ABBRoutine.RoutineType
                let keyword: String
                if trimmedLine.hasPrefix("PROC ") {
                    routineType = .proc
                    keyword = "PROC"
                } else if trimmedLine.hasPrefix("FUNC ") {
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
            else if (trimmedLine.hasPrefix("ENDPROC") || trimmedLine.hasPrefix("ENDFUNC") || trimmedLine.hasPrefix("ENDTRAP")) && currentRoutine != nil {
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
            else if trimmedLine.hasPrefix("ENDMODULE") {
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
            }
            // Variable declarations
            else if currentModule != nil && currentRoutine == nil {
                if !trimmedLine.isEmpty && !trimmedLine.hasPrefix("!") {
                    // Check for variable declarations
                    if trimmedLine.contains("VAR") || trimmedLine.contains("PERS") || trimmedLine.contains("CONST") {
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
