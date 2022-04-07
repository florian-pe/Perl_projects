#!/usr/bin/python

# Python program to print all permutations using
# Heap's algorithm
 
# Generating permutation using Heap Algorithm
def heapPermutation(a, size):
 
    # if size becomes 1 then prints the obtained
    # permutation
    if size == 1:
        print(a)
        return
 
    for i in range(size):
        heapPermutation(a, size-1)
 
        # if size is odd, swap 0th i.e (first)
        # and (size-1)th i.e (last) element
        # else If size is even, swap ith
        # and (size-1)th i.e (last) element
        if size & 1:
#         if size % 2 == 1:
            a[0], a[size-1] = a[size-1], a[0]
        else:
            a[i], a[size-1] = a[size-1], a[i]

GREEN = "\033[0;32m"
RESET = "\033[0m"

def heapPermutation(indentation, a, size):
    print(" " * indentation + "-"*40)
    print(" " * indentation + "CALL heap_permutations()")
    print(" " * indentation + f"SIZE {size}")
    print(" " * indentation + 'LIST "' + " ".join([str(i) for i in a]) + '"')



    # if size becomes 1 then prints the obtained
    # permutation
    if size == 1:
        print(" " * indentation + "$size == 1")
        print(" " * indentation + GREEN + 'PERMUTATION \"' + " ".join([str(x) for x in a]) + '"' + RESET)
        return
 
    print(" " * indentation + "FOR $i in", " ".join([str(x) for x in range(size)]))
    for i in range(size):
        print(" " * indentation + f"$i = {i}")
        print(" " * indentation + f"CALLING heap_permutations({size - 1}, \"" + " ".join([str(x) for x in a]) + '")' )
        heapPermutation(indentation+4, a, size-1)
 
        # if size is odd, swap 0th i.e (first)
        # and (size-1)th i.e (last) element
        # else If size is even, swap ith
        # and (size-1)th i.e (last) element
        if size & 1:
#         if size % 2 == 1:
            print(" " * indentation + f"{size} % 2 == 1")
            a[0], a[size-1] = a[size-1], a[0]
        else:
            print(" " * indentation + f"{size} % 2 != 1")
            a[i], a[size-1] = a[size-1], a[i]
 
 
# Driver code
# a = [1, 2, 3]
a = [1, 2, 3, 4]
n = len(a)
# heapPermutation(a, n)
heapPermutation(0, a, n)
 
# This code is contributed by ankush_953
# This code was cleaned up to by more pythonic by glubs9
