import gleam/list
import gleeunit
import gleeunit/should
import shimmy/lexer
import shimmy/token

pub fn main() {
  gleeunit.main()
}

pub fn lexer_test() {
  let source =
    "( ) [ ] { } + - * / < > <= >= % +. -. *. /. <. >. <=. >=. <> : , # ! = == != | || && << >> |> . -> <- .. @ 42 3.14 \"asd\" lower_word UpperWord _discard_word"
  let tokens = lexer.lex(source)
  let expected = [
    token.LeftParen,
    token.RightParen,
    token.LeftSquare,
    token.RightSquare,
    token.LeftBrace,
    token.RightBrace,
    token.Plus,
    token.Minus,
    token.Star,
    token.Slash,
    token.Less,
    token.Greater,
    token.LessEqual,
    token.GreaterEqual,
    token.Percent,
    token.PlusDot,
    token.MinusDot,
    token.StarDot,
    token.SlashDot,
    token.LessDot,
    token.GreaterDot,
    token.LessEqualDot,
    token.GreaterEqualDot,
    token.LtGt,
    token.Colon,
    token.Comma,
    token.Hash,
    token.Bang,
    token.Equal,
    token.EqualEqual,
    token.NotEqual,
    token.Vbar,
    token.VbarVbar,
    token.AmperAmper,
    token.LtLt,
    token.GtGt,
    token.Pipe,
    token.Dot,
    token.RArrow,
    token.LArrow,
    token.DotDot,
    token.At,
    token.Int("42"),
    token.Float("3.14"),
    token.String("asd"),
    token.Name("lower_word"),
    token.UpName("UpperWord"),
    token.DiscardName("_discard_word"),
    token.EndOfFile,
  ]

  case tokens {
    Ok(tokens) -> {
      should.equal(list.length(tokens), list.length(expected))
      let pairs = list.zip(tokens, expected)
      list.map(pairs, fn(pair) {
        case pair {
          #(tok, exp) -> should.equal(tok, exp)
        }
      })
    }
    Error(msg) -> panic as msg
  }
}

pub fn keyword_test() {
  let source =
    "as assert auto case const delegate derive echo else fn if implement import let macro opaque panic pub test todo type use"
  let tokens = lexer.lex(source)
  let expected = [
    token.As,
    token.Assert,
    token.Auto,
    token.Case,
    token.Const,
    token.Delegate,
    token.Derive,
    token.Echo,
    token.Else,
    token.Fn,
    token.If,
    token.Implement,
    token.Import,
    token.Let,
    token.Macro,
    token.Opaque,
    token.Panic,
    token.Pub,
    token.Test,
    token.Todo,
    token.Type,
    token.Use,
    token.EndOfFile,
  ]

  case tokens {
    Ok(tokens) -> {
      should.equal(list.length(tokens), list.length(expected))
      let pairs = list.zip(tokens, expected)
      list.map(pairs, fn(pair) {
        case pair {
          #(tok, exp) -> should.equal(tok, exp)
        }
      })
    }
    Error(msg) -> panic as msg
  }
}

pub fn error_lexer_test() {
  let source = "§"
  source |> lexer.lex |> should.equal(Error("Unexpected char: §"))

  let source = "3.14.15"
  source |> lexer.lex |> should.equal(Error("Not a valid number: 3.14.15"))

  let source = "\"almafa"
  source |> lexer.lex |> should.equal(Error("Unterminated string literal"))
}
