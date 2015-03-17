%top{
#include <stdio.h>
#include <string.h>

#define lastchar yytext[yyleng - 1]

#define YY_BUF_SIZE 66000

typedef struct {
    char initial_state[50];
    char final_state[50];
    char letter;
} tranzition;

int i, j, k, l, m;
int c = 0;
int pharantesis_number = 0;
int is_letter = 0;
int separator_number = 0;
int open_brackets = 0;
int state_count = 0;
int alphabet_number_count = 0;
int final_state_count = 0;

int in_state_position = 0;
int state_array_number = 0;
int tranzition_array_number = 0;
int final_sates_array_number = 0;

int alphabet_list_number = -1;

char states_array[50][50];
char final_states_array[50][50];
char current_state[50];
char initial_state[50];
char alphabet_list[100];

tranzition tranzitions[5000];
tranzition modified_transition;
}

%s STATESEPARATOR TRANZITION TRANZITIONSYMBOL


letter [a-z]|[A-Z]
special "$"|"%"|"&"|"!"|"#"|"-"|"."|"/"|":"|";"|"<"|">"|"@"|"^"|"`"|"~"|"'"|"*"|"+"|"?"|"|"|"_"|"["|"]"
digit [0-9]
symbolequal {letter}|{special}|{digit}|"="
symbol {letter}|{special}|{digit}

%option noinput
%option nounput
%option noyymore

%%

[ \t\r\n] 

<INITIAL>"(" {
    BEGIN(STATESEPARATOR);
}
<TRANZITION>{
    "(" {
        pharantesis_number++;
        separator_number = 0;
        for(i = 0; i < 50; ++i) {
            modified_transition.initial_state[i] = '\0';
            modified_transition.final_state[i] = '\0';
        }
        modified_transition.letter = '\0';
        is_letter = 0;
        BEGIN(TRANZITIONSYMBOL);
    }
    "d" {
        BEGIN(TRANZITION);
    }
}
<TRANZITIONSYMBOL>{
    {symbol} {
        if(is_letter == 0) {
            modified_transition.initial_state[in_state_position] = lastchar;
            in_state_position++;
        } else if(is_letter == 1) {
            modified_transition.letter = lastchar;
        } else if(is_letter == 2) {
            modified_transition.final_state[in_state_position] = lastchar;
            in_state_position++;
        }
        BEGIN(TRANZITIONSYMBOL);
    }
    "," {
        
        separator_number++;
        in_state_position = 0;
        is_letter = 1;
        if(separator_number == 2) {
            tranzitions[tranzition_array_number] = modified_transition;
            tranzition_array_number++;
            BEGIN(TRANZITION);
        }
        else
            BEGIN(TRANZITIONSYMBOL);
    }
    "(" {
        is_letter = 0;
        in_state_position = 0;             
        pharantesis_number++;
        BEGIN(TRANZITIONSYMBOL);
    }
    ")" {
        pharantesis_number--;
        if(pharantesis_number == 0)
            BEGIN(TRANZITIONSYMBOL);
        else{
            tranzitions[tranzition_array_number] = modified_transition;
            tranzition_array_number++;
            c = 2;
            in_state_position = 0;
            BEGIN(STATESEPARATOR);
        }
    }
    "=" {
        in_state_position = 0;
        is_letter = 2;
        BEGIN(TRANZITIONSYMBOL);
    }
}
<STATESEPARATOR>{ 
   

    {symbolequal} {
                if(c == 0) {
                    states_array[state_array_number][in_state_position] = lastchar;
                    in_state_position++;
                    state_count = state_array_number;
                }else if(c == 1) {
                    alphabet_list[alphabet_list_number] = lastchar;
                    alphabet_number_count = alphabet_list_number;
                }else if(c == 2 && open_brackets < 3) {
                    current_state[in_state_position] = lastchar;
                    in_state_position++;
                }else if(open_brackets == 3) {
                    final_states_array[final_sates_array_number][in_state_position] = lastchar;
                    in_state_position++;
                    final_state_count = final_sates_array_number;
                } 
                BEGIN(STATESEPARATOR);
            }
    "(" {
        in_state_position = 0;
        state_array_number = 0;
        alphabet_list_number = 0;
        BEGIN(TRANZITION);

    }
    ")" {

    }

    "{" {
        in_state_position = 0;
        open_brackets++;
        BEGIN(STATESEPARATOR);
    }
    
    "}" {
        c++;
        BEGIN(STATESEPARATOR);
    }
    "," {
        
        if(c == 0) {
            state_array_number++;
            in_state_position = 0;
        }else if(c == 1) {
            alphabet_list_number++;
        }else if(open_brackets == 3) {
            final_sates_array_number++;
            in_state_position = 0;
        }
        BEGIN(STATESEPARATOR);
    }
    
}
%%

int main(int argc, char* argv[])
{
    FILE* f = fopen("input", "rt");

    yyrestart(f);
    yylex();
    for(i = 0; i < 50; ++i) {
        initial_state[i] = current_state[i];
    }

    state_count++;
    alphabet_number_count++;
    final_state_count++;
    if(final_state_count == 1 && final_states_array[0][0] == '\0')
        final_state_count = 0;

    char word[100];
    FILE *text_file = fopen("text", "rt");
    
    while (fgets(word, 100, text_file) != NULL) {
        l = 0;
        while(l < strlen(word) && word[l] != '\n') {
            m = l;
            while(m < strlen(word) && word[m] != '\n') {
                for(i = l; i < m; ++i) {
                    for(j = 0; j < state_count * alphabet_number_count; ++j) {
                        if(tranzitions[j].letter == word[i]) {
                            int tag = 0;
                            for(k = 0; k < 50; ++k) {
                                if(tranzitions[j].initial_state[k] != current_state[k]) {
                                    tag = 1;
                                }
                            }
                            if(tag == 0) {
                                for(k = 0; k < 50; ++k) {
                                    current_state[k] = tranzitions[j].final_state[k];
                                }
                                break;
                            }
                        }
                    }
                }
                fflush(stdin);
                for(i = 0; i < final_state_count; ++i) {
                    int tag = 0;
                    for(j = 0; j < 50; ++j) {
                        if(current_state[j] != final_states_array[i][j]) {
                            tag = 1;
                        }
                    }
                    if(tag == 0 && l != m) {
                        for(k = l; k < m; ++k) {
                            if(final_state_count > 0){
                                printf("%c", word[k]);
                            }
                        }
                        if(final_state_count > 0)
                           printf("\n");
                        break;
                    }
                }
                for(i = 0; i < 50; ++i) {
                    current_state[i] = initial_state[i];
                }
               ++m; 
            }
            ++l;
        }
    }
    fclose(f);
    fclose(text_file);

    return 0;
}
