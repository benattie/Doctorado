/***********************************************************************
 *
 * swap.h
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
 * History:
 * Version    Date    	Changes
 * ______________________________________________________________________
 * 2.2          10/08/15	Made public under Apache License 2.0
 * 2.1		07/11/05	if ( SGI || LINUX ) replaced by __sgi || __linux__
 **********************************************************************/
 
 #ifndef _SWAP_H
#define _SWAP_H

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
void swapint64(unsigned char*, int);
void swapint32(unsigned char*, int);
void swapint16(unsigned char*, int);
void swapfloat(float*, int);

#endif //_SWAP_H
