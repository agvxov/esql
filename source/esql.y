%code provides {
#include <stdio.h>
#include <string.h>

extern FILE * esql_out;
extern int esql_errno;

#define ECHOS(s) do {                               \
	const char * const  ss = s;                     \
	fwrite(ss, strlen(ss), sizeof(char), esql_out); \
} while (0)

}

%{
#include <stdio.h>
#include <string>

#include "Database.hpp"

extern Database * db;
extern int esql_lineno;
extern char * esql_filename;

extern int esql_lex();
extern int esql_parse();
extern FILE* esql_in;
void esql_error(const char *s);

using namespace std;

int esql_errno;

%}

%union {
    int intval;
    char* strval;
}

%token CONNECT AS DECLARE_START DECLARE_END
%token <strval> CHAR IDENTIFIER PTR
%token <strval> END

%type <strval> statement substatemt string
%type <intval> pointer

%initial-action {
    ECHOS(db->top());
}

%%
sql: %empty
    | sql connect
    | sql statement
    | sql declaration
    ;

declaration: DECLARE_START var DECLARE_END
    ;

var: %empty
    | IDENTIFIER pointer IDENTIFIER {
            db->declare($1, $3);
        }
    ;

pointer: %empty   { $$ = 0; }
    | pointer PTR { $$ = $1 + 1; }
    ;

connect: CONNECT string AS string END {
            ECHOS(db->connect($2, $4));
        }
    ;

statement: substatemt END {
            const char * const e = db->exec((string() + $$ + ';').c_str());
            if(!e) { break; }
            ECHOS(e);
        }
    ;

// pretty sure this could be all on the stack
substatemt: string      { $$ = strdup((string() + $1).c_str()); free($1); }
    | substatemt string { $$ = strdup((string() + $1 + $2).c_str()); free($1); }
    ;

string: CHAR        { $$ = strdup((string() + $1).c_str()); }
    | string CHAR   { $$ = strdup((string() + $1 + $2).c_str()); free($1); }
    ;
%%

void esql_error(const char * msg) {
    fprintf(stderr, "\033[1m%s:%d:\033[0m \033[31m%s\033[0m\n",
                        esql_filename,
                        esql_lineno,
                        msg
            );
    esql_errno = 1;
}
