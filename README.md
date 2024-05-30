# Embeded SQL
> Framework and SQLite implementation of DB2 style embeded SQl for C/C++

## What is embeded SQL?
In short, this:
```C
#include <stdio.h>

signed main(){
	EXEC SQL BEGIN DECLARE SECTION;
	int i;
	char c[4];
	EXEC SQL END DECLARE SECTION;

	EXEC SQL CONNECT TO testdb AS myconnection;
	EXEC SQL SELECT i, text INTO :i, :c FROM test WHERE i = 1;

	puts(c);

	return i;
}
```
It, in a broad sense, is what PL/SQL is for Ada, but for C/C++.

With an extra step of preprocessing,
the above is turned into conventional C,
that any compiler will be able to deal with.
Which is quite similar to how Flex and Bison work.

## Why?
Embeded SQL provides the following benefits:
+ better syntax highlighting compatibility
+ compile time SQL syntax checks
+ more agile type conversions between the database and C

## Who is responsible for this?
IBM is.
The embeded SQL debuted with their DB2.
I am awfully unsure,
which edition,
but I believe it originates from the 80s.

In 1998,
Michael Meskes started Postgresql's on going embeded SQL support
with the following comment:

> Well this is not really a patch.
But I mananged to get Linus' old Postgres95 precompiler
to compile and work with PostgreSQL.

What that implies is under investigation.

Regardles the standard Postgresql tool `ecpg`
is highly functional
and something I can only recommend for people
working with Postgresql in specific.

However,
I find the usage of databases with a server architecture
for non-enterprise purposes of rather poor taste.
This is why this project sets out to
start supporting SQLite/embeded SQL and
to create a system where adding arbitrary databases is easy

## Tell me the details
The exact specification can be found at [documentation/spec.md](documentation/spec.md).
