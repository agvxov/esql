%{
#include <stdio.h>
#include <string>

#include "esql.tab.h"

#include "Database.hpp"

using namespace std;

extern Database * db;

int state_buffer;

string sql = "";

extern YY_BUFFER_STATE esql__scan_string (const char * yystr);
extern int esql_parse (void);
%}

%option noyywrap
%option nodefault

%x SQL DECLARE
%x EAT2COLON

ws			[ \t\r\v\f]
wsnl		[ \t\r\v\f\n]
identifier	[a-zA-Z_$][a-zA-Z_0-9$]*

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
;           { BEGIN INITIAL; return END; }
.           { esql_lval.strval = yytext; return CHAR; }
\n          { ; }

CONNECT{wsnl}+TO    { return CONNECT; }
AS                  { return AS; }

BEGIN{wsnl}+DECLARE{wsnl}+SECTION{wsnl}*; { BEGIN DECLARE; return DECLARE_START; }
}

<DECLARE>{
const           { ECHO; }   // XXX: this is no good
extern|static   { ECHO; }
{identifier}    { ECHO; return IDENTIFIER; }
\*|\[.*\]       { ECHO; return PTR; }
=               { BEGIN EAT2COLON; ECHO; state_buffer = DECLARE; }
{wsnl}          { ECHO; }
EXEC{wsnl}+SQL{wsnl}+END{wsnl}+DECLARE{wsnl}+SECTION{wsnl}*; { BEGIN INITIAL; return DECLARE_END; }
}

<EAT2COLON>{
;    { ECHO; BEGIN state_buffer; }
.|\n { ECHO; }
}

%%
