//
//  File.c
//  
//
//  Created by Jeff Lebrun on 12/11/20.
//

#include "include/FileSize/FileSize.h"
#include <stdio.h>

// From https://www.geeksforgeeks.org/c-program-find-size-file/
/// Gets the size of `file_name`.
/// @param file_name the name of the file to get the size from.
long int getFileSize(char filename[]) {
	FILE* fp = fopen(filename, "r");

	if (fp == NULL) {
		printf("File Not Found!\n");
		return -1;
	}

	fseek(fp, 0L, SEEK_END);

	long int res = ftell(fp);

	fclose(fp);

	return res;
} 
