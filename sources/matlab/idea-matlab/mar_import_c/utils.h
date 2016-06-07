/*********************************************************************
 *
 * io: 		utils.h
 *
 *********************************************************************
 * Copyright 2015,   Claudio Klein, marXperts GmbH
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *  http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *********************************************************************
 *
 * Ver      Date	Description
 * 1.3  10/08/2015	Made public under Apache License 2.0
 * 1.2	09/02/2007	Resol2stol, Resol2twotheta added
 * 1.1	09/12/2005	SplitmarName added
 * 1.0	05/07/1996	Original version
 *********************************************************************/

#ifndef _UTILS_H
#define _UTILS_H

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <math.h>
#include <time.h>
#ifndef __sgi
#include <stdlib.h>
#endif
#ifdef __unix__
#include <unistd.h>
#elif __MSDOS__ || __WIN32__ || _MSC_VER
#include <io.h>
#endif


/*
 * Functions
 */
int InputType(char*);
void WrongType(int, char*, char*);
float GetResol(float, float, float);
float Resol2twotheta(float, float);
float Resol2stol(float, float);
void RemoveBlanks(char*);
// char 	*isdir			(int createdir, char *dir);
int SplitmarName(char*, char*, char*, int*);

#endif //_UTILS_H
