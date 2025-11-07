import Foundation

// ABB RAPID Module representation
struct ABBModule: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var type: ModuleType
    var routines: [ABBRoutine]
    var declarations: [String]
    var content: String
    
    enum ModuleType: String {
        case program = "MODULE"
        case system = "SYSMODULE"
        case user = "USERMODULE"
    }
}

// ABB RAPID Routine representation
struct ABBRoutine: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var type: RoutineType
    var parameters: [String]
    var content: String
    var lineNumber: Int
    
    enum RoutineType: String {
        case proc = "PROC"
        case func = "FUNC"
        case trap = "TRAP"
    }
}

// File representation
struct ABBFile: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var url: URL
    var modules: [ABBModule]
    var rawContent: String
}
