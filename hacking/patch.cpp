#include <iostream>
#include <cstdio>

int main(int argc, char** argv)
{   
    if (argc != 2)
    {
        printf("NO FILE SPECIFIED!");
        return 2;
    }
    
    FILE* binary_executable;
    binary_executable = fopen(argv[1], "r+");

    if (!binary_executable)
    {
        printf("BAD FILE!");
        return 1;
    }

    unsigned int first_byte_to_patch = 0x31;
    char first_patch_value = 0x74;

    unsigned int second_byte_to_patch = 0x52;
    char second_patch_value[2] = {0xA8, 0xB8};

    fseek(binary_executable, first_byte_to_patch, SEEK_SET);
    fwrite(&first_patch_value, 1, 1, binary_executable);

    fseek(binary_executable, second_byte_to_patch, SEEK_SET);
    fwrite(second_patch_value, 1, 2, binary_executable);

    fclose(binary_executable);

    return 0;
}