#include <stdio.h>
#include <sqlite3.h>

#include "esql.yy.h"
#include "sqlite.yy.h"

#include "Sqlite.hpp"

Database * db;

signed main(int argc, char * * argv) {
	esql_in = fopen(argv[1], "r");
	if (!esql_in) {
		exit(1);
	}

    Sqlite * sqlite;
    db = sqlite;
    esql_lex();

    return 0;
}
