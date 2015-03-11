#include <stdio.h>

/* This program takes in a file of the format:
 * *1AA1*		B2*2F2*2C
 * 1AAAA1		B3*3F3*3C
 * AAAAAA  or  	B3*3F3*3C
 * 1AAAA1		B3*3F3*3C
 * *1AA1*		B2*2F2*2C
 * 
 * Output each character of the input as part of a .DB statement
 * as a specially formatted integery. Refer to cell.asm format.
 * 
 * Key:		* 	Mine
 * 		   1-8  This indicates the number of mines adjacent to the cell.
 * 		   A-F  This indicates the "group" the (empty) cell is associated
 * 		   		with. Whenver an empty cell is visited, all cells of its
 * 		   		group are marked as visited. This is because using recursion
 * 		   		in assembly is painful. Very painful.
 *
 * Note: This program will not generate a field for you, you have to design
 * 	the field yourself.
 * 	ALSO note that the assembly program expects a map of 10x10. The examples
 * 	above are smaller than that for clarity.
 */

char dec()
{
	char dec_val, byte_val;
	
	scanf("%c", &dec_val);

	if (dec_val == '\n')
		scanf("%c", &dec_val);
	
	if (dec_val - 48 < 47 && dec_val - 48 >= 0)
		byte_val = dec_val - 48;
	if (dec_val >= 65 && dec_val  <= 70)
		byte_val = dec_val - 55;
	if (dec_val == 42)
		byte_val = 32;

	return byte_val;
}

int main() {
	int i, j;
	char val;

	j = 0;

	for (i = 0; i < 100; i++)
	{
		val = dec();

		if (i % 10 == 0) {
			printf("\n .DB ");
			j++;
		}
		printf("0x");
		if (val <= 0x0f)
			printf("0");
		
		printf("%X", val);
		if (i != 10*j - 1)
			printf(", ");
	}
	return 0;
}
