#include "Clock.hpp"
#include <sys/time.h>
#include <stdio.h>

int getUsec()
{
    struct timeval tv;
    gettimeofday(&tv,NULL);
    return tv.tv_sec*1000000+tv.tv_usec;
}

