open AbstractSyntaxExpressions

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

let compare_bounds b1 b2 =
  match b1, b2 with
  | Neg_infinity, Neg_infinity
  | Pos_infinity, Pos_infinity -> 0
  | Neg_infinity, _ -> -1
  | _, Neg_infinity -> 1
  | Pos_infinity, _ -> 1
  | _, Pos_infinity -> -1
  | Int x, Int y -> compare x y

(* meant for lattice operations, is a property used in AbstractProperty *)

let div_bound b1 b2 = match b1, b2 with
  | _, Int 0 -> Pos_infinity  (* division by zero = top *)
  | Neg_infinity, Int n -> if n > 0 then Neg_infinity else Pos_infinity
  | Pos_infinity, Int n -> if n > 0 then Pos_infinity else Neg_infinity
  | Int n, Pos_infinity -> Int 0
  | Int n, Neg_infinity -> Int 0
  | Int n, Int m -> Int (n / m)
  | Neg_infinity, Pos_infinity -> Neg_infinity
  | Neg_infinity, Neg_infinity -> Pos_infinity
  | Pos_infinity, Pos_infinity -> Pos_infinity
  | Pos_infinity, Neg_infinity -> Neg_infinity
  
let leq_bounds b1 b2=
    match (b1,b2) with
        | (Neg_infinity,Neg_infinity) -> true
        | (Pos_infinity,Pos_infinity) -> true
        | (Pos_infinity, _) -> false
        | (Neg_infinity,_) -> true
        | (_,Pos_infinity) -> true
        | (_,Neg_infinity) -> false
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

let interval_widen i1 i2 =
    match (i1, i2) with
    | (Bottom, _) -> i2
    | (_, Bottom) -> i1
    | (Interval(a1,b1), Interval(a2,b2)) ->
        let a = if a2 < a1 then Neg_infinity else a1 in
        let b = if b2 > b1 then Pos_infinity else b1 in
        Interval(a, b)

let interval_narrow i1 i2 = 
    match (i1,i2) with 
    | (Bottom, _) -> Bottom
    | (_, Bottom) -> Bottom
    | (Interval(a1,b1), Interval(a2,b2)) -> 
        let a = if a1 = Neg_infinity then a2 else a1 in
        let b = if b1 = Pos_infinity then b2 else b1 in
        Interval (a,b)

let interval_meet i1 i2 = 
  match (i1, i2) with 
  | (Bottom, _) -> Bottom
  | (_, Bottom) -> Bottom
  | (Interval(a1, b1), Interval(a2, b2)) -> 
      let a = max_bound a1 a2 in
      let b = min_bound b1 b2 in
      if a > b then Bottom
      else Interval(a, b)
 
module Interval_domain = struct
   type t = interval 
   let leq = leq_interval
   let add = add_interval
   let sub = sub_interval
   let lt = interval_lt
   let gt = interval_gt
   let eq = interval_eq
   let neq = interval_neq
   let to_string = string_of_interval
   let initial = Interval(Int 0, Int 0) 
   (* let initial = Interval (Neg_infinity,Pos_infinity) *)
   let bot = Bottom
   let top = top_interval
   let join = join_interval
   let eval_num x = Interval(Int x,Int x)
   let widen = interval_widen
   let narrow = interval_narrow

   let div i1 i2 = match i1, i2 with
  | Bottom, _ | _, Bottom -> Bottom
  | Interval(a1, b1), Interval(a2, b2) ->
      (* if divisor contains 0, return top *)
      if leq_bounds a2 (Int 0) && leq_bounds (Int 0) b2 then
        Interval(Neg_infinity, Pos_infinity)
      else
        (* safe to divide *)
        let results = [
          div_bound a1 a2; div_bound a1 b2;
          div_bound b1 a2; div_bound b1 b2
        ] in
        Interval(List.fold_left min_bound Pos_infinity results,
                 List.fold_left max_bound Neg_infinity results)

  let sup i = match i with
  | Bottom -> None
  | Interval(_, Pos_infinity) -> None
  | Interval(_, Neg_infinity) -> None  
  | Interval(_, Int b) -> Some b

let inf i = match i with
  | Bottom -> None
  | Interval(Neg_infinity, _) -> None
  | Interval(Pos_infinity, _) -> None 
  | Interval(Int a, _) -> Some a

let filter_lt i1 i2 = match i1, i2 with
  | Bottom, _ | _, Bottom -> (Bottom, Bottom)
  | Interval(a1, b1), Interval(a2, b2) ->
      (* x < y: cap x's upper bound at sup(y)-1, cap y's lower bound at inf(x)+1 *)
      let b1' = match sup i2 with
                | Some n -> min_bound b1 (Int (n-1))
                | None -> b1 in
      let a2' = match inf i1 with
                | Some n -> max_bound a2 (Int (n+1))
                | None -> a2 in
      let i1' = if b1' < a1 then Bottom else Interval(a1, b1') in
      let i2' = if b2 < a2' then Bottom else Interval(a2', b2) in
      (i1', i2')


let filter_eq i1 i2 =
  let i' = interval_meet i1 i2 in
  (i', i')

let filter_neq i1 i2 =
  match i1, i2 with
  | Bottom, _ | _, Bottom -> (Bottom, Bottom)
  | _ ->
      let meet = interval_meet i1 i2 in
      if meet = i1 && meet = i2 then (Bottom, Bottom)
      else (i1, i2)  

let filter_gt i1 i2 = match i1, i2 with
  | Bottom, _ | _, Bottom -> (Bottom, Bottom)
  | Interval(a1, b1), Interval(a2, b2) ->
      let a1' = match inf i2 with
                | Some n -> max_bound a1 (Int (n+1))
                | None -> a1 in
      let b2' = match sup i1 with
                | Some n -> min_bound b2 (Int (n-1))
                | None -> b2 in
      let i1' = if a1' > b1 then Bottom else Interval(a1', b1) in
      let i2' = if a2 > b2' then Bottom else Interval(a2, b2') in
      (i1', i2')

let filter_geq i1 i2 = match i1, i2 with
  | Bottom, _ | _, Bottom -> (Bottom, Bottom)
  | Interval(a1, b1), Interval(a2, b2) ->
      let a1' = match inf i2 with
                | Some n -> max_bound a1 (Int n)  (* x >= inf(y) *)
                | None -> a1 in
      let b2' = match sup i1 with
                | Some n -> min_bound b2 (Int n)  (* y <= sup(x) *)
                | None -> b2 in
      let i1' = if a1' > b1 then Bottom else Interval(a1', b1) in
      let i2' = if a2 > b2' then Bottom else Interval(a2, b2') in
      (i1', i2')

let filter_leq i1 i2 = match i1, i2 with
  | Bottom, _ | _, Bottom -> (Bottom, Bottom)
  | Interval(a1, b1), Interval(a2, b2) ->
      (* x < y: cap x's upper bound at sup(y)-1, cap y's lower bound at inf(x)+1 *)
      let b1' = match sup i2 with
                | Some n -> min_bound b1 (Int (n))
                | None -> b1 in
      let a2' = match inf i1 with
                | Some n -> max_bound a2 (Int (n))
                | None -> a2 in
      let i1' = if b1' < a1 then Bottom else Interval(a1, b1') in
      let i2' = if b2 < a2' then Bottom else Interval(a2', b2) in
      (i1', i2')


end

