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

let top_interval = Interval(Neg_infinity, Pos_infinity)

let bound_numerical_order b= 
    match b with
        | Neg_infinity -> -1000000
        | Int i  -> i
        | Pos_infinity -> 10000000

(* this is made for map/set operations, not lattice *)
let compare_bounds b1 b2=
    match (b1,b2) with
        | (Neg_infinity,Neg_infinity) -> 0
        | (Pos_infinity,Pos_infinity) -> 0
        | (Neg_infinity,_) -> -1
        | (_,Pos_infinity) -> 1
        | (Int x,Int y) -> compare x y

(* meant for lattice operations, is a property used in AbstractProperty *)
let leq_bounds b1 b2=
    match (b1,b2) with
        | (Neg_infinity,Neg_infinity) -> true
        | (Pos_infinity,Pos_infinity) -> true
        | (Pos_infinity, _) -> false
        | (Neg_infinity,_) -> true
        | (_,Pos_infinity) -> true
        | (Int x,Int y) -> x <= y

let min_bound b1 b2 = 
    match leq_bounds b1 b2 with
        | true -> b1
        | false ->b2


let max_bound b1 b2 = 
    match leq_bounds b1 b2 with
        | false -> b1
        | true ->b2 

let leq_interval i1 i2= 
        match (i1,i2) with
        |   (Bottom,Bottom) -> true
        |   (Bottom,_) -> true
        |   (_,Bottom) -> false
        |   (Interval(b1,b2) , Interval(b3,b4)) -> leq_bounds b3 b1 && leq_bounds b2 b4
        
let join_interval i1 i2 = 
        match (i1,i2) with
            | ( Interval (a1,b1) , Interval(a2,b2) ) -> 
                Interval(min_bound a1 a2 , max_bound b1 b2)
            | (i1,Bottom) -> i1
            | (Bottom,i2) -> i2     
            
let add_bound b1 b2 = 
    match (b1,b2) with 
        | (Neg_infinity,_) -> Neg_infinity
        | (_,Neg_infinity) -> Neg_infinity
        | (Pos_infinity,_) -> Pos_infinity
        | (_,Pos_infinity) -> Pos_infinity
        | (Int i, Int j) -> Int(i+j)

let sub_bound b1 b2 =
    match (b1,b2) with
        | (Neg_infinity, Pos_infinity) -> Neg_infinity
        | (Pos_infinity, Neg_infinity) -> Pos_infinity
        | (Neg_infinity, Neg_infinity) -> failwith "undefined: -infinity - -infinity"
        | (Pos_infinity, Pos_infinity) -> failwith "undefined: +infinity - +infinity"
        | (Neg_infinity, Int j) -> Neg_infinity
        | (Pos_infinity, Int j) -> Pos_infinity
        | (Int i, Neg_infinity) -> Pos_infinity
        | (Int i, Pos_infinity) -> Neg_infinity
        | (Int i, Int j) -> Int(i-j)


module AbstractProperty = struct
   type t = interval VariableMap.t

    (* env operations *)

    let join m1 m2= VariableMap.merge 
    (fun _ i1 i2 ->
        match (i1, i2) with
            | (Some i1, Some i2) -> Some (join_interval i1 i2)
            | (Some i1, None)    -> Some i1          
            | (None, Some i2)    -> Some i2          
            | (None, None)       -> None             
    ) m1 m2

   let leq m1 m2= VariableMap.for_all (fun x i1 -> 
        let i2 = VariableMap.find x m2 in
            leq_interval i1 i2
    ) m1
   
   let bot = VariableMap.empty
   

   let initialP l = let rec of_list lt = match lt with
                    | [] -> VariableMap.empty
                    | x::lt' -> VariableMap.add x (Interval(Neg_infinity,Pos_infinity)) (of_list lt')
                 in of_list l

   (* interval arithmetic *)

   let add_interval i1 i2=    
       match (i1,i2) with
            | (_,Bottom) -> Bottom
            | (Bottom, _ ) -> Bottom
            | (Interval(a1,b1),Interval(a2,b2)) -> Interval(add_bound a1 a2,add_bound b1 b2)


    let sub_interval i1 i2 = 
        match (i1,i2) with
            | (_,Bottom) -> Bottom
            | (Bottom, _ ) -> Bottom
            | (Interval(a1,b1),Interval(a2,b2)) -> Interval(sub_bound a1 b2,sub_bound b1 a2)

   (* returns a bound given a integer after we evaluate an arithmetic expression *)
   let rec evala a r = match a with
    | Num i -> Interval(Int i,Int i)
    | Var x -> VariableMap.find (Variable.varofstring x) r
    | Minus (a1,a2) -> sub_interval (evala a1 r) (evala a2 r)
    | Plus (a1,a2) -> add_interval (evala a1 r) (evala a2 r)

   let assign x a p =
      let assignenvironment r = 
         (let assignvalue y v = if (y=x) then (evala a r) else v 
             in VariableMap.mapi assignvalue r)
      in assignenvironment p

   (* interval boolean *)
   
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