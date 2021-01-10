
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>

void *ml_malloc(size_t size);
void ml_free(void *ptr);

void *(*func_tab[]) (unsigned int arg, size_t size);

#define call_func(arg,size)	func_tab[(arg)&0xf]((arg)>>4, size)

#define define_function(n)	\
	void *function_##n(unsigned int arg, size_t size) \
	{ \
		if (arg == 0) \
			return ml_malloc (size); \
		return call_func(arg, size); \
	}

define_function(0); define_function(1); define_function(2); define_function(3);
define_function(4); define_function(5); define_function(6); define_function(7);
define_function(8); define_function(9); define_function(a); define_function(b);
define_function(c); define_function(d); define_function(e); define_function(f);

void *(*func_tab[]) (unsigned int arg, size_t size) =
{
	function_0, function_1, function_2, function_3,
	function_4, function_5, function_6, function_7,
	function_8, function_9, function_a, function_b,
	function_c, function_d, function_e, function_f,
};

void * thread_func (void *arg)
{
	void *ptrs[1024] = { };
	int pi = 0;

	while (1)
	{
		void *ptr;
		unsigned int arg;
		size_t size;

#define MIN_SIZE	64
		size = rand() % 256 + MIN_SIZE;
		arg = rand() & 0xfff;

		ptr = call_func (arg, size);
		memset (ptr, 0x55, size);

		if (arg != 0x111)
		{
			if (ptrs[pi])
				ml_free (ptrs[pi]);
			ptrs[pi] = ptr;

			pi ++;
			pi %= sizeof (ptrs) / sizeof (ptrs[0]);
		}
	}

	return NULL;
}

int main (int argc, char **argv)
{
	int num_threads = 4;

	srand (time(NULL));

	if (argv[1])
		num_threads = atoi (argv[1]);

	for (; num_threads > 0; num_threads --)
	{
		pthread_t thread;

		pthread_create (&thread, NULL, thread_func, NULL);
	}

	while (1)
		pause ();

	return 0;
}

