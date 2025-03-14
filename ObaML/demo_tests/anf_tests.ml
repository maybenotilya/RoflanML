(** Copyright 2025, tepa46, Arsene-Baitenov *)

(** SPDX-License-Identifier: LGPL-2.1-or-later *)

open ObaML

let () =
  let s = Stdio.In_channel.input_all Stdlib.stdin in
  match Parser.structure_from_string s with
  | Ok structure ->
    (match Inferencer.run_structure_infer structure with
     | Ok structure_env ->
       Format.printf
         "Types:\n%a\n"
         Inferencer.TypeEnv.pretty_pp_env
         (Std.std_lst, structure_env);
       let structure, varSet = Alpha_conversion.run_alpha_conversion structure in
       let simple_structure = To_simple_ast.convert structure in
       let simple_structure =
         Closure_conversion.run_closure_conversion simple_structure
       in
       let simple_structure, varSet =
         Lambda_lifting.run_lambda_lifting simple_structure varSet
       in
       let anf_res = To_anf.convert simple_structure varSet in
       (match anf_res with
        | Ok anf ->
          Format.printf "Converted structure:\n%a\n" Anf_pretty_printer.print_program anf;
          let new_structure = Anf_to_simple_ast.convert anf in
          let new_structure = To_ast.convert new_structure in
          (match
             Inferencer.run_structure_infer_with_custom_std
               new_structure
               Std.extended_std_lst
           with
           | Ok new_structure_env ->
             Format.printf
               "Types after conversions:\n%a"
               Inferencer.TypeEnv.pretty_pp_env
               (Std.extended_std_lst, new_structure_env)
           | Error e -> Format.printf "Infer: %a" Typedtree.pp_error e)
        | Error e -> Format.printf "Anf conversion error: %s" e)
     | Error e -> Format.printf "Infer: %a" Typedtree.pp_error e)
  | Error err -> Format.printf "Parser: %s\n" err
;;
