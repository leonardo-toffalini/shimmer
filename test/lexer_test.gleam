import gleam/list
import gleeunit
import gleeunit/should
import lexer
import token

pub fn main() {
  gleeunit.main()
}

pub fn lexer_test() {
  let source =
    "( ) [ ] { } + - * / < > <= >= % +. -. *. /. <. >. <=. >=. <> : , # ! = == != | || && << >> |> . -> <- .. @"
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
