/* 
   Grammar definition taken from 
   http://www.quut.com/c/ANSI-C-grammar-l-2011.html
 */ 

%e  1019
%p  2807
%n  371
%k  284
%a  1213
%o  1117

O   [0-7]
D   [0-9]
NZ  [1-9]
L   [a-zA-Z_]
A   [a-zA-Z_0-9]
H   [a-fA-F0-9]
HP  (0[xX])
E   ([Ee][+-]?{D}+)
P   ([Pp][+-]?{D}+)
FS  (f|F|l|L)
IS  (((u|U)(l|L|ll|LL)?)|((l|L|ll|LL)(u|U)?))
CP  (u|U|L)
SP  (u8|u|U|L)
ES  (\\(['"\?\\abfnrtv]|[0-7]{1,3}|x[a-fA-F0-9]+))
WS  [ \t\v\n\f]

%{
enum types_t{
IDENTIFIER,
ENUMERATION_CONSTANT,
TYPEDEF_NAME,
INCLUDE
}types;

enum error_s{
EOPT=1,
EOUTPUT,
EPARSEERR
} errors;

unsigned int line_num = 1;

#include <stdio.h>
#include <string.h>
#define sym_type(identifier) IDENTIFIER /* with no symbol table, fake it */

static void comment(void);
static int check_type(void);
%}

%%
"/*"                                    { comment(); }
"//".*                                    { /* consume //-comment */ }

"auto"					{ show_token();}
"break"					{ show_token();}
"case"					{ show_token();}
"char"					{ show_token();}
"const"					{ show_token();}
"continue"				{ show_token();}
"default"				{ show_token();}
"do"					{ show_token();}
"double"				{ show_token();}
"else"					{ show_token();}
"enum"					{ show_token();}
"extern"				{ show_token();}
"float"					{ show_token();}
"for"					{ show_token();}
"goto"					{ show_token();}
"if"					{ show_token();}
"inline"				{ show_token();}
"int"					{ show_token();}
"long"					{ show_token();}
"register"				{ show_token();}
"restrict"				{ show_token();}
"return"				{ show_token();}
"short"					{ show_token();}
"signed"				{ show_token();}
"sizeof"				{ show_token();}
"static"				{ show_token();}
"struct"				{ show_token();}
"switch"				{ show_token();}
"typedef"				{ show_token();}
"union"					{ show_token();}
"unsigned"				{ show_token();}
"void"					{ show_token();}
"volatile"				{ show_token();}
"while"					{ show_token();}
"_Alignas"                              { show_token();}
"_Alignof"                              { show_token();}
"_Atomic"                               { show_token();}
"_Bool"                                 { show_token();}
"_Complex"                              { show_token();}
"_Generic"                              { show_token();}
"_Imaginary"                            { show_token();}
"_Noreturn"                             { show_token();}
"_Static_assert"                        { show_token();}
"_Thread_local"                         { show_token();}
"__func__"                              { show_token();}

{L}{A}*					{ check_type(); }

{HP}{H}+{IS}?				{ show_token();}
{NZ}{D}*{IS}?				{ show_token();}
"0"{O}*{IS}?				{ show_token();}
{CP}?"'"([^'\\\n]|{ES})+"'"		{ show_token();}

{D}+{E}{FS}?				{ show_token();}
{D}*"."{D}+{E}?{FS}?			{ show_token();}
{D}+"."{E}?{FS}?			{ show_token();}
{HP}{H}+{P}{FS}?			{ show_token();}
{HP}{H}*"."{H}+{P}{FS}?			{ show_token();}
{HP}{H}+"."{P}{FS}?			{ show_token();}

({SP}?\"([^"\\\n]|{ES})*\"{WS}*)+	{ show_token();}

"\n"                                    { line_num++; } 
"..."					{ show_token();}
">>="					{ show_token();}
"<<="					{ show_token();}
"+="					{ show_token();}
"-="					{ show_token();}
"*="					{ show_token();}
"/="					{ show_token();}
"%="					{ show_token();}
"&="					{ show_token();}
"^="					{ show_token();}
"|="					{ show_token();}
">>"					{ show_token();}
"<<"					{ show_token();}
"++"					{ show_token();}
"--"					{ show_token();}
"->"					{ show_token();}
"&&"					{ show_token();}
"||"					{ show_token();}
"<="					{ show_token();}
">="					{ show_token();}
"=="					{ show_token();}
"!="					{ show_token();}
";"					{ show_token();}
("{"|"<%")				{ show_token();}
("}"|"%>")				{ show_token();}
","					{ show_token();}
":"					{ show_token();}
"="					{ show_token();}
"("					{ show_token();}
")"					{ show_token();}
("["|"<:")				{ show_token();}
("]"|":>")				{ show_token();}
"."					{ show_token();}
"&"					{ show_token();}
"!"					{ show_token();}
"~"					{ show_token();}
"-"					{ show_token();}
"+"					{ show_token();}
"*"					{ show_token();}
"/"					{ show_token();}
"%"					{ show_token();}
"<"					{ show_token();}
">"					{ show_token();}
"^"					{ show_token();}
"|"					{ show_token();}
"?"					{ show_token();}

{WS}					{ /* whitespace separates tokens */ }
.					{ /* discard bad characters */ }

\#{WS}*define{WS}{L}{A}* 	        { /* #define */
                                         char	*s;
                                        defines(yytext, strlen(yytext));
                                        }
\#{WS}*include{WS}*["<][^"> \t\n]+	{ /* #include file */
                                         char	*s;
			
		       			s = strpbrk(yytext, "\"<");
                                        
					if (!s) return(-EPARSEERR);
                                        include_file(s+1, strlen(s));
                                        }
%%

int yywrap(void)        /* called at end of input */
{
    return 1;           /* terminate now */
}

void yyerror(const char *s)
{
#ifdef DEBUG
	fflush(yyout);
	fprintf(yyout, "*** %s\n", s);
#endif 
}

int
defines(char *s, int len)
{
#ifdef DEBUG
     fflush(yyout);
     fprintf(yyout,"DEFINE :%s\n",s);
#endif 
}

int
include_file(char *s, int len)
{
#ifdef DEBUG
     fflush(yyout);
     fprintf(yyout,"INCLUDE file :%s\n",s);
#endif 
}

int show_token()
{
#ifdef DEBUG
    fflush(yyout);
    fprintf(yyout,"Token:%s:%d \n", yytext, line_num);
#endif 
}

static void comment(void)
{
    int c;

    while ((c = input()) != 0)
        if (c == '*')
        {
            while ((c = input()) == '*')
                ;

            if (c == '/')
                return;

            if (c == 0)
                break;
        }
    yyerror("unterminated comment");
}

static int check_type(void)
{
    fflush(yyout);
    switch (sym_type(yytext))
    {
    case TYPEDEF_NAME:                /* previously defined */
#ifdef DEBUG
        fprintf(yyout,"%s:%d is an TYPEDEF_NAME\n", yytext, line_num);
#endif 
        return TYPEDEF_NAME;
    case ENUMERATION_CONSTANT:        /* previously defined */
#ifdef DEBUG
        fprintf(yyout,"%s:%d is an ENUM\n", yytext, line_num);
#endif 
        return ENUMERATION_CONSTANT;
    default:                          /* includes undefined */
#ifdef DEBUG
        fprintf(yyout,"%s:%d is an IDENTIFIER\n", yytext, line_num);
#endif 
        return IDENTIFIER;
    }
}

#ifdef LIBRARY
int 
parser(int argc, char **argv)
#else 
int 
main(int argc, char **argv)
#endif 
{
  int out;

  if (argc < 2 ) {
    printf("Usage parser <c file, header file> [output file]\n");
    return -EOPT;
  }

  if (argv[2] != NULL) {
     /* The earlier output file will be overwritten */
     yyout = fopen(argv[2],"w");
     if (yyout == NULL) {
       printf("\n Unable to open output file : %s\n", argv[2]);
       return -EOUTPUT;
     }
  }

  yyin = fopen(argv[1],"r");
  if (yyin == NULL) {
    printf("\n Unable to  open file %s", argv[1]);
  }
  
  out = yylex();
   
  fclose(yyin);
  fclose(yyout);

  return out;
}

