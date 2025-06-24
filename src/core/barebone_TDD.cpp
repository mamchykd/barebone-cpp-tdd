#include "core/barebone_TDD.h"

#include <iomanip>
#include <iostream>

namespace barebonetdd
{

BareboneTDD::BareboneTDD()
{
    // Trigger a memory leak warning in cppcheck and CppUTest
    // int * q = new int[10];
    // delete q;

    // Trigger an [bugprone-branch-clone] warning in clang-tidy
    /*
    const int i = 5;
    if (i == 0)
    {
        std::cout << "low value" << std::endl;
    }
    else if (i > 3)
    {
        std::cout << "high value" << std::endl;  //  this
    }
    else if (i > 8)                              //  is identical to this
    {
      std::cout << "high value" << std::endl;
    }
    */
}

} // namespace barebonetdd
