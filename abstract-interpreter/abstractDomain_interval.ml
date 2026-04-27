
open CartesianDomain
open Interval


module AbstractProperty = MakeDomain(Interval_domain)
let () = Printf.printf "Interval Domain loaded\n%!"

