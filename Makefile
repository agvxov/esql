ifeq (${DEBUG}, 1)
  LFLAGS   += --debug --trace
  YYFLAGS  += --debug -Wall -Wcounterexamples
  CFLAGS   += -Wall -Wextra -Wpedantic 
  CFLAGS   += -DDEBUG -O0 -ggdb -fno-inline	
  CXXFLAGS += -Wall -Wextra -Wpedantic 
  CXXFLAGS += -DDEBUG -O0 -ggdb -fno-inline	
  WRAP     := valgrind --track-origins=yes --leak-check=full --show-leak-kinds=all 
else
  CXXFLAGS += -O3 -fno-stack-protector -fno-rtti
endif

CXXFLAGS += -Isource/ -Iobject/ -Isource/sqlfun/source/
LDLIBS += $$(pkg-config --cflags --libs sqlite3 jansson)

SOURCE := main.cpp Database.cpp Sqlite.cpp
OBJECT := $(subst .cpp,.o,${SOURCE})
SOURCE := $(addprefix source/,${SOURCE})
OBJECT := $(addprefix object/,${OBJECT})

SOURCE.sqlfun := exec.c sql.tab.c lib.c sql.c
OBJECT.sqlfun := $(subst .c,.o,${SOURCE.sqlfun})
OBJECT.sqlfun := $(addprefix source/sqlfun/source/,${OBJECT.sqlfun})

GENSOURCE := $(addprefix object/,esql.tab.cpp esql.yy.cpp)

GENOBJECT := $(subst .cpp,.o,${GENSOURCE})

OUTPUT := esql

object/%.yy.cpp: source/%.l
	flex ${LFLAGS} --prefix=$(basename $(notdir $<))_ --header-file=object/$(basename $(notdir $<)).yy.h -o $@ $<

object/%.tab.cpp: source/%.y
	bison ${YYFLAGS} --name-prefix=$(basename $(notdir $<))_ --header=object/$(basename $(notdir $<)).tab.h -o $@ $<

object/%.o: source/%.c
	${COMPILE.c} $< -o $@

object/%.o: source/%.cpp
	${COMPILE.cpp} $< -o $@

object/%.o: object/%.c
	${COMPILE.c} $< -o $@

object/%.o: object/%.cpp
	${COMPILE.cpp} $< -o $@

source/sqlfun/source/%.o:
	cd source/sqlfun/; make

main: ${OBJECT.sqlfun} ${GENOBJECT} ${OBJECT}
	${LINK.cpp} -o ${OUTPUT} $+ ${LDLIBS}

clean:
	-rm object/*
	-cd source/sqlfun/; make clean

test:
	esql debug/static_insert.sqc
