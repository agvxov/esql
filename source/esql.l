%{

#include <stdio.h>
#include <string>

#include "Database.hpp"

using namespace std;

extern Database * db;

string sql = "";

%}

%option noyywrap
%option nodefault

%x SQL

ws			[ \t\r\v\f]
wsnl		[ \t\r\v\f\n]

%%

<INITIAL>{

EXEC{wsnl}+SQL{wsnl}+ {
    BEGIN SQL;
}

. {
    ;
}

\n {
    ++yylineno;
}

}

<SQL>{
;   {
    sql += yytext;
    printf("Found SQL: \"%s\"\n", sql.c_str());
    db->eval(sql.c_str());
    sql = "";
    BEGIN INITIAL;
}

. {
    sql += yytext;
}

}

%%
