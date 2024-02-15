ifeq (${DEBUG}, 1)
  LFLAGS   += --debug --trace
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

GENSOURCE := object/sqlite.tab.cpp object/sqlite.yy.cpp object/esql.yy.cpp

GENOBJECT := $(subst .cpp,.o,${GENSOURCE})

REEEEEEEE := exec.o sql.tab.o lib.o sql.o
REEEEEEEE := $(addprefix source/sqlfun/source/,${REEEEEEEE})

OUTPUT := esql

object/%.yy.cpp: source/%.l
	flex ${LFLAGS} --prefix=$(basename $(notdir $<))_ --header-file=object/$(basename $(notdir $<)).yy.h -o $@ $<

object/%.tab.cpp: source/%.y
	bison --name-prefix=$(basename $(notdir $<))_ --header=object/$(basename $(notdir $<)).tab.h -o $@ $<

object/%.o: source/%.c
	${COMPILE.c} $< -o $@

object/%.o: source/%.cpp
	${COMPILE.cpp} $< -o $@

object/%.o: object/%.c
	${COMPILE.c} $< -o $@

object/%.o: object/%.cpp
	${COMPILE.cpp} $< -o $@


main: ${GENOBJECT} object/main.o ${REEEEEEEE}
	${LINK.cpp} -o ${OUTPUT} $+ ${LDLIBS}

clean:
	-rm object/*
	-cd source/sqlfun/; make clean
