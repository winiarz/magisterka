#include "main.hpp"
#include "boost.hpp"

int zmierzCzas( boost::function<void()> funkcja )
{
  uint czasStart = getUsec();
  funkcja();
  return getUsec() - czasStart;
}
