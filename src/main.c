#include <stdio.h>

int main() {
	printf("Hello, World\n");

	char text[10];
	int result = scanf_s("%s", text);
	while (result != EOF) {
		printf("results: %d, input: %s\n", result, text);
		result = scanf_s("%s", text);
	}

	return 0;
}
