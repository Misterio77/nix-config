PREFIX ?= /usr/local
BIN_DIR ?= $(PREFIX)/bin


TARGET_EXEC ?= foo-bar
BUILD_DIR ?= ./build
SRC_DIRS ?= ./src

SRCS := $(shell find $(SRC_DIRS) -name *.cpp -or -name *.c)
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)
DEPS := $(OBJS:.o=.d)

INC_DIRS := $(shell find $(SRC_DIRS) -type d)
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

CPPFLAGS ?= $(INC_FLAGS) -MMD -MP

$(BUILD_DIR)/$(TARGET_EXEC): $(OBJS)
	$(CXX) $(OBJS) -o $@ $(LDFLAGS)

# c source
$(BUILD_DIR)/%.c.o: %.c
	$(MKDIR_P) $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

# c++ source
$(BUILD_DIR)/%.cpp.o: %.cpp
	$(MKDIR_P) $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@
clean:
	$(RM) -r $(BUILD_DIR)

install: $(BUILD_DIR)/$(TARGET_EXEC)
	install -d $(BIN_DIR)
	install -t $(BIN_DIR) $<

run: $(BUILD_DIR)/$(TARGET_EXEC)
	./$<

-include $(DEPS)

MKDIR_P ?= mkdir -p
