open AbstractSyntaxExpressions
open CartesianDomain

(* module VariableMap = Map.Make(String) *)
module VariableMap = CartesianDomain.VariableMap


module AbstractProperty = struct
  type t = (variable list) VariableMap.t
  
  let bot = VariableMap.add "__bot__" ["__bot__"] VariableMap.empty
  
  let is_bot s = 
  let result = VariableMap.exists (fun x ys -> 
    List.exists (fun y ->
      match VariableMap.find_opt y s with
      | Some zs -> List.mem x zs
      | None -> false) ys) s in result
  
  let leq s1 s2 =
    if is_bot s1 then true
    else if is_bot s2 then false
    else
      VariableMap.for_all (fun x ys2 ->
        match VariableMap.find_opt x s1 with
        | Some ys1 -> List.for_all (fun y -> List.mem y ys1) ys2
        | None -> ys2 = []) s2

  let meet s1 s2 =
    if is_bot s1 then bot
    else if is_bot s2 then bot
    else
      VariableMap.merge (fun _ v1 v2 ->
        match v1, v2 with
        | Some ys1, Some ys2 -> Some (List.sort_uniq compare (ys1 @ ys2))
        | Some ys, None -> Some ys
        | None, Some ys -> Some ys
        | None, None -> None) s1 s2

  let join s1 s2 = 
    if is_bot s1 then s2
    else if is_bot s2 then s1
    else
      VariableMap.merge (fun _ v1 v2 ->
        match v1, v2 with
        | Some ys1, Some ys2 -> Some (List.filter (fun y -> List.mem y ys2) ys1)
        | _ -> None) s1 s2   
  
  let initialP vars = VariableMap.empty

  let assign x a s =
    if is_bot s then bot
    else 
      let s' = VariableMap.remove x s in  
      let s'' = VariableMap.map (fun ys -> List.filter (fun z -> z <> x) ys) s' in
      match a with
      | Minus (Var y, Num i) | Minus (Num i, Var y) ->
        if i > 0 then
          let y_bounds = match VariableMap.find_opt y s'' with
                         | Some ys -> ys
                         | None -> [] in
          VariableMap.add x (y :: y_bounds) s''
        else if i < 0 then
          let x_bounds = match VariableMap.find_opt x s'' with
                         | Some xs -> xs
                         | None -> [] in
          VariableMap.add y (x :: x_bounds) s''
        else
          let y_bounds = match VariableMap.find_opt y s'' with
                         | Some ys -> ys
                         | None -> [] in
          VariableMap.add x y_bounds s''
      | Plus (Var y, Num i) | Plus (Num i, Var y) ->
        if y = x && i>0 then s'
        else if y = x && i=0 then s
        else if y = x && i<0 then s''
        else if i < 0 then
          let y_bounds = match VariableMap.find_opt y s'' with
                         | Some ys -> ys
                         | None -> [] in
          VariableMap.add x (y :: y_bounds) s''
        else if i > 0 then
          let x_bounds = match VariableMap.find_opt x s'' with
                         | Some xs -> xs
                         | None -> [] in
          VariableMap.add y (x :: x_bounds) s''
        else
          let y_bounds = match VariableMap.find_opt y s'' with
                         | Some ys -> ys
                         | None -> [] in
          VariableMap.add x y_bounds s''
      | Var y ->
        let y_bounds = match VariableMap.find_opt y s'' with
                       | Some ys -> ys
                       | None -> [] in
        VariableMap.add x y_bounds s''
      
      | _ -> s''
  
  let test b s = 
  if is_bot s then bot
  else 
    match b with
    | Lt (Var x, Var y) ->
      let x_bounds = match VariableMap.find_opt x s with
                   | Some ys -> ys
                   | None -> [] in
      let y_bounds = match VariableMap.find_opt y s with
                   | Some ys -> ys
                   | None -> [] in
      let new_bounds = List.sort_uniq compare (y :: x_bounds @ y_bounds) in
      VariableMap.add x new_bounds s
    | _ -> s

  let nottest b s = 
    if is_bot s then bot
    else match b with
      | Lt (Var x, Var y) ->
           let ys = match VariableMap.find_opt x s with
                  | Some ys -> List.filter (fun z -> z <> y) ys
                  | None -> [] in
          VariableMap.add x ys s
      | _ -> s

  let nottest b s = 
  if is_bot s then bot
  else match b with
    | Lt (Var x, Var y) ->
        (match VariableMap.find_opt x s with
         | None -> s
         | Some ys -> 
             VariableMap.add x (List.filter (fun z -> z <> y) ys) s)
    | _ -> s

  let stringofaP s =
    if is_bot s then "{}"
    else
      VariableMap.fold (fun x ys acc ->
        if x = "__bot__" then acc
        else List.fold_left (fun acc y ->
          acc ^ "(" ^ x ^ "<" ^ y ^ ")"
        ) acc ys
      ) s ""

  let widen s1 s2 =
  if is_bot s1 then s2
  else if is_bot s2 then s1
  else
    VariableMap.merge (fun _ v1 v2 ->
      match v1, v2 with
      | Some ys1, Some ys2 -> 
          if List.for_all (fun y -> List.mem y ys2) ys1 
          then Some ys2 
          else None  (* drop to top, not empty list *)
      | Some ys, None -> None  (* drop entirely *)
      | None, Some ys -> Some ys
      | None, None -> None) s1 s2

  let narrow s1 s2 = meet s1 s2
end
   