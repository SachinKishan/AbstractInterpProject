(*abstraction of cartesian domains using a functor*)
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


module type VALUE_DOMAIN = sig
  type t 
  val bot : t
  val top : t
  val leq : t -> t -> bool
  val join : t -> t -> t
  val eval_num : int -> t
  val add : t -> t -> t
  val sub : t -> t -> t
  val lt : t -> t -> bool
  val gt : t -> t -> bool
  val eq : t -> t -> bool
  val neq : t -> t -> bool
  val to_string : t -> string
  val initial : t
  val widen: t -> t -> t
  val narrow: t -> t -> t

  val filter_lt : t -> t -> t * t 
  val filter_gt : t -> t -> t * t
  val filter_eq : t -> t -> t * t
  val filter_neq : t -> t -> t * t
  val filter_geq : t -> t -> t * t  (* x >= y *)
  val filter_leq : t -> t -> t * t  (* x <= y *)
end



module MakeDomain (VD : VALUE_DOMAIN) = struct
  type t = VD.t VariableMap.t
  let bot = VariableMap.empty
  let leq m1 m2 = VariableMap.for_all (fun x v1 ->
    match VariableMap.find_opt x m2 with
    | Some v2 -> VD.leq v1 v2
    | None -> false
    ) m1


    let lookup x p =
  match VariableMap.find_opt x p with
  | Some v -> v
  | None -> VD.top

let update x v p =
  VariableMap.add x v p

let is_bot p = VariableMap.exists (fun _ v -> VD.leq v VD.bot && VD.leq VD.bot v) p

  let leq m1 m2 = 
    if VariableMap.is_empty m2 && not (VariableMap.is_empty m1) then false
    else VariableMap.for_all (fun x v1 ->
        match VariableMap.find_opt x m2 with
        | Some v2 -> VD.leq v1 v2
        | None -> VD.leq v1 VD.top
        ) m1

  let join m1 m2 = VariableMap.merge (fun _ v1 v2 ->
      match (v1, v2) with
      | (Some a, Some b) -> Some (VD.join a b)
      | (Some a, None) -> Some a
      | (None, Some b) -> Some b
      | (None, None) -> None) m1 m2

  

  let initialP l = let rec of_list lt = match lt with
                    | [] -> VariableMap.empty
                    | x::lt' -> VariableMap.add x VD.initial (of_list lt')
                 in of_list l
  
  let rec evala a r = match a with
    | Num i -> VD.eval_num i
    | Var x -> (match VariableMap.find_opt (Variable.varofstring x) r with
        | Some v -> v
        | None -> VD.top)
    | Plus (a1,a2) -> VD.add (evala a1 r) (evala a2 r)
    | Minus (a1,a2) -> VD.sub (evala a1 r) (evala a2 r)
  let assign x a p =
      let assignenvironment r = 
         (let assignvalue y v = if (y=x) then (evala a r) else v 
             in VariableMap.mapi assignvalue r)
      in assignenvironment p

  let rec evalb b r = match b with 
    | Lt (a1,a2) -> VD.lt (evala a1 r) (evala a2 r)
    | Eq (a1,a2) -> VD.eq (evala a1 r) (evala a2 r)
    | Neq (a1,a2) -> VD.neq (evala a1 r) (evala a2 r)
    | Gt (a1,a2) -> VD.gt (evala a1 r) (evala a2 r)
    | Nand (b1,b2) -> (not (evalb b1 r) && (evalb b2 r))

  let widen m1 m2 = VariableMap.merge (fun _ v1 v2 ->
    match (v1, v2) with
    | (Some a, Some b) -> Some (VD.widen a b)
    | (Some a, None) -> Some a
    | (None, Some b) -> Some b
    | (None, None) -> None) m1 m2

  let narrow m1 m2 = VariableMap.merge (fun _ v1 v2 ->
    match (v1, v2) with
    | (Some a, Some b) -> Some (VD.narrow a b)
    | (Some a, None) -> Some a
    | (None, Some b) -> Some b
    | (None, None) -> None) m1 m2

   (* let test b p = if evalb b p then p else bot *)

   (* let nottest b p = if not (evalb b p) then p else bot *) 

   let test b p = 
    match b with
    | Lt (Var x, Var y) ->
      let vx = lookup x p and vy = lookup y p in
      let vx', vy' = VD.filter_lt vx vy in
      VariableMap.add x vx' (VariableMap.add y vy' p)
    | Lt (Var x, Num n) ->
      let vx = lookup x p in
      let vx', _ = VD.filter_lt vx (VD.eval_num n) in
      VariableMap.add x vx' p
    | Gt (Var x, Var y) ->
      let vx = lookup x p and vy = lookup y p in
      let vx', vy' = VD.filter_gt vx vy in
      VariableMap.add x vx' (VariableMap.add y vy' p)
    | Gt (Var x, Num n) ->
      let vx = lookup x p in
      let vx', _ = VD.filter_gt vx (VD.eval_num n) in
      VariableMap.add x vx' p
    | Eq (Var x, Var y) ->
      let vx = lookup x p and vy = lookup y p in
      let vx', vy' = VD.filter_eq vx vy in
      VariableMap.add x vx' (VariableMap.add y vy' p)
    | Neq (Var x, Var y) ->
      let vx = lookup x p and vy = lookup y p in
      let vx', vy' = VD.filter_neq vx vy in
      VariableMap.add x vx' (VariableMap.add y vy' p)
    | _ -> if evalb b p then p else bot

  let nottest b p = match b with
  | Lt (Var x, Var y) ->
      let vx = lookup x p and vy = lookup y p in
      let vx', vy' = VD.filter_geq vx vy in  (* x >= y *)
      VariableMap.add x vx' (VariableMap.add y vy' p)
  | Gt (Var x, Var y) ->
      let vx = lookup x p and vy = lookup y p in
      let vx', vy' = VD.filter_leq vx vy in  (* x <= y *)
      VariableMap.add x vx' (VariableMap.add y vy' p)
  | _ -> if not (evalb b p) then p else bot

  
  
   let stringofaP p = 
           let stringofbinding x v s = "("^x^"="^(VD.to_string v)^")"^s in 
           "{"^(VariableMap.fold stringofbinding p "")^"}"

   
end
