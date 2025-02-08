import gleam/list
import token.{type Token}

pub fn lex(source: String) -> Result(List(Token), String) {
  do_lex(source, [])
}

fn do_lex(source: String, acc: List(Token)) -> Result(List(Token), String) {
  case source {
    "" -> list.reverse(acc) |> Ok

    // whitespace
    " " <> rest | "\t" <> rest | "\n" <> rest | "\r" <> rest ->
      do_lex(rest, acc)

    // Float operators
    "<=." <> rest -> do_lex(rest, [token.LessEqualDot, ..acc])
    ">=." <> rest -> do_lex(rest, [token.GreaterEqualDot, ..acc])
    "+." <> rest -> do_lex(rest, [token.PlusDot, ..acc])
    "-." <> rest -> do_lex(rest, [token.MinusDot, ..acc])
    "*." <> rest -> do_lex(rest, [token.StarDot, ..acc])
    "/." <> rest -> do_lex(rest, [token.SlashDot, ..acc])
    "<." <> rest -> do_lex(rest, [token.LessDot, ..acc])
    ">." <> rest -> do_lex(rest, [token.GreaterDot, ..acc])

    // Int operators
    "<=" <> rest -> do_lex(rest, [token.LessEqual, ..acc])
    ">=" <> rest -> do_lex(rest, [token.GreaterEqual, ..acc])
    "+" <> rest -> do_lex(rest, [token.Plus, ..acc])
    "-" <> rest -> do_lex(rest, [token.Minus, ..acc])
    "*" <> rest -> do_lex(rest, [token.Star, ..acc])
    "/" <> rest -> do_lex(rest, [token.Slash, ..acc])
    "<" <> rest -> do_lex(rest, [token.Less, ..acc])
    ">" <> rest -> do_lex(rest, [token.Greater, ..acc])
    "%" <> rest -> do_lex(rest, [token.Percent, ..acc])

    // Groupings
    "(" <> rest -> do_lex(rest, [token.LeftParen, ..acc])
    ")" <> rest -> do_lex(rest, [token.RightParen, ..acc])
    "[" <> rest -> do_lex(rest, [token.LeftSquare, ..acc])
    "]" <> rest -> do_lex(rest, [token.RightSquare, ..acc])
    "{" <> rest -> do_lex(rest, [token.LeftBrace, ..acc])
    "}" <> rest -> do_lex(rest, [token.RightBrace, ..acc])

    c -> Error("Unexpected char:" <> c)
  }
}
