pub type Token {
  Name(value: String)
  UpName(value: String)
  DiscardName(value: String)
  Int(value: String)
  Float(value: String)
  String(value: String)
  CommentDoc(content: String)
  CommentNormal(content: String)
  CommentModule(content: String)

  // Groupings
  LeftParen
  RightParen
  LeftSquare
  RightSquare
  LeftBrace
  RightBrace

  // Int Operators
  Plus
  Minus
  Star
  Slash
  Less
  Greater
  LessEqual
  GreaterEqual
  Percent

  // Float Operators
  PlusDot
  MinusDot
  StarDot
  SlashDot
  LessDot
  GreaterDot
  LessEqualDot
  GreaterEqualDot

  // String Operators
  LtGt

  // Other Punctuation
  Colon
  Comma
  Hash
  Bang
  Equal
  EqualEqual
  NotEqual
  Vbar
  VbarVbar
  AmperAmper
  LtLt
  GtGt
  Pipe
  Dot
  RArrow
  LArrow
  DotDot
  At
  EndOfFile

  // Extra
  NewLine

  // Keywords (alphabetically):
  As
  Assert
  Auto
  Case
  Const
  Delegate
  Derive
  Echo
  Else
  Fn
  If
  Implement
  Import
  Let
  Macro
  Opaque
  Panic
  Pub
  Test
  Todo
  Type
  Use
}
