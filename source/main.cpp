#include <stdio.h>
#include <sqlite3.h>

#include "esql.tab.h"
#include "esql.yy.h"
#include "Sqlite.hpp"

Database * db;

char * esql_filename;

signed main(int argc, char * * argv) {
    #if DEBUG
    esql_debug = 1;
    #endif
    esql_out = stdout;
    esql_filename = argv[1];
	esql_in = fopen(esql_filename, "r");
	if (!esql_in) {
		exit(1);
	}

    Sqlite * sqlite = new Sqlite();
    db = sqlite;
    esql_parse();

    return 0;
}
