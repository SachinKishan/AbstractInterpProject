(* file abstractDomain.mli  © P. Cousot 2021 *)

open AbstractSyntaxExpressions

module AbstractProperty : sig
    type t
    val leq : t -> t -> bool
    val bot : t
    val join :  t -> t -> t
    val initialP : variable list -> t
    val assign : variable -> aexpr -> t -> t
    val test : bexpr -> t -> t
    val nottest : bexpr -> t -> t
    val stringofaP : t -> string
end
