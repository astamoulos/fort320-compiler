/* The authors of this work have released all rights to it and placed it
in the public domain under the Creative Commons CC0 1.0 waiver
(http://creativecommons.org/publicdomain/zero/1.0/).

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Retrieved from: http://en.literateprograms.org/Hash_table_(C)?oldid=19638
*/

#ifndef HASHTBL_H_INCLUDE_GUARD
#define HASHTBL_H_INCLUDE_GUARD

#include <stdlib.h>
#include "types.h"

typedef size_t hash_size;
struct hashnode_s {
	char *key;
	void *data;
	int scope; 
	int isArray;
	DataType type;
	struct hashnode_s *next;
	struct hashnode_s *fields;
};

typedef struct hashtbl {
	hash_size size;
	struct hashnode_s **nodes;
	hash_size (*hashfunc)(const char *);
} HASHTBL;


HASHTBL *hashtbl_create(hash_size size, hash_size (*hashfunc)(const char *));
void hashtbl_destroy(HASHTBL *hashtbl);
struct hashnode_s* hashtbl_insert(HASHTBL *hashtbl, char *key, void *data, int scope, DataType type, int isArray);
struct hashnode_s* hashtbl_find(HASHTBL *hashtbl, char *key, int scope);
int hashtbl_remove(HASHTBL *hashtbl, const char *key,int scope);
void *hashtbl_get(HASHTBL *hashtbl, int scope);
void printSymbolTableEntry(DataType type, int isArray);
void printFields(struct hashnode_s* fields, int indentation);
void hashtbl_print(HASHTBL *hashtbl);
void destroy_fields(struct hashnode_s* fields);
#endif
