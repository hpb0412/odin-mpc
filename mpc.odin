package mpc

import "core:c"
import "core:c/libc"

foreign import lib "system:mpc"


/*
** State Type
*/

// mpc_state_t
State :: struct {
	pos:  c.long,
	row:  c.long,
	col:  c.long,
	term: c.int,
}


/*
** Error Type
*/

// mpc_err_t
Error :: struct {
	state:        State,
	expected_num: c.int,
	filename:     cstring,
	failure:      cstring,
	expected:     [^]cstring,
	received:     c.char,
}

@(link_prefix = "mpc_")
foreign lib {
	err_delete :: proc(e: ^Error) ---
	err_string :: proc(e: ^Error) -> cstring ---
	err_print :: proc(e: ^Error) ---
	err_print_to :: proc(e: ^Error, f: ^libc.FILE) ---
}

// mpc_result_t
Result :: struct #raw_union {
	error:   ^Error,
	outpout: rawptr,
}


/*
** Parsing
*/

// mpc_parser_t
Parser :: struct {}

@(link_prefix = "mpc_")
foreign lib {
	parse :: proc(filename: cstring, string: cstring, p: ^Parser, r: ^Result) -> c.int ---
	nparse :: proc(filename: cstring, string: cstring, length: c.size_t, p: ^Parser, r: ^Result) -> c.int ---
	parse_file :: proc(filename: cstring, file: ^libc.FILE, p: ^Parser, r: ^Result) -> c.int ---
	parse_pipe :: proc(filename: cstring, pipe: ^libc.FILE, p: ^Parser, r: ^Result) -> c.int ---
	parse_contents :: proc(filename: cstring, p: ^Parser, r: ^Result) -> c.int ---
}


/*
** Function Types
*/

Dtor_Fn :: #type proc "c" (v: rawptr)
Ctor_Fn :: #type proc "c" () -> rawptr

Apply_Fn :: #type proc "c" (v: rawptr) -> rawptr
Apply_To_Fn :: #type proc "c" (v: rawptr, p: rawptr) -> rawptr
Fold_Fn :: #type proc "c" (n: c.int, v: rawptr) -> rawptr

Check_Fn :: #type proc "c" (v: rawptr) -> c.int
CheckWith_Fn :: #type proc "c" (v: rawptr, p: rawptr) -> c.int

@(link_prefix = "mpc_")
foreign lib {
	/*
    ** Building a Parser
    */
	new :: proc(name: cstring) -> ^Parser ---
	copy :: proc(a: ^Parser) -> ^Parser ---
	define :: proc(p: ^Parser, a: ^Parser) -> ^Parser ---
	undefine :: proc(p: ^Parser) ---

	delete :: proc(p: ^Parser) ---
	cleanup :: proc(n: c.int, ps: ..^Parser) ---

	/*
    ** Basic Parsers
    */
	any :: proc() -> ^Parser ---
	char :: proc(c: c.char) -> ^Parser ---
	range :: proc(s: c.char, e: c.char) -> ^Parser ---
	oneof :: proc(s: cstring) -> ^Parser ---
	noneof :: proc(s: cstring) -> ^Parser ---
	satisfy :: proc(f: #type proc(_: c.char) -> c.int) -> ^Parser ---
	string :: proc(s: cstring) -> ^Parser ---

	/*
    ** Other Parsers
    */
	pass :: proc() -> ^Parser ---
	fail :: proc(m: cstring) -> ^Parser ---
	failf :: proc(fmt: cstring, #c_vararg args: ..cstring) -> ^Parser ---
	lift :: proc(f: Ctor_Fn) -> ^Parser ---
	lift_val :: proc(x: rawptr) -> ^Parser ---
	anchor :: proc(f: #type proc(_: c.char, _: c.char) -> c.int) -> ^Parser ---
	state :: proc() -> ^Parser ---

	/*
    ** Combinator Parsers
    */
	expect :: proc(a: ^Parser, e: cstring) -> ^Parser ---
	expectf :: proc(a: ^Parser, fmt: cstring, #c_vararg args: ..cstring) -> ^Parser ---
	apply :: proc(a: ^Parser, f: Apply_Fn) -> ^Parser ---
	apply_to :: proc(a: ^Parser, f: Apply_To_Fn) -> ^Parser ---
	check :: proc(a: ^Parser, da: Dtor_Fn, f: Check_Fn, e: cstring) -> ^Parser ---
	check_with :: proc(a: ^Parser, da: Dtor_Fn, f: Check_Fn, x: rawptr, e: cstring) -> ^Parser ---
	checkf :: proc(a: ^Parser, da: Dtor_Fn, f: Check_Fn, fmt: cstring, #c_vararg args: ..cstring) -> ^Parser ---
	check_withf :: proc(a: ^Parser, da: Dtor_Fn, f: Check_Fn, x: rawptr, fmt: cstring, #c_vararg args: ..cstring) -> ^Parser ---

	not :: proc(a: ^Parser, da: Dtor_Fn) -> ^Parser ---
	not_lift :: proc(a: ^Parser, da: Dtor_Fn, lf: Ctor_Fn) -> ^Parser ---
	maybe :: proc(a: ^Parser) -> ^Parser ---
	maybe_lift :: proc(a: ^Parser, lf: Ctor_Fn) -> ^Parser ---

	many :: proc(f: Fold_Fn, a: ^Parser) -> ^Parser ---
	many1 :: proc(f: Fold_Fn, a: ^Parser) -> ^Parser ---
	count :: proc(n: c.int, f: Fold_Fn, a: ^Parser, da: Dtor_Fn) -> ^Parser ---

	or :: proc(n: c.int, #c_vararg args: ..^Parser) -> ^Parser ---
	and :: proc(n: c.int, f: Fold_Fn, #c_vararg args: ..^Parser) -> ^Parser ---
	predictive :: proc(a: ^Parser) -> ^Parser ---

	/*
    ** Common Parsers
    */
	eoi :: proc() -> ^Parser ---
	soi :: proc() -> ^Parser ---

	boundary :: proc() -> ^Parser ---
	boundary_newline :: proc() -> ^Parser ---

	whitespace :: proc() -> ^Parser ---
	whitespaces :: proc() -> ^Parser ---
	blank :: proc() -> ^Parser ---

	newline :: proc() -> ^Parser ---
	tab :: proc() -> ^Parser ---
	escape :: proc() -> ^Parser ---

	digit :: proc() -> ^Parser ---
	hexdigit :: proc() -> ^Parser ---
	octdigit :: proc() -> ^Parser ---
	digits :: proc() -> ^Parser ---
	hexdigits :: proc() -> ^Parser ---
	octdigits :: proc() -> ^Parser ---

	lower :: proc() -> ^Parser ---
	upper :: proc() -> ^Parser ---
	alpha :: proc() -> ^Parser ---
	underscore :: proc() -> ^Parser ---
	alphanum :: proc() -> ^Parser ---

	int :: proc() -> ^Parser ---
	hex :: proc() -> ^Parser ---
	oct :: proc() -> ^Parser ---
	number :: proc() -> ^Parser ---

	real :: proc() -> ^Parser ---
	float :: proc() -> ^Parser ---

	char_lit :: proc() -> ^Parser ---
	string_lit :: proc() -> ^Parser ---
	regex_lit :: proc() -> ^Parser ---

	indent :: proc() -> ^Parser ---

	/*
    ** Useful Parsers
    */
	startwidth :: proc(a: ^Parser) -> ^Parser ---
	endwidth :: proc(a: ^Parser, da: Dtor_Fn) -> ^Parser ---
	whole :: proc(a: ^Parser, da: Dtor_Fn) -> ^Parser ---

	stripl :: proc(a: ^Parser) -> ^Parser ---
	stripr :: proc(a: ^Parser) -> ^Parser ---
	strip :: proc(a: ^Parser) -> ^Parser ---
	tok :: proc(a: ^Parser) -> ^Parser ---
	sym :: proc(s: cstring) -> ^Parser ---
	total :: proc(a: ^Parser, da: Dtor_Fn) -> ^Parser ---

	between :: proc(a: ^Parser, ad: Dtor_Fn, o: cstring, c: cstring) -> ^Parser ---
	parens :: proc(a: ^Parser, ad: Dtor_Fn) -> ^Parser ---
	braces :: proc(a: ^Parser, ad: Dtor_Fn) -> ^Parser ---
	brackets :: proc(a: ^Parser, ad: Dtor_Fn) -> ^Parser ---
	squares :: proc(a: ^Parser, ad: Dtor_Fn) -> ^Parser ---

	tok_between :: proc(a: ^Parser, ad: Dtor_Fn, o: cstring, c: cstring) -> ^Parser ---
	tok_parens :: proc(a: ^Parser, ad: Dtor_Fn) -> ^Parser ---
	tok_braces :: proc(a: ^Parser, ad: Dtor_Fn) -> ^Parser ---
	tok_brackets :: proc(a: ^Parser, ad: Dtor_Fn) -> ^Parser ---
	tok_squares :: proc(a: ^Parser, ad: Dtor_Fn) -> ^Parser ---

	sepby1 :: proc(f: Fold_Fn, sep: ^Parser, a: ^Parser) -> ^Parser ---
}
@(link_prefix = "mpc")
foreign lib {
	/*
    ** Common Function Parameters
    */
	f_dtor_null :: proc(x: rawptr) ---

	f_ctor_null :: proc() -> rawptr ---
	f_ctor_str :: proc() -> rawptr ---

	f_free :: proc(x: rawptr) -> rawptr ---
	f_int :: proc(x: rawptr) -> rawptr ---
	f_hex :: proc(x: rawptr) -> rawptr ---
	f_oct :: proc(x: rawptr) -> rawptr ---
	f_float :: proc(x: rawptr) -> rawptr ---
	f_strtriml :: proc(x: rawptr) -> rawptr ---
	f_strtrimr :: proc(x: rawptr) -> rawptr ---
	f_strtrim :: proc(x: rawptr) -> rawptr ---

	f_escape :: proc(x: rawptr) -> rawptr ---
	f_escape_regex :: proc(x: rawptr) -> rawptr ---
	f_escape_string_raw :: proc(x: rawptr) -> rawptr ---
	f_escape_char_raw :: proc(x: rawptr) -> rawptr ---

	f_unescape :: proc(x: rawptr) -> rawptr ---
	f_unescape_regex :: proc(x: rawptr) -> rawptr ---
	f_unescape_string_raw :: proc(x: rawptr) -> rawptr ---
	f_unescape_char_raw :: proc(x: rawptr) -> rawptr ---

	f_null :: proc(n: c.int, xs: rawptr) -> rawptr ---
	f_fst :: proc(n: c.int, xs: rawptr) -> rawptr ---
	f_snd :: proc(n: c.int, xs: rawptr) -> rawptr ---
	f_trd :: proc(n: c.int, xs: rawptr) -> rawptr ---

	f_fst_free :: proc(n: c.int, xs: rawptr) -> rawptr ---
	f_snd_free :: proc(n: c.int, xs: rawptr) -> rawptr ---
	f_trd_free :: proc(n: c.int, xs: rawptr) -> rawptr ---
	f_all_free :: proc(n: c.int, xs: rawptr) -> rawptr ---

	f_freefold :: proc(n: c.int, xs: rawptr) -> rawptr ---
	f_strfold :: proc(n: c.int, xs: rawptr) -> rawptr ---
}

/*
** Regular Expression Parsers
*/
MPC_RE_DEFAULT :: 0
MPC_RE_M :: 1
MPC_RE_S :: 2
MPC_RE_MULTILINE :: 1
MPC_RE_DOTALL :: 2

@(link_prefix = "mpc_")
foreign lib {
	re :: proc(re: cstring) -> ^Parser ---
	re_mode :: proc(re: cstring, mode: c.int) -> ^Parser ---
}

/*
** AST
*/

Ast :: struct {
	tag:          cstring,
	contents:     cstring,
	state:        State,
	children_num: c.int,
	children:     [^]^Ast,
}

@(link_prefix = "mpc_")
foreign lib {
	ast_new :: proc(tag: cstring, contents: cstring) ---
	ast_build :: proc(n: c.int, tag: cstring, #c_vararg args: ..^Ast) ---
	ast_add_root :: proc(a: ^Ast) ---
	ast_add_child :: proc(r: ^Ast, a: ^Ast) ---
	ast_add_tag :: proc(a: ^Ast, t: cstring) ---
	ast_add_root_tag :: proc(a: ^Ast, t: cstring) ---
	ast_tag :: proc(a: ^Ast, t: cstring) ---
	ast_state :: proc(a: ^Ast, s: State) ---

	ast_delete :: proc(a: ^Ast) ---
	ast_print :: proc(a: ^Ast) ---
	ast_print_to :: proc(a: ^Ast, f: ^libc.FILE) ---

	ast_get_index :: proc(a: ^Ast, t: cstring) -> c.int ---
	ast_get_index_lb :: proc(a: ^Ast, t: cstring, lb: c.int) -> c.int ---
	ast_get_child :: proc(a: ^Ast, t: cstring) -> ^Ast ---
	ast_get_child_lb :: proc(a: ^Ast, t: cstring, lb: c.int) -> ^Ast ---
}

AstTravOrder :: enum {
	PRE,
	POST,
}

AstTrav :: struct {
	curr_node:     ^Ast,
	parent:        ^AstTrav,
	current_child: c.int,
	order:         AstTravOrder,
}

@(link_prefix = "mpc_")
foreign lib {
	ast_traverse_start :: proc(ast: ^Ast, order: AstTravOrder) -> ^AstTrav ---
	ast_traverse_next :: proc(trav: ^^AstTrav) -> ^Ast ---
	ast_traverse_free :: proc(trav: ^^AstTrav) ---

	ast_eq :: proc(a: ^Ast, b: ^Ast) -> c.int ---
}

@(link_prefix = "mpc")
foreign lib {
	f_fold_ast :: proc(n: c.int, as: rawptr) -> rawptr ---
	f_str_ast :: proc(c: rawptr) -> rawptr ---
	f_state_ast :: proc(n: c.int, xs: rawptr) -> rawptr ---

	a_tag :: proc(a: ^Parser, t: cstring) -> ^Parser ---
	a_add_tag :: proc(a: ^Parser, t: cstring) -> ^Parser ---
	a_root :: proc(a: ^Parser) -> ^Parser ---
	a_state :: proc(a: ^Parser) -> ^Parser ---
	a_total :: proc(a: ^Parser) -> ^Parser ---

	a_not :: proc(a: ^Parser) -> ^Parser ---
	a_maybe :: proc(a: ^Parser) -> ^Parser ---

	a_many :: proc(a: ^Parser) -> ^Parser ---
	a_many1 :: proc(a: ^Parser) -> ^Parser ---
	a_count :: proc(n: c.int, a: ^Parser) -> ^Parser ---

	a_or :: proc(n: c.int, #c_vararg args: ..^Parser) -> ^Parser ---
	a_and :: proc(n: c.int, #c_vararg args: ..^Parser) -> ^Parser ---
}

A_LANG :: enum {
	DEFAULT              = 0,
	PREDICTIVE           = 1,
	WHITESPACE_SENSITIVE = 2,
}
A_LANG_SET :: bit_set[A_LANG;c.int]

@(link_prefix = "mpc")
foreign lib {
	a_grammar :: proc(flags: A_LANG_SET, grammar: cstring, #c_vararg args: ..^Parser) ---

	a_lang :: proc(flags: A_LANG_SET, language: cstring, #c_vararg args: ..^Parser) ---
	a_lang_file :: proc(flags: A_LANG_SET, f: ^libc.FILE, #c_vararg args: ..^Parser) ---
	a_lang_pipe :: proc(flags: A_LANG_SET, f: ^libc.FILE, #c_vararg args: ..^Parser) ---
	a_lang_contents :: proc(flags: A_LANG_SET, filename: cstring, #c_vararg args: ..^Parser) ---
}

@(link_prefix = "mpc_")
foreign lib {
	/*
    ** Misc
    */
	print :: proc(p: ^Parser) ---
	optimise :: proc(p: ^Parser) ---
	stats :: proc(p: ^Parser) ---

	test_pass :: proc(p: ^Parser, s: cstring, d: rawptr, tester: proc(_: rawptr, _: rawptr) -> c.int, destructor: Dtor_Fn, printer: proc(_: rawptr)) -> c.int ---
	test_fail :: proc(p: ^Parser, s: cstring, d: rawptr, tester: proc(_: rawptr, _: rawptr) -> c.int, destructor: Dtor_Fn, printer: proc(_: rawptr)) -> c.int ---
}
