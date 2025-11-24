import SwiftUI

struct SyntaxHighlighter {
    // ABB RAPID Keywords
    private static let keywords = [
        "MODULE", "ENDMODULE", "PROC", "ENDPROC", "FUNC", "ENDFUNC", "TRAP", "ENDTRAP",
        "LOCAL", "RECORD", "STRUCT", "TRAPDATA", "PERS", "TASK",
        "IF", "THEN", "ELSEIF", "ELSE", "ENDIF",
        "FOR", "TO", "STEP", "ENDFOR",
        "WHILE", "DO", "ENDWHILE",
        "REPEAT", "UNTIL",
        "TEST", "CASE", "DEFAULT", "ENDTEST",
        "GOTO", "LABEL",
        "RETURN", "EXIT",
        "TRUE", "FALSE",
        "AND", "OR", "NOT", "XOR",
        "DIV", "MOD",
        "SYSMODULE", "USERMODULE"
    ]
    
    // ABB RAPID Data Types
    private static let dataTypes = [
        "NUM", "BOOL", "STRING", "BYTE",
        "POS", "ORIENT", "POSE", "CONFDATA", "ROBTARGET", "JOINTTARGET",
        "SPEEDDATA", "ZONEDATA", "TOOLDATA", "WOBJDATA",
        "LOADDATA", "MECHANICALUNITDATA",
        "CLOCK", "DIONUM", "SIGNALXX"
    ]
    
    // ABB RAPID Instructions
    private static let instructions = [
        "MOVEL", "MOVEJ", "MOVEC", "MOVEABSJ",
        "MOVELDO", "MOVEJDO", "MOVECDO",
        "SETDO", "SETAO", "SETGO",
        "RESET", "SET", "PULSEDO",
        "WAITDI", "WAITTIME", "WAITUNTIL",
        "ACCSET", "VELSET",
        "CONFL", "CONFJ",
        "SINGAREA",
        "TRIGGIO", "TRIGGEQUIP",
        "EOFFSON", "EOFFSOFF",
        "WAITWOBJ",
        "STOP", "STOPMOVE",
        "TPWRITE", "TPREADNUM", "TPREADFK"
    ]
    
    static func highlight(_ text: String) -> AttributedString {
        var attributedString = AttributedString(text)
        let fullRange = attributedString.startIndex..<attributedString.endIndex
        
        // Default color
        attributedString[fullRange].foregroundColor = .primary
        
        let lines = text.components(separatedBy: .newlines)
        var currentIndex = attributedString.startIndex
        
        for line in lines {
            let lineLength = line.utf16.count
            let lineEndIndex = attributedString.index(currentIndex, offsetByCharacters: lineLength)
            
            guard lineEndIndex <= attributedString.endIndex else {
                break
            }
            
            let lineRange = currentIndex..<lineEndIndex
            
            // Highlight comments (lines starting with !)
            if let commentRange = line.range(of: "!"), line.distance(from: line.startIndex, to: commentRange.lowerBound) == 0 {
                attributedString[lineRange].foregroundColor = .green
            } else {
                // Highlight keywords, data types, and instructions
                highlightTokens(in: line, range: lineRange, in: &attributedString)
            }
            
            // Move to next line (including newline character)
            if lineEndIndex < attributedString.endIndex {
                currentIndex = attributedString.index(lineEndIndex, offsetByCharacters: 1)
            } else {
                break
            }
        }
        
        return attributedString
    }
    
    private static func highlightTokens(in line: String, range: Range<AttributedString.Index>, in attributedString: inout AttributedString) {
        if let commentIndex = line.firstIndex(of: "!") {
            let startOffset = line.distance(from: line.startIndex, to: commentIndex)
            let start = attributedString.index(range.lowerBound, offsetByCharacters: startOffset)
            let commentRange = start..<range.upperBound
            if start <= attributedString.endIndex {
                attributedString[commentRange].foregroundColor = .green
            }
            return
        }

        let words = line.components(separatedBy: CharacterSet.alphanumerics.inverted)
        var searchStartIndex = range.lowerBound
        
        for word in words {
            guard !word.isEmpty else { continue }

            if let wordRange = findWordRange(word: word, in: attributedString, startingFrom: searchStartIndex, within: range) {
                let uppercased = word.uppercased()
                // Check if it's a keyword
                if keywords.contains(uppercased) {
                    attributedString[wordRange].foregroundColor = .purple
                    attributedString[wordRange].font = .system(.body, design: .monospaced).bold()
                }
                // Check if it's a data type
                else if dataTypes.contains(uppercased) {
                    attributedString[wordRange].foregroundColor = .blue
                }
                // Check if it's an instruction
                else if instructions.contains(uppercased) {
                    attributedString[wordRange].foregroundColor = .orange
                }

                searchStartIndex = wordRange.upperBound
            }
        }
        
        // Highlight string literals
        highlightStrings(in: line, range: range, in: &attributedString)
        
        // Highlight numbers
        highlightNumbers(in: line, range: range, in: &attributedString)
    }
    
    private static func findWordRange(word: String, in attributedString: AttributedString, startingFrom: AttributedString.Index, within: Range<AttributedString.Index>) -> Range<AttributedString.Index>? {
        let substring = String(attributedString[startingFrom..<within.upperBound].characters)
        
        if let range = substring.range(of: "\\b\(word)\\b", options: .regularExpression) {
            let startOffset = substring.distance(from: substring.startIndex, to: range.lowerBound)
            let endOffset = substring.distance(from: substring.startIndex, to: range.upperBound)
            
            let start = attributedString.index(startingFrom, offsetByCharacters: startOffset)
            let end = attributedString.index(startingFrom, offsetByCharacters: endOffset)
            
            return start..<end
        }
        
        return nil
    }
    
    private static func highlightStrings(in line: String, range: Range<AttributedString.Index>, in attributedString: inout AttributedString) {
        let pattern = "\"[^\"]*\""
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return }
        
        let nsRange = NSRange(line.startIndex..., in: line)
        let matches = regex.matches(in: line, range: nsRange)
        
        for match in matches {
            if let swiftRange = Range(match.range, in: line) {
                let startOffset = line.distance(from: line.startIndex, to: swiftRange.lowerBound)
                let endOffset = line.distance(from: line.startIndex, to: swiftRange.upperBound)
                
                let start = attributedString.index(range.lowerBound, offsetByCharacters: startOffset)
                let end = attributedString.index(range.lowerBound, offsetByCharacters: endOffset)
                
                if start < attributedString.endIndex && end <= attributedString.endIndex {
                    attributedString[start..<end].foregroundColor = .red
                }
            }
        }
    }
    
    private static func highlightNumbers(in line: String, range: Range<AttributedString.Index>, in attributedString: inout AttributedString) {
        let pattern = "\\b\\d+\\.?\\d*\\b"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return }
        
        let nsRange = NSRange(line.startIndex..., in: line)
        let matches = regex.matches(in: line, range: nsRange)
        
        for match in matches {
            if let swiftRange = Range(match.range, in: line) {
                let startOffset = line.distance(from: line.startIndex, to: swiftRange.lowerBound)
                let endOffset = line.distance(from: line.startIndex, to: swiftRange.upperBound)
                
                let start = attributedString.index(range.lowerBound, offsetByCharacters: startOffset)
                let end = attributedString.index(range.lowerBound, offsetByCharacters: endOffset)
                
                if start < attributedString.endIndex && end <= attributedString.endIndex {
                    attributedString[start..<end].foregroundColor = .cyan
                }
            }
        }
    }
}
