
TARGETS = v6 fsckv6 mountv6 mkfsv6 dumplog fusecleanup apply
LIB = liblogfs.a


BUILD_DIR = build

$(shell mkdir -p $(BUILD_DIR))

CXXBASE = g++
#CXX = $(CXXBASE) $(ARCH) -std=c++20
CXX = $(CXXBASE) $(ARCH) -std=c++17
CC = $(CXX)
CXXFLAGS = -ggdb -Wall -Werror

CPPFLAGS = $$(pkg-config fuse3 --cflags) -MMD
LIBS = -L. -llogfs

OBJS = $(BUILD_DIR)/$(TARGETS:=.o)
_ALLOBJS = apply.o bitmap.o blockpath.o buffer.o bufio.o cache.o		\
cursor.o dumplog.o fsckv6.o fsops.o inode.o itree.o log.o logentry.o	\
mkfsv6.o mountv6.o replay.o util.o v6.o v6fs.o

ALLOBJS = $(addprefix $(BUILD_DIR)/, $(_ALLOBJS))

LIBOBJS = $(filter-out $(OBJS), $(ALLOBJS))
HEADERS = bitmap.hh blockpath.hh bufio.hh cache.hh fsops.hh ilist.hh	\
imisc.hh itree.hh layout.hh log.hh logentry.hh replay.hh util.hh	\
v6fs.hh

$(BUILD_DIR)/%.o : %.cc
	@echo 'CXX $<'
	@$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c $< -o $@

all: $(TARGETS)



$(LIB): $(LIBOBJS)
	rm -f $@
	$(AR) -crs $(LIB) $(LIBOBJS)

$(filter-out fusecleanup mountv6, $(TARGETS)): %: $(BUILD_DIR)/%.o $(LIB)
	$(CXX) -o $@ $< $(LIBS)

fusecleanup: fusecleanup.cc
	$(CXX) -o $@ fusecleanup.cc

mountv6: $(BUILD_DIR)/mountv6.o $(LIB)
	$(CXX) $(LDFLAGS) $(CXXFLAGS) -o $@ \
		$(BUILD_DIR)/mountv6.o $(LIBS) $$(pkg-config fuse3 --libs)

clean:
	rm -f $(TARGETS) $(LIB) $(ALLOBJS) proj_log.html *.d *~ .*~
	rm -rf $(BUILD_DIR)

.PHONY: all clean

-include $(wildcard $(BUILD_DIR)/*.d)


