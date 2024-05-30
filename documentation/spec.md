# Esql

## Reservations
**All symbol names to the form** `_esql_*` **are reserved for symbol names.**

Esql will sometimes require variables to store intermediate values,
these will always start with the prefix `_esql_`.

## For project contributors
### Structure
The esql implementation follows a very basic polymorphic model.
The base class is `class Database`,
this is what the Sqlite implementation inherits from and
what subsequent databases should too.

### Ideas to explore
+ adding unsafe instructions / precocessing to turn of validation and become syntax sugar only
+ struct unpacking
+ table format validation
