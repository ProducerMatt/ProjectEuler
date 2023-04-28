##
# K and R C
#
# @file
# @version 0.1

#TARGET := $(patsubst %.c, %, $(wildcard *.c))
TARGET = 1-FtoC
CC = clang
TASTYPIE= -fPIE -Wl,-pie -fPIC -Wl,-shared
CFLAGS = -std=c99 -O1 -g -Weverything -Wframe-larger-than=64 -fsanitize=address -fsanitize=undefined -fsanitize=leak -Wformat=2 -fstack-protector-strong -fno-omit-frame-pointer -Wl,-z,nodlopen -Wl,-z,nodump -Wl,-z,relro -Wl,-z,now

.PHONY: default all clean

default: $(TARGET)
all: default

OBJECTS := $(patsubst %.c, %.o, $(wildcard *.c))
HEADERS := $(wildcard *.h)

#%.o: %.c $(HEADERS)
#	$(CC) $(CFLAGS) -c $< -o $@

.PRECIOUS: $(TARGET) $(OBJECTS)

#%.c:

$(TARGET): %: %.c
	$(CC) $(CFLAGS) $< -o $@

clean:
	-rm -f *.o
	-rm -f $(TARGET)

# end
