ifeq (${shell uname}, Darwin)
    PASS_EXTENSION=dylib
else
    PASS_EXTENSION=so
endif

LLVM=${shell cat ./llvm_path.txt}
BUILD=./build
PASS=${BUILD}/ExamplePass/ExamplePass.${PASS_EXTENSION}
PASS_NAME=example
TEST_FILE_C=./resources/test.c
TEST_FILE_OUT=${BUILD}/test.out
TEST_FILE_LL=${BUILD}/test.ll 

.PHONY: all
all: 	generate-pass \
		build-pass \
		run-clang \
		run-opt

.PHONY: help
help:
	@echo "Targets:"
	@sed -nr 's/^.PHONY:(.*)/\1/p' ${MAKEFILE_LIST}

.PHONY: clean
clean:
	@echo "Cleaning..."
	@rm -rdf ${BUILD}

.PHONY: generate-pass
generate-pass:
	@echo "Generating Pass Plugin..."
	@cmake -G Ninja -S . -B ${BUILD} -DLLVM_DIR=${LLVM}/lib/cmake/llvm
	@echo

.PHONY: build-pass
build-pass: generate-pass
	@echo "Building Pass Plugin..."
	@cmake --build ${BUILD}
	@echo

.PHONY: run-clang
run-clang: build-pass
	@echo "Running clang..."
	@${LLVM}/bin/clang -O1 -fpass-plugin=${PASS} ${TEST_FILE_C} -o ${TEST_FILE_OUT}
	@echo

.PHONY: run-opt
run-opt: build-pass
	@echo "Running opt..."
	@${LLVM}/bin/clang -O1 -S -emit-llvm ${TEST_FILE_C} -o ${TEST_FILE_LL}
	@${LLVM}/bin/opt -load-pass-plugin ${PASS} -passes=${PASS_NAME} -disable-output ${TEST_FILE_LL}
	@echo
