class Database {
public:
    virtual char * connect(const char * const to, const char * const as) = 0;
    virtual char * eval(const char * const sql) = 0;
};
