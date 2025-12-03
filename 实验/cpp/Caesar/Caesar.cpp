#include<stdio.h>
#include<time.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include<string>


//凯撒密码函数声明
int REP_KeyGen();
int REP_Encrypt(short key, char* plaintext, int plength, char* ciphertext, int* clength);
int REP_Decrypt(short key, char* ciphertext, int clength, char* plaintext, int* plength);

//实现加解密参数的随机选择函数REP_KeyGen ( );
int REP_KeyGen(){
    srand((int)time(0));
    return rand()%26;
}

//实现加密函数int REP_Encrypt(short key, char*plaintext, int plength, char* ciphertext, int* clength)
int REP_Encrypt(short key, char*plaintext, int plength, char* ciphertext, int* clength)
{
    for (int i = 0; i < plength; i++)
    {
        if(plaintext[i] >= 'A' && plaintext[i] <= 'Z')
            ciphertext[i] = (char)((plaintext[i] - 'A' + key) % 26 + 'A');
        else if(plaintext[i] >= 'a' && plaintext[i] <= 'z')
            ciphertext[i] = (char)((plaintext[i] - 'a' + key) % 26 + 'a');
        else
            ciphertext[i] = plaintext[i];
    }
    ciphertext[plength] = '\0';
    *clength = plength;
    return *ciphertext;
}

//实现解密函数int REP_Decrypt(short key, char*ciphertext, int clength, char* plaintext, int* clength)
int REP_Decrypt(short key, char* ciphertext, int clength, char* plaintext, int* plength)
{
    for (int i = 0; i < clength; i++)
    {
        if(ciphertext[i] >= 'A' && ciphertext[i] <= 'Z')
            plaintext[i] = (char)((ciphertext[i] - 'A' - key + 26) % 26 + 'A');
        else if(ciphertext[i] >= 'a' && ciphertext[i] <= 'z')
            plaintext[i] = (char)((ciphertext[i] - 'a' - key + 26) % 26 + 'a');
        else
            plaintext[i] = ciphertext[i];
    }
    plaintext[clength] = '\0';
    return* plaintext;
}



int main() {
    int clength;
    int key = REP_KeyGen();
    char plaintext[99],ciphertext[99];
    printf("Enter the Plaintext: ");
    scanf("%s",plaintext);
    int plength=strlen(plaintext);
    printf("the value of key is: %d\n",key);
    REP_Encrypt(key,plaintext,plength,ciphertext,&clength);
    printf("Encrypted Text: %s\n",ciphertext);
    REP_Decrypt(key,ciphertext,clength,plaintext,&plength);
    printf("Decrypted Text: %s\n",plaintext);

    return 0;

}
