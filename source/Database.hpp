extern void esql_error(const char * msg);

class Database {
protected:
    int validate(const char * const sql);
public:
    virtual char * declare(const char * const from) = 0;
    virtual void scope_push() = 0;
    virtual void scope_pop() = 0;
    virtual void scope_clear() = 0;

    virtual char * connect(const char * const to, const char * const as) = 0;
#if 0
    virtual char * set_connection(const char * const as) = 0;
    virtual char * disconnect(const char * const as) = 0;
#endif
    virtual char * disconnect() = 0;

#if 0
    virtual char * cursor(const char * const name, const char * const from) = 0;
    virtual char * open(const char * const cursor) = 0;
    virtual char * close(const char * const cursor) = 0;
    // fetch

    virtual int * transaction() = 0;
    virtual int * commit() = 0;
    virtual int * rollback() = 0;

    // prepared statements
#endif

    virtual char * exec(const char * const sql) = 0;
};
