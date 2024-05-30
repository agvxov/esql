#include <Sqlite.hpp>
#include <string.h>

char * Sqlite::top() {
    static const char * const r = 
        "/* This source file was generated with esql.\n"
        " */\n"
        "\n"
        "/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,\n"
        "   They are private implementation details that can be changed or\n"
        "   removed.  */\n"
        "\n"
        "#include <sqlite3.h>\n"
    ;
    return (char*)r;
}

char * Sqlite::connect(const char * const to, const char * const as) {
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

char * Sqlite::disconnect() {
    char * r;
    const int a = asprintf(&r,
        "sqlite3_close(%s);\n",
        connection.c_str()
    );
    (void)a;
    return r;
}

void Sqlite::declare(const char * const type, const char * const name) {
    variables.push_back({name, type, scope});
}

void Sqlite::scope_push() {
    ++scope;
}
void Sqlite::scope_pop() {
    --scope;
    for(int i = variables.size()-1; i > -1; i--) {
        if (variables[i].scope > scope) {
            variables.erase(variables.begin() + i);
        }
    }
}
void Sqlite::scope_clear() {
    scope = 0;
    variables.clear();
}

static
size_t c_var_parser(const char * const s) {
    size_t r = 0;

    if (s[0] == '$'
    || (s[0] >= 'a' && s[0] <= 'z')
    || (s[0] >= 'A' && s[0] <= 'Z')) {
        ++r;
    } else {
        return 0;
    }

    for (const char * i = s+1; *i != '\0'; i++) {
        if ((*i >= 'a' && *i <= 'z')
        ||  (*i >= 'A' && *i <= 'Z')
        ||  (*i >= '0' && *i <= '9')) {
            ++r;
        } else {
            break;
        }
    }

    return r;
}

std::string Sqlite::var_collect_and_placehold(const char * const sql, std::vector<variable*> &collection) {
    std::string r;
    for (int i = 0; sql[i] != '\0'; i++) {
        if (sql[i] == ':') {
            ++i;
            std::string var(sql + i, c_var_parser(sql + i));
            bool is_real_var = false;
            for (auto&& i : variables) {
                if (var == i.name) {
                    collection.push_back(&i);
                    is_real_var = true;
                    break;
                }
            }
            if (not is_real_var) {
                std::string e = std::string() + "No variable declared under the name '" + var + "'";
                esql_error(e.c_str());
                return "";
            }
            r += '?';
        } else {
            r += sql[i];
        }
    }
    return r;
}

std::string Sqlite::statement_to_format_string(const char * const sql, const std::vector<variable*> collection) {
    std::string r;
    // XXX: what if there is a '?' in the sql to begin with?
    struct {    // XXX this table is horrible
        const char * type_name;
        const char * placeholder;
    } placeholder_table[] = {
        {"char", "%c"},
        {"short", "%hd"},
        {"int", "%d"},
        {"long", "%ld"},
        {"float", "%f"},
        {"double", "%lf"},
        {"void*", "%p"},
        {"char*", "%s"},
    };
    auto lookup_placeholder = [&](const char* type_name) -> const char* {
        for (const auto& entry : placeholder_table) {
            if (not strcmp(entry.type_name, type_name)) {
                return entry.placeholder;
            }
        }
        return NULL;
    };
    int var_counter = 0;
    for (const char * c = sql; *c != '\0'; c++) {
        if (*c == '?') {
            r += lookup_placeholder(collection[var_counter]->type.c_str());
        } else {
            r += *c;
        }
    }

    return r;
}

char * Sqlite::exec(const char * const sql) {
    char * r;
    std::vector<variable*> variable_collection;
    std::string sql_with_placeholders = var_collect_and_placehold(sql, variable_collection);

    int v = validate(sql_with_placeholders.c_str());
    if (v) {
        std::string e = std::string() + "Invalid SQL \'" + sql + '\'';
        esql_error(e.c_str());
        return NULL;
    }

    if (not variable_collection.size()) {
        asprintf(&r, "sqlite3_exec(%s, \"%s\", 0, 0, 0);",
                        this->connection.c_str(),
                        sql_with_placeholders.c_str()
                );
    } else {
        std::string s =
            "char * _esql_s;\n"
            "asprintf(&_esql_s,"
        ;
        s += ");";
    }
    
    return r;
}
