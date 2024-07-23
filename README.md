# odin-mpc

This is a binding to the [mpc](https://github.com/orangeduck/mpc) for Odin programming language.

`mpc` stands for `Micro Parser Combinators`

This wrapper is targeting
- revision `d4c99b753bb110cb66c671f6f7c1d8813d24863d`
- commited on Aug 22, 2023

## Mapping

> I intent to keep 1-1 mapping, unless there is a requirement from Odin that force us to do differently.

Basically, for function we have
| C  | Odin |
| - | - |
| `mpc_`func_name | func_name |
| `mpcf_`func_name  | `f`_func_name |
| `mpca_`func_name  | `a`_func_name |

With struct and named enum (with its items)
(*) name of struct's member is preserved

| C  | Odin |
| - | - |
| mpc_`structname`_t | Structname |
| mpc_`enumname`_t | Enumname |
| mpc_`enumname`_item_name | ITEM_NAME |

For unnamed enum, I converted to Odin's `bit_set`
```c
enum {
  MPCA_LANG_DEFAULT              = 0,
  MPCA_LANG_PREDICTIVE           = 1,
  MPCA_LANG_WHITESPACE_SENSITIVE = 2
};
```
```odin
A_LANG :: enum {
	DEFAULT              = 0,
	PREDICTIVE           = 1,
	WHITESPACE_SENSITIVE = 2,
}
A_LANG_SET :: bit_set[A_LANG;c.int]
```

## Example

This example is based on the one from origin's [quickstart](https://github.com/orangeduck/mpc?tab=readme-ov-file#quickstart)

Let take a quick look on the original code
```c
mpc_parser_t *Expr  = mpc_new("expression");
mpc_parser_t *Prod  = mpc_new("product");
mpc_parser_t *Value = mpc_new("value");
mpc_parser_t *Maths = mpc_new("maths");

mpca_lang(MPCA_LANG_DEFAULT,
  " expression : <product> (('+' | '-') <product>)*; "
  " product    : <value>   (('*' | '/')   <value>)*; "
  " value      : /[0-9]+/ | '(' <expression> ')';    "
  " maths      : /^/ <expression> /$/;               ",
  Expr, Prod, Value, Maths, NULL);

mpc_result_t r;

if (mpc_parse("input", input, Maths, &r)) {
  mpc_ast_print(r.output);
  mpc_ast_delete(r.output);
} else {
  mpc_err_print(r.error);
  mpc_err_delete(r.error);
}

mpc_cleanup(4, Expr, Prod, Value, Maths);
```

Assume you name your collection as `dependencies`, below is Odin's equivalent
```odin
import "dependencies:mpc"

//...

Expr  : ^mpc.Parser = mpc.new("expression")
Prod  : ^mpc.Parser = mpc.new("product")
Value : ^mpc.Parser = mpc.new("value")
Maths : ^mpc.Parser = mpc.new("maths")
defer mpc.cleanup(4, Expr, Prod, Value, Maths)

mpc.a_lang(
	{.DEFAULT},
	" expression : <product> (('+' | '-') <product>)*; \n" +
	" product    : <value>   (('*' | '/')   <value>)*; \n" +
	" value      : /[0-9]+/ | '(' <expression> ')';    \n" +
	" maths      : /^/ <expression> /$/;               \n",
	Expr,
	Prod,
	Value,
	Maths,
	nil,
)

r :  mpc.Result

if mpc.parse("input", input, Maths, &r) {
    mpc.ast_print(transmute(^mpc.Ast)r.output)
    mpc.ast_delete(transmute(^mpc.Ast)r.outpout)
} else {
    mpc.err_print(r.error)
    mpc.err_delete(r.error)
}
```
