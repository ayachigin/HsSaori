// StartEnd.c
#include <Rts.h>
#include <windows.h>

static void HsStart() {
    char *argv[] = {"ghcDll", NULL}, **args = argv;
    int argc = sizeof(argv) / sizeof(argv[0]) - 1;

    hs_init(&argc, &args);
}

static void HsEnd() {
    //hs_exit();
}

static HGLOBAL hsLoad(HGLOBAL);

BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved) {
    switch(fdwReason) {
    case DLL_PROCESS_ATTACH:
        HsStart();
        break;

    case DLL_PROCESS_DETACH:
        HsEnd();
        break;

    case DLL_THREAD_ATTACH:
        break;

    case DLL_THREAD_DETACH:
        break;
    }
    return  TRUE;
}
