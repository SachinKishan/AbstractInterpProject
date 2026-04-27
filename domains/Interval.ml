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



let interval_lt i1 i2= 
    match (i1,i2) with
    | (_,Bottom) -> false
    | (Bottom,_) -> false
    |  (Interval(a1,b1),Interval(a2,b2)) -> (compare_bounds b1 a2) < 0
 
let interval_gt i1 i2= 
    match (i1,i2) with
    | (_,Bottom) -> false
    | (Bottom,_) -> false
    |  (Interval(a1,b1),Interval(a2,b2)) -> (compare_bounds a1 b2) > 0

let interval_eq i1 i2= 
    match (i1,i2) with
    | (_,Bottom) -> false
    | (Bottom,_) -> false
    |  (Interval(a1,b1),Interval(a2,b2)) -> (compare_bounds a1 a2) = 0 && (compare_bounds b1 b2) = 0
 
let interval_neq i1 i2 = interval_lt i1 i2 || interval_gt i1 i2

let string_of_bound b = match b with
        | Neg_infinity -> "-inf"
        | Pos_infinity -> "+inf"
        | Int i -> string_of_int i

let string_of_interval i = match i with
        | Bottom -> "Bot"
        | Interval(a, b) -> 
            "[" ^ string_of_bound a ^ "," ^ string_of_bound b ^ "]"

module Interval_domain = struct
   type t = interval VariableMap.t   
   let leq = leq_interval
   let add = add_interval
   let sub = sub_interval
   let lt = sign_lt
   let gt = interval_gt
   let eq = interval_eq
   let neq = interval_neq
   let to_string = string_of_interval
   let initial = Interval(Int 0, Int 0)
   let bot = VariableMap.empty
   let top = top_interval
   let join = join_interval
   let eval_num x = Interval(Int x,Int x)

end