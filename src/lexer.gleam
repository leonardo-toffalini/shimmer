import gleam/list
import gleam/result
import gleam/string
import token.{type Token}

pub fn lex(source: String) -> Result(List(Token), String) {
  do_lex(source, [])
}

fn do_lex(source: String, acc: List(Token)) -> Result(List(Token), String) {
  case source {
    "" -> [token.EndOfFile, ..acc] |> list.reverse |> Ok

    // whitespace
    " " <> rest | "\t" <> rest | "\n" <> rest | "\r" <> rest ->
      do_lex(rest, acc)

    "<>" <> rest -> do_lex(rest, [token.LtGt, ..acc])

    // 2 char tokens
    "<=." <> rest -> do_lex(rest, [token.LessEqualDot, ..acc])
    ">=." <> rest -> do_lex(rest, [token.GreaterEqualDot, ..acc])
    "+." <> rest -> do_lex(rest, [token.PlusDot, ..acc])
    "-." <> rest -> do_lex(rest, [token.MinusDot, ..acc])
    "*." <> rest -> do_lex(rest, [token.StarDot, ..acc])
    "/." <> rest -> do_lex(rest, [token.SlashDot, ..acc])
    "<." <> rest -> do_lex(rest, [token.LessDot, ..acc])
    ">." <> rest -> do_lex(rest, [token.GreaterDot, ..acc])

    "<=" <> rest -> do_lex(rest, [token.LessEqual, ..acc])
    ">=" <> rest -> do_lex(rest, [token.GreaterEqual, ..acc])

    "==" <> rest -> do_lex(rest, [token.EqualEqual, ..acc])
    "!=" <> rest -> do_lex(rest, [token.NotEqual, ..acc])
    "=" <> rest -> do_lex(rest, [token.Equal, ..acc])
    "|>" <> rest -> do_lex(rest, [token.Pipe, ..acc])
    "||" <> rest -> do_lex(rest, [token.VbarVbar, ..acc])
    "|" <> rest -> do_lex(rest, [token.Vbar, ..acc])
    "&&" <> rest -> do_lex(rest, [token.AmperAmper, ..acc])
    "<<" <> rest -> do_lex(rest, [token.LtLt, ..acc])
    ">>" <> rest -> do_lex(rest, [token.GtGt, ..acc])
    "->" <> rest -> do_lex(rest, [token.RArrow, ..acc])
    "<-" <> rest -> do_lex(rest, [token.LArrow, ..acc])
    ".." <> rest -> do_lex(rest, [token.DotDot, ..acc])

    // 1 char tokens
    "+" <> rest -> do_lex(rest, [token.Plus, ..acc])
    "-" <> rest -> do_lex(rest, [token.Minus, ..acc])
    "*" <> rest -> do_lex(rest, [token.Star, ..acc])
    "/" <> rest -> do_lex(rest, [token.Slash, ..acc])
    "<" <> rest -> do_lex(rest, [token.Less, ..acc])
    ">" <> rest -> do_lex(rest, [token.Greater, ..acc])
    "%" <> rest -> do_lex(rest, [token.Percent, ..acc])

    "(" <> rest -> do_lex(rest, [token.LeftParen, ..acc])
    ")" <> rest -> do_lex(rest, [token.RightParen, ..acc])
    "[" <> rest -> do_lex(rest, [token.LeftSquare, ..acc])
    "]" <> rest -> do_lex(rest, [token.RightSquare, ..acc])
    "{" <> rest -> do_lex(rest, [token.LeftBrace, ..acc])
    "}" <> rest -> do_lex(rest, [token.RightBrace, ..acc])

    ":" <> rest -> do_lex(rest, [token.Colon, ..acc])
    "," <> rest -> do_lex(rest, [token.Comma, ..acc])
    "#" <> rest -> do_lex(rest, [token.Hash, ..acc])
    "!" <> rest -> do_lex(rest, [token.Bang, ..acc])
    "." <> rest -> do_lex(rest, [token.Dot, ..acc])
    "@" <> rest -> do_lex(rest, [token.At, ..acc])

    // int
    "1" as c <> rest
    | "2" as c <> rest
    | "3" as c <> rest
    | "4" as c <> rest
    | "5" as c <> rest
    | "6" as c <> rest
    | "7" as c <> rest
    | "8" as c <> rest
    | "9" as c <> rest
    | "0" as c <> rest -> {
      use #(lit, rest, t) <- result.try(read_number(c <> rest, 0, ""))
      case t {
        "int" -> do_lex(rest, [token.Int(lit), ..acc])
        "float" -> do_lex(rest, [token.Float(lit), ..acc])
        _ -> panic
      }
    }

    c -> Error("Unexpected char: " <> c)
  }
}

fn read_number(
  source: String,
  dot_counter: Int,
  acc: String,
) -> Result(#(String, String, String), String) {
  // returns #(number literal, rest, number type <Int, String>)

  case source {
    "1" as c <> rest
    | "2" as c <> rest
    | "3" as c <> rest
    | "4" as c <> rest
    | "5" as c <> rest
    | "6" as c <> rest
    | "7" as c <> rest
    | "8" as c <> rest
    | "9" as c <> rest
    | "0" as c <> rest -> read_number(rest, dot_counter, c <> acc)

    "." <> rest -> read_number(rest, dot_counter + 1, "." <> acc)

    rest ->
      case dot_counter {
        0 -> Ok(#(string.reverse(acc), rest, "int"))
        1 -> Ok(#(string.reverse(acc), rest, "float"))
        _ -> Error("Not a valid number: " <> string.reverse(acc))
      }
  }
}
