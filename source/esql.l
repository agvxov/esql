%{
#include <stdio.h>
#include <string>

#include "esql.tab.h"

#include "Database.hpp"

using namespace std;

extern Database * db;

string sql = "";

extern YY_BUFFER_STATE esql__scan_string (const char * yystr);
extern int esql_parse (void);
%}

%option noyywrap
%option nodefault

%x SQL TEST

ws			[ \t\r\v\f]
wsnl		[ \t\r\v\f\n]

%%

<INITIAL>{

EXEC{wsnl}+SQL{wsnl}+ {
    BEGIN SQL;
}

\{ {
    db->scope_push();
    ECHO;
}

\} {
    db->scope_pop();
    ECHO;
}

. {
    ECHO;
}

\n {
    ++yylineno;
    ECHO;
}

}

<SQL>{
CONNECT\ TO { return CONNECT; }
AS          { return AS; }
;           { BEGIN INITIAL; return END; }
.           { esql_lval.strval = yytext; return CHAR; }
\n          { ; }
}

%%
