#include "Database.hpp"

extern "C" {
    #include "sql.tab.h"
    #include "yyl.h"
    #include "sql.lex.h"
    #include "sql-parser.h"
}

int Database::validate(const char * const sql) {
    int r;
    struct psql_state * pstate = psql_new();
    if(!pstate) {
        return 1;
    }

    psql_set_string_input(pstate, sql);
    yyerrno = 0;
    r = psql_parse(pstate);

    psql_free(pstate);

    return r
        || yyerrno;
}
