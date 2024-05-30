#ifndef EMBEDED_SQLITE_HPP
#define EMBEDED_SQLITE_HPP
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

    char * top();

    char * connect(const char * const to, const char * const as);
    char * disconnect();

    void declare(const char * const type, const char * const name);
    void scope_push();
    void scope_pop();
    void scope_clear();

    char * exec(const char * const sql);

    std::string var_collect_and_placehold(const char * const sql, std::vector<variable*> &collection);
    std::string statement_to_format_string(const char * const sql, const std::vector<variable*> collection);
};
#endif
