
%{
#include <stdio.h>
#include <stdlib.h>

int errors = 0;
%}

%option noyywrap
%option yylineno

DIGIT       [0-9]
LETTER      [a-zA-Z_]
ID          {LETTER}({LETTER}|{DIGIT})*
INT         {DIGIT}+
FLOAT       {DIGIT}+\.{DIGIT}+

%%

^[ \t]*#[^\n]*              { }

[ \t\r\n]+                  { }


"//"[^\n]*                  { }


"/*"([^*]|\*+[^*/])*"*/"   { }


"/*"([^*]|\*+[^*/])*\**     {
                                int start_line = yylineno;
                                int i;

                                for (i = 0; i < yyleng; i++) {
                                    if (yytext[i] == '\n')
                                        start_line--;
                                }

                                printf("Line %d: ERROR - Unterminated comment\n",
                                       start_line);
                                errors++;
                            }

"int"|"float"|"double"|"char"|"void"|"if"|"else"|"while"|"for"|"return"|"break"|"continue"|"do"|"switch"|"case"|"default"|"const" {
                                printf("Line %d: KEYWORD - %s\n", yylineno, yytext);
                            }

\"([^\"\\\n]|\\.)*\"        {
                                printf("Line %d: STRING - %s\n", yylineno, yytext);
                            }

\"([^\"\\\n]|\\.)*          {
                                printf("Line %d: ERROR - Unterminated string: %s\n",
                                       yylineno, yytext);
                                errors++;
                            }

{FLOAT}                     {
                                printf("Line %d: FLOAT - %s\n", yylineno, yytext);
                            }

{DIGIT}+{LETTER}({LETTER}|{DIGIT})* {
                                printf("Line %d: ERROR - Invalid number: %s\n",
                                       yylineno, yytext);
                                errors++;
                            }

{INT}                       {
                                printf("Line %d: INTEGER - %s\n", yylineno, yytext);
                            }

{ID}                        {
                                printf("Line %d: IDENTIFIER - %s\n", yylineno, yytext);
                            }

"=="|"!="|"<="|">="|"&&"|"||"|"++"|"--"|"+="|"-="|"*="|"/="|"%=" {
                                printf("Line %d: OPERATOR - %s\n", yylineno, yytext);
                            }

[+\-*/%=<>!&|^~]            {
                                printf("Line %d: OPERATOR - %s\n", yylineno, yytext);
                            }

[(){}\[\];,.:]              {
                                printf("Line %d: DELIMITER - %s\n", yylineno, yytext);
                            }

.                           {
                                printf("Line %d: ERROR - Invalid character: %s\n",
                                       yylineno, yytext);
                                errors++;
                            }

%%

int main()
{
    printf("========== LEXICAL ANALYSIS ==========\n");
    yylex();

    printf("\nTotal Errors: %d\n", errors);

    return 0;
}
