open OUnit2
open World
open Character
open Position
open State
open Graphics

(********************************************************************
   OUR APPROACH TO TESTING
 ********************************************************************)
(* Our approach to testing ...

   The way we tested...

   Testing was rather difficult because of the fact that a lot of the
   functions heavily relied on the graphics window being open, and most of the
   operations done there. Therefore, the tests would likely fail due to
   needing to open the graphics screen. As well, especially in the
   ImageHandler module, *** POSSIBLY CHANGE THIS

   Partially as a result of that, some tests we omitted because they directly
   relate to the graphics panel, which we do not believe we can really confirm
   through running unit tests. Since we can easily confirm this visually,
   especially in the functions that require using pictures that we can see
   being draw on the graphics panel, there is no need to write test cases for
   this. As well, some functions return a specific type that is defined in the
   module, which in this case is obscured from the client. Therefore, we
   "test" those through the other methods to make sure it has been defined
   properly.

   Therefore, having the our eyes see what we would like and having correct
   unit tests demonstrates the correctness of the system. The game is supposed
   to be graphically based and visual. Because the game works correctly from a
   visual and player standpoint, and the basic tests that in this file all
   pass, this system is very likely to be correct. *)

let cmp_set_like_lists lst1 lst2 =
  let uniq1 = List.sort_uniq compare lst1 in
  let uniq2 = List.sort_uniq compare lst2 in
  List.length lst1 = List.length uniq1
  && List.length lst2 = List.length uniq2
  && uniq1 = uniq2

(** [pp_string s] pretty-prints string [s]. *)
let pp_string s = "\"" ^ s ^ "\""

(** [pp_list pp_elt lst] pretty-prints list [lst], using [pp_elt] to
    pretty-print each element of [lst]. *)
let pp_list pp_elt lst =
  let pp_elts lst =
    let rec loop n acc = function
      | [] -> acc
      | [ h ] -> acc ^ pp_elt h
      | h1 :: (h2 :: t as t') ->
          if n = 100 then acc ^ "..." (* stop printing long list *)
          else loop (n + 1) (acc ^ pp_elt h1 ^ "; ") t'
    in
    loop 0 "" lst
  in
  "[" ^ pp_elts lst ^ "]"

(* These tests demonstrate how to use [cmp_set_like_lists] and [pp_list] to
   get helpful output from OUnit. *)
(* let cmp_demo = [ ( "order is irrelevant" >:: fun _ -> assert_equal
   ~cmp:cmp_set_like_lists ~printer:(pp_list pp_string) [ "foo"; "bar" ] [
   "bar"; "foo" ] ); Uncomment this test to see what happens when a test case
   fails. "duplicates not allowed" >:: (fun _ -> assert_equal
   ~cmp:cmp_set_like_lists ~printer:(pp_list pp_string) ["foo"; "foo"]
   ["foo"]); ] *)

(* HELPER FUNCTIONS/VALUES FOR MAKING TESTS *)

let string_of_array pp_elt arr =
  let lst = Array.to_list arr in
  pp_list pp_elt lst

(* WORLD TESTS *)

let world_test_int_to_tile name i expected_output =
  name >:: fun _ -> assert_equal expected_output (int_to_tile i)

let world_test_get_tile_arr name map expected_output =
  name >:: fun _ -> assert_equal expected_output (get_tile_arr map)

(* ~printer:(string_of_array string_of_tile) *)

let world_test_get_tile name row col map expected_output =
  name >:: fun _ -> assert_equal expected_output (get_tile row col map)

let world_test_get_rows name map expected_output =
  name >:: fun _ ->
  assert_equal expected_output (get_rows map) ~printer:string_of_int

let world_test_get_cols name map expected_output =
  name >:: fun _ ->
  assert_equal expected_output (get_cols map) ~printer:string_of_int

let world_test_get_tile_size name map expected_output =
  name >:: fun _ ->
  assert_equal expected_output (get_tile_size map) ~printer:string_of_int

let world_test_get_assets name map expected_output =
  name >:: fun _ -> assert_equal expected_output (get_assets map)

(********************************************************************* 
  End helper functions.
 *********************************************************************)

let blank = map_from_json_file "blankmap.json"

let map1 = map_from_json_file "testmap.json"

let map2 = map_from_json_file "realmap.json"

let map_size_32 = map_from_json_file "32.json"

let terrain_image = Png.load_as_rgb24 "assets/Terrain.png" []

let street_image = Png.load_as_rgb24 "assets/Street.png" []

let building_image = Png.load_as_rgb24 "assets/Buildings.png" []

let assets = [| terrain_image; street_image; building_image |]

let world_tests =
  [
    world_test_int_to_tile "0 gives blank" 0 Blank;
    world_test_int_to_tile "1 gives grass" 1 Grass;
    world_test_int_to_tile "27 gives top of door" 27 DoorTop;
    world_test_int_to_tile "28 gives bottom of door" 28 DoorBot;
    world_test_get_tile_arr "empty file gives empty array" blank
      (Array.make 0 Blank);
    world_test_get_tile_arr "testmap.json" map1
      (Array.map int_to_tile
         [|
           1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 3; 1; 3; 3; 3; 1; 1; 1; 3;
           3; 3; 3; 3; 3; 3; 3; 1; 2; 2; 2; 2; 2; 2; 2; 2; 2; 2; 1; 1; 1; 1;
           1; 1; 2; 1; 1; 1; 1; 1; 1; 1; 1; 1; 2; 1; 1; 1; 1; 1; 1; 1; 1; 1;
           2; 1; 1; 1;
         |]);
    world_test_get_tile "empty map will give blank tile" 0 0 blank Blank;
    world_test_get_tile "map1 (0, 0) gives " 0 0 map1 Grass;
    world_test_get_tile "map1 (2, 3) gives " 2 3 map1 TreeTop;
    world_test_get_tile "map2 (0, 0) gives " 0 0 map2 Grass;
    world_test_get_tile "map2 (19, 6) gives " 19 6 map2
      Sidewalk_Curved_TopLeft;
    world_test_get_rows "empty map will give 0 rows" blank 0;
    world_test_get_rows "map1 will give 7 rows" map1 7;
    world_test_get_rows "map2 will give 35 rows" map2 35;
    world_test_get_cols "empty map will give 10 cols" blank 0;
    world_test_get_cols "map1 will give 0 cols" map1 10;
    world_test_get_cols "map2 will give 0 cols" map2 50;
    world_test_get_tile_size "blank has 1x1 tile size" blank 1;
    world_test_get_tile_size "map2 has 16x16 tile size" map2 16;
    world_test_get_tile_size "map_size_32 has 32x32 tile size" map_size_32 32;
    (* world_test_get_assets "map should give three assets defined" map2
       assets; *)
  ]

let () = Graphics.open_graph ""

let create_person position =
  {
    name = "person";
    rep = Character.get_person_image Still;
    pos = { x = position.x; y = position.y };
    speed = 16;
    tile_mem = World.get_tile 9 10 world;
  }

let person_1 () = create_person { x = 16; y = 16 }

let person_2 () = create_person { x = World.x_dim - 16; y = World.y_dim - 16 }

let person_3 () = create_person { x = 0; y = 0 }

let move_test_pos name c expected_output p =
  let person = p () in
  Character.move person c;
  name >:: fun _ -> assert_equal expected_output person.pos

let character_tests =
  [
    (* tests for regular movements *)
    move_test_pos "move person_1 left with key a" 'a' { x = 0; y = 16 }
      person_1;
    move_test_pos "move person_1 right one with key d" 'd' { x = 32; y = 16 }
      person_1;
    move_test_pos "move person_1 down one with key s" 's' { x = 16; y = 0 }
      person_1;
    move_test_pos "move person_1 up one with key w" 'w' { x = 16; y = 32 }
      person_1;
    move_test_pos "person_1 will not move with key z" 'z' { x = 16; y = 16 }
      person_1; (* tests for edge cases *)
    move_test_pos "person_2 can't move any further right with key d" 'd'
      { x = World.x_dim - 16; y = World.y_dim - 16 }
      person_2;
    move_test_pos "person_2 can't move any further up with key w" 'w'
      { x = World.x_dim - 16; y = World.y_dim - 16 }
      person_2;
    move_test_pos "person_3 can't move any further left with key a" 'a'
      { x = 0; y = 0 } person_3;
    move_test_pos "person_3 can't move any further down with key s" 's'
      { x = 0; y = 0 } person_3;
  ]

let suite =
  "test suite for m1" >::: List.flatten [ world_tests; character_tests ]

let _ = run_test_tt_main suite
