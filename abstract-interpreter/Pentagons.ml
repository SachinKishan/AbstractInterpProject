open AbstractSyntaxExpressions
open CartesianDomain
open Interval
open Upper_bound


module type INTERVAL_DOMAIN = sig
  include VALUE_DOMAIN
  val sup : t -> int option
  val inf : t -> int option

end

module MakePentagon (VD : INTERVAL_DOMAIN) = struct
  module VariableMap = CartesianDomain.VariableMap
  module ID = MakeDomain(VD)
  module UB = Upper_bound.AbstractProperty

  type t = {
    intervals : ID.t;
    upper_bounds : UB.t
  }

let lookup x b = 
  match CartesianDomain.VariableMap.find_opt x b with
  | Some v -> v
  | None -> VD.top
  

  let bot = { intervals = ID.bot; upper_bounds = UB.bot }

let top = VariableMap.empty

  let is_bot p = 
  ID.leq p.intervals ID.bot || 
  (UB.leq p.upper_bounds UB.bot && UB.leq UB.bot p.upper_bounds)


  let initialP vars = 
  { 
    intervals = ID.initialP vars; 
    upper_bounds = UB.initialP vars 
  }

  let reduce intervals upper_bounds =
  VariableMap.fold (fun x _ acc ->
    VariableMap.fold (fun y _ acc ->
      if x <> y then
        match VD.sup (lookup x intervals),
              VD.inf (lookup y intervals) with
        | Some sx, Some iy -> 
            if sx < iy then
              let current = match VariableMap.find_opt x acc with
                            | Some ys -> ys
                            | None -> [] in
              if List.mem y current then acc
              else VariableMap.add x (y :: current) acc
            else acc
        | _ -> acc
      else acc
    ) intervals acc
  ) intervals upper_bounds

  let leq p1 p2 =
  ID.leq p1.intervals p2.intervals
  &&
  VariableMap.for_all (fun x ys2 ->
    List.for_all (fun y ->
      (match VariableMap.find_opt x p1.upper_bounds with
       | Some ys1 -> List.mem y ys1
       | None -> false)
      ||
      (match VD.sup (lookup x p1.intervals), 
             VD.inf (lookup y p1.intervals) with
       | Some sx, Some iy -> sx < iy
       | _ -> false)
    ) ys2
  ) p2.upper_bounds

  let join p1 p2 = 
  let bt = ID.join p1.intervals p2.intervals in
  let s' x = 
    let ys1 = match VariableMap.find_opt x p1.upper_bounds with Some ys -> ys | None -> [] in
    let ys2 = match VariableMap.find_opt x p2.upper_bounds with Some ys -> ys | None -> [] in
    List.filter (fun y -> List.mem y ys2) ys1 in
  let s'' x =
  let s1x = match VariableMap.find_opt x p1.upper_bounds with
             | Some ys -> ys
             | None -> [] in
  List.filter (fun y ->
    match VD.sup (lookup x p2.intervals),
          VD.inf (lookup y p2.intervals) with
    | Some sx, Some iy -> sx < iy
    | _ -> false) s1x in
  let s''' x =
  let s2x = match VariableMap.find_opt x p2.upper_bounds with
             | Some ys -> ys
             | None -> [] in
  List.filter (fun y ->
    match VD.sup (lookup x p1.intervals),
          VD.inf (lookup y p1.intervals) with
    | Some sx, Some iy -> sx < iy
    | _ -> false) s2x in
  let all_vars = 
    let vars1 = VariableMap.fold (fun x _ acc -> x :: acc) p1.upper_bounds [] in
    let vars2 = VariableMap.fold (fun x _ acc -> x :: acc) p2.upper_bounds [] in
  List.sort_uniq compare (vars1 @ vars2) in
  let st = List.fold_left (fun acc x ->
    let combined = List.sort_uniq compare (s' x @ s'' x @ s''' x) in
    if combined = [] then acc
    else VariableMap.add x combined acc
  ) VariableMap.empty all_vars in
  { intervals = bt; upper_bounds = st }
  
  (* let meet p1 p2 = { intervals = ID.meet p1.intervals p2.intervals; upper_bounds = UB.meet p1.upper_bounds p2.upper_bounds } *)
  let meet p1 p2 = bot
  let widen p1 p2 = { intervals = ID.widen p1.intervals p2.intervals; upper_bounds = UB.widen p1.upper_bounds p2.upper_bounds }
  let narrow p1 p2 = { intervals = ID.narrow p1.intervals p2.intervals; upper_bounds = UB.narrow p1.upper_bounds p2.upper_bounds }


  let assign x a p =
  if is_bot p then bot
  else
      let intervals' = ID.assign x a p.intervals in
      let upper_bounds' = UB.assign x a p.upper_bounds in
      { intervals = intervals'; upper_bounds = reduce intervals' upper_bounds' }

  let test b p =
  let intervals' = ID.test b p.intervals in
  let upper_bounds' = UB.test b p.upper_bounds in
  { intervals = intervals'; upper_bounds = reduce intervals' upper_bounds' }

  let nottest b p =
  let intervals' = ID.nottest b p.intervals in
  let upper_bounds' = UB.nottest b p.upper_bounds in
  { intervals = intervals'; upper_bounds = reduce intervals' upper_bounds' }

  let stringofaP p =
  ID.stringofaP p.intervals ^ " " ^ UB.stringofaP p.upper_bounds


end

