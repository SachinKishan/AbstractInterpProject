
open CartesianDomain
open Sign
open Interval
open Upper_bound
open Pentagons

module AbstractProperty = MakePentagon(Interval_domain)
let () = Printf.printf "Pentagons domain loaded\n%!"