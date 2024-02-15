extern "C" {
    #include "sql.tab.h"
    #include "yyl.h"
    #include "sql.lex.h"
    #include "sql-parser.h"
}

int validate(const char * const sql) {
    int r;
    char * dup = strdup(sql);
    struct psql_state *pstate;
    if(!pstate) {
        return 1;
    }

    psql_set_string_input(pstate, dup);
    r = psql_parse(pstate);

    psql_free(pstate);
    free(dup);

    return !r
        && !yyerrno;
}
