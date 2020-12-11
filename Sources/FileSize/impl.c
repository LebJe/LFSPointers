//
//  File.c
//  
//
//  Created by Jeff Lebrun on 12/11/20.
//

#include "include/FileSize/FileSize.h"
#include <stdio.h>

long int findSize(char file_name[]) {
	// opening the file in read mode
	FILE* fp = fopen(file_name, "r");

	// checking if the file exist or not
	if (fp == NULL) {
		printf("File Not Found!\n");
		return -1;
	}

	fseek(fp, 0L, SEEK_END);

	// calculating the size of the file
	long int res = ftell(fp);

	// closing the file
	fclose(fp);

	return res;
} 
