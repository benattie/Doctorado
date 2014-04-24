//#include <C:\Archivos de programa\WinPython-32bit-2.7.5.1\python-2.7.5\include\Python.h>
#include <windows.h>
#include <stdlib.h>
#include <stdio.h>

int main(){
//scripts de python
	/*char py_cmd[200];
	Py_Initialize();  // Initialize Python.
	PyRun_SimpleString("print \'hola\'");
	sprintf(py_cmd, "python spr2rsts.py %s \"  \" %s %s %d %s", marfile, csv_file, rsts_file, numrings, filename1);
	sprintf(py_cmd, "python spr2rsts.py D:\\Emanuel\\multifitting\\Al70R-spr\\New_Al70R-tex_00001.spr "  "  D:\\Emanuel\\Git\\Doctorado\\tmp\\out\\New_Al70R-tex_00001.csv D:\\Emanuel\\Git\\Doctorado\\tmp\\out\\New_Al70R-tex_00001.rsts 7 New_Al70R-tex_");
	sprintf(py_cmd, "D:\\Emanuel\\Git\\Doctorado\\tmp\\dist\\pyemb.exe");
	printf("%s", py_cmd);
	system(py_cmd);
	*/
    PROCESS_INFORMATION ProcessInfo; //This is what we get as an [out] parameter
    STARTUPINFO StartupInfo; //This is an [in] parameter
    ZeroMemory(&StartupInfo, sizeof(StartupInfo));
    StartupInfo.cb = sizeof StartupInfo ; //Only compulsory field
    if(CreateProcess(NULL, "D:\\Emanuel\\Git\\Doctorado\\tmp\\dist\\pyemb.exe hola \"  \"", //--> con esto corro el ejecutable pasando los argumentos que quiero y cierro todo cuando termina
    //if(CreateProcess("C:\\Archivos de programa\\WinPython-32bit-2.7.5.1\\python-2.7.5\\python.exe", "pyemb.py", //--> esto me deja abierto el interprete de python
	NULL,NULL,FALSE,0,NULL,
        NULL,&StartupInfo,&ProcessInfo))
    { 
	WaitForSingleObject(ProcessInfo.hProcess,INFINITE);
	printf("mundo\n");
        CloseHandle(ProcessInfo.hThread);
        CloseHandle(ProcessInfo.hProcess);
    }




}
