# file "makefile  © P. Cousot 2024 "
# screen -L make will create "screenlog.0" renamed "typescript"


.PHONY: all
all: clean compile examples

.PHONY: compile
compile: 
	ocamllex -q lexer.mll
	ocamlc -c abstractSyntaxExpressions.ml
	ocamlc -c abstractDomain.mli
	ocamlc -c Sign.ml
	ocamlc -c Interval.ml
	ocamlc -c CartesianDomain.ml
	ocamlc -c Upper_bound.ml
	ocamlc -c Pentagons.ml
	ocamlc -c abstractDomain.ml
	ocamlc -c abstractTree.mli
	ocamlc -c abstractSyntax.ml
	ocamlc -c printer.ml
	menhir --infer --explain parser.mly
	ocamlc -c parser.mli
	ocamlc -c lexer.ml
	ocamlc -c parser.ml
	ocamlc -c abstractInterpreter.ml
	ocamlc -c main.ml
	ocamlc abstractSyntaxExpressions.cmo Sign.cmo Interval.cmo CartesianDomain.cmo Upper_bound.cmo Pentagons.cmo abstractDomain.cmo abstractSyntax.cmo printer.cmo parser.cmo lexer.cmo abstractInterpreter.cmo main.cmo -o main
.PHONY: examples
.IGNORE: examples
examples: analyzer
	@echo "*** using the forward abstract interpreter:"
	@echo "**************************************************"
	@echo "*** ;"	
	@echo ";"| ./main
	@echo "**************************************************"
	@echo "*** x = 42;"	
	@echo "x = 42;"| ./main
	@echo "**************************************************"
	@echo "*** x = 7; ; break;"	
	@echo "x = 7; ; break;"| ./main
	@echo "**************************************************"
	@echo "*** {}"	
	@echo "{}" | ./main
	@echo "**************************************************"
	@echo "*** x=-10-20--40;"	
	@echo "x=-10-20--40;" | ./main
	@echo "**************************************************"
	@echo "*** x=1; y=2;"	
	@echo "x=1; y=2;" | ./main
	@echo "**************************************************"
	@echo "*** {x=10; ; y=20;}"	
	@echo "{x=10; ; y=20;}" | ./main
	@echo "**************************************************"
	@echo "*** x=x+1;"	
	@echo "x=x+1;" | ./main
	@echo "**************************************************"
	@echo "*** if (1-2<3-4-5) x=-x;"	
	@echo "if (1-2<3-4-5) x=-x;" | ./main
	@echo "**************************************************"
	@echo "*** if (x<1) if (x<0) x=1; else if (x<0) { x=2; x=3; } else { x=4; x=5; x=6; }"	
	@echo "if (x<1) if (x<0) x=1; else if (x<0) { x=2; x=3; } else { x=4; x=5; x=6; }" | ./main
	@echo "**************************************************"
	@echo "*** while (0>1) {}"	
	@echo "while (0<1) {}" | ./main
	@echo "**************************************************"
	@echo "*** while (x>1) {}"	
	@echo "while (x>1) {}" | ./main
	@echo "**************************************************"
	@echo "*** while (x<1) x=x+1;"	
	@echo "while (x<1) x=x+1;" | ./main
	@echo "**************************************************"
	@echo "*** while (x<3) x=x+1;"	
	@echo "while (x<3) x=x+1;" | ./main
	@echo "**************************************************"
	@echo "*** while (x<10) x=x+1;"	
	@echo "while (x<10) x=x+1;" | ./main
	@echo "**************************************************"
	@echo "*** while (x<3) { x=x+1; if (x>1) break; }"	
	@echo "while (x<3) { x=x+1; if (x>1) break; }" | ./main
	@echo "**************************************************"
	@echo "*** while (x<3) { if (x>1) break; else x=x+1; }"	
	@echo "while (x<3) { if (x>1) break; else x=x+1; }" | ./main
	@echo "**************************************************"
	@echo "*** x=x-1;while (0<1){x=x-1;if(x<2)break;};"	
	@echo "x=x-1;while (0<1){x=x-1;if(x<2)break;};" | ./main
	@echo "**************************************************"
	@echo "*** x=0; while (x<0) { while (x<0) x=x-1; x= 10; }; x= 100;"	
	@echo "x=0; while (x<0) { while (x<0) x=x-1; x= 10; }; x= 100;" | ./main
	@echo "**************************************************"
	@echo "*** x=-10; while (x<0) if (x<0) if (0<x) x=-x;"	
	@echo "x=-10; while (x<0) if (x<0) if (0<x) x=-x;" | ./main
	@echo "**************************************************"
	@echo "*** x=0; while (x<0) { while (x<0) x=x-1; break; }; x= 100;"	
	@echo "x=0; while (x<0) { while (x<0) x=x-1; break; }; x= 100;" | ./main
	@echo "**************************************************"
	@echo "*** x=-10; while (x<0) { x=x-1; break; }; x= 10;"	
	@echo "x=-10; while (x<0) { x=x-1; break; }; x= 10;" | ./main
	@echo "**************************************************"
	@echo "*** x=10; while (x>0) x=x-1;"	
	@echo "x=10; while (x>0) x=x-1;" | ./main
	@echo "**************************************************"
	@echo "*** while (0<1){ break; x=1; }"	
	@echo "while (0<1){ break; x=1; }" | ./main
	@echo "**************************************************"
	@echo "*** while (x!=2) { if (x==0) break; if (x==1) break; }"	
	@echo "while (x!=2) { if (x==0) break; if (x==1) break; }" | ./main
	@echo "**************************************************"
	@echo "# end"

.PHONY: nonterminating
nonterminating:
	@echo "**************************************************"
	@echo "*** while (0<1){}"	
	@echo "while (0<1){}" | ./main
	@echo "**************************************************"
	@echo "*** while (0<1){x=x-1;} x = 42;"	
	@echo "while (0<1){x=x-1;} x = 42;" | ./main
	@echo "**************************************************"
	@echo "# end"

.PHONY: clean
clean: 
	@/bin/rm -f main *~ .*~ *.cmo *.cmi lexer.ml parser.ml parser.mli parser.conflicts
# erase all symbolic links
#	@find . -lname '*.*' -delete

.PHONY: help
help:
	@echo "******************************************************************"	
	@echo "make: compile and run the examples"
	@echo "make compile: compile"
	@echo "make examples: run the examples (after compilation)"
	@echo "make nonterminating: run a nonterminating example (^C to stop)"
	@echo "make clean: delete all auxiliary files"
	@echo "make help: this help"
	@echo "******************************************************************"

main_interval:
	cp abstractDomain_interval.ml abstractDomain.ml
	$(MAKE) compile
	cp main main_interval

main_sign:
	cp abstractDomain_sign.ml abstractDomain.ml
	$(MAKE) compile
	cp main main_sign

main_pentagon:
	cp abstractDomain_pentagon.ml abstractDomain.ml
	$(MAKE) compile
	cp main main_pentagon

main_sub:
	cp abstractDomain_sub.ml abstractDomain.ml
	$(MAKE) compile
	cp main main_sub


analyzer: main_interval main_sign main_pentagon main_sub
	@echo '#!/bin/bash' > analyzer
	@echo 'case "$$1" in' >> analyzer
	@echo '  --sign)     shift; ./main_sign "$$@" ;;' >> analyzer
	@echo '  --pentagon) shift; ./main_pentagon "$$@" ;;' >> analyzer
	@echo '  --sub) shift; ./main_sub "$$@" ;;' >> analyzer
	@echo '  *)          ./main_interval "$$@" ;;' >> analyzer
	@echo 'esac' >> analyzer
	chmod +x analyzer

.PHONY: all compile examples nonterminating clean help main_interval main_sign main_pentagon main_sub analyzer
.PHONY: all
all: clean main_interval main_sign main_pentagon main_sub analyzer examples