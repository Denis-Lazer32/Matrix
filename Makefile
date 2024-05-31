CC=g++ -std=c++17 -Wall -Werror -Wextra -pedantic -g
CHECKFLAGS=-lgtest
REPORTDIR=gcov_report
GCOV=--coverage
OS = $(shell uname)

all: s21_matrix_oop.a test gcov_report

s21_matrix_oop.a:
	$(CC) -c s21_matrix_oop.cpp -o s21_matrix_oop.o
	ar rcs s21_matrix_oop.a s21_matrix_oop.o

test: clean
	$(CC) $(GCOV) -c s21_matrix_oop.cpp 
	$(CC) -c s21_matrix_test.cpp $(CHECKFLAGS)
	$(CC) $(GCOV) -o s21_matrix_test s21_matrix_test.o s21_matrix_oop.o $(CHECKFLAGS)
	./s21_matrix_test

check:
	cppcheck *.cpp && cppcheck --enable=all --language=c++ *.h

linters: 
	# cp ../materials/linters/clang-format .
	clang-format -i *.cpp *.h
	#rm clang-format

linters_check:
	clang-format -n *.cpp *.h

leaks: s21_matrix_test
ifeq ($(OS), Linux)
	CK_FORK=no valgrind --tool=memcheck --leak-check=full ./s21_matrix_test
else
	leaks -atExit -- ./s21_matrix_test
endif

gcov_report: s21_matrix_test
	lcov -t "Unit-tests of matrix_oop" -o s21_matrix_oop.info -c -d .
	genhtml -o $(REPORTDIR) s21_matrix_oop.info
ifeq ($(OS), Linux)
	xdg-open ./gcov_report/index.html
else
	open -a "Safari" ./$(REPORTDIR)/index.html
endif

clean:
	rm -rf ./*.o ./*.a ./a.out ./*.gcno ./*.gcda ./$(REPORTDIR) *.info ./*.info report s21_matrix_test s21_matrix_oop