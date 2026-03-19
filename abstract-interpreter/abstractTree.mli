(* file abstractTree.mli © P. Cousot 2021 *)

open AbstractSyntaxExpressions
open AbstractDomain

type 'a tree =
  | Prog of 'a tree list * 'a
  | Assign of variable * aexpr * 'a
  | Emptystmt of 'a
  | If of bexpr * 'a tree * 'a
  | Ifelse of bexpr * 'a tree * 'a tree * 'a
  | While of bexpr * 'a tree * 'a
  | Break of 'a
  | Stmtlist of 'a tree list * 'a (* trees in inverse order *)
type program_label = int
type labelling = program_label * AbstractProperty.t (* at, abstract property *)
               * program_label * AbstractProperty.t (* after, abstract property *)
               * bool * program_label * AbstractProperty.t 
               (* escape, where to break, abstract property when breaking *)
type labelled_tree = labelling tree (* with labeling attributes *)
