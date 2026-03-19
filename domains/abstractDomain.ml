(* file abstractDomain.ml  © P. Cousot 2021 *)

open AbstractSyntaxExpressions

module Variable = struct
  type t = string (* variable *)
  let compare x1 x2 =
    if (x1=x2) then 0
    else if (x1<x2) then -1
    else 1
  let varofstring (x : string) = (x : t)
end
module VariableMap = Map.Make(Variable)

module Environment = struct
  type t = int VariableMap.t
  let compare = 
     let compareint i j =
        if i=j then 0
        else if i<j then -1
        else 1 in
        (VariableMap.compare compareint)
end
module SetOfEnvironments = Set.Make(Environment)

module AbstractProperty = struct
   type t = SetOfEnvironments.t
   let leq = SetOfEnvironments.subset
   let bot = SetOfEnvironments.empty
   let join = SetOfEnvironments.union
   let initialP l = let rec of_list lt = match lt with
                    | [] -> VariableMap.empty
                    | x::lt' -> VariableMap.add x 0 (of_list lt')
                 in SetOfEnvironments.singleton (of_list l)
   let rec evala a r = match a with
       | Num i -> i
       | Var x -> VariableMap.find (Variable.varofstring x) r
       | Minus (a1,a2) -> (evala a1 r) - (evala a2 r)
       | Plus (a1,a2) -> (evala a1 r) + (evala a2 r)
   let assign x a p =
      let assignenvironment r = 
         (let assignvalue y v = if (y=x) then (evala a r) else v 
             in VariableMap.mapi assignvalue r)
      in SetOfEnvironments.map assignenvironment p
    let rec evalb b r = match b with 
       | Lt (a1,a2) -> (evala a1 r) < (evala a2 r)
       | Eq (a1,a2) -> (evala a1 r) = (evala a2 r)
       | Neq (a1,a2) -> (evala a1 r) != (evala a2 r)
       | Gt (a1,a2) -> (evala a1 r) > (evala a2 r)
       | Nand (b1,b2) -> (not (evalb b1 r) && (evalb b2 r)) (* was (not (evalb b1 r)) && (evalb b2 r), thanks Patrick Collins *)
    let test b p = SetOfEnvironments.filter (evalb b) p
    let nottest b p = SetOfEnvironments.filter (function r -> not (evalb b r)) p
    let stringofaP p = 
        let stringofenvironment r = 
           let stringofbinding x v s = "("^x^"="^(string_of_int v)^")"^s in
              VariableMap.fold stringofbinding r ""
        in let rec stringofenvironmentlist l = match l with
               | [] -> ""
               | r::[] -> (stringofenvironment r)
               | r::l' -> (stringofenvironment r)^","^(stringofenvironmentlist l')
           in "{"^(stringofenvironmentlist (SetOfEnvironments.elements p))^"}"
end
