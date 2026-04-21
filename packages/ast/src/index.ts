export class ASTAnalyzer {
  async analyzeFile(_filePath: string, _content: string): Promise<any> {
    return { symbols: [], imports: [], exports: [], functions: [], classes: [] }
  }
  async renameSymbol(_filePath: string, _content: string, _oldName: string, newName: string): Promise<string> {
    return _content.replace(new RegExp(_oldName, 'g'), newName)
  }
}