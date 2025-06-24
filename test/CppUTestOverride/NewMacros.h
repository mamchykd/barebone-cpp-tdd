
#include <algorithm>
#include <any>
#include <map>
#include <optional>
#include <string>

/* 
 * Resolving conflicts with STL
 * The easiest way is to not pass the --include MemoryLeakDetectionNewMacros.h to the compiler,
 * but this would lose all your file and line information. So this is not recommended.
 * An alternative is to create your own NewMacros.h file which will include the STL file before the new macro is defined.
 * 
 * Reference:
 * https://cpputest.github.io/manual.html
*/

#include "CppUTest/MemoryLeakDetectorNewMacros.h"
#include "CppUTest/MemoryLeakDetectorMallocMacros.h"
