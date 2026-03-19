
(* The type of tokens. *)

type token = 
  | WHILE
  | SEMICOLON
  | RPAREN
  | RBRACKET
  | NUM of (int)
  | NAND
  | MINUS
  | LT
  | LPAREN
  | LBRACKET
  | IF
  | IDENT of (string)
  | END
  | ELSE
  | BREAK
  | ASSIGN

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val prog: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (unit AbstractSyntax.tree)
