default:
	lex c.l
	gcc -shared -Wl,-soname,libparser.so -o libparser.so -fPIC -g -DDEBUG -DLIBRARY lex.yy.c -lfl
#	gcc -o parser -g -DDEBUG lex.yy.c -lfl
clean:
	rm -rf *.c *.h *.so parser
