#include "Database.hpp"

#include <vector>
#include <string>

class Sqlite : public Database {
    /* XXX: make this a list
     */
    std::string connection;

    int scope;

    struct variable {
        std::string name;
        std::string type;
        int scope;
    };

    std::vector<variable> variables = {};

    char * connect(const char * const to, const char * const as) override {
        char * r;
        /* XXX: check for duplicates; check for not being open
         */
        connection = as;
        const int a = asprintf(&r,
            "sqlite3 *%s;\n"
            "sqlite3_open(\"%s\", &%s);\n",
            as, to, as
        );
        (void)a;
        return r;
    }

    virtual char * disconnect() {
        char * r;
        const int a = asprintf(&r,
            "sqlite3_close(%s);\n",
            connection.c_str()
        );
        (void)a;
        return r;
    }

    virtual char * declare(const char * const from) {
        return NULL;
    }

    virtual void scope_push() {
        ++scope;
    }
    virtual void scope_pop() {
        --scope;
        for(int i = variables.size()-1; i > -1; i--) {
            if (variables[i].scope > scope) {
                variables.erase(variables.begin() + i);
            }
        }
    }
    virtual void scope_clear() {
        scope = 0;
        variables.clear();
    }

    char * exec(const char * const sql) override {
        char * r;
        int v = validate(sql);
        if (v) {
            std::string e = std::string() + "Invalid SQL \'" + sql + '\'';
            esql_error(e.c_str());
        }
        const int a = asprintf(&r,
            "sqlite3_exec(%s, \"%s\", 0, 0, NULL);\n",
            connection.c_str(), sql
        );
        (void)a;
        return r;
    }
};
