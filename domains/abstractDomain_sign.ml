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

type sign =
Pos
| Neg
| Zero
| Top
| Bottom

let sign_numerical_order s= 
match s with
Zero -> 0
| Neg -> -1
| Pos -> 1
| Top -> 100
| Bottom -> -100  

module Environment = struct
  type t = sign VariableMap.t
  let compare = 
     let comparesign i j =
        if (sign_numerical_order i) = (sign_numerical_order j) then 0
        else if (sign_numerical_order i) < (sign_numerical_order j) then -1
        else 1 in
        (VariableMap.compare comparesign)
end
module SetOfEnvironments = Set.Make(Environment)

module AbstractProperty = struct
   type t = SetOfEnvironments.t
   let leq = SetOfEnvironments.subset
   let bot = SetOfEnvironments.empty
   let join = SetOfEnvironments.union
   let initialP l = let rec of_list lt = match lt with
                    | [] -> VariableMap.empty
                    | x::lt' -> VariableMap.add x Zero (of_list lt')
                 in SetOfEnvironments.singleton (of_list l)
   
   let sign_plus s1 s2 = 
   match (s1,s2) with
   | (Bottom , _) -> Bottom
   | (_ ,Bottom) -> Bottom
   | (_ ,Top) -> Top
   | (Top,_) -> Top
   | (x,Zero) -> x
   | (Zero,x) -> x
   | (Pos,Pos) -> Pos
   | (Pos,Neg) -> Top
   | (Neg,Neg) -> Neg
   | (Neg,Pos) -> Top

   let sign_minus s1 s2 = 
   match (s1,s2) with
   | (Bottom , _) -> Bottom
   | (_ ,Bottom) -> Bottom
   | (_ ,Top) -> Top
   | (Top,_) -> Top
   | (x,Zero) -> x
   | (Zero,Pos) -> Neg
   | (Zero,Neg) -> Pos
   | (Pos,Pos) -> Top
   | (Pos,Neg) -> Pos
   | (Neg, Pos) -> Neg
   | (Neg, Neg) -> Top

   (* returns a sign after we evaluate an arithmetic expression *)
   let rec evala a r = match a with
    | Num i -> 
        if i > 0 then Pos
        else if i = 0 then Zero
        else Neg
    | Var x -> VariableMap.find (Variable.varofstring x) r
    | Minus (a1,a2) -> sign_minus (evala a1 r) (evala a2 r)
    | Plus (a1,a2) -> sign_plus (evala a1 r) (evala a2 r)

   let assign x a p =
      let assignenvironment r = 
         (let assignvalue y v = if (y=x) then (evala a r) else v 
             in VariableMap.mapi assignvalue r)
      in SetOfEnvironments.map assignenvironment p

   let sign_lt s1 s2= 
    match (s1,s2) with
    |  (Neg,Pos) -> true  
    |  (Zero,Pos) -> true  
    |  (Neg,Zero) -> true  
    |  (_,_) -> false
 
   let sign_gt s1 s2= 
    match (s1,s2) with
    |  (Pos,Neg) -> true  
    |  (Pos,Zero) -> true  
    |  (Zero,Neg) -> true 
    |  (_,_) -> false

   let sign_eq s1 s2= 
    match (s1,s2) with
    | (Zero,Zero) -> true
    |  (Pos,Pos) -> true
    | (Neg,Neg) -> true
    |  (_,_) -> false
 
   let sign_neq s1 s2= 
    match (s1,s2) with
    | (Top,_) -> false
    | (_,Top) -> false
    | (Zero,Zero) -> false
    |  (Pos,Pos) -> false
    | (Neg,Neg) -> false
    |  (_,_) -> true

   let rec evalb b r = match b with 
       | Lt (a1,a2) -> sign_lt (evala a1 r) (evala a2 r) 
       | Eq (a1,a2) -> sign_eq (evala a1 r) (evala a2 r) 
       | Neq (a1,a2) -> sign_neq (evala a1 r) (evala a2 r) 
       | Gt (a1,a2) -> sign_gt (evala a1 r) (evala a2 r) 
       | Nand (b1,b2) -> (not (evalb b1 r) && (evalb b2 r))

   let test b p = SetOfEnvironments.filter (evalb b) p
   let nottest b p = SetOfEnvironments.filter (function r -> not (evalb b r)) p

   let string_of_sign s = match s with
   | Pos -> "Pos"
   | Neg -> "Neg"
   | Zero -> "Zero"
   | Top -> "Top"
   | Bottom -> "Bot"

   let stringofaP p = 
        let stringofenvironment r = 
           let stringofbinding x v s = "("^x^"="^(string_of_sign v)^")"^s in
              VariableMap.fold stringofbinding r ""
        in let rec stringofenvironmentlist l = match l with
               | [] -> ""
               | r::[] -> (stringofenvironment r)
               | r::l' -> (stringofenvironment r)^","^(stringofenvironmentlist l')
           in "{"^(stringofenvironmentlist (SetOfEnvironments.elements p))^"}"
end