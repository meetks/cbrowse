#include <stdio.h>
#include <string.h>
#include <assert.h>

tyepdef struct node_s {
  char* filename;
  int ref_cnt;
  //26 chars and 10 numbers
  struct node_s **ptrs;
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
  temp->filename = malloc(strlen(file) + 1);
  if (temp->filename == NULL) {
    printf("\n What !!!!");
    assert(0);
  }
  strcpy(temp->filename,file);
  return temp;
}

addnode(node_t **trie,char *str)
{
  if (*str == '\0') {
    return;
  } else {
  }
    
}
