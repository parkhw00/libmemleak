
src = .
Q = @

CFLAGS += -O0 -ggdb
CFLAGS += -Wall
CFLAGS += -pthread
LDFLAGS += -pthread

all: \
	libmemleak.so libmemleak_nohook.so \
	memleak_control \
	test \
	test_threads


OBJS_LIB += src/addr2line.o
OBJS_LIB += src/memleak.o
OBJS_LIB += src/sort.o
OBJS_LIB += src/rb_tree/red_black_tree.o
OBJS_LIB += src/rb_tree/stack.o
OBJS_LIB += src/rb_tree/misc.o

CFLAGS_LIB += -I$(src)/src
CFLAGS_LIB += -I$(src)/src/include
CFLAGS_LIB += -I$(src)/src/rb_tree
CFLAGS_LIB += -pthread
CFLAGS_LIB += -fPIC
LIBS_LIB += -lbfd -lpthread

libmemleak.so: $(addprefix objs/lib/,$(OBJS_LIB))
	$(CC) $(LDFLAGS) -shared -o $@ $^ $(LIBS_LIB)

objs/lib/%.o: $(src)/%.c
	$(Q)mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(CFLAGS_LIB) -c -o $@ $^


libmemleak_nohook.so: $(addprefix objs/lib_nohook/,$(OBJS_LIB))
	$(CC) $(LDFLAGS) -shared -o $@ $^ $(LIBS_LIB)

objs/lib_nohook/%.o: $(src)/%.c
	$(Q)mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(CFLAGS_LIB) -DMEMLEAK_NOHOOK -c -o $@ $^


CFLAGS_MC += $(shell pkg-config --cflags readline)
LIBS_MC += $(shell pkg-config --libs readline)

memleak_control: objs/src/memleak_control.o
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS_MC)

objs/src/memleak_control.o: $(src)/src/memleak_control.c
	$(Q)mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(CFLAGS_MC) -c -o $@ $^


%: objs/tests/%.o | libmemleak_nohook.so
	$(CC) $(LDFLAGS) -L. -o $@ $^ -lmemleak_nohook -lpthread

objs/tests/%.o: $(src)/tests/%.c
	$(Q)mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(CFLAGS_TEST) -c -o $@ $^

