/*
 *  The scanner definition for COOL.
 */

import java_cup.runtime.Symbol;

%%

%{

/*  Stuff enclosed in %{ %} is copied verbatim to the lexer class
 *  definition, all the extra variables/functions you want to use in the
 *  lexer actions should go here.  Don't remove or modify anything that
 *  was there initially.  */

    // Max size of string constants
    static int MAX_STR_CONST = 1025;

    // Countint BLOCK_COMMENT layer
    int bc_layer = 0;

    // For assembling string constants
    StringBuffer string_buf = new StringBuffer();

    private int curr_lineno = 1;
    int get_curr_lineno() {
	    return curr_lineno;
    }

    private AbstractSymbol filename;

    void set_filename(String fname) {
	    filename = AbstractTable.stringtable.addString(fname);
    }

    AbstractSymbol curr_filename() {
	    return filename;
    }
%}

%init{

/*  Stuff enclosed in %init{ %init} is copied verbatim to the lexer
 *  class constructor, all the extra initialization you want to do should
 *  go here.  Don't remove or modify anything that was there initially. */

    // empty for now
%init}

%eofval{
/*  Stuff enclosed in %eofval{ %eofval} specifies java code that is
 *  executed when end-of-file is reached.  If you use multiple lexical
 *  states and want to do something special if an EOF is encountered in
 *  one of those states, place your code in the switch statement.
 *  Ultimately, you should return the EOF symbol, or your lexer won't
 *  work.  */

    switch(yystate()) {
      case YYINITIAL:
	      /* nothing special to do in the initial state */
	      break;

      case BLOCK_COMMENT:
         yybegin(YYINITIAL);
         return new Symbol(TokenConstants.ERROR, "EOF in comment");
      
      case STRING:
         yybegin(YYINITIAL);
         return new Symbol(TokenConstants.ERROR, "EOF in string constant");
    }

    return new Symbol(TokenConstants.EOF);

%eofval}

/* Definitions */

%class CoolLexer
%cup

%state INLINE_COMMENT
%state BLOCK_COMMENT
%state STRING


INTEGERS = [0-9]+
TYPE_ID = [A-Z][a-zA-Z0-9_]*
OBJECT_ID = [a-z][a-zA-Z0-9_]*
/* WHITE_SPACE = [ \f\r\v\t]+ */
WHITE_SPACE = [ \f\r\t]+


%%

/* Rules */

/* inline comments */
<YYINITIAL>"--"                  { yybegin(INLINE_COMMENT); }
<INLINE_COMMENT>[^\n]            { }
<INLINE_COMMENT>\n               { curr_lineno++; yybegin(YYINITIAL); }


/* block comments */
<YYINITIAL>"*)"                  { return new Symbol(TokenConstants.ERROR, "Unmatched *)"); }
<YYINITIAL>"(*"                  { yybegin(BLOCK_COMMENT); }
<BLOCK_COMMENT>"(*"              { bc_layer++; }
<BLOCK_COMMENT>\n                { curr_lineno++; /* New Line */ }
<BLOCK_COMMENT>[^\0]             { } 
<BLOCK_COMMENT>"*)" {
   if(bc_layer > 0) {
      bc_layer--;
   } else {
      yybegin(YYINITIAL);
   }
}

/* String */
<YYINITIAL>"\""   { string_buf.setLength(0); yybegin(STRING); }

/*
<STRING>[\\][b] {
   if(string_buf.length() > MAX_STR_CONST) return new Symbol(TokenConstants.ERROR, "String constant too lang");
   string_buf.append('\b');   
}
<STRING>[\\][t] {
   if(string_buf.length() > MAX_STR_CONST) return new Symbol(TokenConstants.ERROR, "String constant too lang"); 
   string_buf.append('\t');
}

<STRING>[\\][n] {
   if(string_buf.length() > MAX_STR_CONST) return new Symbol(TokenConstants.ERROR, "String constant too lang");
   string_buf.append('\n'); 
}

<STRING>[\\][f] {
   if(string_buf.length() > MAX_STR_CONST) return new Symbol(TokenConstants.ERROR, "String constant too lang"); 
   string_buf.append('\f');
}
*/

<STRING>[\\][nbtf] {
   if(string_buf.length() > MAX_STR_CONST) return new Symbol(TokenConstants.ERROR, "String constant too lang");
   switch(yytext()) {
      case "\\n": string_buf.append('\n'); break;
      case "\\b": string_buf.append('\b'); break;
      case "\\t": string_buf.append('\t'); break;
      case "\\f": string_buf.append('\f'); break;
   }
}

/* an eascaped newline, lineno ++ */
<STRING>\\\n {
   if(string_buf.length() > MAX_STR_CONST) return new Symbol(TokenConstants.ERROR, "String constant too lang");
   curr_lineno++;
   string_buf.append('\n'); 
}

/* "\c" => character 'c' */
<STRING>\\[^btnf\0] {
   if(string_buf.length() > MAX_STR_CONST) return new Symbol(TokenConstants.ERROR, "String constant too lang");
   /* TODO */
   string_buf.append(yytext().substring(yytext().indexOf('\\')+1));
}

<STRING>\0 { 
   yybegin(YYINITIAL); 
   return new Symbol(TokenConstants.ERROR, "String contains null character"); 
}

/* an unescaped newline */
<STRING>\n {
   yybegin(YYINITIAL);
   curr_lineno++;
   return new Symbol(TokenConstants.ERROR, "Unterminated string constant");
}

/* String Ends */
<STRING>"\"" { 
   yybegin(YYINITIAL);
   return new Symbol(TokenConstants.STR_CONST, AbstractTable.stringtable.addString(string_buf.toString()));
}

/* characters */
<STRING>[^\0] {
   if(string_buf.length() > MAX_STR_CONST) return new Symbol(TokenConstants.ERROR, "String constant too lang");
   string_buf.append(yytext()); 
}


/* Keywords [cC] => {"c","C"} */
<YYINITIAL>[cC][lL][aA][sS][sS]  { return new Symbol(TokenConstants.CLASS); }
<YYINITIAL>[eE][lL][sS][eE]      { return new Symbol(TokenConstants.ELSE); }
<YYINITIAL>[f][aA][lL][sS][eE]   { return new Symbol(TokenConstants.BOOL_CONST, new Boolean(false)); }
<YYINITIAL>[fF][iI]              { return new Symbol(TokenConstants.FI); }
<YYINITIAL>[iI][fF]              { return new Symbol(TokenConstants.IF); }
<YYINITIAL>[iI][nN]              { return new Symbol(TokenConstants.IN); }
<YYINITIAL>[iI][nN][hH][eE][rR][iI][tT][sS]  { return new Symbol(TokenConstants.INHERITS); }
<YYINITIAL>[iI][sS][vV][oO][iI][dD]          { return new Symbol(TokenConstants.ISVOID); }
<YYINITIAL>[lL][eE][tT]          { return new Symbol(TokenConstants.LET); }
<YYINITIAL>[lL][oO][oO][pP]      { return new Symbol(TokenConstants.LOOP); }
<YYINITIAL>[pP][oO][oO][lL]      { return new Symbol(TokenConstants.POOL); }
<YYINITIAL>[tT][hH][eE][nN]      { return new Symbol(TokenConstants.THEN); }
<YYINITIAL>[wW][hH][iI][lL][eE]  { return new Symbol(TokenConstants.WHILE); }
<YYINITIAL>[cC][aA][sS][eE]      { return new Symbol(TokenConstants.CASE); }
<YYINITIAL>[eE][sS][aA][cC]      { return new Symbol(TokenConstants.ESAC); }
<YYINITIAL>[nN][eE][wW]          { return new Symbol(TokenConstants.NEW); }
<YYINITIAL>[oO][fF]              { return new Symbol(TokenConstants.OF); }
<YYINITIAL>[nN][oO][tT]          { return new Symbol(TokenConstants.NOT); }
<YYINITIAL>[t][rR][uU][eE]       { return new Symbol(TokenConstants.BOOL_CONST, new Boolean(true)); }

<YYINITIAL>"+"                   { return new Symbol(TokenConstants.PLUS); }
<YYINITIAL>"/"                   { return new Symbol(TokenConstants.DIV); }
<YYINITIAL>"-"                   { return new Symbol(TokenConstants.MINUS); }
<YYINITIAL>"*"                   { return new Symbol(TokenConstants.MULT); }
<YYINITIAL>"="                   { return new Symbol(TokenConstants.EQ); } 
<YYINITIAL>"<"                   { return new Symbol(TokenConstants.LT); }
<YYINITIAL>"."                   { return new Symbol(TokenConstants.DOT); }
<YYINITIAL>"~"                   { return new Symbol(TokenConstants.NEG); }
<YYINITIAL>","                   { return new Symbol(TokenConstants.COMMA); }
<YYINITIAL>";"                   { return new Symbol(TokenConstants.SEMI); }
<YYINITIAL>":"                   { return new Symbol(TokenConstants.COLON); }
<YYINITIAL>"("                   { return new Symbol(TokenConstants.LPAREN); }
<YYINITIAL>")"                   { return new Symbol(TokenConstants.RPAREN); }
<YYINITIAL>"@"                   { return new Symbol(TokenConstants.AT); }
<YYINITIAL>"{"                   { return new Symbol(TokenConstants.LBRACE); }
<YYINITIAL>"}"                   { return new Symbol(TokenConstants.RBRACE); }
<YYINITIAL>"=>"			         { return new Symbol(TokenConstants.DARROW); }
<YYINITIAL>"<-"                  { return new Symbol(TokenConstants.ASSIGN); }
<YYINITIAL>"<="                  { return new Symbol(TokenConstants.LE); }

<YYINITIAL>{INTEGERS}            { return new Symbol(TokenConstants.INT_CONST, AbstractTable.inttable.addString(yytext())); }

<YYINITIAL>{OBJECT_ID}           { return new Symbol(TokenConstants.OBJECTID, AbstractTable.inttable.addString(yytext())); }

<YYINITIAL>{TYPE_ID}             { return new Symbol(TokenConstants.TYPEID, AbstractTable.inttable.addString(yytext())); }

<YYINITIAL>{WHITE_SPACE}         { /* Do Noting */ }

<YYINITIAL>\n                    { curr_lineno++; /* New Line */ }

.                                { return new Symbol(TokenConstants.ERROR, yytext()); }

/*
.                               { /* This rule should be the very last
                                     in your lexical specification and
                                     will match match everything not
                                     matched by other lexical rules. */
                                  System.err.println("LEXER BUG - UNMATCHED: " + yytext()); }
*/

