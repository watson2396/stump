#ifdef _MSC_VER
#define _CRT_SECURE_NO_WARNINGS
#endif

#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/types.h>

// -t, t for table, genius I know
const char* table_cmd = "-t";

const char* filename = "output/test.txt";

bool create_dir() {
    const char *dir_name = "db";
    struct stat statbuf;

    if (stat(dir_name, &statbuf) == 0) {
        printf("Directory already exists.\n");
		return true;
    } else {
        if (mkdir(dir_name, 0755) == 0) {
            printf("Directory created successfully.\n");
			return true;
        } else {
            perror("Error creating directory");
			return false;
        }
    }
}


bool create_table() {
	if (!create_dir()) { return false; } 

	// w - Writes to a file
	// a - Appends new data to a file
	// r - Reads from a file
	FILE *fptr;
	fptr = fopen(filename, "w");

	// Write some text to the file
	fprintf(fptr, "new table\n");

	// Close the file
	fclose(fptr);

	return true;
}

// command line flag for creating a table
int main() {
	printf("Hello, World\n");

	char text[10];
	int result = scanf_s("%s", text);
	while (result != EOF) {

		if (strcmp(text, table_cmd) == 0) {
			create_table();
			printf("table created\n");
		}

		result = scanf_s("%s", text);
	}

	return 0;
}
