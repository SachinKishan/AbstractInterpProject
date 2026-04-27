type sign =
Pos
| PosZero
| Neg
| NegZero
| Zero
| Top
| Bottom
| NotZero

let sign_plus s1 s2 =
  match (s1, s2) with
  | (Bottom, _)       -> Bottom
  | (_, Bottom)       -> Bottom
  | (_, Top)          -> Top
  | (Top, _)          -> Top
  | (x, Zero)         -> x
  | (Zero, x)         -> x
  | (Pos, Pos)        -> Pos
  | (Pos, PosZero)    -> Pos
  | (PosZero, Pos)    -> Pos
  | (PosZero, PosZero)-> PosZero
  | (Neg, Neg)        -> Neg
  | (Neg, NegZero)    -> Neg
  | (NegZero, Neg)    -> Neg
  | (NegZero, NegZero)-> NegZero
  | (Pos, NegZero)    -> NotZero
  | (NegZero, Pos)    -> NotZero
  | (Neg, PosZero)    -> NotZero
  | (PosZero, Neg)    -> NotZero
  | (Pos, Neg)        -> Top
  | (Neg, Pos)        -> Top
  | (PosZero, NegZero)-> Top
  | (NegZero, PosZero)-> Top
  | (Pos, NotZero)    -> Top
  | (NotZero, Pos)    -> Top
  | (Neg, NotZero)    -> Top
  | (NotZero, Neg)    -> Top
  | (PosZero, NotZero)-> Top
  | (NotZero, PosZero)-> Top
  | (NegZero, NotZero)-> Top
  | (NotZero, NegZero)-> Top
  | (NotZero, NotZero)-> Top
  | (_, _) -> Top

let sign_minus s1 s2 =
  match (s1, s2) with
  | (Bottom, _)        -> Bottom
  | (_, Bottom)        -> Bottom
  | (_, Top)           -> Top
  | (Top, _)           -> Top
  | (x, Zero)          -> x
  | (Zero, Zero)       -> Zero        (* already caught above, but explicit *)
  | (Zero, Pos)        -> Neg
  | (Zero, PosZero)    -> NegZero
  | (Zero, Neg)        -> Pos
  | (Zero, NegZero)    -> PosZero
  | (Zero, NotZero)    -> NotZero
  | (Pos, Pos)         -> Top
  | (Pos, PosZero)     -> PosZero     (* pos - (>=0) could be neg, zero, pos *)
  | (Pos, Neg)         -> Pos
  | (Pos, NegZero)     -> Pos
  | (Pos, NotZero)     -> Top
  | (Neg, Neg)         -> Top
  | (Neg, NegZero)     -> NegZero
  | (Neg, Pos)         -> Neg
  | (Neg, PosZero)     -> Neg
  | (Neg, NotZero)     -> Top
  | (PosZero, Pos)     -> NegZero
  | (PosZero, PosZero) -> Top
  | (PosZero, Neg)     -> Pos
  | (PosZero, NegZero) -> PosZero
  | (PosZero, NotZero) -> Top
  | (NegZero, Neg)     -> PosZero
  | (NegZero, NegZero) -> Top
  | (NegZero, Pos)     -> Neg
  | (NegZero, PosZero) -> NegZero
  | (NegZero, NotZero) -> Top
  | (NotZero, NotZero) -> Top
  | (NotZero, Pos)     -> Top
  | (NotZero, Neg)     -> Top
  | (NotZero, PosZero) -> Top
  | (NotZero, NegZero) -> Top
  | (_, _) -> Top

let sign_lt s1 s2 =
  match (s1, s2) with
  | (Neg, Pos)     -> true
  | (Neg, PosZero) -> true
  | (Neg, Zero)    -> true
  | (NegZero, Pos) -> true
  | (Zero, Pos)    -> true
  | (Zero, PosZero)-> false   
  | (_, _)         -> false

let sign_gt s1 s2 =
  match (s1, s2) with
  | (Pos, Neg)     -> true
  | (Pos, NegZero) -> true
  | (Pos, Zero)    -> true
  | (PosZero, Neg) -> true
  | (Zero, Neg)    -> true
  | (Zero, NegZero)-> false   
  | (_, _)         -> false
  

let sign_eq s1 s2 =
  match (s1, s2) with
  | (Zero, Zero) -> true
  | (_, _)       -> false

let sign_neq s1 s2 =
  match (s1, s2) with
  | (Bottom, _) | (_, Bottom) -> false
  | (Top, _)    | (_, Top)    -> false
  | (Zero, Pos) | (Pos, Zero) -> true
  | (Zero, Neg) | (Neg, Zero) -> true
  | (Zero, NotZero) | (NotZero, Zero) -> true
  | (Pos, Neg)  | (Neg, Pos)  -> true
  | (Pos, NegZero) | (NegZero, Pos) -> true
  | (Neg, PosZero) | (PosZero, Neg) -> true
  | (_, _) -> false

let string_of_sign s = match s with
   | Pos -> "Pos"
   | Neg -> "Neg"
   | NotZero -> "Not Zero"
   | PosZero -> "Positive or Zero"
   | NegZero -> "Negative or Zero"
   | Zero -> "Zero"
   | Top -> "Top"
   | Bottom -> "Bottom"

module Sign_Domain = struct
  type t = sign

  let bot = Bottom
  let top = Top

  let leq s1 s2 = match (s1, s2) with
    | (Bottom, _)   -> true
    | (_, Top)      -> true
    | (x, y) when x = y -> true
    | (Pos, PosZero)  -> true
    | (Pos, NotZero)  -> true
    | (Neg, NegZero)  -> true
    | (Neg, NotZero)  -> true
    | (Zero, PosZero) -> true
    | (Zero, NegZero) -> true
    | (_, _)          -> false
  
  let join s1 s2 = match (s1, s2) with
  | (Bottom, x) | (x, Bottom) -> x
  | (x, y) when x = y -> x
  | (Pos, Zero)  | (Zero, Pos)  -> PosZero
  | (Pos, PosZero) | (PosZero, Pos) -> PosZero
  | (Neg, Zero)  | (Zero, Neg)  -> NegZero
  | (Neg, NegZero) | (NegZero, Neg) -> NegZero
  | (Pos, NotZero) | (NotZero, Pos) -> NotZero
  | (Neg, NotZero) | (NotZero, Neg) -> NotZero
  | (Pos, Neg) | (Neg, Pos)     -> NotZero
  | (PosZero, NegZero) | (NegZero, PosZero) -> Top
  | (_, _) -> Top

  let meet s1 s2 = match (s1,s2) with 
  | (x, y) when x = y -> x
  | (x, Top) -> x
  | (Top,x) -> x 
  | (Bottom,x) -> Bottom
  | (x,Bottom) -> Bottom
  | (NotZero,NegZero) | (NegZero,NotZero) -> Neg
  | (NotZero,PosZero) | (PosZero,NotZero) -> Pos
  | (NegZero,PosZero) | (PosZero,NegZero) -> Zero
  | (Pos, PosZero) | (PosZero, Pos) -> Pos  
  | (Neg, NegZero) | (NegZero, Neg) -> Neg
  | (Pos, NotZero) | (NotZero, Pos) -> Pos
  | (Neg, NotZero) | (NotZero, Neg) -> Neg  
  | (Zero, PosZero) | (PosZero, Zero) -> Zero
  | (Zero, NegZero) | (NegZero, Zero) -> Zero
  | (_,_) -> Bottom



  let eval_num i =
    if i > 0 then Pos
    else if i = 0 then Zero
    else Neg

  let add = sign_plus
  let sub = sign_minus
  let lt = sign_lt
  let gt = sign_gt
  let eq = sign_eq
  let neq = sign_neq
  let to_string = string_of_sign
  let initial = Zero

  let widen s1 s2 = join s1 s2  
  let narrow s1 s2 = s1          
end

