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

type bound =
    | Neg_infinity
    | Pos_infinity 
    | Int of int 

type interval = 
    | Bottom
    | Interval of bound * bound

let bound_numerical_order b= 
    match b with
        | Neg_infinity -> -1000000
        | Int i  -> i
        | Pos_infinity -> 10000000

let compare_bounds b1 b2=
    match (b1,b2) with
        | (Neg_infinity,Neg_infinity) -> 0
        | (Pos_infinity,Pos_infinity) -> 0
        | (Neg_infinity,_) -> -1
        | (_,Pos_infinity) -> 1
        | (Int x,Int y) -> compare x y
            

let compare_intervals i1 i2 =
  match (i1, i2) with
  | (Bottom, Bottom) -> 0
  | (Bottom, _) -> -1
  | (_, Bottom) -> 1
  | (Interval (l1, u1), Interval (l2, u2)) ->
      (match compare_bounds l1 l2 with
      | 0 -> compare_bounds u1 u2
      | x -> x)

module Environment = struct
  type t = interval VariableMap.t
  let compare = VariableMap.compare compare_intervals
end
module SetOfEnvironments = Set.Make(Environment)



(* WE MUST REWRITE ABSTRACT PROPERTY HERE TO ALLOW FOR NOT A SET OF ENV BUT Boxes = [Vars → Intv] *)


module AbstractProperty = struct
   type t = SetOfEnvironments.t
   let leq = SetOfEnvironments.subset
   let bot = SetOfEnvironments.empty
   let join = SetOfEnvironments.union
   let initialP l = let rec of_list lt = match lt with
                    | [] -> VariableMap.empty
                    | x::lt' -> VariableMap.add x (Interval(Neg_infinity,Pos_infinity)) (of_list lt')
                 in SetOfEnvironments.singleton (of_list l)
   
   let interval_plus b1 b2 = 
   match (b1,b2) with 

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

   (* returns a bound given a integer after we evaluate an arithmetic expression *)
   let rec evala a r = match a with
    | Num i -> interval(i,i)
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