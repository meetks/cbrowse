#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include <assert.h>
#include <ctype.h>

#define CHILDMAX 36+1

typedef struct node_s {
  char* filename;
  //26 chars and 10 numbers
  struct node_s *ptrs[CHILDMAX];
} node_t ;

node_t *
alloc_node(const char *file)
{
  node_t *temp = NULL;
  temp = malloc(sizeof(node_t));
  if (temp == NULL) {
   printf("\n Out of Memory!!!");
   assert(0);
  }
  memset(temp, 0, sizeof(node_t));
  if (file != NULL) {
    temp->filename = malloc(strlen(file) + 1);
    if (temp->filename == NULL) {
      printf("\n What !!!!");
      assert(0);
    }
    strcpy(temp->filename,file);
  }
  return temp;
}

addnode(node_t *trie,char *str)
{
  node_t *dummy;
  char    x;

  if (*str == '\0') {
    return;
  } else {
    if (*str == '_') { 
     x = CHILDMAX - 1;
    } else {
      x = *str - 'A';
    }
    dummy = alloc_node(NULL);
    if (x > 0 && x < CHILDMAX) {
        trie->ptrs[x] = dummy;
    } else {
        return;
    }
    str++;
    addnode(trie->ptrs[x], str);
  }

}

int
findnode(node_t *trie, char *str)
{
   char x;
   static char found = 1;

   if (*str == '\0') return 1;
   if (found == 0) return 0;

   if (*str == '_') { 
     x = CHILDMAX - 1;
   } else {
     x = *str;
     x = x - 'A';
   }
   if (trie->ptrs[x]) {
     str++; 
     findnode(trie->ptrs[x], str);
   } else {
     found = 0;
     return 0;
   }

}


main()
{
   char str[1024];
   node_t *trie;
   FILE *fp;
   int i;

   trie = alloc_node(NULL);
   fp = fopen("/etc/dictionaries-common/words","r");
   if (fp == NULL) {
     printf("\n Can't read dictionary ");
     return -1;
   }

   while (!feof(fp)) {
     fgets(str,1024,fp);
     for(i = 0;i < strlen(str); i++) { 
        if (!(isalnum(str[i]))) {
            printf("\n Not a indentifier");
            printf("\n %s", str);
            continue;
        } else {
        addnode(trie, str);
        }
     }
   }
   fclose(fp);
   if( findnode(trie,"Hell")) {
     printf("\n Found the string Hell");
   }
   if( findnode(trie,"Hellp")) {
     printf("\n Found the string Hellp");
   } else {
     printf("\n Didn't find the string Hellp");
   }
}
