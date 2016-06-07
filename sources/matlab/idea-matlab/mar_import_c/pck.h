/***********************************************************************
 *
 * pck.h
 *
 *********************************************************************
 * Copyright 2015,   Claudio Klein, marXperts GmbH
 * Original code by Prof. Dr. Jan Pieter Abrahams, PSI Switzerland
 *
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
 * Version: 	2.1
 * Date:	01/08/1996
 *
 **********************************************************************/
#ifndef _PCK_H
#define _PCK_H

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
 * Definitions
 */
#define BYTE char
#define WORD short int
#define LONG int

/*
 * Functions
 */
void get_pck(FILE*, WORD*);
static void unpack_word(FILE*, int, int, WORD*);

#endif //_PCK_H
