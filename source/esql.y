%code {
#include <stdio.h>
#include <string.h>

extern FILE * esql_out;

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

%}

%union {
    int intval;
    char* strval;
}

%token CONNECT AS
%token <strval> CHAR
%token <strval> END

%type <strval> statement substatemt string

%%
sql: %empty
    | sql connect
    | sql statement
    ;

connect: CONNECT string AS string END {
        ECHOS(db->connect($2, $4));
        }
    ;

statement: substatemt END {
        ECHOS(db->exec($$));
        }
    ;

substatemt: string
    | substatemt string
    ;

string: CHAR
    | string CHAR
    ;
%%

void esql_error(const char * msg) {
    fprintf(stderr, "\033[1m%s:%d:\033[0m \033[31m%s\033[0m\n", esql_filename, esql_lineno, msg);
}
