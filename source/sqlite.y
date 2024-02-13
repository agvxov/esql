%{
#include <stdio.h>
#include <string>

#include "Database.hpp"

extern Database * db;

extern int sqlite_lex();
extern int sqlite_parse();
extern FILE* sqlite_in;
void sqlite_error(const char *s);

using namespace std;

string statement_buffer = "";

%}

%union {
    int intval;
    char* strval;
}

%token CONNECT AS
%token <strval> STRING
%token END

%%

sql: connect
    | statement
    ;

connect: CONNECT STRING AS STRING END { db->connect($2, $4); }
    ;

statement: STRING { statement_buffer += $1; }
    | statement STRING { statement_buffer += $2; }
    | statement END { db->eval(statement_buffer.c_str()); statement_buffer = ""; }
    ;

%%

void sqlite_error(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}
