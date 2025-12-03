
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton implementation for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Bison version.  */
#define YYBISON_VERSION "2.4.1"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1

/* Using locations.  */
#define YYLSP_NEEDED 0



/* Copy the first part of user declarations.  */

/* Line 189 of yacc.c  */
#line 1 "lrparser.y"

    #include <stdio.h>
    #include "ast.h"
    int yylex(void);
    void yyerror(char *s);
    extern int type;


/* Line 189 of yacc.c  */
#line 82 "lrparser.tab.c"

/* Enabling traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 0
#endif

/* Enabling the token table.  */
#ifndef YYTOKEN_TABLE
# define YYTOKEN_TABLE 0
#endif


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     num_INT = 258,
     Y_INT = 259,
     Y_VOID = 260,
     Y_CONST = 261,
     Y_IF = 262,
     Y_ELSE = 263,
     Y_WHILE = 264,
     Y_BREAK = 265,
     Y_CONTINUE = 266,
     Y_FLOAT = 267,
     Y_RETURN = 268,
     Y_ADD = 269,
     Y_COMMA = 270,
     Y_DIV = 271,
     Y_LPAR = 272,
     Y_SUB = 273,
     Y_LSQUARE = 274,
     Y_MODULO = 275,
     Y_MUL = 276,
     Y_NOT = 277,
     Y_RPAR = 278,
     Y_RSQUARE = 279,
     Y_RBRACKET = 280,
     Y_LESS = 281,
     Y_LESSEQ = 282,
     Y_GREAT = 283,
     Y_GREATEQ = 284,
     Y_NOTEQ = 285,
     Y_EQ = 286,
     Y_AND = 287,
     Y_OR = 288,
     Y_ASSIGN = 289,
     Y_LBRACKET = 290,
     Y_SEMICOLON = 291,
     num_FLOAT = 292,
     Y_ID = 293,
     YYEOF = 294
   };
#endif



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 214 of yacc.c  */
#line 10 "lrparser.y"

    int token;
    int int_value;
    float float_value;
    char* id_name;
    past pAst;



/* Line 214 of yacc.c  */
#line 167 "lrparser.tab.c"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif


/* Copy the second part of user declarations.  */


/* Line 264 of yacc.c  */
#line 179 "lrparser.tab.c"

#ifdef short
# undef short
#endif

#ifdef YYTYPE_UINT8
typedef YYTYPE_UINT8 yytype_uint8;
#else
typedef unsigned char yytype_uint8;
#endif

#ifdef YYTYPE_INT8
typedef YYTYPE_INT8 yytype_int8;
#elif (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
typedef signed char yytype_int8;
#else
typedef short int yytype_int8;
#endif

#ifdef YYTYPE_UINT16
typedef YYTYPE_UINT16 yytype_uint16;
#else
typedef unsigned short int yytype_uint16;
#endif

#ifdef YYTYPE_INT16
typedef YYTYPE_INT16 yytype_int16;
#else
typedef short int yytype_int16;
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif ! defined YYSIZE_T && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned int
# endif
#endif

#define YYSIZE_MAXIMUM ((YYSIZE_T) -1)

#ifndef YY_
# if YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(msgid) dgettext ("bison-runtime", msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(msgid) msgid
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YYUSE(e) ((void) (e))
#else
# define YYUSE(e) /* empty */
#endif

/* Identity function, used to suppress warnings about constant conditions.  */
#ifndef lint
# define YYID(n) (n)
#else
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static int
YYID (int yyi)
#else
static int
YYID (yyi)
    int yyi;
#endif
{
  return yyi;
}
#endif

#if ! defined yyoverflow || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#     ifndef _STDLIB_H
#      define _STDLIB_H 1
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's `empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (YYID (0))
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined _STDLIB_H \
       && ! ((defined YYMALLOC || defined malloc) \
	     && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef _STDLIB_H
#    define _STDLIB_H 1
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* ! defined yyoverflow || YYERROR_VERBOSE */


#if (! defined yyoverflow \
     && (! defined __cplusplus \
	 || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yytype_int16 yyss_alloc;
  YYSTYPE yyvs_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (yytype_int16) + sizeof (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

/* Copy COUNT objects from FROM to TO.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(To, From, Count) \
      __builtin_memcpy (To, From, (Count) * sizeof (*(From)))
#  else
#   define YYCOPY(To, From, Count)		\
      do					\
	{					\
	  YYSIZE_T yyi;				\
	  for (yyi = 0; yyi < (Count); yyi++)	\
	    (To)[yyi] = (From)[yyi];		\
	}					\
      while (YYID (0))
#  endif
# endif

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)				\
    do									\
      {									\
	YYSIZE_T yynewbytes;						\
	YYCOPY (&yyptr->Stack_alloc, Stack, yysize);			\
	Stack = &yyptr->Stack_alloc;					\
	yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAXIMUM; \
	yyptr += yynewbytes / sizeof (*yyptr);				\
      }									\
    while (YYID (0))

#endif

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  18
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   420

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  40
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  37
/* YYNRULES -- Number of rules.  */
#define YYNRULES  126
/* YYNRULES -- Number of states.  */
#define YYNSTATES  242

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   294

#define YYTRANSLATE(YYX)						\
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const yytype_uint16 yyprhs[] =
{
       0,     0,     3,     6,     9,    12,    15,    17,    19,    21,
      23,    25,    29,    34,    37,    41,    43,    47,    50,    55,
      61,    65,    70,    72,    76,    79,    83,    89,    95,    99,
     104,   109,   113,   117,   121,   126,   130,   135,   137,   140,
     144,   149,   152,   156,   158,   164,   171,   173,   177,   180,
     185,   189,   195,   197,   199,   201,   206,   208,   211,   213,
     219,   225,   233,   239,   247,   255,   263,   266,   269,   273,
     276,   281,   283,   286,   288,   294,   300,   308,   314,   322,
     330,   338,   341,   344,   348,   351,   355,   358,   360,   363,
     365,   367,   369,   373,   377,   381,   385,   387,   391,   395,
     397,   401,   403,   407,   409,   411,   415,   419,   421,   425,
     429,   433,   435,   439,   444,   447,   450,   453,   455,   459,
     463,   465,   467,   469,   471,   473,   478
};

/* YYRHS -- A `-1'-separated list of the rules' RHS.  */
static const yytype_int8 yyrhs[] =
{
      41,     0,    -1,    42,    39,    -1,    46,    42,    -1,    49,
      42,    -1,    56,    42,    -1,    43,    -1,    56,    -1,    46,
      -1,    49,    -1,    44,    -1,    59,    46,    36,    -1,    59,
      46,    45,    36,    -1,    15,    46,    -1,    15,    46,    45,
      -1,    38,    -1,    38,    34,    47,    -1,    38,    52,    -1,
      38,    52,    34,    47,    -1,    59,    38,    34,    47,    36,
      -1,    59,    38,    36,    -1,    59,    38,    52,    36,    -1,
      69,    -1,    69,    15,    69,    -1,    35,    25,    -1,    35,
      69,    25,    -1,    35,    69,    15,    69,    25,    -1,    35,
      48,    15,    48,    25,    -1,    47,    15,    47,    -1,     6,
      59,    51,    36,    -1,     6,    59,    50,    36,    -1,    51,
      15,    51,    -1,    50,    15,    51,    -1,    38,    34,    53,
      -1,    38,    52,    34,    53,    -1,    19,    55,    24,    -1,
      19,    55,    24,    52,    -1,    55,    -1,    35,    25,    -1,
      35,    53,    25,    -1,    35,    53,    54,    25,    -1,    15,
      53,    -1,    15,    53,    54,    -1,    70,    -1,    59,    38,
      17,    23,    62,    -1,    59,    38,    17,    57,    23,    62,
      -1,    58,    -1,    57,    15,    58,    -1,    59,    38,    -1,
      59,    38,    19,    24,    -1,    59,    38,    76,    -1,    59,
      38,    19,    24,    76,    -1,     4,    -1,    12,    -1,     5,
      -1,    75,    34,    69,    36,    -1,    36,    -1,    69,    36,
      -1,    62,    -1,     9,    17,    68,    23,    60,    -1,     7,
      17,    68,    23,    62,    -1,     7,    17,    68,    23,    62,
       8,    62,    -1,     7,    17,    68,    23,    61,    -1,     7,
      17,    68,    23,    61,     8,    61,    -1,     7,    17,    68,
      23,    61,     8,    62,    -1,     7,    17,    68,    23,    62,
       8,    61,    -1,    10,    36,    -1,    11,    36,    -1,    13,
      69,    36,    -1,    13,    36,    -1,    75,    34,    69,    36,
      -1,    36,    -1,    69,    36,    -1,    62,    -1,     9,    17,
      68,    23,    60,    -1,     7,    17,    68,    23,    62,    -1,
       7,    17,    68,    23,    62,     8,    62,    -1,     7,    17,
      68,    23,    61,    -1,     7,    17,    68,    23,    61,     8,
      61,    -1,     7,    17,    68,    23,    61,     8,    62,    -1,
       7,    17,    68,    23,    62,     8,    61,    -1,    10,    36,
      -1,    11,    36,    -1,    13,    69,    36,    -1,    13,    36,
      -1,    35,    63,    25,    -1,    35,    25,    -1,    64,    -1,
      64,    63,    -1,    43,    -1,    60,    -1,    70,    -1,    70,
      26,    65,    -1,    70,    28,    65,    -1,    70,    27,    65,
      -1,    70,    29,    65,    -1,    65,    -1,    65,    31,    66,
      -1,    65,    30,    66,    -1,    66,    -1,    66,    32,    67,
      -1,    67,    -1,    67,    33,    68,    -1,    70,    -1,    71,
      -1,    70,    14,    71,    -1,    70,    18,    71,    -1,    72,
      -1,    71,    21,    72,    -1,    71,    16,    72,    -1,    71,
      20,    72,    -1,    74,    -1,    75,    17,    23,    -1,    75,
      17,    73,    23,    -1,    14,    72,    -1,    18,    72,    -1,
      22,    72,    -1,    69,    -1,    69,    15,    73,    -1,    17,
      69,    23,    -1,    75,    -1,     3,    -1,    37,    -1,    38,
      -1,    76,    -1,    76,    19,    69,    24,    -1,    38,    19,
      69,    24,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const yytype_uint8 yyrline[] =
{
       0,    30,    30,    32,    33,    34,    35,    36,    37,    39,
      40,    42,    43,    46,    47,    50,    51,    52,    53,    54,
      55,    56,    59,    60,    61,    62,    63,    64,    67,    69,
      70,    73,    74,    77,    78,    81,    82,    85,    86,    87,
      88,    91,    92,    95,    98,    99,   102,   103,   106,   107,
     108,   109,   112,   113,   114,   117,   118,   119,   120,   121,
     122,   123,   124,   125,   126,   127,   128,   129,   130,   131,
     133,   134,   135,   136,   137,   138,   139,   140,   141,   142,
     143,   144,   145,   146,   147,   148,   149,   152,   153,   156,
     157,   160,   161,   162,   163,   164,   167,   168,   169,   172,
     173,   176,   177,   180,   184,   185,   186,   189,   190,   191,
     192,   195,   196,   197,   198,   199,   200,   203,   204,   207,
     208,   209,   210,   213,   214,   217,   218
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || YYTOKEN_TABLE
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "num_INT", "Y_INT", "Y_VOID", "Y_CONST",
  "Y_IF", "Y_ELSE", "Y_WHILE", "Y_BREAK", "Y_CONTINUE", "Y_FLOAT",
  "Y_RETURN", "Y_ADD", "Y_COMMA", "Y_DIV", "Y_LPAR", "Y_SUB", "Y_LSQUARE",
  "Y_MODULO", "Y_MUL", "Y_NOT", "Y_RPAR", "Y_RSQUARE", "Y_RBRACKET",
  "Y_LESS", "Y_LESSEQ", "Y_GREAT", "Y_GREATEQ", "Y_NOTEQ", "Y_EQ", "Y_AND",
  "Y_OR", "Y_ASSIGN", "Y_LBRACKET", "Y_SEMICOLON", "num_FLOAT", "Y_ID",
  "YYEOF", "$accept", "program", "CompUnit", "Decl", "VarDecl", "VarDecls",
  "VarDef", "InitVal", "InitVals", "ConstDecl", "ConstDefs", "ConstDef",
  "ConstExps", "ConstInitVal", "ConstInitVals", "ConstExp", "FuncDef",
  "FuncParams", "FuncParam", "Type", "Stmt", "Stmt1", "Block",
  "BlockItems", "BlockItem", "RelExp", "EqExp", "LAndExp", "LOrExp", "Exp",
  "AddExp", "MulExp", "UnaryExp", "CallParams", "PrimaryExp", "LVal",
  "ArraySubscripts", 0
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[YYLEX-NUM] -- Internal token number corresponding to
   token YYLEX-NUM.  */
static const yytype_uint16 yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   278,   279,   280,   281,   282,   283,   284,
     285,   286,   287,   288,   289,   290,   291,   292,   293,   294
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_uint8 yyr1[] =
{
       0,    40,    41,    42,    42,    42,    42,    42,    42,    43,
      43,    44,    44,    45,    45,    46,    46,    46,    46,    46,
      46,    46,    47,    47,    47,    47,    47,    47,    48,    49,
      49,    50,    50,    51,    51,    52,    52,    53,    53,    53,
      53,    54,    54,    55,    56,    56,    57,    57,    58,    58,
      58,    58,    59,    59,    59,    60,    60,    60,    60,    60,
      60,    60,    60,    60,    60,    60,    60,    60,    60,    60,
      61,    61,    61,    61,    61,    61,    61,    61,    61,    61,
      61,    61,    61,    61,    61,    62,    62,    63,    63,    64,
      64,    65,    65,    65,    65,    65,    66,    66,    66,    67,
      67,    68,    68,    69,    70,    70,    70,    71,    71,    71,
      71,    72,    72,    72,    72,    72,    72,    73,    73,    74,
      74,    74,    74,    75,    75,    76,    76
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const yytype_uint8 yyr2[] =
{
       0,     2,     2,     2,     2,     2,     1,     1,     1,     1,
       1,     3,     4,     2,     3,     1,     3,     2,     4,     5,
       3,     4,     1,     3,     2,     3,     5,     5,     3,     4,
       4,     3,     3,     3,     4,     3,     4,     1,     2,     3,
       4,     2,     3,     1,     5,     6,     1,     3,     2,     4,
       3,     5,     1,     1,     1,     4,     1,     2,     1,     5,
       5,     7,     5,     7,     7,     7,     2,     2,     3,     2,
       4,     1,     2,     1,     5,     5,     7,     5,     7,     7,
       7,     2,     2,     3,     2,     3,     2,     1,     2,     1,
       1,     1,     3,     3,     3,     3,     1,     3,     3,     1,
       3,     1,     3,     1,     1,     3,     3,     1,     3,     3,
       3,     1,     3,     4,     2,     2,     2,     1,     3,     3,
       1,     1,     1,     1,     1,     4,     4
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const yytype_uint8 yydefact[] =
{
       0,    52,    54,     0,    53,    15,     0,     0,     6,    10,
       8,     9,     7,     0,     0,     0,     0,    17,     1,     2,
       3,     4,     5,    15,     0,     0,     0,     0,     0,   121,
       0,     0,     0,     0,   122,   123,     0,    43,   104,   107,
     111,   120,   124,     0,    16,    22,   103,     0,     0,     0,
      20,    17,     0,    11,     0,     0,     0,     0,     0,    30,
       0,    29,   114,     0,   115,   116,     0,    35,     0,     0,
       0,     0,     0,     0,     0,    24,     0,     0,     0,     0,
      18,     0,     0,    46,     0,    16,    21,    13,    12,     0,
       0,     0,    33,    37,     0,    32,    31,   119,     0,    36,
     105,   106,   109,   110,   108,   112,   117,     0,     0,     0,
       0,     0,    25,    23,     0,    44,     0,     0,    48,    19,
      14,     0,    38,     0,    34,   126,     0,   113,   125,    28,
       0,    23,     0,     0,     0,     0,     0,    86,    56,    89,
       9,     0,    90,    58,     0,    87,     0,   120,    47,    45,
       0,     0,    50,     0,    39,     0,   118,    27,    26,     0,
       0,    66,    67,    69,     0,    85,    88,    57,     0,    49,
      41,    40,    96,    99,   101,     0,    91,     0,    68,     0,
      51,    42,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    55,    98,    97,   100,   102,     0,     0,     0,
       0,     0,    71,    62,    60,     0,   120,    92,    94,    93,
      95,    59,     0,     0,    81,    82,    84,     0,     0,     0,
      72,     0,     0,     0,    83,    63,    64,    65,    61,     0,
       0,     0,    70,    77,    73,    74,     0,     0,    78,    73,
      80,    73
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
      -1,     6,     7,     8,     9,    54,    10,    76,    77,    11,
      27,    28,    17,    92,   155,    93,    12,    82,    83,    13,
     142,   203,   143,   144,   145,   172,   173,   174,   175,    45,
      46,    38,    39,   107,    40,    41,    42
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -168
static const yytype_int16 yypact[] =
{
      61,  -168,  -168,   119,  -168,    51,    25,     2,  -168,  -168,
      61,    61,    61,    16,     7,   382,   321,    18,  -168,  -168,
    -168,  -168,  -168,    52,    11,    34,    56,    14,    22,  -168,
     382,   382,   382,   382,  -168,    63,    87,     9,   145,  -168,
    -168,    99,   101,    75,  -168,   112,     9,   321,   181,   321,
    -168,    43,   121,  -168,   105,   133,   343,   130,     7,  -168,
       7,  -168,  -168,   148,  -168,  -168,   382,   149,   382,   382,
     382,   382,   382,   314,   382,  -168,   174,   186,    79,   382,
    -168,   141,   115,  -168,   182,   176,  -168,   212,  -168,   321,
     192,    84,  -168,  -168,   343,  -168,  -168,  -168,   206,  -168,
     145,   145,  -168,  -168,  -168,  -168,   220,   213,   214,   321,
     321,   382,  -168,  -168,   204,  -168,   119,   141,    -8,  -168,
    -168,   176,  -168,   103,  -168,  -168,   382,  -168,  -168,  -168,
     223,   230,   239,   242,   201,   224,   350,  -168,  -168,  -168,
    -168,   121,  -168,  -168,   236,   240,   227,    -1,  -168,  -168,
     241,    63,   101,   343,  -168,   243,  -168,  -168,  -168,   382,
     382,  -168,  -168,  -168,   228,  -168,  -168,  -168,   382,   229,
     251,  -168,   161,   237,   238,   247,   205,   249,  -168,   244,
     101,  -168,   382,   382,   382,   382,   276,   382,   382,   382,
     382,   312,  -168,  -168,  -168,  -168,  -168,   256,   257,   245,
     246,   376,  -168,   280,   283,   248,    57,  -168,  -168,  -168,
    -168,  -168,   382,   382,  -168,  -168,  -168,   259,   276,   276,
    -168,   382,   269,   273,  -168,  -168,  -168,  -168,  -168,   261,
     276,   312,  -168,   291,   292,  -168,   276,   276,  -168,  -168,
    -168,  -168
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -168,  -168,   184,  -106,  -168,   215,   -12,   -13,   191,  -101,
    -168,    74,    -4,   -85,   134,   288,  -168,  -168,   189,     1,
    -167,   -74,   -79,   162,  -168,    -6,    15,   122,  -153,   -31,
     -10,   156,   -15,   183,  -168,   -83,  -108
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, syntax error.  */
#define YYTABLE_NINF -1
static const yytype_uint8 yytable[] =
{
      63,    24,   115,    44,    14,    37,   123,   177,   139,   124,
     152,   150,    78,   140,    25,    62,    73,    64,    65,    51,
       1,     2,    57,    68,   211,    18,    52,    69,     4,    58,
     151,   147,   196,   168,    80,    98,    85,    60,   149,   139,
      87,    19,   106,   108,   140,    26,    37,    53,   113,    84,
      59,    90,    47,    25,    23,   102,   103,   104,    61,   222,
     223,   180,   147,    99,   235,     1,     2,     3,   170,    48,
      15,    15,    55,     4,    73,    15,   121,    47,    29,    86,
     131,    37,    66,   146,    37,    16,    49,    29,    50,    30,
      56,   221,    31,    32,   111,   106,   129,    33,    30,     5,
      75,    31,    32,   206,   112,   164,    33,   204,   147,   122,
      43,    67,    34,    35,   146,   141,    73,    84,   153,    91,
      74,    34,    35,     1,     2,     1,     2,    79,   154,    24,
     116,     4,    95,     4,    96,   206,   206,   179,   117,   226,
     228,    88,    25,    37,   225,   227,   141,   206,   147,   176,
     176,   234,    15,   206,   206,   205,   233,   239,   241,     5,
     146,    70,   238,   240,    94,    71,    72,    89,    15,    50,
     217,    97,   176,   176,   176,   176,   114,   176,   176,   176,
     176,   207,   208,   209,   210,     1,     2,   205,   205,   109,
     229,   182,   183,     4,    20,    21,    22,   193,   194,   205,
     146,   110,   176,   176,    81,   205,   205,    29,     1,     2,
       3,   132,   119,   133,   134,   135,     4,   136,    30,    68,
     118,    31,    32,    69,   100,   101,    33,    52,    86,   137,
     125,   187,   188,   189,   190,   126,   127,   161,   128,   114,
     138,    34,    35,    29,     1,     2,     3,   132,   157,   133,
     134,   135,     4,   136,    30,   158,   159,    31,    32,   160,
     162,   165,    33,   167,   178,   169,   153,   151,   171,   184,
     186,   185,   191,   212,   213,   114,   138,    34,    35,    29,
     192,   214,   215,   197,   220,   198,   199,   200,   218,   201,
      30,   219,   230,    31,    32,   224,   231,   232,    33,   236,
     237,   130,   120,    36,   181,   148,   195,   166,     0,   156,
       0,   114,   202,    34,    35,    29,     0,    29,     0,   132,
       0,   133,   134,   135,    29,   136,    30,     0,    30,    31,
      32,    31,    32,     0,    33,    30,    33,   105,    31,    32,
       0,     0,     0,    33,     0,     0,    29,   114,   138,    34,
      35,    34,    35,    29,     0,     0,    43,    30,    34,    35,
      31,    32,     0,     0,    30,    33,     0,    31,    32,     0,
       0,     0,    33,     0,     0,     0,     0,     0,    91,    29,
      34,    35,     0,     0,     0,    29,   163,    34,    35,     0,
      30,     0,     0,    31,    32,     0,    30,     0,    33,    31,
      32,     0,     0,     0,    33,     0,     0,     0,     0,     0,
       0,     0,   216,    34,    35,     0,     0,     0,     0,    34,
      35
};

static const yytype_int16 yycheck[] =
{
      31,    13,    81,    16,     3,    15,    91,   160,   114,    94,
     118,    19,    43,   114,    13,    30,    17,    32,    33,    23,
       4,     5,    26,    14,   191,     0,    15,    18,    12,    15,
      38,   114,   185,    34,    47,    66,    49,    15,   117,   145,
      52,    39,    73,    74,   145,    38,    56,    36,    79,    48,
      36,    55,    34,    52,    38,    70,    71,    72,    36,   212,
     213,   169,   145,    67,   231,     4,     5,     6,   153,    17,
      19,    19,    38,    12,    17,    19,    89,    34,     3,    36,
     111,    91,    19,   114,    94,    34,    34,     3,    36,    14,
      34,    34,    17,    18,    15,   126,   109,    22,    14,    38,
      25,    17,    18,   186,    25,   136,    22,   186,   191,    25,
      35,    24,    37,    38,   145,   114,    17,   116,    15,    35,
      19,    37,    38,     4,     5,     4,     5,    15,    25,   141,
      15,    12,    58,    12,    60,   218,   219,   168,    23,   218,
     219,    36,   141,   153,   218,   219,   145,   230,   231,   159,
     160,   230,    19,   236,   237,   186,   230,   236,   237,    38,
     191,    16,   236,   237,    34,    20,    21,    34,    19,    36,
     201,    23,   182,   183,   184,   185,    35,   187,   188,   189,
     190,   187,   188,   189,   190,     4,     5,   218,   219,    15,
     221,    30,    31,    12,    10,    11,    12,   182,   183,   230,
     231,    15,   212,   213,    23,   236,   237,     3,     4,     5,
       6,     7,    36,     9,    10,    11,    12,    13,    14,    14,
      38,    17,    18,    18,    68,    69,    22,    15,    36,    25,
      24,    26,    27,    28,    29,    15,    23,    36,    24,    35,
      36,    37,    38,     3,     4,     5,     6,     7,    25,     9,
      10,    11,    12,    13,    14,    25,    17,    17,    18,    17,
      36,    25,    22,    36,    36,    24,    15,    38,    25,    32,
      23,    33,    23,    17,    17,    35,    36,    37,    38,     3,
      36,    36,    36,     7,    36,     9,    10,    11,     8,    13,
      14,     8,    23,    17,    18,    36,    23,    36,    22,     8,
       8,   110,    87,    15,   170,   116,   184,   145,    -1,   126,
      -1,    35,    36,    37,    38,     3,    -1,     3,    -1,     7,
      -1,     9,    10,    11,     3,    13,    14,    -1,    14,    17,
      18,    17,    18,    -1,    22,    14,    22,    23,    17,    18,
      -1,    -1,    -1,    22,    -1,    -1,     3,    35,    36,    37,
      38,    37,    38,     3,    -1,    -1,    35,    14,    37,    38,
      17,    18,    -1,    -1,    14,    22,    -1,    17,    18,    -1,
      -1,    -1,    22,    -1,    -1,    -1,    -1,    -1,    35,     3,
      37,    38,    -1,    -1,    -1,     3,    36,    37,    38,    -1,
      14,    -1,    -1,    17,    18,    -1,    14,    -1,    22,    17,
      18,    -1,    -1,    -1,    22,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    36,    37,    38,    -1,    -1,    -1,    -1,    37,
      38
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,     4,     5,     6,    12,    38,    41,    42,    43,    44,
      46,    49,    56,    59,    59,    19,    34,    52,     0,    39,
      42,    42,    42,    38,    46,    59,    38,    50,    51,     3,
      14,    17,    18,    22,    37,    38,    55,    70,    71,    72,
      74,    75,    76,    35,    47,    69,    70,    34,    17,    34,
      36,    52,    15,    36,    45,    38,    34,    52,    15,    36,
      15,    36,    72,    69,    72,    72,    19,    24,    14,    18,
      16,    20,    21,    17,    19,    25,    47,    48,    69,    15,
      47,    23,    57,    58,    59,    47,    36,    46,    36,    34,
      52,    35,    53,    55,    34,    51,    51,    23,    69,    52,
      71,    71,    72,    72,    72,    23,    69,    73,    69,    15,
      15,    15,    25,    69,    35,    62,    15,    23,    38,    36,
      45,    47,    25,    53,    53,    24,    15,    23,    24,    47,
      48,    69,     7,     9,    10,    11,    13,    25,    36,    43,
      49,    59,    60,    62,    63,    64,    69,    75,    58,    62,
      19,    38,    76,    15,    25,    54,    73,    25,    25,    17,
      17,    36,    36,    36,    69,    25,    63,    36,    34,    24,
      53,    25,    65,    66,    67,    68,    70,    68,    36,    69,
      76,    54,    30,    31,    32,    33,    23,    26,    27,    28,
      29,    23,    36,    66,    66,    67,    68,     7,     9,    10,
      11,    13,    36,    61,    62,    69,    75,    65,    65,    65,
      65,    60,    17,    17,    36,    36,    36,    69,     8,     8,
      36,    34,    68,    68,    36,    61,    62,    61,    62,    69,
      23,    23,    36,    61,    62,    60,     8,     8,    61,    62,
      61,    62
};

#define yyerrok		(yyerrstatus = 0)
#define yyclearin	(yychar = YYEMPTY)
#define YYEMPTY		(-2)
#define YYEOF		0

#define YYACCEPT	goto yyacceptlab
#define YYABORT		goto yyabortlab
#define YYERROR		goto yyerrorlab


/* Like YYERROR except do call yyerror.  This remains here temporarily
   to ease the transition to the new meaning of YYERROR, for GCC.
   Once GCC version 2 has supplanted version 1, this can go.  */

#define YYFAIL		goto yyerrlab

#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)					\
do								\
  if (yychar == YYEMPTY && yylen == 1)				\
    {								\
      yychar = (Token);						\
      yylval = (Value);						\
      yytoken = YYTRANSLATE (yychar);				\
      YYPOPSTACK (1);						\
      goto yybackup;						\
    }								\
  else								\
    {								\
      yyerror (YY_("syntax error: cannot back up")); \
      YYERROR;							\
    }								\
while (YYID (0))


#define YYTERROR	1
#define YYERRCODE	256


/* YYLLOC_DEFAULT -- Set CURRENT to span from RHS[1] to RHS[N].
   If N is 0, then set CURRENT to the empty location which ends
   the previous symbol: RHS[0] (always defined).  */

#define YYRHSLOC(Rhs, K) ((Rhs)[K])
#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)				\
    do									\
      if (YYID (N))                                                    \
	{								\
	  (Current).first_line   = YYRHSLOC (Rhs, 1).first_line;	\
	  (Current).first_column = YYRHSLOC (Rhs, 1).first_column;	\
	  (Current).last_line    = YYRHSLOC (Rhs, N).last_line;		\
	  (Current).last_column  = YYRHSLOC (Rhs, N).last_column;	\
	}								\
      else								\
	{								\
	  (Current).first_line   = (Current).last_line   =		\
	    YYRHSLOC (Rhs, 0).last_line;				\
	  (Current).first_column = (Current).last_column =		\
	    YYRHSLOC (Rhs, 0).last_column;				\
	}								\
    while (YYID (0))
#endif


/* YY_LOCATION_PRINT -- Print the location on the stream.
   This macro was not mandated originally: define only if we know
   we won't break user code: when these are the locations we know.  */

#ifndef YY_LOCATION_PRINT
# if YYLTYPE_IS_TRIVIAL
#  define YY_LOCATION_PRINT(File, Loc)			\
     fprintf (File, "%d.%d-%d.%d",			\
	      (Loc).first_line, (Loc).first_column,	\
	      (Loc).last_line,  (Loc).last_column)
# else
#  define YY_LOCATION_PRINT(File, Loc) ((void) 0)
# endif
#endif


/* YYLEX -- calling `yylex' with the right arguments.  */

#ifdef YYLEX_PARAM
# define YYLEX yylex (YYLEX_PARAM)
#else
# define YYLEX yylex ()
#endif

/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)			\
do {						\
  if (yydebug)					\
    YYFPRINTF Args;				\
} while (YYID (0))

# define YY_SYMBOL_PRINT(Title, Type, Value, Location)			  \
do {									  \
  if (yydebug)								  \
    {									  \
      YYFPRINTF (stderr, "%s ", Title);					  \
      yy_symbol_print (stderr,						  \
		  Type, Value); \
      YYFPRINTF (stderr, "\n");						  \
    }									  \
} while (YYID (0))


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_value_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
#else
static void
yy_symbol_value_print (yyoutput, yytype, yyvaluep)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
#endif
{
  if (!yyvaluep)
    return;
# ifdef YYPRINT
  if (yytype < YYNTOKENS)
    YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# else
  YYUSE (yyoutput);
# endif
  switch (yytype)
    {
      default:
	break;
    }
}


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
#else
static void
yy_symbol_print (yyoutput, yytype, yyvaluep)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
#endif
{
  if (yytype < YYNTOKENS)
    YYFPRINTF (yyoutput, "token %s (", yytname[yytype]);
  else
    YYFPRINTF (yyoutput, "nterm %s (", yytname[yytype]);

  yy_symbol_value_print (yyoutput, yytype, yyvaluep);
  YYFPRINTF (yyoutput, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_stack_print (yytype_int16 *yybottom, yytype_int16 *yytop)
#else
static void
yy_stack_print (yybottom, yytop)
    yytype_int16 *yybottom;
    yytype_int16 *yytop;
#endif
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)				\
do {								\
  if (yydebug)							\
    yy_stack_print ((Bottom), (Top));				\
} while (YYID (0))


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_reduce_print (YYSTYPE *yyvsp, int yyrule)
#else
static void
yy_reduce_print (yyvsp, yyrule)
    YYSTYPE *yyvsp;
    int yyrule;
#endif
{
  int yynrhs = yyr2[yyrule];
  int yyi;
  unsigned long int yylno = yyrline[yyrule];
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %lu):\n",
	     yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr, yyrhs[yyprhs[yyrule] + yyi],
		       &(yyvsp[(yyi + 1) - (yynrhs)])
		       		       );
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)		\
do {					\
  if (yydebug)				\
    yy_reduce_print (yyvsp, Rule); \
} while (YYID (0))

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YY_SYMBOL_PRINT(Title, Type, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef	YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif



#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined __GLIBC__ && defined _STRING_H
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static YYSIZE_T
yystrlen (const char *yystr)
#else
static YYSIZE_T
yystrlen (yystr)
    const char *yystr;
#endif
{
  YYSIZE_T yylen;
  for (yylen = 0; yystr[yylen]; yylen++)
    continue;
  return yylen;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined __GLIBC__ && defined _STRING_H && defined _GNU_SOURCE
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static char *
yystpcpy (char *yydest, const char *yysrc)
#else
static char *
yystpcpy (yydest, yysrc)
    char *yydest;
    const char *yysrc;
#endif
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

# ifndef yytnamerr
/* Copy to YYRES the contents of YYSTR after stripping away unnecessary
   quotes and backslashes, so that it's suitable for yyerror.  The
   heuristic is that double-quoting is unnecessary unless the string
   contains an apostrophe, a comma, or backslash (other than
   backslash-backslash).  YYSTR is taken from yytname.  If YYRES is
   null, do not copy; instead, return the length of what the result
   would have been.  */
static YYSIZE_T
yytnamerr (char *yyres, const char *yystr)
{
  if (*yystr == '"')
    {
      YYSIZE_T yyn = 0;
      char const *yyp = yystr;

      for (;;)
	switch (*++yyp)
	  {
	  case '\'':
	  case ',':
	    goto do_not_strip_quotes;

	  case '\\':
	    if (*++yyp != '\\')
	      goto do_not_strip_quotes;
	    /* Fall through.  */
	  default:
	    if (yyres)
	      yyres[yyn] = *yyp;
	    yyn++;
	    break;

	  case '"':
	    if (yyres)
	      yyres[yyn] = '\0';
	    return yyn;
	  }
    do_not_strip_quotes: ;
    }

  if (! yyres)
    return yystrlen (yystr);

  return yystpcpy (yyres, yystr) - yyres;
}
# endif

/* Copy into YYRESULT an error message about the unexpected token
   YYCHAR while in state YYSTATE.  Return the number of bytes copied,
   including the terminating null byte.  If YYRESULT is null, do not
   copy anything; just return the number of bytes that would be
   copied.  As a special case, return 0 if an ordinary "syntax error"
   message will do.  Return YYSIZE_MAXIMUM if overflow occurs during
   size calculation.  */
static YYSIZE_T
yysyntax_error (char *yyresult, int yystate, int yychar)
{
  int yyn = yypact[yystate];

  if (! (YYPACT_NINF < yyn && yyn <= YYLAST))
    return 0;
  else
    {
      int yytype = YYTRANSLATE (yychar);
      YYSIZE_T yysize0 = yytnamerr (0, yytname[yytype]);
      YYSIZE_T yysize = yysize0;
      YYSIZE_T yysize1;
      int yysize_overflow = 0;
      enum { YYERROR_VERBOSE_ARGS_MAXIMUM = 5 };
      char const *yyarg[YYERROR_VERBOSE_ARGS_MAXIMUM];
      int yyx;

# if 0
      /* This is so xgettext sees the translatable formats that are
	 constructed on the fly.  */
      YY_("syntax error, unexpected %s");
      YY_("syntax error, unexpected %s, expecting %s");
      YY_("syntax error, unexpected %s, expecting %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s");
# endif
      char *yyfmt;
      char const *yyf;
      static char const yyunexpected[] = "syntax error, unexpected %s";
      static char const yyexpecting[] = ", expecting %s";
      static char const yyor[] = " or %s";
      char yyformat[sizeof yyunexpected
		    + sizeof yyexpecting - 1
		    + ((YYERROR_VERBOSE_ARGS_MAXIMUM - 2)
		       * (sizeof yyor - 1))];
      char const *yyprefix = yyexpecting;

      /* Start YYX at -YYN if negative to avoid negative indexes in
	 YYCHECK.  */
      int yyxbegin = yyn < 0 ? -yyn : 0;

      /* Stay within bounds of both yycheck and yytname.  */
      int yychecklim = YYLAST - yyn + 1;
      int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
      int yycount = 1;

      yyarg[0] = yytname[yytype];
      yyfmt = yystpcpy (yyformat, yyunexpected);

      for (yyx = yyxbegin; yyx < yyxend; ++yyx)
	if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR)
	  {
	    if (yycount == YYERROR_VERBOSE_ARGS_MAXIMUM)
	      {
		yycount = 1;
		yysize = yysize0;
		yyformat[sizeof yyunexpected - 1] = '\0';
		break;
	      }
	    yyarg[yycount++] = yytname[yyx];
	    yysize1 = yysize + yytnamerr (0, yytname[yyx]);
	    yysize_overflow |= (yysize1 < yysize);
	    yysize = yysize1;
	    yyfmt = yystpcpy (yyfmt, yyprefix);
	    yyprefix = yyor;
	  }

      yyf = YY_(yyformat);
      yysize1 = yysize + yystrlen (yyf);
      yysize_overflow |= (yysize1 < yysize);
      yysize = yysize1;

      if (yysize_overflow)
	return YYSIZE_MAXIMUM;

      if (yyresult)
	{
	  /* Avoid sprintf, as that infringes on the user's name space.
	     Don't have undefined behavior even if the translation
	     produced a string with the wrong number of "%s"s.  */
	  char *yyp = yyresult;
	  int yyi = 0;
	  while ((*yyp = *yyf) != '\0')
	    {
	      if (*yyp == '%' && yyf[1] == 's' && yyi < yycount)
		{
		  yyp += yytnamerr (yyp, yyarg[yyi++]);
		  yyf += 2;
		}
	      else
		{
		  yyp++;
		  yyf++;
		}
	    }
	}
      return yysize;
    }
}
#endif /* YYERROR_VERBOSE */


/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep)
#else
static void
yydestruct (yymsg, yytype, yyvaluep)
    const char *yymsg;
    int yytype;
    YYSTYPE *yyvaluep;
#endif
{
  YYUSE (yyvaluep);

  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yytype, yyvaluep, yylocationp);

  switch (yytype)
    {

      default:
	break;
    }
}

/* Prevent warnings from -Wmissing-prototypes.  */
#ifdef YYPARSE_PARAM
#if defined __STDC__ || defined __cplusplus
int yyparse (void *YYPARSE_PARAM);
#else
int yyparse ();
#endif
#else /* ! YYPARSE_PARAM */
#if defined __STDC__ || defined __cplusplus
int yyparse (void);
#else
int yyparse ();
#endif
#endif /* ! YYPARSE_PARAM */


/* The lookahead symbol.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;

/* Number of syntax errors so far.  */
int yynerrs;



/*-------------------------.
| yyparse or yypush_parse.  |
`-------------------------*/

#ifdef YYPARSE_PARAM
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (void *YYPARSE_PARAM)
#else
int
yyparse (YYPARSE_PARAM)
    void *YYPARSE_PARAM;
#endif
#else /* ! YYPARSE_PARAM */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (void)
#else
int
yyparse ()

#endif
#endif
{


    int yystate;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus;

    /* The stacks and their tools:
       `yyss': related to states.
       `yyvs': related to semantic values.

       Refer to the stacks thru separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* The state stack.  */
    yytype_int16 yyssa[YYINITDEPTH];
    yytype_int16 *yyss;
    yytype_int16 *yyssp;

    /* The semantic value stack.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs;
    YYSTYPE *yyvsp;

    YYSIZE_T yystacksize;

  int yyn;
  int yyresult;
  /* Lookahead token as an internal (translated) token number.  */
  int yytoken;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;

#if YYERROR_VERBOSE
  /* Buffer for error messages, and its allocated size.  */
  char yymsgbuf[128];
  char *yymsg = yymsgbuf;
  YYSIZE_T yymsg_alloc = sizeof yymsgbuf;
#endif

#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  yytoken = 0;
  yyss = yyssa;
  yyvs = yyvsa;
  yystacksize = YYINITDEPTH;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY; /* Cause a token to be read.  */

  /* Initialize stack pointers.
     Waste one element of value and location stack
     so that they stay on the same level as the state stack.
     The wasted elements are never initialized.  */
  yyssp = yyss;
  yyvsp = yyvs;

  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyss + yystacksize - 1 <= yyssp)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
	/* Give user a chance to reallocate the stack.  Use copies of
	   these so that the &'s don't force the real ones into
	   memory.  */
	YYSTYPE *yyvs1 = yyvs;
	yytype_int16 *yyss1 = yyss;

	/* Each stack pointer address is followed by the size of the
	   data in use in that stack, in bytes.  This used to be a
	   conditional around just the two extra args, but that might
	   be undefined if yyoverflow is a macro.  */
	yyoverflow (YY_("memory exhausted"),
		    &yyss1, yysize * sizeof (*yyssp),
		    &yyvs1, yysize * sizeof (*yyvsp),
		    &yystacksize);

	yyss = yyss1;
	yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyexhaustedlab;
# else
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
	goto yyexhaustedlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
	yystacksize = YYMAXDEPTH;

      {
	yytype_int16 *yyss1 = yyss;
	union yyalloc *yyptr =
	  (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
	if (! yyptr)
	  goto yyexhaustedlab;
	YYSTACK_RELOCATE (yyss_alloc, yyss);
	YYSTACK_RELOCATE (yyvs_alloc, yyvs);
#  undef YYSTACK_RELOCATE
	if (yyss1 != yyssa)
	  YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;

      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
		  (unsigned long int) yystacksize));

      if (yyss + yystacksize - 1 <= yyssp)
	YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  if (yystate == YYFINAL)
    YYACCEPT;

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

  /* Do appropriate processing given the current state.  Read a
     lookahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to lookahead token.  */
  yyn = yypact[yystate];
  if (yyn == YYPACT_NINF)
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid lookahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = YYLEX;
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yyn == 0 || yyn == YYTABLE_NINF)
	goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the lookahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);

  /* Discard the shifted token.  */
  yychar = YYEMPTY;

  yystate = yyn;
  *++yyvsp = yylval;

  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     `$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 2:

/* Line 1455 of yacc.c  */
#line 30 "lrparser.y"
    {showAst((yyvsp[(1) - (2)].pAst),0);;}
    break;

  case 3:

/* Line 1455 of yacc.c  */
#line 32 "lrparser.y"
    {past l=newCompUnit((yyvsp[(1) - (2)].pAst),NULL);l->right=(yyvsp[(2) - (2)].pAst);(yyval.pAst)=l;;}
    break;

  case 4:

/* Line 1455 of yacc.c  */
#line 33 "lrparser.y"
    {past l=newCompUnit((yyvsp[(1) - (2)].pAst),NULL);l->right=(yyvsp[(2) - (2)].pAst);(yyval.pAst)=l;;}
    break;

  case 5:

/* Line 1455 of yacc.c  */
#line 34 "lrparser.y"
    {past l=newCompUnit((yyvsp[(1) - (2)].pAst),NULL);l->right=(yyvsp[(2) - (2)].pAst);(yyval.pAst)=l;;}
    break;

  case 6:

/* Line 1455 of yacc.c  */
#line 35 "lrparser.y"
    {(yyval.pAst)=newCompUnit((yyvsp[(1) - (1)].pAst),NULL);;}
    break;

  case 7:

/* Line 1455 of yacc.c  */
#line 36 "lrparser.y"
    {(yyval.pAst)=newCompUnit((yyvsp[(1) - (1)].pAst),NULL);;}
    break;

  case 8:

/* Line 1455 of yacc.c  */
#line 37 "lrparser.y"
    {(yyval.pAst)=newCompUnit((yyvsp[(1) - (1)].pAst),NULL);;}
    break;

  case 11:

/* Line 1455 of yacc.c  */
#line 42 "lrparser.y"
    {(yyval.pAst) = newDeclStmt(NULL, (yyvsp[(2) - (3)].pAst));;}
    break;

  case 12:

/* Line 1455 of yacc.c  */
#line 43 "lrparser.y"
    {(yyval.pAst) = newDeclStmt((yyvsp[(2) - (4)].pAst), (yyvsp[(3) - (4)].pAst));;}
    break;

  case 13:

/* Line 1455 of yacc.c  */
#line 46 "lrparser.y"
    {(yyval.pAst) = (yyvsp[(2) - (2)].pAst);;}
    break;

  case 14:

/* Line 1455 of yacc.c  */
#line 47 "lrparser.y"
    {(yyval.pAst) = newDeclStmt1((yyvsp[(2) - (3)].pAst), (yyvsp[(3) - (3)].pAst));;}
    break;

  case 15:

/* Line 1455 of yacc.c  */
#line 50 "lrparser.y"
    {(yyval.pAst) = newVarDecl(get_stype(type), type, 0, (yyvsp[(1) - (1)].id_name), NULL, NULL);;}
    break;

  case 16:

/* Line 1455 of yacc.c  */
#line 51 "lrparser.y"
    {(yyval.pAst) = newVarDecl(get_stype(type), type, 0, (yyvsp[(1) - (3)].id_name), NULL, (yyvsp[(3) - (3)].pAst));;}
    break;

  case 17:

/* Line 1455 of yacc.c  */
#line 52 "lrparser.y"
    {(yyval.pAst) = newVarDecl(get_stype(type), type, 0, (yyvsp[(1) - (2)].id_name), NULL, NULL); ;}
    break;

  case 18:

/* Line 1455 of yacc.c  */
#line 53 "lrparser.y"
    {(yyval.pAst) = newVarDecl(get_stype(type), type, 0, (yyvsp[(1) - (4)].id_name), NULL, (yyvsp[(4) - (4)].pAst)); ;}
    break;

  case 19:

/* Line 1455 of yacc.c  */
#line 54 "lrparser.y"
    {(yyval.pAst) = newVarDecl(get_stype(type), type, 0, (yyvsp[(2) - (5)].id_name), NULL, (yyvsp[(4) - (5)].pAst));;}
    break;

  case 20:

/* Line 1455 of yacc.c  */
#line 55 "lrparser.y"
    {(yyval.pAst) = newVarDecl(get_stype(type), type, 0, (yyvsp[(2) - (3)].id_name), NULL, NULL);;}
    break;

  case 21:

/* Line 1455 of yacc.c  */
#line 56 "lrparser.y"
    {(yyval.pAst) = newVarDecl(get_stype(type), type, 0, (yyvsp[(2) - (4)].id_name), NULL, NULL);;}
    break;

  case 23:

/* Line 1455 of yacc.c  */
#line 60 "lrparser.y"
    {(yyval.pAst) = newInitList((yyvsp[(1) - (3)].pAst),(yyvsp[(3) - (3)].pAst));;}
    break;

  case 24:

/* Line 1455 of yacc.c  */
#line 61 "lrparser.y"
    {(yyval.pAst) = newInitList(NULL,NULL);;}
    break;

  case 25:

/* Line 1455 of yacc.c  */
#line 62 "lrparser.y"
    {(yyval.pAst) = newInitList((yyvsp[(2) - (3)].pAst),NULL);;}
    break;

  case 26:

/* Line 1455 of yacc.c  */
#line 63 "lrparser.y"
    {(yyval.pAst) = newInitList((yyvsp[(2) - (5)].pAst),(yyvsp[(4) - (5)].pAst));;}
    break;

  case 27:

/* Line 1455 of yacc.c  */
#line 64 "lrparser.y"
    {(yyval.pAst) = newInitList(newDeclStmt1((yyvsp[(2) - (5)].pAst),(yyvsp[(4) - (5)].pAst)),NULL) ; ;}
    break;

  case 28:

/* Line 1455 of yacc.c  */
#line 67 "lrparser.y"
    {(yyval.pAst) = newDeclStmt1((yyvsp[(1) - (3)].pAst),(yyvsp[(3) - (3)].pAst)); ;}
    break;

  case 29:

/* Line 1455 of yacc.c  */
#line 69 "lrparser.y"
    {(yyval.pAst) = newDeclStmt1(NULL, (yyvsp[(3) - (4)].pAst));;}
    break;

  case 30:

/* Line 1455 of yacc.c  */
#line 70 "lrparser.y"
    {(yyval.pAst) = newDeclStmt1(NULL, (yyvsp[(3) - (4)].pAst));;}
    break;

  case 31:

/* Line 1455 of yacc.c  */
#line 73 "lrparser.y"
    {(yyval.pAst) = newDeclStmt1((yyvsp[(1) - (3)].pAst), (yyvsp[(3) - (3)].pAst));;}
    break;

  case 32:

/* Line 1455 of yacc.c  */
#line 74 "lrparser.y"
    {(yyval.pAst) = newDeclStmt1((yyvsp[(1) - (3)].pAst), (yyvsp[(3) - (3)].pAst));;}
    break;

  case 33:

/* Line 1455 of yacc.c  */
#line 77 "lrparser.y"
    {(yyval.pAst) = newVarDecl(get_conststype(type), type, 1, (yyvsp[(1) - (3)].id_name), NULL, (yyvsp[(3) - (3)].pAst));;}
    break;

  case 34:

/* Line 1455 of yacc.c  */
#line 78 "lrparser.y"
    {(yyval.pAst) = newVarDecl(get_conststype(type), type, 1, (yyvsp[(1) - (4)].id_name), NULL, (yyvsp[(4) - (4)].pAst)); ;}
    break;

  case 35:

/* Line 1455 of yacc.c  */
#line 81 "lrparser.y"
    {(yyval.pAst) = (yyvsp[(2) - (3)].pAst);;}
    break;

  case 36:

/* Line 1455 of yacc.c  */
#line 82 "lrparser.y"
    {(yyval.pAst) = (yyvsp[(2) - (4)].pAst); ;}
    break;

  case 38:

/* Line 1455 of yacc.c  */
#line 86 "lrparser.y"
    {(yyval.pAst) = NULL; ;}
    break;

  case 39:

/* Line 1455 of yacc.c  */
#line 87 "lrparser.y"
    {(yyval.pAst) = (yyvsp[(2) - (3)].pAst);;}
    break;

  case 40:

/* Line 1455 of yacc.c  */
#line 88 "lrparser.y"
    {(yyval.pAst) = newInitList((yyvsp[(2) - (4)].pAst),(yyvsp[(3) - (4)].pAst)); ;}
    break;

  case 41:

/* Line 1455 of yacc.c  */
#line 91 "lrparser.y"
    {(yyval.pAst) = (yyvsp[(2) - (2)].pAst);;}
    break;

  case 42:

/* Line 1455 of yacc.c  */
#line 92 "lrparser.y"
    {(yyval.pAst) = newDeclStmt1((yyvsp[(2) - (3)].pAst),(yyvsp[(3) - (3)].pAst)); ;}
    break;

  case 44:

/* Line 1455 of yacc.c  */
#line 98 "lrparser.y"
    {(yyval.pAst) = newFuncDecl(get_stype((yyvsp[(1) - (5)].pAst)->ivalue), (yyvsp[(1) - (5)].pAst)->ivalue,(yyvsp[(2) - (5)].id_name), NULL, newCompoundStmt(NULL, (yyvsp[(5) - (5)].pAst)));;}
    break;

  case 45:

/* Line 1455 of yacc.c  */
#line 99 "lrparser.y"
    {(yyval.pAst) = newFuncDecl(get_stype((yyvsp[(1) - (6)].pAst)->ivalue), (yyvsp[(1) - (6)].pAst)->ivalue, (yyvsp[(2) - (6)].id_name), (yyvsp[(4) - (6)].pAst), newCompoundStmt(NULL, (yyvsp[(6) - (6)].pAst)));;}
    break;

  case 47:

/* Line 1455 of yacc.c  */
#line 103 "lrparser.y"
    {(yyval.pAst)=newDeclStmt1((yyvsp[(1) - (3)].pAst),(yyvsp[(3) - (3)].pAst));;}
    break;

  case 48:

/* Line 1455 of yacc.c  */
#line 106 "lrparser.y"
    {(yyval.pAst) = newParaDecl(get_stype((yyvsp[(1) - (2)].pAst)->ivalue), (yyvsp[(2) - (2)].id_name), NULL, NULL);;}
    break;

  case 49:

/* Line 1455 of yacc.c  */
#line 107 "lrparser.y"
    {(yyval.pAst) = newParaDecl(get_stype((yyvsp[(1) - (4)].pAst)->ivalue), (yyvsp[(2) - (4)].id_name), NULL, NULL);;}
    break;

  case 50:

/* Line 1455 of yacc.c  */
#line 108 "lrparser.y"
    {(yyval.pAst) = newParaDecl(get_stype((yyvsp[(1) - (3)].pAst)->ivalue), (yyvsp[(2) - (3)].id_name), NULL, NULL);;}
    break;

  case 51:

/* Line 1455 of yacc.c  */
#line 109 "lrparser.y"
    {(yyval.pAst) = newParaDecl(get_stype((yyvsp[(1) - (5)].pAst)->ivalue), (yyvsp[(2) - (5)].id_name), NULL, NULL);;}
    break;

  case 52:

/* Line 1455 of yacc.c  */
#line 112 "lrparser.y"
    {yylval.int_value = Y_INT;(yyval.pAst) = newType(Y_INT);;}
    break;

  case 53:

/* Line 1455 of yacc.c  */
#line 113 "lrparser.y"
    {yylval.int_value = Y_FLOAT;(yyval.pAst) = newType(Y_FLOAT);;}
    break;

  case 54:

/* Line 1455 of yacc.c  */
#line 114 "lrparser.y"
    {yylval.int_value = Y_VOID;(yyval.pAst) = newType(Y_VOID);;}
    break;

  case 55:

/* Line 1455 of yacc.c  */
#line 117 "lrparser.y"
    {(yyval.pAst) = newBinaryOper("=", Y_ASSIGN, (yyvsp[(1) - (4)].pAst), (yyvsp[(3) - (4)].pAst));;}
    break;

  case 56:

/* Line 1455 of yacc.c  */
#line 118 "lrparser.y"
    {(yyval.pAst) = NULL;;}
    break;

  case 57:

/* Line 1455 of yacc.c  */
#line 119 "lrparser.y"
    {(yyval.pAst) = (yyvsp[(1) - (2)].pAst);;}
    break;

  case 59:

/* Line 1455 of yacc.c  */
#line 121 "lrparser.y"
    {(yyval.pAst) = newWhileStmt((yyvsp[(3) - (5)].pAst), newCompoundStmt(NULL,(yyvsp[(5) - (5)].pAst)));;}
    break;

  case 60:

/* Line 1455 of yacc.c  */
#line 122 "lrparser.y"
    {(yyval.pAst) = newIfStmt((yyvsp[(3) - (5)].pAst), newCompoundStmt(NULL,(yyvsp[(5) - (5)].pAst)), NULL);;}
    break;

  case 61:

/* Line 1455 of yacc.c  */
#line 123 "lrparser.y"
    {(yyval.pAst) = newIfStmt((yyvsp[(3) - (7)].pAst), newCompoundStmt(NULL,(yyvsp[(5) - (7)].pAst)), newCompoundStmt(NULL,(yyvsp[(7) - (7)].pAst)));;}
    break;

  case 62:

/* Line 1455 of yacc.c  */
#line 124 "lrparser.y"
    {(yyval.pAst) = newIfStmt((yyvsp[(3) - (5)].pAst), (yyvsp[(5) - (5)].pAst), NULL);;}
    break;

  case 63:

/* Line 1455 of yacc.c  */
#line 125 "lrparser.y"
    {(yyval.pAst) = newIfStmt((yyvsp[(3) - (7)].pAst), (yyvsp[(5) - (7)].pAst), (yyvsp[(7) - (7)].pAst));;}
    break;

  case 64:

/* Line 1455 of yacc.c  */
#line 126 "lrparser.y"
    {(yyval.pAst) = newIfStmt((yyvsp[(3) - (7)].pAst), (yyvsp[(5) - (7)].pAst), newCompoundStmt(NULL,(yyvsp[(7) - (7)].pAst)));;}
    break;

  case 65:

/* Line 1455 of yacc.c  */
#line 127 "lrparser.y"
    {(yyval.pAst) = newIfStmt((yyvsp[(3) - (7)].pAst), newCompoundStmt(NULL,(yyvsp[(5) - (7)].pAst)), (yyvsp[(7) - (7)].pAst));;}
    break;

  case 66:

/* Line 1455 of yacc.c  */
#line 128 "lrparser.y"
    {(yyval.pAst) = newBreakStmt();;}
    break;

  case 67:

/* Line 1455 of yacc.c  */
#line 129 "lrparser.y"
    {(yyval.pAst) = newContinueStmt();;}
    break;

  case 68:

/* Line 1455 of yacc.c  */
#line 130 "lrparser.y"
    {(yyval.pAst) = newReturnStmt((yyvsp[(2) - (3)].pAst), NULL);;}
    break;

  case 69:

/* Line 1455 of yacc.c  */
#line 131 "lrparser.y"
    {(yyval.pAst) = newReturnStmt(NULL, NULL);;}
    break;

  case 70:

/* Line 1455 of yacc.c  */
#line 133 "lrparser.y"
    {(yyval.pAst) = newBinaryOper("=", Y_ASSIGN, (yyvsp[(1) - (4)].pAst), (yyvsp[(3) - (4)].pAst));;}
    break;

  case 71:

/* Line 1455 of yacc.c  */
#line 134 "lrparser.y"
    {(yyval.pAst) = NULL;;}
    break;

  case 72:

/* Line 1455 of yacc.c  */
#line 135 "lrparser.y"
    {(yyval.pAst) = (yyvsp[(1) - (2)].pAst);;}
    break;

  case 74:

/* Line 1455 of yacc.c  */
#line 137 "lrparser.y"
    {(yyval.pAst) = newWhileStmt((yyvsp[(3) - (5)].pAst), newCompoundStmt(NULL,(yyvsp[(5) - (5)].pAst)));;}
    break;

  case 75:

/* Line 1455 of yacc.c  */
#line 138 "lrparser.y"
    {(yyval.pAst) = newIfStmt((yyvsp[(3) - (5)].pAst), newCompoundStmt(NULL,(yyvsp[(5) - (5)].pAst)), NULL);;}
    break;

  case 76:

/* Line 1455 of yacc.c  */
#line 139 "lrparser.y"
    {(yyval.pAst) = newIfStmt((yyvsp[(3) - (7)].pAst), newCompoundStmt(NULL,(yyvsp[(5) - (7)].pAst)), newCompoundStmt(NULL,(yyvsp[(7) - (7)].pAst)));;}
    break;

  case 77:

/* Line 1455 of yacc.c  */
#line 140 "lrparser.y"
    {(yyval.pAst) = newIfStmt((yyvsp[(3) - (5)].pAst), (yyvsp[(5) - (5)].pAst), NULL);;}
    break;

  case 78:

/* Line 1455 of yacc.c  */
#line 141 "lrparser.y"
    {(yyval.pAst) = newIfStmt((yyvsp[(3) - (7)].pAst), (yyvsp[(5) - (7)].pAst), (yyvsp[(7) - (7)].pAst));;}
    break;

  case 79:

/* Line 1455 of yacc.c  */
#line 142 "lrparser.y"
    {(yyval.pAst) = newIfStmt((yyvsp[(3) - (7)].pAst), (yyvsp[(5) - (7)].pAst), newCompoundStmt(NULL,(yyvsp[(7) - (7)].pAst)));;}
    break;

  case 80:

/* Line 1455 of yacc.c  */
#line 143 "lrparser.y"
    {(yyval.pAst) = newIfStmt((yyvsp[(3) - (7)].pAst), newCompoundStmt(NULL,(yyvsp[(5) - (7)].pAst)), (yyvsp[(7) - (7)].pAst));;}
    break;

  case 81:

/* Line 1455 of yacc.c  */
#line 144 "lrparser.y"
    {(yyval.pAst) = newBreakStmt();;}
    break;

  case 82:

/* Line 1455 of yacc.c  */
#line 145 "lrparser.y"
    {(yyval.pAst) = newContinueStmt();;}
    break;

  case 83:

/* Line 1455 of yacc.c  */
#line 146 "lrparser.y"
    {(yyval.pAst) = newReturnStmt((yyvsp[(2) - (3)].pAst), NULL);;}
    break;

  case 84:

/* Line 1455 of yacc.c  */
#line 147 "lrparser.y"
    {(yyval.pAst) = newReturnStmt(NULL, NULL);;}
    break;

  case 85:

/* Line 1455 of yacc.c  */
#line 148 "lrparser.y"
    {(yyval.pAst) = (yyvsp[(2) - (3)].pAst);;}
    break;

  case 86:

/* Line 1455 of yacc.c  */
#line 149 "lrparser.y"
    {(yyval.pAst) = NULL;;}
    break;

  case 87:

/* Line 1455 of yacc.c  */
#line 152 "lrparser.y"
    {(yyval.pAst) = newCompoundStmt((yyvsp[(1) - (1)].pAst), NULL);;}
    break;

  case 88:

/* Line 1455 of yacc.c  */
#line 153 "lrparser.y"
    {past l = newCompoundStmt((yyvsp[(1) - (2)].pAst), NULL); l->right = (yyvsp[(2) - (2)].pAst); (yyval.pAst) = l;;}
    break;

  case 92:

/* Line 1455 of yacc.c  */
#line 161 "lrparser.y"
    {(yyval.pAst) = newBinaryOper("<", Y_LESS, (yyvsp[(1) - (3)].pAst), (yyvsp[(3) - (3)].pAst));;}
    break;

  case 93:

/* Line 1455 of yacc.c  */
#line 162 "lrparser.y"
    {(yyval.pAst) = newBinaryOper(">", Y_GREAT, (yyvsp[(1) - (3)].pAst), (yyvsp[(3) - (3)].pAst));;}
    break;

  case 94:

/* Line 1455 of yacc.c  */
#line 163 "lrparser.y"
    {(yyval.pAst) = newBinaryOper("<=", Y_LESSEQ, (yyvsp[(1) - (3)].pAst), (yyvsp[(3) - (3)].pAst));;}
    break;

  case 95:

/* Line 1455 of yacc.c  */
#line 164 "lrparser.y"
    {(yyval.pAst) = newBinaryOper(">=", Y_GREATEQ, (yyvsp[(1) - (3)].pAst), (yyvsp[(3) - (3)].pAst));;}
    break;

  case 97:

/* Line 1455 of yacc.c  */
#line 168 "lrparser.y"
    {(yyval.pAst) = newBinaryOper("==", Y_EQ, (yyvsp[(1) - (3)].pAst), (yyvsp[(3) - (3)].pAst));;}
    break;

  case 98:

/* Line 1455 of yacc.c  */
#line 169 "lrparser.y"
    {(yyval.pAst) = newBinaryOper("!=", Y_NOTEQ, (yyvsp[(1) - (3)].pAst), (yyvsp[(3) - (3)].pAst));;}
    break;

  case 100:

/* Line 1455 of yacc.c  */
#line 173 "lrparser.y"
    {(yyval.pAst) = newBinaryOper("&&", Y_AND, (yyvsp[(1) - (3)].pAst), (yyvsp[(3) - (3)].pAst));;}
    break;

  case 102:

/* Line 1455 of yacc.c  */
#line 177 "lrparser.y"
    {(yyval.pAst) = newBinaryOper("||", Y_OR, (yyvsp[(1) - (3)].pAst), (yyvsp[(3) - (3)].pAst));;}
    break;

  case 105:

/* Line 1455 of yacc.c  */
#line 185 "lrparser.y"
    {(yyval.pAst) = newBinaryOper("+", Y_ADD, (yyvsp[(1) - (3)].pAst), (yyvsp[(3) - (3)].pAst));;}
    break;

  case 106:

/* Line 1455 of yacc.c  */
#line 186 "lrparser.y"
    {(yyval.pAst) = newBinaryOper("-", Y_SUB, (yyvsp[(1) - (3)].pAst), (yyvsp[(3) - (3)].pAst));;}
    break;

  case 108:

/* Line 1455 of yacc.c  */
#line 190 "lrparser.y"
    {(yyval.pAst) = newBinaryOper("*", Y_MUL, (yyvsp[(1) - (3)].pAst), (yyvsp[(3) - (3)].pAst));;}
    break;

  case 109:

/* Line 1455 of yacc.c  */
#line 191 "lrparser.y"
    {(yyval.pAst) = newBinaryOper("/", Y_DIV, (yyvsp[(1) - (3)].pAst), (yyvsp[(3) - (3)].pAst));;}
    break;

  case 110:

/* Line 1455 of yacc.c  */
#line 192 "lrparser.y"
    {(yyval.pAst) = newBinaryOper("%", Y_MODULO, (yyvsp[(1) - (3)].pAst), (yyvsp[(3) - (3)].pAst));;}
    break;

  case 112:

/* Line 1455 of yacc.c  */
#line 196 "lrparser.y"
    {(yyval.pAst) = newCallExp(NULL, 0, NULL, (yyvsp[(1) - (3)].pAst), NULL);;}
    break;

  case 113:

/* Line 1455 of yacc.c  */
#line 197 "lrparser.y"
    {(yyval.pAst) = newCallExp(NULL, 0, NULL, (yyvsp[(1) - (4)].pAst), (yyvsp[(3) - (4)].pAst));;}
    break;

  case 114:

/* Line 1455 of yacc.c  */
#line 198 "lrparser.y"
    {(yyval.pAst) = newBinaryOper("+", Y_ADD, NULL, (yyvsp[(2) - (2)].pAst));;}
    break;

  case 115:

/* Line 1455 of yacc.c  */
#line 199 "lrparser.y"
    {(yyval.pAst) = newBinaryOper("-", Y_SUB, NULL, (yyvsp[(2) - (2)].pAst));;}
    break;

  case 116:

/* Line 1455 of yacc.c  */
#line 200 "lrparser.y"
    {(yyval.pAst) = newBinaryOper("!", Y_NOT, NULL, (yyvsp[(2) - (2)].pAst));;}
    break;

  case 118:

/* Line 1455 of yacc.c  */
#line 204 "lrparser.y"
    {(yyval.pAst) = newDeclStmt1((yyvsp[(1) - (3)].pAst), (yyvsp[(3) - (3)].pAst));;}
    break;

  case 119:

/* Line 1455 of yacc.c  */
#line 207 "lrparser.y"
    {(yyval.pAst) = newParen((yyvsp[(2) - (3)].pAst),NULL);;}
    break;

  case 121:

/* Line 1455 of yacc.c  */
#line 209 "lrparser.y"
    {(yyval.pAst) = newIntVal((yyvsp[(1) - (1)].int_value));;}
    break;

  case 122:

/* Line 1455 of yacc.c  */
#line 210 "lrparser.y"
    {(yyval.pAst) = newFloatVal((yyvsp[(1) - (1)].float_value));;}
    break;

  case 123:

/* Line 1455 of yacc.c  */
#line 213 "lrparser.y"
    {(yyval.pAst) = newDeclRefExp((yyvsp[(1) - (1)].id_name), NULL, NULL);;}
    break;

  case 124:

/* Line 1455 of yacc.c  */
#line 214 "lrparser.y"
    {(yyval.pAst) = (yyvsp[(1) - (1)].pAst);;}
    break;

  case 125:

/* Line 1455 of yacc.c  */
#line 217 "lrparser.y"
    {(yyval.pAst)=newArraySubscriptsExp((yyvsp[(1) - (4)].pAst), (yyvsp[(3) - (4)].pAst));;}
    break;

  case 126:

/* Line 1455 of yacc.c  */
#line 218 "lrparser.y"
    {(yyval.pAst)=newArraySubscriptsExp(newDeclRefExp((yyvsp[(1) - (4)].id_name),NULL,NULL), (yyvsp[(3) - (4)].pAst));;}
    break;



/* Line 1455 of yacc.c  */
#line 2367 "lrparser.tab.c"
      default: break;
    }
  YY_SYMBOL_PRINT ("-> $$ =", yyr1[yyn], &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;

  /* Now `shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTOKENS] + *yyssp;
  if (0 <= yystate && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTOKENS];

  goto yynewstate;


/*------------------------------------.
| yyerrlab -- here on detecting error |
`------------------------------------*/
yyerrlab:
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if ! YYERROR_VERBOSE
      yyerror (YY_("syntax error"));
#else
      {
	YYSIZE_T yysize = yysyntax_error (0, yystate, yychar);
	if (yymsg_alloc < yysize && yymsg_alloc < YYSTACK_ALLOC_MAXIMUM)
	  {
	    YYSIZE_T yyalloc = 2 * yysize;
	    if (! (yysize <= yyalloc && yyalloc <= YYSTACK_ALLOC_MAXIMUM))
	      yyalloc = YYSTACK_ALLOC_MAXIMUM;
	    if (yymsg != yymsgbuf)
	      YYSTACK_FREE (yymsg);
	    yymsg = (char *) YYSTACK_ALLOC (yyalloc);
	    if (yymsg)
	      yymsg_alloc = yyalloc;
	    else
	      {
		yymsg = yymsgbuf;
		yymsg_alloc = sizeof yymsgbuf;
	      }
	  }

	if (0 < yysize && yysize <= yymsg_alloc)
	  {
	    (void) yysyntax_error (yymsg, yystate, yychar);
	    yyerror (yymsg);
	  }
	else
	  {
	    yyerror (YY_("syntax error"));
	    if (yysize != 0)
	      goto yyexhaustedlab;
	  }
      }
#endif
    }



  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
	 error, discard it.  */

      if (yychar <= YYEOF)
	{
	  /* Return failure if at end of input.  */
	  if (yychar == YYEOF)
	    YYABORT;
	}
      else
	{
	  yydestruct ("Error: discarding",
		      yytoken, &yylval);
	  yychar = YYEMPTY;
	}
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:

  /* Pacify compilers like GCC when the user code never invokes
     YYERROR and the label yyerrorlab therefore never appears in user
     code.  */
  if (/*CONSTCOND*/ 0)
     goto yyerrorlab;

  /* Do not reclaim the symbols of the rule which action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;	/* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (yyn != YYPACT_NINF)
	{
	  yyn += YYTERROR;
	  if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
	    {
	      yyn = yytable[yyn];
	      if (0 < yyn)
		break;
	    }
	}

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
	YYABORT;


      yydestruct ("Error: popping",
		  yystos[yystate], yyvsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  *++yyvsp = yylval;


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", yystos[yyn], yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;

#if !defined(yyoverflow) || YYERROR_VERBOSE
/*-------------------------------------------------.
| yyexhaustedlab -- memory exhaustion comes here.  |
`-------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
  if (yychar != YYEMPTY)
     yydestruct ("Cleanup: discarding lookahead",
		 yytoken, &yylval);
  /* Do not reclaim the symbols of the rule which action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
		  yystos[*yyssp], yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
#if YYERROR_VERBOSE
  if (yymsg != yymsgbuf)
    YYSTACK_FREE (yymsg);
#endif
  /* Make sure YYID is used.  */
  return YYID (yyresult);
}



/* Line 1675 of yacc.c  */
#line 221 "lrparser.y"


void yyerror(char *s)
{
    printf("%s",s);
}
int main()
{
	yyparse();
	return 0;
}
