#include <stdio.h>
#include <sqlite3.h>

#include "esql.yy.h"
#include "sqlite.yy.h"

extern "C" {
    #include "sql.tab.h"
    #include "yyl.h"
    #include "sql.lex.h"
    #include "sql-parser.h"
}

#include "Database.hpp"
#include "sqlite.tab.h"
class Sqlite : public Database {
    struct psql_state *pstate;

    int validate(const char * const sql) {
        int r;
        char * dup = strdup(sql);
        psql_set_string_input(pstate, dup);
        r = psql_parse(pstate);
        free(dup);
        return !r
            && !yyerrno;
    }

    char * connect(const char * const to, const char * const as) override {
        char * r = NULL;
        #if DEBUG
        printf("Connecting to \"%s\" as \"%s\"\n", to, as);
        #endif
        return r;
    }

    char * eval(const char * const sql) override {
        char * r = NULL;
        int v = validate(sql);
        #if DEBUG
        printf("Recieved SQL: \"%s\" (%d)\n", sql, v);
        #endif
        return r;
    }

public:
    Sqlite() {
        pstate = psql_new();
        if (!pstate) {
            throw 1;
        }
    }

    ~Sqlite() {
        psql_free(pstate);
    }
};

Database * db;

signed main(int argc, char * * argv) {
	esql_in = fopen(argv[1], "r");
	if (!esql_in) {
		exit(1);
	}

    Sqlite sqlite;
    db = &sqlite;
    esql_lex();

    return 0;
}
