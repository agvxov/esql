%{

#include "sqlite.tab.h"

%}

%option noyywrap
%option nodefault

%%

<INITIAL>{
CONNECT\ TO { return CONNECT; }
AS          { return AS; }
[a-zA-Z]+   { sqlite_lval.strval = strdup(yytext); return STRING; }
\(          { sqlite_lval.strval = strdup(yytext); return STRING; }
\)          { sqlite_lval.strval = strdup(yytext); return STRING; }
[0-9]+      { sqlite_lval.strval = strdup(yytext); return STRING; }
[ \t\n]     { ; }
;           { return END; }
}

%%
