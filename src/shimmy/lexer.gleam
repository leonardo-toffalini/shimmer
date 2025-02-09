import gleam/dict
import gleam/list
import gleam/result
import gleam/string
import shimmy/token.{type Token}

pub fn lex(source: String) -> Result(List(Token), String) {
  do_lex(source, [])
}

fn do_lex(source: String, acc: List(Token)) -> Result(List(Token), String) {
  case source {
    "" -> [token.EndOfFile, ..acc] |> list.reverse |> Ok

    // whitespace
    " " <> rest | "\t" <> rest | "\n" <> rest | "\r" <> rest ->
      do_lex(rest, acc)

    // comments
    "////" <> rest -> {
      let #(comment, rest) = read_comment(rest, "")
      do_lex(rest, [token.CommentModule(comment), ..acc])
    }
    "///" <> rest -> {
      let #(comment, rest) = read_comment(rest, "")
      do_lex(rest, [token.CommentDoc(comment), ..acc])
    }
    "//" <> rest -> {
      let #(comment, rest) = read_comment(rest, "")
      do_lex(rest, [token.CommentNormal(comment), ..acc])
    }

    // 3 char tokens
    "<=." <> rest -> do_lex(rest, [token.LessEqualDot, ..acc])
    ">=." <> rest -> do_lex(rest, [token.GreaterEqualDot, ..acc])

    // 2 char tokens
    "<>" <> rest -> do_lex(rest, [token.LtGt, ..acc])
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

    "\"" <> rest -> {
      use #(lit, rest) <- result.try(read_string(rest, ""))
      do_lex(rest, [token.String(lit), ..acc])
    }

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

    // _discard_name
    "_" <> rest -> {
      use #(lit, rest) <- result.try(read_name(rest, ""))
      do_lex(rest, [token.DiscardName("_" <> lit), ..acc])
    }

    // lower_name
    "a" as c <> rest
    | "b" as c <> rest
    | "c" as c <> rest
    | "d" as c <> rest
    | "e" as c <> rest
    | "f" as c <> rest
    | "g" as c <> rest
    | "h" as c <> rest
    | "i" as c <> rest
    | "j" as c <> rest
    | "k" as c <> rest
    | "l" as c <> rest
    | "m" as c <> rest
    | "n" as c <> rest
    | "o" as c <> rest
    | "p" as c <> rest
    | "q" as c <> rest
    | "r" as c <> rest
    | "s" as c <> rest
    | "t" as c <> rest
    | "u" as c <> rest
    | "v" as c <> rest
    | "w" as c <> rest
    | "x" as c <> rest
    | "y" as c <> rest
    | "z" as c <> rest -> {
      use #(lit, rest) <- result.try(read_name(c <> rest, ""))
      case lookup_keyword(lit) {
        Ok(kw) -> do_lex(rest, [kw, ..acc])
        Error(Nil) -> do_lex(rest, [token.Name(lit), ..acc])
      }
    }

    // UpperName
    "A" as c <> rest
    | "B" as c <> rest
    | "C" as c <> rest
    | "D" as c <> rest
    | "E" as c <> rest
    | "F" as c <> rest
    | "G" as c <> rest
    | "H" as c <> rest
    | "I" as c <> rest
    | "J" as c <> rest
    | "K" as c <> rest
    | "L" as c <> rest
    | "M" as c <> rest
    | "N" as c <> rest
    | "O" as c <> rest
    | "P" as c <> rest
    | "Q" as c <> rest
    | "R" as c <> rest
    | "S" as c <> rest
    | "T" as c <> rest
    | "U" as c <> rest
    | "V" as c <> rest
    | "W" as c <> rest
    | "X" as c <> rest
    | "Y" as c <> rest
    | "Z" as c <> rest -> {
      use #(lit, rest) <- result.try(read_up_name(c <> rest, ""))
      do_lex(rest, [token.UpName(lit), ..acc])
    }

    c -> Error("Unexpected char: " <> c)
  }
}

/// returns #(number literal, rest, number type <Int, String>)
fn read_number(
  source: String,
  dot_counter: Int,
  acc: String,
) -> Result(#(String, String, String), String) {
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
    | "0" as c <> rest -> read_number(rest, dot_counter, acc <> c)

    "." <> rest -> read_number(rest, dot_counter + 1, acc <> ".")

    rest ->
      case dot_counter {
        0 -> Ok(#(acc, rest, "int"))
        1 -> Ok(#(acc, rest, "float"))
        _ -> Error("Not a valid number: " <> acc)
      }
  }
}

fn read_string(source: String, acc: String) -> Result(#(String, String), String) {
  case source {
    "\"" <> rest -> Ok(#(string.reverse(acc), rest))
    _ -> {
      case string.pop_grapheme(source) {
        Ok(#(first, rest)) -> read_string(rest, first <> acc)
        Error(Nil) -> Error("Unterminated string literal")
      }
    }
  }
}

fn read_name(source: String, acc: String) -> Result(#(String, String), String) {
  case source {
    "a" as c <> rest
    | "b" as c <> rest
    | "c" as c <> rest
    | "d" as c <> rest
    | "e" as c <> rest
    | "f" as c <> rest
    | "g" as c <> rest
    | "h" as c <> rest
    | "i" as c <> rest
    | "j" as c <> rest
    | "k" as c <> rest
    | "l" as c <> rest
    | "m" as c <> rest
    | "n" as c <> rest
    | "o" as c <> rest
    | "p" as c <> rest
    | "q" as c <> rest
    | "r" as c <> rest
    | "s" as c <> rest
    | "t" as c <> rest
    | "u" as c <> rest
    | "v" as c <> rest
    | "w" as c <> rest
    | "x" as c <> rest
    | "y" as c <> rest
    | "z" as c <> rest
    | "_" as c <> rest -> read_name(rest, acc <> c)

    _ -> Ok(#(acc, source))
  }
}

fn read_up_name(
  source: String,
  acc: String,
) -> Result(#(String, String), String) {
  case source {
    "A" as c <> rest
    | "B" as c <> rest
    | "C" as c <> rest
    | "D" as c <> rest
    | "E" as c <> rest
    | "F" as c <> rest
    | "G" as c <> rest
    | "H" as c <> rest
    | "I" as c <> rest
    | "J" as c <> rest
    | "K" as c <> rest
    | "L" as c <> rest
    | "M" as c <> rest
    | "N" as c <> rest
    | "O" as c <> rest
    | "P" as c <> rest
    | "Q" as c <> rest
    | "R" as c <> rest
    | "S" as c <> rest
    | "T" as c <> rest
    | "U" as c <> rest
    | "V" as c <> rest
    | "W" as c <> rest
    | "X" as c <> rest
    | "Y" as c <> rest
    | "Z" as c <> rest
    | "a" as c <> rest
    | "b" as c <> rest
    | "c" as c <> rest
    | "d" as c <> rest
    | "e" as c <> rest
    | "f" as c <> rest
    | "g" as c <> rest
    | "h" as c <> rest
    | "i" as c <> rest
    | "j" as c <> rest
    | "k" as c <> rest
    | "l" as c <> rest
    | "m" as c <> rest
    | "n" as c <> rest
    | "o" as c <> rest
    | "p" as c <> rest
    | "q" as c <> rest
    | "r" as c <> rest
    | "s" as c <> rest
    | "t" as c <> rest
    | "u" as c <> rest
    | "v" as c <> rest
    | "w" as c <> rest
    | "x" as c <> rest
    | "y" as c <> rest
    | "z" as c <> rest -> read_up_name(rest, acc <> c)

    _ -> Ok(#(acc, source))
  }
}

fn lookup_keyword(name: String) -> Result(Token, Nil) {
  let keywords =
    dict.from_list([
      #("as", token.As),
      #("assert", token.Assert),
      #("auto", token.Auto),
      #("case", token.Case),
      #("const", token.Const),
      #("delegate", token.Delegate),
      #("derive", token.Derive),
      #("echo", token.Echo),
      #("else", token.Else),
      #("fn", token.Fn),
      #("if", token.If),
      #("implement", token.Implement),
      #("import", token.Import),
      #("let", token.Let),
      #("macro", token.Macro),
      #("opaque", token.Opaque),
      #("panic", token.Panic),
      #("pub", token.Pub),
      #("test", token.Test),
      #("todo", token.Todo),
      #("type", token.Type),
      #("use", token.Use),
    ])

  dict.get(keywords, name)
}

fn read_comment(source: String, acc: String) -> #(String, String) {
  case source {
    "\n" <> rest | "\r\n" <> rest -> #(acc, rest)
    _ ->
      case string.pop_grapheme(source) {
        Ok(#(first, rest)) -> read_comment(rest, acc <> first)
        Error(Nil) -> #(acc, "")
      }
  }
}
