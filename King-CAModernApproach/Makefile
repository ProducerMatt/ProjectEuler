# Find all C files in the ./src/ directory
SRC := $(wildcard ./src/*.c)

# Define the output directory for object files
#OBJ_DIR := ./obj
OUT := ./o
# Define the output object files
#OBJ := $(patsubst ./src/%.c, $(OBJ_DIR)/%.o, $(SRC))
EXE := $(patsubst ./src/%.c, $(OUT)/%, $(SRC))

# Define the compiler and flags
CC := musl-clang
TASTYPIE= -fPIE -Wl,-pie -fPIC -Wl,-shared
CFLAGS = -std=c99 -O1 -g -Weverything -Wframe-larger-than=64000 -Wformat=2 -fstack-protector-strong -fno-omit-frame-pointer -Wl,-z,nodlopen -Wl,-z,nodump -Wl,-z,relro -Wl,-z,now -fsanitize=address -fsanitize=undefined -fsanitize=leak

# Default target
all: $(EXE)

# Compile C files to object files
$(OUT)/%: ./src/%.c
	$(CC) $(CFLAGS) $< -o $@

# Clean target
.PHONY: clean
clean:
	rm $(EXE)
