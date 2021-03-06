(** Handles position on the graphical interface *)

(** The abstract type of values representing the position on the graphical
    interface. x = 0, y= is bottom left conner *)
type t = {
  mutable x : int;
  mutable y : int;
}

(** [x_dim] is the width of the graphics window *)
val x_dim : int

(** [y_dim] is the height of the graphics window *)
val y_dim : int

(** [from_json json_file] representation of json_file

    Require: json object contains x y *)
val from_json : Yojson.Basic.t -> t

(** [direction] representation the direction of movement *)
type direction =
  | Still
  | Up
  | Left
  | Right
  | Down

(** [distance pt1 pt2] is distance between pt1 and pt2 *)
val distance : t -> t -> int

(* check valid *)
