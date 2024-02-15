#include "Database.hpp"

class Sqlite : public Database {
    char * connect(const char * const to, const char * const as) override {
        char * r = NULL;
        #if DEBUG
        printf("Connecting to \"%s\" as \"%s\"\n", to, as);
        #endif
        return r;
    }

    char * exec(const char * const sql) override {
        char * r = NULL;
        int v = validate(sql);
        #if DEBUG
        printf("Recieved SQL: \"%s\" (%d)\n", sql, v);
        #endif
        return r;
    }
};
